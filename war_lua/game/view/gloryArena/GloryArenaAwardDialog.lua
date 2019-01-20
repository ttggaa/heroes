--[[
    FileName:       GloryArenaAwardDialog
    Author:         <dongcheng@playcrab.com>
    Datetime:       2018-08-13 17:01:28
    Description:
]]

local GloryArenaAwardDialog = class("GloryArenaAwardDialog", BasePopView)

function GloryArenaAwardDialog:ctor()
    self.super.ctor(self) 
end

-- local tipBg = {"asset/bg/gloryArena_Reward_1.png"}

local childName = {
    --按钮
    {name = "bg", childName = "bg"},
    {name = "closeBtn", childName = "bg.closeBtn", isBtn = true},
    {name = "rankTitleTxt", childName = "bg.bg2.rankTitleTxt", isText = true},
    {name = "rankNum", childName = "bg.bg2.rankNum", isText = true},
    {name = "getAwardTxt", childName = "bg.bg2.getAwardTxt", isText = true},
    {name = "awardScroll", childName = "bg.bg2.awardScroll"},
    {name = "noAward_txt", childName = "bg.bg2.noAward_txt", isText = true},
    {name = "tableNode", childName = "bg.tableNode"},
    {name = "item1", childName = "bg.item1"},
    {name = "item2", childName = "bg.item2"},
    {name = "attackCount_lab", childName = "bg.bg1.attackCount_lab", isText = true},
    {name = "bg1_rankTitleTxt_1", childName = "bg.bg1.rankTitleTxt_1", isText = true},
    {name = "bg1", childName = "bg.bg1"},
    {name = "bg2", childName = "bg.bg2"},
    {name = "rankTitleTxt", childName = "bg.bg1.rankTitleTxt", isText = true},
    {name = "activeTab", childName = "bg.activeTab"},
    {name = "stageTab", childName = "bg.stageTab"},
    {name = "title", childName = "bg.titleBg.title"},
}

function GloryArenaAwardDialog:onRewardCallback(_, _x, _y, sender)
    if sender == nil or self._childNodeTable == nil then
        return 
    end
    if sender:getName() == "closeBtn" then
        self:close()
        UIUtils:reloadLuaFile("gloryArena.GloryArenaAwardDialog")
    end
end


-- 初始化UI后会调用, 有需要请覆盖
function GloryArenaAwardDialog:onInit()
    self._childNodeTable = self:lGetChildrens(self._widget, childName)
    if self._childNodeTable == nil then
        return
    end
    self._isReloadData = true
    -- self:disableTextEffect()

    UIUtils:setTitleFormat(self._childNodeTable.title,1)

    self._childNodeTable.item1:setVisible(false)
    self._childNodeTable.item2:setVisible(false)
    self._items = {}
    self._items[1] = self._childNodeTable.item1
    self._items[2] = self._childNodeTable.item2
    self._tabs = {}
    self._activeTab = self._childNodeTable.activeTab
    table.insert(self._tabs,self._activeTab)
    self._stageTab = self._childNodeTable.stageTab
    table.insert(self._tabs,self._stageTab)

    self._panels = {}
    self._panels[1] = self._childNodeTable.bg1
    self._panels[2] = self._childNodeTable.bg2

    for i=1, 2 do
        self._panels[i]:setVisible(false)
        UIUtils:setTabChangeAnimEnable(self._tabs[i], -42 ,function( )
            self:touchTab(i)
        end)
    end


    self._gloryArenaModel = self._modelMgr:getModel("GloryArenaModel")
    self._rankStageAward = self._gloryArenaModel:lGetSeasonReward()
    self._countAward = clone(tab.honorArenaActivity)
    self:relfashCountAwardTable()
    self:initTab()
	self:addTableView()
    self:touchTab(1)
    self:initTopLay()

--    self:listenReflash("GloryArenaModel", self.reflashUI)

end

