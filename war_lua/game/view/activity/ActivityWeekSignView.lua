
--[[
    Filename:    ActivityWeekSignView.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2017-06-15 16:37:46
    Description: File description
--]]

local point = {
	t_shuyao = {44,52},
	t_liehuojingling = {64,52},
	t_qishi = {84,42},
	t_bimeng = {150,22},
	t_xixuegui = {90,52},
	t_shenguai = {120,52},
	t_mofaxianling = {120,72},
	t_meidusha = {120, 72},
	t_jiutouguai = {120, 60},
	t_meirenyu = {70, 60}
}

local ActivityWeekSignView = class("ActivityWeekSignView",BasePopView)

function ActivityWeekSignView:ctor(param)
    ActivityWeekSignView.super.ctor(self)
    self._delayClose = true
    if param and param.callback then
    	self._callBack = param.callback
    	self._result = param.data
    end
    if not self._result then
    	self._result = {day = 1}
    end
    self._erroStatus = false
    self._rewards,self._todayInfo = self:getRewards()

    self._curWeek = self:getCurentWeek()
end

function ActivityWeekSignView:getCurentWeek()
	local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
	local t = TimeUtils.date("*t", curTime)
    if t.hour < 5 then
        local day = curTime - 86400
        t = TimeUtils.date("*t", day)
    end
	local curWeek = t.wday
	return curWeek
end

function ActivityWeekSignView:getAsyncRes()
    return {
    	{"asset/ui/acRetrieve.plist","asset/ui/acRetrieve.png"},
        "asset/uiother/team/".. self._todayInfo.pic .. ".png",
        "asset/bg/weekSign_clip.png"
    }
end

function ActivityWeekSignView:onDestroy()
	ActivityWeekSignView.super.onDestroy(self)
	cc.Director:getInstance():getTextureCache():removeTextureForKey("asset/uiother/team/".. self._todayInfo.pic .. ".png")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("asset/bg/weekSign_clip.png")
end

function ActivityWeekSignView:onInit()
	self:refreshUI(self._result)
	local getBtn = self:getUI("bg.btn_get")
	self:registerClickEvent(getBtn,function()
		local nowWeek = self:getCurentWeek()
		print("nowWeek",nowWeek)
		print("self._curWeek",self._curWeek)
		if nowWeek ~= self._curWeek and nowWeek == 2 then
			self._viewMgr:showTip("活动时间已结束，请重新登录后再试~")
			self:close()
			return
		end
		if self._erroStatus then
			self._erroStatus = nil
			self._viewMgr:showTip("服务器时间异常")
			self:close()
			return
		end
		self._serverMgr:sendMsg("WeeklySignServer", "weeklySign", {}, true, {}, function(result)
	        if not result then return end
	  --       DialogUtils.showGiftGet({
			-- 	gifts = result.reward,
			-- 	callback = function()
			-- 		local call = self._callBack
			-- 		self:afterGet()
			-- 		self:close(nil,function ()
			-- 			if call then
			-- 				call()
			-- 			end
			-- 		end)
			-- end})
			if not result.reward or not result.reward[1] then
				self._viewMgr:showTip("没有可领取的奖励")
				self:close()
				return
			end
			self:animaAfterGet(result.reward[1])
	    end)
	end)
	local closeBtn = self:getUI("bg.closeBtn")
	if closeBtn then
		self:registerClickEvent(closeBtn,function()
			self:close()
			if OS_IS_WINDOWS then
	            UIUtils:reloadLuaFile("activity.ActivityWeekSignView")
	        end
		end)
	end

	self:getUI("bg.mask_bg"):loadTexture("asset/bg/weekSign_clip.png")
	self:showAnima()
end

function ActivityWeekSignView:animaAfterGet(rewards)
	local name = ""
	if rewards["type"] == "hero" then
        local sysHeroData = tab:Hero(rewards["typeId"])
        name = lang(sysHeroData.heroname)
    else
    	local itemId
        if rewards["type"] == "tool" then
            itemId = rewards["typeId"]
        else
            itemId = IconUtils.iconIdMap[rewards["type"]]
        end
        name = lang(tab:Tool(itemId).name)
    end
    self._viewMgr:showTip("恭喜获得" .. name .. "X" .. rewards["num"])
    self:lock(-1)
    self:afterGet()
    --动画
    local getImage_
    local bigSpawn = cc.Spawn:create(cc.FadeIn:create(0.1),cc.ScaleTo:create(0.1,2.4))
	local seqSmall = cc.Sequence:create(bigSpawn,cc.ScaleTo:create(0.1,0.9*0.6))
	local normalSeq = cc.Sequence:create(seqSmall,cc.ScaleTo:create(0.2,0.6),cc.CallFunc:create(function ()
		self:unlock()
		self._getImage:setOpacity(255)
		getImage_:removeFromParent()
		local call = self._callBack
		self:close(nil,function ()
			if call then
				call()
			end
		end)
	end))

	getImage_ = ccui.ImageView:create()
	getImage_:loadTexture("globalImageUI_activity_getItBlue.png",1)
	local wordPos = self._curPanle:convertToWorldSpace(cc.p(self._getImage:getPositionX(),self._getImage:getPositionY()))
	getImage_:setPosition(wordPos)
	getImage_:setScale(0.6)
	getImage_:setOpacity(0)
	getImage_:setOpacity(0)
	self:addChild(getImage_,10)
	getImage_:runAction(normalSeq)
