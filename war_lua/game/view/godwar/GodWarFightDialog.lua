--[[
    Filename:    GodWarFightDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-04-18 20:48:17
    Description: File description
--]]

-- 战况
local GodWarFightDialog = class("GodWarFightDialog", BasePopView)

local readlyTime = GodWarUtil.readlyTime -- 准备间隔
local fightTime = GodWarUtil.fightTime -- 战斗间隔
function GodWarFightDialog:ctor(param)
    GodWarFightDialog.super.ctor(self)
    self._groupId = param.groupId
    self._index = param.indexId
    self._callbackFight = param.callbackFight
    self._scrollId = param.scrollId
    self._tableData = {}
end

-- 初始化UI后会调用, 有需要请覆盖
function GodWarFightDialog:onInit()
    self:registerClickEventByName("bg.closeBtn", function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("godwar.GodWarFightDialog")
        end
        self:close()
    end)

    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._godWarModel = self._modelMgr:getModel("GodWarModel")
    self._reloadFlag = 0

    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 1)

    local fightPanel = self:getUI("bg.fightPanel")
    fightPanel:setVisible(false)

    self._reportCell = self:getUI("reportCell")
    self._reportCell:setVisible(false)

    self._layer1 = self:getUI("bg.layer1")
    self._layer1:setVisible(false)
    self._layer2 = self:getUI("bg.layer2")
    self._layer2:setVisible(false)

    local flag = self._godWarModel:isMyJoin()
    self._mygroupId = 0
    if flag == true then
        self._mygroupId = self._godWarModel:getMyGroup()
    end

    for i=1,8 do
        local groupBtn = self:getUI("bg.layer1.groupBtn" .. i)
        local btnLab = self:getUI("bg.layer1.groupBtn" .. i .. ".btnLab")
        btnLab:setColor(cc.c3b(252, 244, 197))
        groupBtn:setScaleAnim(true)
        groupBtn:loadTexture("godwarImageUI_img36.png", 1)
        if self._mygroupId == i then
            groupBtn:loadTexture("godwarImageUI_img149.png", 1)
        end
        local selectAnim = mcMgr:createViewMC("zhengbasaixuanzhong_zhandoukaiqi", true, false)
        selectAnim:setPosition(groupBtn:getContentSize().width*0.5,groupBtn:getContentSize().height*0.5-10)
        groupBtn:addChild(selectAnim, 5)
        selectAnim:setVisible(false)
        groupBtn.selectAnim = selectAnim
        self:registerClickEvent(groupBtn, function()
            print("self._groupI==========", self._groupId)
            local groupBtn = self:getUI("bg.layer1.groupBtn" .. self._groupId)
            if self._mygroupId == self._groupId then
                groupBtn:loadTexture("godwarImageUI_img149.png", 1)
            else
                groupBtn:loadTexture("godwarImageUI_img36.png", 1)
            end
            if groupBtn.selectAnim then
                groupBtn.selectAnim:setVisible(false)
            end
            self._groupId = i
            self:updateGroupLayer()
        end)
    end

    -- local groupBtn = self:getUI("bg.layer1.groupBtn8")
    -- groupBtn:setScaleAnim(true)
    -- self:registerClickEvent(groupBtn, function()
    --     local xian = self._godWarModel:getWarXianTuData()
    --     dump(xian)
    -- end)

    local closeTip = self:getUI("closeTip")
    self:registerClickEvent(closeTip, function()
        self:closeFightTip()
    end)
    closeTip:setSwallowTouches(false)

    local tab1 = self:getUI("bg.tab1")
    local tab2 = self:getUI("bg.tab2")
    self._btnList = {}
    table.insert(self._btnList, tab1)
    table.insert(self._btnList, tab2) 

    UIUtils:setTabChangeAnimEnable(tab1,67,handler(self, self.tabButtonClick))
    UIUtils:setTabChangeAnimEnable(tab2,67,handler(self, self.tabButtonClick))

    self:addTableView()
    -- self:updateGroupLayer()
    self:getUI("bg.tab" .. self._index)._appearSelect = true
    self:tabButtonClick(self:getUI("bg.tab" .. self._index), self._index, false)
    -- self:reflashBattleTime()
    self:listenReflash("GodWarModel", self.updateFight)
    self:reloadTableView()
end

function GodWarFightDialog:tabButtonClick(sender, key, infirst)
    print("sender=============")
    if sender == nil then 
        return 
    end
    if self._tabName == sender:getName() then 
        return 
    end
    for k,v in pairs(self._btnList) do
        if v ~= sender then 
            local text = v:getTitleRenderer()
            v:setTitleColor(UIUtils.colorTable.ccUITabColor1)
            text:disableEffect()
            v:setScaleAnim(false)
            v:stopAllActions()
            v:setBright(true)
            v:setEnabled(true)
        end
    end
    if self._preBtn then 
        UIUtils:tabChangeAnim(self._preBtn,nil,true)
    end
    self._preBtn = sender 
    UIUtils:tabChangeAnim(sender,function( )
        local text = sender:getTitleRenderer()
        text:disableEffect()
        sender:setTitleColor(UIUtils.colorTable.ccUITabColor2)
        sender:setBright(false)
        sender:setEnabled(false)
        if sender:getName() == "tab1" then
            self._index = 1 
            self._layer1:setVisible(true)
            self._layer2:setVisible(false)
            self:updateGroupLayer()
        elseif sender:getName() == "tab2" then 
            print("升级")
            self._index = 2
            self._layer1:setVisible(false)
            self._layer2:setVisible(true)
            self:updateCraftLayer()
        end
    end)
