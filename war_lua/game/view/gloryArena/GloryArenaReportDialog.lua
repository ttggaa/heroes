--[[
    FileName:       GloryArenaReportDialog
    Author:         <dongcheng@playcrab.com>
    Datetime:       2018-08-13 09:57:11
    Description:    荣耀竞技场战报
]]

local GloryArenaReportDialog = class("GloryArenaReportDialog", BasePopView)

function GloryArenaReportDialog:ctor()
    self.super.ctor(self)
end


-- 第一次被加到父节点时候调用
function GloryArenaReportDialog:onAdd()

end

--获取打开UI的时候加载的资源
function GloryArenaReportDialog:getAsyncRes()
    return 
         {
--            {"asset/ui/battle4.plist", "asset/ui/battle4.png"},
            {"asset/ui/gloryArena.plist", "asset/ui/gloryArena.png"},
         }
end

local childName = {
    --按钮
    {name = "bg", childName = "bg"},
    {name = "title", childName = "bg.headBg.title"},
    {name = "textFeild", childName = "bg.textFeild"},
    {name = "okBtn", childName = "bg.okBtn"},
    {name = "closeBtn", childName = "bg.closeBtn", isBtn = true},
    {name = "noneNode", childName = "bg.noneNode"},
    {name = "shareLayer", childName = "bg.shareLayer"},
    {name = "tableBg", childName = "bg.tableBg"},
    {name = "scrollItem", childName = "bg.scrollItem"},
    {name = "shareBg", childName = "bg.shareLayer.bg"},
    {name = "playBg", childName = "bg.shareLayer.bg_1"},
}

function GloryArenaReportDialog:onRewardCallback(_, _x, _y, sender)
    if sender == nil or self._childNodeTable == nil then
        return 
    end

    if sender:getName() == "okBtn" then
        local reportID = self._childNodeTable.textFeild:getString()
        self:playReportBattle(reportID)
    elseif sender:getName() == "closeBtn" then
        self:close()
        UIUtils:reloadLuaFile("gloryArena.GloryArenaReportDialog")
    end
end

-- 初始化UI后会调用, 有需要请覆盖
function GloryArenaReportDialog:onInit()
    self._childNodeTable = self:lGetChildrens(self._widget, childName)
    self._reportData = {}
    if self._childNodeTable == nil then
        return
    end
    -- self:disableTextEffect()
    UIUtils:setTitleFormat(self._childNodeTable.title,1)
    
    self:addTableView()

    -- 查看所有战报···
    if OS_IS_WINDOWS and self._childNodeTable.okBtn then
        self._childNodeTable.okBtn:setVisible(true)
        self._childNodeTable.textFeild:setVisible(true)
        self._childNodeTable.textFeild:addEventListener(function(sender, eventType)
        if eventType == 0 then
            self._childNodeTable.textFeild:setPlaceHolder("")
        elseif eventType == 1 then
            self._childNodeTable.textFeild:setPlaceHolder("请输入战报ID！")
        elseif eventType == 2 then
        elseif eventType == 3 then
            if self._childNodeTable.textFeild:getString() == "" then
                self._childNodeTable.textFeild:setPlaceHolder("请输入战报ID！")
            end
        end
    end)
    elseif self._childNodeTable.okBtn then
        self._childNodeTable.okBtn:setVisible(false)
        self._childNodeTable.textFeild:setVisible(false)
    end
    
    --wangyan
    self._childNodeTable.shareLayer:setVisible(false)
    self._childNodeTable.shareBg:setVisible(false)
    self._childNodeTable.playBg:setVisible(false)
    self._childNodeTable.scrollItem:setVisible(false)
--    self._childNodeTable.playBg:setAnchorPoint(cc.p(0.5, 1))

    self._childNodeTable.noneNode:setVisible(false)

    self._gloryArenaModel = self._modelMgr:getModel("GloryArenaModel")
end

-- 接收自定义消息
function GloryArenaReportDialog:reflashUI(data)
    self._reportData = self._gloryArenaModel:lGetGloryArenaReport()
	if self._tableView then
        self._tableView:reloadData()
    end

    dump(self._reportData)

    if self._reportData == nil or #self._reportData == 0 then
        self._childNodeTable.noneNode:setVisible(true)
    else
        self._childNodeTable.noneNode:setVisible(false)
    end
end

