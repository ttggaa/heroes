--[[
    Filename:    HeroduelRankView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-02-04 10:27:02
    Description: File description
--]]


local HeroduelRankView = class("HeroduelRankView",BaseView)
function HeroduelRankView:ctor(param)
    self.super.ctor(self)
    self.initAnimType = 1
    param = param or {}
    self._rankType = tonumber(param.rankType) or 11   --英雄争锋排行榜
    self._rankModel = self._modelMgr:getModel("RankModel")

end

function HeroduelRankView:getAsyncRes()
    return 
    {
        {"asset/ui/arena.plist", "asset/ui/arena.png"},
    }
end

function HeroduelRankView:getBgName()
    return "bg_007.jpg"
end

function HeroduelRankView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{types = {"3042","Gold","HDuelCoin"},title = "globalTitleUI_killRank.png",titleTxt = "排行榜",callback = function()
            self._rankModel:clearRankList()
        end})
end
function HeroduelRankView:setNoticeBar()
    self._viewMgr:hideNotice(true)
end
-- 第一次被加到父节点时候调用
function HeroduelRankView:onBeforeAdd(callback, errorCallback)
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
function HeroduelRankView:onInit()
    -- 通用动态背景
    self:addAnimBg()   

    self._itemData = nil
    self._leftBoard = self:getUI("bg.bgPanel.leftBoard")
    self._noRankBg = self:getUI("bg.bgPanel.noRankBg")
    self._noRankBg:setVisible(false)
    self._titleBg = self:getUI("bg.bgPanel.titleBg")
    self._titleBg:getChildByFullName("title1"):setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    self._titleBg:getChildByFullName("title2"):setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    self._titleBg:getChildByFullName("title3"):setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    self._titleBg:getChildByFullName("title4"):setColor(UIUtils.colorTable.ccUIBaseTextColor1)

    self:getUI("bg.bgPanel.image_mask _0"):setOpacity(0)
    self:getUI("bg.bgPanel.image_mask _1"):setOpacity(0)


    self._selfItem = self:getUI("bg.bgPanel.selfItem")
    self._rankItem = self:getUI("bg.bgPanel.rankItem")
    self._rankItem:setVisible(false)

    self._tableNode = self:getUI("bg.bgPanel.tableNode")
    self._tableCellW,self._tableCellH = self._rankItem:getContentSize().width,self._rankItem:getContentSize().height

    self._tableData = {}
    self._allRankData = {}
    -- 递进刷新控制
    local flashData = tab:Setting("G_RANK_DUEL_SHOW").value
    self.beginIdx = tonumber(flashData[1]) or 20
    self.addStep = tonumber(flashData[1]) or 20
    self.endIdx = tonumber(flashData[2]) or 500

    self._offsetX = nil
    self._offsetY = nil
    self._tableView = nil

    self:addTableView()
    -- 暂时不做监听刷新
    -- self:listenReflash("RankModel", self.reflashUI)

end

