--
-- Author: <ligen@playcrab.com>
-- Date: 2017-08-16 16:49:30
--
local DialogCityBattleUserInfo = class("DialogCityBattleUserInfo",BasePopView)
function DialogCityBattleUserInfo:ctor(data)
    DialogCityBattleUserInfo.super.ctor(self)

    self._palyerData = data
end

function DialogCityBattleUserInfo:onInit()
	self:registerClickEventByName("bg.closeBtn", function(  )
		self:close()
		UIUtils:reloadLuaFile("citybattle.DialogCityBattleUserInfo")
	end)

	self._bg = self:getUI("bg")

    self._title = self:getUI("bg.titleBg.title_txt")
    UIUtils:setTitleFormat(self._title, 1)

    self._heroHead = self:getUI("bg.heroHead")

    self._name = self:getUI("bg.name")
	UIUtils:setTitleFormat(self._name, 2)
	self._vipLab = cc.Label:createWithBMFont(UIUtils.bmfName_vip, "")
    -- self._vipLab:setScale(0.8)
    self._vipLab:setAnchorPoint(cc.p(0,0.5))
    self._vipLab:setPosition(self._name:getPositionX()+self._name:getContentSize().width+10,self._name:getPositionY())
    -- self._vipLabel:setAdditionalKerning(-5)
    self._name:getParent():addChild(self._vipLab, 2)

    self._guildTxt = self:getUI("bg.guild")
	self._guildName = self:getUI("bg.guildName")

    local score = self:getUI("bg.score")
	score:setVisible(false)
	self._score = ccui.TextBMFont:create("00", UIUtils.bmfName_zhandouli_little)
	self._score:setAnchorPoint(cc.p(0,0))
	self._score:setScale(0.6)
	self._score:setPosition(score:getPositionX() ,score:getPositionY()+10)
	self._bg:addChild(self._score)

    self._heroHead = self:getUI("bg.heroHead")
	self._headFrame = self:getUI("bg.info_panel.headFrame")

	self._scrollView = self:getUI("bg.scrollBg.scrollView")

end

