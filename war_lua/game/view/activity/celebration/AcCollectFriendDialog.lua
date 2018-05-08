--
-- Author: huangguofang
-- Date: 2017-07-01 16:40:08
--

local AcCollectFriendDialog = class("AcCollectFriendDialog",BasePopView)

function AcCollectFriendDialog:ctor(param)
    AcCollectFriendDialog.super.ctor(self)
  	self._friendData = param.friendData or {}
  	-- 自己拥有的字的数量
  	self._textArr = param.textArr or {}
  	-- dump(self._friendData,'self._friendData',5)
  	self._celebrationModel = self._modelMgr:getModel("CelebrationModel")
end

-- 第一次被加到父节点时候调用
function AcCollectFriendDialog:onAdd()

end
-- 初始化UI后会调用, 有需要请覆盖
function AcCollectFriendDialog:onInit()
	local title = self:getUI("bg.bgImg.titleBg.titleLab")
	UIUtils:setTitleFormat(title, 1)

	-- 注册关闭按钮
	self:registerClickEventByName("bg.closeBtn", function()
		if self._callback then
			self._callback()
		end
		self:close()
		UIUtils:reloadLuaFile("activity.celebration.AcCollectFriendDialog")
	end)

	-- 在赠送按钮
	self:registerClickEventByName("bg.giveBtn", function()
		local nums = table.nums(self._textSelectArr) 
		-- dump(self._textSelectArr,"self._textSelectArr",4)
		if not self._currFriendData or 
		   not self._currFriendData.usid then		   
			self._viewMgr:showTip("请选择一个好友赠送")
			return
		end
		if nums and nums > 0 then	
			local isOpen = self._celebrationModel:isCelebrationEnd()
			if not isOpen then
				self._viewMgr:showTip("活动已结束")
				return 
			end
			
			-- 打开赠送界面
    		self._viewMgr:showDialog("activity.celebration.AcCollectFriendsSendDialog", 
    			{selectData = self._textSelectArr,
    			friendData = self._currFriendData,
    			succCallBack = function()
    				self:updateTextDataAndUI()
    			end})
    	else
    		self._viewMgr:showTip("请选择您要赠送的文字")
    	end
	end)

 	self._toolId = {
    	[1] = { id = "31038",text="英"},
		[2] = { id = "31039",text="雄"},
		[3] = { id = "31040",text="无"},
		[4] = { id = "31041",text="敌"},
		[5] = { id = "31042",text="经"},
		[6] = { id = "31043",text="典"},
		[7] = { id = "31044",text="归"},
		[8] = { id = "31045",text="来"},
	}
	-- 选择赠送的字
	self._textSelectArr = {}
	-- 字item数组
	self._textItemArr = {}

	self._cellW = 236		
	self._cellH = 92
	self._curSelectIndex = 0 		-- 当前选中的cell idx
	self._nameTxt = self:getUI("bg.nameBg.nameTxt")
	local nameStr = self._friendData[1] and self._friendData[1].name or ""
    local levelStr = self._friendData[1] and "Lv." .. self._friendData[1].lvl or ""
    self._nameTxt:setString(nameStr .. "  " .. levelStr)

    self._currFriendData = self._friendData[1]

    -- 没有好友提示
    local noFriends = self:getUI("bg.noFriends")
    if not self._friendData or table.nums(self._friendData) == 0 then
    	noFriends:setVisible(true)
    else
    	noFriends:setVisible(false)
    end

	self:addFriendList()
	self:initTextPanel()
end

-- 更新右下字的信息
function AcCollectFriendDialog:initTextPanel()
	if not self._textArr then return end
	local textBg = self:getUI("bg.textBg")
	local x = 74
	local y = 196
	local w = 110
	local h = 124
	for i=1,8 do
		local textData = self._toolId[i]
		local item = self:createTextItem(textData)
		item:setPosition(x, y)		
		textBg:addChild(item)
		self._textItemArr[i] = item
		if i == 4 then
			x = 74
			y = y - h
		else
			x = x + w
		end
	end
end

-- 更新赠送之后的数量
function AcCollectFriendDialog:updateTextDataAndUI()	
	for k,v in pairs(self._textSelectArr) do
		if self._textArr[k] then
			self._textArr[k] = tonumber(self._textArr[k]) - 1
		end
	end
	for k,v in pairs(self._textItemArr) do
		v._selected = false
	end
	self._textSelectArr = {}
	self:updateTextItemState()
end
-- 更新右下字的信息
function AcCollectFriendDialog:updateTextItemState()
	if not self._textArr then return end
	local textBg = self:getUI("bg.textBg")
	for i=1,8 do
		local item = self._textItemArr[i]
		local numLab = item and item._numLab
		local showMark = item and item._showMark
		if numLab then
			local num = self._textArr[item._itemId]
			numLab:setString("剩余:" .. (num or " "))
		end
		if showMark then
			showMark:setVisible(false)
		end
	end
