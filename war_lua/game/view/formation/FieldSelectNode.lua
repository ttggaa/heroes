--[[
 	@FileName 	FieldSelectNode.lua
	@Authors 	yuxiaojing
	@Date    	2018-09-05 18:20:56
	@Email    	<yuxiaojing@playcrab.com>
	@Description   描述
--]]

local FieldSelectNode = class("FieldSelectNode", BaseLayer)
function FieldSelectNode:ctor(param)
    self.super.ctor(self)
    if not param then
        param = {}
    end
    self._callback  = param.callback
end

function FieldSelectNode:onInit()
	self._teamModel = self._modelMgr:getModel("TeamModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._formationModel = self._modelMgr:getModel("FormationModel")

    self._pokCell = self:getUI("bg.cell")
    self._pokCell:setVisible(false)
    self:addTableView()
end

function FieldSelectNode:reflashUI(data, hireTeamData)
    self._formationId = data or 1
    local teamTableData = {}
    self._tableData, teamTableData = self._formationModel:getFieldSkillList(hireTeamData)
    local formationData = self._formationModel:getFormationDataByType(self._formationId)
    local areaSkillTeamStr = formationData.areaSkillTeam
    self._usedSkill = {}
    if areaSkillTeamStr then
        self._usedSkill = string.split(areaSkillTeamStr, ",")
    end
    -- 处理曾经选择的雇佣兵领域技能 start --
    if self._usedSkill and #self._usedSkill > 0 then
        local hireId = nil
        for k, v in pairs(self._usedSkill) do
            if not table.indexof(teamTableData, tonumber(v)) then
                hireId = k
            end
        end
        if hireId then
            table.remove(self._usedSkill, hireId)
            self:saveData()
        end
    end
    -- 处理曾经选择的雇佣兵领域技能 end --
    self._tableView:reloadData()
end

function FieldSelectNode:addTableView()
    local tableViewBg = self:getUI("bg.tableViewBg")
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height))
    self._tableView:setDelegate()
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(0, -5)
    self._tableView:registerScriptHandler(function(table, cell) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:setBounceable(false)

    tableViewBg:addChild(self._tableView)
end

function FieldSelectNode:tableCellTouched(table,cell)
    -- self._viewMgr:showDialog("guild.GuildScienceDetailDialog", {detailData = nil})
end

function FieldSelectNode:cellSizeForTable(table,idx) 
    local width = 400
    local height = 96
    return height, width
end

function FieldSelectNode:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local indexId = idx + 1
    if nil == cell then
        cell = cc.TableViewCell:new()
        for i = 1,2 do
            local pokCell = self._pokCell:clone() 
            pokCell:setAnchorPoint(0,0)
            if i == 1 then
                pokCell:setPosition(5,0) 
            else
                pokCell:setPosition(275,0) 
            end
            pokCell:setName("pokCell" .. i)
            cell:addChild(pokCell)
            cell["pokCell" .. i] = pokCell
        end
    end
    self:updateCell(cell, indexId)  
    return cell
end

function FieldSelectNode:numberOfCellsInTableView(table)
    return math.ceil(#self._tableData / 2)
end

function FieldSelectNode:updateCell(inView, indexLine)    
    for i = 1, 2 do
        local indexId = (indexLine - 1) * 2 + i
        local pokCell = inView["pokCell" .. i]
        self:updateFormationCell(pokCell, indexId, i)
    end
end

function FieldSelectNode:updateFormationCell(inView, indexId, cellNum)
    local data = self._tableData[indexId]
    if not data then 
    	inView:setVisible(false)
    	return
    else
    	inView:setVisible(true)
    end
    local tname = inView:getChildByFullName("tname")
    local checkBox = inView:getChildByFullName("checkBox")
    local icon = inView:getChildByFullName("icon")

    local skillType = data[1]
	local skillId = data[2]
    local teamId = data[3]
	local sysSkill = SkillUtils:getTeamSkillByType(skillId, skillType)

    local sysTeamData = tab.team[teamId] or {}
    local iconName = "globalImgUI_class" .. (sysTeamData.race[1] - 100) .. ".png"
    icon:loadTexture(iconName, 1)

	tname:setString(lang(sysSkill.name))
	checkBox:setSelected(not not table.indexof(self._usedSkill, tostring(teamId)))
	checkBox:addEventListener(function (_, state)
        if state == 1 then
            table.removebyvalue(self._usedSkill, tostring(teamId))
            self:saveData()
        else
            if #self._usedSkill >= 3 then
                self._viewMgr:showTip("最多选择3个")
                checkBox:setSelected(false)
                return
            end
            table.insert(self._usedSkill, tostring(teamId))
            self:saveData()
        end
	end)
end

function FieldSelectNode:saveData(  )
    self._serverMgr:sendMsg("FormationServer", "setAreaSkillTeam", {ids = self._usedSkill, id = self._formationId}, true, {}, function ( result )
        if result.d and result.d.formations and result["d"]["formations"][tostring(self._formationId)] and result["d"]["formations"][tostring(self._formationId)]["areaSkillTeam"] then
            if self._callback then
                self._callback(result["d"]["formations"][tostring(self._formationId)]["areaSkillTeam"])
            end
        end
        if result.unset then
            for k, v in pairs(result.unset) do
                if string.find(k, ".") ~= nil then
                    local temp = string.split(k, "%.")
                    if temp[1] == "formations" and #temp == 3 and temp[2] == tostring(self._formationId) then
                        if self._callback then
                            self._callback(nil)
                        end
                        return
                    end
                end
            end
        end
    end)
end

return FieldSelectNode