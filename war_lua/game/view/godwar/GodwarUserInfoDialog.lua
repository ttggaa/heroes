--[[
    Filename:    GodwarUserInfoDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-06-26 16:23:39
    Description: File description
--]]

local GodwarUserInfoDialog = class("GodwarUserInfoDialog",BasePopView)
function GodwarUserInfoDialog:ctor(data)
    self.super.ctor(self)
    -- print("=========================data.isNotShowBtn",data.isNotShowBtn)
    -- self._palyerData = data
    self._notShowBtn = data.isNotShowBtn
    self._isServerName = data.isServerName or false 
    self._palyerData = data
    self._rid = data.rid or data._id or ""

    -- 按钮功能复用
    self._isOtherFun = data.isOtherFun
    self._titleTxtLeft = data.titleTxtLeft
    self._titleTxtRight = data.titleTxtRight
    self._callBackLeft = data.callBackLeft
    self._callBackRight = data.callBackRight
    -- dump(self._palyerData,"playdata")
    self._showType = data.showType or 0 
end

-- 初始化UI后会调用, 有需要请覆盖
function GodwarUserInfoDialog:onInit()
    self:registerClickEventByName("bg.closeBtn", function(  )
        self:close()
        UIUtils:reloadLuaFile("godwar.GodwarUserInfoDialog")
    end)

    -- 私聊加好友按钮
    self._chatBtn = self:getUI("bg.chatBtn")
    self._friend = self:getUI("bg.addFriendBtn") 
    self:registerClickEvent(self._chatBtn, function ()
        self:clickChatEvent()
    end)
    self:registerClickEvent(self._friend, function ()
        self:addFriendEvent()
    end)

    -- 联盟探索生命相关默认隐藏
    local mapHurtBg = self:getUI("bg.mapHurtBg")
    mapHurtBg:setVisible(false)

    --额外功能按钮
    self._leftBtn = self:getUI("bg.leftBtn")
    self._rightBtn = self:getUI("bg.rightBtn") 
    self._leftBtn:setTitleText(self._titleTxtLeft or "战斗")
    self._rightBtn:setTitleText(self._titleTxtRight or "路过")
    self:registerClickEvent(self._leftBtn, function ()
        if self._callBackLeft then
            self._callBackLeft()
        end
    end)    
    self:registerClickEvent(self._rightBtn, function ()
        if self._callBackRight then
            self._callBackRight()
        end
    end)

    -- visible
    self._chatBtn:setVisible(not self._notShowBtn and not self._isOtherFun)
    self._friend:setVisible(not self._notShowBtn and not self._isOtherFun)
    self._leftBtn:setVisible(not self._notShowBtn and self._isOtherFun)
    self._rightBtn:setVisible(not self._notShowBtn and self._isOtherFun)
    

    self._bg = self:getUI("bg")
    self._title = self:getUI("bg.title_img.title_txt")
    UIUtils:setTitleFormat(self._title, 1)

    self._nameBg = self:getUI("bg.nameBg")
    self._nameBg:setContentSize(1,1)
    self._name = self:getUI("bg.name")
    UIUtils:setTitleFormat(self._name, 2)
    self._vipLab = cc.Label:createWithBMFont(UIUtils.bmfName_vip, "")
    -- self._vipLab:setScale(0.8)
    self._vipLab:setAnchorPoint(cc.p(0,0.5))
    self._vipLab:setPosition(self._name:getPositionX()+self._name:getContentSize().width+10,self._name:getPositionY())
    -- self._vipLabel:setAdditionalKerning(-5)
    self._name:getParent():addChild(self._vipLab, 2)

    -- self._level = self:getUI("bg.level")
    -- self._level:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    -- self._rank = self:getUI("bg.rank")
    -- self._rank:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    
    local score = self:getUI("bg.score")
    score:setVisible(false)
    self._score = ccui.TextBMFont:create("00", UIUtils.bmfName_zhandouli_little)
    self._score:setAnchorPoint(cc.p(0,0))
    self._score:setScale(0.6)
    self._score:setPosition(score:getPositionX() ,score:getPositionY()+20)
    self._bg:addChild(self._score)
    self._heroHead = self:getUI("bg.heroHead")
    self._headFrame = self:getUI("bg.info_panel.headFrame")
    
    -- self._headFrame:setScale(0.8)
    -- self._vipLab = self:getUI("bg.vipBtn.vipLab")
    -- self._vipLab:setFntFile(UIUtils.bmfName_vip)

    -- self._vipBtn = self:getUI("bg.vipBtn")
 --    self._vipLab = cc.Label:createWithBMFont(UIUtils.bmfName_vip, "10")
 --    self._vipLab:setPosition(self._vipBtn:getContentSize().width * 0.5, 3.5)
 --    self._vipLab:setAdditionalKerning(-5)
 --    self._vipBtn:addChild(self._vipLab)    

    self._signTxt = self:getUI("bg.signBg.signTxt") 
    self._scrollView = self:getUI("bg.scrollBg.scrollView")

