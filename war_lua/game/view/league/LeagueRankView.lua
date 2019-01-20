--[[
    Filename:    LeagueRankView.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2016-08-16 22:53:18
    Description: File description
--]]

local LeagueRankView = class("LeagueRankView",BasePopView)
function LeagueRankView:ctor()
    self.super.ctor(self)
    self._leagueModel = self._modelMgr:getModel("LeagueModel")
end

-- 初始化UI后会调用, 有需要请覆盖
function LeagueRankView:onInit()
	self:registerClickEventByName("bg.closeBtn", function ()
		self._leagueModel:clearRankList()
        self:close()
        UIUtils:reloadLuaFile("league.LeagueRankView")
    end)
	local rankInfo = self._leagueModel:getRank()
	if not rankInfo or #rankInfo == 0 then
		-- self:sendGetRankMsg()
		self._rankSchedule = ScheduleMgr:regSchedule(50, self, function(self, dt)
  	        local rankInfo = self._leagueModel:getRank()
			if rankInfo and #rankInfo > 0 then
				ScheduleMgr:unregSchedule(self._rankSchedule)
				self:reflashUI()
			end
  	    end)
	end
	self._bgPanel = self:getUI("bg")
	self._leftBoard = self:getUI("bg.leftBoard")
	self._leftBoard:setZOrder(5)
    self._rankItem = self:getUI("bg.rankItem")
    -- [[换rankLab
    local rankLab = self._rankItem:getChildByName("rankLab")
	if rankLab then
		rankLab:removeFromParent()
	end
	if not rankLab then
		rankLab = cc.Label:createWithTTF("", UIUtils.ttfName, 28) --cc.LabelBMFont:create("4", UIUtils.bmfName_rank)
	    rankLab:setAnchorPoint(cc.p(0.5,0.5))
	    rankLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
	    rankLab:setPosition(70, 0)
	    rankLab:setName("rankLab")
	    self._rankItem:addChild(rankLab, 1)
	end
	--]]
    self._selfAward = self:getUI("bg.selfAward")

    self._noRankBg = self:getUI("bg.noRankBg")
    self._noRankBg:setVisible(false)
    self._titleBg = self:getUI("bg.titleBg")    

    self:registerClickEventByName("bg.selfAward.ruleBtn", function ()
    	local weekDay =tonumber(TimeUtils.date("%w",self._modelMgr:getModel("UserModel"):getCurServerTime()))
		local weekHour =tonumber(TimeUtils.date("%H",self._modelMgr:getModel("UserModel"):getCurServerTime()))
    	local showAwardFirst = weekDay == 0 and weekHour >= 5
        self._viewMgr:showDialog("league.LeagueRuleView",{showAwardFirst=showAwardFirst})
    end)
    -- self._rankItem:setVisible(false)
    self._tableNode = self:getUI("bg.tableNode")
    self._tableCellW,self._tableCellH = self._rankItem:getContentSize().width-18,self._rankItem:getContentSize().height
  
    -- listView事件
    self._sliderBg = self:getUI("bg.sliderBg")
	self._sliderBar = self:getUI("bg.sliderBg.sliderBar")
	
	-- self._listView = self:getUI("bg.listView")
 --    self._listView:addScrollViewEventListener(function(sender, eventType)
 --    	if eventType == 6 then
 --    		self:reflashUI()
 --    	end
	-- 	self:setSlider()
 --    end)
    
	-- 暂时不做监听刷新
	self:listenReflash("LeagueModel", self.reflashUI)

	-- 递进刷新控制
	self.beginIdx = 1
	self.endIdx = 30
	self.addStep = 30

    self._tableData = self._leagueModel:getRank()
    self._offsetY = nil
	self:addTableView()

end

