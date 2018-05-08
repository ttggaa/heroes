--[[
    Filename:    WeaponsReplaceView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-09-15 15:59:04
    Description: File description
--]]


local WeaponsReplaceView = class("WeaponsReplaceView", BasePopView)

function WeaponsReplaceView:ctor(param)
    WeaponsReplaceView.super.ctor(self)
    self._selectType = param.selectType or 1
    self._selectPosId = param.selectPosId or 1
end

function WeaponsReplaceView:onInit()
    self._weaponsModel = self._modelMgr:getModel("WeaponsModel")
    self:registerClickEventByName("bg.closeBtn", function ()
        if self._closeCallback ~= nil then 
            self._closeCallback()
        end
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("weapons.WeaponsReplaceView")
        end
        self:close()
    end)  

    local title1 = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title1, 1, 1)

    local title3 = self:getUI("bg.shuxingBg.titleLab")
    title3:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    -- UIUtils:adjustTitle(title3)

    local nothing = self:getUI("bg.nothing")
    nothing:setVisible(true)
    local shuxingBg = self:getUI("bg.shuxingBg")
    shuxingBg:setVisible(false)

    self._selectPosId = self._selectPosId
    self._selectType = 1


    self._bottom = self:getUI("bg.shuxingBg.bottom")
    local mc1 = mcMgr:createViewMC("youjiantou_teamnatureanim", true, false)
    mc1:setPosition(cc.p(self._bottom:getContentSize().width*0.5, self._bottom:getContentSize().height*0.5))
    self._bottom:addChild(mc1)
    self._bottom:setVisible(false)

    self._scrollView = self:getUI("bg.shuxingBg.scrollView")
    self._scrollView:setBounceEnabled(true)
    self._scrollView:addEventListener(function(sender, eventType)
        if eventType == 6 or eventType == 1 then
            -- print ("5eventType============", eventType)
            self._bottom:setVisible(false)
        else
            -- print ("6eventType============", eventType)
            self._bottom:setVisible(true)
        end
    end)


    local uninstallBtn = self:getUI("bg.uninstallBtn")
    self:registerClickEvent(uninstallBtn, function()
        local param = {type = self._selectType, slotId = self._selectPosId}
        self:uninstallProp(param)
    end)
    self._uninstallBtn = uninstallBtn

    local replaceBtn = self:getUI("bg.replaceBtn")
    self:registerClickEvent(replaceBtn, function()
        if not self._secProps then
            self._viewMgr:showTip(lang("SIEGECON_TIPS27"))
            return
        end

        local callback = function()
            local propsData = self._secProps.propsData
            local param = {type = self._selectType, propIdx = propsData.key, slotId = self._selectPosId}
            local tsec = self._secProps
            if tsec then
                self:setAnim(self._selPropIcon)
                tsec:setVisible(false)
                tsec.propsData = nil 
                tsec.indexId = 0
                -- local nothing = self:getUI("bg.nothing")
                -- nothing:setVisible(true)
                -- local shuxingBg = self:getUI("bg.shuxingBg")
                -- shuxingBg:setVisible(false)
                self._secProps = nil 
                self._replaceBtn:setSaturation(-100) 
            end
            self:installProp(param)
            self:reloadData()
        end
        local propsData = self._secProps.propsData
        if propsData.onEquit == 1 then
            self._viewMgr:showDialog("global.GlobalSelectDialog", {desc = lang("SIEGECON_TIPS26"), button1 = "", callback1 = callback, 
                button2 = "", callback2 = nil,titileTip="更换提示", title = "更换提示"},true)
        else
            callback()
        end
    end)
    self._replaceBtn = replaceBtn
    self._replaceBtn:setSaturation(-100)

    local notableNum = self:getUI("bg.notableNum.cardBtn")
    self:registerClickEvent(notableNum, function()
        self._viewMgr:showView("siege.SigeCardView")
    end)

    self._tableData = self._weaponsModel:getNewPropsData()
    self._propsCell = self:getUI("propsCell")
    self:addTableView()

    self:listenReflash("WeaponsModel", self.reflashWeaponUI)
end

