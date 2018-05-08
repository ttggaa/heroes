--[[
    Filename:    PlayerSkillComposeModel.lua
    Author:      <libolong@playcrab.com>
    Datetime:    2015-06-04 11:13:15
    Description: File description
--]]

local PlayerSkillComposeModel = class("PlayerSkillComposeModel", BaseModel)

local SkillItemType = {
	element = 1, -- 元素
	nature = 2, -- 自然
	arcane = 3, -- 奥术
	dark = 4, -- 黑暗
	light = 5 -- 光明
}

function PlayerSkillComposeModel:ctor()
    PlayerSkillComposeModel.super.ctor(self)
    self._data = {}
    self:initData()
end

--[[
--! @function processData
--! @desc 处理数据（临时）
--! @param inData table 追加数据集合
--! @return table
--]]
function PlayerSkillComposeModel:processData(inData)
	local backData = {}
	for k1,v1 in pairs(inData) do
		local tempData = {}
		tempData["skillId"] = v1.id
		tempData["type"] = v1.type
		if v1.down ~= nil then
			tempData["down"] = {}
			for k2,v2 in ipairs(v1.down) do
				tempData["down"][k2] = v2
			end
		end
		if v1.up ~= nil then
			tempData["up"] = {}
			for k2,v2 in ipairs(v1.up) do
				tempData["up"][k2] = v2
			end
		end
		table.insert(backData,tempData)
	end
	return backData
end

--[[
--! @function getExpProp
--! @desc 获取技能背包内的元素
--! @return table 获取物品数据集合
--]]
function PlayerSkillComposeModel:getElementSkills()
	return self:getItemsByType(SkillItemType.element)
end

--[[
--! @function getExpProp
--! @desc 获取技能背包内的自然
--! @return table 获取物品数据集合
--]]
function PlayerSkillComposeModel:getNatureSkills()
	return self:getItemsByType(SkillItemType.nature)
end

--[[
--! @function getExpProp
--! @desc 获取技能背包内的奥术
--! @return table 获取物品数据集合
--]]
function PlayerSkillComposeModel:getArcaneSkills()
	return self:getItemsByType(SkillItemType.arcane)
end

--[[
--! @function getExpProp
--! @desc 获取技能背包内的黑暗
--! @return table 获取物品数据集合
--]]
function PlayerSkillComposeModel:getDarkSkills()
	return self:getItemsByType(SkillItemType.dark)
end

--[[
--! @function getExpProp
--! @desc 获取技能背包内的光明
--! @return table 获取物品数据集合
--]]
function PlayerSkillComposeModel:getLightSkills()
	return self:getItemsByType(SkillItemType.light)
end

--[[
--! @function getItemByType
--! @desc 根据物品类型获取技能背包内物品数据和总数
--! @param inType int 物品类型
--! @return tempItems table 获取物品数据集合
--]]
function PlayerSkillComposeModel:getItemsByType(inType)
	local tempItems = {}
	for k,v in pairs(self._data) do
		if v.type == inType then
			table.insert(tempItems,v)
		end
	end
	return tempItems
end

function PlayerSkillComposeModel:setData(data)
	local backData = self:processData(data)
    self._data = backData
    self:reflashData()
end

function PlayerSkillComposeModel:getData()
    return self._data
end

function PlayerSkillComposeModel:initData()
    local sysPSCompositionDatas = tab.playerSkillComposition
    self:setData(sysPSCompositionDatas)
end

return PlayerSkillComposeModel