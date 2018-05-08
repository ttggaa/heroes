--
-- Author: <ligen@playcrab.com>
-- Date: 2017-01-05 21:27:29
--
local CloudCityCommentView = class("CloudCityCommentView", BasePopView)

function CloudCityCommentView:ctor(data)
    CloudCityCommentView.super.ctor(self)

    self._rankData = data.data

    self._stageId = data.stageId

    -- 评论信息
    self._commentData = data.cData

    -- 评论类型
    self._ctype = data.ctype

    -- 排行榜类型
    self._rankType = data.rankType

    self._userModel = self._modelMgr:getModel("UserModel")
    self._rankModel = self._modelMgr:getModel("RankModel")

    self._tableData = {}
end

function CloudCityCommentView:onInit()
    self:registerClickEventByName("bg.closeBtn", function()
        self:close()
        UIUtils:reloadLuaFile("cloudcity.CloudCityCommentView")
    end)

    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 1)
    title:setString("战斗评论")

    local userNode = self:getUI("bg.userNode")

    local icon = IconUtils:createHeadIconById({avatar = self._rankData.avatar,tp = 3,avatarFrame = self._rankData["avatarFrame"]})
	icon:setAnchorPoint(cc.p(0.5,0.5))
	icon:setPosition(48,48)
	userNode:addChild(icon)

    local nameBg = userNode:getChildByFullName("nameBg")
    nameBg:setVisible(false)

    local nameLabel = userNode:getChildByFullName("nameLabel")
    nameLabel:setFontName(UIUtils.ttfName)
    nameLabel:setString(self._rankData.name)

--     dump(self._rankData)
    local vipLabel = cc.Label:createWithBMFont(UIUtils.bmfName_vip, "v" .. self._rankData.vipLvl)
    vipLabel:setName("vipLabel")
    vipLabel:setAnchorPoint(cc.p(0, 0.5))
    vipLabel:setPosition(nameLabel:getPositionX() + nameLabel:getContentSize().width + 5, nameLabel:getPositionY())
    userNode:addChild(vipLabel)
    vipLabel:setVisible(self._rankData.vipLvl ~= 0)

    if self._rankData.vipLvl == 0 then
        nameBg:setContentSize(nameLabel:getContentSize().width + 40, 34)
    else
        nameBg:setContentSize(nameLabel:getContentSize().width + vipLabel:getContentSize().width + 45, 34)
    end

    local rankLabel = userNode:getChildByFullName("rankLabel")
    rankLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    rankLabel:setFontName(UIUtils.ttfName)
    rankLabel:setString("第" .. tostring(self._rankData.rank) .. "名")

    local camerBgGuang = self:getUI("bg.camerBgGuang")
    local cameraBtnGuang = camerBgGuang:getChildByFullName("cameraBtnGuang")
    self:registerClickEvent(cameraBtnGuang, function()
--        self._viewMgr:showTip("光之回放")
        self:playReport(12)
    end)

    local labelGuang = camerBgGuang:getChildByFullName("labelGuang")
    labelGuang:setColor(cc.c3b(255,241,180))
    labelGuang:enable2Color(1, cc.c4b(235,192,19,255))
	labelGuang:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    labelGuang:setString("光之试炼")

    local camerBgAn = self:getUI("bg.camerBgAn")
    local cameraBtnAn = camerBgAn:getChildByFullName("cameraBtnAn")
    self:registerClickEvent(cameraBtnAn, function()
--        self._viewMgr:showTip("暗之回放")
        self:playReport(13)
    end)

    local labelAn = camerBgAn:getChildByFullName("labelAn")
    labelAn:setColor(cc.c3b(255,241,180))
    labelAn:enable2Color(1, cc.c4b(235,192,19,255))
	labelAn:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    labelAn:setString("暗之试炼")

    self._commentNode = self:getUI("bg.commentNode")
    self._commentItem = self._commentNode:getChildByFullName("item")
    self._commentItem:setVisible(false)

    self:formatTableData()
    self:addTableView()

    self._nothingPic = self._commentNode:getChildByFullName("imgNothing")
    local nothingLabel = self._nothingPic:getChildByFullName("notingLabel")
    nothingLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    nothingLabel:setString("暂无评论")
    if #self._tableData ~= 0 then
        self._nothingPic:setVisible(false)
    end

    self._inputLabel = self:getUI("bg.inputBg.inputText")
    self._inputLabel:setPlaceHolderColor(UIUtils.colorTable.ccUIInputTipColor)
    self._inputLabel:setPlaceHolder("请输入40字以内的评论")
    self._inputLabel:setColor(cc.c3b(255, 255, 255))
    self._inputLabel:addEventListener(function(sender, eventType)
        self._inputLabel:setColor(cc.c3b(70, 40, 0))
        if self._inputLabel:getString() == "" then
            self._inputLabel:setColor(cc.c3b(255, 255, 255))
            self._inputLabel:setPlaceHolderColor(UIUtils.colorTable.ccUIInputTipColor)
            self._inputLabel:setPlaceHolder("请输入40字以内的评论")
        end
    end)

    self:registerClickEventByName("bg.sendBtn", function()
        self:commentMessage()
        self._inputLabel:setString("")
    end)
