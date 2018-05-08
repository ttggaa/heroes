--[[
    Filename:    GuildPlayerDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-04-18 21:41:25
    Description: File description
--]]

-- 联盟玩家详细信息
local GuildPlayerDialog = class("GuildPlayerDialog",BasePopView)
function GuildPlayerDialog:ctor()
    self.super.ctor(self)
    -- self._itemModel = self._modelMgr:getModel("ItemModel")
end

-- 初始化UI后会调用, 有需要请覆盖5
function GuildPlayerDialog:onInit()
    local closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(closeBtn, function( )
        self:close()        
        UIUtils:reloadLuaFile("guild.dialog.GuildPlayerDialog")
    end)

    local name = self:getUI("bg.panel.name")
    UIUtils:setTitleFormat(name, 2)
    self._nameBg = self:getUI("bg.panel.Image_31")
    local fight = self:getUI("bg.panel.fight")
    fight:setScale(0.8)
    fight:setFntFile(UIUtils.bmfName_zhandouli_little)
    fight:setPosition(fight:getPositionX() - 4,fight:getPositionY() + 4)
    local vipLab = self:getUI("bg.panel.vipLab")
    vipLab:setFntFile(UIUtils.bmfName_vip)
    -- vipLab:setScale(0.8)
    -- local loginTime = self:getUI("bg.panel.loginTime")
    -- loginTime:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
    -- local contributionValue = self:getUI("bg.panel.contributionValue")
    -- contributionValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)

    -- 联盟
    self._guild = self:getUI("bg.panel.guild")
    self._guildName = self:getUI("bg.panel.guildName")
    -- self._guildName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)

    -- 签名
    self._signTxt = self:getUI("bg.signBg.signTxt")

    self._title = self:getUI("bg.title_img.title_txt")
    UIUtils:setTitleFormat(self._title, 1)

    self._desTxt = self:getUI("bg.info_panel.des_txt")
    -- self._desTxt:setFontName(UIUtils.ttfName)
    self._desTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)

    self._teamInfo = self:getUI("bg.scrollBg.team_info")
    -- self._teamInfo:setFontName(UIUtils.ttfName)
    self._teamInfo:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)

    self._level = self:getUI("bg.panel.iconBg.level")
    self._level:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)

    local addFriendcom = self:getUI("bg.guildCom.addFriend")
    addFriendcom:setTitleFontName(UIUtils.ttfName)

    local priChatcom = self:getUI("bg.guildCom.priChat")
    priChatcom:setTitleFontName(UIUtils.ttfName)

    local addFriendmgr = self:getUI("bg.guildMgr.addFriend")
    addFriendmgr:setTitleFontName(UIUtils.ttfName)

    local priChatmgr = self:getUI("bg.guildMgr.priChat")
    priChatmgr:setTitleFontName(UIUtils.ttfName)

    self._scrollView = self:getUI("bg.scrollBg.scrollView")
    self._headFrame = self:getUI("bg.info_panel.headFrame")

    self._guildMgr = self:getUI("bg.guildMgr")
    self._guildMgr:setVisible(false)

    self._guildCom = self:getUI("bg.guildCom")
    self._guildCom:setVisible(false)

end

function GuildPlayerDialog:addFriendEvent()


end

