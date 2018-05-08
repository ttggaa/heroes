--
-- Author: <ligen@playcrab.com>
-- Date: 2016-09-01 15:41:06
--
local CloudCityLevelSelectView = class("CloudCityLevelSelectView", BasePopView)

function CloudCityLevelSelectView:ctor(data)
    self.super.ctor(self)

    self.towerFloorTab = tab.towerFloor
    self.towerStageTab = tab.towerStage

    self._cModel = self._modelMgr:getModel("CloudCityModel")

    self.floorCellList = {}
    self.levelCellList = {}

    self._initFloor = data.curFloor
    self._initStage = data.curStage

    self._needShowBtnAni = data.needShowBtnAni

    -- 每层关卡数
    self._kLevelsPerFloor = 4
end

-- 初始化UI后会调用, 有需要请覆盖
function CloudCityLevelSelectView:onInit()
    self:registerClickEventByName("bg.layer.closeBtn", function()
        self:close()
        UIUtils:reloadLuaFile("cloudcity.CloudCityLevelSelectView")
    end )

    local title = self:getUI("bg.layer.titleBg.titleLabel")
    UIUtils:setTitleFormat(title, 1)

    self._floorScrollView = self:getUI("bg.layer.floorScrollView")
    self.levelView = self:getUI("bg.layer.bg3")
    self.levelView:setAnchorPoint(0.5,0.5)

    self._floorItem = self:getUI("bg.layer.floorItem")
    self._floorItem:setVisible(false)
    self._levelItem = self:getUI("bg.layer.levelItem")
    self._levelItem:setVisible(false)

    local timesTxt = self:getUI("bg.layer.timesTxt")
    timesTxt:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    timesTxt:setString("今日剩余次数:")

    self._maxTimes = tab:Setting("G_CLOUD_CITY_TIME").value
    local privilegesTimes = self._modelMgr:getModel("PrivilegesModel"):getPeerageEffect(PrivilegeUtils.peerage_ID.CloudCityTimes)
    if privilegesTimes and privilegesTimes > 0 then
        self._maxTimes = self._maxTimes + privilegesTimes
    end

    self.timesLabel = self:getUI("bg.layer.timesLabel")
    self.timesLabel:setColor(UIUtils.colorTable.ccColorQuality2)
    self.timesLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self.timesLabel:setString(self._cModel:getChallengeTimes() .. "/" .. self._maxTimes)

    self._tequanIcon = self:getUI("bg.layer.tequanIcon")
    self._tequanIcon:setVisible(privilegesTimes and privilegesTimes > 0)

    ----------------------- 初始化层按钮滚动窗    -----------------------
    local fOffsetX = 0
    local fOffsetY = -12
    local scrollViewWidth = self._floorScrollView:getContentSize().width
    local scrollViewHeight = self._floorScrollView:getContentSize().height
    local innerHeight = 0
    local cellHeight = 0
    local maxFloor = #self.towerFloorTab
    for i = 1, maxFloor do
        local fCell = self:createFloorCell(self.towerFloorTab[i])
        fCell:setAnchorPoint(0,0)
        cellHeight = fCell:getContentSize().height
        fCell:setPosition(fOffsetX, (cellHeight + fOffsetY) * (maxFloor - i))
        self._floorScrollView:addChild(fCell)
        table.insert(self.floorCellList, fCell)
        innerHeight = innerHeight + cellHeight + fOffsetY
    end
    self._floorScrollView:setInnerContainerSize(cc.size(scrollViewWidth, innerHeight + 16))

    if self._initFloor >= 7 then
        local scrollHeight = (cellHeight + fOffsetY) * (self._initFloor - 7) + 32
        local scollPercent = scrollHeight / (innerHeight - scrollViewHeight) * 100
        self._floorScrollView:scrollToPercentVertical(scollPercent, 0.05, false)
    end
    ----------------------- 初始化层按钮滚动窗 end -----------------------


    ----------------------- 初始化关卡Item -----------------------
    local lOffsetX = 303
    local lOffsetY = 469
    local lSpaceY = 1
    for j = 1, self._kLevelsPerFloor do
        local lCell = self:createLevelCell({lv = j})
        lCell:setPosition(lOffsetX, lOffsetY - (lSpaceY + lCell:getContentSize().height) * j)
        self.levelView:addChild(lCell)
        table.insert(self.levelCellList, lCell)
    end
    ----------------------- 初始化关卡Item  end -----------------------

    self:listenReflash("PlayerTodayModel", function()
        self.timesLabel:setString(self._cModel:getChallengeTimes() .. "/" .. self._maxTimes)
    end)
