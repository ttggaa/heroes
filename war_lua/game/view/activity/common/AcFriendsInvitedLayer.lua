--
-- Author: huangguofang
-- Date: 2017-11-06 15:44:37
--

local AcFriendsInvitedLayer = class("AcFriendsInvitedLayer", require("game.view.activity.common.ActivityCommonLayer"))

function AcFriendsInvitedLayer:ctor(param)
    self.super.ctor(self)
    
    self._activityId = tonumber(param.activityId) or 98
    self._acModel = self._modelMgr:getModel("ActivityModel")
    self._userModel = self._modelMgr:getModel("UserModel")
end

function AcFriendsInvitedLayer:onInit()
    self.super.onInit(self)
    self._bg = self:getUI("bg")
    self._isWX = sdkMgr:isWX()

    self._reflashNum = tab:Setting("NEWFRIEND_LIST_REFRESH").value
    self._currNum = 0
    -- ruleBtn
    local ruleBtn = self:getUI("bg.ruleBtn")
    self:registerClickEvent(ruleBtn, function(sender)
        local ruleDes = lang("NEW_FRIEND_INVITE_RULES")
        self._viewMgr:showDialog("global.GlobalRuleDescView", {desc = ruleDes},true)
        end)

    local activityD = tab:DailyActivity(self._activityId) or {}   
    local titleBg = self:getUI("bg.titleBg")
    if activityD.titlepic2 then
        titleBg:loadTexture(activityD.titlepic2 .. ".png", 1)
    end
    if activityD.title then 
        titleBg:removeAllChildren()
        local label = UIUtils:getActivityLabel(lang(activityD.title), 70)
        label:setPosition(10, 10)
        titleBg:addChild(label)
        titleBg.title = activityD.title
    end
    local acDes = self:getUI("bg.acDes")
    acDes:setString(lang(activityD.description))

    -- 活动倒计时    
    self._showData = self._acModel:getACCommonShowList(self._activityId)
    local cdDes = self:getUI("bg.cdDes")
    cdDes:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    local currTime = self._userModel:getCurServerTime()
    -- local starTime = self._showData.start_time or currTime
    local endTime = self._showData.end_time or currTime
    local time = tonumber(endTime) - tonumber(currTime)
    local timeStr = TimeUtils.getTimeStringFont1(time)

    local cdTxt = self:getUI("bg.cdTxt")
    cdTxt:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    cdTxt:setString(timeStr)
    if currTime >= endTime then
        cdTxt:setString("0天00:00:00")
    else
        local repeatAction = cc.RepeatForever:create(
            cc.Sequence:create(
            cc.DelayTime:create(1),
            cc.CallFunc:create(function()
                local currTime = self._userModel:getCurServerTime()
                local time = tonumber(endTime) - tonumber(currTime)
                local timeStr = TimeUtils.getTimeStringFont1(time)
                cdTxt:setString(timeStr)
                if currTime >= endTime then
                    cdTxt:setString("0天00:00:00")
                    cdTxt:stopAllActions()
                end
            end)))
        cdTxt:runAction(repeatAction)
    end

    -- 初始化好友任务数据
    self:initFriendsTaskData()
    self._cellTaskW = 400
    self._cellTaskH = 123
    self:addTaskTableView()

    self._friendListH = 290
    self._friendCellH = 86
    -- 获取数据
    self:getPromotionInfo() 

end

