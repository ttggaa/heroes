--[[
 	@FileName 	BackupModel.lua
	@Authors 	yuxiaojing
	@Date    	2018-04-17 17:23:45
	@Email    	<yuxiaojing@playcrab.com>
	@Description   描述
--]]

--[[

	数据结构
	backup
	{
		lv = 1,			等级
		exp = 1,		经验
		slv1 = 1, 		技能1等级
		slv2 = 2,		技能2等级
		score = 100,	战力
		as = 200		全局战力
	}

]]

local BackupModel = class("BackupModel", BaseModel)

function BackupModel:ctor(  )
	BackupModel.super.ctor(self)

	self._userModel = self._modelMgr:getModel("UserModel")
	self._teamModel = self._modelMgr:getModel("TeamModel")
	self._itemModel = self._modelMgr:getModel("ItemModel")

	self._data = {}
	self._backupData = {}
	self._teamUsing = {}
end

function BackupModel:updateData( data )

	for k, v in pairs(data) do
		self._backupData[k] = clone(v)
	end

end

function BackupModel:setBackupData( data )
	self._backupData = {}
	self._backupData = data
end

function BackupModel:getBackupData(  )
	return clone(self._backupData)
end

function BackupModel:getBackupById( id )
	return clone(self._backupData[id .. ""])
end

function BackupModel:setUsingTeamList( value )
	self._teamUsing = value or {}
end

-- 该兵团是否正在布阵中使用
function BackupModel:isTeamUsing( teamId )
	if table.indexof(self._teamUsing, teamId) then
		return true
	end
	return false
end

-- 使用中的阵容是否有空位
function BackupModel:isHaveEmptySeat( backupTs, bid, noUseList, teamUsing )
	if backupTs == nil or bid == nil then
		return true
	end
	local tsData = backupTs[tostring(bid)]
	if tsData == nil then 
		return true
	end
	local function sameClassTeamList( classData, classType, tsData )
		local filterList = {}
		for k, v in pairs(classData) do
			if v[1] == classType then
				local value = tsData["bt" .. k]
				if value and value ~= 0 then
					table.insert(filterList, value)
				end
			end
		end
		return filterList
	end
	local function isHaveCanUseTeamId( allTeamData, filterList, noUseList, teamUsing )
		for k, v in pairs(allTeamData) do
			local teamId = v.teamId
			if not table.indexof(filterList, teamId) and 
				not table.indexof(noUseList, teamId) and 
				not table.indexof(teamUsing, teamId) then
				return true
			end
		end
		return false
	end
	local sysData = tab.backupMain[tonumber(bid)]
	local classData = sysData.class or {}

	for i = 1, 3 do
	    local teamId = tsData["bt" .. i]
	    local class = classData[i][1]
	    local allTeamData = clone(self._teamModel:getHaveTeamWithClass(class))
	    local filterList = sameClassTeamList(classData, class, tsData)
	    if (not teamId or teamId == 0) and isHaveCanUseTeamId(allTeamData, filterList, noUseList, teamUsing) then
	    	return true
	    end
	end
	return false
end

-- 使用中的阵容是否存在冲突兵团
function BackupModel:isHaveConflictTeam( backupTs, bid, teamUsing )
	if backupTs == nil or bid == nil then
		return false
	end
	local tsData = backupTs[tostring(bid)]
	if tsData == nil then 
		return false
	end
	for i = 1, 3 do
		local teamId = tsData["bt" .. i]
		if teamId and teamId ~= 0 and table.indexof(teamUsing, teamId) then
			return true
		end
	end
	return false
end

function BackupModel:isOpen(  )
	local tabData = tab:SystemOpen("Backup")
	local openLevel = tabData[1]
	local playerLevel = self._userModel:getData().lvl
	if playerLevel >= openLevel then
		return true
	end
	return false
end

