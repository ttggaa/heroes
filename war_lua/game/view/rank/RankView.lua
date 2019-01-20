--
-- Author: <wangguojun@playcrab.com>
-- Date: 2016-06-25 13:18:54
--

-- [6] = titleBgX
local titleTable = {
	[1] = {[1]="排名",[2]="角色名",[4]="战斗力",[6] = 1},    --战斗力
	[2] = {[1]="排名",[2]="角色名",[3]="兵团",[4]="战斗力",[6] = 2},		--兵团
	[3] = {[1]="排名",[2]="角色名",[3]="英雄",[4]="战斗力",[6] = 2},		--英雄
	[4] = {[1]="排名",[2]="联盟",[4]="总战斗力",[6] = 1},	--联盟（工会）
	[5] = {[1]="排名",[2]="角色名",[4]="总得星",[6] = 1},	--闯关
	[6] = {[1]="排名",[2]="角色名",[4]="宝物总战力",[6] = 1},--宝物
	[25] = {[1]="排名",[2]="角色名",[3]="觉醒数量",[4]="当前觉醒",[5]="觉醒进度",[6] = 3},--觉醒
	[30] = {[1]="排名",[2]="角色名",[4]="器械总战力",[6] = 1},--器械
}
local payerShow = clone(tab:Setting("G_RANK_PLAYERS_SHOW").value)
local teamShow = clone(tab:Setting("G_RANK_TEAMS_SHOW").value)
local heroShow = clone(tab:Setting("G_RANK_HEROES_SHOW").value)
local guildShow = clone(tab:Setting("G_RANK_GUILD_SHOW").value)
local artifactShow = clone(tab:Setting("G_RANK_ARTIFACT_SHOW").value)
local awakingShow = clone(tab:Setting("G_RANK_AWAKING_SHOW").value)

local weaponShow = clone(tab:Setting("G_RANK_AWAKING_SHOW").value)

local showTable = {
	[1] = {payerShow[1],payerShow[2]},    		--战斗力
	[2] = {teamShow[1],teamShow[2]},			--兵团
	[3] = {heroShow[1],heroShow[2]},			--英雄
	[4] = {guildShow[1],guildShow[2]},			--联盟（工会）
	[5] = {payerShow[1],payerShow[2]},			--闯关
	[6] = {artifactShow[1],artifactShow[2]},	--宝物
	[25] = {awakingShow[1],awakingShow[2]}, 	--觉醒
	[30] = {weaponShow[1],weaponShow[2]}, 		--器械
}

local titleTxt = {
	[1] = "战力",    	--战斗力
	[2] = "兵团",		--兵团
	[3] = "英雄",		--英雄
	[4] = "联盟",		--联盟（工会）
	[5] = "闯关",		--闯关
	[6] = "宝物",		--宝物
	[25] = "觉醒",		--觉醒
	[30] = "器械",		--器械
}

-- 排行榜类型与item的对应关系
local itemIdx = {
	[1] = "1",    	--战斗力
	[2] = "2",		--兵团
	[3] = "2",		--英雄
	[4] = "3",		--联盟（工会）
	[5] = "1",		--闯关
	[6] = "1",		--宝物
	[25] = "4", 	--觉醒
	[30] = "1", 	--器械
}

-- 页签 排行榜类型 映射
local typeIdx = {
	[1] = 1,    	--战斗力
	[2] = 2,		--兵团
	[3] = 25,		--觉醒
	[4] = 3,		--英雄
	[5] = 4,		--联盟（工会）
	[6] = 5,		--闯关
	[7] = 6,		--宝物
	[8] = 30,		--器械
}
local upateItemIdx = {
	[1] = "1",    	--战斗力
	[2] = "2",		--兵团
	[3] = "3",		--英雄
	[4] = "4",		--联盟（工会）
	[5] = "1",		--闯关  同战力
	[6] = "1",		--宝物  同战力
	[25] = "25", 	--觉醒
	[30] = "1", 	--器械  同战力
}
local tabNum = 8
local tabVisibleNum = 8
local RankView = class("RankView",BaseView)
function RankView:ctor(param)
    self.super.ctor(self)
    self.initAnimType = 1
	param = param or {}
	self._rankType = param.rankType 
	self._rankInitType = param.rankType or 1
    self._arenaModel = self._modelMgr:getModel("ArenaModel")
    self._rankModel = self._modelMgr:getModel("RankModel")

    self._intanceModel = self._modelMgr:getModel("IntanceModel")
    self._maxLevelStarArr = self._intanceModel:getSectionMaxStar()
end

function RankView:getAsyncRes()
    return 
    {
        {"asset/ui/arena.plist", "asset/ui/arena.png"},
        {"asset/ui/alliance2.plist", "asset/ui/alliance2.png"},        
    }
end

function RankView:getBgName()
    return "bg_007.jpg"
end

function RankView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{types = {"Physcal","Gold","Gem"},title = "globalTitleUI_rank.png",titleTxt = "排行榜" ,callback = function()
    	-- print("==============bg.closeBtn============")
    		self._rankModel:clearRankList()
    	end})
end

function RankView:setNoticeBar()
    self._viewMgr:hideNotice(true)
end

function RankView:onBeforeAdd(callback, errorCallback)
	if self._rankType then
		local curRankData = self._rankModel:getRankList(self._rankType)
		local curStart = self._rankModel:getRankNextStart(self._rankType)
		print("RankView:onBeforeAdd..................")
	    if #curRankData < 1 then
	        self:sendGetRankMsg(self._rankType,curStart,function (_error)
	            if _error then
	                errorCallback()
	                return
	            end
	            callback()
	        end)
	    else
	        self:reflashUI()
	        callback()
	    end
	else
		callback()
	end
end

