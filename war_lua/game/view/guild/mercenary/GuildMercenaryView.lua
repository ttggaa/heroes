--[[
    @FileName   GuildMercenaryView.lua
    @Authors    zhangtao
    @Date       2017-08-07 16:29:39
    @Email      <zhangtao@playcrad.com>
    @Description   佣兵
--]]

local GuildMercenaryView = class("GuildMercenaryView",BaseView)

GuildMercenaryView.kTypePlace = 1
GuildMercenaryView.kTypeLook = 2


function GuildMercenaryView:ctor()
    self.super.ctor(self)
    self._guildModel = self._modelMgr:getModel("GuildModel")
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._totalPostion = 3  --佣兵坑的个数
    self._itemPos = {}      --列表位置表
    self._btnTable = {} 
    self._curDispatchCount = 0  --当前雇佣个数
end

-- 初始化UI后会调用, 有需要请覆盖
function GuildMercenaryView:onInit()
    local closeBtn = self:getUI("bg.mainBg.closeBtn")
    self:registerClickEvent(closeBtn, function()
        self:close()
        UIUtils:reloadLuaFile("guild.mercenary.GuildMercenaryView")
    end)

    local ruleBtn = self:getUI("bg.mainBg.rewardPanel.placePanel.ruleBtn")
    ruleBtn:setScaleAnim(true)
    self:registerClickEvent(ruleBtn, function()
        -- print("======lansquenet_Rule========="..lang("lansquenet_Rule"))
        self._viewMgr:showDialog("global.GlobalRuleDescView",{desc = lang("lansquenet_Rule")},true)
    end)

    self._listItem1 = self:getUI("item1")
    self._listItem1:setVisible(false)

    self._listItem2 = self:getUI("item2")
    self._listItem2:setVisible(false)

    --面板
    self._placePanel = self:getUI("bg.mainBg.rewardPanel.placePanel")  --放置列表面板
    self._lookPanel = self:getUI("bg.mainBg.rewardPanel.lookPanel")    --查看列表面板
    self._lookItem = self:getUI("lookItem")
    self._placePanel:setVisible(true)
    self._lookPanel:setVisible(false)
    self._lookItem:setVisible(false)
    --lookItem 大小
    self._cellContentSize = self._lookItem:getContentSize()

    local title = self:getUI("bg.mainBg.title.titleName")
    UIUtils:setTitleFormat(title, 1)
    --雇佣次数
    self._dispatchNum = self:getUI("bg.mainBg.rewardPanel.placePanel.dispatchNum")
    self._dispatchNum:setString("0".."/"..self._totalPostion)
    --放置按钮
    local btn_place = self:getUI("bg.mainBg.btn_place") 
    btn_place:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine1, 2)
    btn_place:setTitleFontName(UIUtils.ttfName)
    btn_place:setTitleFontSize(26)
    local btn_place_text = btn_place:getTitleRenderer()
    btn_place:setTitleColor(UIUtils.colorTable.ccUITabColor1)
    btn_place_text:disableEffect()  


    --查看按钮
    local btn_look = self:getUI("bg.mainBg.btn_look")
    btn_look:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine1, 2)
    btn_look:setTitleFontName(UIUtils.ttfName)
    btn_look:setTitleFontSize(26)
    local btn_look_text = btn_look:getTitleRenderer()
    btn_look:setTitleColor(UIUtils.colorTable.ccUITabColor1)
    btn_look_text:disableEffect()  

    local rtxStr = lang("SHOW_LANSQUENET_TIP1")
    local sendDes = RichTextFactory:create(rtxStr,500,30)
    sendDes:formatText()
    sendDes:setVerticalSpace(0)
    sendDes:setAnchorPoint(cc.p(0,0.5))
    sendDes:setPosition(-240,440)
    sendDes:setName("sendDes")
    self._lookPanel:addChild(sendDes)

    self._btnTable[GuildMercenaryView.kTypePlace] = btn_place
    self._btnTable[GuildMercenaryView.kTypeLook] = btn_look
    self._btnType = GuildMercenaryView.kTypePlace

    self._listBg = self:getUI("bg.mainBg.rewardPanel.placePanel.listBg")
    local listContentSize = self._listBg:getContentSize()
    for i = 1, self._totalPostion do
        self._itemPos[i] = {}
        self._itemPos[i].x = listContentSize.width/2
        self._itemPos[i].y = listContentSize.height - 130*i + 60
        self._listBg[i] = {}
        self._listBg[i].item = self:createDispatchCell(i)
        self._listBg[i].item:setPosition(self._itemPos[i].x,self._itemPos[i].y)
        self._listBg:addChild(self._listBg[i].item)
    end
    
    UIUtils:setTabChangeAnimEnable(btn_place,-30,
        function ()
            self:switchTag(GuildMercenaryView.kTypePlace)
        end
    )
    UIUtils:setTabChangeAnimEnable(btn_look,-30,
        function ()
            self:switchTag(GuildMercenaryView.kTypeLook)
        end
    )

    self:setListenReflashWithParam(true)
    self:listenReflash("MercenaryModel", self.updatMercenaryTimes)
    self:firstEnterState()