function WeaponsReplaceView:reloadData()
    local siegeTab = tab:SiegeWeaponType(self._selectType).equipType
    local typeTable = siegeTab[self._selectPosId]
    -- dump(typeTable)
    self._inPropsData = self._weaponsModel:getUsePropsIdData() or {}
    -- dump(self._inPropsData)
    local weaponTypeData = self._weaponsModel:getWeaponsDataByType(self._selectType)
    local propKey = weaponTypeData["sp" .. self._selectPosId]
    local propsData = self._weaponsModel:getPropsDataByType(typeTable)
    -- print("propKey=========", propKey)
    self._tableData = self._weaponsModel:getCanReplaceProps(propsData, propKey, self._selectType)
    local notableNum = self:getUI("bg.notableNum")
    if table.nums(self._tableData) == 0 then
        notableNum:setVisible(true)
    else
        notableNum:setVisible(false)
    end
    self._tableView:reloadData()

    if propKey and propKey ~= 0 then
        self._replaceBtn:setPositionX(561)
        self._replaceBtn:setTitleText("替换")
        self._uninstallBtn:setVisible(true)
    else
        self._replaceBtn:setPositionX(461)
        self._replaceBtn:setTitleText("装备")
        self._uninstallBtn:setVisible(false)
    end
end

function WeaponsReplaceView:reflashWeaponUI()
    self:updateEquiptList()
    self:reloadData()
end

function WeaponsReplaceView:reflashUI(inData)
    self._selectType = inData.selectType or 1
    self._selectPosId = inData.selectPosId or 1
    local tLab = self:getUI("bg.equiptList.tLab")
    local weaponTypeTab = tab:SiegeWeaponType(self._selectType)
    tLab:setString(lang(weaponTypeTab.name))

    self:updateEquiptList()
    self:reloadData()
end

function WeaponsReplaceView:updateEquiptList()
    local weaponTypeData = self._weaponsModel:getWeaponsDataByType(self._selectType)
    -- dump(weaponTypeData)
    local siegeTab = tab:SiegeWeaponType(self._selectType)
    -- local baseInfoLevelLab = self._infoNode:getChildByFullName("levelLab")
    -- baseInfoLevelLab:setString("Lv." .. level)

    -- local equipTypeTab = siegeTab.equipType
    -- for i=1,4 do
    --     local equipBg = self:getUI("bg.equipBg" .. i)
    --     local equipType = self:getUI("bg.equipBg" .. i .. ".equipType")
    --     equipType:loadTexture("weaponImageUI_propsType" .. equipTypeTab[i][2] .. ".png", 1)

    --     local propsId = weaponTypeData["sp" .. i]
    --     self:updateEquipCell(equipBg, propsId, i)
    -- end
    local propsData = self._weaponsModel:getPropsData()
    local equip
    for i=1,4 do
        local equipBg = self:getUI("bg.equiptList.equipBg" .. i)
        local propsIndexId = weaponTypeData["sp" .. i]
        local tpropsData = {}
        if propsIndexId and propsIndexId ~= 0 then
            tpropsData = propsData[propsIndexId] or {}
        end
        -- dump(tpropsData)
        self:updateEquipCell(equipBg, tpropsData, i)
    end
end

