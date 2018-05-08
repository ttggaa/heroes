--
-- Author: huangguofang
-- Date: 2016-04-01 10:32:15
--

--[[-- lang表
	jianianhua_rule_acID   	规则
	jianianhua_tip1_acID	气泡1
	jianianhua_tip2_acID	气泡2
	jianianhua_tip3_acID	气泡3

--]]
local cc = cc
local ActivityCarnival = class("ActivityCarnival",BasePopView)

function ActivityCarnival:ctor(data)
    ActivityCarnival.super.ctor(self)
    self._callback = data.callback

	self._userModel = self._modelMgr:getModel("UserModel")	
	self._carnivalModel = self._modelMgr:getModel("ActivityCarnivalModel")	
end


function ActivityCarnival:getAsyncRes()
    return 
    {
        {"asset/ui/activityCarnival.plist", "asset/ui/activityCarnival.png"},
        {"asset/ui/activityCarnival1.plist", "asset/ui/activityCarnival1.png"},
    }
end


local labelTag = {
	levelBtn = 1,
	kingBtn = 2,
	eliteBtn = 3,
}
local titlePos = {
	[912] = {bgPos = {140,580},txtPos={315,510}}
}
local normalColor = cc.c4b(78,50,13,255)
local normalOutColor = cc.c4b(30, 75, 172, 255)
local selectColor = cc.c4b(198,79,37,255)
local selectOutColor = cc.c4b(43, 87, 183, 255)
-- 第一次被加到父节点时候调用
function ActivityCarnival:onAdd()

end
-- 初始化UI后会调用, 有需要请覆盖
function ActivityCarnival:onInit()
	-- 打开界面有需要刷新数据（停留在主界面的时候有数据推送）
	local carnivalModel = self._modelMgr:getModel("ActivityCarnivalModel")
    carnivalModel:doUpdate()

	self._days = {}
	self._typeTable = {}
	self._currData1 = {}
	self._currData2 = {}
	self._currData3 = {}
	self._tableData = self._carnivalModel:getData() or {}
	self._haveGetNum1 = 0
	self._haveGetNum2 = 0
	self._haveGetNum3 = 0

	self._currBtn = 1
	self._currLabel = 1

   	-- cell W H
    self._tableCellW,self._tableCellH = 566 , 130 --self._item:getContentSize().width,self._item:getContentSize().height

	-- 每次进界面判断是否需要滚动左侧按钮 >4 的时候需要滚动
	self._isGoButtom = true
	self._activityDay = 7
    self._acId = self._carnivalModel:getCarnivalId()
	self._day,self._leftTime = self._carnivalModel:getCurrDay()
	self._leftDay = self._activityDay - self._day

	local ribben1 = self:getUI("bg.ribben1")
	ribben1:setVisible(912 ~= self._acId)
	local ribben2 = self:getUI("bg.ribben2")
	ribben2:setVisible(912 ~= self._acId)

	local ribben4 = self:getUI("bg.ribben4")
	ribben4:setVisible(911 == self._acId)
	--判断是否是某天第一次进嘉年华
	self._isFirst = false	
	-- SystemUtils.saveAccountLocalData("loginCarnivalDay",0)
	local loginDay = SystemUtils.loadAccountLocalData("loginCarnivalDay")

	if not loginDay then
		self._isFirst = true		
		SystemUtils.saveAccountLocalData("loginCarnivalDay",self._day)
	else
		if loginDay < self._day then
			self._isFirst = true
			SystemUtils.saveAccountLocalData("loginCarnivalDay",self._day)
		end
	end
	-- SystemUtils.saveAccountLocalData("loginCarnivalDay",1)
	-- self._isFirst = true	

	-- 注册关闭按钮
	self:registerClickEventByName("bg.closeBtn", function()
		if self._callback then
			self._callback()
		end
		
		self:doClose()
	end)

	-- 初始化界面显示
    local bg_img = self:getUI("bg.bg_img")
    bg_img:setZOrder(-1)
    bg_img:loadTexture("asset/bg/activity_bg_paper.png")  --bg_activityCarnival2    
    local title_red_bg = self:getUI("bg.title_red_bg")
    title_red_bg:loadTexture("redTtitle_bg_"..self._acId..".png",1)
    title_red_bg:setZOrder(912 == self._acId and 10 or 2)
    local title_img = self:getUI("bg.title_img")
    title_img:loadTexture("activity_carnival_title_"..self._acId..".png",1) 
    if titlePos[self._acId] then
    	local pos = titlePos[self._acId]
    	title_red_bg:setPosition(pos.bgPos[1], pos.bgPos[2])
		title_img:setPosition(pos.txtPos[1], pos.txtPos[2])
	end
        
    local pumpkin908 = self:getUI("bg.pumpkin908")
    -- pumpkin908:setVisible(908 == self._acId) 
    pumpkin908:setVisible(false)
    -- local dayBtn_Bg = self:getUI("bg.dayBtn_Bg")
    -- dayBtn_Bg:loadTexture("activity_carnival_buttonBg_"..self._acId..".png",1) 
    
    -- local progressBg = self:getUI("bg.progressBg")
    -- progressBg:loadTexture("activity_progressBg_"..self._acId..".png",1) 
    -- local progress = self:getUI("bg.progress")
    -- progress:loadTexture("activity_progress_"..self._acId..".png",1)     

    -- 标签
    self._bg = self:getUI("bg")
    self._levelBtn = self:getUI("bg.right_bg.btn1")
    self._kingBtn = self:getUI("bg.right_bg.btn2")
    self._eliteBtn = self:getUI("bg.right_bg.btn3")
    self._levelBtn:setTag(5)
    self._kingBtn:setTag(5)
    self._eliteBtn:setTag(5)

    self._levelBtn:setTitleFontName(UIUtils.ttfName)
    self._levelBtn:setTitleFontSize(24)
    self._kingBtn:setTitleFontName(UIUtils.ttfName)
    self._kingBtn:setTitleFontSize(24)
    self._eliteBtn:setTitleFontName(UIUtils.ttfName) 
    self._eliteBtn:setTitleFontSize(24)

	-- 领取按钮事件
	registerClickEvent(self._levelBtn,function(sender) 
	    self:LabelChangeState(labelTag.levelBtn)
	    self._currLabel = 1
	    self._currData = self._currData1
	    if self._currData and self._itemScrollView then
	    	self._itemScrollView:reloadData()
	    end
	    -- self:updateItemScrollView(self._currData1,1)
    end)
	registerClickEvent(self._kingBtn,function(sender) 
	    self:LabelChangeState(labelTag.kingBtn)
	    self._currLabel = 2
	    self._currData = self._currData2
	    -- self:updateItemScrollView(self._currData2,2)
	    if self._currData and self._itemScrollView then
	    	self._itemScrollView:reloadData()
	    end
    end)
	registerClickEvent(self._eliteBtn,function(sender) 
	    self:LabelChangeState(labelTag.eliteBtn)
	    self._currLabel = 3
	    self._currData = self._currData3
	    -- self:updateItemScrollView(self._currData3,3)
	    if self._currData and self._itemScrollView then
	    	self._itemScrollView:reloadData()
	    end
    end)

	--左侧按钮scrollView
    self._dayBtnScrollView = self:getUI("bg.dayBtn_scrollView")
    self._dayBtnScrollView:setBounceEnabled(true)

	self._dayImg = self:getUI("bg.day_img")

	if self._leftDay >= 0 then 
		self._dayImg:loadTexture("activity_carnival_num"..self._leftDay..".png",1)	
	else		
		self._dayImg:loadTexture("activity_carnival_num0.png",1)
	end

	self._activityDes = self:getUI("bg.day_img.des_txt")
	-- self._activityDes:enableOutline(cc.c4b(111,24,26),2)
	
	-- if self._leftDay <= 0 then
	-- 	self._activityDes:setString("领取结束时间")
	-- end
	local dayTxt = self:getUI("bg.day_img.day")
	-- dayTxt:enableOutline(cc.c4b(111,24,26),2)    -- 31,8,0

	-- self:updateTimeLabel()
	--计算倒计时	
	local timeCount = self:getUI("bg.day_img.timeCount")	
	local timerFunc = function()
		local day 
		day,self._leftTime = self._carnivalModel:getCurrDay()
		-- if self._leftDay <= 0 then
		-- 	self._activityDes:setString("领取结束时间")
		-- end
        if self._leftDay >= 0 and self._leftTime > 1 then 
       		self._leftTime = self._leftTime - 1 
       		timeCount:setString(string.format("%02d:%02d:%02d",math.floor(self._leftTime/3600),math.floor((self._leftTime%3600)/60),self._leftTime%60) or 0)
       	elseif self._leftDay >= 0 and self._leftTime <= 1  then   
       		self._leftDay = self._leftDay - 1    		
       		if self._leftDay < 0 then
	       		self._leftTime = 0    
	       		self._dayImg:loadTexture("activity_carnival_num0.png",1)   		
	       		timeCount:setString("00:00:00")
	       		if self.timer then
			        ScheduleMgr:unregSchedule(self.timer)
			        self.timer = nil
			    end
	       		self:reflashCarnivalUI()
	       	else	
       			-- self._leftDay = self._leftDay - 1
       			self._day = self._day + 1
	       		self._leftTime = 86400
	       		-- SystemUtils.saveAccountLocalData("loginCarnivalDay",self._day)
       			-- self._isFirst = true       			
       			self._carnivalModel:updateCarnivalData()
       			self:updateTimeLabel(true)    
	       		-- self._dayImg:loadTexture("activity_carnival_num"..leftDay..".png",1)
	       		timeCount:setString(string.format("%02d:%02d:%02d",math.floor(self._leftTime/3600),math.floor((self._leftTime%3600)/60),self._leftTime%60) or 0)
       			
       		end
       end       
    end
    if self._leftDay >= 0 then 
	    timerFunc()
		self._timerFunc = timerFunc
		self.timer = ScheduleMgr:regSchedule(1000,self,function( )
			if self._timerFunc then
	        	self._timerFunc()
	        else
	        	ScheduleMgr:unregSchedule(self.timer)
        		self.timer = nil
	        end
	    end)
	else
		timeCount:setString("00:00:00")
	end

	--全目标奖励btn
	self._targetBtn = self:getUI("bg.target_btn")
	self._targetBtn:loadTextures("activity_targetBtn_" .. self._acId .. ".png" ,"activity_targetBtn_" .. self._acId .. ".png","",1)
	local mc = mcMgr:createViewMC("mubiaojiangli_carnivaltargetanim", true,false)
	mc:setPosition(self._targetBtn:getContentSize().width/2, self._targetBtn:getContentSize().height/2)
	self._targetBtn:addChild(mc,10)
	self:registerClickEventByName("bg.target_btn", function()
		if self._timerFunc then
			self._timerFunc()
		end
		local bIsCarBtnClick = SystemUtils.loadAccountLocalData("CARNIVAL_TARGET" .. self._acId)
		if not bIsCarBtnClick then
			self._isHaveBubble = false 
			SystemUtils.saveAccountLocalData("CARNIVAL_TARGET" .. self._acId, true)
		end
		-- 用于判断全目标可领时按钮气泡的显示
		self._carnivalModel:setClickState(true)
		self._viewMgr:showDialog("activity.ActivityCarnivalTarget", {parentView = self,targetBtn = self._targetBtn,viewType = 2}, false)
	end)  
	
	--防止旗袍重复添加 
	self._isHaveBubble = false 
	--添加气泡 1-6天没点过全目标显示气泡1，第7天没点过全目标显示气泡2
	local bubble1 = self._targetBtn:getChildByFullName("bubble1") 
	local bubble2 = self._targetBtn:getChildByFullName("bubble2")
	local bubble3 = self._targetBtn:getChildByFullName("bubble3")	
	bubble2:setSwallowTouches(false)
	bubble1:setSwallowTouches(false)
	bubble3:setSwallowTouches(false)

	-- 春节嘉年华 屏蔽气泡逻辑
	if self._acId ~= 912 then
		self:addBubbles(self._targetBtn)
	else
		self._isHideBubble = true
		bubble2:setVisible(false)
		bubble1:setVisible(false)
		bubble3:setVisible(false)
	end

	self._progressBar = self:getUI("bg.progress")
	-- progressBar:setCapInsets(cc.rect(0, 0, 1, 1))
	 -- 给进度条增加遮罩
    -- self._progressBar

    self._proTxt = self:getUI("bg.progressTxt")
    self._proTxt:setString("/0")
    self._proTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._getNum1 = self:getUI("bg.getNum1")
    self._getNum1:setString("0")
    self._getNum1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    self._proTxt:setString("/"..table.getn(self._tableData))
    self._getNum1:setString(self._carnivalModel:getTotalStatus())
    self._getNum1:setZOrder(101)
	self._proTxt:setZOrder(101)
	self._progressBar:setPercent(self._carnivalModel:getTotalStatus()/table.getn(self._tableData)*100)

	--初始化数据
	-- self:changeScrollViewData(self._currBtn)
	-- self:setVisible(false)
	-- ScheduleMgr:nextFrameCall(self, function()
	-- 	-- self:setVisible(true)
	-- end) 
	self:addLeftBtn(self._day)
	self:updateLeftBtn(self._day)	
	self:changeScrollViewData(self._currBtn)
    self:addTableView()  -- 添加tableView

	self:listenReflash("ActivityCarnivalModel", self.reflashCarnivalUI)
	-- 进嘉年华时的玩家等级
	self._userLvl = self._userModel:getPlayerLevel()
	--监听userModel 玩家等级发生变化且返回主界面 关闭嘉年华
	self:listenReflash("UserModel", self.levelUpNeedClose)
