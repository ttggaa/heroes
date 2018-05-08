--
-- Author: huangguofang
-- Date: 2017-05-27 11:18:10
--

local ACTrainingLiveDialog = class("ACTrainingLiveDialog",BasePopView)
function ACTrainingLiveDialog:ctor(param)
    self.super.ctor(self)
    self._trainAcData = param.trainAcData or {}
    self._callBack = param.callback

    self._trainModel = self._modelMgr:getModel("TrainingModel")
end
-- function ACTrainingLiveDialog:getAsyncRes()
--     return 
--     {

--     }
-- end

function ACTrainingLiveDialog:onDestroy()
	ACTrainingLiveDialog.super.onDestroy(self)
	
end

-- 第一次被加到父节点时候调用
function ACTrainingLiveDialog:onAdd()

end

function ACTrainingLiveDialog:onInit()
	self._bg = self:getUI("bg")
	self._bg:setSwallowTouches(false)

	self:registerClickEventByName("touchPanel", function() 
		if self._callBack then
			self._callBack()
		end
		self:close()
		-- UIUtils:reloadLuaFile("activity.ACTrainingLiveDialog")
	end)
	
	local bgImg = self:getUI("bg.bgImg")
	bgImg:loadTexture("asset/bg/bg_activity_train.png")

	local challengeBtn = self:getUI("bg.challengeBtn")
	self:registerClickEventByName("bg.challengeBtn", function() 
		self._trainModel:setIgnoreGuide(true)
		self._viewMgr:showView("training.TrainingView",{isFromAc = true})
		self:close()
	end)

	--[[
	--appear_time  --disappear_time
	local currTime    = self._modelMgr:getModel("UserModel"):getCurServerTime()
	local appear_time = self._trainAcData.appear_time or currTime
    local disappear_time = self._trainAcData.disappear_time or currTime 

	local timeTxt = self:getUI("bg.timeTxt")
	local appearData = TimeUtils.date("*t",appear_time)
	local disData = TimeUtils.date("*t",disappear_time)
	dump(appearData,"appearData",4)
	local str = "活动时间:" .. appearData.month .. "月" .. appearData.day .. "日 " .. string.format("%02d",appearData.hour) .. ":" .. string.format("%02d",appearData.min)
	str = str .. " -- " .. disData.month .. "月" .. disData.day .. "日 " .. string.format("%02d",disData.hour) .. ":" .. string.format("%02d",disData.min)
	timeTxt:setString(str)
	]]


	local timeTxt = self:getUI("bg.timeTxt")
	timeTxt:setString(lang("TRAINING_ACTIVITY_SHOW_1"))
	timeTxt:setPositionY(timeTxt:getPositionY()+4)

	local desTxt = self:getUI("bg.desTxt")
	desTxt:setColor(cc.c4b(255,238,157,255))
	desTxt:enable2Color(1,cc.c4b(255,201,70,255))
	desTxt:setString(lang("TRAINING_ACTIVITY_SHOW_2"))
	desTxt:setPositionY(desTxt:getPositionY()+3)

end

-- function ACTrainingLiveDialog:getMaskOpacity()
--     return 0
-- end
function ACTrainingLiveDialog:reflashUI(data)
	
end



function ACTrainingLiveDialog:onTop()

end

return ACTrainingLiveDialog