end

-- 创建层按钮（左侧）
function CloudCityLevelSelectView:createFloorCell(fData)
    local fCell = self._floorItem:clone()
    fCell:setVisible(true)
    fCell.normalBg = fCell:getChildByFullName("normalBg")
    fCell.selectBg = fCell:getChildByFullName("selectBg")
    fCell.lockBg = fCell:getChildByFullName("lockBg")
    fCell.floorLabel = fCell:getChildByFullName("floorLabel")
    fCell.floorLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    fCell.floorLabel:setString("第" .. fData.id .. "层")
--    fCell.floorLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    fCell.curIcon = fCell:getChildByFullName("curIcon")
    fCell.curIcon:getChildByFullName("Label_53"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    fCell.curIcon:getChildByFullName("Label_53"):setFontName(UIUtils.ttfName)
    fCell.lockIcon = fCell:getChildByFullName("lockIcon")
    fCell.lockIcon:setSaturation(-80)

    self:registerClickEvent(fCell, function()
        self:updateFloor(fData.id)
    end)

    return fCell
end

-- 创建关卡Item（右侧）
function CloudCityLevelSelectView:createLevelCell(lData)
    local lCell = self._levelItem:clone()
    lCell:setVisible(true)

    lCell:setAnchorPoint(0.5,0.5)

    lCell.levelLabel = lCell:getChildByFullName("levelLabel")
    lCell.levelLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    lCell.levelLabel:setString("第" .. lData.lv .. "关")
    lCell.rewardLabel = lCell:getChildByFullName("rewardLabel")
    lCell.rewardLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    lCell.rewardLabel:setString("奖励")
    lCell.itemBg = lCell:getChildByFullName("itemBg")
    lCell.unOpenIcon = lCell:getChildByFullName("unOpenIcon")
    lCell.line = lCell:getChildByFullName("line")

    lCell.rewardIconNode = lCell:getChildByFullName("rewardIconNode")

    lCell.curIcon = lCell:getChildByFullName("curIcon")
    lCell.curIcon:getChildByFullName("dangqian"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    lCell.curIcon:getChildByFullName("dangqian"):setFontName(UIUtils.ttfName)

    lCell.advanceBtn = lCell:getChildByFullName("advanceBtn")
    lCell.sweepBtn = lCell:getChildByFullName("sweepBtn")

    self:L10N_Text(lCell.advanceBtn)
    self:registerClickEvent(lCell.advanceBtn, function()
        self.actionCallBack({cType = "advanceStage", toFloor = self._curFloor, toStage = lData.lv})
        self:close()
    end)

    self:L10N_Text(lCell.sweepBtn)
    self:registerClickEvent(lCell.sweepBtn, function()
        self:onSweepLevel(self:getIdByFloorAndStage(self._curFloor, lData.lv))
    end)

    return lCell
end

function CloudCityLevelSelectView:reflashUI(data)
    self._uData = {curFloor = data.curFloor, curStage = data.curStage}
    self.actionCallBack = data.callback

    -- 通过的最高层
    local gotMaxFloor,_ = self:getFloorAndStageById(self._cModel:getAttainStageId())
    -- 所在层
    local curFloor = self._uData.curFloor
    for i = 1, #self.floorCellList do
        local floorData = self.towerFloorTab[i]
        if floorData.id <= gotMaxFloor then
            self.floorCellList[i].normalBg:setVisible(true)
            self.floorCellList[i].lockBg:setVisible(false)
            self.floorCellList[i].lockIcon:setVisible(false)
--            self.floorCellList[i]:setTouchEnabled(true)
            self.floorCellList[i].floorLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        else
--            self.floorCellList[i]:setTouchEnabled(false)
--            self.floorCellList[i].normalBg:setBrightness(-51)
            self.floorCellList[i].normalBg:setVisible(false)
            self.floorCellList[i].lockBg:setVisible(true)
            self.floorCellList[i].floorLabel:setColor(UIUtils.colorTable.ccUIBaseColor8)
        end

        if floorData.id == curFloor then
            self.floorCellList[i].selectBg:setVisible(true)
        end

        if floorData.id == gotMaxFloor then
            self.floorCellList[i].curIcon:setVisible(true)
        end
    end

    self:updateFloor(curFloor)
end

-- 切换层
function CloudCityLevelSelectView:updateFloor(changeFloor)
    if changeFloor == self._curFloor then
        return
    end
    -- 本层通过最高关
    local curMaxStage = 0
    local gotMaxFloor, gotMaxStage = self:getFloorAndStageById(self._cModel:getAttainStageId())

    if self.floorCellList[self._curFloor] ~= nil then
        if self._curFloor <= gotMaxFloor then
            self.floorCellList[self._curFloor].normalBg:setVisible(true)
        else
            self.floorCellList[self._curFloor].lockBg:setVisible(true)
        end
        self.floorCellList[self._curFloor].selectBg:setVisible(false)
    end

    self.floorCellList[changeFloor].selectBg:setVisible(true)
    self.floorCellList[changeFloor].lockBg:setVisible(false)
    self.floorCellList[changeFloor].normalBg:setVisible(false)


    self._curFloor = changeFloor

    if self._curFloor < gotMaxFloor then
        curMaxStage = 4
    elseif self._curFloor == gotMaxFloor then
        curMaxStage = gotMaxStage
    else
        curMaxStage = 0
    end

    -- 玩家所在关卡
    local curStage = self._uData.curStage
    local isFirstReward = false
    local isActivityOpen = self._cModel:isActivityOpen()
    for i = 1, self._kLevelsPerFloor do
        -- 重置关卡Item
        self.levelCellList[i].curIcon:setVisible(false)
        self.levelCellList[i].sweepBtn:setVisible(false)
        self.levelCellList[i].advanceBtn:setVisible(false)
        self:setLevelCellBright(self.levelCellList[i], true)
        self.levelCellList[i].rewardIconNode:removeAllChildren()

        local rewardConfig = nil
        if i <= curMaxStage then
            if i == gotMaxStage and gotMaxFloor == self._curFloor then
                local stageId = self:getIdByFloorAndStage(self._curFloor, i)
                if stageId == #tab.towerStage and self._cModel:getPassMaxStageId() == stageId then
                    self.levelCellList[i].sweepBtn:setVisible(true)
                else
                    self.levelCellList[i].advanceBtn:setVisible(true)
                end 
            else
                self.levelCellList[i].sweepBtn:setVisible(true)
            end

            self.levelCellList[i].unOpenIcon:setVisible(false)

            if i == self._initStage and self._curFloor == self._initFloor and self._needShowBtnAni then
                local mc1 = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true, false)
                mc1:setName("anim")
                mc1:setPosition(65, 30)
                self.levelCellList[i].sweepBtn:addChild(mc1, 1)
            else
                self.levelCellList[i].sweepBtn:removeChildByName("anim")
            end


            if i == gotMaxStage and self._curFloor == gotMaxFloor then
                self.levelCellList[i].curIcon:setVisible(true)
            end

            if i == curMaxStage and self._curFloor == gotMaxFloor and self._cModel:getAttainStageId() ~= self._cModel:getPassMaxStageId() then
                rewardConfig = self.towerStageTab[(self._curFloor - 1) * self._kLevelsPerFloor + i].firstReward
                isFirstReward = true
            else
                rewardConfig = self.towerStageTab[(self._curFloor - 1) * self._kLevelsPerFloor + i].reward
            end
        else
            rewardConfig = self.towerStageTab[(self._curFloor - 1) * self._kLevelsPerFloor + i].firstReward
            self.levelCellList[i].unOpenIcon:setVisible(true)
            isFirstReward = true
        end


        if rewardConfig ~= nil then
            local iconWidth = 80
            local offsetX = 10
            for rI = 1, #rewardConfig do
                local itemType = rewardConfig[rI][1]
                local itemId = nil
                local itemNum = nil
                if itemType == "tool" then
                    itemId = rewardConfig[rI][2]
                else 
                    itemId = IconUtils.iconIdMap[itemType]
                    itemNum = rewardConfig[rI][3]
                end
                local toolD = tab:Tool(tonumber(itemId))
                local rewardIcon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD, num = itemNum})
                rewardIcon:setScale(iconWidth / rewardIcon:getContentSize().width)
                rewardIcon:setPosition((rI - 1) * (iconWidth + offsetX) + 5, -2)
                self.levelCellList[i].rewardIconNode:addChild(rewardIcon)

                local iconColor = rewardIcon:getChildByName("iconColor")

                if itemType == "tool" then
                    local toolNum = 0

                    if rewardConfig[rI][4] ~= nil and rewardConfig[rI][3] ~= rewardConfig[rI][4] then
                        toolNum = rewardConfig[rI][3] .. "~" .. rewardConfig[rI][4]
                    else
                        toolNum = rewardConfig[rI][3]
                    end

                    local numLab =  ccui.Text:create()
                    numLab:setString("")
   	                numLab:setName("numLab")
                    numLab:setFontSize(20)
                    numLab:setFontName(UIUtils.ttfName)
                    numLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
                    numLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
                    numLab:setAnchorPoint(cc.p(1, 0))
                    numLab:setPosition(cc.p(rewardIcon:getContentSize().width - 8, 4))
                    numLab:setString(toolNum)
                    iconColor:addChild(numLab,11)
                end

                local iconDes = nil
                if isFirstReward then
                    iconDes = "首通"
                elseif isActivityOpen and itemType == "tool" then
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
        else
            print("towerStage需要配表")
        end

        if i > curMaxStage then
            self:setLevelCellBright(self.levelCellList[i], false)
        end
    end

