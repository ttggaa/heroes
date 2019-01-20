--
-- Author: <ligen@playcrab.com>
-- Date: 2017-04-10 21:12:46
--
local HandbookView = class("HandbookView", BaseView)

function HandbookView:ctor(data)
    HandbookView.super.ctor(self)
    self.initAnimType = 2

    self._curIndex = nil

    self._tableData = {}
    self._taskData = {}

    self._userModel = self._modelMgr:getModel("UserModel")
    self._hModel = self._modelMgr:getModel("HandbookModel")

    self._redData = data.redData

    -- 最新一次开启功能的等级
    self._newOpenLv = 0

    self._previewCount = tab:Setting("GAMEPLAY_PREVIEW_AMOUNT").value -- 未开启功能预览个数
    self._jumpTargetIndex = 5 -- 默认跳转到第五个的位置
end

function HandbookView:getBgName()
    return "bg_handbook.jpg"
end

function HandbookView:getAsyncRes()
    return
    {
        { "asset/ui/handbook.plist", "asset/ui/handbook.png" }
    }
end

function HandbookView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{titleTxt = "领主手册"})
end

function HandbookView:onBeforeAdd(callback, errorCallback)
    if not self._hModel:getHasCeche() then
        self._serverMgr:sendMsg("HandbookServer", "getAllTaskInfo", {}, true, {}, function(result)
            self._taskData = result
            callback()
            self:reflashUI(true)
        end)
    else
        self._taskData = self._hModel:getData()
        callback()
        self:reflashUI(true)
    end
end

function HandbookView:initData()
    self._tableData = {}    
    self._specialIndex = nil    -- 斯坦德威克特殊处理index
    self._specialNum = 0        -- 斯坦德威克事件影响的任务个数
    for k, v in pairs(tab.gameplayOpen) do
        table.insert(self._tableData, v)
    end

    table.sort(self._tableData, function(a,b)
        return a.tabRank < b.tabRank
    end)

    self._gamePlayOpenLen = #self._tableData

    self._maxPreviewIndex = nil

    local newTab = {}
    for i = 1, #self._tableData do
        local data = self._tableData[i]
        local userLv = self._userModel:getPlayerLevel()
        if userLv < self._tableData[i].requiresLevel then   
            if self._maxPreviewIndex == nil then
                self._maxPreviewIndex = math.min(i + self._previewCount, self._gamePlayOpenLen)
            end
            -- 未开启最多显示六个
            if i <= self._maxPreviewIndex then
                if data.LinkGroup and data.LinkGroup == 1 then
                    self._specialNum = self._specialNum + 1
                    if not self._specialIndex then
                        self._specialIndex = #newTab + 1
                        local dataTemp = {}
                        dataTemp.id = "special"
                        table.insert(newTab, dataTemp)
                        table.insert(newTab, dataTemp)
                    end
                end
                table.insert(newTab, data)
            else
                break
            end
        else
            if data.LinkGroup and data.LinkGroup == 1 then
                self._specialNum = self._specialNum + 1
                if not self._specialIndex then
                    self._specialIndex = #newTab + 1
                    local dataTemp = {}
                    dataTemp.id = "special"
                    table.insert(newTab, dataTemp)
                    table.insert(newTab, dataTemp)
                end
            end
            table.insert(newTab, data)
            self._newOpenLv = math.max(self._newOpenLv, data.requiresLevel)
        end
    end
    self._tableData = newTab
    -- dump(self._tableData,"_tableData==>",5)
    self._checkData = self._hModel:getCheckData()
end

function HandbookView:onTop()
    
    -- 刷新嘉年华数据
    local carnivalModel = self._modelMgr:getModel("ActivityCarnivalModel")  
    carnivalModel:doUpdate()   
end

function HandbookView:onInit()
    self:initData()


--    local curData = self._tableData[self._curIndex]

    self._openLvLabel = self:getUI("bg.layer.openLvLabel")
    self:formatLabel(self._openLvLabel, UIUtils.colorTable.ccUIBaseTextColor2, nil, UIUtils.ttfName_Title)

    self._nameLabel = self:getUI("bg.layer.nameLabel")
    self:formatLabel(self._nameLabel, cc.c3b(181,0,3), nil, UIUtils.ttfName_Title)

    self._desLabel = self:getUI("bg.layer.desLabel")
    self:formatLabel(self._desLabel, UIUtils.colorTable.ccUIBaseTextColor1, nil, UIUtils.ttfName_Title)

    self:formatLabel(self:getUI("bg.layer.outputLabel"), nil, "产出:",  UIUtils.ttfName_Title, nil)

    self:formatLabel(self:getUI("bg.layer.titleBg.titleLabel"), UIUtils.colorTable.ccUIBaseTextColor2, 
        "冒险任务", UIUtils.ttfName_Title,nil)

    self:formatLabel(self:getUI("bg.layer.taskTitle"), UIUtils.colorTable.ccUIBaseTextColor2,
        "完成所有任务可获得",  UIUtils.ttfName_Title)


    self._desImg = self:getUI("bg.layer.imgDes")
--    self._desImg:loadTexture("asset/uiother/handbook/handbookPic_" .. self._curIndex .. ".png")

    self._outputNode = self:getUI("bg.layer.outputNode")
--    self:reflashOutPut(curData.rewardsPreview)

    self._taskNode = self:getUI("bg.layer.taskNode")
--    self:reflashTaskNode(curData.corrQuest)

    self._awardNode = self:getUI("bg.layer.awardNode")
--    self:reflashAwardNode(curData.questRewards)

    self._selectMc = mcMgr:createViewMC("xuanzhong_xuanzhong", true)
    self._selectMc:retain()

    self._tableCellWidth = 123
    self._tableCellHeight = 150
    
    self._taskView = self:getUI("bg.layer.taskView")
    self._taskView:setContentSize(cc.size(MAX_SCREEN_WIDTH - 40, 162))
    self._taskView:setPositionX((MAX_DESIGN_WIDTH-MAX_SCREEN_WIDTH)*0.5+20)

    self._leftPaoPosX = 10
    self._leftPaoPosY = 95
    self._rightPaoPosX = self._taskView:getContentSize().width - 10
    self._rightPaoPosY = 95 

    self._tableView = self:addTableView()

--    local sideLeft = cc.Sprite:createWithSpriteFrameName("imgSideLeft_handbook.png")
--    sideLeft:setPosition(-sideLeft:getContentSize().width*0.5+20, sideLeft:getContentSize().height*0.5)
--    self._taskView:addChild(sideLeft)
--    local rightLeft = cc.Sprite:createWithSpriteFrameName("imgSideRight_handbook.png")
--    rightLeft:setPosition(self._taskView:getContentSize().width+sideLeft:getContentSize().width*0.5-23, sideLeft:getContentSize().height*0.5-1)
--    self._taskView:addChild(rightLeft)

    self._goBtn = self:getUI("bg.layer.goBtn")
    self:registerClickEvent(self._goBtn, function(sender)
        if sender.state == 1 then
            self._viewMgr:showTip(sender.desStr)
            return
        end

        if self["goView" .. self._tableData[self._curIndex].button] then
            self["goView" .. self._tableData[self._curIndex].button](self)
        end
    end)

    self._getBtn = self:getUI("bg.layer.getBtn")
    self:registerClickEvent(self._getBtn, function(sender)
        if sender.enabled == false then
            self._viewMgr:showTip(lang("handBook_2"))
            return
        end

        self._serverMgr:sendMsg("HandbookServer", "getTaskAward", 
            {funcId = self._tableData[self._curIndex].id}, true, {}, 
            specialize(self.onGetAward, self)
        )
    end)

    self._gotIcon = self:getUI("bg.layer.gotIcon")

    self._getMC = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true)
    self._getMC:setPlaySpeed(1, true)
    self._getMC:setPosition(self._getBtn:getContentSize().width / 2, self._getBtn:getContentSize().height / 2)
    self._getBtn:addChild(self._getMC)

    -- 加上下箭头
    self._leftArrow = mcMgr:createViewMC("zuojiantou_teamnatureanim", true, false)
    self._leftArrow:setPosition(15, 61)
    self._taskView:addChild(self._leftArrow)

    self._rightArrow = mcMgr:createViewMC("youjiantou_teamnatureanim", true, false)
    self._rightArrow:setPosition(self._taskView:getContentSize().width - 20, 61)
    self._taskView:addChild(self._rightArrow)

