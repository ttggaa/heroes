--
-- Author: <wangguojun@playcrab.com>
-- Date: 2016-07-06 16:23:53
--
local LeagueSetSpot = class("LeagueSetSpot",BasePopView)
function LeagueSetSpot:ctor()
    self.super.ctor(self)
    self._leagueModel = self._modelMgr:getModel("LeagueModel")
end
-- 自动添加描边
function LeagueSetSpot:enableDefaultOutline(element)
    if element == nil then
        element = self._widget
    end
    local desc = element:getDescription()
    local nameStr = element:getName()
    if desc == "Label" and (name ~= "title" or name ~= "intitle" or name ~= "des1") then
        element:setFontName(UIUtils.ttfName)
        element:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    end
    local count = #element:getChildren()
    for i = 1, count do
        self:enableDefaultOutline(element:getChildren()[i])
    end
end
-- 初始化UI后会调用, 有需要请覆盖
function LeagueSetSpot:onInit()
    self:enableDefaultOutline()
	self:registerClickEventByName("bg.closeBtn",function()
        if self:detectCanSave() then
            DialogUtils.showShowSelect({
                desc = lang("LEAGUETIP_09"),
                button1 = "保存",
                button2 = "退出",
                callback1=function( )
        			self:detectCanSave(true)
                    self:close()
                end,
                callback2=function( )
                    self:close()
                end
                })
        else
    		self:close()
        end 
        UIUtils:reloadLuaFile("league.LeagueSetSpot")
	end)
    
	self._tableBg = self:getUI("bg.tableBg")
	self._itemBg = self:getUI("bg.recommand.itemBg")

    self._title = self:getUI("bg.headBg.title")
    -- self._title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    UIUtils:setTitleFormat(self._title,4) 
    -- self._title:setColor(cc.c3b(255, 255, 255))
    -- self._title:setColor(cc.c3b(250, 242, 192))
    -- self._title:enable2Color(1,cc.c4b(255, 195, 20,255))

        
    self._selectLab = self:getUI("bg.selectLab")

	self._allIcons = {}
	self._selectIcon = {}
    self._selectIconSortIdx = 0
    -- 初始化已选热点兵团
    local selectHot = self._leagueModel:getHot()
    self._selectHot = {}
    self._curSelectHot = {}
    self._seasonspot = {}
    self._otherspot = {}
    self:resetFixedStatus()
    
    -- ue 2.0 新增逻辑
    self._hotPanel = self:getUI("bg.redFlag.hotPanel")
    self:updateSeasonHot()
    self._recommand = self:getUI("bg.recommand")
    local inTitle = self:getUI("bg.recommand.intitle")
    inTitle:setFontName(UIUtils.ttfName)
    inTitle:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._recommand:setVisible(false)
    self._hotTableBg = self:getUI("bg.hotTableBg")
    self._other = {}
    self._hotTableData = self:generateSportData()
    -- self:addHotTableView()
	self._tableData = {}
	local haveTeams = clone(self._modelMgr:getModel("TeamModel"):getData())
    for k,v in pairs(haveTeams) do
        v.isSeason = self._seasonspot[v.teamId] or false
        v.isOther = self._otherspot[v.teamId] or 0
        v.isSelected = self._curSelectHot[v.teamId] or false
        table.insert(self._tableData,v)
    end
    table.sort(self._tableData,function( a,b )
        if a.isSeason ~= b.isSeason then
            return a.isSeason 
        else
            if a.isSelected ~= b.isSelected then
                return a.isSelected 
            else
                -- if a.isOther ~= b.isOther then
                --     return a.isOther < b.isOther
                -- else
                    if a.score ~= b.score then
                        return a.score > b.score
                    else
                        return a.teamId < b.teamId 
                    end
                -- end
            end
        end
    end)
    self:addTableView()

    -- select特效
    -- self._selectMc = mcMgr:createViewMC("redianxuanzhong_leagueredianxuanzhong", true, false,function( _,sender )
    --     -- sender:gotoAndPlay(10)
    -- end,RGBA8888)
    -- self._selectMc:setVisible(false)
    -- self:addChild(self._selectMc,999)
    --
    self._flyPanel = self:getUI("bg.flyPanel")

    -- ue3.0 改pageview 2016.9.6
    local des1_0 = self:getUI("bg.des1_0")
    des1_0:setString(lang("LEAGUETIP_12"))
    self._pageView = self:getUI("bg.pageView")
    self._saveBtn = self:getUI("bg.saveBtn")
    self._pageView:addEventListener(function(sender, eventType)
        if eventType == 0 then
            self:setSaveBtnStatue()
        end
    end)
    self:registerClickEvent(self._saveBtn,function( )
        self:detectCanSave(true)
    end)
    self._pages = {}
    self._page1 = self:getUI("bg.pageView.page1")
    table.insert(self._pages,self._page1)
    local leagueRankCount = #tab.leagueRank
    for i=1,leagueRankCount-1 do
        local page = self._page1:clone()
        table.insert(self._pages,page)
        self._pageView:addPage(page)
    end
    self:initPages()
