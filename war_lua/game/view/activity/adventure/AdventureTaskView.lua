--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-05-03 22:50:48
--


local AdventureTaskView = class("AdventureTaskView",BasePopView)

-- [[ 模仿任务 TaskView.XX -> AdventureTaskView.AdventureTaskView
AdventureTaskView.kViewTypePrimaryLine = 1
AdventureTaskView.kViewTypeEveryday = 2

AdventureTaskView.kStatusCannot = 0
AdventureTaskView.kStatusAvailable = 1
AdventureTaskView.kStatusAlready = -1

AdventureTaskView.kNormalZOrder = 500
AdventureTaskView.kLessNormalZOrder = AdventureTaskView.kNormalZOrder - 1
AdventureTaskView.kAboveNormalZOrder = AdventureTaskView.kNormalZOrder + 1
AdventureTaskView.kHighestZOrder = AdventureTaskView.kAboveNormalZOrder + 1

AdventureTaskView.kTaskItemTag = 1000 

AdventureTaskView.kSuperiorTypeNormal = 1
AdventureTaskView.kSuperiorTypePrivileges = 2
AdventureTaskView.kSuperiorTypeAdventure = 3
--]]

function AdventureTaskView:ctor()
    self.super.ctor(self)
    self._privilegesModel = self._modelMgr:getModel("PrivilegesModel")
    self._userModel = self._modelMgr:getModel("UserModel")
end

-- 初始化UI后会调用, 有需要请覆盖
function AdventureTaskView:onInit()
	self:registerClickEventByName("bg.closeBtn",function( )
	    self:close()
	    UIUtils:reloadLuaFile("activity.adventure.AdventureTaskView")
	end)
	self._item = self:getUI("item")
	self._tableBg = self:getUI("bg.tableBg")
	UIUtils:setTitleFormat(self:getUI("bg.headBg.title"),1)
	self:filterTaskData()
	self:addTableView()
	self:listenReflash("AdventureModel", function( )
        print("============ 监听model....... task Model")
        self:reflashUI()
    end)
    self:listenReflash("UserModel", function( )
        print("============ 监听model....... task Model")
        self:reflashUI()
    end)

end

-- 接收自定义消息
function AdventureTaskView:reflashUI(data)
	self:filterTaskData()
	self._tableView:reloadData()
end

function AdventureTaskView:filterTaskData( )
	self._tableData = {}
	local allTaskData = self._modelMgr:getModel("TaskModel"):getData().task.detailTasks
	local allStaticTask = tab.task 
	for k,v in pairs(allStaticTask) do
		if v.unlock and v.unlock[1] == 4 then
			local taskData = clone(v)
			table.merge(taskData,clone(allTaskData[tostring(k)]))
			table.insert(self._tableData,taskData)
		end
	end
	table.sort(self._tableData,function( a,b )
		if a.status == b.status then
			return a.id < b.id 
		else
			if a.status == 1 then
				return true
			elseif b.status == 1 then
				return false 
			elseif a.status*b.status == 0 then
				return a.status == 0
			else
				return a.id < b.id
			end
		end
	end)
end

function AdventureTaskView:addTableView( )
    local tableView = cc.TableView:create(cc.size(534, 430))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(12,10)
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    self._tableBg:addChild(tableView,10)
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

function AdventureTaskView:scrollViewDidScroll(view)
    -- print("scrollViewDidScroll")
end

function AdventureTaskView:scrollViewDidZoom(view)
    -- print("scrollViewDidZoom")
end

function AdventureTaskView:tableCellTouched(table,cell)
    -- print("cell touched at index: " .. cell:getIdx())
end

function AdventureTaskView:cellSizeForTable(table,idx) 
    return 115,534
end

function AdventureTaskView:tableCellAtIndex(table, idx)
    local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
    end
    local cellBoard = cell:getChildByName("cellBoard")
    if not cellBoard then
        cellBoard = self:getUI("item"):clone()
        self:L10N_Text(cellBoard)
        cellBoard:setSwallowTouches(false)
        cellBoard:setName("cellBoard")
        cellBoard:setPosition(0,3)
        cell:addChild(cellBoard)
    end
    self:updateTaskCell(cellBoard,self._tableData[idx+1])
    return cell
end

