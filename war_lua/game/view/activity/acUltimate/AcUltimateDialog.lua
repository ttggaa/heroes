--
-- Author: huangguofang
-- Date: 2018-05-05 17:12:00
--

local AcUltimateDialog = class("AcUltimateDialog",BasePopView)
function AcUltimateDialog:ctor(param)
    self.super.ctor(self)
    self.initAnimType = 1
    -- print("================initAnimType===",self.initAnimType)
    self._acUltimateModel = self._modelMgr:getModel("AcUltimateModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._closeCallBack = param.closeCallBack
    
end
function AcUltimateDialog:getAsyncRes()
    return 
    {
        {"asset/ui/acUltimate.plist", "asset/ui/acUltimate.png"},
    }
end

-- function AcUltimateDialog:getBgName()
--     return "acLuckyLottery_bg_img.jpg"
-- end

function AcUltimateDialog:onDestroy()
    AcUltimateDialog.super.onDestroy(self)
    
end

-- 第一次被加到父节点时候调用
function AcUltimateDialog:onAdd()

end

function AcUltimateDialog:onInit()
    self._endTime = self._acUltimateModel:getAcEndTime() 
    self._nextTime = self._acUltimateModel:getNextReflashDay()
    self._acId = self._acUltimateModel:getUltimateId() or 50001
    self._guildShowData = tab.guildShow
    self._acData = self._guildShowData[tonumber(self._acId)]
    self._bubbleD = self._acData.qipao 
    self._tableData1 = self._acUltimateModel:getGuildData()
    self._tableData2 = self._acUltimateModel:getPersonalData()
    self:sortFunction(self._tableData1)
    self:sortFunction(self._tableData2)
    self._boxData = self._acUltimateModel:getBoxData()
    -- 判断有没有加入联盟
    local isHaveGuild = true
    local userData = self._userModel:getData()
    if not userData.guildId or userData.guildId == 0 then
        isHaveGuild = false
    end
    self._isHaveGuild = isHaveGuild
    -- self._selectNum = isHaveGuild and 1 or 2  -- >>1联盟  >>2个人  默认联盟
    self._selectNum = 2
    
    self._bg = self:getUI("bg")
    local bgImg = self:getUI("bg.bgImg")
    bgImg:loadTexture("asset/bg/acUltimateImg_bg.png")
    local titleImg = self:getUI("bg.titleImg")
    local titleMc = mcMgr:createViewMC("zhongjijianglin_zhongjijianglin", true,false)
    titleMc:setPosition(440,357)
    self._bg:addChild(titleMc,100)

    local roleImg = self:getUI("bg.roleImg")
    local teamID = self._acData.teamID
    local teamData = tab:Team(tonumber(teamID))
    if teamData and teamData["art1"] then
        local imgName = string.sub(teamData["art1"], 4, string.len(teamData["art1"]))
        roleImg:loadTexture("asset/uiother/team/t_"..imgName..".png")
    end
    self._closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(self._closeBtn, function ()
        self:close()
        if self._closeCallBack then
            self._closeCallBack()
        end
        UIUtils:reloadLuaFile("activity.acUltimate.AcUltimateDialog")
    end)
    self._item = self:getUI("bg.item")
    self._tableCellH = self._item:getContentSize().height
    self._tableCellW = self._item:getContentSize().width
    self._item:setVisible(false)
    self._guildTaskBtn = self:getUI("bg.guildTaskBtn")
    self._guildTaskBtn:setSaturation(isHaveGuild and 0 or -100)
    -- self._guildTaskBtn:setEnabled(isHaveGuild and true or false)
    self._btnTxt1 = self:getUI("bg.guildTaskBtn.btnTxt")
    self._personalTaskBtn = self:getUI("bg.personalTaskBtn")
    self._btnTxt2 = self:getUI("bg.personalTaskBtn.btnTxt")
    self:registerClickEvent(self._guildTaskBtn, function (sender)
        if not isHaveGuild then
            self._viewMgr:showTip("请先加入联盟")
            return 
        end
        self._selectNum = 1
        self:taskButtonClicked(1)
    end)
    self:registerClickEvent(self._personalTaskBtn, function (sender)
        self._selectNum = 2
        self:taskButtonClicked(2)
    end)
    self:updateBtnRed(self._guildTaskBtn,1)
    self:updateBtnRed(self._personalTaskBtn,2)

    self._bubbleImg = self:getUI("bg.bubbleImg")
    self._bubbleImg:setZOrder(10)
    self._bubbleImg:setVisible(false)
    self._bubbleTxt = self:getUI("bg.bubbleImg.bubbleTxt")
    self._bubbleTxt:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    self._listBg = self:getUI("bg.listBg")
    self:getUI("bg.listBg_0"):setSwallowTouches(true)
    self:getUI("bg.listBg_0_1"):setSwallowTouches(true)

    self._countNum = self:getUI("bg.countNum")
    -- 底部宝箱初始化
    self._boxPanel = self:getUI("bg.boxPanel")
    self._guildNum = self:getUI("bg.boxPanel.guildNum")
    self._iconImg = self:getUI("bg.boxPanel.iconImg")
    self._haveNum = self:getUI("bg.boxPanel.haveNum")
    self._boxBar = self:getUI("bg.boxPanel.boxBar")
    self._bar = self:getUI("bg.boxPanel.boxBar.bar")

    -- 捐献 未加入联盟置灰
    local donateBtn = self:getUI("bg.boxPanel.donateBtn")
    donateBtn:setSaturation(isHaveGuild and 0 or -100)
    donateBtn:setEnabled(isHaveGuild and true or false)
    donateBtn:enableOutline(cc.c4b(1, 67, 128, 255), 1) 
    donateBtn:setTitleFontSize(24)
    self:registerClickEvent(donateBtn, function (sender)
        self:sendDonateMsg()
    end)
    self._donateBtn = donateBtn
    self:initBoxReward()

    -- 联盟活动倒计时
    self._timeStr1 = self:getUI("bg.timeStr1")
    self._timeNum1 = self:getUI("bg.timeNum1")
    -- 个人任务下次刷新时间
    self._timeStr2 = self:getUI("bg.timeStr2")
    self._timeNum2 = self:getUI("bg.timeNum2")

    -- 倒计时
    self:reflashCD1()
    self:reflashCD2()
    self._timer1 = ScheduleMgr:regSchedule(1000, self, function( )
        self:reflashCD1()
    end)
    self._timer2 = ScheduleMgr:regSchedule(1000, self, function( )
        self:reflashCD2()
    end)

    -- 默认联盟
    self:taskButtonClicked(self._selectNum)
    self._tableData = self["_tableData" .. self._selectNum]
    self:addTableView()

    -- 规则
    local ruleBtn = self:getUI("bg.ruleBtn")
    UIUtils:addFuncBtnName(ruleBtn, "规则",cc.p(ruleBtn:getContentSize().width/2,0),true,18)
    self:registerClickEvent(ruleBtn, function(sender)
        -- self:ruleButtonClicked()
        self._viewMgr:showDialog("activity.acUltimate.AcUltimateRuleDialog", {acId = self._acId,acData=self._acData},true)
    end)

    -- 排行
    local rankBtn = self:getUI("bg.rankBtn")
    UIUtils:addFuncBtnName(rankBtn, "排行", cc.p(rankBtn:getContentSize().width/2, 0), true, 18)
    self:registerClickEvent(rankBtn, function(sender)
        -- self:rankButtonClicked()
        self._viewMgr:showDialog("activity.acUltimate.AcUltimateRankDialog", {rankType = 1},true)
    end)

    local isOpened = SystemUtils.loadAccountLocalData("ACTIVITY_ULTIMATE" .. self._acId)
    if not isOpened then
        SystemUtils.saveAccountLocalData("ACTIVITY_ULTIMATE" .. self._acId, true)        
        self:appearAnim()
    end
    -- 监听
    self:listenReflash("AcUltimateModel", self.reflashDataAndUI)

end

local normalColor = cc.c4b(138,152,172,255)
local normalOutColor = UIUtils.colorTable.ccUIBaseOutlineColor
local selectColor = cc.c4b(255, 255, 255, 255)
local selectOutColor = UIUtils.colorTable.ccUIBaseOutlineColor
function AcUltimateDialog:taskButtonClicked(buttonNum)
    if not buttonNum then 
        buttonNum = 1
    end
    self._guildTaskBtn:loadTextures("acUltimate_btn_normal.png","acUltimate_btn_normal.png","acUltimate_btn_normal.png",1)
    self._personalTaskBtn:loadTextures("acUltimate_btn_normal.png","acUltimate_btn_normal.png","acUltimate_btn_normal.png",1)
    self._guildTaskBtn:setTouchEnabled(true)    
    self._personalTaskBtn:setTouchEnabled(true)
    self._btnTxt1:setColor(normalColor)
    self._btnTxt1:enableOutline(normalOutColor,1)
    self._btnTxt1:setPosition(75, 16)
    self._btnTxt2:setColor(normalColor)
    self._btnTxt2:enableOutline(normalOutColor,1)
    self._btnTxt2:setPosition(75, 16)
    if buttonNum == 1 then
        self._guildTaskBtn:loadTextures("acUltimate_btn_selected.png","acUltimate_btn_selected.png","acUltimate_btn_selected.png",1)
        self._guildTaskBtn:setTouchEnabled(false)
        self._btnTxt1:setColor(selectColor)
        self._btnTxt1:enableOutline(selectOutColor,1)
        self._btnTxt1:setPosition(75, 21)
    else
        self._personalTaskBtn:loadTextures("acUltimate_btn_selected.png","acUltimate_btn_selected.png","acUltimate_btn_selected.png",1)
        self._personalTaskBtn:setTouchEnabled(false)
        self._btnTxt2:setColor(selectColor)
        self._btnTxt2:enableOutline(selectOutColor,1)
        self._btnTxt2:setPosition(75, 21)
    end 

    -- 获取listData
    self._tableData = self["_tableData" .. buttonNum]
    -- dump(self._tableData,"self._tableData==>",5)
    
    if self._tableView and self._tableData then
        self._tableView:reloadData()
    end
    -- 更新进度显示
    local num = self._acUltimateModel["getComNum" .. buttonNum](self._acUltimateModel)
    self._countNum:setString(num .. "/" .. (#self._tableData))
    -- 更新倒计时显示
    self._timeStr1:setVisible(buttonNum == 1)
    self._timeNum1:setVisible(buttonNum == 1)
    self._timeStr2:setVisible(buttonNum == 2)
    self._timeNum2:setVisible(buttonNum == 2)
end

function AcUltimateDialog:addTableView( )
    if self._tableView then  
        self._tableView:removeFromParent()
        self._tableView = nil
    end
    local tableView = cc.TableView:create(cc.size(370, 300))
    -- local tableView = cc.TableView:create(cc.size(573, 392))
    -- tableView:setClippingType(1)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(0,12)
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    -- tableView:setBounceEnabled(true)
    self._listBg:addChild(tableView,1)
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


function AcUltimateDialog:scrollViewDidScroll(view)
    self._inScrolling = view:isDragging()   
end

function AcUltimateDialog:scrollViewDidZoom(view)
    -- print("scrollViewDidZoom")
end

function AcUltimateDialog:tableCellTouched(table,cell)
    print("cell touched at index: " .. cell:getIdx())
end

function AcUltimateDialog:cellSizeForTable(table,idx) 
    return self._tableCellH+5,self._tableCellW
    -- return 110,566
end

function AcUltimateDialog:tableCellAtIndex(table, idx)
    local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    local label = nil
    local cellData = self._tableData[idx+1]

    if nil == cell then
        cell = cc.TableViewCell:new()    
    else
        cell:removeAllChildren()
    end
    local item = self:creatItem(cellData,idx+1)
    item:setPosition(15,5)
    item:setAnchorPoint(0,0)
    cell:addChild(item)

    return cell
end
function AcUltimateDialog:numberOfCellsInTableView(table)
    return #self._tableData
end

function AcUltimateDialog:initBoxReward()
    -- 底部宝箱初始化
    local userData = self._userModel:getData()
    local donateNum = userData.guildExp or 0
    self._guildNum:setString(donateNum)
    
    local xinwu = self._acData.xinwuID
    self._itemId = xinwu[2]
    print("=============self._itemId====",self._itemId)
    local _,num = self._itemModel:getItemsById(self._itemId)
    self._haveNum:setString(num or 0)
    self._donateBtn:setSaturation((self._isHaveGuild and num>0) and 0 or -100)
    self._iconImg:setVisible(false)
    local toolD = tab:Tool(self._itemId)
    local icon = IconUtils:createItemIconById({itemId = self._itemId, itemData = toolD,eventStyle=0})
    icon:setAnchorPoint(cc.p(0.5, 0.5))
    icon:setPosition(self._iconImg:getPositionX()-5,self._iconImg:getPositionY()+3)
    icon:setScale(0.3)
    self._boxPanel:addChild(icon,5)
    local boxIcon = icon.boxIcon
    local iconColor = icon.iconColor
    if boxIcon then
        boxIcon:setVisible(false)
    end
    if iconColor then
        iconColor:setVisible(false)
    end
    self._haveNum:setPositionY(self._iconImg:getPositionY()+2)

    local numD = self._acData.number or {}
    local reward = self._acData.reward or {}
    self._maxGuildNum = numD[#numD] or 0
    -- dump(numD,"numD==>",4)
    self._boxArr = {}
    local barLen = 550
    local averageLen = 550 / (self._maxGuildNum == 0 and 1 or self._maxGuildNum)
    local imgName
    local box
    local getMc
    local numTxt
    local guildNumImg
    local guildNumTxt 
    for i=1,#numD do
        -- print("========numD[i]===",numD[i])
        -- local rewardD = reward[i]
        imgName = self._boxData[numD[i]] and "box_1_p.png" or "box_1_n.png"
        box = ccui.Button:create()
        box:loadTextures(imgName,imgName,"",1)
        box:setPosition(averageLen*numD[i] - 20,25)
        self._boxBar:addChild(box)
        box.__reward = reward[i]
        box.__needNum = numD[i]
        box.__isCanGet = (not self._boxData[numD[i]] and donateNum >= numD[i])

        box:setOpacity((not self._boxData[numD[i]] and donateNum >= numD[i]) and 0 or 255)
        getMc = mcMgr:createViewMC("baoxiang1_baoxiang", true,false)
        getMc:setPosition(38,32)
        getMc:setVisible(not self._boxData[numD[i]] and donateNum >= numD[i])
        box:addChild(getMc)
        box._getMc = getMc

        numTxt = ccui.Text:create()
        numTxt:setFontSize(20)
        numTxt:setFontName(UIUtils.ttfName)
        numTxt:setString(reward[i][3])
        numTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        numTxt:setPosition(35, 12)
        box:addChild(numTxt)
        registerClickEvent(box, function(sender)
            self:sendGetBoxMsg(sender)
        end)
        table.insert(self._boxArr, box)

        guildNumImg = ccui.ImageView:create()
        guildNumImg:loadTexture("acUltimate_boxNum_bg.png",1)
        guildNumImg:setPosition(averageLen*numD[i] - 20,-16)
        self._boxBar:addChild(guildNumImg)

        guildNumTxt = ccui.Text:create()
        guildNumTxt:setFontSize(16)
        guildNumTxt:setFontName(UIUtils.ttfName)
        guildNumTxt:setString(numD[i])
        guildNumTxt:setColor(cc.c4b(123,199,210,255))
        -- guildNumTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        guildNumTxt:setPosition(averageLen*numD[i] - 20,-16)
        self._boxBar:addChild(guildNumTxt)
    end

    self._bar:setPercent((self._maxGuildNum == 0) and 0 or (donateNum/self._maxGuildNum*100))
end
function AcUltimateDialog:updateBox()
    if not self._boxArr then return end

    local _,num = self._itemModel:getItemsById(self._itemId)
    self._haveNum:setString(num or 0)

    self._donateBtn:setSaturation((self._isHaveGuild and num>0) and 0 or -100)
    self._boxData = self._acUltimateModel:getBoxData()
    local userData = self._userModel:getData()
    local donateNum = userData.guildExp or 0
    self._guildNum:setString(donateNum)
    -- self._maxGuildNum 
    local imgName
    for k,v in pairs(self._boxArr) do
        local box = v
        local needNum = box.__needNum
        box.__isCanGet = not self._boxData[needNum] and donateNum >= needNum
        imgName = self._boxData[needNum] and "box_1_p.png" or "box_1_n.png"
        box:loadTextures(imgName,imgName,"",1)
        box:setOpacity((not self._boxData[needNum] and donateNum >= needNum) and 0 or 255)
        box._getMc:setVisible(not self._boxData[needNum] and donateNum >= needNum)
    end
    self._bar:setPercent((self._maxGuildNum == 0) and 0 or (donateNum/self._maxGuildNum*100))
end

-- 联盟活动倒计时
function AcUltimateDialog:reflashCD1()
    local currentTime = self._userModel:getCurServerTime()
    local endTime = self._endTime or currentTime

    local remainTime = endTime - currentTime

    local tempValue = remainTime    
    local day = math.floor(tempValue/86400) 
    tempValue = tempValue - day*86400
    
    local hour = math.floor(tempValue/3600)
    tempValue = tempValue - hour*3600

    local minute = math.floor(tempValue/60)
    tempValue = tempValue - minute*60
   
    local second = math.fmod(tempValue, 60)
    local showTime = string.format("%.2d天%.2d:%.2d:%.2d", day, hour, minute, second)
    if day == 0 then
        showTime = string.format("00天%.2d:%.2d:%.2d", hour, minute, second)
    end
    if remainTime <= 0 then
        if self._timer1 then
            ScheduleMgr:unregSchedule(self._timer1)
            self._timer1 = nil
        end
        if self._timer2 then
            self._timeNum2:setString("00:00:00")
            ScheduleMgr:unregSchedule(self._timer2)
            self._timer2 = nil
        end
        showTime = "00天00:00:00"
    end
    self._timeNum1:setString(showTime)
end

-- 个人下次刷新时间（每天刷新）
function AcUltimateDialog:reflashCD2()
    local currentTime = self._userModel:getCurServerTime()
    local endTime = self._nextTime or currentTime

    local remainTime = endTime - currentTime

    local tempValue = remainTime    
    
    local hour = math.floor(tempValue/3600)
    tempValue = tempValue - hour*3600

    local minute = math.floor(tempValue/60)
    tempValue = tempValue - minute*60
   
    local second = math.fmod(tempValue, 60)
    local showTime = string.format("%.2d:%.2d:%.2d", hour, minute, second)
    
    if remainTime <= 0 then
        showTime = "00:00:00"
        self._nextTime = self._acUltimateModel:getNextReflashDay()
    end
    self._timeNum2:setString(showTime)
end


function AcUltimateDialog:reflashDataAndUI(data)
    -- print("=========================reflashDataAndUI()=====")
    if not self._acUltimateModel:isActivityOpen() then return end
    self._tableData1 = self._acUltimateModel:getGuildData()
    self._tableData2 = self._acUltimateModel:getPersonalData()
    self:sortFunction(self._tableData1)
    self:sortFunction(self._tableData2)
    self._boxData = self._acUltimateModel:getBoxData()
    self._tableData = self["_tableData" .. self._selectNum]

    if self._tableData and self._tableView then
        self._tableView:reloadData()
    end

    self:updateBtnRed(self._guildTaskBtn,1)
    self:updateBtnRed(self._personalTaskBtn,2)
    local _,num = self._itemModel:getItemsById(self._itemId)
    self._haveNum:setString(num or 0)
    self._donateBtn:setSaturation((self._isHaveGuild and num>0) and 0 or -100)

    -- 更新进度显示
    local num = self._acUltimateModel["getComNum" .. self._selectNum](self._acUltimateModel)
    self._countNum:setString(num .. "/" .. (#self._tableData))

    -- 更新联盟信物值
    local userData = self._userModel:getData()
    local donateNum = userData.guildExp or 0
    self._guildNum:setString(donateNum)
end
function AcUltimateDialog:updateBtnRed(btn,selectedNum)
    local dot = btn.__noticeTip
    if not dot then
        dot = ccui.ImageView:create()
        dot:loadTexture("globalImageUI_bag_keyihecheng.png", 1)
        dot:setPosition(140,34)--node:getContentSize().width,node:getContentSize().height))
        btn.__noticeTip = dot
        btn:addChild(dot,99)
    end

    local isTrue = self._acUltimateModel["isTaskRed" .. selectedNum](self._acUltimateModel)
    dot:setVisible(isTrue)
    return dot
end

function AcUltimateDialog:sortFunction(data)
    if not data or type(data) ~= "table" then
        return
    end

    table.sort(data,function(a,b)
        if a.status == b.status then
            return a.id < b.id
        else
            return a.status > b.status
        end
    end)

end


function AcUltimateDialog:creatItem(data,index)
    local item = self._item:clone()
    item:setVisible(true)
    item:setSwallowTouches(false)
    local itemBg = item:getChildByFullName("itemBg")
    itemBg:setSwallowTouches(false)
    local iconPanel = item:getChildByFullName("iconPanel")
    iconPanel:setSwallowTouches(false)
    local titleTxt = item:getChildByFullName("titleTxt")
    titleTxt:setVisible(false)
    -- titleTxt:setString(index)
    local getBtn = item:getChildByFullName("getBtn")
    local goBtn = item:getChildByFullName("goBtn")
    getBtn:setVisible(false)
    goBtn:setVisible(false)
    if not data then return  item end

    iconPanel:removeAllChildren()
    --创建奖励icon
    local createShowItem = self.createShowItem
    local rewardD = data.reward or {}
    local posX = 36
    local posY = 34
    for k,v in pairs(rewardD) do
        local icon = createShowItem(self,v,posX,posY)
        posX = posX + 60
        iconPanel:addChild(icon)
    end

    -- 添加title富文本
    if item.__title then 
        item.__title:removeFromParent()
        item.__title = nil
    end
    local titleStr = lang(data.title)
    if string.find(titleStr, "color=") == nil then
        titleStr = "[color=ffffff]"..titleStr.."[-]"
    end
    local title = RichTextFactory:create(titleStr, 500, 30)
    title:formatText()
    title:setPosition(258, 75)
    item:addChild(title,1)
    item.__title = title

    -- 联盟信物展示
    if item.__xinwu then
        item.__xinwu:removeFromParent()
        item.__xinwu = nil
    end
     -- 联盟信物展示
    if item.__xinwuTxt then
        item.__xinwuTxt:removeFromParent()
        item.__xinwuTxt = nil
    end
    if data.leagueReward then
        local leagueReward = data.leagueReward
        local posX = 30 + title:getRealSize().width
        local icon = createShowItem(self,leagueReward,posX,76)
        icon:setScale(0.4)
        item:addChild(icon)
        item.__xinwu = icon
        local boxIcon = icon.boxIcon
        local iconColor = icon.iconColor
        if boxIcon then
            boxIcon:setVisible(false)
        end
        if iconColor then
            iconColor:setVisible(false)
        end
        local txt = ccui.Text:create()
        txt:setString("x" .. leagueReward[3])
        txt:setColor(UIUtils.colorTable.ccUIBaseColor1)
        -- txt:enableOutline(cc.c4b(0,0,0,255),1)
        txt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        txt:setFontName(UIUtils.ttfName)
        txt:setFontSize(16)
        txt:setAnchorPoint(0,0.5)
        txt:setPosition(posX + 15, 75)
        item:addChild(txt, 1)
        item.__xinwuTxt = txt
    end

    getBtn:setVisible(data.status ~= 0)
    getBtn:setTitleText(data.status == -1 and "已领取" or "领取")
    getBtn:setSaturation(data.status == -1 and -100 or 0)
    goBtn:setVisible(data.status == 0)
    self:registerClickEvent(goBtn, function ()
        if self["goView" .. (data.button or 1)] then
            self["goView" .. (data.button or 1)](self)
            self:close()
            if self._closeCallBack then
                self._closeCallBack()
            end
        end
    end)
    getBtn.__data = data
    self:registerClickEvent(getBtn, function (sender)
        self:sendGetRewardMsg(sender.__data)
    end)

    local comNum = item:getChildByFullName("comNum")
    local targetNum = item:getChildByFullName("targetNum")
    comNum:setString(data.currNum or 0)
    targetNum:setString("/" .. (data.targetNum or 0))
    targetNum:setColor(data.status == 1 and cc.c4b(255,255,255,255) or cc.c4b(92,170,181,255))

    UIUtils:center2Widget(comNum,targetNum,275)
    return item
end

function AcUltimateDialog:createShowItem(rewardD,posX,posY)   
    local icon        
    local itemNum = rewardD[3]
    local itemId = rewardD[2] 
    local itemType = rewardD[1]
    if itemType == "hero" then
        local heroData = clone(tab:Hero(itemId))
        icon = IconUtils:createHeroIconById({sysHeroData = heroData})
        --icon:setAnchorPoint(cc.p(0, 0))
        icon:getChildByName("starBg"):setVisible(false)
        for i=1,6 do
            if icon:getChildByName("star" .. i) then
                icon:getChildByName("star" .. i):setPositionY(icon:getChildByName("star" .. i):getPositionY() + 5)
            end
        end
        icon:setPosition(giftItem:getContentSize().width / 2, giftItem:getContentSize().height / 2)
        icon:setSwallowTouches(false)
        registerClickEvent(icon, function()
            local NewFormationIconView = require "game.view.formation.NewFormationIconView"
            self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = itemId}, true)
        end)
    elseif itemType == "team" then
        local teamTeam = clone(tab:Team(itemId))
        icon = IconUtils:createSysTeamIconById({sysTeamData = teamTeam,isJin=true})
        --icon:setAnchorPoint(cc.p(0,0))
        --icon:setSwallowTouches(false)
    elseif itemType == "avatarFrame" then
        local frameData = tab:AvatarFrame(itemId)
        param = {itemId = itemId, itemData = frameData}
        icon = IconUtils:createHeadFrameIconById(param)
    elseif itemType == "siegeProp" then
        self.rewardsSiegeProp = true
        local propsTab = tab:SiegeEquip(itemId)
        local param = {itemId = itemId, level = 1, itemData = propsTab, quality = propsTab.quality, iconImg = propsTab.art, eventStyle = 1}
        icon = IconUtils:createWeaponsBagItemIcon(param)
    elseif itemType == "rune" then
        local runeData = tab:Rune(itemId)
        icon =IconUtils:createHolyIconById({suitData = runeData})
    else
        if itemType ~= "tool" then
            itemId = IconUtils.iconIdMap[itemType]
        end
        icon = IconUtils:createItemIconById({itemId = itemId, num = itemNum,eventStyle = eventStyle})
    end
    icon:setScale(0.6)
    icon:setPosition(posX,posY)
    icon:setAnchorPoint(0.5,0.5)

    return icon

end

-- 更新气泡展示
function AcUltimateDialog:updateBubbleShow()
    -- print("=========================")
    local isVisible = self._bubbleImg:isVisible()
    local posX,posY = self._bubbleImg:getPosition()
    local randnum = math.random(1, 3)
    local str = self._bubbleD[randnum]
    -- dump(self._acData,"self._acData==>",5)
    -- dump(self._bubbleD,"self._bubbleD==>",6)
    -- print("============randnum===",randnum,str)
    if not str then
        str = ""
    end
    print("============str================",str)
    self._bubbleTxt:setString(lang(str))
    if isVisible then
        self._bubbleImg:stopAllActions()
        self._bubbleImg:setOpacity(255)
        local action = cc.Sequence:create(cc.DelayTime:create(0.8),CCCallFunc:create(function( ... )
            self._bubbleImg:setOpacity(0)
            self._bubbleImg:setVisible(false)
            self._bubbleImg:setPosition(posX, posY)
        end))
        self._bubbleImg:runAction(action)
    else
        self._bubbleImg:stopAllActions()
        self._bubbleImg:setOpacity(0)
        self._bubbleImg:setVisible(true)
        local action = cc.Sequence:create(
            cc.Spawn:create(
                cc.FadeIn:create(0.2),
                cc.Sequence:create(cc.MoveTo:create(0.1, cc.p(posX+5,posY)),cc.MoveTo:create(0.1, cc.p(posX,posY)))
            ),
            cc.DelayTime:create(0.8),
            cc.CallFunc:create(function()
                self._bubbleImg:setOpacity(0)
                self._bubbleImg:setVisible(false)
            end))
        self._bubbleImg:runAction(action)

    end
    self._bubbleImg:setVisible(true)
    
end

-- 领任务奖
function AcUltimateDialog:sendGetRewardMsg(data)
    print("===================领任务奖==============")
    if data.status == -1 then
        self._viewMgr:showTip("奖励已领取")
        return
    end
    -- 领取联盟奖励
    if self._selectNum == 1 then        
        self._serverMgr:sendMsg("ComingGuildAcServer", "getGuildReward", {acId = self._acId,taskId = data.id}, true, {}, function(data)
            if data["reward"] then 
                DialogUtils.showGiftGet({ gifts = data["reward"], hide = self, callback = function()                    
                    -- 更新数据及刷新界面
                    self:reflashDataAndUI()
                end,notPop = false})
            end 
        end)
    else
        -- 领取个人奖励
        self._serverMgr:sendMsg("ComingGuildAcServer", "getRoleReward", {acId = self._acId,taskId = data.id}, true, {}, function(data)
            if data["reward"] then 
                DialogUtils.showGiftGet({ gifts = data["reward"], hide = self, callback = function()                    
                    -- 更新数据及刷新界面
                    self:reflashDataAndUI()
                end,notPop = false})
            end 
        end)
    end
end

-- 捐献
function AcUltimateDialog:sendDonateMsg()
    print("===================捐献==============")
    local _,itemNum = self._itemModel:getItemsById(self._itemId)
    if not itemNum or itemNum == 0 then
        self._viewMgr:showTip("没有可以捐赠的信物")
        return
    end
    self._serverMgr:sendMsg("ComingGuildAcServer", "donateExp", {acId = self._acId,num=itemNum}, true, {}, function(data)
        -- 更新气泡显示
        self._viewMgr:showTip("捐献成功")
        self:updateBubbleShow()
        self:updateBox()
    end)
end
-- 领进度宝箱奖
function AcUltimateDialog:sendGetBoxMsg(sender)
    print("=========领取宝箱奖励==========")
    local reward = sender.__reward or {}
    if sender.__isCanGet then
        self._serverMgr:sendMsg("ComingGuildAcServer", "getRoleProcessReward", {acId = self._acId,taskId = sender.__needNum}, true, {}, function(data)
            -- 更新宝箱显示
            if data["reward"] then 
                DialogUtils.showGiftGet({ gifts = data["reward"], hide = self, callback = function()                    
                    -- 更新宝箱状态
                    self:updateBox()
                end,notPop = false})
            end 
            
        end)
    else
       --预览
       local arr = {}
       table.insert(arr, sender.__reward)
        DialogUtils.showGiftGet({
           gifts = arr,
           viewType = 1,
           des = "联盟信物达到" .. sender.__needNum .. "可获得"
        })
    end
end

-- 抽卡
function AcUltimateDialog:goView1()
    print("================goview1============")
    self._viewMgr:showView("flashcard.FlashCardView")
end
-- 占星 宝物抽卡
function AcUltimateDialog:goView2()
    print("================goview2============")
    if not SystemUtils:enableTreasure() then
        self._viewMgr:showTip(lang("TIP_Treasure"))
        return 
    end

    self._viewMgr:showView("treasure.TreasureShopView")
end
-- 器械
function AcUltimateDialog:goView3()
    print("================goview3============")
    if self._modelMgr:getModel("WeaponsModel"):getWeaponState() ~= 4 then
        self._viewMgr:showTip(lang("TIPS_SIEGE_LORDBOOK_OPEN_1"))
        return 
    end
    self._viewMgr:showView("weapons.WeaponsView", {})
end
-- 法术
function AcUltimateDialog:goView4()
    print("================goview4============")
    if not SystemUtils:enableSkillBook() then
        self._viewMgr:showTip(lang("TIP_GUILD_OPEN_5"))
        return 
    end
    self._viewMgr:showView("skillCard.SkillCardTakeView")
end
-- 圣辉跳转
function AcUltimateDialog:goView5()
    print("================goview5============")
    if not SystemUtils:enableHoly() then
        self._viewMgr:showTip(lang("TIP_rune"))
        return 
    end
    self._viewMgr:showView("team.TeamHolyView", {})
end
-- 副本
function AcUltimateDialog:goView6()
    print("================goview1============")
    self._viewMgr:showView("intance.IntanceView", {superiorType = 1}) 
end
-- 兵团
function AcUltimateDialog:goView7()
    print("================goview1============")
    self._viewMgr:showView("team.TeamListView")
end
-- 联盟地图
function AcUltimateDialog:goView8()
    print("================goview9============")
    if not SystemUtils:enableGuild() then
        self._viewMgr:showTip(lang("TIP_Guild"))
        return 
    end
    local userData = self._userModel:getData()
    if not userData.guildId or userData.guildId == 0 then
        self._viewMgr:showTip("尚未加入联盟")
        return
    end

    self._viewMgr:showView("guild.map.GuildMapView")
end

-- 联盟
function AcUltimateDialog:goView9()
    print("================goview7============")
    if not SystemUtils:enableGuild() then
        self._viewMgr:showTip(lang("TIP_Guild"))
        return 
    end
    local userData = self._userModel:getData()
    if not userData.guildId or userData.guildId == 0 then
        self._viewMgr:showTip("尚未加入联盟")
        return
    end
    self._viewMgr:showView("guild.GuildView")
end
-- 充值
function AcUltimateDialog:goView10()
    print("================goview10============")
    self._viewMgr:showView("vip.VipView", {viewType = 0})
end
-- 船坞
function AcUltimateDialog:goView11()
    print("================goview11============")
    if not SystemUtils:enableMF() then
        self._viewMgr:showTip(lang("TIP_MF"))
        return 
    end

    self._viewMgr:showView("MF.MFView")
end

-- 首次出场动画
function AcUltimateDialog:appearAnim()

    self:lock(-1)
    self._bg:setVisible(false)
    self._bg:setScale(0)
    local appearMc = mcMgr:createViewMC("zhongjijianglinchuxian_zhongjijianglinchuxian", false,true)
    appearMc:addCallbackAtFrame(35, function()
        self._bg:setVisible(true)
        local seq = cc.Sequence:create(cc.ScaleTo:create(0.1, 1.1),
                        cc.ScaleTo:create(0.1, 1),
                        CCCallFunc:create(function()
                            self:unlock()
                        end))
        self._bg:runAction(seq)
    end)
    appearMc:setPosition(MAX_SCREEN_WIDTH*0.5,320)
    appearMc:setScale(MAX_SCREEN_WIDTH/960)
    self:addChild(appearMc,-1)
end

function AcUltimateDialog.dtor()
    normalColor = nil
    normalOutColor = nil
    selectColor = nil
    selectOutColor = nil
end

return AcUltimateDialog