local rankImgs = {"firstImg","secondImg","thirdImg"}
function HeroduelRankView:reflashUserInfo()
    local item  = self._selfItem
    local rankData = self._rankModel:getSelfRankInfo(self._rankType)
    if not rankData then print("====================no rankInfo....",self._rankType) return end
    
    local nameLab = item:getChildByFullName("nameLab")
    nameLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    local winLab = item:getChildByFullName("winLab")
    winLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    local UIscoreLab = item:getChildByFullName("scoreLab")
    UIscoreLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    local rank = rankData.rank
    local rankLab = item:getChildByName("rankLab")
    if not rankLab then
        rankLab = cc.LabelBMFont:create("4", UIUtils.bmfName_rank)
        rankLab:setAnchorPoint(cc.p(0.5,0.5))
        rankLab:setPosition(70, 50)
        rankLab:setName("rankLab")
        item:addChild(rankLab, 1)
    end
    rankLab:setScale(0.9)
    --玩家名称
    local userData = self._modelMgr:getModel("UserModel"):getData()
    nameLab:setString(userData.name)

    --联盟label
    local winTimes = (rankData.i1 or "") .. "胜" .. (rankData.i2 or "") .. "次"
    winLab:setVisible(true)
    if rankData.rank ~= 0 then 
        winLab:setString(winTimes)
    else 
        winLab:setString("未入榜")     --联盟击杀排行榜一般不会出现这种情况
    end

    --得分label
    UIscoreLab:setString(rankData.i3 or "")

    for i=1,3 do
        local rankImg = item:getChildByFullName(rankImgs[tonumber(i)])
        rankImg:setVisible(false)
    end
    if rank then  
        rankLab:setString(rank)
        -- if rank <= 3 and rank > 0 then
        --  item:loadTexture("arenaRankUI_cellBg1.png",1)
        -- else
            -- item:loadTexture("arenaRankUI_cellBg5.png",1)
        -- end
        if rankImgs[tonumber(rank)] then
            rankLab:setVisible(false)
            local rankImg = item:getChildByFullName(rankImgs[tonumber(rank)])
            rankImg:setVisible(true)
        else
            if rank > 999 then
                rankLab:setScale(0.7)
            end
            rankLab:setVisible(true)
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
        txt:setPosition(rankLab:getPositionX(), rankLab:getPositionY() - 10)
        txt:setFontName(UIUtils.ttfName)
        txt:setColor(UIUtils.colorTable.ccUIBaseColor1)
        txt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        item:addChild(txt)      
    end

    self:registerClickEvent(item,function( )
        -- print("==========*********************")
        self:selfItemClicked(rankData)          
       
    end)

    --启动特权类型
    local tequan = self._modelMgr:getModel("TencentPrivilegeModel"):getTencentTeQuan() or ""
--	data["tequan"] = "sq_gamecenter"
	local tequanImg = IconUtils.tencentIcon[tequan] or "globalImageUI6_meiyoutu.png"
	local tequanIcon = ccui.ImageView:create(tequanImg, 1)
    tequanIcon:setScale(0.65)
    tequanIcon:setPosition(cc.p(247, item:getContentSize().height*0.5 - 27))
	item:addChild(tequanIcon)

    local qqVipTp = self._modelMgr:getModel("TencentPrivilegeModel"):getQQVip() or ""
--    data["qqVip"] = "is_qq_svip"
    local qqVipImg = (qqVipTp and qqVipTp ~= "") and IconUtils.tencentIcon[qqVipTp .. "_head"] or "globalImageUI6_meiyoutu.png"
    local qqVipIcon = ccui.ImageView:create(qqVipImg, 1)
    qqVipIcon:setScale(24 / qqVipIcon:getContentSize().width)
    qqVipIcon:setPosition(cc.p(nameLab:getPositionX() + nameLab:getContentSize().width*0.5 + 16, item:getContentSize().height*0.5 + 5))
	item:addChild(qqVipIcon)

end

function HeroduelRankView:reflashNo1( data )

    local name = self._leftBoard:getChildByFullName("name")
    local level = self._leftBoard:getChildByFullName("level")
    local guild = self._leftBoard:getChildByFullName("guild")
--    local detailBtn = self._leftBoard:getChildByFullName("showDetail")
--    detailBtn:setVisible(false)
    name:setString("暂无榜首")
    level:setString("") 
    guild:setString("")

    if not data then return end
--    detailBtn:setVisible(true)
    local name = self._leftBoard:getChildByFullName("name")
    name:setString(data.name)
    local level = self._leftBoard:getChildByFullName("level")
    level:setString("等级:" .. (data.level or data.lvl or 0))
    
    --联盟label
    -- local winTimes = (data.i1 or "") .. "胜" .. (data.i2 or "") .. "次"
    local serverStr = self._modelMgr:getModel("LeagueModel"):getServerName(data.sec)
    if data.rank ~= "" then 
        guild:setString(serverStr)
        guild:setVisible(true)
    else
        guild:setVisible(false)
    end

    local avatarIcon = self._leftBoard:getChildByFullName("avatarIcon")
    if avatarIcon then
        avatarIcon:setVisible(false)
        avatarIcon:removeFromParent()
    end
    -- local guildLeader = self._leftBoard:getChildByFullName("guildLeader")    
    -- guildLeader:setVisible(false)

    -- print("=======avatarName======================",data.avatar)
