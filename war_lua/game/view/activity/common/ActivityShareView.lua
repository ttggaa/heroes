--
-- Author: huangguofang
-- Date: 2016-06-01 18:40:37
-- Description: 分享有礼活动

local ActivityShareView = class("ActivityShareView", require("game.view.activity.common.ActivityCommonLayer"))

-- function ActivityShareView:getBgName()
-- 	return "ac_bg_share.jpg"
-- end

function ActivityShareView:getAsyncRes()
    return 
    {
	}
end

function ActivityShareView:ctor()
    self.super.ctor(self)

end

-- 初始化UI后会调用, 有需要请覆盖
function ActivityShareView:onInit()
 	self.super.onInit(self)

	self._activityModel = self._modelMgr:getModel("ActivityModel")
	self._userModel = self._modelMgr:getModel("UserModel")
    self._instanceModel = self._modelMgr:getModel("IntanceModel")
    self._privilegeModel = self._modelMgr:getModel("PrivilegesModel")

 	self._taskList = {}
 	self._shareData = clone(tab.activity99)

	local serverData = self._activityModel:getACShareList()
	-- dump(serverData,"serverData-->>")
	 -- 合并数据
	self._shareData = self:FormatShareData(self._shareData,serverData)
	-- self._isCanGet = false

 	self._activityTitle = self:getUI("bg.titleTxt")
 	self._activityTitle:setString(lang("HUODONG1_99"))
 	-- self._activityTitle:setString("竞技挑战")

    self._activityTitle:enable2Color(1, cc.c4b(189, 118, 7, 255))
    self._activityTitle:enableOutline(cc.c4b(27, 4, 2, 255), 3)
    self._activityTitle:setFontName(UIUtils.ttfName)

    local des = self:getUI("bg.description")   --
	des:setString(lang("HUODONG2_99"))
	self:addTableView()
	self._offsetX = 0
	self._offsetY = 0

	--添加倒计时
	local showData = self._activityModel:getACShareShowList()	
	self._time = self:getUI("bg.activity_time")
	local activity_time_des = self:getUI("bg.activity_time_des")
	local tempTime = showData.end_time - self._userModel:getCurServerTime() + 1
    local day, hour, min, sec, tempValue
    self:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.CallFunc:create(function()
            tempTime = tempTime - 1
            tempValue = tempTime
            day = math.floor(tempValue/86400) 
            tempValue = tempValue - day*86400

            hour = math.floor(tempValue/3600)
            tempValue = tempValue - hour*3600

            min = math.floor(tempValue/60)
            tempValue = tempValue - min*60

            sec = math.fmod(tempValue, 60)
            local showTime
            if tempTime <= 0 then
                showTime = "00天00:00:00"
            else
               	showTime = string.format("%.2d天%.2d:%.2d:%.2d", day, hour, min, sec)
            end
            self._time:setString(showTime)
            self._time:setPositionX(activity_time_des:getPositionX() + activity_time_des:getContentSize().width/2 + 5)
        end),cc.DelayTime:create(1))
    ))

	-- self:listenReflash("ActivityModel", self.reflashUI)
	-- self:listenReflash("UserModel", self.reflashUI)
end
function ActivityShareView:addTableView()
	local task_list = self:getUI("bg.task_list")
    local tableView = cc.TableView:create(cc.size(task_list:getContentSize().width, task_list:getContentSize().height))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(task_list:getPosition())
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    -- tableView:setBounceEnabled(true)
    task_list:getParent():addChild(tableView,100)
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
    self._tableView = tableView
    tableView:reloadData()
end
function ActivityShareView:scrollViewDidScroll(view)
	self._inScrolling = view:isDragging()	
	self._offsetX = view:getContentOffset().x
	self._offsetY = view:getContentOffset().y
	-- print("------------",self._tableView:getContentOffset().x,self._tableView:getContentOffset().y)
	
end

function ActivityShareView:scrollViewDidZoom(view)
end
function ActivityShareView:tableCellTouched(table,cell)
	-- body
	-- print("=========" .. cell:getIdx())
end
function ActivityShareView:cellSizeForTable(table,index)
	--  height width
	return 120,677
end
function ActivityShareView:tableCellAtIndex(table,index)
	-- body
	local cell = table:dequeueCell()
	if nil == cell then
        cell = cc.TableViewCell:new()
    else
    	cell:removeAllChildren()
    end
    local cellData = self._shareData[index+1]
    local item = self:creatItem(cellData)
    item:setPosition(cc.p(1,0))
    item:setAnchorPoint(cc.p(0,0))

    cell:addChild(item)

    return cell
end

function ActivityShareView:numberOfCellsInTableView(table)
	-- body
	return 5
end