function WeaponsReplaceView:updateEquipCell(inView, propsData, indexId)
    -- print("propsId===========", propsId, indexId)
    local propsId = propsData.id or 0
    -- print("propsId===========", propsId, indexId)
    local notEquip = self:getUI("bg.equiptList.equipBg" .. indexId .. ".notEquip")

    if (not propsId) or (propsId == 0) then
        if notEquip then
            notEquip:setVisible(true)
            -- self:registerClickEvent(notEquip, function()
            --     -- self._viewMgr:showDialog("weapons.WeaponsReplaceView", {})
            -- end)
        end
        local propsIcon = inView.propsIcon
        if propsIcon then
            propsIcon:setVisible(false)
        end
    else
        if notEquip then
            notEquip:setVisible(false)
        end
        -- print("propsId==========", propsId)
        local propsTab = tab:SiegeEquip(propsId)
        local propsIcon = inView.propsIcon
        local param = {itemId = propsId, level = propsData.lv, itemData = propsTab, quality = propsTab.quality, iconImg = propsTab.art, eventStyle = 0}
        if not propsIcon then
            propsIcon = IconUtils:createWeaponsBagItemIcon(param)
            propsIcon:setName("propsIcon")
            propsIcon:setPosition(-2, -3)
            propsIcon:setScale(80/propsIcon:getContentSize().width)
            inView:addChild(propsIcon)
            inView.propsIcon = propsIcon
        else
            IconUtils:updateWeaponsBagItemIcon(propsIcon, param)
        end
        propsIcon:setVisible(true)
    end

    local xuanzhong = inView.xuanzhong
    if not xuanzhong then
        xuanzhong = mcMgr:createViewMC("xuanzhong_itemeffectcollection", true, false)
        xuanzhong:setName("xuanzhong")
        xuanzhong:gotoAndStop(1)
        xuanzhong:setPosition(38, 38)
        xuanzhong:setScale(0.75)
        inView:addChild(xuanzhong,50)
        inView.xuanzhong = xuanzhong
    end

    local siegeTab = tab:SiegeWeaponType(self._selectType)
    local tequipType = siegeTab.equipType[indexId][1]
    local equipType = self:getUI("bg.equiptList.equipBg" .. indexId .. ".equipType")
    equipType:loadTexture("weaponImageUI_propsType" .. tequipType .. ".png", 1)

    if self._selectPosId == indexId then
        xuanzhong:setVisible(true)
    else
        xuanzhong:setVisible(false)
    end

    self:registerClickEvent(inView, function()
        local equipBg = self:getUI("bg.equiptList.equipBg" .. self._selectPosId)
        local xuanzhong = equipBg.xuanzhong
        if xuanzhong then
            xuanzhong:setVisible(false)
        end
        print("self._selectPosId=============", self._selectPosId)
        self._selectPosId = indexId
        self._secProps = nil
        self._replaceBtn:setSaturation(-100) 
        self:updateEquipCell(inView, propsData, self._selectPosId)
        self:reloadData()
        self:updateLeftPanel(propsData)  
    end)
end


--[[
用tableview实现
--]]
function WeaponsReplaceView:addTableView()
    local tableViewBg = self:getUI("bg.tableViewBg")
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width+10, tableViewBg:getContentSize().height))
    self._tableView:setDelegate()
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(-5, 0))
    self._tableView:registerScriptHandler(function(table, cell) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:setBounceable(true)
    -- self._tableView:reloadData()
    -- if self._tableView.setDragSlideable ~= nil then 
    --     self._tableView:setDragSlideable(true)
    -- end
    
    tableViewBg:addChild(self._tableView)
end


-- 触摸时调用
function WeaponsReplaceView:tableCellTouched(table,cell)
    -- self._viewMgr:showDialog("guild.GuildScienceDetailDialog", {detailData = nil})
end

-- cell的尺寸大小
function WeaponsReplaceView:cellSizeForTable(table,idx) 
    local width = 400
    local height = 80
    return height, width
end

-- 创建在某个位置的cell
function WeaponsReplaceView:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    -- local param = self._technology[idx+1]
    local indexId = idx + 1
    if nil == cell then
        cell = cc.TableViewCell:new()
        local propsCell = self._propsCell:clone() 
        propsCell:setAnchorPoint(0,0)
        propsCell:setPosition(5,0) --0
        propsCell:setName("propsCell")
        cell:addChild(propsCell)

        for i=1,5 do
            local xuanzhong = mcMgr:createViewMC("xuanzhong_itemeffectcollection", true, false)
            xuanzhong:setName("xuanzhong" .. i)
            xuanzhong:gotoAndStop(1)
            xuanzhong:setPosition(40+(i-1)*80, 40-3)
            xuanzhong:setScale(0.75)
            xuanzhong:setVisible(false)
            propsCell:addChild(xuanzhong,5)
            propsCell["xuanzhong" .. i] = xuanzhong
        end
        -- local shangzhen = teamNode:getChildByName("shangzhen")
        -- shangzhen:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnColor4, 2)
        -- local xiazhen = teamNode:getChildByName("xiazhen")
        -- xiazhen:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnColor4, 2)
    end
    local propsCell = cell:getChildByFullName("propsCell")
    if propsCell then
        self:updateCell(propsCell, indexId)  
    end
    return cell
end