end
--关闭当前界面
function ActivityCarnival:levelUpNeedClose()
	-- 如果等级没有发生变化 不作处理	
	local userLvl = self._userModel:getPlayerLevel()
	if self._userLvl >= userLvl then
		return
	end
	
	local lvData = tab.userLevel[userLvl]
	local gotoview = 0
	if lvData then
		gotoview = lvData["gotoview"] or 0
	end
	-- 升级 & 返回主界面
    if 1 == gotoview then  
		if self._callback then
			self._callback()
		end
		
		self:doClose(true)
 	end
	
end

function ActivityCarnival:doClose(noAnim)	
	if self.timer then
        ScheduleMgr:unregSchedule(self.timer)
        self.timer = nil
    end
    if OS_IS_WINDOWS then
    	UIUtils:reloadLuaFile("activity.ActivityCarnival")
    end
    self:close(noAnim)
end

-- 添加嘉年华气泡
-- 嘉年华将有三条提示
-- 1 玩家没有点击过嘉年华全目标 显示tips1
-- 2 玩家点击过一次全目标奖励后，不再显示tip1，改为常态显示tip2，直到全目标奖励可领
-- 3 全目标奖励可领，显示tip3，玩家点击过全目标奖励一次后，本次登录不再显示tip3（但下次登录还会显示）
function ActivityCarnival:addBubbles(target)
	if self._isHideBubble then return end
	--第七天是否点击过全目标btn
	local bIsLastClick = self._carnivalModel:getClickState()-- SystemUtils.loadAccountLocalData("CARNIVAL_GETAWARD")
	--是否点击过全目标btn
	local bIsCarBtnClick = SystemUtils.loadAccountLocalData("CARNIVAL_TARGET" .. self._acId)
	local bubble1 = target:getChildByFullName("bubble1")	
	local bubble2 = target:getChildByFullName("bubble2")	
	local bubble3 = target:getChildByFullName("bubble3")
	bubble1:setVisible(false)
	bubble2:setVisible(false)
	bubble3:setVisible(false)

	if bIsLastClick then
		bubble3:setVisible(false)
		bubble3:stopAllActions()
	end
	if bIsCarBtnClick then
		bubble1:setVisible(false)
		bubble1:stopAllActions()
	end
	--如果已经初始化过气泡，不再初始化
	if self._isHaveBubble then return end

	--获取当前天数
	local day ,_ = self._carnivalModel:getCurrDay()
	local isCanget = self._carnivalModel:isTargetCanGet()
	if isCanget then
		if not bIsLastClick then
			bubble3:setVisible(true)
			bubble3:setTouchEnabled(true)
			bubble3:setSwallowTouches(true)
			--初始化气泡3
			local str = lang("jianianhua_tip3_" .. self._acId) or " "
			self:initBubbleAction(bubble3,str,3)
		end
	else
		if 7 ~= day then 
			if not bIsCarBtnClick then
				bubble1:setVisible(true)
				bubble1:setTouchEnabled(true)
				bubble1:setSwallowTouches(true)
				-- 初始化气泡1
				local str = lang("jianianhua_tip1_" .. self._acId) or " "
				self:initBubbleAction(bubble1,str,1)
			else
				bubble2:setVisible(true)				
				bubble2:setTouchEnabled(true)
				bubble2:setSwallowTouches(true)
				-- 初始化气泡2
				local str = lang("jianianhua_tip2_" .. self._acId) or " "
				self:initBubbleAction(bubble2,str,2)
			end
		end
	end

	self._isHaveBubble = true