end

function LeagueSetSpot:setSaveBtnStatue( )
    local page = self._pageView:getCurPageIndex()+1
    self._saveBtn:setVisible(self._curZone == page and self:detectCanSave() and not self._allreadyFixed)
end

function LeagueSetSpot:resetFixedStatus( )
    self._allCanFixedNum = 0
    self._curZone = self._leagueModel:getData().league.currentZone or 1
    local curZoneHot = self._leagueModel:getCurZoneHot(self._curZone)
    self._preHotStr = curZoneHot and curZoneHot.hot or ""
    local allCanFixedNum = tab:LeagueRank(self._leagueModel:getData().league.currentZone).hotspot
    self._allCanFixedNum = allCanFixedNum or 0
    self._selectLab:setString("已选择(0/".. allCanFixedNum ..")")
    if curZoneHot and curZoneHot.hot and curZoneHot.hot ~= "" then
        local curHots = string.split(curZoneHot.hot,",")
        for k,v in pairs(curHots) do
            self._curSelectHot[tonumber(v)] = true
        end
        if #curHots == allCanFixedNum then
            self._allreadyFixed = true
        end
        self._selectLab:setString("已选择(".. #curHots .. "/".. allCanFixedNum ..")")
    end
end
function LeagueSetSpot:detectCanSave( save )
    local selectIds = ""
    for k,v in pairs(self._selectIcon) do
        if selectIds == "" then 
            selectIds = v._id 
        else
            selectIds =  v._id .. "," .. selectIds
        end
    end
    
    local id = self._leagueModel:getData().league.currentZone
    -- print("··· tostring(selectIds) ~= tostring(self._preHotStr)", tostring(selectIds) ~= tostring(self._preHotStr))
    if selectIds and selectIds ~= "" and (not self._preHotStr or tostring(selectIds) ~= tostring(self._preHotStr)) then
        if save then
            ServerManager:getInstance():sendMsg("LeagueServer", "setHot", {id=id,list = selectIds}, true, {}, function(result)
                    if self and self.resetFixedStatus then
                        self:resetFixedStatus()
                        local tempAr = {}
                        for k,v in pairs(self._selectIcon) do
                            table.insert(tempAr,v)
                        end
                        self._allreadyFixed = #tempAr == self._allCanFixedNum
                        self._tableView:reloadData()
                        self:setSaveBtnStatue()
                        self._viewMgr:showTip(lang("LEAGUETIP_16"))
                        self:updateSelecIcons()
                    end
            end)
        end
        return true
    elseif self._preHotStr and selectIds == tostring(self._preHotStr) then
        return false
    end
    return false
end

function LeagueSetSpot:initPages( )
    for i,page in ipairs(self._pages) do
        self:updatePage(page,self._hotTableData[i])
    end
    self._pageView:scrollToPage(self._curZone-1)
end

local roleBgPos = {
    [1] = {cc.p(375,90)},
    [2] = {cc.p(190,90),cc.p(570,90)},
    [3] = {cc.p(130,90),cc.p(375,90),cc.p(620,90)},
}

function LeagueSetSpot:updatePage( page,data )
    local hotBgNum = data.num
    local offsetX = 740/hotBgNum+375
    local poses = roleBgPos[hotBgNum]
    local hotTeams = {}
    if data.hot and data.hot ~= "" then
        hotTeams = string.split(data.hot ,",")
    end
    page.hotNum = hotBgNum
    local subTitle = page:getChildByName("subTitle")
    if subTitle then
        subTitle:setFontName(UIUtils.ttfName)
        subTitle:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
        subTitle:setString((data.name or "") .. "段位热点")
    end
    self:enableDefaultOutline(page)
    for i=1,hotBgNum do
        local hotBg = ccui.ImageView:create()
        hotBg:loadTexture("asset/uiother/dizuo/heroDizuo.png")
        hotBg:setName("bg" .. i)
        hotBg:setScale(0.6)
        hotBg:setPosition(poses[i])
        hotBg._teamId = tonumber(hotTeams[i])
        page:addChild(hotBg)
        if hotTeams[i] then
            local teamImg = ccui.ImageView:create()
            local teamD = tab:Team(tonumber(hotTeams[i]))
            -- 觉醒
            local teamData = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(tonumber(hotTeams[i]))
            local isAwaked = false
            local awakeArt = nil
            local awakeName = nil
            if teamData then
                isAwaked = TeamUtils:getTeamAwaking(teamData)
                awakeName,_,_,awakeArt = TeamUtils:getTeamAwakingTab(teamData, teamD.id)
            end
            local steam = awakeArt or teamD.steam 
            local filename = "asset/uiother/steam/" .. steam .. ".png"
            local fu = cc.FileUtils:getInstance()
            if not fu:isFileExist(filename) then
                filename = "asset/uiother/steam/" .. steam .. ".jpg"
            end
            -- 觉醒end
            teamImg._id = tonumber(hotTeams[i])
            teamImg:setAnchorPoint(cc.p(0.5,0))
            teamImg:loadTexture(filename)
            teamImg:setPosition(90,20)
            teamImg:setName("teamImg")
            hotBg:addChild(teamImg)
            
        end
        self:registerClickEvent(hotBg,function( )
            local teamImg = hotBg:getChildByName("teamImg")
            local teamId = hotBg._teamId
            if not self._allreadyFixed and teamId and teamImg and not self._curSelectHot[tonumber(hotTeams[i])] and self._pageView:getCurPageIndex()==self._curZone-1 then
                self:removeTeamImg(page,teamId)
                self._selectIcon[teamId] = nil
                self:updateSelecIcons()
                local icon = self:getTeamTableIconById(teamId)
                if icon then
                    icon._select = nil 
                    self._flyId = icon._id
                    local pos1 = icon:getParent():convertToWorldSpace(cc.p(icon:getPositionX(),icon:getPositionY()))
                    local pos2 = self._flyPanel:convertToNodeSpace(pos1)
                    local idx = self:getSelectRoleIdxById(icon._id)
                    self._flyBeginPos = cc.p(roleBgPos[self._allCanFixedNum][idx].x-40,300)
                    self:showFlyAnim(icon._id,pos2)
                    self:baodouReversAnim(icon)
                    self:updateIconState(icon)
                end
            end
        end)
    end
end

function LeagueSetSpot:addTeamToPage( page, teamId)
    local poses = roleBgPos[page.hotNum]
    for i=1,page.hotNum do
        local bg = page:getChildByName("bg" .. i)
        if not bg._teamId then 
            local teamImg = bg:getChildByName("teamImg")
            if teamImg then 
                teamImg:removeFromParent()
            end
            self:showFlyAnim(tonumber(teamId),cc.p(poses[i].x-40,300),function( )
                teamImg = ccui.ImageView:create()
                local teamD = tab:Team(tonumber(teamId))
                -- 觉醒
                local teamData = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(tonumber(teamId))
                local isAwaked = false
                local awakeArt = nil
                local awakeName = nil
                if teamData then
                    isAwaked = TeamUtils:getTeamAwaking(teamData)
                    awakeName,_,_,awakeArt = TeamUtils:getTeamAwakingTab(teamData, teamD.id)
                end
                local steam = awakeArt or teamD.steam 
                local filename = "asset/uiother/steam/" .. steam .. ".png"
                local fu = cc.FileUtils:getInstance()
                if not fu:isFileExist(filename) then
                    filename = "asset/uiother/steam/" .. steam .. ".jpg"
                end
                -- 觉醒end
                teamImg:setAnchorPoint(cc.p(0.5,0))
                teamImg:loadTexture(filename)
                teamImg:setPosition(90,20)
                teamImg:setName("teamImg")
                -- teamImg:setVisible(false)
                bg:addChild(teamImg)
                bg._teamId = tonumber(teamId)
                local teamShowMc = mcMgr:createViewMC("redianshanzhen1_leaguerediantexiao", false, true,function( _,sender )
                -- sender:gotoAndPlay(10)
                end,RGBA8888)
                teamShowMc:setPosition(90,80)
                teamShowMc:setScale(1.5)
                bg:addChild(teamShowMc)
                -- teamImg:setColor(cc.c4b(240, 240, 33, 255))
                teamImg:setBrightness(80)
                teamImg:setOpacity(0)
                teamImg:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.FadeIn:create(0.5),cc.CallFunc:create(function( )
                    teamImg:setVisible(true)
                    teamImg:setBrightness(0)
                end)))
            end)
            break
        end
    end
