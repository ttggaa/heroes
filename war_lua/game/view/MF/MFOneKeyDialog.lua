--[[
    Filename:    MFOneKeyDialog.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2017-8-8 21:42:53
    Description: File description
--]]


-- 航海帮助详情
local MFOneKeyDialog = class("MFOneKeyDialog", BasePopView)

function MFOneKeyDialog:ctor()
    MFOneKeyDialog.super.ctor(self)
    self._MFModel = self._modelMgr:getModel("MFModel")
    self._robbData,self._helpData, self._countRob, self._countHelp = self._MFModel:getOneKeyEndData()
    self._showCount = 0
    if self._robbData and table.nums(self._robbData) > 0 then
    	self._showCount = self._showCount + 1
    	self._showType = "rob"
    end
    if self._helpData and table.nums(self._helpData) > 0 then
    	self._showCount = self._showCount + 1
    	self._showType = "help"
    end
    if self._showCount == 1 then
    	if self._showType == "rob" then
    		self._singleData = self._robbData or {}
    	else
    		self._singleData = self._helpData or {}
    	end
    end
end


function MFOneKeyDialog:onInit()
	local imageBg = self:getUI("bg.image_bg")
	imageBg:loadTexture("asset/bg/bg_mf_dialog1.jpg")
	local imageBg1 = self:getUI("bg.image_bg1")
	imageBg1:loadTexture("asset/bg/bg_mf_dialog2.png")
	self._cellPanel = self:getUI("bg.cellPanel")
	self._cellPanel:setVisible(false)
	self:registerClickEventByName("bg.closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("MF.MFOneKeyDialog")
        end
        self:close()
    end)
    self:registerClickEventByName("bg.cancelBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("MF.MFOneKeyDialog")
        end
        self._serverMgr:sendMsg("MFServer", "oneKeyThankAndDel",{}, true, {}, function (result)
        	self._MFModel:clearHelpInfo()
	        self:close()
	    end, function(errorId)
	        self:close()
	    end)
    end)
    self._layer1 = self:getUI("bg.layer1")
    self._layer1:setVisible(false)
    self._layer2 = self:getUI("bg.layer2")
    self._layer2:setVisible(false)
    self._Image_title = self:getUI("bg.Image_title")
    self:showType()
    self:showTitleDes()
    self:showTableView()
end

function MFOneKeyDialog:showTitleDes()
	local function createRich(root,str)
	    local richLabel = RichTextFactory:create(str, 820, 30)
	    richLabel:formatText()
	    richLabel:enablePrinter(true)
	    richLabel:setPosition(20, 5)
	    root:addChild(richLabel)
		UIUtils:alignRichText(richLabel,{hAlign = "center"})
	end
	if self._showCount == 1 then
		local node = self._layer1:getChildByFullName("richNode")
		if self._showType == "help" then
			local str = lang("MF_TIPS_DES1")
			local result = string.gsub(str,"{$num}",table.nums(self._helpData))
	        result = string.gsub(result,"{$time}",self._countHelp)
	        createRich(node,result)
		elseif self._showType == "rob" then
			local str = lang("MF_TIPS_DES2")
			local result = string.gsub(str,"{$num}",table.nums(self._robbData))
	        result = string.gsub(result,"{$time}",self._countRob)
	        createRich(node,result)
		end
	else
		local helpRichNode = self._layer2:getChildByFullName("richNode1")
		local robRichNode  =  self._layer2:getChildByFullName("richNode2")
		local str = lang("MF_TIPS_DES1")
		local result = string.gsub(str,"{$num}",table.nums(self._helpData))
        result = string.gsub(result,"{$time}",self._countHelp)
        createRich(helpRichNode,result)

        str = lang("MF_TIPS_DES2")
		result = string.gsub(str,"{$num}",table.nums(self._robbData))
        result = string.gsub(result,"{$time}",self._countRob)
        createRich(robRichNode,result)
	end
end


function MFOneKeyDialog:showType()
	if self._showCount == 1 then
		self._layer1:setVisible(true)
		self._Image_title:setPosition(595,420)
	else
		self._layer2:setVisible(true)
		self._Image_title:setPosition(595,514)
	end
end

