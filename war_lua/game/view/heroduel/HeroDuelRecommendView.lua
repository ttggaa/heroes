--
-- Author: <ligen@playcrab.com>
-- Date: 2017-06-15 01:02:24
--
local HeroDuelRecommendView = class("HeroDuelRecommendView", BasePopView)
function HeroDuelRecommendView:ctor()
    HeroDuelRecommendView.super.ctor(self)

    self._titleList = {
        {"玩家","英雄","兵团阵容","胜场"},
        {"排名","兵团","平均单局输出","出场率"},
        {"排名","兵团","平均单局承受","出场率"},
        {"排名","英雄","出场率","胜率"},
    }

    self._picInfo = {
        {path = "asset/uiother/team/t_dafashi.png",flippedX = true, picPos = cc.p(-50, 224),scale = 0.75, 
            dialog = "HERODUEL_CHART1", dialogRect = cc.size(165, 50), dialogPos = cc.p(36, 462),
            bgRect = cc.size(195, 90), bgPos = cc.p(34, 460)},
        {path = "asset/uiother/team/t_shenv.png",flippedX = false, picPos = cc.p(-70, 250),scale = 0.65, 
            dialog = "HERODUEL_CHART2", dialogRect = cc.size(150, 50), dialogPos = cc.p(36, 462),
            bgRect = cc.size(180, 90), bgPos = cc.p(34, 460)},
        {path = "asset/uiother/team/t_tieren.png",flippedX = true, picPos = cc.p(-10, 205),scale = 0.7, 
            dialog = "HERODUEL_CHART3", dialogRect = cc.size(150, 50), dialogPos = cc.p(23, 412),
            bgRect = cc.size(180, 90), bgPos = cc.p(21, 412)},
        {path = "asset/uiother/hero/crusade_Rashka.png",flippedX = false, picPos = cc.p(0, 229),scale = 1, 
            dialog = "HERODUEL_CHART4", dialogRect = cc.size(160, 75), dialogPos = cc.p(36, 420),
            bgRect = cc.size(190, 105), bgPos = cc.p(30, 420)}
    }

    self._rankModel = self._modelMgr:getModel("RankModel")
    self._rankTpList = {
        self._rankModel.kRankDuelRecommend1,
        self._rankModel.kRankDuelRecommend2,
        self._rankModel.kRankDuelRecommend3,
        self._rankModel.kRankDuelRecommend4
    }

    self._rankType = self._rankModel.kRankDuelRecommend1 --英雄交锋最强阵容榜

    self._initTabIndex = 1

    self._hModel = self._modelMgr:getModel("HeroDuelModel")
end

-- 初始化UI后会调用, 有需要请覆盖
function HeroDuelRecommendView:onInit()
    self:registerClickEventByName("bg.layer.closeBtn", function ()
        self:close()
        if OS_IS_WINDOWS then
            package.loaded["game.view.heroduel.HeroDuelRecommendView"] = nil
        end
    end)

    self:getUI("bg.layer.bgImg"):loadTexture("asset/bg/activity_bg_paper.png")
    
    self._tabList = {}
    local btnLabelList = {"大神阵容","最高输出","最高承受","热门英雄"}
    for i = 1, 4 do 
        local btn = self:getUI("bg.layer.btnPanel.btn" .. i)
        btn:getTitleRenderer():setString(btnLabelList[i])
        btn:getTitleRenderer():setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        btn:getTitleRenderer():disableEffect()
        btn.index = i
        table.insert(self._tabList, btn)

        self:registerClickEvent(btn, function()
            self:onChangeTab(btn.index)
        end)
    end

    self._titleBg1 = self:getUI("bg.layer.titleBg1")
    self._titleBg2 = self:getUI("bg.layer.titleBg2")

    self._rolePanel = self:getUI("bg.layer.rolePanel")
    self._dialogBg = self._rolePanel:getChildByFullName("dialogBg")
    self._dialogLabel = self._rolePanel:getChildByFullName("dialogLabel")
    self._dialogLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    for i = 1, 4 do
        self._titleBg1:getChildByFullName("label" .. i):setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        self._titleBg2:getChildByFullName("label" .. i):setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    end

    self._listLayer = self:getUI("bg.layer.listLayer")

    self._godItem = self:getUI("bg.layer.godItem")
    self._godItem:setVisible(false)
    self._normalItem = self:getUI("bg.layer.rankItem")
    self._normalItem:setVisible(false)

    self._noRankImg = self:getUI("bg.layer.noRankImg")
    self._noRankImg:setVisible(false)

    -- 递进刷新控制
	self.beginIdx = tab:Setting("DUEL_LINE2").value
	self.addStep = tab:Setting("DUEL_LINE2").value
	self.endIdx = tab:Setting("DUEL_LINE1").value

    self:addTableView()

    self:onChangeTab(self._initTabIndex)