--    self._canGetAward = self:canGetAward()
--    self._canGetAward = self:canGetAward()
--    self._getBtn:setVisible(self._canGetAward ~= 2)
--    self._getMC:setVisible(self._canGetAward == 1)
--    self._gotIcon:setVisible(self._canGetAward == 2)
--    UIUtils:setGray(self._getBtn, self._canGetAward == 0)
--    self._getBtn:setTouchEnabled(self._canGetAward == 0)

    self:setListenReflashWithParam(true)
    self:listenReflash("HandbookModel", self.updateInfo)
end

function HandbookView:updateInfo(eventName)
    if eventName ~= nil then
        return
    end

    self._taskData = self._hModel:getData()
    local offset =  self._tableView:getContentOffset()
    self._selectMc:removeFromParent()
    self._tableView:reloadData()
--    self._tableView:updateCellAtIndex(self._curIndex - 1)
    self._tableView:setContentOffset(offset)

    self:reflashHandbookInfo()
end

function HandbookView:reflashUI(isInit)
    if not isInit then
        self:initData()
    end

    self._tableView:reloadData()

    local jumpTab = nil

    local userlvl = self._modelMgr:getModel("UserModel"):getData().lvl 
    -- 跳到下一个未领奖 优先级（1）
    if jumpTab == nil then
        for i = 1, #self._tableData do
            if self._taskData[tostring(self._tableData[i].id)] and self._taskData[tostring(self._tableData[i].id)].status == 1 then
                jumpTab = i
                break
            end
        end
    end

    -- 跳到最后一个标示“新” 优先级（2）
    if jumpTab == nil then
        for i = 1, #self._tableData do
            if self._tableData[i].id ~= "special" and SystemUtils["enable" .. self._tableData[i].system]() 
                and userlvl >= self._tableData[i].requiresLevel 
                and not self:hasChecked(self._tableData[i]) then
                jumpTab = i
            end
        end
    end

    if jumpTab == nil then
        local userlevelTab = tab:UserLevel(userlvl)
        local systemnotice = userlevelTab.systemnotice

        -- 开启功能预告为入口
        if systemnotice then
            for i = 1, #self._tableData do
                if self._tableData[i].sysDesId ~= nil and tonumber(self._tableData[i].sysDesId) == tonumber(systemnotice) then
                    jumpTab = i
                    break
                end
            end
        end

        if jumpTab == nil then
            -- 跳转到下一个未解锁功能
            for i = 1, #self._tableData do
                if self._tableData[i].id ~= "special" then
                    if not SystemUtils["enable" .. self._tableData[i].system] then
                        self._viewMgr:showTip("systemOpen或gameplayOpen表问题")
                    end
                    if not SystemUtils["enable" .. self._tableData[i].system]() or userlvl < self._tableData[i].requiresLevel then
                        jumpTab = i
                        break
                    end
                end
            end

            -- 没有未领奖，跳到下一个未完成
            if jumpTab == nil then
                for i = 1, #self._tableData do
                    if self._taskData[tostring(self._tableData[i].id)] and self._taskData[tostring(self._tableData[i].id)].status == 0 then
                        jumpTab = i
                        break
                    end
                end
            end

            -- 都已完成,跳到最后一个
            if jumpTab == nil then
                jumpTab = #self._tableData
            end
        end
    end

    if jumpTab == nil then
        jumpTab = #self._tableData
    end
    
    self:jumpToNeedPos(jumpTab, self._jumpTargetIndex)
end

function HandbookView:jumpToNeedPos(jumpTab, toPos, time)
    local offsetX = -self._tableCellWidth*(jumpTab - toPos)
    offsetX = math.max(self._tableView:minContainerOffset().x, offsetX)
    offsetX = math.min(self._tableView:maxContainerOffset().x, offsetX)

    if time ~= nil then
        self._tableView:setContentOffsetInDuration(cc.p(offsetX, 0), time)
    else
        self._tableView:setContentOffset(cc.p(offsetX, 0))
    end

    self._leftArrow:setVisible(offsetX < self._tableView:maxContainerOffset().x)
    self._rightArrow:setVisible(offsetX > self._tableView:minContainerOffset().x)

    local leftTp, rightTp = self:getTipType(offsetX)
    self:showLeftBubble(leftTp)
    self:showRightBubble(rightTp)

    self:reflashTab(jumpTab)
end

-- 切换任务页签
function HandbookView:reflashTab(index)
    if index == self._curIndex then return end
    local oldIndex = self._curIndex
    self._curIndex = index

    self._selectMc:removeFromParent()

    self:reflashHandbookInfo()

    if oldIndex ~= nil then
        self._tableView:updateCellAtIndex(oldIndex - 1)
    end
    self._tableView:updateCellAtIndex(index - 1)
end

-- 刷新当前任务信息
function HandbookView:reflashHandbookInfo()
    local curData = self._tableData[self._curIndex]

    self._openLvLabel:setString(curData.requiresLevel .. "级解锁:")
    self._nameLabel:setString(lang(curData.name))
    self._nameLabel:setPositionX(self._openLvLabel:getPositionX() + self._openLvLabel:getContentSize().width +10)
    self._desLabel:setString(lang(curData.description))
    self:reflashOutPut(curData.rewardsPreview)
    self:reflashTaskNode(curData.corrQuest)
    self:reflashAwardNode(curData.questRewards)
    
    self._desImg:loadTexture("asset/uiother/handbook/" .. curData.artThumbnail .. ".png")

    self._canGetAward = self:canGetAward(curData.id)



    local userLv = self._userModel:getPlayerLevel()
    local isOpen, isPassTime = SystemUtils["enable" .. curData.system]()
    if not isOpen or userLv < curData.requiresLevel then
        UIUtils:setGray(self._goBtn, true)
        UIUtils:setGray(self._getBtn, true)
--        self._getBtn:setTouchEnabled(false)
        self._getBtn.enabled = false

        if self:getIsStimeOpen(curData.system) then
            self._goBtn.state = 1
            if isPassTime then
                self._goBtn.desStr = lang("handBook_1")
            else
                self._goBtn.desStr = lang(curData.buttonTips)
            end
        else
            self._goBtn.state = 1
            self._goBtn.desStr = lang("handBook_1")
        end
    else
        UIUtils:setGray(self._goBtn, false)
        self:setChecked(curData.id)

        UIUtils:setGray(self._getBtn, self._canGetAward == 0)
--      self._getBtn:setTouchEnabled(self._canGetAward == 1)
        self._getBtn.enabled = self._canGetAward == 1
        self._goBtn.state = 0
        self._goBtn.desStr = nil
    end