end

function AcCollectFriendDialog:createTextItem(data)
	-- body
	local num = self._textArr[data.id] or 0
	--名片区域
	local layout = ccui.Widget:create()  
	layout = ccui.Widget:create()  
	layout:setContentSize(cc.size(84, 130)) --233/98
	layout._itemId = data.id
	--名片背景
	local bgImg = ccui.ImageView:create()
	bgImg:loadTexture("celebration_collect_redGift.png", 1)
	bgImg:setPosition(cc.p(layout:getContentSize().width*0.5, layout:getContentSize().height*0.5))
	layout._bgImg = bgImg
	layout:addChild(bgImg)
	layout._data = data

	-- 选中当前字
	local showMark = ccui.ImageView:create()
	showMark:setAnchorPoint(cc.p(0.5, 0.5))
	showMark:setPosition(cc.p(layout:getContentSize().width*0.5 , layout:getContentSize().height*0.5))
	layout:addChild(showMark, 5)	
	showMark:loadTexture("celebration_collect_selected.png", 1)  --252/116
	layout._showMark = showMark
	showMark:setVisible(false)

	-- 字
	local nameLab = ccui.Text:create()
	nameLab:setString(data.text or " ")
	nameLab:setFontName(UIUtils.ttfName)
	nameLab:setFontSize(22)
	nameLab:setAnchorPoint(cc.p(0.5,0.5))
	nameLab:setPosition(layout:getContentSize().width*0.5 , layout:getContentSize().height*0.5+10)
	layout._nameLab = nameLab
	layout:addChild(nameLab, 2)

	-- 数量
	local numLab = ccui.Text:create()
	numLab:setString("剩余:" .. (num or " "))
	numLab:setFontName(UIUtils.ttfName)
	numLab:setFontSize(14)
	numLab:setAnchorPoint(cc.p(0.5,0.5))
	numLab:setColor(cc.c4b(255,206,206,255))
	numLab:setPosition(layout:getContentSize().width*0.5, 25)
	layout._numLab = numLab
	layout:addChild(numLab, 2)

	layout._selected = false
	layout.__id = data.id

	registerClickEvent(layout,function(sender)
		local textNum = self._textArr[sender.__id]
    	if textNum and textNum > 0 then
    		if not sender._selected then
    			self._textSelectArr[sender._itemId] = 1
    		else
    			self._textSelectArr[sender._itemId] = nil
    		end
			sender._selected = not sender._selected
	    	sender._showMark:setVisible(sender._selected)
    	else
    		self._viewMgr:showTip("数量不足，无法赠送")
    	end
    end)

	return layout
end


