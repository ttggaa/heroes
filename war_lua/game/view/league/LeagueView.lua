--
-- Author: <wangguojun@playcrab.com>
-- Date: 2016-07-05 13:59:30
--

local LeagueView = class("LeagueView",BaseView)
function LeagueView:ctor()
    self.super.ctor(self)
    self.initAnimType = 2
    self._leagueModel = self._modelMgr:getModel("LeagueModel")
    self._teamModel = self._modelMgr:getModel("TeamModel")
end

function LeagueView:getAsyncRes()
    return 
    {
        {"asset/ui/league.plist", "asset/ui/league.png"},
        {"asset/ui/league1.plist", "asset/ui/league1.png"},
        {"asset/ui/arena.plist", "asset/ui/arena.png"},
        {"asset/ui/heroDuel2.plist", "asset/ui/heroDuel2.png"},
        {"asset/bg/bg_league2.plist", "asset/bg/bg_league2.png"}
    }
end

function LeagueView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{hideInfo=true,hideHead=true,hideBtn=false})
end
-- 第一次被加到父节点时候调用
function LeagueView:onBeforeAdd(callback, errorCallback)
	local leagueData = self._modelMgr:getModel("LeagueModel"):getData()
    if not next(leagueData) then
        self._serverMgr:sendMsg("LeagueServer", "enterLeague", {}, true, {}, function(result)
            self:reflashUI()
            callback()
        end, function (errorCode)
            if errorCode == 3216 then
                self._viewMgr:showTip("shopppppppppp")
            end
            errorCallback()
        end)
    else
        self:reflashUI()
        callback()
    end
end
-- 自动添加描边
function LeagueView:enableDefaultOutline(element)
    if element == nil then
        element = self._widget
    end
    local desc = element:getDescription()
    local nameStr = element:getName()
    if desc == "Label" and name ~= "stage" and name ~= "sloganLab" then
        element:setFontName(UIUtils.ttfName)
    	element:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    end
    local count = #element:getChildren()
    for i = 1, count do
        self:enableDefaultOutline(element:getChildren()[i])
    end
end
function LeagueView:getBgName()
    return "bg_league.jpg"
end

