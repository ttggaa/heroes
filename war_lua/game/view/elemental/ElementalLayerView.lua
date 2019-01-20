--[[
    @FileName   ElementalLayerView.lua
    @Authors    zhangtao
    @Date       2017-08-14 15:09:10
    @Email      <zhangtao@playcrad.com>
    @Description   描述
--]]

local ElementalLayerView = class("ElementalLayerView",BaseView)
require "game.view.intance.IntanceUtils" 
local loadInfo =     
    {   --1 背景 2 人物  3 title背景 4title 名字  5领主名字 6.奖励背景面板 7.奖励覆盖图片 8调色值

        {"elementalBg/elemental_huo.jpg","asset/uiother/element/person_huo.png","elemental_huoTitleImage.png","elemental_huoTitleName.png",
            "elemental_nameHuo.png","bgFlag_pveAiRen.png","elemental_cover1.png","0"},
        {"elementalBg/elemental_shui.jpg","asset/uiother/element/person_shui.png","elemental_shuiTitleImage.png","elemental_shuiTitleName.png",
            "elemental_nameShui.png","bgFlag_pveZombie.png","elemental_cover3.png","0"},
        {"elementalBg/elemental_qi.jpg","asset/uiother/element/person_qi.png","elemental_qiTitleImage.png","elemental_qiTitleName.png",
            "elemental_nameQi.png","bgFlag_pveDragon.png","elemental_cover2.png","0"},
        {"elementalBg/elemental_tu.jpg","asset/uiother/element/person_tu.png","elemental_tuTitleImage.png","elemental_tuTitleName.png",
            "elemental_nameTu.png","bgFlag_pveAiRen.png","elemental_cover1.png","12"},
        {"elementalBg/elemental_hundun.jpg","asset/uiother/element/person_hundun.png","elemental_hundunTitleImage.png","elemental_hundunTitleName.png",
            "elemental_nameHunluan.png","bgFlag_pveDragon.png","elemental_cover2.png","0"}
    }

function ElementalLayerView:ctor(data)
    self.super.ctor(self)
    self._planeId = data.planeId
    self._layerNum = data.layerNum

    self._elementModel = self._modelMgr:getModel("ElementModel")
    self._formationModel = self._modelMgr:getModel("FormationModel")
    self._elementTable = {
                            [1] = tab.elementalPlane1,
                            [2] = tab.elementalPlane2,
                            [3] = tab.elementalPlane3,
                            [4] = tab.elementalPlane4,
                            [5] = tab.elementalPlane5,
                        }

    self._formationType = {
                            [1] = self._formationModel.kFormationTypeElemental1,
                            [2] = self._formationModel.kFormationTypeElemental2,
                            [3] = self._formationModel.kFormationTypeElemental3,
                            [4] = self._formationModel.kFormationTypeElemental4,
                            [5] = self._formationModel.kFormationTypeElemental5,
                        }

    self._awardTable = {}
    self._openLayerNum = 0   --当前打到的层数
    self._mercenaryId = 0    --设置的佣兵id
    self._userId = 0         
end

-- 第一次被加到父节点时候调用
function ElementalLayerView:onBeforeAdd(callback, errorCallback)
    self._serverMgr:sendMsg("ElementServer", "getElementFirstData", {elementId = self._planeId,stageId = self._layerNum}, true, {}, function(result, errorCode)
        if errorCode ~= 0 then 
            errorCallback()
            self._viewMgr:unlock(51)
            return
        end
        self:initOrder(result)
        callback()
    end)
end
--初始化排名
function ElementalLayerView:initOrder(result)
    self._orderList[1]:setString("暂无数据")
    self._orderList[2]:setString("暂无数据")
    self._orderList[3]:setString("暂无数据")
    if result == nil or not next(result) then return end 
    if result["rankData"] then
        for k , v in pairs(result["rankData"]) do
            self._orderList[v["rank"]]:setString(v["name"])
        end
    end
    if result["owner"] then
        self:getUI("orderBg.myOrderValue"):setString(result["owner"]["rank"])
    else
        self:getUI("orderBg.myOrderValue"):setString(0)
    end
end
-- 初始化UI后会调用, 有需要请覆盖
function ElementalLayerView:onInit()
    local closeBtn = self:getUI("closeBtn")
    self:registerClickEvent(closeBtn, function()
        UIUtils:reloadLuaFile("elemental.ElementalLayerView")
        self:close()
    end)
    self._challengeTimes = self._elementModel:getMaxChallengeTimes()
    --挑战按钮
    self._challengeBtn = self:getUI("Panel.rightBk.challengeBtn")
    self._challengeBtn:setVisible(false)
    self:registerClickEvent(self._challengeBtn, function()
        local hasTimes = self._elementModel:getAllElementTimes()[self._planeId]
        if hasTimes == 0 then
            self._viewMgr:showTip("今日挑战次数已用完")
            return
        end
        local openLv = self._elementTable[self._planeId][self._layerNum]["openLv"] or 0
        local curLv = self._modelMgr:getModel("UserModel"):getData()["lvl"] or 0
        if curLv < openLv then
            self._viewMgr:showTip("等级达到"..openLv.."开启")
            return
        end

        self:enterFormation()
    end)
    --扫荡按钮
    self._sweepBtn = self:getUI("Panel.rightBk.sweepBtn")
    self._sweepBtn:setVisible(false)
    self:registerClickEvent(self._sweepBtn, function()
        self:onSweepLevel(self._layerNum)
    end)    
    
    --文字加描边
    self:getUI("Panel.rightBk.skill"):enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:getUI("Panel.rightBk.tuijian"):enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:getUI("Panel.rightBk.award"):enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:getUI("Panel.rightBk.hasTime"):enableOutline(cc.c4b(0, 0, 0, 255), 1)
    -- self:getUI("progressBk.progressTitle"):setBrightness(10)

    self._orderList = {}
    local order1 = self:getUI("orderBg.order1")
    local order2 = self:getUI("orderBg.order2")
    local order3 = self:getUI("orderBg.order3")
    table.insert(self._orderList,order1)
    table.insert(self._orderList,order2)
    table.insert(self._orderList,order3)
    self:updataUI()
    --当前进度
    self:addProgressAni(false)

    self:setMenuClick()
    -- self:setListenReflashWithParam(true)
    -- self:listenReflash("ElementModel", self.reLoadUI)