end

-- 接收自定义消息
function GodwarUserInfoDialog:reflashUI(data)
    -- dump(data,"data")
    -- 签名
    local mapHurtBg = self:getUI("bg.mapHurtBg")
    mapHurtBg:setVisible(false)

    local signBg = self:getUI("bg.signBg")
    signBg:setVisible(true)

    if not self._palyerData.msg or self._palyerData.msg == "" then
        self._signTxt:setString("签名: 这家伙很懒，什么也没有留下")
    else
        self._signTxt:setString("签名: "..self._palyerData.msg)
    end
    -- userData
    local userData = self._modelMgr:getModel("UserModel"):getData()
    if self._palyerData and self._rid and self._rid == userData._id then 
        self._chatBtn:setVisible(false)
        self._chatBtn:setEnabled(false)
        self._friend:setVisible(false)
        self._friend:setEnabled(false)
    end
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
        self._avatar = IconUtils:createHeadIconById({avatar = data.avatar,level = data.lv or "0" ,tp = 4,avatarFrame=data["avatarFrame"], tencetTp = tencetTp}) 
        -- self._avatar:getChildByFullName("iconColor"):loadTexture("globalImageUI6_headBg.png",1)
        self._avatar:setPosition(cc.p(-1,-1))
        self._heroHead:addChild(self._avatar)
    else
        IconUtils:updateHeadIconByView(self._avatar,{avatar = data.avatar,level = data.lv or "0" ,tp = 4, tencetTp = tencetTp})
        -- self._avatar:getChildByFullName("iconColor"):loadTexture("globalImageUI6_headBg.png",1)
    end

 -- data["tequan"] = "sq_gamecenter"
    local tequanImg = IconUtils.tencentIcon[data["tequan"]] or "globalImageUI6_meiyoutu.png"
    local tequanIcon = ccui.ImageView:create(tequanImg, 1)
    tequanIcon:setPosition(465, 350)
    self._bg:addChild(tequanIcon)
    tequanIcon:setScaleAnim(true)

    if tequanImg ~= "globalImageUI6_meiyoutu.png" then
        self:registerClickEvent(tequanIcon,function( sender )
            self._viewMgr:showDialog("tencentprivilege.TencentPrivilegeView")
        end)
    end

    self._name:setString(data.name or "")

    local guild = self:getUI("bg.guild")
    local guildName = self:getUI("bg.guildName")
    guildName:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    -- guildName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)

    local rankStr =  ""
    if self._isServerName then
        guild:setString("服务器：")
        rankStr = self._modelMgr:getModel("LeagueModel"):getServerName(data.serverNum)
    else    
        guild:setString("联盟：")
        if data.guildMapName and data.guildMapName ~= "" then        
            rankStr = data.guildMapName
            guildName:setString(data.guildMapName)
        elseif data.guildName and data.guildName ~= "" then        
            rankStr = data.guildName
            guildName:setString(data.guildName)
        else
            rankStr = "尚未加入联盟"        
        end   
    end
    guildName:setPositionX(guild:getPositionX()+guild:getContentSize().width-5) 
    guildName:setString(rankStr)

    -- self._score:setScale(0.8)
    if not data.formation then
        data.formation = {}
    end
    local score = data.hScore 
    if not score or 0 == score then
        score = data.formation.score or 0
    end
    self._score:setString("a" .. score)
    local vipLvl = (data.vipLvl or 0)
    self._vipLab:setPosition(self._name:getPositionX()+self._name:getContentSize().width+10,self._name:getPositionY())
    self._vipLab:setString( "V" .. vipLvl)
    local isHideVip = UIUtils:isHideVip(data.hideVip,"userInfo")
    if vipLvl == 0 and not isHideVip then
        self._vipLab:setVisible(false)
        self._vipLab:setString("")
        -- self._vipBtn:setVisible(false)
    else
        self._vipLab:setVisible(true)
    end

    -- local nameWidth = self._name:getContentSize().width+10+self._vipLab:getContentSize().width
    -- self._nameBg:setContentSize(nameWidth < 115 and 192 or nameWidth + 80, self._nameBg:getContentSize().height)

    -- avatar
    -- print("data.avatar",data.avatar)--safecode toberemove
    -- local icon = IconUtils:createHeadIconById({avatar = data.avatar,tp = 2,avatarFrame=data["avatarFrame"]}) 
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
        detailData.heros = self._palyerData.hero
        detailData.heros.heroId = self._palyerData.formation.heroId
        if self._palyerData.globalSpecial and self._palyerData.globalSpecial ~= "" then
            detailData.globalSpecial = self._palyerData.globalSpecial
        end
        detailData.level = self._palyerData.lv 
        detailData.treasures = self._palyerData.treasures
        detailData.hAb = self._palyerData.hAb
        detailData.talentData = self._palyerData.talentData or self._palyerData.talent
        detailData.uMastery = self._palyerData.uMastery
        detailData.hSkin = self._palyerData.hSkin
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
    -- dump(data.teams)
    for teamId,team in pairs(data.teams) do
        x = (idx-1)%col*iconSize+offsetx
        y = boardHeight- (math.floor((idx-1)/col+1)*iconSize)+offsety
        team.teamId = tonumber(teamId)
        self:createTeams(x,y,tonumber(teamId),team)
        idx=idx+1
    end
    local teamMaxNum = tab:UserLevel(tonumber(data.lv or data.level)).num
    for i = idx ,8 do
        x = (idx-1)%col*iconSize+offsetx
        y = boardHeight- (math.floor((idx-1)/col+1)*iconSize)+offsety
        -- 未达到最大上阵兵团数，添加空格子，剩下不足八个的添加带锁的空格子     
        if i <= teamMaxNum then         
            self:createGrid(x,y,false)      
        else
            self:createGrid(x,y,true)
        end
        idx=idx+1

    end
    if self["reflashUI" .. self._showType] ~= nil then 
        self["reflashUI" .. self._showType](self, data)
    end

