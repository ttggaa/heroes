--[[
 	@FileName 	BackupFormationDialog.lua
	@Authors 	yuxiaojing
	@Date    	2018-04-20 15:15:37
	@Email    	<yuxiaojing@playcrab.com>
	@Description   描述
--]]

local BackupGridItem = require("game.view.backup.BackupGridItem")

local BackupGrid = BackupGridItem[1]
local BackupItem = BackupGridItem[2]

local BackupFormationDialog = class("BackupFormationDialog", BasePopView)

BackupFormationDialog.maxGridItemNum = 9

function BackupFormationDialog:ctor( param )
	self.super.ctor(self)
	self._bid = param.bid 						-- 正在使用中的阵容id	
	self._backupTs = param.backupTs 			-- 该编组的所有阵容数据 
	self._teamUsing = param.teamUsing or {} 	-- 布阵中使用的兵团列表
	self._sortList = param.sortList or {} 		-- 选择上阵兵团的排序规则
	self._formationType = param.formationType 	-- 该布阵编组类型
	self._callback = param.callback
	self._formationView = param.formationView
	-- self.dontRemoveRes = true
end

function BackupFormationDialog:getAsyncRes(  )
	return
	{
		-- {"asset/ui/activity.plist", "asset/ui/activity.png"},
		-- {"asset/ui/newFormation.plist", "asset/ui/newFormation.png"},
	}
end

function BackupFormationDialog:onInit(  )
	self._backupModel = self._modelMgr:getModel("BackupModel")
	self._userModel = self._modelMgr:getModel("UserModel")

	self._backupModel:setUsingTeamList(self._teamUsing)

	self._scheduler = cc.Director:getInstance():getScheduler()

	UIUtils:setTitleFormat(self:getUI("bg.layer.titleImg.titleTxt"), 1)
	self._touch_layer = self:getUI("bg.touch_layer")
	self._tableBg = self:getUI("bg.layer.tableviewBg")
	self._backupCell = self:getUI("itemClone")
	self._formationBg = self:getUI("bg.layer.right_layer.formation_bg")
	self._backupInfo = self:getUI("bg.layer.right_layer.info_bg")
	self._scorePanel = self:getUI("bg.layer.right_layer.team_bg.score_panel")
	local touchGrid9 = self:getUI("bg.layer.right_layer.team_bg.formation.grid9")
	local touchGrid4 = self:getUI("bg.layer.right_layer.team_bg.formation.grid4")

	self._formationIcon = {}
	for i = 1, 16 do
		self._formationIcon[i] = self._formationBg:getChildByFullName('formation.formation_icon_' .. i)
	end
	touchGrid4:setVisible(false)
	touchGrid9:setVisible(false)
	self:enableTouchLayer(true)

	local btn_close = self:getUI("bg.layer.btn_close")
	self:registerClickEvent(btn_close, function (  )
		if not self._bid then
			self:closeSelf()
			return
		end
		local btData = self._backupTs[tostring(self._bid)] or {}
		local isUsing = false
		local isCanUse = false
		local teamNum = 0
		for i = 1, 3 do
			local teamId = btData["bt" .. i]
			if teamId and teamId ~= 0  then
				teamNum = teamNum + 1
				if self._backupModel:isTeamUsing(teamId) then
					isUsing = true
				else
					isCanUse = true
				end
			end
		end
		local tipDes = ""
		if teamNum <= 0 or (isUsing and not isCanUse) then
			tipDes = lang("backup_Tips4")
		end
		if teamNum > 0 and isCanUse and isUsing then
			tipDes = lang("backup_Tips7")
		end
		if tipDes ~= "" then
			DialogUtils.showShowSelect(
				{desc = tipDes,
				callback1 = function( )
	                self:closeSelf()
	            end})
			return
		end
		self:closeSelf()
	end)

	self._btn_up = self._formationBg:getChildByFullName('btn_up')
	self._btn_down = self._formationBg:getChildByFullName('btn_down')
	self._btn_use = self:getUI('bg.layer.btn_use')
	self:registerClickEvent(self._btn_up, function (  )
		local data = self._backupData[self._curSelectIdx + 1]
		self._backupTs[tostring(data.id)]["bpos"] = self._backupTs[tostring(data.id)]["bpos"] - 1
		self:updateFormation()
	end)

	self:registerClickEvent(self._btn_down, function (  )
		local data = self._backupData[self._curSelectIdx + 1]
		self._backupTs[tostring(data.id)]["bpos"] = self._backupTs[tostring(data.id)]["bpos"] + 1
		self:updateFormation()
	end)

	self:registerClickEvent(self._btn_use, function (  )
		local btData = self._backupTs[tostring(self._curSelectIdx + 1)]
		local teamNum = 0
		for i = 1, 3 do
			local teamId = btData["bt" .. i]
			if teamId and teamId ~= 0 then
				teamNum = teamNum + 1
			end
		end
		if teamNum <= 0 then
			self._viewMgr:showTip("至少上阵一名兵团")
			return
		end
		local oldBid = self._bid
		local data = self._backupData[self._curSelectIdx + 1]
		self._bid = data.id
		if oldBid then
			self._tableView:updateCellAtIndex(oldBid - 1)
		end
		self._tableView:updateCellAtIndex(self._curSelectIdx)
		self._viewMgr:showTip("更换后援成功")
		self:updateBackupUseBtn()
	end)

	self:startClock()

	self._backupData = clone(tab.backupMain)

	self._cellHeight = 98
	self._cellWidth = 138
	self._curSelectIdx = 0
	self._gridItems = {}
	self._isHittedItemSwitch = false
	self._hittedItem = nil
	self._hittedItemGrid = nil

	for k, v in pairs(self._backupData) do
		if v.id == self._bid then
			self._curSelectIdx = k - 1
		end
	end
	
	self:createTableView()
	self:reflashBackupUI()
