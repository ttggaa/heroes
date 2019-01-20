--[[
    Filename:    AcLimitSelectView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2018-05-22 17:14
    Description: 限时活动选择界面
--]]

local AcLimitSelectView = class("AcLimitSelectView", BasePopView)

local acConfig = {
	--限时招募
	[1001] = {teamId = 107, scale = 0.8, pos = {123, 205}},  --大天使
	[1002] = {teamId = 606, scale = 0.9, pos = {93, 175}},   --娜迦
	[1003] = {teamId = 407, scale = 0.8, pos = {100, 175}},  --比蒙
	[1004] = {teamId = 307, scale = 0.9, pos = {93, 175}},   --骨龙
	[1005] = {teamId = 507, scale = 0.9, pos = {93, 175}},	 --大恶魔
	[1006] = {teamId = 108, scale = 0.9, pos = {93, 175}},   --圣骑士
	[1007] = {teamId = 707, scale = 0.9, pos = {93, 175}},   --黑龙
	[1008] = {teamId = 607, scale = 0.9, pos = {93, 175}},   --泰坦
	[1009] = {teamId = 207, scale = 0.9, pos = {93, 175}},   --绿龙
	[1010] = {teamId = 805, scale = 0.9, pos = {93, 135}},   --蛮牛
	[1011] = {teamId = 807, scale = 0.9, pos = {93, 175}},   --多头龙
	[1012] = {teamId = 408, scale = 0.9, pos = {93, 195}},   --狂战士
	[1013] = {teamId = 9902, scale = 0.9, pos = {93, 180}},  --宝藏猎人
	[1014] = {teamId = 9906, scale = 0.9, pos = {70, 215}},  --龙龟
	[1015] = {teamId = 708, scale = 0.9, pos = {70, 165}},  --红龙

	--限时魂石
	[1051] = {teamId = 407, scale = 0.9, pos = {85, 165}},   --比蒙
	[1052] = {teamId = 606, scale = 0.9, pos = {85, 165}},   --娜迦
	[1053] = {teamId = 107, scale = 0.9, pos = {80, 180}},   --大天使
	[1054] = {teamId = 307, scale = 0.9, pos = {80, 180}},   --鬼龙
	[1055] = {teamId = 207, scale = 0.9, pos = {85, 165}},   --绿龙
	[1056] = {teamId = 507, scale = 0.9, pos = {80, 180}},   --大恶魔
	[1057] = {teamId = 707, scale = 0.9, pos = {80, 180}},   --黑龙
	[1058] = {teamId = 805, scale = 0.9, pos = {80, 180}},   --蛮牛
	[1059] = {teamId = 108, scale = 0.9, pos = {80, 180}},   --蛮牛
	[1060] = {teamId = 408, scale = 0.9, pos = {80, 180}},   --狂战士
	[1061] = {teamId = 607, scale = 0.9, pos = {80, 180}},   --泰坦
}

local posConfig = {
	[2] = {scale = 1, posX = {280, 680}},
	[3] = {scale = 0.95, posX = {167, 484, 797}},
}

function AcLimitSelectView:ctor(param)
	self.super.ctor(self)
	self._teamModel = self._modelMgr:getModel("LimitTeamModel")
	self._data = param
end

function AcLimitSelectView:onInit()
	local closeBtn = self:getUI("closeBtn")
	self:registerClickEvent(closeBtn, function()
		self:close()
		UIUtils:reloadLuaFile("activity.acLimit.AcLimitSelectView")
		end)
end

function AcLimitSelectView:reflashUI()
	local ids = self._data["ids"]
	local tempPos = posConfig[#ids]
	dump(ids, "ids")

	for i=1, 3 do
		repeat
			local selectNode = self:getUI("bg.select" .. i)
			local enterBtn = self:getUI("bg.enterBtn" .. i)
			if i > #ids then
				selectNode:setVisible(false)
				enterBtn:setVisible(false)
				break
			end

			local acData = ids[i]
			local cfData = acConfig[acData["activity_id"]] 
			if not cfData then
				break
			end
			
			selectNode:setScale(tempPos["scale"] or 1)
			selectNode:setPositionX(tempPos["posX"][i])
			enterBtn:setPositionX(tempPos["posX"][i])

			local name = selectNode:getChildByName("name")
			name:setColor(cc.c4b(253, 251, 200, 255))
			name:enable2Color(1, cc.c4b(169, 123, 82, 255))
			name:enableOutline(cc.c4b(45, 21, 21, 255), 2)

			local img = selectNode:getChildByFullName("imgNode.img")
			img:setScale(cfData["scale"])
			img:setPosition(cfData["pos"][1], cfData["pos"][2])

			self:refreshUIByType(acData, selectNode, enterBtn)
			
		until true
	end
end

function AcLimitSelectView:refreshUIByType(acData, selectNode, enterBtn)
	local tempParam = {
		isLoadRes = true, 
		id = acData["_id"], 
		acId = acData["activity_id"],
		callback = self._data["callback"],
		callback2 = function()
			self:close()
		end
	}

	local cfData = acConfig[acData["activity_id"]] 
	local uiType = self._data["uiType"]
	local teamD = tab:Team(cfData["teamId"])
	local lihui = string.sub(teamD["art1"], 4, string.len(teamD["art1"]))
	
	local name = selectNode:getChildByName("name")
	local frame = selectNode:getChildByName("frame")
	local img = selectNode:getChildByFullName("imgNode.img")
	
	if uiType == "limit" then
		local res = "asset/uiother/team/t_" .. lihui .. ".png"
		img:loadTexture(res)
		frame:loadTexture("ac_teamTL_selectBg2.png", 1)
		name:setString(lang(teamD["name"]))

		self:registerClickEvent(enterBtn, function()
			self._viewMgr:showDialog("activity.acLimit.ACTeamLimitTimeLayer", tempParam, true)
			self:setVisible(false)
			end)
	else
		local res = "asset/uiother/team/ta_" .. lihui .. ".png"
		img:loadTexture(res)
		frame:loadTexture("ac_awakenTL_selectBg2.png", 1)
		name:setString(lang(teamD["awakingName"]))

		self:registerClickEvent(enterBtn, function()
			self._viewMgr:showDialog("activity.acLimit.ACAwakenLimitTimeLayer", tempParam, true)
			self:setVisible(false)
			end)
	end
end

function AcLimitSelectView:getAsyncRes()
    return 
    {
        {"asset/ui/acAwakenTL.plist", "asset/ui/acAwakenTL.png"},
        {"asset/ui/acAwakenTL1.plist", "asset/ui/acAwakenTL1.png"},
        {"asset/ui/acAwakenTL2.plist", "asset/ui/acAwakenTL2.png"},
        
        {"asset/ui/activityTeamTL.plist", "asset/ui/activityTeamTL.png"},
        {"asset/ui/activityTeamTL1.plist", "asset/ui/activityTeamTL1.png"},
        {"asset/ui/activityTeamTL2.plist", "asset/ui/activityTeamTL2.png"},
        {"asset/ui/activityTeamTL3.plist", "asset/ui/activityTeamTL3.png"},
    }
end

function AcLimitSelectView:dtor()
	acConfig = nil
	posConfig = nil
end

return AcLimitSelectView
