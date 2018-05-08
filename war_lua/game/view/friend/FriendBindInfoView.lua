--[[
    Filename:    FriendBindInfoView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-09-09 17:19
    Description: 好友绑定关系
--]]

local FriendBindInfoView = class("FriendBindInfoView", BasePopView)

function FriendBindInfoView:ctor(param)
	self.super.ctor(self)
	require("game.view.friend.FriendConst")
	self._recallModel = self._modelMgr:getModel("FriendRecallModel")
    self._playerTodayModel = self._modelMgr:getModel("PlayerTodayModel")
	self._callback = param.callback
end

function FriendBindInfoView:onInit()
	local title = self:getUI("bg.bg1.titleBg.title")
    UIUtils:setTitleFormat(title, 1)

    local nothing = self:getUI("bg.bg1.nothing")
    nothing:setVisible(false)

    self._item = self:getUI("item")

	--closeBtn
	local closeBtn = self:getUI("bg.bg1.closeBtn")
	self:registerClickEvent(closeBtn, function()
 		self:close()
		end)

    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then
            UIUtils:reloadLuaFile("friend.FriendBindInfoView")          
        end
    end)
end

function FriendBindInfoView:reflashUI()
	self._data = self._recallModel:getBindData()

	local nothing = self:getUI("bg.bg1.nothing")
	local des = self:getUI("bg.bg1.nothing.des")
    if #self._data == 0 then
    	nothing:setVisible(true)
    	des:setString(lang("FRIENDLIST_EMPTY"))
        return
    end

    local tableBg = self:getUI("bg.bg1.tableBg")
    local wid, hei = tableBg:getContentSize().width - 16, tableBg:getContentSize().height - 20
    self._tableView = cc.TableView:create(cc.size(wid, hei))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setPosition(cc.p(8, 10))
    self._tableView:setDelegate()
    self._tableView:setBounceable(true) 
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:registerScriptHandler(function(view) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:registerScriptHandler(function(table, cell ) return self:tableCellWillRecycle(table,cell) end ,cc.TABLECELL_WILL_RECYCLE)
    tableBg:addChild(self._tableView)
    if self._tableView.setDragSlideable ~= nil then 
        self._tableView:setDragSlideable(true)
    end
    
    self._tableView:reloadData()
end

function FriendBindInfoView:scrollViewDidScroll(view)
end

function FriendBindInfoView:cellSizeForTable(table,idx)
	return 138, 530
end

function FriendBindInfoView:numberOfCellsInTableView(table)
	return #self._data
end

function FriendBindInfoView:tableCellWillRecycle(table,cell)
end


function FriendBindInfoView:tableCellAtIndex(table, idx)
	local cell = table:dequeueCell()
	if nil == cell then
        cell = cc.TableViewCell:new()
    end

	local cellData = self._data[idx + 1]
    if cell.item == nil then
        local item = self._item:clone()
        item = self:updateCell(item, cellData, idx)
        item:setPosition(cc.p(3,0))
        item:setAnchorPoint(cc.p(0,0))
        cell.item = item
        cell:addChild(item)
    else
        self:updateCell(cell.item, cellData, idx)
    end

    return cell
end

function FriendBindInfoView:updateCell(item, data, idx)
	if data == nil then
		return
	end
    -- dump(data, "data", 10)

    -- avatar
    local avatar = item:getChildByFullName("avatar")
    if not avatar then
        avatar = IconUtils:createUrlHeadIconById({name = data["nickName"], url = data["picUrl"], openid = data["pId"], tencetTp = data["qqVip"], tp = 4})
        avatar:setAnchorPoint(0, 0.5)
        avatar:setPosition(25, item:getContentSize().height*0.5 - 1)
        avatar:setName("avatar")
        item:addChild(avatar, 2)
    else
        IconUtils:updateUrlHeadIconByView(avatar,{name = data["nickName"], url = data["picUrl"], openid = data["pId"], tencetTp = data["qqVip"], tp = 4})  
    end

    registerClickEvent(avatar, function() 
    	local fid = (data["lvl"] and data["lvl"] >= 15) and 101 or 1
		self._serverMgr:sendMsg("UserServer", "getTargetUserBattleInfo", {tagId = data["rid"], fid = fid, fsec = data["sec"]}, true, {}, function(result) 
			if not result then
				self._viewMgr:showTip("请求数据失败")
				return
			end

			if result["tequan"] == nil then
				result["tequan"] = data["tequan"]
			end

			if result["qqVip"] == nil then
				result["qqVip"] = data["qqVip"]
			end

			local viewType = FriendConst.FRIEND_TYPE.PLATFORM
			self._viewMgr:showDialog("friend.FriendUserInfoView", {data = result, viewType = viewType}, true)
	    end)
	end)

	--name
    local nameLab = item:getChildByFullName("name")
    UIUtils:setTitleFormat(nameLab, 2)
    nameLab:setString(data["nickName"] or "")

	--lv
    local lvLab = item:getChildByFullName("lvLab")  
    lvLab:setString("Lv." .. (data["level"] or 0))
    
    --sec
    local secName = self._modelMgr:getModel("LeagueModel"):getServerName(data["sec"]) or ""
    local sec = item:getChildByFullName("allianLab")
    sec:setString("服务器: " .. secName)

    --vip
    local vipLv = item:getChildByFullName("vipLv")
    vipLv:setVisible(false) 
    if data["vipLvl"] and data["vipLvl"] > 0 then
    	vipLv:setVisible(true) 
    	vipLv:loadTexture("chatPri_vipLv" .. data["vipLvl"] .. ".png", 1)
    	vipLv:setPositionX(nameLab:getPositionX() + nameLab:getContentSize().width + 25)
    end

    --tequan
    local tequan = item:getChildByFullName("tequan")
    tequan:setVisible(false)
    if data["tequan"] then
    	local tequanImg = FriendConst.TEQUAN_TYPE[data["tequan"]] or "globalImageUI6_meiyoutu.png"
    	tequan:loadTexture(tequanImg, 1) 
    end

    --bind
    local bindBtn = item:getChildByFullName("bindBtn")
    local binded = item:getChildByFullName("binded")
    bindBtn:setVisible(false)
    binded:setVisible(false)
    if data["status"] and data["status"] == 1 then  --nil可绑定  1已绑定
        binded:setVisible(true)
    else
        bindBtn:setVisible(true)
    end
    self:registerClickEvent(bindBtn, function()
    	self._viewMgr:showDialog("global.GlobalSelectDialog",
	        {   desc = lang("FRIEND_TEXT_TIPS_6"),
	            button1 = "确定",
	            button2 = "取消", 
	            callback1 = function ()
		            self._serverMgr:sendMsg("RecallServer", "bindRecallFriend", {targetPid = data["pId"]}, true, {}, function (result)
                        self._recallModel:setBindInfo(data)

                        --上限
                        local curNum = self._recallModel:getAcData().dailyFriendScore or 0
                        local limit = tab.setting["FRIEND_RETURN_MAXPOINTS_PERDAY"].value
                        if curNum >= limit then
                            self._viewMgr:showTip(lang("FRIEND_TEXT_TIPS_7"))
                        else
                            self._viewMgr:showTip(lang("FRIEND_TEXT_TIPS_5"))
                        end

			            DialogUtils.showGiftGet( {
				            gifts = result["reward"], 
				            callback = function() end
				        ,notPop = true})

                        self:close()
			        end)
	            end,
	            callback2 = function()
	            end})
        end)

    return item
end

return FriendBindInfoView