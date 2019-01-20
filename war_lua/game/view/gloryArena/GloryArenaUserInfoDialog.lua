--[[
    FileName:       GloryArenaUserInfoDialog
    Author:         <dongcheng@playcrab.com>
    Datetime:       2018-08-16 11:27:25
    Description:
]]

local GloryArenaUserInfoDialog = class("GloryArenaUserInfoDialog", BasePopView)

function GloryArenaUserInfoDialog:ctor()
    self.super.ctor(self)
end


-- 第一次被加到父节点时候调用
function GloryArenaUserInfoDialog:onAdd()

end

--获取打开UI的时候加载的资源
--function GloryArenaUserInfoDialog:getAsyncRes()
--    return 
--         {
--            {"asset/ui/battle4.plist", "asset/ui/battle4.png"},
--         }
--end

local childName = {
    --按钮
    {name = "closeBtn", childName = "bg.closeBtn", isBtn = true},
    {name = "title_txt", childName = "bg.title_img.title_txt"},
    {name = "name_text", childName = "bg.name_text", isText = true},
    {name = "guildName_text", childName = "bg.guildName_text", isText = true},
    {name = "serverName_text", childName = "bg.serverName_text", isText = true},
    {name = "guild", childName = "bg.guild", isText = true},
    {name = "heroHead", childName = "bg.heroHead"},
    {name = "modelCell", childName = "bg.modelCell"},
    {name = "tableViewBg_lay", childName = "bg.tableViewBg_lay"},
}

function GloryArenaUserInfoDialog:onRewardCallback(_, _x, _y, sender)
    if sender == nil or self._childNodeTable == nil then
        return 
    end

    if sender:getName() == "closeBtn" then
        self:close()
        UIUtils:reloadLuaFile("gloryArena.GloryArenaUserInfoDialog")
    end
end

-- 初始化UI后会调用, 有需要请覆盖
function GloryArenaUserInfoDialog:onInit()
    self._childNodeTable = self:lGetChildrens(self._widget, childName)
    
    if self._childNodeTable == nil then
        return
    end

    -- self:disableTextEffect()

    UIUtils:setTitleFormat(self._childNodeTable.title_txt,1)

    self._childNodeTable.modelCell:setVisible(false)

--    self._vipLab = cc.Label:createWithBMFont(UIUtils.bmfName_vip, "")
--    self._vipLab:setAnchorPoint(cc.p(0,0.5))
--    self._vipLab:setPosition(self._childNodeTable.name_text:getPositionX()+self._childNodeTable.name_text:getContentSize().width+10, self._childNodeTable.name_text:getPositionY())
--    self._vipLab:setString("")--"V" .. "15")
--    self._childNodeTable.name_text:getParent():addChild(self._vipLab, 2)

   
end

-- 接收自定义消息
function GloryArenaUserInfoDialog:reflashUI(data)
    self._userData = data
    self:updateUI()
end

function GloryArenaUserInfoDialog:updateUI()
    if self._userData then
        local headP = {avatar = self._userData["avatar"],level = self._userData["lv"] or 0, tp = 4,
                        avatarFrame = self._userData["avatarFrame"], tencetTp = self._userData["qqVip"], plvl = self._userData["plvl"]}
        self._avatar = IconUtils:createHeadIconById(headP) 
        self._avatar:setAnchorPoint(0, 0)
        self._avatar:setPosition(0, 0)
        self._childNodeTable.heroHead:addChild(self._avatar, 2)

        --name
        self._childNodeTable.name_text:setString(self._userData["name"])
        self._childNodeTable.name_text:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        self._childNodeTable.name_text:setFontSize(24)
   
   	    -- vip
        local vipLabel = cc.Label:createWithBMFont(UIUtils.bmfName_vip, "v" .. (self._userData.vipLvl or 0))
        vipLabel:setName("vipLabel")
        vipLabel:setAnchorPoint(cc.p(0, 0.5))
        vipLabel:setPosition(self._childNodeTable.name_text:getPositionX()+self._childNodeTable.name_text:getContentSize().width+10, self._childNodeTable.name_text:getPositionY())
        self._childNodeTable.name_text:getParent():addChild(vipLabel, 2)
--        local isHideVip = UIUtils:isHideVip(self._userData.hideVip,"userInfo")
        if not self._userData.vipLvl or self._userData.vipLvl == 0 then
            vipLabel:setVisible(false)
        end

        self._childNodeTable.guildName_text:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        local str = self._userData.guildName
        if not str or str == "" then
            str = "尚未加入联盟"
        end
        self._childNodeTable.guildName_text:setString(str)

        self._childNodeTable.serverName_text:setString("服务器：" .. (self._modelMgr:getModel("GloryArenaModel"):lGetServerNameStr(self._userData.sec or "8001") or ""))
        self:addTableView()
    end
