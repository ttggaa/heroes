--
-- Author: huangguofang
-- Date: 2017-07-15 15:22:50
--

local ShareBaseView = require("game.view.share.ShareBaseView")

function ShareBaseView:transferData(data)
    self._activityId = data.acId
end

function ShareBaseView:updateModuleView(data)
    
end

function ShareBaseView:onDestroy()
    ShareBaseView.super.onDestroy(self)
end

function ShareBaseView:getShareBgName()
	-- print("=======self._activityId====",self._activityId)
	if self._activityId and 99988 == tonumber(self._activityId) then
		return "asset/bg/share/share_team_race_107.jpg"
	elseif self._activityId and 99997 == tonumber(self._activityId) then		
    	return "asset/bg/share/share_team_race_109.jpg"
    else
    	return "asset/bg/share/share_team_race_109.jpg"
	end
end

function ShareBaseView:getInfoPosition()
    return nil, nil
end

function ShareBaseView:getShareId()
    return 16
end