function GloryArenaAwardDialog:initTopLay()
    if self._curIndex == 1 then
        local attackCount = self._gloryArenaModel:lGetSelfAttackCount()
        local chalNum = attackCount.chalNum or 0
        self._childNodeTable.attackCount_lab:setString(chalNum)
        if self._items1Bg == nil then
            local Season = self._gloryArenaModel:lGetSeason()
            self._items1Bg = ccui.ImageView:create()
            self._items1Bg:setAnchorPoint(cc.p(0, 0))
            local resData = tab:HonorArenaResource(tonumber(Season))
	        if resData then
                self._items1Bg:loadTexture("asset/bg/" .. (resData.Resource5 or "gloryArena_Reward_1") .. ".png", ccui.TextureResType.localType)
            end
            -- self._items1Bg
            self._panels[1]:addChild(self._items1Bg, -1)
            local rankTitleTxt_1 = self._panels[1]:getChildByName("rankTitleTxt_1")
            rankTitleTxt_1:setPositionY(85)
            rankTitleTxt_1:setColor(cc.c3b(255, 255, 255))
            self._panels[1]:getChildByName("rankTitleTxt"):setPositionY(15)
            self._childNodeTable.attackCount_lab:setPositionY(50)
        end
    elseif self._curIndex == 2 then
        local rank = self._gloryArenaModel:lGetSelfRank()
        self._childNodeTable.rankNum:setString(rank)
        local reward = self._gloryArenaModel:lGetAccumulateReward()
        self._childNodeTable.awardScroll:removeAllChildren()
        if #reward == 0 then
            self._childNodeTable.noAward_txt:setVisible(true)
        else
            self._childNodeTable.noAward_txt:setVisible(false)
            self._childNodeTable.awardScroll:setContentSize(cc.size(480, 70))
            self:addItems( self._childNodeTable.awardScroll, reward, cc.p(50, 10))
        end
    end
end

function GloryArenaAwardDialog:initTab()
    for key, var in ipairs(self._tabs) do
        local v = var
        if v then
            v:loadTextureNormal("globalBtnUI4_page1_n.png",1)
            v:loadTexturePressed("globalBtnUI4_page1_n.png",1)
            local text = v:getTitleRenderer()
            v:setTitleFontName(UIUtils.ttfName)
            text:disableEffect()
            v:setTitleColor(UIUtils.colorTable.ccUITabColor1)
            v:setEnabled(true)
            v:setZOrder(0)
            UIUtils:tabChangeAnim(v, nil, true)
        end
    end
    
end


--添加小红点
function GloryArenaAwardDialog:lSetRedSpot(sender, bIsShow)
    if sender then
        if sender._redSport_img == nil then
            sender._redSport_img = cc.Sprite:createWithSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrameByName("globalImageUI_bag_keyihecheng.png"))
            sender._redSport_img:setPosition(cc.p(18, sender:getContentSize().height - 10))
--            sender._redSport_img:setScale(0.8)
            sender:addChild(sender._redSport_img, 1)
        end
        sender._redSport_img:setVisible(bIsShow)
    end
end

function GloryArenaAwardDialog:lCheckRedSport()
    if self._childNodeTable then
        self:lSetRedSpot(self._childNodeTable.activeTab, self._gloryArenaModel:bIsCanReward())
        self:lSetRedSpot(self._childNodeTable.stageTab, self._gloryArenaModel:bIsCanBuyRed())
    end
end