--    local avatarName = data.avatar
--    if avatarName == 0 or not avatarName then avatarName = 1203 end 
--    local icon = IconUtils:createHeadIconById({avatar = avatarName,tp = 3,avatarFrame = data["avatarFrame"]}) 
--    icon:setName("avatarIcon")
--    icon:setAnchorPoint(cc.p(0.5,0.5))
--    -- icon:setScale(1.21)
--    icon:setPosition(100,410)
--    self._leftBoard:addChild(icon)

    local roleAnim = self._leftBoard._roleAnim
	if roleAnim then
		roleAnim:setVisible(false)
		roleAnim:removeFromParent()
	end
	-- 左侧人物形象
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
    sp:setPosition(self._leftBoard:getContentSize().width*0.5,220)
    self._leftBoard._roleAnim = sp
    self._leftBoard:addChild(sp,1)
    
    self:registerClickEventByName("bg.bgPanel.leftBoard",function( )
        self:itemClicked(data)
    end)
end

function HeroduelRankView:addTableView( )
	self._tableViewW = 616
	self._tableViewH = 318
    local tableView = cc.TableView:create(cc.size(self._tableViewW, self._tableViewH))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(11,10))
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


function HeroduelRankView:createLoadingMc()
    if self._loadingMc then return end
    -- 添加加载中动画
    self._loadingMc = mcMgr:createViewMC("jiazaizhong_rankjiazaizhong", true, false, function (_, sender)      end)
    self._loadingMc:setName("loadingMc")
    self._loadingMc:setPosition(cc.p(self._tableNode:getContentSize().width*0.5 - 30, self._tableView:getPositionY() + 20))
    self._tableNode:addChild(self._loadingMc, 1000)
    self._loadingMc:setVisible(false)
end

function HeroduelRankView:scrollViewDidScroll(view)
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
    if self._tableData and #self._tableData < 4 then
        -- tableView height 330
        condY = self._tableViewH - #self._tableData*(self._tableCellH+5)
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

function HeroduelRankView:scrollViewDidZoom(view)
    -- print("scrollViewDidZoom")
end

function HeroduelRankView:tableCellTouched(table,cell)
    print("cell touched at index: " .. cell:getIdx())
end

function HeroduelRankView:cellSizeForTable(table,idx) 
    return self._tableCellH+5,self._tableCellW
end

function HeroduelRankView:tableCellAtIndex(table, idx)
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
    item:setPosition(cc.p(0,4))
    item:setAnchorPoint(cc.p(0,0))
    cell:addChild(item)

    return cell
end