end

function HeroDuelRecommendView:onChangeTab(index)
    if self._curTabIndex == index then return end

    -- 如果正在发送请求(服务器还没有返回)，不能切换页签
	--self._loadingMc:isVisible() 说明正在滑动tableView，此时切换页签最上面会有留白
	if self._isSending or (self._loadingMc and self._loadingMc:isVisible()) then
		return
	end

	--切页停止滚动
	if self._tableView then
		self._tableView:stopScroll()
	end
	if self._loadingMc and self._loadingMc:isVisible() then
		self._loadingMc:setVisible(false)
	end

	self._rankType = self._rankTpList[index]

    if self._curTabIndex and self._tabList[self._curTabIndex] then
        self:setTabBtnSeleted(self._tabList[self._curTabIndex], false)
    end

    local picInfo = self._picInfo[index]
    if self._rolePic == nil then
        self._rolePic = cc.Sprite:create(picInfo.path)
        self._rolePanel:addChild(self._rolePic, -1)
    else
        self._rolePic:setTexture(picInfo.path)
    end
    self._rolePic:setFlippedX(picInfo.flippedX)
    self._rolePic:setPosition(picInfo.picPos)
    self._rolePic:setScale(picInfo.scale)
    self:setTabBtnSeleted(self._tabList[index], true)

    self._dialogLabel:setString(lang(picInfo.dialog))
    self._dialogLabel:setTextAreaSize(picInfo.dialogRect)
    self._dialogLabel:setPosition(picInfo.dialogPos)

    self._dialogBg:setContentSize(picInfo.bgRect)
    self._dialogBg:setPosition(picInfo.bgPos)

    self._titleBg1:setVisible(index == 1)
    self._titleBg2:setVisible(index ~= 1)

    local curTitleBg = index == 1 and self._titleBg1 or self._titleBg2
    for i = 1, 4 do 
        local label = curTitleBg:getChildByFullName("label" .. i)
        label:setString(self._titleList[index][i])
    end

    self._tableCellH = index == 1 and 150 or 90
    self._tableCellW = 598
    self._cellSpaceH = 3

    self._curTabIndex = index

    self._allRankData = self._rankModel:getRankList(self._rankType)
	self._tableData = {}
	if #self._allRankData < 1 then
		--请求数据点击tab 回调reflashUI里刷新有无排行榜的显示以及数据的刷新
		if self._rankType ~= self._rankInitType then
		    self:sendGetRankMsg(self._rankType,1)
		end
		self._firstIn = true
	else
		self._firstIn = false
		self._tableData = self:updateTableData(self._allRankData,self.beginIdx) 
		-- dump(self._tableData,"self._tableData")
		self._tableView:reloadData()   --jumpToTop
		
		--不请求数据点击tab 刷新有无排行榜的显示
		self:reflashNoRankUI()		
	end
end