-- 初始化UI后会调用, 有需要请覆盖
function LeagueView:onInit()
	-- 通用动态背景
	-- self:addAnimBg()

	self:enableDefaultOutline()
	self._bg           = self:getUI("bg")
    self._topLayer     = self:getUI("bg.topLayer")
	self._leagueTime   = self:getUI("bg.topLayer.leagueTime")
	self._leagueTime:setColor(cc.c3b(250, 242, 192))
	self._leagueTime:enable2Color(1,cc.c4b(255, 195, 17, 255))
	self._name         = self:getUI("bg.name")
	self._level        = self:getUI("bg.level")
	self._leftNum      = self:getUI("bg.btnBg.leftNum")
	self._cdLabel      = self:getUI("bg.cdLabel")
	self._matchBtn     = self:getUI("bg.btnBg.matchBtn")
    self._sloganBg     = self:getUI("bg.btnBg.sloganBg")
    self._sloganLab    = self:getUI("bg.btnBg.sloganBg.sloganLab")
    self._sloganLab:setFontSize(20)
    self._sloganLab:getVirtualRenderer():setMaxLineWidth(175)
    self._sloganLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    self._sloganLab:setName("sloganLab")
    self._sloganLab:disableEffect()
    -- self._sloganBg:setCascadeOpacityEnabled(true)
    self._sloganBg:setVisible(false)
    local seq = cc.Sequence:create(cc.ScaleTo:create(1, 1.1), cc.ScaleTo:create(1, 1))
    self._sloganBg:runAction(cc.RepeatForever:create(seq))
    self._statusLab = self:getUI("bg.blueFlag.statusLab")
    self._statusLab:getVirtualRenderer():setMaxLineWidth(140)
    self._statusLab:setVisible(false)
        -- self._bg3 = self:getUI("bg3")
    self:registerClickEvent(self._matchBtn,function( )
        -- self:showChangeAnim(2,1,1120,1000)
        -- if true then return end
        if self._leagueModel:isInMidSeasonRestTime() then self._viewMgr:showTip(lang("LEAGUETIP_10")) return end
        self:detectOpen()
        if self._matchBtn._tip then
            if tonumber(self._matchBtn._tip) then
                self:sendBuyChallengeNumMsg(true)
            else
                self._viewMgr:showTip(self._matchBtn._tip)
            end
            return 
        end
        self:showMatchView()
        -- self._viewMgr:showView("league.LeagueMatchView",{parent = self,callback=function( matchResult )
        --     if matchResult then
        --         self:challengeEnemy(matchResult)
        --     end
        -- end})
    end)
    self._chanceNum     = self:getUI("bg.btnBg.chanceNum")
    self._addChangeBtn  = self:getUI("bg.btnBg.addChangeBtn")
    self:registerClickEvent(self._addChangeBtn,function( )
        if self._leagueModel:isInMidSeasonRestTime() then self._viewMgr:showTip(lang("LEAGUETIP_10")) return end
        
        self:sendBuyChallengeNumMsg()
    end)

	-- left board
    self._redFlag       = self:getUI("bg.redFlag")
	self._stage         = self:getUI("bg.redFlag.stage")
    self._stage:setFontName(UIUtils.ttfName)
	self._stage:setColor(cc.c3b(250, 242, 192))
	self._stage:enable2Color(2,cc.c4b(255, 195, 17, 255))
    self._stageImg      = self:getUI("bg.redFlag.stageImg")
	self:registerClickEvent(self._stageImg,function( )
        self._viewMgr:showDialog("league.LeagueStageView",{},true)
    end)
    self._redDes1       = self:getUI("bg.redFlag.redDes1")
	self._redDes1:setString("产量:")
	self._redDes2       = self:getUI("bg.redFlag.redDes2")
	self._redDes2:setString("奖励:")
	self._num1          = self:getUI("bg.redFlag.num1")
	self._num2          = self:getUI("bg.redFlag.num2")
    self._leagueCoin2   = self:getUI("bg.redFlag.leagueCoin2")
    self._hadGetImg     = self:getUI("bg.redFlag.hadGetImg")
    self._progress      = self:getUI("bg.redFlag.progress")
	self._progressLabel = self:getUI("bg.redFlag.progressLabel")
	self._rewardBtn     = self:getUI("bg.redFlag.rewardBtn")
    local rewardMc      = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true, false)
    rewardMc:setName("anim")
    rewardMc:setScale(0.95,1)
    rewardMc:setPosition(63, 29)
    self._btnMc         = rewardMc 
    self._fullStampt    = self:getUI("bg.redFlag.stampt")
    self._fullStampt:setVisible(false)
    self._rewardBtn:addChild(rewardMc, 1)
	self:registerClickEvent(self._rewardBtn,function()
        local addedAward= self._awardNum or 0
        if addedAward >= 1 then
            local preLeagueCoin = self._modelMgr:getModel("UserModel"):getData().leagueCoin 
    		self._serverMgr:sendMsg("LeagueServer", "getAward", {}, true, {}, function(result)
                local curLeagueCoin = self._modelMgr:getModel("UserModel"):getData().leagueCoin 
                local gainCoin = curLeagueCoin-preLeagueCoin
                if gainCoin > 0 then
                    DialogUtils.showGiftGet({{"leagueCoin",0,gainCoin}})
                end
    		end)
        else
            self._viewMgr:showTip(lang("LEAGUETIP_11") or "暂无奖励领取")
        end
	end)

    local stageBgW,stageBgH = self._stageImg:getContentSize().width,self._stageImg:getContentSize().height

	-- rigth board
    self._blueFlag  = self:getUI("bg.blueFlag")
	self._bdes1     = self:getUI("bg.blueFlag.hotPanel.des1")
    self._bdes2     = self:getUI("bg.blueFlag.selPanel.des2")
    self._bnum1     = self:getUI("bg.blueFlag.hotPanel.num1")
    self._bnum2     = self:getUI("bg.blueFlag.selPanel.num2")
    self._bdes1:setString(lang("LEAGUETIP_05"))
    self._bnum1:setString( "+" .. tab:Setting("G_LEAGUE_HOTSPOT").value[1] .. "%")
    self._bdes2:setString(lang("LEAGUETIP_06"))
    self._bnum2:setString( "+" .. tab:Setting("G_LEAGUE_HOTSPOT").value[2] .. "%")
	self._hotPanel     = self:getUI("bg.blueFlag.hotPanel")
	self._selPanel     = self:getUI("bg.blueFlag.selPanel")
    self._selHots      = {}
    for i=1,3 do
        local hotIcon  = self:getUI("bg.blueFlag.selPanel.hot" .. i)
        local function openSetSpotView( )
            if self._leagueModel:isInMidSeasonRestTime() then self._viewMgr:showTip(lang("LEAGUETIP_10")) return end
        
            self._serverMgr:sendMsg("LeagueServer", "getHot", {}, true, {}, function(result) 
                self._viewMgr:showDialog("league.LeagueSetSpot",{},true)
            end)
        end
        self:registerClickEvent(hotIcon,function( )
            if i > tab:LeagueRank(self._curZone).hotspot or not self._isOpen then return end
            if not next(self._leagueModel:getHot()) then
                openSetSpotView()
            else
                -- self._viewMgr:showDialog("league.LeagueSetSpot",{},true)
                local hotSpotInfo = self._leagueModel:getCurZoneHot(self._leagueData.league.currentZone)
                if hotSpotInfo and hotSpotInfo.hot and hotSpotInfo.hot ~= "" then
                    local hot = string.split(hotSpotInfo.hot,",")
                    if hot[i] then
                        self._viewMgr:showDialog("league.LeagueSeasonHotView",{ids = hot,upNum = 100},true)
                    else
                        openSetSpotView( )
                    end
                else
                    openSetSpotView( )
                end
            end
        end)
        table.insert(self._selHots,hotIcon)
    end
    self._seasonHots = {}
    for i=1,2 do
        local hotIcon = self:getUI("bg.blueFlag.hotPanel.hot" .. i)
        table.insert(self._seasonHots,hotIcon)
    end
    local formationModel = self._modelMgr:getModel("FormationModel")
    local leagueFormation = formationModel:getFormationDataByType(formationModel.kFormationTypeLeague)
    self._heroBody = self:getUI("bg.heroBody")
    self._rankHeroLy = self:getUI("bg.rankHeroLy")
    local heroId = leagueFormation.heroId
    if heroId then
        local heroD = tab:Hero(heroId or 60001)
        self:updateHeroSp(heroId)
    end
	local btnNames = {
		"shangdian",
		"guize",
		"award",
		"zhanbao",
		"buzhen",
		"paihang",
	}
	local btnFuncs = {
		function( )-- 1
            if self._modelMgr:getModel("LeagueModel"):isMondayRest() then
                self._viewMgr:showTip(lang("LEAGUETIP_18"))
                return 
            end
            local shopData = self._modelMgr:getModel("ShopModel"):getShopGoods("league") or {}
            if not next(shopData) then
                self._serverMgr:sendMsg("ShopServer", "getShopInfo", {type = "league"}, true, {}, function(result)
                    self._viewMgr:showView("shop.ShopView",{idx = 6})
                end)
            else
    			self._viewMgr:showView("shop.ShopView",{idx = 6})
            end
		end,
		function( )-- 2
			self._viewMgr:showDialog("league.LeagueRuleView",{},true)
		end,
		function( )-- 3
			self._viewMgr:showDialog("league.LeagueAwardView",{},true)
		end,
		function( )-- 4
            if self._leagueModel:isInMidSeasonRestTime() then self._viewMgr:showTip(lang("LEAGUETIP_10")) return end
        
            self._serverMgr:sendMsg("LeagueServer","getReportList",{time = 0},true,{},function( result )
    			self._viewMgr:showDialog("league.LeagueBattleReport",{},true)
            end)
		end,
		function( )-- 5
			self._viewMgr:showView("formation.NewFormationView", {
                formationType = self._modelMgr:getModel("FormationModel").kFormationTypeLeague,
                recommend = self._hotIds or {},
                extend = {
                    heroes = self._leagueModel:getLeagueHeroIds(),
                    helpHero = {self._modelMgr:getModel("LeagueModel"):getCurHelpHeroId()},
                    nextHelpHero = {self._modelMgr:getModel("LeagueModel"):getNextHelpHeroId()},
                    showHelpTag = true,
                },
            })    
		end,
		function( )-- 6
            -- 实时抓数据
            if self._leagueModel:isInMidSeasonRestTime() then self._viewMgr:showTip(lang("LEAGUETIP_10")) return end
        
            self._serverMgr:sendMsg("LeagueServer", "getRank", {page=1}, true, {}, function(result) 
    			self._viewMgr:showDialog("league.LeagueRankView",{},true)
            end)
		end,
	}
    self._btnBg = self:getUI("bg.btnBg")
    self._btns = {}
    local btnTitleNames = {"商店","规则","奖励","战报","布阵","排行"}
	for i,btnName in ipairs(btnNames) do
        UIUtils:addFuncBtnName( self:getUI("bg.btnBg." .. btnName),btnTitleNames[i],nil,true )
		self:registerClickEventByName("bg.btnBg." .. btnName,function( )
			btnFuncs[i]()
		end)
        self._btns[i] = self:getUI("bg.btnBg." .. btnName)
	end

	self:listenReflash("LeagueModel", self.reflashUI)
    self:listenReflash("FormationModel", self.reflashUI)
    self._updateTenMinutes = ScheduleMgr:regSchedule(1000,self,function( )
        self:updateAward()
    end)
    self:updateAward()
    self:addSmallPeople()
    -- self:detectDot()
    self:registerTimer(5, 0, 0, function ()
        if self._leagueModel:isInMidSeasonRestTime() then self._viewMgr:showTip(lang("LEAGUETIP_10")) return end
        self._serverMgr:sendMsg("LeagueServer", "enterLeague", {}, true, {}, function(result)
            self:reflashUI()

        end,function( errorCode )
            if tonumber(errorCode) == 3216 then
                self._viewMgr:showTip("shopppppppppp")
            end
        end)
    end)
    self:registerTimer(9, 0, 0, function ()
        if self._leagueModel:isInMidSeasonRestTime() then self._viewMgr:showTip(lang("LEAGUETIP_10")) return end
        self._serverMgr:sendMsg("LeagueServer", "enterLeague", {}, true, {}, function(result)
            self:reflashUI()
        end,function( errorCode )
            if tonumber(errorCode) == 3216 then
                self._viewMgr:showTip("shopppppppppp")
            end
        end)
    end)

    -- 本地排行新逻辑 by guojun 2017.6.16
    self._localRankBtn = self:getUI("bg.localRankBtn")
    if self._localRankBtn then
        local isGodWarOpen = self._modelMgr:getModel("GodWarModel").isGodWarOpenFightWeek and self._modelMgr:getModel("GodWarModel"):isGodWarOpenFightWeek()
        UIUtils:addFuncBtnName( self:getUI("bg.localRankBtn"),"诸神名单",nil,nil )
        self._localRankBtn:setVisible(isGodWarOpen or false)
        self._localRankBtn:setPosition(340,480)
        if isGodWarOpen then
            local mc = mcMgr:createViewMC("lingzhushouce_lianmengjihuo", true, false) 
            -- mc:setScale(0.9)
            mc:setPosition(cc.p(self._localRankBtn:getContentSize().width*0.5, self._localRankBtn:getContentSize().height*0.5))
            mc:setName("diguang")
            self._localRankBtn:addChild(mc,-1)
        end
    end
    self:registerClickEventByName("bg.localRankBtn",function() 
        -- 实时抓数据
        if self._leagueModel:isInMidSeasonRestTime() then self._viewMgr:showTip(lang("LEAGUETIP_10")) return end
    
        self._serverMgr:sendMsg("LeagueServer", "getSecRank", {page=1}, true, {}, function(result) 
            if not self._viewMgr then return end
            if next(result) then
                self._viewMgr:showDialog("league.LeagueLocalRankView",{},true)
            else
                self._viewMgr:showTip("名单生成中···")
            end
        end)
    end)
end

-- function LeagueView:onAnimEnd()
--     local isFirst = self._leagueModel:getData().first and self._leagueModel:getData().first ~= 0
--     if isFirst then
--         local curZone = self._leagueModel:getCurZone()
--         if curZone == 2 then
--             GuideUtils.checkTriggerByType("action", "10")
--         elseif curZone == 3 then
--             GuideUtils.checkTriggerByType("action", "11")
--         end
--     end
-- end