--    -- 特定时间开启功能未开启时，需特殊提示
--    if not SystemUtils["enable" .. curData.system]() and userLv >= curData.requiresLevel then
--        self._goBtn.state = 2
--    end

    -- 嘉年华单独判断是否开启
    if curData.system == "sevenDayAim" then
        if userLv < curData.requiresLevel then
            UIUtils:setGray(self._goBtn, true)
            self._goBtn.state = 1
            self._goBtn.desStr = lang("handBook_1")

        elseif not self._modelMgr:getModel("ActivityCarnivalModel"):carnivalIsOpen() then
            UIUtils:setGray(self._goBtn, true)
            self._goBtn.state = 1
            self._goBtn.desStr = lang(curData.buttonTips)
        end
    end


    if curData.system == "GodWar" then
        local godWarModel = self._modelMgr:getModel("GodWarModel")
        local flag = godWarModel:getClickGodwarBtn()
        if flag == 1 then
            UIUtils:setGray(self._goBtn, true)

            local openTimeStr = godWarModel:getOpenTime()
            self._goBtn.state = 1
            self._goBtn.desStr = openTimeStr

        elseif flag == 2 then
            UIUtils:setGray(self._goBtn, true)
            self._goBtn.state = 1
            self._goBtn.desStr = godWarModel:getOpenTime1()

        elseif flag == 3 then
            UIUtils:setGray(self._goBtn, true)
            self._goBtn.state = 1
            self._goBtn.desStr = lang("ZHENGBASAI_HEFU_TIPS")
        end
    end

    if not self._nameLabel._lockTxt then
        local lockTxt = cc.Label:createWithTTF("(需要斯坦德威克活动结束)", UIUtils.ttfName_Title, 20)
        lockTxt:setColor(cc.c3b(181,0,3))
        --    lockTxt:enable2Color(1, cc.c4b(213, 184, 118, 255))
        -- lockTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        lockTxt:setAnchorPoint(0,0.5)
        self._nameLabel._lockTxt = lockTxt
        self:getUI("bg.layer"):addChild(lockTxt)
    end
    self._nameLabel._lockTxt:setVisible(false)
    self._nameLabel._lockTxt:setPosition(self._nameLabel:getPositionX()+self._nameLabel:getContentSize().width+5, self._nameLabel:getPositionY()-2)
    if curData.system == "Weapon" then
        if self._modelMgr:getModel("WeaponsModel"):getWeaponState() ~= 4 then
            self._nameLabel._lockTxt:setVisible(true)
            UIUtils:setGray(self._goBtn, true)
            self._goBtn.state = 1
            self._goBtn.desStr = lang("TIPS_SIEGE_LORDBOOK_OPEN_1")
        end
    end
    if curData.system == "DailySiege" then
        if not self._modelMgr:getModel("SiegeModel"):isSiegeDailyOpen() then
            self._nameLabel._lockTxt:setVisible(true)
            UIUtils:setGray(self._goBtn, true)
            self._goBtn.state = 1
            self._goBtn.desStr = lang(curData.buttonTips)
        end
    end

    if curData.system == "CrossPK" then
        local flag = self._modelMgr:getModel("CrossModel"):getOpenActionState()
        if flag == 0 or flag == 5 then
            UIUtils:setGray(self._goBtn, true)
            self._goBtn.state = 1
            self._goBtn.desStr = lang("TIP_CROSSPK3")

        elseif flag == 1 then
            UIUtils:setGray(self._goBtn, true)
            self._goBtn.state = 1
            self._goBtn.desStr = lang("TIP_CROSSPK2")

        elseif flag == 2 or flag == 3 then
            UIUtils:setGray(self._goBtn, true)
            self._goBtn.state = 1
            self._goBtn.desStr = lang("TIP_CROSSPK")

        elseif flag == 6 then
            UIUtils:setGray(self._goBtn, true)
            self._goBtn.state = 1
            self._goBtn.desStr = lang("cp_tips_clickicon")
        end
    end

    -- 宝物升星
    if curData.system == "TreasureStar" then 
        local sTimeData = tab.sTimeOpen[103]
        local isTimeOpen = self:isInOpenTime()
        if not isTimeOpen then
            self._goBtn.state = 1
            local des = lang(sTimeData.systemTimeOpenTip)
            des = string.gsub(des,"%b{}",function( catchStr )
                local str = catchStr
                str = str.gsub(str,"{","")  
                str = str.gsub(str,"}","")
                local _,_,nowDaySec = self:isInOpenTime() -- self._modelMgr:getModel("UserModel"):getOpenServerTime()
                -- local nowDaySec = self._modelMgr:getModel("UserModel"):getOpenServerTime()
                local openDay = math.ceil(nowDaySec/86400)
                print("nowDaySec",nowDaySec,nowDaySec/86400,openDay)
                openDay = sTimeData.opentime - openDay

                str = str.gsub(str,"$serveropen",openDay)  
                str = loadstring("return " .. str)
                local _,result = trycall("count",str) 
                return result or catchStr
            end)
            self._goBtn.desStr = des
        end
    end

    self._getBtn:setVisible(self._canGetAward ~= 2)
    self._getMC:setVisible(self._canGetAward == 1)
    self._gotIcon:setVisible(self._canGetAward == 2)
end

-- 宝物升星跳转判断专用
function HandbookView:isInOpenTime( )
    local tabId = 103
    local serverBeginTime = ModelManager:getInstance():getModel("UserModel"):getData().sec_open_time
    if serverBeginTime then
        local sec_time = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(serverBeginTime,"%Y-%m-%d 05:00:00"))
        if serverBeginTime < sec_time then   --过零点判断
            serverBeginTime = sec_time - 86400
        end
    end
    local serverHour = tonumber(TimeUtils.date("%H",serverBeginTime)) or 0
    local nowTime = ModelManager:getInstance():getModel("UserModel"):getCurServerTime()
    local openDay = tab:STimeOpen(tabId).opentime-1
    local openTimeNotice = tab:STimeOpen(tabId).openhour
    local openHour = string.format("%02d:00:00",openTimeNotice)
    local openTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(serverBeginTime + openDay*86400,"%Y-%m-%d " .. openHour))
    local leftTime = openTime - nowTime
    local isOpen = leftTime <= 0
    -- 显示页签时间
    local noticeTime = tab:STimeOpen(tabId).notice-1
    local showTabTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(serverBeginTime + noticeTime*86400,"%Y-%m-%d " .. openHour))
    local showLeftTime = showTabTime - nowTime
    local isPreDay = showLeftTime <= 0

    return isOpen,isPreDay,leftTime
end

-- 判断是否属于sTimeOpen表，有开始时间限制
function HandbookView:getIsStimeOpen(systemName)
    for k, v in pairs(tab.sTimeOpen) do
        if v.system == systemName then
            return true
        end
    end
    return false
end

-- 刷新产出图标
function HandbookView:reflashOutPut(data)
    if self._outputNode then
        self._outputNode:removeAllChildren(true)
    end
    if data then
        for i = 1, #data do
            local cData = data[i]
            local icon = nil
            local iconWidth = 47

            local itemType = cData[1]
            if itemType == "rune" then
                local stoneTab = tab:Rune(cData[2]) 
                nameStr = lang(stoneTab.name)
                local param = {suitData = stoneTab}
                icon = IconUtils:createHolyIconById(param)
                icon:setScaleAnim(true)
                icon:setAnchorPoint(0.5,0.5)
--                self:registerClickEvent(icon, function()
                    -- local param = {teamId = cData[2], selectStone = 1, key = 1,holyData = stoneTab, hintType = 1, callback = function()
                    -- end}
                    -- self._viewMgr:showHintView("team.TeamHolyTipView", param)
--                end)
                icon:setPosition(iconWidth * 0.5 + (i-1) * 48 - 12 , iconWidth * 0.5 )
            else
                if itemType == "tool" then
                    itemId = cData[2]            
                else
                    itemId = IconUtils.iconIdMap[itemType]
                end
                local toolD = tab:Tool(tonumber(itemId))
                icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD})
                icon:setPosition(iconWidth * 0.5 + (i-1) * 48 - 35, 0)
            end
            icon:setScale(iconWidth / icon:getContentSize().width)
            self._outputNode:addChild(icon)
        end
    end

    self:getUI("bg.layer.outputLabel"):setVisible(data ~= nil and #data > 0)
end

-- 刷新任务信息
function HandbookView:reflashTaskNode(data)
    self._taskNode:removeAllChildren(true)
    if data then
        local taskTab = tab.adventureQuest
        for i = 1, #data do
            local taskData = taskTab[data[i]]
            local rateData = self:getTargetData(data[i])
            local pointIcon = nil
            if rateData and rateData.status == 1 then
                pointIcon = cc.Sprite:createWithSpriteFrameName("iconPoint_handbook.png")
            else
                pointIcon = cc.Sprite:createWithSpriteFrameName("bgPoint_handbook.png")
            end
            pointIcon:setScale(0.9)
            pointIcon:setPosition(20, 162 + (3-i)*30)
            self._taskNode:addChild(pointIcon)

            local taskLabel = cc.Label:createWithTTF(lang(taskData.questCriteria), UIUtils.ttfName_Title, 20)
            taskLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
            taskLabel:setAnchorPoint(0, 0.5)
            taskLabel:setPosition(35, 162 + (3-i)*30)
            self._taskNode:addChild(taskLabel)

            local rateNum = 0
            if rateData then
                rateNum = tonumber(rateData.cnt)
            end

            local rateStr = nil
            local taskCount = tonumber(taskData.count)
            if taskCount > 9999 then
                if rateNum >= taskCount then
                    rateStr = taskCount / 10000 .."万"
                elseif rateNum > 9999 then
                    rateStr = string.format("%.1f", math.round(rateNum/10) / 1000) .. "万"
                end

                taskCount = taskCount / 10000 .."万"
            end

            rateStr = rateStr or tostring(rateNum)
            local rateLabel = cc.Label:createWithTTF(rateStr .. "/" .. taskCount, UIUtils.ttfName_Title, 20)

            if tonumber(rateNum) >= tonumber(taskData.count) then
                rateLabel:setColor(UIUtils.colorTable.ccUIBaseColor2)
                rateLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            else
                rateLabel:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
            end
            rateLabel:setAnchorPoint(1, 0.5)
            rateLabel:setPosition(334, 162 + (3-i)*30)
            self._taskNode:addChild(rateLabel)
        end
    end
end

-- 刷新奖励信息
function HandbookView:reflashAwardNode(data)
    if self._awardNode then
        self._awardNode:removeAllChildren(true)
    end
    if data then
        local len = #data
        local startX = (3-len)*45 + 3
        for i = 1, len do
            local cData = data[i]
            local icon = nil
            local iconWidth = 81

            local itemType = cData[1]
            if itemType == "tool" then
                itemId = cData[2]
            else 
                itemId = IconUtils.iconIdMap[itemType]
            end

            local toolD = tab:Tool(tonumber(itemId))
            local icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD, num = cData[3]})
            icon:setScale(iconWidth / icon:getContentSize().width)
            icon:setPosition((i-1) * 91 + startX, 0)
            self._awardNode:addChild(icon)
        end
    end
