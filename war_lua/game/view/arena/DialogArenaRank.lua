--[[
    Filename:    DialogArenaRank.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2015-10-29 10:24:13
    Description: File description
--]]

local DialogArenaRank = class("DialogArenaRank",BasePopView)
function DialogArenaRank:ctor()
    self.super.ctor(self)
    self._arenaModel = self._modelMgr:getModel("ArenaModel")
end

-- 初始化UI后会调用, 有需要请覆盖
function DialogArenaRank:onInit()
	self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
        UIUtils:reloadLuaFile("arena.DialogArenaRank")
    end)
	local rankInfo = self._arenaModel:getArenaRank()
	if not rankInfo or #rankInfo == 0 then
		-- self:sendGetRankMsg()
		self._rankSchedule = ScheduleMgr:regSchedule(50, self, function(self, dt)
  	        local rankInfo = self._arenaModel:getArenaRank()
			if rankInfo and #rankInfo > 0 then
				ScheduleMgr:unregSchedule(self._rankSchedule)
				self:reflashUI()
			end
  	    end)
	end
	self._leftBoard = self:getUI("bg.leftBoard")
	self._leftBoard:setZOrder(5)

    self._noRankBg = self:getUI("bg.noRankBg")
    self._noRankBg:setVisible(false)
    self._titleBg = self:getUI("bg.titleBg")    

    self:registerClickEventByName("bg.selfAward.ruleBtn", function ()
        self._viewMgr:showDialog("arena.ArenaRuleView")
    end)

    self._rankItem = self:getUI("bg.rankItem")
    -- self._rankItem:setVisible(false)
    self._tableNode = self:getUI("bg.tableNode")
    self._tableCellW,self._tableCellH = self._rankItem:getContentSize().width-18,self._rankItem:getContentSize().height
    self._selfAward = self:getUI("bg.selfAward")
    self._selfAward:setVisible(false)

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
	self:listenReflash("ArenaModel", self.reflashUI)

	-- 递进刷新控制
	self.beginIdx = 1
	self.endIdx = 30
	self.addStep = 30

    self._tableData = self._arenaModel:getArenaRank()
	self:addTableView()
end

local rankImgs = {"firstImg","secondImg","thirdImg"}
function DialogArenaRank:reflashUserInfo()
	self._selfAward:setVisible(true)
	local item  = self._rankItem
	local arenaD = self._arenaModel:getArena()
	local rank = math.min(self._arenaModel:getData().rank,10000)
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
		rankLab:setString(rank)
		-- if rank <= 3 and rank > 0 then
		-- 	item:loadTexture("arenaRankUI_cellBg1.png",1)
		-- else
			-- item:loadTexture("arenaRankUI_cellBg5.png",1)
		-- end
		if rankImgs[tonumber(rank)] then
			rankLab:setVisible(false)
			local rankImg = item:getChildByFullName(rankImgs[tonumber(rank)])
			rankImg:setVisible(true)
		else
			rankLab:setVisible(true)
			if rank > 999 then
				-- rankLab:setScale(0.7)
			end
			rankLab:setPosition(70,45)
		end
	end
	local txt  = item:getChildByFullName("rankTxt")
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
		txt:setPosition(rankLab:getPositionX()+8, rankLab:getPositionY()-10)
		txt:setFontName(UIUtils.ttfName)
		txt:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
		-- txt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
		item:addChild(txt)		
	end

	local nameLab = item:getChildByFullName("nameLab")
	local levelLab = item:getChildByFullName("levelLab")
	local UIscoreLab = item:getChildByFullName("scoreLab")
	nameLab:setVisible(false)
	levelLab:setVisible(false)
	UIscoreLab:setVisible(false)
	local destxt = self._selfAward:getChildByFullName("destxt") 
	local arenaHonor = clone(tab["arenaHonor"])
	if rank == 0 or not rank then
		local awardTxt1 = self._selfAward:getChildByFullName("awardTxt1")  --钻石
        -- awardTxt1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        awardTxt1:setString(arenaHonor[1].diamond or 0)
        local awardTxt2 = self._selfAward:getChildByFullName("awardTxt2")  --金币
        -- awardTxt2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        awardTxt2:setString(arenaHonor[1].gold or 0)
       	local awardTxt3 = self._selfAward:getChildByFullName("awardTxt3")  --竞技币
        -- awardTxt3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        awardTxt3:setString(arenaHonor[1].currency or 0)
        destxt:setString("排名进入" .. arenaHonor[1].pos[2] .. "名可获得：")
    else
		for k,v in pairs(arenaHonor) do
			local pos = v.pos
			if tonumber(rank) >= tonumber(pos[1]) and tonumber(rank) <= tonumber(pos[2]) then
				local awardTxt1 = self._selfAward:getChildByFullName("awardTxt1")  --钻石
		        -- awardTxt1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
		        awardTxt1:setString(v.diamond or 0)
		        local awardTxt2 = self._selfAward:getChildByFullName("awardTxt2")  --金币
		        -- awardTxt2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
		        awardTxt2:setString(v.gold or 0)
		       	local awardTxt3 = self._selfAward:getChildByFullName("awardTxt3")  --竞技币
		        -- awardTxt3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
		        awardTxt3:setString(v.currency or 0)
		        break
		    end
		end
	end
	--[[
	-- 不显示玩家信息  changed by huang 7.27
	local userData = self._modelMgr:getModel("UserModel"):getData()
	local nameLab = item:getChildByFullName("nameLab")
	-- nameLab:enableOutline(cc.c4b(61,37,17,255),2)
	nameLab:setString(userData.name)
	local levelLab = item:getChildByFullName("levelLab")
	-- levelLab:enableOutline(cc.c4b(61,37,17,255),2)
	levelLab:setString(userData.lvl)
	-- 战斗力
	local UIscoreLab = item:getChildByFullName("scoreLab")
	local fightNum = self:getMyDefScore()
	UIscoreLab:setString(fightNum)
	--]]

	-- local formationModel = self._modelMgr:getModel("FormationModel")
 --    local data = formationModel:getFormationData()[formationModel.kFormationTypeArenaDef]
 --    local fightCapacity = 0
 --    local teamModel = self._modelMgr:getModel("TeamModel")
 --    if data then
 --        table.walk(data, function(v, k)
 --            if 0 == v then return end
 --            if string.find(tostring(k), "team") and not string.find(tostring(k), "g") then
 --                local teamData = teamModel:getTeamAndIndexById(v)
 --                fightCapacity = fightCapacity + teamData.score
 --            end
 --        end)
 --        local heroData = self._modelMgr:getModel("HeroModel"):getData()[tostring(data.heroId)]
 --        fightCapacity = fightCapacity + heroData.score + self._modelMgr:getModel("TreasureModel"):getTreasureScore()
	-- 	local UIscoreLab = item:getChildByFullName("scoreLab")
	-- 	UIscoreLab:setString(fightCapacity)
 --    end
