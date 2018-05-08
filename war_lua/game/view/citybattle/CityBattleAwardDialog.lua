--[[
    Filename:    CityBattleAwardDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-02-23 16:41:56
    Description: File description
--]]


local userScore
local userRewardHistory = {}
local cloneCell

-- 阶段奖励
local CityBattleAwardDialog = class("CityBattleAwardDialog", BasePopView)
function CityBattleAwardDialog:ctor(data)
    -- dump(data)

    self:initData(data.resultData)
    self._callBack = data.callBack
    CityBattleAwardDialog.super.ctor(self)
    self._userModel = self._modelMgr:getModel("UserModel")
    self._initIndex = 1
end

function CityBattleAwardDialog:initData(data)
    local score = 0
    if data["p"] then
        for id, num in pairs(data["p"]) do 
            score = score + num
        end
    end
    userScore  = score
    print("userScore",userScore)

    userRewardHistory = {}
    if data["a"] then
        for id,value in pairs (data["a"]) do 
            userRewardHistory[id] = value
        end
    end
    -- self._getIndex = table.nums(userRewardHistory)
end

function CityBattleAwardDialog:showRedPoint(node,status)
    local redNode = node:getChildByName("RedPoint")
    if redNode then
        redNode:setVisible(status)
    elseif status then
        local imgRed = cc.Sprite:createWithSpriteFrameName("globalImageUI_bag_keyihecheng.png")
        imgRed:setName("RedPoint")
        imgRed:setPosition(-node:getContentSize().width/2+100, node:getContentSize().height - 10)
        node:addChild(imgRed)
    end
end


function CityBattleAwardDialog:onInit()
    self._citybattleModel = self._modelMgr:getModel("CityBattleModel")


    self:registerClickEventByName("bg.mainBg.closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("citybattle.CityBattleAwardDialog")
        end
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("citybattle.CityBattleCityRankDialog")
        end
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("citybattle.CityBattleGuildRankDialog")
        end
        if self._callBack then
            self._callBack()
        end
        self:close()
    end)

    self._rewardPanel = self:getUI("bg.mainBg.rewardPanel")
    self._perconPanel = self._rewardPanel:getChildByFullName("perconPanel")
    self._perconPanel:setVisible(false)
    cloneCell = self:getUI("cell")

    cloneCell:setVisible(false)

    self._tabData = clone(tab.cityBattleReward)
    local index = 1
    for id,data in pairs (self._tabData) do 
        if userRewardHistory[tostring(id)] then
            self._getIndex = index
        else
            break
        end
        index = index + 1
    end
    -- dump(userRewardHistory)
    -- dump(self._tabData,"aaa",10)

    -- print(self._getIndex,"self._getIndex")

    local totalScore = self._perconPanel:getChildByFullName("scoreNum")
    totalScore:setString(userScore)

    -- 个人
    local tab1 = self:getUI("bg.mainBg.btn_person")
    -- 联盟
    local tab2 = self:getUI("bg.mainBg.btn_guild")
    -- 城池
    local tab3 = self:getUI("bg.mainBg.btn_city")



    self:showRedPoint(tab3,self._citybattleModel:checkNewGvg())

    tab1:setTitleFontName(UIUtils.ttfName)
    tab2:setTitleFontName(UIUtils.ttfName)
    tab3:setTitleFontName(UIUtils.ttfName)

    local off = -40
    UIUtils:setTabChangeAnimEnable(tab1,off,function(sender)self:tabButtonClick(sender, 1)end)
    UIUtils:setTabChangeAnimEnable(tab2,off,function(sender)self:tabButtonClick(sender, 2)end)
    UIUtils:setTabChangeAnimEnable(tab3,off,function(sender)self:tabButtonClick(sender, 3)end)

    self._tabEventTarget = {}
    table.insert(self._tabEventTarget, tab1)
    table.insert(self._tabEventTarget, tab2)
    table.insert(self._tabEventTarget, tab3)

    local userGuild = self._userModel:getData().roleGuild
    if not userGuild or not userGuild.guildId or tonumber(userGuild.guildId) == 0 then
        UIUtils:setGray(tab2,true)
        self._haveNotGuild = true
    end

    -- self:progressData()
    if self._initIndex == 1 then
        self:addTableView()
        self:tabButtonClick(tab1, 1)
    end

    local topPanel = ccui.Layout:create()
    topPanel:setContentSize(570,30)
    self._rewardPanel:addChild(topPanel,6)
    topPanel:setTouchEnabled(true)
    topPanel:setPosition(0,440)

    local bottomPanel = ccui.Layout:create()
    bottomPanel:setContentSize(570,60)
    self._rewardPanel:addChild(bottomPanel,6)
    bottomPanel:setTouchEnabled(true)
    bottomPanel:setPosition(0,-60)

end

