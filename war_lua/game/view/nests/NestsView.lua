--
-- Author: <ligen@playcrab.com>
-- Date: 2016-12-09 16:44:14
--
local NestsView = class("NestsView", BaseView)

local mapMaskOffsetList = {
    [1] = 0,
    [2] = 0,
    [3] = 0,
    [4] = 0,
    [5] = 0,
    [6] = 0,
    [7] = 0,
    [8] = 0,
    [9] = 0 
}

-- race表和nest表 raceId对应表
local raceToNestsIdMap = {
    [101] = 1,
    [102] = 2,
    [103] = 4,
    [104] = 3,
    [105] = 5,
    [106] = 6,
    [107] = 7,
    [108] = 8,
    [109] = 9
}

-- race表和nest表 raceId对应表
local nestsToRaceIdMap = {
    [1] = 101,
    [2] = 102,
    [3] = 104,
    [4] = 103,
    [5] = 105,
    [6] = 106,
    [7] = 107,
    [8] = 108,
    [9] = 109
}

local raceNameOffset = {
    [1] = -20,
    [2] = 0,
    [3] = -20,
    [4] = 30,
    [5] = 20,
    [6] = 0,
    [7] = 0,
    [8] = 0,
    [9] = 0
}

local nestsTab = tab.nests

local kGrooveMax = 10

function NestsView:ctor(data)
    NestsView.super.ctor(self)
    self.initAnimType = 2

    self._nModel = self._modelMgr:getModel("NestsModel")

    self._initData = data

    self._campCurIndex = 1
    self._curRaceId = 1

    self._campTableData = {}
    self._towerTableData = {}

    -- 巢穴tableView位置是否固定
    self._savePos = true

    -- 阵营菜单圆弧半径
    self._campRoundR = 730
end

--function NestsView:getBgName()
--    return "bg_007.jpg"
--end

function NestsView:getAsyncRes()
    return
    {
        { "asset/ui/nests1.plist", "asset/ui/nests1.png" },
        { "asset/ui/nests.plist", "asset/ui/nests.png" },
        { "asset/ui/nests-HD.plist", "asset/ui/nests-HD.png"},
        { "asset/ui/bag.plist", "asset/ui/bag.png" },
    }
end

function NestsView:setNavigation()
--    self._viewMgr:showNavigation("global.UserInfoView", { title = "globalTitleUI_Nests.png",titleTxt = "兵营", types = { "nests1", "nests2", "nests3"} })
    self._viewMgr:showNavigation("global.UserInfoView", {types = { "nests1", "nests2", "nests3"},hideHead = true })

end

function NestsView:onBeforeAdd(callback)
    self:sendGetNestsData(self._curRaceId, function()
        callback()
        self:reflashUI(true)
    end)
end

function NestsView:onInit()
    local showTab = tab:Setting("NESTS_OPEN").value
    for i = 1, #showTab do
        if showTab[i] == 1 then
            table.insert(self._campTableData, tab:Race(nestsToRaceIdMap[i]))
        end
    end

    if self._initData and self._initData.cId then
        self._campCurIndex = self:getIndexByRaceId(self._initData.cId) 
    elseif self._initData and self._initData.tId then
        self._campCurIndex = self:getIndexByRaceId(nestsToRaceIdMap[self._nModel:getCampByTeamId(self._initData.tId)])
    end

    self:updateTowerTableData()

    self._curRaceId = raceToNestsIdMap[self._campTableData[self._campCurIndex].id]

    self._mapNode = self:getUI("bg.mapNode")
    self._mapNodeWidth = MAX_SCREEN_WIDTH
    self._mapNodeHeight = 640
    self._mapNode:setContentSize(self._mapNodeWidth, self._mapNodeHeight)

    --share  by wangyan 
    self:createShareBtn()

    local desNode = self._mapNode:getChildByFullName("desNode")
    desNode:setPositionX(ADOPT_IPHONEX and 394 or 274)
--    desNode:setPositionY(self._mapNodeHeight - 162)

    self._titleLabel = desNode:getChildByFullName("titleLabel")
    self._titleLabel:setFontName(UIUtils.ttfName_Title)
    self._titleLabel:setColor(cc.c3b(253,242,201))
    self._titleLabel:enable2Color(1,cc.c4b(237,220,151))

    self._mapDesLabel = desNode:getChildByFullName("mapDesLabel")
    self._mapDesLabel:setColor(cc.c3b(255,255,234))
    self._mapDesLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._mapDesLabel1 = desNode:getChildByFullName("mapDesLabel1")
    self._mapDesLabel1:setColor(cc.c3b(255,255,234))
    self._mapDesLabel1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._mapCenterX = (MAX_SCREEN_WIDTH-150)*0.5 + 150
    if ADOPT_IPHONEX then
        self._mapCenterX = self._mapCenterX + 95 
    end
    self._mapCenterY = 442
    local campPos = tab:Setting("NESTS_RACE_" .. self._curRaceId).value
    self._mapImg = cc.Sprite:create("asset/uiother/map/chaodaditu.jpg")
    self._mapImg:setPosition(self._mapCenterX + self._mapImg:getContentSize().width*0.5-campPos[1], self._mapCenterY + self._mapImg:getContentSize().height*0.5-campPos[2])
    self._mapNode:addChild(self._mapImg)

    local mapPatchImgR = ccui.Scale9Sprite:createWithSpriteFrameName("bgLargeMap_nests.png")
    mapPatchImgR:setCapInsets(cc.rect(100, 20, 1, 1))
    mapPatchImgR:setContentSize(327, 2000)
    mapPatchImgR:setPosition(2090, 1000)
    self._mapImg:addChild(mapPatchImgR)

    local mapPatchImgL = ccui.Scale9Sprite:createWithSpriteFrameName("bgLargeMap_nests.png")
    mapPatchImgL:setCapInsets(cc.rect(100, 20, 1, 1))
    mapPatchImgL:setContentSize(487, 2000)
    mapPatchImgL:setFlippedX(true)
    mapPatchImgL:setPosition(-180, 1000)
    self._mapImg:addChild(mapPatchImgL)

    self._mapBound = cc.Sprite:create("asset/uiother/nests/mapBorder".. self._curRaceId .. "_nests.png")
    self._mapBound:setScale(1.42)
    self._mapBound:setPosition(self._mapCenterX, self._mapCenterY)
    self._mapNode:addChild(self._mapBound)

    self._campNamePic = self._mapNode:getChildByFullName("mapTitle")
    self._campNamePic:setPositionX(self._mapCenterX)

    self:getUI("bg.maskBottom"):setContentSize(MAX_SCREEN_WIDTH, 449)