end
function ActivityCarnival:initBubbleAction(target,str,num)
	-- 初始化气泡1
	local uiText = target:getChildByFullName("text")
	uiText:setVisible(false)
	local targetNum = num or 1
	local str1 = str
	if string.find(str1, "color=") == nil then
        str1 = "[color=000000]"..str1.."[-]"
    end  
	local label1 = RichTextFactory:create(str1, uiText:getContentSize().width, uiText:getContentSize().height)
    label1:formatText()
    label1:setName("labelTxt")
    target:addChild(label1,11)
   
   	local labelW = label1:getRealSize().width
   	local w = target:getContentSize().width
   	local targetW = targetNum == 1 and target:getContentSize().width or (labelW + 22)
    local targetH = math.max(label1:getRealSize().height + 20 ,80)

    local offsetX = targetNum == 1 and 6 or 0
 	target:setContentSize(targetW,targetH) 	
	label1:setPosition(w*0.5 + offsetX,targetH*0.5)

    --action
    local seq = cc.Sequence:create(cc.DelayTime:create(0.5),
		cc.CallFunc:create(function()
            target:setVisible(true)
        end),cc.DelayTime:create(2),
        cc.CallFunc:create(function()
            target:setVisible(false)
        end),cc.DelayTime:create(10.5))
	local forever = cc.RepeatForever:create(seq)
    --执行forever
	target:runAction(forever)

end

function ActivityCarnival:addTableView( )
	if self._itemScrollView then  
		self._itemScrollView:removeFromParent()
		self._itemScrollView = nil
	end
	local scrollPanel = self:getUI("bg.right_bg.item_ScrollView")
    local tableView = cc.TableView:create(cc.size(scrollPanel:getContentSize().width, scrollPanel:getContentSize().height-5))
    -- local tableView = cc.TableView:create(cc.size(573, 392))
    -- tableView:setClippingType(1)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(scrollPanel:getPosition())
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    -- tableView:setBounceEnabled(true)
    scrollPanel:getParent():addChild(tableView,1)
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
    self._itemScrollView = tableView
    tableView:reloadData()
end


function ActivityCarnival:scrollViewDidScroll(view)
	self._inScrolling = view:isDragging()	
end

function ActivityCarnival:scrollViewDidZoom(view)
    -- print("scrollViewDidZoom")
end

function ActivityCarnival:tableCellTouched(table,cell)
    print("cell touched at index: " .. cell:getIdx())
end

function ActivityCarnival:cellSizeForTable(table,idx) 
    return self._tableCellH+5,self._tableCellW
    -- return 110,566
end

function ActivityCarnival:tableCellAtIndex(table, idx)
    local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    local label = nil
	local cellData = self._currData[idx+1]

    if nil == cell then
        cell = cc.TableViewCell:new()	     
	    local item = self:creatItem(cellData,idx+1)
	    item:setPosition(0,5)
	    item:setName("cellItem")
	    item:setAnchorPoint(0,0)
	    cell:addChild(item)
    else
    	local cellItem = cell:getChildByFullName("cellItem")    	
        self:updateCellItem(cellItem,cellData, idx)       
        
    end

    return cell
end
function ActivityCarnival:numberOfCellsInTableView(table)
	return #self._currData
end
function ActivityCarnival:updateTimeLabel(isFresh)
	-- self._showDay = self._leftDay - 1
	if self._leftDay >= 0 then 
		self._dayImg:loadTexture("activity_carnival_num"..self._leftDay..".png",1)	
	else		
		self._dayImg:loadTexture("activity_carnival_num0.png",1)
	end

	-- if self._leftDay <= 0 then
	-- 	self._activityDes:setString("领取结束时间")
	-- end

    self:addLeftBtn(self._day)  
    -- if not isFresh then 
    -- 	self:updateLeftBtn(self._day)
    -- end
    if self._itemScrollView then
		self._itemScrollView:reloadData()
	end
end
function ActivityCarnival:addLeftBtn(dayNum)
	if not dayNum then
		dayNum = 1
	end
	self._noticeIndex = 7
	self._dayBtnScrollView:removeAllChildren()
	local itemW = 172
	local itemH = 62
	local itemNum = 6 --self._activityDay
	local scrollHeight = itemH * itemNum
	self._dayBtnScrollView:setInnerContainerSize(cc.size(self._dayBtnScrollView:getContentSize().width+50,scrollHeight + 10))
	
	for i=1,6 do		
		local button = ccui.Button:create("activity_carnival_dayBtn_n.png", "activity_carnival_dayBtn_n.png", "", 1)
		button:setTag(i)
		button:setName("button")

	    --[[
	 	local img1 = ccui.ImageView:create()
	 	img1:loadTexture("activity_num_wordDi.png", 1)
	 	img1:setPosition(button:getContentSize().width*0.5-40,button:getContentSize().height*0.5)
	 	button:addChild(img1)

	 	local img2 = ccui.ImageView:create()
	 	img2:loadTexture("activity_num_wordDay.png", 1)
	 	img2:setPosition(button:getContentSize().width*0.5+40,button:getContentSize().height*0.5)
	 	button:addChild(img2)

	 	local imgNum = ccui.ImageView:create()
	 	imgNum:loadTexture("activity_num" .. i .. ".png", 1)
	 	imgNum:setPosition(button:getContentSize().width*0.5,button:getContentSize().height*0.5)
	 	button:addChild(imgNum)

	 	local imgSelected = ccui.ImageView:create()
	 	imgSelected:setName("selectedImg")
	 	imgSelected:loadTexture("activity_carnival_selected.png", 1)
	 	imgSelected:setPosition(button:getContentSize().width*0.5,button:getContentSize().height*0.5)
	 	button:addChild(imgSelected)
	    ]]

		-- 标题
		local btnTxt = ccui.Text:create()
	    btnTxt:setFontSize(26)
	    btnTxt:setName("btnTxt")
	    btnTxt:setFontName(UIUtils.ttfName)
	    btnTxt:setString("第 " .. i .. " 天")
	    btnTxt:setColor(cc.c4b(242,224,200,255))
	    btnTxt:setAnchorPoint(0.5,0.5)
	    btnTxt:setPosition(button:getContentSize().width*0.5,button:getContentSize().height*0.5)
	    button:addChild(btnTxt,1)
	    -- + 1 设置查看次日信息,第二天不加锁
	    if i > (dayNum + 1) then
	    	local lock = cc.Sprite:createWithSpriteFrameName("pokeImage_suo.png")
	    	lock:setScale(0.8)
	    	lock:setPosition(button:getContentSize().width - lock:getContentSize().width*lock:getScale() + 5, button:getContentSize().height/2)
	    	button:addChild(lock)
		end
	    registerClickEvent(button,function(sender)
	    	-- +1 设置查看次日信息，可点击
	    	if tonumber(sender:getTag()) > (dayNum + 1) then
	    		self._viewMgr:showTip("第"..sender:getTag().."天开启")
	    	else
	    		self._currBtn = sender:getTag()
	    		self:buttonChangeState(tonumber(sender:getTag()))
        		self:changeScrollViewData(tonumber(sender:getTag()))
        		if self._currData and self._itemScrollView then
			    	self._itemScrollView:reloadData()
			    end
        	end
        end)	
	    if self._carnivalModel:isNoticeaAtDay(i,dayNum) then
	    	if i < self._noticeIndex then 
	    		self._noticeIndex = i
	    	end
	    	self:addNoticeDot(button,button:getContentSize().width-15,button:getContentSize().height-15)
	    end
    	self._days[i] = button
    	button:setAnchorPoint(0.5,0.5)
    	button:setPosition(itemW/2+12, scrollHeight - (i-1)*itemH - itemH/2 + 5)
    	self._dayBtnScrollView:addChild(button)
	end
	self:buttonChangeState(self._currBtn) 
end
--更新左边按钮位置
function ActivityCarnival:updateLeftBtn(dayNum)
	if dayNum > 6 then
		dayNum = 1
	end
	local itemH = 75
	if self._noticeIndex == 7 then
		self._noticeIndex = 1
	end
	if self._isFirst then	
		self._currBtn =  dayNum	
		self._isFirst = false		
	else
		self._currBtn = self._noticeIndex
	end
	-- print("========================",dayNum)
	if self._currBtn > 4 and self._isGoButtom then			
		local num = self._dayBtnScrollView:getInnerContainerSize().height - self._dayBtnScrollView:getContentSize().height
		local percent = itemH * (self._currBtn - 4) /num * 100
		percent = percent > 100 and 99 or percent
		self._dayBtnScrollView:scrollToPercentVertical(percent, 0, false)
		self._isGoButtom = false
	end
	-- self:changeScrollViewData(self._currBtn)
	self:buttonChangeState(self._currBtn) 
end
function ActivityCarnival:addNoticeDot(btn,x,y)
    local dot = btn:getChildByName("noticeTip")
    if dot then 
    	dot:removeFromParent()
    end
    -- param = param or {}
    -- local pos = param.pos or cc.p(65,70)
    local dot = ccui.ImageView:create()
    dot:loadTexture("globalImageUI_bag_keyihecheng.png", 1)
    dot:setPosition(x,y)--node:getContentSize().width,node:getContentSize().height))
    dot:setName("noticeTip")
    btn:addChild(dot)
    return dot