-- 初始化UI后会调用, 有需要请覆盖
function RankView:onInit()
	-- 通用动态背景
    self:addAnimBg()

	self._itemData = nil
	self._bgPanel = self:getUI("bg.bgPanel")
	self._leftBoard = self:getUI("bg.bgPanel.leftBoard")
	self._leftBoard:setZOrder(5)
	self._noRankBg = self:getUI("bg.bgPanel.noRankBg")
	self._noRankBg:setTouchEnabled(true)
	self._noRankBg:setSwallowTouches(false)
	self._noRankBg:setVisible(false)
	self._titleBg1 = self:getUI("bg.bgPanel.titleBg1")
	self._titleBg2 = self:getUI("bg.bgPanel.titleBg2")
	self._titleBg3 = self:getUI("bg.bgPanel.titleBg3")
	self._titleBg1:setVisible(false)
	self._titleBg2:setVisible(false)
	self._titleBg3:setVisible(false)

	self._selfItem1 = self:getUI("bg.bgPanel.selfItem1")
    self._selfItem2 = self:getUI("bg.bgPanel.selfItem2")
    self._selfItem3 = self:getUI("bg.bgPanel.selfItem3")
    self._selfItem4 = self:getUI("bg.bgPanel.selfItem4")
    local awakingNum = self._selfItem4:getChildByFullName("awakingNum")
	awakingNum:setPositionX(awakingNum:getPositionX() + 8)
	local nameLab = self._selfItem4:getChildByFullName("nameLab")
	nameLab:setPositionX(nameLab:getPositionX() - 20)
    self._selfItem1:setVisible(false)
	self._selfItem2:setVisible(false)
	self._selfItem3:setVisible(false)
	self._selfItem4:setVisible(false)

    self._rankItem1 = self:getUI("bg.bgPanel.rankItem1")
    self._rankItem2 = self:getUI("bg.bgPanel.rankItem2")
    self._rankItem3 = self:getUI("bg.bgPanel.rankItem3")
    self._rankItem4 = self:getUI("bg.bgPanel.rankItem4")
	self._rankItem1:setVisible(false)
	self._rankItem2:setVisible(false)
	self._rankItem3:setVisible(false)
	self._rankItem4:setVisible(false)

    self._guildPanel = self:getUI("bg.bgPanel.guildPanel")
    self._guildPanel:setVisible(false)
    self._guildPanel:setSwallowTouches(true)
    self._noRank = self:getUI("bg.bgPanel.guildPanel.noRank")
    self._noRank:setFontSize(22)
    self._applyBtn = self:getUI("bg.bgPanel.guildPanel.applyBtn")
    registerClickEvent(self._applyBtn,function(sender) 
		-- print("========跳转去加入联盟=====")
		local isOpen,toBeOpen = SystemUtils["enableGuild"]()
		if not isOpen then 
			self._viewMgr:showTip(lang("TIPS_RANK_03"))  
			return 
		end
		local userData = self._modelMgr:getModel("UserModel"):getData()
        if not userData.guildId or userData.guildId == 0 then
        	self._rankModel:clearRankList()
        	self:close()
            ViewManager:getInstance():showView("guild.join.GuildInView")            
        end
	end)

    self._tableNode = self:getUI("bg.bgPanel.tableNode")
    self._tableCellW,self._tableCellH = self._rankItem1:getContentSize().width,self._rankItem1:getContentSize().height  
    
	-- 暂时不做监听刷新
	-- self:listenReflash("ArenaModel", self.reflashUI)

	self._tableData = {}
	-- 递进刷新控制
	self.beginIdx = {
		[1] = showTable[1][1],
		[2] = showTable[2][1],
		[3] = showTable[3][1],
		[4] = showTable[4][1],
		[5] = showTable[5][1],
		[6] = showTable[6][1],
		[25] =showTable[25][1],
		[30] =showTable[30][1]
	}
	self.addStep = {
		[1] = showTable[1][1],
		[2] = showTable[2][1],
		[3] = showTable[3][1],
		[4] = showTable[4][1],
		[5] = showTable[5][1],
		[6] = showTable[6][1],
		[25] =showTable[25][1],
		[30] =showTable[30][1]
	}
	self.endIdx = {
		[1] = showTable[1][2],
		[2] = showTable[2][2],
		[3] = showTable[3][2],
		[4] = showTable[4][2],
		[5] = showTable[5][2],
		[6] = showTable[6][2],
		[25] =showTable[25][2],
		[30] =showTable[30][2]
	}

	self._clickItemData = nil
    
    self._allRankData = self._rankModel:getRankList(self._rankType or 1)

    self._offsetX = nil
    self._offsetY = nil
    self._tableView = nil
	self:addTableView()

	self._tabs = {}
	local tab1 = self:getUI("bg.bgPanel.tab1")	
	local tab8 = self:getUI("bg.bgPanel.tab8")	
	local offsetY = tabNum == tabVisibleNum and 0 or 30
	local posY = tab1:getPositionY() - offsetY
	local subY = posY - tab8:getPositionY()
	local disY = subY / (tabVisibleNum - 1)
	for i=1,tabNum do			
		local tab = self:getUI("bg.bgPanel.tab" .. i)		
		if i > tabVisibleNum then
			tab:setVisible(false)

		else
			tab:setPositionY(posY - (i -1)*disY)
			-- table.insert(self._tabs,tab)
			self._tabs[typeIdx[i]] = tab
			tab:setTitleFontName(UIUtils.ttfName)
	        -- tab:setTitleFontSize(28)
			-- self:registerClickEvent(tab,function( )
			-- 	--切页签音效
			-- 	audioMgr:playSound("Tab")
			-- 	self:touchTab(i)
			-- end)
			UIUtils:setTabChangeAnimEnable(tab,685,function( )
				audioMgr:playSound("Tab")
				self:touchTab(typeIdx[i])
			end,nil,true)
		end
	end
	self._tabs[self._rankType or 1]._appearSelect = true
	self:touchTab(self._rankType or 1)
end

function RankView:touchTab( idx )
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

	self._rankType = idx 
	-- print("==================",self._rankType)
	local tabBtn = self._tabs[idx]
	for k,v in pairs(self._tabs) do
		if k ~= idx then
			 local text = v:getTitleRenderer()
            v:setTitleColor(UIUtils.colorTable.ccUITabColor1)
            text:disableEffect()
			-- tabTxt:setString(titleTxt[tonumber(k)])
			v:setEnabled(true)
			v:setBright(true)
			v:loadTextureNormal("TeamBtnUI_tab_n.png",1)
		end
	end
	if self._preBtn then
		UIUtils:tabChangeAnim(self._preBtn,nil,true,true)
	end
	self._preBtn = tabBtn 
	UIUtils:tabChangeAnim(tabBtn,function( )
		tabBtn:setEnabled(false)
		tabBtn:setBright(false)
		
		local text = tabBtn:getTitleRenderer()
        text:disableEffect()
        -- text:setPositionX(85)
        tabBtn:setTitleColor(UIUtils.colorTable.ccUITabColor2)	
		tabBtn:loadTextureNormal("TeamBtnUI_tab_p.png",1)
		-- print("=============self._rankType====",self._rankType)
		self._allRankData = self._rankModel:getRankList(self._rankType) or {}
		self._tableData = {}
		if #self._allRankData < 1 then
			--请求数据点击tab 回调reflashUI里刷新有无排行榜的显示以及数据的刷新
			if self._rankType ~= self._rankInitType then
			    self:sendGetRankMsg(self._rankType,1)
			end
			self._firstIn = true
		else
			self._firstIn = false
			self._tableData = self:updateTableData(self._allRankData,self.beginIdx[self._rankType]) 
			-- dump(self._tableData,"self._tableData")
			self._tableView:reloadData()   --jumpToTop
			
			if self._tableData[1] then
				self:reflashNo1(self._tableData[1])
			end
			--不请求数据点击tab 刷新有无排行榜的显示
			self:reflashNoRankUI()		
		end
		--不单独请求自己排行榜数据
		--如果没有个人信息向服务器发请求
		-- local selfInfo = self._rankModel:getSelfRankInfo(self._rankType)
		-- if not selfInfo then
			-- self:sendGetSelfRankMsg(self._rankType)
		-- else
			--如果有数据则刷新自己信息
			if #self._tableData > 0 then
				self:reflashUserInfo()
			end
		-- end
		self:reflashTitleName(idx)
	end,nil,true)
		
end

function RankView:updateTableData(rankList,index)
	-- print("*************************",index)
	local data = {}
	for k,v in pairs(rankList) do
		if tonumber(v.rank) <= tonumber(index) then
			data[k] = v
		end
	end
	return data
end

function RankView:reflashTitleName(index)
	local titleD = titleTable[index]
	self._titleBg1:setVisible(false)
	self._titleBg2:setVisible(false)
	self._titleBg3:setVisible(false)
	
	self["_titleBg" .. titleD[6]]:setVisible(true)
	for i=1 , 5  do
		local title = self["_titleBg" .. titleD[6]]:getChildByFullName("title"..i)
		if titleD and titleD[i] and title then
			title:setString(titleD[i] or "")
		end
	end
end

