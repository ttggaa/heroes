--
-- Author: zhaoyang
-- Date: 2016-06-12 16:15:58

local AiRenMuWuRewardView = class("AiRenMuWuRewardView",BasePopView)
function AiRenMuWuRewardView:ctor()
    AiRenMuWuRewardView.super.ctor(self)
    self._bossModel = self._modelMgr:getModel("BossModel")
    self._userModel = self._modelMgr:getModel("UserModel")
end
local bossId = "4" 
local typeTable = {
                        tableName = "dwarfDailyReward" ,
                        rankImgName ="rankTitleTxt1",
                        itemNameStart ="本日击杀矮人数量达到" ,
                        itemNameEnd = "",
                        AWARDS_COLOR = "G_DWARF_AWARDS_COLOR"
                }

-- 初始化UI后会调用, 有需要请覆盖
function AiRenMuWuRewardView:onInit()

    -- item awardBg
    -- self._awardImg = {
    --     [1] = "arenaAward_awardBg_com.png",
    --     [2] = "arenaAward_awardBg_com.png",
    --     [3] = "arenaAward_awardBg_blue.png",
    --     [4] = "arenaAward_awardBg_purple.png",
    --     [5] = "arenaAward_awardBg_com.png",
    --     [6] = "arenaAward_awardBg_com.png",
    -- }

    self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
        UIUtils:reloadLuaFile("pve.AiRenMuWuRewardView")
    end)

    self._rankNum = self:getUI("bg.bg2.rankTitleBg.rankNum")
    -- self._rankNum:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    self._rankNum:setFontName(UIUtils.ttfName)
    local killNumTxt = self:getUI("bg.bg2.rankTitleBg.rankTitleTxt")
    -- killNumTxt:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    killNumTxt:setFontName(UIUtils.ttfName)

    self._tableNode = self:getUI("bg.bg2.tableNode")
    self._canGetIdData = {}
    self._sendGetId = {}
    self._allGetBtn = self:getUI("bg.bg2.allGetBtn")
    self:registerClickEvent(self._allGetBtn , function (sender) 
        self._sendGetId = self._canGetIdData
        self:lock(-1)
        self._serverMgr:sendMsg("BossServer", "getPVEDailyReward", 
                    {bossId = tonumber(self.bossId),id = self._sendGetId}, true, {}, function(errorCode ,result) 

            if not tolua.isnull(self) and not tolua.isnull(sender) then
                self._bossModel:setRanksAndUserInfo(tonumber(bossId),result.d)
                local rewards = result.reward or {}
                self:playGetAnim(nil,rewards,result) 
            end
        end)
    end)

    self._item = self:getUI("bg.item")
    self._item:setVisible(false)
    self._tableCellW,self._tableCellH = self._item:getContentSize().width,self._item:getContentSize().height

    self._tableDataStatic = clone(tab[typeTable.tableName])
 
    self._times = {}
    self:addTableView() 
    self._offsetX = 0
    self._offsetY = nil
    -- self._offsetY = 0
end