end

-- 换 tableView
function CloudCityCommentView:addTableView()
    local tableView = cc.TableView:create(cc.size(self._commentNode:getContentSize().width, self._commentNode:getContentSize().height))
    tableView:setColor(cc.c3b(255,255,255))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(4, 0))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._commentNode:addChild(tableView)
    tableView:registerScriptHandler(function( view )
        return self:scrollViewDidScroll(view)
    end ,cc.SCROLLVIEW_SCRIPT_SCROLL)

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

function CloudCityCommentView:scrollViewDidScroll(view)
end

function CloudCityCommentView:tableCellTouched(table,cell)
end

function CloudCityCommentView:cellSizeForTable(table,idx) 
    return self._commentItem:getContentSize().height, self._commentItem:getContentSize().width
end

function CloudCityCommentView:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
        local item = self._commentItem:clone()
        item:setName("item")
        item:setPosition(cc.p(0,0))
        item:setAnchorPoint(cc.p(0,0))
        cell:addChild(item)
    end

    self:updateItem(cell:getChildByName("item"), self._tableData[idx+1], idx + 1)
    return cell
end

function CloudCityCommentView:numberOfCellsInTableView(table)
   return #self._tableData
end

function CloudCityCommentView:updateItem(tempItem, data, index)
    if data == nil or tempItem == nil then return end

    local item = tempItem
    item:setVisible(true)

    local bgHot = item:getChildByFullName("bgHot")
    local bgNormal = item:getChildByFullName("bgNormal")
    local hotIcon = item:getChildByFullName("hotIcon")

    local likeGoldBtn = item:getChildByFullName("likeBg.likeGoldBtn")
    local likeGreenBtn = item:getChildByFullName("likeBg.likeGreenBtn")

    local likeBtn = nil
    if index <= 3 then
        bgHot:setVisible(true)
        bgNormal:setVisible(false)
        likeGoldBtn:setVisible(true)
        likeGreenBtn:setVisible(false)
        hotIcon:setVisible(true)
        likeBtn = likeGoldBtn
    else
        bgHot:setVisible(false)
        bgNormal:setVisible(true)
        likeGoldBtn:setVisible(false)
        likeGreenBtn:setVisible(true)
        hotIcon:setVisible(false)
        likeBtn = likeGreenBtn
    end

    local rtx = item:getChildByName("rtx")
    if rtx then
        rtx:removeFromParent(true)
    end
    local nameStr = self:formatName(data.name)
    rtx = RichTextFactory:create("[color = 46280A,fontsize=22,linklinecolor = 704010ff, linklinesize = 2]".. nameStr .. "[-]", 115, 80)
    rtx:formatText()
    rtx:setTouchEnabled(false)
    rtx:setVerticalSpace(7)
    rtx:setName("rtx")
    rtx:setPosition(75, 37)
    rtx:setSaturation(0)
    rtx:setSwallowTouches(false)
    item:addChild(rtx)
    UIUtils:alignRichText(rtx,{hAlign = center})

    local touchRect = item:getChildByFullName("nameTouch")
    self:registerClickEvent(touchRect, function()
        self:showUserDetailInfo(self._stageId, data.cId)
    end )

    local commentLabel = item:getChildByFullName("commnetLabel")
    commentLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    commentLabel:setString(data.cm or " ")

    self:registerClickEvent(likeBtn, function()
        self:commentAttitude(self._stageId, data.cId, 1, index, item)
    end )

    local likeLabel = item:getChildByFullName("likeBg.likeLabel")
    likeLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    likeLabel:setString(data.ag)

    local unlikeBtn = item:getChildByFullName("unlikeBg.unlikeBtn")
    self:registerClickEvent(unlikeBtn, function()
        self:commentAttitude(self._stageId, data.cId, 2, index, item)
--        item:setVisible(false)
    end )

    local unlikeLabel = item:getChildByFullName("unlikeBg.unlikeLabel")
    unlikeLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    unlikeLabel:setString(data.dis)

    likeLabel:disableEffect()
    unlikeLabel:disableEffect()
    --TODO 点赞状态
    local likeState = data.aId
    if likeState == 1 then
        likeLabel:setColor(UIUtils.colorTable.ccUIBaseColor2)
        likeLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    elseif likeState == 2 then
        unlikeLabel:setColor(UIUtils.colorTable.ccUIBaseColor2)
        unlikeLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    end

    if likeState > 0 then
        likeBtn:setTouchEnabled(false)
        unlikeBtn:setTouchEnabled(false)
    else
        likeBtn:setTouchEnabled(true)
        unlikeBtn:setTouchEnabled(true)
    end
    return  item