function ActivityShareView:creatItem(data)
	if not data then return end
	local layer = ccui.Layout:create()
	layer:setAnchorPoint(cc.p(0,0))
	layer:setContentSize(cc.size(667, 119))
	layer:setBackGroundImage("activity_item_bg2.png",1)
	layer:setBackGroundImageScale9Enabled(true)
	layer:setBackGroundImageCapInsets(cc.rect(236,31,1,1))
	--任务名称背景
	local bgImg = ccui.ImageView:create()
	bgImg:loadTexture("globalPanelUI7_subTitleBg1.png",1)
	bgImg:setContentSize(300,32)
	bgImg:setScale9Enabled(true)
	bgImg:setCapInsets(cc.rect(50,16,1,1))
	bgImg:setOpacity(150)
	-- bgImg:setScaleY(0.8)
	bgImg:setPosition(119, 96)	
	layer:addChild(bgImg,1)

	--名称容器
	local nameLayer = ccui.Layout:create()
	nameLayer:setAnchorPoint(cc.p(0,0))
	nameLayer:setPosition(22, 82)
	nameLayer:setContentSize(cc.size(350, 30))
	layer:addChild(nameLayer,2)
	--任务名称
	local desc = lang(data.des)
	local richText = layer:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, 350, 25)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(nameLayer:getContentSize().width / 2, nameLayer:getContentSize().height - richText:getInnerSize().height / 2)
    richText:setName("descRichText")
    nameLayer:addChild(richText)

    --奖励容器
	local rewardLayer = ccui.Layout:create()
	rewardLayer:setAnchorPoint(cc.p(0,0))
	rewardLayer:setPosition(8, 12)
	rewardLayer:setContentSize(cc.size(320, 60))
	layer:addChild(rewardLayer,3)
	for k,v in pairs(data.reward) do
		local itemId 
		if v[1] == "tool" then
			itemId = v[2]
		else
			itemId = IconUtils.iconIdMap[v[1]]
		end
		local toolD = tab:Tool(tonumber(itemId))
		local icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = v[3]})
		icon:setScale(0.65)
		-- icon:settouch
		icon:setAnchorPoint(cc.p(0,0))
		icon:setPosition(cc.p(14+(k-1)*76,-5))
		rewardLayer:addChild(icon)
	end
	-- print("====================",data.status)
	if data.status == -1 then
	 	local goBtn = self:createButton(layer,"前往","globalButtonUI7_blue",cc.c4b(5,92,144,255))
	    layer:addChild(goBtn,5)
	    --前往按钮
		registerClickEvent(goBtn,function(sender) 
			-- print("===goBtn======")
			if self["goView" .. data.button] then
		        self["goView" .. data.button](self)
		    end
		end)
	elseif data.status == 0 then	
	    local shareBtn = self:createButton(layer,"分享","globalButtonUI7_blue",cc.c4b(5,92,144,255))
	    layer:addChild(shareBtn,5)
	    --分享按钮
		registerClickEvent(shareBtn,function(sender) 
			self:shareBtnClicked(data)
		end)
	elseif data.status == 1 then	
	    local getBtn = self:createButton(layer,"领取","globalButtonUI7_yellow",cc.c4b(153,93,0,255))
	    layer:addChild(getBtn,5)

		--领取按钮
		registerClickEvent(getBtn,function(sender) 
			self:getBtnClicked(data)
		end)
	else
		layer:setBackGroundImage("activity_item_bg1.png",1)
		local getImg = ccui.ImageView:create()
		getImg:loadTexture("globalImageUI_activity_getIt.png",1)
		-- getImg:setScaleY(0.8)
		getImg:setPosition(570, layer:getContentSize().height/2)	
		layer:addChild(getImg,10)
	end

	return layer
end

function ActivityShareView:createButton(layer,text,normalImg,enableColor)
	 local button = ccui.Button:create()
    button:loadTextures(normalImg..".png",normalImg..".png","",1)
    button:setPosition(570, layer:getContentSize().height/2)
	button:setTitleFontName(UIUtils.ttfName)
    button:setTitleColor(cc.c4b(255, 255, 255, 255))
    button:getTitleRenderer():enableOutline(enableColor, 2) --(cc.c4b(101, 33, 0, 255), 2)
    button:setTitleFontSize(28)
    button:setTitleText(text)
    return button
end

-- 接收自定义消息
function ActivityShareView:reflashUI(data)
	local serverData = self._activityModel:getACShareList()
	-- dump(serverData,"serverData")
	local offsetX = self._offsetX
	local offsetY = self._offsetY
	 -- 合并数据
	self._shareData = self:FormatShareData(self._shareData,serverData)
	 if self._tableView then
	 	self._tableView:reloadData()
	 	self._tableView:setContentOffset(cc.p(offsetX,offsetY))
	 end
end

function ActivityShareView:goView1()
	self._viewMgr:showView("intance.IntanceView", {superiorType = 1})
end

function ActivityShareView:goView8()
	self._viewMgr:showView("flashcard.FlashCardView")
