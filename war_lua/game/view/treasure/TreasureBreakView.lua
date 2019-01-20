--[[
    Filename:    TreasureBreakView.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2016-01-27 15:00:11
    Description: File description
--]]

local TreasureBreakView = class("TreasureBreakView",BasePopView)
function TreasureBreakView:ctor()
    self.super.ctor(self)
    self._tModel = self._modelMgr:getModel("TreasureModel")

end

function TreasureBreakView:getAsyncRes()
    return
    {
        -- { "asset/ui/treasure3.plist", "asset/ui/treasure3.png" },
    }
end

-- 初始化UI后会调用, 有需要请覆盖
function TreasureBreakView:onInit()
	self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
        UIUtils:reloadLuaFile("treasure.TreasureBreakView")
    end)
    self._stageMax = table.nums(tab.devDisTreasure) + 1
    self._title = self:getUI("bg.headBg.title")
    UIUtils:setTitleFormat(self._title,1)
    self._bg = self:getUI("bg")
    self._scrollBg = self:getUI("bg.scrollBg")
    self._breakDesBg = self:getUI("bg.breakDesBg")
    self._breakDesBg:setCascadeOpacityEnabled(true) 
    self._smallJinghuaImg = self:getUI("bg.breakDesBg.smallJinghuaImg")
    self._numLab = self:getUI("bg.breakDesBg.numLab")
    self._numLab:setString("x0")
    self._numLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
    self._addtionNode = self:getUI("bg.addtionNode")
    self._countNum = self:getUI("bg.addtionNode.countNum")
    self._countNum:setString("宝物X0)")
    self._countNum:setColor(UIUtils.colorTable.ccUIBaseColor1)
    self._selNumLab = self:getUI("bg.selNumLab")
    self._selNumLab:setString("0")
    -- self._selNumLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
    self._des1 = self:getUI("bg.breakDesBg.des1")
    self._des1:setColor(UIUtils.colorTable.ccUIBaseColor1)
    UIUtils:alignNodesToPos({self._des1,self._smallJinghuaImg,self._numLab},100)
    self._des3 = self:getUI("bg.des3")
    self._des3:setColor(UIUtils.colorTable.ccUIBaseColor1)
    self._des2 = self:getUI("bg.des2")
    self._des2:setColor(UIUtils.colorTable.ccUIBaseColor1)
    self._des4 = self:getUI("bg.addtionNode.des4")
    self._des4:setColor(UIUtils.colorTable.ccUIBaseColor1)
    self._purple = self:getUI("bg.addtionNode.purple")
    self._purple:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    self._tipsBg = self:getUI("bg.tipsBg")
    self._tipsLabel = self._tipsBg:getChildByFullName("tipsLabel")
    self._tipsLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    self._getBtn = self._tipsBg:getChildByFullName("getBtn")
    self:registerClickEvent(self._getBtn, function()
        self._viewMgr:showView("shop.ShopView", { idx = 4, showDialogTreasure = false })
    end)

    local shopTitle = self:getUI("bg.shopBtn.text")
    shopTitle:setFontName(UIUtils.ttfName)
    shopTitle:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    self:registerClickEventByName("bg.shopBtn",function() 
        self._viewMgr:showView("shop.ShopView", {idx = 4})
    end)
    self:registerClickEventByName("bg.breakBtn", function ()
        if self._resultPanel and self._resultPanel:isVisible() then return end
        local purpleSelNum = self:calculateBreaks()
        if table.nums(self._breakPool) == 0 then
            self._viewMgr:showTip(lang("TIPS_ARTIFACT_05"))
            return 
        end
        local items = {}
        for k,v in pairs(self._breakPool) do
            table.insert(items,{k,v})
        end
        local function sendMsg( )
            local preTreasureCoin = self._modelMgr:getModel("UserModel"):getData().treasureCoin 
            self._serverMgr:sendMsg("TreasureServer","dismantlingDisTreasure",{args = json.encode({items = items})}, true, {}, function(result)
                self._breakPool = {}
                self:calculateBreaks()
                self:reflashUI()
                local curTreasureCoin = self._modelMgr:getModel("UserModel"):getData().treasureCoin 
                local deltTreasureCoin = curTreasureCoin-preTreasureCoin
                if deltTreasureCoin > 0 then
                    ScheduleMgr:delayCall(500, self, function( )
                        if not preTreasureCoin then return end
                        DialogUtils.showGiftGet({{"tool",IconUtils.iconIdMap["treasureCoin"],deltTreasureCoin}})
                    end)
                    preTreasureCoin = curTreasureCoin
                end
            end)
        end
        if purpleSelNum > 0 then
            self._viewMgr:showSelectDialog( lang("TIPS_ARTIFACT_06"), "", function( )
                self:clearCardPool(function( )
                    sendMsg()
                end)
            end, 
            "")
        else
            self:clearCardPool(function( )
                sendMsg()
            end)
        end
        -- if true then return end
    end)
	self._iconNode = self:getUI("bg.iconNode")
    self._iconNode:setVisible(true)
	-- local icon = IconUtils:createItemIconById({itemId = 39999})
	-- self._iconNode:addChild(icon)
	-- local splice = ccui.ImageView:create()
	-- splice:loadTexture("globalImageUI_splice.png",1)
	-- splice:setContentSize(cc.size(35, 35))
	-- splice:setPosition(cc.p(0,icon:getContentSize().height-10))
	-- icon:addChild(splice,99)
    self._resultPanel = self:getUI("bg.resultPanel")
    self._resultPanel:setVisible(false)
    self._resultPanel:setCascadeOpacityEnabled(true)
    self._resultPanel:setPositionY(self._bg:getContentSize().height/2)
    self._resultLab = self:getUI("bg.resultPanel.resultLab")
    self._resultIcon = self:getUI("bg.resultPanel.icon")
	self._desNode = self:getUI("bg.desNode")
	-- local rtx = RichTextFactory:create("[color = 6f4620,fontsize=20]已选择[-][color = 00ff00]0[-][color = 6f4620,fontsize=20]件宝物　[-][color = 6f4620,fontsize=18](其中[-][color = ba55d3,fontsize=20]紫色[-][color = 6f4620,fontsize=18]以上x1)[-]",self._desNode:getContentSize().width,40)
 --    rtx:formatText()
 --    rtx:setVerticalSpace(7)
 --    rtx:setName("rtx")
 --    rtx:setPosition(cc.p(self._desNode:getContentSize().width/2,self._desNode:getContentSize().height-10))
 --    self._desNode:addChild(rtx)
 --    UIUtils:alignRichText(rtx,{valign = "left",halign = "bottom"})
 --    self._rtx1 = rtx
    self._poolData = {}
    self._breakPool = {}
    self:getCanBreakTreasures()
    self:addTableView()

    --自动选择 add by yuxiaojing
    self._selectQuality = {}
    local autoSelect = self:getUI("bg.autoSelect")
    self:registerClickEvent(autoSelect, function()
        local callback = function(selectQuality)
            self._selectQuality = selectQuality
            dump(self._selectQuality)
            self:autoSelect()
            self:calculateBreaks()
        end
        local param = {callback = callback, selectType = "treasure"}
        self._viewMgr:showDialog("weapons.WeaponsAutoSelectDialog", param)
    end)

    self:listenReflash("TreasureModel", self.reflashUI)
    self:listenReflash("ItemModel", self.reflashUI)

    -- 新UI
    self:initFireAnim()