end

function ActivityCarnival:buttonChangeState(buttonNum)

	if not buttonNum then 
		buttonNum = 1
	end

	for k,v in pairs(self._days) do
		-- local selectedImg = v:getChildByName("selectedImg")
		local btnTxt = v:getChildByFullName("btnTxt")
		if k == buttonNum then
			v:setTouchEnabled(false)
			v:loadTextures("activity_carnival_dayBtn_s.png", "activity_carnival_dayBtn_s.png", "", 1)
			if btnTxt then
				btnTxt:setColor(cc.c4b(242,224,200,255))
			end
			-- selectedImg:setVisible(true)
		else
			v:loadTextures("activity_carnival_dayBtn_n.png", "activity_carnival_dayBtn_n.png", "", 1)			
			v:setTouchEnabled(true)
			if btnTxt then
				btnTxt:setColor(cc.c4b(130,86,40,255))
			end
			-- selectedImg:setVisible(false)
		end
	end
end

function ActivityCarnival:LabelChangeState(buttonNum)	
	if self._itemScrollView then
		self._itemScrollView:stopScroll()
	end
    self._levelBtn:setVisible(false)
    self._kingBtn:setVisible(false)
    self._eliteBtn:setVisible(false)
	for i = 1,#self._typeTable do
		-- print("--------------=================",i)
		local btn = self:getUI("bg.right_bg.btn" .. i)
		local nameStr = self._nameTable[self._typeTable[i]][2]
		btn:setTitleText(lang(nameStr))
		btn:setVisible(true)
		local noticeDot = btn:getChildByFullName("noticeTip")
		if noticeDot ~= nil then
			noticeDot:removeFromParent()
		end
	end
	self._currLabel = buttonNum
	self._levelBtn:getTitleRenderer():disableEffect()	
    self._eliteBtn:getTitleRenderer():disableEffect()
    self._kingBtn:getTitleRenderer():disableEffect()

    self._levelBtn:loadTextures("activity_carnival_btn_n.png","activity_carnival_btn_n.png","activity_carnival_btn_n.png",1)
	self._kingBtn:loadTextures("activity_carnival_btn_n.png","activity_carnival_btn_n.png","activity_carnival_btn_n.png",1)
	self._eliteBtn:loadTextures("activity_carnival_btn_n.png","activity_carnival_btn_n.png","activity_carnival_btn_n.png",1)
	self._levelBtn:setTouchEnabled(true)
	self._kingBtn:setTouchEnabled(true)
	self._eliteBtn:setTouchEnabled(true)
    self._levelBtn:setTitleColor(normalColor)
    -- self._levelBtn:getTitleRenderer():enableOutline(selectOutColor, 2)
	self._kingBtn:setTitleColor(normalColor)
    -- self._kingBtn:getTitleRenderer():enableOutline(normalOutColor, 2) 
    self._eliteBtn:setTitleColor(normalColor)
    -- self._eliteBtn:getTitleRenderer():enableOutline(normalOutColor, 2)
    self._levelBtn:setTitleFontSize(24)
	self._kingBtn:setTitleFontSize(24)
	self._eliteBtn:setTitleFontSize(24)

	if buttonNum == labelTag.levelBtn then
		self._levelBtn:loadTextures("activity_carnival_btn_s.png","activity_carnival_btn_s.png","activity_carnival_btn_s.png",1)
		self._levelBtn:setTouchEnabled(false)
		self._levelBtn:setTitleColor(selectColor)
	    -- self._levelBtn:getTitleRenderer():enableOutline(selectOutColor, 2)		
	elseif buttonNum == labelTag.kingBtn then
		self._kingBtn:loadTextures("activity_carnival_btn_s.png","activity_carnival_btn_s.png","activity_carnival_btn_s.png",1)
		self._kingBtn:setTouchEnabled(false)
		self._kingBtn:setTitleColor(selectColor)
	    -- self._kingBtn:getTitleRenderer():enableOutline(selectOutColor, 2)
	else
		self._eliteBtn:loadTextures("activity_carnival_btn_s.png","activity_carnival_btn_s.png","activity_carnival_btn_s.png",1)
		self._eliteBtn:setTouchEnabled(false)
		self._eliteBtn:setTitleColor(selectColor)
	    -- self._eliteBtn:getTitleRenderer():enableOutline(selectOutColor, 2)
	end	
	if self._day >= 8 then
		return
	end
	-- 如果没开启，只是查看 不加红点
	if self._day < self._currBtn then
		return
	end
    if self._haveGetNum1 > 0 then
    	self:addNoticeDot(self._levelBtn,self._levelBtn:getContentSize().width-10,self._levelBtn:getContentSize().height-5)
    end	    
    if self._haveGetNum2 > 0 then
    	self:addNoticeDot(self._kingBtn,self._kingBtn:getContentSize().width-10,self._kingBtn:getContentSize().height-5)
    end
    if self._haveGetNum3 > 0 then
    	self:addNoticeDot(self._eliteBtn,self._eliteBtn:getContentSize().width-10,self._eliteBtn:getContentSize().height-5)
    end
end
--初始化数据
function ActivityCarnival:changeScrollViewData(btnNum,labelNum)
	-- 筛选出某一天的数据，分别放在三个数组中
	self._typeTable = {}
	self._nameTable = {}
	-- dump(tableData)
	self._currData1 = {}
	self._currData2 = {}
	self._currData3 = {}

	self._haveGetNum1 = 0
	self._haveGetNum2 = 0
	self._haveGetNum3 = 0

	local dayTable = {} 
	local titleTable = {}
	local canGetNum = 0
	for k,v in pairs(self._tableData) do
		if type(v) == "table" and tonumber(v.day) == tonumber(btnNum) then
			table.insert(dayTable, v)

			table.insert(self._typeTable, v.type)
			table.insert(titleTable, {v.type,v.title})
		end
	end

	self._typeTable = table.unique(self._typeTable,true)
	table.sort(self._typeTable)
	self._nameTable = {}
	for k,v in pairs(titleTable) do
		for i,value in pairs(self._typeTable) do
			if tonumber(v[1]) == tonumber(value) then 
				self._nameTable[self._typeTable[i]] = v
			end
		end		
	end
	for k,v in pairs(dayTable) do
		if self._typeTable[1] then
			if v.type == self._typeTable[1] then 
				if v.status == 2 then
					self._haveGetNum1 = self._haveGetNum1 + 1
				end
				table.insert(self._currData1, v)
			end
		end

		if self._typeTable[2] then
			if v.type == self._typeTable[2] then 
				if v.status == 2 then
					self._haveGetNum2 = self._haveGetNum2 + 1
				end
				table.insert(self._currData2, v)
			end
		end

		if self._typeTable[3] then
			if v.type == self._typeTable[3] then 
				if v.status == 2 then
					self._haveGetNum3 = self._haveGetNum3 + 1
				end
				table.insert(self._currData3, v)
			end
		end
	end
	if not labelNum then
		if self._haveGetNum1 > 0 then
			self._currLabel = 1
		elseif self._haveGetNum2 > 0 then
			self._currLabel = 2
		elseif self._haveGetNum3 > 0 then
			self._currLabel = 3
		else
			self._currLabel = 1
		end
	end
	if self._day < btnNum then 
		self._currLabel = 1
	end
	labelNum = self._currLabel
	self:LabelChangeState(labelNum)
	-- print("==============================",labelNum)
	self._currData1 = self:sortCurrData(self._currData1)
	self._currData2 = self:sortCurrData(self._currData2)
	self._currData3 = self:sortCurrData(self._currData3)
	if labelNum == 1 then
		self._currData = self._currData1
	elseif labelNum == 2 then
		self._currData = self._currData2
	elseif labelNum == 3 then
		self._currData = self._currData3
	end
	-- dump(self._currData,"self._currData")
	-- self._currData = self:sortCurrData(self._currData)
	-- self:updateItemScrollView(creatItemcreatItem,labelNum)
	-- if self._itemScrollView then
	-- 	self._itemScrollView:reloadData()
	-- end
end

function ActivityCarnival:sortCurrData(data)
	local targetData = {}
	local canGetData = {}
	local allGetData = {}
	local otherData = {}

	for k,v in pairs(data) do
		if type(v) == "table" then
			if 2 == v.status then
				table.insert(canGetData,v)
				-- canGetData[k] = v
			elseif 1 == v.status then
				table.insert(allGetData, v)
				-- allGetData[k] = v
			else
				table.insert(otherData, v)
				-- otherData[k] = v
			end
		end
	end

	if table.getn(canGetData) >= 2 then
		table.sort(canGetData,function ( a,b )
	            return a.id < b.id
	        end)
	end

	if table.getn(allGetData) >= 2 then
		table.sort(allGetData,function ( a,b )
	            return a.id < b.id
	        end)
	end

	if table.getn(otherData) >= 2 then
		table.sort(otherData,function ( a,b )
	            return a.id < b.id
	        end)
	end	

	for k,v in ipairs(canGetData) do
		table.insert(targetData, v)
	end

	for k,v in ipairs(otherData) do
		table.insert(targetData, v)
	end

	for k,v in ipairs(allGetData) do
		table.insert(targetData, v)
	end

	return targetData
