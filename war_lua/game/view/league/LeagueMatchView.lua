--
-- Author: <wangguojun@playcrab.com>
-- Date: 2016-07-07 14:15:11
--
local LeagueMatchView = class("LeagueMatchView",BaseLayer)
function LeagueMatchView:ctor(data)
    self.super.ctor(self)
    self._callback = data.callback
    -- self.initAnimType = 1
    self._leagueModel = self._modelMgr:getModel("LeagueModel")
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._parent = data.parent
    self._isToBeClose = false
end

-- -- 第一次被加到父节点时候调用
-- function LeagueMatchView:onBeforeAdd(callback)
-- 	if callback then
-- 		callback()
-- 	end
-- end
--
function LeagueMatchView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{hideInfo=true,hideBtn=true,hideHead=true,callback = function( )
    	ViewManager:getInstance():popView()
    end})
end
function LeagueMatchView:getBgName()
    return "bg_league.jpg"
end

-- local imgs = {}
-- for k,v in pairs(tab.hero) do
-- 	if v and v.crusadeRes then
-- 		imgs[v.crusadeRes] = v.crusadeRes
-- 	end
-- end
local rolePool = {
	"asset/uiother/hero/crusade_Adelaide.png",
	"asset/uiother/hero/crusade_Catherine.png",
	"asset/uiother/hero/crusade_CragHack.png",
	"asset/uiother/hero/crusade_Gelu.png",
	"asset/uiother/hero/crusade_Mephala.png",
	"asset/uiother/hero/crusade_Roland.png",
	"asset/uiother/hero/crusade_Sandro.png",
	"asset/uiother/hero/crusade_Vidomina.png",
}
-- for k,v in pairs(imgs) do
-- 	if #rolePool < 5 then
-- 		table.insert(rolePool,"asset/uiother/hero/" .. v ..".png")
-- 	end
-- end

