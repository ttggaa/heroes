--
-- Author: <wangguojun@playcrab.com>
-- Date: 2016-07-06 20:11:26
--
local PvpInView = class("PvpInView",BaseView)
function PvpInView:ctor()
    PvpInView.super.ctor(self)
    self.initAnimType = 2
end
function PvpInView:getAsyncRes()
    return 
    {
        {"asset/ui/pvpIn.plist", "asset/ui/pvpIn.png"},
        {"asset/ui/pvpIn1.plist", "asset/ui/pvpIn1.png"},
    }
end

-- local gloryArenaIconBg = {"ti_fenghuang.jpg"}

function PvpInView:getBgName()
    return "bg_001.jpg"
end

function PvpInView:setNavigation()
	self._viewMgr:showNavigation("global.UserInfoView",{title = "globalTitleUI_pvp.png",titleTxt = "战神像"})
    -- self._viewMgr:showNavigation("global.UserInfoView",{hideInfo=true,hideHead=true})
end

function PvpInView:onTop( )
    if self._updateSche == nil then
        self._updateSche = ScheduleMgr:regSchedule(1000, self, function( )
    	    self:updatePvpIn()
        end)
        print("PvpInView:onTop")
    end 
	self:updatePvpIn()
	self:reflashUI()
end

-- 初始化UI后会调用, 有需要请覆盖
function PvpInView:onInit()
	-- 通用动态背景
    self:addAnimBg()
	self._scrollView = self:getUI("bg.scrollView")
	-- self._scrollView:setBounceEnabled(true)
    local scrollSize = self._scrollView:getContentSize()
    self._rightArrow = mcMgr:createViewMC("tujianyoujiantou_teamnatureanim", true, false)
    self._rightArrow:setPosition(self._scrollView:getPositionX() + scrollSize.width,300)
    self:getUI("bg"):addChild(self._rightArrow, 99)

    self._leftArrow = mcMgr:createViewMC("tujianzuojiantou_teamnatureanim", true, false)
    self._leftArrow:setPosition(self._scrollView:getPositionX(),300)
    self:getUI("bg"):addChild(self._leftArrow, 99)

    self._leftArrow:setVisible(false)
    self._rightArrow:setVisible(true)

    self._scrollView:addEventListener(function(sender, EventType)
        if EventType == SCROLLVIEW_EVENT_SCROLL_TO_LEFT or EventType == SCROLLVIEW_EVENT_BOUNCE_LEFT then
            self._leftArrow:setVisible(false)
            self._rightArrow:setVisible(true)
        elseif EventType == SCROLLVIEW_EVENT_SCROLL_TO_RIGHT or EventType == SCROLLVIEW_EVENT_BOUNCE_RIGHT then
            self._leftArrow:setVisible(true)
            self._rightArrow:setVisible(false)
        else
            self._leftArrow:setVisible(true)
            self._rightArrow:setVisible(true)
        end
    end)

	self._hole1 = self:getUI("bg.scrollView.hole1")
    self._hole1.pointIcon = self._hole1:getChildByFullName("pointIcon")
    self._hole1.pointIcon:setVisible(false)
	local arenaEnable = SystemUtils["enableArena"]()
	if arenaEnable then
		if not ModelManager:getInstance():getModel("ArenaModel"):getArena() then
			ScheduleMgr:nextFrameCall(self,function( )
				ServerManager:getInstance():sendMsg("ArenaServer", "enterArena", {}, true, {}, function(result)
					print("firstIn .,...")
					if self.reflashUI then
						self:reflashUI()
					end
				end,function( )
				end)
			end)
		end
		local arenaShopD = ModelManager:getInstance():getModel("ArenaModel"):getArenaShop() or {}
        if not arenaShopD.shop1 then
            ServerManager:getInstance():sendMsg("ArenaServer", "enterArenaShop", {}, true, {}, function(result)
	            if self.reflashUI then
					self:reflashUI()
				end
            end)
        end
	end
	self._hole1:setScaleAnimMin(0.9)
	self:registerClickEvent(self._hole1,function() 
		if arenaEnable then
			self._serverMgr:sendMsg("ArenaServer", "enterArena", {}, true, {}, function(result)
				if self.reflashUI then
					self._viewMgr:showView("arena.ArenaView",{notSendEnterMsg=true})
					self:reflashUI()
				end
			end,function( )
				self._viewMgr:showTip("暂未开放")
			end)
		else
			local systemOpenTip = tab.systemOpen["Arena"][3]
            if not systemOpenTip then
                self._viewMgr:showTip(tab.systemOpen["Arena"][1] .. "级开启")
            else
                self._viewMgr:showTip(lang(systemOpenTip))
            end
		end
	end)
	-- self:registerClickEvent(self._hole1,function() 
		
	-- 	self._hole1.__oriScale = 1
	-- end)
	self:isLocked(self._hole1,not arenaEnable,lang(tab.systemOpen["Arena"][3]) or tab.systemOpen["Arena"][1] .. "级开启")
	-- UIUtils:setGray(self._hole1,not arenaEnable)

	self._hole2 = self:getUI("bg.scrollView.hole2")
    self._hole2.pointIcon = self._hole2:getChildByFullName("pointIcon")
    self._hole2.pointIcon:setVisible(false)
	local isOpen,openDes,lvlTip = self:isLeagueOpen()
	self._heroBg = self:getUI("bg.scrollView.hole2.heroBg")
	self._heroBg:setVisible(isOpen)
	-- local hole2Img = self._hole2:getChildByName("img")
	-- UIUtils:setGray(hole2Img,not openLeague)
	-- isOpen,openDes = false,"暂未开启"
	-- isOpen = true
	self:isLocked(self._hole2,not isOpen,openDes)
	if isOpen then
		if not ModelManager:getInstance():getModel("LeagueModel"):getLeague() then
			ScheduleMgr:nextFrameCall(self,function( )
				ServerManager:getInstance():sendMsg("LeagueServer", "enterLeague", {}, true, {}, function(result)
		        	self:addHeroIcon()
		        	-- 如果进入 去掉主界面的播动画
				    self._modelMgr:getModel("LeagueModel"):isShowCurBatchInTipMc(true)
		        end, function ()
		        end)
			end)
		else
			self:addHeroIcon()
			-- 如果进入 去掉主界面的播动画
		    self._modelMgr:getModel("LeagueModel"):isShowCurBatchInTipMc(true)
		end
	end
	self._hole2:setScaleAnimMin(0.9)
	self:registerClickEvent(self._hole2,function() 
		local isOpen,openDes,lvlTip = self:isLeagueOpen()
		-- isOpen = true
		if isOpen then
			self._serverMgr:sendMsg("LeagueServer", "enterLeague", {}, true, {}, function(result)
				self._viewMgr:showView("league.LeagueView")
	        end, function ()
	            self._viewMgr:showTip(lang("LEAGUETIP_10"))-- "开放时间9:00-22:00")
	        end)
		else
			local isOpen,openDes,lvlTip = self:isLeagueOpen()
			self._viewMgr:showTip(lvlTip or openDes)
		end
	end)

	self._hole3 = self:getUI("bg.scrollView.hole3")
	self._hole3:loadTexture("heroDuel_pvp.png",1)
    self._hole3.pointIcon = self._hole3:getChildByFullName("pointIcon")
    self._hole3.pointIcon:setVisible(false)

    local isOpen,openDes = self:isHeroDuelOpen()
	self._featureBg = self:getUI("bg.scrollView.hole3.heroBg")
	self._featureBg:setVisible(isOpen)

    local featureId = tab:HeroDuel(self._modelMgr:getModel("HeroDuelModel"):getWeekNum()).char1
    local featureData = tab:HeroDuelSelect(featureId)
    local featureIcon = self._featureBg:getChildByFullName("icon")
    featureIcon:loadTexture(featureData.icon .. ".png", 1)

	if isOpen then
		if not ModelManager:getInstance():getModel("HeroDuelModel"):hasBaseInfo() then
			ScheduleMgr:nextFrameCall(self,function( )
				ServerManager:getInstance():sendMsg("HeroDuelServer", "hDuelGetBaseInfo", {}, true, {}, function(result)
                    self:updateHeroDuelFeature()
				end,function( )
				end)
			end)
        else
            self:updateHeroDuelFeature()
		end
	end

	self:isLocked(self._hole3,not isOpen,openDes)

	self._hole3:setScaleAnimMin(0.9)

    self:registerClickEvent(self._hole3,function()
    	local isOpen,openDes = self:isHeroDuelOpen() 
    	if isOpen then
	        self._viewMgr:showView("heroduel.HeroDuelMainView")
	    else
	    	local isOpen,openDes,lvlTip = self:isHeroDuelOpen()
			self._viewMgr:showTip(lvlTip or openDes)
    	end
	end)


	local _isOpen, _openDes, _lvlTip = self:isGloryArenaOpen()

    self._hole4 = self:getUI("bg.scrollView.hole4")

    self:isLocked(self._hole4, not _isOpen, _openDes)

	self._gloryArenaBg = self:getUI("bg.scrollView.hole4.heroBg")
	self._gloryArenaBg:setVisible(_isOpen)

	self._hole4:setScaleAnimMin(0.9)
    self._hole4.pointIcon = self._hole4:getChildByFullName("pointIcon")
    self._hole4.pointIcon:setVisible(false)
	if _isOpen then
		self._serverMgr:sendMsg("CrossArenaServer", "enterCrossArena", {},true ,{}, function(resule)
			self:updateGloryArena()
		end)
	else
		self._serverMgr:sendMsg("CrossArenaServer", "enterCrossArena", {},true ,{}, function(resule)
		end)
	end
    self:registerClickEvent(self._hole4, function()
--         if _isOpen then
-- --            self._modelMgr:getModel("GloryArenaModel"):lOpenGloryArena()
--             self._serverMgr:sendMsg("CrossArenaServer", "enterCrossArena", {},true ,{}, function(resule)
--                 self._viewMgr:showView("gloryArena.GloryArenaView")
--             end
--             )
--         else
			
--         end
		local _isOpen, _openDes, _lvlTip = self:isGloryArenaOpen()
		if _isOpen then
				self._serverMgr:sendMsg("CrossArenaServer", "enterCrossArena", {},true ,{}, function(resule)
					self._viewMgr:showView("gloryArena.GloryArenaView")
				end
			)
		else
			self._viewMgr:showTip(_lvlTip or _openDes)
			self._serverMgr:sendMsg("CrossArenaServer", "enterCrossArena", {},true ,{}, function(resule)
			end)
		end
	end)

	SystemUtils["enablesevenDayAim"]()
    self:reflashUI()
    self:listenReflash("ArenaModel", self.reflashUI)
    self:listenReflash("LeagueModel", self.reflashUI)
	self:listenReflash("PlayerTodayModel", self.reflashUI)
	self:listenReflash("GloryArenaModel", self.reflashUI)

    self._updateSche = ScheduleMgr:regSchedule(1000, self, function( )
    	self:updatePvpIn()
    end)
    self:updatePvpIn()

