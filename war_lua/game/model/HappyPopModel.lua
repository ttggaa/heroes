--[[
    Filename:    HappyPopModel.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-11-8 20:47:42
    Description: File description
--]]

local HappyPopModel = class("HappyPopModel", BaseModel)

function HappyPopModel:ctor()
	HappyPopModel.super.ctor(self)
	require("game.view.activity.happyPop.HappyPopConst")
    self._userModel = self._modelMgr:getModel("UserModel")

    self._data = {}
    self._data["card"] = {}
    self._data["info"] = {}
    self._acData = {}

    self:registerTimer(5, 0, 0, function ()
    	local curTime = self._userModel:getCurServerTime()
        if self._acData["end_time"] and curTime >= self._acData["end_time"] then
        	self:clearAndRestart()
        	self:reflashData("acEnd")
        end
    end)
    --[[
    self._data["match"]   --匹配对
    self._data["rewards"] --奖励

    self._isUseLocal  	--是否用本地数据
    self._isClicked  	--主界面红点 点击过按钮红点消失
    ]]
end

function HappyPopModel:setAcData(inId)
	self._acData = inId
	self._data["endTime"] = self._acData["end_time"]   --记录活动结束时间
end

function HappyPopModel:getAcData()
	return self._acData or {}
end

function HappyPopModel:setIsClickedBtn(inState)  --主界面红点
	self._isClicked = inState
end

function HappyPopModel:getIsClickedBtn()
	return self._isClicked or false
end

function HappyPopModel:getIsUseLocalState()
	return self._isUseLocal or false
end

function HappyPopModel:getData()
	return self._data or {}
end

function HappyPopModel:setClickTime(isForce)   --单副牌开始的时间（用来最小翻牌结束时间防作弊判断）
	local curTime = self._userModel:getCurServerTime()
	local time = SystemUtils.loadAccountLocalData("HAPPY_POP_CLICK_TIME", curTime)
	if isForce or time == nil then
		SystemUtils.saveAccountLocalData("HAPPY_POP_CLICK_TIME", curTime)
	end
end

function HappyPopModel:getClickTime()
	local time = SystemUtils.loadAccountLocalData("HAPPY_POP_CLICK_TIME", curTime)
	return time or 0
end

function HappyPopModel:clearClickTime()
	SystemUtils.loadAccountLocalData("HAPPY_POP_CLICK_TIME", nil)
end

function HappyPopModel:saveLocalData(inDisT)   --退出保存进度
	if not self._data or not self._data["card"] or next(self._data["card"]) == nil then
		return
	end

	if inDisT then
		self._data["info"]["lt"] = inDisT  --修改时间
	end
	self._data["endTime"] = self._acData["end_time"]
	SystemUtils.saveAccountLocalData("HAPPY_POP_GAME", self._data)
end

function HappyPopModel:checkLocalData() 		--重进读取进度
	local localD = SystemUtils.loadAccountLocalData("HAPPY_POP_GAME")
	local curTime = self._userModel:getCurServerTime()
	-- dump(localD,"localD")
	if localD and next(localD) and localD["endTime"] and localD["endTime"] > curTime then
		self._data = localD
		return true		
	end

	self._data = {}
	return false
end

function HappyPopModel:setData(inData)
	if inData["card"] == nil or inData["info"] == nil then
		return 
	end

	--版本号>=服务器版本号 用本地数据
	if not (self._data["info"] and self._data["info"]["c"] and 
		inData["info"]["c"] and self._data["info"]["c"] >= inData["info"]["c"]) then
	
		self:clearAndRestart()  --重新开始
		self._data = inData
	else
		self._isUseLocal = true  --是用本地数据
	end
end

function HappyPopModel:openCards(inData)
	if not inData["rewards"] then   --换牌
		self._data["card"] = inData["card"]
		self._data["match"] = {}
		self._data["info"]["c"] = inData["info"]["c"]
		self._data["info"]["lt"] = inData["info"]["lt"]
		self._data["endTime"] = self._acData["end_time"]
		SystemUtils.saveAccountLocalData("HAPPY_POP_GAME", self._data)
	else
		self:clearAndRestart()     	--结束
	end
end

--重新开始游戏
function HappyPopModel:clearAndRestart()
	self._isUseLocal = false
	self._data = {}
	self._data["card"] = {}
    self._data["info"] = {}
	SystemUtils.saveAccountLocalData("HAPPY_POP_GAME", {})   --清进度
	SystemUtils.saveAccountLocalData("HAPPY_POP_CLICK_TIME", nil)
end

--新手引导状态
function HappyPopModel:setFirstGuideState()
	local localD = SystemUtils.loadAccountLocalData("HAPPY_POP_GAME")
    if localD["isFirst"] and localD["isFirst"] == 1 then
        localD["isFirst"] = 1
        SystemUtils.saveAccountLocalData("HAPPY_POP_GAME", localD)
    end
end

function HappyPopModel:notifyChildViewClose()
	self:reflashData("close")
end

function HappyPopModel:notifyCheatClose()
	self:clearAndRestart()
	self:reflashData("cheat")
end

--[[------------
'c'   => core_Schema::NUM, //牌的唯一id
's'   => core_Schema::NUM, //道具获得次数【当局累计】
'n'   => core_Schema::NUM, //碎片获得次数【当局累计】
'score'=> core_Schema::NUM, //最高积分【历史最高】
'lt'  => core_Schema::NUM, //剩余秒数
'card'=> core_Schema::NUM, //翻的牌数【单局】
'hids'=> core_Schema::STR, //翻的英雄碎片【单局】
'ut'  => core_Schema::NUM, //更新时间
'source'  => core_Schema::NUM, //当局得分
--------------]]
function HappyPopModel:matchSuccess(inData)   --匹配成功 记录数据
	local sysConfig = tab.magicTrainingCfg
	local sysTraining = tab.magicTraining

	for i,v in ipairs(inData["match"]) do
		--匹配对 match
		if not self._data["match"] then
			self._data["match"] = {}
		end
		table.insert(self._data["match"], v)

		--最高分
		local score = self._data["source"] or 0
		self._data["source"] = score + sysConfig["SCORE"]["value"] * 2

		local rwdType = inData["matchValue"]
		local limitS = sysConfig["LIMIT_SCROLL_NUM"]["value"]
		local limitN = sysConfig["LIMIT_HERO_NUM"]["value"]
		--普通牌
		if rwdType == HappyPopConst.cardType.skill or rwdType == HappyPopConst.cardType.master then 
			local s = self._data["info"]["s"] or 0
			local limit = sysConfig["LIMIT_SCROLL_NUM"]["value"]
			self._data["info"]["s"] = math.min(s + sysConfig["CLEAN_CARD_NUM"]["value"] * 2, limitS)

		--时钟
		elseif rwdType == HappyPopConst.cardType.clock then
			local s = self._data["info"]["s"] or 0
			self._data["info"]["s"] = math.min(s + sysConfig["CLEAN_CARD_NUM"]["value"] * 2, limitS) 
			
			local lt = self._data["info"]["lt"] or 0
			self._data["info"]["lt"] = lt + sysTraining[3001]["value"]

		--英雄
		elseif rwdType == HappyPopConst.cardType.hero then
			local n = self._data["info"]["n"] or 0
			self._data["info"]["n"] = math.min(n + sysConfig["CLEAN_HERO_CARD_NUM"]["value"] * 2, limitN) 
		end
	end	
end

function HappyPopModel:getEndDateStr()
    if next(self._acData) then
        local endM = TimeUtils.getDateString(self._acData.end_time - 86400,"%d")
        return endM
    end

    return 0
end

return HappyPopModel