function AdventureTaskView:updateTaskCell( item,taskData )
    local layerGoBg = item:getChildByFullName("layer_go_bg")
    layerGoBg:setSwallowTouches(false)
    --local layerGoBg:setBrightness(-51)
    
    local layerFinishedLine = item:getChildByFullName("layer_finished_line")
    local label_finished = item:getChildByFullName("layer_finished_line.label_finished")
    -- label_finished:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    local taskIcon = item:getChildByFullName("task_icon_bg.task_icon")
    taskIcon:setVisible(false)
    local taskName = item:getChildByFullName("task_title_bg.task_name")
    --local taskName:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    local task_namebg = item:getChildByFullName("task_namebg")
    local taskDescription = item:getChildByFullName("task_title_bg.task_description")
    local taskCurrentDataBg = item:getChildByFullName("task_title_bg.task_current_data_bg")
    local taskCurrentData = item:getChildByFullName("task_title_bg.task_current_data")
    local btnGo = item:getChildByFullName("btn_go")
    local btnGet = item:getChildByFullName("btn_get")

    local label_reward_value_1 = item:getChildByFullName("task_title_bg.label_reward_value_1")
    local label_reward_value_2 = item:getChildByFullName("task_title_bg.label_reward_value_2")
    local label_reward_value_3 = item:getChildByFullName("task_title_bg.label_reward_value_3")
    local task_reward = item:getChildByFullName("task_title_bg.task_reward")
    local imageAlreadyGet = item:getChildByFullName("image_already_get")

    local rewards = {}
    for i = 1, 1 do
        rewards[i] = {}
        rewards[i]._icon = item:getChildByFullName("task_title_bg.reward_icon_" .. i)
        rewards[i]._value = item:getChildByFullName("task_title_bg.label_reward_value_" .. i)
        --rewards[i]._value:enableShadow(cc.c4b(0, 0, 0,255))
        rewards[i]._addValue = item:getChildByFullName("task_title_bg.label_reward_add_value_" .. i)
        -- rewards[i]._addValue:enableOutline(cc.c4b(60, 30, 10, 255), 2)
        rewards[i]._addValue:setVisible(false)
        rewards[i]._bg = item:getChildByFullName("task_title_bg.icon_bg_" .. i)
    end

    self:registerClickEvent(btnGo, function ()
        self:onButtonGoClicked(taskData)
    end)
    
    self:registerClickEvent(btnGet, function ()
        self:onButtonGetClicked(taskData)
    end)

    -- 
    local filename = IconUtils.iconPath .. taskData.art .. ".png"
    taskIcon:setVisible(true)
    taskIcon:loadTexture(filename, 1)
    -- taskIcon:loadTexture(IconUtils.iconPath .. taskData.art .. ".png")
    item:setBackGroundImage(taskData.status > 1 and "globalPanelUI7_cellBg22.png" or "globalPanelUI7_cellBg20.png", 1)
    item:setBackGroundImageCapInsets(cc.rect(41,41,1,1))
    layerGoBg:setVisible(taskData.status < 1)
    btnGo:setVisible(0 == taskData.status and 0 < taskData.button)
    btnGet:setVisible(1 == taskData.status)
    imageAlreadyGet:setVisible(taskData.status > 1)
    taskCurrentDataBg:setVisible(not imageAlreadyGet:isVisible())
    taskCurrentData:setVisible(not imageAlreadyGet:isVisible())
    taskName:setFontName(UIUtils.ttfName)
    taskName:setString(lang(taskData.name))
    task_namebg:setContentSize(cc.size(math.max(190,taskName:getContentSize().width+95),34))

    local labelDiscription = taskDescription
    local desc = lang(taskData.des)
    if taskData.id == 9622 and self._userModel:getData().guildLevel and (self._userModel:getData().guildLevel >= 3) then
        desc = lang("TASKDES_9622_1")
    end
    local varibleNameToValue = {
        ["$physical1"] = self._privilegesModel:getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_19),
        ["$physical2"] = self._privilegesModel:getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_17),
        ["$physical3"] = self._privilegesModel:getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_18)
    }
    desc = string.gsub(desc, "%b{}", function(substring)
        return math.round(loadstring("return " .. string.gsub(string.gsub(substring, "%$%w+", function(variableName)
            return tostring(varibleNameToValue[variableName])
        end), "[{}]", ""))())
    end)
    desc = string.gsub(desc, "，", ",") 
    desc = string.gsub(desc, "fontsize=20", "fontsize=24") -- fontsize=20
    desc = string.gsub(desc, "645252", "3c2a1e") -- fontsize=20
    local richText = labelDiscription:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, labelDiscription:getContentSize().width, labelDiscription:getContentSize().height - 5)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(labelDiscription:getContentSize().width / 2, labelDiscription:getContentSize().height - richText:getInnerSize().height / 2-10)
    richText:setName("descRichText")
    labelDiscription:addChild(richText)
    local activeName = viewType == self.kViewTypeItemPrimary and "成长值" or "活跃度"
    local activeValue = "+" .. (viewType == self.kViewTypeItemPrimary and taskData.grow or taskData.active)
    local isActiveShow = viewType == self.kViewTypeItemPrimary and 0 ~= taskData.grow or
                         viewType == self.kViewTypeItemEveryday and 0 ~= taskData.active
    --taskCurrentData:setPositionY((btnGo:isVisible() or btnGet:isVisible()) and 7 or -23)
    taskCurrentData:setColor(cc.c3b(138, 92, 29))
    local conditiontype = taskData.conditiontype
    if 101 == conditiontype or
       102 == conditiontype then
       taskCurrentDataBg:setVisible(true)
        taskCurrentData:setVisible(true)
        if 0 == taskData.status then
            taskCurrentData:setString("0/1")
        elseif 1 == taskData.status then
            taskCurrentData:setString("1/1")
        else
            taskCurrentDataBg:setVisible(false)
            taskCurrentData:setVisible(false)
        end
    elseif 998 == conditiontype or 997 == conditiontype then
        taskCurrentDataBg:setVisible(true)
        taskCurrentData:setVisible(true)
        if 0 == taskData.status then
            taskCurrentData:setString("未购买")
        elseif 1 == taskData.status then
            taskCurrentData:setString("已购买")
            local restDay = math.floor((taskData.val2 - self._userModel:getCurServerTime()) / 86400)
        else
            taskCurrentDataBg:setVisible(false)
            taskCurrentData:setVisible(false)
        end   
    elseif 999 == conditiontype then
        if 0 == taskData.status then
            taskCurrentData:setString("时间未到")
        elseif taskData.status >= 1 then
            taskCurrentData:setVisible(false)
        elseif -1 == taskData.status then
            taskCurrentData:setString("时间已过")
        end
    else
        taskCurrentData:setVisible(not imageAlreadyGet:isVisible())
        taskCurrentData:setColor(1 == taskData.status and cc.c3b(28, 162, 22) or cc.c3b(138, 92, 29))
        local value1 = ItemUtils.formatItemCount(tonumber(taskData.val2))
        local value2 = ItemUtils.formatItemCount(tonumber(taskData.val1))
        taskCurrentData:setString(string.format("%s/%s",value1,value2))
    end

    local toolTableData = tab.tool
    local staticConfigTableData = IconUtils.iconIdMap
    local staticConfigTableResData = clone(IconUtils.resImgMap)
    staticConfigTableResData.exp = "globalImageUI_exp2.png"
    staticConfigTableResData.vexp = "globalImageUI_exp2.png"

    for i=1, 1 do
        rewards[i]._icon:setVisible(false)
        rewards[i]._value:setVisible(false)
        rewards[i]._addValue:setVisible(false)
        rewards[i]._bg:setVisible(false)
    end

    local count = math.min(#taskData.award, 2)
    for i = 1, count do
        rewards[i]._icon:setVisible(true)
        rewards[i]._value:setVisible(true)
        rewards[i]._bg:setVisible(true)
        if taskData.award[i][1] ~= "tool" and staticConfigTableData[taskData.award[i][1]] then
            local filename = IconUtils.iconPath .. staticConfigTableResData[taskData.award[i][1]]
            rewards[i]._icon:loadTexture(filename, 1)
            rewards[i]._icon:setScale(30 / rewards[i]._icon:getContentSize().width)
            local value = tonumber(taskData.award[i][3])
            local addition = 0
            local additionValue = 0
            local color = cc.c3b(255, 255, 255)
            if taskData.award[i][1] == "physcal" then
                if 9615 == taskData.id then
                    addition = self._privilegesModel:getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_19)
                    if addition > 0 then
                        color = cc.c3b(118, 238, 0)
                    end
                    additionValue = addition
                elseif 9616 == taskData.id then
                    addition = self._privilegesModel:getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_17)
                    if addition > 0 then
                        color = cc.c3b(118, 238, 0)
                    end
                    additionValue = addition
                elseif 9617 == taskData.id then
                    addition = self._privilegesModel:getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_18)
                    if addition > 0 then
                        color = cc.c3b(118, 238, 0)
                    end
                    additionValue = addition
                end
            elseif taskData.award[i][1] == "exp" then
                addition = self._privilegesModel:getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_16)
                if addition > 0 then
                    color = cc.c3b(118, 238, 0)
                end
                additionValue = value * addition * 0.01
            end
            -- rewards[i]._value:setColor(color)
            --rewards[i]._icon:loadTexture(IconUtils.iconPath .. toolTableData[staticConfigTableData[taskData.award[i][1]]].art .. ".jpg")
            --rewards[i]._value:setString(math.round(value))
            rewards[i]._value:setString(math.round(value))
            if additionValue > 0 then
                rewards[i]._addValue:setVisible(true)
                rewards[i]._addValue:enableOutline(cc.c4b(60, 30, 10, 255), 1)
                rewards[i]._addValue:setPosition(rewards[i]._value:getPositionX() + rewards[i]._value:getContentSize().width, rewards[i]._value:getPositionY())
                rewards[i]._addValue:setString(string.format("+%d", math.round(additionValue)))
            end
        elseif taskData.award[i][1] == "tool" and toolTableData[taskData.award[i][2]] then
            local filename = IconUtils.iconPath .. toolTableData[taskData.award[i][2]].art .. ".png"
            rewards[i]._icon:loadTexture(filename, 1)
            rewards[i]._icon:setScale(30 / rewards[i]._icon:getContentSize().width)
            -- rewards[i]._icon:loadTexture(IconUtils.iconPath .. toolTableData[taskData.award[i][2]].art .. ".jpg")
            rewards[i]._value:setString(taskData.award[i][3])
        end
    end