end

-- 刷新助战英雄
function PvpInView:addHeroIcon( )
	local batchId = self._modelMgr:getModel("LeagueModel"):getData().batchId
	local leagueActD = tab.leagueAct[tonumber(batchId)]
	if not leagueActD then
		leagueActD = tab.leagueAct[2016101]
	end
	local heroId = leagueActD.freehero[1]
	local sysHeroData = tab:Hero(tonumber(heroId))
	local heroName = lang(sysHeroData.heroname)
	local heroBg = self:getUI("bg.scrollView.hole2.heroBg")
	local icon = heroBg:getChildByName("icon")
	if not icon then
		icon = IconUtils:createHeroIconById({sysHeroData = sysHeroData})
		icon:setPosition(37,32)
		if icon:getChildByFullName("starBg") then
			icon:getChildByFullName("starBg"):removeFromParent()
		end
		if icon:getChildByFullName("iconStar") then
			icon:getChildByFullName("iconStar"):removeFromParent()
		end
		-- icon:setVisible(false)
		icon:setName("icon")
		icon:setScale(60 / icon:getContentSize().width)
		heroBg:addChild(icon)
	else
		IconUtils:updateHeroIconByView(icon,{sysHeroData = sysHeroData})
	end
	local heroNameLab = self:getUI("bg.scrollView.hole2.heroBg.heroName")
	heroNameLab:setFontName(UIUtils.ttfName_Title)