function CityBattleAwardDialog:getAsyncRes()
    return {            
               
}
end

function CityBattleAwardDialog:tabButtonState(sender, isSelected, key)
    local titleNames = {
        " 个人 ",
        " 联盟 ",
        " 城池 ",
    }
    local shortTitleNames = {
        "个人",
        "联盟",
        "城池",
    }

    -- local tabtxt = sender:getChildByFullName("tabtxt")
    -- tabtxt:setString("")

    sender:setBright(not isSelected)
    sender:setEnabled(not isSelected)
    sender:getTitleRenderer():disableEffect()

    if isSelected then
        sender:setTitleText(titleNames[key])
        sender:setTitleColor(UIUtils.colorTable.ccUITabColor2)
    else
        sender:setTitleText(shortTitleNames[key])
        sender:setTitleColor(UIUtils.colorTable.ccUITabColor1)
    end
end

function CityBattleAwardDialog:tabButtonClick(sender, key)
    if sender == nil then 
        return 
    end
    if self._tabName == sender:getName() then 
        return 
    end

    if sender:getName() == "btn_guild" then
        if self._haveNotGuild then
            self._viewMgr:showTip("您还没有联盟")
            if self._preBtn then
                UIUtils:tabChangeAnim(self._preBtn,nil,false)
            end
            return
        end
    end

    for k,v in pairs(self._tabEventTarget) do
        if v ~= sender then
            self:tabButtonState(v, false, k)
        end
    end

    

    if self._preBtn then
        UIUtils:tabChangeAnim(self._preBtn,nil,true)
    end
    self._preBtn = sender
    UIUtils:tabChangeAnim(sender,function()
        self:tabButtonState(sender, true, key)
        audioMgr:playSound("Tab")
        local tempBaseInfoNode = self._rewardPanel
        if sender:getName() == "btn_person" then
            self._perconPanel:setVisible(true)
            if not self._tableView then
                self:addTableView()
            end
            if self._guildRankLayer then
                self._guildRankLayer:setVisible(false)
            end
            if self._cityLayer then
                self._cityLayer:setVisible(false)
            end
        elseif sender:getName() == "btn_guild" then
            

            self._serverMgr:sendMsg("CityBattleServer", "getGuildRank", {page = 1}, true, {}, function (result, error)
                if result then
                    if self._guildRankLayer == nil then
                        self._guildRankLayer = self:createLayer("citybattle.CityBattleGuildRankDialog",result)
                        tempBaseInfoNode:addChild(self._guildRankLayer)
                    else
                        self._guildRankLayer:reflashUI(result)
                    end
                    self._guildRankLayer:setVisible(true)
                    self._perconPanel:setVisible(false)
                    if self._cityLayer then
                        self._cityLayer:setVisible(false)
                    end
                end
            end)
        elseif sender:getName() == "btn_city" then
            if self._cityLayer == nil then
                self._cityLayer = self:createLayer("citybattle.CityBattleCityRankDialog")
                tempBaseInfoNode:addChild(self._cityLayer)
                local tab3 = self:getUI("bg.mainBg.btn_city")
                self:showRedPoint(tab3,false)
            end
            self._cityLayer:setVisible(true)
            self._cityLayer:reflashUI()
            self._perconPanel:setVisible(false)
            if self._guildRankLayer then
                self._guildRankLayer:setVisible(false)
            end
        end
    end)
end