function HeroduelRankView:numberOfCellsInTableView(table)
    -- print("#self._tableData",#self._tableData)
    return #self._tableData 
end

function HeroduelRankView:createItem( data,index )
     -- dump(data,"paranm")
    if data == nil then return end
    self._itemData = data

    local item = self._rankItem:clone()
    item:setContentSize(self._tableCellW,self._tableCellH)
    local rankLab = item:getChildByFullName("rankLab")
    rankLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    local nameLab = item:getChildByFullName("nameLab")
    nameLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    local winLab = item:getChildByFullName("winLab")
    winLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    local UIscoreLab = item:getChildByFullName("scoreLab")
    UIscoreLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    item:setVisible(true)
    self._currItem = item
    item.data = data
    local rank = data.rank
    local score = data.i3
    --初始化名称
    local name = data.name or ""
    nameLab:setString(name)

    --联盟label
    local winTimes = (data.i1 or "") .. "胜" .. (data.i2 or "") .. "次"
    winLab:setString(winTimes)

    UIscoreLab:setString(score)

--    local rankLab = item:getChildByName("rankLab")
--    if not rankLab then
--        rankLab = cc.LabelBMFont:create("4", UIUtils.bmfName_rank)
--        rankLab:setAnchorPoint(cc.p(0.5,0.5))
--        rankLab:setPosition(60, 50)
--        rankLab:setName("rankLab")
--        item:addChild(rankLab, 1)
--    end
    rankLab:setString(rank or 0)

    if rank <= 3 and rank > 0 then
        -- item:loadTexture("arenaRankUI_cellBg".. rank ..".png",1)
    else
        -- item:loadTexture("arenaRankUI_cellBg4.png",1)
    end
    -- item:setCapInsets(cc.rect(160,40,1,1))
    for i=1,3 do
        local rankImg = item:getChildByFullName(rankImgs[tonumber(i)])
        -- local rankMc = rankImg:getChildByFullName("rankmc" .. i)
        -- if 1 == i then
        --  if not rankMc then              
        --      rankMc = mcMgr:createViewMC("diyiming_paimingeffect", true, false, function (_, sender)
        --         end)
        --         rankMc:setName("rankmc1")
        --         rankMc:setScale(0.8)
        --         rankMc:setPosition(cc.p(rankImg:getContentSize().width*0.5, rankImg:getContentSize().height*0.5 - 2))
        --         rankImg:addChild(rankMc, -1)
        --     end
  --      else
  --            if not rankMc then
        --          rankMc = mcMgr:createViewMC("ersanming_paimingeffect", true, false, function (_, sender)
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
    -- local children = item:getChildren()
    -- for k,v in pairs(children) do
    --  v:setSwallowTouches(false)
    -- end  

    --启动特权类型
--	 data["tequan"] = "sq_gamecenter"
	local tequanImg = IconUtils.tencentIcon[data["tequan"]] or "globalImageUI6_meiyoutu.png"
	local tequanIcon = ccui.ImageView:create(tequanImg, 1)
    tequanIcon:setScale(0.65)
    tequanIcon:setPosition(cc.p(233, item:getContentSize().height*0.5 - 22))
	item:addChild(tequanIcon)

--    data["qqVip"] = "is_qq_svip"
    local qqVipImg = (data["qqVip"] and data["qqVip"] ~= "") and IconUtils.tencentIcon[data["qqVip"] .. "_head"] or "globalImageUI6_meiyoutu.png"
    local qqVipIcon = ccui.ImageView:create(qqVipImg, 1)
    qqVipIcon:setScale(24 / qqVipIcon:getContentSize().width)
    qqVipIcon:setPosition(cc.p(nameLab:getPositionX() + nameLab:getContentSize().width*0.5 + 16, item:getContentSize().height*0.5 + 5))
	item:addChild(qqVipIcon)

    return item
end

function HeroduelRankView:reflashNoRankUI()
    if (not self._tableData or #self._tableData <= 0) then
        
        self._noRankBg:setVisible(true)
        self._selfItem:setVisible(false)
        self._tableNode:setVisible(false)
        self._titleBg:setVisible(false)
        -- self._norankFlag = UIUtils:addBlankPrompt( self._noRankBg,{scale = 0.7,x=165,y=245,des="排行榜还没有整理完成哦~"} )
    else
        -- if self._norankFlag then
        --  self._norankFlag:removeFromParent()
        --  self._norankFlag = nil
        -- end
        self._noRankBg:setVisible(false)
        self._selfItem:setVisible(true)
        self._tableNode:setVisible(true)
        self._titleBg:setVisible(true)
    end
end

function HeroduelRankView:selfItemClicked(data)
    if not data then return end
    -- if true then return end
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local roleId = userData.sec .. "-" .. userData._id
    -- self._itemData = {}
    -- self._itemData.rid = roleId
    -- self._itemData.name = userData.name
    -- self._itemData.level = userData.lvl or userData.level
    -- self._itemData.rank = data.rank  
    -- self._itemData.score = data.score
    if roleId and roleId ~= 0 then
        local param = {roleId = roleId, type = 11}
        self._serverMgr:sendMsg("RankServer", "getDetailRank", param, true, {}, function(result) 
            local data1 = result
            data1.rank = data.rank
            data1.serverNum = userData.sec
            data1.isNotShowBtn = true
            data1.isServerName = true
            self._viewMgr:showDialog("arena.DialogArenaUserInfo",data1,true)
        end)
    else
        print("=======数据异常-================")
    end
end

function HeroduelRankView:itemClicked(data)    
    if not data then return end
    -- self._itemData = data
    if data.key and data.key ~= 0 then
        -- dump(param,"paranm")
        -- dump(data,"dataItemClicked-->")
        local param = {roleId = data.key, type = 11}
        self._serverMgr:sendMsg("RankServer", "getDetailRank", param, true, {}, function(result) 
            local data1 = result
            data1.rank = data.rank
            data1.serverNum = data.sec
            data1.isNotShowBtn = true
            data1.isServerName = true
            self._viewMgr:showDialog("arena.DialogArenaUserInfo",data1,true)
        end)
    else
        print("=======数据异常-================")
    end
end

--是否要刷新排行榜
function HeroduelRankView:sendMessageAgain()
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
    --  -- if self.
    --  if #self._allRankData > statCount then
    --      self:searchForPosition(statCount,addCount,endCount)     
    --      self:reflashUI()
    --  end     
        self._canRequest = false
        self._viewMgr:unlock()
    end
end
--刷新之后tableView 的定位
function HeroduelRankView:searchForPosition(statCount,addCount,endCount)   
    self._offsetX = 0
    if statCount + addCount <= endCount then
        self.beginIdx = statCount + addCount
        local subNum = #self._allRankData - statCount

        if subNum < addCount then
            self._offsetY = -1 * (tonumber(subNum) * (self._tableCellH+5))          
        else
            self._offsetY = -1 * (tonumber(self.addStep) * (self._tableCellH+5))            
        end
        
    else
        self.beginIdx = endCount
        self._offsetY = -1 * (endCount - statCount) * (self._tableCellH+5)
    end
end
--获取当前排行榜数据
function HeroduelRankView:sendGetRankMsg(tp,start,callback)
    self._rankModel:setRankTypeAndStartNum(tp,start)
    self._serverMgr:sendMsg("RankServer", "getRankList", {type=tp,startRank = start}, true, {}, function(result) 
        if callback then
            callback()
        end
        self:reflashUI()
        self:reflashNoRankUI()
    end)
end
-- --获取自己排行榜数据
-- function HeroduelRankView:sendGetSelfRankMsg( tp )
--  self._serverMgr:sendMsg("RankServer", "getMyRank", {type=tp}, true, {}, function(result) 
--      if #self._tableData > 0 then
--          self:reflashUserInfo()
--      end
--     end)
-- end

--刷心排行榜后显示的数据
function HeroduelRankView:updateTableData(rankList,index)
    -- print("*************************",index)
    local data = {}
    for k,v in pairs(rankList) do
        if tonumber(v.rank) <= tonumber(index) then
            data[k] = v
        end
    end
    return data
end

-- 接收自定义消息
function HeroduelRankView:reflashUI(data)

    local offsetX = nil
    local offsetY = nil
    if self._offsetX and self._offsetY then
        offsetX = self._offsetX
        offsetY = self._offsetY
    end
    self._allRankData = self._rankModel:getRankList(self._rankType)
    self._tableData = self:updateTableData(self._allRankData,self.beginIdx)
    -- print("************&&&&&&&&&&&&-----------",#self._tableData)
    if self._tableData and self._tableView then     
        self._tableView:reloadData()
        if offsetX and offsetY and not self._firstIn then
            -- print("=========================",offsetX,offsetY)
            self._tableView:setContentOffset(cc.p(offsetX,offsetY))
            self._canRequest = false
        end     
        self._firstIn = false
    end

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
    
    if self._tableData then
        self:reflashNo1(self._tableData[1])
    end
    
end


function HeroduelRankView.dtor()
    rankImgs = nil  
end

return HeroduelRankView