end

function ActivityWeekSignView:playNightAnima()
	local node = self:getUI("bg.animaNode")
    local mc1 = mcMgr:createViewMC("zhouyejiaoti_zhouyejiaoti", false, false)
    mc1:setPosition(450,80)
    node:addChild(mc1)
end

function ActivityWeekSignView:playDayAnima()
	local node = self:getUI("bg.animaNode")
    local mc1 = mcMgr:createViewMC("zhouyejiaoti_zhouyejiaoti", false, false)
    mc1:setPosition(450,80)
    mc1:gotoAndStop(100)
    -- mc1:setScaleY(1.1)
    node:addChild(mc1)
end

function ActivityWeekSignView:showAnima()
	local saveTime = SystemUtils.loadAccountLocalData("WEEK_GIGN_TIME")
	local time = self._modelMgr:getModel("UserModel"):getCurServerTime()
	if not saveTime then
		SystemUtils.saveAccountLocalData("WEEK_GIGN_TIME", time)
		self:playNightAnima()
		return
	else
		local isNew = TimeUtils.checkIsAnotherWeek(tonumber(saveTime),time)
		if isNew then
			SystemUtils.saveAccountLocalData("WEEK_GIGN_TIME", time)
			self:playNightAnima()
		else
			self:playDayAnima()
		end
	end
end

function ActivityWeekSignView:onPopEnd()
	
end

function ActivityWeekSignView:refreshUI(result)
	local dayNum = result.day
	local rewards,todayInfo = self._rewards,self._todayInfo
	-- dump(todayInfo,"ActivityWeekSignView",10)
	for i=1,7 do
		local itemPanle = self:getUI("bg.day".. i) 
		local iconPanel = itemPanle:getChildByFullName("iconPanel")
		local data = rewards[i]
		local awardIcon
		local num = data[3]
		if data[1] == "hero" then
            local sysHeroData = tab:Hero(data[2])
            awardIcon = IconUtils:createHeroIconById({sysHeroData = sysHeroData, effect = false})
            awardIcon:setAnchorPoint(0.5,0.5)
            awardIcon:setScale(0.55)
            awardIcon:setPosition(iconPanel:getContentSize().width/2,iconPanel:getContentSize().height/2)
            iconPanel:addChild(awardIcon)
            -- awardIcon:getChildByName("starBg"):setVisible(false)
            -- awardIcon:getChildByName("iconStar"):setVisible(false)

            registerClickEvent(iconPanel, function()
            local NewFormationIconView = require "game.view.formation.NewFormationIconView"
	            self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = data[2]}, true)
	        end)
        else
        	local itemId
            if data[1] == "tool" then
                itemId = data[2]	
            else
                itemId = IconUtils.iconIdMap[data[1]]
            end
            awardIcon = IconUtils:createItemIconById({itemId = itemId, num = num,effect = true,eventStyle = 4, swallowTouches = true})
            awardIcon:setScale(0.6)
            awardIcon:setAnchorPoint(0.5,0.5)
            awardIcon:setPosition(iconPanel:getContentSize().width/2,iconPanel:getContentSize().height/2)
            iconPanel:addChild(awardIcon)
        end
        awardIcon:setSwallowTouches(false)

        --领取状态
        if i <= dayNum then
        	print("已领取")
        	local mask = ccui.ImageView:create()
			mask:loadTexture("globalPanelUI7_zhezhao.png",1)
			mask:setPosition(itemPanle:getContentSize().width/2-1,itemPanle:getContentSize().height/2+17)
			mask:setScale(0.6)
			itemPanle:addChild(mask)

        	local getImage = ccui.ImageView:create()
			getImage:loadTexture("globalImageUI_activity_getItBlue.png",1)
			getImage:setPosition(itemPanle:getContentSize().width/2,itemPanle:getContentSize().height/2+20)
			getImage:setScale(0.6)
			itemPanle:addChild(getImage)
        end
        if i == dayNum + 1 then
        	self._curPanle = itemPanle
        end
        local dayLabel = itemPanle:getChildByFullName("day_label")
  --       dayLabel:setColor(cc.c3b(255, 253, 235))
		-- dayLabel:enable2Color(2,cc.c3b(253, 229, 175))
		dayLabel:enableOutline(cc.c3b(60, 30, 10))
	end

	

	--立绘,title,描述
	if todayInfo.pic then
		local leftImage = self:getUI("bg.left_image")
		leftImage:loadTexture("asset/uiother/team/".. todayInfo.pic .. ".png")
		leftImage:setBrightness(15)
		if point[todayInfo.pic] and point[todayInfo.pic][1] then
			leftImage:setPosition(leftImage:getPositionX()+point[todayInfo.pic][1],leftImage:getPositionY()+point[todayInfo.pic][2])
		end
		if todayInfo.pic == "t_shenguai" then
			leftImage:setFlippedX(true) 
		end
	end

	local titleStr = lang(todayInfo.title)
	if titleStr then
		local title = self:getUI("bg.title_txt")
		-- title:setFontSize(34)
		title:setColor(cc.c3b(255, 253, 235))
		title:enable2Color(1,cc.c3b(253, 229, 175))
		title:enableOutline(cc.c3b(60, 30, 10),2)
		title:setString(titleStr)
		title:setPosition(title:getPositionX()+10,title:getPositionY()-20)
		local label2 = self:getUI("bg.richPanel.label2")
		label2:setString(titleStr)
		label2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

		local mc1 = mcMgr:createViewMC("guang_zhouyejiaoti", true, false)
	    mc1:setPosition(title:getContentSize().width-8,title:getContentSize().height-7)
	    title:addChild(mc1)
	end
	local richPanel = self:getUI("bg.richPanel")
	local label1 = richPanel:getChildByFullName("label1")
	label1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

	if todayInfo.des1 then
		local richStr = lang(todayInfo.des1)
		local label3 = richPanel:getChildByFullName("label3")
		label3:setString(richStr)
		label3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	end

	-- if todayInfo.des2 then
	-- 	local richStr = todayInfo.des2
	-- 	local label4 = richPanel:getChildByFullName("label4")
	-- 	label4:setString(richStr)
	-- 	label4:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	-- end
	-- local imageNode = self:getUI("bg.richPanel.Image_61_0")
	local label3 = richPanel:getChildByFullName("label3")
	-- local label4 = richPanel:getChildByFullName("label4")
	-- imageNode:setPositionX(label3:getPositionX()+label3:getContentSize().width+10)
	-- label4:setPositionX(imageNode:getPositionX()+10)