--    self._mapClipNode = cc.ClippingNode:create()
--    self._mapClipNode:setPosition((self._mapNodeWidth + 120) * 0.5, self._mapNodeHeight * 0.5)
----    self._mapClipNode:setInverted(true)
--    local mask = cc.Scale9Sprite:createWithSpriteFrameName("mapMask_nests.png")
--	mask:setCapInsets(cc.rect(80, 100, 1, 1))
--    mask:setContentSize(self._mapNodeWidth + 100, self._mapNodeHeight)
--    mask:setPosition(0, -1)
--    self._mapClipNode:setStencil(mask)
--    self._mapClipNode:setAlphaThreshold(0.5)
--    self._mapClipNode:addChild(self._mapImg)
--    self._mapClipNode:addChild(self._mapBound, 1)
--    self._mapNode:addChild(self._mapClipNode)

    self._mapDarkNode = ccui.Scale9Sprite:createWithSpriteFrameName("globalPanelUI7_zhezhao.png")
    self._mapDarkNode:setCapInsets(cc.rect(54, 54, 1, 1))
    self._mapDarkNode:setContentSize(MAX_SCREEN_WIDTH + 120, MAX_SCREEN_HEIGHT)
    self._mapDarkNode:setAnchorPoint(cc.p(0.5, 0.5))
    self._mapDarkNode:setPosition(self._mapNodeWidth*0.5, self._mapNodeHeight*0.5)

    self._darkClipNode = cc.ClippingNode:create()
    self._darkClipNode:setPosition(0, 0)
    self._darkClipNode:setInverted(true)
    local mask = cc.Sprite:create("asset/uiother/nests/maskBorder".. self._curRaceId .. "_nests.png")
--    mask:setPosition((self._mapNodeWidth + 120) * 0.5, self._mapNodeHeight * 0.5)
    mask:setPosition(self._mapCenterX, self._mapCenterY)
    mask:setScale(1.42)
    self._darkClipNode:setStencil(mask)
    self._darkClipNode:setAlphaThreshold(0.00001)
    self._darkClipNode:addChild(self._mapDarkNode)
    self._mapNode:addChild(self._darkClipNode)

    self._menuNode = self:getUI("bg.menuNode")
    self._menuNode:setContentSize(ADOPT_IPHONEX and 197 or 177, MAX_SCREEN_HEIGHT)
    local maskNode = ccui.Layout:create()
    maskNode:setBackGroundColor(cc.c3b(125, 125, 125))
    maskNode:setContentSize(155, 310)
    maskNode:setSwallowTouches(false)
    self._menuNode:addChild(maskNode)
    self:registerClickEvent(maskNode,function( )
    end)

    self._campTableBg = self:getUI("bg.menuNode.sliderBg")
    self._campTableBg:setPosition(ADOPT_IPHONEX and 67 or 107, MAX_SCREEN_HEIGHT * 0.5)
    self._campTableBg:setContentSize(ADOPT_IPHONEX and 276 or 216, 720)

    self._campTableSize = self._menuNode:getContentSize()
    self._campCellSize = cc.size(101, 115)

    -- 阵营滚动窗
    self._campTableView = self:addCampTableView()

    self._minOffsetY = self._campTableSize.height - self._campCellSize.height * #self._campTableData
    self._upArrow = mcMgr:createViewMC("chaoxuejiantou1_teamnatureanim", true, false)
    self._upArrow:setPosition(22, self._menuNode:getContentSize().height - 80)
    self._menuNode:addChild(self._upArrow, 5)

    self._downArrow = mcMgr:createViewMC("chaoxuejiantou2_teamnatureanim", true, false)
    self._downArrow:setPosition(20, 80)
    self._menuNode:addChild(self._downArrow, 5)

    --------------------------- 初始化阵营按钮弧度 ---------------------------
    -- 阵营滚动窗起始世界坐标Y值
    self._startWorldPosY = self._campTableView:convertToWorldSpace(cc.p(0, 0)).y
    self._centerPosY = self._campTableBg:getPositionY() - 50
    local cellList = self._campTableView:getContainer():getChildren()
    for i = 1, #cellList do
        local posY = cellList[i]:getPositionY()
        cellList[i]:setPositionX(self:getPosX(self._campRoundR, posY, cc.p(self._campRoundR, self._centerPosY)))
        print("posX" .. cellList[i]:getPositionX(), " posY" .. posY, " cY" .. self._centerPosY)
    end  
    --------------------------- 初始化阵营按钮弧度 end ---------------------------

    self._towerTableNode = self:getUI("bg.towerNode")

    if ADOPT_IPHONEX then
        self._towerTableNode:setContentSize(MAX_SCREEN_WIDTH - 400, 640)
    else
        self._towerTableNode:setContentSize(MAX_SCREEN_WIDTH - 150, 640)
    end

    self._leftArrow = mcMgr:createViewMC("zuojiantou_teamnatureanim", true, false)
    self._leftArrow:setPosition(54,160)
    self._leftArrow:setVisible(false)
    self._towerTableNode:addChild(self._leftArrow, 10)

    self._rightArrow = mcMgr:createViewMC("youjiantou_teamnatureanim", true, false)
    self._rightArrow:setPosition(self._towerTableNode:getContentSize().width - 70,160)
    self._towerTableNode:addChild(self._rightArrow, 10)

    self._tempTowerItem = self:getUI("bg.towerItem")
    self._tempTowerItem:setVisible(false)

    -- 巢穴滚动窗
    self._towerTableView = self:addTowerTableView()

    self._towerTableView:reloadData()
    self._campTableView:reloadData()

    self:startRefreshSchedule()

    self:setListenReflashWithParam(true)
    self:listenReflash("NestsModel", self.onModelReflash)
    self:listenReflash("ActivityModel", self.onModelReflash)