end
--派遣列表
function GuildMercenaryView:createDispatchCell(pos)
    local dispatchCell = self:getUI("item1"):clone()
    dispatchCell:setVisible(true)
    dispatchCell:setAnchorPoint(0.5,0.5)
    local desNode = dispatchCell:getChildByFullName("desBg")
    local rtxStr = lang("SHOW_LANSQUENET_TIP2")
    local sendDes = RichTextFactory:create(rtxStr,450,60)
    sendDes:formatText()
    sendDes:setVerticalSpace(0)
    sendDes:setAnchorPoint(cc.p(0,0.5))
    sendDes:setPosition(-225,0)
    sendDes:setName("sendDes")
    desNode:addChild(sendDes)

    dispatchCell.dispatchBtn = dispatchCell:getChildByFullName("sendBtn")
    dispatchCell.dispatchBtn:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine7, 2)


    self:registerClickEvent(dispatchCell.dispatchBtn, function()
        self._viewMgr:showDialog("guild.mercenary.GuildMercenaryListView", {pos = pos})
    end)
    self:registerClickEvent(dispatchCell:getChildByFullName("cell.image"),function()
        self._viewMgr:showDialog("guild.mercenary.GuildMercenaryListView", {pos = pos})
    end)
    return dispatchCell
end


-- function GuildMercenaryView:getRealData(teamId)
--     local userId = self._modelMgr:getModel("UserModel"):getData()._id
--     return self._guildModel:getEnemyDataById(teamId,userId)
-- end