--[[
用tableview实现
--]]
function CityBattleAwardDialog:addTableView()
    self._perconPanel:setVisible(true)
    local tableViewBg = self._rewardPanel:getChildByFullName("perconPanel")
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height-12))
    self._tableView:setDelegate()
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0,5))
    self._tableView:registerScriptHandler(function(table, cell) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:setBounceable(true)
    self._tableView:reloadData()
    -- if self._tableView.setDragSlideable ~= nil then 
    --     self._tableView:setDragSlideable(true)
    -- end
    if self._getIndex and self._getIndex > 0 then
        local viewHeight = self._tableView:getContainer():getContentSize().height
        local offY =  tableViewBg:getContentSize().height+self._getIndex*124-10-viewHeight
        local realY = math.min(0,offY)
        self._tableView:setContentOffset(cc.p(0,realY))
    end
    tableViewBg:addChild(self._tableView)
end

function CityBattleAwardDialog:setInitOffSet( ... )
    if self._getIndex and self._getIndex > 0 then

    end
end

-- 触摸时调用
function CityBattleAwardDialog:tableCellTouched(table,cell)
end

-- cell的尺寸大小
function CityBattleAwardDialog:cellSizeForTable(table,idx) 
    local width = 550 
    local height = 124
    return height, width
end

-- 创建在某个位置的cell
function CityBattleAwardDialog:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local indexId = idx+1
    local param = self._tabData[indexId]
    if nil == cell then
        cell = cc.TableViewCell:new()
        local detailCell = cloneCell:clone() 
        detailCell:setVisible(true)
        detailCell:setPosition(cc.p(12,0))
        detailCell:setName("detailCell")
        cell:addChild(detailCell)

        local awardBtn = detailCell:getChildByFullName("awardBtn")
        UIUtils:setButtonFormat(awardBtn, 3, 0)

        local num = detailCell:getChildByFullName("num")
        num:setColor(cc.c3b(254, 249, 217))
        num:enable2Color(1,cc.c3b(235, 237, 145))
    end

    local detailCell = cell:getChildByName("detailCell")
    if detailCell then
        self:updateCell(detailCell, param, indexId)
        detailCell:setSwallowTouches(false)
    end

    return cell
end

-- 返回cell的数量
function CityBattleAwardDialog:numberOfCellsInTableView(table)
    return #self._tabData 
end

function CityBattleAwardDialog:getSize(value)
    local num  = tonumber(value)
    local size = {54,46,36,26}
    local index = math.floor(math.log10(value)) + 1 
    return size[index] or 26
end

function CityBattleAwardDialog:updateCell(inView, data, indexId)

    local awardBtn = inView:getChildByFullName("awardBtn")
    awardBtn:setVisible(false)
    local notGetImg = inView:getChildByFullName("notGetImg")
    notGetImg:setVisible(false)
    local done = inView:getChildByFullName("done") 
    done:setVisible(false)

    local num = inView:getChildByFullName("num")
    local condition = data.condition
    num:setString(condition)
    num:setFontSize(self:getSize(condition)) 

    -- local gvguser = self._citybattleModel:getGVGUserData()
    -- local gvguserScore = gvguser["p"]

    if userScore >= condition then
        if userRewardHistory[tostring(indexId)] then --已领取
            done:setVisible(true)
        else
            awardBtn:setVisible(true)
            awardBtn:setSwallowTouches(false)
            self:registerClickEvent(awardBtn,function()
                self:getAward(data.id)
            end)
        end
    else
        notGetImg:setVisible(true)
    end

    self:updateItem(inView, data)
end

function CityBattleAwardDialog:getAward(indexId)
    local param = {id = indexId}
    self._serverMgr:sendMsg("CityBattleServer", "getAward", param, true, {}, function (result)
        dump(result, "result===", 10)
        self._citybattleModel:updateGetRewardIds(indexId)
        if self.getAwardFinish then
            self:getAwardFinish(result)
        end
    end)
end

function CityBattleAwardDialog:getAwardFinish(result)
    if result == nil then
        return 
    end
    DialogUtils.showGiftGet({gifts = result.reward})
    -- self:progressData()
    -- self:reflashUI()
    if result["d"]["cb"] 
        and result["d"]["cb"]["a"] then
        for id,value in pairs (result["d"]["cb"]["a"]) do 
            userRewardHistory[id] = value
        end
    end
    self:reloadTableViewWithoutOff()
end

function CityBattleAwardDialog:reloadTableViewWithoutOff()
    if self._tableView then
        local off = self._tableView:getContentOffset()
        self._tableView:reloadData()
        self._tableView:setContentOffset(off)
    end
end

function CityBattleAwardDialog:updateItem(inView, data)
    local awardData = data.award
    print("===================",table.nums(awardData))
    for i=1,3 do
        local itemIcon = inView["award" .. i]
        
        if awardData[i] then
            local itemId = awardData[i][2]
            if awardData[i][1] ~= "tool" then
                itemId = IconUtils.iconIdMap[awardData[i][1]]
            end
            local param = {itemId = itemId, effect = true, eventStyle = 1, num = awardData[i][3]}
            if itemIcon then
                IconUtils:updateItemIconByView(itemIcon, param)
            else
                itemIcon = IconUtils:createItemIconById(param)
                itemIcon:setName("itemIcon")
                -- local itemNormalScale = 90/itemIcon:getContentSize().width
                itemIcon:setScale(0.8)
                itemIcon:setPosition(cc.p(85*i+35, 23))
                inView:addChild(itemIcon)
                inView["award" .. i] = itemIcon
            end
            itemIcon:setVisible(true)
        else
            if itemIcon then
                itemIcon:setVisible(false)
            end
        end
    end
end

-- function CityBattleAwardDialog:reflashUI()
--     local scoreLab = self:getUI("bg.mainBg.activePanel.num")
--     local gvguser = self._citybattleModel:getGVGUserData()
--     local gvguserScore = gvguser["p"]
--     scoreLab:setString(gvguserScore)
--     self._tableView:reloadData()
-- end

function CityBattleAwardDialog:dtor( ... )
    userScore = nil
    userRewardHistory = nil
    cloneCell = nil
end

return CityBattleAwardDialog