function GloryArenaAwardDialog:touchTab(nIndex)
    if self._curIndex == nIndex then
        return
    end

    if self._curIndex == 1 then
        if self._gloryArenaModel:bIsCanBuyRed() then
            local curTime = ModelManager:getInstance():getModel("UserModel"):getCurServerTime()
            local sec_time = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 05:00:00"))
            sec_time = sec_time + 86400
            SystemUtils.saveAccountLocalData("GLORY_ARENA_BUY_RED_TIME", sec_time)
            self._gloryArenaModel:reflashData()
        end
    end

    if self._curIndex ~= nil then
        local v = self._tabs[self._curIndex]
        if v then
            v:loadTextureNormal("globalBtnUI4_page1_n.png",1)
            v:loadTexturePressed("globalBtnUI4_page1_n.png",1)
            local text = v:getTitleRenderer()
            v:setTitleFontName(UIUtils.ttfName)
            text:disableEffect()
            v:setTitleColor(UIUtils.colorTable.ccUITabColor1)
            self._panels[self._curIndex]:setVisible(false)
            v:setEnabled(true)
            v:setZOrder(0)
            UIUtils:tabChangeAnim(v, nil, true)
        end
    end

    v = self._tabs[nIndex]
    if v then
        UIUtils:tabChangeAnim(v, function()
            v:loadTextureNormal("globalBtnUI4_page1_p.png",1)
            v:loadTexturePressed("globalBtnUI4_page1_p.png",1)
            v:setTitleFontName(UIUtils.ttfName)
            v:setTitleColor(UIUtils.colorTable.ccUITabColor2)
            local text = v:getTitleRenderer()
            text:disableEffect()
        end)
        
    end
    self._panels[nIndex]:setVisible(true)
    self._curIndex = nIndex
    self._tableView:reloadData()
    self:initTopLay()
    self:lCheckRedSport()
    if nIndex == 2 then
        local _, nIndex = self._gloryArenaModel:bIsCanBuy()