--领奖和召回列表
--pos 坑位
--detailData 佣兵数据
function GuildMercenaryView:createAwardCell(pos,detailData)
    dump(detailData,"======detailData========")
    local teamId = detailData["teamId"]
    local awardCell = self:getUI("item2"):clone()
    awardCell:setVisible(true)
    awardCell:setAnchorPoint(0.5,0.5)
    awardCell.cell = awardCell:getChildByFullName("cell")
    -- dump(self._teamModel:getData())
    local realTeamData = clone(detailData["team"])
    realTeamData["teamId"] = teamId
    local teamData = realTeamData or self._teamModel:getTeamAndIndexById(teamId)
    local teamTableData = tab:Team(teamData.teamId)
    local quality = self._teamModel:getTeamQualityByStage(teamData.stage)        
    awardCell.teamIcon = IconUtils:createTeamIconById({teamData = teamData, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],eventStyle = 0})

    local userId = self._modelMgr:getModel("UserModel"):getData()._id
    registerTouchEvent(awardCell.teamIcon,function()
    end,function()
    end,function()
        ViewManager:getInstance():showDialog("formation.NewFormationDescriptionView", {iconType = 10000,iconSubtype = userId, iconId = teamData.teamId or teamData.id,formationType = nil,isCustom = nil}, true)
    end)

    awardCell.teamIcon:setScale(0.86)
    awardCell.teamIcon:setAnchorPoint(0.5,0.5)
    awardCell.teamIcon:setPosition(50,50)
    awardCell.cell:addChild(awardCell.teamIcon)

    --累计奖励
    local award1,award2,delTime = self:getAwardCount(pos,detailData)
    local totalAward = award1 + award2
    awardCell.totalAwardNum = awardCell:getChildByFullName("totalAwardNum")
    awardCell.totalAwardNum:setString(award1+award2)
    --驻守时间
    awardCell.timeValue = awardCell:getChildByFullName("timeValue")
    awardCell.timeValue:stopAllActions()
    if delTime >= 0 then
        local tempAward = totalAward
        awardCell.timeValue:runAction(cc.RepeatForever:create(
            cc.Sequence:create(cc.CallFunc:create(function()
                delTime = delTime + 1
                local tempValue = delTime
                local hour, minute, second
                hour = math.floor(tempValue/3600)
                tempValue = tempValue - hour*3600
                minute = math.floor(tempValue/60)
                tempValue = tempValue - minute*60
                second = math.fmod(tempValue, 60)
                local showTime = string.format("%.2d:%.2d:%.2d", hour, minute, second)
                awardCell.timeValue:setString(showTime)
                --如果在放置的过程中产生奖励则需要刷新列表，可以领取奖励
                local awardValue1,awardValue2,delTimeValue = self:getAwardCount(pos,detailData)
                if tempAward  == 0 then  
                    if awardValue1 + awardValue2 > 0 then
                        tempAward = awardValue1 + awardValue2
                        self:refreshOnList(pos,false)
                    end
                else
                    if awardValue1 + awardValue2 > totalAward then
                        awardCell.totalAwardNum:setString(awardValue1+awardValue2)
                    end 
                end 
                
            end), cc.DelayTime:create(1))
        ))
    end
    --雇佣次数
    awardCell.hireTimes = awardCell:getChildByFullName("hireTimes")
    awardCell.hireTimes:setString(detailData["sTimes"])

    --按钮状态
    awardCell.getAwardBtn = awardCell:getChildByFullName("getAward")
    awardCell.recallBtn = awardCell:getChildByFullName("recallBtn")
    --额外奖励
    awardCell.otherPanel = awardCell:getChildByFullName("otherPanel")
    awardCell.otherPanel.otherNum = awardCell.otherPanel:getChildByFullName("otherNum")
    awardCell.otherPanel.otherText1 = awardCell.otherPanel:getChildByFullName("otherText1")
    print("============award2========="..award2)
    awardCell.otherPanel:setVisible(tonumber(award2) > 0) 
    if totalAward > 0 then
        awardCell.getAwardBtn:setVisible(true)
        awardCell.recallBtn:setVisible(false)
        -- awardCell.otherPanel:setVisible(true)
        local profitCount = self:getUesedProfit(detailData)
        awardCell.otherPanel.otherNum:setString(profitCount)

        local nodePosX,nodePosY = awardCell.otherPanel.otherNum:getPosition()
        local anchorPointX = awardCell.otherPanel.otherNum:getAnchorPoint().x
        local contsizeWidth = awardCell.otherPanel.otherNum:getContentSize().width
        awardCell.otherPanel.otherText1:setPosition(nodePosX + (1-anchorPointX)*contsizeWidth , nodePosY)

        awardCell.getAwardBtn:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine5, 2)

        self:registerClickEvent(awardCell.getAwardBtn, function()
            self._serverMgr:sendMsg("GuildServer", "getMercenaryReward", {pos = pos}, true, {}, function(result, errorCode)
                if errorCode ~= 0 then 
                    self._viewMgr:unlock(51)
                    return
                end
                -- dump(result,"======getMercenaryReward========")
                DialogUtils.showGiftGet({
                  gifts = result["reward"],
                })
                self:refreshOnList(pos,false)
            end)
        end)
    else
        awardCell.getAwardBtn:setVisible(false)
        awardCell.recallBtn:setVisible(true)
        -- awardCell.otherPanel:setVisible(false)
        awardCell.recallBtn:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine2, 2)
        self:registerClickEvent(awardCell.recallBtn, function()
            local retractTime = detailData["retractTime"]                          --可撤回时间戳
            local retractState,hasTime = self:checkRetractState(retractTime,pos)   --判断是否可以撤回
            if retractState then
                self._serverMgr:sendMsg("GuildServer", "retractMercenary", {pos = pos}, true, {}, function(result, errorCode)
                    print("======errorCode======="..errorCode)
                    if errorCode ~= 0 then 
                        self._viewMgr:unlock(51)
                        return
                    end
                    self:refreshOnList(pos,true)
                    -- self:upOtherBubbleState(pos)
                end)
            else
                local hasTimeDes
                local minute, second,tempValue
                minute = math.floor(hasTime/60)
                tempValue = hasTime - minute*60
                second = math.fmod(tempValue, 60)
                if minute > 0 then
                    hasTimeDes =  minute .. "分"
                    if second > 0 then
                        hasTimeDes = hasTimeDes ..second .."秒"
                    end
                else
                    hasTimeDes = second .."秒"
                end
                local tipDes = "还有"..hasTimeDes .."才能撤回"
                self._viewMgr:showTip(tipDes)
            end
        end)
    end
    -- --添加气泡
    -- local isChange = self._guildModel:checkChange(pos)
    -- if isChange then
    --     self:addShowBubble(awardCell)
    -- end
    -- --更新其它位置气泡状态
    -- self:upOtherBubbleState(pos)
    return awardCell