local rankImgs = {"firstImg","secondImg","thirdImg"}
function RankView:reflashUserInfo()
	local item  = self["_selfItem" .. itemIdx[self._rankType]]
	for i=1,4 do
		self["_selfItem" .. i]:setVisible(false)
	end
	item:setVisible(true)

	local nameLab = item:getChildByFullName("nameLab")
	local UIscoreLab = item:getChildByFullName("scoreLab")
	nameLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
	UIscoreLab:setColor(UIUtils.colorTable.ccUIBaseColor5)

	local rankData = self._rankModel:getSelfRankInfo(self._rankType)
	if not rankData then print("no rankInfo....",self._rankType) return end
	local rank = rankData.rank

	local rankLab = item:getChildByName("rankLab")
	if not rankLab then
		rankLab = cc.Label:createWithTTF("", UIUtils.ttfName, 28) --cc.LabelBMFont:create("4", UIUtils.bmfName_rank)
	    rankLab:setAnchorPoint(cc.p(0.5,0.5))
	    rankLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
	    rankLab:setPosition(68, 45)
	    rankLab:setName("rankLab")
	    item:addChild(rankLab, 1)
	end
	for i=1,3 do
		local rankImg = item:getChildByFullName(rankImgs[tonumber(i)])
		rankImg:setVisible(false)
	end
	if rank then  
		rankLab:setString(rank)		
		if rankImgs[tonumber(rank)] then
			rankLab:setVisible(false)
			local rankImg = item:getChildByFullName(rankImgs[tonumber(rank)])
			rankImg:setVisible(true)
		else
			rankLab:setVisible(true)
		end
	end
	self._guildPanel:setVisible(false)
	-- 没有排名或者大于一万 显示暂未上榜
	if not rank or rank > 9999 or rank == 0 or rank == "" then
		rankLab:setString("暂未上榜")	
	end	
	--特殊界面 如果是联盟并且没有排名的时候不显示暂未上榜，显示guildPanel
	if 4 == self._rankType and (not rank or rank == 0 or rank == "") then
		rankLab:setVisible(false)
		self._guildPanel:setVisible(true)
	end

	local userData = self._modelMgr:getModel("UserModel"):getData()
	nameLab:setString(userData.name)
	-- levelLab:setString(userData.lvl)
	UIscoreLab:setString(rankData.score or "")

	self._selfRankData = rankData
	self._selfRankData.lvl = userData.lvl
	self:registerClickEvent(item,function( )
		self:selfItemClicked(rankData)			
	end)
	if self["updateSelfItem" .. self._rankType] then
		self["updateSelfItem" .. self._rankType](self)
	end

end

function RankView:updateSelfItem1()
	local rankData = self._modelMgr:getModel("UserModel"):getData()
	local headNode = self._selfItem1:getChildByFullName("headNode")
	headNode:removeAllChildren()
	self:createRoleHead(rankData,headNode)

    local nameLab = self._selfItem1:getChildByFullName("nameLab")

    if self._selfItem1.tequanIcon then
        self._selfItem1.tequanIcon:removeFromParent(true)
        self._selfItem1.tequanIcon = nil
    end

    --启动特权类型
    local tequan = self._modelMgr:getModel("TencentPrivilegeModel"):getTencentTeQuan() or ""
	--	tequan = "sq_gamecenter"
	local tequanImg = IconUtils.tencentIcon[tequan] or "globalImageUI6_meiyoutu.png"
	local tequanIcon = ccui.ImageView:create(tequanImg, 1)
    tequanIcon:setScale(0.7)
    tequanIcon:setPosition(cc.p(282, self._selfItem1:getContentSize().height*0.5 - 27))
    self._selfItem1.tequanIcon = tequanIcon
	self._selfItem1:addChild(tequanIcon)

    if self._selfItem1.qqVipIcon then
        self._selfItem1.qqVipIcon:removeFromParent(true)
        self._selfItem1.qqVipIcon = nil
    end

    local qqVipTp = self._modelMgr:getModel("TencentPrivilegeModel"):getQQVip() or ""
	--    qqVipTp = "is_qq_svip"
    local qqVipImg = (qqVipTp and qqVipTp ~= "") and IconUtils.tencentIcon[qqVipTp .. "_head"] or "globalImageUI6_meiyoutu.png"
    local qqVipIcon = ccui.ImageView:create(qqVipImg, 1)
    qqVipIcon:setScale(24 / qqVipIcon:getContentSize().width)
    qqVipIcon:setPosition(cc.p(nameLab:getPositionX() + nameLab:getContentSize().width + 16, self._selfItem1:getContentSize().height*0.5 + 5))
	self._selfItem1:addChild(qqVipIcon)
end

function RankView:updateSelfItem2()
	local rankData = self._selfRankData
	local teamData = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(rankData.teamId)
	-- dump(teamData,"teamData")
	rankData.stage = teamData.stage
	rankData.star = teamData.star
	rankData.tLevel = teamData.level or teamData.lvl
	-- 觉醒
	rankData.ast = teamData.ast
	rankData.aLvl = teamData.aLvl
	-- 加入皮肤字段
	rankData.sId = teamData.sId

	local headNode = self._selfItem2:getChildByFullName("headNode")
	headNode:removeAllChildren()
	self:createTeamHead(rankData,headNode)

    local nameLab = self._selfItem2:getChildByFullName("nameLab")

    if self._selfItem2.tequanIcon then
        self._selfItem2.tequanIcon:removeFromParent(true)
        self._selfItem2.tequanIcon = nil
    end

    --启动特权类型
    local tequan = self._modelMgr:getModel("TencentPrivilegeModel"):getTencentTeQuan() or ""
	--	tequan = "sq_gamecenter"
	local tequanImg = IconUtils.tencentIcon[tequan] or "globalImageUI6_meiyoutu.png"
	local tequanIcon = ccui.ImageView:create(tequanImg, 1)
    tequanIcon:setScale(0.7)
    tequanIcon:setPosition(cc.p(193, self._selfItem2:getContentSize().height*0.5 - 27))
    self._selfItem2.tequanIcon = tequanIcon
	self._selfItem2:addChild(tequanIcon)

    if self._selfItem2.qqVipIcon then
        self._selfItem2.qqVipIcon:removeFromParent(true)
        self._selfItem2.qqVipIcon = nil
    end

    local qqVipTp = self._modelMgr:getModel("TencentPrivilegeModel"):getQQVip() or ""
	--    qqVipTp = "is_qq_svip"
    local qqVipImg = (qqVipTp and qqVipTp ~= "") and IconUtils.tencentIcon[qqVipTp .. "_head"] or "globalImageUI6_meiyoutu.png"
    local qqVipIcon = ccui.ImageView:create(qqVipImg, 1)
    qqVipIcon:setScale(24 / qqVipIcon:getContentSize().width)
    qqVipIcon:setPosition(cc.p(nameLab:getPositionX() + nameLab:getContentSize().width + 16, self._selfItem2:getContentSize().height*0.5 + 5))
    self._selfItem2.qqVipIcon = qqVipIcon
	self._selfItem2:addChild(qqVipIcon)
end
function RankView:updateSelfItem3()
	local rankData = self._selfRankData
	local heroData = self._modelMgr:getModel("HeroModel"):getHeroData(rankData.heroId)
	-- dump(heroData,"heroData")
	rankData.star = heroData.star
	rankData.skin = heroData.skin
	local headNode = self._selfItem2:getChildByFullName("headNode")
	headNode:removeAllChildren()
	self:createHeroHead(rankData,headNode)

    local nameLab = self._selfItem2:getChildByFullName("nameLab")

    if self._selfItem2.tequanIcon then
        self._selfItem2.tequanIcon:removeFromParent(true)
        self._selfItem2.tequanIcon = nil
    end

    --启动特权类型
    local tequan = self._modelMgr:getModel("TencentPrivilegeModel"):getTencentTeQuan() or ""
	--	tequan = "sq_gamecenter"
	local tequanImg = IconUtils.tencentIcon[tequan] or "globalImageUI6_meiyoutu.png"
	local tequanIcon = ccui.ImageView:create(tequanImg, 1)
    tequanIcon:setScale(0.7)
    tequanIcon:setPosition(cc.p(193, self._selfItem2:getContentSize().height*0.5 - 27))
    self._selfItem2.tequanIcon = tequanIcon
	self._selfItem2:addChild(tequanIcon)

    if self._selfItem2.qqVipIcon then
        self._selfItem2.qqVipIcon:removeFromParent(true)
        self._selfItem2.qqVipIcon = nil
    end

    local qqVipTp = self._modelMgr:getModel("TencentPrivilegeModel"):getQQVip() or ""
	--    qqVipTp = "is_qq_svip"
    local qqVipImg = (qqVipTp and qqVipTp ~= "") and IconUtils.tencentIcon[qqVipTp .. "_head"] or "globalImageUI6_meiyoutu.png"
    local qqVipIcon = ccui.ImageView:create(qqVipImg, 1)
    qqVipIcon:setScale(24 / qqVipIcon:getContentSize().width)
    qqVipIcon:setPosition(cc.p(nameLab:getPositionX() + nameLab:getContentSize().width + 16, self._selfItem2:getContentSize().height*0.5 + 5))
    self._selfItem2.qqVipIcon = qqVipIcon
	self._selfItem2:addChild(qqVipIcon)