end

function AdventureTaskView:numberOfCellsInTableView(table)
   return #self._tableData
end


--- 从任务拷贝过来的
function AdventureTaskView:goView1() self._viewMgr:showView("intance.IntanceView", {superiorType = 2}) end
function AdventureTaskView:goView2() self._viewMgr:showView("vip.VipView", {viewType = 0}) end
function AdventureTaskView:goView3()
    if not SystemUtils:enableElite() then
        self._viewMgr:showTip(lang("TIP_JINGYING_1"))
        return 
    end
    self._viewMgr:showView("intance.IntanceEliteView", {superiorType = 2}) 
end
function AdventureTaskView:goView4() 
    if not SystemUtils:enableDwarvenTreasury() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    self._viewMgr:showView("pve.AiRenMuWuView") 
end
function AdventureTaskView:goView5() 
    if not SystemUtils:enableCrypt() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    self._viewMgr:showView("pve.ZombieView") 
end
function AdventureTaskView:goView6() 
    if not SystemUtils:enableBoss() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    self._viewMgr:showView("pve.DragonView") 
end
function AdventureTaskView:goView7() self._viewMgr:showView("team.TeamListView") end
function AdventureTaskView:goView8() self._viewMgr:showView("flashcard.FlashCardView") end
function AdventureTaskView:goView9() 
    if not SystemUtils:enableArena() then
        self._viewMgr:showTip(lang("TIP_Arena"))
        return 
    end
    self._viewMgr:showView("arena.ArenaView") 
