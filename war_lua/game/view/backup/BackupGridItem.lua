--[[
 	@FileName 	BackupGridItem.lua
	@Authors 	yuxiaojing
	@Date    	2018-04-20 15:59:53
	@Email    	<yuxiaojing@playcrab.com>
	@Description   描述
--]]

local BackupItem = class("BackupItem", BaseMvcs , BaseEvent, function(  )
    return ccui.Widget:create()
end)

function BackupItem:ctor( params )
	BackupItem.super.ctor(self)

	self._teamModel = self._modelMgr:getModel("TeamModel")
	self._backupModel = self._modelMgr:getModel("BackupModel")

	self._container = params.container
	self._btValue = params.btValue 		--兵团ID

	self:setContentSize(90, 90)
    self:setAnchorPoint(cc.p(0.5, 0.5))

    self:enableTouch(true)

    self._backupGrid = nil
    if self._btValue then
    	self:reflashInfo(self._btValue)
    end
end

-- 刷新兵团数据
function BackupItem:reflashInfo( btValue )
	self._btValue = btValue
	local teamData = self._teamModel:getTeamAndIndexById(btValue)
	if not teamData then 
        self._viewMgr:onLuaError("invalid team id:" .. self._iconId .. serialize(self._modelMgr:getModel("FormationModel"):getFormationData()))
    end
    local teamTableData = tab:Team(teamData.teamId)
    local quality = self._teamModel:getTeamQualityByStage(teamData.stage)

    if self._itemBody == nil then
    	self._itemBody = ccui.ImageView:create()
    	self._itemBody:setAnchorPoint(cc.p(0.5, 0))
    	self._itemBody:setScale(0.8)
    	self._itemBody:setPosition(self:getContentSize().width / 2, 35)
    	self:addChild(self._itemBody)
    end
    local isNeedChanged, changeTeamId = self._container._formationView:isTeamNeedChanged(teamData.teamId)
    local awakingTeamName, _, _, awakingTeamSteam, _ = TeamUtils:getTeamAwakingTab(teamData, isNeedChanged and changeTeamId or nil)
    self._itemBody:loadTexture(awakingTeamSteam .. ".png", 1)

    if self._teamNumBg == nil then
    	self._teamNumBg = ccui.ImageView:create("team_num_bg_forma.png", 1)
    	self._teamNumBg:setScale(1)
        self._itemBody:addChild(self._teamNumBg, 5)
    end
    self._teamNumBg:setPosition(self._itemBody:getContentSize().width / 2, -self._teamNumBg:getContentSize().height + 10)

    if self._imageClass == nil then
    	self._imageClass = ccui.ImageView:create(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
        self._imageClass:setScale(0.7 / 1)
        self._itemBody:addChild(self._imageClass, 20)
    end
    self._imageClass:setPosition(self._teamNumBg:getPositionX() - self._teamNumBg:getContentSize().width / 2, self._teamNumBg:getPositionY() + 6)

    if self._teamNumX == nil then
    	self._teamNumX = ccui.Text:create("X", UIUtils.ttfName, 14)
        self._teamNumX:setScale(1)
        self._teamNumX:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        self._teamNumX:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._itemBody:addChild(self._teamNumX, 10)
    end
    self._teamNumX:setPosition(self._imageClass:getPositionX() + 30, -self._teamNumBg:getContentSize().height + 10)

    if self._teamNum == nil then
    	self._teamNum = ccui.Text:create("", UIUtils.ttfName, 22)
        self._teamNum:setScale(1)
        self._teamNum:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
        self._teamNum:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._itemBody:addChild(self._teamNum, 10)
    end
    self._teamNum:setPosition(self._teamNumX:getPositionX() + self._teamNumX:getContentSize().width + 5, -self._teamNumBg:getContentSize().height + 10)
    self._teamNum:setString((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")))

    if self._teamConflict == nil then
    	self._teamConflict = ccui.ImageView:create("backup_img20.png", 1)
    	self._teamConflict:setAnchorPoint(cc.p(0.5, 0.5))
    	self._itemBody:addChild(self._teamConflict, 20)
    	self._teamConflict:setVisible(false)
    end
    self._teamConflict:setPosition(self._itemBody:getContentSize().width / 2, 40)

    -- 已在布阵中的 兵团 置灰
    local isUsing = self._backupModel:isTeamUsing(self._btValue)
    self._teamConflict:setVisible(isUsing)
    UIUtils:setGray(self._itemBody, isUsing)
    UIUtils:setGray(self._imageClass, isUsing)
    self._teamNumX:setColor(isUsing and cc.c4b(150, 150, 150, 255) or UIUtils.colorTable["ccColorQuality" .. quality[1]])
    self._teamNum:setColor(isUsing and cc.c4b(150, 150, 150, 255) or UIUtils.colorTable["ccColorQuality" .. quality[1]])

end

function BackupItem:setBackupGrid( grid )
	self._backupGrid = grid
end

function BackupItem:getBackupGrid(  )
	return self._backupGrid
end

function BackupItem:getBTValue(  )
	return self._btValue
end

function BackupItem:enableTouch(enable)
    if not enable then
        return self:setTouchEnabled(false)
    end
    self:setTouchEnabled(true)
    self:setSwallowTouches(false)
    self:registerTouchEvent(self, 
        handler(self, self.onTouchBegan), 
        handler(self, self.onTouchMoved), 
        handler(self, self.onTouchEnded), 
        handler(self, self.onTouchCancelled))
end

function BackupItem:onTouchBegan(_, x, y)
    if not (self._container and self._container.onItemTouchBegan) then return end
    return self._container:onItemTouchBegan(self, x, y)
end

function BackupItem:onTouchMoved(_, x, y)
end

function BackupItem:onTouchEnded(_, x, y)
end

function BackupItem:onTouchCancelled(_, x, y)
end

function BackupItem:showOperateDialog(  )
	if self._btValue then
		local isNeedChanged, changeTeamId = self._container._formationView:isTeamNeedChanged(self._btValue)
		self._container._viewMgr:showDialog("backup.BackupOperateDialog", 
			{classType = self._backupGrid:getClassType(), 
			teamId = self._btValue,
			isChange = isNeedChanged,
			changeId = changeTeamId,
			callback = function (  )
				self._backupGrid:onShowBackupListDialog()
			end,
			callback1 = function (  )
				self._backupGrid:teamOperate()
			end
			})
	end
end

function BackupItem.dtor()
    BackupItem = nil
end


----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------


local BackupGrid = class("BackupGrid")

BackupGrid.bCarrerBoard = {
	[1] = "backup_gongji.png",
	[2] = "backup_fangyu.png",
	[3] = "backup_tuji.png",
	[4] = "backup_sheshou.png",
	[5] = "backup_mofa.png",
}

function BackupGrid:ctor( params )
	self._gridData = params.gridData
	self._gridIndex = params.gridIndex
	self._container = params.container
	self._grid = params.baseGrid

	self._formationModel = ModelManager:getInstance():getModel("FormationModel")

	local classData = self._gridData.icon
	self._classType = 1
	self._btIndex = 1
	for k, v in pairs(classData) do
		if v[2] == self._gridIndex then
			self._classType = v[1]
			self._btIndex = k
		end
	end
	self._btValue = self:getBTValue()

	local board = ccui.ImageView:create()
	board:loadTexture(BackupGrid.bCarrerBoard[self._classType], 1)
	board:setAnchorPoint(cc.p(0.5, 0))
	board:setPosition(cc.p(self._grid:getContentSize().width / 2, -10))
	board:setScale(1.1)
	self._grid:addChild(board)

	local addImg = ccui.Button:create()
	addImg:loadTextures("golbalIamgeUI5_add.png", "golbalIamgeUI5_add.png", "golbalIamgeUI5_add.png", 1)
	addImg:setAnchorPoint(cc.p(0.5, 0.5))
	addImg:setPosition(cc.p(self._grid:getContentSize().width / 2, self._grid:getContentSize().height / 2 + 10))
	addImg:setScale(0.5)
	addImg:setVisible(false)
	self._addImg = addImg
	self._grid:addChild(addImg, 10)

	local addBtn = ccui.Button:create()
	addBtn:loadTextures("golbalIamgeUI5_add.png", "golbalIamgeUI5_add.png", "golbalIamgeUI5_add.png", 1)
	addBtn:setAnchorPoint(cc.p(0.5, 0.5))
	addBtn:setPosition(cc.p(self._grid:getContentSize().width / 2, self._grid:getContentSize().height / 2 + 10))
	addBtn:setScale(0.5)
	addBtn:setOpacity(0)
	addBtn:setVisible(false)
	self._addBtn = addBtn
	self._grid:addChild(addBtn, 10)
	registerClickEvent(addBtn, function ( sender )
		self:onShowBackupListDialog()
	end)

	self._canUseMC = mcMgr:createViewMC("kefangzhi_houyuanxitong", true)
	self._canUseMC:setVisible(false)
	self._canUseMC:setPosition(self._grid:getContentSize().width / 2, 40)
	self._grid:addChild(self._canUseMC, 1)

	self._item = nil
	self:makeBackupItem()
end

function BackupGrid:getMatchFormationBackupList(  )
	--云中城另一个编组的后援兵团数据
	local result = {}
	if self._container._formationView:isShowCloudInfo() then
		local formationId = self._formationModel.kFormationTypeCloud1 + self._formationModel.kFormationTypeCloud2 - self._container._formationType
		local data = self._container._formationView._layerLeft._teamFormation._data[formationId]
		local backupTs = data.backupTs or {}
		for k, v in pairs(backupTs) do
			for i = 1, 3 do
				local teamId = v["bt" .. i]
				if teamId and teamId ~= 0 and not table.indexof(result, teamId) then
					local sysTeam = tab:Team(teamId)
					if sysTeam.class == self._classType then
						table.insert(result, teamId)
					end
				end
			end
		end
	end
	return result
end

function BackupGrid:removeMatchFormationBackup( removeId )
	--去掉云中城另一个编组的后援兵团
	if self._container._formationView:isShowCloudInfo() then
		local formationId = self._formationModel.kFormationTypeCloud1 + self._formationModel.kFormationTypeCloud2 - self._container._formationType
		local data = self._container._formationView._layerLeft._teamFormation._data[formationId]
		local backupTs = data.backupTs or {}
		for k, v in pairs(backupTs) do
			for i = 1, 3 do
				local teamId = v["bt" .. i]
				if teamId and teamId ~= 0 and teamId == removeId then
					v["bt" .. i] = nil
				end
			end
		end
	end
end

function BackupGrid:onShowBackupListDialog(  )
	self._container._viewMgr:showDialog("backup.BackupListDialog", 
		{
			classType = self._classType,
			filterList = self:getSameClassTeamId(),
			sortList = self._container._sortList,
			formationType = self._container._formationType,
			matchBackupList = self:getMatchFormationBackupList(),
			callback = function ( teamId )
				if teamId == nil then return end
				self:removeMatchFormationBackup(teamId)
				self:teamOperate(teamId)
				self:showSuccessMC()
			end
		})
end

function BackupGrid:teamOperate( teamId )
	self:setBTValue(teamId, true)
	self:makeBackupItem()
end

-- 获取同阵容中同类型已上阵的兵团，上阵列表要过滤这些
function BackupGrid:getSameClassTeamId(  )
	local result = {}
	local classData = self._gridData.icon
	local btData = self._container._backupTs[tostring(self._gridData.id)]
	for k, v in pairs(classData) do
		if v[1] == self._classType then
			local value = btData["bt" .. k]
			if value and value ~= 0 then
				table.insert(result, value)
			end
		end
	end
	return result
end

function BackupGrid:addButtonVisible( isVisible )
	if not self._addBtn then return end
	if not self._addImg then return end
	if isVisible then
		self._addBtn:setVisible(true)
		self._addImg:setVisible(true)
		self._addImg:setScale(0.5)
		self._addImg:runAction(cc.RepeatForever:create(
			cc.Sequence:create(
		        cc.Spawn:create(cc.ScaleTo:create(1, 0.4), cc.FadeTo:create(1, 180)),
		        cc.Spawn:create(cc.ScaleTo:create(1, 0.5), cc.FadeTo:create(1, 255))
			)))
	else
		self._addBtn:setVisible(false)
		self._addImg:setVisible(false)
		self._addImg:stopAllActions()
	end
end

function BackupGrid:makeBackupItem(  )
	self._btValue = self:getBTValue()
	if self._btValue == nil then
		self:addButtonVisible(true)
		if self._item then
			self._item:setBackupGrid()
			self._item:removeFromParent()
			self._item = nil
		end
		return
	end

	self:addButtonVisible(false)
	if self._item == nil then
		self._item = BackupItem.new({container = self._container})
		self._item:setPosition(self._grid:getContentSize().width / 2, self._grid:getContentSize().height / 2)
		self._item:setBackupGrid(self)
		self._grid:addChild(self._item, 10)
	end
	self._item:reflashInfo(self._btValue)
end

function BackupGrid:setBackupItem( item )
	if self._item then
		self._item:setBackupGrid()
		self._item:removeFromParent()
		self:setBTValue(nil)
		self._item = nil
	end
	if item then
		item:retain()
		item:removeFromParent()
		self._item = item
        self._item:setPosition(self._grid:getContentSize().width / 2, self._grid:getContentSize().height / 2)
        self._item:setBackupGrid(self)
        self._grid:addChild(self._item, 10)
        self:setBTValue(self._item:getBTValue())
        item:release()
		self:addButtonVisible(false)
    end
end

function BackupGrid:showSuccessMC(  )
	local mc = mcMgr:createViewMC("fangzhitexiao_houyuanxitong", false, true)
	mc:setPosition(self._grid:getContentSize().width / 2, 50)
	self._grid:addChild(mc, 11)
end

function BackupGrid:setCanUseMC( flag )
	if self._canUseMC then
		self._canUseMC:setVisible(flag == true)
	end
end

function BackupGrid:getClassType(  )
	return self._classType
end

function BackupGrid:getBackupItem(  )
	return self._item
end

function BackupGrid:getGridWiget(  )
	return self._grid
end

function BackupGrid:getGridIndex(  )
	return self._gridIndex
end

-- 获取该位置兵团ID
function BackupGrid:getBTValue(  )
	-- return 805
	local value = self._container._backupTs[tostring(self._gridData.id)]["bt" .. self._btIndex]
	if value and value ~= 0 then
		return value
	end
	return nil
end

function BackupGrid:setBTValue( value, isReflash )
	self._container._backupTs[tostring(self._gridData.id)]["bt" .. self._btIndex] = value
	if isReflash then
		self._container:updateFightScore(true)
	end
end


return {BackupGrid, BackupItem}