end

-- 移除mc
function LeagueSetSpot:removeTeamImg( page,teamId )
    for i=1,page.hotNum do
        local bg = page:getChildByName("bg" .. i)
        if not bg then break end
        local teamImg = bg:getChildByName("teamImg")
        if teamImg and bg._teamId == teamId then
            teamImg:setBrightness(180)
            teamImg:setPurityColor(191, 181, 114)
            teamImg:runAction(cc.Sequence:create(
                cc.Spawn:create(cc.ScaleTo:create(0.1,0.8),cc.FadeOut:create(0.4)),
                cc.CallFunc:create(function( )
                    teamImg:removeFromParent()
                end)
            ))
            bg._teamId = nil
            break 
        end
    end 
end

-- 飞入效果及回调
function LeagueSetSpot:showFlyAnim( teamId,targetPos,callback )
    local teamData = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(tonumber(teamId))
    local backQuality = self._modelMgr:getModel("TeamModel"):getTeamQualityByStage(teamData.stage)
    local flyIcon = IconUtils:createTeamIconById({sysTeamData = tab:Team(teamData.teamId),teamData= teamData,quality = backQuality[1], quaAddition = backQuality[2],eventStyle=0,effect = true})
    self._flyPanel:addChild(flyIcon,99999)
    flyIcon:setOpacity(0.8)
    flyIcon:setScale(0.75)
    flyIcon:setPosition(self._flyBeginPos.x,self._flyBeginPos.y)
    -- local pos1 = target:getParent():convertToWorldSpace(cc.p(target:getPositionX(),target:getPositionY()))
    -- local pos2 = self._flyPanel:convertToNodeSpace(pos1)
    -- dump(pos1)
    -- dump(self._flyBeginPos)
    -- dump(pos2)
    self:lock()
    flyIcon:runAction(cc.Sequence:create(cc.MoveTo:create(0.2,targetPos),cc.CallFunc:create(function()
        if callback then
            callback()
        end
        flyIcon:removeFromParent()
        self:unlock()
        self._inSelecting = false
    end)))