end

function TreasureBreakView:autoSelect(  )
    local selectQuality = self._selectQuality
    self._breakPool = {}
    for k, v in pairs(self._tableData) do
        local toolD = tab:Tool(v.goodsId)
        local quality = (toolD and toolD.color ~= 9) and toolD.color or ItemUtils.findResIconColor(inTable.itemId,inTable.num)
        if selectQuality[quality] and v.stage >= self._stageMax then
            self._breakPool[v.goodsId] = v.num
        end
    end
    self._tableView:reloadData()
    self._iconNode:removeAllChildren()
    local index = 1
    for k, v in pairs(self._breakPool) do
        self:addCardToPool(k, v, true, index)
        index = index + 1
    end
end

--
function TreasureBreakView:initFireAnim( )
    local breakBg = self:getUI("bg.innerBg.breakBg")
    self._breakBg = breakBg
    -- local mc = mcMgr:createViewMC("baowufenjiehuoyan_duizhanui", true, false)
    -- mc:setPosition(300,0)
    -- breakBg:addChild(mc)

    local clipNode = cc.ClippingNode:create()
    clipNode:setPosition(320,0)
    clipNode:setContentSize(cc.size(0, 0))
    local mask = cc.Sprite:createWithSpriteFrameName("treasureBreak_bg.png")
    mask:setAnchorPoint(0.5,0)
    -- mask:setScale(0.95)
    clipNode:setStencil(mask)
    clipNode:setAlphaThreshold(0.05)
    -- clipNode:setInverted(true)
    clipNode:setCascadeOpacityEnabled(true)

    local mc = mcMgr:createViewMC("baowufenjiehuoyan_duizhanui", true,false)
    mc:setPosition(-0,20)
    clipNode:addChild(mc)
    mc:setCascadeOpacityEnabled(true)
    mc:play()
    mc:gotoAndStop(5)
    self._breakMc = mc

    -- 绑定方法
    self._breakMc._turnNormalAnim = function( )
        if not self._breakMc then return end
        -- self._breakMc:play()
        self._breakMc:gotoAndStop(0)
    end

    self._breakMc._turnBreakAnim = function( )
        if not self._breakMc then return end
        self._breakMc:gotoAndPlay(0)
    end
    -- self._breakMc:setPlaySpeed(0.2)
    self._breakMc:addCallbackAtFrame(30,function( )
        self._breakMc._turnNormalAnim()
    end)

    self._breakClipNode = clipNode

    breakBg:addChild(clipNode,999)