function LeagueView:showMatchView( )
    self._viewMgr:showNavigation("global.UserInfoView",{hideInfo=true,hideHead=true,hideBtn=true})
    if not self._matchView then
        UIUtils:reloadLuaFile("league.LeagueMatchView")
        self._matchView = self:createLayer("league.LeagueMatchView",{parent = self,callback=function( matchResult )
            if matchResult then
                self._matchResult = matchResult
                self:challengeEnemy(matchResult)
            else
                self._matchView:setVisible(false)
                self:setNavigation()
            end
        end})
        self._matchView:setName("LeagueMatchView")
        self._matchView:setPosition(0,0)
        self._bg:addChild(self._matchView,999)
    end

    self._matchView:setVisible(true)
    self._matchView:beforePopAnim()
    self._matchView:popAnim()
end

function LeagueView:detectOpen( )
    -- [[ 判断是否周一休息
    if self._modelMgr:getModel("LeagueModel"):isMondayRest() then
        self:reflashAwardTip()
        self._viewMgr:closeCurView()
        ViewManager:getInstance():showTip(lang("LEAGUETIP_18"))
        return
    end
    --]]
    local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    -- if true then return end
    local hour = tonumber(TimeUtils.date("%H",nowTime))
    local min = tonumber(TimeUtils.date("%M",nowTime))
    -- print("min",min)

    local currWeek = tonumber(TimeUtils.date("%w",nowTime))
    -- print("=============beginWeek=========",currWeek)   
    
    --周一五点到周天十点 
    local low,high = tab:Setting("G_LEAGUE_OPENTIME").value[1],tab:Setting("G_LEAGUE_OPENTIME").value[2]
    -- local 
    if (currWeek == 1 and hour < low ) or (currWeek == 0 and (hour >= high) ) then
        self._redDes2:setVisible(false)
        self._num2:setVisible(false)
        self._rewardBtn:setVisible(false)
        self._leagueCoin2:setVisible(false)
        self._fullStampt:setVisible(false)

        self._hadGetImg:setVisible(true)
        UIUtils:setGray(self._matchBtn,true)
        self._matchBtn._tip = lang("LEAGUETIP_10")
        self._isOpen = false
        self:showRestTimeCount(true,currWeek)
        if not self._timeCounting then
            self._timeCounting = true
            if self._leagueModel and not next(self._leagueModel:getRank()) then
                if self._leagueModel:isInMidSeasonRestTime() then self._viewMgr:showTip(lang("LEAGUETIP_10")) return end
        
                self._serverMgr:sendMsg("LeagueServer","getRank",{time = 0},true,{},function( result )
                    self._heroBody:setVisible(false)
                    self:showRankHeros(true)
                end)
            else
                self._heroBody:setVisible(false)
                self:showRankHeros(true)
            end
        end
        self:reflashAwardTip()
        return false
    else
        self._redDes2:setVisible(true)
        self._num2:setVisible(true)
        self._rewardBtn:setVisible(true)
        self._leagueCoin2:setVisible(true)
        -- self._fullStampt:setVisible(true)
        self._hadGetImg:setVisible(false)
        UIUtils:setGray(self._matchBtn,false)
        if self._leagueModel:getLeague() then
            local curTicketCount = self._leagueModel:getLeague().ticket.currentCounts or 0
            if curTicketCount ~= 0 then
                self._matchBtn._tip = nil
            end
        end
        self._isOpen = true
        if self._statusLab:isVisible() then
            self:showRestTimeCount(false,currWeek)
        end
        self:inFirstBatchShow()
        self._timeCounting = false
        if self._rankHeroLy:isVisible() then
            self:showRankHeros(false)
        end
        self:reflashAwardTip()
        return true
    end
end

-- 第一次进 第一赛季 前两级的引导用
function LeagueView:inFirstBatchShow( )
    -- [[ 第一赛季特做
    local isFirst = self._leagueModel:isShowHot() --.first and self._leagueModel:getData().first ~= 0
    if isFirst then
        local curZone = self._leagueModel:getCurZone()
        if isFirst == 1 then
            self._hotPanel:setVisible(false)
            self._selPanel:setVisible(false)
            self._statusLab:setVisible(true)
            self._statusLab:setString("冠军对决")
            return true
        elseif isFirst == 2 then
            self._hotPanel:setVisible(true)
            self._selPanel:setVisible(false)
            self._statusLab:setVisible(true)
            self._statusLab:setString("冠军对决")
            return true
        else
            self._hotPanel:setVisible(true)
            self._selPanel:setVisible(true)
            self._statusLab:setString("")
        end
    end
    return false
    --]]
end

-- 休息期间倒计时
function LeagueView:showRestTimeCount( isShow,week )
    if self:inFirstBatchShow() and not self._modelMgr:getModel("LeagueModel"):isInMidSeasonRestTime() then return end
    local children = self._blueFlag:getChildren()
    for k,v in pairs(children) do
        v:setVisible(not isShow)
    end
    local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local low,high = tab:Setting("G_LEAGUE_OPENTIME").value[1],tab:Setting("G_LEAGUE_OPENTIME").value[2]
    local openTime 
    if week == 1 then
        openTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(nowTime,"%Y-%m-%d " .. low .. ":00:00"))
    elseif week == 0 then
        openTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(nowTime + 86400,"%Y-%m-%d " .. low .. ":00:00"))
    end
    if openTime then
        local lastTime = openTime - nowTime
        self._statusLab:setString("开启倒计时" .. string.format("%02d:%02d:%02d", math.floor(lastTime/3600), math.floor(lastTime%3600/60), lastTime%60 ))
    end
    self._statusLab:setVisible(isShow)
end

-- 增加背景小人
function LeagueView:addSmallPeople( )
    mcMgr:loadRes("leaguexaioren",function( )
        local mc = mcMgr:createViewMC("beijingxiaoren_leaguexaioren", true, false)
        mc:setPosition(450,400)
        self._bg:addChild(mc,0)
    end)
    mcMgr:loadRes("leaguejinjiechenggong",function( )
        local mc = mcMgr:createViewMC("piaoluocaidai_leaguejinjiechenggong", true, false)
        mc:setPosition(450,600)
        self._bg:addChild(mc,-1)
    end)
end

--- 判断可领取奖励否
function LeagueView:updateAward()
    local awardNum = 0
    local leagueData = self._leagueModel:getData()
    local open = self:detectOpen()
    if not open then return end
    local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    if leagueData and leagueData.league and leagueData.league.leagueAward then
        local curLeagueRank = tab:LeagueRank(leagueData.league.currentZone or 1)
        local addedScore = math.floor(((nowTime-leagueData.league.leagueAward.upDateTime)/3600)*curLeagueRank.timebonus)
        awardNum = math.min(curLeagueRank.timemax,addedScore+(leagueData.league.leagueAward.sum or 0))+(leagueData.league.leagueAward.cs or 0)
        self._num2:setString( awardNum ) -- .. "/" .. curLeagueRank.timemax)
        self._awardNum = awardNum 
        UIUtils:setGray(self._rewardBtn,tonumber(awardNum) <= 0)
        if awardNum == curLeagueRank.timemax then
            self._btnMc:setVisible(true)
            if not self._fullStampt:isVisible() then
                self._fullStampt:setScale(4)
                self._fullStampt:setOpacity(0)
                self._fullStampt:setVisible(true)
                self._fullStampt:runAction(cc.Spawn:create(cc.FadeIn:create(0.3),cc.ScaleTo:create(0.3,1)))
            end
            self._fullStampt:setPositionX(self._num2:getPositionX()+self._num2:getContentSize().width+22)
        else
            self._btnMc:setVisible(false)
            if self._fullStampt:isVisible() then
                self._fullStampt:setVisible(false)
                self._fullStampt:setOpacity(0)
            end
        end
    end
    -- [[ 三秒换动作
    if not self._lastSwitchHeroTime then
        self._lastSwitchHeroTime = nowTime
    end
    if nowTime > self._lastSwitchHeroTime+3 then
        self._lastSwitchHeroTime = nowTime
        self:switchHeroMC()
    end
    --]]
end

function LeagueView:onTop( )
    self:detectZoneAward()
    -- if nowZone ~= self._preZone then
    --     self:changeFlagAnim(function( )
    --         self:reflashRedFlag()
    --         self:reflashBlueFlag()
    --     end)
    -- end

    if self._enterBattle and not self._leagueModel:isInMidSeasonRestTime() then
        self:lock(-1)
        ScheduleMgr:delayCall(0, self, function()
            self:unlock()
            GuideUtils.checkTriggerByType("action", "8")
        end)
    end
    -- [[ 剩余奖励气泡
    self:reflashAwardTip()
    --]]

    -- 引到前不显示 旗子
    local trigger19 = ModelManager:getInstance():getModel("UserModel"):hasTrigger("19")
    local league = self._leagueModel:getLeague()

    if trigger19 or (league and league.currentPoint and league.currentPoint > 1000) then
        self._redFlag:setVisible(true)
        self._blueFlag:setVisible(true)
    else
        self._redFlag:setVisible(false)
        self._blueFlag:setVisible(false)
    end