end

function NestsView:onModelReflash(eventName)
    if eventName == "request" then
        self:sendGetNestsData(self._curRaceId, specialize(self.reflashUI, self))

    elseif eventName == "ActivityModel" then
        if self:needActivityUpdate() then
            self:sendGetNestsData(self._curRaceId, specialize(self.reflashUI, self))
        end
    end
end

function NestsView:reflashUI(isInit)
    if isInit then
        local campOffsetY = self._campTableView:minContainerOffset().y + (self._campCurIndex-5)*self._campCellSize.height
        campOffsetY = math.max(campOffsetY, self._campTableView:minContainerOffset().y)
        campOffsetY = math.min(campOffsetY, self._campTableView:maxContainerOffset().y)
        self._campTableView:setContentOffsetInDuration(cc.p(0, campOffsetY), 0.1)
    end

    self._offsetX = self._towerTableView:getContentOffset().x


    self._curCampData = self._nModel:getCampDataById(self._curRaceId)
    self:updateTowerTableData()

    -- 刷新阵营关闭建造成功特效的计时器
    if self._schId then
        ScheduleMgr:unregSchedule(self._schId)
        self._schId = nil
    end
    self._towerTableView:reloadData()
    self._minTowerOffsetX = self._towerTableView:minContainerOffset().x

    if self._savePos then
        self._towerTableView:setContentOffset(cc.p(self._offsetX, 0))
    else
        self._savePos = true
    end

    self._leftArrow:setVisible(false)
    self._rightArrow:setVisible(self._minTowerOffsetX < 0)

    local namePath = string.format("campName%d_nests", tonumber(self._curRaceId))
    if self._curRaceId == 9 then
        namePath = namePath .. "_1"
    end
    self._campNamePic:loadTexture(namePath .. ".png", 1)
    self._campNamePic:setPositionX(self._mapCenterX + raceNameOffset[self._curRaceId])
    self._titleLabel:setString(lang("NESTSLABEL_LANG_" .. self._curRaceId))
    self._mapDesLabel:setString(lang("NESTS_LANG_" .. self._curRaceId))
    self._mapDesLabel1:setString(lang("NESTS_LANG_" .. self._curRaceId .. "_1"))
end


