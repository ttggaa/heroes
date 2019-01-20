--[[
    Filename:    CrossGodWarUserInfoView.lua
    Author:      <haotaian@playcrab.com>
    Datetime:    2018-05-14 16:55
    Description: File description
--]]
local CrossGodWarUserInfoView = class("CrossGodWarUserInfoView", BasePopView)

function CrossGodWarUserInfoView:ctor(param)
	CrossGodWarUserInfoView.super.ctor(self)
	self._userInfo = param.userInfo or {}
    self._formationInfos = {}
    self._state = param.state or 3
end

function CrossGodWarUserInfoView:onInit( )
	self:registerClickEvent(self:getUI("bg.mainBg.closeBtn"), function ( ... )
		self:close()
	end)
    self._crossGodWarModel = self._modelMgr:getModel("CrossGodWarModel")
	self._userInfoPanel = self:getUI("bg.mainBg.userInfo")
    self._formationPanel = self:getUI("bg.mainBg.formationPanel")
	self._item = self:getUI("item")
    self:addTableView()
    self:initUserInfo()
    self._serverMgr:sendMsg("CrossGodWarServer","getThreeFormationInfoById",{id = self._userInfo.playerId },true,{},function ( result )
        self._formationInfos = result.formations
        self._dFId = result.dFId
        self._fUseInfo = result.c
        self:updateUI()
    end)
	
end

function CrossGodWarUserInfoView:updateUI(data)
    local isVisible = false
    for k,v in pairs(self._formationInfos) do
        if next(v) then
            isVisible = true
        end
    end 
    local nothing = self:getUI("bg.mainBg.nothing")
    nothing:setVisible(not isVisible)
    self._itemScrollView:reloadData()
end

function CrossGodWarUserInfoView:initUserInfo()
    local headP = {avatar = self._userInfo["avatar"],level = self._userInfo["lvl"] or self._userInfo["lv"] or 0, tp = 4,
                    avatarFrame = self._userInfo["avatarFrame"], tencetTp = self._userInfo["qqVip"], plvl = self._userInfo["plvl"]}
	self._avatar = IconUtils:createHeadIconById() 
    self._avatar:setAnchorPoint(0, 0)
    self._avatar:setPosition(0, 63)
    self._userInfoPanel:addChild(self._avatar, 2)

    local nameLab = self._userInfoPanel:getChildByFullName("name")
    nameLab:setString(self._userInfo["name"])
    nameLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    nameLab:setFontSize(24)

    local vipLabel = cc.Label:createWithBMFont(UIUtils.bmfName_vip, "v" .. (self._userInfo.vipLvl or 0))
    vipLabel:setName("vipLabel")
    vipLabel:setAnchorPoint(cc.p(0, 0.5))
    vipLabel:setPosition(math.max(105 + nameLab:getContentSize().width + 20, 165) , nameLab:getPositionY())
    self._userInfoPanel:addChild(vipLabel, 2)
    local isHideVip = UIUtils:isHideVip(self._userInfo.hideVip,"userInfo")
    if self._userInfo.vipLvl == 0 or isHideVip then
        vipLabel:setVisible(false)
    end

    local fightScore = self:getUI("bg.mainBg.userInfo.fightScore")
    fightScore:setFntFile(UIUtils.bmfName_zhandouli_little)
    fightScore:setString("a" .. (self._userInfo.score or 0))--最高战力
    fightScore:setScale(0.5)
    fightScore:setPosition(fightScore:getPositionX() - 1, 80)

    local guildLab = self:getUI("bg.mainBg.userInfo.guild")
    local guildName = self:getUI("bg.mainBg.userInfo.guildName")
    guildLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    guildName:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    guildLab:setString("联盟：")
    local str = self._userInfo.guildName
    if not str or str == "" then
        str = "尚未加入联盟"
    end
    guildName:setString(str)

    self:getUI("bg.mainBg.userInfo.realNameBtn"):setVisible(GameStatic.is_show_realName)

    local serverStr
    if self._state == 3 or self._state == 4 then
        serverStr = self._crossGodWarModel:getServerNameStr(self._crossGodWarModel:getGroupRivalServerId())
    else
        serverStr = self._crossGodWarModel:getServerNameStr(self._userInfo.serverId)
    end
    print("ssssss ",serverStr)
    print("_state ",self._state)
    local serverName = self:getUI("bg.mainBg.userInfo.serverName")
    if (not self._userInfo.serverId) and (self._state ~= 3 and self._state ~= 4) then
        serverName:setVisible(false)
    else
        serverName:setString(string.format("%s",serverStr))
        serverName:setVisible(true)
    end

end