end
function RankView:updateSelfItem4()
	local rankData = self._selfRankData
	if not rankData.rank then return end
	-- 联盟名称
	local nameLab = self._selfItem3:getChildByFullName("nameLab")
	nameLab:setString(rankData.name or "")
	local levelLab = self._selfItem3:getChildByFullName("levelLab")
	levelLab:setString("联盟等级：" .. (rankData.level or rankData.lvl or 0))
	local headNode = self._selfItem3:getChildByFullName("headNode")
	headNode:removeAllChildren()
	local param = {flags = rankData.avatar1 or 101, logo = rankData.avatar2 or 201}
    avatarIcon = IconUtils:createGuildLogoIconById(param)
    avatarIcon:setName("avatarIcon")
    avatarIcon:setScale(0.7)
    avatarIcon:setAnchorPoint(cc.p(0.5,1))
	avatarIcon:setPosition(headNode:getContentSize().width*0.5,headNode:getContentSize().height)
	headNode:addChild(avatarIcon)
end
function RankView:updateSelfItem5()
	self:updateSelfItem1()
end
function RankView:updateSelfItem6()
	self:updateSelfItem1()
end

-- 觉醒
function RankView:updateSelfItem25()
	local rankData = self._selfRankData
	local scoreLab = self._selfItem4:getChildByFullName("scoreLab")	
	local noAwaking = self._selfItem4:getChildByFullName("noAwaking")
	noAwaking:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
	
	local awakingNum = self._selfItem4:getChildByFullName("awakingNum")
	awakingNum:setString(0)

	local teamData = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(rankData.teamId)
	-- dump(teamData,"teamData")
	local score = rankData.score or 0
	-- print("=======self==========",score)
	-- 后三位进度 剩下的是觉醒数量
	local awakingPro = string.sub(score, -3, -1)
	local awakingNumStr = string.sub(score, -5, -4)
	if awakingNumStr == "" then
		awakingNumStr = 0
	end
	if awakingPro == "" then
		awakingPro = 0
	end
	-- print("=========self=======awakingNum==",awakingNumStr,awakingPro)
	local awakingNum = self._selfItem4:getChildByFullName("awakingNum")
	awakingNum:setString(tonumber(awakingNumStr))
	if rankData.teamId == 0 then
		scoreLab:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
		scoreLab:setString("暂无")
		noAwaking:setVisible(true)
	else
		scoreLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)	
		scoreLab:setString(tonumber(awakingPro) .. "%")
		noAwaking:setVisible(false)
	end

    local nameLab = self._selfItem4:getChildByFullName("nameLab")
    if self._selfItem4.tequanIcon then
        self._selfItem4.tequanIcon:removeFromParent(true)
        self._selfItem4.tequanIcon = nil
    end
    --启动特权类型
    local tequan = self._modelMgr:getModel("TencentPrivilegeModel"):getTencentTeQuan() or ""
	--	tequan = "sq_gamecenter"
	local tequanImg = IconUtils.tencentIcon[tequan] or "globalImageUI6_meiyoutu.png"
	local tequanIcon = ccui.ImageView:create(tequanImg, 1)
    tequanIcon:setScale(0.7)
    tequanIcon:setPosition(cc.p(173, self._selfItem4:getContentSize().height*0.5 - 27))
    self._selfItem4.tequanIcon = tequanIcon
	self._selfItem4:addChild(tequanIcon)

    if self._selfItem4.qqVipIcon then
        self._selfItem4.qqVipIcon:removeFromParent(true)
        self._selfItem4.qqVipIcon = nil
    end

    local qqVipTp = self._modelMgr:getModel("TencentPrivilegeModel"):getQQVip() or ""
	--    qqVipTp = "is_qq_svip"
    local qqVipImg = (qqVipTp and qqVipTp ~= "") and IconUtils.tencentIcon[qqVipTp .. "_head"] or "globalImageUI6_meiyoutu.png"
    local qqVipIcon = ccui.ImageView:create(qqVipImg, 1)
    qqVipIcon:setScale(24 / qqVipIcon:getContentSize().width)
    qqVipIcon:setPosition(cc.p(nameLab:getPositionX() + nameLab:getContentSize().width + 16, self._selfItem4:getContentSize().height*0.5 + 5))
    self._selfItem4.qqVipIcon = qqVipIcon
	self._selfItem4:addChild(qqVipIcon)

	-- 没有正在觉醒的兵团
	if not teamData then return end
	rankData.stage = teamData.stage
	rankData.star = teamData.star
	rankData.tLevel = teamData.level or teamData.lvl
	-- 觉醒
	rankData.ast = teamData.ast
	rankData.aLvl = teamData.aLvl
    -- 加入皮肤字段
	rankData.sId = teamData.sId

	local headNode = self._selfItem4:getChildByFullName("headNode")
	headNode:removeAllChildren()
	self:createTeamHead(rankData,headNode)
end

function RankView:createRoleHead(data,headNode,scaleNum)
	local avatarName = tonumber(data.avatar)
	local scale = scaleNum and scaleNum or 0.8
	if avatarName == 0 or not avatarName then avatarName = 1203 end	
	local lvl = data.lvl
	local icon = IconUtils:createHeadIconById({avatar = avatarName,tp = 3 ,level = lvl,avatarFrame = data["avatarFrame"], plvl = data["plvl"]})
	icon:setName("avatarIcon")
	icon:setAnchorPoint(cc.p(0.5,0.5))
	icon:setScale(scale)
	icon:setPosition(headNode:getContentSize().width*0.5,headNode:getContentSize().height*0.5 - 2)
	headNode:addChild(icon)
end

function RankView:createTeamHead(data,headNode,scaleNum)
	local teamId = tonumber(data.teamId)
	local scale = scaleNum and scaleNum or 0.7
	if teamId then
		local sysTeam = tab:Team(teamId)
		if not sysTeam then
			teamId = 101
			sysTeam = tab:Team(101)
		end
		-- dump(sysTeam,"sysTeam")
        -- itemIcon = IconUtils:createSysTeamIconById({sysTeamData = sysTeam})
        local inTeamData = {teamId=teamId,level=data.tLevel or data.level,star=data.star,ast=data.ast,aLvl=data.aLvl,sId=data.sId}
        if not data.stage or 0 == data.stage then
        	data.stage = 1
        end
        local quality = self._modelMgr:getModel("TeamModel"):getTeamQualityByStage(data.stage)

        local itemIcon = IconUtils:createTeamIconById({teamData = inTeamData, sysTeamData = sysTeam,quality = quality[1] , quaAddition = quality[2],  eventStyle = 0})
        itemIcon:setAnchorPoint(cc.p(0.5,0.5))
        itemIcon:setScale(scale)
        itemIcon:setName("teamIcon")
        itemIcon:setPosition(headNode:getContentSize().width*0.5,headNode:getContentSize().height*0.5)
        itemIcon:setSwallowTouches(false)
        headNode:addChild(itemIcon,1)
	end
