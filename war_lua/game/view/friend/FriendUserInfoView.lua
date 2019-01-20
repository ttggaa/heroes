--[[
    Filename:    FriendUserInfoView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2016-07-26 16:58
    Description: 好友用户信息界面
--]]

local FriendUserInfoView = class("FriendUserInfoView", BasePopView)

function FriendUserInfoView:ctor(param)
	FriendUserInfoView.super.ctor(self)
	require("game.view.friend.FriendConst")
	self._userModel = self._modelMgr:getModel("UserModel"):getData()
	self._friendModel = self._modelMgr:getModel("FriendModel")

    -- dump(param, "user", 10)
	self._userData = param.data
	self._fsec = param.fsec
    self._type = param.viewType
    self._callback = param.callback
end

function FriendUserInfoView:onInit()
	self._titleLab = self:getUI("bg.bg3._titlebg.Label_35")  
    UIUtils:setTitleFormat(self._titleLab, 1)

    --closeBtn
	self:registerClickEventByName("bg.bg3.closeBtn", function ()
		self:close()
        UIUtils:reloadLuaFile("friend.FriendUserInfoView")
	end)

	--chatBtn
	self._chatBtn = self:getUI("bg.bg3.friendBtnNode.chatBtn")
	self:registerClickEventByName("bg.bg3.friendBtnNode.chatBtn", function ()
		self:openPriChatView()
	end)

    --delete
	self:registerClickEventByName("bg.bg3.friendBtnNode.deleteBtn", function ()
		self._friendModel:setDeleteUsid(self._userData["usid"])
		local delUsic = self._friendModel:getDeleteUsid()
		self._serverMgr:sendMsg("GameFriendServer", "deleteGameFriend", {id = self._userModel["_id"], usid = json.encode({usid = delUsic})}, true, {}, function(result)
	   			self._viewMgr:showTip("成功删除1个好友")
	   			self._friendModel:setDeleteUsid()
	   			if self._callback then
		    		self._callback()
		    	end
		    	self:close()
	    end)
	end)

	--rejectBtn   --改为发起私聊
	self:registerClickEventByName("bg.bg3.addBtnNode.rejectBtn", function ()
		self:openPriChatView()
	end)

	--agreeBtn
	self:registerClickEventByName("bg.bg3.addBtnNode.agreeBtn", function ()
		self._serverMgr:sendMsg("GameFriendServer", "acceptGameFriend", {id = self._userModel["_id"], usid = self._userData["usid"], accept = 1}, true, {}, function(result)
	    	self._friendModel:dealfriendApply(self._userData["usid"], 1)
	    	if self._callback then
	    		self._callback()
	    	end
	    	self:close()
		end)
	end)

	--chatBtn
    self._chatBtn = self:getUI("bg.bg3.applyBtnNode.chatBtn")
    self:registerClickEventByName("bg.bg3.applyBtnNode.chatBtn", function ()
        self:openPriChatView()
    end)

    -- fightBtn 好友切磋
    self._fightBtn = self:getUI("bg.bg3.fightBtn")
    self:registerClickEventByName("bg.bg3.fightBtn", function ()
        self:onFightFriend()
    end)
    if self._fightBtn then
        local _,_,arenaOpenLv = SystemUtils:enableArena()
        self._fightBtn:setVisible(self._userData.lv >= arenaOpenLv)
        self._fightBtn:setTitleFontSize(20)
    end

    --apply
	self._applyBtn = self:getUI("bg.bg3.applyBtnNode.applyBtn")
	self:registerClickEvent(self._applyBtn, function ()
		self._serverMgr:sendMsg("GameFriendServer", "applyGameFriend", {usid = self._userData["usid"]}, true, {}, function(result)
	    	self._friendModel:applyAddFriend(self._userData["usid"])
	    	if self._callback then
	    		self._callback()
	    	end
	    	self:close()
		end)
	end)
    -- 加好友按钮 不做灰化处理 hgf
	-- if self._friendModel:checkIsApply(self._userData["usid"]) then
	-- 	-- self._applyBtn:setTitleText("已申请")
	-- 	self._applyBtn:setSaturation(-180)
	-- 	self._applyBtn:setTouchEnabled(false)
	-- end

	self:refreshUpUI()
	self:refreshBtns()
	self:initInfoPanel()