function CrossGodWarUserInfoView:addTableView(data)
    if self._itemScrollView then  
        self._itemScrollView:removeFromParent()
        self._itemScrollView = nil
    end
    local tableView = cc.TableView:create(cc.size(self._formationPanel:getContentSize().width, self._formationPanel:getContentSize().height-5))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(self._formationPanel:getPosition())
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    -- tableView:setBounceEnabled(true)
    self._formationPanel:getParent():addChild(tableView,1)
    tableView:registerScriptHandler(function( view )
        return self:scrollViewDidScroll(view)
    end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(function( view )
        return self:scrollViewDidZoom(view)
    end ,cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(function ( table,cell )
        return self:tableCellTouched(table,cell)
    end,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(function( table,index )
        return self:cellSizeForTable(table,index)
    end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function ( table,index )
        return self:tableCellAtIndex(table,index)
    end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function ( table )
        return self:numberOfCellsInTableView(table)
    end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._itemScrollView = tableView
end

function CrossGodWarUserInfoView:scrollViewDidScroll(view)
    self._inScrolling = view:isDragging()   
end

function CrossGodWarUserInfoView:scrollViewDidZoom(view)
    -- print("scrollViewDidZoom")
end

function CrossGodWarUserInfoView:tableCellTouched(table,cell)
    print("cell touched at index: " .. cell:getIdx())
end

function CrossGodWarUserInfoView:cellSizeForTable(table,idx) 
    return 188,666
end

function CrossGodWarUserInfoView:tableCellAtIndex(table, idx)
    local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    local label = nil
    local key = tostring((idx+37))
    local cellData = self._formationInfos[key]
    if not cellData.formation then
        return
    end
    if nil == cell then
        cell = cc.TableViewCell:new()     
        local item = self._item:clone()
		item:setVisible(true)
        self:updateCellItem(item,cellData, idx+1) 
        item:setPosition(10,5)
        item:setName("cellItem")
        item:setAnchorPoint(0,0)
        cell:addChild(item)
    else
        local cellItem = cell:getChildByFullName("cellItem")        
        self:updateCellItem(cellItem,cellData, idx+1)       
    end

    return cell
end

function CrossGodWarUserInfoView:numberOfCellsInTableView(inView)
    return table.nums(self._formationInfos)
end

local titleNames = {"第一阵容","第二阵容","第三阵容"}
function CrossGodWarUserInfoView:updateCellItem(inView,cellData,idx)
    local tName = inView:getChildByName("titleName")
    tName:setString(titleNames[idx])
    if not inView.scoreLab then
        local scoreNode = inView:getChildByName("powerNode")
        local scoreLab = cc.Label:createWithBMFont(UIUtils.bmfName_zhandouli_little, "a".. cellData.formation.score )
        inView.scoreLab = scoreLab
        scoreLab:setAnchorPoint(cc.p(0, 0.5))
        scoreLab:setPositionY(4)
        scoreLab:setScale(0.5)
        scoreNode:addChild(scoreLab, 2)
    else
        inView.scoreLab:setString("a"..cellData.formation.score)
    end

    local sysHeroData = clone(tab:Hero(cellData.formation.heroId))
    sysHeroData.star = cellData.hero.star
    sysHeroData.skin = cellData.hero.skin
    if not inView.heroIcon then
        local heroNode = inView:getChildByName("heroNode")
        local heroIcon = IconUtils:createHeroIconById({sysHeroData = sysHeroData,tp = 4})
        heroIcon:setAnchorPoint(cc.p(0,0))
        inView.heroIcon = heroIcon
        heroNode:addChild(heroIcon)  
    else
        IconUtils:updateHeroIconByView(inView.heroIcon, {sysHeroData = sysHeroData,tp = 4})
    end 

    inView.selectBtn = inView:getChildByFullName("selectBtn")
    inView.selectBtn:setEnabled(false)
    inView.selectBtn:setBright(false)
    inView.selectBtn:setBrightness(-50)

    self:createListView(inView,cellData,cellData.hero)
    local index = 36 + idx
    if self._dFId== index then
        inView.selectBtn:setTitleText("使用中")
    else
        inView.selectBtn:setTitleText("使用")
    end

    local allTimes = 6 
    if self._state >= 6 and self._state < 12 then
        allTimes = 1
    end
    inView.timesLab = inView:getChildByFullName("timesLab")
    local times = allTimes - (self._fUseInfo[tostring(index)] or 0)
    inView.timesLab:setString(times .. "/" .. allTimes)
    if times > 0 then
        inView.timesLab:setColor(cc.c3b(28,162,22))
    else
        inView.timesLab:setColor(cc.c3b(205,32,30))
    end
end

--[[
@desc 创建军团列表
@param inView parant节点 formationData 阵容信息 heroData 阵容英雄信息
]]
function CrossGodWarUserInfoView:createListView( inView,cellData,heroData)
    local list = inView:getChildByFullName("teamList")
    if #list:getItems() > 0 then
        return
    end
    for i=1,8 do
        local teamId = cellData.formation["team"..i]
        if teamId ~= 0 then
            local teamData = cellData.teams[tostring(teamId)]
            local teamIcon = self:createTeam(teamId,teamData,cellData,heroData)
            teamIcon:setAnchorPoint(cc.p(0,0))
            teamIcon:setScale(0.5)
            teamIcon:setContentSize(cc.size(teamIcon:getContentSize().width/2,teamIcon:getContentSize().height/2))
            list:pushBackCustomItem(teamIcon)
        end
    end

end

--[[
@desc 创建军团
@param teamId:id teamData:兵团信息 formationData 阵容信息 heroData 阵容英雄信息
]]
function CrossGodWarUserInfoView:createTeam(teamId,teamData,cellData,heroData)
    -- dump(teamData)
    local teamD = tab:Team(teamId)
    -- -- print("===========self._palyerData.formation.heroId,teamId=>",self._palyerData.formation.heroId,teamId)
    local _,changeId = TeamUtils.changeArtForHeroMasteryByData(heroData,cellData.formation.heroId,teamId)
    -- -- print("===========cahngeId=========",changeId)
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
        detailData.pokedex = cellData.pokedex or {}
        detailData.treasures = cellData.treasures or {}
        detailData.runes = cellData.runes or {}
        detailData.battleArray = cellData.battleArray
        detailData.pTalents = cellData.pTalents
        ViewManager:getInstance():showDialog("rank.RankTeamDetailView", {data=detailData}, true)
        -- ViewManager:getInstance():showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeArenaTeam, iconId = teamId}, true)
    end})
    return teamIcon
end


--界面显示切换响应状态
function CrossGodWarUserInfoView:onTop()

end

function CrossGodWarUserInfoView:onHide()

end

function CrossGodWarUserInfoView:destroy()

end


return CrossGodWarUserInfoView