end

--更新其它位置气泡状态
function GuildMercenaryView:upOtherBubbleState(pos)
    for index = 1 , 3 do
        if index ~= pos then
            if self._listBg[index].item.qipaoNode then
                print("======index========"..index)
                self._listBg[index].item.qipaoNode:removeFromParentAndCleanup(true)
                self._listBg[index].item.qipaoNode = nil
            end
            if self._listBg[index].item then
                local isChange = self._guildModel:checkChange(index)
                if isChange then
                    self:addShowBubble(self._listBg[index].item)
                end
            end
        end
    end
end


--添加气泡
function GuildMercenaryView:addShowBubble(addNode)
    local tipbg = cc.Scale9Sprite:createWithSpriteFrameName("mercenaryQipao_change.png")     
    tipbg:setAnchorPoint(0, 0.5)
    tipbg:setPosition(550,110)
    local scale = 0.9
    tipbg:setScale(scale)
    local seq = cc.Sequence:create(cc.ScaleTo:create(0.8, scale+scale*0.2), cc.ScaleTo:create(0.8, scale))
    tipbg:runAction(cc.RepeatForever:create(seq))
    addNode.qipaoNode = tipbg
    addNode:addChild(tipbg, 100)
end

function GuildMercenaryView:checkRetractState(retractTime,pos)
    local curTime = self._userModel:getCurServerTime()
    print("===curTime======"..os.date("%c",curTime))

    local curTime = self._userModel:getCurServerTime()
    local changeTime = tab.lansquenet[pos]["changeTime"]
    if tonumber(retractTime) > tonumber(curTime) then
        return false,retractTime - tonumber(curTime) 
    end
    return true
end

--获取当前奖励值
--如果为0  显示召回 不为0则显示领奖
function GuildMercenaryView:getAwardCount(pos,detailData)
    local curServerTime = self._userModel:getCurServerTime()
    local delTime = curServerTime - detailData["setTime"]
    local awardValue1 = math.ceil(math.floor(delTime/tab.lansquenet[pos]["time"])*detailData["per"]) 
    local usedProfit = self:getUesedProfit(detailData)
    local awardValue2 = usedProfit
    return awardValue1,awardValue2,delTime
end

-- --计算单次被使用的收益
function GuildMercenaryView:getUesedProfit(detailData)
    -- local x = tab.lansquenet[pos]["x"]  --战斗力系数
    -- local y = tab.lansquenet[pos]["y"]  --基础奖励
    -- local n = tab.lansquenet[pos]["n"]  
    -- local time = tab.lansquenet[pos]["time"]
    -- return math.ceil(math.pow(score/x,2)*y)
    local usedProfit = 0
    local perUse = detailData["perUse"] or 0
    if tonumber(perUse) == 0 then
        usedProfit = detailData["sumUse"] or 0
    else
        usedProfit = perUse*detailData["sTimes"]
    end
    return usedProfit
end

