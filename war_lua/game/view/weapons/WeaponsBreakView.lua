--[[
    Filename:    WeaponsBreakView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-09-18 20:23:12
    Description: File description
--]]


local WeaponsBreakView = class("WeaponsBreakView",BasePopView)
local verticalLine = 6
function WeaponsBreakView:ctor()
    self.super.ctor(self)
end

-- 初始化UI后会调用, 有需要请覆盖
function WeaponsBreakView:onInit()
    self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
        UIUtils:reloadLuaFile("weapons.WeaponsBreakView")
    end)
    
    self._weaponsModel = self._modelMgr:getModel("WeaponsModel")
    self._userModel = self._modelMgr:getModel("UserModel")
   
    self._title = self:getUI("bg.headBg.title")
    UIUtils:setTitleFormat(self._title,1)

    self._breakDesBg = self:getUI("bg.breakDesBg")
    self._breakDesBg:setCascadeOpacityEnabled(true) 
    self._smallJinghuaImg = self:getUI("bg.breakDesBg.smallJinghuaImg")
    self._numLab = self:getUI("bg.breakDesBg.numLab")
    self._numLab:setString("x0")
    self._addtionNode = self:getUI("bg.addtionNode")
    self._selNumLab = self:getUI("bg.selNumLab")
    self._selNumLab:setString("0")
    self._des1 = self:getUI("bg.breakDesBg.des1")
    self._des3 = self:getUI("bg.des3")
    self._des4 = self:getUI("bg.addtionNode.des4")
    self._des4:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    local itemBg = self:getUI("bg.breakDesBg.itemBg")
    local itemId = IconUtils.iconIdMap.siegePropExp
    print("itemId==========", itemId)
    local itemIcon = IconUtils:createItemIconById({itemId = itemId, effect = true,eventStyle = 0, swallowTouches = true})
    itemIcon:setName("itemIcon")
    itemIcon:setAnchorPoint(0,0)
    itemIcon:setScale(0.8)
    itemIcon:setPosition(-4,-2)
    itemBg:addChild(itemIcon)
    self._itemIcon = itemIcon


    self:registerClickEventByName("bg.breakBtn", function ()
        if table.nums(self._breakPool) == 0 then
            self._viewMgr:showTip(lang("SIEGECON_TIPS17"))
            return
        end

        local tishi = false
        for k,v in pairs(self._breakPool) do
            local propsData = self._weaponsModel:getPropsDataByKey(v)
            if propsData.quality == 5 then
                tishi = true
            end
        end
        if tishi == true then
            local callback = function()
                self:resolveProp()
            end
            self._viewMgr:showDialog("global.GlobalSelectDialog", {desc = lang("SIEGECON_TIPS25"), button1 = "", callback1 = callback, 
                button2 = "", callback2 = nil,titileTip="温馨提示", title = "温馨提示"},true)
        else
            self:resolveProp()
        end
    end)

    local autoSelect = self:getUI("bg.autoSelect")
    self:registerClickEvent(autoSelect, function()
        local callback = function(selectQuality)
            self._selectQuality = selectQuality
            dump(self._selectQuality)
            self:autoSelect()
            self:calculationAward()
        end
        local param = {callback = callback, selectType = "weapon"}
        self._viewMgr:showDialog("weapons.WeaponsAutoSelectDialog", param)
    end)

    self._iconNode = self:getUI("bg.iconNode")
    self._iconNode:setVisible(true)
    self._resultLab = self:getUI("bg.resultPanel.resultLab")
    self._resultIcon = self:getUI("bg.resultPanel.icon")
    self._desNode = self:getUI("bg.desNode")

    self._propsCell = self:getUI("propsCell")
    self._selectQuality = {}
    self._breakPool = {}
    self:addTableView()

    -- local breakFrontBg = self:getUI("bg.innerBg.breakFrontBg")
    -- local mc = mcMgr:createViewMC("baowufenjiehuoyan_duizhanui", true,false)
    -- mc:setPosition(320,50)
    -- breakFrontBg:addChild(mc, -1)
    -- mc:setCascadeOpacityEnabled(true)
    -- mc:play()
    -- mc:gotoAndStop(5)

    -- self:listenReflash("TreasureModel", self.reflashUI)
    -- self:listenReflash("ItemModel", self.reflashUI)
    self:initFireAnim()