-- 返回cell的数量
function WeaponsReplaceView:numberOfCellsInTableView(table)
    return self:cellLineNum() -- #self._tableData
end

function WeaponsReplaceView:cellLineNum()
    local num = math.ceil(table.nums(self._tableData)*0.2)
    return num 
end

function WeaponsReplaceView:updateCell(inView, indexLine)    
    for i=1,5 do
        local indexId = (indexLine-1)*5+i
        self:updatePropsCell(inView, indexId, i)
    end
end

function WeaponsReplaceView:updatePropsCell(inView, indexId, cellNum)
    local tableData = self._tableData
    local propsIcon
    local propsData = tableData[indexId]

    local propsIcon = inView["propsIcon" .. cellNum]
    local xuanzhong = inView["xuanzhong" .. cellNum]
    local recommend = inView["recommend" .. cellNum]
    if propsData then
        local propsId = propsData.id
        local propsLevel = propsData.lv
        local propsTab = tab:SiegeEquip(propsId)
        -- print("propsId========", propsId)
        local param = {itemId = propsId, level = propsLevel, itemData = propsTab, quality = propsTab.quality, iconImg = propsTab.art, eventStyle = 0}
        if not propsIcon then
            propsIcon = IconUtils:createWeaponsBagItemIcon(param)
            propsIcon:setName("propsIcon")
            propsIcon:setPosition((cellNum-1)*80+3, 1)
            propsIcon:setScale(0.72)
            inView:addChild(propsIcon)

            propsIcon:setTouchEnabled(true)
            propsIcon:setSwallowTouches(false)
            inView["propsIcon" .. cellNum] = propsIcon
        else
            IconUtils:updateWeaponsBagItemIcon(propsIcon, param)
        end

        if indexId == 1 then
            local onReplace = self:isRecommend()
            if onReplace == true then
                if not recommend then
                    recommend = ccui.ImageView:create("globalImageUI7_tuijian1.png", 1)
                    recommend:setRotation(-35)
                    recommend:setScale(0.8)
                    recommend:setPosition(15,inView:getContentSize().height-20)
                    inView:addChild(recommend,100)
                    inView["recommend" .. cellNum] = recommend
                end
                recommend:setVisible(true)
            else
                if recommend then
                    recommend:setVisible(false)
                end
            end
        else
            if recommend then
                recommend:setVisible(false)
            end
        end

        if self._secProps and (self._secProps.indexId == indexId) then
            if xuanzhong then
                xuanzhong:setVisible(true)
            end
        else
            if xuanzhong then
                xuanzhong:setVisible(false)
            end
        end
        local equipImg = propsIcon._equipImg
        local wpType = self._inPropsData[propsData.key]
        if wpType then
            if not equipImg then
                equipImg = ccui.ImageView:create("globalImageUI_weaponPropType" .. wpType .. ".png", 1)
                equipImg:setPosition(25,propsIcon:getContentSize().height-20)
                propsIcon:addChild(equipImg,99)
                propsIcon._equipImg = equipImg
            else
                equipImg:loadTexture("globalImageUI_weaponPropType" .. wpType .. ".png", 1)
            end
            equipImg:setVisible(true)
        else
            if equipImg then
                equipImg:setVisible(false)
            end
        end
        self:registerClickEvent(propsIcon, function()
            -- self:updatePropsCell(inView, indexId, cellNum, flag)
            local tsec = self._secProps
            if tsec then
                -- print('indexId=======11========', tsec.indexId)
                tsec:setVisible(false)
                tsec.propsData = nil 
                tsec.indexId = 0
                -- print('indexId=======22========', tsec.indexId)
            end
            if xuanzhong then
                self._selPropIcon = propsIcon
                xuanzhong:setVisible(true)
                xuanzhong.indexId = indexId
                xuanzhong.propsData = propsData
                self._secProps = xuanzhong
                -- print('indexId=======33========', xuanzhong.indexId)
                self:updateLeftPanel(propsData)  
                if self._secProps then
                    self._replaceBtn:setSaturation(0) 
                end
            end
        end)
        propsIcon:setVisible(true)
    else
        if propsIcon then
            propsIcon:setVisible(false)
        end
        if xuanzhong then
            xuanzhong:setVisible(false)
        end
        if recommend then
            recommend:setVisible(false)
        end
    end