end
function AdventureTaskView:goView10() 
    if not SystemUtils:enableCrusade() then
        self._viewMgr:showTip(lang("TIP_Crusade"))
        return 
    end
    self._viewMgr:showView("crusade.CrusadeView") 
end
function AdventureTaskView:goView11() DialogUtils.showBuyRes({goalType = "gold", callback = function(success)
    -- if success then self._tableViews[self._viewType]:setContentOffset(self._tableViews[self._viewType]:minContainerOffset()) end
end}) end
function AdventureTaskView:goView12() DialogUtils.showBuyRes({goalType = "physcal", callback = function(success)
    -- if success then self._tableViews[self._viewType]:setContentOffset(self._tableViews[self._viewType]:minContainerOffset()) end
end}) end
function AdventureTaskView:goView13() DialogUtils.showBuyRes({goalType = "gem", callback = function(success)
    -- if success then self._tableViews[self._viewType]:setContentOffset(self._tableViews[self._viewType]:minContainerOffset()) end
end}) end

function AdventureTaskView:goView18() 
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

function AdventureTaskView:goView22() 
    if not SystemUtils:enableMF() then
        self._viewMgr:showTip(lang("TIP_MF"))
        return 
    end

    self._viewMgr:showView("MF.MFView")
end

function AdventureTaskView:goView23()
    if not SystemUtils:enableCloudCity() then
        self._viewMgr:showTip(lang("TIP_TOWER"))
        return 
    end

    self._viewMgr:showView("cloudcity.CloudCityView")
end