end

function ActivityShareView:goView9()
	if not SystemUtils:enableArena() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
	self._viewMgr:showView("arena.ArenaView")
end

function ActivityShareView:goView10()
	if not SystemUtils:enableCrusade() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    self._viewMgr:showView("crusade.CrusadeView") 	
end

function ActivityShareView:goView15()
	if not SystemUtils:enablePrivilege() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    self._viewMgr:showView("privileges.PrivilegesView") 
end

function ActivityShareView:shareBtnClicked(data)
	-- share 发送分享协议
	self._serverMgr:sendMsg("ActivityServer", "finishShare",{id = data.id}, true, {} ,function(success)
        if not success then return end
        self._viewMgr:showTip("分享成功")
        self:reflashUI()
    end)
end
--领取奖励
function ActivityShareView:getBtnClicked(data)
	-- share 发送领奖协议
	self._serverMgr:sendMsg("ActivityServer", "getSpecialAcReward",{acId = 99,args = json.encode({id = data.id})}, true, {} ,function(success)
        if not success then return end
        local params = clone(data.reward)
    	DialogUtils.showGiftGet({gifts = params})
    	self:reflashUI()
    end)
end
-- function ActivityShareView:changeTaskState(dataId)	
-- 	-- for k,v in pairs(self._shareData) do
-- 	-- 	if k == dataId then
-- 	-- 		v.status = 1
-- 	-- 	end
-- 	-- end
-- 	-- self._
-- 	-- self._tableView:reloadData()
-- 	self:reflashUI()
-- end
--格式化数据
function ActivityShareView:FormatShareData(staticData,serverData)
	if not staticData or not serverData then return end
	local mergeData = {}
	local finalData = {}
	local comData = {}	
	local flag = false
	-- self._isCanGet = false
	for k,v in pairs(staticData) do	
		for kk,vv in pairs(serverData) do
			flag = false
			if tonumber(v.id) == tonumber(kk) then				
				v.status = tonumber(vv)	
				flag = true
				break
			end
		end
		if not flag then						
			--判断是前往还是分享		
			v.status = -1
			if self:isCanShare(v) then
				v.status = 0
		    end			
		end
		mergeData[k] = v
	end

	-- dump(finalData,"finalData")
	-- dump(comData,"comData")

	for k,v in pairs(mergeData) do
		-- table.insert(canGetData,v)
		if v.status > 1 then
			table.insert(comData,v)
		else
			table.insert(finalData,v)
		end
	end

	for k,v in pairs(comData) do
		table.insert(finalData,v)
		-- finalData[k] = v
	end
	-- dump(canGetData,"canGetData===>>")
	-- dump(finalData,"finalData==>>")
	return finalData
end

-- 是否达到条件
function ActivityShareView:isCanShare(data)
	if not data then return end
	local canGet = false
	if 1 == data.id then
		local stageData = self._instanceModel:getStageInfo(data.task[1])
	    if stageData.star > 0 then 
	        canGet = true
	    end
	elseif 2 == data.id then
		if self._userModel:getData().drawAward then
			local first = self._userModel:getData().drawAward.first or 0
			if 1 == first then
				canGet = true
			end
		else
			canGet = false
		end
	elseif 3 == data.id then
		local rank = self._userModel:getData().statis.snum7 or 0
        targetrank = data.task[1]        
        canGet = (rank > 0 and rank <= targetrank)
	elseif 4 == data.id then
		local num = self._userModel:getData().statis.snum8 or 0
		canGet = tonumber(num) == tonumber(data.task[1]) 
	elseif 5 == data.id then
		local peerage = self._privilegeModel:getPeerage()
		canGet = peerage >= tonumber(data.task[1])
	end

    return canGet
end

function ActivityShareView:isActivityCanGet()
	return self._activityModel:isShareDataTip()
end
-- -- 通关某副本
-- function ActivityShareView:isCanShare1(data)
-- 	local canGet = false
-- 	local stageData = self._instanceModel:getStageInfo(data.task)
--     if stageData.star > 0 then 
--         canGet = true
--     end
--     return canGet
-- end

-- -- 祭坛招募一次
-- function ActivityShareView:isCanShare2(data)
-- 	--flashcard.FlashCardView 
-- 	return false
-- end
-- --首次竞技场排名3000以内
-- function ActivityShareView:isCanShare3(data)	
-- 	-- arena.ArenaView 
-- 	return false
-- end
-- --通关远征
-- function ActivityShareView:isCanShare4(data)	
--    	local num = self._userModel:getData().statis.snum8
--    	-- return tonumber(num) == tonumber(data.task)
--    	return true
-- end
-- --爵位达到勋爵
-- function ActivityShareView:isCanShare5(data)	
--     -- privileges.PrivilegesView
--     return false
-- end

return ActivityShareView