--	heroNameLab:setColor(cc.c3b(255,211,44))
--	heroNameLab:enable2Color(2, cc.c4b(246, 147, 42, 255))
--	heroNameLab:enableOutline(cc.c4b(27, 12, 4, 255), 1)
	heroNameLab:setString(heroName or "")
	
end

-- 更新英雄交锋特色信息
function PvpInView:updateHeroDuelFeature()
    local weekNum = self._modelMgr:getModel("HeroDuelModel"):getWeekNum()
    self._featureBg:getChildByFullName("titleName"):setString(lang(tab:HeroDuel(weekNum).charName))

    -- 赛季时间
    local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local year = tonumber(TimeUtils.date("%Y",nowTime))
    local month = TimeUtils.date("%m",nowTime)
    local daySum = TimeUtils.getDaysOfMonth(nowTime)
    self._featureBg:getChildByFullName("desLabel"):setString("赛季:" .. month..".01-"..month.."."..daySum)
end

-- 
function PvpInView:updateGloryArena()
	local bIsCross = self._modelMgr:getModel("GloryArenaModel"):bIsCross()
	local Season = self._modelMgr:getModel("GloryArenaModel"):lGetSeason()
	local resData = tab:HonorArenaResource(tonumber(Season))
	local GloryISOpne = self._modelMgr:getModel("GloryArenaModel"):lIsOpen()
	if GloryISOpne then
		self._hole4.pointIcon:setVisible(self._modelMgr:getModel("GloryArenaModel"):bIsCanMainTips())
	end