end

function GodWarFightDialog:updateFight()
    print("updateFight==========================")
    ScheduleMgr:delayCall(5000, self, function()
        if self._index == 1 then
            if self.updateGroupLayer then
                self:updateGroupLayer(true)
            end
        else
            if self.updateCraftLayer then
                self:updateCraftLayer(true)
            end
        end
    end)
end

function GodWarFightDialog:onPopEnd()
    self:scrollToNext(indexId)
end

function GodWarFightDialog:scrollToNext(indexId)
    if not self._scrollId then
        return
    end
    local selectedIndex = (self._scrollId-1) or 0
    local allIndex = table.nums(self._tableData)
    local begHeight = selectedIndex*117 + 50
    if selectedIndex > 4 then
        begHeight = begHeight + 50*2
    elseif selectedIndex > 6 then
        begHeight = begHeight + 50*3
    end

    local scrollAnim = true
    local tempheight = self._tableView:getContainer():getContentSize().height
    local tableViewBg = self:getUI("bg.layer2.tableViewBg")
    local tabHeight = tempheight - tableViewBg:getContentSize().height + 10
    print("containHeight==========", tabHeight)
    if tempheight < tableViewBg:getContentSize().height then
        self._tableView:setContentOffset(cc.p(0, self._tableView:getContentOffset().y), scrollAnim)
    else
        if (tempheight - begHeight) > tableViewBg:getContentSize().height then
            print("+++4", -1*(tabHeight-begHeight))
            self._tableView:setContentOffset(cc.p(0, -1*(tabHeight-begHeight)), scrollAnim)
        else
            print("+++5")
            self._tableView:setContentOffset(cc.p(0, 0), scrollAnim)
        end
    end
end

function GodWarFightDialog:getGroupList(groupId)
    local groupData = self._godWarModel:getGroupById(self._groupId)
    self._groupList = self:progressGroupList(groupData)
end

-- 处理小组赛列表
function GodWarFightDialog:progressGroupList(groupData)
    local tGroupData = {}
    for i=1,table.nums(groupData) do
        local siteData = groupData[tostring(i)]
        tGroupData[i] = siteData
    end
    return tGroupData
end

function GodWarFightDialog:getCraftList()
    local warData = self._godWarModel:getWarDataAll()
    -- dump(warData)
    self._craftList = self:progressCraftData()
end

-- 处理争霸赛列表
function GodWarFightDialog:getCraftState()
    local curServerTime = self._userModel:getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", curServerTime))
    local godWarConstData = self._userModel:getGodWarConstData()
    local begTime = godWarConstData["RACE_BEG"]
    local state = 0
    if begTime == 0 then
        state = 4
    else
        if weekday == 3 then
            local endTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:36:00"))
            if curServerTime > endTime then
                state = 1
            end
        elseif weekday == 4 then
            local endTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:18:00"))
            if curServerTime > endTime then
                state = 2
            else
                state = 1
            end
            local endTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:29:00"))
            if curServerTime > endTime then
                state = 3
            else
                state = 2
            end
        else
            state = 4
        end
    end

    print("state======", state)
    return state 
end

function GodWarFightDialog:progressCraftData()
    local state = self:getCraftState()
    local tGroupData = {}
    local warData = self._godWarModel:getWarDataById(8)
    tGroupData[1] = warData
    local warData = self._godWarModel:getWarDataById(4)
    tGroupData[2] = warData
    local warData = self._godWarModel:getWarDataById(3)
    tGroupData[3] = warData
    local warData = self._godWarModel:getWarDataById(2)
    tGroupData[4] = warData

    return tGroupData
end


-- 接收自定义消息
function GodWarFightDialog:reflashUI()
    -- self._tableView:reloadData()
    -- self:updateConditionDes()

    -- 处理页签的存在
    local state, indexId = self._godWarModel:getStatus()
    if state < 4 then
        for i=1,2 do
            local tab = self:getUI("bg.tab" .. i)
            tab:setVisible(false)
        end
    else
        for i=1,2 do
            local tab = self:getUI("bg.tab" .. i)
            tab:setVisible(true)
        end
    end
    -- local state = self:getCheckBtnState(powerId)
    -- if state == true then
    --     for i=1,2 do
    --         local tab = self:getUI("bg.tab" .. i)
    --         tab:setVisible(false)
    --     end
    -- end
end