--        print("\n*********************\n",  nIndex,  self._tableView:getContentSize().height, self._tableView:getViewSize().height, "\n*********************\naa")
        self._tableView:setContentOffset(cc.p(self._tableView:getContentOffset().x, -((#self._rankStageAward - nIndex) * 125 - self._tableView:getViewSize().height)), false)
    end
end

function GloryArenaAwardDialog:addTableView( )
	local tableView = cc.TableView:create(cc.size(self._childNodeTable.tableNode:getContentSize().width, self._childNodeTable.tableNode:getContentSize().height-20))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(5,12))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    self._childNodeTable.tableNode:addChild(tableView)
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

--    tableView:reloadData()
    self._tableView = tableView
end

function GloryArenaAwardDialog:scrollViewDidScroll(view)

end

function GloryArenaAwardDialog:scrollViewDidZoom(view)
end

function GloryArenaAwardDialog:tableCellTouched(view,cell)
end

local cellSize = {100 , 125}

function GloryArenaAwardDialog:cellSizeForTable(view,idx) 
    return cellSize[self._curIndex], 0
end

function GloryArenaAwardDialog:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    end
    local item = cell:getChildByName("item")
    if item then
        cell:removeChild(item, true)
        item = nil
    end
    if not item then
        item = self._items[self._curIndex]:clone()
        item:setVisible(true)
        item:setAnchorPoint(cc.p(0, 0))
        item:setPosition(cc.p(0, 0))
        item:setSwallowTouches(false)
        item:setName("item")
        cell:addChild(item)

    end
    self:updateItem(item, idx + 1)
    return cell
end

function GloryArenaAwardDialog:relfashCountAwardTable()
--    local noComplest =  {}
--    local complete = {}
    local newTable = {}
    local nIndex = 0
    self._countAward = clone(tab.honorArenaActivity)
    if self._countAward then
        for key, var in ipairs(self._countAward) do
            if var then
                if not self._gloryArenaModel:lGetArenaShop(2)[var.id] then
                    nIndex = nIndex + 1
                    table.insert(newTable, nIndex, var)
                else
                    newTable[#newTable + 1] = var
                end
            end
        end
    end
    self._countAward = newTable
end

function GloryArenaAwardDialog:numberOfCellsInTableView(tableView)
    if self._curIndex == 1 then
        return #self._countAward
    elseif self._curIndex == 2 then
        return #self._rankStageAward
    end
	return 0
end

local itemConfigName = {
    {
        {name = "num", childName = "num", isText = true},
        {name = "awardBtn", childName = "awardBtn"},
        {name = "getDes", childName = "getDes", isText = true},
        {name = "des", childName = "des", isText = true},
        {name = "mask_img", childName = "mask_img"},
        {name = "receive_img", childName = "receive_img"},
    },
    {
        {name = "bgImage", childName = "bgImage"},
        {name = "awardImg", childName = "awardImg"},
        {name = "itemNameRank", childName = "itemNameRank", isText = true},
        {name = "getImg", childName = "getImg"},
        {name = "zhezhao", childName = "zhezhao"},
        {name = "exchangeBtn", childName = "exchangeBtn"},
        {name = "costImg", childName = "costImg"},
        {name = "costNum", childName = "costNum", isText = true},
        {name = "friendPanel", childName = "friendPanel"},
        {name = "nothing", childName = "friendPanel.nothing"},
        {name = "friendBg", childName = "friendPanel.friendBg"},
        {name = "friendBg_bg", childName = "friendPanel.friendBg.friendBg"},
        {name = "headIcon", childName = "friendPanel.friendBg.headIcon"},
        {name = "nameTxt", childName = "friendPanel.friendBg.nameTxt", isText = true},
        {name = "dexTxt", childName = "friendPanel.friendBg.dexTxt", isText = true},
        {name = "btntitleBg", childName = "btntitleBg"},
        {name = "itemIcon", childName = "itemIcon"},
        {name = "itemName1", childName = "itemName1", isText = true},
        {name = "itemName", childName = "itemName", isText = true},
        
        
    }
}

function GloryArenaAwardDialog:addItems(sender, data, offset)
    if sender and data then
        reward = {}
        for k,v in pairs(data) do
	    	if v[1] == "tool" then
                local var = {}
                var.typeId = v[2]
                var.num = v[3]
                reward[#reward + 1] = var
            elseif v[1] == "avatarFrame" then 
                local var = {}
                var.typeId = v[2]
                var.num = v[3]
                var.strType = "avatarFrame"
                reward[#reward + 1] = var
            else
                local var = {}
                var.typeId = IconUtils.iconIdMap[v[1]]
                var.num = v[3]
                reward[#reward + 1] = var
--	    	elseif v[1] == "gold" then
--                local var = {}
--                var.typeId = IconUtils.iconIdMap["gold"]
--                var.num = v[3]
--	    		reward[#reward + 1] = var
--	    	elseif v[1] == "gem" then
--                local var = {}
--                var.typeId = IconUtils.iconIdMap["gem"]
--                var.num = v[3]
--    			reward[#reward + 1] = var
--            elseif v[1] == "texp" then
--                local var = {}
--                var.typeId = IconUtils.iconIdMap["texp"]
--                var.num = v[3]
--    			reward[#reward + 1] = var
--            elseif v[1] == "honorCertificate" then
--                local var = {}
--                var.typeId = IconUtils.iconIdMap["texp"]
--                var.num = v[3]
--    			reward[#reward + 1] = var
	    	end
	    end
        for key, var in ipairs(reward) do
            if var then
                if not var.strType then
                    local sysItem = tab:Tool(var.typeId)
                    local item = IconUtils:createItemIconById({itemId = var.typeId, num = var.num, itemData = sysItem})
                    item:setScale(0.6)
                    item:setPosition(cc.p(offset.x + (key - 1) * 60, offset.y))
                    sender:addChild(item)
                elseif var.strType == "avatarFrame" then
                    local frameData = tab:AvatarFrame(var.typeId)
                    param = {itemId = var.typeId, num = var.num, itemData = frameData}
                    local icon = IconUtils:createHeadFrameIconById(param)
                    icon:setPosition(cc.p(offset.x + (key - 1) * 60, offset.y))
                    icon:setScale(0.56)
                    sender:addChild(icon)
                end
            end
        end
    end
end

function GloryArenaAwardDialog:updateItem(item, nIdx)
    if item == nil then
        return
    end
    local childNodeTable = self:lGetChildrens(item, itemConfigName[self._curIndex])
    if childNodeTable then
        if self._curIndex == 1 then
            local data = self._countAward[nIdx]
            self:addItems(item, data.award, cc.p(200, 20))
            childNodeTable.awardBtn:setVisible(false)
            local text = childNodeTable.awardBtn:getTitleRenderer()
            childNodeTable.awardBtn:setTitleFontName(UIUtils.ttfName)
            text:disableEffect()

            childNodeTable.num:setString(data.chalNum)

            local chalNum = self._gloryArenaModel:lGetSelfAttackCount().chalNum or 0
            childNodeTable.mask_img:setVisible(false)
            childNodeTable.receive_img:setVisible(false)
            childNodeTable.mask_img:setLocalZOrder(2)
            if chalNum >= data.chalNum then
                childNodeTable.awardBtn:setVisible(true)
                childNodeTable.getDes:setVisible(false)
                self:registerClickEvent(childNodeTable.awardBtn, function()
                    self._serverMgr:sendMsg("CrossArenaServer", "getChallengeAward", {id = tostring(data.id)}, true, {}, function(result) 
                            if result.errorCode and 0 ~= result.errorCode then 
                                self._gloryArenaModel:reflashEnterCrossArena(function()
                                    self:reflashUI()                                
                                end)
				            else
                                childNodeTable.awardBtn:setVisible(false)
                                childNodeTable.getDes:setVisible(false)
                                childNodeTable.mask_img:setVisible(true)
                                childNodeTable.receive_img:setVisible(true)
--                                DialogUtils.showGiftGet( {gifts = result.rewards})
                                DialogUtils.showGiftGet({gifts = result.rewards,notPop = true})
                                self:relfashCountAwardTable()
                                self._tableView:reloadData()
                                self:lCheckRedSport()
                            end
                    end)
                end)
            else
                childNodeTable.awardBtn:setVisible(false)
                childNodeTable.getDes:setVisible(true)
            end

            local bIsBought = false

            if self._gloryArenaModel:lGetArenaShop(2)[data.id] then
                bIsBought = true
            end

            if bIsBought then
                childNodeTable.awardBtn:setVisible(false)
                childNodeTable.getDes:setVisible(false)
                childNodeTable.mask_img:setVisible(true)
                childNodeTable.receive_img:setVisible(true)
            end

        elseif self._curIndex == 2 then
            local data = self._rankStageAward[nIdx]

            local rank = self._gloryArenaModel:lGetSelfRank()

            self:addItems(item, data.award, cc.p(200, 20))

            childNodeTable.awardImg:setVisible(false)
            childNodeTable.getImg:setVisible(false)
            childNodeTable.zhezhao:setVisible(false)
            childNodeTable.friendBg:setVisible(false)
            childNodeTable.itemIcon:setVisible(false)

            local text = childNodeTable.exchangeBtn:getTitleRenderer()
            childNodeTable.exchangeBtn:setTitleFontName(UIUtils.ttfName)
            text:disableEffect()

            local userData = self._modelMgr:getModel("UserModel"):getData()
            local currency = userData["honorCertificate"] or 0
            
            childNodeTable.costNum:setString(data.cost)
            childNodeTable.itemNameRank:setString(data.limit)

            childNodeTable.itemName1:setPositionX(childNodeTable.itemNameRank:getPositionX() + childNodeTable.itemNameRank:getContentSize().width)

            --等级
            local bIsLevel = false
            if rank <= data.limit then
                bisLevel = true
--                childNodeTable.exchangeBtn:loadTextures("globalButtonUI13_1_2.png", "globalButtonUI13_1_2.png", "", ccui.TextureResType.plistType)
                UIUtils:setGray(childNodeTable.exchangeBtn,false)
            else
                bisLevel = false
                UIUtils:setGray(childNodeTable.exchangeBtn,true)
--                childNodeTable.exchangeBtn:loadTextures("globalButtonUI13_3_2.png", "globalButtonUI13_3_2.png", "", ccui.TextureResType.plistType)
            end

            --货币是否够
            local bIscurrency = false
            if currency >= data.cost then
                bIscurrency = true
            end

            childNodeTable.costNum:setColor(bIscurrency and cc.c3b(60, 42, 30) or cc.c3b(255, 0, 0))

            --是否购买过
            local bIsBought = false

            if self._gloryArenaModel:lGetArenaShop(1)[data.id] then
                bIsBought = true
            end
            childNodeTable.costImg:ignoreContentAdaptWithSize(false)
            childNodeTable.costImg:loadTexture("globalImageUI_gloryArenaIcon_min.png", ccui.TextureResType.plistType)
            if bIsBought then
                childNodeTable.getImg:setVisible(true)
                childNodeTable.exchangeBtn:setVisible(false)
                childNodeTable.btntitleBg:setVisible(false)
                childNodeTable.costNum:setVisible(false)
                childNodeTable.costImg:setVisible(false)
            end

            self:registerClickEvent(childNodeTable.exchangeBtn, function()
                local rank = self._gloryArenaModel:lGetSelfRank()
                if rank > data.limit then
                    self._viewMgr:showTip(lang("TIPS_AWARDS_01"))
                elseif currency < data.cost then
                    self._viewMgr:showTip(lang("honorArena_tip_8"))
                else
                    --购买
                    --弹出二级确认框
				    local desc = "[color=3d1f00,fontsize=22]是否消耗[pic=globalImageUI_gloryArenaIcon_min.png][-]"  .. data.cost .. "进行奖励兑换？[-]"
				    self._viewMgr:showDialog("global.GlobalSelectDialog", {desc = desc, button1 = "", callback1 = function( )
			                self._serverMgr:sendMsg("CrossArenaServer", "exchangeShop", {id = tostring(data.id)}, true, {}, function(result) 
				           	    if not self or not childNodeTable or  tolua.isnull(childNodeTable.exchangeBtn) then return end
                                if result.errorCode and 0 ~= result.errorCode then 
                                    if 1117 == tonumber(result.errorCode) then
                                        self._viewMgr:showTip(lang("honorArena_tip_24"))
                                    end
                                    --9503    该奖励不属于当前赛季，无法领取
                                    self._gloryArenaModel:reflashEnterCrossArena(function()
                                        self:reflashUI()                                
                                    end)
                                    
				                else
				            	    --隐藏按钮和条件
				            	    childNodeTable.getImg:setVisible(true)
                                    childNodeTable.exchangeBtn:setVisible(false)
                                    childNodeTable.btntitleBg:setVisible(false)
                                    childNodeTable.costNum:setVisible(false)
                                    childNodeTable.costImg:setVisible(false)
                                    DialogUtils.showGiftGet( {gifts = result.rewards})
--                                    DialogUtils.showGiftGet({gifts = result.rewards,notPop = true})
                                    self:initTopLay()
                                    self:lCheckRedSport()
                                    if self._rankStageAward then
                                        for key = 0, #self._rankStageAward - 1 do
                                            self._tableView:updateCellAtIndex(key)
                                        end
                                    end
				                end         
				            end)
			            end, 
			            button2 = "",titileTip=true},true)	
                end
            end)
        end
    end
end

-- 接收自定义消息
function GloryArenaAwardDialog:reflashUI(data)
--   self:relfashCountAwardTable()
--    print("++++++++++++++++++++++++++++++++++++")
    if self._isReloadData then
        self._rankStageAward = self._gloryArenaModel:lGetSeasonReward()
        self._countAward = clone(tab.honorArenaActivity)
        self:relfashCountAwardTable()
        local curIndex = self._curIndex
        self._curIndex = 0
        self:touchTab(curIndex)
    else
        self._isReloadData = true
    end
--    self:lCheckRedSport()
--    self:initTab()
--	self:addTableView()
--    self:touchTab(1)
--    self:initTopLay()
end

function GloryArenaAwardDialog:dtor(args)
    childName = nil
    itemConfigName = nil
    -- tipBg = nil
end


return GloryArenaAwardDialog