end

function HandbookView:addTableView()
    local tableView = cc.TableView:create(cc.size(self._taskView:getContentSize().width, self._taskView:getContentSize().height))
    tableView:setColor(cc.c3b(255,255,255))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    tableView:setPosition(cc.p(0,0))
    tableView:setDelegate()
--    tableView:setHorizontalFillOrder(cc.TABLEVIEW_FILL_RIGHTLEFT)
    -- tableView:setBounceEnabled(false)
    self._taskView:addChild(tableView)
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
    return tableView
end

function HandbookView:scrollViewDidScroll(view)
    self._inScrolling = view:isDragging()
    
    self._offsetX = view:getContentOffset().x
--    self._offsetY = view:getContentOffset().y

--    if not self._inScrolling then
--        view:stopScroll()

--        if self._offsetX > self._tableView:minContainerOffset().x  
--            and self._offsetX < self._tableView:maxContainerOffset().x
--            and not self._inScrolling
--        then
--            local needMoveDistance = (self._offsetX - view:minContainerOffset().x) % self._tableCellWidth
--            if needMoveDistance <= self._tableCellWidth * 0.5 then
--                view:setContentOffsetInDuration(cc.p(self._offsetX - needMoveDistance, 0), 0.3)

--            else
--                view:setContentOffsetInDuration(cc.p(self._offsetX + (self._tableCellWidth- needMoveDistance), 0), 0.3)
--            end
--        end
--    end
    


    self._leftArrow:setVisible(self._offsetX < self._tableView:maxContainerOffset().x)
    self._rightArrow:setVisible(self._offsetX > self._tableView:minContainerOffset().x)

    local leftTp, rightTp = self:getTipType(self._offsetX)
    self:showLeftBubble(leftTp)
    self:showRightBubble(rightTp)
end

function HandbookView:scrollViewDidZoom(view)
end

function HandbookView:tableCellTouched(table,cell)
    

end

function HandbookView:cellSizeForTable(table,idx) 
    return self._tableCellHeight, self._tableCellWidth
end

function HandbookView:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if not cell then 
        cell = cc.TableViewCell:new()  
    else
        cell:removeAllChildren()
    end
    local data = self._tableData[idx+1]
    local isSpecial = self._specialIndex and idx+1 < self._specialIndex + 2 and  idx+1 >= self._specialIndex
    local item = self:createItem(data, idx,isSpecial,cell)
    item:setPosition(item:getContentSize().width*0.5,item:getContentSize().height*0.5)
    cell:addChild(item)
    cell.item = item
    if self._specialIndex and idx+1 == self._specialIndex then
        cell:setZOrder(1)
    else
        cell:setZOrder(2)
    end
    return cell

    -- local data = self._tableData[idx+1]    
    -- local isSpecial = self._specialIndex and idx+1 < self._specialIndex + 2 and  idx+1 >= self._specialIndex
    -- if nil == cell then
    --     cell = cc.TableViewCell:new()        
    --     local item = self:createItem(data, idx,isSpecial)
    --     item:setPosition(item:getContentSize().width*0.5,item:getContentSize().height*0.5)
    --     cell:addChild(item)
    --     cell.item = item
    -- else
    --     self:updateItem(cell.item, data, idx,isSpecial)
    -- end
    -- return cell
end