end

function ActivityCarnival:creatItem(data,idx)
	local item = ccui.Layout:create()
	item:setAnchorPoint(0,0)
	item:setContentSize(556, 130)
    item:setTouchEnabled(true)
    item:setSwallowTouches(false)
	if not data then return  item end

 	-- 背景
    local bgImg = ccui.ImageView:create()
    bgImg:loadTexture("globalPanelUI_activity_cellBg.png",1)
    bgImg:setPosition(285, 65)
    bgImg:setName("bg_img1")
    bgImg:setContentSize(566,130)
    bgImg:setScale9Enabled(true)
    bgImg:setCapInsets(cc.rect(40,40,1,1))
    item:addChild(bgImg)

    -- 标题背景
    local titleBg = ccui.ImageView:create()
    titleBg:loadTexture("activity_carnival_itemTitleBG.png",1)
    titleBg:setName("titleBg")
    titleBg:setPosition(0, 97)
    titleBg:setAnchorPoint(0,0.5)
    titleBg:setScale9Enabled(true)
    titleBg:setCapInsets(cc.rect(34,19,1,1))
    item:addChild(titleBg)

    -- 标题
	local title_txt = ccui.Text:create()
    title_txt:setFontSize(20)
    title_txt:setName("title_txt")
    title_txt:setFontName(UIUtils.ttfName)
    title_txt:setString(lang(data.description))
    title_txt:enableOutline(cc.c4b(14,56,94),1)
    title_txt:setAnchorPoint(0,0.5)
    title_txt:setPosition(15, 97)
    item:addChild(title_txt,1)
    -- titleBg
    local w = title_txt:getContentSize().width + 50
    w = w > 210 and w or 210
    titleBg:setContentSize(w,38)

    --条件
    local conditionTxt = ccui.Text:create()
    conditionTxt:setFontSize(24)
    conditionTxt:setName("conditionTxt")
    conditionTxt:setFontName(UIUtils.ttfName)
    conditionTxt:setColor(cc.c4b(130,80,40,255))
    conditionTxt:setAnchorPoint(0.5,0.5)
    conditionTxt:setPosition(479, 90)
    item:addChild(conditionTxt,10)

    -- 奖励面板
    local iconPanel = ccui.Layout:create()
	iconPanel:setAnchorPoint(0,0)
	iconPanel:setName("iconPanel")
	iconPanel:setContentSize(556, 106)
	iconPanel:setPosition(15,8)
    iconPanel:setTouchEnabled(true)
    iconPanel:setSwallowTouches(false)
    item:addChild(iconPanel,2)

    --领取按钮
    local getBtn = ccui.Button:create()
    getBtn:loadTextures("globalButtonUI13_1_2.png","globalButtonUI13_1_2.png","",1)
    getBtn:setTitleText("领取")
    getBtn:setPosition(479, 50)  
    getBtn:setTag(data.id)  
    getBtn._data = data
    getBtn:setName("getBtn")
	getBtn:setTitleFontName(UIUtils.ttfName)
    getBtn:setTitleColor(UIUtils.colorTable.ccUICommonBtnColor1)
    getBtn:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine5, 2) --(cc.c4b(101, 33, 0, 255), 2)
    getBtn:setTitleFontSize(22) 
    item:addChild(getBtn,2)	
	-- 领取按钮事件
	registerClickEvent(getBtn,function(sender) 
		self:getCarnivalAward(data)
   	end)

	-- 前往按钮
    local goBtn = ccui.Button:create()
    goBtn:loadTextures("globalButtonUI13_2_2.png","globalButtonUI13_2_2.png","",1)
	goBtn:setTag(data.id)
	goBtn:setName("goBtn")
	goBtn:setTitleFontName(UIUtils.ttfName)
    goBtn:setTitleColor(UIUtils.colorTable.ccUICommonBtnColor2)
    goBtn:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine7, 2) --(cc.c4b(101, 33, 0, 255), 2)
    goBtn:setTitleFontSize(22)
    goBtn:setTitleText("前往")
    goBtn:setVisible(false)
    goBtn:setTouchEnabled(false)    
    item:addChild(goBtn,5)
    -- 前往按钮事件
	registerClickEvent(goBtn,function(sender) 
		self:goToTargetById(data)
	end)

    local anniuAnim = getBtn:getChildByFullName("anniuAnim")
    if not anniuAnim then
	    -- 领取按钮特效	
    	anniuAnim = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true,false)
		anniuAnim:setName("anniuAnim")
		anniuAnim:setVisible(false)
		anniuAnim:setPosition(getBtn:getContentSize().width/2-2, getBtn:getContentSize().height/2+2)
		getBtn:addChild(anniuAnim,10)
	end	

	-- 领取图片
	local getSp = cc.Sprite:createWithSpriteFrameName("globalImageUI_activity_getItBlue.png")
	getSp:setName("getSp")
	getSp:setVisible(false)
    getSp:setPosition(getBtn:getPositionX(),item:getContentSize().height/2 - 5)
    item:addChild(getSp)

	local tipSp = ccui.ImageView:create()
    tipSp:loadTexture("activity_carnival_nextOpen.png", 1)
    tipSp:setPosition(conditionTxt:getPositionX(), item:getContentSize().height/2)
    tipSp:setName("tipSp")
    item:addChild(tipSp,5)

	local num = data.currNum or 0
	local targetNum = data.targetNum or 0
	local userInfo = self._modelMgr:getModel("UserModel"):getData()

	local itemW = 72
	if 0 == data.rewardType then
		itemW = 100
	end
	if data.reward then
		local rewardNum = #data.reward
		for i=1,rewardNum do		
			local v = data.reward[i]
			local icon 
			if not v then
				v = data.reward[1]			
			end
			-- 
			local itemId 
			if v[1] == "avatarFrame" then
				itemId = v[2]
				local frameData = tab:AvatarFrame(itemId)
		        param = {itemId = itemId, itemData = frameData}
		        icon = IconUtils:createHeadFrameIconById(param)
		        icon:setName("icon" .. i)
		        icon:setPosition((i-1)*itemW,0)
		        icon:setScale(0.58)
		    elseif v[1] == "siegeProp" then
		    	itemId = v[2]
				local propsTab = tab:SiegeEquip(itemId)
		    	local param = {itemId = itemId, level = 1, itemData = propsTab, quality = propsTab.quality, iconImg = propsTab.art, eventStyle = 1}
				icon = IconUtils:createWeaponsBagItemIcon(param)
				local iconColor = icon:getChildByName("iconColor")
				if iconColor and iconColor.lvlLabel then
					iconColor.lvlLabel:setVisible(false)
				end
		        icon:setName("icon" .. i)
		        icon:setScale(0.66)
		        icon:setPosition((i-1)*itemW,0)
			else
				if v[1] == "tool"then
					itemId = v[2]
				else
					itemId = IconUtils.iconIdMap[v[1]]
				end
				local toolD = tab:Tool(tonumber(itemId))
				icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = v[3]})
				icon:setName("icon" .. i)
				icon:setScale(0.66)
				-- icon:settouch
				icon:setPosition((i-1)*itemW,0)
			end
			icon:setAnchorPoint(0,0)
		    iconPanel:addChild(icon)

			-- N选1
			if 0 == data.rewardType and i < rewardNum then
				local txt = ccui.Text:create()
				txt:setFontSize(24)
				txt:setColor(cc.c4b(122,82,55,255))
				txt:setFontName(UIUtils.ttfName)
				txt:setString("或")
				txt:setName("selectTip" .. i)
				txt:setVisible(true)
				txt:setPosition((i-1)*100 + 80,30)
			    iconPanel:addChild(txt)
			end
		end
	end
    -- 如果是没开启但是可查看的item 则不显示按钮，显示“明天开启” 16.8.30 huang
    if self._day < self._currBtn then
    	getBtn:setVisible(false)
    	getBtn:setEnabled(false)
		conditionTxt:setVisible(false)
    	if tipSp then
    		tipSp:setVisible(true)
    	end

    	return item
    else
    	if tipSp then
    		tipSp:setVisible(false)
    	end
    end
   
	conditionTxt:setVisible(true)
   
	getBtn:setVisible(false)
	getBtn:setEnabled(false)

	-- print("==============item:addChild(goBtn,5)======================")
    if targetNum < 0 then
    	conditionTxt:setVisible(false)
    	getBtn:setPositionY(65)
    else    	
		num = self:formatConditionStr(num)
		targetNum = self:formatConditionStr(targetNum)
		conditionTxt:setString(num.."/"..targetNum)
	end		
    goBtn:setPosition(getBtn:getPosition())
    -- print(data.id,"====================",data.status)
	if 1 == data.status then
		conditionTxt:setVisible(false)
		getSp:setVisible(true)
	elseif 0 == data.status then
		-- print("未达到未领")
		goBtn:setVisible(true)
    	goBtn:setEnabled(true)
    	if self._leftDay < 0 then 
    		goBtn:loadTextures("globalButtonUI13_1_1.png","globalButtonUI13_1_1.png","",1)
			goBtn:setSaturation(-100)
			goBtn:setEnabled(false)
		end
		--按钮是前往
	elseif 2 == data.status then
		-- print("已达到达到未领")
		conditionTxt:setColor(UIUtils.colorTable.ccUIBaseColor9)
		getBtn:setVisible(true)
		getBtn:setEnabled(true)
		if self._leftDay < 0 then 
			getBtn:setSaturation(-100)
			getBtn:setEnabled(false)
		else
			if anniuAnim then
				anniuAnim:setVisible(true)
			end 
		end				
	end

	-- button == 0 无跳转按钮
	if 0 == data.status and 0 == data.button then
		goBtn:setVisible(false)
		conditionTxt:setPositionY(item:getContentSize().height/2)
	end
		
	return item
