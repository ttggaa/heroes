--
-- Author: zhaoyang
-- Date: 2016-06-16 21:04:39
--

-- local NewFormationIconView = require("game.view.formation.NewFormationIconView")
local DialogPVEUserInfo = class("DialogPVEUserInfo",BasePopView)
function DialogPVEUserInfo:ctor(data)
    self.super.ctor(self)
    self._palyerData = data
end

-- 初始化UI后会调用, 有需要请覆盖
function DialogPVEUserInfo:onInit(data)
	self:registerClickEventByName("bg.closeBtn", function(  )
		self:close()
		UIUtils:reloadLuaFile("pve.DialogPVEUserInfo")
	end)

	self._chatBtn = self:getUI("bg.chatBtn")
	self._friend = self:getUI("bg.friendBtn") 
	-- self._chatBtn:setVisible(not self._notShowBtn)
	-- self._friend:setVisible(not self._notShowBtn)
	self:registerClickEvent(self._chatBtn, function ()
        self:clickChatEvent()
    end)
    self:registerClickEvent(self._friend, function ()
        self:addFriendEvent()
    end)
    local userData = self._modelMgr:getModel("UserModel"):getData()
	if self._palyerData and self._palyerData.rid and self._palyerData.rid == userData._id then 
		self._chatBtn:setVisible(false)
		self._chatBtn:setEnabled(false)
		self._friend:setVisible(false)
		self._friend:setEnabled(false)
	end

	self._bg = self:getUI("bg")
	self._title = self:getUI("bg.title_img.title_txt")
    UIUtils:setTitleFormat(self._title, 1)

    self._nameBg = self:getUI("bg.nameBg")
    self._nameBg:setContentSize(1,1)
	--    self._nameBg:setContentSize(self._nameBg:getContentSize().width + 30, self._nameBg:getContentSize().height)

	self._name = self:getUI("bg.name")	
	UIUtils:setTitleFormat(self._name, 2)
	self._level = self:getUI("bg.level")
	self._level:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
	self._rank = self:getUI("bg.rank")
	self._rank:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
	
	local score = self:getUI("bg.score")
	score:setVisible(false)
	self._score = ccui.TextBMFont:create("00", UIUtils.bmfName_zhandouli_little)
	self._score:setAnchorPoint(cc.p(0,0))
	self._score:setScale(0.6)
	self._score:setPosition(score:getPositionX()-4 ,score:getPositionY()+15)
	self._bg:addChild(self._score)
	self._heroHead = self:getUI("bg.heroHead")
	self._headFrame = self:getUI("bg.info_panel.headFrame")
	self._desTxt = self:getUI("bg.info_panel.des_txt")
	self._desTxt:setFontName(UIUtils.ttfName)
	self._desTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
	-- self._headFrame:setScale(0.8)
	-- self._vipLab = self:getUI("bg.vipBtn.vipLab")
	-- self._vipLab:setFntFile(UIUtils.bmfName_vip)

	-- self._vipBtn = self:getUI("bg.vipBtn")
 --    self._vipLab = cc.Label:createWithBMFont(UIUtils.bmfName_vip, "10")
 --    self._vipLab:setPosition(self._vipBtn:getContentSize().width * 0.5, 3.5)
 --    self._vipLab:setAdditionalKerning(-5)
 --    self._vipBtn:addChild(self._vipLab)

    self._vipLab = cc.Label:createWithBMFont(UIUtils.bmfName_vip, "10")
    -- self._vipLab:setScale(0.8)
    self._vipLab:setAnchorPoint(cc.p(0,0.5))
    self._vipLab:setPosition(self._name:getPositionX()+self._name:getContentSize().width+10,self._name:getPositionY())
    -- self._vipLabel:setAdditionalKerning(-5)
    self._name:getParent():addChild(self._vipLab, 2)

	self._scrollView = self:getUI("bg.scrollBg.scrollView")
	self._teamInfo = self:getUI("bg.scrollBg.team_info")
	self._teamInfo:setFontName(UIUtils.ttfName)
	self._teamInfo:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)

	self._guildName = self:getUI("bg.guildName")
	-- self._guildName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)

	self._signTxt = self:getUI("bg.signBg.signTxt")	

end