end

function LeagueSetSpot:addTableView( )
    local tableView = cc.TableView:create(cc.size(740, 200))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(2,2))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    self._tableBg:addChild(tableView)
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
    tableView:reloadData()
    self._tableView = tableView
    self:updateSelecIcons()
end

function LeagueSetSpot:scrollViewDidScroll(view)
    -- print("scrollViewDidScroll")
    self._isScrolling = view:isDragging()
    if not self._scrollBeginOffset then
        self._scrollBeginOffset = view:getContentOffset()
    end
    self._scrollingOffset = view:getContentOffset()
    -- dump(self._offset)
end

function LeagueSetSpot:scrollViewDidZoom(view)
    -- print("scrollViewDidZoom")
end

function LeagueSetSpot:tableCellTouched(table,cell)
    self._scrollBeginOffset = nil
end

function LeagueSetSpot:cellSizeForTable(table,idx) 
    return 108,630
end

function LeagueSetSpot:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    else
        cell:removeAllChildren()
    end

    for i=1,7 do
        if self._tableData[7*idx+i] then
            local icon = self:createIcon(self._tableData[7*idx+i])
            icon:setPosition(cc.p((i-1)*105+10,6))
            self._allIcons[7*idx+i] = icon
            cell:addChild(icon,99)
            -- self:updateIconState(icon)
        end
    end

    return cell
end