function GodWarFightDialog:getCheckBtnState(powerId)
    local godwarConst = self._userModel:getGodWarConstData()
    local raceTime = godwarConst.RACE_BEG
    local flag = false
    if raceTime == 0 then
        flag = false
    else
        local curServerTime = self._userModel:getCurServerTime()
        local weekday = tonumber(TimeUtils.date("%w", curServerTime))
        if weekday == 3 then
            local begTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
            local endTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:36:00"))
            if curServerTime >= begTime and curServerTime <= endTime then
                flag = true
            end
        elseif weekday == 4 then
            local begTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
            local endTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:30:00"))
            if curServerTime >= begTime and curServerTime <= endTime then
                flag = true
            end
            local begTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:40:00"))
            local endTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:55:00"))
            if curServerTime >= begTime and curServerTime <= endTime then
                flag = true
            end
        end
    end
    return flag
end

function GodWarFightDialog:getGroupRoundTimer(data)
    local titleId = data.title
    local pow = data.round 
    print("titleId=======", titleId, type(titleId))
    if titleId < 8 then
        local curServerTime = self._userModel:getCurServerTime()
        local tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
        local separate = fightTime*3*(titleId-1)
        local begTime = TimeUtils.getDateString(tempTime + separate,"%H:%M")
        local begBattleTime = tempTime + separate
        local separate = fightTime*3*(titleId)
        local endTime = TimeUtils.getDateString(tempTime + separate,"%H:%M")
        local endBattleTime = tempTime + separate

        local flag = false
        if (curServerTime >= begBattleTime) and (curServerTime <= endBattleTime) then
            flag = true
        end
        local timerStr = begTime .. "~" .. endTime
        return timerStr, flag
    elseif titleId == 18 then
        local curServerTime = self._userModel:getCurServerTime()
        local tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
        local begTime = TimeUtils.getDateString(tempTime,"%H:%M")
        local begBattleTime = tempTime
        local separate = 2160
        local endTime = TimeUtils.getDateString(tempTime + separate,"%H:%M")
        local endBattleTime = tempTime + separate

        local flag = false
        if (curServerTime >= begBattleTime) and (curServerTime <= endBattleTime) then
            flag = true
        end
        local weekday = tonumber(TimeUtils.date("%w", curServerTime))
        if weekday ~= 3 then
            flag = false
        end
        local timerStr = begTime .. "~" .. endTime
        return timerStr, flag
    elseif titleId == 14 then
        local curServerTime = self._userModel:getCurServerTime()
        local tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
        local begTime = TimeUtils.getDateString(tempTime,"%H:%M")
        local begBattleTime = tempTime
        local separate = 1080
        local endTime = TimeUtils.getDateString(tempTime + separate,"%H:%M")
        local endBattleTime = tempTime + separate

        local flag = false
        if (curServerTime >= begBattleTime) and (curServerTime <= endBattleTime) then
            flag = true
        end
        local weekday = tonumber(TimeUtils.date("%w", curServerTime))
        if weekday ~= 4 then
            flag = false
        end
        local timerStr = begTime .. "~" .. endTime
        return timerStr, flag
    elseif titleId == 13 then
        local curServerTime = self._userModel:getCurServerTime()
        local tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:18:00"))
        local begTime = TimeUtils.getDateString(tempTime,"%H:%M")
        local begBattleTime = tempTime
        local separate = 660
        local endTime = TimeUtils.getDateString(tempTime + separate,"%H:%M")
        local endBattleTime = tempTime + separate

        local flag = false
        if (curServerTime >= begBattleTime) and (curServerTime <= endBattleTime) then
            flag = true
        end
        local weekday = tonumber(TimeUtils.date("%w", curServerTime))
        if weekday ~= 4 then
            flag = false
        end
        local timerStr = begTime .. "~" .. endTime
        return timerStr, flag
    elseif titleId == 12 then
        local curServerTime = self._userModel:getCurServerTime()
        local tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:18:00"))
        local begTime = TimeUtils.getDateString(tempTime,"%H:%M")
        local begBattleTime = tempTime
        local separate = 660
        local endTime = TimeUtils.getDateString(tempTime + separate,"%H:%M")
        local endBattleTime = tempTime + separate

        local flag = false
        if (curServerTime >= begBattleTime) and (curServerTime <= endBattleTime) then
            flag = true
        end
        local weekday = tonumber(TimeUtils.date("%w", curServerTime))
        if weekday ~= 4 then
            flag = false
        end
        local timerStr = begTime .. "~" .. endTime
        return timerStr, flag
    end

end