--	print("+++++++++++++++++++++", Season)
	if resData then
		self._gloryArenaBg:getChildByFullName("titleName"):setString(lang(resData.Name) or "涅槃")
		self._gloryArenaBg:getChildByFullName("desLabel"):setString("赛季:" .. self._modelMgr:getModel("GloryArenaModel"):lGetTimeShow(2))
		self._gloryArenaBg:getChildByFullName("titleTxt"):setString("本期奖励:")
		local icon = self._gloryArenaBg:getChildByFullName("icon")
		icon:ignoreContentAdaptWithSize(false)
		icon:loadTexture((resData.Resource1 or "ti_fenghuang") .. ".jpg", ccui.TextureResType.plistType)

		if icon.headIcon == nil then
			icon.headIcon = ccui.ImageView:create((resData.Resource2 or "avatarFrame_76") .. ".png", ccui.TextureResType.plistType)
			icon.headIcon:setContentSize(icon:getContentSize())
			icon.headIcon:setAnchorPoint(cc.p(0, 0))
            icon.headIcon:setScale(1.1)
            local _pos = cc.p(-6, -4)
--            local _pos = cc.p(-12, -15)
            if resData.offect then
                _pos = cc.p(resData.offect[1] or -6, resData.offect[2] or -4)
            end
            icon.headIcon:setPosition(_pos)
			icon:addChild(icon.headIcon)
		end
		icon:setScale(0.5)
	end

    -- 赛季时间
    -- local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    -- local year = tonumber(TimeUtils.date("%Y",nowTime))
    -- local month = TimeUtils.date("%m",nowTime)
    -- local daySum = TimeUtils.getDaysOfMonth(nowTime)
    -- self._gloryArenaBg:getChildByFullName("desLabel"):setString("赛季:" .. month..".01-"..month.."."..daySum)
end

function PvpInView:updatePvpIn( )
	if self._modelMgr:getModel("LeagueModel"):isMondayRest() then
		if not self._mondayRest then
			self._mondayRest = true
			local isOpen,openDes = self:isLeagueOpen()
			self:isLocked(self._hole2,not isOpen,openDes)
			self._heroBg:setVisible(isOpen)
			self:reflashUI()
		end
	elseif self._mondayRest then
		self._mondayRest = false
		local isOpen,openDes = self:isLeagueOpen()
		self:isLocked(self._hole2,not isOpen,openDes)
		self._heroBg:setVisible(isOpen)
		local batchId = self._modelMgr:getModel("LeagueModel"):getData().batchId
		if batchId then
			self:addHeroIcon()
		end
		self:reflashUI()
	end
	local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
	if tonumber(os.date("%w",nowTime)) == 0 or tonumber(os.date("%w",nowTime)) == 1 then
		if self._modelMgr:getModel("LeagueModel"):isInMidSeasonRestTime() then
		    if not self._inRestTime then
				self._inRestTime = true
				self:reflashUI()
			end
		elseif self._inRestTime then
			self._inRestTime = false
			self:reflashUI()
		end
	end

    local function gloryCallback()
        local gloryArenaMode = ModelManager:getInstance():getModel("GloryArenaModel")
        if not tolua.isnull(self) and  self.isGloryArenaOpen and self.isLocked and self.getUI then
            local _isOpen, _openDes, _lvlTip = self:isGloryArenaOpen()
            local hole4 = self:getUI("bg.scrollView.hole4")
            self:isLocked(hole4, not _isOpen, _openDes)
            if _isOpen and self.updateGloryArena then
                self:updateGloryArena()
			end
			local gloryArenaBg = self:getUI("bg.scrollView.hole4.heroBg")
			if gloryArenaBg then
				gloryArenaBg:setVisible(_isOpen)
			end
        end
    end
    self._modelMgr:getModel("GloryArenaModel"):lCheckTime(gloryCallback)
end