function DialogCityBattleUserInfo:reflashUI(data)
--    dump(data)
    
    if not data.avatar or data.avatar==0 then
		data.avatar = 1203
	end

    if not self._avatar then
        self._avatar = IconUtils:createHeadIconById({avatar = data.avatar,level = data.lv or "0" ,tp = 4,avatarFrame=data["avatarFrame"], plvl = data["plvl"]}) 
        -- self._avatar:getChildByFullName("iconColor"):loadTexture("globalImageUI6_headBg.png",1)
        self._avatar:setPosition(cc.p(-1,-1))
        self._heroHead:addChild(self._avatar)
    else
        IconUtils:updateHeadIconByView(self._avatar,{avatar = data.avatar,level = data.lv or "0" ,tp = 4})
        -- self._avatar:getChildByFullName("iconColor"):loadTexture("globalImageUI6_headBg.png",1)
    end

	self._name:setString(data.name or "")

    local rankStr =  ""
	rankStr = self._modelMgr:getModel("LeagueModel"):getServerName(data.serverNum)
	self._guildName:setPositionX(self._guildTxt:getPositionX()+self._guildTxt:getContentSize().width-5) 
    self._guildName:setString(rankStr)

    if not data.formation then
		data.formation = {}
	end
	local score = data.score 
	self._score:setString("a" .. score)
	local vipLvl = (data.vipLvl or 0)

	self._vipLab:setPosition(self._name:getPositionX()+self._name:getContentSize().width+10,self._name:getPositionY())
	self._vipLab:setString( "V" .. vipLvl)
	local isHideVip = UIUtils:isHideVip(data.hideVip,"userInfo")
	if vipLvl == 0 or isHideVip then
		self._vipLab:setVisible(false)
		self._vipLab:setString("")
		-- self._vipBtn:setVisible(false)
	else
		self._vipLab:setVisible(true)
	end

    local heroName = self:getUI("bg.info_panel.heroName")
	local heroData = clone(tab:Hero(data.formation.heroId or 60001))
	heroData.star = data.hero.star
	heroData.skin = data.hero.skin
	
	heroName:setString(lang(heroData.heroname))
    local icon = IconUtils:createHeroIconById({sysHeroData = heroData})
    icon:setScale(0.9)
    icon:setPosition(self._headFrame:getContentSize().width * 0.5, self._headFrame:getContentSize().height * 0.5)
    self:registerClickEvent(icon,function( )
    	local detailData = {}
    	detailData.heros = data.hero
    	detailData.heros.heroId = data.formation.heroId
    	if data.globalSpecial and data.globalSpecial ~= "" then
    		detailData.globalSpecial = data.globalSpecial
    	end
    	detailData.level = data.lv 
    	detailData.treasures = data.treasures
    	detailData.hAb = data.hAb
    	detailData.talentData = data.talentData or data.talent
        detailData.uMastery = data.uMastery
        detailData.hSkin = data.hSkin
        detailData.backups = data.backups
        detailData.pTalents = data.pTalents
    	-- ViewManager:getInstance():showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeArenaHero, iconId = data.formation.heroId}, true)
    	ViewManager:getInstance():showDialog("rank.RankHeroDetailView", {data=detailData}, true)
    end)
	self._headFrame:addChild(icon)
	local x,y = 0,0
	local offsetx,offsety = 10,5
	local row,col = 2,4
	local iconSize = 93
	local boardHeight = self._scrollView:getContentSize().height
	local idx = 1
	local item 
	-- dump(data.teams)
	for teamId,team in pairs(data.teams) do
		x = (idx-1)%col*iconSize+offsetx
		y = boardHeight- (math.floor((idx-1)/col+1)*iconSize)+offsety
		team.teamId = tonumber(teamId)
		item = self:createTeams(x,y,tonumber(teamId),team)
		idx=idx+1
		item:setScale(0.73)
		item:setPosition(cc.p(x,y))
		self._scrollView:addChild(item)
		
	end
	local teamMaxNum = tab:UserLevel(tonumber(data.lv or data.level)).num
	for i = idx ,8 do
		x = (idx-1)%col*iconSize+offsetx
		y = boardHeight- (math.floor((idx-1)/col+1)*iconSize)+offsety
		-- 未达到最大上阵兵团数，添加空格子，剩下不足八个的添加带锁的空格子		
		if i <= teamMaxNum then			
			item = self:createGrid(x,y,false)		
		else
			item = self:createGrid(x,y,true)
		end
		idx=idx+1
		item:setScale(0.73)
		item:setPosition(cc.p(x,y))
		self._scrollView:addChild(item)
	end

	-- weapon信息展示
	local formationData = self._palyerData.formation
	self._weaponId = {}		-- 上阵weaponId	
	local weaponId
	for i=1,3 do
		weaponId = formationData["weapon"..i]
		if weaponId and weaponId ~= 0 then 
			table.insert(self._weaponId,weaponId)
		end
	end

    local weaponPanel = self:getUI("bg.info_panel.weaponPanel")
    if #self._weaponId > 0 then 
    	local weaponsData = data.weapons
    	weaponPanel:setVisible(true)
    	self:initWeaponsPanel(weaponPanel,weaponsData)
    	heroName:setVisible(false)
    else
    	weaponPanel:setVisible(false)
		heroName:setVisible(true)    	
    end
end

-- 器械
function DialogCityBattleUserInfo:initWeaponsPanel(weaponPanel,weaponsData)
	local weaponD = weaponsData or {}
	local weaponIDs = self._weaponId
	local x,y = 0,0
	local offsetx,offsety = 5,18
	local iconSize = 76
	local item
	-- local levelD = tab.systemOpen["Weapon"]
	-- local level = levelD and levelD[1] or 1000
	local isOpen = true --self._palyerData.lv >= tonumber(level)
	for i=1,3 do
		local weaponID = weaponIDs[i]
		local weaponTemp = weaponD[weaponID] or {}
		if weaponID then
			local weaponsTab = tab:SiegeWeapon(weaponID)
			local tLevel = weaponTemp.lv
			local param = {weaponsTab = weaponsTab, level = tlevel}
			item = IconUtils:createWeaponsIconById(param)
			item:setName("item" .. i)
            item:setScale(0.67)
            item:setPosition(x+offsetx,y+offsety-2)

            local clickFlag = false
            local downY
            local posX, posY
            registerTouchEvent(
                item,
                function (_, _, y)
                    downY = y
                    clickFlag = false
                end, 
                function (_, _, y)
                    if downY and math.abs(downY - y) > 5 then
                        clickFlag = true
                    end
                end, 
                function ()
                    if clickFlag == false then
                        if not weaponD[tostring(weaponID)] then 
                            print("======数据异常=====")
                        	return
                        end
                        local userWeapon = clone(weaponD[tostring(weaponID)])
                        local weaponType = weaponsTab.type
                        userWeapon.unlockIds = {}
                        userWeapon.unlockIds[tostring(weaponID)] = userWeapon.score or 0
                        local param = {userWeapon = userWeapon, weaponId = weaponID, weaponType = weaponType}
                        self._viewMgr:showDialog("rank.RankWeaponsDetailView", param)                        
                    end
                end,
                function ()
                end)
            item:setSwallowTouches(false)
		else
			item = self:createGrid(x,y,not isOpen)
			item:setScale(0.6)
			item:setPosition(x+offsetx,y+offsety)
		end
		weaponPanel:addChild(item)
		x = x + iconSize
	end