function GodWarFightDialog:updateCell(inView, data, indexId)
    if data == nil then
        return
    end
    -- dump(data, "============" .. indexId)

    local bg1 = inView:getChildByFullName("bg1")
    local titleCell = inView.titleCell

    local chakanBtn = inView:getChildByFullName("bg1.statePanel.chakanBtn")
    local leftLayer = inView:getChildByFullName("bg1.left")
    local lefticonBg = inView:getChildByFullName("bg1.left.iconBg")
    local rightLayer = inView:getChildByFullName("bg1.right")
    local righticonBg = inView:getChildByFullName("bg1.right.iconBg")
    local leftname = inView:getChildByFullName("bg1.left.pname")
    local rightname = inView:getChildByFullName("bg1.right.pname")
    local leftjieguo = inView:getChildByFullName("bg1.left.jieguo")
    local rightjieguo = inView:getChildByFullName("bg1.right.jieguo")
    local stateLab = inView:getChildByFullName("bg1.stateLab")

    local flag = self._godWarModel:isReverse(data.def)
    if flag == true then
        data = self._godWarModel:reversalData(data)
    end

    local round = self:getGroupFight(data.round, data.pow)
    -- self:reloadTableView(inView, data, indexId, data.round, data.pow)
    local stateBg = inView:getChildByFullName("bg1.statePanel.stateBg")
    local chakanBtn = inView:getChildByFullName("bg1.statePanel.chakanBtn")
    local vs = inView:getChildByFullName("bg1.statePanel.vs")
    print("round==========", round)
    if round == 1 then
        stateBg:loadTexture("godwarImageUI_img138.png", 1)
        -- stateLab:setString("即将开始")
        -- stateLab:setColor(cc.c3b(28, 162, 22))
        vs:setVisible(true)
        chakanBtn:setVisible(false)
    elseif round == 2 then
        stateBg:loadTexture("godwarImageUI_img137.png", 1)
        -- stateLab:setString("准备中")
        -- stateLab:setColor(cc.c3b(28, 162, 22))
        vs:setVisible(true)
        chakanBtn:setVisible(false)
    elseif round == 3 then
        stateBg:loadTexture("godwarImageUI_img139.png", 1)
        -- stateLab:setString("战斗中")
        -- stateLab:setColor(cc.c3b(138, 92, 29))
        vs:setVisible(true)
        chakanBtn:setVisible(false)
    elseif round == 4 then
        stateBg:loadTexture("godwarImageUI_img140.png", 1)
        -- stateLab:setString("已结束")
        -- stateLab:setColor(cc.c3b(78, 78, 78))
        vs:setVisible(false)
        chakanBtn:setVisible(true)
    elseif round == 5 then
        stateBg:loadTexture("godwarImageUI_img139.png", 1)
        -- stateLab:setString("战斗中")
        -- stateLab:setColor(cc.c3b(138, 92, 29))
        vs:setVisible(false)
        chakanBtn:setVisible(true)
    end

    local atkId = data.atk
    local atkData = self._godWarModel:getPlayerById(atkId)
    local defId = data.def
    local defData = self._godWarModel:getPlayerById(defId)
    local userId = self._userModel:getData()._id

    if atkData then
        local param1 = {avatar = atkData.avatar, tp = 4,avatarFrame = atkData["avatarFrame"]}
        leftLayer:setVisible(true)
        if lefticonBg then
            local icon = lefticonBg:getChildByName("icon")
            if not icon then
                icon = IconUtils:createHeadIconById(param1)
                icon:setName("icon")
                icon:setScale(0.68)
                icon:setAnchorPoint(0.5, 0.5)
                icon:setPosition(cc.p(30,35))
                lefticonBg:addChild(icon)
                icon:setScaleAnim(true)
            else
                IconUtils:updateHeadIconByView(icon, param1)
            end
            self:registerClickEvent(icon, function()
                local data = {tagId = atkId, fid = 101}
                self:getTargetUserBattleInfo(data)
            end)
        end
        if atkId == userId then
            leftname:setColor(cc.c3b(138, 92, 29))
            if bg1 then
                bg1:loadTexture("godwarImageUI_img143.png", 1)
            end
        else
            leftname:setColor(cc.c3b(60, 42, 30))
            if bg1 then
                bg1:loadTexture("godwarImageUI_img142.png", 1)
            end
        end
        leftname:setString(atkData.name)
    else
        leftLayer:setVisible(true)
    end


    if defData then
        local param1 = {avatar = defData.avatar, tp = 4,avatarFrame = defData["avatarFrame"]}
        rightLayer:setVisible(true)
        if righticonBg then
            local icon = righticonBg:getChildByName("icon")
            if not icon then
                icon = IconUtils:createHeadIconById(param1)
                icon:setName("icon")
                icon:setScale(0.68)
                icon:setAnchorPoint(0.5, 0.5)
                icon:setPosition(cc.p(30,35))
                righticonBg:addChild(icon)
                icon:setScaleAnim(true)
            else
                IconUtils:updateHeadIconByView(icon, param1)
            end
            self:registerClickEvent(icon, function()
                local data = {tagId = defId, fid = 101}
                self:getTargetUserBattleInfo(data)
            end)
            icon:setSwallowTouches(false)
        end
        if defId == userId then
            rightname:setColor(cc.c3b(138, 92, 29))
        else
            rightname:setColor(cc.c3b(60, 42, 30))
        end
        rightname:setString(defData.name)
    else
        rightLayer:setVisible(false)
    end

    -- dump(data)
    if data.win ~= 0 then
        leftjieguo:setVisible(true)
        rightjieguo:setVisible(true)
        if data.win == 1 then
            leftjieguo:loadTexture("godwarImageUI_img78.png", 1)
            rightjieguo:loadTexture("godwarImageUI_img79.png", 1)
        else
            leftjieguo:loadTexture("godwarImageUI_img79.png", 1)
            rightjieguo:loadTexture("godwarImageUI_img78.png", 1)
        end
    else
        leftjieguo:setVisible(false)
        rightjieguo:setVisible(false)
    end

    local chData = data.reps
    for i=1,3 do
        local leftju = inView:getChildByFullName("bg1.left.ju" .. i)
        local rightju = inView:getChildByFullName("bg1.right.ju" .. i)
        if chData then
            local juData = chData[tostring(i)]
            if juData then
                if juData["w"] == 1 then
                    leftju:loadTexture(TeamUtils.godWarWinImg[1], 1)
                    rightju:loadTexture(TeamUtils.godWarWinImg[2], 1)
                elseif juData["w"] == 3 then
                    leftju:loadTexture(TeamUtils.godWarWinImg[4], 1)
                    rightju:loadTexture(TeamUtils.godWarWinImg[4], 1)
                else
                    leftju:loadTexture(TeamUtils.godWarWinImg[2], 1)
                    rightju:loadTexture(TeamUtils.godWarWinImg[1], 1)
                end
            else
                leftju:loadTexture(TeamUtils.godWarWinImg[3], 1)
                rightju:loadTexture(TeamUtils.godWarWinImg[3], 1)
            end
        else
            leftju:loadTexture(TeamUtils.godWarWinImg[3], 1)
            rightju:loadTexture(TeamUtils.godWarWinImg[3], 1)
        end
    end

    self:registerClickEvent(chakanBtn, function()
        local flag, reportList = self:getBattleReport(data)
        if flag == true then
            if self._index == 1 then
                local param = {gp = data.gp, round = data.round, ju = data.per}
                self:getGroupBattleInfo(param, data)
            elseif self._index == 2 then
                local param = {pow = data.pow, round = data.round}
                self:getWarBattleInfo(param, data)
            end
        else
            local serverData
            if self._index == 1 then
                serverData = {gp = data.gp, round = data.round, ju = data.per}
            elseif self._index == 2 then
                serverData = {pow = data.pow, round = data.round}
            end
            local param = {fightData = data, differ = self._index, serverData = serverData, list = reportList, callbackFight = self._callbackFight}
            self._viewMgr:showDialog("godwar.GodWarFightDetailDialog", param, true)
        end
    end)