end

--
function WeaponsBreakView:initFireAnim( )
    local breakBg = self:getUI("bg.innerBg.breakFrontBg")
    self._breakBg = breakBg

    local clipNode = cc.ClippingNode:create()
    clipNode:setPosition(320,0)
    clipNode:setContentSize(cc.size(0, 0))
    local mask = cc.Sprite:createWithSpriteFrameName("weaponImageUI_img16.png")
    mask:setAnchorPoint(0.5,0)
    -- mask:setScale(0.95)
    clipNode:setStencil(mask)
    clipNode:setAlphaThreshold(0.05)
    -- clipNode:setInverted(true)
    clipNode:setCascadeOpacityEnabled(true)

    local mc = mcMgr:createViewMC("baowufenjiehuoyan_duizhanui", true,false)
    mc:setPosition(-0,20)
    clipNode:addChild(mc)
    mc:setCascadeOpacityEnabled(true)
    mc:play()
    mc:gotoAndStop(5)
    self._breakMc = mc

    -- 绑定方法
    self._breakMc._turnNormalAnim = function( )
        if not self._breakMc then return end
        -- self._breakMc:play()
        self._breakMc:gotoAndStop(0)
    end

    self._breakMc._turnBreakAnim = function( )
        if not self._breakMc then return end
        self._breakMc:gotoAndPlay(0)
    end
    -- self._breakMc:setPlaySpeed(0.2)
    self._breakMc:addCallbackAtFrame(30,function( )
        self._breakMc._turnNormalAnim()
    end)

    self._breakClipNode = clipNode

    breakBg:addChild(clipNode,-1)
end


function WeaponsBreakView:autoSelect()
    local selectQuality = self._selectQuality
    for k,v in pairs(self._tableData) do
        local propsKey = v.key
        if selectQuality[v.quality] then
            self._breakPool[propsKey] = propsKey
        else
            self._breakPool[propsKey] = nil
        end
    end
    self._tableView:reloadData()
end


-- 接收自定义消息
function WeaponsBreakView:reflashUI(data)
    self._tableData = self._weaponsModel:getCanBreakProps()
    local nothing = self:getUI("bg.tableViewBg.nothing")
    if table.nums(self._tableData) == 0 then
        nothing:setVisible(true)
    else
        nothing:setVisible(false)
    end
    self._tableView:reloadData()
    self:calculationAward()
end