end

function ActivityCarnival:updateCellItem(item,data,idx)
	if not data then return end
    -- 标题
	local title_txt = item:getChildByFullName("title_txt")
	title_txt:setString(lang(data.description))
    local titleBg = item:getChildByFullName("titleBg")
    local w = title_txt:getContentSize().width + 50
    w = w > 210 and w or 210
    titleBg:setContentSize(w,38)
    --条件
    local conditionTxt = item:getChildByFullName("conditionTxt")
    -- 奖励面板
    local iconPanel = item:getChildByFullName("iconPanel")	
    iconPanel:removeAllChildren()

    --领取按钮
    local getBtn = item:getChildByFullName("getBtn")
    getBtn:setTag(data.id) 
    getBtn:setVisible(false)
	getBtn:setEnabled(false)   
	registerClickEvent(getBtn,function(sender) 
		self:getCarnivalAward(data)
   	end)	

    -- 明日开启
	local tipSp = item:getChildByFullName("tipSp")
	tipSp:setVisible(false)

 --    --领取按钮
    local goBtn = item:getChildByFullName("goBtn")
    goBtn:setTag(data.id) 
    goBtn:setVisible(false)
    goBtn:setEnabled(false)  

    -- 前往按钮事件
	registerClickEvent(goBtn,function(sender) 
		self:goToTargetById(data)
	end)


	--领取按钮特效
	local anniuAnim = getBtn:getChildByFullName("anniuAnim")
	if anniuAnim then
		anniuAnim:setVisible(false)
	end
	-- 已领取图片
	local getSp = item:getChildByFullName("getSp")
	getSp:setVisible(false)

	local num = data.currNum or 0
	local targetNum = data.targetNum or 0
	local userInfo = self._modelMgr:getModel("UserModel"):getData()

	local itemW = 72
	if 0 == data.rewardType then
		itemW = 100
	end
	if data.reward then
		local rewardNum = #data.reward
		for i=1,rewardNum do		
			local v = data.reward[i]
			local icon 
			if not v then
				v = data.reward[1]			
			end
			-- 
			local itemId 
			if v[1] == "avatarFrame" then
				itemId = v[2]
				local frameData = tab:AvatarFrame(itemId)
		        param = {itemId = itemId, itemData = frameData}
		        icon = IconUtils:createHeadFrameIconById(param)
		        icon:setName("icon" .. i)		        
		        icon:setPosition((i-1)*itemW,0)
		        icon:setScale(0.58)
		    elseif v[1] == "siegeProp" then
		    	itemId = v[2]
		    	local propsTab = tab:SiegeEquip(itemId)
		    	local param = {itemId = itemId, level = 1, itemData = propsTab, quality = propsTab.quality, iconImg = propsTab.art, eventStyle = 1}
				icon = IconUtils:createWeaponsBagItemIcon(param)
				local iconColor = icon:getChildByName("iconColor")
				if iconColor and iconColor.lvlLabel then
					iconColor.lvlLabel:setVisible(false)
				end
		        icon:setName("icon" .. i)
		        icon:setScale(0.66)
		        icon:setPosition((i-1)*itemW,0)
			else
				if v[1] == "tool"then
					itemId = v[2]
				else
					itemId = IconUtils.iconIdMap[v[1]]
				end
				local toolD = tab:Tool(tonumber(itemId))
				icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = v[3]})
				icon:setName("icon" .. i)
				icon:setScale(0.66)
				icon:setPosition((i-1)*itemW,0)
				-- icon:settouch
			end
			icon:setAnchorPoint(0,0)
		    iconPanel:addChild(icon)

			-- N选1
			if 0 == data.rewardType and i < rewardNum then
				local txt = ccui.Text:create()
				txt:setFontSize(24)
				txt:setColor(cc.c4b(122,82,55,255))
				txt:setFontName(UIUtils.ttfName)
				txt:setString("或")
				txt:setName("selectTip" .. i)
				txt:setVisible(true)
				txt:setPosition((i-1)*100 + 80,30)
			    iconPanel:addChild(txt)
			end
		end
	end

    -- 如果是没开启但是可查看的item 则不显示按钮，显示“明天开启” 16.8.30 huang
    if self._day < self._currBtn then
		conditionTxt:setVisible(false)    	
    	if tipSp then
    		tipSp:setVisible(true)
    	end

    	if true then return end
    end   
	conditionTxt:setVisible(true)	
	conditionTxt:setColor(cc.c4b(130,80,40,255))   
	
    if targetNum < 0 then
    	conditionTxt:setVisible(false)
    	getBtn:setPositionY(65)
    else    	
    	getBtn:setPositionY(50)
		num = self:formatConditionStr(num)
		targetNum = self:formatConditionStr(targetNum)
		conditionTxt:setString(num.."/"..targetNum)
	end		
    goBtn:setPosition(getBtn:getPosition())
    -- print(data.id,"====================",data.status)
	if 1 == data.status then
		conditionTxt:setVisible(false)
		getSp:setVisible(true)
	elseif 0 == data.status then
		-- print("未达到未领")
		goBtn:setVisible(true)
    	goBtn:setEnabled(true)
    	if self._leftDay < 0 then 
    		goBtn:loadTextures("globalButtonUI13_1_1.png","globalButtonUI13_1_1.png","",1)
			goBtn:setSaturation(-100)
			goBtn:setEnabled(false)
		end
		--按钮是前往
	elseif 2 == data.status then
		-- print("已达到达到未领")
		conditionTxt:setColor(UIUtils.colorTable.ccUIBaseColor9)
		getBtn:setVisible(true)
		getBtn:setEnabled(true)
		if self._leftDay < 0 then 
			getBtn:setSaturation(-100)
			getBtn:setEnabled(false)
		else
			if anniuAnim then
				anniuAnim:setVisible(true)
			end
		end				
	end
	-- button == 0 无跳转按钮
	if 0 == data.status and 0 == data.button then
		goBtn:setVisible(false)
		conditionTxt:setPositionY(item:getContentSize().height/2)
	else
		conditionTxt:setPositionY(90)
	end

end
function ActivityCarnival:getCarnivalAward(data)
	local getAwardFunc = function(taskId,awardIdx)
		-- if true then return end
		self._serverMgr:sendMsg("AwardServer", "getSevenAimReward", {acId = self._acId,taskId = taskId,cId = awardIdx}, true, {}, function(data)
	        -- 监听model 会执行reflashCarnivalUI 更新当前界面
	  		-- ScheduleMgr:nextFrameCall(self, function()
			-- 	self:reflashCarnivalUI()
			-- end) 		 2
			if data["reward"] then 
	        	DialogUtils.showGiftGet({ gifts = data["reward"], hide = self, callback = function()	        		
	        		--播放特效 动画
					local preNum = tonumber(self._getNum1:getString())									
					local progressBg = self:getUI("bg.progressBg")
					
					local mcPro = mcMgr:createViewMC("jingyantiao_carnivaltargetanim", false,true)
					mcPro:setPosition(progressBg:getPositionX(),progressBg:getPositionY()+3)
					self._bg:addChild(mcPro,99)

					local num1 = math.floor(preNum / 10)
					local num2 = preNum % 10
					self._getNum1:setVisible(false)
			    	if num2 < 9 then
			    		self:labelAction1(num1,num2)
			    	else
			    		self:labelAction2(preNum)
			    	end	

					self._getNum1:setString(self._carnivalModel:getTotalStatus())
	        	end,notPop = true})
	        end	       
    	end)
	end

	if self._leftDay < 0 then
		self._viewMgr:showTip("活动已结束")
		return
	end
	if not data then 
		print("==============当前点击的奖励数据不存在=========")
		return
	 end
	local awardIdx = 1
	-- print("==================taskId==",data.id)
	-- dump(data)
	-- N 选一
	if 0 == data.rewardType then
		self._viewMgr:showDialog("global.GlobalSelectAwardDialog", {gift = data.reward or {},callback = function(idx)
			awardIdx = idx
			getAwardFunc(data.id,awardIdx)
		end})
	else
		getAwardFunc(data.id, awardIdx)		
	end
	