-- 养成 阵容 红点提示
function BackupModel:redPointPrompt(  )
	local result = {}
	local specSkillMaxlv = tab.setting["backupLevelMax"].value
	local userData = self._userModel:getData()
	local userBU = userData.texp or 0
	for k, v in pairs(self._backupData) do
		local sysData = tab.backupMain[tonumber(k)]
		local isRed = false
		-- #627 要求去掉
		-- special skill
		local specialSkillLv = v.lv or 1
		-- if specialSkillLv < specSkillMaxlv then
		-- 	local specialSkillExp = v.exp or 0
		-- 	local levelupData = tab.backupLevelup[specialSkillLv] or {}
		-- 	local needExp = levelupData.levelupExp
		-- 	if needExp - specialSkillExp <= userBU then
		-- 		isRed = true
		-- 	end
		-- end

		-- skill1
		local slv1 = v.slv1 or 1
		local levelupData = tab.backupSkillLevelup[slv1] or {}
		local needNum = levelupData.skill1Item[1][3]
		local _, curNum = self._itemModel:getItemsById(levelupData.skill1Item[1][2])
		-- local curNum = self._userModel:getResNumByType(levelupData.skill1Item[1][1])
		if slv1 < specialSkillLv and curNum >= needNum and slv1 < specSkillMaxlv and specialSkillLv >= sysData.skill1Unlock then
			isRed = true
		end

		-- skill2
		local slv2 = v.slv2 or 1
		local levelupData = tab.backupSkillLevelup[slv2] or {}
		local needNum = levelupData.skill2Item[1][3]
		local _, curNum = self._itemModel:getItemsById(levelupData.skill2Item[1][2])
		-- local curNum = self._userModel:getResNumByType(levelupData.skill2Item[1][1])
		if slv2 < specialSkillLv and curNum >= needNum and slv2 < specSkillMaxlv and specialSkillLv >= sysData.skill2Unlock then
			isRed = true
		end

		if isRed then
			table.insert(result, k)
		end
	end
	return result
end

function BackupModel:showBackupGradeView(  )
	if self._backupData and #self._backupData > 0 then
		self._viewMgr:showView("backup.BackupGrowView")
		return
	end
	self._serverMgr:sendMsg("BackupServer", "getBackupInfo", {}, true, {}, function(success, data)
    	self._viewMgr:showView("backup.BackupGrowView")
    end, function ( errorId )
        errorId = tonumber(errorId)
        print("errorId:" .. errorId)
        self._viewMgr:unlock()
    end)
end

function BackupModel:showBackupFormationDialog( params )
	if self._backupData and #self._backupData > 0 then
		self._viewMgr:showView("backup.BackupFormationDialog", params)
		return
	end
	self._serverMgr:sendMsg("BackupServer", "getBackupInfo", {}, true, {}, function(success, data)
    	self._viewMgr:showDialog("backup.BackupFormationDialog", params)
    end, function ( errorId )
        errorId = tonumber(errorId)
        print("errorId:" .. errorId)
        self._viewMgr:unlock()
    end)
end

function BackupModel:clearBackupThumb( cell )
	local grid4 = cell:getChildByFullName('formation.grid4')
	local grid9 = cell:getChildByFullName('formation.grid9')
	grid4:setVisible(false)
	grid9:setVisible(false)
	for i = 1, 9 do
		local item = grid4:getChildByFullName('formation_icon_' .. i)
		if item then
			item:removeAllChildren()
		end
		local item = grid9:getChildByFullName('formation_icon_' .. i)
		if item then
			item:removeAllChildren()
		end
	end
end

--根据配表icon规则获取缩略图展示的格子
function BackupModel:handleBackupThumb( cell, class )
	local grid4 = cell:getChildByFullName('formation.grid4')
	local grid9 = cell:getChildByFullName('formation.grid9')
	grid4:setVisible(false)
	grid9:setVisible(false)
	local dataIcon = class
	local lIndex = {1, 2, 4, 5}
	local grid = grid4
	for k, v in pairs(dataIcon) do
		if not table.indexof(lIndex, v[2]) then
			grid = grid9
		end
	end
	grid:setVisible(true)
	formationIcons = {}
	for i = 1, 9 do
		local item = grid:getChildByFullName('formation_icon_' .. i)
		if item then
			item:removeAllChildren()
		end
		formationIcons[i] = item
	end
	return formationIcons, grid
end

