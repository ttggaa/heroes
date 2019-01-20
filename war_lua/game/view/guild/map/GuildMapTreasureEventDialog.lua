
--author lannan

local GuildMapTreasureEventDialog = class("GuildMapTreasureEventDialog", BasePopView, require("game.view.guild.map.GuildMapCommonBattle"))

function GuildMapTreasureEventDialog:ctor(param)
    GuildMapTreasureEventDialog.super.ctor(self)
	self._guildMapModel = self._modelMgr:getModel("GuildMapModel")
	self._treasureType = param.treasureType
	self._eventKey = param.treasureEventKey
	self._targetId = param.targetId
	self._treasureData = param.treasureData
	self._eleTypeName = param.typeName
end

function GuildMapTreasureEventDialog:onInit()
	local closeBtn = self:getUI("bg")
	self:registerClickEvent(closeBtn, function()
		if OS_IS_WINDOWS then
			UIUtils:reloadLuaFile("guild.map.GuildMapTreasureEventDialog")
		end
--		self:close()
	end)
	
	self._eventTab = tab.guildMapTreasureEvent[self._eventKey]
	
	local titleLab = self:getUI("bg.textBg.titleText")--标题文本
	titleLab:setString(lang(self._eventTab.eventTitle))
	local desLab = self:getUI("bg.textBg.descText")--描述文本
	desLab:setString(lang(self._eventTab.eventStory))
	
	local selectPanel = self:getUI("bg.textBg.selectPanel")
	local funcBtn = self:getUI("bg.textBg.funcBtn")
	selectPanel:setVisible(false)
	funcBtn:setVisible(false)
	
	local bgImg = self:getUI("bg.bgImg")
	local eventBgImg = "asset/bg/guildMapTreasure/"..self._eventTab.eventPic..".png"
	bgImg:loadTexture(eventBgImg)
	if self["loadTreasyreViewType"..self._treasureType] then
		self["loadTreasyreViewType"..self._treasureType](self)
	end
end

function GuildMapTreasureEventDialog:getReward()
	self._serverMgr:sendMsg("GuildMapServer", "getTMapReward", {tagPoint = self._targetId}, true, {}, function(result, error)
		if error and error ~= 0 then
			self:close()
			return
		end
        if result.reward then
			DialogUtils.showGiftGet({gifts = result.reward})
		end
		self:close()
	end)
end

function GuildMapTreasureEventDialog:loadTreasyreViewType1()
	local funcBtn = self:getUI("bg.textBg.funcBtn")
	funcBtn:setTitleText("确定")
	funcBtn:setVisible(true)
	self:registerClickEvent(funcBtn, function()
		self:getReward()
	end)
end

function GuildMapTreasureEventDialog:loadTreasyreViewType2()
	local selectPanel = self:getUI("bg.textBg.selectPanel")
	selectPanel:setVisible(true)
    self._mapInfomation = self._treasureData
	self._callback = function (result)
		if result then
			self:loadAfterFightViewShow(result.win)
		end
	end
	for i=1, 2 do
		local label = self:getUI("bg.textBg.selectPanel.label"..i)
		label:stopAllActions()
		label:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.6, 160), cc.FadeTo:create(0.6, 255))))
		label:setString(i.."."..lang(self._eventTab["choice"..i]))
		self:registerClickEvent(label, function()
			self:onSelectIndex(i)
		end)
	end
end

function GuildMapTreasureEventDialog:onSelectIndex(index)
	local desLab = self:getUI("bg.textBg.descText")
	local selectPanel = self:getUI("bg.textBg.selectPanel")
	local funcBtn = self:getUI("bg.textBg.funcBtn")
	local isNeedBattle = self._treasureData["ta"..index]==1
	selectPanel:setVisible(false)
	funcBtn:setVisible(true)
	
	self._selectIndex = index
	if isNeedBattle then
		desLab:setString(lang(self._eventTab["choice"..index.."ResultBattle"]))
		funcBtn:setTitleText("战斗")
		self:registerClickEvent(funcBtn, function()
			self:treasureBefore()
		end)
	else
		desLab:setString(lang(self._eventTab["choice"..index.."ResultPass"]))
		funcBtn:setTitleText("确定")
		self:registerClickEvent(funcBtn, function()
			self:getReward()
		end)
	end
end

function GuildMapTreasureEventDialog:onDestroy()
	print("sssssss")
end

function GuildMapTreasureEventDialog:loadAfterFightViewShow(win)
	local funcBtn = self:getUI("bg.textBg.funcBtn")
	funcBtn:setTitleText("确定")
	self:registerClickEvent(funcBtn, function()
		local reward = self._guildMapModel:getTreasureReward()
		if reward then
			DialogUtils.showGiftGet({gifts = reward})
			self._guildMapModel:clearTreasureReward()
			self:close()
		end
	end)
	
	local desLab = self:getUI("bg.textBg.descText")
	if win==1 then--赢了
		desLab:setString(lang(self._eventTab["choice"..self._selectIndex.."ResultBattleWin"]))
	else--输了或中途退出
		desLab:setString(lang(self._eventTab["choice"..self._selectIndex.."ResultBattleLose"]))
	end
end

return GuildMapTreasureEventDialog