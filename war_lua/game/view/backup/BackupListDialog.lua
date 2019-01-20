--[[
 	@FileName 	BackupListDialog.lua
	@Authors 	yuxiaojing
	@Date    	2018-04-24 10:46:32
	@Email    	<yuxiaojing@playcrab.com>
	@Description   描述
--]]

local BackupListDialog = class("BackupListDialog", BasePopView)

function BackupListDialog:ctor( params )
	self.super.ctor(self)
	self._classType = params.classType 			-- 兵团类型
	self._filterList = params.filterList or {} 	-- 过滤列表
	self._sortList = params.sortList or {} 		-- 排序列表
	self._formationType = params.formationType 	-- 布阵编组类型
	self._matchBackupList = params.matchBackupList or {}	-- 配对的编组共用一套兵团数据的时候
	self._callback = params.callback
end

function BackupListDialog:onInit(  )

	self._backupModel = self._modelMgr:getModel("BackupModel")
	self._formationModel = self._modelMgr:getModel("FormationModel")
	
	self:registerClickEventByName("bg.layer.btn_close", function ()
        self:close()
        UIUtils:reloadLuaFile("backup.BackupListDialog")
    end)
	UIUtils:setTitleFormat(self:getUI("bg.layer.titleImg.titleTxt"), 1)

	self:getUI('bg.layer.titleType.Image'):loadTexture('backup_icon' .. self._classType .. ".png", 1)
	self._tableBg = self:getUI("bg.layer.tableviewBG")
	self._itemCell = self:getUI("bg.layer.cellItem")
	self._cellHeight = 118
	self._cellWidth = 488

	-- 不同编组 不能使用的兵团 状态不同
	self._specTagName = "globalImageUI4_dead.png"
    if self._formationType == self._formationModel.kFormationTypeGuild then
        self._specTagName = "globalImageUI7_hurt.png"
    elseif self._formationType == self._formationModel.kFormationTypeAiRenMuWu or 
        self._formationType == self._formationModel.kFormationTypeZombie or
        self._formationType == self._formationModel.kFormationTypeCrossPKAtk1 or 
        self._formationType == self._formationModel.kFormationTypeCrossPKAtk2 or 
        self._formationType == self._formationModel.kFormationTypeCrossPKAtk3 or 
        self._formationType == self._formationModel.kFormationTypeCrossPKDef1 or 
        self._formationType == self._formationModel.kFormationTypeCrossPKDef2 or 
        self._formationType == self._formationModel.kFormationTypeCrossPKDef3 then
        self._specTagName = "team_forbidden_forma.png"
    end

    -- 配对的编组标签
    self._matchTagName = "flag_light_forma.png"
    if self._formationType == self._formationModel.kFormationTypeCloud1 then
    	self._matchTagName = "flag_dark_forma.png"
    end

	self._teamModel = self._modelMgr:getModel("TeamModel")

	local allTeamData = clone(self._teamModel:getHaveTeamWithClass(self._classType))

	self._teamData = {}
	local t1 = {}
	local t2 = {}

	for k, v in pairs(allTeamData) do
		if not table.indexof(self._filterList, v.teamId) then
			if table.indexof(self._sortList, v.teamId) then
				v.specTag = 1
				table.insert(t2, v)
			else
				if table.indexof(self._matchBackupList, v.teamId) then
					v.matchTag = 1
				end
				table.insert(t1, v)
			end
		end
	end

	table.sort(t1, function ( data1, data2 )
		return data1.score > data2.score
	end)

	table.sort(t2, function ( data1, data2 )
		return data1.score > data2.score
	end)

	for k, v in pairs(t1) do
		self._teamData[#self._teamData + 1] = v
	end

	for k, v in pairs(t2) do
		self._teamData[#self._teamData + 1] = v
	end

	self:createTableView()
end

function BackupListDialog:createTableView(  )
	local tableView = cc.TableView:create(cc.size(488, 413))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(0,0))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    self._tableBg:addChild(tableView)

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

function BackupListDialog:cellSizeForTable( table, idx )
	return self._cellHeight, self._cellWidth
end

function BackupListDialog:numberOfCellsInTableView( table )
	return math.ceil(#self._teamData / 2)
end

function BackupListDialog:tableCellAtIndex( table, idx )
	local cell = table:dequeueCell()
	if nil == cell then
		cell = cc.TableViewCell:new()
	end

	local itemCell = cell:getChildByFullName("itemCell")
	if tolua.isnull(itemCell) then
		itemCell = self._itemCell:clone()
		itemCell:setPosition(0, 0)
		itemCell:setCascadeOpacityEnabled(true, true)
		itemCell:setSwallowTouches(false)
		itemCell:setName("itemCell")
		itemCell:setVisible(true)
		cell:addChild(itemCell, 999)
	end

	self:updateCellInfo(cell, idx)

	return cell
end

function BackupListDialog:updateCellInfo( cellItem, idx )
	local cell = cellItem:getChildByFullName('itemCell')
	local index = idx * 2
	for i = 1, 2 do
		local data = self._teamData[index + i]
		local cellItem = cell:getChildByFullName('cellItem' .. i)
		if data then
			local isGray = false
			if data.specTag and data.specTag == 1 then
				isGray = true
			end
			local sysTeam = tab:Team(data.teamId)
			cellItem:setVisible(true)
			cellItem:getChildByFullName('fightLab'):setString("战斗力:" .. data.score)
			local backQuality = self._teamModel:getTeamQualityByStage(data["stage"])
			local teamName, art1, art2, art3 = TeamUtils:getTeamAwakingTab(data)
			cellItem:getChildByFullName('name'):setString(lang(teamName))
			cellItem:getChildByFullName('name'):setColor(UIUtils.colorTable["ccColorQuality" .. backQuality[1]])
        	cellItem:getChildByFullName('name'):enableOutline(UIUtils.colorTable["ccColorQualityOutLine" .. backQuality[1]], 1)

        	local iconBg = cellItem:getChildByFullName('iconBg')
        	local icon = iconBg:getChildByFullName('teamIcon')
        	if icon == nil then
        		icon = IconUtils:createTeamIconById({teamData = data, sysTeamData = sysTeam, quality = backQuality[1], quaAddition = backQuality[2], eventStyle = 0})
		        icon:setName("teamIcon")
		        icon:setPosition(cc.p(iconBg:getContentSize().width / 2, iconBg:getContentSize().height / 2))
		        icon:setAnchorPoint(cc.p(0.5, 0.5))
		        icon:setScale(0.90)
		        iconBg:addChild(icon)
        	else
        		IconUtils:updateTeamIconByView(icon, {teamData = data, sysTeamData = sysTeam, quality = backQuality[1], quaAddition = backQuality[2], eventStyle = 0})
        	end
        	icon:setSaturation(isGray and -100 or 0)

        	registerTouchEvent(icon, function()
		    end,function()
		    end,function()
		        ViewManager:getInstance():showDialog("formation.NewFormationDescriptionView", {iconType = 1, iconId = data.teamId or sysTeam.id}, true)
		    end)
		    
        	icon:setSwallowTouches(false)

        	local specTagImg = iconBg:getChildByFullName('specTagImg')
        	if specTagImg == nil then
        		specTagImg = ccui.ImageView:create(self._specTagName, 1)
        		specTagImg:setName('specTagImg')
        		specTagImg:setAnchorPoint(cc.p(0.5, 0.5))
        		specTagImg:setPosition(iconBg:getContentSize().width / 2, iconBg:getContentSize().height / 2)
        		iconBg:addChild(specTagImg)
        	end
        	specTagImg:setVisible(isGray)

        	local matchTagImg = iconBg:getChildByFullName('matchTagImg')
        	if matchTagImg ==nil then
        		matchTagImg = ccui.ImageView:create(self._matchTagName, 1)
        		matchTagImg:setName('matchTagImg')
        		matchTagImg:setAnchorPoint(cc.p(0.5, 0.5))
        		matchTagImg:setPosition(iconBg:getContentSize().width / 2, iconBg:getContentSize().height / 2)
        		iconBg:addChild(matchTagImg)
        	end
        	matchTagImg:setVisible(data.matchTag and data.matchTag == 1)

        	local img_use = cellItem:getChildByFullName('img_use')
        	if self._backupModel:isTeamUsing(data.teamId) then
        		img_use:setVisible(true)
        	else
        		img_use:setVisible(false)
        	end

        	local btn_fight = cellItem:getChildByFullName('btn_fight')
        	self:registerClickEvent(btn_fight, function (  )
        		if self._callback then
        			self._callback(data.teamId)
        		end
        		self:close()
        		UIUtils:reloadLuaFile("backup.BackupListDialog")
        	end)
        	btn_fight:setEnabled(not isGray)
        	UIUtils:setGray(btn_fight, isGray)
		else
			cellItem:setVisible(false)
		end
	end
end

function BackupListDialog:onDestroy()
	self.super.onDestroy(self)
end

function BackupListDialog:getAsyncRes( )
	return {

	}
end

return BackupListDialog