-- 接收自定义消息
function AiRenMuWuRewardView:reflashUI(data)
    local offsetX = self._offsetX
    local offsetY = self._offsetY
    
    local bossData = self._bossModel:getDataByPveId(bossId)
    if bossData then
        self.rank = bossData.highScore or 0
    else
        self.rank = 0
    end
    self._rankNum:setString(tostring(self.rank))
    local rewardList  = self._bossModel:getRawardList(bossId)
    self:initTableData()
    if self._tableData and  self._tableView then
        self._tableView:reloadData()
        if offsetY then
            self._tableView:setContentOffset(cc.p(offsetX,offsetY))
        end
    end

    self._allGetBtn:setVisible(#self._canGetIdData > 0)
end

-- 初始化数据  未领 > 已领
function AiRenMuWuRewardView:initTableData()
    self._canGetIdData = {}
    local rewardList  = self._bossModel:getRawardList(bossId)  
    self._tableData = {}
    local awardData = {}
    local getData = {}
    for k,v in pairs(self._tableDataStatic) do
       v.isGetted = false
       for id,vv in pairs(rewardList) do
            if v.id == tonumber(id) then
                v.isGetted = true
                break
            end
        end
    end   

    for k,v in pairs(self._tableDataStatic) do
        if v.isGetted then
            table.insert(getData,v)
        else
            table.insert(awardData,v)
        end
    end

    table.sort(getData,function ( a,b )
            return tonumber(a.condition) < tonumber(b.condition)
        end)

    table.sort(awardData,function ( a,b )
            return tonumber(a.condition) < tonumber(b.condition)
        end)

    local vipLv = self._modelMgr:getModel("VipModel"):getData().level or 0
    for k,v in pairs(awardData) do
        local limit = v.viplimit or 0
        -- vip and level 限制
        if vipLv >= limit and self._userModel:getPlayerLevel() >= v.effective[1] and self._userModel:getPlayerLevel() <= v.effective[2] then
            if self.rank >= v.condition then
                table.insert(self._canGetIdData,v.id)
            end
            table.insert(self._tableData,v)
        end
    end

    for k,v in pairs(getData) do
        table.insert(self._tableData,v)
    end
end

-- 换 tableView
function AiRenMuWuRewardView:addTableView()
    local tableView = cc.TableView:create(cc.size(self._tableNode:getContentSize().width, self._tableNode:getContentSize().height-15))
    tableView:setColor(cc.c3b(255,255,255))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(11,8))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    -- tableView:setBounceEnabled(false)
    self._tableNode:addChild(tableView)
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

function AiRenMuWuRewardView:scrollViewDidScroll(view)
    self._inScrolling = view:isDragging()
    
    self._offsetX = view:getContentOffset().x
    self._offsetY = view:getContentOffset().y
    -- print("====================view:getContentOffset().y---------",view:getContentOffset().y)
end

function AiRenMuWuRewardView:scrollViewDidZoom(view)
end

function AiRenMuWuRewardView:tableCellTouched(table,cell)
end

function AiRenMuWuRewardView:cellSizeForTable(table,idx) 
    return self._tableCellH,self._tableCellW
end

function AiRenMuWuRewardView:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    else
        cell:removeAllChildren()
    end
    local item = self:createItem(self._tableData[idx+1], idx)
    -- print("idx item",idx,item)
    if item then
        item:setPosition(cc.p(0,0))
        item:setAnchorPoint(cc.p(0,0))
        cell:addChild(item)
    end
    return cell
end