-- 接收自定义消息
function DialogPVEUserInfo:reflashUI(data)
--	 dump(data)

	if data.teams then
		self._modelMgr:getModel("ArenaModel"):setEnemyData(data.teams)
	end
	if data.hero then
		self._modelMgr:getModel("ArenaModel"):setEnemyHeroData(data.hero)
	end


	-- local userInfo = self._modelMgr:getModel("UserModel"):getData()
	if not data.avatar or data.avatar==0 then--safecode toberemove
		data.avatar = 1203--safecode toberemove
	end--safecode toberemove

    local tencetTp = data["qqVip"]
    if not self._avatar then
        self._avatar = IconUtils:createHeadIconById({avatar = data.avatar,level = (data.level or data.lv or "0") ,tp = 4,avatarFrame = data["avatarFrame"], tencetTp = tencetTp})
        -- self._avatar:getChildByFullName("iconColor"):loadTexture("globalImageUI6_headBg.png",1)
        self._avatar:setPosition(cc.p(-1,-1))
        self._heroHead:addChild(self._avatar)
    else
        IconUtils:updateHeadIconByView(self._avatar,{avatar = data.avatar,level = (data.level or data.lv or "0") ,tp = 4,avatarFrame = data["avatarFrame"], tencetTp = tencetTp})
        -- self._avatar:getChildByFullName("iconColor"):loadTexture("globalImageUI6_headBg.png",1)
    end

--    	data["tequan"] = "sq_gamecenter"
	local tequanImg = IconUtils.tencentIcon[data["tequan"]] or "globalImageUI6_meiyoutu.png"
	local tequanIcon = ccui.ImageView:create(tequanImg, 1)
    tequanIcon:setPosition(688, 458)
	self._bg:addChild(tequanIcon)
    tequanIcon:setScaleAnim(true)

    if tequanImg ~= "globalImageUI6_meiyoutu.png" then
        self:registerClickEvent(tequanIcon,function( sender )
            self._viewMgr:showDialog("tencentprivilege.TencentPrivilegeView")
        end)
    end

	self._name:setString(data.name or "")
	self._level:setString("")--(data.lv or 0)
	self._level:setVisible(false)
	self._rank:setString(data.rank or 0)
	-- self._score:setScale(0.8)
	self._score:setString("a".. (data.fight or data.score or 0))
	self._rank:setString(data.rank or "暂无排名")
	local vipLvl = (data.vipLvl or 0)
	local isHideVip = UIUtils:isHideVip(data.hideVip,"userInfo")
	if vipLvl == 0 or isHideVip then
		self._vipLab:setVisible(false)
		-- self._vipBtn:setVisible(false)
	else
		self._vipLab:setVisible(true)
	end
	self._vipLab:setPosition(self._name:getPositionX()+self._name:getContentSize().width+10,self._name:getPositionY())
	self._vipLab:setString( "V" .. vipLvl)

    -- local nameWidth = self._name:getContentSize().width+10+self._vipLab:getContentSize().width   
    -- self._nameBg:setContentSize(nameWidth < 115 and 192 or nameWidth + 80, self._nameBg:getContentSize().height)

    --guild
    local guild = self:getUI("bg.guild")

	local rankStr =  ""
    if data.guildName and data.guildName ~= "" then        
        rankStr = data.guildName
    else
    	rankStr = "尚未加入联盟"        
    end    
    self._guildName:setString(rankStr)

    -- 签名
	if not data.msg or data.msg == "" then
		self._signTxt:setString("签名: 这家伙很懒，什么也没有留下")
	else
		self._signTxt:setString("签名: "..data.msg)
	end

	-- avatar
	-- print("data.avatar",data.avatar)--safecode toberemove
	-- local icon = IconUtils:createHeadIconById({avatar = data.avatar,tp = 2})
	local heroData = clone(tab:Hero(data.formation.heroId or 60001))
	heroData.star = data.hero.star
	heroData.skin = data.hero.skin

	local heroName = self:getUI("bg.info_panel.heroName")
	heroName:setString(lang(heroData.heroname))

	-- local icon = IconUtils:createHeadIconById({art = heroData.herohead,tp = 2})
    local icon = IconUtils:createHeroIconById({sysHeroData = heroData})
    icon:setScale(0.9)
    icon:setPosition(self._headFrame:getContentSize().width * 0.5, self._headFrame:getContentSize().height * 0.5)
    self:registerClickEvent(icon,function( )

    	local detailData = {}
    	detailData.heros = self._palyerData.hero
    	detailData.heros.heroId = self._palyerData.formation.heroId
    	if self._palyerData.globalSpecial and self._palyerData.globalSpecial ~= "" then
    		detailData.globalSpecial = self._palyerData.globalSpecial
    	end
    	detailData.level = self._palyerData.lv or self._palyerData.level
    	detailData.treasures = self._palyerData.treasures
    	detailData.hAb = self._palyerData.hAb
    	detailData.talentData = self._palyerData.talentData or self._palyerData.talent
        detailData.uMastery = self._palyerData.uMastery
        detailData.hSkin = self._palyerData.hSkin
        detailData.spTalent = self._palyerData.spTalent
		ViewManager:getInstance():showDialog("rank.RankHeroDetailView", {data=detailData}, true)
    	-- ViewManager:getInstance():showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeArenaHero, iconId = data.hero.heroId}, true)
    end)
	self._headFrame:addChild(icon)
	local x,y = 0,0
	local offsetx,offsety = 10,6
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
	-- 上阵weaponId	
	local formationData = data.formation
	self._weaponId = {}
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
function DialogPVEUserInfo:createTeams( x,y,teamId,teamData )
	-- dump(teamData)
	local teamD = tab:Team(teamId)
	local _,changeId = TeamUtils.changeArtForHeroMasteryByData(self._palyerData.hero,self._palyerData.formation.heroId,teamId)
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
    	ViewManager:getInstance():showDialog("rank.RankTeamDetailView", {data=detailData}, true)


    	-- ViewManager:getInstance():showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeArenaTeam, iconId = teamId}, true)
    end})
    return teamIcon