end

-- 扫荡
function CloudCityLevelSelectView:onSweepLevel(stageId)
    if self._cModel:getChallengeTimes() == 0 then
        self:buyTimes()
        return
    end

    self._serverMgr:sendMsg("CloudyCityServer", "sweepCloudyCity", {stageId = stageId}, true, {}, function(result)
        if tolua.isnull(self._sweepView) then
            self._sweepView = self._viewMgr:showDialog("cloudcity.CloudCitySweepRewardView", {stageId = stageId, reward = result.reward, againCallBack = specialize(self.onSweepLevel, self)}) 
        else
            self._sweepView:reflashUI(result.reward)
        end

        if self.actionCallBack then
            self.actionCallBack({cType = "sweepStage"})
        end
        self.timesLabel:setString(self._cModel:getChallengeTimes() .. "/" .. self._maxTimes)
    end)
end

-- 购买次数
function CloudCityLevelSelectView:buyTimes()
    local gem = self._modelMgr:getModel("UserModel"):getData()["gem"]
    local buyTimes = self._modelMgr:getModel("PlayerTodayModel"):getData()["day41"]
    local vipLv = self._modelMgr:getModel("VipModel"):getData().level
    local costNum = tab:ReflashCost(buyTimes + 1)["costCloud"]

    if tab:Vip(vipLv)["buyCloud"] > buyTimes then
        DialogUtils.showBuyDialog({costNum = costNum,goods = "购买一次挑战次数",callback1 = function( )
            if costNum < gem then
                self._serverMgr:sendMsg("CloudyCityServer", "buyCloudyCityNum", {}, true, {}, function(result) 
                    self._viewMgr:showTip("购买成功")
                end)
            else
                DialogUtils.showNeedCharge({callback1=function( )
                    local viewMgr = ViewManager:getInstance()
                    viewMgr:showView("vip.VipView", {viewType = 0})
                end})
            end
        end})
    else
        self._viewMgr:showTip("挑战次数已用尽")
    end