function PvpInView:isSysOpen( sOpenId, desLab )
	local openDes = ""
	local isOpen = true
	local serverBeginTime = ModelManager:getInstance():getModel("UserModel"):getData().sec_open_time
	if serverBeginTime then
		local sec_time = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(serverBeginTime,"%Y-%m-%d 05:00:00"))
		if serverBeginTime < sec_time then   --过零点判断
			serverBeginTime = sec_time - 86400
		end
	end
	local sTimeOpenD = tab:STimeOpen(sOpenId or 101)
	if not sTimeOpenD then
		sTimeOpenD = tab:STimeOpen(101)
	end
	print("serverBeginTime??????????",os.date("%x",serverBeginTime),sTimeOpenD.opentime)
	local serverHour = tonumber(TimeUtils.date("%H",serverBeginTime)) or 0
	local nowTime = ModelManager:getInstance():getModel("UserModel"):getCurServerTime()
	local openDay = (sTimeOpenD.opentime or 1)-1
	local openTimeNotice = sTimeOpenD.openhour or 0
	local openHour = string.format("%02d:00:00",openTimeNotice)
	local openTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(serverBeginTime + openDay*86400,"%Y-%m-%d " .. openHour))
    local leftTime = openTime - nowTime
	local isOpen = leftTime <= 0
	-- print("======================serverBeginTime",TimeUtils.date("%x",serverBeginTime),serverBeginTime,serverHour,leftTime,math.floor(leftTime/3600))
	local hole2DesLab = desLab or self:getUI("bg.scrollView.hole2.lockbg.des")
	if leftTime > 86400 and not isOpen then
		openDes = "距玩法开启还有".. ( math.ceil(leftTime/86400) or openDay or 7) .."天"
		desLab:getVirtualRenderer():setMaxLineWidth(1000)
		if not self._daySche then
			local dayCountDown = leftTime 
			self._daySche = ScheduleMgr:regSchedule(1000, self, function( )
				dayCountDown = dayCountDown - 1
				if dayCountDown < 86400 then
					local leagueOpen = self:isLeagueOpen()
					local heroDuelOpen = self:isHeroDuelOpen()
					local gloryArenaOpen = self:isGloryArenaOpen()
					if leagueOpen and heroDuelOpen and gloryArenaOpen then 
						ScheduleMgr:unregSchedule(self._daySche)
						self._daySche = nil 
					end
				end
			end)
		end
	elseif leftTime < 86400 and leftTime > 0 then
		if sOpenId == 101 then 
			openDes = self:upDateLeagueTime(serverBeginTime,openDay,serverHour,openTimeNotice)
			if not self._leagueOpenSch then
				self._leagueOpenSch = ScheduleMgr:regSchedule(1000, self, function( )
					self:upDateLeagueTime(serverBeginTime,openDay,serverHour,openTimeNotice)
				end)
			end
		end
		if sOpenId == 104 then
			openDes = self:updateHeroDuelTime(serverBeginTime,openDay,serverHour,openTimeNotice)
			if not self._heroDuelOpenSch then
				self._heroDuelOpenSch = ScheduleMgr:regSchedule(1000, self, function( )
					self:updateHeroDuelTime(serverBeginTime,openDay,serverHour,openTimeNotice)
				end)
			end
		end

		if sOpenId == 106 then
			openDes = self:updateGloryArenaTime(serverBeginTime,openDay,serverHour,openTimeNotice)
			if not self._gloryArenaOpenSch then
				self._gloryArenaOpenSch = ScheduleMgr:regSchedule(1000, self, function( )
					self:updateGloryArenaTime(serverBeginTime,openDay,serverHour,openTimeNotice)
				end)
			end
		end

	end 
	local lvlTip
	if isOpen then -- 后判断等级
		local openTab = sTimeOpenD
		local openLvl = openTab.level
		local userLvl = ModelManager:getInstance():getModel("UserModel"):getData().lvl
		if openLvl > userLvl then
			isOpen = false 
			openDes = "玩家等级" .. openLvl .. "开启" --  --
			if sOpenId == 101 then 
				lvlTip = lang("TIP_LEAGUE")
			elseif sOpenId == 104 then
				lvlTip = lang("TIP_HERODUEL")
            elseif sOpenId == 106 then
                lvlTip = lang("honorArena_tip_7")
			end
		end
	end
	if sOpenId == 101 and isOpen then
		if self._modelMgr:getModel("LeagueModel"):isMondayRest() then
			isOpen = false
			-- openDes = "即将开启"
			lvlTip = lang("LEAGUETIP_18")
		end
	end

	if sOpenId == 106 and isOpen then
		if not self._modelMgr:getModel("GloryArenaModel"):lIsCurTimeOpen() then
			isOpen = false
			-- openDes = "即将开启"
			lvlTip = lang("honorArena_tip_6")
		end
        if isOpen then
            isOpen, lvlTip = self._modelMgr:getModel("GloryArenaModel"):lCheckAdditionalContion()
        end
	end

	return isOpen,openDes,lvlTip -- false,"暂未开启",