-- 第一次被加到父节点时候调用
function GuildMercenaryView:onBeforeAdd(callback, errorCallback)
    self._serverMgr:sendMsg("GuildServer", "getMyMercenaryList", {}, true, {}, function(result, errorCode)
        if errorCode ~= 0 then 
            errorCallback()
            self._viewMgr:unlock(51)
            return
        end
        self._serverMgr:sendMsg("GuildServer", "getAllMercenary", {}, true, {}, function(result, errorCode)
            if errorCode ~= 0 then 
                self._viewMgr:unlock(51)
                return
            end
            self:switchTag(self._btnType,true)
            self:refreshUIUnify()
            callback()
        end)
    end)
end

function GuildMercenaryView:switchTag(viewType,force)
    if viewType == self._btnType and not force then return end
    self._btnType = viewType
    local btn = self._btnTable[viewType]
    for k , v in pairs(self._btnTable) do
        if v ~= btn then 
            local text = v:getTitleRenderer()
            text:disableEffect()
            v:setTitleColor(UIUtils.colorTable.ccUITabColor1)
            v:setScaleAnim(false)
            v:stopAllActions()
            v:setBright(true)
            v:setEnabled(true)
            UIUtils:tabChangeAnim(v,nil,true)
        end
    end
 
    UIUtils:tabChangeAnim(btn,function( )
        local text = btn:getTitleRenderer()
        text:disableEffect()
        btn:setTitleColor(UIUtils.colorTable.ccUITabColor2)
        btn:setBright(false)
        btn:setEnabled(false)
    end)

    if viewType == GuildMercenaryView.kTypePlace then
        self._placePanel:setVisible(true)
        self._lookPanel:setVisible(false)
    else
        self._serverMgr:sendMsg("GuildServer", "getAllMercenary", {}, true, {}, function(result, errorCode)
            print("======errorCode======="..errorCode)
            if errorCode ~= 0 then 
                self._viewMgr:unlock(51)
                return
            end
            self._placePanel:setVisible(false)
            self._lookPanel:setVisible(true)
            self._guildMercenaryData = self:getOrderData(result["mercenaryList"])
            local noDataDes = self:getUI("bg.mainBg.rewardPanel.lookPanel.noData")
            local nothingImage = self:getUI("bg.mainBg.rewardPanel.lookPanel.cellBg1.nothingImage")
            if #self._guildMercenaryData == 0 then
                noDataDes:setVisible(true)
                nothingImage:setVisible(true)
            else
                self:createTableView()
                noDataDes:setVisible(false)
                nothingImage:setVisible(false)
            end
        end)
    end
end

--首次进入 刷新所有佣兵列表
function GuildMercenaryView:refreshUIUnify()
    local result = self._guildModel:getGuildMercenary()
    dump(result,"====result====",2)
    if not next(result) then return end
    self._curDispatchCount = 0
    for k , v in pairs(result["mercenaryDetails"]) do        
        self:updateList(k,v,false)
        self._curDispatchCount = v["teamId"] == 0 and self._curDispatchCount or self._curDispatchCount + 1
    end
    self:setDispatchCount()
end
--刷新指定坑位列表信息
function GuildMercenaryView:refreshOnList(pos,isCallBack)
    local isCallBack = false or isCallBack
    local result = self._guildModel:getGuildMercenary()
    if not result or not next(result) then return end
    self._curDispatchCount = 0
    for k , v in pairs(result["mercenaryDetails"]) do 
        self._curDispatchCount = v["teamId"] == 0 and self._curDispatchCount or self._curDispatchCount + 1       
        if tonumber(k) == tonumber(pos) then
            self:updateList(k,v,isCallBack)
        end
    end
    self:setDispatchCount()
end


--更新佣兵列
--pos 坑位
--佣兵信息
--isCallBack --是否是召回
function GuildMercenaryView:updateList(pos,detailData,isCallBack)
    if isCallBack == false then
        if detailData["teamId"] == 0 then return end
    end
    local pos = tonumber(pos)
    self._listBg[pos].item:stopAllActions()
    self._listBg[pos].item:removeFromParent()
    self._listBg[pos].item = isCallBack == true and self:createDispatchCell(pos) or self:createAwardCell(pos,detailData)
    self._listBg[pos].item:setPosition(self._itemPos[pos].x,self._itemPos[pos].y)
    self._listBg:addChild(self._listBg[pos].item,tonumber(pos))
end

--设置佣兵派遣个数
function GuildMercenaryView:setDispatchCount()
    self._dispatchNum:setString(self._curDispatchCount.."/"..self._totalPostion)
