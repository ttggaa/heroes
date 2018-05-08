
--[[
    Filename:    SkillCardPreView.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2017-09-7 14:39:47
    Description: File description
--]]

local SkillCardPreView = class("SkillCardPreView",BasePopView)

function SkillCardPreView:ctor(param)
	SkillCardPreView.super.ctor(self)
	self._tabId = param.id --本期id
	self._nextId = param.nextId --下期id
    self._beginTime = param.beginTime
    self._endTime = param.endTime
	self._userModel = self._modelMgr:getModel("UserModel")
    self._SpellBooksModel  = self._modelMgr:getModel("SpellBooksModel")
    self._isHideTab = param.hide
    self._callback = param.callback
    -- self:checkHideTab()
end

--[[
    开始时不显示标签页，本期结束前前3天显示【本期】和【下期】两个标签页
]]
function SkillCardPreView:checkHideTab()
    local conditionDay = 3
    local curTime = self._userModel:getCurServerTime()
    if curTime + conditionDay * 86400 >= self._endTime then
        self._HideTab = false
    else
        self._HideTab = true
    end
end

function SkillCardPreView:updateTabRedPoint()
    local red = false
    local diffNextID = self._SpellBooksModel:isNewGift(self._nextId)
    if not self._isHideTab and diffNextID then
        red = true
    end
    UIUtils.addRedPoint(self._secondBtn,red,cc.p(20,50))
end

function SkillCardPreView:processData(index)
	if index == 1 then
		local data = tab:ScrollTemplate(self._tabId)

		local art1 = data.art1
		if art1 then
			self._top = art1
		else
			self._top = {}
		end

		local art2 = data.art2
		if art2 then
			self._bottom = art2
		else
			self._bottom = {}
		end
	else
		local data = tab:ScrollTemplate(self._nextId)

		local art1 = data.art1
		if art1 then
			self._top = art1
		else
			self._top = {}
		end

		local art2 = data.art2
		if art2 then
			self._bottom = art2
		else
			self._bottom = {}
		end
	end
end

function SkillCardPreView:getRegisterNames()
	return {
		{"titleLabel","bg.title.titleLabel"},
		{"closeBtn","bg.closeBtn"},
		{"list","bg.list"},
		{"topDes","bg.topDes"},
		{"bg","bg"},
		{"firstBtn","bg.imageBg.firstBtn"},
		{"secondBtn","bg.imageBg.secondBtn"},
}
end

function SkillCardPreView:onInit()
	self:registerClickEvent(self._closeBtn,function()
        if self._callback then
            self._callback()
        end
		self:close()
		UIUtils:reloadLuaFile("skillCard.SkillCardPreView")
    end)
	self._bg:setPosition(MAX_SCREEN_WIDTH*0.5,MAX_SCREEN_HEIGHT*0.5)
    self._titleLabel:setString("本期预览")
    self._topDes:setColor(cc.c3b(255, 253, 235))
	self._topDes:enable2Color(1,cc.c3b(253, 229, 175))
	self._topDes:enableOutline(cc.c3b(60, 30, 10),1)
    UIUtils:setTitleFormat(self._titleLabel,1)

    self._firstBtn:setTitleFontName(UIUtils.ttfName)
    self._secondBtn:setTitleFontName(UIUtils.ttfName)
    local off = -42
    UIUtils:setTabChangeAnimEnable(self._firstBtn,off,function(sender)self:tabButtonClick(sender, 1)end)
    UIUtils:setTabChangeAnimEnable(self._secondBtn,off,function(sender)self:tabButtonClick(sender, 2)end)
    self._tabEventTarget = {}
    table.insert(self._tabEventTarget, self._firstBtn)
    table.insert(self._tabEventTarget, self._secondBtn)
    -- self._animBtns = self._tabEventTarget
    self:tabButtonClick(self._firstBtn, 1)
    if self._isHideTab then
        self._firstBtn:setVisible(false)
        self._secondBtn:setVisible(false)
    else
        self._firstBtn:setVisible(true)
        self._secondBtn:setVisible(true)
    end
    self:updateTabRedPoint()
end