end

function BackupFormationDialog:closeSelf(  )
	if self._callback then
		self._callback(self._bid, self._backupTs)
	end
	dump(self._backupTs)
	self:close()
	UIUtils:reloadLuaFile("backup.BackupFormationDialog")
	UIUtils:reloadLuaFile("backup.BackupGridItem")
end

function BackupFormationDialog:createTableView(  )
	local tableView = cc.TableView:create(cc.size(138, 429))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(0,0))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    self._tableBg:addChild(tableView)

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

function BackupFormationDialog:switchBackupItem( cell )
	local lastCell = self._tableView:cellAtIndex(self._curSelectIdx)
	if lastCell ~= nil then
		self:switchItemState(lastCell, true)
	end
	self:switchItemState(cell, false)

	self._curSelectIdx = cell:getIdx()

	self:reflashBackupUI()
end

function BackupFormationDialog:tableCellTouched( table, cell )
	local cellIdx = cell:getIdx()
	if cellIdx == self._curSelectIdx then
		return
	end
	-- dump(self._backupTs)
	local lockType = cell.lockType
	-- print("cell touch at index: " .. cell:getIdx())
	if lockType == 2 then

		local data = self._backupData[cellIdx + 1]
		local curDiamond = self._modelMgr:getModel("UserModel"):getData().gem
		local needDiamond = data.openDiamond[1][3]

		DialogUtils.showBuyDialog({
            costNum = needDiamond,
            goods = "解锁阵型？",
            callback1 = function()
				if needDiamond > curDiamond then
					DialogUtils.showNeedCharge({desc = "钻石不足，是否前去充值",callback1=function( )
			            local viewMgr = ViewManager:getInstance()
			            viewMgr:showView("vip.VipView", {viewType = 0})
			        end})
			        return
			    end

                self._serverMgr:sendMsg("BackupServer", "unlock", {bid = data.id}, true, {}, function(success, dataa)
                	-- local cell = self._tableView:cellAtIndex(cellIdx)
                	self:lock(-1)
                	local lockBG = cell:getChildByFullName("backupItem.lockImg")
                	if lockBG:getChildByFullName('lockAnim') then
                		lockBG:removeChildByName('lockAnim')
                	end
					local mc2 = mcMgr:createViewMC("jianzao_qianghua", false, true)
					mc2:setPosition(lockBG:getContentSize().width / 2, lockBG:getContentSize().height / 2)
					lockBG:addChild(mc2, 2)
					local mc1 = mcMgr:createViewMC("jinengsuo1_qianghua", false, true)
					mc1:setPosition(lockBG:getContentSize().width / 2, lockBG:getContentSize().height / 2 + 5)
					lockBG:addChild(mc1, 3)
					ScheduleMgr:delayCall(500, self, function(_, sender) 
						self:unlock()
						self:switchBackupItem(cell)
	                	self._tableView:updateCellAtIndex(cellIdx)
	                	self._viewMgr:showDialog("backup.BackupUnlockSuccessDialog", {backupId = data.id, showType = 1})
        			end)
                end)
            end
        })
		return
	elseif lockType == 3 then
		self._viewMgr:showTip('阵型尚未开放')
		return
	end
	self:switchBackupItem(cell)