local rankImgs = {"firstImg","secondImg","thirdImg"}
function LeagueRankView:reflashUserInfo()
	self._selfAward:setVisible(true)
	local item  = self._rankItem
	local leagueD = self._leagueModel:getLeague()
	local rank = self._leagueModel:getData().rank or  self._leagueModel:getData().historyRank
	-- dump( self._leagueModel:getData())
	local rankLab = item:getChildByName("rankLab")
	if not rankLab then
		-- rankLab = cc.LabelBMFont:create("4", UIUtils.bmfName_rank)
		--    rankLab:setAnchorPoint(cc.p(0.5,0.5))
		--    rankLab:setPosition(60, 50)
		--    rankLab:setName("rankLab")
		--    item:addChild(rankLab, 1)

	    rankLab = cc.Label:createWithTTF("", UIUtils.ttfName, 28) --cc.LabelBMFont:create("4", UIUtils.bmfName_rank)
	    rankLab:setAnchorPoint(cc.p(0.5,0.5))
	    rankLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
	    rankLab:setPosition(70, 0)
	    rankLab:setName("rankLab")
	    item:addChild(rankLab, 1)
	end
	-- rankLab:setScale(0.9)
	if rank then  
		-- if rank > 9999 then 
		-- 	local rankNumLab = self:getBmpFromNum(rank,rankLab)
		-- 	rankNumLab:setScale(0.8)
		-- elseif rank > 999 then
		-- 	local rankNumLab = self:getBmpFromNum(rank,rankLab,-20)
		-- 	rankNumLab:setScale(0.9)
		-- else
		-- 	self:getBmpFromNum(rank,rankLab)
		-- end
		rankLab:setString(rank)
		-- if rank <= 3 then
		-- 	item:loadTexture("arenaRankUI_cellBg".. rank ..".png",1)
		-- else
			-- item:loadTexture("arenaRankUI_cellBg5.png",1)
		-- end
		for i=1,3 do
			local rankImg = item:getChildByFullName(rankImgs[tonumber(i)])
			rankImg:setVisible(false)
		end
		if rankImgs[tonumber(rank)] then
			rankLab:setVisible(false)
			local rankImg = item:getChildByFullName(rankImgs[tonumber(rank)])
			rankImg:setVisible(true)
		else
			rankLab:setVisible(true)
			if rank > 999 then
				rankLab:setScale(0.7)
			end
			rankLab:setPosition(70,45)
		end
	end
	local txt = item:getChildByFullName("rankTxt")
	if txt then
		txt:setVisible(false)
		txt:removeFromParent()
	end

	if not rank or rank > 9999 or rank == 0 or rank == "" then
		rankLab:setVisible(false)	

		local txt = ccui.Text:create()
		txt:setName("rankTxt")
		txt:setString("暂未上榜")
		txt:setFontSize(30)
		txt:setPosition(rankLab:getPositionX()+10, rankLab:getPositionY()-10)
		txt:setFontName(UIUtils.ttfName)
		txt:setColor(UIUtils.colorTable.ccUIBaseColor1)
		txt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
		item:addChild(txt)		
	end

	local nameLab = item:getChildByFullName("nameLab")
	local levelLab = item:getChildByFullName("levelLab")
	local UIscoreLab = item:getChildByFullName("scoreLab")
	nameLab:setVisible(false)
	levelLab:setVisible(false)
	UIscoreLab:setVisible(false)
	local destxt = self._selfAward:getChildByFullName("destxt") 
	local leagueHonor = clone(tab["leagueHonor"])
	if rank == 0 or not rank then
		local awardTxt1 = self._selfAward:getChildByFullName("awardTxt1")  --钻石
        awardTxt1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        awardTxt1:setString(leagueHonor[1].diamond or 0)
        local awardTxt2 = self._selfAward:getChildByFullName("awardTxt2")  --金币
        awardTxt2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        awardTxt2:setString(leagueHonor[1].gold or 0)
       	local awardTxt3 = self._selfAward:getChildByFullName("awardTxt3")  --竞技币
        awardTxt3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        awardTxt3:setString(leagueHonor[1].currency or 0)
        destxt:setString("排名进入" .. leagueHonor[1].pos[2] .. "名可获得：")
    else
		for k,v in pairs(leagueHonor) do
			local pos = v.pos
			if tonumber(rank) >= tonumber(pos[1]) and tonumber(rank) <= tonumber(pos[2]) then
				local awardTxt1 = self._selfAward:getChildByFullName("awardTxt1")  --钻石
		        awardTxt1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
		        awardTxt1:setString(v.diamond or 0)
		        local awardTxt2 = self._selfAward:getChildByFullName("awardTxt2")  --金币
		        awardTxt2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
		        awardTxt2:setString(v.gold or 0)
		       	local awardTxt3 = self._selfAward:getChildByFullName("awardTxt3")  --竞技币
		        awardTxt3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
		        awardTxt3:setString(v.currency or 0)
		        break
		    end
		end
	end

	local leagueRank = tab:LeagueRank( self._leagueModel:getLeague().currentZone or 1)
	-- TimeUtils.date 格式化出来的是 0到6
	local weekDay =tonumber(TimeUtils.date("%w",self._modelMgr:getModel("UserModel"):getCurServerTime()))
	local weekHour =tonumber(TimeUtils.date("%H",self._modelMgr:getModel("UserModel"):getCurServerTime()))
	local awards = leagueRank.weeklyawards
	print("weekday",weekDay,weekHour)
	if weekDay ~= 0 or weekDay == 0 and weekHour < 5 then
		destxt:setString("+　")
		local rtx = RichTextFactory:create( "[color = ffffff,fontsize=22,outlinecolor=3d1f00ff]保持[color = 00ff1e,fontsize=22,outlinecolor=3d1f00ff]" .. lang(leagueRank.name) .. "[-]段位可获得：[-]", 300, 40)
        rtx:formatText()
        rtx:setVerticalSpace(7)
        rtx:setName("rtx")
        local w = rtx:getInnerSize().width
	    local h = rtx:getInnerSize().height
        rtx:setPosition(cc.p(w/2, 10))
        rtx:setSaturation(0)
        destxt:addChild(rtx, 99)
		-- destxt:setString("保持" .. lang(leagueRank.name) .. "段位可获得：")
	end
	if weekDay == 0 and weekHour >= 5 then  
		local honorD = self:getInRangeData(rank)
		awards = honorD.monthlyawards
		if destxt:getChildByName("rtx") then
			destxt:getChildByName("rtx"):removeFromParent()
		end
		-- if rank then
			destxt:setString(lang("LEAGUETIP_17") or "保持当前排名可获得：")
		-- end
	end
	self:reflashAwardImg(awards)
	self:registerClickEvent(item,function( )
		-- print("==========*********************")
		-- local rid = self._modelMgr:getModel("UserModel"):getData()._id
		-- self._serverMgr:sendMsg("LeagueServer", "GetInfo", {id = rid}, true, {}, function(result) 
		-- 	-- dump(data,"data==?")
		-- 	if next(result) then
		-- 		local data1 = clone(result)
		-- 		data1.rank = 1
		-- 		data1.isNotShowBtn = true
		-- 		self._viewMgr:showDialog("arena.DialogArenaUserInfo",data1,true)
		-- 	end
	 --    end)		
       
	end)