end


function ElementalLayerView:updataUI()
    self._openLayerNum = self._elementModel:getElementData()["stageId"..self._planeId] or 0
    --标头
    self._titleBg = self:getUI("titleBg")
    self._titleBg:loadTexture(loadInfo[self._planeId][3], 1)
    self._titleName = self:getUI("titleBg.titleName")
    self._titleName:loadTexture(loadInfo[self._planeId][4], 1)
    --名字
    self._layerName = self:getUI("Panel.rightBk.layerTitle.layerName")
    self._layerName:loadTexture(loadInfo[self._planeId][5], 1)    
    --层
    self._layerorder = self:getUI("Panel.rightBk.layerTitle.layerNum")
    self._layerorder:setString("第"..self._layerNum.."层")

    --人物形象
    -- self._bg.personImage:loadTexture(loadInfo[self._planeId][2], 2)

    --右侧面板
    self._rightBk = self:getUI("Panel.rightBk")
    self._rightBk:loadTexture(loadInfo[self._planeId][6],1)
    self._rightBk:setHue(tonumber(loadInfo[self._planeId][8]))

    self._coverImage = self:getUI("Panel.rightBk.coverImage")
    self._coverImage:loadTexture(loadInfo[self._planeId][7],1)
    self._coverImage:setHue(tonumber(loadInfo[self._planeId][8]))  
    --更新按钮状态
    self:upBtnState()
    --剩余次数
    self:setHasTimes()
    --buffer
    -- self:createBuffNode()
    -- self:updateBufferBtnAmin
    --技能列表
    -- self:setSkill()
    self._skillNode = self:getUI("Panel.rightBk.skillBk")
    self:creatSkillTableView()
    --奖励列表
    self:setAward()
    --推荐列表
    self._tuijianNode = self:getUI("Panel.rightBk.tuijianBk")
    self:creatTableView()    
end

--更新按钮状态
function ElementalLayerView:upBtnState()
    if self._openLayerNum < self._layerNum then
        self._challengeBtn:setVisible(true)
        self._sweepBtn:setVisible(false)
    else
        self._challengeBtn:setVisible(false)
        self._sweepBtn:setVisible(true)
    end
end
--添加进度动画
function ElementalLayerView:addProgressAni(backFight)
    self._openLayerNum = self._elementModel:getElementData()["stageId"..self._planeId] or 0
    local maxLayer = #self._elementTable[self._planeId]
    if not backFight or self._openLayerNum == maxLayer then self:setProgress() return end
    local fankuiAni = mcMgr:createViewMC("fankui_lianmengjihuo", false,true, function()
        self:setProgress()
    end)
    local containsNode = nil
    if self._openLayerNum > 0 and  self._openLayerNum < maxLayer - 1 then
        containsNode = self:getUI("progressBk.icon2")
    else
        containsNode = self:getUI("progressBk.icon3")
    end
    local conContentSize = containsNode:getContentSize()
    fankuiAni:setPosition(cc.p(conContentSize.width/2,conContentSize.height/2))
    containsNode:addChild(fankuiAni)
end