function AiRenMuWuRewardView:numberOfCellsInTableView(table)
    -- print("table num...",#self._tableData)
   return #self._tableData
end



function AiRenMuWuRewardView:createItem( data,idx )

    print(data.id)
    if data == nil  then return end
    item = self._item:clone()
    item:setVisible(true)
    item:setSwallowTouches(false)
    
    item.data = data
    ---[[todo : 创建物品
    local itemIcon = item:getChildByFullName("itemIcon")

    local reward = data.award or {}

    local rewardColor = 0 
    for i,v in ipairs(reward) do
        local itemId 
        if v[1] == "tool" then
            itemId = v[2]
        else
            itemId = IconUtils.iconIdMap[v[1]]
        end
        local toolD = tab:Tool(tonumber(itemId))
        if rewardColor <( toolD.color or 0) then
            rewardColor = toolD.color or 0 
        end
        local icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = v[3]})
        icon:setScale(72 / icon:getContentSize().width)
        itemIcon:setSwallowTouches(false)
        -- icon:setPosition(cc.p((i-1)%2*65-6,40-math.floor((i-1)/2)*65))
        icon:setPosition(cc.p((i-1)*80 + 12,10))
        itemIcon:addChild(icon)
    end
    local bgImage = item:getChildByFullName("bgImage")  

    local getImg = item:getChildByFullName("getImg")
    local itemName = item:getChildByFullName("itemName")
    itemName:setFontName(UIUtils.ttfName)
    local lim = data.condition  or 0 --lang(toolD.name) or "无名字"   
    itemName:setString( typeTable.itemNameStart .. lim..typeTable.itemNameEnd)

    local exchangeBtn = item:getChildByFullName("exchangeBtn")
    exchangeBtn:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine1 , 2)
    exchangeBtn:setTitleColor(UIUtils.colorTable.ccUICommonBtnColor1)
    exchangeBtn:setTitleFontName(UIUtils.ttfName) 
    exchangeBtn:setTitleFontSize(22) 
  
    self.bossId = bossId 
    self:registerClickEvent(exchangeBtn, function (sender) 
        self._tableView:stopScroll()
        if self.rank < lim then
            self._viewMgr:showTip(lang("TIPS_AWARDS_03"))            
        else 
            self:lock(-1)
            self._sendGetId = {}
            table.insert(self._sendGetId,data.id)
            self._serverMgr:sendMsg("BossServer", "getPVEDailyReward", 
                        {bossId = tonumber(self.bossId),id = self._sendGetId}, true, {}, function(errorCode ,result) 

                if not tolua.isnull(self) and not tolua.isnull(sender) then
                    self._bossModel:setRanksAndUserInfo(tonumber(bossId),result.d)
                    sender:setEnabled(false)                
                    sender:setVisible(false)                 
                    -- print("========================data.id,==",data.id)
                    local rewards = result.reward or {}
                    self:playGetAnim(data.id,rewards,result) 
                end

            end)
        end
    end)
    self._times[tostring(data.id)] = {}
    self._times[tostring(data.id)].bgImg = bgImage
    self._times[tostring(data.id)].getImg = getImg
    self._times[tostring(data.id)].exchangeBtn = exchangeBtn

    
    -- 根据是否已经领取 设置相关按钮信息
    if data.isGetted then
        getImg:setVisible(true)
        bgImage:loadTexture("globalPanelUI7_cellBg2.png",1)
        exchangeBtn:setEnabled(false)
        exchangeBtn:setVisible(false)
    else
        getImg:setVisible(false)
        exchangeBtn:setEnabled(true)
        exchangeBtn:setVisible(true)

        -- 置灰效果 
        if self.rank < lim then
            UIUtils:setGray(exchangeBtn,true)
            bgImage:loadTexture("globalPanelUI7_cellBg1.png",1)
        else
            bgImage:loadTexture("globalPanelUI7_cellBg0.png",1)
        end
    end
    return item
end


function AiRenMuWuRewardView:playGetAnim(id,award,result)
    if not id then
        if award then award.notPop = true end
        DialogUtils.showGiftGet(award or {})
        self:reflashUI() 
        self:unlock()
    else        
        local getImg = self._times[tostring(id)].getImg
        local bgImg = self._times[tostring(id)].bgImg
        getImg:setVisible(true)
        bgImg:setBrightness(0)
        getImg:setScale(3)
        local action = cc.Sequence:create(cc.ScaleTo:create(0.1,0.8),cc.ScaleTo:create(0.02,1),cc.DelayTime:create(0.02),
                            cc.CallFunc:create(function()
                            self._beginIdx = 1
        ----                self._modelMgr:getModel("UserModel"):updateUserData(result.d or {})
                            -- dump(result.rewards)
                            -- if result.rewards then
                            if award then award.notPop = true end  
                            DialogUtils.showGiftGet(award or {})
                            -- end 
                            self:reflashUI() 

                            self:unlock()
                        end))
        getImg:runAction(action)
    end
end

-- 获得板子和名字的颜色索引号
function AiRenMuWuRewardView:getBoardColorIndex( rank )
    if not self._boardNameColorMap then -- 白绿蓝紫橙红
        self._boardNameColorMap = tab:Setting(typeTable.AWARDS_COLOR).value
        -- dump(self._boardNameColorMap, "self._boardNameColorMap")
    end
    -- local colorData = {cc.c4b(255,200,150,255),cc.c4b(0,255,40,255),cc.c4b(0,150,255,255),
    --                     cc.c4b(250,40,250,255),cc.c4b(255,120,0,255),cc.c4b(255,50,50,255)}-- 白绿蓝紫橙红
    
    local index = 1
    for i,v in ipairs(self._boardNameColorMap) do 
        if rank <= v then
            break
        end               
        index = i
    end
    index = index > 6 and 6 or index 
    return index
    -- return colorData[index]
end

function AiRenMuWuRewardView.dtor()
    bossId = nil
    typeTable = nil
    AiRenMuWuRewardView = nil
end
return AiRenMuWuRewardView