end

function LeagueRankView:getInRangeData( rank )
    local leagueHonor = tab["leagueHonor"]
    for i,honorD in ipairs(leagueHonor) do
        local low,high = honorD.pos[1],honorD.pos[2]
        if rank >= low and rank <= high then
            return honorD
        end
    end
end

function LeagueRankView:reflashAwardImg( awards )
    if not awards then return end
    local images = {}
    local awardNum = {}
    if awards then
        for i,v in ipairs(awards) do
            if v[1] == "tool" and v[2] ~= 3002 and v[2] ~= 3004 then
                local toolD = tab:Tool(v[2])
                local filename = IconUtils.iconPath .. toolD.art .. ".png"
                local sfc = cc.SpriteFrameCache:getInstance()
                if not sfc:getSpriteFrameByName(filename) then
                    filename = IconUtils.iconPath .. toolD.art .. ".jpg"
                end
                table.insert(images,filename)
            elseif v[2] == 3002 then
                table.insert(images,"globalImageUI_herosplice1.png")
            elseif v[2] == 3004 then
                table.insert(images,"globalImageUI_fashujuanzhou.png")
            else
                table.insert(images,IconUtils.resImgMap[v[1]])
            end
            table.insert(awardNum,v[3])
        end
    end
    for i=1,3 do
    	local awardImg = self._selfAward:getChildByName("awardImg" .. i)
    	awardImg:loadTexture(images[i],1)
    	awardImg:setScale(math.floor((32/awardImg:getContentSize().width)*100)/100)
    	local awardTxt = self._selfAward:getChildByName("awardTxt" .. i)
    	awardTxt:setString(awardNum[i])
    end