end

function TreasureBreakView:getCanBreakTreasures( )
    self._tableData = {}
    local allTreasures = self._modelMgr:getModel("ItemModel"):getTreasures()
    local tModel = self._tModel
    local disInfo

    for k,v in pairs(allTreasures) do
        if math.floor( tonumber(v.goodsId)/1000) ~= 41 then
            disInfo = tModel:getTreasureById(tostring(v.goodsId))
            v.stage = disInfo and disInfo.s or 0
            table.insert(self._tableData,v)
            self._poolData[v.goodsId] = v.num
        end
    end
    table.sort(self._tableData,function(a,b)
        local colorA = tab.tool[a.goodsId].color
        local colorB = tab.tool[b.goodsId].color
        if colorA ~= colorB then
            return colorA< colorB
        end
        return a.goodsId < b.goodsId
    end)
end
-- 接收自定义消息
function TreasureBreakView:reflashUI(data)
	self:getCanBreakTreasures()
	self._tableView:reloadData()
    -- self:calcuelateBreaks()
    self:runValueChangeAnim(self._des3,function( )
        local treasureCoin = self._modelMgr:getModel("UserModel"):getData().treasureCoin
        self._des3:setString(treasureCoin or 0)
    end)
    if self._tableData == nil or #self._tableData == 0 then
        self._tipsBg:setVisible(true)
    else
        self._tipsBg:setVisible(false)
    end
end
function TreasureBreakView:addTableView( )
    local tableView = cc.TableView:create(cc.size(688, 136))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(4,8))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    self._scrollBg:addChild(tableView)
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

function TreasureBreakView:scrollViewDidScroll(view)
    self._inScrolling = view:isDragging()
end

function TreasureBreakView:scrollViewDidZoom(view)
end

function TreasureBreakView:tableCellTouched(table,cell)
end