end

function DialogPVEUserInfo:createGrid(x,y,isLocked)
	local bagGrid = ccui.Widget:create()
    bagGrid:setContentSize(cc.size(107,107))
    bagGrid:setAnchorPoint(cc.p(0,0))

    local bagGridFrame = ccui.ImageView:create()
    bagGridFrame:loadTexture("globalImageUI4_squality1.png", 1)
    bagGridFrame:setName("bagGridFrame")
    bagGridFrame:setAnchorPoint(cc.p(0,0))
    bagGridFrame:setContentSize(cc.size(107, 107))
    bagGridFrame:ignoreContentAdaptWithSize(false)
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

function DialogPVEUserInfo:initWeaponsPanel(weaponPanel,weaponsData)
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

function DialogPVEUserInfo:clickChatEvent( ... )
	local chatModel = self._modelMgr:getModel("ChatModel")
    local isPriOpen, tipDes = chatModel:isPirChatOpen()
    if isPriOpen == false then
        self._viewMgr:showTip(tipDes)
        return
    end
	
	if self._palyerData and self._palyerData.rid then
		local friendModel = self._modelMgr:getModel("FriendModel")
        if friendModel:checkIsBlack(self._palyerData.rid) then
            self._viewMgr:showTip("玩家在黑名单列表中，不能进行私聊")
            return
        end

		self._serverMgr:sendMsg("UserServer", "getTargetUser", {rid = self._palyerData.rid}, true, {}, function (result)
	        if result and next(result) ~= nil and string.sub(result.rid,1,5) ~= "arena" then
	        	self._viewMgr:showDialog("chat.ChatPrivateView", {userData = result, viewtType = "pri"}, true)
	        else
	        	print("============返回数据为空或者rid为nil-==========")
	        end
	    end)
	else
		print("============数据为空或者rid为nil-==========")
	end
end
function DialogPVEUserInfo:addFriendEvent( ... )	
	self._friendModel = self._modelMgr:getModel("FriendModel")
        -- dump(self._palyerData,'result')
        -- print("========================self._userData[usid]==",self._palyerData.usid)
        if self._palyerData.usid == nil then
            self._viewMgr:showTip("usid为空")
            return
        end
        -- print("================self._palyerData.usid==",self._palyerData.usid)
        if self._friendModel:checkIsFriend(self._palyerData.usid) then
            self._viewMgr:showTip("已在好友列表中")
            return
        end
        if self._friendModel:checkIsBlack(self._palyerData.usid) then
            self._viewMgr:showTip("已在黑名单列表中")
            return
        end
        self._serverMgr:sendMsg("GameFriendServer", "applyGameFriend", {usid = self._palyerData.usid}, true, {}, function (result)
			self._viewMgr:showTip(lang("TIPS_ARENA_11"))
            self._modelMgr:getModel("FriendModel"):applyAddFriend(self._palyerData.usid)
        end)

end
function DialogPVEUserInfo.dtor()
	-- body
	NewFormationIconView = nil
end

return DialogPVEUserInfo