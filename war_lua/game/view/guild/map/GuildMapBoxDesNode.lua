--[[
    Filename:    GuildMapBoxDesNode.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2016-6-27 17:53:10
    Description: 宝箱说明界面
--]]


local GuildMapBoxDesNode = class("GuildMapBoxDesNode", BasePopView)

function GuildMapBoxDesNode:ctor(param)
    GuildMapBoxDesNode.super.ctor(self)
    self._guildMapModel = self._modelMgr:getModel("GuildMapModel")
    self._taskID = param.taskId
    self._eleId = param.eleId
end

function GuildMapBoxDesNode:onInit()
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("guild.map.GuildMapBoxDesNode")
        elseif eventType == "enter" then 
        end
    end)    

	local title = self:getUI("bg.titlebg.Label_35")
    UIUtils:setTitleFormat(title, 1)
    -- title:setFontName(UIUtils.ttfName)

    self:registerClickEventByName("bg.getBtn", function()
			self:close()
		end)
    self:registerClickEventByName("bg.closeBtn", function()
			self:close()
		end)

    self:reflashUI()
end

function GuildMapBoxDesNode:reflashUI()
	local guildMapData = self._modelMgr:getModel("GuildMapModel"):getData()
    local sysGuildMapTask = tab.guildMapTask[self._taskID] 
    local desNode = self:getUI("bg.desNode")
    local tipDes = ""
    
    local taskT1 = GuildConst.TASK_TYPE.GUILD_MAP_ST_FIND_XUEZHE
    local taskT2 = GuildConst.TASK_TYPE.GUILD_MAP_ST_FIND_BOX
    local taskType = sysGuildMapTask.condition

    --寻找小精灵
    if taskType == taskT1 then
        local tipTemp = sysGuildMapTask["des"] or "GUILDMAPTASKDES_"..self._taskID
        tipDes = lang(tipTemp)
        local goGuildName = self._guildMapModel:getPassGuildName()
        tipDes = string.gsub(tipDes, "${name}", goGuildName)

    --寻找宝箱
    elseif taskType == taskT2 then
        if guildMapData["spTaskData"] and guildMapData["spTaskData"]["sp3"] then
            local buildData = guildMapData["spTaskData"]["sp3"]
            local buildId = buildData["id"]
            local buildPos = buildData["pos"]
            local sysData = tab.guildMapThing[buildId]

            local posType = 1
            for i,v in ipairs(sysData["ranposi"]) do
                local posStr = v[1] .. "," .. v[2]
                if posStr == buildPos then
                    posType = i
                end
            end
            
            tipDes = lang("GUILDMAPTASKDES_"..self._taskID)
            local goGuildName = self._guildMapModel:getPassGuildName()
            tipDes = string.gsub(tipDes, "${name}", goGuildName)
            tipDes = string.gsub(tipDes, "${posi}", lang("SPOSI_GUILDBOX_"..self._taskID .. "_"..posType))
        end
    else
        tipDes = lang(tab.guildMapTask[self._taskID].des)
    end

    if desNode ~= nil and tipDes ~= nil then 
        if string.find(tipDes, "color=") == nil then
            tipDes = "[color=3c2a1e]"..tipDes.."[-]"
        end          
        local rtx = RichTextFactory:create(tipDes,desNode:getContentSize().width,desNode:getContentSize().height)
        rtx:formatText()
        rtx:setVerticalSpace(3)
        rtx:setAnchorPoint(cc.p(0,0.5))
        rtx:setPosition(-rtx:getInnerSize().width/2,desNode:getContentSize().height/2)
        desNode:addChild(rtx)
    end

	local taskDes = self:getUI("bg.taskBg.des")
	-- dump(guildMapData["mapStatis"], "111", 10)
    local userModelData = self._modelMgr:getModel("UserModel"):getData()
	local currNum = userModelData["mapStatis"] and (userModelData["mapStatis"][tostring(sysGuildMapTask.condition)] or 0) or 0
    local maxNum = sysGuildMapTask.conditionNum
	taskDes:setString("当前进度  ".. math.min(currNum, maxNum) .."/" .. maxNum)
	taskDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	taskDes:setFontSize(20)
	
	self:showItems(tab.guildMapTask[self._taskID].award)
end


function GuildMapBoxDesNode:showItems(inItems)
	if inItems == nil then
		return
	end
    local tips1 = {}
    local index = 1
    for k,v in pairs(inItems) do
        local itemType = v[1]
        local itemId = v[2]
        local itemNum = v[3]
        if itemType ~= "tool" then
            itemId = IconUtils.iconIdMap[itemType]
        end
        local itemData = tab:Tool(itemId)
        local itemIcon = IconUtils:createItemIconById({itemId = itemId, num = itemNum, itemData = itemData})       
        itemIcon:setScale(0.8)
        tips1[k] = itemIcon
    end

    local nodeTip1 = UIUtils:createHorizontalNode(tips1, nil, false, 10)
    nodeTip1:setAnchorPoint(cc.p(0.5, 0.5))
    local taskIcon = self:getUI("bg.taskBg.icon")
    nodeTip1:setPosition(taskIcon:getPosition())
    taskIcon:getParent():addChild(nodeTip1)
end


return GuildMapBoxDesNode