function TreasureBreakView:cellSizeForTable(table,idx) 
    return 100,683
end

function TreasureBreakView:tableCellAtIndex(table, idx)
    local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
    end
    cell:removeAllChildren()
    local row = idx*6
    for i=0,5 do
        local item 
        if i+row+1<=#self._tableData then
        --     item = self:createGrid()
        -- else
            item = self:createItem(self._tableData[i+row+1])
	        item:setPosition(cc.p(i*112+16,10))
	        item:setName("cellItem".. i)
	        cell:addChild(item)
        end
        -- if self._none then
        --     item:setVisible(false)
        -- end
    end 
    return cell
end

function TreasureBreakView:numberOfCellsInTableView(table)
   	local itemRow = math.ceil(#self._tableData/6)
	if itemRow < 1 then
	    itemRow = 1
	end
    return itemRow
end

function TreasureBreakView:addToPool( id,num,max )
	num = num or 1
	if not self._breakPool[id] then
		self._breakPool[id] = 0
	end
	if self._breakPool[id]+num > max then
		return max
	end
    self:addCardToPool( id,num )
    self._breakPool[id] = self._breakPool[id]+num
	return self._breakPool[id]
end

function TreasureBreakView:removeFromPool( id,num )
	num = num or 1
	if not self._breakPool[id] or  self._breakPool[id] == 0 then
		return 0
	end
	self._breakPool[id] = self._breakPool[id]-num
    self:removeFromCardPool(id,self._breakPool[id])
	if self._breakPool[id] <= 0 then
		self._breakPool[id] = nil
		return 0
	end
	return self._breakPool[id]
end

function TreasureBreakView:createItem( data )
	local item
    local function itemCallback( )
        if self._resultPanel and self._resultPanel:isVisible() then return end
        if not item or tolua.isnull(item) then return end
        if not self._inScrolling then
            -- print("data.goodsId...in itemCallBack...",data.goodsId)
            local pos1 = item:getParent():convertToWorldSpace(cc.p(item:getPositionX()+10,item:getPositionY()+10))
            local pos2 = self._bg:convertToNodeSpace(pos1)
            self._flyBeginPos = pos2
            local num = self:addToPool(data.goodsId,1,data.num)
            local numLab = item:getChildByName("iconColor"):getChildByName("numLab")
            local items = {}
            for k,v in pairs(self._breakPool) do
                table.insert(items,{k,v})
            end
         --    if num == 0 then
	        --     numLab:setString("")
	        -- else
	        -- 	numLab:setString(ItemUtils.formatItemCount(num) .. "/" .. ItemUtils.formatItemCount(self._poolData[data.goodsId]))
        	-- end
            -- if num > 0 then 
            -- 	item._subBtn:setVisible(true)
            -- end
            if num <= 0 then 
                item._subBtn:setVisible(false)
                numLab:setString(ItemUtils.formatItemCount(self._poolData[data.goodsId])) 
            else
                item._subBtn:setVisible(true)
                numLab:setString(ItemUtils.formatItemCount(num) .. "/" .. ItemUtils.formatItemCount(self._poolData[data.goodsId])) 
            end
             self:calculateBreaks()
        else
            self._inScrolling = false
        end
        -- print(data.goodsId,"点击的物品~~~")
    end

    local toolD = tab:Tool(data.goodsId)
    item = IconUtils:createItemIconById({itemId = data.goodsId,num = data.num,itemData = toolD,eventStyle = 0,effect=true})-- self._scrollItem:clone()
    local touchBeginX,touchBeginY
    local touchW = item:getContentSize().width*item:getScale()
    local touchH = item:getContentSize().height*item:getScale()
    local scheduled
    self:registerTouchEvent(item, function( _,x,y )
        touchBeginX,touchBeginY = x,y
        -- item:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function( )
        --     print("data.goodsId...in itemCallBack...",data.goodsId)
        --     item._clockOn = ScheduleMgr:regSchedule(100,self,function( )
        --         itemCallback()
        --     end)
        -- end)))
    end, function( _,x,y )
        local touchPoint = item:convertToNodeSpace(cc.p(x, y))
        if math.abs(touchBeginX-x)>= touchW*0.2  
            or math.abs(touchBeginY-y)>= touchH*0.2 
            or touchPoint.x < 0 or touchPoint.x > touchW 
            or touchPoint.y < 0 or touchPoint.y > touchH
        then
            if item._clockOn then
                ScheduleMgr:unregSchedule(item._clockOn)
                item._clockOn = nil
            end
        end
    end, function( )
        -- item:stopAllActions()
        if item._clockOn then
            ScheduleMgr:unregSchedule(item._clockOn)
            item._clockOn = nil
            scheduled = nil
        elseif not scheduled then
            itemCallback()
        end
    end, function(  )
        -- item:stopAllActions()
        print("item._clockOn",item._clockOn)
        if item._clockOn then
            ScheduleMgr:unregSchedule(item._clockOn)
            item._clockOn = nil
            scheduled = nil
            print("item._clockOn...and unregSchedule...")
        end
    end,function( )
        self._createTime = 1
        itemCallback()
        item._clockOn = ScheduleMgr:regSchedule(100,self,function( )
            self._createTime = self._createTime + 0.1
            itemCallback()
            scheduled = true
            if self._createTime >= 5 and self._createTime < 10 then
                if item._clockOn then
                    ScheduleMgr:unregSchedule(item._clockOn)
                    item._clockOn = nil
                    scheduled = nil
                end
                item._clockOn = ScheduleMgr:regSchedule(20,self,function( )
                    self._createTime = self._createTime + 0.02
                    itemCallback()
                    scheduled = true
                    if self._createTime >= 10 then
                        if item._clockOn then
                            ScheduleMgr:unregSchedule(item._clockOn)
                            item._clockOn = nil
                            scheduled = nil
                        end
                        item._clockOn = ScheduleMgr:regSchedule(10,self,function( )
                            self._createTime = self._createTime + 0.01
                            itemCallback()
                            scheduled = true
                        end)
                    end
                end)
            end
                

        end)
    end)
    item:setContentSize(cc.size(107, 107))
    -- item:setScale(100/item:getContentSize().width)
    item:setScale(0.9)
    item:setVisible(true)
    item:setSwallowTouches(false)
    -- local tmpTip = item:getChildByName("tip")
    -- if tmpTip then
    --     tmpTip:removeFromParent()
    -- end
    local numLab = item:getChildByName("iconColor"):getChildByName("numLab")
    numLab:setString(ItemUtils.formatItemCount(self._poolData[data.goodsId]))

    item._added = false
    local subBtn = ccui.ImageView:create("globalBtnUI_bigSubBtn_n.png", 1)
    subBtn:setAnchorPoint(cc.p(1,1))
    subBtn:setPosition(cc.p(item:getContentSize().width-10,item:getContentSize().height-10))
    subBtn:setVisible(false)
    item._subBtn = subBtn
    item:addChild(subBtn,99)
    local btnTouchLayer = ccui.Layout:create()
    btnTouchLayer:setBackGroundColorType(1)
    btnTouchLayer:setContentSize(cc.size(30,30))
    btnTouchLayer:setBackGroundColor(cc.c3b(128, 128, 0))
    btnTouchLayer:setBackGroundColorOpacity(0)
    btnTouchLayer:setAnchorPoint(cc.p(1,1))
    btnTouchLayer:setPosition(cc.p(item:getContentSize().width-10,item:getContentSize().height-10))
    item:addChild(btnTouchLayer,100)
    local num = self._breakPool[data.goodsId]

    if num and num > 0 then 
        numLab:setString(ItemUtils.formatItemCount(num) .. "/" .. ItemUtils.formatItemCount(self._poolData[data.goodsId])) 
        subBtn:setVisible(true)
    else
        item._subBtn:setVisible(false)
        numLab:setString(ItemUtils.formatItemCount(self._poolData[data.goodsId]))
        subBtn:setVisible(false) 
    end

    local btnCallBack = function(  )
        if not tolua.isnull(subBtn) and subBtn:isVisible() then
            if self._resultPanel and self._resultPanel:isVisible() then return end
            local num = self:removeFromPool(data.goodsId)
            local numLab = item:getChildByName("iconColor"):getChildByName("numLab")
            if num <= 0 then 
                item._subBtn:setVisible(false)
                numLab:setString(ItemUtils.formatItemCount(self._poolData[data.goodsId])) 
                if btnTouchLayer._clockOn then
                    ScheduleMgr:unregSchedule(btnTouchLayer._clockOn)
                    btnTouchLayer._clockOn = nil
                end
            else
                numLab:setString(ItemUtils.formatItemCount(num) .. "/" .. ItemUtils.formatItemCount(self._poolData[data.goodsId])) 
            end
            -- local num = self:addToPool(data.goodsId,1,data.num)
            self:calculateBreaks()
        end
    end
    local touchBeginX1,touchBeginY1
    local touchW1 = btnTouchLayer:getContentSize().width*btnTouchLayer:getScale()
    local touchH1 = btnTouchLayer:getContentSize().height*btnTouchLayer:getScale() 
    self:registerTouchEvent(btnTouchLayer, function( _,x,y )
        touchBeginX1,touchBeginY1 = x,y
        btnTouchLayer:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function( )
            btnTouchLayer._clockOn = ScheduleMgr:regSchedule(100,self,function( )
                -- btnCallBack()
                if not tolua.isnull(subBtn) and subBtn:isVisible() then
                    btnCallBack()
                elseif btnTouchLayer._clockOn then
                    ScheduleMgr:unregSchedule(btnTouchLayer._clockOn)
                    btnTouchLayer._clockOn = nil
                end
            end)
        end)))
    end, function( _,x,y )
        local touchPoint = btnTouchLayer:convertToNodeSpace(cc.p(x, y))
        if math.abs(touchBeginX1-x)>= touchW1  
            or math.abs(touchBeginY1-y)>= touchH1 
            or touchPoint.x < 0 or touchPoint.x > touchW1 
            or touchPoint.y < 0 or touchPoint.y > touchH1
        then
            btnTouchLayer:stopAllActions()
            if btnTouchLayer._clockOn then
                ScheduleMgr:unregSchedule(btnTouchLayer._clockOn)
                btnTouchLayer._clockOn = nil
            end
        end
    end, function( )
        btnTouchLayer:stopAllActions()
        if btnTouchLayer._clockOn then
            ScheduleMgr:unregSchedule(btnTouchLayer._clockOn)
            btnTouchLayer._clockOn = nil
        else
            if subBtn and subBtn:isVisible() then
                btnCallBack()
            -- else
            --     itemCallback()
            end
        end
    end, function(  )
        btnTouchLayer:stopAllActions()
        if btnTouchLayer._clockOn then
            ScheduleMgr:unregSchedule(item._clockOn)
            btnTouchLayer._clockOn = nil
        end
    end)

    --满级  by hgf
    local maxImg = ccui.ImageView:create("treasureBreak_levelMax.png", 1)
    maxImg:setAnchorPoint(0, 0)
    maxImg:setPosition(cc.p(4, 7))
    maxImg:setVisible(false)
    item._maxImg = maxImg 
    item:addChild(maxImg, 1000)
    if data.stage >= self._stageMax then
        maxImg:setVisible(true)
    end
    
    return item