end

function LeagueRankView:getMyDefScore( )
	-- 战斗力
	local formationModel = self._modelMgr:getModel("FormationModel")
    -- local data = formationModel:getFormationData()[formationModel.kFormationTypeleagueDef]
    local fightCapacity = formationModel:getCurrentFightScoreByType(formationModel.kFormationTypeleagueDef)
	  --   local teamModel = self._modelMgr:getModel("TeamModel")
	  --   if data then
	  --       table.walk(data, function(v, k)
	  --           if 0 == v then return end
	  --           if string.find(tostring(k), "team") and not string.find(tostring(k), "g") then
	  --               local teamData = teamModel:getTeamAndIndexById(v)
	  --               fightCapacity = fightCapacity + teamData.score
	  --           end
	  --       end)
	  --       local heroData = self._modelMgr:getModel("HeroModel"):getData()[tostring(data.heroId)]
	  --       fightCapacity = fightCapacity + heroData.score + self._modelMgr:getModel("TreasureModel"):getTreasureScore()
			-- -- local UIscoreLab = item:getChildByFullName("scoreLab")
			-- -- UIscoreLab:setString(fightCapacity)
	  --   end
    return fightCapacity
end

function LeagueRankView:reflashNo1( data )
	local name = self._leftBoard:getChildByFullName("name")
	local level = self._leftBoard:getChildByFullName("level")
	local guild = self._leftBoard:getChildByFullName("guild")
	local guildDes = self._leftBoard:getChildByFullName("guildDes")
	local detailBtn = self._leftBoard:getChildByFullName("showDetail")
	local guildBg = self._leftBoard:getChildByFullName("guildBg")	
	local levelBg = self._leftBoard:getChildByFullName("levelBg")	
	guildBg:setVisible(false)
	levelBg:setVisible(false)
	detailBtn:setVisible(false)
	name:setString("暂无榜首")
	level:setString("")	
	guild:setString("")
	guildDes:setString("")
	
	if not data then return end
	-- levelBg:setVisible(true)
	-- detailBtn:setVisible(true)
	name:setString(data.name)
	local inParam = {lvlStr = "Lv." .. (data.level or data.lvl or 0), lvl = (data.level or data.lvl or 0), plvl = data.plvl}
    UIUtils:adjustLevelShow(level, inParam, 1)
	local guildName = data.guildName 	
	if guildName and guildName ~= "" then 
		guild:setVisible(true)
		guildBg:setVisible(true)
		local nameLen = utf8.len(guildName)
		if nameLen > 6 then
			guildName = string.sub(guildName,1,15) .. "..."
		end
		guildDes:setString("联盟:")
		guild:setString("" .. (guildName or ""))
	else
		guild:setVisible(false)
		guildBg:setVisible(false)
	end
		
	-- local avatarName = data.avatar
	-- if avatarName == 0 then avatarName = 1203 end	
	-- local icon = IconUtils:createHeadIconById({avatar = avatarName,tp = 3,avatarFrame = data["avatarFrame"]}) 
	-- icon:setAnchorPoint(cc.p(0.5,0.5))
	-- -- icon:setScale(1.21)
	-- icon:setPosition(130,410)
	-- self._leftBoard:addChild(icon)
	--左侧人物形象
	dump(data,"----------fheroId")
	local heroId = data.fHeroId  or 60001
    local heroD = tab:Hero(heroId)
    local heroArt = heroD["heroart"]
    if data.heroSkin and data.heroSkin ~= 0 then
        local heroSkinD = tab.heroSkin[data.heroSkin]
        heroArt = (heroSkinD and heroSkinD["heroart"]) and heroSkinD["heroart"] or heroD["heroart"]
    end
    local sp = mcMgr:createViewMC("stop_" .. heroArt, true)
    sp:setScale(0.8)
    sp:setAnchorPoint(0.5,0)
    sp:setPosition(self._leftBoard:getContentSize().width*0.5, self._leftBoard:getContentSize().height*0.5 - 30)
    self._leftBoard._roleAnim = sp
    self._leftBoard:addChild(sp,0)
	self:registerClickEventByName("bg.leftBoard",function( )
		self._serverMgr:sendMsg("LeagueServer", "GetInfo", {id = data.rid,sec=data.sec}, true, {}, function(result) 
			-- dump(data,"data==?")
			if next(result) then
				local data1 = clone(result)
				data1.rank = 1
				data1.isNotShowBtn = true
				self._viewMgr:showDialog("arena.DialogArenaUserInfo",data1,true)
			end
	    end)
	end)