end

function RankView:createHeroHead(data,headNode,scaleNum)
	local heroId = tonumber(data.heroId)
	local scale = scaleNum and scaleNum or 0.7
	if heroId then	
        local sysHeroData = clone(tab:Hero(heroId))
		if not sysHeroData then
			sysHeroData = clone(tab:Hero(60001))
		end
		sysHeroData.star = data.star or 1
		sysHeroData.skin = data.skin
        local itemIcon = IconUtils:createHeroIconById({sysHeroData = sysHeroData,tp = 4})
        itemIcon:setName("heroIcon")
        itemIcon:setAnchorPoint(cc.p(0.5,0.5))
        itemIcon:setScale(scale)
        itemIcon:setPosition(headNode:getContentSize().width*0.5,headNode:getContentSize().height*0.5)
        itemIcon:setSwallowTouches(false)
        headNode:addChild(itemIcon,1)

        itemIcon:getChildByName("starBg"):setVisible(false)
        for i=1,6 do
            if itemIcon:getChildByName("star" .. i) then
                itemIcon:getChildByName("star" .. i):setPositionY(itemIcon:getChildByName("star" .. i):getPositionY() + 5)
            end
        end

	end
end

function RankView:reflashNo1( data )
	-- print("======================reflashNo1()")
	-- dump(data,"data")
	local name = self._leftBoard:getChildByFullName("name")
	local level = self._leftBoard:getChildByFullName("level")
	local guild = self._leftBoard:getChildByFullName("guild")
	local guildDes = self._leftBoard:getChildByFullName("guildDes")
	guildDes:setVisible(false)	
	name:setString("暂无榜首")
	level:setString("")	
	guild:setString("")

	if self._leftBoard._roleAnim then
		-- roleAnim:setVisible(false)
		self._leftBoard._roleAnim:removeFromParent()
		self._leftBoard._roleAnim = nil
	end
	if not data then 		
		self:registerClickEventByName("bg.bgPanel.leftBoard",function( )
			-- self:itemClicked(data)
		end)
		return 
	end
	guildDes:setVisible(true)
	local name = self._leftBoard:getChildByFullName("name")
	name:setString(data.name)
	local level = self._leftBoard:getChildByFullName("level")
	local inParam = {lvlStr = "Lv." .. (data.level or data.lvl or 0), lvl = data.level or data.lvl, plvl = data.plvl}
	UIUtils:adjustLevelShow(level, inParam, 1)
	local guild = self._leftBoard:getChildByFullName("guild")
	local guildName = data.guildName 
		
	if guildName and guildName ~= "" then 
		guild:setVisible(true)
		
		local nameLen = utf8.len(guildName)
		if nameLen > 6 then
			guildName = string.sub(guildName,1,15) .. "..."
		end
		guild:setString("" .. (guildName or ""))
	else
		guildDes:setVisible(false)
		guild:setVisible(false)		
	end

	-- 左侧人物形象
	local rolePanel = self._leftBoard:getChildByFullName("rolePanel")
	local heroId = data.fHeroId  or 60001
    local heroD = tab:Hero(heroId)
    local heroArt = heroD["heroart"]
    -- heroSkin  编租皮肤id 只跟左侧No.1信息有关
    if data.heroSkin then
        local heroSkinD = tab.heroSkin[data.heroSkin]
        heroArt = (heroSkinD and heroSkinD["heroart"]) and heroSkinD["heroart"] or heroD["heroart"]
    end
    local sp = mcMgr:createViewMC("stop_" .. heroArt, true)
    -- sp:setScale(0.8)
    sp:setAnchorPoint(0.5,0)
    sp:setPosition(self._leftBoard:getContentSize().width*0.5, rolePanel:getPositionY())
    self._leftBoard._roleAnim = sp
    self._leftBoard:addChild(sp,1)

	local guildLeader = self._leftBoard:getChildByFullName("guildLeader")
	local guildImg = self._leftBoard:getChildByFullName("guildImg")
	
	if 4 == self._rankType then
		level:setString("联盟等级：" .. (data.level or data.lvl or 0))	
		guildImg:setVisible(true)
		local logoData = tab:GuildFlag(data.avatar2)
		if logoData and logoData.pic then
			guildImg:loadTexture(logoData.pic .. ".png",1)
		else
			guildImg:setVisible(false)
		end
		guildDes:setVisible(false)
		guildLeader:setVisible(false)
		if data.mName then
			guildLeader:setString("" .. data.mName)
		end
	else
		guildImg:setVisible(false)
		guildLeader:setVisible(false)
	end
	self:registerClickEventByName("bg.bgPanel.leftBoard",function( )
		self:itemClicked(data)
	end)
end

function RankView:addTableView( )
	self._tableViewW = 616
	self._tableViewH = 318
    local tableView = cc.TableView:create(cc.size(self._tableViewW, self._tableViewH))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(9,5))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    -- tableView:setBounceEnabled(false)
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

function RankView:createLoadingMc()
	if self._loadingMc then return end
	-- 添加加载中动画
	self._loadingMc = mcMgr:createViewMC("jiazaizhong_rankjiazaizhong", true, false, function (_, sender)      end)
    self._loadingMc:setName("loadingMc")
    self._loadingMc:setPosition(cc.p(self._bgPanel:getContentSize().width*0.5 - 30, self._tableNode:getPositionY() + 20))
    self._bgPanel:addChild(self._loadingMc, 20)
    self._loadingMc:setVisible(false)
end

function RankView:scrollViewDidScroll(view)
	self._inScrolling = view:isDragging()

    local offsetY = view:getContentOffset().y   	
	if offsetY >= 60 and #self._tableData > 5 and #self._tableData < self.endIdx[self._rankType] and not self._canRequest then
		self._canRequest = true
		self:createLoadingMc()
		if not self._loadingMc:isVisible() then
			self._loadingMc:setVisible(true)
		end
	end	
		
    local condY = 0
    if self._tableData and #self._tableData < 4 then
    	-- tableView height 330
    	condY = self._tableViewH - #self._tableData*(self._tableCellH+5)
    end
	if self._inScrolling then
	    if offsetY >= condY+60 and not self._canRequest then
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
			self._canRequest = false
			self:sendMessageAgain()
			self:createLoadingMc()
			if self._loadingMc:isVisible() then
				self._loadingMc:setVisible(false)
			end		
		end
	end

end

function RankView:scrollViewDidZoom(view)
    -- print("scrollViewDidZoom")
end

function RankView:tableCellTouched(table,cell)
    print("cell touched at index: " .. cell:getIdx())
end

function RankView:cellSizeForTable(table,idx) 
    return self._tableCellH+5,self._tableCellW
end

function RankView:tableCellAtIndex(table, idx)
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
    if item then
	    item:setPosition(cc.p(2,4))
	    item:setAnchorPoint(cc.p(0,0))
	    cell:addChild(item)
	end

    return cell
end