end

-- 显示玩家详细信息
-- @param id:关卡ID
-- @param cId:评论ID
function CloudCityCommentView:showUserDetailInfo(id, cId)
    local ext = cjson.encode({targetId = self._rankData._id, fId = 1})
    local param = {ctype = self._ctype, id = id, cId = cId, ext = ext}
    self._serverMgr:sendMsg("CommentServer", "getCommentDetail", param, true, {}, function(result)
        -- dump(result)
        self._viewMgr:showDialog("arena.DialogArenaUserInfo", result, true)
    end)
end

-- 评论
function CloudCityCommentView:commentMessage()
    local conLabel = self._inputLabel:getString()
    if conLabel == "" or string.gsub(conLabel, " ", "") == "" then
        self._viewMgr:showTip(lang("towertip_23"))
        return
    end

    if tonumber(self._commentData.cNum) >= tab:Setting("Y_COMMENT_NUM6").value then
        self._viewMgr:showTip("对此玩家评论次数已达上限")
        return
    end

    local ext = cjson.encode({targetId = self._rankData._id})
    local param = {ctype = self._ctype, id = self._stageId, content = conLabel, ext = ext}
    self._serverMgr:sendMsg("CommentServer", "commentMessage", param, true, {}, function(result)
        self:addTableCell(conLabel, result["cId"])
        self._commentData.cNum = self._commentData.cNum + 1
    end)
end

function CloudCityCommentView:addTableCell(conLabel, cId)
    -- local conLabel = self._conLabel:getString()
    self._nothingPic:setVisible(false)

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
    if table.nums(self._tableData) >= 3 then
        table.insert(self._tableData, 4, tempValue)
    else
        table.insert(self._tableData, tempValue)
    end
    
    self._tableView:reloadData()
end