-- 任务列表
function AcFriendsInvitedLayer:addTaskTableView()
	if not self._taskData then return end
	local listBg = self:getUI("bg.taskPanel.taskBg")
	if self._taskList ~= nil then 
        self._taskList:removeFromParent()
        self._taskList = nil
    end
    self._taskList = cc.TableView:create(cc.size(listBg:getContentSize().width - 10, listBg:getContentSize().height - 16))
    self._taskList:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._taskList:setPosition(2, 8)
    self._taskList:setDelegate()
    self._taskList:setBounceable(true)
    self._taskList:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._taskList:registerScriptHandler(function( view )
        return self:scrollViewDidScroll(view)
    end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._taskList:registerScriptHandler(function( view )
        return self:scrollViewDidZoom(view)
    end ,cc.SCROLLVIEW_SCRIPT_ZOOM)
    self._taskList:registerScriptHandler(function ( table,cell )
        return self:tableCellTouched(table,cell)
    end,cc.TABLECELL_TOUCHED)
    self._taskList:registerScriptHandler(function( table,index )
        return self:cellSizeForTable(table,index)
    end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._taskList:registerScriptHandler(function ( table,index )
        return self:tableCellAtIndex(table,index)
    end,cc.TABLECELL_SIZE_AT_INDEX)
    self._taskList:registerScriptHandler(function ( table )
        return self:numberOfCellsInTableView(table)
    end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._taskList:reloadData()
    listBg:addChild(self._taskList)
end

function AcFriendsInvitedLayer:scrollViewDidScroll(view)
	self._inScrolling = view:isDragging()	
end

function AcFriendsInvitedLayer:scrollViewDidZoom(view)
    -- print("scrollViewDidZoom")
end

function AcFriendsInvitedLayer:tableCellTouched(table,cell)
    print("cell touched at index: " .. cell:getIdx())
end

function AcFriendsInvitedLayer:cellSizeForTable(table,idx) 
    return self._cellTaskH ,self._cellTaskW
end

function AcFriendsInvitedLayer:tableCellAtIndex(table, idx)
    local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    local label = nil
	local cellData = self._taskData[idx+1]
    if nil == cell then
        cell = cc.TableViewCell:new()
        local item = self:createCellItem()
        item:setPosition(0,0)
        cell._cellItem = item
        item:setAnchorPoint(0,0)
        cell:addChild(item)
    end

	local item = cell._cellItem
    self:updateCellItem(item,cellData,idx+1)
    
    return cell
end
function AcFriendsInvitedLayer:numberOfCellsInTableView(table)
	return self._taskNum or 0
end

function AcFriendsInvitedLayer:createCellItem()
    local item = ccui.Layout:create()
    item:setAnchorPoint(0,0)
    item:setContentSize(self._cellTaskW, self._cellTaskH)
    item:setTouchEnabled(true)
    item:setSwallowTouches(false)
    -- 背景
    local bgImg = ccui.ImageView:create()
    bgImg:loadTexture("globalPanelUI7_cellBg1.png",1)
    bgImg:setPosition(self._cellTaskW*0.5, self._cellTaskH*0.5)
    bgImg:setName("bg_img1")
    bgImg:setContentSize(self._cellTaskW,132)
    bgImg:setScale9Enabled(true)
    bgImg:setCapInsets(cc.rect(40,40,1,1))
    item._bgImg = bgImg
    item:addChild(bgImg)

    -- 奖励面板
    local iconPanel = ccui.Layout:create()
    -- iconPanel:setBackGroundColorOpacity(150)
    -- iconPanel:setBackGroundColorType(1)
    iconPanel:setAnchorPoint(0,0)
    item._iconPanel = iconPanel
    iconPanel:setContentSize(240, 76)
    iconPanel:setPosition(25,8)
    iconPanel:setTouchEnabled(true)
    iconPanel:setSwallowTouches(false)
    item:addChild(iconPanel)

    -- 条件背景
    local condBg = ccui.ImageView:create()
    condBg:loadTexture("globalPanelUI12_btnTitleBg.png",1)
    condBg:setName("titleBg")
    condBg:setPosition(310, 80)
    condBg:setAnchorPoint(0.5,0.5)
    item._condBg = condBg
    item:addChild(condBg)

    local condTxt = ccui.Text:create()
    condTxt:setFontSize(20)
    item._condTxt = condTxt
    condTxt:setFontName(UIUtils.ttfName)
    condTxt:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
    condTxt:setString("/")
    condTxt:setAnchorPoint(0.5,0.5)
    condTxt:setPosition(310, 88)
    item:addChild(condTxt,1)    

    --领取按钮
    local getBtn = ccui.Button:create()
    getBtn:loadTextures("globalButtonUI13_1_2.png","globalButtonUI13_1_2.png","",1)
    getBtn:setTitleText("领取")
    getBtn:setPosition(310, 48)  
    getBtn:setName("getBtn")
    getBtn:setTitleFontName(UIUtils.ttfName)
    getBtn:setTitleColor(UIUtils.colorTable.ccUICommonBtnColor1)
    getBtn:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine5, 2) --(cc.c4b(101, 33, 0, 255), 2)
    getBtn:setTitleFontSize(22) 
    item._getBtn = getBtn
    item:addChild(getBtn,1) 

    -- 领取图片
    local getSp = cc.Sprite:createWithSpriteFrameName("globalImageUI_activity_getIt.png")
    getSp:setPosition(310,60)
    getSp:setVisible(false)
    item._getSp = getSp
    item:addChild(getSp,2)

    return item
end
-- 更新好友任务cell
function AcFriendsInvitedLayer:updateCellItem(item,cellData,idx)
    local titleTxt = item._titleTxt
    local iconPanel = item._iconPanel
    local condBg = item._condBg
    local condTxt = item._condTxt
    local getBtn = item._getBtn
    local getSp = item._getSp

    if titleTxt then 
        titleTxt:removeFromParent()
        titleTxt = nil
    end
    -- title
    titleTxt = RichTextFactory:create(lang(cellData.description), 200, 30)
    titleTxt:formatText()
    titleTxt:setPosition(125,98)
    item:addChild(titleTxt)
    item._titleTxt = titleTxt

    -- 奖励
    iconPanel:removeAllChildren()
    local awardData = cellData.reward 
    if cellData.reward then
        local icon
        for k,v in pairs(awardData) do
            if v[1] == "avatarFrame" then
                itemId = v[2]
                local frameData = tab:AvatarFrame(itemId)
                param = {itemId = itemId, itemData = frameData}
                icon = IconUtils:createHeadFrameIconById(param)
                icon:setPosition((k-1)*76+2,5)
                icon:setScale(0.65)
            else
                if v[1] == "tool"then
                    itemId = v[2]
                else
                    itemId = IconUtils.iconIdMap[v[1]]
                end
                local toolD = tab:Tool(tonumber(itemId))
                icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = v[3]})
                icon:setScale(0.76)
                icon:setPosition((k-1)*76+2,5)
            end
            iconPanel:addChild(icon)
        end
    end

    local status = cellData.status or 2
    condTxt:setString(self._achieveNum .. "/" .. cellData.condition)
    condTxt:setColor(status == 1 and UIUtils.colorTable.ccUIBaseColor9 or UIUtils.colorTable.ccUIBaseDescTextColor1)
    condTxt:setVisible(status ~= 3)
    condBg:setVisible(status ~= 3)
    getBtn:setVisible(status ~= 3)
    getBtn:setSaturation(status == 2 and -100 or 0)
    getSp:setVisible(status == 3)
    if status ~= 3 then
        -- 领取按钮事件
        registerClickEvent(getBtn,function(sender) 
            if status == 1 then
                self:getTaskAward(cellData)
            else
               self._viewMgr:showTip("条件尚未达成") 
            end
        end)
    end