function RankView:numberOfCellsInTableView(table)
	-- print("#self._tableData",#self._tableData)
	return #self._tableData
	
end

-- 接收自定义消息
function RankView:reflashUI(data)
	local offsetX = nil
	local offsetY = nil
	if self._offsetX and self._offsetY then
		offsetX = self._offsetX
		offsetY = self._offsetY
	end
    self._allRankData = self._rankModel:getRankList(self._rankType)
    self._tableData = self:updateTableData(self._allRankData,self.beginIdx[self._rankType])
   	-- print("************&&&&&&&&&&&&-----------",#self._tableData)
    if self._tableData and self._tableView then    	
	    self._tableView:reloadData()
	    if offsetX and offsetY and not self._firstIn then
	    	self._tableView:setContentOffset(cc.p(offsetX,offsetY))
			-- self._canRequest = false
	    end	    
	    self._firstIn = false
	end
	--如果有数据则刷新自己信息
	if #self._tableData > 0 then
		self:reflashUserInfo()
	end
	if self._tableData then
		self:reflashNo1(self._tableData[1])
	end
	-- if self._rankType == 4 or self._rankType == 6 then
	
	-- end

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

function RankView:reflashNoRankUI()
	if (not self._tableData or #self._tableData <= 0) then
		self._noRankBg:setVisible(true)
		self._noRankBg:setSwallowTouches(true)
		self._tableNode:setVisible(false)
		self._titleBg1:setVisible(false)
		self._titleBg2:setVisible(false)	
		self._titleBg3:setVisible(false)		
		self._guildPanel:setVisible(false)
		
	else
		self._noRankBg:setVisible(false)
		self._noRankBg:setSwallowTouches(false)
		self["_selfItem" .. itemIdx[self._rankType]]:setVisible(true)
		self._tableNode:setVisible(true)
		self["_titleBg" .. titleTable[self._rankType][6]]:setVisible(true)
	end
end

local rankTextColor = {cc.c4b(254, 203, 34, 255),cc.c4b(183, 215, 215, 255),cc.c4b(253, 156, 87, 255)}
function RankView:createItem( data,index )
	if data == nil then return end

	local item = self["_rankItem" .. itemIdx[self._rankType]]:clone()

	item:setContentSize(self._tableCellW,self._tableCellH)
	local nameLab = item:getChildByFullName("nameLab")
	nameLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
	local scoreLab = item:getChildByFullName("scoreLab")
	scoreLab:setColor(UIUtils.colorTable.ccUIBaseColor5)

	self._itemData = data
	item:setVisible(true)
	self._currItem = item
	item.data = data
	local rank = data.rank
	local score = data.score

	local UIscoreLab = item:getChildByFullName("scoreLab")
	if self._rankType == 5 and data.lvl then
		-- 副本总行数，校对
		-- print(index, data.lvl, score, self._maxLevelStarArr[data.lvl])
		UIscoreLab:setString(math.min(score, self._maxLevelStarArr[data.lvl] or score))
	else
		UIscoreLab:setString(score)
	end

	local rankLab = item:getChildByName("rankLab")
	if not rankLab then
		rankLab = cc.Label:createWithTTF("0", UIUtils.ttfName, 28) --cc.LabelBMFont:create("4", UIUtils.bmfName_rank)
	    rankLab:setAnchorPoint(cc.p(0.5,0.5))
	    rankLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
	    rankLab:setPosition(60, 38)
	    rankLab:setName("rankLab")
	    item:addChild(rankLab, 1)
	end
	for i=1,3 do
		local rankImg = item:getChildByFullName(rankImgs[tonumber(i)])
		rankImg:setVisible(false)
	end
	if rank then  
		rankLab:setString(rank)
		if rankImgs[tonumber(rank)] then
			rankLab:setVisible(false)
			local rankImg = item:getChildByFullName(rankImgs[tonumber(rank)])
			rankImg:setVisible(true)
		else
			rankLab:setVisible(true)
		end
	end

	for i=1,3 do
		local rankImg = item:getChildByFullName(rankImgs[tonumber(i)])
		-- local rankMc = rankImg:getChildByFullName("rankmc" .. i)
		-- if 1 == i then
		-- 	if not rankMc then				
		-- 		rankMc = mcMgr:createViewMC("diyiming_paimingeffect", true, false, function (_, sender)
		--         end)
		--         rankMc:setName("rankmc1")
		--         rankMc:setScale(0.8)
		--         rankMc:setPosition(cc.p(rankImg:getContentSize().width*0.5, rankImg:getContentSize().height*0.5 - 2))
		--         rankImg:addChild(rankMc, -1)
		--     end
  --      else
  --      		if not rankMc then
		--        	rankMc = mcMgr:createViewMC("ersanming_paimingeffect", true, false, function (_, sender)
	 --            end)
	 --            rankMc:setName("rankmc" .. i)
	 --            rankMc:setScale(0.8)
	 --            rankMc:setPosition(cc.p(rankImg:getContentSize().width*0.5, rankImg:getContentSize().height*0.5))
	 --            rankImg:addChild(rankMc, -1)
	 --        end
  --       end
		rankImg:setVisible(false)
	end
	if rankImgs[tonumber(rank)] then
		rankLab:setVisible(false)
		local rankImg = item:getChildByFullName(rankImgs[tonumber(rank)])
		-- rankImg:setScale(2)
		rankImg:setVisible(true)
	else
		rankLab:setVisible(true)
	end
	item:setSwallowTouches(false)
	self:registerClickEvent(item,function( )
		if not self._inScrolling then
			self:itemClicked(data)			
        else
            self._inScrolling = false
        end
	end)
	item:setSwallowTouches(false)

	if self["updateItem" .. upateItemIdx[self._rankType]] then
		self["updateItem" .. upateItemIdx[self._rankType]](self)
	end
	return item
end
function RankView:updateItem1()
	local item = self._currItem
	local data = self._itemData
	local name = data.name or ""
	local nameLab = item:getChildByFullName("nameLab")
	nameLab:setString(name)
	-- local levelLab = item:getChildByFullName("levelLab")
	-- levelLab:setString(data.level or data.lvl or "")
	
	local headNode = item:getChildByFullName("headNode")
	headNode:removeAllChildren()
	self:createRoleHead(data,headNode,0.65)

    --启动特权类型
	--	 data["tequan"] = "sq_gamecenter"
	local tequanImg = IconUtils.tencentIcon[data["tequan"]] or "globalImageUI6_meiyoutu.png"
	local tequanIcon = ccui.ImageView:create(tequanImg, 1)
    tequanIcon:setScale(0.65)
    tequanIcon:setPosition(cc.p(272, item:getContentSize().height*0.5 - 22))
	item:addChild(tequanIcon)

	--    data["qqvip"] = "is_qq_svip"
    local qqVipImg = (data["qqVip"] and data["qqVip"] ~= "") and IconUtils.tencentIcon[data["qqVip"] .. "_head"] or "globalImageUI6_meiyoutu.png"
    local qqVipIcon = ccui.ImageView:create(qqVipImg, 1)
    qqVipIcon:setScale(24 / qqVipIcon:getContentSize().width)
    qqVipIcon:setPosition(cc.p(nameLab:getPositionX() + nameLab:getContentSize().width + 16, item:getContentSize().height*0.5 + 5))
	item:addChild(qqVipIcon)
end

function RankView:updateItem2()
	local item = self._currItem
	local data = self._itemData
	local name = data.name	or ""
	local nameLab = item:getChildByFullName("nameLab")
	nameLab:setString(name)

	-- data.stage = teamData.stage
	-- data.star = teamData.star
	-- data.level = teamData.level or teamData.lvl
	local headNode = item:getChildByFullName("headNode")
	headNode:removeAllChildren()
	self:createTeamHead(data,headNode,0.6)

    --启动特权类型
	--	data["tequan"] = "sq_gamecenter"
	local tequanImg = IconUtils.tencentIcon[data["tequan"]] or "globalImageUI6_meiyoutu.png"
	local tequanIcon = ccui.ImageView:create(tequanImg, 1)
    tequanIcon:setScale(0.65)
    tequanIcon:setPosition(cc.p(180, item:getContentSize().height*0.5 - 22))
	item:addChild(tequanIcon)

	--    data["qqvip"] = "is_qq_svip"
    local qqVipImg = (data["qqVip"] and data["qqVip"] ~= "") and IconUtils.tencentIcon[data["qqVip"] .. "_head"] or "globalImageUI6_meiyoutu.png"
    local qqVipIcon = ccui.ImageView:create(qqVipImg, 1)
    qqVipIcon:setScale(24 / qqVipIcon:getContentSize().width)
    qqVipIcon:setPosition(cc.p(nameLab:getPositionX() + nameLab:getContentSize().width + 16, item:getContentSize().height*0.5 + 5))
	item:addChild(qqVipIcon)
end

function RankView:updateItem3()
	local item = self._currItem
	local data = self._itemData
	local name = data.name	or ""
	local nameLab = item:getChildByFullName("nameLab")
	-- nameLab:enableOutline(cc.c4b(61,37,17,255),2)
	nameLab:setString(name)

	-- data.star = heroData.star
	local headNode = item:getChildByFullName("headNode")
	headNode:removeAllChildren()
	self:createHeroHead(data,headNode,0.6)
	
    
    --启动特权类型
	--	data["tequan"] = "sq_gamecenter"
	local tequanImg = IconUtils.tencentIcon[data["tequan"]] or "globalImageUI6_meiyoutu.png"
	local tequanIcon = ccui.ImageView:create(tequanImg, 1)
    tequanIcon:setScale(0.65)
    tequanIcon:setPosition(cc.p(182, item:getContentSize().height*0.5 - 22))
	item:addChild(tequanIcon)

	--    data["qqvip"] = "is_qq_svip"
    local qqVipImg = (data["qqVip"] and data["qqVip"] ~= "") and IconUtils.tencentIcon[data["qqVip"] .. "_head"] or "globalImageUI6_meiyoutu.png"
    local qqVipIcon = ccui.ImageView:create(qqVipImg, 1)
    qqVipIcon:setScale(24 / qqVipIcon:getContentSize().width)
    qqVipIcon:setPosition(cc.p(nameLab:getPositionX() + nameLab:getContentSize().width + 16, item:getContentSize().height*0.5 + 5))
	item:addChild(qqVipIcon)
end

function RankView:updateItem4()
	local item = self._currItem
	local data = self._itemData
	local name = data.name	or ""
	local nameLab = item:getChildByFullName("nameLab")
	nameLab:setString(name)
	local levelLab = item:getChildByFullName("levelLab")
	levelLab:setString("联盟等级：" .. data.level or data.lvl or "")

	local headNode = item:getChildByFullName("headNode")
	headNode:removeAllChildren()
	local param = {flags = data.avatar1 or 101, logo = data.avatar2 or 201}
    avatarIcon = IconUtils:createGuildLogoIconById(param)
    avatarIcon:setName("avatarIcon")
    avatarIcon:setScale(0.6)
    avatarIcon:setAnchorPoint(cc.p(0.5,1))
	avatarIcon:setPosition(headNode:getContentSize().width*0.5,headNode:getContentSize().height - 5)
	headNode:addChild(avatarIcon)
end

function RankView:updateItem5()
	self:updateItem1()
end

function RankView:updateItem6()
	self:updateItem1()
end

function RankView:updateItem25()
	local item = self._currItem
	local data = self._itemData

	local scoreLab = item:getChildByFullName("scoreLab")	
	local noAwaking = item:getChildByFullName("noAwaking")
	noAwaking:setColor(UIUtils.colorTable.ccUIBaseTextColor1)	
	local awakingNum = item:getChildByFullName("awakingNum")
	awakingNum:setString(0)

	local score = data.score or 0
	-- 后三位进度 剩下的是觉醒数量
	local awakingPro = string.sub(score, -3, -1)
	local awakingNumStr = string.sub(score, -5, -4)
	if awakingNumStr == "" then
		awakingNumStr = 0
	end
	if awakingPro == "" then
		awakingPro = 0
	end
	local awakingNum = item:getChildByFullName("awakingNum")
	awakingNum:setPositionX(awakingNum:getPositionX() + 8)
	awakingNum:setString(tonumber(awakingNumStr))
	if data.teamId == 0 then
		scoreLab:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
		scoreLab:setString("暂无")
		noAwaking:setVisible(true)
	else
		scoreLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)	
		scoreLab:setString(tonumber(awakingPro) .. "%")
		noAwaking:setVisible(false)
	end

	local name = data.name	or ""
	local nameLab = item:getChildByFullName("nameLab")
	nameLab:setString(name)
	nameLab:setPositionX(nameLab:getPositionX() - 20)
    --启动特权类型
		-- data["tequan"] = "sq_gamecenter"
	local tequanImg = IconUtils.tencentIcon[data["tequan"]] or "globalImageUI6_meiyoutu.png"
	local tequanIcon = ccui.ImageView:create(tequanImg, 1)
    tequanIcon:setScale(0.65)
    tequanIcon:setPosition(cc.p(160, item:getContentSize().height*0.5 - 22))
	item:addChild(tequanIcon)

		-- data["qqVip"] = "is_qq_vip"
    local qqVipImg = (data["qqVip"] and data["qqVip"] ~= "") and IconUtils.tencentIcon[data["qqVip"] .. "_head"] or "globalImageUI6_meiyoutu.png"
    local qqVipIcon = ccui.ImageView:create(qqVipImg, 1)
    qqVipIcon:setScale(24 / qqVipIcon:getContentSize().width)
    qqVipIcon:setPosition(cc.p(nameLab:getPositionX() + nameLab:getContentSize().width + 16, item:getContentSize().height*0.5 + 5))
	item:addChild(qqVipIcon)

	-- 没有正在觉醒的兵团
	if data.teamId == 0 then return end
	-- data.stage = teamData.stage
	-- data.star = teamData.star
	-- data.level = teamData.level or teamData.lvl
	local headNode = item:getChildByFullName("headNode")
	headNode:removeAllChildren()
	self:createTeamHead(data,headNode,0.6)
end

function RankView:selfItemClicked(data)
	if not data then return end
	self._param = {}
	local userData = self._modelMgr:getModel("UserModel"):getData()
	local roleId = userData._id
	if 2 == self._rankType then
		self._param = {type=self._rankType,roleId=roleId,id=data.teamId or 101}
		self._clickId = data.teamId
	elseif 3 == self._rankType then
		self._param = {type=self._rankType,roleId=roleId,id=data.heroId or 60101}
		self._clickId = data.heroId
	elseif 25 == self._rankType then
		self._param = {type=self._rankType,roleId=roleId,id=data.teamId or 101}
		self._clickId = data.teamId
	else
		self._param = {type=self._rankType,roleId=roleId}
	end
	self._itemData = {}
	self._itemData.rid = roleId
	self._itemData.rank = data.rank
	self._itemData.name = userData.name
	self._itemData.lvl = userData.lvl
	self._itemData.avatarFrame = userData.avatarFrame
	self._itemData.avatar = userData.avatar
	self._itemData.score = data.score
	self._itemData.qqVip = self._modelMgr:getModel("TencentPrivilegeModel"):getQQVip() or ""
	self._itemData.tequan = self._modelMgr:getModel("TencentPrivilegeModel"):getTencentTeQuan() or ""

	-- if data.rank and data.rank > 0 then
	-- 	self._itemData.rank = data.rank
	-- else
	--  	self._itemData.rank = "暂未上榜"
	-- end 
	if self._rankType ~= 4 and roleId and roleId ~= 0 then
		self._clickItemData = self._itemData
		if self["goView" .. self._rankType] then
			self["goView" .. self._rankType](self)
		end	    
	elseif 4 == self._rankType then
		if userData.guildId and userData.guildId ~= ""  then
			local param = {guildId = guildId}
		    self._serverMgr:sendMsg("GuildServer", "getGameGuildBaseInfo", {guildId = userData.guildId}, true, {}, function (result)
		        self._clickItemData = result
		        self:goView4()
		    end)
		end
	else
		print("=======数据异常-================")
	end
end

function RankView:itemClicked(data)
	-- body
	if not data then return end
	self._param = {}
	if 2 == self._rankType then
		self._param = {type=self._rankType,roleId=data.rid or data._id,id=data.teamId}
		self._clickId = data.teamId
	elseif 3 == self._rankType then
		self._param = {type=self._rankType,roleId=data.rid or data._id,id=data.heroId}
		self._clickId = data.heroId
	elseif 25 == self._rankType then
		self._param = {type=self._rankType,roleId=data.rid or data._id,id=data.teamId}
		self._clickId = data.teamId
		elseif 25 == self._rankType then
	else
		self._param = {type=self._rankType,roleId=data.rid or data._id}
	end
	self._itemData = data
	if self._rankType ~= 4 and data._id and data._id ~= 0 then
		self._clickItemData = self._itemData
		if self["goView" .. self._rankType] then
			self["goView" .. self._rankType](self)
		end
	elseif 4 == self._rankType then
		self._clickItemData = data
		self:goView4()
	else
		print("=======数据异常-================")
	end
end

function RankView:goView1()
	if not self._clickItemData then return end
	local fId = (self._clickItemData.lvl and  self._clickItemData.lvl >= 15) and 101 or 1
	self._serverMgr:sendMsg("UserServer", "getTargetUserBattleInfo", {tagId = self._clickItemData.rid or self._clickItemData._id,fid=fId}, true, {}, function(result) 
		local data = result
		data.rank = self._clickItemData.rank
		data.usid = self._clickItemData.usid
		-- data.isNotShowBtn = true
		self._viewMgr:showDialog("arena.DialogArenaUserInfo",data,true)
    end)
end
function RankView:goView2()
	self._serverMgr:sendMsg("RankServer", "getDetailRank", self._param, true, {}, function(result) 
		local dataTemp = result
		if not dataTemp then return end
		dataTemp.team.teamId = tonumber(self._clickId)
		self._viewMgr:showDialog("rank.RankTeamDetailView",{data = dataTemp},true)
	end)
	
end
function RankView:goView3()
	self._serverMgr:sendMsg("RankServer", "getDetailRank", self._param, true, {}, function(result) 
		local dataTemp = result
		if not dataTemp then return end
		dataTemp.heros.heroId = tonumber(self._clickId) 
		self._viewMgr:showDialog("rank.RankHeroDetailView",{data = dataTemp},true)
	end)	
end
function RankView:goView4()
	 self._viewMgr:showDialog("guild.dialog.GuildDetailDialog", {allianceD = self._clickItemData})
end
function RankView:goView5()
	if not self._clickItemData then return end
	local fId = (self._clickItemData.lvl and  self._clickItemData.lvl >= 15) and 101 or 1
	self._serverMgr:sendMsg("UserServer", "getTargetUserBattleInfo", {tagId = self._clickItemData.rid or self._clickItemData._id,fid=fId}, true, {}, function(result) 
		local data = result
		data.rank = self._clickItemData.rank
		data.usid = self._clickItemData.usid
		-- data.isNotShowBtn = true
		self._viewMgr:showDialog("arena.DialogArenaUserInfo",data,true)
    end)

end
function RankView:goView6()
	self._serverMgr:sendMsg("RankServer", "getDetailRank", self._param, true, {}, function(result) 
		local dataTemp = result
		local itemData = {}
		if self._itemData then
			itemData = clone(self._itemData)
		end
		self._viewMgr:showDialog("rank.RankTreasureView",{data = dataTemp,userData = itemData},true)
	end)
	
end

function RankView:goView25()
	if self._clickId == 0 then 
		-- self._viewMgr:showTip("当前没有正在觉醒的兵团")  
		return
	end
	self._serverMgr:sendMsg("RankServer", "getDetailRank", self._param, true, {}, function(result) 
		local dataTemp = result
		if not dataTemp then return end
		dataTemp.team.teamId = tonumber(self._clickId)
		self._viewMgr:showDialog("rank.RankTeamDetailView",{data = dataTemp},true)
	end)
end

function RankView:goView30()
	print("=========goView30=器械详情=====")
	-- if self._clickId == 0 then 
	-- 	return
	-- end
	self._serverMgr:sendMsg("RankServer", "getDetailRank", self._param, true, {}, function(result) 
		if not result then return end
		-- dump(result,"dataTem==>",1)
		if not result.weaponData then 
			result.weaponData = {}
		end
		result.rank = self._clickItemData.rank
		self._viewMgr:showDialog("rank.RankUserWeaponsDialog",result,true)
	end)
end

function RankView:getBmpFromNum( num,node,offsetx )
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
	return widget
end
--是否要刷新排行榜
function RankView:sendMessageAgain()
	-- self.beginIdx -- self.endIdx -- self.addStep
	self._allRankData = self._rankModel:getRankList(self._rankType)
	local starNum = self._rankModel:getRankNextStart(self._rankType)
	local statCount = tonumber(self.beginIdx[self._rankType])
	local endCount = tonumber(self.endIdx[self._rankType])
	local addCount = tonumber(self.addStep[self._rankType])

	if #self._tableData == #self._allRankData and #self._allRankData%addCount == 0 and #self._allRankData < endCount then
		--如果本地没有更多数据则向服务器请求
		self:sendGetRankMsg(self._rankType,starNum,function()
			self._offsetX = 0
			self._offsetY = 0
			if #self._allRankData > statCount then
				self:searchForPosition(statCount,addCount,endCount)
			end
			self._viewMgr:unlock()
		end)
	else
	-- 	-- if self.
	-- 	if #self._allRankData > statCount then
	-- 		self:searchForPosition(statCount,addCount,endCount)		
	-- 		self:reflashUI()
	-- 	end		
		-- self._canRequest = false
		self._viewMgr:unlock()
	end
end
--刷新之后tableView 的定位
function RankView:searchForPosition(statCount,addCount,endCount)
	self._offsetX = 0
	if statCount + addCount <= endCount then
		self.beginIdx[self._rankType] = statCount + addCount
		local subNum = #self._allRankData - statCount

		if subNum < addCount then
			self._offsetY = -1 * (tonumber(subNum) * (self._tableCellH+5))			
		else
			self._offsetY = -1 * (tonumber(self.addStep[self._rankType]) * (self._tableCellH+5))			
		end
		
	else
		self.beginIdx[self._rankType] = endCount
		self._offsetY = -1 * (endCount - statCount) * (self._tableCellH+5)
	end

	--一屏内 
	local tempH = #self._allRankData * (self._tableCellH+5) - self._tableViewH
	if tempH <= 0 or tempH < (self._tableCellH + 5) * 0.5 then --差值小于0.5个cell高度
		self._offsetY = self._tableViewH - #self._allRankData * (self._tableCellH+5)
	end
end
--获取排行榜数据
function RankView:sendGetRankMsg(tp,start,callback)
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
--获取自己的排行榜数据
-- function RankView:sendGetSelfRankMsg( tp )
-- 	self._serverMgr:sendMsg("RankServer", "getMyRank", {type=tp}, true, {}, function(result) 
-- 		if #self._tableData > 0 then
-- 			self:reflashUserInfo()
-- 			self:reflashTitleName(self._rankType)
-- 		end
--     end)
-- end

function RankView.dtor()
    titleTable = nil
	rankImgs = nil
	rankTextColor = nil
	payerShow = nil
	teamShow = nil
	heroShow = nil
	guildShow = nil
	artifactShow = nil
	showTable = nil
	itemIdx = nil
	awakingShow = nil
	titleTxt = nil
	typeIdx = nil
	weaponShow = nil
	tabNum = nil
	tabVisibleNum = nil
end


return RankView