end

function PvpInView:isLeagueOpen(sOpenId,desLab)
	local isOpen,openDes,lvlTip = self:isSysOpen(101,self:getUI("bg.scrollView.hole2.lockbg.des")) 
	return isOpen,openDes,lvlTip -- false,"暂未开启",
end

function PvpInView:isGloryArenaOpen(sOpenId,desLab)
	local isOpen,openDes,lvlTip = self:isSysOpen(106,self:getUI("bg.scrollView.hole4.lockbg.des")) 
	return isOpen,openDes,lvlTip -- false,"暂未开启",
end

function PvpInView:isHeroDuelOpen( sOpenId,desLab )
	if not self._modelMgr:getModel("HeroDuelModel"):getHDuelIsOpen() then return false,"敬请期待" end
	local isOpen,openDes,lvlTip = self:isSysOpen(104,self:getUI("bg.scrollView.hole3.lockbg.des")) 
	return isOpen,openDes,lvlTip --lang("TIP_HERODUEL") -- false,"暂未开启",
end

function PvpInView:upDateLeagueTime(serverBeginTime,openDay,serverHour,openTimeNotice )
	local hole2DesLab
	hole2DesLab = self:getUI("bg.scrollView.hole2.lockbg.des")
	local nowTime = ModelManager:getInstance():getModel("UserModel"):getCurServerTime()
	-- local leftTime = openDay*86400 - (nowTime-serverBeginTime) - (serverHour-5)*3600
	local openHour = string.format("%02d:00:00",openTimeNotice)
	local openTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(serverBeginTime + openDay*86400,"%Y-%m-%d " .. openHour))
    local leftTime = openTime - nowTime
	-- leftTime = leftTime-1
	-- print("···",math.floor(leftTime/3600),math.floor(leftTime%3600/60),math.floor(leftTime%60))
	local openDes 
	if leftTime < 0 and self._leagueOpenSch then
		local isOpen = self:isLeagueOpen()
		_,openDes = self:isLeagueOpen()
		hole2DesLab:setString(openDes)
		hole2DesLab:setVisible(true)
		self:isLocked(self._hole2,not isOpen)
		ScheduleMgr:unregSchedule(self._leagueOpenSch)
		self._leagueOpenSch = nil 
		self._heroBg:setVisible(isOpen)
		self:addHeroIcon()
	else
		openDes = --"据玩法开启还有" .. math.floor(leftTime/3600) .. ":" .. math.floor(leftTime%3600/60) .. ":" .. math.floor(leftTime%60)
		string.format("距玩法开启还有%02d:%02d:%02d",math.floor(leftTime/3600),
			math.floor(leftTime%3600/60),math.floor(leftTime%60))
	end
	if hole2DesLab then
		hole2DesLab:setString(openDes)
		hole2DesLab:getVirtualRenderer():setMaxLineWidth(180)
		hole2DesLab:setTextHorizontalAlignment(1)
	end
	return openDes
end

function PvpInView:updateHeroDuelTime( serverBeginTime,openDay,serverHour,openTimeNotice )
	local hole3DesLab
	hole3DesLab = self:getUI("bg.scrollView.hole3.lockbg.des")
	local nowTime = ModelManager:getInstance():getModel("UserModel"):getCurServerTime()
	-- local leftTime = openDay*86400 - (nowTime-serverBeginTime) - (serverHour-5)*3600
	local openHour = string.format("%02d:00:00",openTimeNotice)
	local openTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(serverBeginTime + openDay*86400,"%Y-%m-%d " .. openHour))
    local leftTime = openTime - nowTime
	-- leftTime = leftTime-1
	-- print("···",math.floor(leftTime/3600),math.floor(leftTime%3600/60),math.floor(leftTime%60))
	local openDes 
	if leftTime < 0 and self._heroDuelOpenSch then
		local isOpen = self:isHeroDuelOpen()
		_,openDes = self:isHeroDuelOpen()
		hole3DesLab:setString(openDes)
		hole3DesLab:setVisible(true)
		self:isLocked(self._hole3,not isOpen)
		if isOpen then
	        self:updateHeroDuelFeature()
	    end
		ScheduleMgr:unregSchedule(self._heroDuelOpenSch)
		self._heroDuelOpenSch = nil 
		self._featureBg:setVisible(isOpen):setVisible(isOpen)
	else
		openDes = --"据玩法开启还有" .. math.floor(leftTime/3600) .. ":" .. math.floor(leftTime%3600/60) .. ":" .. math.floor(leftTime%60)
		string.format("距玩法开启还有%02d:%02d:%02d",math.floor(leftTime/3600),
			math.floor(leftTime%3600/60),math.floor(leftTime%60))
	end
	if hole3DesLab then
		hole3DesLab:setString(openDes)
		hole3DesLab:getVirtualRenderer():setMaxLineWidth(180)
		hole3DesLab:setTextHorizontalAlignment(1)
	end
	return openDes