end

-- 判断是否可以领当前段位晋升奖励
function LeagueView:detectZoneAward( )
    local nowZone = self._leagueModel:getData().league.currentZone
    local league = self._leagueModel:getLeague()
    local isUpStageAwardGeted = false
    if league and league.changeReward and nowZone ~= 1 then
        if not league.changeReward[tostring(nowZone)] or league.changeReward[tostring(nowZone)] == 1 then
            isUpStageAwardGeted = true
        end 
    end
    if not self._preZone then 
        self._preZone = self._leagueModel:getData().league.currentZone 
    end
    if nowZone > self._preZone or isUpStageAwardGeted then
        self._preZone = nowZone
        self._viewMgr:showDialog("league.LeagueUpStageView",{zone=nowZone,callback = function( )
            local trigger25 = ModelManager:getInstance():getModel("UserModel"):hasTrigger("25")
            local trigger26 = ModelManager:getInstance():getModel("UserModel"):hasTrigger("26")
            local trigger34 = ModelManager:getInstance():getModel("UserModel"):hasTrigger("34")
            local curZone = self._leagueModel:getCurZone()
            if curZone == 2 and not trigger25 then
                GuideUtils.checkTriggerByType("action", "10")
            elseif curZone == 3 and not trigger26 then
                GuideUtils.checkTriggerByType("action", "11")
            elseif curZone == 9 and not trigger34 then
                GuideUtils.checkTriggerByType("action", "15")
            else
                -- 评论
                local param = {inType = 4, num = nowZone}
                local isPop, popData = self._modelMgr:getModel("CommentGuideModel"):checkCommentGuide(param)
                if isPop == true then
                    self._viewMgr:showDialog("global.GlobalCommentGuideView", popData, true)
                end
            end
        end},true)
    end
end

function LeagueView:onShow( )
    self:detectZoneAward()
    local batchId = self._modelMgr:getModel("LeagueModel"):getBatchId()
    local isMondayRest = self._modelMgr:getModel("LeagueModel"):isMondayRest()
    local isInMidSeasonRestTime = self._modelMgr:getModel("LeagueModel"):isInMidSeasonRestTime()
    local nowTime = ModelManager:getInstance():getModel("UserModel"):getCurServerTime()
    local isCurBatchFirstIn = self._modelMgr:getModel("LeagueModel"):isCurBatchFirstIn()
    if isCurBatchFirstIn and not isInMidSeasonRestTime then  
        -- SystemUtils.saveAccountLocalData("leagueStart", batchId)
        self._modelMgr:getModel("LeagueModel"):isCurBatchFirstIn(true)
        self._modelMgr:getModel("LeagueModel"):isShowCurBatchInTipMc(true)
        self._viewMgr:showDialog("league.LeagueStartFlagView",nil,nil,nil,nil,true)
    end
    self:reflashAwardTip()
    --
    local trigger19 = ModelManager:getInstance():getModel("UserModel"):hasTrigger("19")
    print("trigger...19================",trigger19)
    if not trigger19 then
        self._redFlag:setVisible(false)
        self._blueFlag:setVisible(false)
    end
end

function LeagueView:reflashAwardTip( )
    -- [[ 剩余奖励气泡
    local hadChallengeNum = self._modelMgr:getModel("PlayerTodayModel"):getData().day31 or 0
    self._sloganBg:setVisible(hadChallengeNum < 6)
    -- print(hadChallengeNum,"===========================")
    if hadChallengeNum >= 0 and hadChallengeNum < 3 then
        self._sloganBg:setContentSize(cc.size(220,75))
        local des = lang("LEAGUETIP_20")
        des = string.gsub(des,"%b{}",function( catchStr )
            return 3-hadChallengeNum
        end)
        local rtx = self._sloganBg:getChildByFullName("rtx")
        if rtx then
            rtx:removeFromParent()
        end
        des = "[color=825528,fontsize=22]" .. des .. "[-]"
        rtx = RichTextFactory:create(des or "[][-]",250,40)
        rtx:formatText()
        rtx:setVerticalSpace(7)
        rtx:setName("rtx")
        rtx:setPosition(cc.p(self._sloganBg:getContentSize().width/2+5,self._sloganBg:getContentSize().height/2))
        self._sloganBg:addChild(rtx)
        UIUtils:alignRichText(rtx)
        self._sloganLab:setString("")
        self._sloganBg:setPosition(560,175)
    elseif hadChallengeNum < 6 then
        self._sloganBg:setContentSize(cc.size(220,85))
        local des = lang("LEAGUETIP_21")
        des = string.gsub(des,"%b{}",function( catchStr )
            return 6-hadChallengeNum
        end)
        local rtx = self._sloganBg:getChildByFullName("rtx")
        if rtx then
            rtx:removeFromParent()
        end
        des = "[color=825528,fontsize=22]" .. des .. "[-]"
        rtx = RichTextFactory:create(des or "[][-]",250,40)
        rtx:formatText()
        rtx:setVerticalSpace(7)
        rtx:setName("rtx")
        rtx:setPosition(cc.p(self._sloganBg:getContentSize().width/2,self._sloganBg:getContentSize().height/2))
        self._sloganBg:addChild(rtx)
        UIUtils:alignRichText(rtx)
        self._sloganLab:setString("")
        self._sloganBg:setPosition(-274+568,130)      
        local vip = self._modelMgr:getModel("VipModel"):getData().level
        self._sloganBg:setVisible(vip > 2)
    end
    -- self._sloganBg:setVisible(hadChallengeNum < 10)
    local inRest = self._modelMgr:getModel("LeagueModel"):isInMidSeasonRestTime()
    if inRest then
        self._sloganBg:setVisible(false)
    end
    --]]
end

-- 接收自定义消息
function LeagueView:reflashUI(data)
	local leagueData = self._leagueModel:getData()
    -- dump(leagueData,"leagueData",10)
	if not next(leagueData) then return end 
	self._leagueData = leagueData

	local userData = self._modelMgr:getModel("UserModel"):getData()
	self._name:setString(userData.name or "")
	self._level:setString("等级" .. (userData.lvl or 0))

	-- 静态表内容
	local curLeagueRank = tab:LeagueRank(leagueData.league.currentZone or 1)

	-- 进度条
	local currentZone = leagueData.league.currentZone
    self._curZone = currentZone or 1
	-- self._progress:setPercent(leagueData.league.currentPoint/curLeagueRank.gradeup*100)

    -- self._leftNum:setString("挑战次数".. leagueData.league.ticket.currentCounts .."/5")
    local curTicketCount = leagueData.league.ticket.currentCounts or 0
    self._chanceNum:setString(curTicketCount .."/" .. tab:Setting("G_LEAGUE_PHYSICAL").value)
    self._addChangeBtn:setVisible(curTicketCount == 0)

    

    if curTicketCount == 0 then
        self._chanceNum:setColor(cc.c3b(255, 23, 23))
        self._matchBtn._tip = 1 --"没有挑战次数"
    else
        self._chanceNum:setColor(cc.c3b(0, 255, 23))
        self._matchBtn._tip = nil
    end
    self._cdLabel:setString("")
    local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    -- local deltTime = nowTime - leagueData.league.ticket.upDateTime
    -- self._cdLabel:setString(string.format("%02d:%02d",math.floor(deltTime/60),deltTime%60))
    if leagueData.league and leagueData.league.leagueAward then
        local addedScore = math.floor(((nowTime-leagueData.league.leagueAward.upDateTime)/3600)*curLeagueRank.timebonus)
        self._num2:setString( math.min(curLeagueRank.timemax,addedScore+(leagueData.league.leagueAward.sum or 0))) -- .. "/" .. curLeagueRank.timemax)
        UIUtils:setGray(self._rewardBtn,tonumber(addedScore) <= 0)
    end

    if not self._preZone2 then
        self._preZone2 = currentZone
    end
    if self._preZone2 == currentZone then -- 如果段位无变化直接刷板子，否则等onTop刷
        self:reflashBlueFlag()
        self:reflashRedFlag()
    else
        self:changeFlagAnim(function( )
            self:reflashRedFlag()
            self:reflashBlueFlag()
        end)    
        self._preZone2 = currentZone
    end
    
    local formationModel = self._modelMgr:getModel("FormationModel")
    local leagueFormation = formationModel:getFormationDataByType(formationModel.kFormationTypeLeague)
    local heroId = leagueFormation.heroId
    self:updateHeroSp(heroId)
    
    self:detectDot()
    -- 赛季时间
    local schetime = tonumber(leagueData.league.schetime)
    local beginYear,beginMonth,beginDay = math.floor(schetime/10000),math.floor(schetime%10000/100),math.floor(schetime%100)
    local beginSec = os.time({year=beginYear,month=beginMonth,day=beginDay}) or 0
    local endSec = beginSec+6*86400
    local schedule = leagueData.schedule
    local endMonth,endDay = TimeUtils.date("%m",endSec),TimeUtils.date("%d",endSec) --math.floor(schedule%10000/100),math.floor(schedule%100)
    local batchId = leagueData.batchId
    local LeagueNum = string.sub(batchId,7,string.len(batchId))
    local seasonNum = leagueData.season
    if seasonNum == 0 then seasonNum = 1 end
    self._leagueTime:setString(string.format("第%d赛季(%d月%d日-%d月%d日)",seasonNum or tonumber(LeagueNum) or 0,tonumber(beginMonth) or 0,tonumber(beginDay) or 0,tonumber(endMonth) or 0,tonumber(endDay) or 0))

    -- 第一次进第一赛季判断
    self:inFirstBatchShow()
    self:reflashAwardTip()
    -- 2017.4.15 新逻辑 没有购买次数时显示
    self:showNoBuyCounts()