end

function DialogCityBattleUserInfo:createTeams( x,y,teamId,teamData )
	-- dump(teamData)
	local teamD = tab:Team(teamId)
	-- print("===========self._palyerData.formation.heroId,teamId=>",self._palyerData.formation.heroId,teamId)
	local _,changeId = TeamUtils.changeArtForHeroMasteryByData(self._palyerData.hero,self._palyerData.formation.heroId,teamId)
	-- print("===========cahngeId=========",changeId)
	if changeId then
		teamD = tab:Team(changeId)
	end
	local quality = self._modelMgr:getModel("TeamModel"):getTeamQualityByStage(teamData.stage)
    local teamIcon = IconUtils:createTeamIconById({teamData = teamData,sysTeamData = teamD, quality = quality[1] , quaAddition = quality[2],eventStyle=3,clickCallback = function( )		
    	local detailData = {}
    	detailData.team = teamData
    	detailData.team.teamId = teamId
    	if changeId then
			detailData.team.teamId = changeId
		end    
    	detailData.pokedex = self._palyerData.pokedex 
    	detailData.treasures = self._palyerData.treasures
    	detailData.runes = self._palyerData.runes
    	detailData.heros = self._palyerData.heros
    	detailData.battleArray = self._palyerData.battleArray
        detailData.pTalents = self._palyerData.pTalents
    	ViewManager:getInstance():showDialog("rank.RankTeamDetailView", {data=detailData}, true)
    	-- ViewManager:getInstance():showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeArenaTeam, iconId = teamId}, true)
    end})
	return teamIcon
end
function DialogCityBattleUserInfo:createGrid(x,y,isLocked)
	local bagGrid = ccui.Widget:create()
    bagGrid:setContentSize(cc.size(107,107))
    bagGrid:setAnchorPoint(cc.p(0,0))

    local bagGridFrame = ccui.ImageView:create()
    bagGridFrame:loadTexture("globalImageUI4_squality1.png", 1)
    bagGridFrame:setName("bagGridFrame")
    bagGridFrame:setContentSize(cc.size(107, 107))
    bagGridFrame:ignoreContentAdaptWithSize(false)
    bagGridFrame:setAnchorPoint(cc.p(0,0))
    bagGrid:addChild(bagGridFrame,1)

    local bagGridBg = ccui.ImageView:create()
    bagGridBg:loadTexture("globalImageUI4_itemBg3.png", 1)
    bagGridBg:setName("bagGridBg")
    bagGridBg:setContentSize(cc.size(107, 107))
    bagGridBg:ignoreContentAdaptWithSize(false)
    bagGridBg:setAnchorPoint(cc.p(0.5,0.5))
    bagGridBg:setPosition(cc.p(bagGrid:getContentSize().width/2,bagGrid:getContentSize().height/2))
    bagGrid:addChild(bagGridBg,-1)

    -- locked
    if isLocked then
    	local lockImg = ccui.ImageView:create()
	    lockImg:loadTexture("globalImageUI5_treasureLock.png", 1)
	    lockImg:setName("lockImg")
	    lockImg:setAnchorPoint(cc.p(0.5,0.5))
	    lockImg:setScale(1.5)
	    lockImg:setPosition(cc.p(bagGrid:getContentSize().width/2,bagGrid:getContentSize().height/2))
	    bagGrid:addChild(lockImg,2)
	end
	return bagGrid
	
end
return DialogCityBattleUserInfo