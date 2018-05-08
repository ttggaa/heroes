--[[
    Filename:    TeamCommentDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-01-09 20:47:33
    Description: File description
--]]

local TeamCommentDialog = class("TeamCommentDialog", BasePopView)

function TeamCommentDialog:ctor(param)
    TeamCommentDialog.super.ctor(self)
    self._teamCommentData = {}
    self._teamId = param.teamId or 106
end

function TeamCommentDialog:onInit()
    self._commentModel = self._modelMgr:getModel("CommentModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._teamModel = self._modelMgr:getModel("TeamModel")
    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 1)

    self:registerClickEventByName("bg.closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("team.TeamCommentDialog")
        end
        self:close()
    end)

    self._cell = self:getUI("cell")
    self._cell:setVisible(false)

    local noneBg = self:getUI("bg.noneBg")
    noneBg:setVisible(false)

    self._conLabel = self:getUI("bg.downBg.commentTxt")
    self._conLabel:setPlaceHolder("请输入40字以内的评论")
    self._conLabel:setColor(cc.c3b(255, 255, 255))
    self._conLabel:setPlaceHolderColor(UIUtils.colorTable.ccUIInputTipColor)
    self._conLabel:addEventListener(function(sender, eventType)
        self._conLabel:setColor(cc.c3b(70, 40, 0))
        if self._conLabel:getString() == "" then
            self._conLabel:setColor(cc.c3b(255, 255, 255))
            self._conLabel:setPlaceHolderColor(UIUtils.colorTable.ccUIInputTipColor)
            self._conLabel:setPlaceHolder("请输入40字以内的评论")
        end
    end)

    local commentBtn = self:getUI("bg.downBg.commentBtn")
    self:registerClickEvent(commentBtn, function()
        print("=================", self._teamId)
        self:commentMessage()
        
    end)

    self:addTableView()
end

function TeamCommentDialog:onPopEnd(data)
    local teamDetail = self._commentModel:getTeamDetailData()
    local flag = self._teamModel:getTeamCommentFristShow(self._teamId)
    if flag == true then
        if teamDetail.daily == 0 then
            return
        end
        local desc = "近期又有" .. teamDetail.daily .. "名玩家为你点赞喔，总共被点赞" .. teamDetail.total .. "次"
        self._viewMgr:showDialog("global.GlobalSelectDialog",
            {desc = desc,
            alignNum = 1,
            -- button1 = "确定",
            -- button2 = "取消", 
            callback1 = function ()
                if self._teamModel then
                    self._teamModel:saveTeamCommentFristShow(self._teamId)
                end
            end,
            callback2 = function()
                if self._teamModel then
                    self._teamModel:saveTeamCommentFristShow(self._teamId)
                end
            end}, true)  
    end
end

function TeamCommentDialog:reflashUI(data)
    self._teamCommentData = self._commentModel:getTeamData()
    local teamDetail = self._commentModel:getTeamDetailData()
    self._hotNum = table.nums(teamDetail.hList)
    print("self._hotNum===========", self._hotNum)
    dump(teamDetail)
    local noneBg = self:getUI("bg.noneBg")
    if table.nums(self._teamCommentData) == 0 then
        noneBg:setVisible(true)
    else
        noneBg:setVisible(false)
    end
    self._tableView:reloadData()
    -- self:test()


end


-- function TeamCommentDialog:test()
--     local test1 = {}
--     test1["1"] = 1
--     test1["3"] = 2
--     test1["4"] = 3
--     test1["5"] = 4
--     test1["9"] = 5
--     local test2 = {}
--     for k,v in pairs(test1) do
--         test2[tonumber(k)] = v
--     end

--     for k,v in pairs(test2) do
--         print(k,v)
--     end
-- end