end

function TreasureBreakView:calculateBreaks(  )
	local breaks = 0
	local purpleSel = 0
	local selNum = 0
	for id,num in pairs(self._breakPool) do
		local disT = tab:DisTreasure(id)
		local fragNum = disT.fragNum
		breaks = breaks + fragNum*num
		if disT.quality >= 4 then
			purpleSel = purpleSel + num
		end
		selNum = selNum + num
	end
	self._numLab:setString("x" .. (breaks or 0)) -- "宝物精华X" .. 
    UIUtils:alignNodesToPos({self._des1,self._smallJinghuaImg,self._numLab},100)
    self._resultLab:setString(breaks or 0)
    UIUtils:center2Widget(self._resultIcon,self._resultLab,5)
    -- print(selNum,"......selNum")
	self._selNumLab:setString(selNum)
	self._countNum:setString("及以上宝物X" .. purpleSel .. ")")
	
	-- 调整位置
	-- self._des3:setPositionX(self._selNumLab:getPositionX()+self._selNumLab:getContentSize().width+2)
    -- if self._selNumLab:getContentSize().width > 10 then
		-- self._addtionNode:setPositionX(self._des3:getPositionX()+self._des3:getContentSize().width+2)
	-- end
    return purpleSel
end
local maxDisplayNum = 10
-- 新逻辑 列牌
function TreasureBreakView:addCardToPool( itemId,num, noAnim, order )
    local itemIcon = self._iconNode:getChildByName("card_" .. itemId)
    if not itemIcon then
        order = order or table.nums(self._breakPool)
        itemIcon = IconUtils:createItemIconById({itemId = itemId,num = num,itemData = tab.tool[itemId],eventStyle = 0,effect=true})
        itemIcon:setName("card_" .. itemId)
        itemIcon._order = order
        self._iconNode:addChild(itemIcon)
        itemIcon:setVisible(false)
    else
        IconUtils:updateItemIconByView(itemIcon,{itemId = itemId,num = num+(self._breakPool[itemId] or 0),itemData = tab.tool[itemId],eventStyle = 0,effect=true})
    end 
    itemIcon:setScale(0.8)
    local children = self._iconNode:getChildren()
    local count = #children
    local posx = self:getCardPosByOrder(count,itemIcon._order)
    itemIcon:setPositionX(posx)
    if noAnim then
        itemIcon:setVisible(true)
        self:sortCards()
        return
    end
    local pos1 = itemIcon:getParent():convertToWorldSpace(cc.p(itemIcon:getPositionX(),itemIcon:getPositionY()))
    local pos2 = self._bg:convertToNodeSpace(pos1)
    self._flyToPos = pos2
    self:showItemFlyAnim(itemId,pos2,function( )
        self:sortCards()
        if not tolua.isnull(itemIcon) then 
            itemIcon:setVisible(true)
            itemIcon:setBrightness(40)
            itemIcon:runAction(cc.Sequence:create(
                cc.DelayTime:create(0.05),
                cc.CallFunc:create(function( )
                    itemIcon:setBrightness(0)
                end)
            ))
        end
    end)