function GuildPlayerDialog:reflashUI(data)
    -- dump(data, "data =======================")
    if data == nil then
        return
    end
    -- dump(data,5,5)
    -- 联盟名字
    local guildData = self._modelMgr:getModel("GuildModel"):getAllianceDetail()
    self._guildName:setString(guildData.name)

    local detailData = data.detailData
    local dataType = data.dataType
    self._hAb = data.detailData.hAb

    -- 签名
    if not detailData.msg or detailData.msg == "" then
        self._signTxt:setString("签名: 这家伙很懒，什么也没有留下")
    else
        self._signTxt:setString("签名: "..detailData.msg)
    end

    local addFriendcom = self:getUI("bg.guildCom.addFriend")
    local priChatcom = self:getUI("bg.guildCom.priChat")

    local addFriendmgr = self:getUI("bg.guildMgr.addFriend")
    local priChatmgr = self:getUI("bg.guildMgr.priChat")
    local userid = self._modelMgr:getModel("UserModel"):getData()._id 
    if detailData.memberId == userid then
        addFriendcom:setVisible(false)
        priChatcom:setVisible(false)
        addFriendmgr:setVisible(false)
        priChatmgr:setVisible(false)
    end

    --私聊
    self:registerClickEvent(priChatcom, function()
        local friendModel = self._modelMgr:getModel("FriendModel")
        if friendModel:checkIsBlack(detailData.memberId) then
            self._viewMgr:showTip("玩家在黑名单列表中，不能进行私聊")
            return
        end
        
        local chatModel = self._modelMgr:getModel("ChatModel")
        local isPriOpen, tipDes = chatModel:isPirChatOpen()
        if isPriOpen == false then
            self._viewMgr:showTip(tipDes)
            return
        end

        self._serverMgr:sendMsg("UserServer", "getTargetUser", {rid = detailData.memberId}, true, {}, function (result)
            self._viewMgr:showDialog("chat.ChatPrivateView", {userData = result, viewtType = "pri"}, true)
        end)
    end)
    self:registerClickEvent(priChatmgr, function()
        local friendModel = self._modelMgr:getModel("FriendModel")
        if friendModel:checkIsBlack(detailData.memberId) then
            self._viewMgr:showTip("玩家在黑名单列表中，不能进行私聊")
            return
        end

        local chatModel = self._modelMgr:getModel("ChatModel")
        local isPriOpen, tipDes = chatModel:isPirChatOpen()
        if isPriOpen == false then
            self._viewMgr:showTip(tipDes)
            return
        end
        
        self._serverMgr:sendMsg("UserServer", "getTargetUser", {rid = detailData.memberId}, true, {}, function (result)
            self._viewMgr:showDialog("chat.ChatPrivateView", {userData = result, viewtType = "pri"}, true)
        end)
    end)

    -- 加好友
    self:registerClickEvent(addFriendcom, function()
        print("加好友 addFriendcom================")
        self:addFriendFunc(detailData)        
    end)
    self:registerClickEvent(addFriendmgr, function()
        print("加好友 addFriendmgr================")
        self:addFriendFunc(detailData)        
    end)

    local iconBg = self:getUI("bg.panel.iconBg")
    if iconBg then
        local tencetTp = data.detailData["qqVip"]
        local param1 = {avatar = detailData.avatar, level = detailData.lvl ,tp = 4,avatarFrame = detailData["avatarFrame"], tencetTp = tencetTp}
        local icon = iconBg:getChildByName("icon")
        if not icon then
            icon = IconUtils:createHeadIconById(param1)
            icon:setPosition(cc.p(-5,-5))
            iconBg:addChild(icon)
        else
            IconUtils:updateHeadIconByView(icon, param1)
        end
    end

    local name = self:getUI("bg.panel.name")
    name:setString(detailData.name)
    self._level:setString(detailData.lvl)
    self._level:setVisible(false)
    local fight = self:getUI("bg.panel.fight")
    fight:setString("a" .. (detailData.score or 0))
    local vipLab = self:getUI("bg.panel.vipLab")
    vipLab:setString("V" .. (detailData.vipLvl or 1))
    local isHideVip = UIUtils:isHideVip(detailData.hideVip,"userInfo")
    vipLab:setVisible( (0 ~= detailData.vipLvl) and not isHideVip )
    vipLab:setPosition(name:getPositionX() + name:getContentSize().width + 5,name:getPositionY()-4)

    local nameWidth = name:getContentSize().width+20+vipLab:getContentSize().width
    self._nameBg:setContentSize(nameWidth < 115 and 192 or nameWidth + 80, self._nameBg:getContentSize().height)
    

    -- local contributionValue = self:getUI("bg.panel.contributionValue")
    -- local des1 = self:getUI("bg.panel.des1")
    -- local des2 = self:getUI("bg.panel.des2")
    -- local className = self:getUI("bg.panel.className")
    -- local loginTime = self:getUI("bg.panel.loginTime")
   
    local gun = self:getUI("bg.guildMgr.gun")
    local hao = self:getUI("bg.guildMgr.hao")
    if dataType == 2 then       
        -- 普通显示 只加好友和私聊
        self._guildMgr:setVisible(false)
        self._guildCom:setVisible(true)

        -- des1:setString("竞技场排名:")
        -- 申请管理界面查看信息，不显示联盟，显示申请时间
        self._guild:setString("申请时间:")
        self._guildName:setString(GuildUtils:getDisTodayTime(detailData.applyTime))
        self._guildName:setPositionX(self._guild:getPositionX()+self._guild:getContentSize().width+2)
        -- contributionValue:setString(detailData.rank)

        -- self:registerClickEvent(gun, function()
        --     self:close()
        --     if data.callback then
        --         local param = {defId = detailData.memberId, type = 0}
        --         data.callback(param, data.proId)
        --     end
        -- end)
        -- self:registerClickEvent(hao, function()
        --     self:close()
        --     if data.callback then
        --         local param = {defId = detailData.memberId, type = 1}
        --         data.callback(param, data.proId)
        --     end
        -- end)
    elseif dataType == 1 then
        -- 不显示身份  by hgf
        -- if detailData.pos == 1 then
        --     className:setString("联盟长")
        --     className:setColor(cc.c3b(255,214,24))
        --     className:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
        -- elseif detailData.pos == 2 then
        --     className:setString("副联盟长")
        --     className:setColor(cc.c3b(255,214,24))
        --     className:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
        -- elseif detailData.pos == 3 then
        --     className:setString("成员")
        --     className:setColor(cc.c3b(72,210,255))
        --     className:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
        -- end

        -- contributionValue:setString(detailData.dNum)
        -- des1:setString("贡献:")
        -- des2:setString("登录:")
        local userData = self._modelMgr:getModel("UserModel"):getData()
        if userData.roleGuild then            
            local playAlliance = userData.roleGuild
            if playAlliance.pos == 1 and playAlliance.pos ~= detailData.pos and userData["_id"] ~= detailData.memberId then  
                -- local appointBtn = self:getUI("bg.guildMgr.hao")
                -- appointBtn:setVisible(false)
                self._guildMgr:setVisible(true)
                self._guildCom:setVisible(false)
            elseif playAlliance.pos == 2 and playAlliance.pos < detailData.pos and userData["_id"] ~= detailData.memberId then
                
                -- 副联盟长没有任命权限
                local appointBtn = self:getUI("bg.guildMgr.hao")
                appointBtn:setVisible(false)

                self._guildMgr:setVisible(true)
                self._guildCom:setVisible(false)
            else
                self._guildMgr:setVisible(false)
                self._guildCom:setVisible(true)
            end
        end

        -- if detailData.leaveTime and detailData.online then
        --     local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
        --     local tempTime = curServerTime - detailData.leaveTime
        --     if detailData.online == 1 then
        --         loginTime:setString("在线")
        --     else
        --         loginTime:setString(GuildUtils:getDisTodayTime(detailData.leaveTime))
        --     end
        -- end

        self:registerClickEvent(gun, function()
            self:kickMember(detailData.memberId)
            print("踢出 ================")
        end)
        self:registerClickEvent(hao, function()
            self:close()
            self._viewMgr:showDialog("guild.manager.GuildAppointDialog", {detailData = detailData})
            print("任命 ================")
        end)
    end

    -- loginTime:setPositionX(des2:getPositionX()+des2:getContentSize().width)
    -- contributionValue:setPositionX(des1:getPositionX()+des1:getContentSize().width)

    -- local userData = self._modelMgr:getModel("UserModel"):getData()
    -- if userData.roleGuild then
    --     local gun = self:getUI("bg.gun")
    --     local hao = self:getUI("bg.hao")
    --     local putong = self:getUI("bg.putong")
    --     local playAlliance = userData.roleGuild
    --     if playAlliance.pos == 1 and playAlliance.pos ~= detailData.pos then 
    --         gun:setVisible(true)
    --         hao:setVisible(true)
    --         putong:setVisible(false)
    --     elseif playAlliance.pos == 2 and playAlliance.pos < detailData.pos then
    --         gun:setVisible(true)
    --         hao:setVisible(false)
    --         putong:setVisible(false)
    --         gun:setPositionX(self:getUI("bg"):getContentSize().width * 0.5)
    --     else
    --         gun:setVisible(false)
    --         hao:setVisible(false)
    --         putong:setVisible(true)
    --     end
    -- end
    
    -- 英雄头像
    local heroData = clone(tab:Hero(detailData.hero.heroId or 60001))
    heroData.star = detailData.hero.star
    heroData.skin = detailData.hero.skin
    local heroName = self:getUI("bg.info_panel.heroName")
    heroName:setString(lang(heroData.heroname))
    -- local icon = IconUtils:createHeadIconById({art = heroData.herohead,tp = 2,avatarFrame = heroData["avatarFrame"]})
    local icon = IconUtils:createHeroIconById({sysHeroData = heroData})
    icon:setScale(0.9)
    icon:setPosition(self._headFrame:getContentSize().width * 0.5, self._headFrame:getContentSize().height * 0.5)
    self._headFrame:addChild(icon)
    self:registerClickEvent(icon, function()
        if self._globalSpecial and self._playerLv and self._treasures and self._hAb then
            self:rankHeroDetailView(detailData.hero.heroId, detailData.hero)
        else
            self:getTargetUserBattleInfo(detailData.hero.heroId, detailData.hero, detailData.memberId , "hero")
        end
    end)

    -- 兵团头像
    local x,y = 0,0
    local offsetx,offsety = 10,4
    local row,col = 2,4
    local iconSize = 93
    local boardHeight = self._scrollView:getContentSize().height
    local idx = 1
    local item 
    for teamId,team in pairs(detailData.teams) do
        x = (idx-1)%col*iconSize+offsetx
        y = boardHeight- (math.floor((idx-1)/col+1)*iconSize)+offsety
        local rid = detailData.memberId or detailData.rid
        item = self:createTeams(x,y,tonumber(teamId),team,rid)
        idx=idx+1

        item:setScale(0.73)
        item:setPosition(cc.p(x,y))
        self._scrollView:addChild(item)
    end

    local teamMaxNum = tab:UserLevel(tonumber(detailData.lvl)).num
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

    --启动特权类型
    --	data.detailData["tequan"] = "sq_gamecenter"
	local tequanImg = IconUtils.tencentIcon[data.detailData["tequan"]] or "globalImageUI6_meiyoutu.png"
	local tequanIcon = ccui.ImageView:create(tequanImg, 1)
    tequanIcon:setScale(0.65)
    tequanIcon:setPosition(500,50)
	self:getUI("bg.panel"):addChild(tequanIcon)
    tequanIcon:setScaleAnim(true)

    if tequanImg ~= "globalImageUI6_meiyoutu.png" then
        self:registerClickEvent(tequanIcon,function( sender )
            self._viewMgr:showDialog("tencentprivilege.TencentPrivilegeView")
        end)
    end

    -- local gun = self:getUI("bg.gun")
    -- self:registerClickEvent(gun, function()
    --     self:kickMember(detailData.memberId)
    --     print("踢出 ================")
    -- end)
    -- local hao = self:getUI("bg.hao")
    -- self:registerClickEvent(hao, function()
    --     self:close()
    --     self._viewMgr:showDialog("guild.GuildAppointDialog", {detailData = detailData})
    --     print("任命 ================")
    -- end)

    -- weapon信息展示
    -- 上阵weaponId   
    local formationData = detailData.formation or {}
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