end

function LeagueView:showNoBuyCounts( )
    -- 次数用尽时隐藏的节点
    local buyNum = self._modelMgr:getModel("PlayerTodayModel"):getData().day17 or 0
    local vip = self._modelMgr:getModel("VipModel"):getData().level
    local canBuyNum = tonumber(tab:Vip(vip).leaguephy) 
    local leftNum = canBuyNum-buyNum
    print("leftNum,canBuyNum,buyNum", canBuyNum-buyNum, canBuyNum,buyNum)
    local curTicketCount = self._leagueModel:getLeague().ticket.currentCounts or 0
    if leftNum == 0 and canBuyNum > 0 and curTicketCount == 0 then
        self._leftNum:setString("今日次数已用尽")
        self._leftNum:setPositionX(568)
        local noCountHideSet = {self._chanceNum,self:getUI("bg.btnBg.chanceNumBg"),self._addChangeBtn}
        for i,v in ipairs(noCountHideSet) do
            v:setVisible(leftNum ~= 0)
        end
    else
        self._leftNum:setString("挑战次数")
        self._leftNum:setPositionX(537)
    end
end

local heroPoses = {
    [1] = {{0,0}},
    [2] = {{-90,0},{110,0}},
    [3] = {{5,-50},{-100,0},{100,0}},
}
local nameOffset = {
    [1] = {-40,0},
    [2] = {-45,0},
    [3] = {0,0},
}
-- 显示排名前三的英雄兵模
function LeagueView:showRankHeros( isShow )
    -- if true then return end
    if not self._leagueModel then return end
    local rankList = self._leagueModel:getRank()
    self._rankHeroLy:removeAllChildren()
    self._rankHeroLy:setVisible(isShow)
    self._name:setVisible(not isShow)
    self._heroBody:setVisible(not isShow)
    if not isShow then return end
    self._rankMcs = {}
    if rankList then
        local heroNum = #rankList 
        -- if heroNum == 1 then return end 
        if heroNum >  3 then heroNum = 3 end
        self._rankHeroLy:setVisible(true)
        local heroInfo = {}
        for i,v in ipairs(rankList) do
            if i > heroNum then break end
            heroInfo[i] = {}
            -- dump(v)
            if self._leagueModel:isInMidSeasonRestTime() then self._viewMgr:showTip(lang("LEAGUETIP_10")) return end
        
            self._serverMgr:sendMsg("LeagueServer", "GetInfo", {id = v.rid,sec = v.sec}, true, {}, function(result) 
                -- dump(data,"data==?")
                if next(result) then
                    -- dump(result)
                    local heroId = result.formation and result.formation.heroId
                    local mcs = self:addHeroMc(heroId,self._rankHeroLy,{"stop"},heroPoses[heroNum][i],function( mcs )
                        dump(mcs)
                    end)
                    local zOrder = 100-i
                    if mcs[1] then
                        table.insert(self._rankMcs,mcs[1])
                        mcs[1]:setVisible(true)
                        mcs[1]:setZOrder(zOrder)
                    end
                    local heroD = tab.hero[tonumber(heroId) or 60001]
                    -- [[ 名字板子
                    local width,height = self._rankHeroLy:getContentSize().width,self._rankHeroLy:getContentSize().height
                    local nameBg = ccui.ImageView:create()
                    nameBg:loadTexture("globalPanelUI7_desBg.png",1)
                    nameBg:setPosition(width+heroPoses[heroNum][i][1]-70+nameOffset[i][1], height+heroPoses[heroNum][i][2]-200)
                    self._rankHeroLy:addChild(nameBg,zOrder+1)
                    local nameLab = ccui.Text:create()
                    nameLab:setFontSize(18)
                    nameLab:setFontName(UIUtils.ttfName)
                    nameLab:setString(v.name or "")
                    nameLab:setPosition(35,15)
                    nameLab:setAnchorPoint(0,0.5)
                    nameBg:addChild(nameLab)
                    local rankImg = ccui.ImageView:create()
                    rankImg:loadTexture("league_rank_" .. i ..".png",1)
                    rankImg:setPosition(20,15)
                    nameBg:addChild(rankImg)
                    --]]
                end
            end)
        end
    end
end

-- 添加英雄兵模
function LeagueView:addHeroMc( heroId,parent,actions,offset,callback,skin )
    local heroD = tab:Hero(heroId or 60001)
    
    local mcs = {}
    actions = actions or {"stop", "run", "win"}
    local specialLow = 0
    if heroId == 60001 then
        specialLow = 18
    end
    local callfunc = callback 
    local offset = offset or {0,0}
    local heroArt = heroD["heroart"]
    -- 注释皮肤相关代码
    if skin then
        local heroSkinD = tab.heroSkin[skin]
        heroArt = heroSkinD["heroart"] or heroD["heroart"]
    end
    -- mcMgr:loadRes(heroD.heroart, function()
        for i = 1, #actions do
            local actionMc = mcMgr:createViewMC(actions[i] .. "_" .. heroArt, true)
            actionMc:setVisible(i==1)
            actionMc:setScale(-.7,.7)
            actionMc:setPosition(parent:getContentSize().width / 2 + 10 + offset[1], parent:getContentSize().height / 2 - 100-specialLow+ offset[2])
            mcs[i] = actionMc
            parent:addChild(actionMc,99)
        end
        print("callacllllsslslslsl")
        if callfunc then
            callfunc(mcs)
        end
        mcs[1]:setVisible(true)
    -- end)
    return mcs
end

-- 英雄兵模更新
function LeagueView:updateHeroSp( heroId )
    if not self._heroId or heroId ~= self._heroId then
        self._heroBody:removeAllChildren()
        self:registerClickEvent(self._heroBody,function() 
            self:switchHeroMC()
        end)
        local heroD = tab:Hero(heroId or 60001)
        self._heroId = heroId

        self._heroBodyMC = {}
        self._currentHeroMCIndex = 1
        self._heroMCName = {"stop", "run", "win"}
        local heroSkin = nil -- 加皮肤
        -- 注释皮肤相关代码
        local heroData = self._modelMgr:getModel("HeroModel"):getHeroData(heroId)
        if heroData and heroData.skin then
            heroSkin = heroData.skin
        end
        self._heroBodyMC = self:addHeroMc(heroId,self._heroBody,self._heroMCName,nil,function( )
            print("ddddd")
            self:switchHeroMC()
        end,heroSkin)
    end
end