--[[
用tableview实现
--]]
function TeamCommentDialog:addTableView()
    local tableViewBg = self:getUI("bg.tableViewBg")
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height))
    self._tableView:setDelegate()
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    -- self._tableView:registerScriptHandler(function( view ) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    -- self._tableView:registerScriptHandler(function( view ) return self:scrollViewDidZoom(view) end ,cc.SCROLLVIEW_SCRIPT_ZOOM)
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

--刷新之后tableView 的定位
-- function TeamCommentDialog:searchForPosition() 
--     self._tableData = self._leagueModel:getRank()

--     local tab = self._leagueModel:getCurrRankTab()
--     local subNum = #self._tableData - (tab - 1)*20
--     if subNum < 20 then
--         self._offsetY = -1 * (tonumber(subNum) * (self._tableCellH+5))          
--     else
--         self._offsetY = -1 * 20 * (self._tableCellH+5)          
--     end
    
-- end

function TeamCommentDialog:scrollViewDidScroll(view)
    self._offsetY = view:getContentOffset().y
    local minY = 0 - #self._teamCommentData * 80 + self._tableViewHeight 
    local isDragging = view:isDragging()
    
    if isDragging then
        -- print("minY ===", isDragging, minY, self._offsetY)
        if self._offsetY >= 0 then
            if (self._offsetY - minY) > 60 and not self._reRequest then
                self._loadingMc:setPositionY(20)
                self._reRequest = true
                self._loadingMc:setVisible(true)
            elseif self._offsetY < 260 and not self._reRequest then
                self._loadingMc:setPositionY(330)
                self._reRequest = true
                self._loadingMc:setVisible(true)
            end

            if self._offsetY < 30 and self._reRequest then
                self._reRequest = false
                self._loadingMc:setVisible(false)
            end
        else
            if self._offsetY < minY - 60 and not self._reRequest then
                self._loadingMc:setPositionY(330)
                self._reRequest = true
                self._loadingMc:setVisible(true)
            end
            if self._offsetY > minY - 30 and self._reRequest then
                self._reRequest = false
                self._loadingMc:setVisible(false)
            end
        end
    else
        if self._reRequest and 0 == self._offsetY then
            self._reRequest = false
            -- 请求
            self._loadingMc:setVisible(false)
            if self._updateMailTick == nil or socket.gettime() > self._updateMailTick + 5 then
                self:getApplyGuildList(true, 1)
                self._updateMailTick = socket.gettime()
            end
        elseif self._reRequest and minY == self._offsetY then
            self._reRequest = false
            -- 请求
            self._loadingMc:setVisible(false)
            if self._updateMailTick == nil or socket.gettime() > self._updateMailTick + 5 then
                self:getApplyGuildList(true, -1)
                self._updateMailTick = socket.gettime()
            end
        end
    end
end

function TeamCommentDialog:attain()
    print("++++++++++++++selectedIndex========")
end

function TeamCommentDialog:scrollToNext(selectedIndex)
    selectedIndex = selectedIndex or 0
    for k,v in pairs(self._teamCommentData) do
        if v.roleNumLimit <= v.roleNum then
            selectedIndex = selectedIndex + 1
        end
    end
    -- print("selectedIndex========", selectedIndex)

    local tempheight = 80*(#self._teamCommentData) -- self._tableView:getContentSize().height
    local downBg = self:getUI("bg.tableViewBg")
    local tabHeight = tempheight - downBg:getContentSize().height
    if tempheight < downBg:getContentSize().height then
        -- print("+++1")
        self._tableView:setContentOffset(cc.p(0, self._tableView:getContentOffset().y))
    else
        if (tempheight - (selectedIndex)*80) > downBg:getContentSize().height then
            -- print("+++4")
            self._tableView:setContentOffset(cc.p(0, -1*(tabHeight - 80*selectedIndex)))
        else
            -- print("+++5")
            self._tableView:setContentOffset(cc.p(0, -1*tabHeight))
        end
    end
end

function TeamCommentDialog:scrollViewDidZoom(view)

end

-- 触摸时调用
function TeamCommentDialog:tableCellTouched(table,cell)

end

-- cell的尺寸大小
function TeamCommentDialog:cellSizeForTable(table,idx) 
    local width = 730 
    local height = 80
    return height, width
end

-- 创建在某个位置的cell
function TeamCommentDialog:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local indexId = idx+1
    local param = self._teamCommentData[indexId]
    if nil == cell then
        cell = cc.TableViewCell:new()
        local commentCell = self._cell:clone()
        commentCell:setPosition(7, 0)
        commentCell:setVisible(true)
        commentCell:setName("commentCell")
        cell:addChild(commentCell)
        commentCell:setSwallowTouches(false)
    end

    local commentCell = cell:getChildByName("commentCell")
    if commentCell then
        self:updateCell(commentCell, param, indexId)
        commentCell:setSwallowTouches(false)
    end
    
    return cell
end

-- 返回cell的数量
function TeamCommentDialog:numberOfCellsInTableView(table)
    return self:tableNum() -- 10 -- #self._teamCommentData -- 20 --table.nums(self._guildData)
end

function TeamCommentDialog:tableNum()
    return table.nums(self._teamCommentData)
end

function TeamCommentDialog:updateCell(inView, param, indexId)
    if not param then
        return
    end
    print("limitLen=====", os.clock())
    local reping = inView:getChildByFullName("reping")
    local cellBg = inView:getChildByFullName("cellBg")
    local name = inView:getChildByFullName("name")
    local nameBtn = inView:getChildByFullName("nameBtn")
    local pingLab = inView:getChildByFullName("pingLab")

    local zanBg = inView:getChildByFullName("zanBg")
    local zanLab = inView:getChildByFullName("zanBg.lab")
    local zanIcon = inView:getChildByFullName("zanBg.icon")
    local caiBg = inView:getChildByFullName("caiBg")
    local caiLab = inView:getChildByFullName("caiBg.lab")
    local caiIcon = inView:getChildByFullName("caiBg.icon")

    if indexId <= self._hotNum then
        if reping then
            reping:setVisible(true)
        end
        if zanIcon then
            zanIcon:loadTexture("comment_iconLikeGold.png", 1)
        end
        if cellBg then
            cellBg:loadTexture("globalPanelUI7_cellBg0.png", 1)
            cellBg:setCapInsets(cc.rect(41,41,1,20))
        end
    else
        if reping then
            reping:setVisible(false)
        end
        if zanIcon then
            zanIcon:loadTexture("comment_iconLikeGreen.png", 1)
        end
        if cellBg then
            cellBg:loadTexture("globalPanelUI7_cellBg1.png", 1)
            cellBg:setCapInsets(cc.rect(41,41,1,20))
        end
    end

    local tempFlag = 0
    if param.aId and param.aId == 0 then
        zanLab:disableEffect()
        zanLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        caiLab:disableEffect()
        caiLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    elseif param.aId and param.aId == 1 then
        zanLab:disableEffect()
        zanLab:setColor(UIUtils.colorTable.ccUIBaseColor9)
        -- zanLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        caiLab:disableEffect()
        caiLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        tempFlag = 1
    elseif param.aId and param.aId == 2 then
        zanLab:disableEffect()
        zanLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        caiLab:disableEffect()
        caiLab:setColor(UIUtils.colorTable.ccUIBaseColor9)
        -- caiLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        tempFlag = 2
    end

    zanLab:setString(param.ag)
    caiLab:setString(param.dis)
    
    local rtx = inView:getChildByName("rtx")
    if rtx then
        rtx:removeFromParent(true)
    end
    local nameStr = self:formatName(param.name)
    -- rtx = RichTextFactory:create("[color = 46280A,fontsize=22,linklinecolor = 704010ff, linklinesize = 2]".. nameStr .. "[-]", 115, 80)
    rtx = RichTextFactory:create("[color = 46280A,fontsize=22]".. nameStr .. "[-]", 115, 80)
    rtx:formatText()
    rtx:setTouchEnabled(false)
    rtx:setVerticalSpace(7)
    rtx:setName("rtx")
    rtx:setPosition(75, 37)
    rtx:setSaturation(0)
    rtx:setSwallowTouches(false)
    inView:addChild(rtx)
    UIUtils:alignRichText(rtx,{hAlign = center})
    -- local nameStr, nameBtnStr = self:limitLen(param.name)
    -- nameBtn:setString(nameBtnStr)
    -- name:setString(nameStr)
    nameBtn:setVisible(false)
    name:setVisible(false)

    -- self:registerClickEvent(rtx, function()
    --     if param.cId then
    --         self:getCommentDetail(param.cId)
    --     end
    -- end)

    local str = ""
    if ((not param.rid) and param.lId) or (param.rid and param.rid == "") then
        local comTab = tab:CommentTeam(param.lId)
        if comTab then
            str = lang(comTab.lang)
        end
    elseif param.cm then
        str = param.cm
    end
    pingLab:setString(str)

    if tempFlag == 0 then
        local callback = function()
            self:updateCell(inView, param, indexId)
        end
        self:registerClickEvent(zanBg, function()
            self:commentAttitude(param.cId, 1, indexId, callback)
        end)
        zanIcon:setScaleAnim(true)
        self:registerClickEvent(zanIcon, function()
            self:commentAttitude(param.cId, 1, indexId, callback)
        end)

        self:registerClickEvent(caiBg, function()
            self:commentAttitude(param.cId, 2, indexId, callback)
        end)
        caiIcon:setScaleAnim(true)
        self:registerClickEvent(caiIcon, function()
            self:commentAttitude(param.cId, 2, indexId, callback)
        end)
    else
        self:registerClickEvent(zanBg, function()
            self:showTishi(tempFlag)
        end)
        zanIcon:setScaleAnim(true)
        self:registerClickEvent(zanIcon, function()
            self:showTishi(tempFlag)
        end)

        self:registerClickEvent(caiBg, function()
            self:showTishi(tempFlag)
        end)
        caiIcon:setScaleAnim(true)
        self:registerClickEvent(caiIcon, function()
            self:showTishi(tempFlag)
        end)
    end
    print("limitLen==111===", os.clock())
end

function TeamCommentDialog:showTishi(flag)
    if flag == 1 then
        self._viewMgr:showTip("您已经对该评论点过赞")
    else
        self._viewMgr:showTip("您已经踩过该评论了")
    end
end

-- rid  评论人ID 为空代表官方评论
-- name 评论人名字
-- cm   评论内容
-- lId  语言表ID
-- cId  评论ID
-- ct   评论时间
-- aId  当前玩家对应该条评论的状态(0:无 1:赞 2:踩)
-- ag   赞的总数
-- dis  踩的总数
function TeamCommentDialog:commentAttitude(cId, aId, indexId, callback)
    local param = {ctype = 1, id = self._teamId, cId = cId, aId = aId}
    self._serverMgr:sendMsg("CommentServer", "commentAttitude", param, true, {}, function(result)
        -- dump(result)
        if aId == 1 then
            self._teamCommentData[indexId].aId = aId
            self._teamCommentData[indexId].ag = self._teamCommentData[indexId].ag + 1
        elseif aId == 2 then
            self._teamCommentData[indexId].aId = aId
            self._teamCommentData[indexId].dis = self._teamCommentData[indexId].dis + 1
        end
        callback()
        -- self._viewMgr:showDialog("team.TeamCommentDialog", {teamId = self._curSelectTeam.teamId})
    end)
end

-- 规范名字格式
function TeamCommentDialog:formatName(nameStr, fontSize, outlineSize)
    if not nameStr then
        return ""
    end
    -- fontsize = fontSize or 18
    -- if outlineSize then
    --     fontSize = fontSize + outlineSize*2
    -- end

    -- local nameLabel = nil
    -- local nameLen = utf8.len(nameStr)
    -- local subStr = nameStr
    -- local times = 1
    -- while true do
    --     nameLabel = cc.Label:createWithTTF(subStr, UIUtils.ttfName, fontsize)
    --     if nameLabel:getContentSize().width > 88 then
    --         subStr = utf8.sub(nameStr, 1, nameLen - times) .. "..."
    --         times = times + 1
    --     else
    --         break
    --     end
    -- end
    local subStr = self:limitLen(nameStr)
    return subStr
end

function TeamCommentDialog:limitLen(str)
    local maxNum = 8
    if not str then
        str = ""
    end
    local _, nameLen = utf8.width(str)
    local nameAdd = ""
    if nameLen > 10 then
        maxNum = 8
        nameAdd = "..."
    else
        maxNum = nameLen
    end
    local str = utf8.limitLen(str, maxNum)
    str = str .. nameAdd
    return str
end

-- function TeamCommentDialog:limitLen(str)
--     local maxNum = 8
--     if not str then
--         str = ""
--     end
--     local nameLen = self:stringLenNum(str)
--     local nameAdd = ""
--     if nameLen > 10 then
--         maxNum = 8
--         nameAdd = "..."
--     else
--         maxNum = nameLen
--     end

--     local str2 = ""
--     for i=1,maxNum+1 do
--         str2 = str2 .. "_"
--     end

--     local lenInByte = #str
--     local lenNum = 0
--     for i=1,lenInByte do
--         local curByte = string.byte(str, i)
--         if curByte>0 and curByte<=127 then
--             lenNum = lenNum + 1
--         elseif curByte>=192 and curByte<225 then
--             lenNum = lenNum + 2
--             maxNum = maxNum + 1
--         elseif curByte>=225 and curByte<=247 then
--             lenNum = lenNum + 3
--             maxNum = maxNum + 1
--         end
--         if lenNum >= maxNum then
--             break
--         end
--     end
--     str = string.sub(str, 1, lenNum)
--     str = str .. nameAdd
--     return str, str2
-- end

function TeamCommentDialog:stringLenNum(str)
    local lenInByte = #str
    local lenNum = 0
    for i=1,lenInByte do
        local curByte = string.byte(str, i)
        if curByte>0 and curByte<=127 then
            lenNum = lenNum + 1
        elseif curByte>=192 and curByte<=247 then
            lenNum = lenNum + 2
        end
    end
    return lenNum
end

-- 评论
function TeamCommentDialog:commentMessage()
    local conLabel = self._conLabel:getString()
    conLabel = string.gsub(conLabel, "^%s*(.-)%s*$", "%1")
    -- if conLabel == "" or string.gsub(conLabel, " ", "") == "" then
    if conLabel == "" then
        self._viewMgr:showTip("输入内容为空")
        return
    end
    local userData = self._userModel:getData()
    local curServerTime = self._userModel:getCurServerTime()
    local param = {ctype = 1, id = self._teamId, content = conLabel}
    self._serverMgr:sendMsg("CommentServer", "commentMessage", param, true, {}, function(result)
        -- dump(result, "result======", 10)
        -- self._viewMgr:showDialog("team.TeamCommentDialog", {teamId = self._curSelectTeam.teamId})
        self:addTableCell(conLabel, result["cId"])
        self._conLabel:setString("")
    end, function(errorId)
        if tonumber(errorId) == 125 then
            self._viewMgr:showTip("只能为中文、英文、数字")
        elseif tonumber(errorId) == 126 then
            self._viewMgr:showTip("字符串长度不足")
        elseif tonumber(errorId) == 127 then
            self._viewMgr:showTip("字符串长度超出限制")
        elseif tonumber(errorId) == 117 then
            self._viewMgr:showTip("输入内容含有非法字符")
        elseif tonumber(errorId) == 4514 then
            self._viewMgr:showTip("输入内容含有非法字符")
        elseif tonumber(errorId) == 4515 then
            self._viewMgr:showTip("输入内容为空")
        elseif tonumber(errorId) == 4504 then
            local str = lang("COMTERM_NUM1")
            self._viewMgr:showTip(str)
        end
    end)
end

function TeamCommentDialog:addTableCell(conLabel, cId)
    -- local conLabel = self._conLabel:getString()
    local userData = self._userModel:getData()
    local curServerTime = self._userModel:getCurServerTime()

    local tempValue = {}
    tempValue["aId"]  = 0
    tempValue["ag"]  = 0
    tempValue["cId"]  = cId
    tempValue["cm"]  = conLabel
    tempValue["ct"]  = curServerTime
    tempValue["dis"]  = 0
    tempValue["lId"]  = 0
    tempValue["name"]  = userData.name
    tempValue["rid"]  = userData._id
    if table.nums(self._teamCommentData) >= 3 then
        table.insert(self._teamCommentData, 4, tempValue)
    else
        local insertId = table.nums(self._teamCommentData) + 1
        table.insert(self._teamCommentData, insertId, tempValue)
    end

    local noneBg = self:getUI("bg.noneBg")
    if table.nums(self._teamCommentData) == 0 then
        noneBg:setVisible(true)
    else
        noneBg:setVisible(false)
    end
    
    self._tableView:reloadData()
end

function TeamCommentDialog:getCommentDetail(cId)
    local param = {ctype = 1, id = self._teamId, cId = cId}
    self._serverMgr:sendMsg("CommentServer", "getCommentDetail", param, true, {}, function(result)
        -- dump(result)
        -- data.rank = self._clickItemData.rank
        -- data.usid = self._clickItemData.usid
        -- data.isNotShowBtn = true
        self._viewMgr:showDialog("arena.DialogArenaUserInfo", result, true)
    end)
end

return TeamCommentDialog