--[[
用tableview实现
--]]
function WeaponsBreakView:addTableView()
    local tableViewBg = self:getUI("bg.tableViewBg")
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height-20))
    self._tableView:setDelegate()
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(0, 10)
    self._tableView:registerScriptHandler(function(view) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    -- self._tableView:registerScriptHandler(function(table, cell) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:setBounceable(true)
    -- if self._tableView.setDragSlideable ~= nil then 
    --     self._tableView:setDragSlideable(true)
    -- end
    
    tableViewBg:addChild(self._tableView)
end

function WeaponsBreakView:scrollViewDidScroll(view)
    self._inScrolling = view:isDragging()
end

function WeaponsBreakView:cellSizeForTable(table,idx) 
    return 110,683
end

function WeaponsBreakView:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    -- local param = self._technology[idx+1]
    local indexId = idx + 1
    if nil == cell then
        cell = cc.TableViewCell:new()
        local propsCell = self._propsCell:clone() 
        propsCell:setAnchorPoint(0,0)
        propsCell:setPosition(0,5) --0
        propsCell:setName("propsCell")
        cell:addChild(propsCell)

    end
    local propsCell = cell:getChildByFullName("propsCell")
    if propsCell then
        self:updateCell(propsCell, indexId)  
    end
    return cell
end

function WeaponsBreakView:numberOfCellsInTableView(tabled)
    local itemRow = math.ceil(table.nums(self._tableData)/verticalLine)
    return itemRow
end


function WeaponsBreakView:updateCell(inView, indexLine)    
    for i=1,verticalLine do
        local indexId = (indexLine-1)*verticalLine+i
        self:updatePropsCell(inView, indexId, i)
    end
end

function WeaponsBreakView:updatePropsCell(inView, indexId, verticalId)
    local btnTouchLayer
    local propsData = self._tableData[indexId]
    local propsIcon = inView["propsIcon" .. verticalId]
    local subBtn = inView["subBtn" .. verticalId]
    -- dump(propsData)
    if propsData then
        print('indexId===========', indexId)
        local propsId = propsData.id
        local propsLevel = propsData.lv
        local propsTab = tab:SiegeEquip(propsId)
        local propsKey = propsData.key
        local propsQuality = propsData.quality
        local param = {itemId = propsId, level = propsLevel, itemData = propsTab, quality = propsTab.quality, iconImg = propsTab.art, eventStyle = 0}
        if not propsIcon then
            propsIcon = IconUtils:createWeaponsBagItemIcon(param)
            propsIcon:setName("propsIcon")
            propsIcon:setPosition((verticalId-1)*110+15, 5)
            inView:addChild(propsIcon)
            -- propsIcon:setTouchEnabled(true)
            
            inView["propsIcon" .. verticalId] = propsIcon
        else
            IconUtils:updateWeaponsBagItemIcon(propsIcon, param)
        end
        propsIcon:setVisible(true)

        local subBtn = propsIcon._subBtn
        if not propsIcon._subBtn then
            subBtn = ccui.ImageView:create("weaponImageUI_img21.png", 1)
            subBtn:setAnchorPoint(0,0)
            -- subBtn:setPosition(propsIcon:getContentSize().width*0.5,propsIcon:getContentSize().height*0.5)
            subBtn:setPosition((verticalId-1)*110+18, 8)
            subBtn:setScale(1.13)
            subBtn:setVisible(false)
            -- subBtn:setTouchEnabled(true)
            -- subBtn:setSwallowTouches(false)
            inView:addChild(subBtn,99)
            propsIcon._subBtn = subBtn
            inView["subBtn" .. verticalId] = subBtn

            local subBtnImg = ccui.ImageView:create("globalImageUI_duigou.png", 1)
            subBtnImg:setPosition(subBtn:getContentSize().width*0.5,subBtn:getContentSize().height*0.5)
            subBtn:addChild(subBtnImg,99)
            propsIcon._subBtnImg = subBtnImg
        end

        self:registerClickEvent(subBtn, function()
            print("subBtn=========", indexId, propsKey)
            subBtn:setVisible(false)
            propsIcon:setTouchEnabled(true)
            self._breakPool[propsKey] = nil
            -- propsIcon._select = 0
            self:calculationAward()
        end)
        subBtn:setSwallowTouches(false)

        self:registerClickEvent(propsIcon, function()
            subBtn:setVisible(true)
            propsIcon:setTouchEnabled(false)
            self._breakPool[propsKey] = propsKey
            -- propsIcon._select = 1
            print("propsIcon=========", indexId, propsKey)
            self:propPiaoNature(propsKey)
            self:calculationAward()
        end)
        propsIcon:setSwallowTouches(false)

        if self._breakPool[propsKey] then
            subBtn:setVisible(true)
            propsIcon:setTouchEnabled(false)
        else
            subBtn:setVisible(false)
            propsIcon:setTouchEnabled(true)
        end

        propsIcon:setVisible(true)
    else
        if propsIcon then
            propsIcon:setVisible(false)
        end
        if subBtn then
            subBtn:setVisible(false)
        end
    end
end


function WeaponsBreakView:propPiaoNature(propsKey)
    local runeIcon = self._numLab -- self._itemIcon
    local propsData = self._weaponsModel:getPropsDataByKey(propsKey)
    local num = self:getPropsUpgradeCost(propsData)
    local param = {}
    local tstr = "+" .. num -- lang("SIEGEWEAPONT_" .. indexId) .. "+" .. TeamUtils.getNatureNums(data)
    table.insert(param, tstr)

    for i=1,table.nums(param) do
        local natureLab = runeIcon:getChildByName("natureLab" .. i)
        if natureLab then
            natureLab:stopAllActions()
            natureLab:removeFromParent()
        end
        natureLab = cc.Label:createWithTTF(param[i], UIUtils.ttfName, 32)
        natureLab:setName("natureLab" .. i)
        natureLab:setColor(UIUtils.colorTable.ccColorQuality2)
        natureLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        natureLab:setPosition(cc.p(runeIcon:getContentSize().width*0.5, runeIcon:getContentSize().height*0.5-35*i))
        natureLab:setOpacity(0)
        runeIcon:addChild(natureLab,100)

        local seqnature = cc.Sequence:create(cc.ScaleTo:create(0, 0.2), cc.DelayTime:create(0.2+0.1*i), 
            cc.Spawn:create(cc.ScaleTo:create(0.2, 1),cc.FadeIn:create(0.2),cc.MoveBy:create(0.2, cc.p(0,38))), 
            cc.MoveBy:create(0.38, cc.p(0,17)),
            cc.Spawn:create(cc.MoveBy:create(0.4, cc.p(0,10)),cc.FadeOut:create(0.7)),
            cc.RemoveSelf:create(true))
        natureLab:runAction(seqnature)
    end
end

function WeaponsBreakView:calculationAward()
    -- dump(self._breakPool)
    local toolAllNum = 0
    for k,v in pairs(self._breakPool) do
        local propsData = self._weaponsModel:getPropsDataByKey(v)
        local toolValue = self:getPropsUpgradeCost(propsData) or 0
        toolAllNum = toolAllNum + toolValue
    end

    self._numLab:setString("x" .. toolAllNum)

    self._selNumLab:setString(table.nums(self._breakPool))

    local userData = self._userModel:getData()
    local siegePropExp = userData.siegePropExp or 0
    self._des3:setString(siegePropExp)
end

function WeaponsBreakView:getPropsUpgradeCost(propData)
    local toolNum = 0
    local propTab = tab:SiegeEquip(propData.id)
    local propBaseNum = propTab["base"][1][3]
    toolNum = toolNum + propBaseNum
    local level = propData.lv
    local quality = propData.quality
    if level > 1 then
        level = level - 1
        local tNum = 0
        for i=1,level do
            local costNum = tab:SiegeEquipExp(i)["exp" .. quality][1][3]
            tNum = tNum + costNum
        end
        toolNum = toolNum + tNum
    end
    return toolNum or 0
end

-- 分解配件
function WeaponsBreakView:resolveProp()
    local proidTab = {}
    for k,v in pairs(self._breakPool) do
        table.insert(proidTab, v)
    end
    local param = {propIdxs = proidTab}
    dump(param)
    self._serverMgr:sendMsg("WeaponServer", "resolveProp", param, true, {}, function (result)
        self._breakPool = {}
        self:reflashUI()
        dump(result, "result=======", 10)
        -- self:updateCurrencyUI()
        -- self:updateRightSubBg()
        -- self:updateLeftPanel(weaponId, weaponsId)
        local callback = function()
            DialogUtils.showGiftGet({gifts = result.reward})
        end
        self:clearCardPool(callback)
    end)
end


function WeaponsBreakView:clearCardPool( callback )
    -- 火焰上升动画
    if self._breakMc and self._breakMc._turnBreakAnim then
        self._breakMc._turnBreakAnim()
    end

    local itemBg = self:getUI("bg.breakDesBg.itemBg")
    local mc = mcMgr:createViewMC("baowufenjie_treasureui", false, false)
    mc:addCallbackAtFrame(14,function( )
        callback()
    end)
    mc:setPosition(itemBg:getContentSize().width*0.5, itemBg:getContentSize().height*0.5)
    itemBg:addChild(mc)
end

return WeaponsBreakView