end

function DialogArenaRank:getMyDefScore( )
	-- 战斗力
	local formationModel = self._modelMgr:getModel("FormationModel")
    -- local data = formationModel:getFormationData()[formationModel.kFormationTypeArenaDef]
    local fightCapacity = formationModel:getCurrentFightScoreByType(formationModel.kFormationTypeArenaDef)
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

function DialogArenaRank:reflashNo1( data )
	if not data then return end
	local name = self._leftBoard:getChildByFullName("name")
	name:setString(data.name)
	local level = self._leftBoard:getChildByFullName("level")
	level:setString("等级:" .. (data.lvl or ""))
	local guild = self._leftBoard:getChildByFullName("guild")
	local guildDes = self._leftBoard:getChildByFullName("guildDes")
	local guildName = data.guildName
	if guildName and guildName ~= "" then 
		guild:setVisible(true)
		local nameLen = utf8.len(guildName)
		if nameLen > 6 then
			guildName = string.sub(guildName,1,15) .. "..."
		end
		guild:setString("" .. (guildName or ""))
		guildDes:setVisible(true)
	else
		guild:setVisible(false)
		guildDes:setVisible(false)
	end
		
	-- local avatarName = data.avatar
	-- if avatarName == 0 then avatarName = 1203 end
	-- local icon = IconUtils:createHeadIconById({avatar = avatarName,tp = 3,avatarFrame=data["avatarFrame"]}) 
	-- icon:setAnchorPoint(cc.p(0.5,0.5))
	-- -- icon:setScale(1.212)
	-- icon:setPosition(100,410)
	-- self._leftBoard:addChild(icon)
	--左侧人物形象
	local heroId = data.fHeroId  or 60001
    local heroD = tab:Hero(heroId)
    local heroArt = heroD["heroart"]
    if data.heroSkin then
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
		self._serverMgr:sendMsg("ArenaServer", "getDetailInfo", {roleId = data.rid}, true, {}, function(result) 
				local info = result.info
				-- dump(result,"arenarank !!!!!!!!!!!!!!!!!!!!",10)
				info.battle.msg = info.msg
				info.battle.rank = info.rank
				local data = clone(info.battle)
				-- data.isNotShowBtn = true
				-- print("==========================",data.isNotShowBtn)
				self._viewMgr:showDialog("arena.DialogArenaUserInfo",data,true)
		    end)
	end)
end

function DialogArenaRank:addTableView( )
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

function DialogArenaRank:scrollViewDidScroll(view)
	self._inScrolling = view:isDragging()
    self:setSlider()
end

function DialogArenaRank:scrollViewDidZoom(view)
    -- print("scrollViewDidZoom")
end

function DialogArenaRank:tableCellTouched(table,cell)
    print("cell touched at index: " .. cell:getIdx())
end

function DialogArenaRank:cellSizeForTable(table,idx) 
    return self._tableCellH+5,self._tableCellW
