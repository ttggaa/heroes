--[[
    @FileName   ElementalLevelSelectView.lua
    @Authors    zhangtao
    @Date       2017-08-04 11:00:06
    @Email      <zhangtao@playcrad.com>
    @Description   描述
--]]
local ElementalLevelSelectView = class("ElementalLevelSelectView",BasePopView)

ElementalLevelSelectView.kEnterType1 = 1   --从位面页面进入
ElementalLevelSelectView.kEnterType2 = 2   --从位面boss页面进入
local weekDay = {"周一","周二","周三","周四","周五","周六","周日"}

function ElementalLevelSelectView:ctor(data)
    self.super.ctor(self)
    self._itemId = data.planeId
    self._enterType = data.enterType
    self._parent = data.parent
    self._elemItemCount = 5   --元素个数
    self._layerItemList = {}  --层节点
    self._itemList = {}       --元素节点
    self._maxLayer = {}
    -- self._userModel = self._modelMgr:getModel("UserModel")
    self._elementModel = self._modelMgr:getModel("ElementModel")
    -- self._playerTodayModel = self._modelMgr:getModel("PlayerTodayModel")

    self._curOpenLayerNum = self._elementModel:getElementData()["stageId"..self._itemId] or 0

end

-- 初始化UI后会调用, 有需要请覆盖
function ElementalLevelSelectView:onInit()
    local closeBtn = self:getUI("bg.layer.closeBtn")
    self:registerClickEvent(closeBtn, function()
        self:close()
        UIUtils:reloadLuaFile("elemental.ElementalLevelSelectView")
    end)

    self._openList = self._elementModel:getOpenList()
    self._elementTable = {
                            [1] = tab.elementalPlane1,
                            [2] = tab.elementalPlane2,
                            [3] = tab.elementalPlane3,
                            [4] = tab.elementalPlane4,
                            [5] = tab.elementalPlane5,
                        }
    self._challengeTimes = self._elementModel:getMaxChallengeTimes()
    self._elemNameTable = {"火元素","水元素","气元素","土元素","混乱元素"}

    local title = self:getUI("bg.layer.titleBg.titleLabel")
    UIUtils:setTitleFormat(title, 1)

    self._itemView = self:getUI("bg.layer.itemView")
    self._elemItem = self:getUI("bg.layer.elemItem")
    self._elemItem:setVisible(false)
    self._levelItem = self:getUI("bg.layer.levelItem")
    self._levelItem:setVisible(false)
    --剩余次数
    self._timesLabel = self:getUI("bg.layer.timesLabel")
    self._timesLabel:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    --层列表
    self._layerNode = self:getUI("bg.layer.layerPanel")
    self:createTableView()
    --元素列表
    local itemHeight = self._itemView:getContentSize().height
    for index = 1 , self._elemItemCount do
        local elemItem = self:createElemItem(index)
        elemItem:setAnchorPoint(0,0)
        local elemItemHeight = elemItem:getContentSize().height
        elemItem:setPosition(0,itemHeight - elemItemHeight*index)
        self._itemView:addChild(elemItem)
        table.insert(self._itemList, elemItem)
    end
    --剩余次数
    self:setHasTimes()
end


function ElementalLevelSelectView:setHasTimes()
    local hasTimes = self._elementModel:getAllElementTimes()[self._itemId]
    self._timesLabel:setString(hasTimes.."/"..self._challengeTimes)
    self._timesLabel:setColor(hasTimes == 0 and cc.c3b(255, 0, 0) or cc.c3b(0, 255, 0))
end