--[[
	
	阵容处理
	@param icons 16个小格子
	@param class 阵容数据
	
]]
function BackupModel:handleFormation( icons, class )
	if icons == nil or #icons <= 0 then return end
	local classLabel = {"tl_shuchu.png", "tl_fangyu.png", "tl_tuji.png", "tl_yuancheng.png", "tl_mofa.png"}
	local function getCalssType( pos )
		if class then
			for k, v in pairs(class) do
				if v[2] == pos then
					return v[1]
				end
			end
		end
		return nil
	end
	for i = 1, #icons do
		local icon = icons[i]
		if icon then
			icon:removeAllChildren()
			local classType = getCalssType(i)
			if classType then
				local imageView = ccui.ImageView:create(IconUtils.iconPath .. classLabel[classType], 1)
				local scale = icon:getContentSize().width / imageView:getContentSize().width
				imageView:setScale(scale)
				imageView:setPosition(cc.p(icon:getContentSize().width / 2, icon:getContentSize().height / 2))
	            icon:addChild(imageView)
			end
		end
	end
end

function BackupModel:containsPoint( widget, pos )
	local position = widget:convertToNodeSpace(pos)
	local size = widget:getContentSize()
	local rect = cc.rect(0, 0, size.width * widget:getScaleX(), size.height * widget:getScaleY())
	if cc.rectContainsPoint(rect, position) then
		return true
	end
	return false
end

-- 根据记录在服务器端的pos计算移动后兵团的真正位置
function BackupModel:calClassData( classData, pos )
	local gridRow = 4
	local minRow = 1
	local maxRow = 4

	local minPos = 16
	local maxPos = 0
	for k, v in pairs(classData) do
		if v[2] < minPos then
			minPos = v[2]
		end
		if v[2] > maxPos then
			maxPos = v[2]
		end
	end
	local minPosRow = math.ceil(minPos / gridRow)
	local maxPosRow = math.ceil(maxPos / gridRow)
	pos = pos or minPosRow
	local changeRow = pos - minPosRow
	for k, v in pairs(classData) do
		v[2] = v[2] + (changeRow * gridRow)
	end

	local isUp = (minPosRow + changeRow - 1) >= minRow
	local isDown = (maxPosRow + changeRow + 1) <= maxRow

	return classData, isUp, isDown, pos
end

function BackupModel:setBackupTs( ts, id, key, value )
	ts = ts or {}
	if not ts[id] then
		ts[id] = {}
	end
	ts[id][key] = value
end

--获取后援增加的英雄四维属性
function BackupModel:getBackUpAddAtr()
	local backupData = self:getBackupData()
	local backUpAtr = {}
	if backupData and next(backupData) then
        for key, var in pairs(backupData) do
            if var then
                local slv2 = var["slv2"] or 1
                local hformationDataTemp = tab.backupMain[tonumber(key)]
                local _nUnckSk2 = tonumber(hformationDataTemp.skill2Unlock or 1)
                local _nBaForLv = tonumber(var.lv or 1)
                if  _nBaForLv >= _nUnckSk2 then
                    if hformationDataTemp and hformationDataTemp["skill2Self"] then
                        local hattr = hformationDataTemp["skill2Self"]
                        for k = 1, #hattr do
                            local _attr = hattr[k][1]
                            local _value = hattr[k][2] + hattr[k][3] * (slv2 - 1)
                            if backUpAtr[_attr] then
                            	backUpAtr[_attr] = backUpAtr[_attr] + _value
                            else
                            	backUpAtr[_attr] = _value
                            end
                            
                        end
                    end
                end
            end
        end
	end
	return backUpAtr
end

function BackupModel:getBackupLevelReachNum( level )
	local res = 0
	if not level or type(level) ~= "number" then
		return res
	end
	local backupData = self:getBackupData()
	if backupData and next(backupData) then
		for k, v in pairs(backupData) do
			if v and v.lv and v.lv >= level then
				res = res + 1
			end
		end
	end
	return res
end

function BackupModel:getSkillLevelReachNum1( level )
	local res = 0
	if not level or type(level) ~= "number" then
		return res
	end
	local backupData = self:getBackupData()
	if backupData and next(backupData) then
		for k, v in pairs(backupData) do
			if v and v.slv1 and v.slv1 >= level then
				res = res + 1
			end
		end
	end
	return res
end

function BackupModel:getSkillLevelReachNum2( level )
	local res = 0
	if not level or type(level) ~= "number" then
		return res
	end
	local backupData = self:getBackupData()
	if backupData and next(backupData) then
		for k, v in pairs(backupData) do
			if v and v.slv2 and v.slv2 >= level then
				res = res + 1
			end
		end
	end
	return res
end

return BackupModel