function GuildPlayerDialog:addFriendFunc(detailData)
    self._friendModel = self._modelMgr:getModel("FriendModel")
    -- dump(detailData,'result')
    -- print("========================self._userData[usid]==",detailData.usid)
    if detailData.usid == nil then
        self._viewMgr:showTip("usid为空")
        return
    end
    
    -- print("================detailData.usid==",detailData.usid)
    if self._friendModel:checkIsFriend(detailData.usid) then
        self._viewMgr:showTip("已在好友列表中")
        return
    end
    if self._friendModel:checkIsBlack(detailData.usid) then
        self._viewMgr:showTip("已在黑名单列表中")
        return
    end
    self._serverMgr:sendMsg("GameFriendServer", "applyGameFriend", {usid = detailData.usid}, true, {}, function (result)
        self._viewMgr:showTip(lang("TIPS_ARENA_11"))
        self._modelMgr:getModel("FriendModel"):applyAddFriend(detailData.usid)
    end)
end


function GuildPlayerDialog:kickMember(indexId)
    print("载入=============数据====")
    if self._modelMgr:getModel("UserModel"):getData()["roleGuild"]["pos"] == 3 then
        self._viewMgr:showTip("你已不是联盟管理成员")
        self:close()
        return
    end
    local param = {mId = indexId}
    self._serverMgr:sendMsg("GuildServer", "kickMember", param, true, {}, function (result)
        self._modelMgr:getModel("GuildModel"):setGuildTempData(true)
        self:close()
        -- self:getApplyGuildListFinish(result)
    end)