function AcCollectFriendDialog:addFriendList()
	if not self._friendData then return end
	local friendBg = self:getUI("bg.friendBg")
	if self._friendList ~= nil then 
        self._friendList:removeFromParent()
        self._friendList = nil
    end
    self._friendList = cc.TableView:create(cc.size(friendBg:getContentSize().width, friendBg:getContentSize().height - 16))
    self._friendList:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._friendList:setPosition(cc.p(9, 10))
    self._friendList:setDelegate()
    self._friendList:setBounceable(true)
    self._friendList:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._friendList:registerScriptHandler(function( view )
        return self:scrollViewDidScroll(view)
    end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._friendList:registerScriptHandler(function( view )
        return self:scrollViewDidZoom(view)
    end ,cc.SCROLLVIEW_SCRIPT_ZOOM)
    self._friendList:registerScriptHandler(function ( table,cell )
        return self:tableCellTouched(table,cell)
    end,cc.TABLECELL_TOUCHED)
    self._friendList:registerScriptHandler(function( table,index )
        return self:cellSizeForTable(table,index)
    end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._friendList:registerScriptHandler(function ( table,index )
        return self:tableCellAtIndex(table,index)
    end,cc.TABLECELL_SIZE_AT_INDEX)
    self._friendList:registerScriptHandler(function ( table )
        return self:numberOfCellsInTableView(table)
    end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._friendList:reloadData()
    friendBg:addChild(self._friendList)
end

function AcCollectFriendDialog:scrollViewDidScroll(view)
	self._inScrolling = view:isDragging()	
end

function AcCollectFriendDialog:scrollViewDidZoom(view)
    -- print("scrollViewDidZoom")
end

function AcCollectFriendDialog:tableCellTouched(table,cell)
    print("cell touched at index: " .. cell:getIdx())
    
    if self._curSelectIndex == cell:getIdx() then return end
    local tempCell = table:cellAtIndex(self._curSelectIndex)
    if tempCell ~= nil and tempCell._showMark then 
        tempCell._showMark:setVisible(false)
    end
    if cell._showMark then
    	cell._showMark:setVisible(true)
    end
    self._curSelectIndex = cell:getIdx()

    local friendData = cell._friendData
    self._currFriendData = friendData
    local nameStr = friendData and friendData.name or ""
    local levelStr = friendData and "Lv." .. friendData.lvl or ""
    self._nameTxt:setString(nameStr .. "  " .. levelStr)

end

function AcCollectFriendDialog:cellSizeForTable(table,idx) 
    return self._cellH + 3,self._cellW
end

function AcCollectFriendDialog:tableCellAtIndex(table, idx)
    local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    local label = nil
	local cellData = self._friendData[idx+1]

    if nil == cell then
        cell = cc.TableViewCell:new()
    else
    	cell:removeAllChildren()
    end
    cell._friendData = cellData
    local item = self:createFriendCell(cellData,idx+1,self._curSelectIndex == idx)
    item:setPosition(0,0)
    item:setName("cellItem")
    cell._showMark = item._showMark
    item:setAnchorPoint(0,0)
    cell:addChild(item)

    return cell
end
function AcCollectFriendDialog:numberOfCellsInTableView(table)
	return #self._friendData
end

function AcCollectFriendDialog:createFriendCell(cellData,idx,isSelected)
	--名片区域
	local layout = ccui.Widget:create()  
	layout = ccui.Widget:create()  
	layout:setContentSize(cc.size(self._cellW, self._cellH)) --233/98
	layout:setAnchorPoint(cc.p(0.5, 0.5))

	--当前聊天 选中
	local showMark = ccui.ImageView:create()
	showMark:setAnchorPoint(cc.p(0.5, 0.5))
	showMark:setPosition(cc.p(self._cellW*0.5 , self._cellH*0.5))
	showMark:ignoreContentAdaptWithSize(false)
	showMark:setContentSize(self._cellW + 10, self._cellH + 10)
	layout:addChild(showMark, 5)	
	showMark:loadTexture("chatPri_light.png", 1)  --252/116
	showMark:setVisible(isSelected)
	layout._showMark = showMark

	--名片背景
	local bgImg = ccui.ImageView:create()
	bgImg:loadTexture("globalPanelUI7_cellBg21.png", 1)
	bgImg:setScale9Enabled(true)
	bgImg:setCapInsets(cc.rect(25, 25, 1, 1))
	bgImg:setContentSize(cc.size(self._cellW, self._cellH))
	bgImg:ignoreContentAdaptWithSize(false)
	bgImg:setPosition(cc.p(self._cellW*0.5, self._cellH*0.5))
	layout:addChild(bgImg)

	-- 头像
	local headIcon = IconUtils:createHeadIconById({avatar = cellData.avatar, tp = 4, avatarFrame=cellData["avatarFrame"]})
	headIcon:setScale(0.73)
	headIcon:setAnchorPoint(cc.p(0, 0.5))
	headIcon:setPosition(13, layout:getContentSize().height*0.5)  --18
	layout:addChild(headIcon)
	
	-- 名字
	local nameLab = ccui.Text:create()
	nameLab:setString(cellData.name or " ")
	nameLab:setFontName(UIUtils.ttfName)
	UIUtils:setTitleFormat(nameLab, 2)
	nameLab:setFontSize(18)
	nameLab:setAnchorPoint(cc.p(0,0.5))
	nameLab:setPosition(84, 65)
	layout:addChild(nameLab, 2)

	-- 等级
	local lvlLab = ccui.Text:create()
	lvlLab:setString("Lv." .. (cellData.lvl or " "))
	lvlLab:setFontName(UIUtils.ttfName)
	UIUtils:setTitleFormat(lvlLab, 2)
	lvlLab:setFontSize(16)
	lvlLab:setAnchorPoint(cc.p(0,0.5))
	lvlLab:setPosition(84, 25)
	layout:addChild(lvlLab, 2)

	--login
	local loginLab = ccui.Text:create()
	loginLab:setAnchorPoint(cc.p(0,0.5))
	loginLab:setFontName(UIUtils.ttfName)
	loginLab:setFontSize(16)
	loginLab:setPosition(127, 25)  --23  
	layout:addChild(loginLab,2)
	
	local disNum = cellData["_lt"] and self._modelMgr:getModel("UserModel"):getCurServerTime() - cellData["_lt"] or 10000000
	local loginDes 
	if cellData["online"] and cellData["online"] == 1 then
    	loginDes = "在线"
    	loginLab:setColor(cc.c4b(63, 125, 0, 255))
    else
    	loginDes = TimeUtils:getTimeDisByFormat(disNum) .. "前"
    	loginLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    end
    loginLab:setString("登录:" .. loginDes)

	return layout
	
end

function AcCollectFriendDialog:reflashUI()
	-- body
end


return AcCollectFriendDialog