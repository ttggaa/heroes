local GodWarEntranceView = class("GodWarEntranceView", BaseView)

function GodWarEntranceView:ctor(data)
    GodWarEntranceView.super.ctor(self)
end

function GodWarEntranceView:getAsyncRes()
    return {
        {"asset/ui/crossGodWar2.plist", "asset/ui/crossGodWar2.png"},
    }
end

function GodWarEntranceView:getBgName()
    return "bg_009.jpg"
end

function GodWarEntranceView:onInit()

	self:registerClickEvent(self:getUI("bg.entrance1"), function ( ... )
		local godWarModel = self._modelMgr:getModel("GodWarModel")
        local flag = godWarModel:getClickGodwarBtn()
        if flag == 0 then
            self._serverMgr:sendMsg("GodWarServer", "getJoinList", {}, true, {}, function (result)
                self._viewMgr:showView("godwar.GodWarView")
            end)
        elseif flag == 1 then
            local openTimeStr = godWarModel:getOpenTime()
            self._viewMgr:showTip(openTimeStr)
        elseif flag == 2 then
            local openTimeStr = godWarModel:getOpenTime1()
            self._viewMgr:showTip(openTimeStr)
        elseif flag == 3 then
            self._viewMgr:showTip(lang("ZHENGBASAI_HEFU_TIPS"))
        end
	end)

	self:registerClickEvent(self:getUI("bg.entrance2"), function ( ... )
		if not GameStatic.is_open_crossGodWar then
			self._viewMgr:showTip("系统维护中")
			return
		end
		local openTime = self._modelMgr:getModel("CrossGodWarModel"):getFirstSeasonOpenTime(true)
		local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
        if curTime<=openTime then
			self._viewMgr:showTip(lang("crossFight_tips_5"))
		elseif self:checkIsTimeInIllegalTime() then
			self._viewMgr:showTip(lang("crossFight_tips_6"))
		else
            self._serverMgr:sendMsg("CrossGodWarServer", "enter", {}, true, {}, function(result)
                UIUtils:reloadLuaFile("crossGod.CrossGodWarView")
                self._viewMgr:showView("crossGod.CrossGodWarView")
            end)
        end
	end)
	
	self:setEntranceTip()

	local entrance1 = self:getUI("bg.entrance1")
	local mc1 = mcMgr:createViewMC("zhushenrukoulan_kuafuzhushenrukou2",true,false)
	mc1:setPosition(entrance1:getContentSize().width/2,entrance1:getContentSize().height/2-3)
	mc1:setScale(1.1)
	entrance1:addChild(mc1,10)
	local mc2 = mcMgr:createViewMC("zhushenrukouhuang_kuafuzhushenrukou",true,false)
	local entrance2 = self:getUI("bg.entrance2")
	entrance2:addChild(mc2,10)
	mc2:setPosition(entrance2:getContentSize().width/2,entrance2:getContentSize().height/2)
end

function GodWarEntranceView:checkIsTimeInIllegalTime()
	local weekTime = 7*24*60*60
	local openTime = self._modelMgr:getModel("CrossGodWarModel"):getFirstSeasonOpenTime(true)--改为六点
	local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
	local week = tonumber(TimeUtils.getDateString(curTime, "%w"))
	if week==1 then
		local timeEnd = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 06:00:00"))--6:00
		if ((timeEnd-openTime)/weekTime)%2==1 then--只隔一周，不是跨服诸神的开启周，周一五点半到六点可以进
			return false
		end
		local timeStart = timeEnd - 6*60*60
		if curTime>=timeStart and curTime<=timeEnd then
			return true
		end
	end
	return false
end

function GodWarEntranceView:setEntranceTip()
	local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
	local tipLab2 = self:getUI("bg.entrance2.tipLab")
	tipLab2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	local tipText2 = ""
	
	local firstOpenTime = self._modelMgr:getModel("CrossGodWarModel"):getFirstSeasonOpenTime(true)--改为六点
	if curTime<firstOpenTime then
		tipText2 = "未开启"
		tipLab2:setColor(cc.c3b(205, 32, 30))
	else
		local crossGodIsOpen, nowWeek = self._modelMgr:getModel("CrossGodWarModel"):getIsWarOpenWeek()
		local enterTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 06:00:00"))
		tipLab2:setColor(cc.c3b(205, 32, 30))
		if crossGodIsOpen then
			local endData = tab.crossFightTime[table.nums(tab.crossFightTime)]
			local endTime = TimeUtils.getTimeStampWithWeekTime(curTime, endData.time2, endData.week[2])
			if nowWeek==1 and curTime<enterTime then
				tipText2 = "六点开启"
			elseif curTime>=endTime then
				tipText2 = "已结束"
			else
				tipText2 = "开启中"
				tipLab2:setColor(cc.c3b(87, 253, 83))
			end
		else
			tipText2 = "下周开启"
		end
	end
	tipLab2:setString(tipText2)
	if not GameStatic.is_open_crossGodWar then
		tipLab2:setVisible(false)
	end
--	tipLab2:setVisible(false)--临时修改隐藏提示文字
end

function GodWarEntranceView:setNavigation()
    -- self._viewMgr:showNavigation("global.UserInfoView",{hideHead=true,hideInfo=true, callback = callback})
    self._viewMgr:showNavigation("global.UserInfoView",{types = {"CrossGodWarCoin","Fans","Gem",},titleTxt = "跨服诸神"}, nil, ADOPT_IPHONEX and self.fixMaxWidth or nil)
end

return GodWarEntranceView