end

function FriendUserInfoView:openPriChatView()
    local chatModel = self._modelMgr:getModel("ChatModel")
    local isPriOpen, tipDes = chatModel:isPirChatOpen()
    if isPriOpen == false then
        self._viewMgr:showTip(tipDes)
        return
    end
    
	self._serverMgr:sendMsg("UserServer", "getTargetUser", {rid = self._userData["rid"]}, true, {}, function (result)
        if result and next(result) ~= nil then
        	local limitLevel = tonumber(tab.systemOpen["Chat"][1])
		    if self._userData["lv"] < limitLevel then 
		        self._viewMgr:showTip(lang("CHAT_SYSTEM_LVLIMIT"))
		    else
		        self._viewMgr:showDialog("chat.ChatPrivateView", {userData = result, viewtType = "pri"}, true)
        		self:close()
		    end
        end
    end)
end 

function FriendUserInfoView:refreshBtns()
	local friBtnNode = self:getUI("bg.bg3.friendBtnNode")
	local addBtnNode = self:getUI("bg.bg3.addBtnNode")
	local applyBtnNode = self:getUI("bg.bg3.applyBtnNode")
	friBtnNode:setVisible(false)
	friBtnNode:setSwallowTouches(false)
	addBtnNode:setVisible(false)
	addBtnNode:setSwallowTouches(false)
	applyBtnNode:setVisible(false)
	applyBtnNode:setSwallowTouches(false)

    local bg1 = self:getUI("bg.bg1")
    bg1:setVisible(false)
    local bg2 = self:getUI("bg.bg2")
    bg2:setVisible(true)
    local bg3 = self:getUI("bg.bg3")
    bg3:setPosition(bg2:getPosition())

    if self._type == FriendConst.FRIEND_TYPE.PLATFORM then
        bg1:setVisible(true)
        bg2:setVisible(false)
        bg3:setPosition(bg1:getPositionX(), bg1:getPositionY() - 34)

        if self._fightBtn and self._userData.rid == self._userModel["_id"] then
            self._fightBtn:setVisible(false)
        end
	elseif self._type == FriendConst.FRIEND_TYPE.FRIEND then
		friBtnNode:setVisible(true)
	elseif self._type == FriendConst.FRIEND_TYPE.ADD then
		addBtnNode:setVisible(true)
        if self._fightBtn then
            self._fightBtn:setVisible(false)
        end
	elseif self._type == FriendConst.FRIEND_TYPE.APPLY then
		applyBtnNode:setVisible(true)
        if self._fightBtn then
            self._fightBtn:setVisible(false)
        end
	end
end