end

function TreasureBreakView:removeFromCardPool( itemId,num )
    local itemIcon = self._iconNode:getChildByName("card_" .. itemId)
    if itemIcon then
        if num > 0 then
            IconUtils:updateItemIconByView(itemIcon,{itemId = itemId,num = num,itemData = tab.tool[itemId],eventStyle = 0,effect=true})
        else
            local removedOrder = itemIcon._order
            self:sortCards(removedOrder)
            itemIcon:removeFromParent()
        end
    end
end

local cardW = 75
local displayCount = 5
local cardsW = cardW*displayCount

function TreasureBreakView:sortCards( removeOrder )
    local children = self._iconNode:getChildren()
    local count = #children
    if removeOrder then
        count = count - 1
    end
    for k,icon in pairs(children) do
        local order = icon._order
        if removeOrder and (order > removeOrder) then
            order = order - 1
            icon._order = order 
        end
        local posx = self:getCardPosByOrder(count,order)
        icon:setPositionX(posx)
        icon:setZOrder(count-order+99)
    end
end

function TreasureBreakView:getCardPosByOrder( count,order )
    local posx = 0
    local blank = 0
    if count > displayCount then
        blank = cardsW/(count-1)
        posx = (order-1)*blank-cardsW*0.5
    else
        posx = (order-1)*cardW-count*cardW*0.5
    end
    return posx-5