-- 初始化UI后会调用, 有需要请覆盖
function LeagueMatchView:onInit()
	self._matchBtn = self:getUI("bg.matchBtn")
	self:registerClickEvent(self._matchBtn,function()
		if self._matchBtn._tip then
			return 
		end
		if self._callback then
			self._callback(false)
		end 
		self:resetUI()
		self:close()
		-- UIUtils:reloadLuaFile("league.LeagueMatchView")
		-- UIUtils:reloadLuaFile("formation.NewFormationView")
	end)

	-- 加背景
	local bgImg = cc.Sprite:create("asset/bg/bg_league.jpg")
	local xscale = math.max(MAX_SCREEN_WIDTH,bgImg:getContentSize().width) / bgImg:getContentSize().width
    local yscale = math.max(MAX_SCREEN_HEIGHT,bgImg:getContentSize().height) / bgImg:getContentSize().height
	if xscale > yscale then
        bgImg:setScale(xscale)
    else
        bgImg:setScale(yscale)
    end
	bgImg:setPosition(480,math.max(320,MAX_SCREEN_HEIGHT * 0.5))
    -- bgImg:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
	-- bgImg:setScale(xscale,yscale)
	self:getUI("bg"):addChild(bgImg, -10)

	self._topLayer = self:getUI("bg.layer")	
	self._leagueTime = self:getUI("bg.layer.leagueTime")
	self._leagueTime:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	self._leagueTime:setString(string.format("00:%02d",0))
	self._layer = self:getUI("bg.layer")
	self._blueFlag = self:getUI("bg.blueFlag")
    -- self._blueFlag:loadTexture("blueFlag_league.png", 1)
    self:getUI("bg.blueFlag.infoBg"):loadTexture("blueinfobg_league.png", 1)
	self._bHotIconLy = self:getUI("bg.bHotLy.hotIconLy")
	self._bHotLab = self:getUI("bg.bHotLy.hotLab")
	self._bHotLab:setColor(cc.c3b(254,255,221))
	self._bHotLab:enable2Color(1, cc.c4b(253, 190, 77, 255))
	self._bHotLab:enableOutline(cc.c4b(27, 12, 4, 255), 1)
	self._bHotLy = self:getUI("bg.bHotLy")
	self._redFlag = self:getUI("bg.redFlag")
    -- self._redFlag:loadTexture("redFlag_league.png", 1)
    self:getUI("bg.redFlag.infoBg"):loadTexture("redinfobg_league.png", 1)
	self._rHotIconLy = self:getUI("bg.rHotLy.hotIconLy")
	self._rHotLab = self:getUI("bg.rHotLy.hotLab")
	self._rHotLab:setColor(cc.c3b(254,255,221))
	self._rHotLab:enable2Color(1, cc.c4b(253, 190, 77, 255))
	self._rHotLab:enableOutline(cc.c4b(27, 12, 4, 255), 1)
	self._rHotLy = self:getUI("bg.rHotLy")
	self._rHotLy:setVisible(false)
	self._vs = self:getUI("bg.layer.img_vs")
	self._vs:setOpacity(0)
	self._vsMc = mcMgr:createViewMC("vs_duizhanui", false, false,function( )
		self._vsMc:stop()
	end)
	self._vsMc:stop()
	self._vsMc:setVisible(false)
	self._vsMc:setPosition(cc.p(480,320))
	self:getUI("bg"):addChild(self._vsMc,10)


	-- 热点兵团展示适配1136分辨率
	self._borderOffX = 0
	if MAX_SCREEN_WIDTH == 1136 then
		self._rHotLy:setPositionX(self._rHotLy:getPositionX()+100)
		self._bHotLy:setPositionX(self._bHotLy:getPositionX()-82)
		self._borderOffX = 20
		-- self._bHotLy:setPositionX(35)
		local children = self:getUI("bg.blueFlag.infoBg"):getChildren()
		for i,v in ipairs(children) do
			v:setPositionX(v:getPositionX()-20)
		end
		local children = self:getUI("bg.redFlag.infoBg"):getChildren()
		for i,v in ipairs(children) do
			v:setPositionX(v:getPositionX()+20)
		end
	end

	-- 旗子底儿动画
	local redBgMc = mcMgr:createViewMC("youbian_duizhanui", true, false,function(_,sender )
		sender:gotoAndPlay(18)
	end)
	-- redBgMc:stop()
	redBgMc:setScale(1.5)
	-- redBgMc:setVisible(false)
	redBgMc:setPosition(cc.p(350,50))
	self:getUI("bg.redFlag"):addChild(redBgMc,0)
	

	local fixedW = (960-MAX_SCREEN_WIDTH)/2
	local blueInitX = -48+fixedW
	self._blueFlag:setPosition(cc.p(blueInitX,508))
	local redInitX = 1011-fixedW 
	self._redFlag:setPosition(cc.p(redInitX,508))

	local formationModel = self._modelMgr:getModel("FormationModel")
	local leagueFormation = formationModel:getFormationDataByType(formationModel.kFormationTypeLeague)
	local heroId = leagueFormation.heroId
	local heroD = tab:Hero(heroId or 60001)

	self._bRole = self:getUI("bg.blueFlag.roleImg")
	local crusadeRes = heroD.crusadeRes
	-- ================= begin 英雄皮肤 ========================
	local myHadHero = self._modelMgr:getModel("HeroModel"):getHeroData(heroId)
    if myHadHero and myHadHero.skin then
    	local skinTableData = tab:HeroSkin(tonumber(myHadHero.skin))
    	if skinTableData and skinTableData.wholecut then
    		crusadeRes = skinTableData.wholecut
    	end
    end
	-- ================= end   英雄皮肤 ========================
	self._bRole:loadTexture("asset/uiother/hero/" .. crusadeRes ..".png")
	-- self._bRole:setScale(0.8)
	self._bName = self:getUI("bg.blueFlag.infoBg.name")
	self._bName:setFontSize(26)
	local userData = self._modelMgr:getModel("UserModel"):getData()
	self._bName:setFontName(UIUtils.ttfName)
	self._bName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	self._bName:setString(userData.name or "")
	self._bBmpScoreBg,self._bBmpScore = UIUtils:createFightLabel("",0.8,22) --self:getUI("bg.blueFlag.infoBg.bmpScore")
	self._blueFlag:getChildByFullName("infoBg"):addChild(self._bBmpScoreBg)
	self._bBmpScoreBg:setAnchorPoint(0,0.5)
	local children = self._bBmpScoreBg:getChildren()
	for k,v in pairs(children) do
		print(v:getDescription(),v:getDescription(),v:getDescription(),v:getDescription(),v:getDescription())
		if v:getDescription() == "Label" then
			v:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
		end
	end
	self._bBmpScoreBg:setPosition(220-self._borderOffX,-15)
	-- self._bBmpScore:setFntFile(UIUtils.bmfName_zhandouli_little)
	self._bBmpScore:setString("" .. (formationModel:getCurrentFightScoreByType(formationModel.kFormationTypeLeague) or 0))
	self._bBmpScore:setScale(0.45)
	self._bBmpScore:setPositionY(25)
	self._bStageImg = self:getUI("bg.blueFlag.infoBg.stageImg")
	-- begin 新逻辑 显示 自己 积分
	local cupImg = ccui.ImageView:create()
	cupImg:loadTexture("cup_league.png",1)
	cupImg:setPosition(240-self._borderOffX,25)
	self:getUI("bg.blueFlag.infoBg"):addChild(cupImg)
	self._bCupImg = cupImg
	local myCredit = ccui.Text:create()
	myCredit:setFontName(UIUtils.ttfName)
	myCredit:setFontSize(40)
	myCredit:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	local myPoint = self._leagueModel:getLeague() and self._leagueModel:getLeague().currentPoint
	myCredit:setString(myPoint or 0)
	myCredit:setAnchorPoint(0,0.5)
	self._bPointLab = myCredit 
	myCredit:setPosition(265-self._borderOffX,25)
	self:getUI("bg.blueFlag.infoBg"):addChild(myCredit)
	-- end   新逻辑显示积分
	-- 旗子底儿动画
	local blueBgMc = mcMgr:createViewMC("youbian_duizhanui", true, false,function(_,sender )
		sender:gotoAndPlay(18)
	end)
	blueBgMc:setHue(150)
	-- blueBgMc:stop()
	blueBgMc:setScale(1.5)
	-- blueBgMc:setVisible(false)
	blueBgMc:setPosition(cc.p(100,50))
	self:getUI("bg.blueFlag"):addChild(blueBgMc,0)
	
	-- 切换动画
	local roleMc = mcMgr:createViewMC("qiehuandonghua_leaguerolechanging", true, false,function(_,sender )
		sender:gotoAndPlay(18)
	end)
	roleMc:stop()
	roleMc:setScale(1.2)
	-- roleMc:setVisible(false)
	roleMc:setPosition(cc.p(360,200))
	self:getUI("bg.redFlag"):addChild(roleMc)
	self._roleMc = roleMc
	-- 静态表内容
	local leagueData = self._leagueModel:getData()
	local curLeagueRank = tab:LeagueRank(leagueData.league.currentZone or 1)
	self._bStageImg:loadTexture(curLeagueRank.icon .. ".png",1)

	self._rRole = self:getUI("bg.redFlag.roleImg")
	self._rRole:setVisible(false)
	self._rRole:loadTexture(rolePool[GRandom(1,#rolePool)])
	-- self._rRole:setScale(0.8)
	self._rRoleInitPos = cc.p(self._rRole:getPositionX(),self._rRole:getPositionY())

	self._role2 = role2
	self._rName = self:getUI("bg.redFlag.infoBg.name")
	self._rName:setFontSize(26)
	self._rName:setFontName(UIUtils.ttfName)
	self._rName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	self._rName:setString("???")
	-- self._rName:setPositionX(-30+310)
	self._rBmpScore = self:getUI("bg.redFlag.infoBg.bmpScore")
	self._rBmpScore:setFntFile(UIUtils.bmfName_zhandouli_little)
	-- self._rBmpScore:setPositionX(-30+310)
	self._rBmpScoreBg,self._rBmpScore = UIUtils:createFightLabel("",0.8,22) --self:getUI("bg.blueFlag.infoBg.bmpScore")
	self._redFlag:getChildByFullName("infoBg"):addChild(self._rBmpScoreBg)
	self._rBmpScoreBg:setPosition(360,-15)
	self._rBmpScoreBg:setAnchorPoint(1,0.5)
	self._rBmpScore:setScale(0.45)
	self._rBmpScore:setPositionY(25)
	self._rBmpScore:setString("")
	self._rBmpScoreBg:setVisible(false)
	self._rBmpScoreBg:setPositionX(500+self._borderOffX-self._rBmpScore:getContentSize().width)
	local children = self._rBmpScoreBg:getChildren()
	for k,v in pairs(children) do
		print(v:getDescription(),v:getDescription(),v:getDescription(),v:getDescription(),v:getDescription())
		if v:getDescription() == "Label" then
			v:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
		end
	end	
	
	self._rStageImg = self:getUI("bg.redFlag.infoBg.stageImg")
	-- self._rStageImg:setPositionX(-93+310)
	self._rStageImg:loadTexture(curLeagueRank.icon .. ".png",1)

	-- 
	self:upDateSelfHotIcons()
end

-- 添加己方热点兵团icon
function LeagueMatchView:upDateSelfHotIcons( )
	local leagueM = self._modelMgr:getModel("LeagueModel")
	print("leagueM:isShowHot()" ,leagueM:isShowHot())
	if leagueM:isShowHot() == 1 then 
		self._bHotLy:setVisible(false)
		return 
	end
	local hotIds = {}
	-- 赛季热点
	local leagueActD = leagueM:getCurLeagueActD()
	local seasonspot = leagueActD.seasonspot
    if leagueM:getData() and leagueM:getData().first and leagueM:getData().first ~= 0 then
        seasonspot = tab:Setting("G_LEAGUE_FIRST").value
    end
    for k,v in pairs(seasonspot) do
    	table.insert(hotIds,tonumber(v))
    end
	-- 获得自己热点兵团
	local curZone = leagueM:getCurZone()
	local hotD = leagueM:getCurZoneHot(curZone)
	if hotD and hotD.hot and hotD.hot ~= "" and leagueM:isShowHot() ~= 2 then
		local hots = string.split(hotD.hot,',')
		for k,v in pairs(hots) do
		    table.insert(hotIds,tonumber(v))
	    end
	end

    dump(hotIds)
    local haveIds = table.nums(hotIds) > 0
    self._bHotLy:setVisible(haveIds)	
	if haveIds then
		self._bHotIconLy:removeAllChildren()
		for i,v in ipairs(hotIds) do
			local teamData = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(tonumber(v))
            -- local quality = self._modelMgr:getModel("TeamModel"):getTeamQualityByStage(teamData.stage)
            local sTeamData = self._teamModel:getTeamAndIndexById(tonumber(v) or 101)
            local teamD = tab:Team(tonumber(v) or 101)
            local icon
            if sTeamData then
            	local quality = self._modelMgr:getModel("TeamModel"):getTeamQualityByStage(sTeamData.stage)
            	icon = IconUtils:createTeamIconById({teamData = sTeamData, sysTeamData = teamD, quality = quality[1] , quaAddition = quality[2], eventStyle=0})
            else
            	icon = IconUtils:createSysTeamIconById({sysTeamData = teamD, eventStyle=0})
            end
            icon:setCascadeOpacityEnabled(true)
			icon:setPosition((i-1)*70+3,10)
            icon:setName("hot" .. i)
			icon:setScale(0.6)
			if not teamData then
				UIUtils:setGray(icon,true)
			end
			-- local hotImage = ccui.ImageView:create()
			-- hotImage:loadTexture("league_hotlab.png",1)
			-- hotImage:setPosition((i-1)*80+35,90)
			-- hotImage:setScale(0.9)
   --          self._bHotIconLy:addChild(hotImage,444)
            self._bHotIconLy:addChild(icon,333)
		end
	end
end

-- 添加对方热点兵团icon
function LeagueMatchView:upDataRivalHotIcons( rivalData )
	local leagueM = self._modelMgr:getModel("LeagueModel")
	if not rivalData or not next(rivalData) or leagueM:isShowHot() == 1 then return end
	local teams  = rivalData.teams 
	local hotIds  = {}
	local isIdInTeam = {}  -- 
	for k,v in pairs(teams) do
		if v.leagueBuff then
			if leagueM:isShowHot() ~= 2 then
				table.insert(hotIds,tonumber(k))
				isIdInTeam[tonumber(k)] = true
			end
		end
	end

	-- 赛季热点
	local leagueActD = leagueM:getCurLeagueActD()
	local seasonspot = leagueActD.seasonspot
    if leagueM:getData() and leagueM:getData().first and leagueM:getData().first ~= 0 then
        seasonspot = tab:Setting("G_LEAGUE_FIRST").value
    end
    local isSeasonId = {}
    for k,v in pairs(seasonspot) do
    	isSeasonId[tonumber(v)] = true
    	if not isIdInTeam[tonumber(v)] then
	    	table.insert(hotIds,tonumber(v))
	    end
    end
	
	local haveIds = table.nums(hotIds) > 0
	self._rHotLy:setVisible(haveIds)
	if haveIds then
		self._rHotIconLy:removeAllChildren()
		for i,v in ipairs(hotIds) do
			local sTeamData = self._teamModel:getTeamAndIndexById(tonumber(v) or 101)
            local teamD = tab:Team(tonumber(v) or 101)
            local icon
            if sTeamData then
            	local quality = self._modelMgr:getModel("TeamModel"):getTeamQualityByStage(sTeamData.stage)
            	icon = IconUtils:createTeamIconById({teamData = sTeamData, sysTeamData = teamD, quality = quality[1] , quaAddition = quality[2], eventStyle=0})
            else
            	icon = IconUtils:createSysTeamIconById({sysTeamData = teamD,eventStyle=0})
            end
            icon:setCascadeOpacityEnabled(true)
			icon:setPosition(140-(i-1)*70-10,10)
            icon:setName("hot" .. i)
			icon:setScale(0.6)
			if not isIdInTeam[tonumber(v)] then
				UIUtils:setGray(icon,true)
			end
            self._rHotIconLy:addChild(icon,333)
		end
	end
end

-- 滚动特效
function LeagueMatchView:rollTheRole( )
	-- self._roleMc:gotoAndStop(0)
	local beginX = self._bRole:getPositionX()
	-- local beginY = self._bRole:getPositionY()
	self._rRole:setOpacity(0)
	self._roleMc:gotoAndPlay(0)
	self._roleMc:setVisible(true)
	self._roleMc:addEndCallback(function (_, sender)
		sender:gotoAndPlay(21)
	end)
	self._rRoleX = beginX
	local stageIdx = 2
	-- 前两次切换较慢
	local act1 = cc.Sequence:create(
		-- cc.FadeIn:create(0.35),
		cc.DelayTime:create(0.15)
		,cc.CallFunc:create(function( )
			local curLeagueRank = tab:LeagueRank(stageIdx%#tab.leagueRank+1)
			self._rStageImg:loadTexture(curLeagueRank.icon .. ".png",1)
			stageIdx = stageIdx + 1
			audioMgr:playSound("LeagueMatchSlash")
		end)
		,cc.DelayTime:create(0.1)
	)

	local act2 = cc.Sequence:create(
		-- cc.FadeIn:create(0.35),
		cc.DelayTime:create(0.3)
		,cc.CallFunc:create(function( )
			local curLeagueRank = tab:LeagueRank(stageIdx%#tab.leagueRank+1)
			self._rStageImg:loadTexture(curLeagueRank.icon .. ".png",1)
			stageIdx = stageIdx + 1
			audioMgr:playSound("LeagueMatchSlash")
		end)
		,cc.DelayTime:create(0.1)
	)

	local act3 = cc.Sequence:create(
		-- cc.FadeIn:create(0.35),
		cc.DelayTime:create(0.1)
		,cc.CallFunc:create(function( )
			local curLeagueRank = tab:LeagueRank(stageIdx%#tab.leagueRank+1)
			self._rStageImg:loadTexture(curLeagueRank.icon .. ".png",1)
			stageIdx = stageIdx + 1
			audioMgr:playSound("LeagueMatchSlash")
		end)
		-- ,cc.DelayTime:create(0.1)
	)


	local callbackAct = cc.CallFunc:create(function( )
		self._rStageImg:stopAllActions()
		-- 后边快速切换
		local repeatAct = cc.RepeatForever:create(cc.Sequence:create(
			-- cc.FadeIn:create(0.35),
			cc.CallFunc:create(function( )
				local curLeagueRank = tab:LeagueRank(stageIdx%#tab.leagueRank+1)
				self._rStageImg:loadTexture(curLeagueRank.icon .. ".png",1)
				stageIdx = stageIdx + 1
				audioMgr:playSound("LeagueMatchSlash")
			end)
			,cc.DelayTime:create(0.2)
		))

		self._rStageImg:runAction(repeatAct)
	end)

	local seq = cc.Sequence:create(act1,act2,act3,callbackAct)
	self._rStageImg:runAction(seq)
end

function LeagueMatchView:countDown( )
	local clockT = math.floor(os.clock()*10)
    GRandomSeed(tostring(os.time()+clockT):reverse():sub(1, 6))
	local endNum = GRandom(1,10)
	local count = 1
	self._leagueTime:setString(string.format("00:%02d",count))
	if not self._timeSchedule then
		self._timeSchedule = ScheduleMgr:regSchedule(1000,self,function( )
			self._leagueTime:setString(string.format("00:%02d",count))
			if count >= endNum then
				ScheduleMgr:unregSchedule(self._timeSchedule)
				self._timeSchedule = nil
				-- if self._callback then
				-- 	self._callback(true)
				-- end
				self._matchBtn:setEnabled(false)
				self:findEnemy()
				-- self:close()
				-- UIUtils:reloadLuaFile("league.LeagueMatchView")
			end
			count = count+1
		end)
	end
end

-- 获得敌人信息
function LeagueMatchView:findEnemy()
	self._matchBtn._tip = ""
	self._serverMgr:sendMsg("LeagueServer", "findEnemy", {}, true, {}, function(result)
		-- dump(result,"findEnemy",10)
		-- 加实际的战斗力
		if OS_IS_WINDOWS and result.ce then
			local selfScore = self._blueFlag:getChildByName("scoreLab")
			if not selfScore then
				selfScore = ccui.Text:create()
				selfScore:setFontSize(18)
				selfScore:setFontName(UIUtils.ttfName)
				selfScore:setPosition(50,0)
				selfScore:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
				selfScore:setName("scoreLab")
				self._blueFlag:addChild(selfScore,99)
			end
			selfScore:setAnchorPoint(0,1)
			selfScore:getVirtualRenderer():setMaxLineWidth(900)
			selfScore:setString("测试用战力:" .. (result.ce.self or 0) .. (result.debug and serialize({current = result.debug.current,up=result.debug.up,down=result.debug.down,listNum=table.nums(result.debug.celist)}) or " "))
			local rivalScore = self._redFlag:getChildByName("scoreLab")
			if not rivalScore then
				rivalScore = ccui.Text:create()
				rivalScore:setFontSize(30)
				rivalScore:setFontName(UIUtils.ttfName)
				rivalScore:setPosition(300,-10)
				rivalScore:setName("scoreLab")
				rivalScore:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
				self._redFlag:addChild(rivalScore,99)
			end
			rivalScore:setString("测试用战力:" .. (result.ce.rival or 0))
			if result.npc and result.npc == 1 then
				rivalScore:setString("这是NPC")
			end
		end
		local info = result.rival or {}
    	self._leagueModel:setEnemyZone((result.ce and result.ce.rivalZone) or 1)
		if result.ce and result.ce.rivalZone then
			self._rStageImg:stopAllActions()
			local enemyLeagueRank = tab:LeagueRank(result.ce.rivalZone)
			self._rStageImg:loadTexture(enemyLeagueRank.icon .. ".png",1)
		end
		self:upDataRivalHotIcons(info)
		audioMgr:playSound("LeagueMatch")
		audioMgr:playSound("LeagueMatchVS")
        local enemyFormation = info.formation or {}
		self._rName:setString(info.name or "???")
		self._rBmpScore:setString( "" .. (enemyFormation.score or 0))
		self._rBmpScoreBg:setPositionX(self._rName:getPositionX()-5-self._rBmpScore:getContentSize().width*self._rBmpScore:getScale())
		self._rBmpScoreBg:setVisible(true)
		self._leagueModel:setEnemyMatchScore((enemyFormation.score or 0))
		self._roleMc:gotoAndStop(0)
		self._roleMc:stop()
		self._roleMc:setVisible(false)
		self._vs:setScale(7.8)
		self._rRole:stopAllActions()
		self._rRole:setPositionX(self._rRoleX)
		self._rRole:setOpacity(255)
		local heroD = tab:Hero((info.formation and tonumber(info.formation.heroId)) or 60001)--info.formation.heroId))
		local crusadeRes = heroD.crusadeRes

		-- begin 新逻辑 显示 敌人 积分
		local cupImg = ccui.ImageView:create()
		cupImg:loadTexture("cup_league.png",1)
		cupImg:setAnchorPoint(1,0.5)
		cupImg:setPosition(self._rName:getPositionX(),25)
		self:getUI("bg.redFlag.infoBg"):addChild(cupImg)
		self._rCupImg = cupImg
		local credit = ccui.Text:create()
		credit:setFontName(UIUtils.ttfName)
		credit:setFontSize(40)
		credit:setAnchorPoint(1,0.5)
		credit:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
		local ePoint = result.rScore or (self._leagueModel:getLeague().currentPoint-3) or 1000
		credit:setString(ePoint or 0)
		self._rPointLab = credit 
		credit:setPosition(self._rName:getPositionX()-45,25)
		self:getUI("bg.redFlag.infoBg"):addChild(credit)
		-- end   新逻辑显示积分
		-- ================= begin 英雄皮肤 ========================
		local skin = result.skin  -- 后端还没传 暂写在info.skin
	    if skin then
	    	local skinTableData = tab:HeroSkin(tonumber(skin))
	    	if skinTableData and skinTableData.wholecut then
	    		crusadeRes = skinTableData.wholecut
	    	end
	    end
		-- ================= end   英雄皮肤 ========================
		self._rRole:loadTexture("asset/uiother/hero/" .. crusadeRes ..".png") -- 
		self._rRole:setZOrder(1)
		local moveBeginPos = cc.p(self._rRoleInitPos.x+heroD.crusadePosi[1]+200,self._rRoleInitPos.y)
		local moveEndPos = cc.p(self._rRoleInitPos.x+heroD.crusadePosi[1]-100,self._rRoleInitPos.y)
		self._rRole:setPosition(moveBeginPos)
		self._rRole:setColor(cc.c3b(0, 0, 0))
		self._rRole:setVisible(true)
		self._rRole:runAction(cc.Sequence:create(
			cc.MoveTo:create(0.1,moveEndPos),
			cc.TintTo:create(0.2,cc.c4b(255, 255, 255, 255)),
			cc.CallFunc:create(function( )
				self._vsMc:setVisible(true)
				self._vsMc:gotoAndPlay(0)
				self._isToBeClose = true
				self._vs:runAction(cc.Sequence:create(
					cc.DelayTime:create(1),
					cc.CallFunc:create(function( )
		                if self._timeSchedule then 
						    ScheduleMgr:unregSchedule(self._timeSchedule)
						    self._timeSchedule = nil
		                end
						local callback = self._callback
						self:close()
						if callback then
							callback(result)
						end
					end)
				))
			end)
		))
	end,
	function( errorCode ) -- error func
		if errorCode then
			ViewManager:getInstance():showTip("当前没有能匹配的对手")
			ScheduleMgr:delayCall(1000, self, function( )
				if self and self.close then
					self:close()
					self:setVisible(false) -- 匹配不到人隐藏
				end
				ViewManager:getInstance():showNavigation("global.UserInfoView",{hideInfo=true,hideHead=true,hideBtn=false})
			end)
		end
	end
	)
end

-- 接收自定义消息
function LeagueMatchView:reflashUI(data)

end

function LeagueMatchView:resetUI( )
	self._matchBtn:setEnabled(true)
	self._matchBtn._tip = nil
	self._rName:setString("???")
	self._rBmpScore:setString("")
	self._rBmpScoreBg:setPositionX(500+self._borderOffX-self._rBmpScore:getContentSize().width)
	self._rBmpScoreBg:setVisible(false)
	self._vs:setOpacity(0)
	self._vsMc:setVisible(false)
	self._leagueTime:setString(string.format("00:%02d",0))
	self._roleMc:gotoAndStop(0)
	local formationModel = self._modelMgr:getModel("FormationModel")
	self._bBmpScore:setString("" .. (formationModel:getCurrentFightScoreByType(formationModel.kFormationTypeLeague) or 0))
	audioMgr:stopAll()
	self._rStageImg:stopAllActions()
	local leagueData = self._leagueModel:getLeague()
	if leagueData then
		local curLeagueRank = tab:LeagueRank(leagueData.currentZone or 1)
		self._rStageImg:loadTexture(curLeagueRank.icon .. ".png",1)
		self._bStageImg:loadTexture(curLeagueRank.icon .. ".png",1)
		-- self._rStageImg:setPositionX(-93+310)
		self._rStageImg:loadTexture(curLeagueRank.icon .. ".png",1)
		self._rStageImg:stopAllActions()
	
		if self._bPointLab then
			local myPoint = self._leagueModel:getLeague() and self._leagueModel:getLeague().currentPoint
			self._bPointLab:setString(myPoint or 0)
		end
	end
	if not tolua.isnull(self._rCupImg) then
		self._rCupImg:removeFromParent()
	end
	if not tolua.isnull(self._rPointLab) then
		self._rPointLab:removeFromParent()
	end
	-- 更新热点
	self:upDateSelfHotIcons()
	self._rHotLy:setVisible(false)
	self._rHotIconLy:removeAllChildren()
end

-- 重载出现动画
function LeagueMatchView:beforePopAnim()
	self:resetUI()-- 
	local formationModel = self._modelMgr:getModel("FormationModel")
	local leagueFormation = formationModel:getFormationDataByType(formationModel.kFormationTypeLeague)
	local heroId = leagueFormation.heroId
	local heroD = tab:Hero(heroId or 60001)
	local crusadeRes = heroD.crusadeRes
	-- ================= begin 英雄皮肤 ========================
	local myHadHero = self._modelMgr:getModel("HeroModel"):getHeroData(heroId)
    if myHadHero and myHadHero.skin then
    	local skinTableData = tab:HeroSkin(tonumber(myHadHero.skin))
    	if skinTableData and skinTableData.wholecut then
    		crusadeRes = skinTableData.wholecut
    	end
    end
	-- ================= end   英雄皮肤 ========================
	self._bRole:loadTexture("asset/uiother/hero/" .. crusadeRes ..".png")
	self._rRole:setOpacity(0)
    if self.initAnimType == 1 or self.initAnimType == 2 then
        if self._topLayer and self._topLayer.visible then
            self._topLayer:setOpacity(0)
        end
    end
end

function LeagueMatchView:popAnim(callback)
    -- 执行父节点动画
    -- self.super.popAnim(self,callback)
    -- 定义自己动画
    if self._topLayer then
    		if not self._topInitPos then
    			self._topInitPos = cc.p(self._topLayer:getPositionX(), self._topLayer:getPositionY())
    		end
		    local topBeginPos = cc.p(self._topInitPos.x, self._topInitPos.y)
            self._topLayer:stopAllActions()
            self._topLayer:setOpacity(255)
            self._topLayer:setAnchorPoint(cc.p(0,0))
            local x, y = topBeginPos.x, topBeginPos.y +(MAX_SCREEN_HEIGHT-960)+320
            self._topLayer:setPosition(x, y + 80)
            self._topLayer:runAction(cc.Sequence:create(
                cc.DelayTime:create(0.13),
                cc.EaseOut:create(cc.MoveTo:create(0.1, cc.p(x, y - 5)), 3),
                cc.MoveTo:create(0.07, cc.p(x, y))
            ))
    end
    local btnBgInitPos = cc.p(self._matchBtn:getPositionX(),74)
    self._matchBtn:setPosition(cc.p(btnBgInitPos.x,btnBgInitPos.y-300))
    self._matchBtn:runAction(cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(0.2,cc.pAdd(btnBgInitPos,cc.p(0,10))),cc.FadeIn:create(0.1)),cc.MoveTo:create(0.05,btnBgInitPos)))
    
    local fixedW = (960-MAX_SCREEN_WIDTH)/2
    print(fixedW,"fixedW")
    ScheduleMgr:nextFrameCall(self, function()
    	local blueInitX = 0+fixedW
    	local fromX = 100
    	local bounceX = 10
        self._blueFlag:setPosition(cc.p(blueInitX-fromX,MAX_SCREEN_HEIGHT))
        self._blueFlag:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.13),
            cc.EaseOut:create(cc.MoveTo:create(0.1, cc.p(blueInitX+bounceX,MAX_SCREEN_HEIGHT)), 3),
            cc.MoveTo:create(0.07, cc.p(blueInitX,MAX_SCREEN_HEIGHT))
        ))

        local redInitX = MAX_SCREEN_WIDTH+fixedW 
        self._redFlag:setPosition(cc.p(redInitX+fromX,MAX_SCREEN_HEIGHT))
        self._redFlag:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.13),
            cc.EaseOut:create(cc.MoveTo:create(0.1, cc.p(redInitX-bounceX,MAX_SCREEN_HEIGHT)), 3),
            cc.MoveTo:create(0.07, cc.p(redInitX,MAX_SCREEN_HEIGHT)),
            cc.DelayTime:create(0.5),
            cc.CallFunc:create(function ( )
            	if self:isVisible() then
		            self:rollTheRole()
		            self:countDown()
		        end
            end)
        ))

    end)
end

-- baseLayer 没有close方法,重写
function LeagueMatchView:close()
	-- self:setVisible(false)
	if self._timeSchedule then
		ScheduleMgr:unregSchedule(self._timeSchedule)
		self._timeSchedule = nil
	end
	self._vsMc:stop()
	self._rRole:stopAllActions()
	self._rStageImg:stopAllActions()
end

function LeagueMatchView:onDestroy( )
	if self._timeSchedule then
		ScheduleMgr:unregSchedule(self._timeSchedule)
		self._timeSchedule = nil
	end
	self._rRole:stopAllActions()
	self.super.onDestroy(self)
end

return LeagueMatchView