end


-- 可邀请的好友列表
function AcFriendsInvitedLayer:addFriendsTableView()
    if not self._friendData then return end
    self._friendBg = self:getUI("bg.taskPanel.friendBg")
    local friendBg = self._friendBg
    if self._friendList ~= nil then 
        self._friendList:removeFromParent()
        self._friendList = nil
    end
    self._friendList = cc.TableView:create(cc.size(friendBg:getContentSize().width, self._friendListH))
    self._friendList:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._friendList:setPosition(0, 0)
    self._friendList:setDelegate()
    self._friendList:setBounceable(true)
    self._friendList:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._friendList:registerScriptHandler(function( view )
        return self:friendScrollViewDidScroll(view)
    end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._friendList:registerScriptHandler(function( view )
        return self:friendScrollViewDidZoom(view)
    end ,cc.SCROLLVIEW_SCRIPT_ZOOM)
    self._friendList:registerScriptHandler(function ( table,cell )
        return self:friendTableCellTouched(table,cell)
    end,cc.TABLECELL_TOUCHED)
    self._friendList:registerScriptHandler(function( table,index )
        return self:friendCellSizeForTable(table,index)
    end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._friendList:registerScriptHandler(function ( table,index )
        return self:friendTableCellAtIndex(table,index)
    end,cc.TABLECELL_SIZE_AT_INDEX)
    self._friendList:registerScriptHandler(function ( table )
        return self:friendNumberOfCellsInTableView(table)
    end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._friendList:reloadData()
    friendBg:addChild(self._friendList)
end

function AcFriendsInvitedLayer:friendScrollViewDidScroll(view)
    self._inScrolling = view:isDragging()
    self._currOffsetY = view:getContentOffset().y
    -- 所有数据全部加载完毕
    if self._isFinished then return end
    local offsetY = view:getContentOffset().y    
    local condY = 0
    if self._friendData and #self._friendData < 4 then
        -- tableView height 330
        condY = self._friendListH - #self._friendData*self._friendCellH
    end
    if self._inScrolling then
        if offsetY >= condY+60 and not self._canRequest then
            self._canRequest = true
            self:createLoadingMc()
            if not self._loadingMc:isVisible() then
                self._loadingMc:setVisible(true)
            end
        end
        if offsetY < condY+20 and self._canRequest then
            self._canRequest = false
            self:createLoadingMc()
            if self._loadingMc:isVisible() then
                self._loadingMc:setVisible(false)
            end 
        end
    else
        -- 满足请求更多数据条件
        if self._canRequest and offsetY == condY then       
            -- self._viewMgr:lock(1)
            self._canRequest = false
            self:getShowFriendsData()
            self:createLoadingMc()
            if self._loadingMc:isVisible() then
                self._loadingMc:setVisible(false)
            end     
        end
    end     
end

function AcFriendsInvitedLayer:createLoadingMc()
    if self._loadingMc then return end
    -- 添加加载中动画
    self._loadingMc = mcMgr:createViewMC("jiazaizhong_rankjiazaizhong", true, false, function (_, sender)      end)
    self._loadingMc:setName("loadingMc")
    self._loadingMc:setPosition(cc.p(self._friendBg:getContentSize().width*0.5 - 30, self._friendList:getPositionY() + 20))
    self._friendBg:addChild(self._loadingMc, 20)
    self._loadingMc:setVisible(false)
end

function AcFriendsInvitedLayer:friendScrollViewDidZoom(view)
    -- print("scrollViewDidZoom")
end

function AcFriendsInvitedLayer:friendTableCellTouched(table,cell)
    print("cell touched at index: " .. cell:getIdx())
end

function AcFriendsInvitedLayer:friendCellSizeForTable(table,idx) 
    return self._friendCellH ,246
end

function AcFriendsInvitedLayer:friendTableCellAtIndex(table, idx)
    local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    local label = nil
    local cellData = self._friendData[idx+1]
    if nil == cell then
        cell = cc.TableViewCell:new()
        local item = self:createFriendCell()
        item:setPosition(0,0)
        cell._cellItem = item
        item:setAnchorPoint(0,0)
        cell:addChild(item)
    end

    local item = cell._cellItem
    self:updateFriendCell(item,cellData,idx+1)
    
    return cell
end
function AcFriendsInvitedLayer:friendNumberOfCellsInTableView(table)
    return #self._friendData
end

function AcFriendsInvitedLayer:createFriendCell()
    local w = 246
    local h = self._friendCellH
    local item = ccui.Layout:create()
    item:setAnchorPoint(0,0)
    item:setContentSize(w, h)
    item:setTouchEnabled(true)
    item:setSwallowTouches(false)
    -- 背景
    local bgImg = ccui.ImageView:create()
    bgImg:loadTexture("globalImageUI_cellFrame.png",1)
    bgImg:setPosition(w*0.5, h*0.5)
    bgImg:setContentSize(w,h)
    bgImg:setScale9Enabled(true)
    bgImg:setCapInsets(cc.rect(40,40,1,1))
    item._bgImg = bgImg
    item:addChild(bgImg)

    -- 头像
    local avatar = IconUtils:createUrlHeadIconById({})
    avatar:setAnchorPoint(0, 0.5)
    avatar:setPosition(10, h*0.5 + 2)
    avatar:setScale(0.7)
    item._avatar = avatar
    item:addChild(avatar, 2)

    local userName = ccui.Text:create()
    userName:setFontSize(20)
    item._userName = userName
    userName:setFontName(UIUtils.ttfName)
    userName:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    userName:setString("玩家名称")
    userName:setAnchorPoint(0,0.5)
    userName:setPosition(90, 62)
    item:addChild(userName,1)

    local levelTxt = ccui.Text:create()
    levelTxt:setFontSize(20)
    item._levelTxt = levelTxt
    levelTxt:setFontName(UIUtils.ttfName)
    levelTxt:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    levelTxt:setString("Lv.0")
    levelTxt:setAnchorPoint(0,0.5)
    levelTxt:setPosition(90, 20)
    item:addChild(levelTxt,1)

    local invitedTxt = ccui.Text:create()
    invitedTxt:setFontSize(20)
    item._invitedTxt = invitedTxt
    invitedTxt:setFontName(UIUtils.ttfName)
    invitedTxt:setColor(cc.c4b(196,73,4,255))
    invitedTxt:setString("已达成")
    invitedTxt:setAnchorPoint(0,0.5)
    invitedTxt:setPosition(160, 20)
    item:addChild(invitedTxt,1)

    --邀请
    local invitedBtn = ccui.Button:create()
    invitedBtn:loadTextures("globalButtonUI13_1_2.png","globalButtonUI13_1_2.png","",1)
    invitedBtn:setTitleText("邀请TA")
    invitedBtn:setPosition(200, 20)  
    invitedBtn:setScale(0.6)
    invitedBtn:setTitleFontName(UIUtils.ttfName)
    invitedBtn:setTitleColor(UIUtils.colorTable.ccUICommonBtnColor1)
    invitedBtn:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine5, 2) --(cc.c4b(101, 33, 0, 255), 2)
    invitedBtn:setTitleFontSize(22)
    item._invitedBtn = invitedBtn
    item:addChild(invitedBtn,1)

    --再次邀请（QQ显示，微信不显示）
    local invitedAgain = ccui.Button:create()
    invitedAgain:loadTextures("globalButtonUI13_3_2.png","globalButtonUI13_3_2.png","",1)
    invitedAgain:setTitleText("再次邀请")
    invitedAgain:setPosition(200, 20)
    invitedAgain:setScale(0.6)
    invitedAgain:setName("invitedAgain")
    invitedAgain:setTitleFontName(UIUtils.ttfName)
    invitedAgain:setTitleColor(UIUtils.colorTable.ccUICommonBtnColor2)
    invitedAgain:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine2, 2) --(cc.c4b(101, 33, 0, 255), 2)
    invitedAgain:setTitleFontSize(22)
    item._invitedAgain = invitedAgain
    item:addChild(invitedAgain,1) 

    -- 邀请文字（wx显示，qq不显示）
    local invitedIng = ccui.Text:create()
    invitedIng:setFontSize(20)
    item._invitedIng = invitedIng
    invitedIng:setFontName(UIUtils.ttfName)
    invitedIng:setColor(cc.c4b(196,73,4,255))
    invitedIng:setString("邀请中...")
    invitedIng:setAnchorPoint(0,0.5)
    invitedIng:setPosition(160, 20)
    item:addChild(invitedIng,1)

    return item
end
-- 更新好友任务cell
function AcFriendsInvitedLayer:updateFriendCell(item,cellData,idx)
    local avatar = item._avatar
    local userName = item._userName
    local levelTxt  = item._levelTxt 

    local invitedTxt = item._invitedTxt
    local invitedBtn = item._invitedBtn
    local invitedAgain = item._invitedAgain
    local invitedIng = item._invitedIng

    userName:setString(cellData["nick_name"])
    local lv = cellData.lv or 0
    levelTxt:setString("Lv." .. lv)
    if avatar then 
        IconUtils:updateUrlHeadIconByView(avatar,{
                                    name = cellData["nick_name"], 
                                    url = cellData["head_img_url"], 
                                    openid = cellData["sopenid"], 
                                    tencetTp = cellData["qqVip"], 
                                    tp = 4})
    else
        local avatar = IconUtils:createUrlHeadIconById({
                                    name = cellData["nick_name"], 
                                    url = cellData["head_img_url"], 
                                    openid = cellData["sopenid"], 
                                    tencetTp = cellData["qqVip"], 
                                    tp = 4})
        avatar:setAnchorPoint(0, 0.5)
        avatar:setPosition(25, item:getContentSize().height*0.5)
        item._avatar = avatar
        item:addChild(avatar, 2)
    end
   
    -- 1 未邀请  2 已邀请  3 已达成
    local status = cellData.status or 1
    invitedTxt:setVisible(status == 3)
    invitedBtn:setVisible(status == 1)
    invitedAgain:setVisible(status == 2 and not self._isWX)
    invitedIng:setVisible(status == 2 and self._isWX)
    
    if 1 == status then
        registerClickEvent(invitedBtn, function()
            self:invitedFriend(cellData,true)
        end)
    elseif 2 == status then
        registerClickEvent(invitedAgain, function()
            self:invitedFriend(cellData)
        end)
    end

end
-- 获取数据
function AcFriendsInvitedLayer:getPromotionInfo()
    self._serverMgr:sendMsg("ActivityServer", "getPromotionInfo", {}, true, {}, function(result,succ)
        self:initFriendsTaskData()
        -- dump(result,"friendList==>",5)
        self:initFriendListData(result.friendList)
        self:addFriendsTableView()
    end)
end

-- 领取任务奖励
function AcFriendsInvitedLayer:getTaskAward(data)
    self._serverMgr:sendMsg("ActivityServer", "getPromotionReward", {rewardId = data.id}, true, {}, function(result,succ)
        self:initFriendsTaskData()
        -- dump(result,"result==>",5)
        -- 恭喜获得
        DialogUtils.showGiftGet( {
                    gifts = result["reward"], 
                    callback = function() end
                ,notPop = true})
    end)
end

-- 邀请好友
function AcFriendsInvitedLayer:invitedFriend(fData,isFirst)
    -- print("============邀请好友======")
    local tipsDes = string.gsub(lang("NEW_FRIEND_INVITE_TIPS"),"{$name}",(fData.nick_name or ""))
    self._viewMgr:showDialog("global.GlobalSelectDialog",
            {desc = tipsDes,
            button1 = "确定",
            button2 = "取消", 
            callback1 = function ()
                self._serverMgr:sendMsg("ActivityServer", "inviteFriend", {friendSOpenId = fData.sopenid}, true, {}, function(result)
                    -- dump(result,"result==>",5)
                    if not self._isWX then
                        local param = {}
                        param.fopenid = fData["sopenid"]
                        param.title = lang("NEW_FRIEND_INVITE_MSGTITLE")
                        param.desc = lang("NEW_FRIEND_INVITE_MSGDES")
                        param.media_tag = sdkMgr.SHARE_TAG.MSG_INVITE_NEW
                        -- param.path = "/storage/emulated/0/Android/data/com.tencent.tmgp.yxwdzzjy/share.png"
                        sdkMgr:sendToPlatformFriend(param, function(code, data) end)
                        -- self._viewMgr:showTip(lang("SUC_FRIENDTIPS"))
                    end
                    print("===========邀请成功========")
                    if isFirst then 
                        self:initFriendListData(nil,true)
                    end
                end)
            end,
            callback2 = function()
                
            end})
    
end

-- 好友任务数据
function AcFriendsInvitedLayer:initFriendsTaskData()
    -- 好友邀请数据
    self._promotionData = self._acModel:getInvitedData()
    -- 任务列表
    self._taskData = {}
    local taskData = clone(tab.activityInviteNew)
    self._taskNum = table.nums(taskData)
    local sSOpenIds = self._promotionData.sSOpenIds or {}        -- 已达成的sOpenId 列表
    local rewardList = self._promotionData.rewardList or {}      -- 已领取的奖励 列表

    self._achieveNum = table.nums(sSOpenIds) or 0   
    -- status    1已完成  2未完成  3已领取
    for k,v in pairs(taskData) do
        if v.condition and v.condition <= self._achieveNum then
            v.status = 1
        else
            v.status = 2
        end
        if v.id and rewardList[tostring(v.id)] then 
            v.status = 3
        end
        table.insert(self._taskData,v)
    end

    table.sort(self._taskData,function(a,b)
        if a.status == b.status then
            return a.condition < b.condition
        else
            return a.status < b.status
        end
    end)
    -- dump(self._taskData,"self._taskData==",6)
    if self._taskList then
        self._taskList:reloadData()
    end
end

-- 可邀请的好友列表
function AcFriendsInvitedLayer:initFriendListData(friendList,isInvited)
    -- 好友列表
    if friendList then 
        self.friendAllData = friendList
    end
    if not self.friendAllData then 
        self.friendAllData = {}
    end

    self._promotionData = self._acModel:getInvitedData()
    -- dump(self._promotionData,"self._promotionData==》",5)
    local friendNum = #self.friendAllData
    local sOpenIds = self._promotionData.sOpenIds or {}          -- 已发送的玩家sOpenId列表
    -- self._bSOpenIds = self._promotionData.bSOpenIds or {}        -- 已绑定的玩家sOpenId 列表
    local sSOpenIds = self._promotionData.sSOpenIds or {}        -- 已达成的sOpenId 列表
    -- status  1 未邀请  2 已邀请  3 已达成
    for i=1,friendNum do
        local friendData = self.friendAllData[i]
        friendData.status = 1
        if sOpenIds[tostring(friendData.sopenid)] then
            friendData.status = 2
        end

        if sSOpenIds[tostring(friendData.sopenid)] then
            friendData.status = 3
        end
        
    end
    -- dump(friendList,"friendList==>",5)
    -- dump(self.friendAllData,"self.friendAllData==>",5)
    -- print("=========self.friendAllData===",#self.friendAllData)
    self:getShowFriendsData(isInvited)

    if self._friendList then
        local offsetY = self._currOffsetY
        self._friendList:reloadData()
        if offsetY and isInvited then
            self._friendList:setContentOffset(cc.p(0,offsetY))
        end
    end
end

-- 获取可展示的好友数据
function AcFriendsInvitedLayer:getShowFriendsData(isInvited)
    if isInvited then
        return
    end
    if not self._friendData then
        self._friendData = {}
    end
    local allNum = #self.friendAllData
    local showNum = #self._friendData
    if allNum <= showNum then
        self._friendData = self.friendAllData
        self._offsetY = 0
        self._isFinished = true
    else

        local num = self._currNum + self._reflashNum
        for i=self._currNum + 1,num do
            local data = self.friendAllData[i]
            if data then
                table.insert(self._friendData, data)
            end
        end
        if num < allNum then
            self._offsetY = -1 * self._reflashNum * self._friendCellH
        else
            self._offsetY = -1 * (allNum - self._currNum) * self._friendCellH
        end
        -- 一屏内
        -- friendList 高度
        local tempH = #self._friendData * self._friendCellH - self._friendListH
        local subH = self._friendListH - #self._friendData * self._friendCellH
        if tempH <= 0 or tempH < self._friendCellH or self._offsetY < subH then --差值小于1个cell高度 或者计算的差绝对值大于最大值
            self._offsetY = self._friendListH - #self._friendData * self._friendCellH
        end

        self._currNum = num
        if self._currNum >= allNum then
            self._isFinished = true
        end
    end

    if self._friendList then
        self._friendList:reloadData()
        -- 计算当前offsetY
        if self._offsetY then 
            self._friendList:setContentOffset(cc.p(0,self._offsetY))
        end
    end

end

function AcFriendsInvitedLayer:reflashUI()

end
return AcFriendsInvitedLayer