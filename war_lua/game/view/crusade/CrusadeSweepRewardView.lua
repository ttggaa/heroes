--[[
    Filename:    CrusadeSweepRewardView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-01-19 23:33:20
    Description: 作弊奖励界面
--]]

local CrusadeSweepRewardView = class("CrusadeSweepRewardView", BasePopView)

function CrusadeSweepRewardView:ctor(param)
	CrusadeSweepRewardView.super.ctor(self)

	math.randomseed(tostring(os.time()):reverse():sub(1, 6))  --随机种子
	self._crusadeData = self._modelMgr:getModel("CrusadeModel"):getData()
	self._data = param.data
	self._callback = param.sCallback
end

function CrusadeSweepRewardView:onInit()
	self._bg = self:getUI("bg")

	-- local titleImg = self:getUI("bg.titleImg")
	-- local tipDes = ""
	-- if self._crusadeData["accSweep"] <= 7 then
	-- 	titleImg:loadTexture("crusadeImg_skipSuccess.png", 1)
	-- 	tipDes = lang("CRUSADE_SWEEP_WORD_1")
	-- else
	-- 	local random = math.random(1, 100)
	-- 	if random == 66 then
	-- 		titleImg:loadTexture("crusadeImg_skipFail.png", 1)
	-- 		tipDes = lang("CRUSADE_SWEEP_WORD_2")
	-- 	else
	-- 		titleImg:loadTexture("crusadeImg_skipReward.png", 1)
	-- 		tipDes = lang("CRUSADE_SWEEP_WORD_3")
	-- 	end
	-- end

	local titleImg = self:getUI("bg.titleImg")
	titleImg:loadTexture("crusadeImg_skipFail.png", 1)
	local tipDes = lang("CRUSADE_SWEEP_WORD_2")

	local enterBtn = self:getUI("bg.okBtn")
	self:registerClickEvent(enterBtn, function()
		DialogUtils.showGiftGet( {
		    gifts = self._data["reward"],
		    callback = function()
		    	if self._callback then
					self._callback()
				end
				self:close(true)
		    end} )
			self:setVisible(false)
		end)

	--提示文字
	local richText = RichTextFactory:create(tipDes, 740, 0)
	richText:setAnchorPoint(cc.p(0.5, 1))
    richText:formatText()
    richText:setPosition(480, 424)
	self._bg:addChild(richText)
	--奖励
	self:createReward()
end

function CrusadeSweepRewardView:createReward()
	local _reward = self._data["reward"]
	local centerPosX = self._bg:getContentSize().width*0.5
	local posX = {}
	if #_reward == 2 then
		posX = {centerPosX - 50, centerPosX + 50}
	elseif #_reward == 3 then
		posX = {centerPosX - 50, centerPosX, centerPosX + 50}
	end

	-- 物品
    local reward = {}
    for k,v in pairs(_reward) do
    	if v.type == "tool" then
    		reward[#reward + 1] = v

    	elseif v.type == "crusading" then
    		reward[#reward + 1] = v
    		reward[#reward]["typeId"] = IconUtils.iconIdMap["crusading"]
    		reward[#reward]["num"] = v.num

    	elseif v.type == "gold" then
    		reward[#reward + 1] = v
			reward[#reward]["typeId"] = IconUtils.iconIdMap["gold"]
			reward[#reward]["num"] = v.num

    	elseif v.type == "gem" then
			reward[#reward + 1] = v
			reward[#reward]["typeId"] = IconUtils.iconIdMap["gem"]

		elseif v.type == "treasureCoin" then
			reward[#reward + 1] = v
    		reward[#reward]["typeId"] = IconUtils.iconIdMap["treasureCoin"]
    		reward[#reward]["num"] = v.num
    	end
    end

    for i = 1, #reward do
    	local sysItem = tab:Tool(reward[i].typeId)
        local item = IconUtils:createItemIconById({itemId = reward[i].typeId, num = reward[i].num, itemData = sysItem})
        item:setScale(0.78)
        item:setAnchorPoint(0.5, 0.5)
        item:setPosition(posX[i], 260)
        self._bg:addChild(item)
        if sysItem.typeId == ItemUtils.ITEM_TYPE_TREASURE then
            local mc1 = mcMgr:createViewMC("wupinguang_itemeffectcollection", true)
            mc1:setPosition(item:getContentSize().width/2 ,item:getContentSize().height/2)
            item:addChild(mc1, 10)
        end
    end
end

return CrusadeSweepRewardView