function HandbookView:numberOfCellsInTableView(table)
    -- print("table num...",#self._tableData)
    return #self._tableData
end

function HandbookView:createItem(data, idx, isSpecial,cell)
    if isSpecial then
        local item = self:createSpecialItem(idx,cell)
        return item
    end
    local index = idx + 1
    local item = ccui.Layout:create()
    --    item:setBackGroundColorOpacity(200)
    --    item:setBackGroundColorType(1)
    --    item:setBackGroundColor(cc.c3b(255, 255, 255))
    item:setContentSize(103, 150)
    item:setTouchEnabled(true)
    item:setSwallowTouches(false)
    item:setAnchorPoint(cc.p(0.5,0.5))
    item:setScaleAnim(true)

    local isLock = false
    -- 多于五个未开启，统一显示锁
    if index == self._maxPreviewIndex and self._maxPreviewIndex < self._gamePlayOpenLen then
        isLock = true
    end

    local bg = nil
    if index == self._curIndex then
        bg = cc.Sprite:createWithSpriteFrameName("bgBoxSelect_handbook.png")
    else
        bg = cc.Sprite:createWithSpriteFrameName("bgBoxNormal_handbook.png")
    end
    bg:setPosition(51, 52)
    bg:setVisible(not isLock)
    item.bg = bg
    item:addChild(bg)

    local funcIcon = cc.Sprite:createWithSpriteFrameName(data.art .. ".png")
    funcIcon:setScale(0.87)
    funcIcon:setPosition(51, 75)
    funcIcon:setVisible(not isLock)
    item.funcIcon = funcIcon
    item:addChild(funcIcon)

    local cover = nil
    if index == self._curIndex then
        cover = cc.Sprite:createWithSpriteFrameName("maskBoxSelect_handbook.png")
    else
        cover = cc.Sprite:createWithSpriteFrameName("maskBoxNormal_handbook.png")
    end
    cover:setPosition(51, 78)
    cover:setVisible(not isLock)
    item.cover = cover
    item:addChild(cover)

    local aniNode = cc.Node:create()
    aniNode:setPosition(51, 12)
    item.aniNode = aniNode
    item:addChild(aniNode)

    local lockIcon = cc.Sprite:createWithSpriteFrameName("iconLock_handbook.png")
    lockIcon:setPosition(51, 66)
    lockIcon:setVisible(isLock)
    item.lockIcon = lockIcon
    item:addChild(lockIcon) 

    if index == self._curIndex then
        if self._selectMc:getParent() == nil then
            item.aniNode:addChild(self._selectMc)
        else
            --切换时有时多刷新一次  临时解决方案
            self._selectMc:removeFromParent()
            item.aniNode:addChild(self._selectMc)
        end
    end

    local lvLabel = cc.Label:createWithTTF(data.requiresLevel .. "级", UIUtils.ttfName_Title, 20)
    lvLabel:setColor(cc.c3b(251,240,186))
    lvLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    lvLabel:setPosition(51, 48)
    item.lvLabel = lvLabel
    item:addChild(lvLabel)

    local nameBg = cc.Sprite:createWithSpriteFrameName("bgName_handbook.png")
    nameBg:setPosition(51, 16)
    item:addChild(nameBg)

    local nameLabel = cc.Label:createWithTTF(lang(data.tabName), UIUtils.ttfName_Title, 18)
    nameLabel:setColor(cc.c3b(251,240,186))
    --    nameLabel:enable2Color(1, cc.c4b(213, 184, 118, 255))
    nameLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    nameLabel:setPosition(51, 16)
    item.nameLabel = nameLabel
    item:addChild(nameLabel)

    local completeIcon = cc.Sprite:createWithSpriteFrameName("iconFinish_handbook.png")
    completeIcon:setPosition(51, 75)
    completeIcon:setVisible(self._taskData[tostring(data.id)] and self._taskData[tostring(data.id)].status == 2)
    item.completeIcon = completeIcon
    item:addChild(completeIcon)



    local redPoint = cc.Sprite:createWithSpriteFrameName("globalImageUI_bag_keyihecheng.png")
    redPoint:setPosition(87, 110)
    item.redPoint = redPoint
    item:addChild(redPoint)

    local newIcon = cc.Sprite:createWithSpriteFrameName("imgNew_handbook.png")
    newIcon:setPosition(77, 110)
    item.newIcon = newIcon
    item:addChild(newIcon)

    item.index = index

    self:addClickTouchEvent(item, function()
        if not item.lockIcon:isVisible() then
            self:reflashTab(item.index)
        else
            self._viewMgr:showTip(lang("handBook_3"))
        end
    end)

    if not SystemUtils["enable" .. data.system] then
        self._viewMgr:showTip("systemOpen或gameplayOpen表问题")
    end
    local userLv = self._userModel:getPlayerLevel()
    if userLv < data.requiresLevel then
        UIUtils:setGray(bg, true)
        UIUtils:setGray(funcIcon, true)
        UIUtils:setGray(cover, true)

        redPoint:setVisible(false)
        newIcon:setVisible(false)

    else
        -- 有未领奖优先显示红点
        if self._taskData[tostring(data.id)] and self._taskData[tostring(data.id)].status == 1 then
            redPoint:setVisible(true)
        else
            redPoint:setVisible(false)
        end

        -- 没有红点，未查看过，最新开启的功能显示“新”
        if not self:hasChecked(data) and not redPoint:isVisible() then
            newIcon:setVisible(true)
        else
            newIcon:setVisible(false)
        end
    end

    return item
end
function HandbookView:createSpecialItem(idx,cell)
    local item = ccui.Layout:create()
    --    item:setBackGroundColorOpacity(200)
    --    item:setBackGroundColorType(1)
    --    item:setBackGroundColor(cc.c3b(255, 255, 255))
    item:setContentSize(103, 150)
    item:setTouchEnabled(true)
    item:setSwallowTouches(false)
    item:setAnchorPoint(cc.p(0.5,0.5))
    item:setScaleAnim(true)
    local getImage
    if idx+1 == self._specialIndex then 
        -- 特殊底板
        local specialBox = ccui.ImageView:create()
        specialBox:loadTexture("specialBox_handBook.png",1)
        specialBox:setContentSize(self._tableCellWidth*(self._specialNum+2),75)
        specialBox:setScale9Enabled(true)
        specialBox:setCapInsets(cc.rect(62,30,1,1))
        specialBox:setAnchorPoint(cc.p(0,0))
        specialBox:setPosition(-15, 0)
        cell:addChild(specialBox,-2)

        -- 特殊连线
        local specialLine = ccui.ImageView:create()
        specialLine:loadTexture("specialLine1_handBook.png",1)
        specialLine:setPosition(item:getContentSize().width*0.5,50)
        specialLine:setContentSize(self._tableCellWidth*(self._specialNum+1),9)
        specialLine:setScale9Enabled(true)
        specialLine:setCapInsets(cc.rect(9,4,1,1))
        specialLine:setAnchorPoint(cc.p(0,0.5))
        cell:addChild(specialLine,-1)
        if self._modelMgr:getModel("WeaponsModel"):getWeaponState() == 4 then
            specialLine:loadTexture("specialLine2_handBook.png",1)        
        end

        getImage = ccui.ImageView:create()
        getImage:loadTexture("world_siege_handBook.png",1)
        getImage:setPosition(item:getContentSize().width*0.5,item:getContentSize().height*0.5-8)
        item:addChild(getImage)
        local nameLabel = cc.Label:createWithTTF(lang("SIEGE_EVENT_HANDBOOK_NAME_1"), UIUtils.ttfName_Title, 18)
        nameLabel:setColor(cc.c3b(251,240,186))
        --    nameLabel:enable2Color(1, cc.c4b(213, 184, 118, 255))
        nameLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        nameLabel:setPosition(50, 16)
        item:addChild(nameLabel)
        self:addClickTouchEvent(item, function()
            self._viewMgr:showDialog("global.GlobalRuleDescView",{desc = lang("SIEGE_EVENT_HANDBOOK_TEXT_1")},true)
        end)
    else
        getImage = ccui.ImageView:create()
        getImage:loadTexture("i_101.png",1)
        getImage:setPosition(item:getContentSize().width*0.5-5,item:getContentSize().height*0.5-8)
        item:addChild(getImage)
        local nameLabel = cc.Label:createWithTTF(lang("SIEGE_EVENT_HANDBOOK_NAME_2"), UIUtils.ttfName_Title, 18)
        nameLabel:setColor(cc.c3b(251,240,186))
        --    nameLabel:enable2Color(1, cc.c4b(213, 184, 118, 255))
        nameLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        nameLabel:setPosition(56, 16)
        item:addChild(nameLabel)
        self:addClickTouchEvent(item, function()
            self._viewMgr:showDialog("global.GlobalRuleDescView",{desc = lang("SIEGE_EVENT_HANDBOOK_TEXT_2")},true)
        end)
    end
    if self._modelMgr:getModel("WeaponsModel"):getWeaponState() ~= 4 then
        UIUtils:setGray(getImage, true)
    end
    return item
end
--[[
function HandbookView:updateItem(item, data, idx)

    local index = idx + 1
    local isLock = false
    -- 多于五个未开启，统一显示锁
    if index == self._maxPreviewIndex and self._maxPreviewIndex < self._gamePlayOpenLen then
        isLock = true
    end

    if index == self._curIndex then
        item.bg:setSpriteFrame("bgBoxSelect_handbook.png")
        item.cover:setSpriteFrame("maskBoxSelect_handbook.png")

        if self._selectMc:getParent() == nil then
            item.aniNode:addChild(self._selectMc)
        else
            --切换时有时多刷新一次  临时解决方案
            self._selectMc:removeFromParent()
            item.aniNode:addChild(self._selectMc)
        end
    else
        item.bg:setSpriteFrame("bgBoxNormal_handbook.png")
        item.cover:setSpriteFrame("maskBoxNormal_handbook.png")
        item.aniNode:removeAllChildren()
    end

    item.bg:setVisible(not isLock)
    item.cover:setVisible(not isLock)
    item.funcIcon:setVisible(not isLock)
    item.lockIcon:setVisible(isLock)

    item.funcIcon:setSpriteFrame(data.art .. ".png")
    item.lvLabel:setString(data.requiresLevel .. "级")
    item.nameLabel:setString(lang(data.tabName))
    item.index = index

    if not SystemUtils["enable" .. data.system] then
        self._viewMgr:showTip("systemOpen或gameplayOpen表问题")
    end
    local userLv = self._userModel:getPlayerLevel()
    if userLv < data.requiresLevel then
        UIUtils:setGray(item.bg, true)
        UIUtils:setGray(item.funcIcon, true)
        UIUtils:setGray(item.cover, true)

        item.redPoint:setVisible(false)
        item.newIcon:setVisible(false)
        item.completeIcon:setVisible(false)
    else
        UIUtils:setGray(item.bg, false)
        UIUtils:setGray(item.funcIcon, false)
        UIUtils:setGray(item.cover, false)

        if self._taskData[tostring(data.id)] and self._taskData[tostring(data.id)].status == 1 then
            item.redPoint:setVisible(true)
        else
            item.redPoint:setVisible(false)
        end

        if not self:hasChecked(data) and not item.redPoint:isVisible() then
            item.newIcon:setVisible(true)
        else
            item.newIcon:setVisible(false)
        end

        item.completeIcon:setVisible(self._taskData[tostring(data.id)] and self._taskData[tostring(data.id)].status == 2)
    end
end
]]
-- 显示左边气泡
function HandbookView:showLeftBubble(tp)
    if self._leftBubble == nil then
        self._leftBubble = ccui.ImageView:create()
        self._leftBubble:loadTexture("globalImageUI_qipao2.png", 1)
        self._leftBubble:setScale9Enabled(true)
        self._leftBubble:setAnchorPoint(0.5, 0)
        self._leftBubble:setCapInsets(cc.rect(35, 23, 1, 1))
        self._leftBubble:setFlippedX(true)
        self._leftBubble:setContentSize(65, 60)
        self._leftBubble:setPosition(self._leftPaoPosX, self._leftPaoPosY)
        self._leftBubble:setScale(0)
        self._taskView:addChild(self._leftBubble)

        self:registerClickEvent(self._leftBubble, function()
            self:jumpToTipCell("left", self._leftBubble.tp)
        end)

        local boxImg = cc.Sprite:createWithSpriteFrameName("box_3_n.png")
        boxImg:setScale(0.7)
        boxImg:setPosition(32, 37)
        boxImg:setFlippedX(true)
        boxImg:setName("box")
        self._leftBubble:addChild(boxImg)
    end
    
    if tp ~= nil then
        local boxImg = self._leftBubble:getChildByName("box")
        if tp == "reward" then
            boxImg:setSpriteFrame("box_3_n.png")
            boxImg:setScale(0.7)
            self._leftBubble.tp = "reward"
        elseif tp == "new" then
            boxImg:setSpriteFrame("imgNew_handbook.png")
            boxImg:setScale(1)
            self._leftBubble.tp = "new"
        end
        if self._leftBubble:getNumberOfRunningActions() == 0 then
            self._leftBubble:runAction(cc.Sequence:create(
                cc.ScaleTo:create(0.2, 1),
                cc.CallFunc:create(function()
                    self._leftBubble:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.EaseOut:create(cc.MoveTo:create(0.6, cc.p(self._leftPaoPosX,self._leftPaoPosY+10)), 1), 
                        cc.EaseOut:create(cc.MoveTo:create(0.6, cc.p(self._leftPaoPosX,self._leftPaoPosY)), 1)
                    )))
                end)
            ))
        end
    else
        self._leftBubble:stopAllActions()
        self._leftBubble:setScale(0)
    end
