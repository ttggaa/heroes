--[[
    Filename:    FriendBlackView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2016-07-26 16:58
    Description: 好友黑名单界面
--]]

local FriendBlackView = class("FriendBlackView", BasePopView)

function FriendBlackView:ctor(param)
	FriendBlackView.super.ctor(self)
    self._callback = param.callback
	self._friendModel = self._modelMgr:getModel("FriendModel")
end

function FriendBlackView:onInit()
	local title = self:getUI("bg._titlebg.Label_35")
    UIUtils:setTitleFormat(title, 1)
    self:getUI("bg.item"):setVisible(false)

    local nothing = self:getUI("bg.nothing")
    nothing:setVisible(false)

    self:registerClickEventByName("bg.closeBtn", function()
        if self._callback then
            self._callback()
        end
        self:close()
        end)
    self:reflushView()

    self:listenReflash("FriendModel", self.reflushView)
end

function FriendBlackView:reflushView()
    --请求数据
    self._data = clone(self._friendModel:getDataByType(FriendConst.FRIEND_TYPE.BLACK))

    local nothing = self:getUI("bg.nothing")
    if #self._data == 0 then
        nothing:setVisible(true)
        return
    end

	local tableBg = self:getUI("bg.listBg")
    self._tableView = cc.TableView:create(cc.size(tableBg:getContentSize().width , tableBg:getContentSize().height - 20))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setPosition(cc.p(0, 10))
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
    
    -- dump(self._data, "123", 10)
    self._viewMgr:unlock()  -- unlock
    self._tableView:reloadData()
end

function FriendBlackView:scrollViewDidScroll(view)
end

function FriendBlackView:cellSizeForTable(table,idx)
	return 129, 490  --110/458 -11
end

function FriendBlackView:numberOfCellsInTableView(table)
	return #self._data
end

function FriendBlackView:tableCellWillRecycle(table,cell)
end


function FriendBlackView:tableCellAtIndex(table, idx)
	local cell = table:dequeueCell()
	if nil == cell then
        cell = cc.TableViewCell:new()
    else
    	cell:removeAllChildren()
    end

	local cellData = self._data[idx + 1]
    local item = self:creatCell(cellData, idx)
    item:setPosition(cc.p(3,0))
    item:setAnchorPoint(cc.p(0,0))
    cell:addChild(item)

    return cell
end

function FriendBlackView:creatCell(data, idx)
	if data == nil then
		return
	end

    -- dump(data, "data", 10)
	
	local item = self:getUI("bg.item"):clone()
    item:setVisible(true)
    item:setTouchEnabled(true)
    item:setSwallowTouches(false)

	--avatar
	local headIcon = item:getChildByFullName("avatar")
	if not headIcon then
		headIcon = IconUtils:createHeadIconById({avatar = data["avatar"], tp = 4,avatarFrame = data["avatarFrame"]}) 
	    headIcon:setAnchorPoint(0, 0.5)
	    headIcon:setPosition(19, item:getContentSize().height/2)
        headIcon:setScale(0.95)
	    headIcon:setName("avatar")
	    item:addChild(headIcon, 2)
	else
		IconUtils:updateHeadIconByView(self._avatar,{avatar = data["avatar"], tp = 4,avatarFrame = data["avatarFrame"]}) 
	end

	--name
    local nameLab = item:getChildByFullName("name")
    UIUtils:setTitleFormat(nameLab, 2)
    nameLab:setString(data["name"])
    -- nameLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
   
    --nameBg
    local nameBg = item:getChildByFullName("nameBg")
    nameBg:ignoreContentAdaptWithSize(false)
    nameBg:setOpacity(150)
    local dis = math.max(nameLab:getContentSize().width - 141, 0)
    nameBg:setContentSize(225 + dis, 34)

	--lv
    local lvLab = item:getChildByFullName("lvLab")  
    lvLab:setString("等级: " .. (data["lvl"] or data["lv"]))
    -- lvLab:setPosition(120, 48)
    
    --alliance
    local alliance = item:getChildByFullName("allianLab")
    alliance:setString("联盟: " .. ((not data["guildName"] or data["guildName"] == "") and "无" or data["guildName"]))
    -- alliance:setPosition(120, 21)

    local removeBtn = item:getChildByFullName("deleteBtn")
    removeBtn:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine2, 2)
    self:registerClickEvent(removeBtn, function()
        local function removeFunc()
            self._friendModel:removeFriendFromBlack(data["rid"])
            self._data = clone(self._friendModel:getDataByType(FriendConst.FRIEND_TYPE.BLACK))
            
            local offsetLast = self._tableView:getContentOffset()
            self._tableView:reloadData()
            local offsetNew = self._tableView:getContentOffset()

            if offsetNew.y < 0 then   --多于一屏数据
                if offsetLast.y > -129 and offsetNew.y < -129 then 
                    self._tableView:setContentOffset(cc.p(offsetLast.x, offsetLast.y)) --下移
                else
                    self._tableView:setContentOffset(cc.p(offsetLast.x, offsetLast.y + 129))   --上移
                end
            end
        end

        if data["isFakeNpc"] == true then
            removeFunc()
        else
            self._serverMgr:sendMsg("GameFriendServer", "removeBlackList", {usid = data["usid"]}, true, {}, function (result)
                removeFunc()
            end)
        end
        end)

    return item
end

return FriendBlackView