function FriendUserInfoView:refreshUpUI()
	if self._userData == nil then
		return
	end
		
	self._upNode = self:getUI("bg.bg3.Panel_20")

	--headIcon
    local headP = {avatar = self._userData["avatar"],level = self._userData["lv"] or 0, tp = 4,
                    avatarFrame = self._userData["avatarFrame"], tencetTp = self._userData["qqVip"], plvl = self._userData["plvl"]}
	self._avatar = IconUtils:createHeadIconById(headP) 
    self._avatar:setAnchorPoint(0, 0)
    self._avatar:setPosition(0, 63)
    self._upNode:addChild(self._avatar, 2)
    
    --name
    self._nameLab = self:getUI("bg.bg3.Panel_20.name")
    self._nameLab:setString(self._userData["name"])
    self._nameLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    self._nameLab:setFontSize(24)
   
   	-- vip
    local vipLabel = cc.Label:createWithBMFont(UIUtils.bmfName_vip, "v" .. (self._userData.vipLvl or 0))
    vipLabel:setName("vipLabel")
    vipLabel:setAnchorPoint(cc.p(0, 0.5))
    vipLabel:setPosition(math.max(105 + self._nameLab:getContentSize().width + 20, 165) , self._nameLab:getPositionY())
    self._nameLab:getParent():addChild(vipLabel, 2)
    local isHideVip = UIUtils:isHideVip(self._userData.hideVip,"userInfo")
    if self._userData.vipLvl == 0 or isHideVip then
        vipLabel:setVisible(false)
    end

    --nameBg
    self._nameBg = self:getUI("bg.bg3.Panel_20.nameBg")
    local nameWidth = self._nameLab:getContentSize().width + 10 + vipLabel:getContentSize().width
    self._nameBg:setContentSize(nameWidth < 115 and 192 or (nameWidth + 100) , 34)

    --USID
    -- self._uidLab = self:getUI("bg.bg3.Panel_20.uidLab")
    -- self._uidLab:setString("UID:" .. self._userData["usid"])

    --fightScore
    self._fightScore = self:getUI("bg.bg3.Panel_20.fightScore")
    self._fightScore:setFntFile(UIUtils.bmfName_zhandouli_little)
    self._fightScore:setString("a" .. (self._userData.hScore or 0))--最高战力
    self._fightScore:setScale(0.5)
    self._fightScore:setPosition(self._fightScore:getPositionX() - 1, 80)
       
    --guildName / login
    local guildLab = self:getUI("bg.bg3.Panel_20.guild")
    local guildName = self:getUI("bg.bg3.Panel_20.guildName")
    guildLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    guildName:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    if self._type == FriendConst.FRIEND_TYPE.PLATFORM then
        guildLab:setString("登录：")
        local disNum = self._modelMgr:getModel("UserModel"):getCurServerTime() - (self._userData["lt"] or 0)
        if self._userData["online"] and self._userData["online"] == 1 then
            guildName:setString("在线")
            guildName:setColor(cc.c4b(63, 125, 0, 255))
        else
            guildName:setString(TimeUtils:getTimeDisByFormat(disNum) .. "前")
        end  
    else
        guildLab:setString("联盟：")
        local str = self._userData.guildName
        if not str or str == "" then
            str = "尚未加入联盟"
        end
        guildName:setString(str)
    end
    

    --sign
    self._signLab = self:getUI("bg.bg3.Panel_20.signLab")
	if not self._userData["msg"] or self._userData["msg"] == "" then
		self._signLab:setString("签名: 这家伙很懒，什么也没有留下")
	else
		self._signLab:setString("签名: "..self._userData["msg"])
	end

    --游戏启动中心
    local gameCenter = self:getUI("bg.bg3.Panel_20.gCenterBtn")
    if not GameStatic.appleExamine and self._userData["tequan"] and self._modelMgr:getModel("TencentPrivilegeModel"):isOpenPrivilege() then 
        gameCenter:setVisible(true) 
        local tequanImg = FriendConst.TEQUAN_TYPE[self._userData["tequan"]] or "globalImageUI6_meiyoutu.png"
        gameCenter:loadTextures(tequanImg, tequanImg, tequanImg, 1)
        self:registerClickEvent(gameCenter,function( )
            self._viewMgr:showDialog("tencentprivilege.TencentPrivilegeView")
        end) 
    else
        gameCenter:setVisible(false)  
    end

    self:getUI("bg.bg3.Panel_20.realNameBtn"):setVisible(GameStatic.is_show_realName)
end