end


--格式化条件显示
function ActivityCarnival:formatConditionStr(num)
	local numStr = num
	local conNum1 = num / 100000
	local conNum = num / 10000
	conNum1 = math.floor(conNum1)
	conNum = math.floor(conNum)
	if conNum1 > 0 then
		-- numStr = conNum/10 .. "万"
		numStr = conNum .. "万"
	end
	return numStr
end

function ActivityCarnival:goToTargetById(data)
	if data == nil then return end 
	if self._leftDay < 0 then
		self._viewMgr:showTip("活动已结束")
		return
	end
	-- print("====================data.button===",data.button)
	if self["jumpToView" .. data.button] then
		self["jumpToView" .. data.button](self,data)
	else
		print("==========跳转类型不存在===========")
	end
end
--副本 button == 1
function ActivityCarnival:jumpToView1()
	self._viewMgr:showView("intance.IntanceView")
end
--精英副本 button == 2
function ActivityCarnival:jumpToView2()
	local userInfo = self._userModel:getData()	
	local level = tonumber(tab.systemOpen["Elite"][1])
	if userInfo.lvl < level then
		self._viewMgr:showTip("请先将等级提升到"..level.."级")
	else
		self._viewMgr:showView("intance.IntanceEliteView") 
	end
end
--兵团进阶 button == 3
function ActivityCarnival:jumpToView3()
	ViewManager:getInstance():showView("team.TeamView",{team = ModelManager:getInstance():getModel("TeamModel"):getData()[1],index = 1})
end
--兵团升星 button == 4
function ActivityCarnival:jumpToView4()
	ViewManager:getInstance():showView("team.TeamView",{team = ModelManager:getInstance():getModel("TeamModel"):getData()[1],index = 3})
end
--英雄 button == 5
function ActivityCarnival:jumpToView5()
	local userInfo = self._userModel:getData()	
	local level = tonumber(tab.systemOpen["HeroOpen"][1])
	if userInfo.lvl < level then
		self._viewMgr:showTip("请先将等级提升到"..level.."级")
	else
		self._viewMgr:showView("hero.HeroView")
	end
end
--英雄专精跳到英雄 button == 6
function ActivityCarnival:jumpToView6()
	local userInfo = self._userModel:getData()	
	local level = tonumber(tab.systemOpen["HeroMastery"][1])
	if userInfo.lvl < level then
		self._viewMgr:showTip("请先将等级提升到"..level.."级")
	else
		self._viewMgr:showView("hero.HeroView")
	end
end
--竞技场 button == 7
function ActivityCarnival:jumpToView7()
	local userInfo = self._userModel:getData()	
	local level = tonumber(tab.systemOpen["Arena"][1])
	if userInfo.lvl < level then
		self._viewMgr:showTip("请先将等级提升到"..level.."级")
	else
		self._viewMgr:showView("arena.ArenaView")
	end
end
--远征 button == 8
function ActivityCarnival:jumpToView8()
	local userInfo = self._userModel:getData()	
	local level = tonumber(tab.systemOpen["Crusade"][1])
	if userInfo.lvl < level then
		self._viewMgr:showTip("请先将等级提升到"..level.."级")
	else
		self._viewMgr:showView("crusade.CrusadeView")
	end
end
-- 抢红包界面 button == 9
function ActivityCarnival:jumpToView9(idx) 
	local index = idx
	if not index then
		index = 1
	end
	local userInfo = self._userModel:getData()	
	local level = tonumber(tab.systemOpen["Guild"][1])
	if userInfo.lvl < level then
		self._viewMgr:showTip("请先将等级提升到"..level.."级")
	else
        if not userInfo.guildId or userInfo.guildId == 0 then
            self._viewMgr:showView("guild.join.GuildInView")
        else
            self._viewMgr:showView("guild.GuildView")            
        end
	end	 
end
-- 抢红包界面 button == 10
function ActivityCarnival:jumpToView10() self:jumpToView9() end

-- 捐卡界面 button == 11
function ActivityCarnival:jumpToView11() self:jumpToView9() end

-- 抽卡界面 button == 12
function ActivityCarnival:jumpToView12() self._viewMgr:showView("flashcard.FlashCardView") end

-- 联盟探索地图 button == 13
function ActivityCarnival:jumpToView13()  self:jumpToView9() end

-- 航海 button == 14
function ActivityCarnival:jumpToView14()  
	local userInfo = self._userModel:getData()	
	local level = tonumber(tab.systemOpen["MF"][1])
	if userInfo.lvl < level then
		self._viewMgr:showTip("请先将等级提升到"..level.."级")
	else
        self._viewMgr:showView("MF.MFView")
	end	
end

-- 积分联赛 button == 15
function ActivityCarnival:jumpToView15()  
	-- local userInfo = self._userModel:getData()	
	-- local level = tonumber(tab.systemOpen["League"][1])
	-- if userInfo.lvl < level then
	-- else
	    local isOpen,openDes = LeagueUtils:isLeagueOpen()
	    if isOpen then
	        self._viewMgr:showView("league.LeagueView")
	    else
			self._viewMgr:showTip(openDes)
	    	--todo
	    end
	-- end
end

-- 异界之门 button == 16
function ActivityCarnival:jumpToView16()  
	local userInfo = self._userModel:getData()	
	local level = tonumber(tab.systemOpen["Pve"][1])
	if userInfo.lvl < level then
		self._viewMgr:showTip("请先将等级提升到"..level.."级")
	else
        self._viewMgr:showView("pve.PveView")
	end
end

-- 云中城 button == 17
function ActivityCarnival:jumpToView17()  
	local userInfo = self._userModel:getData()	
	local level = tonumber(tab.systemOpen["CloudCity"][1])
	if userInfo.lvl < level then
		self._viewMgr:showTip("请先将等级提升到"..level.."级")
	else
        self._viewMgr:showView("cloudcity.CloudCityView")
	end
end

-- 兵团培养 button == 18 废弃
function ActivityCarnival:jumpToView18()  
	--[[
	local userInfo = self._userModel:getData()	
	local level = tonumber(tab.systemOpen["TeamBoost"][1])
	if userInfo.lvl < level then
		self._viewMgr:showTip("请先将等级提升到"..level.."级")
	else
        self._viewMgr:showView("teamboost.TeamBoostView")
	end
	]]
end

-- 宝物抽卡 button == 19
function ActivityCarnival:jumpToView19()  
	local userInfo = self._userModel:getData()	
	local level = tonumber(tab.systemOpen["TreasureShop"][1])
	if userInfo.lvl < level then
		self._viewMgr:showTip("请先将等级提升到"..level.."级")
	else
        self._viewMgr:showView("treasure.TreasureShopView")
	end
end

-- 训练场  button == 20
function ActivityCarnival:jumpToView20()  
	local userInfo = self._userModel:getData()	
	local _,_,level = SystemUtils:enableTraining()
	if userInfo.lvl < level then
		self._viewMgr:showTip("请先将等级提升到"..level.."级")
	else
        self._viewMgr:showView("training.TrainingView")
	end
end

-- 元素位面  button == 21
function ActivityCarnival:jumpToView21()  
	local userInfo = self._userModel:getData()	
	local _,_,level = SystemUtils:enableElement()
	if userInfo.lvl < level then
		self._viewMgr:showTip("请先将等级提升到"..level.."级")
	else
        self._viewMgr:showView("elemental.ElementalView")
	end
end

-- 觉醒（跳指定兵团）  button == 22
function ActivityCarnival:jumpToView22(data)  
	-- teamid  condition[1]
	local teamId = (data and data.condition) and data.condition[1] 
	if not teamId then 
		print("=======teamId is nil ======,",data.condition)
		self._viewMgr:showTip(lang("jianianhua_systemtip1_910"))
		return
	end
	local teamModel = ModelManager:getInstance():getModel("TeamModel")
	local teamdata = teamModel:getTeamAndIndexById(teamId)
	if not teamdata then 
		print("=======teamId is ======,",teamId)
		self._viewMgr:showTip(lang("jianianhua_systemtip1_910"))
		return
	end
	ViewManager:getInstance():showView("team.TeamView",{team = teamdata,index = 1})
end