end

function GodWarFightDialog:getBattleReport(data)
    local reportList = {}
    local flag = false
    local repsData = data["reps"]
    if not repsData then
        return true
    end
    for i=1,3 do
        local indexId = tostring(i)
        local battleD = repsData[indexId]
        if battleD and battleD.battleReport then
            reportList[indexId] = battleD.battleReport
            -- table.insert(reportList, battleD.battleReport)
        else
            flag = true
        end
    end
    return flag, reportList
end


function GodWarFightDialog:getGroupBattleInfo(param, data)
    self._serverMgr:sendMsg("GodWarServer", "getGroupBattleInfo", param, true, {}, function(result) 
        local param = {fightData = data, differ = self._index, serverData = param, list = result, callbackFight = self._callbackFight}
        self._viewMgr:showDialog("godwar.GodWarFightDetailDialog", param, true)
    end, function(errorId)
        if tonumber(errorId) == 113 then
            self._viewMgr:showTip(lang("REPLAY_CLEAR_TIP"))
        end
    end)
end

function GodWarFightDialog:getWarBattleInfo(param, data)
    self._serverMgr:sendMsg("GodWarServer", "getWarBattleInfo", param, true, {}, function(result) 
        local param = {fightData = data, differ = self._index, serverData = param, list = result, callbackFight = self._callbackFight}
        self._viewMgr:showDialog("godwar.GodWarFightDetailDialog", param, true)
    end, function(errorId)
        if tonumber(errorId) == 113 then
            self._viewMgr:showTip(lang("REPLAY_CLEAR_TIP"))
        end
    end)
end


function GodWarFightDialog:setBtnTip(fightPanel, indexId, data)
    local chData = data.reps
    if not chData then
        -- self._viewMgr:showTip("正在生成战报")
        -- return
    end
    dump(data)
    print("indexId===========", indexId)
    self:closeFightTip()
    if fightPanel then
        fightPanel:setVisible(true)
        for i=1,3 do
            local fightBtn = fightPanel:getChildByFullName("fight" .. i)
            if fightBtn then
                if chData then
                    local reportData = chData[tostring(i)]
                    if reportData and reportData["k"] then
                        fightBtn:setSaturation(0)
                        self:registerClickEvent(fightBtn, function()
                            if self._callbackFight then
                                self._viewMgr:showTip("战斗开启")
                                self._callbackFight(reportData["k"])
                            end
                        end)
                    else
                        fightBtn:setSaturation(-100)
                        self:registerClickEvent(fightBtn, function()
                            self._viewMgr:showTip("战斗尚未开启，请耐心等待")
                        end)
                    end
                else
                    fightBtn:setSaturation(-100)
                    self:registerClickEvent(fightBtn, function()
                        self._viewMgr:showTip("战斗尚未开启，请耐心等待")
                    end)
                end

                -- self:registerClickEvent(fightBtn, function()
                --     if chData then
                --         local reportData = chData[tostring(i)]
                --         if reportData and reportData["k"] then
                --             if self._callbackFight then
                --                 self._viewMgr:showTip("战斗开启")
                --                 self._callbackFight(reportData["k"])
                --             end
                --         else
                --             self._viewMgr:showTip("战斗尚未开启，请耐心等待")
                --         end
                --     end
                -- end)
            end
        end
        self._fightTip = fightPanel
    end