end

function GodwarUserInfoDialog:reflashUI1(data)
    if data.mapHurt == nil then 
        return
    end
    local mapHurtBg = self:getUI("bg.mapHurtBg")
    mapHurtBg:setVisible(true)

    local signBg = self:getUI("bg.signBg")
    signBg:setVisible(false)


    local progBar = self:getUI("bg.mapHurtBg.progBar")
    progBar:setPercent(data.mapHurt / 100 * 100)


    local mapHurtLab = self:getUI("bg.mapHurtBg.mapHurtLab")
    mapHurtLab:setString(data.mapHurt)
    mapHurtLab:setColor(UIUtils.colorTable.ccUIBaseColor5)

    local tipLab1 = self:getUI("bg.mapHurtBg.tipLab1")
    tipLab1:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    

    local tipLab = self:getUI("bg.mapHurtBg.tipLab")
    tipLab:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    tipLab:setPositionX(mapHurtLab:getPositionX() + mapHurtLab:getContentSize().width)
end

function GodwarUserInfoDialog:createTeams( x,y,teamId,teamData )
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
        ViewManager:getInstance():showDialog("rank.RankTeamDetailView", {data=detailData}, true)
        -- ViewManager:getInstance():showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeArenaTeam, iconId = teamId}, true)
    end})
    teamIcon:setScale(0.73)
    teamIcon:setPosition(cc.p(x,y))
    self._scrollView:addChild(teamIcon)
end
function GodwarUserInfoDialog:createGrid(x,y,isLocked)
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
    bagGrid:setScale(0.73)
    bagGrid:setPosition(cc.p(x,y))
    self._scrollView:addChild(bagGrid)

end
function GodwarUserInfoDialog:clickChatEvent()
    local chatModel = self._modelMgr:getModel("ChatModel")
    local isPriOpen, tipDes = chatModel:isPirChatOpen()
    if isPriOpen == false then
        self._viewMgr:showTip(tipDes)
        return
    end
    
    -- if true then return end
    if self._palyerData and self._rid then
        local friendModel = self._modelMgr:getModel("FriendModel")
        if friendModel:checkIsBlack(self._rid) then
            self._viewMgr:showTip("玩家在黑名单列表中，不能进行私聊")
            return
        end
         
        if string.sub(self._rid,1,5) ~= "arena" then
            self._serverMgr:sendMsg("UserServer", "getTargetUser", {rid = self._rid}, true, {}, function (result)
                if result and next(result) ~= nil and string.sub(result.rid,1,5) ~= "arena" then
                    self._viewMgr:showDialog("chat.ChatPrivateView", {userData = result, viewtType = "pri"}, true)  
                end
            end)
        else

            local chatUserData = {
                name    = self._palyerData.name or "",
                avatar  = self._palyerData.avatar or 1101,
                avatarFrame = self._palyerData.avatarFrame or 1000,
                banChat = self._palyerData.banChat or 0,
                lvl     = self._palyerData.lv or 0,
                score   = self._palyerData.score or 0,
                rid     = self._rid or "arena_001",
                usid    = self._palyerData.usid or 0,
                vipLvl  = self._palyerData.vipLvl or 0,
                userType = "arena",
            }           

            self._viewMgr:showDialog("chat.ChatPrivateView", {userData = chatUserData, viewtType = "arena"}, true)
        end
    else
        print("============数据为空或者rid为nil-==========")
    end
end

function GodwarUserInfoDialog:addFriendEvent()
    
    if string.sub(self._rid,1,5) == "arena" then
        self._viewMgr:showTip(lang("TIPS_ARENA_11"))
    else
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

end

return GodwarUserInfoDialog