end

function DialogArenaRank:tableCellAtIndex(table, idx)
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

function DialogArenaRank:numberOfCellsInTableView(table)
	-- print("#self._tableData",#self._tableData)
	return #self._tableData
	-- if #self._tableData > 0 then
	-- 	return 3
	-- else
	-- 	return 0
	-- end
end

function DialogArenaRank:setSlider( )
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
function DialogArenaRank:reflashUI(data)
	self:reflashUserInfo()
	local arenaD = self._arenaModel:getArena()
	local rank = math.min(self._arenaModel:getData().rank,10000)	

    self._tableData = self._arenaModel:getArenaRank()
    if self._tableData then
	    self._tableView:reloadData()
	end
	self:reflashNo1(self._tableData[1])

	if not self._tableData or #self._tableData <= 0 then
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
	-- local rankData = self._arenaModel:getArenaRank() 
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
function DialogArenaRank:createItem( data,index )
	if data == nil then return end	
	-- self._selfAward:setVisible(false)
	local item = self._rankItem:clone()
	item:setContentSize(self._tableCellW,self._tableCellH)
	item:setVisible(true)
	item.data = data
	local rank = math.min(data.rank,10000)
	local score = data.score
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
	if rank == self._modelMgr:getModel("ArenaModel"):getRank() then
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

	-- self:getBmpFromNum(rank,rankLab)
	local levelLab = item:getChildByFullName("levelLab")
	-- levelLab:setString(data.lvl or "")
	local guildName = data.guildName
	levelLab:setVisible(true)
	if guildName and guildName ~= "" then 
		local nameLen = utf8.len(guildName)
		if nameLen > 6 then
			guildName = string.sub(guildName,1,15) .. ""
		end
		levelLab:setString(guildName or "")
	else
		levelLab:setString("尚未加入")
	end
	
	for i=1,3 do
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
		rankLab:setVisible(true)
		item:loadTexture("globalPanelUI7_cellBg21.png",1)
		rankLab:setPosition(60,45)
	end
	item:setCapInsets(cc.rect(20,20,1,1))
	item:setSwallowTouches(false)
	self:registerClickEvent(item,function( )
		if not self._inScrolling then
			-- dump(data)
			self._serverMgr:sendMsg("ArenaServer", "getDetailInfo", {roleId = data.rid}, true, {}, function(result) 
				local info = result.info
				-- dump(result,"!!!!!!!!!!!!!!!!!!!",10)
				info.battle.msg = info.msg
				info.battle.rank = info.rank
				local data1 = clone(info.battle)
				-- dump(data,"data==>>")
				
				-- data1.usid = 
				-- data.isNotShowBtn = true
				-- print("==========================",data.isNotShowBtn)
				self._viewMgr:showDialog("arena.DialogArenaUserInfo",data1,true)
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
    tequanIcon:setPosition(cc.p(246, item:getContentSize().height*0.5 - 22))
	item:addChild(tequanIcon)

--    data["qqvip"] = "is_qq_svip"
--    local qqVipImg = (data["qqVip"] and data["qqVip"] ~= "") and IconUtils.tencentIcon[data["qqvip"] .. "_head"] or "globalImageUI6_meiyoutu.png"
--    local qqVipIcon = ccui.ImageView:create(qqVipImg, 1)
--    qqVipIcon:setScale(24 / qqVipIcon:getContentSize().width)
--    qqVipIcon:setPosition(cc.p(nameLab:getPositionX() + nameLab:getContentSize().width + 16, item:getContentSize().height*0.5 + 5))
--	item:addChild(qqVipIcon)

	return item
end

function DialogArenaRank:createRoleHead(data,headNode,scaleNum)
	local avatarName = data.avatar
	local scale = scaleNum and scaleNum or 0.8
	if avatarName == 0 or not avatarName then avatarName = 1203 end	
	local lvl = data.lvl

    local tencetTp = data["qqVip"]
	local icon = IconUtils:createHeadIconById({avatar = avatarName,tp = 3 ,level = lvl,avatarFrame = data["avatarFrame"], tencetTp = tencetTp})
	icon:setName("avatarIcon")
	icon:setAnchorPoint(cc.p(0.5,0.5))
	icon:setScale(scale)
	icon:setPosition(headNode:getContentSize().width*0.5,headNode:getContentSize().height*0.5 - 2)
	headNode:addChild(icon)
end

function DialogArenaRank:getBmpFromNum( num,node,offsetx )
	offsetx = offsetx or 0
	local width = 0
	local widget = node or ccui.Widget:create()
	local numStr = tostring(num)
	local numSps = {}
	local endPos = string.len(numStr)
	local pos = 1
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
function DialogArenaRank:sendGetRankMsg()
	self._serverMgr:sendMsg("ArenaServer", "getRank", {}, true, {}, function(result) 
		self:reflashUI()
    end)
end

return DialogArenaRank