-- 赞或踩
-- @param id:关卡ID
-- @param cId:评论ID
-- @param aId: 赞踩（1:赞 2:踩）
function CloudCityCommentView:commentAttitude(id, cId, aId, indexId, cellItem)
    local ext = cjson.encode({targetId = self._rankData._id})
    self._serverMgr:sendMsg("CommentServer", "commentAttitude", {ctype=self._ctype,id=id,cId=cId,aId=aId,ext=ext}, true, {}, function(result)
        if aId == 1 then
            self._tableData[indexId].aId = aId
            self._tableData[indexId].ag = self._tableData[indexId].ag + 1
        elseif aId == 2 then
            self._tableData[indexId].aId = aId
            self._tableData[indexId].dis = self._tableData[indexId].dis + 1
        end
        self:updateItem(cellItem, self._tableData[indexId], indexId)
    end)
end

-- @param rType  光之试炼战报=12 暗之试炼战报=13
function CloudCityCommentView:playReport(rType)
    local battleSubId = rType == 12 and 1 or 2
    local rankId = self:getReportType()--self._rankType == 8 and 1 or 2
    local param = {stageId = self._stageId, targetId = self._rankData._id, rankId = rankId, fId = rType}
    self._serverMgr:sendMsg("CloudyCityServer","getCloudyCityReport",param,true,{},function( result )
        -- dump(data)
        if result.code == 3527 then
            self._viewMgr:showTip(lang("towertip_24"))
        else
    	    self:reviewTheBattle(result, battleSubId)
        end
    end)
end

function CloudCityCommentView:getReportType()
    if self._rankType == self._rankModel.kRankTypeCloudCity then
        return 1
    elseif self._rankType == self._rankModel.kRankTypeCloudCity_MIN_fight then
        return 2
    elseif self._rankType == self._rankModel.kRankTypeCloudCity_NEW_fight then
        return 3
    end
end

function CloudCityCommentView:reviewTheBattle(result, battleSubId)
    -- dump(reportData)
    local left  = self:initBattleData(result.atk)

    -- if result.atk.skillList ~= "" then
    --     left.skillList = cjson.decode(result.atk.skillList)
    -- end

    BattleUtils.disableSRData()
    BattleUtils.enterBattleView_CloudCity(left,
        self:getFightId(self._stageId, battleSubId), 
        result.atk.fSubId,
        true, -- true为看录像 
        false,
        function (info, callback)
            -- 战斗结束
            callback(info)
        end,
        function (info)
            -- 退出战斗
        end)
end 

function CloudCityCommentView:initBattleData( reportData )
	return BattleUtils.jsonData2lua_battleData(reportData)
end

-- 根据stageId和subId获得FightId
function CloudCityCommentView:getFightId(stageId, subId)
    return (stageId - 1) * 2 + subId
end

-- 规范名字格式
function CloudCityCommentView:formatName(nameStr, fontSize, outlineSize)
    fontsize = fontSize or 18
    if outlineSize then
        fontSize = fontSize + outlineSize*2
    end

    local nameLabel = nil
    local nameLen = utf8.len(nameStr)
    local subStr = nameStr
    local times = 1
    while true do
        nameLabel = cc.Label:createWithTTF(subStr, UIUtils.ttfName, fontsize)
        if nameLabel:getContentSize().width > 88 then
            subStr = utf8.sub(nameStr, 1, nameLen - times) .. "..."
            times = times + 1
        else
            break
        end
    end
    return subStr
end

-- 整理评论信息数据
function CloudCityCommentView:formatTableData()
    local hList = self._commentData.hList
    if type(hList) == "table" then
        for hI = 1, #hList do
            table.insert(self._tableData, hList[hI])
        end
    end

    local cList = self._commentData.cList
    if type(cList) == "table" then
        for cI = 1, #cList do
            table.insert(self._tableData, cList[cI])
        end
    end
end
return CloudCityCommentView