function LeagueSetSpot:numberOfCellsInTableView(table)
   return math.ceil(#self._tableData/7)
end

-- 接收自定义消息
function LeagueSetSpot:reflashUI(data)

end

function LeagueSetSpot:createIcon( data )
	local icon 
	local backQuality = self._modelMgr:getModel("TeamModel"):getTeamQualityByStage(data.stage)
	local tIcon = IconUtils:createTeamIconById({sysTeamData = tab:Team(data.teamId),teamData= data,quality = backQuality[1], quaAddition = backQuality[2],eventStyle=0,effect = false})
	icon = tIcon
	icon._data = data

        
    icon._id = data.teamId
    if self._curSelectHot[tonumber(data.teamId)] then
        local selectD = {}
        self._selectIconSortIdx = self._selectIconSortIdx+1
        selectD._id = icon._id
        selectD._icon = icon
        selectD.sort = self._selectIconSortIdx
        self._selectIcon[icon._id] = selectD
        icon._selected = true
        self:updateSelecIcons()
    end
    -- 只有传奇 可选
    -- if self._otherspot[icon._id] then
    --     icon._other = true
    -- end
    if self._seasonspot[icon._id] then
        icon._season = true
        self:registerClickEvent(icon,function( )
        end)
    else
        self:registerClickEvent(icon,function( )
            if self._scrollingOffset and self._scrollBeginOffset then            
                local x1,y1 = self._scrollingOffset.x,self._scrollingOffset.y
                local x2,y2 = self._scrollBeginOffset.x,self._scrollBeginOffset.y
                self._scrollBeginOffset = nil
                if math.abs(x1-x2) > 5 or math.abs(y1-y2) > 5 then
                    return
                end
            end
            
            -- 不在本页不可选热点
            local curPageIdx = self._pageView:getCurPageIndex()+1
            if curPageIdx ~= self._curZone  then
                self._viewMgr:showTip("本段位不可选择")
                return 
            end
            if self._allreadyFixed or 
                ((table.nums(self._selectIcon)+table.nums(self._curSelectHot)) == self._allCanFixedNum and not self._selectIcon[icon._id]) then
                local str = lang("LEAGUETIP_04")
                str = string.gsub(str,"{$hotspot}",self._allCanFixedNum)
                self._viewMgr:showTip(str)
            end
            if (self._allreadyFixed and not icon._select) or icon._other or icon._season or icon._selected then
                return 
            end
            if not self._selectIcon[icon._id] then
                if table.nums(self._selectIcon) < self._allCanFixedNum then
                    local selectD = {}
                    self._selectIconSortIdx = self._selectIconSortIdx+1
                    selectD._id = icon._id
                    selectD._icon = icon
                    selectD.sort = self._selectIconSortIdx
                    self._selectIcon[icon._id] = selectD
                    icon._select = true
                    self:baodouAnim(icon)
                    self._noFly = false
                    self._hadSave = false
                    audioMgr:playSound("LeagueHotSpot")
                end
            else
                self._selectIcon[icon._id] = nil
                icon._select = nil
                self._noFly = true
                self:baodouReversAnim(icon)
                self._flyId = icon._id
                local pos1 = icon:getParent():convertToWorldSpace(cc.p(icon:getPositionX(),icon:getPositionY()))
                local pos2 = self._flyPanel:convertToNodeSpace(pos1)
                local idx = self:getSelectRoleIdxById(icon._id)
                self._flyBeginPos = cc.p(roleBgPos[self._allCanFixedNum][idx].x-40,300)
                self:showFlyAnim(icon._id,pos2)
                self:removeTeamImg(self._pageView:getPage(self._curZone-1),icon._id)
            end
            self._inSelecting = true
            self:updateIconState(icon)
            if not self._noFly then
                self:addTeamToPage(self._pageView:getPage(self._curZone-1),icon._id)
            end
            self:updateSelecIcons()
            -- 设置保存按钮可见状态
            self:setSaveBtnStatue()
        end)
    end
    icon:setSwallowTouches(false)
    self:updateIconState(icon)
    icon:setSwallowTouches(false)
    icon:setScale(0.8)

    -- 加外饰
    local bg = ccui.ImageView:create()
    bg:loadTexture("hotIconBg_league.png",1)
    bg:setPosition(53,53)
    bg:setScale(1.25)
    
    local dotbg = ccui.ImageView:create()
    dotbg:loadTexture("dotbg_league.png",1)
    dotbg:setPosition(53,0)
    dotbg:setScale(1.25)
    icon:addChild(dotbg,10)
    icon:addChild(bg,-5)
    self:addDotAnim(icon)

	return icon
end

function LeagueSetSpot:addDotAnim( icon )
    if not icon or tolua.isnull(icon) then return end
    if icon._season then 
        if not icon:getChildByName("dotMc") then
            local dotMc =  mcMgr:createViewMC("saijirediandou_leaguerediantexiao", true, false,function( _,sender )
            end,RGBA8888)
            dotMc:setPosition(53,0)
            dotMc:setName("dotMc")
            icon:addChild(dotMc,11)
        end
        if not icon:getChildByName("kuangMc") then
            local kuangMc = mcMgr:createViewMC("saijirediankuang_leaguerediantexiao", true, false,function( _,sender )
            end,RGBA8888)
            kuangMc:setName("kuangMc")
            kuangMc:setScale(1.3)
            kuangMc:setPosition(52,56)
            icon:addChild(kuangMc,-1)
        end
    else
        if not icon:getChildByName("dotMc") 
            and not self._selectFull 
            and not self._otherspot[icon._id] 
            and not self._selectIcon[icon._id] then
            local dotMc =  mcMgr:createViewMC("duanweirediandou_leaguerediantexiao", true, false,function( _,sender )
            end,RGBA8888)
            dotMc:setPosition(53,0)
            dotMc:setName("dotMc")
            icon:addChild(dotMc,11)
        end
        if not icon:getChildByName("kuangMc") and (icon._select or self._selectIcon[icon._id]) then
            local kuangMc = mcMgr:createViewMC("duanweirediankuang_leaguerediantexiao", true, false,function( _,sender )
            end,RGBA8888)
            kuangMc:setName("kuangMc")
            kuangMc:setScale(1.3)
            kuangMc:setPosition(53,56)
            icon:addChild(kuangMc,-1)
        end
    end
    local tempArCount = table.nums(self._selectIcon)
    if tempArCount == self._allCanFixedNum or self._allreadyFixed then
        if not self._selectIcon[icon._id] then
            if icon:getChildByName("dotImg") then
                icon:getChildByName("dotImg"):removeFromParent()
            end
            local dotImg = ccui.ImageView:create()
            dotImg:setName("dotImg")
            dotImg:setPositionX(54)
            dotImg:setScale(1.2)
            dotImg:loadTexture("dot_league.png",1)
            icon:addChild(dotImg,10)
        end
    else
        if icon:getChildByName("dotImg") then
            icon:getChildByName("dotImg"):removeFromParent()
        end
    end
end

function LeagueSetSpot:baodouAnim( icon )
    local clipNode = cc.ClippingNode:create()
    clipNode:setContentSize(cc.size(130,130))
    clipNode:setPosition(52,-10)
    clipNode:setScale(1.33)
    clipNode:setName("clipNode")
    icon:addChild(clipNode,-1)

    local mask = ccui.ImageView:create()
    mask:loadTexture("globalPanelUI7_zhezhao.png",1)
    mask:setColor(cc.c4b(0, 0, 0,255))
    mask:setName("mask")
    -- mask:setContentSize(cc.size(130,130))
    mask:setPosition(0,0)

    mask:setScale(0.5)
    clipNode:setStencil(mask)
    clipNode:setAlphaThreshold(0.05)

    local kuangMc = mcMgr:createViewMC("duanweirediankuang_leaguerediantexiao", true, false,function( _,sender )
    end,RGBA8888)
    kuangMc:setName("kuangMc")
    kuangMc:setPosition(0,50)
    clipNode:addChild(kuangMc,11)

    self:lock(-1)
    local scale = 0.5
    self._baoScheduler = ScheduleMgr:regSchedule(1, self, function( )
        scale = scale+0.2
        if scale >= 5 then
            if self._baoScheduler then 
                ScheduleMgr:unregSchedule(self._baoScheduler)
                self:unlock()
                self._baoScheduler = nil
            end
        else
            mask:setScale(scale)
            clipNode:setStencil(mask)
            clipNode:setAlphaThreshold(0.05)
        end
    end)
    local dotMc = icon:getChildByName("dotMc")
    if dotMc then
        dotMc:removeFromParent()
    end
    local dotBaoMc =  mcMgr:createViewMC("duanweiredianbaodou_leaguerediantexiao", false, true,function( _,sender )
    end,RGBA8888)
    dotBaoMc:setPosition(53,0)
    icon:addChild(dotBaoMc,999)

end

function LeagueSetSpot:baodouReversAnim( icon )
    local clipNode = icon:getChildByName("clipNode")
    if icon:getChildByName("kuangMc") then
        icon:getChildByName("kuangMc"):removeFromParent()
    end
    if not clipNode then
        clipNode = cc.ClippingNode:create()
        clipNode:setContentSize(cc.size(130,130))
        clipNode:setPosition(50,-5)
        clipNode:setScale(1.3)
        clipNode:setName("clipNode")
        icon:addChild(clipNode,-1)

        local mask = ccui.ImageView:create()
        mask:loadTexture("globalPanelUI7_zhezhao.png",1)
        mask:setColor(cc.c4b(0, 0, 0,255))
        mask:setName("mask")
        -- mask:setContentSize(cc.size(130,130))
        mask:setPosition(0,0)

        mask:setScale(5)
        clipNode:setStencil(mask)
        clipNode:setAlphaThreshold(0.05)

        local kuangMc = mcMgr:createViewMC("duanweirediankuang_leaguerediantexiao", true, false,function( _,sender )
        end,RGBA8888)
        kuangMc:setName("kuangMc")
        kuangMc:setPosition(0,50)
        clipNode:addChild(kuangMc,11)
    end
    if clipNode then
        local mask = ccui.ImageView:create()
        mask:loadTexture("globalPanelUI7_zhezhao.png",1)
        mask:setColor(cc.c4b(0, 0, 0,255))
        mask:setName("mask")
        -- mask:setContentSize(cc.size(130,130))
        mask:setAnchorPoint(cc.p(0.5,0))
        mask:setPosition(0,-50)

        mask:setScale(5)
        clipNode:setStencil(mask)
        clipNode:setAlphaThreshold(0.05) 
        self:lock(-1)
        local scale = 2
        self._baoReverseScheduler = ScheduleMgr:regSchedule(10, self, function( )
            scale = scale-0.3
            if scale <= 0.8 then
                scale = scale-0.03
                if mask then
                    mask:setScaleX(scale)
                    clipNode:setStencil(mask)
                    clipNode:setAlphaThreshold(0.05)
                end
                if (scale <= 0.1 or not mask) and self._baoReverseScheduler then 
                    ScheduleMgr:unregSchedule(self._baoReverseScheduler)
                    self:unlock()
                    self._baoReverseScheduler = nil
                    clipNode:removeFromParent()
                    local dotBaoMc =  mcMgr:createViewMC("duanweirediandouchuxian_leaguerediantexiao", false, true,function( _,sender )
                    end,RGBA8888)
                    dotBaoMc:setPosition(53,0)
                    icon:addChild(dotBaoMc,999)
                    self:addDotAnim(icon)
                    for i,icon in ipairs(self._allIcons) do
                        if not tolua.isnull(icon) then
                            if icon:getChildByName("dotMc")and not(self._seasonspot[icon._id] or  self._otherspot[icon._id] or self._curSelectHot[icon._id]) then
                                icon:getChildByName("dotMc"):removeFromParent()
                            end
                            self:addDotAnim(icon)
                        end
                    end
                end
            else
                mask:setScale(scale)
                clipNode:setStencil(mask)
                clipNode:setAlphaThreshold(0.05)
            end
        end)
    end
end

-- 根据teamId索引到icon
function LeagueSetSpot:getTeamTableIconById( teamId )
    for i,icon in ipairs(self._allIcons) do
        if icon._id == teamId then
            return icon
        end
    end
end

-- 
function LeagueSetSpot:getSelectRoleIdxById( teamId )
    local page = self._pageView:getPage(self._curZone-1)
    for i=1,3 do
        local bg = page:getChildByName("bg" .. i)
        if bg and bg._teamId and bg._teamId == teamId then
            return i,bg:getChildByName("teamImg")
        end
    end
    return 1,page:getChildByName("bg1")
end

function LeagueSetSpot:updateIconState(icon)
	local selectTag = icon:getChildByName("selectTag")
	if not selectTag then
        selectTag = ccui.Text:create()
        selectTag:setTextHorizontalAlignment(1)
        selectTag:setName("selectTag")
        selectTag:setFontName(UIUtils.ttfName)
        selectTag:setColor(cc.c3b(0, 255, 30))
        selectTag:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
        selectTag:setFontSize(24)
        -- selectTag:setRotation(41)
        selectTag:setPosition(55,55)
        icon:addChild(selectTag,99)
    end
    local lock = icon:getChildByName("lock")
    if not lock then
        lock = ccui.ImageView:create()
        lock:loadTexture("globalImageUI5_treasureLock.png",1)
        lock:setScale(0.8)
        lock:setName("lock")
        lock:setPosition(90,90)
        icon:addChild(lock,999)
    end
    lock:setVisible(false)
    self:setNodeColor(icon,cc.c3b(255, 255, 255))
    if icon._select or self._selectIcon[icon._id] then
        if self._allreadyFixed or icon._selected then
            selectTag:setString("生效中")
            lock:setVisible(true)
            -- self:setNodeColor(icon,cc.c3b(168, 168, 168))
        else
            if icon:getParent() then
                self._flyId = icon._id
                local pos1 = icon:getParent():convertToWorldSpace(cc.p(icon:getPositionX(),icon:getPositionY()))
                local pos2 = self._flyPanel:convertToNodeSpace(pos1)
                self._flyBeginPos = pos2
            end
            selectTag:setString("预备中")
            self:setNodeColor(icon,cc.c3b(168, 168, 168))
        end
    end

    if icon._selected then
        selectTag:setString("生效中")
    end
    -- seasonspot
    if icon._season then
        selectTag:setString("赛季\n热点")
        selectTag:setColor(cc.c3b(240, 240, 0))
        lock:setVisible(true)
    end

    if icon._other then
        local zone = self._otherspot[icon._id]
        local name = lang(tab:LeagueRank(zone or 1).name)
        selectTag:setString(name .. "\n段位")
        selectTag:setColor(cc.c3b(255, 255, 255))
        self:setNodeColor(icon,cc.c3b(168, 168, 168))
        lock:setVisible(true)
    end

    if icon._select or icon._season or icon._other or self._selectIcon[icon._id] then
        selectTag:setVisible(true)
    else
        selectTag:setVisible(false)
    end
end

function LeagueSetSpot:updateSelecIcons( )
    if not self._hotTableData or not next(self._hotTableData) or not self._hotTableData[self._curZone] then return end
    self._hotTableData[self._curZone]["hot"] = nil
    local hotString = nil
    local tempAr = {}
    for k,v in pairs(self._selectIcon) do
        table.insert(tempAr,v)
    end
    table.sort(tempAr,function( a,b )
        if a.sort and b.sort then
            return a.sort < b.sort
        else
            return a.sort or false
        end
    end)
    if #tempAr > 0 then
        self._selectTail = tempAr[#tempAr]._id
    end
	local idx =1
	for k,icon in ipairs(tempAr) do
        if hotString and hotString ~= "" then
            hotString = hotString  .. "," .. icon._id 
        else
            hotString = icon._id
        end
		idx=idx+1
	end
    self._hotTableData[self._curZone]["hot"] = hotString
    --[[ 更改结构，不更新tableView 更新pageView
    self._hotTableView:reloadData()
    self._hotTableView:setContentOffset(cc.p(-(self._curZone-1)*268,0))
    --]]
    -- self._selectMc:setVisible(false)
    -- 改选择标签
    if not self._allreadyFixed then
        self._selectLab:setString("已选择(".. #tempAr .. "/".. self._allCanFixedNum ..")")
    end
    if #tempAr == self._allCanFixedNum or self._allreadyFixed then
        for i,icon in ipairs(self._allIcons) do
            if not tolua.isnull(icon) and not(self._seasonspot[icon._id] or  self._otherspot[icon._id] or self._curSelectHot[icon._id]) then
                if icon:getChildByName("dotMc") then
                    icon:getChildByName("dotMc"):removeFromParent()
                end
                if not self._selectIcon[icon._id] then
                    if icon:getChildByName("dotImg") then
                        icon:getChildByName("dotImg"):removeFromParent()
                    end
                    local dotImg = ccui.ImageView:create()
                    dotImg:setName("dotImg")
                    dotImg:setPositionX(54)
                    dotImg:setScale(1.2)
                    dotImg:loadTexture("dot_league.png",1)
                    icon:addChild(dotImg,10)
                end
            end
        end
        self._selectFull = true
    else
        self._selectFull = false
        for i,icon in ipairs(self._allIcons) do
            if not tolua.isnull(icon) and icon:getChildByName("dotImg") then
                icon:getChildByName("dotImg"):removeFromParent()
            end
        end
    end
    -- self._allreadyFixed = #tempAr == self._allCanFixedNum
end

-- UE 2.0 新增 逻辑
-- 
function LeagueSetSpot:updateSeasonHot( )
    local batchId = self._leagueModel:getData().batchId 
    local leagueActD = tab:LeagueAct(tonumber(batchId))
    -- 本赛程热点军团展示
    if leagueActD then
        local seasonspot = leagueActD.seasonspot
        if self._leagueModel:getData().first and self._leagueModel:getData().first ~= 0 then
            seasonspot = tab:Setting("G_LEAGUE_FIRST").value
        end
        self._seasonspot = {}
        for i,v in ipairs(seasonspot) do
            self._seasonspot[v] = true
        end
    end
end

function LeagueSetSpot:generateSportData( )
    local hotSpot = {}
    local hotInfo = clone(self._leagueModel:getHot())
    for i=1,9 do
        hotSpot[i] = hotInfo[tostring(i)] or {}
        local leagueRank = tab:LeagueRank(i)
        hotSpot[i].name = lang(leagueRank.name)
        hotSpot[i].num = leagueRank.hotspot
        if hotSpot[i].hot and hotSpot[i].hot ~= "" then
            local hotTeams = string.split(hotSpot[i].hot ,",")
            for i1,v in ipairs(hotTeams) do
                if i ~= tonumber(self._curZone) then
                    self._otherspot[tonumber(v)] = i
                end
            end
        end
    end
    return hotSpot
end


function LeagueSetSpot:setNodeColor( node,color )
    -- if true then return end
    if node and not tolua.isnull(node) then 
        if node:getDescription() ~= "Label" then
            node:setColor(color)
        else
            node:setBrightness(-50)
        end
    end
    local children = node:getChildren()
    if children == nil or #children == 0 then
        return 
    end
    for k,v in pairs(children) do
        self:setNodeColor(v,color)
    end
end
return LeagueSetSpot