end

function WeaponsReplaceView:isRecommend()
    local onReplace = false
    local wpType = self._selectType
    local weaponTypeData = self._weaponsModel:getWeaponsDataByType(wpType)
    local weaponTypeTab = tab.siegeWeaponType[wpType]
    local equipType = weaponTypeTab.equipType
    local skillTab = equipType[self._selectPosId]
    local propsData = self._weaponsModel:getPropsNoInsertByType(skillTab)
    local sp = weaponTypeData["sp" .. self._selectPosId]
    local tpropData1 = self._weaponsModel:getPropsDataByKey(sp)
    local tpropData2 = self._weaponsModel:getRecommendProps(propsData, wpType)[1]
    if (not tpropData1) and tpropData2 then
        onReplace = true
        return onReplace
    elseif not tpropData2 then
        return onReplace
    end
    local score1 = tpropData1.score
    local score2 = tpropData2.score
    local quality1 = tpropData1.quality
    local quality2 = tpropData2.quality
    local proper1 = tpropData1.showequip[wpType]
    local proper2 = tpropData2.showequip[wpType]

    if proper1 < proper2 then
        onReplace = true
    elseif proper1 == proper2 then
        if score1 < score2 then
            onReplace = true
        end
    end
    return onReplace
end

function WeaponsReplaceView:updateLeftPanel(propsData)    
    dump(propsData)
    local natureLab = {}
    local natureValue = {}
    local warningLab = {}

    local propKey = propsData.key 
    local propId = propsData.id 
    local propLevel = propsData.lv
    if not propId then
        local nothing = self:getUI("bg.nothing")
        nothing:setVisible(true)
        local shuxingBg = self:getUI("bg.shuxingBg")
        shuxingBg:setVisible(false)
        return
    end

    local propTab = tab:SiegeEquip(propId)

    local propType = propsData.jackType
    local shuxingBg = self:getUI("bg.shuxingBg")
    local titleLab = self:getUI("bg.shuxingBg.titleLab")
    titleLab:setString(lang(propTab.name))
    local propTypeImg = self:getUI("bg.shuxingBg.propType")
    propTypeImg:loadTexture("weaponImageUI_propsType" .. propType .. ".png", 1)
    local posx = shuxingBg:getContentSize().width - titleLab:getContentSize().width - propTypeImg:getContentSize().width - 10
    posx = posx*0.5
    titleLab:setPositionX(posx)
    posx = posx + titleLab:getContentSize().width + 10
    propTypeImg:setPositionX(posx)

    local attrData = self._weaponsModel:getPropsAttr(propKey)
 
    natureLab[1] = "战斗力"
    natureValue[1] = propsData.score
    warningLab[1] = 0

    local intproperty = propTab.intproperty
    for i=1,3 do
        local _intproperty = intproperty[i]
        if _intproperty then
            table.insert(natureLab, lang("SIEGEWEAPONT_" .. _intproperty[1]))
            table.insert(natureValue, "+" .. attrData[_intproperty[1]])
            table.insert(warningLab, 0)
        end
    end

    local lineId = table.nums(natureLab)

    local equipLimitLv = tab:Setting("SIEGE_EQUIP_LV").value
    for i=1,6 do
        local percent = propTab["percent" .. i]
        if percent then
            table.insert(natureLab, lang("SIEGEWEAPONTS_" .. percent[1]))
            table.insert(natureValue, "+" .. percent[2] .. "%")
            if propLevel < equipLimitLv[i] then
                table.insert(warningLab, "(配件" .. equipLimitLv[i] .. "级激活)")
            else
                table.insert(warningLab, 0)
            end
        end
    end

    -- dump(natureLab)
    -- dump(natureValue)
    -- dump(warningLab)

    local scrollView = self:getUI("bg.shuxingBg.scrollView")
    local natureNum = table.nums(natureLab)
    local maxHight = natureNum*22 + 30
    print("maxHight========", maxHight)
    scrollView:setInnerContainerSize(cc.size(200, maxHight))
    maxHight = scrollView:getInnerContainerSize().height
    for i=1,10 do
        local desLab = scrollView["desLab" .. i]
        if not desLab then
            desLab = cc.Label:createWithTTF("", UIUtils.ttfName, 18)
            desLab:setAnchorPoint(0, 0.5)
            desLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
            desLab:setName("desLab")
            scrollView:addChild(desLab) -- 4r3
            scrollView["desLab" .. i] = desLab 
        end

        local valueLab = scrollView["valueLab" .. i]
        if not valueLab then
            valueLab = cc.Label:createWithTTF("", UIUtils.ttfName, 20)
            valueLab:setAnchorPoint(0, 0.5)
            valueLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
            valueLab:setName("valueLab")
            scrollView:addChild(valueLab) -- 4r3
            scrollView["valueLab" .. i] = valueLab 
        end
        if natureLab[i] then
            desLab:setString(natureLab[i])
            desLab:setPosition(10, maxHight-i*24)
            desLab:setVisible(true)
        else
            desLab:setVisible(false)
        end
        if natureValue[i] then
            valueLab:setString(natureValue[i])
            valueLab:setPosition(100, maxHight-i*24)
            valueLab:setVisible(true)
        else
            valueLab:setVisible(false)
        end
        if i > lineId then
            valueLab:setPosition(110, maxHight-i*24)
        end
        if warningLab[i] ~= 0 then
            desLab:setColor(UIUtils.colorTable.ccUIBaseColor8)
            valueLab:setColor(UIUtils.colorTable.ccUIBaseColor8)
        else
            desLab:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
            valueLab:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
        end
        if i == 1 then
            desLab:setColor(cc.c3b(201, 38, 27))
            valueLab:setColor(cc.c3b(201, 38, 27))
        end
    end
    local nothing = self:getUI("bg.nothing")
    nothing:setVisible(false)
    local shuxingBg = self:getUI("bg.shuxingBg")
    shuxingBg:setVisible(true)