function AdventureTaskView:goView24()
    local isOpen,openDes = LeagueUtils:isLeagueOpen()
    if not isOpen then
        self._viewMgr:showTip(openDes)
        return
    end
    self._viewMgr:showView("league.LeagueView")
end

function AdventureTaskView:goView27()
    self._viewMgr:showDialog("tencentprivilege.TencentPrivilegeView")
end

function AdventureTaskView:onButtonGetClicked(taskData)
    --print("onButtonGetClicked")
    -- [[体力超3000不让领取体力 by guojun 2016.8.23 
    if taskData.award and #taskData.award == 1 and taskData.award[1][1] == "physcal" then
        local physcal = self._modelMgr:getModel("UserModel"):getData().physcal 
        if physcal >= 3000 then
            self._viewMgr:showTip("体力接近上限，请去扫荡副本")
            return 
        end
    end
    --]]
    local context = { taskId = taskData.id }
    -- 目前只有日常色子任务
   	if taskData.type == AdventureTaskView.kViewTypeEveryday then
        self._serverMgr:sendMsg("TaskServer", "detailTaskReward", context, true, {}, function(success, resultData)
            if not success then 
                self._viewMgr:showTip(lang("TIP_LINGQUGUOQI"))
                self:doRequestData()
                return 
            end
            self:showRewardDialog(taskData, resultData)
            self._everyDayDirty = true
        end)
    end
end

function AdventureTaskView:onButtonGoClicked(taskData)
    --print("onButtonGoClicked")
    if self["goView" .. taskData.button] then
        self["goView" .. taskData.button](self)
    end
end

function AdventureTaskView:doRequestData(callback, errorCallback)
    if not (self._serverMgr and self.filterTaskData and self.switchTag and self.getCurrentTag) then return end
    self._serverMgr:sendMsg("TaskServer", "getTask", {}, true, {}, function(success)
        if not (self._serverMgr and self.filterTaskData) then return end
        self._primaryLineDirty = true
        self._everyDayDirty = true
        self:filterTaskData()
        self._tableView:reloadData()
        if callback then
            callback()
        end
    end, 
    function(errorCode)
        if errorCode and errorCallback then
            errorCallback()
        end
    end)
end

function AdventureTaskView:showRewardDialog(taskData, resultData)
    local params = { gifts = clone(taskData.award) }
    if resultData then
        params.callback = function()
            if resultData.lvl then
                local lastLvl = self._userModel:getLastLvl()
                local lastPhysical = self._userModel:getLastPhysical()
                local userLevel = self._userModel:getData().lvl
                local userphysic = self._userModel:getData().physcal
                self._viewMgr:checkLevelUpReturnMain(resultData.lvl)
                ViewManager:getInstance():showDialog("global.DialogUserLevelUp", { preLevel = lastLvl, level = resultData.lvl, prePhysic = lastPhysical, physic = resultData.physcal }, true, nil, nil, false)
            elseif resultData.plvl then
                local lastPLvl = self._userModel:getLastPLvl()
                local lastPTalentPoint = self._userModel:getLastPTalentPoint()
                local plvl = self._userModel:getData().plvl or 1
                local pTalentPoint = self._userModel:getData().pTalentPoint or lastPTalentPoint
                ViewManager:getInstance():showDialog("global.DialogUserParagonLevelUp", {oldPlvl = lastPLvl, plvl = plvl, pTalentPoint = (pTalentPoint - lastPTalentPoint)}, true, nil, nil, false)
            end
        end
    end

    local toolTableData = tab.tool
    local staticConfigTableData = IconUtils.iconIdMap

    for i = 1, #params.gifts do
        if params.gifts[i][1] ~= "tool" and staticConfigTableData[params.gifts[i][1]] then
            if params.gifts[i][1] == "physcal" then
                if 9615 == taskData.id then
                    params.gifts[i][3] = math.round(params.gifts[i][3] + self._privilegesModel:getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_19))
                elseif 9616 == taskData.id then
                    params.gifts[i][3] = math.round(params.gifts[i][3] + self._privilegesModel:getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_17))
                elseif 9617 == taskData.id then
                    params.gifts[i][3] = math.round(params.gifts[i][3] + self._privilegesModel:getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_18))
                end
            elseif params.gifts[i][1] == "exp" then
                params.gifts[i][3] = math.round(params.gifts[i][3] + params.gifts[i][3] * self._privilegesModel:getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_16) * 0.01)
            end
        end
    end
    dump(params, "params", 10)
    DialogUtils.showGiftGet(params)
end

return AdventureTaskView