-- 英雄兵模加动作
function LeagueView:switchHeroMC()
    if not self._heroMCName or #self._heroMCName == 0 then return end
    for i = 1, #self._heroMCName do
        if not tolua.isnull(self._heroBodyMC[i]) then
            if i == self._currentHeroMCIndex then
                self._heroBodyMC[i]:gotoAndPlay(0)
                self._heroBodyMC[i]:setVisible(true)
            else
                self._heroBodyMC[i]:setVisible(false)
                self._heroBodyMC[i]:stop()
            end
        end
    end
    self._currentHeroMCIndex = self._currentHeroMCIndex + 1 > #self._heroMCName and 1 or self._currentHeroMCIndex + 1
end

function LeagueView:reflashRedFlag( )
    local leagueData = self._leagueModel:getData()
    local currentZone = leagueData.league.currentZone
    local curLeagueRank = tab:LeagueRank(currentZone or 1)
    -- if self._curZone ~= #tab.leagueRank then
    --     self._progressLabel:setString((leagueData.league.currentPoint or 0) .. "/" .. curLeagueRank.gradeup)
    -- else
        self._progressLabel:setString(leagueData.league.currentPoint or "")
    -- end
    self._stage:setString(lang(curLeagueRank.name))
    self._stageImg:removeAllChildren()
    local curRank,preRank = self._modelMgr:getModel("LeagueModel"):getCurRank()
    if currentZone == 9 then
        local curRank,preRank = self._modelMgr:getModel("LeagueModel"):getCurRank()
        if curRank <= 32 then
            self._stageImg:loadTexture(tab:LeagueRank(currentZone).icon .. "_1.png",1)
        end
        local rankInImg = ccui.Text:create()
        rankInImg:setFontSize(24)
        rankInImg:setColor(cc.c4b(255,255,221,255))
        rankInImg:setFontName(UIUtils.ttfName)
        rankInImg:setPosition(self._stageImg:getContentSize().width/2,self._stageImg:getContentSize().height/2-16)
        rankInImg:setString(curRank)
        self._stageImg:addChild(rankInImg,11)
    end
    self._stageImg:loadTexture(curLeagueRank.icon .. ".png",1)
    self._num1:setString( curLeagueRank.timebonus .. "/小时")
end

function LeagueView:reflashBlueFlag( notSendMsg )
    self._leagueData = self._leagueModel:getData()
	local batchId = self._leagueData.batchId 
	local leagueActD = tab:LeagueAct(tonumber(batchId))
    -- 本赛程热点军团展示
    self._hotIds = {} -- 用于给布阵传
    self._hotBuff = {} -- 给战斗传
    self:resetSeasonHot()
	if leagueActD then
		local seasonspot = leagueActD.seasonspot
        if self._leagueData.first and self._leagueData.first ~= 0 then
            seasonspot = tab:Setting("G_LEAGUE_FIRST").value
        end
		for i,v in ipairs(seasonspot) do
            table.insert(self._hotIds,tonumber(v))
            self._hotBuff[tonumber(v)] = 50
            if self._seasonHots[i]:getChildByName("seasonIcon" .. i) then
                self._seasonHots[i]:getChildByName("seasonIcon" .. i):removeFromParent()
            end
            local sTeamData = self._teamModel:getTeamAndIndexById(v or 101)
            local teamD = tab:Team(v or 101)
            local icon
            if sTeamData then
                local quality = self._modelMgr:getModel("TeamModel"):getTeamQualityByStage(sTeamData.stage)
                icon = IconUtils:createTeamIconById({teamData = sTeamData, sysTeamData = teamD, quality = quality[1] , quaAddition = quality[2], eventStyle = 3, clickCallback = function( )
                    self._viewMgr:showDialog("league.LeagueSeasonHotView", {ids = seasonspot}, true)
                end})
            else
    			icon = IconUtils:createSysTeamIconById({sysTeamData = teamD,eventStyle=3,clickCallback=function ( )
                    self._viewMgr:showDialog("league.LeagueSeasonHotView",{ids = seasonspot},true)
                end})
            end
            icon:setCascadeOpacityEnabled(true)
			icon:setPosition(7,7)--(i-1)*90,0)
            icon:setName("seasonIcon" .. i)
			icon:setScale(0.8)
            if not icon:getChildByName("kuangMc") then
                local kuangMc = mcMgr:createViewMC("saijirediankuang_leaguerediantexiao", true, false,function( _,sender )
                end,RGBA8888)
                kuangMc:setName("kuangMc")
                kuangMc:setScale(1.3)
                kuangMc:setPosition(53,56)
                icon:addChild(kuangMc,-1)
            end
            self._seasonHots[i]:addChild(icon,99)
            self._seasonHots[i]:getChildByFullName("frame"):setVisible(false)
		end
	end
	-- 自己选择的兵团 todo
    local curLeagueRank = tab:LeagueRank(self._leagueData.league.currentZone or 1)
    local hotOpenNum = curLeagueRank.hotspot or 0
    self:resetSelHots(hotOpenNum)
    if hotOpenNum > 0 then 
    	local hotSpotInfo = self._leagueModel:getCurZoneHot(self._leagueData.league.currentZone)
    	if --[[not hotSpotInfo and--]] not notSendMsg then 
            if self._leagueModel:isInMidSeasonRestTime() then self._viewMgr:showTip(lang("LEAGUETIP_10")) return end
        
    		self._serverMgr:sendMsg("LeagueServer", "getHot", {id=self._leagueData.league.currentZone}, true, {}, function(result)
                self:reflashBlueFlag(true)
            end)
    	elseif hotSpotInfo and hotSpotInfo.hot and hotSpotInfo.hot ~= "" then
            local hot = string.split(hotSpotInfo.hot,",")
    		for i=1,hotOpenNum do
                if hot[i] then
                    table.insert(self._hotIds,tonumber(hot[i]))
                    self._hotBuff[tonumber(hot[i])] = 100
                    local teamData = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(tonumber(hot[i]))
                    local icon = self._selHots[i]:getChildByName("icon")
                    if not icon then
                        if teamData then 
                            local quality = self._modelMgr:getModel("TeamModel"):getTeamQualityByStage(teamData.stage)
                            icon = IconUtils:createTeamIconById({eventStyle=0,sysTeamData = tab:Team(tonumber(hot[i]) or 101),teamData = teamData, quality = quality[1] , quaAddition = quality[2]})
                        else
                            icon = IconUtils:createSysTeamIconById({sysTeamData = tab:Team(tonumber(hot[i]) or 101),eventStyle=0})
                        end
                        self._selHots[i]:addChild(icon,99)
                    else
                        if teamData then 
                            local quality = self._modelMgr:getModel("TeamModel"):getTeamQualityByStage(teamData.stage)
                            IconUtils:updateTeamIconByView(icon,{eventStyle=0,sysTeamData = tab:Team(tonumber(hot[i]) or 101),teamData = teamData, quality = quality[1] , quaAddition = quality[2]})
                        else
                            IconUtils:updateSysTeamIconByView(icon,{sysTeamData = tab:Team(tonumber(hot[i]) or 101),eventStyle=0})
                        end
                    end
                        
                    icon:setName("icon")
                    icon:setPosition(7,7)
                    icon:setVisible(true)
                    icon:setScale(0.8)
                    if not icon:getChildByName("kuangMc") then
                        local kuangMc = mcMgr:createViewMC("duanweirediankuang_leaguerediantexiao", true, false,function( _,sender )
                        end,RGBA8888)
                        kuangMc:setName("kuangMc")
                        kuangMc:setScale(1.3)
                        kuangMc:setPosition(53,56)
                        icon:addChild(kuangMc,-1)
                    end
                end
            end
    	else
            for i=1,hotOpenNum do
                local icon = self._selHots[i]:getChildByName("icon")
                if icon then
                    icon:removeFromParent()
                end
            end
        end
    end
end

-- 更新自己选的热点兵团状态
function LeagueView:resetSelHots( openNum )
    print("resetSelHots....FFFFFFFFFFFFFFFFFFFFF")
    for i,v in ipairs(self._selHots) do
        local lock = v:getChildByName("lock")
        if i<= openNum then
            lock:loadTexture("golbalIamgeUI5_add.png",1) --:setVisible(false)
            lock:setScale(0.6) 
        else
            local icon = v:getChildByName("icon")
            if icon then 
                icon:removeFromParent()
            end
            -- lock:setVisible(true)
            lock:loadTexture("globalImageUI5_treasureLock.png",1)
        end
    end
end