end

function TreasureBreakView:clearCardPool( callback )
    -- 火焰上升动画
    if self._breakMc and self._breakMc._turnBreakAnim then
        self._breakMc._turnBreakAnim()
    end
    local targetPos = cc.p(-cardW/2,-92)
    local children = self._iconNode:getChildren()
    for i,icon in ipairs(children) do
        if i == 1 then
            self:showFlyAnim(icon,targetPos,function( )
                self._iconNode:removeAllChildren()
                self._resultPanel:setOpacity(0)
                self._resultPanel:setVisible(true)
                self._breakDesBg:setVisible(false)
                local mc = mcMgr:createViewMC("baowufenjie_treasureui", false, false)
                mc:addCallbackAtFrame(14,function( )
                    local bgHW,bgHH = self._bg:getContentSize().width/2,self._bg:getContentSize().height/2
                    self._resultPanel:runAction(cc.Sequence:create(
                        cc.Spawn:create(
                            cc.FadeIn:create(0.1),
                            cc.EaseIn:create(
                                cc.MoveTo:create(0.1,cc.p(bgHW-10,bgHH+80)),
                                0.3
                            )
                        ),
                        cc.DelayTime:create(0.2),
                        cc.CallFunc:create(function(  )
                            self:showFlyAnim(self._resultPanel,cc.p(100,bgHH+195),function( )
                                self._resultPanel:setVisible(false)
                                self._breakDesBg:setOpacity(0)
                                self._breakDesBg:setVisible(true)
                                self._breakDesBg:runAction(cc.Sequence:create(
                                    cc.DelayTime:create(1),
                                    cc.FadeIn:create(0.2)
                                ))
                                self._resultPanel:setPosition(bgHW-10,bgHH)
                                callback()
                            end)
                        end)
                    ))
                end)
                if self._breakClipNode then
                    mc:setPosition(20,50)
                    self._breakClipNode:addChild(mc,999)
                else
                    mc:setPosition(0,-50)
                    self._iconNode:addChild(mc,999)
                end
            end)
        else
            self:showFlyAnim(icon,targetPos)
        end
    end