function NestsView:addCampTableView()
    local tableView = cc.TableView:create(self._campTableSize)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(0, 0)
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    self._menuNode:addChild(tableView,9)

    tableView:registerScriptHandler(function(table,cell)
        return self:campCellTouched(table,cell)
    end,cc.TABLECELL_TOUCHED)

    local cellSizeForTable = function(table,index)
        return self._campCellSize.height, self._campCellSize.width
    end
    tableView:registerScriptHandler(function( table,index )
        return cellSizeForTable(table,index)
    end,cc.TABLECELL_SIZE_FOR_INDEX)

    tableView:registerScriptHandler(function ( table,index )
        return self:campTableCellAtIndex(table,index)
    end,cc.TABLECELL_SIZE_AT_INDEX)

    local numberOfCellsInTableView = function(table)
        return #self._campTableData
    end
    tableView:registerScriptHandler(function ( table )
        return numberOfCellsInTableView(table)
    end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

    tableView:registerScriptHandler(function( view )
        return self:scrollViewDidScroll(view)
    end ,cc.SCROLLVIEW_SCRIPT_SCROLL)

    return tableView
end

function NestsView:campCellTouched(table,cell)
--    print("cell touched at index: " .. cell:getIdx())

--    if self._campCurIndex == cell:getIdx() + 1 then return end

--    local preCell = table:cellAtIndex(self._campCurIndex-1)

--    if preCell then
--        preCell:getChildByFullName("cellNode.item"):setScale(0.9)
--        preCell:getChildByFullName("cellNode.selectBound"):setVisible(false)

--        local preName = preCell:getChildByFullName("cellNode.item.nameLabel")
--        preName:disableEffect()
--        preName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
--        preName:setColor(cc.c3b(250,224,188))
--        preName:enable2Color(1, cc.c4b(250,224,188,255))
--    end

--    local nameLabel = cell:getChildByFullName("cellNode.item.nameLabel")
--    nameLabel:disableEffect()
--    nameLabel:setColor(cc.c3b(255,255,204))
--    nameLabel:enable2Color(1, cc.c4b(255,203,94,255))
--    nameLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

--    cell:getChildByFullName("cellNode.item"):setScale(1)
--    cell:getChildByFullName("cellNode.selectBound"):setVisible(true)

--    self._campCurIndex = cell:getIdx() + 1

--    self._savePos = false

--    self:refreshCamp(self._campCurIndex)
end

function NestsView:createShareBtn()
    if self._shareNode == nil then
        self._shareNode = require("game.view.share.GlobalShareBtnNode").new({mType = "ShareTeamRaceModule"})
        self._shareNode:setPosition(ADOPT_IPHONEX and MAX_SCREEN_WIDTH - 110  or MAX_SCREEN_WIDTH - 50, MAX_SCREEN_HEIGHT * 0.5 + 50)
        self._shareNode:setCascadeOpacityEnabled(true, true)
        self:addChild(self._shareNode, 10)
    end 

    self._shareNode:registerClick(function()
        return {moduleName = "ShareTeamRaceModule", raceId = self._curRaceId}
    end) 

    -- if self._curRaceId ~= 9 then
        self._shareNode:setVisible(true)
    -- else
    --     self._shareNode:setVisible(false)
    -- end  
end

function NestsView:refreshCamp(campIndex)  
    --share  by wangyan 
    self:createShareBtn()

    if self._mapDarkNode ~= nil then
        self._mapDarkNode:removeFromParent(true)
        self._mapDarkNode = nil
    end
    
    if self._darkClipNode ~= nil then
        self._darkClipNode:removeFromParent(true)
        self._darkClipNode = nil
    end

    self._mapBound:stopAllActions()
    self._mapBound:setVisible(false)
    self._mapImg:stopAllActions()
    self._campNamePic:setVisible(false)

    local campPos = tab:Setting("NESTS_RACE_" .. self._curRaceId).value
    self._mapImg:runAction(cc.Sequence:create(
        cc.EaseInOut:create(cc.MoveTo:create(0.5, cc.p(self._mapCenterX + 1000 - campPos[1], self._mapCenterY + 1000 - campPos[2])), 5),
        cc.CallFunc:create(function()
            self._mapBound:setVisible(true)
            self._mapBound:setTexture("asset/uiother/nests/mapBorder" .. self._curRaceId .."_nests.png")
            self._mapBound:runAction(cc.Blink:create(0.5, 2))

            self._mapDarkNode = ccui.Scale9Sprite:createWithSpriteFrameName("globalPanelUI7_zhezhao.png")
            self._mapDarkNode:setCapInsets(cc.rect(54, 54, 1, 1))
            self._mapDarkNode:setContentSize(MAX_SCREEN_WIDTH + 120, MAX_SCREEN_HEIGHT)
            self._mapDarkNode:setAnchorPoint(cc.p(0.5, 0.5))
            self._mapDarkNode:setPosition(self._mapNodeWidth*0.5, self._mapNodeHeight*0.5)

            self._darkClipNode = cc.ClippingNode:create()
            self._darkClipNode:setPosition(0, 0)
            self._darkClipNode:setInverted(true)
            local mask = cc.Sprite:create("asset/uiother/nests/maskBorder" .. self._curRaceId  .. "_nests.png")
            mask:setScale(1.42)
            mask:setPosition(self._mapCenterX + mapMaskOffsetList[self._curRaceId], self._mapCenterY)
            self._darkClipNode:setStencil(mask)
            self._darkClipNode:setAlphaThreshold(0.00001)
            self._darkClipNode:addChild(self._mapDarkNode)
            self._mapNode:addChild(self._darkClipNode)

            self._campNamePic:setVisible(true)

        end)))

    self:sendGetNestsData(self._curRaceId, specialize(self.reflashUI, self))

end

function NestsView:campTableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
    else
    	cell:removeAllChildren()
    end
    local cellData = self._campTableData[idx+1]
    local item = self:creatCampCell(cellData,idx+1)
    if item then
	    item:setAnchorPoint(cc.p(0,0))
	    item:setPosition(cc.p(0,0))
	    cell:addChild(item)
	end

    return cell
end

function NestsView:creatCampCell(data,index)
    local cellNode = ccui.Widget:create()
    cellNode:setName("cellNode")
    cellNode:ignoreContentAdaptWithSize(true)

    local selectBound = cc.Sprite:createWithSpriteFrameName("classBound_nests.png")
    selectBound:setPosition(self._campCellSize.width * 0.5 + 10, self._campCellSize.height * 0.5)
    selectBound:setName("selectBound")
    selectBound:setCascadeOpacityEnabled(true) 
    selectBound:setVisible(self._campCurIndex == index)
    cellNode:addChild(selectBound)

    local item = ccui.ImageView:create()
    item:loadTexture("globalImgUI_class".. data.id - 100 .. ".png",1)
    item:setScale(self._campCurIndex == index and 1 or 0.9)
    item:setPosition(self._campCellSize.width * 0.5 + 10, self._campCellSize.height * 0.5)
    item:setName("item")
    item:setCascadeOpacityEnabled(true)
    item:setTouchEnabled(true)
    item:setSwallowTouches(false)
    cellNode:addChild(item) 

    local nameLabel = cc.Label:createWithTTF(lang("NESTS_CAMP_NAME_" .. data.id - 100), UIUtils.ttfName, 22)
    if self._campCurIndex == index then
        nameLabel:setColor(cc.c3b(255,255,204))
        nameLabel:enable2Color(1, cc.c4b(255,203,94,255))
    else
        nameLabel:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
    end
    nameLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    nameLabel:setName("nameLabel")
    nameLabel:setPosition(50 , 17)
    item:addChild(nameLabel)

    self:addClickTouchEvent(item, function()
        if self._campCurIndex == index then return end

        local preCell = self._campTableView:cellAtIndex(self._campCurIndex-1)

        if preCell then
            preCell:getChildByFullName("cellNode.item"):setScale(0.9)
            preCell:getChildByFullName("cellNode.selectBound"):setVisible(false)

            local preName = preCell:getChildByFullName("cellNode.item.nameLabel")
            preName:disableEffect()
            preName:disable2Color()
            preName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            preName:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
        end

        nameLabel:disableEffect()
        nameLabel:setColor(cc.c3b(255,255,204))
        nameLabel:enable2Color(1, cc.c4b(255,203,94,255))
        nameLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

        item:setScale(1)
        selectBound:setVisible(true)

        self._campCurIndex = index
        self._curRaceId = raceToNestsIdMap[self._campTableData[self._campCurIndex].id]

        self._savePos = false

        self:refreshCamp(self._campCurIndex)
    end)

    return cellNode
end

function NestsView:scrollViewDidScroll(view)
	self._inScrolling = view:isDragging()
    local cellList = view:getContainer():getChildren()
    for i = 1, #cellList do
        local posY = cellList[i]:getPositionY()
        local worldPosY = view:getContainer():convertToWorldSpace(cc.p(0, posY)).y
        cellList[i]:setPositionX(self:getPosX(self._campRoundR, worldPosY - self._startWorldPosY , cc.p(self._campRoundR, self._centerPosY)))
--        print("posX" .. cellList[i]:getPositionX(), " posY" .. posY, " cY" .. self._centerPosY)
    end  

    local offsetY = view:getContainer():getPositionY()
--     print(offsetY)
    if offsetY < 0 then
        self._downArrow:setVisible(true)
    else
        self._downArrow:setVisible(false)
    end

    if offsetY > self._minOffsetY then
        self._upArrow:setVisible(true)
    else
        self._upArrow:setVisible(false)
    end
end

function NestsView:addTowerTableView()
    local tableView = cc.TableView:create(cc.size(self._towerTableNode:getContentSize().width, 300))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    tableView:setPosition(0, 15)
    tableView:setDelegate() 
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(MAX_SCREEN_WIDTH < 1136)
    self._towerTableNode:addChild(tableView,9)

    tableView:registerScriptHandler(function(table,cell)
        return self.towerCellTouched(self,table,cell)
    end,cc.TABLECELL_TOUCHED)

    local cellSizeForTable = function(table,index)
        return self._tempTowerItem:getContentSize().height, self._tempTowerItem:getContentSize().width + 5
    end
    tableView:registerScriptHandler(function(table,index)
        return cellSizeForTable(table,index)
    end,cc.TABLECELL_SIZE_FOR_INDEX)

    tableView:registerScriptHandler(function ( table,index )
        return self:towerTableCellAtIndex(table,index)
    end,cc.TABLECELL_SIZE_AT_INDEX)

    local numberOfCellsInTableView = function(table)
        return #self._towerTableData
    end
    tableView:registerScriptHandler(function ( table )
        return numberOfCellsInTableView(table)
    end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

    tableView:registerScriptHandler(function( view )
        return self:towerScrollViewDidScroll(view)
    end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    return tableView
end

function NestsView:towerScrollViewDidScroll(view)
    local offsetX = view:getContainer():getPositionX()
    if offsetX < 0 then
        self._leftArrow:setVisible(true)
    else
        self._leftArrow:setVisible(false)
    end

    if self._minTowerOffsetX then
        if offsetX > self._minTowerOffsetX then
            self._rightArrow:setVisible(true)
        else
            self._rightArrow:setVisible(false)
        end
    end
end

function NestsView:towerCellTouched(table,cell)
    -- local index = cell:getIdx() + 1

    -- local item = cell:getChildByName("item_" .. index)
    -- if item:getChildByName("upgradeNode"):isVisible() then
    --     local nId = self._towerTableData[index].id
    --     local data = self._nModel:getNestDataById(nId)
    --     self._viewMgr:showDialog("nests.NestsExchangeView", {nData = data, callBack = specialize(self.onExchange, self)})
    -- else
    --     self._viewMgr:showTip(lang("NESTS_TIP_1"))
    -- end
end

function NestsView:towerTableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
    else
    	cell:removeAllChildren()
    end
    local cellData = self._towerTableData[idx+1]
    local item = self.createTowerCell(self,cellData,idx+1)
    if item then
	    item:setPosition(cc.p(0,0))
	    item:setAnchorPoint(cc.p(0,0))
	    cell:addChild(item)
	end
    return cell
end

function NestsView:createTowerCell(data,index)
    local teamData = tab:Team(data.team)
    local item = self._tempTowerItem:clone()
    item:setName("item_" .. index)
    item:setSwallowTouches(false)
    item:setVisible(true)
    item:setPositionY(-20)

    local itemBg = item:getChildByFullName("bg")

    local towerIconNode = item:getChildByFullName("towerIconNode")
    local towerIcon = cc.Sprite:create("asset/uiother/intance/" .. data.art .. ".png")
    towerIcon:setPosition(towerIconNode:getContentSize().width*0.5 + data["position"][1], towerIconNode:getContentSize().height*0.5 + data["position"][2])
    towerIcon:setScale(138 / towerIcon:getContentSize().height * data["position"][3])
    towerIcon:setName("towerIcon")
    towerIconNode:addChild(towerIcon) 

    local titleLabel = item:getChildByFullName("nameLabel")
    titleLabel:setString(lang(data.name))
    titleLabel:setFontName(UIUtils.ttfName)
    titleLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    titleLabel:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)

    local infoNode = nil
    local desLabel = nil
    -- 巢穴等级信息
    local nestData = self._nModel:getNestDataById(data.id)
    if nestData then
        itemBg:loadTexture("bgNormal_nests.png", 1)

        infoNode = item:getChildByFullName("upgradeNode")

        local currencyData = data.exchange[1]
        local currencyIcon = cc.Sprite:createWithSpriteFrameName(IconUtils.resImgMap[currencyData[1]])
        currencyIcon:setPosition(37, 25)
        currencyIcon:setScale(36 / currencyIcon:getContentSize().width)
        infoNode:addChild(currencyIcon)

        local numLabel1 = cc.Label:createWithTTF(tostring(currencyData[3]), UIUtils.ttfName, 18)
        numLabel1:setPosition(50, 17)
        numLabel1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        infoNode:addChild(numLabel1)

        local goodsId = tab:Team(data.team)["goods"]
        local toolData = tab:Tool(goodsId)
        local iconImg = IconUtils:createItemIconById({itemId = goodsId,itemData = toolData,eventStyle = 3,effect = true})
        iconImg:setScale(38 / iconImg:getContentSize().width)
        iconImg:setPosition(132, 5)
        infoNode:addChild(iconImg)

        local numLabel2 = cc.Label:createWithTTF("1", UIUtils.ttfName, 18)
        numLabel2:setPosition(163, 18)
        numLabel2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        infoNode:addChild(numLabel2)

        local lvLabel = infoNode:getChildByFullName("lvLabel")
        lvLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        lvLabel:setString("Lv." .. nestData.lvl)

        local maxLv = #data.upgrade + 1
        local userLv = self._modelMgr:getModel("UserModel"):getPlayerLevel()
        local upgradeBtn = infoNode:getChildByFullName("upgradeBtn")
        upgradeBtn:setName("upgradeBtn" .. data.team)

        -- 限制升级等级
        if nestData.lvl < maxLv then
            upgradeBtn:getChildByFullName("upgradeLabel"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            UIUtils:setGray(upgradeBtn, userLv < data.upgradeLevel[nestData.lvl])
            self:registerClickEvent(upgradeBtn,function( )
                if userLv < data.upgradeLevel[nestData.lvl] then
                    self._viewMgr:showTip("玩家" .. data.upgradeLevel[nestData.lvl] .. "级可升级兵营")
                    return
                end
                self._viewMgr:showDialog("nests.NestsUpdateView", {nData = nestData, callBack = specialize(self.upgradeNest, self)})
            end)
        else
            upgradeBtn:setVisible(false)
        end

--        local harvestBtn = infoNode:getChildByFullName("harvest")

        -- 丰收此阵营所有巢穴
--        self:registerClickEvent(harvestBtn,function( )
--            self._viewMgr:showDialog("nests.NestsHarvestView", {cId = self._campCurIndex + 100, callBack = specialize(self.nestsHarvest, self)})
--        end)

        -- 丰收单个巢穴
--        local maxTimes = tab:Vip(self._modelMgr:getModel("VipModel"):getLevel()).nest
--        harvestBtn:setVisible(maxTimes > 0)
--        self:registerClickEvent(harvestBtn,function( )
--            local param = {
--                cId = self._campCurIndex + 100, 
--                nId = data.id,
--                buyTimes = nestData.hst or 0,
--                callBack = specialize(self.nestsHarvest, self)
--            }
--            self._viewMgr:showDialog("nests.NestsHarvestView", param)
--        end)

        local reteNode = infoNode:getChildByFullName("rateNode")
        self:updateGroove(reteNode, nestData.frg)

    elseif self._nModel:getCanBuildById(data.team) then
        itemBg:loadTexture("bgCanBuild_nests.png", 1)
        UIUtils:setGray(towerIcon, true)

        infoNode = item:getChildByFullName("buildNode")
        desLabel = infoNode:getChildByFullName("desLabel")
        desLabel:setColor(UIUtils.colorTable.ccUIBaseColor2)
        desLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

        local buildBtn = infoNode:getChildByFullName("buildBtn")
        buildBtn:setName("buildBtn" .. data.team)
        buildBtn:getChildByFullName("buildLabel"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

        self:registerClickEvent(buildBtn,function( )
            self._viewMgr:showDialog("nests.NestsBuildView", {nData = data, callBack = specialize(self.buildNest, self)})
        end)
    else
        itemBg:loadTexture("bgGray_nests.png", 1)
        UIUtils:setGray(towerIcon, true)

        titleLabel:setColor(UIUtils.colorTable.ccUIBaseColor8)

        infoNode = item:getChildByFullName("lockNode")
        desLabel = cc.Label:createWithTTF("招募" .. lang(teamData.name) .. "后可建造", UIUtils.ttfName, 18, cc.size(145,60), 1)
        desLabel:setMaxLineWidth(145)
        desLabel:setColor(UIUtils.colorTable.ccUIBaseColor8)
        desLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        desLabel:setLineHeight(20)
        desLabel:setPosition(96, 16)
        infoNode:addChild(desLabel)
    end
    infoNode:setVisible(true)

    self:addClickTouchEvent(item, function()
        if item:getChildByName("upgradeNode"):isVisible() then
        local nId = self._towerTableData[index].id
            self._viewMgr:showDialog("nests.NestsExchangeView", {nId = nId, callBack = specialize(self.onExchange, self)})
        else
            self._viewMgr:showTip(lang("NESTS_TIP_1"))
        end
    end)

    return item
end

-- 更新碎片槽
function NestsView:updateGroove(view, num)
    if num > 10 then
        for i = 1, kGrooveMax do
            local eImg = cc.Sprite:createWithSpriteFrameName("powerBg_nests.png")
            eImg:setPosition(8 + (i - 1) * 17, 6)
            view:addChild(eImg)

            local picName = nil
            if i <= num - kGrooveMax then
                picName = "powerPointRed_nests.png"
            else
                picName = "powerPoint_nests.png"
            end
            local pImg = cc.Sprite:createWithSpriteFrameName(picName)
            pImg:setPosition(8 + (i - 1) * 17, 6)
            view:addChild(pImg)
        end
    else
        for i = 1, kGrooveMax do
            local eImg = cc.Sprite:createWithSpriteFrameName("powerBg_nests.png")
            eImg:setPosition(8 + (i - 1) * 17, 6)
            view:addChild(eImg)

            if i <= num then
                local pImg = cc.Sprite:createWithSpriteFrameName("powerPoint_nests.png")
                pImg:setPosition(8 + (i - 1) * 17, 6)
                view:addChild(pImg)
            end
        end
    end

    local aniName = nil
    if num == kGrooveMax then
        aniName = "chaoxuetiaoman_qianghua"
    elseif num > kGrooveMax then
        aniName = "chaoxuetiaoman1_qianghua"
    end

    if aniName then
        local fullMc = mcMgr:createViewMC(aniName, true, false)
        fullMc:setPosition(8, 6)
        view:addChild(fullMc)
    end
end

-- 建造巢穴成功刷新
function NestsView:buildNest(nestData)
    self:reflashUI()

    local cell = self._towerTableView:cellAtIndex(self:getIndexById(nestData.nestId) - 1)
    local towerIconNode = cell:getChildByName("item_" .. self:getIndexById(nestData.nestId)):getChildByFullName("towerIconNode")
    local towerIcon= towerIconNode:getChildByName("towerIcon")
    towerIcon:setBrightness(128)

    local nestTemData = tab:Nests(tonumber(nestData.nestId))
    local towerEffectIcon = cc.Sprite:create("asset/uiother/intance/" .. nestTemData.art .. ".png")
    towerEffectIcon:setPurityColor(255, 255, 255)
    towerEffectIcon:setPosition(towerIconNode:getContentSize().width*0.5 + nestTemData["position"][1], towerIconNode:getContentSize().height*0.5 + nestTemData["position"][2])
    towerEffectIcon:setScale(138 / towerEffectIcon:getContentSize().height * nestTemData["position"][3])
    towerIconNode:addChild(towerEffectIcon)

    towerEffectIcon:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.1),
        cc.Spawn:create(cc.ScaleBy:create(0.1, 1.15), cc.FadeTo:create(0.1, 100), cc.CallFunc:create(function()
            local buildMc = mcMgr:createViewMC("jianzao_qianghua", false, true)
            buildMc:setPosition(towerIconNode:getContentSize().width*0.5, towerIconNode:getContentSize().height*0.5)
            towerIconNode:addChild(buildMc)
        end)),
        cc.Spawn:create(
            cc.CallFunc:create(function()
                towerIcon:setOpacity(200)

                local dtTime = 0
                self._schId = ScheduleMgr:regSchedule(0.01, self, function(self, dt)
                    dtTime = dtTime + dt
                    if dtTime > 0.4 then
                        towerIcon:setBrightness(0)
                        towerIcon:setOpacity(255)
                        ScheduleMgr:unregSchedule(self._schId)
                        self._schId = nil
                    else
                        towerIcon:setBrightness(255 * (0.4 - dtTime) / 0.4)
                        towerIcon:setOpacity(255 * dtTime / 0.4)
                    end

                end)
            end),
            cc.FadeOut:create(0.4), cc.ScaleBy:create(0.4, 1.008)),
        cc.CallFunc:create(function()
            towerEffectIcon:stopAllActions()
            towerEffectIcon:removeFromParent(true)
        end)
        )
     )
end

-- 升级巢穴成功刷新
function NestsView:upgradeNest(nestData)
    self:reflashUI()

    local cell = self._towerTableView:cellAtIndex(self:getIndexById(nestData.nestId) - 1)
    local iconNode = cell:getChildByName("item_" .. self:getIndexById(nestData.nestId)):getChildByFullName("towerIconNode")

    self:lock(-1)
    ScheduleMgr:delayCall(100, self, function()
        local upgradeMc = mcMgr:createViewMC("shengji1_qianghua", false, true)
        upgradeMc:setPosition(iconNode:getContentSize().width*0.5, iconNode:getContentSize().height*0.5 - 30)
        iconNode:addChild(upgradeMc)

        local upgradeMc2 = mcMgr:createViewMC("shengji2_qianghua", false, true)
        upgradeMc2:setPosition(iconNode:getContentSize().width*0.5, iconNode:getContentSize().height*0.5 - 40)
        iconNode:addChild(upgradeMc2, -1)
    
        self:unlock()
    end)
end

-- 丰收成功刷新
function NestsView:nestsHarvest(harvestData)
    self:lock(-1)
    ScheduleMgr:delayCall(100, self, function()
        for k, v in pairs(harvestData) do
            local cell = self._towerTableView:cellAtIndex(self:getIndexById(k) - 1)

            if cell then
                local iconNode = cell:getChildByName("item_" .. self:getIndexById(k)):getChildByFullName("towerIconNode")
                local harvestMc = mcMgr:createViewMC("fengshou_qianghua", false, true)
                harvestMc:setPosition(iconNode:getContentSize().width*0.5 - 35, iconNode:getContentSize().height*0.5 + 130)
                iconNode:addChild(harvestMc)

                local rateNode = cell:getChildByName("item_" .. self:getIndexById(k)):getChildByFullName("upgradeNode.rateNode")
                rateNode:removeAllChildren()
                self:updateGroove(rateNode, v.newCount)
--                local delayTime = 0
--                for i = 1, kGrooveMax do
--                    if i > v.oldCount and i <= v.newCount then
--                        delayTime = (i - v.oldCount) * 100
--                        ScheduleMgr:delayCall(delayTime, self, function()
--                            local pImg = cc.Sprite:createWithSpriteFrameName("powerPoint_nests.png")
--                            pImg:setPosition(8 + (i - 1) * 17, 6)
--                            rateNode:addChild(pImg)

--                            local lightMc = mcMgr:createViewMC("fengshoutiao_qianghua", false, true)
--                            lightMc:setPosition(8 + (i - 1) * 17, 6)
--                            rateNode:addChild(lightMc)
--                        end)
--                    end
--                end

--                if v.newCount == kGrooveMax then
--                    local fullMc = mcMgr:createViewMC("chaoxuetiaoman_qianghua", true, false)
--                    fullMc:setPosition(8, 6)
--                    rateNode:addChild(fullMc)
--                elseif v.newCount > kGrooveMax then
--                    local fullMc = mcMgr:createViewMC("chaoxuetiaoman1_qianghua", true, false)
--                    fullMc:setPosition(8, 6)
--                    reteNode:addChild(fullMc)
--                end
            end
        end

        self:unlock()
    end)
end

-- 兑换成功刷新
function NestsView:onExchange(tp, exData)
    if tp == 1 then
        self:reflashUI()
    elseif tp == 2 then
        self:nestsHarvest(exData)
    end
end

-- 请求巢穴数据
function NestsView:sendGetNestsData(cId, callBack)
    if cId == nil then
        print("没有传入当前阵营ID")
    end
    self._serverMgr:sendMsg("NestsServer", "getNestsInfo", {cid = cId}, true, { }, function(result)
        if callBack then
--            callBack(result)
            callBack()
        end
    end)
end

-- 更新巢穴数据
function NestsView:updateTowerTableData()
    if #self._towerTableData > 0 then
        for i = 1, #self._towerTableData do
            self._towerTableData[i] = nil
        end
    end
    for k, v in pairs(tab.nests) do
        if v.race == self._curRaceId then
            table.insert(self._towerTableData, v)
        end
    end

    local sortFunc = function(a, b)
        return a.rank < b.rank
    end
    table.sort(self._towerTableData, sortFunc)
end

-- 开启计时刷新碎片生成进度
function NestsView:startRefreshSchedule()
    local produceScore = tab:Setting("NESTS_PRODUCE").value
    local needUpdate = false
    self._timer = ScheduleMgr:regSchedule(60000,self,function( )
        if self._curCampData then
            local curTimeStamp = self._modelMgr:getModel("UserModel"):getCurServerTime()
            for k, v in pairs(self._curCampData) do
                local growTime = curTimeStamp - v.lut
                local rate = nestsTab[tonumber(k)].born[v.lvl]
                local growNum = math.floor(((rate * growTime / 60) + v.lus) / produceScore)
    --            print("id" .. k .. "   " .. math.floor(((rate * growTime / 60) + v.lus)) .. "/" .. produceScore)
                if growNum > 0 then
                    needUpdate = true
                end
            end

            if needUpdate then
                self:sendGetNestsData(self._curRaceId, specialize(self.reflashUI, self))
                needUpdate = false
            end
        end
    end)

end

-- 关闭计时器
function NestsView:closeRefreshSchedule()
    if self._timer then
        ScheduleMgr:unregSchedule(self._timer)
        self._timer = nil
    end
end


function NestsView:addClickTouchEvent(inview, callBack)
    local startX = 0
    local startY = 0
    local touchMove = false
    self:registerTouchEvent(inview,function(sender, x, y)
        startX = x
    end,
    function(sender, x, y)
        if x - startX > 10 or x - startX < -10 then
            touchMove = true
        end
    end,
    function( )
        if not touchMove then
            callBack()
        end
        touchMove = false
    end,
    function()
        touchMove = false
    end)
end

-- 根据巢穴ID获得在此阵营的index
function NestsView:getIndexById(cId)
    local nestTemData = tab:Nests(tonumber(cId))
    return nestTemData.rank
end

-- 根据race表阵营ID获得对应兵营页签index
function NestsView:getIndexByRaceId(rId)
    for i = 1, #self._campTableData do
        if rId == self._campTableData[i].id then
            return i
        end 
    end

    print("阵营中未找到兵团ID" .. rId)
    return 1
end

-- 判断是否有活动开启或关闭导致碎片数量的更新
function NestsView:needActivityUpdate()
    if self._modelMgr:getModel("ActivityModel"):isActivityOpen(52) or
        self._modelMgr:getModel("ActivityModel"):isActivityOpen(53)
    then
        for k, v in pairs(self._curCampData) do
            if v["add"] > 0 then
                return false
            end
        end
        return true
    else
        for k, v in pairs(self._curCampData) do
            if v["add"] > 0 then
                return true
            end
        end
        return false
    end
end


-- 圆形轨道坐标X
-- @param r:圆形半径
-- @param posY:对应最表Y
-- @param posC:圆心坐标
function NestsView:getPosX(r, posY, posC)
    local y = posY
    local cX = posC.x
    local cY = posC.y
    return r * 2 - (math.sqrt(math.pow(r,2) - math.pow((y - cY), 2)) + cX)
end

function NestsView:onTop()
    local popViews = self:getPopViews()
    for _, view in pairs(popViews) do
        if view.updateCurrency then
            view:updateCurrency()
        end
    end

end

function NestsView:onDestroy()
    self:closeRefreshSchedule()
    NestsView.super.onDestroy(self)
end

function NestsView:dtor()
    mapMaskOffsetList = nil
    raceToNestsIdMap = nil
    nestsToRaceIdMap = nil
    kGrooveMax = nil
end
return NestsView