end

function PvpInView:updateGloryArenaTime( serverBeginTime,openDay,serverHour,openTimeNotice )
	local hole3DesLab
	hole3DesLab = self:getUI("bg.scrollView.hole4.lockbg.des")
	local nowTime = ModelManager:getInstance():getModel("UserModel"):getCurServerTime()
	-- local leftTime = openDay*86400 - (nowTime-serverBeginTime) - (serverHour-5)*3600
	local openHour = string.format("%02d:00:00",openTimeNotice)
	local openTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(serverBeginTime + openDay*86400,"%Y-%m-%d " .. openHour))
    local leftTime = openTime - nowTime
	-- leftTime = leftTime-1
	-- print("···",math.floor(leftTime/3600),math.floor(leftTime%3600/60),math.floor(leftTime%60))
	local openDes 
	if leftTime < 0 and self._gloryArenaOpenSch then
		local isOpen, openDes = self:isGloryArenaOpen()
		hole3DesLab:setString(openDes)
		hole3DesLab:setVisible(true)
		self:isLocked(self._hole3,not isOpen)
		if isOpen then
	        self:updateGloryArena()
	    end
		ScheduleMgr:unregSchedule(self._gloryArenaOpenSch)
		self._gloryArenaOpenSch = nil 
		self._gloryArenaBg:setVisible(isOpen)
	else
		openDes = --"据玩法开启还有" .. math.floor(leftTime/3600) .. ":" .. math.floor(leftTime%3600/60) .. ":" .. math.floor(leftTime%60)
		string.format("距玩法开启还有%02d:%02d:%02d",math.floor(leftTime/3600),
			math.floor(leftTime%3600/60),math.floor(leftTime%60))
	end
	if hole3DesLab then
		hole3DesLab:setString(openDes)
		hole3DesLab:getVirtualRenderer():setMaxLineWidth(180)
		hole3DesLab:setTextHorizontalAlignment(1)
	end
	return openDes
end

function PvpInView:isLocked( node,lock,lockDes )
	local lockbg = node:getChildByFullName("lockbg")
	if not lockbg then return end
	lockbg:setOpacity(0)
	local des = lockbg:getChildByFullName("des")
	des:enableOutline(cc.c4b(0, 0, 0, 128),2)
	des:setString(lockDes or "")

	UIUtils:setGray(node,lock)
	-- -- img:setColor(color)
	-- -- node:setBrightness(-10)
 --    img:setContrast(lock and -10 or 0)
    -- img:setHue(lock and 20 or 0)
    -- img:setSaturation(lock and -90 or 0)
	node:setBrightness(lock and -10 or 0)
	lockbg:setVisible(lock)

	lockbg:setHue(-10)
    lockbg:setSaturation(80)
end
-- 第一次进入调用, 有需要请覆盖
function PvpInView:onShow()
	self:updatePvpIn()
end

-- 第一次进入调用, 有需要请覆盖
function PvpInView:onHide()
    if self._updateSche then
        print("PvpInView:onHide")
		ScheduleMgr:unregSchedule(self._updateSche)
		self._updateSche = nil 
	end
end

