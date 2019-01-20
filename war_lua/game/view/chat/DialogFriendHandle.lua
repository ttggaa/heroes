--[[
    Filename:    DialogFriendHandle.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2016-05-20 17:19
    Description: 私聊进入玩家详细界面
--]]

local DialogFriendHandle = class("DialogFriendHandle",BasePopView)

function DialogFriendHandle:ctor(data)
    self.super.ctor(self)
    self._currData = data
    self.callBack = data.callback
    self._openType = data.openType
    self._isFakeNpc = data.isFakeNpc
    self._detailData = data.detailData or {}
    self._uiData = data.uiData or {}
    if self._currData.uiData and self._currData.uiData.message and self._currData.uiData.message.udata then
        self._uiData = self._currData.uiData.message.udata
    end
    
    self._friendModel = self._modelMgr:getModel("FriendModel")
    self._chatModel = self._modelMgr:getModel("ChatModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._guildModel = self._modelMgr:getModel("GuildModel")
    -- dump(self._uiData, "userData", 10)
    -- dump(self._detailData, "userData", 10)
end

function DialogFriendHandle:onInit()
	self._privateBtn = self:getUI("bg.privateBtn")
	self._shieldBtn = self:getUI("bg.shieldBtn")
	self._addBtn = self:getUI("bg.addBtn")
	self._zhaomuBtn = self:getUI("bg.zhaomuBtn")
   
	self._closeBtn = self:getUI("bg.closeBtn")
	self._bg1 = self:getUI("bg.bg1")
    self._titleLab = self:getUI("bg._titlebg.Label_35")
    UIUtils:setTitleFormat(self._titleLab, 1)

    --按钮显隐
    self:setBtnState()
    --上部UI
	self:showUpUI()   
    -- 初始化英雄兵团信息
    self:initInfoPanel()

	self:registerClickEvent(self._closeBtn, function()
			self:close()
            UIUtils:reloadLuaFile("chat.DialogFriendHandle")
		end) 

	self:registerClickEvent(self._privateBtn, function()
        self:privateBtnFunc()
    end)
    	
	self:registerClickEvent(self._shieldBtn, function()
        self:shieldBtnFunc()
		end)

	self:registerClickEvent(self._addBtn, function()
        self:addBtnFunc()	
		end)

	self:registerClickEvent(self._zhaomuBtn, function()
        self:zhaomuBtnFunc()
		end)
end

function DialogFriendHandle:setBtnState()
    local bg = self:getUI("bg")
    local wid, hei = bg:getContentSize().width, bg:getContentSize().height
    
    local btnPosX = {
        [1] = {wid * 0.5}, 
        [2] = {wid * 0.5 - 100, wid * 0.5 + 100},
        [3] = {wid * 0.5 - 180, wid * 0.5, wid * 0.5 + 180}}

    local showBtns = {}
    self._privateBtn:setVisible(false)
    self._shieldBtn:setVisible(false)
    self._addBtn:setVisible(false)
    self._zhaomuBtn:setVisible(false)
    
    local guildId = self._userModel:getData().guildId
    local secId = self._userModel:getData().sec

    --屏蔽
    if not self._uiData["sec"] or self._uiData["sec"] == secId then
        table.insert(showBtns, self._shieldBtn)
    end

    --联盟招募 自己有联盟而对方没有
    if not self._uiData["sec"] or self._uiData["sec"] == secId and self._openType == "private" and guildId and guildId ~= 0 and 
        (not self._detailData.guildName or self._detailData.guildName == "") then
        table.insert(showBtns, self._zhaomuBtn)
    end

    --私聊
    if self._openType ~= "private" then
        table.insert(showBtns, self._privateBtn)
    end

    --加好友
    if not self._uiData["sec"] or self._uiData["sec"] == secId then
        table.insert(showBtns, self._addBtn)
    end

    for i,v in ipairs(showBtns) do
        v:setVisible(true)
        v:setPositionX(btnPosX[#showBtns][i])
    end
end

--初始化上部UI数据
function DialogFriendHandle:showUpUI()
	if self._currData == nil then
		return
	end
	
	--headIcon
    local headP = {avatar = self._detailData.avatar,level = self._detailData.lv or 0, tp = 4,avatarFrame=self._detailData["avatarFrame"], plvl = self._detailData.plvl}
	self._avatar = IconUtils:createHeadIconById(headP) 
    self._avatar:setAnchorPoint(0, 0.5)
    self._avatar:setPosition(0, self._bg1:getContentSize().height/2+8)
    self._bg1:addChild(self._avatar, 2)
    
    --name
    self._nameLab = ccui.Text:create()
    self._nameLab:setFontName(UIUtils.ttfName)
    self._nameLab:setFontSize(24)
    self._nameLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    self._nameLab:setAnchorPoint(0, 1)
    self._nameLab:setPosition(105, 100) 
    self._nameLab:setString(self._detailData.name)
    self._bg1:addChild(self._nameLab, 2)

    -- vip
    local vipLabel = cc.Label:createWithBMFont(UIUtils.bmfName_vip, "v" .. (self._detailData.vipLvl or 0))
    vipLabel:setName("vipLabel")
    vipLabel:setAnchorPoint(cc.p(0, 1))
    vipLabel:setPosition(105 + self._nameLab:getContentSize().width+10 , 100)
    self._bg1:addChild(vipLabel, 2)
    local isHideVip = UIUtils:isHideVip(self._detailData.hideVip,"userInfo")
    if not self._detailData.vipLvl or self._detailData.vipLvl == 0 or isHideVip == true then
        vipLabel:setVisible(false)
    end

    --nameBg
    self._nameBg = cc.Scale9Sprite:createWithSpriteFrameName("globalPanelUI7_subInner2TitleBg.png")
    self._nameBg:setAnchorPoint(0, 0)
    self._nameBg:setCapInsets(cc.rect(19, 16, 1, 1))
    self._nameBg:setPosition(45 , 68)

    --属性
    self._guildDes = cc.Label:createWithTTF("", UIUtils.ttfName, 22)
    self._guildDes:setAnchorPoint(0, 1)
    self._guildDes:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    self._guildDes:setPosition(105, 68)      
    self._guildDes:setString("联盟：")    
    self._bg1:addChild(self._guildDes)

    self._guildLab = cc.Label:createWithTTF("", UIUtils.ttfName, 22)
    self._guildLab:setAnchorPoint(0, 1)
    self._guildLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    self._guildLab:setPosition(self._guildDes:getPositionX()+self._guildDes:getContentSize().width, 69)  
    
    local rankStr =  ""
    if self._detailData.guildMapName and self._detailData.guildMapName ~= "" then        
        rankStr = self._detailData.guildMapName
    elseif self._detailData.guildName and self._detailData.guildName ~= "" then        
        rankStr = self._detailData.guildName
    else
        rankStr = "尚未加入联盟"        
    end   
    self._guildLab:setString(rankStr)
    self._bg1:addChild(self._guildLab)

    -- 显示最高战力
    local score = self._detailData.hScore or self._detailData.score
    local fightLabel = cc.Label:createWithBMFont(UIUtils.bmfName_zhandouli_little, "a" .. (score or 0))
    fightLabel:setName("fightLabel")
    fightLabel:setScale(0.5)
    fightLabel:setAnchorPoint(cc.p(0, 1))
    fightLabel:setPosition(cc.p(105, 40))
    self._bg1:addChild(fightLabel, 2)
end

-- 初始化英雄兵团信息  hgf
function DialogFriendHandle:initInfoPanel()
    if not self._detailData.formation then 
        self._detailData.formation = {}
    end
    self._scrollView = self:getUI("bg.infoBg.scrollView")
    self._signTxt = self:getUI("bg.signBg.signTxt")

    -- 签名
    if not self._detailData.msg or self._detailData.msg == "" then
        self._signTxt:setString("签名: 这家伙很懒，什么也没有留下")
    else
        self._signTxt:setString("签名: "..self._detailData.msg)
    end
    -- 英雄静态数据
    local heroData = clone(tab:Hero(self._detailData.formation.heroId or 60001))
    heroData.star = self._detailData.hero.star
    heroData.skin = self._detailData.hero.skin

    -- 英雄名字
    local heroName = self:getUI("bg.infoBg.heroBg.heroName")
    heroName:setString(lang(heroData.heroname))
    --英雄头像
    local heroFrame = self:getUI("bg.infoBg.heroBg.heroFrame")
    local icon = IconUtils:createHeroIconById({sysHeroData = heroData})
    icon:setScale(0.9)
    icon:setPosition(heroFrame:getContentSize().width * 0.5, heroFrame:getContentSize().height * 0.5)
    self:registerClickEvent(icon,function( )
        local detailData = {}
        detailData.heros = self._detailData.hero
        detailData.heros.heroId = self._detailData.formation.heroId
        if self._detailData.globalSpecial and self._detailData.globalSpecial ~= "" then
            detailData.globalSpecial = self._detailData.globalSpecial
        end
        detailData.level = self._detailData.lv 
        detailData.treasures = self._detailData.treasures
        detailData.hAb = self._detailData.hAb
        detailData.talentData = self._detailData.talentData or self._detailData.talent
        detailData.uMastery = self._detailData.uMastery
        detailData.hSkin = self._detailData.hSkin
        detailData.backups = self._detailData.backups
        detailData.pTalents = self._detailData.pTalents
        ViewManager:getInstance():showDialog("rank.RankHeroDetailView", {data=detailData}, true)
    end)
    heroFrame:addChild(icon)

    -- team
    local x,y = 0,0
    local offsetx,offsety = 10,8
    local row,col = 2,4
    local iconSize = 93
    local boardHeight = self._scrollView:getContentSize().height
    local idx = 1
    local item 
    for teamId,team in pairs(self._detailData.teams) do
        x = (idx-1)%col*iconSize+offsetx
        y = boardHeight- (math.floor((idx-1)/col+1)*iconSize)+offsety
        team.teamId = tonumber(teamId)
        item = self:createTeams(x,y,tonumber(teamId),team)
        idx=idx+1
        item:setScale(0.73)
        item:setPosition(x,y)
        self._scrollView:addChild(item)
    end
    -- 最大上着兵团数
    local teamMaxNum = tab:UserLevel(tonumber(self._detailData.lv or self._detailData.level)).num
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
        item:setPosition(x,y)
        self._scrollView:addChild(item)
    end

    -- weapon信息展示
    local formationData = self._detailData.formation
    self._weaponId = {}
    local weaponId
    for i=1,3 do
        weaponId = formationData["weapon"..i]
        if weaponId and weaponId ~= 0 then 
            table.insert(self._weaponId,weaponId)
        end
    end

    local weaponPanel = self:getUI("bg.infoBg.weaponPanel")
    if #self._weaponId > 0 then 
        local weaponsData = self._detailData.weapons
        weaponPanel:setVisible(true)
        self:initWeaponsPanel(weaponPanel,weaponsData)
        heroName:setVisible(false)
    else
        weaponPanel:setVisible(false)
        heroName:setVisible(true)     
    end
end

--创建兵团头像  hgf
function DialogFriendHandle:createTeams( x,y,teamId,teamData )

    local teamD = tab:Team(teamId)
    local _,changeId = TeamUtils.changeArtForHeroMasteryByData(self._detailData.hero,self._detailData.formation.heroId,teamId)
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
        detailData.pokedex = self._detailData.pokedex 
        detailData.treasures = self._detailData.treasures
        detailData.runes = self._detailData.runes
        detailData.heros = self._detailData.heros
        detailData.battleArray = self._detailData.battleArray
        detailData.pTalents = self._detailData.pTalents
        ViewManager:getInstance():showDialog("rank.RankTeamDetailView", {data=detailData}, true)
    end})
    return teamIcon
end

-- 创建空格子 hgf
function DialogFriendHandle:createGrid(x,y,isLocked)
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
function DialogFriendHandle:initWeaponsPanel(weaponPanel,weaponsData)
    local weaponD = weaponsData or {}
    local weaponIDs = self._weaponId
    local x,y = 0,0
    local offsetx,offsety = 5,18
    local iconSize = 76
    local item
    
    local isOpen = true
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

function DialogFriendHandle:privateBtnFunc()
    local checkId = self._detailData["usid"] or self._detailData["rid"]
    if self._friendModel:checkIsBlack(checkId) then
        self._viewMgr:showTip("玩家在黑名单列表中，不能进行私聊")
        return
    end
    self._serverMgr:sendMsg("UserServer", "getTargetUser", {rid = self._detailData.rid, tsec = self._uiData["sec"]}, true, {}, function (result)
        self:onGetTargetUserFinish(result)
    end)
end

function DialogFriendHandle:onGetTargetUserFinish(result)
    local isPriOpen, tipDes = self._chatModel:isPirChatOpen()
    if isPriOpen == false then
        self._viewMgr:showTip(tipDes)
        return
    end

    if not result["sec"] then
        result["sec"] = self._uiData["sec"]
    end
    if not result["plvl"] then
        result["plvl"] = self._detailData["plvl"] or self._uiData["plvl"]
    end
    self._viewMgr:showDialog("chat.ChatPrivateView", {userData = result, oldUI = self._currData.oldUI, viewtType = "pri", isHasLoadAsy = true}, true)
    self:close(false)
end

function DialogFriendHandle:shieldBtnFunc()
    local friendModel = self._modelMgr:getModel("FriendModel")
    local isFriOpen, tipDes = friendModel:isFriendOpen()
    if isFriOpen == false then
        self._viewMgr:showTip(tipDes)
        return
    end

    if self._detailData["usid"] == nil then
        self._viewMgr:showTip("id不能为空")
        return
    end
    if self._friendModel:checkIsBlack(self._detailData["rid"]) then
        self._viewMgr:showTip("已在黑名单列表中")
        return
    end
    local function shieldFunc(inData)
        self._shieldBtn:setSaturation(-180)
        self._shieldBtn:setTouchEnabled(false)
        self._shieldBtn:setTitleText("已屏蔽")
        self._viewMgr:showTip("已加入黑名单")
        self._modelMgr:getModel("FriendModel"):addFriendToBlack(inData)
    end

    if self._isFakeNpc == true then
        self._detailData["isFakeNpc"] = true
        shieldFunc(self._detailData)

        if self.callBack and self.callBack["shieldBtn"] then        --私聊调界面方法删除
            self.callBack["shieldBtn"]()
        end
    else
        self._serverMgr:sendMsg("GameFriendServer", "addBlackList", {usid = self._detailData["usid"]}, true, {}, function (result)
            -- dump(result, "123", 10)
            shieldFunc(result["d"])
            if self._openType == "private" then
                if self.callBack and self.callBack["shieldBtn"] then        --私聊调界面方法删除
                    self.callBack["shieldBtn"]()
                end
            else
                self._chatModel:removeBlackChatUser(self._detailData["rid"], true, true, true, true)
            end
        end)
    end
end

function DialogFriendHandle:addBtnFunc()
    local friendModel = self._modelMgr:getModel("FriendModel")
    local isFriOpen, tipDes = friendModel:isFriendOpen()
    if isFriOpen == false then
        self._viewMgr:showTip(tipDes)
        return
    end

    if self._detailData["usid"] == nil then
        self._viewMgr:showTip("id不能为空")
        return
    end
    if self._friendModel:checkIsFriend(self._detailData["rid"]) then
        self._viewMgr:showTip("已在好友列表中")
        return
    end
    if self._friendModel:checkIsBlack(self._detailData["rid"]) then
        self._viewMgr:showTip("已在黑名单列表中")
        return
    end
    if self._isFakeNpc == true then
        self._viewMgr:showTip("好友申请已发送")
    else
        self._serverMgr:sendMsg("GameFriendServer", "applyGameFriend", {usid = self._detailData["usid"]}, true, {}, function (result)
            self._viewMgr:showTip("好友申请已发送")
            self._modelMgr:getModel("FriendModel"):applyAddFriend(self._detailData["usid"])
        end)    
    end
end

function DialogFriendHandle:zhaomuBtnFunc()
    local guildId = self._userModel:getData().guildId
    if not guildId or guildId == 0 then
        self._viewMgr:showTip("您已被踢出联盟！")
        return true
    end

    local flag, showTimeStr = self._guildModel:getGuildJoinCDTime()
    if flag == true then
        local allianceD = self._guildModel:getAllianceDetail()
        local param1 = {
            zhaomu = {
                guildId = allianceD.guildId or -1, 
                guildLevel = allianceD.level or 0,
                guildName = allianceD.name or "", 
                lvlimit = allianceD.lvlimit or 0}
            }

        if self._isFakeNpc == true then     --排行榜NPC
            local _, _,sendData = self._chatModel:paramHandle("fakePriZhaomu", param1)
            self._chatModel:pushData(sendData)
        else                                   
            param1.toID = self._detailData["rid"]
            local _, _,sendData = self._chatModel:paramHandle("priZhaomu", param1)
            self._serverMgr:sendMsg("ChatServer", "sendPriMessage", sendData, true, {}, function (result)  end)
            self._viewMgr:showTip(lang("GUILD_RECRUIT_TIP_1"))
        end
        
    else
        local tempStr = string.gsub(lang("GUILD_RECRUIT_TIP_2"), "{$cd}", showTimeStr)
        self._viewMgr:showTip(tempStr)
    end
end

return DialogFriendHandle