-- 法术书柜  button == 23
function ActivityCarnival:jumpToView23() 
	local userInfo = self._userModel:getData()	
	local _,_,level = SystemUtils:enableSkillBook()
	if userInfo.lvl < level then
		self._viewMgr:showTip("请先将等级提升到"..level.."级")
	else
        self._viewMgr:showView("spellbook.SpellBookCaseView",{},true)
	end	
end

-- 前往攻城器械 button == 24
function ActivityCarnival:jumpToView24() 
	if not self._weaponsModel then 
        self._weaponsModel = self._modelMgr:getModel("WeaponsModel")
    end
    local weaponsModel = self._weaponsModel
    local state = weaponsModel:getWeaponState()
    if state == 1 then
        self._viewMgr:showTip(lang("TIP_Weapon"))
    elseif state == 2 then
        self._viewMgr:showTip(lang("TIP_Weapon2"))
    elseif state == 3 then
        self._viewMgr:showTip(lang("TIP_Weapon3"))
    elseif state == 4 then
        local tdata = weaponsModel:getWeaponsDataByType(1)
        if tdata then
            self._viewMgr:showView("weapons.WeaponsView", {})
        else
            self._serverMgr:sendMsg("WeaponServer", "getWeaponInfo", {}, true, {}, function(result)
                self._viewMgr:showView("weapons.WeaponsView", {})
            end)
        end
    end
end

-- 前往每日任务  button == 25
function ActivityCarnival:jumpToView25() 
	if not SystemUtils:enableDailyTask() then
        self._viewMgr:showTip(lang("TIP_DailyTask"))
        return 
    end
    self._viewMgr:showView("task.TaskView",{viewType = 2})
end

-- 前往宝物界面  button == 26
function ActivityCarnival:jumpToView26() 
	if not SystemUtils:enableTreasure() then
        self._viewMgr:showTip(lang("TIP_TreasureShop"))
        return 
    end
    self._viewMgr:showView("treasure.TreasureView")
end

-- 前往斯坦德威克  button == 27
function ActivityCarnival:jumpToView27() 
	if not self._siegeModel then
		self._siegeModel = self._modelMgr:getModel("SiegeModel")
	end
	if not self._siegeModel:isSiegeDailyOpen() then
		self._viewMgr:showTip(lang("TIPS_SIEGE_LORDBOOK_OPEN_2"))
		return 
	end
	self._viewMgr:showDialog("siegeDaily.SiegeDailySelectView")
end


-- 前往图鉴  button == 28
function ActivityCarnival:jumpToView28() 
	if not SystemUtils:enablePokedex() then
        self._viewMgr:showTip(lang("TIP_Pokedex"))
        return 
    end

    self._viewMgr:showView("pokedex.PokedexView")
end

-- 全目标数字变化动画
function ActivityCarnival:labelAction1(num1,num2)	
	-- self._viewMgr:lock(-1)
	local label1 = ccui.Text:create()
	if num1 == 0 then 
  		label1:setString(" ")
  	else
  		label1:setString(num1)
  	end
  	label1:setAnchorPoint(1,0.5)
  	label1:setColor(cc.c4b(195,220,237,255))
  	-- label1:enableOutline(cc.c4b(14,56,94,255))		  	
	label1:setZOrder(200)  
	label1:setFontSize(22)	
	local posX, posY = self._getNum1:getPosition()
	posX = posX - self._getNum1:getContentSize().width
  	label1:setPosition(posX,posY)
  	self._bg:addChild(label1)

  	local label2 = ccui.Text:create()
  	label2:setAnchorPoint(0,0.5)
  	label2:setString(num2)
  	label2:setColor(cc.c4b(195,220,237,255))
  	-- label2:enableOutline(cc.c4b(14,56,94,255))
  	label2:setPosition(posX,posY)	
  	label2:setZOrder(200)
  	label2:setFontSize(22)	
	self._bg:addChild(label2)

	local label3 = ccui.Text:create()
	label3:setZOrder(201)
	label3:setAnchorPoint(0,0.5)
	label3:setFontSize(22)
  	label3:setString(num2+1)
  	label3:setColor(cc.c4b(195,220,237,255))
  	-- label3:enableOutline(cc.c4b(14,56,94,255))
  	label3:setPosition(posX, posY - 4)	    	
	self._bg:addChild(label3)
	label3:setOpacity(0)
	label3:setScale(1.5)

	local action1 = cc.Sequence:create(cc.ScaleTo:create(0.2, 1.5),cc.DelayTime:create(0.45),cc.ScaleTo:create(0.1, 1),cc.CallFunc:create(function ()
		label1:removeFromParent()
    end))
	label1:runAction(action1)
	local action2 = cc.Sequence:create(cc.ScaleTo:create(0.2, 1.5),cc.DelayTime:create(0.1),cc.Spawn:create(cc.MoveBy:create(0.25, cc.p(0,8)),cc.FadeOut:create(0.15)),cc.CallFunc:create(function ()
		label2:removeFromParent()
    end))
	label2:runAction(action2)
	local action3 = cc.Sequence:create(cc.DelayTime:create(0.2),cc.FadeIn:create(0.1),cc.MoveBy:create(0.25, cc.p(0,4)),cc.DelayTime:create(0.1),cc.ScaleTo:create(0.1, 1),cc.CallFunc:create(function ()
		self._getNum1:setVisible(true)
		label3:removeFromParent()
		-- self._viewMgr:unlock()
    end))
	label3:runAction(action3)
end
function ActivityCarnival:labelAction2(num)	
	-- self._viewMgr:lock(-1)
	local label1 = ccui.Text:create()	
  	label1:setString(num)
  	label1:setAnchorPoint(0.5,0.5)
  	label1:setColor(cc.c4b(195,220,237,255))
  	-- label1:enableOutline(cc.c4b(14,56,94,255))		  	
	label1:setZOrder(200)  
	label1:setFontSize(22)	
	local posX = self._getNum1:getPositionX() - self._getNum1:getContentSize().width
	local posY = self._getNum1:getPositionY()
  	label1:setPosition(posX,posY)
  	self._bg:addChild(label1)

	local label3 = ccui.Text:create()
	label3:setZOrder(201)
	label3:setAnchorPoint(0.5,0.5)
	label3:setFontSize(22)
  	label3:setString(num+1)
  	label3:setColor(cc.c4b(195,220,237,255))
  	-- label3:enableOutline(cc.c4b(14,56,94,255))
  	label3:setPosition(posX, posY - 4)	    	
	self._bg:addChild(label3)
	label3:setOpacity(0)
	label3:setScale(1.5)

	local action2 = cc.Sequence:create(cc.ScaleTo:create(0.2, 1.5),cc.DelayTime:create(0.1),cc.Spawn:create(cc.MoveBy:create(0.25, cc.p(0,8)),cc.FadeOut:create(0.15)),cc.CallFunc:create(function ()
		label1:removeFromParent()
    end))
	label1:runAction(action2)
	local action3 = cc.Sequence:create(cc.DelayTime:create(0.2),cc.FadeIn:create(0.1),cc.MoveBy:create(0.25, cc.p(0,4)),cc.DelayTime:create(0.1),cc.ScaleTo:create(0.1, 1),cc.CallFunc:create(function ()
			self._getNum1:setVisible(true)
			label3:removeFromParent()
			-- self._viewMgr:unlock()
    end))
	label3:runAction(action3)
end

-- 被其他View盖住会调用, 有需要请覆盖
function ActivityCarnival:onHide()
    
end
-- function ActivityCarnival:onTop( )
--    self:reflashCarnivalUI()
-- end
-- 接收自定义消息
function ActivityCarnival:reflashCarnivalUI(data)
	--如果等级变化且返回主界面，当前界面会关掉，监听carnivalModel事件回调时，当前界面的变量会变成nil
	if not self._carnivalModel then
		return
	end

	local acId = self._carnivalModel:getCarnivalId()
	-- 如果结束开启了新的活动，不刷新界面
	if self._acId ~= acId then
		return
	end

	self._tableData = self._carnivalModel:getData()
	-- dump(self._tableData,"self._tableData")
	local btnNum = self._currBtn or 1
	local labelNum = self._currLabel or 1
	self:addLeftBtn(self._day)
	-- self:buttonChangeState(btnNum)	
	self:changeScrollViewData(btnNum,labelNum)

	if self._proTxt then
		self._proTxt:setString("/"..table.getn(self._tableData))	
	end
	if self._progressBar then
		self._progressBar:setPercent(self._carnivalModel:getTotalStatus()/table.getn(self._tableData)*100)

	end

    if self._currData and self._itemScrollView then
    	self._itemScrollView:reloadData()
    end
	
end
function ActivityCarnival:reflashUI(data)
	
end

function ActivityCarnival.dtor()
	labelTag = nil
	normalColor = nil
	normalOutColor = nil
	selectColor = nil
	selectOutColor = nil
	cc = nil
	titlePos = nil
end

return ActivityCarnival