end

function GodWarFightDialog:tongji()
    self._refGroupData = false
    local callFunc = cc.CallFunc:create(function()
        self._refGroupData = true
    end)
    local seq = cc.Sequence:create(cc.DelayTime:create(300), callFunc)
    -- local x = self:getUI("bg.")
end

-- 小组赛是否在战斗中
-- 1 即将开始 2 准备中 3 战斗中 4 结束
function GodWarFightDialog:getGroupFight(lun, pow)
    print("lun, pow======", lun, pow)
    local flag = 1
    local curServerTime = self._userModel:getCurServerTime()
    local godWarConstData = self._userModel:getGodWarConstData()
    if godWarConstData.RACE_BEG ~= 0 then
        local weekday = tonumber(TimeUtils.date("%w", curServerTime))
        local begTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
        if weekday == 2 then
            if pow == 32 then
                local minBegTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:" .. 6*(lun-1) .. ":00"))
                local minTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:" .. 6*(lun-1)+1 .. ":00"))
                local maxTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:" .. 6*lun .. ":00"))
                local tmpTime = curServerTime - minTime
                if curServerTime < begTime then
                    flag = 2
                elseif curServerTime >= begTime then
                    if curServerTime >= minTime and curServerTime < maxTime then
                        flag = 5
                    elseif curServerTime >= maxTime then
                        flag = 4
                    else
                        flag = 1
                    end
                end
            else
                flag = 1
            end
        elseif weekday == 3 then
            if pow == 8 then
                local middleTime = math.floor((readlyTime + fightTime*3)/60)
                local minTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:" .. middleTime*(lun-1) .. ":00"))
                local maxTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:" .. middleTime*lun .. ":00"))
                local tmpTime = curServerTime - minTime
                print("=================", curServerTime, minTime, maxTime)
                if curServerTime <= begTime then
                    flag = 2
                elseif curServerTime >= begTime then
                    if curServerTime >= minTime and curServerTime <= maxTime then
                        flag = 3
                    elseif curServerTime >= maxTime then
                        flag = 4
                    else
                        flag = 1
                    end
                end
            elseif pow == 32 then
                flag = 4
            else
                flag = 1
            end
        elseif weekday == 4 then
            if pow == 4 then
                local middleTime = math.floor((readlyTime + fightTime*3)/60)
                local minTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:" .. middleTime*(lun-1) .. ":00"))
                local maxTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:" .. middleTime*lun .. ":00"))
                local tmpTime = curServerTime - minTime
                if curServerTime <= begTime then
                    flag = 2
                elseif curServerTime >= begTime then
                    if curServerTime >= minTime and curServerTime <= maxTime then
                        flag = 3
                    elseif curServerTime >= maxTime then
                        flag = 4
                    else
                        flag = 1
                    end
                end
            elseif pow == 3 then
                local begTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:18:00"))
                local minTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:" .. 23 .. ":00"))
                local maxTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:" .. 29 .. ":00"))
                local tmpTime = curServerTime - minTime
                if curServerTime <= begTime then
                    flag = 2
                elseif curServerTime >= begTime then
                    if curServerTime >= minTime and curServerTime <= maxTime then
                        flag = 3
                    elseif curServerTime >= maxTime then
                        flag = 4
                    else
                        flag = 1
                    end
                end
            elseif pow == 2 then
                local begTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:18:00"))
                local minTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:" .. 23 .. ":00"))
                local maxTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:" .. 29 .. ":00"))
                local tmpTime = curServerTime - minTime
                if curServerTime <= begTime then
                    flag = 2
                elseif curServerTime >= begTime then
                    if curServerTime >= minTime and curServerTime <= maxTime then
                        flag = 3
                    elseif curServerTime >= maxTime then
                        flag = 4
                    else
                        flag = 1
                    end
                end
            elseif pow == 32 or pow == 8 then
                flag = 4
            end
        else
            flag = 4
        end
    else
        flag = 4
    end
    return flag
end

function GodWarFightDialog:getTargetUserBattleInfo(param)
    self._serverMgr:sendMsg("UserServer", "getTargetUserBattleInfo", param, true, {}, function(result) 
        self._viewMgr:showDialog("godwar.GodwarUserInfoDialog", result, true)
    end)