end

function ActivityWeekSignView:afterGet()
	if self._curPanle then
		local mask = ccui.ImageView:create()
		mask:loadTexture("globalPanelUI7_zhezhao.png",1)
		mask:setPosition(self._curPanle:getContentSize().width/2-1,self._curPanle:getContentSize().height/2+17)
		mask:setScale(0.6)
		self._curPanle:addChild(mask)

    	local getImage = ccui.ImageView:create()
		getImage:loadTexture("globalImageUI_activity_getItBlue.png",1)
		getImage:setPosition(self._curPanle:getContentSize().width/2,self._curPanle:getContentSize().height/2+20)
		getImage:setScale(0.6)
		getImage:setOpacity(0)
		self._curPanle:addChild(getImage)
		self._getImage = getImage
	end
	-- self._curPanle = nil
	local getBtn = self:getUI("bg.btn_get")
	getBtn:setTouchEnabled(false)
	-- self:registerClickEvent(getBtn,function()
	-- 	self._viewMgr:showTip("今天已签到")
	-- end)
end

--返回7天的奖励和今天的data
function ActivityWeekSignView:getRewards()
	local serverTime = self._modelMgr:getModel("UserModel"):getCurServerTime() - 18000
	local t_ = os.date("*t",serverTime)
	local zeroTime = os.time({year = t_.year,month = t_.month, day = t_.day, hour = 0, min = 0, sec = 0})
	local a,b = zeroTime,zeroTime
	local idList = {}
	local todayId = tonumber(string.format("%d%02d%02d",t_.year,t_.month,t_.day))
	while true do --向前索引到周一
		local t = os.date("*t",a)
		if t.wday == 2 then
			local str = string.format("%d%02d%02d",t.year,t.month,t.day)
			table.insert(idList,tonumber(str))
			break
		else
			local str = string.format("%d%02d%02d",t.year,t.month,t.day)
			table.insert(idList,tonumber(str))
			a = a - 86400
		end
	end

	while true do  --向后索引到周日
		local t = os.date("*t",b)
		if t.wday == 1 then
			local str = string.format("%d%02d%02d",t.year,t.month,t.day)
			if not table.find(idList,tonumber(str)) then
				table.insert(idList,tonumber(str))
			end
			break
		else
			local str = string.format("%d%02d%02d",t.year,t.month,t.day)
			if not table.find(idList,tonumber(str)) then
				table.insert(idList,tonumber(str))
			end
			b = b + 86400
		end
	end

	table.sort(idList,function (a,b)
		return a < b
	end)

	local rewards = {}
	local todayInfo
	local i =0
	for _,id in pairs (idList) do 
		local data = tab:WeeklySign(id)
		i = i+1
		if i == self._result.day+1 then
			todayInfo = data
		end
		-- if id == todayId then
		-- 	todayInfo = data
		-- end
		table.insert(rewards,data.reward[1])
	end
	if not todayInfo then
		todayInfo = tab:WeeklySign(idList[#idList])
		self._erroStatus = true
	end
	return rewards,todayInfo
end

return ActivityWeekSignView