-- 接收自定义消息
function HeroDuelRecommendView:reflashUI(data)
	local offsetX = nil
	local offsetY = nil
	if self._offsetX and self._offsetY then
		offsetX = self._offsetX
		offsetY = self._offsetY
	end
    self._allRankData = self._rankModel:getRankList(self._rankType)
    self._tableData = self:updateTableData(self._allRankData, self.beginIdx)
   	-- print("************&&&&&&&&&&&&-----------",#self._tableData)

    dump(self._tableData, "self._tableData", 5)
    if self._tableData and self._tableView then    	
	    self._tableView:reloadData()
	    if offsetX and offsetY and not self._firstIn then
	    	self._tableView:setContentOffset(cc.p(offsetX,offsetY))
			self._canRequest = false
	    end	    
	    self._firstIn = false
	end
end

function HeroDuelRecommendView:updateTableData(rankList,index)
	-- print("*************************",index)
	local data = {}
	for k,v in pairs(rankList) do
		if tonumber(v.rank) <= tonumber(index) then
			data[k] = v
		end
	end
	return data
end

-- 设置标签页选中状态
function HeroDuelRecommendView:setTabBtnSeleted(btn, bool)
    if bool then
        btn:getTitleRenderer():setColor(cc.c3b(196, 73, 4))
        btn:loadTextures("globalPanelUI_activity_selectBtn.png","globalPanelUI_activity_selectBtn.png","",1)
    else
        btn:loadTextures("globalPanelUI_activity_normalBtn.png","globalPanelUI_activity_normalBtn.png","",1)
        btn:getTitleRenderer():setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    end
end

function HeroDuelRecommendView:addTableView( )
	self._tableViewW = 608
	self._tableViewH = 346
    local tableView = cc.TableView:create(cc.size(self._tableViewW, self._tableViewH))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(5,1)
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    -- tableView:setBounceEnabled(false)
    self._listLayer:addChild(tableView)

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

    self._tableView = tableView
end


function HeroDuelRecommendView:createLoadingMc()
    if self._loadingMc then return end
    -- 添加加载中动画
    self._loadingMc = mcMgr:createViewMC("jiazaizhong_rankjiazaizhong", true, false, function (_, sender)      end)
    self._loadingMc:setName("loadingMc")
    self._loadingMc:setPosition(cc.p(self._listLayer:getContentSize().width*0.5 - 30, 0))
    self._listLayer:addChild(self._loadingMc, 1000)
    self._loadingMc:setVisible(false)
end

local maxShowCount = {3,4,4,4}
function HeroDuelRecommendView:scrollViewDidScroll(view)
    self._inScrolling = view:isDragging()

    local offsetY = view:getContentOffset().y       
    if offsetY >= 100 and #self._tableData > 5 and #self._tableData < self.endIdx and not self._canRequest then
        self._canRequest = true
        self:createLoadingMc()
        if not self._loadingMc:isVisible() then
            self._loadingMc:setVisible(true)
        end
    end 
        
    local condY = 0
    if self._tableData and #self._tableData < maxShowCount[self._curTabIndex] then
        -- tableView height 330
        condY = self._tableViewH - #self._tableData*(self._tableCellH+self._cellSpaceH)
    end
    if self._inScrolling then
        if offsetY >= condY+100 and not self._canRequest then
            self._canRequest = true         
            self:createLoadingMc()            
            if not self._loadingMc:isVisible() then
                self._loadingMc:setVisible(true)
            end
        end
        if offsetY < condY+20 and self._canRequest then
            self._canRequest = false
            self:createLoadingMc() 
            if self._loadingMc:isVisible() then
                self._loadingMc:setVisible(false)
            end 
        end
    else
        -- 满足请求更多数据条件
        if self._canRequest and offsetY == condY then       
            self._viewMgr:lock(1)
            self:sendMessageAgain()
            if self._loadingMc:isVisible() then
                self._loadingMc:setVisible(false)
            end     
        end
    end

end

function HeroDuelRecommendView:scrollViewDidZoom(view)
    -- print("scrollViewDidZoom")
end

function HeroDuelRecommendView:tableCellTouched(table,cell)
    print("cell touched at index: " .. cell:getIdx())
end

function HeroDuelRecommendView:cellSizeForTable(table,idx) 
    return self._tableCellH+self._cellSpaceH,self._tableCellW
end

function HeroDuelRecommendView:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
    else
        cell:removeAllChildren()
    end
    local cellData = self._tableData[idx+1]
    local item = nil
    if self._curTabIndex == 1 then
        item = self:createGodItem(cellData,idx+1)
    else
        item = self:createNormalItem(cellData,idx+1)
    end
    item:setPosition(cc.p(0,4))
    item:setAnchorPoint(cc.p(0,0))
    cell:addChild(item)

    return cell
end

function HeroDuelRecommendView:numberOfCellsInTableView(table)
    return #self._tableData 
end

local rankImgs = {"firstImg","secondImg","thirdImg"}
function HeroDuelRecommendView:createGodItem( data,index )
     -- dump(data,"paranm")
    if data == nil then return end
    self._itemData = data

    local item = self._godItem:clone()
    item:setContentSize(self._tableCellW,self._tableCellH)
    item:setVisible(true)

    local headIcon = IconUtils:createHeadIconById({avatar = data.avatar, tp = 4, avatarFrame = data.avatarFrame})
    headIcon:setPosition(28, 55)
    headIcon:setScale(86 / headIcon:getContentSize().width)
    item:addChild(headIcon)

    item:getChildByFullName("serverName"):setString(self._modelMgr:getModel("LeagueModel"):getServerName(data.sec))
    item:getChildByFullName("name"):setString(data.name)

    local heroData = clone(tab:Hero(data.formation.heroId))
    heroData.star = tab:HeroDuel(self._hModel:getWeekNum()).herostar or 0
    local heroIcon = IconUtils:createHeroIconById({sysHeroData = heroData})
    heroIcon:setPosition(208, 89)
    heroIcon:setScale(68 / heroIcon:getContentSize().width)
    item:addChild(heroIcon)

    item:getChildByFullName("heroName"):setString(lang(heroData.heroname))

    item:getChildByFullName("winNum"):setString(tostring(data.wins) .. "胜")
    item:getChildByFullName("loseNum"):setString(tostring(data.loses) .. "负")

    local teamsData = data.formation.teams
    local teamsInfo = data.formation.teamsInfo
    local realW = 56
    local offsetX = 273
    local offsetY = 76
    for tI = 1, #teamsData do
        local teamId = teamsData[tI]
    	local sysTeam = tab:Team(teamId)
        local heroDuelTab = tab:HeroDuel(self._hModel:getWeekNum())
        local quality = self._modelMgr:getModel("TeamModel"):getTeamQualityByStage(heroDuelTab.teamquality)

        local ast = nil
        local aLv = nil
        if teamsInfo and teamsInfo[tostring(teamId)].awaking == 1 then
            ast = 3
            aLvl = tab:HeroDuejx(teamId).aLvl
        end

        local inTeamData = {
            teamId=teamId,
            level=nil,
            star=heroDuelTab.teamstar,
            ast = ast,
            aLvl = aLvl
        }
        local param = {teamData = inTeamData, 
            sysTeamData = sysTeam,
            quality = quality[1], 
            quaAddition = 0,  
            formationType = self._modelMgr:getModel("FormationModel").kFormationTypeHeroDuel,
            eventStyle = 0,
            isCustom = true
        }
        local teamIcon = IconUtils:createTeamIconById(param)
        teamIcon:setPosition(offsetX+(tI-1)%4*(realW+3), offsetY-math.floor((tI-1)/4)*(realW+5))
        teamIcon:setScale(realW / teamIcon:getContentSize().width)
        item:addChild(teamIcon)
    end


    --启动特权类型
----	 data["tequan"] = "sq_gamecenter"
--	local tequanImg = IconUtils.tencentIcon[data["tequan"]] or "globalImageUI6_meiyoutu.png"
--	local tequanIcon = ccui.ImageView:create(tequanImg, 1)
--    tequanIcon:setScale(0.65)
--    tequanIcon:setPosition(cc.p(233, item:getContentSize().height*0.5 - 22))
--	item:addChild(tequanIcon)

----    data["qqVip"] = "is_qq_svip"
--    local qqVipImg = (data["qqVip"] and data["qqVip"] ~= "") and IconUtils.tencentIcon[data["qqVip"] .. "_head"] or "globalImageUI6_meiyoutu.png"
--    local qqVipIcon = ccui.ImageView:create(qqVipImg, 1)
--    qqVipIcon:setScale(24 / qqVipIcon:getContentSize().width)
--    qqVipIcon:setPosition(cc.p(nameLab:getPositionX() + nameLab:getContentSize().width*0.5 + 16, item:getContentSize().height*0.5 + 5))
--	item:addChild(qqVipIcon)

    return item
end

local keyList = {
    {},
    {value1 = "average", value2 = "roundsRate"},
    {value1 = "average", value2 = "roundsRate"},
    {value1 = "roundsRate", value2 = "winRate"}
}
function HeroDuelRecommendView:createNormalItem( data,index )
     -- dump(data,"paranm")
    if data == nil then return end
    self._itemData = data

    local item = self._normalItem:clone()
    item:setContentSize(self._tableCellW,self._tableCellH)
    item:setVisible(true)


    local rank = data.rank
    for i=1,3 do
        local rankImg = item:getChildByFullName(rankImgs[tonumber(i)])
        rankImg:setVisible(false)
    end

    local rankLab = item:getChildByName("rankLab")
    if rankImgs[tonumber(rank)] then
        rankLab:setVisible(false)
        local rankImg = item:getChildByFullName(rankImgs[tonumber(rank)])
        rankImg:setVisible(true)
    else
        rankLab:setVisible(true)
        rankLab:setString(tostring(rank))
    end
    item:setSwallowTouches(false)


    if string.len(data.id) == 5 then
        local heroData = clone(tab:Hero(data.id))
        heroData.star = tab:HeroDuel(self._hModel:getWeekNum()).herostar or 0
        local heroIcon = IconUtils:createHeroIconById({sysHeroData = heroData})
        heroIcon:setPosition(221, 47)
        heroIcon:setScale(72 / heroIcon:getContentSize().width)
        item:addChild(heroIcon)

        self:registerClickEvent(heroIcon, function()
            local NewFormationIconView = require "game.view.formation.NewFormationIconView"
            local param = {
                isCustom = true, 
                iconType = NewFormationIconView.kIconTypeHero, 
                iconId = data.id,
                formationType = self._modelMgr:getModel("FormationModel").kFormationTypeHeroDuel
                }
            self._viewMgr:showDialog("formation.NewFormationDescriptionView", param, true)
        end)

    else
        local teamId = data.id
        local sysTeam = tab:Team(teamId)
        local heroDuelTab = tab:HeroDuel(self._hModel:getWeekNum())
        local quality = self._modelMgr:getModel("TeamModel"):getTeamQualityByStage(heroDuelTab.teamquality)

        local ast = nil
        local aLv = nil
        if data["awaking"] == 1 then
            ast = 3
            aLvl = tab:HeroDuejx(teamId).aLvl
        end

        local inTeamData = {
            teamId=teamId,
            level=nil,
            star=heroDuelTab.teamstar,
            ast = ast,
            aLvl = aLvl
        }
        local param = {teamData = inTeamData, 
            sysTeamData = sysTeam,
            quality = quality[1], 
            quaAddition = 0,  
            formationType = self._modelMgr:getModel("FormationModel").kFormationTypeHeroDuel,
            eventStyle = 1,
            isCustom = true
        }
        local teamIcon = IconUtils:createTeamIconById(param)
        teamIcon:setPosition(185, 9)
        teamIcon:setScale(72 / teamIcon:getContentSize().width)
        item:addChild(teamIcon)
    end

    local valueStr1 = ""
    local valueStr2 = ""

    valueStr1 = data[keyList[self._curTabIndex].value1]
    valueStr2 = data[keyList[self._curTabIndex].value2]

    if string.find(keyList[self._curTabIndex].value1, "Rate") then
        valueStr1 = valueStr1 .. "%"
    end

    if string.find(keyList[self._curTabIndex].value2, "Rate") then
        valueStr2 = valueStr2 .. "%"
    end

    local valueLabel1 = item:getChildByFullName("value1")
    local valueLabel2 = item:getChildByFullName("value2")
    valueLabel1:setString(valueStr1)
    valueLabel2:setString(valueStr2)

    if self._curTabIndex == 2 and tostring(data.id) == "605" then
        local cureIcon = cc.Sprite:createWithSpriteFrameName("icon_cure_heroDuel.png")
        cureIcon:setPosition(valueLabel1:getPositionX() - valueLabel1:getContentSize().width*0.5 - 25, valueLabel1:getPositionY())
        item:addChild(cureIcon)
    end

    return item
end

function HeroDuelRecommendView:reflashNoRankUI()
    if (not self._tableData or #self._tableData <= 0) then
        self._noRankImg:setVisible(true)
        self._listLayer:setVisible(false)
    else
        self._noRankImg:setVisible(false)
        self._listLayer:setVisible(true)
    end
end

--是否要刷新排行榜
function HeroDuelRecommendView:sendMessageAgain()
    -- self.beginIdx -- self.endIdx -- self.addStep
    self._allRankData = self._rankModel:getRankList(self._rankType)
    local starNum = self._rankModel:getRankNextStart(self._rankType)
    local statCount = tonumber(self.beginIdx)
    local endCount = tonumber(self.endIdx)
    local addCount = tonumber(self.addStep)

    if #self._tableData == #self._allRankData and #self._allRankData%addCount == 0 and #self._allRankData < endCount then
        --如果本地没有更多数据则向服务器请求
        self:sendGetRankMsg(self._rankType,starNum,function()
            if #self._allRankData > statCount then
                self:searchForPosition(statCount,addCount,endCount)
            end
            self._viewMgr:unlock()
        end)
    else
    --  if #self._allRankData > statCount then
    --      self:searchForPosition(statCount,addCount,endCount)     
    --      self:reflashUI()
    --  end     
        self._canRequest = false
        self._viewMgr:unlock()
    end
end
--刷新之后tableView 的定位
function HeroDuelRecommendView:searchForPosition(statCount,addCount,endCount)   
    self._offsetX = 0
    if statCount + addCount <= endCount then
        self.beginIdx = statCount + addCount
        local subNum = #self._allRankData - statCount

        if subNum < addCount then
            self._offsetY = -1 * (tonumber(subNum) * (self._tableCellH+self._cellSpaceH))          
        else
            self._offsetY = -1 * (tonumber(self.addStep) * (self._tableCellH+self._cellSpaceH))            
        end
        
    else
        self.beginIdx = endCount
        self._offsetY = -1 * (endCount - statCount) * (self._tableCellH+self._cellSpaceH)
    end
end
--获取当前排行榜数据
function HeroDuelRecommendView:sendGetRankMsg(tp,start,callback)
	self._isSending = true
	self._rankModel:setRankTypeAndStartNum(tp,start)
	self._serverMgr:sendMsg("RankServer", "getRankList", {type=tp,startRank = start}, true, {}, function(result) 
		if callback then
			callback()
		end
		self:reflashUI()
		self:reflashNoRankUI()
		self._isSending = false
    end)
end

function HeroDuelRecommendView:onDestroy()
    self._rankModel:clearRankList()
    HeroDuelRecommendView.super.onDestroy(self)
end

function HeroDuelRecommendView:dtor()
    maxShowCount = nil
    keyList = nil
    HeroDuelRecommendView = nil
end
return HeroDuelRecommendView