-- 红点通知
function LeagueView:detectDot( )
    local awardBtn = self:getUI("bg.btnBg.award")
    local dot = awardBtn:getChildByName("dot")
    local hadAward = self._modelMgr:getModel("LeagueModel"):haveAward()
    if hadAward then
        if not dot then
            self:addDot(awardBtn)
        else
            dot:setVisible(true)
        end
    else
        if dot then
            dot:setVisible(false)
        end
    end
    -- 攻城器械红点
    local buzhenBtn = self:getUI("bg.btnBg.buzhen")
    local dot = buzhenBtn:getChildByName("dot")
    local formationModel = self._modelMgr:getModel("FormationModel")
    local isFullWeapons = formationModel:isHaveWeaponCanLoaded(formationModel.kFormationTypeLeague)
    if isFullWeapons then
        if not dot then
            self:addDot(buzhenBtn)
        else
            dot:setVisible(true)
        end
    else
        if dot then
            dot:setVisible(false)
        end
    end
end
function LeagueView:addDot(node)
    dot = ccui.ImageView:create()
    dot:loadTexture("globalImageUI_bag_keyihecheng.png", 1)
    dot:setPosition(60,60)--node:getContentSize().width,node:getContentSize().height))
    dot:setName("dot")
    node:addChild(dot,99)
end

function LeagueView:resetSeasonHot( )
    for i,v in ipairs(self._seasonHots) do
        local icon = v:getChildByName("icon")
        if icon then 
            icon:removeFromParent()
        end 
    end
end

function LeagueView:onReconnect()
    print("onReconnect^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^",self._matchResult)
    if self._matchResult then
        self:challengeEnemy(self._matchResult)
    end
end

-- 组战斗数据
-- 挑战按钮回调
function LeagueView:challengeEnemy( result )
    if not result or not next(result) then 
        if self._matchView then
            self._matchView:setVisible(false)
            self:setNavigation()
        end
        return 
    end
    -- [[ 记录进布阵的时间 用于处理切到后台 切回来的问题
    self._showFormationTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    --]]
    local info = result.rival
    local enemyFormation = clone(info.formation)
    enemyFormation.filter = ""
     -- 给布阵传递数据
    self._leagueModel:setEnemyData(info.teams)
    
    self._leagueModel:setEnemyHeroData(info.hero)
    local formationType = self._modelMgr:getModel("FormationModel").kFormationTypeLeague
    self._viewMgr:showView("formation.NewFormationView", {
        formationType = formationType,
        recommend = self._hotIds or {},
        enemyFormationData = {[formationType] = enemyFormation},
        extend = {
            heroes = self._leagueModel:getLeagueHeroIds(),
            helpHero = {self._modelMgr:getModel("LeagueModel"):getCurHelpHeroId()},
            nextHelpHero = {self._modelMgr:getModel("LeagueModel"):getNextHelpHeroId()},
            showHelpTag = true,
        },
        callback = function(leftData)
            self._serverMgr:sendMsg("LeagueServer", "beforeAtk", {token = result.token, serverInfoEx = BattleUtils.getBeforeSIE()}, true, {}, function(_result) 
                -- 关布阵
                if self._matchView then
                    self._matchView:setVisible(false)
                    self:setNavigation()
                end
                self._matchResult = nil
                self._viewMgr:popView()
                -- self._viewMgr:showDialog("arena.DialogArenaUserInfo",info.battle,true)
                self:enterLeagueBattle( BattleUtils.jsonData2lua_battleData(_result["atk"]), result.r1, result.r2,info,result.token)
            end)
        end,
        customCallback = function( )
            self._serverMgr:sendMsg("LeagueServer", "beforeAtk", {token = result.token, serverInfoEx = BattleUtils.getBeforeSIE()}, true, {}, function(_result) 
                -- 关布阵
                if self._matchView then
                    self._matchView:setVisible(false)
                    self:setNavigation()
                end
                self._matchResult = nil
                self._viewMgr:popView()
                -- self._viewMgr:showDialog("arena.DialogArenaUserInfo",info.battle,true)
                self:enterLeagueBattle( BattleUtils.jsonData2lua_battleData(_result["atk"]), result.r1, result.r2,info,result.token)
            end)
        end
    })
    
end

function LeagueView:enterLeagueBattle( playerInfo, r1, r2,enemyD,token)
    local _,enemyInfo = self:initBattleData(enemyD)
    -- for i,team in ipairs(playerInfo.team) do
    --     if self._hotBuff[tonumber(team.id)] then
    --         team.leagueBuff = self._hotBuff[tonumber(team.id)]
    --     end
    -- end
    -- dump(playerInfo,"playerInfo...--------------",10)
    -- local playerInfo  = self:getVirtualPlayerInfo()
    self._enterBattle = true
    BattleUtils.enterBattleView_League(playerInfo, enemyInfo, r1, r2, false,
    function (info, callback)
        -- 战斗结束
        -- dump(info)
        -- print(debug.traceback())
        self:afterLeagueBattle(info,callback,token)
        -- callback(info)
    end,
    function (info)
        -- 退出战斗
        -- ViewManager:getInstance():popView()
    end)
end

function LeagueView:afterLeagueBattle( data,callback,token )
    local win = 0
    if data.win then
        win = 1
    end
    if data.isTimeUp then
        win = 2
    end
    local leagueData = self._leagueModel:getData().league or {}
    local preLeague = {
        currentZone = leagueData.currentZone,
        currentPoint = leagueData.currentPoint,
    }
    -- dump(data,"afterLeagueBattle",2)
    -- 后端统计数据要加入time by guojun 2016.9.6
    local preLeagueCoin = self._modelMgr:getModel("UserModel"):getData().leagueCoin
    local crash
    if data.isSurrender then
        crash = 1
    end
    local zzid = GameStatic.zzid5
    self._serverMgr:sendMsg("LeagueServer", "getBattleAward", 
        {data=json.encode({win=win,token=token,zzid=zzid,time=data.time or 0,crash=crash,serverInfoEx=data.serverInfoEx,skillList=data.skillList})}, true, {}, function(result)
        if result["extract"] then dump(result["extract"]["hp"], "getBattleAward", 10) end
        -- dump(result)
        -- 带进去战后数据
        local curLeagueCoin = result.d.leagueCoin or self._modelMgr:getModel("UserModel"):getData().leagueCoin
        local leagueData = self._leagueModel:getData().league
        -- data.isTimeUp = true
        data.leagueInfo = {
            currentZone = leagueData.currentZone or preLeague.currentZone,
            currentPoint = leagueData.currentPoint,
            preZone = preLeague.currentZone,
            prePoint = preLeague.currentPoint,
            awardLeagueCoin = curLeagueCoin - preLeagueCoin
        }
        if result["cheat"] == 1 then
            data.failed = true
            data.extract = result["extract"]
        end
        -- dump(data)
		callback(data)
	end)
    -- self:sendFightAfterMsg(defid,defrank,token,win,function (result)
    --     callback(data)
    -- end)
end
-- 组装战斗数据 copy from GlobalFormationView
function LeagueView:initBattleData(enemyData)
    local result = {}
    local formationModel = self._modelMgr:getModel("FormationModel")
    local playerInfo = formationModel:initBattleData(formationModel.kFormationTypeLeague)[1]
    playerInfo.level = ModelManager:getInstance():getModel("UserModel"):getData().lvl

    table.insert(result, playerInfo)
    if not enemyData then 
        return playerInfo
    end
    --  合成敌人数据
    local enemyD = enemyData
    local enemyInfo = BattleUtils.jsonData2lua_battleData(enemyD)
    table.insert(result,enemyInfo)
    -- 给布阵设数据
    self._leagueModel:setEnemyHeroData(enemyInfo.hero)
    self._leagueModel:setEnemyData(enemyD.teams)
    --
    return ---[[
    playerInfo,
    --]]
    enemyInfo
end



function LeagueView:onDestroy( )
    if self._updateTenMinutes then
        ScheduleMgr:unregSchedule(self._updateTenMinutes)
        self._updateTenMinutes = nil
    end
    self.super.onDestroy(self)
end