end


function GuildPlayerDialog:createTeams( x,y,teamId,teamData, rid )
    local teamD = tab:Team(teamId)
    local quality = self._modelMgr:getModel("TeamModel"):getTeamQualityByStage(teamData.stage)
    local teamIcon = IconUtils:createTeamIconById({teamData = teamData,sysTeamData = teamD, quality = quality[1] , quaAddition = quality[2], eventStyle = 3,clickCallback = function( )        
        if self._pokedex and self._treasures then
            self:rankTeamDetailView(teamId, teamData)
        else
            self:getTargetUserBattleInfo(teamId, teamData, rid, "team")
        end
    end})
    return teamIcon
end

function GuildPlayerDialog:createGrid(x,y,isLocked)
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

-- 器械
function GuildPlayerDialog:initWeaponsPanel(weaponPanel,weaponsData)
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

function GuildPlayerDialog:getTargetUserBattleInfo(teamId, teamData, rid, isHero)

    self._serverMgr:sendMsg("UserServer", "getTargetUserBattleInfo", {tagId=rid}, true, {}, function (result)
        -- dump(result)
        if result["treasures"] then
            self._treasures = result["treasures"]
            result["treasures"] = nil
        end
        if result["pokedex"] then
            self._pokedex = result["pokedex"]
            result["pokedex"] = nil
        end
        if result["globalSpecial"] then
            self._globalSpecial = result["globalSpecial"]
            result["globalSpecial"] = nil 
        end
        if result["lv"] then
            self._playerLv = result["lv"]
            result["lv"] = nil 
        end

        if result["talentData"] or result["talent"] then
            self._talentData = result["talentData"] or result["talent"]
        end
        if result["uMastery"] then
            self._uMastery = result["uMastery"]
            result["uMastery"] = nil 
        end
        if result["hSkin"] then
            self._hSkin = result["hSkin"]
            result["hSkin"] = nil 
        end
        if result["spTalent"] then
            self._spTalent = result["spTalent"]
            result["spTalent"] = nil
        end

        if result["runes"] then
            self._runes = result["runes"]
            result["runes"] = nil
        end

        if result["heros"] then
            self._heros = result["heros"]
            result["heros"] = nil
        end
        

        -- if result["globalSpecial"] then
        --     self._globalSpecial = result["globalSpecial"]
        --     result["globalSpecial"] = nil 
        -- end
        if isHero == "team" then
            self:rankTeamDetailView(teamId, teamData)
        else
            if result["hAb"] then
                self._hAb = result["hAb"]
                result["hAb"] = nil 
            end
            self:rankHeroDetailView(teamId, teamData)
        end
    end)
end

function GuildPlayerDialog:rankTeamDetailView(teamId, teamData)
    local detailData = {}
    detailData.team = teamData
    detailData.team.teamId = teamId
    detailData.pokedex = self._pokedex 
    detailData.treasures = self._treasures
    detailData.runes = self._runes
    detailData.heros = self._heros
    ViewManager:getInstance():showDialog("rank.RankTeamDetailView", {data=detailData}, true)
end

function GuildPlayerDialog:rankHeroDetailView(teamId, teamData)
    local detailData = {}
    detailData.heros = teamData
    detailData.heros.heroId = teamId
    if self._globalSpecial and self._globalSpecial ~= "" then
        detailData.globalSpecial = self._globalSpecial
    end
    detailData.level = self._playerLv 
    detailData.treasures = self._treasures
    detailData.hAb = self._hAb
    detailData.talentData = self._talentData
    detailData.uMastery = self._uMastery
    detailData.hSkin = self._hSkin
    detailData.spTalent = self._spTalent
    ViewManager:getInstance():showDialog("rank.RankHeroDetailView", {data=detailData}, true)
end

return GuildPlayerDialog