--设置进度
function ElementalLayerView:setProgress()
    dump(self._elementModel:getElementData(),"_elementModel")
    local openLayer = self._openLayerNum

    -- local openLayer = 2
    local maxLayer = #self._elementTable[self._planeId]   
    print("========openLayer==========="..openLayer)
    print("========maxLayer==========="..maxLayer)
    for i = 1,3 do
        self:getUI("progressBk.icon"..i):loadTexture("elemental_notCrossIcon.png",1)
        self:getUI("progressBk.layer"..i):setColor(cc.c3b(255, 255, 255))
        self:getUI("progressBk.layer"..i):setString("第"..i.."层")
    end
    if openLayer == 0 then
        self:getUI("progressBk.icon"..1):loadTexture("elemental_curIcon.png",1)
        self:getUI("progressBk.layer"..1):setColor(cc.c3b(255, 230, 65))
    elseif openLayer > 0 and openLayer < maxLayer - 1 then
        self:getUI("progressBk.icon"..1):loadTexture("elemental_crossIcon.png",1)
        self:getUI("progressBk.icon"..2):loadTexture("elemental_curIcon.png",1)
        self:getUI("progressBk.layer"..1):setString("第"..openLayer.."层")
        self:getUI("progressBk.layer"..2):setString("第"..(openLayer + 1).."层")
        self:getUI("progressBk.layer"..3):setString("第"..(openLayer + 2).."层")
        self:getUI("progressBk.layer"..2):setColor(cc.c3b(255, 230, 65))
    elseif openLayer == maxLayer - 1 then
        self:getUI("progressBk.icon"..1):loadTexture("elemental_crossIcon.png",1)
        self:getUI("progressBk.icon"..2):loadTexture("elemental_crossIcon.png",1)
        self:getUI("progressBk.icon"..3):loadTexture("elemental_curIcon.png",1)
        self:getUI("progressBk.layer"..1):setString("第"..(openLayer - 1).."层")
        self:getUI("progressBk.layer"..2):setString("第"..openLayer.."层")
        self:getUI("progressBk.layer"..3):setString("第"..(openLayer + 1).."层")
        self:getUI("progressBk.layer"..3):setColor(cc.c3b(255, 230, 65))        
    else
        self:getUI("progressBk.icon"..1):loadTexture("elemental_crossIcon.png",1)
        self:getUI("progressBk.icon"..2):loadTexture("elemental_crossIcon.png",1)
        self:getUI("progressBk.icon"..3):loadTexture("elemental_crossIcon.png",1)
        self:getUI("progressBk.layer"..1):setString("第"..(openLayer - 2).."层")
        self:getUI("progressBk.layer"..2):setString("第"..(openLayer - 1).."层")
        self:getUI("progressBk.layer"..3):setString("第"..openLayer.."层")
        self:getUI("progressBk.layer"..3):setColor(cc.c3b(255, 230, 65))        
    end
end


--设置挑战次数
function ElementalLayerView:setHasTimes()
    local hasTimes = self._elementModel:getAllElementTimes()[self._planeId]
    self._hasTime = self:getUI("Panel.rightBk.hasTime")
    self._hasTime:setString(hasTimes.."/"..self._challengeTimes)
    self._hasTime:setColor(hasTimes == 0 and cc.c3b(255, 0, 0) or cc.c3b(0, 255, 0))
    -- self._challengeBtn:setTouchEnabled(hasTimes ~= 0)
    self._challengeBtn:setSaturation(hasTimes == 0 and -180 or 0)
end