end

-- function WeaponsReplaceView:updateLeftPanel(propsData)    
--     dump(propsData)

--     local propKey = propsData.key 
--     local propId = propsData.id 
--     local propLevel = propsData.lv
--     if not propId then
--         local nothing = self:getUI("bg.nothing")
--         nothing:setVisible(true)
--         local shuxingBg = self:getUI("bg.shuxingBg")
--         shuxingBg:setVisible(false)
--         return
--     end
--     local propTab = tab:SiegeEquip(propId)
--     local propType = propsData.jackType

--     local attrData = self._weaponsModel:getPropsAttr(propKey)
--     local nothing = self:getUI("bg.nothing")
--     nothing:setVisible(false)
--     local shuxingBg = self:getUI("bg.shuxingBg")
--     shuxingBg:setVisible(true)

--     local shuxingBg = self:getUI("bg.shuxingBg")
--     local titleLab = self:getUI("bg.shuxingBg.titleLab")
--     titleLab:setString(lang(propTab.name))
--     local propTypeImg = self:getUI("bg.shuxingBg.propType")
--     propTypeImg:loadTexture("weaponImageUI_propsType" .. propType .. ".png", 1)
--     local posx = shuxingBg:getContentSize().width - titleLab:getContentSize().width - propTypeImg:getContentSize().width - 10
--     posx = posx*0.5
--     titleLab:setPositionX(posx)
--     posx = posx + titleLab:getContentSize().width + 10
--     propTypeImg:setPositionX(posx)

--     local fightLab = self:getUI("bg.shuxingBg.fightLab")
--     fightLab:setString(propsData.score)


--     local attr1TipLab = self:getUI("bg.shuxingBg.infoBg.attr1TipLab")
--     local attr1Lab = self:getUI("bg.shuxingBg.infoBg.attr1Lab")
--     local attr2TipLab = self:getUI("bg.shuxingBg.infoBg.attr2TipLab")
--     local attr2Lab = self:getUI("bg.shuxingBg.infoBg.attr2Lab")
--     local attr3TipLab = self:getUI("bg.shuxingBg.infoBg.attr3TipLab")
--     local attr3Lab = self:getUI("bg.shuxingBg.infoBg.attr3Lab")

--     local intproperty = propTab.intproperty
--     if intproperty[1] then
--         attr1TipLab:setVisible(true)
--         attr1Lab:setVisible(true)
--         attr1TipLab:setString(lang("SIEGEWEAPONT_" .. intproperty[1][1]))
--         attr1Lab:setString("+" .. attrData[1])
--     else
--         attr1TipLab:setVisible(false)
--         attr1Lab:setVisible(false)
--     end