end

function BackupFormationDialog:cellSizeForTable( table, idx )
	return self._cellHeight, self._cellWidth
end

function BackupFormationDialog:numberOfCellsInTableView( table )
	return #self._backupData
end

function BackupFormationDialog:tableCellAtIndex( table, idx )
	local cell = table:dequeueCell()
	if nil == cell then
		cell = cc.TableViewCell:new()
	end

	local backupItem = cell:getChildByFullName("backupItem")
	if tolua.isnull(backupItem) then
		backupItem = self._backupCell:clone()
		backupItem:setPosition(0, 0)
		backupItem:setCascadeOpacityEnabled(true, true)
		backupItem:setSwallowTouches(false)
		backupItem:setName("backupItem")
		backupItem:setVisible(true)
		cell:addChild(backupItem, 999)
	end

	self:updateCellInfo(cell, idx)

	return cell
end

function BackupFormationDialog:updateCellInfo( backupItem, idx )
	local cell = backupItem:getChildByFullName('backupItem')
	local data = self._backupData[idx + 1]
	local sData = self._backupModel:getBackupById(data.id)
	local name = lang(data.name)
	if sData and sData.lv then
		name = name .. "Lv." .. sData.lv
	end
	cell:getChildByFullName('name'):setString(name)
	cell:getChildByFullName('name'):enableOutline(cc.c4b(0,0,0,255), 1)

	--thumb
	local formationIcons = self._backupModel:handleBackupThumb(cell, data.icon)
	self._backupModel:handleFormation(formationIcons, data.icon)

	--unlock
	local unlockImg = cell:getChildByFullName('lockImg')
	unlockImg:setVisible(false)
	unlockImg:getChildByFullName("lockImg"):setVisible(true)
	local openLevel = data.openLevel or 0
	local curLevel = self._userModel:getPlayerLevel()
	if curLevel >= openLevel then
		if sData and sData.lv then
			backupItem.lockType = 1
		else
			unlockImg:setVisible(true)
			local mc = mcMgr:createViewMC("jinengsuo_qianghua", true, false)
			mc:setName("lockAnim")
			mc:setPosition(unlockImg:getContentSize().width / 2, unlockImg:getContentSize().height / 2 + 5)
			unlockImg:addChild(mc)
			unlockImg:getChildByFullName("lockImg"):setVisible(false)
			unlockImg:getChildByFullName('Label_93'):setString("点击解锁")
			backupItem.lockType = 2
		end
	else
		unlockImg:setVisible(true)
		unlockImg:getChildByFullName('Label_93'):setString(openLevel .. "级开放")
		backupItem.lockType = 3
	end

	--red point
	cell:getChildByFullName('red_tag'):setVisible(false)

	local img_use = cell:getChildByFullName('img_use')
	img_use:setVisible(data.id == self._bid)

	cell:getChildByFullName('icon.Image_88'):loadTexture(data.specialSkillIcon .. ".png", 1)

	self:switchItemState(backupItem, self._curSelectIdx ~= idx)