end

-- 显示右边气泡
function HandbookView:showRightBubble(tp)
    if self._rightBubble == nil then
        self._rightBubble = ccui.ImageView:create()
        self._rightBubble:loadTexture("globalImageUI_qipao2.png", 1)
        self._rightBubble:setScale9Enabled(true)
        self._rightBubble:setAnchorPoint(0.5, 0)
        self._rightBubble:setCapInsets(cc.rect(35, 23, 1, 1))
        self._rightBubble:setContentSize(65, 60)
        self._rightBubble:setPosition(self._rightPaoPosX, self._rightPaoPosY)
        self._rightBubble:setScale(0)
        self._taskView:addChild(self._rightBubble)

        self:registerClickEvent(self._rightBubble, function()
            self:jumpToTipCell("right", self._rightBubble.tp)
        end)

        local boxImg = cc.Sprite:createWithSpriteFrameName("box_3_n.png")
        boxImg:setScale(0.7)
        boxImg:setPosition(32, 37)
        boxImg:setName("box")
        self._rightBubble:addChild(boxImg)
    end

    if tp ~= nil then
        local boxImg = self._rightBubble:getChildByName("box")
        if tp == "reward" then
            boxImg:setSpriteFrame("box_3_n.png")
            boxImg:setScale(0.7)
            self._rightBubble.tp = "reward"
        elseif tp == "new" then
            boxImg:setSpriteFrame("imgNew_handbook.png")
            boxImg:setScale(1)
            self._rightBubble.tp = "new"
        end
        if self._rightBubble:getNumberOfRunningActions() == 0 then
            self._rightBubble:runAction(cc.Sequence:create(
                cc.ScaleTo:create(0.2, 1),
                cc.CallFunc:create(function()
                    self._rightBubble:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.EaseOut:create(cc.MoveTo:create(0.6, cc.p(self._rightPaoPosX,self._rightPaoPosY+10)), 1), 
                        cc.EaseOut:create(cc.MoveTo:create(0.6, cc.p(self._rightPaoPosX,self._rightPaoPosY)), 1)
                    )))
                end)
            ))
        end
    else
        self._rightBubble:stopAllActions()
        self._rightBubble:setScale(0)
    end
end

-- 获取气泡提示类型
function HandbookView:getTipType(offsetX)
    local maxOffsetX = self._tableView:maxContainerOffset().x
    local minOffsetX = self._tableView:minContainerOffset().x

    local minId = math.floor((maxOffsetX - offsetX)/self._tableCellWidth)
    local maxId = #self._tableData + 1 - math.floor((offsetX - minOffsetX)/self._tableCellWidth)
    local leftTp = nil
    local rightTp = nil

    if minId > 0 and minId <= #self._tableData then
        for i = 1, minId do
            local data = self._tableData[i]
            local userLv = self._userModel:getPlayerLevel()
            if data.id ~= "special" and SystemUtils["enable" .. data.system]() and userLv >= data.requiresLevel then
                if self._taskData[tostring(data.id)] and self._taskData[tostring(data.id)].status == 1 then
                    leftTp = "reward"
                    break
                elseif not self:hasChecked(data) then
                    leftTp = "new"
                end
            end
        end
    end

    if maxId > 0 and maxId < #self._tableData then
        for i = maxId, #self._tableData do
            local data = self._tableData[i]
            local userLv = self._userModel:getPlayerLevel()
--            print(data.requiresLevel)
            if data.id ~= "special" and SystemUtils["enable" .. data.system]() and userLv >= data.requiresLevel then
                if self._taskData[tostring(data.id)] and self._taskData[tostring(data.id)].status == 1 then
                    rightTp = "reward"
                    break
                elseif not self:hasChecked(data) then
                    rightTp = "new"
                end
            end
        end
    end
    return leftTp, rightTp
end

-- 跳转到气泡提示的功能
function HandbookView:jumpToTipCell(direction, tipTp)
    local offsetX = self._tableView:getContentOffset().x
    if direction == "left" then
        local maxOffsetX = self._tableView:maxContainerOffset().x
        local minId = math.floor((maxOffsetX - offsetX)/self._tableCellWidth)
        local jumpId = 1
        for i = minId, 1, -1 do
            local data = self._tableData[i]
            local userLv = self._userModel:getPlayerLevel()
            if data.id ~= "special" and SystemUtils["enable" .. data.system]() and userLv >= data.requiresLevel then
                if tipTp == "reward" and self._taskData[tostring(data.id)] and self._taskData[tostring(data.id)].status == 1 then
                    jumpId = i
                    break
                elseif tipTp == "new" and not self:hasChecked(data) then
                    jumpId = i
                    break
                end
            end
        end
        self:jumpToNeedPos(jumpId, self._jumpTargetIndex, 0.3)
    elseif direction == "right" then

        local minOffsetX = self._tableView:minContainerOffset().x
        local maxId = #self._tableData + 1 - math.floor((offsetX - minOffsetX)/self._tableCellWidth)

        local jumpId = 1
        for i = maxId, #self._tableData do
            local data = self._tableData[i]
            local userLv = self._userModel:getPlayerLevel()
            if data.id ~= "special" and SystemUtils["enable" .. data.system]() and userLv >= data.requiresLevel then
                if tipTp == "reward" and self._taskData[tostring(data.id)] and self._taskData[tostring(data.id)].status == 1 then
                    jumpId = i
                    break
                elseif tipTp == "new" and not self:hasChecked(data) then
                    jumpId = i
                    break
                end
            end
        end
        self:jumpToNeedPos(jumpId, self._jumpTargetIndex, 0.3)
    end
end

-- 判断是否可以领取奖励
function HandbookView:canGetAward(gId)
    if self._taskData and self._taskData[tostring(gId)] then
        return self._taskData[tostring(gId)].status or 0
    else
        return 0
    end
end

-- 领取奖励
function HandbookView:onGetAward(result)
    if result.awards ~= nil then
        DialogUtils.showGiftGet(result.awards)
    end

    self._getBtn:setVisible(false)
    self._getMC:setVisible(false)
    self._gotIcon:setVisible(true)
    
    self._taskData = self._hModel:getData()
    self._tableView:updateCellAtIndex(self._curIndex - 1)
end