end

-- -- 飞入效果及回调
function TreasureBreakView:showItemFlyAnim( itemId,targetPos,callback )
    local flyIcon = IconUtils:createItemIconById({itemId = itemId,itemData = tab.tool[itemId],eventStyle = 0,effect=true})
    self._bg:addChild(flyIcon,99999)
    -- flyIcon:setOpacity(0.8)
    flyIcon:setScale(0.8)
    flyIcon:setPosition(self._flyBeginPos.x,self._flyBeginPos.y)
    self:showFlyAnim(flyIcon,targetPos,callback,true)
end

-- 飞动画 
function TreasureBreakView:showFlyAnim( node,targetPos,callback,isRemove )
    node:runAction(cc.Sequence:create(cc.MoveTo:create(0.2,targetPos),cc.CallFunc:create(function()
        if callback then
            callback()
        end
        if isRemove then
            node:removeFromParent()
        end
    end)))
end

-- 数值变化动画
function TreasureBreakView:runValueChangeAnim( label,endFunc )
    if not label then return end
    if not label:getActionByTag(101) then
        local preColor = label:getColor()
        label.treasureBreakView_endFunc = endFunc
        if not label.changeColor then
            label:setColor(cc.c3b(0, 255, 0))
        else
            label:setColor(label.changeColor)
        end
        local seq = cc.Sequence:create(cc.ScaleTo:create(0.05,1.3),cc.ScaleTo:create(0.05,1),cc.CallFunc:create(function( )
            label:setColor(preColor)
            if type(label.treasureBreakView_endFunc) == "function" then
                label.treasureBreakView_endFunc(index)
            end
        end))
        seq:setTag(101)
        label:runAction(seq)
    else
        label.treasureBreakView_endFunc = endFunc
    end
end


return TreasureBreakView