end

function BackupFormationDialog:switchItemState( backupItem, isSelected )
    backupItem:getChildByFullName('backupItem.select'):setVisible(not isSelected)
    backupItem:getChildByFullName('backupItem.bg'):setVisible(isSelected)
    local nameLab = backupItem:getChildByFullName('backupItem.name')
    if isSelected then
    	nameLab:setColor(cc.c4b(255, 255, 255, 255))
    else
    	nameLab:setColor(cc.c4b(210, 201, 160, 255))
    end
end

function BackupFormationDialog:reflashBackupUI(  )
	local data = self._backupData[self._curSelectIdx + 1]
	local sData = self._backupModel:getBackupById(data.id)
	if sData == nil then
		print("=================这个阵型没解锁呢================")
		return
	end

	local specName = lang(data.name) .. "  Lv." .. sData.lv
	if OS_IS_WINDOWS then
		specName = specName .. "   [id:" .. data.id .. "]"
	end
	self._backupInfo:getChildByFullName('title'):setString(specName)
	self._backupInfo:getChildByFullName('icon.Image_88'):loadTexture(data.specialSkillIcon .. ".png", 1)

	local desScrollView = self._backupInfo:getChildByFullName('ScrollView')
	local minHeight = desScrollView:getContentSize().height
	desScrollView:removeAllChildren()

	local attr = {sklevel = sData.lv, artifactlv = 1}
	local desc = "[color=7a5221, fontsize=20]" .. BattleUtils.getDescription(BattleUtils.kIconTypeSkill, data.specialSkill, attr, 1, nil, nil, nil) .. "[-]"
	local richText = RichTextFactory:create(desc, desScrollView:getContentSize().width - 10, 0)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setName("descRichText")
    local innerH = richText:getRealSize().height
    richText:setPosition(richText:getRealSize().width / 2 + 5, innerH / 2)
    if innerH < minHeight then
        richText:setPosition(richText:getRealSize().width / 2 + 5, minHeight - innerH + innerH / 2)
        innerH = minHeight
    end
    desScrollView:setInnerContainerSize(cc.size(desScrollView:getContentSize().width, innerH))

    desScrollView:addChild(richText)

	self:updateFormation()
	self:updateBackupUseBtn()
	self:updateBackupGridItem()
	self:updateFightScore()
end

function BackupFormationDialog:calFightScore(  )
	local data = self._backupData[self._curSelectIdx + 1]
	local sData = self._backupModel:getBackupById(data.id)
	local score = 0
	score = score + (sData.score or 0)
	score = score + (sData.as or 0)

	local tsData = self._backupTs[tostring(data.id)]
	for i = 1, 3 do
		local teamId = tsData["bt" .. i]
		if teamId and teamId ~= 0 then
			local teamData = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(teamId)
			if teamData then
				score = score + teamData.score
			end
		end
	end
	return score
end