-- 判断子任务是否完成
function HandbookView:getTargetData(tId)
    tId = tostring(tId)
    for k, v in pairs(self._taskData) do
        if v.tasks then
            if v.tasks[tId] then
                return v.tasks[tId]
            end
        end
    end
    return nil
end

-- 保存已浏览状态
function HandbookView:setChecked(id)
    id = tostring(id)
    self._hModel:setCheckData(id)
end

-- 判断是否浏览过
function HandbookView:hasChecked(data)
    id = tostring(data.id)
    for i = 1, #self._checkData do
        if self._checkData[i] == id then
            return true
        end
    end

    if data.requiresLevel < self._newOpenLv then
        return true
    else
        return false
    end
end

function HandbookView:formatLabel(label, color, str, fontName, color2, outline)
    if color then
        label:setColor(color)
    end

    if str then
        label:setString(str)
    end

    if fontName then
        label:setFontName(fontName)
    end

    if color2 then
        label:enable2Color(1, color2)
    end

    if outline then
        label:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, outline)
    end
end

function HandbookView:addClickTouchEvent(inview, callBack)
    local startX = 0
    local startY = 0
    local touchMove = false
    self:registerTouchEvent(inview,function(sender, x, y)
        startX = x
    end,
    function(sender, x, y)
        if x - startX > 10 or x - startX < -10 then
            touchMove = true
        end
    end,
    function( )
        if not touchMove then
            self:runAction(cc.Sequence:create(
                cc.DelayTime:create(0.1),
                cc.CallFunc:create(function()
                    callBack()
                end)
            ))
        end
        touchMove = false
    end,
    function()
        touchMove = false
    end)
end

function HandbookView:goView1() self._viewMgr:showView("intance.IntanceView", {superiorType = 2}) end
function HandbookView:goView2() self._viewMgr:showView("vip.VipView", {viewType = 0}) end
function HandbookView:goView3()
    if not SystemUtils:enableElite() then
        self._viewMgr:showTip(lang("TIP_JINGYING_1"))
        return 
    end
    self._viewMgr:showView("intance.IntanceEliteView", {superiorType = 2}) 
end
function HandbookView:goView4() 
    if not SystemUtils:enableDwarvenTreasury() then
        self._viewMgr:showTip(lang("TIP_DwarvenTreasury"))
        return 
    end
    self._viewMgr:showView("pve.AiRenMuWuView") 
end
function HandbookView:goView5() 
    if not SystemUtils:enableCrypt() then
        self._viewMgr:showTip(lang("TIP_Crypt"))
        return 
    end
    self._viewMgr:showView("pve.ZombieView") 
end
function HandbookView:goView6() 
    if not SystemUtils:enableBoss() then
        self._viewMgr:showTip(lang("TIP_Boss"))
        return 
    end
    self._viewMgr:showView("pve.DragonView") 
end
function HandbookView:goView7() self._viewMgr:showView("team.TeamListView") end
function HandbookView:goView8() self._viewMgr:showView("flashcard.FlashCardView") end
function HandbookView:goView9() 
    if not SystemUtils:enableArena() then
        self._viewMgr:showTip(lang("TIP_Arena"))
        return 
    end
    self._viewMgr:showView("arena.ArenaView") 
end
function HandbookView:goView10() 
    if not SystemUtils:enableCrusade() then
        self._viewMgr:showTip(lang("TIP_Crusade"))
        return 
    end
    self._viewMgr:showView("crusade.CrusadeView") 
end
function HandbookView:goView11() DialogUtils.showBuyRes({goalType = "gold", callback = function(success)
    if success then self._tableViews[self._viewType]:setContentOffset(self._tableViews[self._viewType]:minContainerOffset()) end
end}) end
function HandbookView:goView12() DialogUtils.showBuyRes({goalType = "physcal", callback = function(success)
    if success then self._tableViews[self._viewType]:setContentOffset(self._tableViews[self._viewType]:minContainerOffset()) end
end}) end
function HandbookView:goView13() DialogUtils.showBuyRes({goalType = "gem", callback = function(success)
    if success then self._tableViews[self._viewType]:setContentOffset(self._tableViews[self._viewType]:minContainerOffset()) end
end}) end
function HandbookView:goView14() 
    if not SystemUtils:enablesign() then
        self._viewMgr:showTip(lang("TIP_sign"))
        return 
    end
    self._viewMgr:showDialog("activity.ActivitySignInView",self._redData) 
end
function HandbookView:goView15() 
    if self._modelMgr:getModel("ActivityCarnivalModel"):carnivalIsOpen() then
        self._viewMgr:showDialog("activity.ActivityCarnival", self._redData, true)
    else
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
    end
end
function HandbookView:goView16() 
    if not SystemUtils:enablePrivilege() then
        self._viewMgr:showTip(lang("TIP_Privilege"))
        return 
    end
    self._viewMgr:showView("privileges.PrivilegesView") 
end
function HandbookView:goView17() 
    if not SystemUtils:enableFormation() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    self._viewMgr:showView("formation.NewFormationView") 
end
function HandbookView:goView18() 
    if not SystemUtils:enableTask() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    self._viewMgr:showView("task.TaskView",{viewType = 2})
end
function HandbookView:goView19() 
    if not SystemUtils:enablePvp() then
        self._viewMgr:showTip(lang("TIP_Pvp"))
        return 
    end
    self._viewMgr:showView("pvp.PvpInView")
end
function HandbookView:goView20() 
    if not SystemUtils:enableHero() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end

    self._viewMgr:showView("hero.HeroView")
end
function HandbookView:goView21() 
    if not SystemUtils:enablePve() then
        self._viewMgr:showTip(lang("TIP_Pve"))
        return 
    end

    self._viewMgr:showView("pve.PveView")
end

function HandbookView:goView22() 
    if not SystemUtils:enableGuild() then
        self._viewMgr:showTip(lang("TIP_Guild"))
        return 
    end
    local userData = self._userModel:getData()
    if not userData.guildId or userData.guildId == 0 then
        self._viewMgr:showView("guild.join.GuildInView")
    else
        self._viewMgr:showView("guild.GuildView")
    end
end

function HandbookView:goView24() 
    if not SystemUtils:enableMysteryShop() then
        self._viewMgr:showTip(lang("TIP_MysteryShop"))
        return 
    end

    self._viewMgr:showView("shop.ShopView", {idx = 1})
end

function HandbookView:goView25()
    if not SystemUtils:enablePokedex() then
        self._viewMgr:showTip(lang("TIP_Pokedex"))
        return 
    end

    self._viewMgr:showView("pokedex.PokedexView")
end

function HandbookView:goView26() 
    if not SystemUtils:enableTreasure() then
        self._viewMgr:showTip(lang("TIP_Treasure"))
        return 
    end

    self._viewMgr:showView("treasure.TreasureView")
end
function HandbookView:goView27() 
    if not SystemUtils:enableTalent() then
        self._viewMgr:showTip(lang("TIP_Talent"))
        return 
    end

    self._viewMgr:showView("talent.TalentView", {openTab = 1})
end
function HandbookView:goView28() 
    if not SystemUtils:enableTraining() then
        self._viewMgr:showTip(lang("TIP_Training"))
        return 
    end

    self._viewMgr:showView("training.TrainingView")
end
function HandbookView:goView31() 
    if not SystemUtils:enableTeamSkill() then
        self._viewMgr:showTip(lang("Tip_TeamSkill"))
        return 
    end
    self._viewMgr:showView("team.TeamView",{team = self._modelMgr:getModel("TeamModel"):getData()[1],index = 4})
end
--function HandbookView:goView32() 
--    if not SystemUtils:enableTeamBoost() then
--        self._viewMgr:showTip(lang("TIP_TeamBoost"))
--        return 
--    end

--    self._viewMgr:showView("teamboost.TeamBoostView")
--end

function HandbookView:goView33() 
    if not SystemUtils:enableMF() then
        self._viewMgr:showTip(lang("TIP_MF"))
        return 
    end

    self._viewMgr:showView("MF.MFView")
end
function HandbookView:goView34() 
    if not SystemUtils:enableNests() then
        self._viewMgr:showTip(lang("Tip_Nests"))
        return 
    end
    self._viewMgr:showView("nests.NestsView")