end

-- 根据总的阶ID获得对应层数和本层阶数
function CloudCityLevelSelectView:getFloorAndStageById(stageId)
    return tab:TowerStage(stageId).floor, stageId % 4 == 0 and 4 or stageId % 4
end

-- 根据层数和对应阶数获得总的阶ID
function CloudCityLevelSelectView:getIdByFloorAndStage(floor, stage)
    return (floor - 1) * 4 + stage
end

function CloudCityLevelSelectView:setLevelCellBright(cell, isBright)
    cell.itemBg:setBrightness(isBright and 0 or -31)
    cell.line:setBrightness(isBright and 0 or -31)

    local cellList = cell:getChildByFullName("rewardIconNode"):getChildren() or {}
    for _, v in pairs(cellList) do
        self:setNodeColor(v, isBright and cc.c4b(255,255,255,255) or cc.c4b(128, 128, 128,255))
    end
end

-- 灰态
function CloudCityLevelSelectView:setNodeColor( node,color )
    if node:getName() == "bgMc" then return end
    if node and not tolua.isnull(node) then 
        if node:getDescription() ~= "Label" then
            node:setColor(color)
        else
            node:setBrightness(-30)
        end
    end
    local children = node:getChildren()
    if children == nil or #children == 0 then
        return 
    end
    for k,v in pairs(children) do
        self:setNodeColor(v,color)
    end
end

return CloudCityLevelSelectView