function BackupFormationDialog:updateFightScore( isAnim )
	local score_panel = self._scorePanel

	local score = self:calFightScore()

	local fightLab = score_panel:getChildByFullName('fightLab')
	if fightLab == nil then
		fightLab = ccui.TextBMFont:create("a", UIUtils.bmfName_zhandouli_little)
	    fightLab:setAnchorPoint(cc.p(0, 0.5))
	    fightLab:setPosition(5, -3)
	    fightLab:setScale(0.4)
	    fightLab:setName("fightLab")
	    score_panel:addChild(fightLab)
	end

	local fightNum = score_panel:getChildByFullName('fightNum')
	if fightNum == nil then
		fightNum = ccui.TextBMFont:create("0", UIUtils.bmfName_zhandouli_little)
		fightNum:setAnchorPoint(0, 0.5)
		fightNum:setPosition(fightLab:getContentSize().width * fightLab:getScale() + 8, 0)
		fightNum:setScale(0.5)
		fightNum:setName("fightNum")
		score_panel:addChild(fightNum)
	end
	local oldPropFight = tonumber(fightNum:getString())
	if isAnim and oldPropFight ~= score then
		local fightBg = self:getUI("bg.layer")
	    TeamUtils:setFightAnim(fightBg, {oldFight = oldPropFight, newFight = score, x = fightBg:getContentSize().width*0.5-100, y = fightBg:getContentSize().height - 200})
	end
	fightNum:setString(score)
	local allW = fightLab:getContentSize().width * fightLab:getScale() + 8 + fightNum:getContentSize().width * fightNum:getScale()
	score_panel:setContentSize(allW, 0)
	score_panel:setPositionX(score_panel:getParent():getContentSize().width / 2 - (allW / 2))
end

function BackupFormationDialog:updateBackupUseBtn(  )
	local data = self._backupData[self._curSelectIdx + 1]
	UIUtils:setGray(self._btn_use, data.id == self._bid)
	self._btn_use:setEnabled(not (data.id == self._bid))
	self._btn_use:setTitleText((data.id == self._bid) and "使用中" or "使用")
end

function BackupFormationDialog:updateFormation(  )
	local data = self._backupData[self._curSelectIdx + 1]

	local bdata = self._backupTs[tostring(data.id)] or {}
	local pos = bdata.bpos
	local classData = data.class
	classData, isTop, isDown, nPos = self._backupModel:calClassData(classData, pos)

	self._backupModel:handleFormation(self._formationIcon, classData)
	UIUtils:setGray(self._btn_up, not isTop)
	self._btn_up:setEnabled(isTop)
	UIUtils:setGray(self._btn_down, not isDown)
	self._btn_down:setEnabled(isDown)

	self._backupModel:setBackupTs(self._backupTs, tostring(data.id), "bpos", nPos)
end

function BackupFormationDialog:updateBackupGridItem(  )
	local data = self._backupData[self._curSelectIdx + 1]
	local formationIcons = {}
	formationIcons, self._touchGrid = self._backupModel:handleBackupThumb(self:getUI("bg.layer.right_layer.team_bg"), data.icon)
	for k, v in pairs(formationIcons) do
		local iconType = 0
		for k1, v1 in pairs(data.icon) do
			if v1[2] == k then
				iconType = v[1]
			end
		end
		if iconType ~= 0 then
			local grid = BackupGrid.new({container = self, baseGrid = v, gridIndex = k, gridData = clone(data)})
			self._gridItems[k] = grid
		else
			self._gridItems[k] = nil
		end
	end
end

function BackupFormationDialog:updateState(  )
	if not self._isIconMoved then return end
	if self._hittedItem and self._touchMoveP then
		self._hittedItem:setPosition(self._touchMoveP)
	end
	if self._isHittedItemSwitch and self._hittedItem then
		local kk, grid  = self:containGrid(self._touchMoveP)
		if kk then
			for k, v in pairs(self._gridItems) do
				if v:getGridIndex() ~= self._hittedItemGrid:getGridIndex() and 
					self._hittedItemGrid:getClassType() == v:getClassType() and 
					kk == k then
					v:setCanUseMC(true)
				else
					v:setCanUseMC(false)
				end
			end
		end
	end
end

function BackupFormationDialog:startClock()
    if self._timer_id then self:endClock() end
    self._timer_id = self._scheduler:scheduleScriptFunc(function()
        self:updateState()
    end, 0, false)
end

function BackupFormationDialog:endClock()
    if self._timer_id then 
        self._scheduler:unscheduleScriptEntry(self._timer_id)
        self._timer_id = nil
    end
end