--[[
	tableView root
	update fun
	cell count
]]
function MFOneKeyDialog:createTableView(root,callFun,cellCount)
    local tableView = cc.TableView:create(cc.size(root:getContentSize().width, root:getContentSize().height))
    tableView:setDelegate()
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setPosition(cc.p(0, 0))
    tableView:registerScriptHandler(function( view ) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(function( view ) return self:scrollViewDidZoom(view) end ,cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(function(table, cell) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function(table, idx) return callFun(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function(table) return cellCount end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:setBounceable(true)
    root:addChild(tableView)
    tableView:reloadData()
    return tableView
end

function MFOneKeyDialog:scrollViewDidScroll(view)
    self._inScrolling = view:isDragging()
end

function MFOneKeyDialog:scrollViewDidZoom(view)
end

function MFOneKeyDialog:tableCellTouched(table,cell)
end

function MFOneKeyDialog:cellSizeForTable(table,idx)
	return 110,120
end

function MFOneKeyDialog:showTableView()
	if self._showCount == 1 then
		if not self._tableView1 then
			local tableViewBg = self._layer1:getChildByFullName("tableViewBg1")
			self._tableView1 = self:createTableView(tableViewBg,specialize(self.tableCellAtIndex, self),table.nums(self._singleData))
		end
	else
		if not self._tableView1 then
			local tableViewBg = self._layer2:getChildByFullName("tableViewBg1")
			self._tableView1 = self:createTableView(tableViewBg,specialize(self.tableCellAtIndex1, self),table.nums(self._helpData))
		end
		if not self._tableView2 then
			local tableViewBg = self._layer2:getChildByFullName("tableViewBg2")
			self._tableView2 = self:createTableView(tableViewBg,specialize(self.tableCellAtIndex2, self),table.nums(self._robbData))
		end
	end
end

function MFOneKeyDialog:createRoleHead(item,data)
	local headIcon = item:getChildByFullName("avatar")
	if not headIcon then
		headIcon = IconUtils:createHeadIconById({avatar = data["avatar"], tp = 4,avatarFrame=data["avatarFrame"], level = data["lvl"] })
	    headIcon:setAnchorPoint(0.5, 0.5)
	    headIcon:setPosition(item:getContentSize().width/2, item:getContentSize().height/2)
        headIcon:setScale(0.9)
	    headIcon:setName("avatar")
	    item:addChild(headIcon, 2)
	else
		IconUtils:updateHeadIconByView(headIcon,{avatar = data["avatar"], tp = 4,avatarFrame=data["avatarFrame"], level = data["lvl"]})
	end
end

function MFOneKeyDialog:tableCellAtIndex(table,idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    end
    local cellItem = cell:getChildByName("cellItem")
    if not cellItem then
        cellItem = self._cellPanel:clone()
        cellItem:setVisible(true)
        cellItem:setSwallowTouches(false)
        cellItem:setName("cellItem")
        cellItem:setPosition(0,0)
        cell:addChild(cellItem)
    end
    self:update(cellItem,self._singleData[idx+1])
    return cell
end

function MFOneKeyDialog:tableCellAtIndex1(table,idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    end
    local cellItem = cell:getChildByName("cellItem")
    if not cellItem then
        cellItem = self._cellPanel:clone()
        cellItem:setVisible(true)
        cellItem:setSwallowTouches(false)
        cellItem:setName("cellItem")
        cellItem:setPosition(0,0)
        cell:addChild(cellItem)
    end
    self:update(cellItem,self._helpData[idx+1])
    return cell
end

function MFOneKeyDialog:tableCellAtIndex2(table,idx)
	local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    end
    local cellItem = cell:getChildByName("cellItem")
    if not cellItem then
        cellItem = self._cellPanel:clone()
        cellItem:setVisible(true)
        -- cellItem:setSwallowTouches(false)
        cellItem:setName("cellItem")
        cellItem:setPosition(0,0)
        cell:addChild(cellItem)
    end
    self:update(cellItem,self._robbData[idx+1])
    return cell
end

function MFOneKeyDialog:update(item,data)
	local name = item:getChildByFullName("name")
	name:setString(data.name)
	local icon = item:getChildByFullName("icon")
	self:createRoleHead(icon,data)

	self:registerClickEvent(item,function( )
		if not self._inScrolling then
			self:showUserDialog(data)			
        else
            self._inScrolling = false
        end
	end)
	item:setSwallowTouches(false)
end

function MFOneKeyDialog:showUserDialog(data)
	print("aaaa")
	local fId = (data.lvl and  data.lvl >= 15) and 101 or 1
	self._serverMgr:sendMsg("UserServer", "getTargetUserBattleInfo", {tagId = data.rid or data._id,fid=fId}, true, {}, function(result) 
		local data = result
		-- data.rank = self._clickItemData.rank
		-- data.usid = self._clickItemData.usid
		-- data.isNotShowBtn = true
		self._viewMgr:showDialog("arena.DialogArenaUserInfo",data,true)
    end)
end

function MFOneKeyDialog:getAsyncRes()
	return {"asset/bg/bg_mf_dialog1.jpg",
	"asset/bg/bg_mf_dialog2.png"
}
end


return MFOneKeyDialog