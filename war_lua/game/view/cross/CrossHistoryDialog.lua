--[[
    Filename:    CrossHistoryDialog.lua
    Author:      <lannan@playcrab.com>
    Datetime:    2016-04-27 21:29:47
    Description: File description
--]]

local CrossHistoryDialog = class("CrossHistoryDialog", BasePopView)

local l_winImg = {
	[0] = "winlose_2_battle.png",
	[1] = "winlose_1_battle.png",
}


function CrossHistoryDialog:ctor(data)
    CrossHistoryDialog.super.ctor(self)
	self._crossData = data.crossData
end

function CrossHistoryDialog:getAsyncRes()
    return 
    {
        {"asset/ui/battle4.plist", "asset/ui/battle4.png"},
    }
end

function CrossHistoryDialog:onInit()
	local closeBtn = self:getUI("bg.closeBtn")
	self:registerClickEvent(closeBtn, function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("cross.CrossHistoryDialog")
        end
		self:close()
	end)
	self._campNode = {}
	for index=1, 2 do
		local tbNode = {}
		local rootNode = self:getUI("bg.tableBg.campRoot"..index)
		tbNode.nameLab = rootNode:getChildByFullName("campNameLab")
		tbNode.serverNameLab = rootNode:getChildByFullName("fightCampLab")
		tbNode.scoreNode = {}
		for i=1,4 do
			local node = {
				winImg = rootNode:getChildByFullName("resultImg"..i),
				scoreLab = rootNode:getChildByFullName("resultLab"..i),
				lastImg = rootNode:getChildByFullName("lastImg"..i)
			}
			table.insert(tbNode.scoreNode, node)
		end
		tbNode.levelLab = rootNode:getChildByFullName("levelLab")
		tbNode.noScoreLab = rootNode:getChildByFullName("noScoreLab")
		self._campNode[index] = tbNode
	end
	self:initHistoryData()
	
	local ruleBtn = self:getUI("bg.headBg.ruleBtn")
	self:registerClickEvent(ruleBtn, function()
		if OS_IS_WINDOWS then
			UIUtils:reloadLuaFile("cross.CpHistoryRuleDialog")
		end
		self._viewMgr:showDialog("cross.CpHistoryRuleDialog")
	end)
end

function CrossHistoryDialog:initHistoryData()
	local serverName1, serverName2 = self._modelMgr:getModel("CrossModel"):getWarZoneName(true)
	local tbServerName = {
		[1] = serverName1,
		[2] = serverName2
	}
	for index,v in ipairs(self._campNode) do
		local crossData = self._crossData[index]
		v.levelLab:setString(crossData.level or 0)
		v.serverNameLab:setString(tbServerName[index])
		local noScoreCount = 0
		for i,vv in ipairs(v.scoreNode) do
			if crossData.score and crossData.score[i] then
				vv.winImg:loadTexture(l_winImg[crossData.win[i]], 1)
				local score = ItemUtils.formatItemCount(crossData.score[i], "w")
				vv.scoreLab:setString(score)
				vv.winImg:setVisible(true)
				vv.scoreLab:setVisible(true)
				if i == #crossData.score then
					vv.lastImg:setVisible(true)
				else
					vv.lastImg:setVisible(false)
				end
			else
				noScoreCount = noScoreCount + 1
				vv.winImg:setVisible(false)
				vv.scoreLab:setVisible(false)
				vv.lastImg:setVisible(false)
			end
		end
		v.noScoreLab:setVisible(noScoreCount==4)
	end
end

return CrossHistoryDialog