end
--查看联盟佣兵列表
function GuildMercenaryView:createTableView()
    if self._lookTableView then
        self._lookTableView:reloadData()
        return 
    end
    local tableNode = self:getUI("bg.mainBg.rewardPanel.lookPanel.listBg1")
    local tableView = cc.TableView:create(cc.size(760,400))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setAnchorPoint(0,0)
    tableView:setPosition(0 ,0)
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    tableNode:addChild(tableView,999)
    tableView:registerScriptHandler(function( view ) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(function ( table,cell ) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(function( table,index ) return self:cellSizeForTable(table,index) end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function ( table,index ) return self:tableCellAtIndex(table,index) end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function ( table ) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()
    -- UIUtils:ccScrollViewAddScrollBar(tableView, cc.c3b(169, 124, 75), cc.c3b(64, 32, 12), -16, 6)
    self._lookTableView = tableView
    -- self._inScrolling = false
end

function GuildMercenaryView:scrollViewDidScroll(view)
    -- self._inScrolling = view:isDragging()
    -- self._tableOffset = view:getContentOffset()
    -- UIUtils:ccScrollViewUpdateScrollBar(view)
end


function GuildMercenaryView:tableCellTouched(table,cell)
end

function GuildMercenaryView:cellSizeForTable(table,idx) 
    return self._cellContentSize.height,self._cellContentSize.width
end

function GuildMercenaryView:tableCellAtIndex(table,idx)
    local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    local lookItem = self:getUI("lookItem")
    local row = idx*4
    if nil == cell then
        cell = cc.TableViewCell:new()
        for i=0,3 do
            local item = cell:getChildByName("cellItem".. i)
            if i+row+1>#self._guildMercenaryData then
                if item then
                    item:setVisible(false)
                end
            else

                if item then
                    self:createTeamItem(item,i+row+1,self._guildMercenaryData[i+row+1])
                end
                if not item then
                    item = lookItem:clone()
                    self:createTeamItem(item,i+row+1,self._guildMercenaryData[i+row+1])
                    cell:addChild(item)
                end
                item._indexNum = i+row+1
                item:setPosition(i*(self._cellContentSize.width+5) + self._cellContentSize.width/2+10,95)
                item:setName("cellItem".. i)
            end
        end
    else
        for i=0,3 do
            local item = cell:getChildByName("cellItem".. i)
            if i+row+1>#self._guildMercenaryData then
                if item then
                    -- item:removeFromParent()
                    item:setVisible(false)
                end
            else
                if item then
                    self:createTeamItem(item,i+row+1,self._guildMercenaryData[i+row+1])
                else
                    item = lookItem:clone()
                    self:createTeamItem(item,i+row+1,self._guildMercenaryData[i+row+1])
                    cell:addChild(item)
                    item._indexNum = i+row+1
                    item:setPosition(i*(self._cellContentSize.width+5) + self._cellContentSize.width/2+10,95)
                    item:setName("cellItem".. i)
                end
            end
        end
    end
    -- cell:removeAllChildren()    
    return cell
end

function GuildMercenaryView:getOrderData(mercenaryListData)
    
    local userId = self._userModel:getData()["_id"]
    -- print("=====userId======"..userId)
    local myMercenaryData = {}
    local otherMercenaryData = {}
    local allMercenaryData = {}
    for k , v in pairs(mercenaryListData) do
        if v["userId"] == userId then
            table.insert(myMercenaryData,v)
        else
            table.insert(otherMercenaryData,v)
        end
    end
    -- dump(myMercenaryData,"=======myMercenaryData====")
    table.sort(myMercenaryData, function(a, b)
        return a["team"].score - a["team"].pScore > b["team"].score - b["team"].pScore
    end)
    table.sort(otherMercenaryData, function(a, b)
        return a["team"].score - a["team"].pScore > b["team"].score - b["team"].pScore
    end)
    for k , v in pairs(myMercenaryData) do
        table.insert(allMercenaryData,v)
    end
    for k , v in pairs(otherMercenaryData) do
        table.insert(allMercenaryData,v)
        -- allMercenaryData[#myMercenaryData+1] = v
    end
    return allMercenaryData
end

function GuildMercenaryView:numberOfCellsInTableView(table)
    local itemRow = math.ceil(#self._guildMercenaryData/4)
    return itemRow
end

function GuildMercenaryView:createTeamItem(teamCell,index,data)
    local teamId = data["teamId"]
    teamCell:setVisible(true)
    teamCell:setAnchorPoint(0.5,0.5)
    teamCell.cell = teamCell:getChildByFullName("cell")
    local userId = self._userModel:getData()["_id"]
    local teamData = data["team"]
    teamData["teamId"] = teamId
    local teamTableData = tab:Team(teamId)
    local quality = self._teamModel:getTeamQualityByStage(teamData.stage)  
    --军团Icon
    if teamCell.cell then
        teamCell.cell:removeAllChildren()
    end
    teamCell.teamNode = IconUtils:createTeamIconById({teamData = teamData, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
    registerTouchEvent(teamCell.teamNode,function()
    end,function()
    end,function()
        ViewManager:getInstance():showDialog("formation.NewFormationDescriptionView", {iconType = 10000,iconSubtype = data["userId"], iconId = teamData.teamId or teamData.id,formationType = nil,isCustom = nil}, true)
    end)
    teamCell.teamNode:setScale(0.8)
    teamCell.teamNode:setAnchorPoint(0.5,0.5)
    teamCell.teamNode:setPosition(45,45)
    teamCell.cell:addChild(teamCell.teamNode)
    -- teamCell.teamNode.teamIcon:setTouchEnabled(false)
    teamCell.cell:setSwallowTouches(false)
    teamCell.teamNode:setSwallowTouches(false)
    teamCell.teamNode.teamIcon:setSwallowTouches(false)
    --名字
    teamCell.name = teamCell:getChildByFullName("name")
    teamCell.name:setString(data["userInfo"]["name"])
    --战力
    teamCell.fightBk = teamCell:getChildByFullName("fightBk")
    if teamCell.fightBk then
        teamCell.fightBk:removeAllChildren()
    end
    local fightValue = teamCell:getChildByFullName("fightValue")
    local fightDes = "战斗力:"..data["team"]["score"] - data["team"]["pScore"]
    fightValue:setString(fightDes)
    -- local zhanliText = cc.LabelBMFont:create("a"..(data["team"]["score"] - data["team"]["pScore"]), UIUtils.bmfName_zhandouli)
    
    fightValue:setColor(UIUtils.colorTable.ccUIBaseColor5)
    -- zhanliText:setScale(0.40)
    fightValue:setAnchorPoint(cc.p(0.5,0.5))
    -- zhanliText:setPosition(cc.p(teamCell.fightBk:getContentSize().width/2, teamCell.fightBk:getContentSize().height/2+3))

    -- teamCell.fightBk:addChild(zhanliText)

    -- teamCell:setSwallowTouches(false)
    -- return teamCell
end
--刷新被雇佣次数
function GuildMercenaryView:updatMercenaryTimes(pos)
    self:refreshOnList(pos,false)
end

-- 第一次进入调用, 有需要请覆盖
function GuildMercenaryView:onShow()

end

-- 被其他View盖住会调用, 有需要请覆盖
function GuildMercenaryView:onHide()

end

function GuildMercenaryView:getBgName(  )
    return "bg_007.jpg"
end

-- 接收自定义消息
function GuildMercenaryView:reflashUI(data)
    if self._btnType == GuildMercenaryView.kTypePlace then
        self:refreshOnList(data.pos,false)
    else

    end
end

function GuildMercenaryView:firstEnterState()
    local curServerTime = self._userModel:getCurServerTime()
    local timeDate
    local tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
    if curServerTime > tempCurDayTime then
        timeDate = TimeUtils.getDateString(curServerTime,"%Y%m%d")
    else
        timeDate = TimeUtils.getDateString(curServerTime - 86400,"%Y%m%d")
    end
    local tempdate = SystemUtils.loadAccountLocalData("MERCENARY_IS_SHOWED_ITEM")
    if tempdate ~= timeDate then
        SystemUtils.saveAccountLocalData("MERCENARY_IS_SHOWED_ITEM", timeDate)
    end
end

return GuildMercenaryView