function SkillCardPreView:updateGift(index)
	if index == 1 then
		self._titleLabel:setString("本期预览")
	else
		self._titleLabel:setString("下期预览")
	end
	-------大招
    local tabData = tab.tool
    for index,data in pairs(self._top) do
      	local itemType,id,num = data[1],data[2],data[3] 
    	local icon = self._bg:getChildByFullName("icon"..index)

    	local itemIcon = icon.itemIcon
    	if not itemIcon then
    		itemIcon = IconUtils:createItemIconById({itemId = id, tabData[id], eventStyle = 1, showSpecailSkillBookTip = true})
	    	icon:addChild(itemIcon)
	    	icon.itemIcon = itemIcon
	    	itemIcon:setAnchorPoint(0.5,0.5)
	    	itemIcon:setPosition(40,40)
    	else
    		IconUtils:updateItemIconByView(itemIcon,{itemId = id, tabData[id], eventStyle = 1, showSpecailSkillBookTip = true})
    	end

        self:addUnActiveState(itemIcon, id)
    end

    ------普通
    local bottom = self._bottom
    local totalNum = #bottom
    local row = math.ceil(totalNum*0.2)
    local list = self._list
    local cellH = 100
    local cellW = 100
    local totalHeight = math.max(cellH*row,list:getContentSize().height)
    list:removeAllChildren()
    list:setInnerContainerSize(cc.size(list:getContentSize().width,totalHeight))

    for i=1,row do
    	for j=1,5 do 
    		local index = (i-1)*5+j
    		local data = bottom[index]
    		if not data then break end
    		local itemType,id,num = data[1],data[2],data[3]
	    	local itemIcon = IconUtils:createItemIconById({itemId = id, tabData[id], eventStyle = 1, showSpecailSkillBookTip = true})
	    	list:addChild(itemIcon)
	    	itemIcon:setAnchorPoint(0.5,0.5)
	    	itemIcon:setScale(0.9)
	    	itemIcon:setPosition((j-1)*cellW+ cellW*0.5-2,totalHeight-(i-1)*cellH-cellH*0.5)

            self:addUnActiveState(itemIcon, id)
    	end 
    end
end

function SkillCardPreView:addUnActiveState(inObj, itemId)    --by wangyan
    local spellBModel = self._modelMgr:getModel("SpellBooksModel")
    local bookList = spellBModel:getCacheTab()
    if not bookList[itemId] then
        return
    end

    local spbData = spellBModel:getData()
    local spellInfo = spbData[tostring(bookList[itemId])]
    local level = spellInfo and spellInfo.l or 0
    if level > 0 then
        return
    end

    local child = inObj:getChildren()
    for k,v in pairs(child) do
        v:setBrightness(-25)
    end

    local bgMc = inObj:getChildByFullName("iconColor.bgMc")
    if bgMc then
        bgMc:setBrightness(-30)
    end

    if inObj.unHave then
        inObj.unHave:removeFromParent(true)
        inObj.unHave = nil
    end

    local unHave = cc.Label:createWithTTF("未拥有", UIUtils.ttfName, 16)
    unHave:setPosition(inObj:getContentSize().width * 0.5, 15)
    unHave:setColor(UIUtils.colorTable.ccUIBaseColor1)
    unHave:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    inObj.unHave = unHave
    inObj:addChild(unHave, 100)
end

function SkillCardPreView:tabButtonState(sender, isSelected, key)
    local titleNames = {
        " 本期 ",
        " 下期 ",
    }
    local shortTitleNames = {
        " 本期 ",
        " 下期 ",
    }


    sender:setBright(not isSelected)
    sender:setEnabled(not isSelected)
    sender:getTitleRenderer():disableEffect()
    if isSelected then
        sender:setTitleText(titleNames[key])
        sender:setTitleColor(UIUtils.colorTable.ccUITabColor2)
    else
        sender:setTitleText(shortTitleNames[key])
        sender:setTitleColor(UIUtils.colorTable.ccUITabColor1)
    end
end

function SkillCardPreView:tabButtonClick(sender, key)
    if sender == nil then 
        return 
    end
    if self._tabName == sender:getName() then 
        return 
    end
    for k,v in pairs(self._tabEventTarget) do
        if v ~= sender then
            self:tabButtonState(v, false, k)
        end
    end
    if self._preBtn then
        UIUtils:tabChangeAnim(self._preBtn,nil,true)
    end
    self._preBtn = sender
    UIUtils:tabChangeAnim(sender,function( )
        self:tabButtonState(sender, true, key)
        audioMgr:playSound("Tab")

        local tempBaseInfoNode = self:getUI("bg.rightSubBg")

        if sender:getName() == "firstBtn" then
            self:processData(1)
            self:updateGift(1)
        elseif sender:getName() == "secondBtn" then
            self:processData(2)
            self:updateGift(2)
            UIUtils.addRedPoint(self._secondBtn,false)
            local preNextID = SystemUtils.loadAccountLocalData("SKILL_BOOK_NEXTID")
            if preNextID ~= self._nextId then
                SystemUtils.saveAccountLocalData("SKILL_BOOK_NEXTID",self._nextId)
            end
        end
        
    end)
end

return SkillCardPreView