end

function LeagueRankView:addTableView( )
	self._tableViewH = 350
    local tableView = cc.TableView:create(cc.size(660, self._tableViewH))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(5,6))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    self._tableNode:addChild(tableView,999)
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
    -- tableView:reloadData()
end

function LeagueRankView:createLoadingMc()
	if self._loadingMc then return end
	-- 添加加载中动画
    self._loadingMc = mcMgr:createViewMC("jiazaizhong_rankjiazaizhong", true, false, function (_, sender)      end)
    self._loadingMc:setPosition(cc.p(self._tableNode:getContentSize().width * 0.5 - 30, self._tableNode:getPositionY() + 20))
    self._bgPanel:addChild(self._loadingMc, 20)
    self._loadingMc:setVisible(false)
end

function LeagueRankView:scrollViewDidScroll(view)
	self._inScrolling = view:isDragging()
    self:setSlider()

	local offsetY = view:getContentOffset().y

    local condY = 0
    if self._tableData and #self._tableData < 4 then
    	condY = self._tableViewH - #self._tableData*(self._tableCellH+5)
    end
    if self._inScrolling then
	    if offsetY >= condY+100 and not self._canRequest then
            self._canRequest = true
            self:createLoadingMc()
            self._loadingMc:setVisible(true)
        end
        if offsetY <= condY+20 and self._canRequest then
            self._canRequest = false
            self:createLoadingMc()
            self._loadingMc:setVisible(false)
        end

    else
        if self._canRequest and condY == offsetY then
            self._canRequest = false
            -- 请求数据
            self:createLoadingMc()
            self._loadingMc:setVisible(false)
            if self._updateRankTick == nil or socket.gettime() > self._updateRankTick + 5 then
                self:sendGetRankMsg()
                self._updateRankTick = socket.gettime()
  			else
  				print("===========请求过于频繁==============")
            end            
        end

    end

end

function LeagueRankView:scrollViewDidZoom(view)
    -- print("scrollViewDidZoom")
end

function LeagueRankView:tableCellTouched(table,cell)
    print("cell touched at index: " .. cell:getIdx())