-- 接收自定义消息
function PvpInView:reflashUI(data)
	local arenaModel = ModelManager:getInstance():getModel("ArenaModel")
	local newReport = ModelManager:getInstance():getModel("PlayerTodayModel").newArenaReport
	local formationModel = ModelManager:getInstance():getModel("FormationModel")
	local isFormationFull = formationModel:isFormationTeamFullByType(formationModel.kFormationTypeArenaDef)
   	local isFullWeapons = formationModel:isHaveWeaponCanLoaded(formationModel.kFormationTypeArenaDef)
    if arenaModel:haveAward() or newReport or not isFormationFull or arenaModel:haveChanllengeNum()
    	or isFullWeapons 
    then
       	self._hole1.pointIcon:setVisible(true)
   	else
       	self._hole1.pointIcon:setVisible(false)
   	end

   	local leagueModel = ModelManager:getInstance():getModel("LeagueModel")
	local isFullWeapons = formationModel:isHaveWeaponCanLoaded(formationModel.kFormationTypeLeague)
	if (leagueModel:haveAward() 
		or leagueModel:timeAwardFull() 
		or leagueModel:haveChallengeNum()
		or isFullWeapons) 
		and not leagueModel:isInMidSeasonRestTime() 
	then
	   self._hole2.pointIcon:setVisible(true)
	else
	   self._hole2.pointIcon:setVisible(false)
	end
    if self._hole4 then
        local _isOpen, _openDes, _lvlTip = self:isGloryArenaOpen()
        self:isLocked(self._hole4, not _isOpen, _openDes)
	    self._gloryArenaBg:setVisible(_isOpen)
        self._hole4.pointIcon:setVisible(false)
	    if _isOpen then
		    self:updateGloryArena()
	    end
    end

--    local gloryArenaMode = ModelManager:getInstance():getModel("GloryArenaModel")
--	local GloryISOpne = gloryArenaMode:lIsOpen()
--	if GloryISOpne then
--		self._hole4.pointIcon:setVisible(gloryArenaMode:bIsCanMainTips())
--	end
end
function PvpInView:beforePopAnim()
	PvpInView.super.beforePopAnim(self)
	for i=1,4 do
		self["_hole" .. i]:setCascadeOpacityEnabled(true, true)
		self["_hole" .. i]:setOpacity(0)
		self["_hole" .. i]:setScaleAnim(true)
		local lockbg = self["_hole" .. i]:getChildByName("lockbg")
		if lockbg then
			lockbg:setCascadeOpacityEnabled(true)
			lockbg:setOpacity(0)
		end
	end
end
-- 重载出现动画
function PvpInView:popAnim(callback)
	-- 执行父节点动画
	PvpInView.super.popAnim(self, nil)

    self:lock(-1)
	-- 定义自己动画
	local delayTime = 0.1
	local moveTime = 0.1
	local springTime = 0.2
	local fadeInTime = 0.2
	local moveDis = 200
	local springDis = 10
	for i=1,4 do
		local hole = self["_hole" .. i]
		local holeInitPos = cc.p(hole:getPositionX(),hole:getPositionY())
		local holeSpringPos = cc.p(hole:getPositionX()-springDis,hole:getPositionY())
		local holebeginPos = cc.p(hole:getPositionX()+moveDis,hole:getPositionY())
		hole:setPosition(holebeginPos)
		local holeDelayTime = delayTime*(i-1)
		local delayAct = cc.DelayTime:create(holeDelayTime)
		local spawn = cc.Spawn:create(cc.MoveTo:create(moveTime,holeSpringPos),cc.FadeIn:create(fadeInTime))
		local seq
		if i == 3 then
			seq = cc.Sequence:create(delayAct,spawn,cc.MoveTo:create(springTime,holeInitPos), cc.CallFunc:create(function ()
				if callback then
					callback()
				end
			end))
		else
			seq = cc.Sequence:create(delayAct,spawn,cc.MoveTo:create(springTime,holeInitPos))
		end
		self["_hole" .. i]:runAction(seq)
		local lockbg = self["_hole" .. i]:getChildByName("lockbg")
		if lockbg then
			lockbg:runAction(cc.Sequence:create(cc.FadeIn:create(fadeInTime),cc.CallFunc:create(function( )
				lockbg:setCascadeOpacityEnabled(false)
				lockbg:setOpacity(0)
			end)) )
		end
	end

    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.4), cc.CallFunc:create(function()
        self:unlock()
    end)))
end

function PvpInView:openCountDown()
    

end

function PvpInView:closeCountDown()


end

function PvpInView:onDestroy( )
	if self._leagueOpenSch then
		ScheduleMgr:unregSchedule(self._leagueOpenSch)
		self._leagueOpenSch = nil 
	end
	if self._heroDuelOpenSch then
		ScheduleMgr:unregSchedule(self._heroDuelOpenSch)
		self._heroDuelOpenSch = nil 
	end
	if self._daySche then
		ScheduleMgr:unregSchedule(self._daySche)
		self._daySche = nil 
	end
	if self._updateSche then
		ScheduleMgr:unregSchedule(self._updateSche)
		self._updateSche = nil 
	end
	if self._gloryArenaOpenSch then
		ScheduleMgr:unregSchedule(self._gloryArenaOpenSch)
		self._gloryArenaOpenSch = nil 
	end
	PvpInView.super.onDestroy(self)
end
return PvpInView