-- 初始化英雄兵团信息  hgf
function FriendUserInfoView:initInfoPanel()

    self._scrollView = self:getUI("bg.bg3.infoBg.scrollView")
    
    -- 英雄静态数据
    local heroData = clone(tab:Hero(self._userData.formation.heroId or 60001))
    heroData.star = self._userData.hero.star
    heroData.skin = self._userData.hero.skin

    -- 英雄名字
    local heroName = self:getUI("bg.bg3.infoBg.heroBg.heroName")
    heroName:setString(lang(heroData.heroname))
    --英雄头像
    local heroFrame = self:getUI("bg.bg3.infoBg.heroBg.heroFrame")
    local icon = IconUtils:createHeroIconById({sysHeroData = heroData})
    icon:setScale(0.9)
    icon:setPosition(heroFrame:getContentSize().width * 0.5, heroFrame:getContentSize().height * 0.5+2)
    self:registerClickEvent(icon,function( )
        local detailData = {}
        detailData.heros = self._userData.hero
        detailData.heros.heroId = self._userData.formation.heroId
        if self._userData.globalSpecial and self._userData.globalSpecial ~= "" then
            detailData.globalSpecial = self._userData.globalSpecial
        end
        detailData.level = self._userData.lv 
        detailData.treasures = self._userData.treasures
        detailData.hAb = self._userData.hAb
        detailData.talentData = self._userData.talentData or self._userData.talent
        detailData.uMastery = self._userData.uMastery
        detailData.hSkin = self._userData.hSkin
        detailData.spTalent = self._userData.spTalent
        detailData.backups = self._userData.backups
        detailData.pTalents = self._userData.pTalents
        ViewManager:getInstance():showDialog("rank.RankHeroDetailView", {data=detailData}, true)
    end)
    heroFrame:addChild(icon)

    -- team
    local x,y = 0,0
    local offsetx,offsety = 10,10
    local row,col = 2,4
    local iconSize = 93
    local boardHeight = self._scrollView:getContentSize().height
    local idx = 1
    local item 
    for teamId,team in pairs(self._userData.teams) do
        x = (idx-1)%col*iconSize+offsetx
        y = boardHeight- (math.floor((idx-1)/col+1)*iconSize)+offsety
        team.teamId = tonumber(teamId)
        item = self:createTeams(x,y,tonumber(teamId),team)
        idx=idx+1        
        item:setScale(0.73)
        item:setPosition(cc.p(x,y))
        self._scrollView:addChild(item)
    end
    -- 最大上着兵团数
    local teamMaxNum = tab:UserLevel(tonumber(self._userData.lv or self._userData.level)).num
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
    local formationData = self._userData.formation
    self._weaponId = {}     -- 上阵weaponId  
    local weaponId
    for i=1,3 do
        weaponId = formationData["weapon"..i]
        if weaponId and weaponId ~= 0 then 
            table.insert(self._weaponId,weaponId)
        end
    end

    local weaponPanel = self:getUI("bg.bg3.infoBg.weaponPanel")
    if #self._weaponId > 0 then 
        local weaponsData = self._userData.weapons
        weaponPanel:setVisible(true)
        self:initWeaponsPanel(weaponPanel,weaponsData)
        heroName:setVisible(false)
    else
        weaponPanel:setVisible(false)
        heroName:setVisible(true)     
    end 

    local btn_backup = self:getUI("bg.bg3.infoBg.btn_backup")
    btn_backup:setVisible(false)
    local formationData = self._userData.formation or {}
    local bid = formationData.bid
    local backupData = formationData.backupTs or {}
    local bidData = clone(backupData[tostring(bid)])

    if bid and bidData then
        local helpTeams = self._userData.helpTeams or {}
        local teams = self._userData.teams or {}
        for i = 1, 3 do
            local teamId = bidData["bt" .. i]
            if teamId and teamId ~= 0 then
                local teamData = helpTeams[tostring(teamId)]
                if teamData == nil then
                    teamData = teams[tostring(teamId)]
                end
                bidData["btData" .. i] = clone(teamData)
            end
        end
        local growBackups = self._userData.backups or {}
        local growData = growBackups[tostring(bid)] or {}
        btn_backup:setVisible(true)
        self:registerClickEvent(btn_backup, function( )
            self._viewMgr:showDialog("backup.BackupUserInfoDialog",  {bid = bid, bidData = bidData, growData = growData, playerData = self._userData})
        end)
    end
end

--创建兵团头像  hgf
function FriendUserInfoView:createTeams( x,y,teamId,teamData )

    local teamD = tab:Team(teamId)
    local _,changeId = TeamUtils.changeArtForHeroMasteryByData(self._userData.hero,self._userData.formation.heroId,teamId)
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
        detailData.pokedex = self._userData.pokedex 
        detailData.treasures = self._userData.treasures
        detailData.runes = self._userData.runes
        detailData.heros = self._userData.heros
        detailData.battleArray = self._userData.battleArray
        detailData.pTalents = self._userData.pTalents
        ViewManager:getInstance():showDialog("rank.RankTeamDetailView", {data=detailData}, true)
    end})
    return teamIcon