end
function HandbookView:goView35()
    if not SystemUtils:enableCloudCity() then
        self._viewMgr:showTip(lang("TIP_TOWER"))
        return 
    end

    self._viewMgr:showView("cloudcity.CloudCityView")
end
function HandbookView:goView37() 
    if not SystemUtils:enableTalent() then
        self._viewMgr:showTip(lang("Tip_Talent"))
        return 
    end

    self._viewMgr:showView("talent.TalentView", {openTab = 2})
end
function HandbookView:goView38() 
    if not SystemUtils:enableTalent() then
        self._viewMgr:showTip(lang("Tip_Talent"))
        return 
    end

    self._viewMgr:showView("talent.TalentView", {openTab = 3})
end
function HandbookView:goView39() 
    if not SystemUtils:enableTalent() then
        self._viewMgr:showTip(lang("Tip_Talent"))
        return 
    end

    self._viewMgr:showView("talent.TalentView", {openTab = 4})
end
function HandbookView:goView40() 
    if not SystemUtils:enableTalent() then
        self._viewMgr:showTip(lang("Tip_Talent"))
        return 
    end

    self._viewMgr:showView("talent.TalentView", {openTab = 5})
end
function HandbookView:goView41() 
    if not SystemUtils:enableGodWar() then
        self._viewMgr:showTip(lang("TIP_GODWAR"))
        return 
    end

    self._viewMgr:showView("godwar.GodWarView")
end
function HandbookView:goView42() 
    if not SystemUtils:enableCityBattle() then
        self._viewMgr:showTip(lang("TIP_CITYBATTLE"))
        return 
    end
    local status,des = self._modelMgr:getModel("CityBattleModel"):checkIsGvgOpen()
    if not status  then
        self._viewMgr:showTip(des)
        return
    end
    self._viewMgr:showView("citybattle.CityBattleView")
end

function HandbookView:goView43() 
    if not SystemUtils:enableElement() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    self._viewMgr:showView("elemental.ElementalView")
end

function HandbookView:goView44() 
    if self._modelMgr:getModel("WeaponsModel"):getWeaponState() ~= 4 then
        self._viewMgr:showTip(lang("TIPS_SIEGE_LORDBOOK_OPEN_1"))
        return 
    end
    self._viewMgr:showView("weapons.WeaponsView", {})
end

function HandbookView:goView45() 
    if not self._modelMgr:getModel("SiegeModel"):isSiegeDailyOpen() then
        self._viewMgr:showTip(lang("TIPS_SIEGE_LORDBOOK_OPEN_2"))
        return 
    end
    -- self._viewMgr:showView("siegeDaily.SiegeDailyView",{utype = 1})
    self._viewMgr:showDialog("siegeDaily.SiegeDailySelectView") 
end

function HandbookView:goView46() 
    if not self._modelMgr:getModel("SiegeModel"):isSiegeDailyOpen() then
        self._viewMgr:showTip(lang("TIPS_SIEGE_LORDBOOK_OPEN_3"))
        return 
    end
    -- self._viewMgr:showView("siegeDaily.SiegeDailyView",{utype = 2}) 
    self._viewMgr:showDialog("siegeDaily.SiegeDailySelectView")
end

function HandbookView:goView48() 
    if not self._modelMgr:getModel("CrossModel"):getOpenActionState() then
        self._viewMgr:showTip(lang("TIPS_SIEGE_LORDBOOK_OPEN_3"))
        return 
    end
    self._viewMgr:showView("cross.CrossMainView")
end

-- 无尽炼狱跳转
function HandbookView:goView49() 
    local purModel = self._modelMgr:getModel("PurgatoryModel")
    purModel:showPurgatoryView()
end

-- 圣辉跳转
function HandbookView:goView50() 
    if not SystemUtils:enableHoly() then
        self._viewMgr:showTip(lang("TIP_Runes"))
        return 
    end
    self._viewMgr:showView("team.TeamHolyView", {})
end

-- 后援
function HandbookView:goView52() 
    if not SystemUtils:enableBackup() then
        self._viewMgr:showTip(lang("TIP_Backup"))
        return
    end
    self._modelMgr:getModel("BackupModel"):showBackupGradeView()
end

-- 战阵
function HandbookView:goView55() 
    if not SystemUtils:enableBattleArray()  then
        self._viewMgr:showTip(lang("TIP_BattleArray"))
        return
    end
    self._viewMgr:showView("battleArray.BattleArrayEnterView")
end


-- 荣耀竞技场 56
function HandbookView:goView56() 
    self._modelMgr:getModel("GloryArenaModel"):lOpenGloryArena()
end


-- 巅峰天赋 57
function HandbookView:goView57() 
    if not SystemUtils:enableParagonTalent() then
        self._viewMgr:showTip(lang("TIP_BattleArray"))
        return
    end

    self._viewMgr:showView("paragon.ParagonTalentView")
end
-- 周常任务 59
function HandbookView:goView59()
    if not SystemUtils:enableWeeklyTask() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    self._viewMgr:showView("task.TaskView",{viewType = 4})
end
function HandbookView:goView60()
    local worldBossModel = self._modelMgr:getModel("WorldBossModel")
    local isOpen,_,desc = worldBossModel:checkLevelAndServerTime()
    if isOpen then
        local opState, _, isOpenDay = worldBossModel:checkOpenTime()
        if opState ~= worldBossModel.notOpen then
            self._viewMgr:showView("worldboss.WorldBossView",{},true)
        else
            if not isOpenDay then
                self._viewMgr:showTip(lang("worldBoss_Tips6"))
            else
                self._viewMgr:showTip(lang("worldBoss_Tips2"))
            end
        end
    else
        self._viewMgr:showTip(desc)
    end
end

--军团试炼
function HandbookView:goView61()
    local lvOpen,isNotWeekend = self._modelMgr:getModel("ProfessionBattleModel"):getOpenState()
    if not lvOpen then
        self._viewMgr:showTip(lang("TIP_ArmyTest"))
        return
    end
    if not isNotWeekend then
        self._viewMgr:showTip(lang("TIP_ArmyTest_Lock"))
        return
    end
    self._serverMgr:sendMsg("ProfessionBattleServer", "getInfo", {}, true, {}, function(result)
        self._viewMgr:showDialog("pve.ProfessionBattleDialog")
    end)
end
-- 跨服诸神
function HandbookView:goView53()
    if not SystemUtils:enableCrossGodWar() then
        self._viewMgr:showTip(lang("CrossGodWar"))
        return
    end
    local godWarConstData = self._modelMgr:getModel("UserModel"):getGodWarConstData()
    local openTime = godWarConstData.FIRST_RACE_BEG + 43200 + 3*7*24*60*60
    openTime = TimeUtils.formatTimeToFiveOclock(openTime)
    local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    if curTime<=openTime then
        self._viewMgr:showTip(lang("crossFight_tips_5"))
    elseif self:checkIsTimeInIllegalTime() then
        self._viewMgr:showTip(lang("crossFight_tips_6"))
    else
        self._serverMgr:sendMsg("CrossGodWarServer", "enter", {}, true, {}, function(result)
            UIUtils:reloadLuaFile("crossGod.CrossGodWarView")
            self._viewMgr:showView("crossGod.CrossGodWarView")
        end)
    end 
end

-- 检测诸神时间
function HandbookView:checkIsTimeInIllegalTime()
    local godWarConstData = self._modelMgr:getModel("UserModel"):getGodWarConstData()
    local weekTime = 7*24*60*60
    local openTime = godWarConstData.FIRST_RACE_BEG + 43200 + 3*weekTime
    openTime = TimeUtils.formatTimeToFiveOclock(openTime)
    local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local week = tonumber(TimeUtils.getDateString(curTime, "%w"))
    if week==1 then
        local timeEnd = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 05:00:00"))--5:00
        if ((timeEnd-openTime)/weekTime)%2==1 then--只隔一周，不是跨服诸神的开启周，周一三点到五点可以进
            return false
        end
        local timeStart = timeEnd - 2*60*60
        if curTime>=timeStart and curTime<=timeEnd then
            return true
        end
    end
    return false
end

function HandbookView:onDestroy()
    if self._selectMc then
        if self._selectMc:getParent() ~= nil then
            self._selectMc:removeFromParent(true)
        end
        self._selectMc:release()
        self._selectMc = nil
    end
end
return HandbookView