end

function GloryArenaUserInfoDialog:addTableView()
    local _size = self._childNodeTable.tableViewBg_lay:getContentSize()
    local tableView = cc.TableView:create(_size)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(0,0))
    tableView:setAnchorPoint(cc.p(0,0))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    self._childNodeTable.tableViewBg_lay:addChild(tableView)
    tableView:registerScriptHandler(function( view )
        return self:scrollViewDidScroll(view)
    end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(function( view )
        return self:scrollViewDidZoom(view)
    end ,cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(function ( view,cell )
        return self:tableCellTouched(view,cell)
    end,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(function( view,index )
        return self:cellSizeForTable(view,index)
    end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function ( view,index )
        return self:tableCellAtIndex(view,index)
    end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function ( view )
        return self:numberOfCellsInTableView(view)
    end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()
    self._tableView = tableView
end


function GloryArenaUserInfoDialog:scrollViewDidScroll(view)
end

function GloryArenaUserInfoDialog:scrollViewDidZoom(view)
end

function GloryArenaUserInfoDialog:tableCellTouched(view,cell)
end

function GloryArenaUserInfoDialog:cellSizeForTable(view,idx) 
    return 230, 0
end

function GloryArenaUserInfoDialog:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local label = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
    end
    local item = cell:getChildByName("item")
    if not item then
        item = self._childNodeTable.modelCell:clone()
        item:setVisible(true)
        item:setAnchorPoint(cc.p(0,1))
        item:setPosition(cc.p(0, 230))
        item:setSwallowTouches(false)
        item:setName("item")
        cell:addChild(item)
    end
    self:updeteItem(item, idx + 1)
    return cell
end

function GloryArenaUserInfoDialog:numberOfCellsInTableView(view)
   return 3
end

local itemConfigName = {
    {name = "noHide_lay", childName = "noHide_lay"},
    {name = "info_panel", childName = "noHide_lay.info_panel"},
    {name = "headFrame", childName = "noHide_lay.info_panel.headFrame"},
    {name = "weaponPanel", childName = "noHide_lay.info_panel.weaponPanel"},
    {name = "score_text", childName = "noHide_lay.info_panel.score_text"},
    {name = "scrollView", childName = "noHide_lay.scrollView"},
    {name = "hide_image", childName = "hide_image"},
}

function GloryArenaUserInfoDialog:updeteItem(item, nIndex)
    if item == nil or self._userData == nil or self._userData.battle == nil then
        return
    end
    local data = self._userData.battle[nIndex]
    if item._childNodeTable == nil then
        item._childNodeTable = self:lGetChildrens(item, itemConfigName)
    end
    if item._childNodeTable and data then
        item._childNodeTable.score_text:setVisible(false)
        if data.hidden and data.hidden == 1 then
            item._childNodeTable.hide_image:setVisible(true)
            item._childNodeTable.noHide_lay:setVisible(false)
        else
            item._childNodeTable.hide_image:setVisible(false)
            item._childNodeTable.noHide_lay:setVisible(true)
            self:initInfoPanel(item._childNodeTable, data)
        end
    end
end


-- 初始化英雄兵团信息  hgf
function GloryArenaUserInfoDialog:initInfoPanel(childNode ,data)

    local scrollView = childNode.scrollView
    

    -- 英雄静态数据
    local heroData = clone(tab:Hero(data.formation.heroId or 60001))
    heroData.star = data.hero.star
    heroData.skin = data.hero.skin

--    -- 英雄名字
--    local heroName = childNode.heroName
--    heroName:setString(lang(heroData.heroname))
    --英雄头像
    if childNode.icon == nil then
        local heroFrame = childNode.headFrame
        local icon = IconUtils:createHeroIconById({sysHeroData = heroData})
        icon:setScale(0.9)
        icon:setPosition(heroFrame:getContentSize().width * 0.5, heroFrame:getContentSize().height * 0.5+2)
        self:registerClickEvent(icon,function( )
            local detailData = {}
            detailData.heros = data.hero
            detailData.heros.heroId = data.formation.heroId
            if data.globalSpecial and data.globalSpecial ~= "" then
                detailData.globalSpecial = data.globalSpecial
            end
            detailData.level = data.lv or 0
            detailData.treasures = data.treasures or {}
            detailData.hAb = data.hAb or {}
            detailData.talentData = data.talentData or data.talent or {}
            detailData.uMastery = data.uMastery or {}
            detailData.hSkin = data.hSkin
            detailData.spTalent = data.spTalent or {}
            detailData.backups = data.backups
            detailData.pTalents = data.pTalents
            ViewManager:getInstance():showDialog("rank.RankHeroDetailView", {data=detailData}, true)
        end)
        heroFrame:addChild(icon)
        childNode.icon = icon
    else
        IconUtils:updateHeroIconByView(childNode.icon, {sysHeroData = heroData})
    end
    --战力
    if childNode.score  == nil then
        local score = ccui.TextBMFont:create("00", UIUtils.bmfName_zhandouli_little)
	    score:setAnchorPoint(cc.p(0.5, 0.5))
	    score:setScale(0.5)
        score:setPosition(childNode.score_text:getPositionX() , childNode.score_text:getPositionY())
        local nscore = 0
        if data.formation and data.formation.score then
            nscore = data.formation.score
        end
        score:setString("a" .. nscore)
        childNode.info_panel:addChild(score)
        childNode.score = score
    else
        local nscore = 0
        if data.formation and data.formation.score then
            nscore = data.formation.score
        end
        childNode.score:setString("a" .. nscore)
    end

    scrollView:removeAllChildren()
    -- team
    local x,y = 0,0
    local offsetx,offsety = 10,10
    local row,col = 2,4
    local iconSize = 93
    local boardHeight = scrollView:getContentSize().height
    local idx = 1
    local item 
    for teamId,team in pairs(data.teams) do
        x = (idx-1)%col*iconSize+offsetx
        y = boardHeight- (math.floor((idx-1)/col+1)*iconSize)+offsety
        team.teamId = tonumber(teamId)
        item = self:createTeams(x,y,tonumber(teamId),team, data)
        idx=idx+1        
        item:setScale(0.73)
        item:setPosition(cc.p(x,y))
        scrollView:addChild(item)
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
        scrollView:addChild(item)
    end
    -- weapon信息展示
    local formationData = data.formation
    local _weaponId = {}     -- 上阵weaponId  
    local weaponId
    for i=1,3 do
        weaponId = formationData["weapon"..i]
        if weaponId and weaponId ~= 0 then 
            table.insert(_weaponId, weaponId)
        end
    end

    local weaponPanel = childNode.weaponPanel--self:getUI("bg.bg3.infoBg.weaponPanel")
    if #_weaponId > 0 then 
        local weaponsData = data.weapons
        weaponPanel:removeAllChildren()
        weaponPanel:setVisible(true)
        self:initWeaponsPanel(weaponPanel,weaponsData, _weaponId)
        if childNode.score then
            childNode.score:setPositionY(childNode.score_text:getPositionY() - 60)
        end
    else
        if childNode.score then
            childNode.score:setPositionY(childNode.score_text:getPositionY())
        end
        weaponPanel:setVisible(false)  
    end 

end

--创建兵团头像  hgf
function GloryArenaUserInfoDialog:createTeams( x,y,teamId,teamData, data )

    local teamD = clone(tab:Team(teamId))
    local _,changeId = TeamUtils.changeArtForHeroMasteryByData(data.hero,data.formation.heroId,teamId)
    if changeId then
        teamD = clone(tab:Team(changeId))
    end
    local quality = self._modelMgr:getModel("TeamModel"):getTeamQualityByStage(teamData.stage)
    local teamIcon = IconUtils:createTeamIconById({teamData = teamData,sysTeamData = teamD, quality = quality[1] , quaAddition = quality[2],eventStyle=3,clickCallback = function( )        
        local detailData = {}
        detailData.team = teamData
        detailData.team.teamId = teamId
        if changeId then
            detailData.team.teamId = changeId
        end    
        detailData.pokedex = data.pokedex or {}
        detailData.treasures = data.treasures or {}
        detailData.runes = data.runes or {}
        detailData.heros = data.heros or {}
        detailData.battleArray = data.battleArray
        detailData.pTalents = data.pTalents
        ViewManager:getInstance():showDialog("rank.RankTeamDetailView", {data=detailData}, true)
    end})
    return teamIcon
end

-- 创建空格子 hgf
function GloryArenaUserInfoDialog:createGrid(x,y,isLocked)
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
function GloryArenaUserInfoDialog:initWeaponsPanel(weaponPanel,weaponsData, _weaponId)
    local weaponD = weaponsData or {}
    local weaponIDs = _weaponId
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

function GloryArenaUserInfoDialog:dtor()
    childName = nil
    itemConfigName = nil
end

return GloryArenaUserInfoDialog