function ElementalLevelSelectView:createTableView()
    if self._layerNodeTableView then
        self._layerNodeTableView:reloadData()
        return 
    end
    local tableView = cc.TableView:create(cc.size(578,404))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setAnchorPoint(0,0)
    tableView:setPosition(0 ,0)
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    self._layerNode:addChild(tableView,999)
    tableView:registerScriptHandler(function( view ) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(function ( table,cell ) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(function( table,index ) return self:cellSizeForTable(table,index) end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function ( table,index ) return self:tableCellAtIndex(table,index) end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function ( table ) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()
    self._layerNodeTableView = tableView
end


function ElementalLevelSelectView:scrollViewDidScroll(view)

end


function ElementalLevelSelectView:tableCellTouched(table,cell)
end

function ElementalLevelSelectView:cellSizeForTable(table,idx) 
    return 102,568
end

function ElementalLevelSelectView:tableCellAtIndex(table,idx)
    local index = idx + 1
    local cell = table:dequeueCell()
    -- if nil == cell then
    --     cell = cc.TableViewCell:new()
    -- else
    --     cell:removeAllChildren()
    -- end
    -- local itemView = self:createLevelItem(index)
    -- if itemView then
    --     itemView:setTouchEnabled(false)
    --     itemView:setVisible(true)
    --     itemView:setPosition(290, 51)
    --     cell:addChild(itemView)
    -- end

    if nil == cell then
        cell = cc.TableViewCell:new()
        local itemView = self._levelItem:clone()
        itemView:setVisible(true)
        itemView:setAnchorPoint(0,0)
        itemView:setTouchEnabled(false)
        itemView:setPosition(10, 0)
        itemView:setTag(9999)
        cell:addChild(itemView)
        self:createLevelItem(itemView,index)
    else
        local itemView = cell:getChildByTag(9999)
        if not itemView then return end
        self:createLevelItem(itemView,index)
    end
    return cell
end

function ElementalLevelSelectView:numberOfCellsInTableView(table)
    return #self._elementTable[self._itemId]
end

function ElementalLevelSelectView:createElemItem(index)
    local elemItem = self:getUI("bg.layer.elemItem"):clone()
    elemItem:setVisible(true)
    elemItem.floorLabel = elemItem:getChildByFullName("floorLabel")
    -- elemItem.floorLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    elemItem.floorLabel:setString(self._elemNameTable[index])

    local curLayerNum = self._elementModel:getElementData()["stageId"..index] or 0
    elemItem:getChildByFullName("curFloor"):setString("("..curLayerNum.."/"..#self._elementTable[self._itemId]..")")

    elemItem.lockBg = elemItem:getChildByFullName("lockBg")
    elemItem.lockIcon = elemItem:getChildByFullName("lockIcon")
    elemItem.normalBg = elemItem:getChildByFullName("normalBg")
    --当前
    elemItem.curIcon = elemItem:getChildByFullName("curIcon")
    elemItem.curIcon:getChildByFullName("Label_53"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    elemItem.curIcon:getChildByFullName("Label_53"):setFontName(UIUtils.ttfName)
    
    --是否开启
    local isOpen = self._elementModel:getOpenState()[index]
    elemItem.lockBg:setVisible(not isOpen)
    elemItem.lockIcon:setVisible(not isOpen)
    elemItem.normalBg:setVisible(isOpen)
    elemItem.floorLabel:setColor(isOpen and UIUtils.colorTable.ccUIBaseTextColor2 or UIUtils.colorTable.ccUIBaseColor8)

    elemItem.lockIcon:setSaturation(-80)
    self:registerClickEvent(elemItem, function()
        -- if index == 4 or index == 5 then
        --     self._viewMgr:showTip(lang("TIP_GUILD_OPEN_5"))
        --     return
        -- end

        if not next(self._elementModel:getOpenList()[index]) then
            self._viewMgr:showTip(lang("TIP_GUILD_OPEN_5"))
            return
        end

        if not isOpen then
            self._viewMgr:showTip(self:openNotice(index))
            return
        end
        self:switchBtn(index)
    end)
    return elemItem
end
--层节点
function ElementalLevelSelectView:createLevelItem(layerCell,idx)
    layerCell.levelLabel = layerCell:getChildByFullName("levelLabel")
    layerCell.levelLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    layerCell.levelLabel:setString("第" .. idx .. "关")
    layerCell.rewardLabel = layerCell:getChildByFullName("rewardLabel")
    layerCell.rewardLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    layerCell.rewardLabel:setString("奖励")
    layerCell.itemBg = layerCell:getChildByFullName("itemBg")
    layerCell.unOpenIcon = layerCell:getChildByFullName("unOpenIcon")
    layerCell.line = layerCell:getChildByFullName("line")

    layerCell.rewardIconNode = layerCell:getChildByFullName("rewardIconNode")

    layerCell.curIcon = layerCell:getChildByFullName("curIcon")
    layerCell.curIcon:getChildByFullName("dangqian"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    layerCell.curIcon:getChildByFullName("dangqian"):setFontName(UIUtils.ttfName)

    layerCell.advanceBtn = layerCell:getChildByFullName("advanceBtn")
    layerCell.sweepBtn = layerCell:getChildByFullName("sweepBtn")
    --设置关卡奖励
    self:updateLayerItem(layerCell,idx)

    self:L10N_Text(layerCell.advanceBtn)
    self:registerClickEvent(layerCell.advanceBtn, function()
        -- dump(self._elementTable[self._itemId])
        local openLv = self._elementTable[self._itemId][tonumber(idx)]["openLv"]

        local curLv = self._modelMgr:getModel("UserModel"):getData()["lvl"]
        if curLv < openLv then
            self._viewMgr:showTip("等级达到"..openLv.."开启")
            return
        end
        if self._enterType == ElementalLevelSelectView.kEnterType2 then
            self._serverMgr:sendMsg("ElementServer", "getElementFirstData", {elementId = self._itemId,stageId = idx}, true, {}, function(result, errorCode)
                if errorCode ~= 0 then 
                    errorCallback()
                    self._viewMgr:unlock(51)
                    return
                end
                self._parent:reLoadUI({item = self._itemId,layerNum = idx,serverData = result})
                self:close()
            end)
        else
            self._viewMgr:showView("elemental.ElementalLayerView",{planeId = self._itemId,layerNum = idx})
            self:close()
        end
    end)
    --扫荡
    self:L10N_Text(layerCell.sweepBtn)
    self:registerClickEvent(layerCell.sweepBtn, function()
        self:onSweepLevel(idx)
    end)
    layerCell:setSwallowTouches(false)
    return layerCell
end


function ElementalLevelSelectView:updateLayerItem(layerCell,index)
    -- print("========updateLayerItem index=========="..index)

    local isActivityOpen = self._elementModel:isActivityOpen(self._itemId)
    local isFirstAward = false   --首通标志
    local isBright = true        --灰态标志
    if tonumber(index) > tonumber(self._curOpenLayerNum) + 1 then    --未开启
        layerCell.curIcon:setVisible(false)
        layerCell.advanceBtn:setVisible(false)
        layerCell.sweepBtn:setVisible(false)
        layerCell:getChildByFullName("unOpenIcon"):setVisible(true)
        isFirstAward = true
        isBright = false
    else
        isBright = true
        if tonumber(index) == tonumber(self._curOpenLayerNum) + 1 then   --当前关卡
            layerCell.curIcon:setVisible(true)
            layerCell.advanceBtn:setVisible(true)
            layerCell.sweepBtn:setVisible(false)
            layerCell:getChildByFullName("unOpenIcon"):setVisible(false)
            isFirstAward = true
        else                                                     --打过的关卡
            layerCell.curIcon:setVisible(false)
            layerCell.advanceBtn:setVisible(false)
            layerCell.sweepBtn:setVisible(true)
            layerCell:getChildByFullName("unOpenIcon"):setVisible(false)
            isFirstAward = false                             
        end
    end
    if layerCell.rewardIconNode then
        layerCell.rewardIconNode:removeAllChildren()
    end
    
    local awardTable = {}
    if isFirstAward then
        awardTable = self._elementTable[self._itemId][index]["firstReward"]
    else
        awardTable = self._elementTable[self._itemId][index]["reward"]
    end

    local iconWidth = 80
    local offsetX = 10
    if #awardTable ~= 0 then
        for k = 1 , #awardTable do
            -- dump(awardTable,"=======awardTable=======")
            local itemType = awardTable[k][1]
            local itemId = nil
            local itemNum = nil
            if itemType == "tool" then
                itemId = awardTable[k][2]
            else 
                itemId = IconUtils.iconIdMap[itemType]
                itemNum = awardTable[k][3]
            end
            local toolD = tab:Tool(tonumber(itemId))

            local rewardIcon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD, num = itemNum})
            -- rewardIcon:setTouchEnabled(false)
            
            rewardIcon:setScale(iconWidth / rewardIcon:getContentSize().width)
            rewardIcon:setPosition((k - 1) * (iconWidth + offsetX) + 5, -2)
            layerCell.rewardIconNode:addChild(rewardIcon)
            local iconColor = rewardIcon:getChildByName("iconColor")
            if itemType == "tool" then
                local toolNum = 0

                if awardTable[k][4] ~= nil and awardTable[k][3] ~= awardTable[k][4] then
                    toolNum = awardTable[k][3] .. "~" .. awardTable[k][4]
                else
                    toolNum = awardTable[k][3]
                end
                local numLab =  ccui.Text:create()
                numLab:setString("")
                numLab:setName("numLab")
                numLab:setFontSize(24)
                numLab:setFontName(UIUtils.ttfName)
                numLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
                numLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
                numLab:setAnchorPoint(cc.p(1, 0))
                numLab:setPosition(cc.p(rewardIcon:getContentSize().width - 13, 7))
                numLab:setString(toolNum)
                iconColor:addChild(numLab,11)
            end

            local iconDes = nil
            if isFirstAward then
                iconDes = "首通"
            elseif isActivityOpen and itemType == "planeCoin" then
                iconDes = "双倍"
            end        
            if iconDes ~= nil then
                local firstIcon = cc.Sprite:createWithSpriteFrameName("globalImageUI6_connerTag_r.png")
                firstIcon:setAnchorPoint(cc.p(0, 0.5))
                firstIcon:setPosition(firstIcon:getContentSize().width - 47, firstIcon:getContentSize().height + 6)
                iconColor:addChild(firstIcon, 8)

                local firstTxt = cc.Label:createWithTTF(iconDes, UIUtils.ttfName, 22)
                firstTxt:setRotation(41)
                firstTxt:setPosition(cc.p(45, 37))
                firstTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
                firstIcon:addChild(firstTxt)
            end
        end
    end
    self:setLayerCellBright(layerCell,isBright)
end

--扫荡
function ElementalLevelSelectView:onSweepLevel(stageId)
    local hasTimes = self._elementModel:getAllElementTimes()[self._itemId]
    print("=========hasTimes========="..hasTimes)
    if hasTimes == 0 then
        self._viewMgr:showTip("今天挑战次数已用完")
        return
    end
    self._serverMgr:sendMsg("ElementServer", "sweepElement", {elementId = self._itemId,stageId = stageId}, true, {}, function(result)
        if tolua.isnull(self._sweepView) then
            self._sweepView = self._viewMgr:showDialog("elemental.ElementSweepRewardView", {elementId = self._itemId,stageId = stageId, reward = result.reward, againCallBack = specialize(self.onSweepLevel, self)}) 
        else
            self._sweepView:reflashUI(result.reward)
        end
        self:setHasTimes()
        self._parent:setHasTimes()
        if self.actionCallBack then
            self.actionCallBack({cType = "sweepStage"})
        end
        -- self.timesLabel:setString(self._cModel:getChallengeTimes() .. "/" .. tab:Setting("G_CLOUD_CITY_TIME").value)
    end)
end

-- 第一次进入调用, 有需要请覆盖
function ElementalLevelSelectView:onShow()

end

function ElementalLevelSelectView:switchBtn(index)
    if index > #self._itemList then return end
    for k , itemNode in pairs(self._itemList) do
        if k == index then
            itemNode:getChildByFullName("selectBg"):setVisible(true)
            itemNode.curIcon:setVisible(true)
        else
            itemNode:getChildByFullName("selectBg"):setVisible(false)
            itemNode.curIcon:setVisible(false)            
        end
    end
    self._itemId = index
    self._curOpenLayerNum = self._elementModel:getElementData()["stageId"..self._itemId] or 0
    -- self:updateLayerItem(index)
    if self._layerNodeTableView then
        self._layerNodeTableView:reloadData()
        self:scrollToCurPos()
        self:setHasTimes()
        return 
    end
end

-- 接收自定义消息
function ElementalLevelSelectView:reflashUI(data)
    self:switchBtn(self._itemId)
end

--设置层节点为灰色
function ElementalLevelSelectView:setLayerCellBright(cell, isBright)
    cell.itemBg:setBrightness(isBright and 0 or -31)
    cell.line:setBrightness(isBright and 0 or -31)
    local cellList = cell:getChildByFullName("rewardIconNode"):getChildren() or {}
    for _, node in pairs(cellList) do
        local color = isBright and cc.c4b(255,255,255,255) or cc.c4b(128, 128, 128,255)
        if node:getName() == "bgMc" then return end
        local children = node:getChildren()
        if children == nil or #children == 0 then
            return 
        end
        for k,v in pairs(children) do
            if v and not tolua.isnull(v) then 
                if v:getDescription() ~= "Label" then
                    v:setColor(color)
                else
                    v:setBrightness(-30)
                end
            end
        end
    end
end

--滑动到当前挑战层
function ElementalLevelSelectView:scrollToCurPos()
    -- self._curOpenLayerNum = 15
    local offsetNum = 0
    if self._curOpenLayerNum < 2 then
        offsetNum = 0
    elseif  self._curOpenLayerNum > (#self._elementTable[self._itemId] - 4) then
        offsetNum = #self._elementTable[self._itemId] - 4
    else
        offsetNum = self._curOpenLayerNum - 1
    end

    local off = self._layerNodeTableView:getContentOffset()
    local oldHeight = self._layerNodeTableView:getContainer():getContentSize().height
    self._layerNodeTableView:setContentOffset(cc.p(0, off.y + offsetNum* 102), false)
end

--开启提示
function ElementalLevelSelectView:openNotice(itemId)
    local noticeDesc = ""
    for k , v in pairs(self._openList[itemId]) do
        if k ~= #self._openList[itemId] then
            noticeDesc = noticeDesc .. weekDay[tonumber(v)].."、"
        else
            noticeDesc = noticeDesc .. weekDay[tonumber(v)].."开启"
        end        
    end
    return noticeDesc
end

return ElementalLevelSelectView