function BackupFormationDialog:containGrid( pos )
	if not self._backupModel:containsPoint(self._touchGrid, pos) then
		return nil
	end
    for k, v in pairs(self._gridItems) do
    	if v then
    		local grid = v:getGridWiget()
    		if self._backupModel:containsPoint(grid, pos) then
    			return k, v
    		end
    	end
    end
    return nil
end

function BackupFormationDialog:enableTouchLayer( enable )
	if not enable then
		return self._touch_layer:setTouchEnabled(false)
	end
	self._touch_layer:setTouchEnabled(true)
	self._touch_layer:setSwallowTouches(false)
	self:registerTouchEvent(self._touch_layer, 
		handler(self, self.onTouchLayerTouchBegan),
		handler(self, self.onTouchLayerTouchMoved),
		handler(self, self.onTouchLayerTouchEnded),
		handler(self, self.onTouchLayerTouchCancelled)
	)
end

function BackupFormationDialog:onTouchLayerTouchBegan( _, x, y )
	self._isHittedItemSwitch = false
	self._touchBeginP = cc.p(x, y)
	self._isIconMoved = false
	return
end

function BackupFormationDialog:onTouchLayerTouchMoved( _, x, y )
	self._touchMoveP = cc.p(x, y)
	if not self._isIconMoved then
		if OS_IS_WINDOWS then
			self._isIconMoved = true
		else
			self._isIconMoved = (math.abs(self._touchMoveP.x - self._touchBeginP.x) >= 5 or math.abs(self._touchMoveP.y - self._touchBeginP.y) >= 5)
		end
	end
	if not self._isIconMoved then return end
	if not self._isHittedItemSwitch and self._hittedItem then
		self._hittedItem:retain()
		if self._hittedItemGrid then
			self._hittedItemGrid:setBackupItem()
		end
		self._touch_layer:addChild(self._hittedItem)
		self._isHittedItemSwitch = true
		self._hittedItem:release()
	end
end

function BackupFormationDialog:onTouchLayerTouchEnded( _, x, y )
	if not self._isIconMoved and self._hittedItem then
		self._hittedItem:showOperateDialog()
		self._hittedItem = nil
		self._touchMoveP = nil
		self._isHittedItemSwitch = false
		return
	end
	if self._hittedItem and self._isHittedItemSwitch then
		local k, grid  = self:containGrid(cc.p(x, y))
		if k then
			local itemGrid = self._gridItems[k]
			if self._hittedItemGrid:getGridIndex() ~= itemGrid:getGridIndex() then
				if self._hittedItemGrid:getClassType() == itemGrid:getClassType() then
					local switchItem = grid:getBackupItem()
					if switchItem then
						switchItem:retain()
						itemGrid:setBackupItem(self._hittedItem)
						self._hittedItemGrid:setBackupItem(switchItem)
						switchItem:release()
						self._hittedItemGrid:showSuccessMC()
					else
						itemGrid:setBackupItem(self._hittedItem)
						self._hittedItemGrid:makeBackupItem()
					end
					grid:showSuccessMC()
					grid:setCanUseMC(false)
				else
					self._viewMgr:showTip("位置兵团类型不符")
					self._hittedItemGrid:setBackupItem(self._hittedItem)
				end
			else
				self._hittedItemGrid:setBackupItem(self._hittedItem)
			end
		else
			self._hittedItemGrid:setBackupItem(self._hittedItem)
		end
	end
	self._hittedItem = nil
	self._touchMoveP = nil
	self._isHittedItemSwitch = false
end

function BackupFormationDialog:onTouchLayerTouchCancelled( _, x, y )
	self:onTouchLayerTouchEnded(_, x, y)
end

function BackupFormationDialog:onItemTouchBegan( itemView, x, y )
	self._hittedItem = itemView
	self._hittedItemGrid = self._hittedItem:getBackupGrid()
	return true
end

function BackupFormationDialog:onDestroy()
    self:endClock()
    BackupFormationDialog.super.onDestroy(self)
end

return BackupFormationDialog