--     if intproperty[2] then
--         attr2TipLab:setVisible(true)
--         attr2Lab:setVisible(true)
--         attr2TipLab:setString(lang("SIEGEWEAPONT_" .. intproperty[2][1]))
--         attr2Lab:setString("+" .. attrData[2])
--     else
--         attr2TipLab:setVisible(false)
--         attr2Lab:setVisible(false)
--     end

--     if intproperty[3] then
--         attr3TipLab:setVisible(true)
--         attr3Lab:setVisible(true)
--         attr3TipLab:setString(lang("SIEGEWEAPONT_" .. intproperty[3][1]))
--         attr3Lab:setString("+" .. attrData[3])
--     else
--         attr3TipLab:setVisible(false)
--         attr3Lab:setVisible(false)
--     end

--     local tipLab1 = self:getUI("bg.shuxingBg.expertBg.tipLab1")
--     local valueLab1 = self:getUI("bg.shuxingBg.expertBg.valueLab1")
--     local warningLab1 = self:getUI("bg.shuxingBg.expertBg.warningLab1")
--     local tipLab2 = self:getUI("bg.shuxingBg.expertBg.tipLab2")
--     local valueLab2 = self:getUI("bg.shuxingBg.expertBg.valueLab2")
--     local warningLab2 = self:getUI("bg.shuxingBg.expertBg.warningLab2")
--     local tipLab3 = self:getUI("bg.shuxingBg.expertBg.tipLab3")
--     local valueLab3 = self:getUI("bg.shuxingBg.expertBg.valueLab3")
--     local warningLab3 = self:getUI("bg.shuxingBg.expertBg.warningLab3")

--     local equipLimitLv = tab:Setting("SIEGE_EQUIP_LV").value
--     local percent = propTab["percent1"]
--     if percent then
--         tipLab1:setVisible(true)
--         valueLab1:setVisible(true)
--         warningLab1:setVisible(true)
--         tipLab1:setString(lang("SIEGEWEAPONT_" .. percent[1]))
--         valueLab1:setString("+" .. percent[2] .. "%")
--         if propLevel < equipLimitLv[1] then
--             warningLab1:setString("(配件" .. equipLimitLv[1] .. "级激活)")
--             warningLab1:setVisible(false)
--             tipLab1:setColor(UIUtils.colorTable.ccUIBaseColor8)
--             valueLab1:setColor(UIUtils.colorTable.ccUIBaseColor8)
--         else
--             warningLab1:setVisible(false)
--             tipLab1:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
--             valueLab1:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
--         end
--     else
--         tipLab1:setVisible(false)
--         valueLab1:setVisible(false)
--         warningLab1:setVisible(false)
--     end

--     local percent = propTab["percent2"]
--     if percent then
--         tipLab2:setVisible(true)
--         valueLab2:setVisible(true)
--         tipLab2:setString(lang("SIEGEWEAPONT_" .. percent[1]))
--         valueLab2:setString("+" .. percent[2] .. "%")
--         if propLevel < equipLimitLv[2] then
--             warningLab2:setString("(配件" .. equipLimitLv[2] .. "级激活)")
--             warningLab2:setVisible(false)
--             tipLab2:setColor(UIUtils.colorTable.ccUIBaseColor8)
--             valueLab2:setColor(UIUtils.colorTable.ccUIBaseColor8)
--         else
--             warningLab2:setVisible(false)
--             tipLab2:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
--             valueLab2:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
--         end
--     else
--         tipLab2:setVisible(false)
--         valueLab2:setVisible(false)
--         warningLab2:setVisible(false)
--     end

--     local percent = propTab["percent3"]
--     if percent then
--         tipLab3:setVisible(true)
--         valueLab3:setVisible(true)
--         tipLab3:setString(lang("SIEGEWEAPONT_" .. percent[1]))
--         valueLab3:setString("+" .. percent[2] .. "%")
--         if propLevel < equipLimitLv[3] then
--             warningLab3:setString("(配件" .. equipLimitLv[3] .. "级激活)")
--             warningLab3:setVisible(false)
--             tipLab3:setColor(UIUtils.colorTable.ccUIBaseColor8)
--             valueLab3:setColor(UIUtils.colorTable.ccUIBaseColor8)
--         else
--             warningLab3:setVisible(false)
--             tipLab3:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
--             valueLab3:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
--         end
--     else
--         tipLab3:setVisible(false)
--         valueLab3:setVisible(false)
--         warningLab3:setVisible(false)
--     end
-- end