end

-- 点击晋级赛战况
function GodWarFightDialog:updateCraftLayer()
    self:getCraftList()
    self._tableData = self._craftList
    self._tableView = self._tableCraftView
    self._tableView:reloadData()

end

-- 点击更新小组赛战况
function GodWarFightDialog:updateGroupLayer(scrollFlag)
    self:getGroupList(self._groupId)
    self._tableData = self._groupList
    self._tableView = self._tableGroupView
    local offset = self._tableView:getContentOffset()
    local posX, posY = offset.x, offset.y
    self._tableView:reloadData()
    if scrollFlag == true then
        self._tableView:setContentOffset(cc.p(posX, posY))
    end
    -- 加交战中 滚动 begin
    local scrollToFightIdx
    -- if not self._initScrollGroup then
    --     self._initScrollGroup = true
        local scrollOffsetMap = {-474,-195,0}
        for i,cellData in ipairs(self._tableData) do
            -- print("round===========",((round == 3 or round == 5) and i > 1),round,cellData["1"].round, cellData["1"].pow)
            local _, flag = self:getGroupRoundTimer(cellData["1"])
            if (flag and i > 1) then
                scrollToFightIdx = i
                posY = scrollOffsetMap[scrollToFightIdx]
                break
            end
        end
        if scrollToFightIdx then
            self._tableView:setContentOffset(cc.p(posX, posY))
        end
    -- end
    -- 交战中滚动    end

    local groupBtn = self:getUI("bg.layer1.groupBtn" .. self._groupId)
    if self._mygroupId == self._groupId then
        groupBtn:loadTexture("godwarImageUI_img149.png", 1)
    else
        groupBtn:loadTexture("godwarImageUI_img35.png", 1)
    end
    if groupBtn.selectAnim then
        groupBtn.selectAnim:setVisible(true)
    end
end

function GodWarFightDialog:closeFightTip()
    if self._fightTip then
        self._fightTip:setVisible(false)
        self._fightTip = nil
    end
end

--[[
用tableview实现
--]]
function GodWarFightDialog:addTableView()
    local tableViewBg = self:getUI("bg.layer1.tableViewBg")

    self._tableGroupView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width+100, tableViewBg:getContentSize().height-10))
    self._tableGroupView:setDelegate()
    self._tableGroupView:setName("groupTable")
    self._tableGroupView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableGroupView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableGroupView:setAnchorPoint(0, 0)
    self._tableGroupView:setPosition(cc.p(0, 5))
    self._tableGroupView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableGroupView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableGroupView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableGroupView:setBounceable(true)
    -- if self._tableGroupView.setDragSlideable ~= nil then 
    --     self._tableGroupView:setDragSlideable(true)
    -- end
    tableViewBg:addChild(self._tableGroupView)

    local tableViewBg = self:getUI("bg.layer2.tableViewBg")
    self._tableCraftView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width+100, tableViewBg:getContentSize().height-10))
    self._tableCraftView:setDelegate()
    self._tableCraftView:setName("craftTable")
    self._tableCraftView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableCraftView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableCraftView:setAnchorPoint(0, 0)
    self._tableCraftView:setPosition(cc.p(0, 5))
    self._tableCraftView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableCraftView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableCraftView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableCraftView:setBounceable(true)
    -- if self._tableCraftView.setDragSlideable ~= nil then 
    --     self._tableCraftView:setDragSlideable(true)
    -- end
    tableViewBg:addChild(self._tableCraftView)
end

-- cell的尺寸大小
function GodWarFightDialog:cellSizeForTable(table,idx) 
    local width = 668
    local height = 126
    if self._index == 1 then
        height = 280
    else
        if idx == 0 then
            height = 500
        elseif idx == 1 then
            height = 280
        elseif idx == 2 then
            height = 170
        elseif idx == 3 then
            height = 170
        end
        -- if idx == 0 or idx == 4 or idx == 6 then
        --     height = 180
        -- end
    end
    return height, width
end