end

function LeagueRankView:cellSizeForTable(table,idx) 
    return self._tableCellH+5,self._tableCellW
end

function LeagueRankView:tableCellAtIndex(table, idx)
    local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
    else
    	cell:removeAllChildren()
    end
    local cellData = self._tableData[idx+1]
    local item = self:createItem(cellData,idx+1)
    item:setPosition(cc.p(5,4))
    item:setAnchorPoint(cc.p(0,0))
    cell:addChild(item)

    return cell
end

function LeagueRankView:numberOfCellsInTableView(table)
	-- print("#self._tableData",#self._tableData)
	return #self._tableData
	-- if #self._tableData > 0 then
	-- 	return 3
	-- else
	-- 	return 0
	-- end
end

function LeagueRankView:setSlider( )
	if not self._sliderBarScope then
		local sliderBgH = self._sliderBg:getContentSize().height
		local sliderBarH = self._sliderBar:getContentSize().height
	    self._sliderBarScope = sliderBgH - sliderBarH
	end

	local containerOffsetY = self._tableView:getContentOffset().y --self._listView:getInnerContainer():getPositionY()
	local totalHeight =  #self._tableData*self._tableCellH - 427 --self._listView:getInnerContainer():getContentSize().height-self._listView:getContentSize().height
	local offsetY = math.abs((containerOffsetY/totalHeight)*self._sliderBarScope)
	-- print("offsetY....",offsetY)
	if containerOffsetY > 0 then offsetY = 0 end
	if containerOffsetY <= -totalHeight then offsetY = self._sliderBarScope end
	self._sliderBar:setPositionY(offsetY)
end
-- 接收自定义消息
function LeagueRankView:reflashUI(data)
	local offsetY = self._offsetY
	self:reflashUserInfo()
	local leagueD = self._leagueModel:getLeague()
	local rank = self._leagueModel:getData().rank	

    self._tableData = self._leagueModel:getRank()
    if self._tableData then
	    self._tableView:reloadData()
	    if offsetY then
	    	self._tableView:setContentOffset(cc.p(0,offsetY))
	    end
	end
	self:reflashNo1(self._tableData[1])
	-- dump(self._tableData,"-====>>",5)
	-- print("===========reflashUI()=======",#self._tableData)
	if not self._tableData or not next(self._tableData) then
		self._rankItem:setVisible(false)
		self._noRankBg:setVisible(true)
		self._titleBg:setVisible(false)
		-- self._norankFlag = UIUtils:addBlankPrompt( self._noRankBg,{scale = 0.7,x=180,y=245,des="排行榜还没有整理完成哦~"} )
	else
		-- if self._norankFlag then
		-- 	self._norankFlag:removeFromParent()
		-- 	self._norankFlag = nil
		-- end
		self._rankItem:setVisible(true)
		self._noRankBg:setVisible(false)
		self._titleBg:setVisible(true)
	end
	-- local rankData = self._leagueModel:getRank() 
	-- if rankData == nil or #rankData == 0 or self.endIdx == #rankData then 
	-- 	return 
	-- end

	-- for i=self.beginIdx,self.endIdx do
	-- 	self:createItem(rankData[i])
	-- end
	-- self.beginIdx = self.endIdx+1
	-- self.endIdx = self.endIdx+self.addStep
	-- -- self:setSlider()
	-- if self.endIdx == #rankData then self.endIdx = #rankData end
	
end

local rankTextColor = {cc.c4b(254, 203, 34, 255),cc.c4b(183, 215, 215, 255),cc.c4b(253, 156, 87, 255)}
function LeagueRankView:createItem( data,index )
	if data == nil then return end
	data.league = data.league or {}	-- 做容错无此字段时不显示内容
	-- self._selfAward:setVisible(false)
	local item = self._rankItem:clone()
	item:setVisible(true)
	item:setContentSize(self._tableCellW,self._tableCellH)
	
	item.data = data
	local rank = data.rank
	local score = lang(tab:LeagueRank(data.league.currentZone or 1).name)
	local name = data.name
	-- local unionLab = data.unionName or "没有工会"
	
	local nameLab = item:getChildByFullName("nameLab")
	-- nameLab:enableOutline(cc.c4b(61,37,17,255),2)
	nameLab:setVisible(true)
	nameLab:setString(name)
	local selfTag = item:getChildByFullName("selfTag")
	selfTag:setVisible(false)
	local UIscoreLab = item:getChildByFullName("scoreLab")
	UIscoreLab:setVisible(true)
	-- UIscoreLab:setVisible(false)
	-- local scoreLab = ccui.TextBMFont:create("0", UIUtils.bmfName_zhandouli_little)
 -- 	scoreLab:setScale(0.8)
	-- scoreLab:setPosition(UIscoreLab:getPosition())
	-- UIscoreLab:getParent():addChild(scoreLab,1)
	-- scoreLab:enableOutline(cc.c4b(3,2,0,255), 2)	
	-- scoreLab:setColor(cc.c3b(250, 250, 58))
	-- scoreLab:enable2Color(1, cc.c4b(239, 149, 52, 255))
	-- scoreLab:setString(score)
	UIscoreLab:setString(score)

	local txt  = item:getChildByFullName("rankTxt")
	if txt then
		txt:setVisible(false)
	end
	if rank == self._modelMgr:getModel("LeagueModel"):getRank() then
		local UIscoreLab = item:getChildByFullName("scoreLab")
		local fightNum = self:getMyDefScore()
		UIscoreLab:setString(fightNum)
	end
	local rankLab = item:getChildByName("rankLab")
	if not rankLab then
		-- rankLab = cc.LabelBMFont:create("4", UIUtils.bmfName_rank)
		--    rankLab:setAnchorPoint(cc.p(0.5,0.5))
		--    rankLab:setPosition(60, 50)
		--    rankLab:setName("rankLab")
		--    item:addChild(rankLab, 1)

	    rankLab = cc.Label:createWithTTF("", UIUtils.ttfName, 28) --cc.LabelBMFont:create("4", UIUtils.bmfName_rank)
	    rankLab:setAnchorPoint(cc.p(0.5,0.5))
	    rankLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
	    rankLab:setPosition(70, 0)
	    rankLab:setName("rankLab")
	    item:addChild(rankLab, 1)
	end

	rankLab:setString(rank or 0)
	local levelLab = item:getChildByFullName("levelLab")
	-- levelLab:setString(data.lvl or "")
	-- local guildName = data.guildName
	levelLab:setVisible(true)
	levelLab:setString(data.league.historyPoint or "")
	-- if guildName and guildName ~= "" then 
	-- 	local nameLen = utf8.len(guildName)
	-- 	if nameLen > 6 then
	-- 		guildName = string.sub(guildName,1,15) .. ""
	-- 	end
	-- 	levelLab:setString(guildName or "")
	-- else
	-- 	levelLab:setString("尚未加入")
	-- end
	
	for i=1,3 do
		-- print("=============",rankImgs[tonumber(rank)])
		local rankImg = item:getChildByFullName(rankImgs[tonumber(i)])
		rankImg:setVisible(false)
	end
	if rankImgs[tonumber(rank)] then
		rankLab:setVisible(false)
		local rankImg = item:getChildByFullName(rankImgs[tonumber(rank)])
		-- rankImg:setScale(2)
		rankImg:setVisible(true)
		item:loadTexture("globalPanelUI7_cellBg21.png",1)
	else
		item:loadTexture("globalPanelUI7_cellBg21.png",1)
		rankLab:setVisible(true)
		rankLab:setPosition(60,45)
	end
	item:setCapInsets(cc.rect(20,20,1,1))
	item:setSwallowTouches(false)
	self:registerClickEvent(item,function( )
		if not self._inScrolling then
			self._serverMgr:sendMsg("LeagueServer", "GetInfo", {id = data.rid,sec=data.sec}, true, {}, function(result) 
				-- dump(data,"data==?")
				if next(result) then
					local data1 = clone(result)
					data1.rank = rank
					data1.isNotShowBtn = true
					self._viewMgr:showDialog("arena.DialogArenaUserInfo",data1,true)
				end
		    end)
        else
            self._inScrolling = false
        end
	end)
	item:setSwallowTouches(false)
	-- 创建头像
	local headNode = item:getChildByFullName("headNode")
	headNode:setVisible(true)
	self:createRoleHead(data,headNode,0.6)

    --启动特权类型
--	data["tequan"] = "sq_gamecenter"
	local tequanImg = IconUtils.tencentIcon[data["tequan"]] or "globalImageUI6_meiyoutu.png"
	local tequanIcon = ccui.ImageView:create(tequanImg, 1)
    tequanIcon:setScale(0.65)
    tequanIcon:setPosition(cc.p(270, item:getContentSize().height*0.5 - 22))
	item:addChild(tequanIcon)

	return item
end

function LeagueRankView:createRoleHead(data,headNode,scaleNum)
	local avatarName = data.avatar
	local scale = scaleNum and scaleNum or 0.8
	if avatarName == 0 or not avatarName then avatarName = 1203 end	
	local lvl = data.lvl

    local tencetTp = data["qqVip"]
	local icon = IconUtils:createHeadIconById({avatar = avatarName,tp = 3 ,level = lvl,avatarFrame = data["avatarFrame"], tencetTp = tencetTp, plvl = data.plvl})
	icon:setName("avatarIcon")
	icon:setAnchorPoint(cc.p(0.5,0.5))
	icon:setScale(scale)
	icon:setPosition(headNode:getContentSize().width*0.5,headNode:getContentSize().height*0.5 - 2)
	headNode:addChild(icon)
end

function LeagueRankView:getBmpFromNum( num,node,offsetx )
	offsetx = offsetx or 0
	local width = 0
	local widget = node or ccui.Widget:create()
	local numStr = tostring(num)
	local numSps = {}
	local endPos = string.len(numStr)
	local pos = 1
	-- print("num",num,".....")
	while pos <= endPos do
		local numC = string.sub(numStr,pos,pos)
		if numC then 
			local numSp = ccui.ImageView:create("arenaRankUI_" .. numC .. ".png",1)
			numSp:setAnchorPoint(cc.p(0,0.5))
			numSp:setPosition(width+offsetx,numSp:getContentSize().height/2)
			widget:addChild(numSp)
			width = width+numSp:getContentSize().width
			table.insert(numSps,numSp)
		end
		pos = pos+1
	end

	-- for i,sp in ipairs(numSps) do
	-- 	sp:setPositionX(sp:getPositionX()-width/2)
	-- 	widget:addChild(sp)
	-- end
	return widget
end
--刷新之后tableView 的定位
function LeagueRankView:searchForPosition()	
	self._tableData = self._leagueModel:getRank()

	local tab = self._leagueModel:getCurrRankTab()
	local subNum = #self._tableData - (tab - 1)*20
	if subNum < 20 then
		self._offsetY = -1 * (tonumber(subNum) * (self._tableCellH+5))			
	else
		self._offsetY = -1 * 20 * (self._tableCellH+5)			
	end
	
end
function LeagueRankView:sendGetRankMsg()
	local tab = self._leagueModel:getNextRankTab()
	self._serverMgr:sendMsg("LeagueServer", "getRank", {page=tab}, true, {}, function(result) 
		--如果返回结果不为空，更新tableView		
		if next(result) then
			self:searchForPosition()
			self:reflashUI()
		end
    end)
end

return LeagueRankView