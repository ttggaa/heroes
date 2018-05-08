--[[
    Filename:    WeeklySignServer.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2017-5-2 18:54:41
    Description: File description
--]]


local WeeklySignServer = class("WeeklySignServer",BaseServer)

function WeeklySignServer:ctor(data)
    WeeklySignServer.super.ctor(self,data)
    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._userModel = self._modelMgr:getModel("UserModel")
end

--取周签到数据
function WeeklySignServer:onGetweeklySignInfo( result, error)
	if error ~= 0 then 
		return
	end
	dump(result,"result",10)
	self:callback(result)
end

--周签到
function WeeklySignServer:onWeeklySign(result,error)
	if error ~= 0 then
		return
	end
	dump(result)
	if result["d"] then
		self._itemModel:updateItems(result["d"]["items"])
		result["d"]["items"] = nil
		if result["d"]["dayInfo"] and result["d"]["dayInfo"]["day58"] then
			self._modelMgr:getModel("PlayerTodayModel"):setDayInfo(58,result["d"]["dayInfo"]["day58"])
		end
		self._userModel:updateUserData(result["d"])
		self:callback(result)
	end
end

return WeeklySignServer