function WeaponsReplaceView:installProp(param, weaponsId)
    dump(param)
    local weaponTypeData = clone(self._weaponsModel:getWeaponsDataByType(self._selectType))
    local oldPropKey = weaponTypeData["sp" .. param.slotId]
    local oldPropData = self._weaponsModel:getPropsDataByKey(oldPropKey)
    local oldPropFight = 0
    if oldPropData then
        oldPropFight = oldPropData.score
    end
    self._serverMgr:sendMsg("WeaponServer", "installProp", param, true, {}, function (result)
        -- self:updateCurrencyUI()
        -- self:updateRightSubBg()
        -- self:updateLeftPanel(weaponId, weaponsId)
        local newWeaponTypeData = self._weaponsModel:getWeaponsDataByType(self._selectType)
        local skillLock = self._weaponsModel:getWeaponsSkillLock()
        for i=1,2 do
            local indexId = "ss" .. i
            local oldSkill = weaponTypeData[indexId]
            local newSkill = newWeaponTypeData[indexId]
            if newSkill == 1 and oldSkill == 0 then
                skillLock[i] = i
            end
        end
        dump(skillLock)

        local propData = self._weaponsModel:getPropsDataByKey(param.propIdx)
        local propFight = propData.score
        local fightBg = self:getUI("bg")
        TeamUtils:setFightAnim(fightBg, {oldFight = oldPropFight, newFight = propFight, x = fightBg:getContentSize().width*0.5-100, y = fightBg:getContentSize().height - 100})
    end)
end


-- 物品框特效
function WeaponsReplaceView:setAnim(inView)
    -- self:lock()
    local mc2 = mcMgr:createViewMC("wupinguang_teamupgrade", true, false, function (_, sender)
        sender:gotoAndPlay(0)
        sender:removeFromParent()
    end)
    mc2:setName("anim2")
    mc2:setScale(1.2)
    mc2:setPosition(50, 50)
    inView:addChild(mc2, 2)

-- 物品移动
    local bg = self:getUI("bg")  
    local mc3 = inView:clone()
    
    mc3:setTouchEnabled(false)
    mc3:setAnchorPoint(cc.p(0.5, 0.5))
    mc3:setScale(0.9)
    mc3:setCascadeOpacityEnabled(true)
    bg:addChild(mc3, 10)
    -- local itemCount = mc3:getChildByFullName("itemCount")
    -- if itemCount then
    --     itemCount:removeFromParent()
    -- end

    local equipBg = self:getUI("bg.equiptList.equipBg" .. self._selectPosId)
    local equipBgWorldPoint = equipBg:convertToWorldSpace(cc.p(38, 38))
    local mcPos = bg:convertToNodeSpace(cc.p(equipBgWorldPoint.x,equipBgWorldPoint.y))

    local itemWorldPoint = inView:convertToWorldSpace(cc.p(50, 50))
    local pos1 = bg:convertToNodeSpace(cc.p(itemWorldPoint.x,itemWorldPoint.y))
    mc3:setPosition(cc.p(pos1.x,pos1.y))

    local moveSp = cc.EaseOut:create(cc.MoveTo:create(0.2, cc.p(mcPos.x,mcPos.y)), 3)
    local seq = cc.Sequence:create(cc.Spawn:create(moveSp,cc.FadeTo:create(0.3, 100)), cc.RemoveSelf:create(true))
    mc3:runAction(seq)
end


function WeaponsReplaceView:uninstallProp(param, weaponsId)
    dump(param)
    self._serverMgr:sendMsg("WeaponServer", "uninstallProp", param, true, {}, function (result)
        dump(result, "result=======", 10)
        -- self:updateCurrencyUI()
        -- self:updateRightSubBg()
        -- self:updateLeftPanel(weaponId, weaponsId)
    end)
end


return WeaponsReplaceView