--技能列表
function ElementalLayerView:creatSkillTableView()
    if self._skillTableView then
        self._skillTableView:reloadData()
        return 
    end
    local tableView = cc.TableView:create(cc.size(380,69))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    tableView:setAnchorPoint(0,0)
    tableView:setPosition(0 ,0)
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    self._skillNode:addChild(tableView,999)
    tableView:registerScriptHandler(function ( table,cell ) return self:skillTableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(function( table,index ) return self:skillCellSizeForTable(table,index) end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function ( table,index ) return self:skillTableCellAtIndex(table,index) end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function ( table ) return self:skillNumberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()
    self._skillTableView = tableView
end


function ElementalLayerView:skillTableCellTouched(table,cell)
end

function ElementalLayerView:skillCellSizeForTable(table,idx) 
    return 50,50
end

function ElementalLayerView:skillTableCellAtIndex(table,idx)
    local index = idx + 1
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    else
        cell:removeAllChildren()
    end
    local skillTable = self._elementTable[self._planeId][self._layerNum]["skill"]
    local sysSkill = SkillUtils:getTeamSkillByType(tonumber(skillTable[index][2]),skillTable[index][1])
    local defFrame = nil
    if index == 1 then
        defFrame = "globalImageUI_teamawakeskill2.png"
    end
    local itemView = IconUtils:createTeamSkillIconById({teamSkill = sysSkill,level = 1, eventStyle = 1,iconFrame = defFrame})

    itemView:getChildByFullName("icon"):setSwallowTouches(false)
    local boxIcon = itemView:getChildByFullName("boxIcon")
    boxIcon:setSwallowTouches(false)
    if index == 1 then
        local borderImage = "globalImageUI_teamawakeskill2.png"
        boxIcon:loadTexture(borderImage, 1)
    end

    itemView:setAnchorPoint(cc.p(0.5,0.5))
    itemView:setScale(0.5)
    itemView:setPosition(30,29)
    itemView:setVisible(true)
    cell:addChild(itemView)
    return cell
end

function ElementalLayerView:skillNumberOfCellsInTableView(table)
    return #self._elementTable[self._planeId][self._layerNum]["skill"]
end


--奖励
function ElementalLayerView:setAward()
    local isFirstCross = true  --是否首通
    if tonumber(self._openLayerNum) < tonumber(self._layerNum) then
        self._awardTable = self._elementTable[self._planeId][self._layerNum]["firstReward"]
        isFirstCross = true
    else
        self._awardTable = self._elementTable[self._planeId][self._layerNum]["reward"]
        isFirstCross = false
    end
    local createAwardItem = function(data,indexId,isFirstCross)
        local itemBg = self:getUI("Panel.rightBk.awardBk.awardImage" .. indexId)
        itemBg:removeAllChildren()
        local itemId
        local teamId
        local num
        local starlevel 
        if data[1] == "tool" then
            itemId = data[2]
            num = data[3]
        elseif data[1] == "team" then 
            teamId = data[2]
            num = data[3]
            starlevel = data[4]
        elseif data[1] == "hero" then
            return
        else
            itemId = IconUtils.iconIdMap[data[1]]
            num = data[3]
        end
        local itemIcon = itemBg:getChildByName("awardItemIcon")
        if itemId then
            local param = {itemId = itemId, effect = false, eventStyle = 1, num = num}
            -- local itemIcon = itemBg:getChildByName("itemIcon")
            if itemIcon then
                IconUtils:updateItemIconByView(itemIcon, param)
            else
                itemIcon = IconUtils:createItemIconById(param)
                itemIcon:setName("awardItemIcon")
                local itemNormalScale = 78/itemIcon:getContentSize().width
                itemIcon:setScale(itemNormalScale)
                itemIcon:setPosition(cc.p(0,0))
                itemBg:addChild(itemIcon)
            end
        elseif teamId then
            local sysTeamData = clone(tab.team[teamId])
            if starlevel ~= nil  then 
                sysTeamData.starlevel = starlevel
            end
            local param = {sysTeamData = sysTeamData, effect = false, eventStyle = 0, isJin = true}
            if itemIcon then
                IconUtils:updateSysTeamIconByView(itemIcon, param)
            else
                itemIcon = IconUtils:createSysTeamIconById(param)
                itemIcon:setName("awardItemIcon")
                local itemNormalScale = 78/teamIcon:getContentSize().width
                itemIcon:setScale(itemNormalScale)
                itemIcon:setPosition(cc.p(0,0))
                itemBg:addChild(itemIcon)
            end
        end
        local colorIcon = itemIcon:getChildByName("iconColor")
        local firstIconNode = colorIcon:getChildByFullName(firstIcon)
        if firstIconNode then 
            firstIconNode:removeFromParent(true)
        end
        if isFirstCross then
            local firstIcon = cc.Sprite:createWithSpriteFrameName("globalImageUI6_connerTag_r.png")
            firstIcon:setAnchorPoint(cc.p(0, 0.5))
            firstIcon:setPosition(firstIcon:getContentSize().width - 48, firstIcon:getContentSize().height+5)
            firstIcon:setName("firstIcon")
            colorIcon:addChild(firstIcon, 8)

            local firstTxt = cc.Label:createWithTTF("首通", UIUtils.ttfName, 22)
            firstTxt:setRotation(41)
            firstTxt:setPosition(cc.p(45, 37))
            firstTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            firstIcon:addChild(firstTxt)
        end
    end
    for k , v in pairs(self._awardTable) do
        createAwardItem(v,k,isFirstCross)
    end
    -- table.walk(t, fun)
end



-- --奖励列表
-- function ElementalLayerView:createAwardItem(data, indexId,isFirstCross)
--     local itemBg = self:getUI("Panel.rightBk.awardBk.awardImage" .. indexId)
--     itemBg:removeAllChildren()
--     local itemId
--     local teamId
--     local num
--     local starlevel 
--     if data[1] == "tool" then
--         itemId = data[2]
--         num = data[3]
--     elseif data[1] == "team" then 
--         teamId = data[2]
--         num = data[3]
--         starlevel = data[4]
--     elseif data[1] == "hero" then
--         return
--     else
--         itemId = IconUtils.iconIdMap[data[1]]
--         num = data[3]
--     end
--     local itemIcon = itemBg:getChildByName("awardItemIcon")
--     if itemId then
--         local param = {itemId = itemId, effect = false, eventStyle = 1, num = num}
--         -- local itemIcon = itemBg:getChildByName("itemIcon")
--         if itemIcon then
--             IconUtils:updateItemIconByView(itemIcon, param)
--         else
--             itemIcon = IconUtils:createItemIconById(param)
--             itemIcon:setName("awardItemIcon")
--             local itemNormalScale = 78/itemIcon:getContentSize().width
--             itemIcon:setScale(itemNormalScale)
--             itemIcon:setPosition(cc.p(0,0))
--             itemBg:addChild(itemIcon)
--         end
--     elseif teamId then
--         local sysTeamData = clone(tab.team[teamId])
--         if starlevel ~= nil  then 
--             sysTeamData.starlevel = starlevel
--         end
--         local param = {sysTeamData = sysTeamData, effect = false, eventStyle = 0, isJin = true}
--         if itemIcon then
--             IconUtils:updateSysTeamIconByView(itemIcon, param)
--         else
--             itemIcon = IconUtils:createSysTeamIconById(param)
--             itemIcon:setName("awardItemIcon")
--             local itemNormalScale = 78/teamIcon:getContentSize().width
--             itemIcon:setScale(itemNormalScale)
--             itemIcon:setPosition(cc.p(0,0))
--             itemBg:addChild(itemIcon)
--         end
--     end
--     local colorIcon = itemIcon:getChildByName("iconColor")
--     local firstIconNode = colorIcon:getChildByFullName(firstIcon)
--     if firstIconNode then 
--         firstIconNode:removeFromParent(true)
--     end
--     if isFirstCross then
--         local firstIcon = cc.Sprite:createWithSpriteFrameName("globalImageUI6_connerTag_r.png")
--         firstIcon:setAnchorPoint(cc.p(0, 0.5))
--         firstIcon:setPosition(firstIcon:getContentSize().width - 48, firstIcon:getContentSize().height+5)
--         firstIcon:setName("firstIcon")
--         colorIcon:addChild(firstIcon, 8)

--         local firstTxt = cc.Label:createWithTTF("首通", UIUtils.ttfName, 22)
--         firstTxt:setRotation(41)
--         firstTxt:setPosition(cc.p(45, 37))
--         firstTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
--         firstIcon:addChild(firstTxt)
--     end
-- end

--推荐列表
function ElementalLayerView:creatTableView()
    if self._tableView then
        self._tableView:reloadData()
        return 
    end
    local tableView = cc.TableView:create(cc.size(380,69))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    tableView:setAnchorPoint(0,0)
    tableView:setPosition(0 ,0)
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    self._tuijianNode:addChild(tableView,999)
    tableView:registerScriptHandler(function( view ) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(function ( table,cell ) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(function( table,index ) return self:cellSizeForTable(table,index) end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function ( table,index ) return self:tableCellAtIndex(table,index) end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function ( table ) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()
    self._tableView = tableView
end


function ElementalLayerView:scrollViewDidScroll(view)

end

function ElementalLayerView:tableCellTouched(table,cell)
    print("=======tableCellTouched===========")
end

function ElementalLayerView:cellSizeForTable(table,idx) 
    return 60,60
end

function ElementalLayerView:tableCellAtIndex(table,idx)
    local index = idx + 1
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    else
        cell:removeAllChildren()
    end

    local tuijianData = self._elementTable[self._planeId][self._layerNum]["commend"]
    local teamId = tonumber(tuijianData[index])
    local teamTableData = tab:Team(teamId)
    local star = 0
    local stage = 1
    if teamTableData then
        star = teamTableData.star
        stage = teamTableData.stage
    end
    local itemView = IconUtils:createTeamIconById({teamData = {id = teamId, star = star}, sysTeamData = teamTableData, quality = nil, quaAddition = 0, tipType = 9, eventStyle = 2})
    
    itemView.teamIcon:setSwallowTouches(false)
    if star == 0 then
        itemView:setSaturation(-100)
    end
    IconUtils:setTeamIconStarVisible(itemView, false)
    IconUtils:setTeamIconStageVisible(itemView, false)
    IconUtils:setTeamIconLevelVisible(itemView, false)

    itemView:setAnchorPoint(cc.p(0.5,0.5))
    itemView:setScale(0.5)
    itemView:setPosition(36,33)
    itemView:setVisible(true)
    cell:addChild(itemView)

    return cell
end

function ElementalLayerView:numberOfCellsInTableView(table)
    return #self._elementTable[self._planeId][self._layerNum]["commend"]
end

-- function ElementalLayerView:createBuffNode()
--     local bufferBg = self:getUI("bufferBg")
--     bufferBg:setVisible(false)
--     local buffBg = self:getUI("buffBg")
--     buffBg:setVisible(false)

--     --重置buff图标位置
--     for i=1,5 do
--         local bufferIcon = self:getUI("bufferBg.smallIcon" .. i)
--         bufferIcon:setPosition(bufferIcon:getPositionX()+125, bufferIcon:getPositionY()+125)
--     end

--     local function showBufferNode()    --左上角buff按钮点击事件  
--         local userBuffs = cjson.decode(self._elementModel:getElementData()["buffList"])
--         dump(userBuffs)
--         if (userBuffs == nil or table.nums(userBuffs) <=0) then 
--             self._viewMgr:showTip("您当前没有加成")
--             return
--         end
--         local bgLayer = ccui.Layout:create()
--         bgLayer:setBackGroundColorOpacity(0)
--         bgLayer:setBackGroundColorType(1)
--         bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
--         bgLayer:setTouchEnabled(true)
--         bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
--         self._widget:addChild(bgLayer, 100)
--         bgLayer:setName("bgLayer")

--         registerClickEvent(bgLayer, function()
--             local bufferBg = self:getUI("bufferBg")    --buff显示图
--             bufferBg:setVisible(false)
--             local buffBg = self:getUI("buffBg")   
--             buffBg:setVisible(false)
--             bgLayer:removeFromParent()
--         end)

--         --普通buff
--         if userBuffs ~= nil and next(userBuffs) ~= nil then
--             local bufferBg = self:getUI("bufferBg")
--             local sysBuffPic = tab.crusadeBuffPic
--             for i=1,5 do
--                 local bufferIcon = self:getUI("bufferBg.smallIcon" .. i)
--                 bufferIcon:setVisible(false)

--                 if bufferBg:getChildByName("richText" .. i) ~= nil then 
--                     bufferBg:getChildByName("richText" .. i):removeFromParent()
--                 end
--             end

--             local buffOrderKeys = table.keys(userBuffs)

--             local sortFunc = function(a, b) return tonumber(b) > tonumber(a) end
--             table.sort(buffOrderKeys, sortFunc)
--             for k,v in pairs(buffOrderKeys) do
--                 local buff = userBuffs[v]
--                 local bufferIcon = self:getUI("bufferBg.smallIcon" .. k) 
--                 bufferIcon:loadTexture(sysBuffPic[tonumber(v)].pic .. ".png", 1)
--                 bufferIcon:setVisible(true)
--                 bufferIcon:setScale(0.3)
--                 local desc = lang("CRUSADE_BUFFS_" .. v)   --text
--                 local result,count = string.gsub(desc, "$num", buff)
--                 if count > 0 then 
--                     desc = result
--                 end
--                 local richText = RichTextFactory:create(desc, 160 , 0)
--                 richText:formatText()
--                 -- richText:setScale(0.9)
--                 richText:setPosition(80 + richText:getContentSize().width/2, bufferIcon:getPositionY())
--                 richText:setName("richText" .. k)
--                 bufferBg:addChild(richText)

--                 local picFrame = ccui.ImageView:create("globalImageUI4_squality5.png", 1)
--                 picFrame:setPosition( bufferIcon:getContentSize().width/2, bufferIcon:getContentSize().height/2)
--                 bufferIcon:addChild(picFrame)
--             end
--         end
--         bufferBg:setVisible(true)
--         buffBg:setVisible(true)
--     end

--     local bufferBtn = self:getUI("bufferBtn")  
--     self:registerClickEvent(bufferBtn, function()
--         showBufferNode()
--     end)
-- end

-- --buff按钮上动画
-- function ElementalLayerView:updateBufferBtnAmin()
--     local flag = false
--     if self._elementModel:getData().buffList ~= nil and 
--         table.nums(self._elementModel:getData().buffList) >0 then
--         flag = true
--     end
--     local bufferBtn = self:getUI("bufferBtn")
--     if flag == false then 
--         local amin1 = bufferBtn:getChildByName("amin1")
--         if amin1 ~= nil then
--             amin1:clearCallbacks()
--             amin1:stop()
--             amin1:removeFromParent()
--         end

--         local amin2 = bufferBtn:getChildByName("amin2")
--         if amin2 ~= nil then
--             amin2:clearCallbacks()
--             amin2:stop()
--             amin2:removeFromParent()
--         end
--     end
--     if flag == false or bufferBtn:getChildByName("amin1") ~= nil   then 
--         return
--     end

--     local point2 = bufferBtn:convertToWorldSpace(cc.p(0, 0))
--     local amin1 = mcMgr:createViewMC("buffguangxiaoxia_duizhanui", true)
--     amin1:setName("amin1")
--     amin1:setPosition(bufferBtn:getContentSize().width/2, bufferBtn:getContentSize().height/2)
--     bufferBtn:addChild(amin1, -1)

--     local amin2 = mcMgr:createViewMC("bufftubiaoshang_crusademap", true)
--     amin2:setName("amin2")
--     amin2:setPosition(bufferBtn:getContentSize().width/2, bufferBtn:getContentSize().height/2)
--     bufferBtn:addChild(amin2, 1)
-- end

function ElementalLayerView:setMenuClick()
    local orderBtn = self:getUI("menu.menuList.btnBg01")
    orderBtn:setScaleAnim(true)
    -- self:registerClickEvent(orderBtn, function()
    --     print("orderBtn click")
    --     local rankModel = self._modelMgr:getModel("RankModel")
    --     rankModel:setRankTypeAndStartNum(rankModel.kRankTypeElemQuick, 1)
    --     local id = self._planeId.."_"..self._layerNum   
    --     self._serverMgr:sendMsg("RankServer", "getRankList", {type = rankModel.kRankTypeElemQuick, startRank = 1, id = id}, true, {}, function(result)
    --         self._viewMgr:showDialog("elemental.ElementalRankView", {stageId = id}, true)
    --     end)
    -- end)
    self:registerClickEvent(orderBtn, function()
        local rankModel = self._modelMgr:getModel("RankModel")
        rankModel:setRankTypeAndStartNum(rankModel.kRankTypeElemProgress, 1) 
        self._serverMgr:sendMsg("RankServer", "getRankList", {type = rankModel.kRankTypeElemProgress, startRank = 1, id = self._planeId }, true, {}, function(result)
            self._viewMgr:showDialog("elemental.ElementalLayerRankView",{selectIndex = self._planeId}, true)
        end)
    end)


    local ruleBtn = self:getUI("menu.menuList.btnBg02")
    ruleBtn:setScaleAnim(true)
    self:registerClickEvent(ruleBtn, function()
        self._viewMgr:showDialog("global.GlobalRuleDescView",{desc = lang("planeRule")},true)
    end)

    local deliveryBtn = self:getUI("menu.menuList.btnBg03")
    deliveryBtn:setScaleAnim(true)
    self:registerClickEvent(deliveryBtn, function()
        self._viewMgr:showDialog("elemental.ElementalLevelSelectView", {planeId = self._planeId,enterType = 2,parent = self}, true)
    end)
end
--重载页面
function ElementalLayerView:reLoadUI(data)
    if data.item == self._planeId and self._layerNum == data.layerNum then return end
    self._planeId = data.item 
    self._layerNum = data.layerNum
    --切换位面时更新位面背景图片
    if self.__viewBg ~= nil then
        self.__viewBg:removeFromParent()
    end
    self.__viewBg = cc.Sprite:create("asset/bg/" .. loadInfo[self._planeId][1])
    self:addChild(self.__viewBg, -10)
    self:adjustBg()

    self:initOrder(data.serverData)
    self:updataUI()
    self:addProgressAni(false)
end


--从战斗返回刷新数据
function ElementalLayerView:backFormFightReloadUI()
    self._serverMgr:sendMsg("ElementServer", "getElementFirstData", {elementId = self._planeId,stageId = self._layerNum}, true, {}, function(result, errorCode)
        if errorCode ~= 0 then 
            errorCallback()
            self._viewMgr:unlock(51)
            return
        end
        self:initOrder(result)
        self:updataUI()
    end)
end

--进入布阵
function ElementalLayerView:enterFormation()
    local guildId = self._modelMgr:getModel("UserModel"):getData().guildId
    local enterFormationFunc = function(hireInfo,isShowHireTeam)
        -- dump(self._modelMgr:getModel("GuildModel"):getAllEnemyId(),"====getAllEnemyId====")
        local sysStage
        if self._planeId == 4 then
            -- 土元素特殊对待
            sysStage = clone(self._elementTable[self._planeId][self._layerNum])
            sysStage.m1 = {sysStage["n2"][1], 11}
        else
            sysStage = self._elementTable[self._planeId][self._layerNum]
        end
        local enemyFormation = IntanceUtils:initFormationData(sysStage)
        self._viewMgr:showView("formation.NewFormationView", {
            recommend = sysStage["commend"] or {},
            formationType = self._formationType[self._planeId],
            enemyFormationData = {[self._formationType[self._planeId]] = enemyFormation},
            heroes = heroes,
            extend = {
                hireTeams = hireInfo,
                isShowHireTeam = isShowHireTeam,
            },
            callback = 
                function(...)
                    local paramTable = {...}
                    self:enterFight(paramTable)
                end,
            closeCallback = 
                function(inIsNpcHero)
                end}
            )
    end
    local hireInfo = {}
    if not guildId or tonumber(guildId) == 0 then             --是否加入联盟
        enterFormationFunc(hireInfo,1)
    else
        local userLevel = self._modelMgr:getModel("UserModel"):getData().lvl
        local limitLevel = tab:SystemOpen("Lansquenet")[1]

        print("======userLevel=========="..userLevel)
        print("======limitLevel=========="..limitLevel)
        if tonumber(userLevel) < tonumber(limitLevel) then
            enterFormationFunc(hireInfo,2)
            return
        end
        self._serverMgr:sendMsg("GuildServer", "getMercenaryList", {}, true, {}, function(result, errorCode)
            if errorCode ~= 0 then 
                if errorCode == 2703 then
                    --更新联盟id
                    self._modelMgr:getModel("UserModel"):simulationGuildId()
                end
                self._viewMgr:unlock(51)
                return
            end
            hireInfo = self._modelMgr:getModel("GuildModel"):getAllEnemyId()
            enterFormationFunc(hireInfo,0)
        end)
    end
end

--进入战斗
function ElementalLayerView:enterFight(inLeftData)
    local guildId = self._modelMgr:getModel("UserModel"):getData().guildId
    self._formationData = inLeftData

    local param = {
                    elementId = self._planeId,
                    stageId = self._layerNum,
                    mercenaryUserId = inLeftData[8],
                    mercenaryId = inLeftData[7],
                    mercenaryPos = inLeftData[6]
                    }
    -- if guildId and tonumber(guildId) ~= 0 then
    --     param["mercenaryUserId"] = inLeftData[8]
    --     param["mercenaryId"] = inLeftData[7]
    --     param["mercenaryPos"] = inLeftData[6]
    -- end
    self._serverMgr:sendMsg("ElementServer", "atkBeforeElement", param, true, {}, function (result,errorCode)
        self._mercenaryId = inLeftData[7]
        self._userId = inLeftData[8]
        -- dump(result,"=====result=======")
        self._battleToken = result["token"]
        self._viewMgr:popView()
        if self._lockCallBack ~= nil then 
            self._lockCallBack(true)
        end
        BattleUtils.enterBattleView_Elemental(BattleUtils.jsonData2lua_battleData(result["atk"]), tonumber(self._planeId),tonumber(self._layerNum), function (info,callBack)
            self:battleCallBack(info,callBack)
        end,
        function (info)
            if self._battleWin == 1 then
                local function closePassView()
                    self:addProgressAni(true)
                    self:backFormFightReloadUI()
                end
                local isAllCross = false
                if self._layerNum == #self._elementTable[self._planeId] then
                    self._layerNum = #self._elementTable[self._planeId]
                    isAllCross = true
                else
                    self._layerNum = self._layerNum + 1
                end
                -- local isAllCross =  self._openLayerNum == #self._elementTable[self._planeId] and true or false
                -- self:backFormFightReloadUI()
                self._viewMgr:showDialog("elemental.ElementalPassView", {allCross = isAllCross,callBack = closePassView})
            else

            end
            if self._lockCallBack ~= nil then 
                self._lockCallBack(false)
            end
        end)
    end,
    function (errorCode)
        if errorCode == 7462 or errorCode == 7463 or errorCode == 7464
            or errorCode == 7465 or errorCode == 7466 then
            -- self._viewMgr:showTip(self:getOpenDes())
            self:lock()
            ScheduleMgr:delayCall(300, self, function( )
                self:unlock()
                self._viewMgr:popView()
                self:close()  
            end)
        elseif errorCode == 3120 or errorCode == 3121 or errorCode == 2703 or errorCode == 2742 then
            self:lock()
            ScheduleMgr:delayCall(400, self, function( )
                self:unlock()
                self._viewMgr:popView()
            end)
        end
    end)
end

function ElementalLayerView:battleCallBack(inResult,inCallBack)
    self._battleWin = 0
    if inResult == nil or inResult.isSurrender then 
        if self._lockCallBack ~= nil then 
            self._lockCallBack(false)
        end
        if inCallBack ~= nil then
            inCallBack(inResult)
        end
        return 
    end
    -- 配合战斗做的性能优化，支线战斗结束后重新加载地图
    -- self:setTexture(self:getBgName())
    -- self:setBgTexture()
    self._battleWin = 0
    if inResult.win ~= nil 
        and inResult.win == true then 
       self._battleWin = 1
    end


    local mySelfHp = math.ceil(inResult.hp[1] / inResult.hp[2] * 100)
    -- GuideUtils.saveIndex(GuideUtils.getNextBeginningIndex())

    local param = {stageId = self._layerNum,
                   elementId = self._planeId, 
        args = json.encode({
                    win = self._battleWin, 
                    time = inResult.time, 
                    dieCount = inResult.dieCount, 
                    serverInfoEx = inResult.serverInfoEx,
                    skillList = inResult.skillList,
                    hp = mySelfHp,
                    fId = self._formationType[self._planeId],
                    zzid = GameStatic.zzid6,
                }),
                token = self._battleToken}
    self._serverMgr:sendMsg("ElementServer", "atkAfterElement", param, true, {}, function (result)
        if result == nil then 
            self._battleWin = 0
            if inCallBack ~= nil then
                inCallBack({failed = true, __code = 5, extract = result["extract"]})
            end
            return             
        end
        if result["extract"] then 
            dump(result["extract"]["hp"], "battleCallBack", 10) 
            if result["extract"]["win"] == false then
                self._battleWin = 0
            end
        end
        self._elementModel:setCrossData(result)
        -- 向战斗层传送数据
        local resultData = clone(result)
        resultData["reward"] = {}
        if resultData["cheat"] == 1 then
            resultData.failed = true
        end
        if inCallBack ~= nil then
            resultData["mercenaryId"] = self._mercenaryId   --佣兵Id
            resultData["userId"] = self._userId
            inCallBack(resultData)
        end
    end, function (error)
        if error then
            self._battleWin = 0
            if inCallBack ~= nil then
                inCallBack({failed = true, __code = 8, __error = error})
            end
        end
    end)
end

-- 第一次进入调用, 有需要请覆盖
function ElementalLayerView:onShow()

end

-- 被其他View盖住会调用, 有需要请覆盖
function ElementalLayerView:onHide()

end

-- 刷新界面
function ElementalLayerView:reflashUI(data)

end

-- function ElementalLayerView:onTop()
--     print("==============onTop===========")
    
-- end

--进入动画
function ElementalLayerView:beforePopAnim()
    local titleBg = self:getUI("titleBg")
    if titleBg then
        titleBg:setOpacity(0)
    end
end

function ElementalLayerView:popAnim(callback)
    local titleBg = self:getUI("titleBg")
    if titleBg then
        ScheduleMgr:nextFrameCall(self, function()
            titleBg:stopAllActions()
            titleBg:setOpacity(255)
            local x, y = titleBg:getPositionX(), titleBg:getPositionY()
            titleBg:setPosition(x, y + 80)
            titleBg:runAction(cc.Sequence:create(
                cc.EaseOut:create(cc.MoveTo:create(0.1, cc.p(x, y - 5)), 3),
                cc.MoveTo:create(0.07, cc.p(x, y)),
                cc.CallFunc:create(function ()
                    self.__popAnimOver = true
                    if callback then callback() end
                end)
            ))
        end)
    else
        self.__popAnimOver = true
    end
end

--扫荡
function ElementalLayerView:onSweepLevel(stageId)
    local hasTimes = self._elementModel:getAllElementTimes()[self._planeId]
    if hasTimes == 0 then
        self._viewMgr:showTip("今天挑战次数已用完")
        return
    end
    self._serverMgr:sendMsg("ElementServer", "sweepElement", {elementId = self._planeId,stageId = stageId}, true, {}, function(result)
        if tolua.isnull(self._sweepView) then
            self._sweepView = self._viewMgr:showDialog("elemental.ElementSweepRewardView", {elementId = self._planeId,stageId = stageId, reward = result.reward, againCallBack = specialize(self.onSweepLevel, self)}) 
        else
            self._sweepView:reflashUI(result.reward)
        end
        self:setHasTimes()
    end)
end


function ElementalLayerView:getBgName()
    return loadInfo[self._planeId][1]
end

function ElementalLayerView:getAsyncRes()
    return 
    {
        {"asset/ui/pveIn.plist", "asset/ui/pveIn.png"},
        {"asset/ui/pveAiRen.plist", "asset/ui/pveAiRen.png"},
        {"asset/ui/pveZombie.plist", "asset/ui/pveZombie.png"},
        {"asset/ui/pveDragon.plist", "asset/ui/pveDragon.png"},
    }
end

return ElementalLayerView