-- 创建在某个位置的cell
function GodWarFightDialog:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local param = self._tableData[idx+1]
    local indexId = idx + 1
    if nil == cell then
        cell = cc.TableViewCell:new()
        local reportCellBg = ccui.Scale9Sprite:createWithSpriteFrameName("godwarImageUI_img141.png")
        reportCellBg:setCapInsets(cc.rect(15, 60, 1, 1))
        reportCellBg:setAnchorPoint(0, 0)
        reportCellBg:setPosition(0, 0)
        reportCellBg:setName("reportCellBg")
        cell:addChild(reportCellBg) -- 2

        for i=1,4 do
            local reportCell = self._reportCell:clone() 
            reportCell:setVisible(true)
            reportCell:setAnchorPoint(0, 0)
            reportCell:setPosition(5, 110*(i-1)+5)
            reportCell:setName("reportCell" .. i)
            reportCellBg:addChild(reportCell)
            reportCellBg["reportCell" .. i] = reportCell

            local jieguo_0 = reportCell:getChildByFullName("bg1.right.jieguo_0")
            jieguo_0:setColor(cc.c3b(99,99,99))
            local jieguo_0 = reportCell:getChildByFullName("bg1.left.jieguo_0")
            jieguo_0:setColor(cc.c3b(99,99,99))
        end

        local titleLab = cc.Label:createWithTTF("", UIUtils.ttfName, 24)
        titleLab:setColor(cc.c3b(255, 243, 174))
        titleLab:setName("titleLab")
        reportCellBg:addChild(titleLab) -- 4

        local leftAdorn = cc.Sprite:createWithSpriteFrameName("globalImageUI11_0418DayTitleAdorn.png")
        leftAdorn:setName("leftAdorn")
        reportCellBg:addChild(leftAdorn) -- 3

        local rightAdorn = cc.Sprite:createWithSpriteFrameName("globalImageUI11_0418DayTitleAdorn.png")
        rightAdorn:setName("rightAdorn")
        reportCellBg:addChild(rightAdorn) -- 3

        -- local bg1 = reportCell:getChildByFullName("bg1")
        -- -- local bg2 = reportCell:getChildByFullName("bg2")
        -- titleCell:setCapInsets(cc.rect(70, 25, 1, 1))
        -- bg1:setCapInsets(cc.rect(25, 25, 1, 1))
        -- self:updateCell(reportCell, param, indexId)
    end
    local reportCellBg = cell:getChildByName("reportCellBg")
    if reportCellBg then
        self:updateReportCellBg(reportCellBg, param, indexId)
    end

    return cell
end

function GodWarFightDialog:updateReportCellBg(inView, param, indexId)
    local height = 280
    local titleStr = ""
    local timerStr, flag = self:getGroupRoundTimer(param["1"])
    if self._index == 1 then
        height = 280
        titleStr = "第" .. indexId .. "轮 " .. timerStr
    else
        local showPow = ""
        if indexId == 1 then
            height = 500
            showPow = "8强赛"
        elseif indexId == 2 then
            height = 280
            showPow = "4强赛"
        elseif indexId == 3 then
            height = 170
            showPow = "季军赛"
        elseif indexId == 4 then
            height = 170
            showPow = "决赛"
        end
        titleStr = showPow .. " " .. timerStr
    end
    inView:setContentSize(680, height)
    local titleLab = inView:getChildByName("titleLab")
    if titleLab then
        titleLab:setString(titleStr)
        titleLab:setPosition(inView:getContentSize().width*0.5, height-25)
    end
    local leftAdorn = inView:getChildByName("leftAdorn")
    if leftAdorn then
        local posX = titleLab:getPositionX() - titleLab:getContentSize().width*0.5 - 20 
        leftAdorn:setPosition(posX, height-25)
    end
    local rightAdorn = inView:getChildByName("rightAdorn")
    if rightAdorn then
        local posX = titleLab:getPositionX() + titleLab:getContentSize().width*0.5 + 20 
        rightAdorn:setPosition(posX, height-25)
    end

    for i=1,4 do
        local reportCell = inView["reportCell" .. i] 
        if reportCell then
            local indexId = tostring(i)
            local indexNum = i
            local reportData = param[indexId]
            if reportData then
                self:updateCell(reportCell, reportData, indexId)
                reportCell:setVisible(true)
                reportCell:setPosition(5, 110*(table.nums(param)-indexNum)+5)
            else
                reportCell:setVisible(false)
            end
        end
    end
end

-- 返回cell的数量
function GodWarFightDialog:numberOfCellsInTableView(table)
    return self:cellLineNum() -- 
end

function GodWarFightDialog:cellLineNum()
    return table.nums(self._tableData) 
end

-- 刷新界面
function GodWarFightDialog:reloadTableView()
    local curServerTime = self._userModel:getCurServerTime()
    local godWarConstData = self._userModel:getGodWarConstData()
    if godWarConstData.RACE_BEG ~= 0 then
        local weekday = tonumber(TimeUtils.date("%w", curServerTime))
        local begTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
        if weekday == 2 then
            local tTime1 = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:01:00"))
            local tTime2 = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:07:00"))
            local tTime3 = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:13:00"))
            local minTime = 0
            if curServerTime < tTime1 then
                minTime = tTime1
            elseif curServerTime < tTime2 then
                minTime = tTime2
            elseif curServerTime < tTime3 then
                minTime = tTime3
            end
            local title = self:getUI("bg.titleBg.title")
            local callFunc = cc.CallFunc:create(function()
                local curServerTime = self._userModel:getCurServerTime()
                if curServerTime >= minTime then
                    if self._reloadFlag ~= minTime then
                        self._reloadFlag = minTime
                        if self._index == 1 then
                            self:updateGroupLayer(true)
                            self:reloadTableView()
                            title:stopAllActions()
                        end
                    end
                end
            end)
            local seq = cc.Sequence:create(callFunc, cc.DelayTime:create(1))
            title:stopAllActions()
            title:runAction(cc.RepeatForever:create(seq))
        end
    end
end

return GodWarFightDialog