-- 切换旗子动画
function LeagueView:changeFlagAnim( midCallback )
    local trigger19 = ModelManager:getInstance():getModel("UserModel"):hasTrigger("19")
    if not trigger19 then
        self._redFlag:setVisible(false)
        self._blueFlag:setVisible(false)
        return 
    end
    local changeTime = 0.2
    local seq1 = cc.Sequence:create(
        cc.Spawn:create(
            cc.FadeTo:create(changeTime,66),cc.EaseOut:create(cc.MoveTo:create(changeTime, cc.p(129,MAX_SCREEN_HEIGHT+200)), 3)
        ),
        cc.CallFunc:create(function( )
            -- if midCallBack then
            --     midCallBack()
            -- end
            self:reflashRedFlag()
            self:reflashBlueFlag()
        end),
        cc.Spawn:create(
            cc.FadeTo:create(changeTime,255),cc.EaseOut:create(cc.MoveTo:create(changeTime, cc.p(129,MAX_SCREEN_HEIGHT-5)), 3)
        ),
        cc.MoveTo:create(0.07, cc.p(129,MAX_SCREEN_HEIGHT))
    )
    self._redFlag:setCascadeOpacityEnabled(true)
    self._redFlag:runAction(seq1)
    
    local seq2 = cc.Sequence:create(
        cc.Spawn:create(
            cc.FadeTo:create(changeTime,66),cc.EaseOut:create(cc.MoveTo:create(changeTime, cc.p(815,MAX_SCREEN_HEIGHT+200)), 3)
        ),
        cc.CallFunc:create(function( )
            -- if midCallBack then
            --     midCallBack()
            -- end
        end),
        cc.Spawn:create(
            cc.FadeTo:create(changeTime,255),cc.EaseOut:create(cc.MoveTo:create(changeTime, cc.p(815,MAX_SCREEN_HEIGHT-5)), 3)
        ),
        cc.MoveTo:create(0.07, cc.p(815,MAX_SCREEN_HEIGHT))
    )
    self._blueFlag:setCascadeOpacityEnabled(true)
    self._blueFlag:runAction(seq2)
end

-- 重载出现动画
function LeagueView:beforePopAnim()
    if self.initAnimType == 1 or self.initAnimType == 2 then
        if self._topLayer and self._topLayer.visible then
            self._topLayer:setOpacity(0)
        end
    end
    self._redFlag:setVisible(false)
    self._blueFlag:setVisible(false)
end
function LeagueView:popAnim(callback)
    -- 执行父节点动画
    self.super.popAnim(self,callback)
    -- 定义自己动画
    local topBeginPos = cc.p(0,MAX_SCREEN_HEIGHT)
    self._topLayer:setPosition(topBeginPos)
    -- self._topLayer:runAction(cc.MoveTo:create(0.1,cc.p(0,MAX_SCREEN_HEIGHT)))
    -- self._topLayer:setPosition(topBeginPos)
    -- self._topLayer:runAction(cc.MoveTo:create(0.1,cc.p(0,MAX_SCREEN_HEIGHT)))
    local offsetY = 0
    local offsetX = 0
    local scale = 1
    if MAX_SCREEN_WIDTH < 1136 then
        offsetX = 0 --40
        offsetY = 0
        scale = MAX_SCREEN_WIDTH / 1136
    end

    if self._topLayer then
        self._topLayer:stopAllActions()
        self._topLayer:setOpacity(255)
        local x, y = self._topLayer:getPositionX(), self._topLayer:getPositionY()
        self._topLayer:setPosition(x, y + 80)
        self._topLayer:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.13),
            cc.EaseOut:create(cc.MoveTo:create(0.1, cc.p(x, y - 5)), 3),
            cc.MoveTo:create(0.07, cc.p(x, y))
        ))
        local titleBg1 = self._topLayer:getChildByName("titleBg1")
        if titleBg1 then
            titleBg1:setPositionX(480)
            titleBg1:setScaleX(scale)
        end
        local titleBg2 = self._topLayer:getChildByName("titleBg2")
        if titleBg2 then
            titleBg2:setPositionX(728-offsetX)
        end
        if offsetX ~= 0 then
            self._leagueTime:setFontSize(20)
        end
    end
    local btnBgInitPos = cc.p(self._btnBg:getPositionX(),47)
    self._btnBg:setPosition(cc.p(btnBgInitPos.x,btnBgInitPos.y-300))
    self._btnBg:runAction(cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(0.2,cc.pAdd(btnBgInitPos,cc.p(0,10))),cc.FadeIn:create(0.1)),cc.MoveTo:create(0.05,btnBgInitPos),cc.CallFunc:create(function( )
        -- self._sloganBg:runAction(cc.FadeIn:create(0.2))
        self._btnBg:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.05),
            cc.CallFunc:create(function( )
                local hadChallengeNum = self._modelMgr:getModel("PlayerTodayModel"):getData().day31 or 0
                self._sloganBg:setVisible(hadChallengeNum < 10)
                local inRest = self._modelMgr:getModel("LeagueModel"):isInMidSeasonRestTime()
                if inRest then
                    self._sloganBg:setVisible(false)
                end
                self:reflashAwardTip()
            end)
        ))
    end)))
    ScheduleMgr:nextFrameCall(self, function()
        self._redFlag:setPosition(cc.p(145+offsetX,MAX_SCREEN_HEIGHT+700))

        self._redFlag:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.13),
            cc.EaseOut:create(cc.MoveTo:create(0.1, cc.p(145+offsetX,MAX_SCREEN_HEIGHT)), 3),
            cc.MoveTo:create(0.07, cc.p(145+offsetX,MAX_SCREEN_HEIGHT+offsetY+2))
        ))

        self._blueFlag:setPosition(cc.p(815-offsetX,MAX_SCREEN_HEIGHT+700))
        self._blueFlag:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.13),
            cc.EaseOut:create(cc.MoveTo:create(0.1, cc.p(815-offsetX,MAX_SCREEN_HEIGHT)), 3),
            cc.MoveTo:create(0.07, cc.p(815-offsetX,MAX_SCREEN_HEIGHT+offsetY+2))
        ))

        local trigger19 = ModelManager:getInstance():getModel("UserModel"):hasTrigger("19")
        local league = self._leagueModel:getLeague()
        if trigger19 or (league and league.currentPoint and league.currentPoint > 1000) then
            self._redFlag:setVisible(true)
            self._blueFlag:setVisible(true)
        end
    end)
    self:detectOpen()
end

-- 发送协议
function LeagueView:sendBuyChallengeNumMsg(isToMatch)
    local buyNum = self._modelMgr:getModel("PlayerTodayModel"):getData().day17 or 0
    local vip = self._modelMgr:getModel("VipModel"):getData().level

    local canBuyNum = tonumber(tab:Vip(vip).leaguephy) 
    print("buyNum , canBuy num",vip,buyNum , canBuyNum)
    local canBuyStr = ""
    if canBuyNum > 0 then
        canBuyStr = "(还可购买" .. (canBuyNum-buyNum) .. "次)" 
    end
    if buyNum >= canBuyNum then
        -- self._viewMgr:showTip("已达购买上限！")
        self._viewMgr:showDialog("global.GlobalResTipDialog",{},true)
        return 
    end
    -- local buySetting = 
    -- [[ 活动加成
    local actCostLess = self._modelMgr:getModel("ActivityModel"):getAbilityEffect(self._modelMgr:getModel("ActivityModel").PrivilegIDs.PrivilegID_19) or 0
    --]]
    local costIdx = math.min(buyNum+1,#tab.reflashCost)-- tab:Setting("G_League_BUY_GEM").value
    local nextCost = tab:ReflashCost(costIdx).costLeague*(1+actCostLess)

    local gem = self._modelMgr:getModel("UserModel"):getData()["gem"]
    if nextCost < gem then
        DialogUtils.showBuyDialog({costNum = nextCost,goods = "购买一张入场券" .. canBuyStr,callback1 = function( )
            local param = {}
            self._serverMgr:sendMsg("LeagueServer", "buyTicket", param, true, {}, function(result) 
                -- self:reflashMainBoad()
                if isToMatch and self then
                    self:showMatchView()
                    -- ViewManager:getInstance():showView("league.LeagueMatchView",{parent = self,callback=function( matchResult )
                    --     if matchResult and self.challengeEnemy then
                    --         self:challengeEnemy(matchResult)
                    --     end
                    -- end})
                end
            end)    
        end})
    else
        DialogUtils.showNeedCharge({callback1=function( )
            local viewMgr = ViewManager:getInstance()
            viewMgr:showView("vip.VipView", {viewType = 0})
        end})
    end
end

-- 处理切入后台
function LeagueView:applicationDidEnterBackground()

end

function LeagueView:applicationWillEnterForeground(second)
    print("leagueview...applicationWillEnterForeground",second)
    -- local matchView = self._bg:getChildByFullName("LeagueMatchView")
    -- if matchView then
    --     matchView:close()
    --     matchView:setVisible(false)
    -- end
end

return LeagueView