end

-- 创建空格子 hgf
function FriendUserInfoView:createGrid(x,y,isLocked)
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
-- 添加器械信息
function FriendUserInfoView:initWeaponsPanel(weaponPanel,weaponsData)
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

-- 好友切磋功能 by guojun 2017.3.25
function FriendUserInfoView:onFightFriend( )
    -- dump(self._userData,"userData")
    local detailCallback = function( result,isPlat )
        local info = result.info
        if not info.battle or not info.battle.formation then
            self._viewMgr:showTip("对方尚未在竞技场布阵，无法切磋")
            return 
        end
        info.battle.msg = info.msg
        info.battle.rank = info.rank
        local enemyFormation = clone(info.battle.formation)
        enemyFormation.filter = ""
         -- 给布阵传递数据
        self._modelMgr:getModel("ArenaModel"):setEnemyData(info.battle.teams)
        self._modelMgr:getModel("ArenaModel"):setEnemyHeroData(info.battle.hero)

        local formationType = self._modelMgr:getModel("FormationModel").kFormationTypeArena
        self._viewMgr:showView("formation.NewFormationView", {
            formationType = formationType,
            enemyFormationData = {[formationType] = enemyFormation},
            callback = function(leftData)
                -- 实质上还是播战报
                local enemyRid  = self._userData.rid 
                if enemyRid and enemyRid ~= "" then
                    local competeMethod = isPlat and "platCompete" or "compete"
                    self._serverMgr:sendMsg("GameFriendServer", competeMethod, {rid = self._userModel["_id"], fid = enemyRid,tSec = self._fsec}, true, {}, function(result)
                        dump(result,"获得详情。。。")
                        if result then
                            self._battleKey = result
                            self._serverMgr:sendMsg("BattleServer","getBattleReport",{reportKey = result},true,{},function( result1 )
                                self:enterFriendBattle(result1)
                            end)
                        end
                    end)
                end
            end,
        })
    end
    -- 调用布阵界面
    if self._type == FriendConst.FRIEND_TYPE.PLATFORM then
        self._serverMgr:sendMsg("ArenaServer", "getDetailInfoCross", {roleId = self._userData.rid,tSec = self._fsec}, true, {}, function(result) 
            detailCallback(result,true)
        end)
    else
        self._serverMgr:sendMsg("ArenaServer", "getDetailInfo", {roleId = self._userData.rid}, true, {}, function(result) 
            detailCallback(result)
        end)
    end
    
end

-- 站前组合数据
function FriendUserInfoView:enterFriendBattle( result )
    local left 
    local right 
    left  = BattleUtils.jsonData2lua_battleData(result.atk)
    right = BattleUtils.jsonData2lua_battleData(result.def)
    -- BattleUtils.disableSRData()
    -- 关闭布阵
    self._viewMgr:popView()
    BattleUtils.enterBattleView_Arena( left, right, result.r1, result.r2, 3, false,
    function (info, callback)
        info.friendBattleCallback = function(  )
            -- todo 切磋分享给好友
            ScheduleMgr:delayCall(100, self, function( )
                DialogUtils.showShowSelect({desc = lang("FRIEND_PKTIPS") or "是否发送战斗结果给好友？",callback1 = function( )
                    local param1 = {
                        reportInfo = {reportKey = result._id,tSec = GameStatic.sec},
                        toData = self._userData,
                        toID = self._userData.rid,
                        sec = self._fsec,
                    }

                    local _, isInfoBanned, sendData = self._modelMgr:getModel("ChatModel"):paramHandle("priReport", param1)
                    if isInfoBanned == true then
                        self._chatModel:pushData(sendData)
                    else
                        self._serverMgr:sendMsg("ChatServer", "sendPriMessage", sendData, true, {}, function (result)

                        end)  
                    end
                end})
            end)
        end
        -- dump(info)
        -- 战斗结束
        callback(info)
    end,
    function (info)
        -- 退出战斗
    end)
end

return FriendUserInfoView