function GloryArenaReportDialog:addTableView()
    local tableView = cc.TableView:create(cc.size(640, 465))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(10,10))
    tableView:setAnchorPoint(cc.p(0,0))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    self._childNodeTable.tableBg:addChild(tableView)
    tableView:registerScriptHandler(function( view )
        return self:scrollViewDidScroll(view)
    end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(function( view )
        return self:scrollViewDidZoom(view)
    end ,cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(function ( view,cell )
        return self:tableCellTouched(view,cell)
    end,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(function( view,index )
        return self:cellSizeForTable(view,index)
    end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function ( view,index )
        return self:tableCellAtIndex(view,index)
    end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function ( view )
        return self:numberOfCellsInTableView(view)
    end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
--    tableView:reloadData()
    self._tableView = tableView
end


function GloryArenaReportDialog:scrollViewDidScroll(view)
    self._inScrolling = view:isDragging()
end

function GloryArenaReportDialog:scrollViewDidZoom(view)
end

function GloryArenaReportDialog:tableCellTouched(view,cell)
end

function GloryArenaReportDialog:cellSizeForTable(view,idx) 
    return 103,638
end

function GloryArenaReportDialog:tableCellAtIndex(view, idx)
    local strValue = string.format("%d",idx)
    local cell = view:dequeueCell()
    local label = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
    end
    local item = cell:getChildByName("item")
    if not item then
        item = self._childNodeTable.scrollItem:clone()
        item:setVisible(true)
        item:setAnchorPoint(cc.p(0,0))
        item:setPosition(cc.p(0, 0))
        item:setSwallowTouches(false)
        item:setName("item")
        cell:addChild(item)
    end
    self:updeteItem(item, idx + 1)
    return cell
end

function GloryArenaReportDialog:numberOfCellsInTableView(view)
   return #self._reportData or 0
end

local itemConfigName = {
    {name = "resultImgBg", childName = "resultImgBg"},
    {name = "winImg", childName = "winImg"},
    {name = "failImg", childName = "failImg"},
    {name = "itemNode", childName = "itemNode"},
    {name = "itemName", childName = "itemName", isText = true},
    {name = "reportKey_lab", childName = "reportKey_lab", isText = true},
    {name = "upImg", childName = "upImg"},
    {name = "upDiff", childName = "upImg.diff", isText = true},
    {name = "downImg", childName = "downImg"},
    {name = "downDiff", childName = "downImg.diff", isText = true},
    {name = "drawImg", childName = "drawImg"},
    {name = "shareBtn", childName = "shareBtn"},
    {name = "reviewBtn", childName = "reviewBtn"},
    {name = "report_layout", childName = "report_layout"},
    {name = "resultBg_img", childName = "report_layout.resultBg_img", starNum = 1, endNum = 3},
}

function GloryArenaReportDialog:showPlayerInfo(data)
    if  data == nil then
        return
    end
    dump(data)
    local userId = self._modelMgr:getModel("UserModel"):getUID()
    local isMeAtk = userId == data.atkId
    local str = "_def"
    if not isMeAtk then
        str = "_atk"
    end
    self._serverMgr:sendMsg("CrossArenaServer", "getDetailInfo", {id = data[str .. "Id"]},true ,{}, function(resule)
        self._viewMgr:showDialog("gloryArena.GloryArenaUserInfoDialog", resule.info)
    end)
end

function GloryArenaReportDialog:updeteItem(item, index)
    local _data = self._reportData[index]
    if item == nil or _data == nil then
        return
    end
    local childNodeTable = self:lGetChildrens(item, itemConfigName)
    if childNodeTable then
        local isWin = false

         self:registerClickEvent(item,
        function()
            if not self._inScrolling then
                self:showPlayerInfo(_data)
            else
                self._inScrolling = false
            end
        end)
        item:setSwallowTouches(false)

        local userId = self._modelMgr:getModel("UserModel"):getUID()
        local isMeAtk = userId == _data.atkId

        local prefix = "atk"
        local antiPrefix = "def"
        if isMeAtk then
            prefix = "def"
            antiPrefix = "atk"
        else
            prefix = "atk"
            antiPrefix = "def"
        end
        
        if (_data.win == 1 and userId == _data.atkId) or (_data.win == 2 and userId == _data.defId) then
            isWin = true
        end

        childNodeTable.failImg:setVisible(not isWin)
        childNodeTable.winImg:setVisible(isWin)
        local name = _data[prefix .. "Name"]
        childNodeTable.itemName:setString(name or "神勇妖皇")

        childNodeTable.upImg:setVisible(false)
        childNodeTable.downImg:setVisible(false)
        childNodeTable.drawImg:setVisible(false)

        childNodeTable.reportKey_lab:setString(_data.chalKey or "")

        -- 判断排名是否变化
        local diffRank = _data.defRank - _data.atkRank
       
        if isWin and userId == _data.atkId then
            if diffRank > 0 then
                childNodeTable.upImg:setVisible(true)
                childNodeTable.upDiff:setString("+" .. (diffRank))
                childNodeTable.upDiff:setColor(cc.c3b(10, 245, 8))
                childNodeTable.upDiff:enableOutline(cc.c3b(0, 0, 0), 1)
            else
                childNodeTable.drawImg:setVisible(true)
            end
        elseif not isWin and userId == _data.defId then
            if diffRank > 0 then
                childNodeTable.downImg:setVisible(true)
                childNodeTable.downDiff:setString("-" .. (diffRank))
                childNodeTable.downDiff:enableOutline(cc.c3b(0, 0, 0), 1)
            else
                childNodeTable.drawImg:setVisible(true)
            end
        else
            childNodeTable.drawImg:setVisible(true)
        end

        if _data.change and _data.change == 0 then
            childNodeTable.upImg:setVisible(false)
            childNodeTable.downImg:setVisible(false)
            childNodeTable.drawImg:setVisible(true)
        end

        for key, var in ipairs(childNodeTable.resultBg_img) do
            if var then
                if _data.battles and _data.battles[key] then
--                    local result_img = var:getChildByName("result_img")
                    local _isWin = 2
                    if (isMeAtk and _data.battles[key].win == 1) or (not isMeAtk and _data.battles[key].win == 2) then
                        _isWin = 1
                    end
                    var:setVisible(true)
                    var:loadTexture("globalImage_winlose_" .. (_isWin or 2) .. ".png", ccui.TextureResType.plistType)
                else
                    var:setVisible(false)
                end
            end
        end
        
        local lv = _data[prefix .. "Lvl"] or 0
	    local avatar = _data[prefix .. "Avatar"]
        local plvl = _data[prefix .. "Plvl"]
        local headP = {avatar = avatar,level = lv ,tp = 4, avatarFrame=_data[prefix .. "AvatarFrame"], plvl = plvl}
        local icon = childNodeTable.itemNode:getChildByName("icon")
        if not icon then
            icon = IconUtils:createHeadIconById(headP) 
	        icon:setAnchorPoint(cc.p(0,0))
            icon:setPosition(cc.p(-20, -8))
            icon:setName("icon")
	        childNodeTable.itemNode:addChild(icon)
            childNodeTable.itemNode:setSwallowTouches(false)
        else    
            IconUtils:updateHeadIconByView(icon, headP) 
        end
        self:registerClickEvent(childNodeTable.shareBtn, function(_, x, y, sender)
            --分享
           self:shareBtnClickEvent(sender, _data, isMeAtk, isWin)
        end)

        self:registerClickEvent(childNodeTable.reviewBtn, function(_, x, y, sender)
            --回放
            self:playBtnClickEvent(sender, _data, isMeAtk)
        end)

    end
end

--观看方式的选择界面
function GloryArenaReportDialog:playBtnClickEvent(inBtn, data, isMeAtk)
    if data == nil or data.battles == nil then
        return
    end
    local shareLayer = self:getUI("bg.shareLayer")
    shareLayer:setVisible(true)
    self:registerClickEvent(shareLayer, function()
        shareLayer:setVisible(false)
        end)

    local bg = shareLayer:getChildByFullName("bg")
    local bg_1 = shareLayer:getChildByFullName("bg_1")
    bg_1:setVisible(true)
    bg:setVisible(false)

    local point1 = inBtn:convertToWorldSpace(cc.p(0, 0)) 
    point1 = shareLayer:convertToNodeSpace(point1)
    local disY = bg:getContentSize().height
    if point1.y - disY - 5 <= 10 then
        bg_1:setPosition(point1.x, point1.y + disY * 0.5 - 7 + inBtn:getContentSize().height)
    else
        bg_1:setPosition(point1.x, point1.y - disY * 0.5 - 5)
    end
    local playBtn = {}
    for i = 1, 3 do
        playBtn[i] = bg_1:getChildByName("play_btn" .. i)
        if data.battles[i] then
            playBtn[i]:setTouchEnabled(true)
            playBtn[i]:setVisible(true)
            playBtn[i]:getChildByName("title"):setString("第" .. i .. "场")
            self:lSetBtnTitle(playBtn[i])
            local isWin = 2
            if (isMeAtk and data.battles[i].win == 1) or (not isMeAtk and data.battles[i].win == 2) then
                isWin = 1
            end
            playBtn[i]:getChildByFullName("icon"):loadTexture("globalImage_winlose_" .. (isWin or 3) .. ".png", ccui.TextureResType.plistType)
--            Image_72
            self:registerClickEvent(playBtn[i], function(_, x, y, sender)
                --回放  
                local _sec = ModelManager:getInstance():getModel("UserModel"):getServerId()
                self._serverMgr:sendMsg("CrossArenaServer","getBattleReport",{reportKey = data.battles[i].reportKey, sec = _sec, type = 1},true,{},function( result )
                    self:playBackBattle(result, data, isMeAtk)
                end)
            end)
        else
            playBtn[i]:setTouchEnabled(false)
            playBtn[i]:setVisible(false)
        end
    end

end


--战斗回放
function GloryArenaReportDialog:playBackBattle(result,data,isMeAtk)
    local left 
	local right 
    left  = self:initBattleData(result.atk)
    right = self:initBattleData(result.def)
    BattleUtils.disableSRData()
    
    BattleUtils.enterBattleView_GloryArena(left, right, result.r1, result.r2, false,
        function(info, callback)
            -- 战斗结束
            callback(info)
        end,
        function (info)
            -- 退出战斗
        end, false, not isMeAtk
    )
end

--分享方式选择界面 by wangyan
function GloryArenaReportDialog:shareBtnClickEvent(inBtn, data, isMeAtk,isWin)
    local shareLayer = self:getUI("bg.shareLayer")
    shareLayer:setVisible(true)
    self:registerClickEvent(shareLayer, function()
        shareLayer:setVisible(false)
        end)

    local bg = shareLayer:getChildByFullName("bg")
    local bg_1 = shareLayer:getChildByFullName("bg_1")
    bg_1:setVisible(false)
    bg:setVisible(true)
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

    local _data = {{}, {}}
    if data.battles then
        for key, var in ipairs(data.battles) do
            if var then
                _data[1][key] = var.reportKey
                local _isWin = 2
                if (isMeAtk and var.win == 1) or (not isMeAtk and var.win == 2) then
                    _isWin = 1
                end
                _data[2][key] = _isWin
            end
        end
    end
    -- _data._isMeAtk = isMeAtk
    self:registerClickEvent(shareBtn1, function()
        shareLayer:setVisible(false)
        local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
        if self._sendTime and (nowTime - self._sendTime) < 300 then
            self._viewMgr:showTip(lang("REPLAY_TIP_FREQ"))
            return 
        end
        local desTxt = lang("REPLAY_GLORYARENA")
        local enemyName = ""
        if isMeAtk then
            enemyName = data.defName 
        else
            enemyName = data.atkName
        end
        desTxt = string.gsub(desTxt,"{$enemyname}",enemyName)
        
        local param1 = {
            reportInfo = {
                reportKey = _data, 
                enemyName = enemyName,
                _isMeAtk = isMeAtk,
            }
        }
        local _, isInfoBanned, sendData = self._modelMgr:getModel("ChatModel"):paramHandle("replay2", param1)
        if isInfoBanned == true then
            self._chatModel:pushData(sendData)
        else
            self._serverMgr:sendMsg("ChatServer", "sendMessage", sendData, true, {}, function (result)
                ViewManager:getInstance():showTip(lang("REPLAY_TIP"))
                self._sendTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
            end)  
        end
        end)

    -- 分享给好友
    local shareBtn2 = shareLayer:getChildByFullName("bg.shareBtn2")
    shareBtn2:setVisible(false)
    local _bg = shareLayer:getChildByFullName("bg")
    _bg:setContentSize(_bg:getContentSize().width, 80)
    shareBtn1:setPositionY(38)
--    shareBtn2:setVisible(false)
--    local _bg = shareLayer:getChildByFullName("bg")
--    _bg:setContentSize(_bg:getContentSize().width, 80)
--    shareBtn1:setPositionY(38)

--    shareLayer:getChildByFullName("bg.shareBtn2.title"):enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine2, 2)
--    if not GameStatic.appleExamine and (sdkMgr:isWX() or sdkMgr:isQQ()) then
--        shareBtn2:setVisible(true)
--    else
--        shareBtn2:setVisible(false)
--        local _bg = shareLayer:getChildByFullName("bg")
--        _bg:setContentSize(_bg:getContentSize().width, 80)
--        shareBtn1:setPositionY(38)
--    end

--    local platIcon = shareLayer:getChildByFullName("bg.shareBtn2.icon")
--    if sdkMgr:isQQ() == true then
--        platIcon:loadTexture("tencentIcon_qq.png", 1)
--    elseif sdkMgr:isWX() == true then
--        platIcon:loadTexture("tencentIcon_wx.png", 1)
--    else
--        -- platIcon:loadTexture("tencentIcon_qq.png", 1)
--        -- shareBtn2:setVisible(false)
--    end 

--    self:registerClickEvent(shareBtn2, function()
--        shareLayer:setVisible(false)

--        local enemyName = ""
--        local selfName = ""
--        if isMeAtk then
--            enemyName = data.defName
--            selfName = data.atkName
--        else
--            enemyName = data.atkName
--            selfName = data.atkName
--        end
--        local desTxt = lang("REPORTSHARE_DES1")
--        local userData = self._modelMgr:getModel("UserModel"):getData()
--        desTxt = string.gsub(desTxt,"{$name1}",userData["name"] or "")
--        desTxt = string.gsub(desTxt,"{$name2}",enemyName)

--        local param = {}
--        param.message_ext = "t=1,k=".. data.chalKey ..",s=".. GameStatic.sec ..",bt=3,l=".. selfName ..",r=".. enemyName ..""
--        param.scene = 2
--        param.title = lang("REPORTSHARE_GLORYARENA_TITLE1")
--        param.desc  = desTxt
--        param.media_tag = sdkMgr.SHARE_TAG.MSG_INVITE
--        sdkMgr:sendToPlatform(param, function(code, data) 
--        end)
--    end)
end

function GloryArenaReportDialog:initBattleData( reportData )
	return BattleUtils.jsonData2lua_battleData(reportData)
end

function GloryArenaReportDialog:reviewTheBattle(	result,reportData,isMeAtk,isWin )
	local left 
	local right 
    left  = self:initBattleData(result.atk)
    right = self:initBattleData(result.def)
    BattleUtils.disableSRData()
	BattleUtils.enterBattleView_Arena(left, right, result.r1, result.r2, 1, not isMeAtk,
    function (info, callback)
        -- 战斗结束
        if isMeAtk and isWin then
            local arenaInfo = {}
            arenaInfo.rank,arenaInfo.preRank,arenaInfo.preHRank = reportData.defRank,reportData.atkRank,reportData.atkRank
            info.arenaInfo = arenaInfo
        end
        callback(info)
    end,
    function (info)
        -- 退出战斗
    end)
end

function GloryArenaReportDialog:playReportBattle(reportID)
    local globalServerUrl = AppInformation:getInstance():getValue("global_server_url", GameStatic.httpAddress_global)
    if GameStatic.use_globalExPort and RestartMgr.globalUrl_planB then
        globalServerUrl = RestartMgr.globalUrl_planB
    end
    print("globalServerUrl: ", globalServerUrl)
    local param = {}
    param.mod = "global"
    param.act = "getCrossArenaBattleData"
    param.reportKey = tostring(reportID)
    -- self._battleInfo.k
    param.sec = GameStatic.sec
    param.method = "system.sysInterface"
    HttpManager:getInstance():sendMsg(globalServerUrl, nil, param, 
    function(inData)
        if inData.result ~= nil and inData.result.bcode ~= 1 then
--            dump(inData.result)
            ViewManager:getInstance():showDialog("gloryArena.GloryArenaDuelDialog", inData.result)
        else
            ViewManager:getInstance():showTip(lang("REPORTSHARE_ERROR"))
        end
    end,
    function(status, errorCode, response)
        ViewManager:getInstance():showTip(lang("REPORTSHARE_ERROR"))
    end,
    GameStatic.useHttpDns_Global)
end

function GloryArenaReportDialog:dtor()
    childName = nil
    itemConfigName = nil
end

return GloryArenaReportDialog