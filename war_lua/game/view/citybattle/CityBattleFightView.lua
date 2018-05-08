--[[
    Filename:    CityBattleFightView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-12-07 14:49:17
    Description: File description
--]]


local CityBattleUtils = CityBattleUtils
local updateDrawLeida = CityBattleUtils.updateDrawLeidaNew
local drawLeida = CityBattleUtils.drawLeidaNew
local zhenyingTable = CityBattleUtils.zhenyingTable
local heroSoloGroupTab = tab.heroSoloGroup

-- 血条背景  红蓝绿紫
local hpBgColorTab = {
    {hue = -180, saturation = 6, brightness = -26, contrast = 14, color = cc.c3b(0,255,115), opacity = 255},
    {hue = 26, saturation = 6, brightness = 6, contrast = 14, color = cc.c3b(0,202,255), opacity = 255},
    {hue = 26, saturation = 6, brightness = 6, contrast = 14, color = cc.c3b(0,255,115), opacity = 255},
    {hue = 133, saturation = 6, brightness = 6, contrast = 14, color = cc.c3b(0,255,115), opacity = 255},
}
-- 血条  红蓝绿紫
local hpColorTab = {
    {hue = 0, saturation = 0, brightness = 0, contrast = 24, color = cc.c3b(255,0,0), opacity = 255},
    {hue = 26, saturation = 6, brightness = 6, contrast = 14, color = cc.c3b(0,202,255), opacity = 255},
    {hue = 0, saturation = 0, brightness = -10, contrast = 24, color = cc.c3b(128,255,107), opacity = 255},
    {hue = 65, saturation = 6, brightness = -8, contrast = 34, color = cc.c3b(0,166,255), opacity = 255},
}
-- 雷达背景  红蓝绿紫
local radarBgColorTab = {
    {hue = 173, saturation = 14, brightness = 20, contrast = 56, color = cc.c3b(0,135,255), opacity = 255},
    {hue = -7, saturation = 8, brightness = 20, contrast = 56, color = cc.c3b(127,150,255), opacity = 255},
    {hue = -25, saturation = 12, brightness = 20, contrast = 56, color = cc.c3b(0,255,255), opacity = 255},
    {hue = 166, saturation = 20, brightness = 20, contrast = 56, color = cc.c3b(31,122,0), opacity = 255},
}
-- 雷达  红蓝绿紫
local radarColorTab = {
    {hue = 166, saturation = 20, brightness = 20, contrast = 56, color = cc.c3b(0,130,178), opacity = 255},
    {hue = -7, saturation = 8, brightness = 20, contrast = 46, color = cc.c3b(0,142,255), opacity = 255},
    {hue = -29, saturation = 12, brightness = 20, contrast = 56, color = cc.c3b(0,255,255), opacity = 255},
    {hue = 162, saturation = 2, brightness = 20, contrast = 56, color = cc.c3b(31,122,0), opacity = 255},
}
-- 文字背景  红蓝绿紫
local labBgColorTab = {
    {hue = 0, saturation = 0, brightness = 0, contrast = 24, color = cc.c3b(255,0,0), opacity = 255},
    {hue = 26, saturation = 6, brightness = 6, contrast = 14, color = cc.c3b(0,202,255), opacity = 255},
    {hue = 0, saturation = 0, brightness = -10, contrast = 24, color = cc.c3b(128,255,107), opacity = 255},
    {hue = 65, saturation = 6, brightness = -8, contrast = 14, color = cc.c3b(0,166,255), opacity = 255},
}

-- 区服icon 红蓝绿
local secIconTab = {
    "citybattle_view_temp6",
    "citybattle_view_temp8",
    "citybattle_view_temp7",
    "globalImageUI6_meiyoutu"
}

local CityBattleFightView = class("CityBattleFightView",BaseView)

function CityBattleFightView:ctor(param)
    CityBattleFightView.super.ctor(self)
    if not param then
        param = {}
    end
    self._cityId = param.cityId or 1
    -- dump(self._cityId)
    -- self._leftPerson = param.leftPerson
    -- self._rightPerson = param.rightPerson

    self._leftPerson = {} -- 进攻玩家
    self._rightPerson = {}  -- 防守玩家

    self._fightCurrent = nil -- 最新战斗数据
    self._leftCurPlayer = nil
    self._rightCurPlayer = nil
    
    self._reportList = {} -- 战报
    self._watchingReport = false

    self._isPlayingBattle = false

    self._isBattleAniming = false

    self._cellListL = {}
    self._cellListR = {}

end

function CityBattleFightView:setNoticeBar()
    self._viewMgr:hideNotice(true)
end

function CityBattleFightView:getAsyncRes()
    return {            
                {"asset/ui/citybattle.plist", "asset/ui/citybattle.png"},
                {"asset/ui/citybattle2.plist", "asset/ui/citybattle2.png"}
            }
end

function CityBattleFightView:getBgName()
    return "gvg_bg_1.jpg"
end

function CityBattleFightView:onBeforeAdd(callback, errorCallback)
--    self._serverMgr:sendMsg("CityBattleServer", "getCitybattleSoketData", {}, true, {}, function(result)

--        callback()
--    end)
    self._onBeforeAddCallback = function(inType)
        if inType == 1 then 
            callback()
        else
            errorCallback()
        end
    end

    self._serverMgr:RS_sendMsg("PlayerProcessor", "getRoomInfo", 
        {
            mapId = self._cModel:getMapId(),
            cid = self._cityId,
            rid = self._modelMgr:getModel("UserModel"):getRID()
        }
    )
end

function CityBattleFightView:onInit()

    self._cModel = self._modelMgr:getModel("CityBattleModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._secId = self._cModel:getCityDataById(self._cityId).b

    self._cityServerData = self._cModel:getCityServerList()
    self._serverNum = #self._cityServerData
    self._cityHPMax = tab:CityBattle(tonumber(self._cityId))["cityhp" .. self._serverNum]

    self._rId = self._modelMgr:getModel("UserModel"):getRID()

    self._occupyColorPlan = self._cModel:getData().c.co
    -- dump(self._occupyColorPlan)

    local closeBtn = self:getUI("bg.closeBtn")
    closeBtn:setScaleAnim(false)
    self:registerClickEvent(closeBtn, function()
        self:onClose()
        UIUtils:reloadLuaFile("citybattle.CityBattleFightView")
    end)

--    self._heroLeftCell = self:getUI("bg.heroLeftCell")
--    self._heroRightCell = self:getUI("bg.heroRightCell")

    local titleLabel = self:getUI("bg.titlePanel.titleName")
    titleLabel:setString(lang(tab:CityBattle(tonumber(self._cityId)).name))
    titleLabel:setColor(cc.c3b(255,255,128))
    titleLabel:enable2Color(1, cc.c4b(255, 157, 84,255))

    self._locationBtn = self:getUI("bg.titlePanel.locationNode.locationBtn")
    self:registerClickEvent(self._locationBtn, function()
        self:gamePlayerGPS()
    end)

    self._locationLab = self:getUI("bg.titlePanel.locationNode.lab")

    self._leftView = self:getUI("bg.titlePanel.leftView")
    self._rightView = self:getUI("bg.titlePanel.rightView")

    self._scrollViewL = self:getUI("bg.titlePanel.leftView.scrollView")
    self._scrollViewL:setClippingType(1)
    self._scrollViewR = self:getUI("bg.titlePanel.rightView.scrollView")
    self._scrollViewR:setClippingType(1)

    self._leftDown = self:getUI("bg.leftDown")
    self._rightDown = self:getUI("bg.rightDown")

    local leftLeida = self._leftDown:getChildByName("leidaBg2")
    self:registerClickEvent(leftLeida, function()
        self:showLeidaTips("left")
    end)

    local rightLeida = self._rightDown:getChildByName("leidaBg2")
    self:registerClickEvent(rightLeida, function()
        self:showLeidaTips("right")
    end)

    local downPanel = self:getUI("bg.downPanel")
    downPanel:setContentSize(MAX_SCREEN_WIDTH,  33)
    self._cityBloodImg = downPanel:getChildByFullName("cityHpProgress")
    self._cityBloodImg:setContentSize(MAX_SCREEN_WIDTH, 26)
    self._cityHpLab = downPanel:getChildByFullName("cityHpLab")
    self._cityHpLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._cityHpLab:setPositionX(MAX_SCREEN_WIDTH * 0.5)

    local sideImg = self:getUI("bg.downPanel.sideImg")
    sideImg:setContentSize(MAX_SCREEN_WIDTH, 6)
    sideImg:setPositionX(MAX_SCREEN_WIDTH * 0.5)

    -- 战报
    self._reportBtn = self:getUI("bg.infoPanel.infoBtn")
    self:registerClickEvent(self._reportBtn, function()
        self._reportBtn:setVisible(false)
        self._tableNode:setVisible(true)
    end)

    local reportLabel = cc.Label:createWithTTF("战\n况\n回\n顾", UIUtils.ttfName, 16)
    reportLabel:setContentSize(20, 80)
    reportLabel:setPosition(23, 67)
    reportLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    reportLabel:setLineHeight(16)
    self._reportBtn:addChild(reportLabel)

    self._reportHideBtn = self:getUI("bg.infoPanel.reportView.backBtn")
    self:registerClickEvent(self._reportHideBtn, function()
        self._reportBtn:setVisible(true)
        self._tableNode:setVisible(false)
    end)


    self:updateBulletBtnState()
--    self:showBullet()

    self._tableNode = self:getUI("bg.infoPanel.reportView")
    self._reportItem = self:getUI("bg.infoPanel.reportItem")
    self._tableCellW,self._tableCellH = self._reportItem:getContentSize().width,self._reportItem:getContentSize().height
    self:addTableView()
--    self:reflashUI()

    self:setOpenQuickDispatch()
    self:setListenReflashWithParam(true)
    self:listenReflash("CityBattleModel", self.onModelReflash)
    self:listenRSResponse(specialize(self.onSocektResponse, self))
end

function CityBattleFightView:onModelReflash(eventName)
    if self._watchingReport or self._isInBackGround then
        return
    end
    if eventName == "NewBattle" then  
        self:updateFightData()

    elseif eventName == "PersonRefresh" then
        self:onPersonRefresh()

    elseif eventName == "JoinCity" then 
        self:joinCityUpdate()

    elseif eventName == "LeaveCity" then 

        self:leaveCityUpdate()

    end
end

-- java服务器的response或者push接受
function CityBattleFightView:onSocektResponse(data)
    if data.error ~= nil then
        return
    end

    local status = 0
    local result = nil
    if data.status then
        status = data.status
    end

    if status == self._cModel.INIT_CITY_FIGHT then
        result = json.decode(data.result)
        if result then
            -- dump(result)
            self:reflashUI(result)
            self._cModel:setWatchCity(result.cid)
            self._onBeforeAddCallback(1)
        end
    end
end

function CityBattleFightView:reflashUI(data)
    self._cityHpLab:setString(string.format("城池耐久度  %d/%d", data.bl, self._cityHPMax))
    self._cityBloodImg:setContentSize(data.bl / self._cityHPMax * MAX_SCREEN_WIDTH, 26)
    local colorPlan = self._occupyColorPlan[data["b"]] or 4
    self._cityBloodImg:loadTexture(CityBattleUtils.cityhpImg[colorPlan], 1)

    self._myFormation = self._cModel:getMyCityFdata(self._cityId)
    -- dump(self._myFormation)
    self._leftPerson = data["ael"]
    self._rightPerson = data["del"]
    
    if not self._isBattleAniming then
        self:createLeftCards(data["ael"])
        self:createRightCards(data["del"])
    end
    self:createLeftCards(data["ael"])
    self:createRightCards(data["del"])

    self._atkNum = data["an"] or 0
    self._defNum = data["dn"] or 0

    self:updateLD(data["ael"])
    self:updateRD(data["del"])


    self:updateLocationBtn()

    self._reportList = data["br"]


    if self._reportList and  self._tableView then
        self._tableView:reloadData()
--        if offsetY then
--            self._tableView:setContentOffset(cc.p(offsetX,offsetY))
--        end
    end
end

-- 更新定位按钮状态
function CityBattleFightView:updateLocationBtn()
    -- 判断自己是否有兵团在本城
    local isExist = false
    for i = 1, #self._leftPerson do
        if self._leftPerson[i].rid == self._rId then
            isExist = true
        end
    end

    if not isExist then
        for i = 1, #self._rightPerson do
            if self._rightPerson[i].rid == self._rId then
                isExist = true
            end
        end
    end
    self._locationBtn:setTouchEnabled(isExist)
    self._locationLab:setVisible(isExist)
end

function CityBattleFightView:gamePlayerGPS()
    if self._cModel:getMineSec() == tonumber(self._secId) then
        for i = 1, #self._cellListR do
            local cell = self._cellListR[i]
            if cell.rid == self._rId then
                local posX = cell:getPositionX()
                local scrollDistance = math.max(0, posX - 235)
                local maxDistance = math.max(0, self._scrollViewR:getInnerContainerSize().width - self._scrollViewR:getContentSize().width)
                if maxDistance > 0 then
                    local percent = scrollDistance / maxDistance * 100
                    self._scrollViewR:scrollToPercentHorizontal(percent, 0.2, true)
                end
            end
        end
    else
        for i = 1, #self._cellListL do
            local cell = self._cellListL[i]
            if cell.rid == self._rId then
                local posX = cell:getPositionX()
                local scrollDistance = math.min(0, posX - (self._scrollViewL:getInnerContainerSize().width - 235))
                local maxDistance = math.max(0, self._scrollViewL:getInnerContainerSize().width - self._scrollViewL:getContentSize().width)
                if maxDistance > 0 then
                    local percent = 100 + scrollDistance / maxDistance * 100
                    self._scrollViewL:scrollToPercentHorizontal(percent, 0.2, true)
                end
            end
        end
    end

--    self._viewMgr:showDialog("citybattle.CityBattleFightResultView", {data = {
--        win = true,
--        atk = {name = "fdasfas", skin = "26010202"},
--        def = {name = "fdasfdasa", skin = "26010202"},
--        killCount = 5
--    }})
    

--    self:test()
end

-- 更新左下角进攻方数据
-- @param  data table 进攻方队列数据
function CityBattleFightView:updateLD(data)
    if self._radarBgL == nil then
        self._radarBgL = self:getUI("bg.leftDown.leidaBg2")
        self._labBgL = self:getUI("bg.leftDown.labBg")
        self._labL1 = self:getUI("bg.leftDown.lab1")
        self._labL1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    end

    if data and type(data) == "table" then
        if next(data) ~= nil then
            local atkNum = #data < 10 and #data or self._atkNum
            self._labL1:setString("进攻方 " .. atkNum .. "人")

            local curPlayer = data[1]
            local colorPlan = self._occupyColorPlan[curPlayer.sec]

            local radarBgColorData = colorPlan and radarBgColorTab[colorPlan] or radarBgColorTab[4]
            self:setViewColor(self._radarBgL, radarBgColorData)

            local radarColorData = colorPlan and radarColorTab[colorPlan] or radarBgColorTab[4]

            local labColorData = colorPlan and labBgColorTab[colorPlan] or labBgColorTab[4]
            self:setViewColor(self._labBgL, labColorData)

            local sec = curPlayer.sec
            if string.len(sec) == 0 then
                sec = nil
            end
            local radarLevels = self._cModel:getReadlyLevel(sec)
    --        dump(radarLevels, "leftLevels")
            if radarLevels then
--                radarLevels = {
--                    [1] = 10,
--                    [2] = 10,
--                    [3] = 10,
--                    [4] = 10,
--                    [5] = 10,
--                    [6] = 10,
--                }
            
                local panelCX = 66
                local panelCY = 180
                if not self._drawNodeL then
                    self._drawNodeL = drawLeida(radarLevels,panelCX,panelCY,6,6,32)
                else
                    updateDrawLeida(self._drawNodeL,radarLevels,panelCX,panelCY,6,6,32)
                end

                if not self._clipNodeL then
                    self._clipNodeL = cc.ClippingNode:create()   
                    self._clipNodeL:setContentSize(panelCX*2,panelCY*2)
                    self._clipNodeL:setStencil(self._drawNodeL)
                    self._leftDown:addChild(self._clipNodeL)
                end

                if not self._drawMaskL then
                    self._drawMaskL = cc.Sprite:createWithSpriteFrameName("citybattle_view_img76.png")
                    self._drawMaskL:setPosition(panelCX,panelCY)
                    self._drawMaskL:getTexture():setAntiAliasTexParameters()
    --                self._drawMaskL:setOpacity(180)
                    self._clipNodeL:addChild(self._drawMaskL)
                    self._clipNodeL:setInverted(false) 
                end
                self:setViewColor(self._drawMaskL, radarColorData)
            end
        else
            self._labL1:setString("进攻方 0人")
        end
    end
end

-- 更新右下角防守方数据
-- @param  data table 防守方队列数据
function CityBattleFightView:updateRD(data)
    if self._radarBgR == nil then
        self._radarBgR = self:getUI("bg.rightDown.leidaBg2")
        self._labBgR = self:getUI("bg.rightDown.labBg")
        self._labR1 = self:getUI("bg.rightDown.lab1")
        self._labR1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    end

    if data and type(data) == "table" then
        if next(data) ~= nil then
            local defNum = #data < 10 and #data or self._defNum
            self._labR1:setString("防守方 " .. defNum .. "人")

            local curPlayer = data[1]
            local colorPlan = self._occupyColorPlan[curPlayer.sec]

            local radarBgColorData = colorPlan and radarBgColorTab[colorPlan] or radarBgColorTab[2]
            self:setViewColor(self._radarBgR, radarBgColorData)

            local radarColorData = colorPlan and radarColorTab[colorPlan] or radarBgColorTab[2]

            local labColorData = colorPlan and labBgColorTab[colorPlan] or labBgColorTab[2]
            self:setViewColor(self._labBgR, labColorData)

            local sec = self._secId
            local radarLevels = self._cModel:getReadlyLevel(sec)
--            dump(radarLevels, "rightLevels")
            if radarLevels then
--                radarLevels = {
--                    [1] = 5,
--                    [2] = 6,
--                    [3] = 7,
--                    [4] = 8,
--                    [5] = 9,
--                    [6] = 10,
--                }
            
                local panelCX = 66
                local panelCY = 174
                if not self._drawNodeR then
                    self._drawNodeR = drawLeida(radarLevels,panelCX,panelCY,6,6,32)
                else
                    updateDrawLeida(self._drawNodeR,radarLevels,panelCX,panelCY,6,6,32)
                end

                if not self._clipNodeR then
                    self._clipNodeR = cc.ClippingNode:create()   
                    self._clipNodeR:setContentSize(panelCX*2,panelCY*2)
                    self._clipNodeR:setStencil(self._drawNodeR)
                    self._clipNodeR:setPositionX(269)
                    self._rightDown:addChild(self._clipNodeR)
                end

                if not self._drawMaskR then
                    self._drawMaskR = cc.Sprite:createWithSpriteFrameName("citybattle_view_img76.png")
                    self._drawMaskR:setPosition(panelCX,panelCY)
                    self._drawMaskR:getTexture():setAntiAliasTexParameters()
    --                self._drawMaskR:setOpacity(180)
                    self._clipNodeR:addChild(self._drawMaskR)
                    self._clipNodeR:setInverted(false) 
                end
                self:setViewColor(self._drawMaskR, radarColorData)
            end
        else
            self._labR1:setString("防守方 0人")
        end
    end
end

local cellWidth = 94
local cellSpace = -25
local maskWidth = 30 -- 减隐区宽度
function CityBattleFightView:createLeftCards(infos)
    if self._scrollViewL then
        self._scrollViewL:removeAllChildren()
        self._cellListL = {}
    end
    if infos ~= nil then
        local infoLen = #infos
        infoLen = math.max(5, infoLen)
        infoLen = math.min(10, infoLen)

        local showInfo = {}
        for i = 1, infoLen do
            table.insert(showInfo, infos[i])
        end

        -- 如果不在前十，添加自己编组信息
        if infoLen == 10 then
            for i = 1, #self._myFormation do
                if self._myFormation[i]["i"] > 10 and self._myFormation[i]["sec"] ~= self._secId then
                    table.insert(showInfo, self._myFormation[i])
                end
            end
        end
        infoLen = math.max(5, #showInfo)

        local innerContainer = self._scrollViewL:getInnerContainer()
        local containerWidth = (infoLen + 1) * cellWidth + infoLen * cellSpace + maskWidth
--        print("######################" .. containerWidth)
        local frontNode = cc.Node:create()
        frontNode:setContentSize(self._scrollViewL:getContentSize())
        local frontNodeWidth = frontNode:getContentSize().width
        frontNode:setPositionX(containerWidth - frontNodeWidth)
        self._scrollViewL:addChild(frontNode, 99)
        self._scrollViewL.frontNode = frontNode

        self._scrollViewL:setInnerContainerSize(cc.size(containerWidth, 112))
        for i = 1, infoLen do
            local cell = self:createCardCell(showInfo[i], true)

            if i <= 2 then
                cell:setPosition(frontNodeWidth - (cellWidth * i + (i - 1) * cellSpace) - maskWidth, 0)
                frontNode:addChild(cell, 6 - i)
            elseif i == 6 then
                cell:setPosition(frontNodeWidth - (cellWidth * (i+1) + i * cellSpace) - maskWidth, 0)
                frontNode:addChild(cell, 6 - i)
            else
                cell:setPosition(containerWidth - (cellWidth * (i+1) + i * cellSpace) - maskWidth, 0)
                self._scrollViewL:addChild(cell, infoLen - i)
            end
            table.insert(self._cellListL, cell)
        end

        local divideIcon = cc.Sprite:createWithSpriteFrameName("citybattle_view_img31.png")
        divideIcon:setPosition(frontNodeWidth-(cellWidth * 2 + (2) * cellSpace) - maskWidth - 43, 53)
        frontNode:addChild(divideIcon, 99)
    end

    self._scrollViewL:jumpToRight()
end

function CityBattleFightView:sortScrollViewL()
    local frontNode = self._scrollViewL.frontNode
    local frontNodeWidth = frontNode:getContentSize().width
    local cellLen = #self._cellListL

    local containerWidth = (cellLen + 1) * cellWidth + cellLen * cellSpace + maskWidth
    containerWidth = containerWidth < frontNodeWidth and frontNodeWidth or containerWidth
    for i = 1, cellLen do
        local cell = self._cellListL[i]
        cell:retain()
        cell:removeFromParent()
        if i <= 2 then
            cell:setPosition(frontNodeWidth - (cellWidth * i + (i - 1) * cellSpace) - maskWidth, 0)
            frontNode:addChild(cell, 6 - i)
        elseif i == 6 then
            cell:setPosition(frontNodeWidth - (cellWidth * (i+1) + i * cellSpace) - maskWidth, 0)
            frontNode:addChild(cell, 6 - i)
        else
            cell:setPosition(containerWidth - (cellWidth * (i+1) + i * cellSpace) - maskWidth, 0)
            self._scrollViewL:addChild(cell, cellLen - i)
        end
        cell:release()
    end

    self._scrollViewL:setInnerContainerSize(cc.size(containerWidth, 112))
    frontNode:setPositionX(containerWidth - frontNodeWidth)
    self._scrollViewL:jumpToRight()
end


function CityBattleFightView:createRightCards(infos)
    if self._scrollViewR then
        self._scrollViewR:removeAllChildren()
        self._cellListR = {}
    end
    if infos ~= nil then
        local infoLen = #infos
        infoLen = math.max(5, infoLen)
        infoLen = math.min(10, infoLen)

        local showInfo = {}
        for i = 1, infoLen do
            table.insert(showInfo, infos[i])
        end

        -- 如果不在前十，添加自己编组信息
        if infoLen == 10 then
            for i = 1, #self._myFormation do
                if self._myFormation[i]["i"] > 10 and self._myFormation[i]["sec"] == self._secId then
                    table.insert(showInfo, self._myFormation[i])
                end
            end
        end
        infoLen = math.max(5, #showInfo)

        local innerContainer = self._scrollViewR:getInnerContainer()
        local containerWidth = (infoLen + 1) * cellWidth + infoLen * cellSpace + maskWidth
--        print("######################" .. containerWidth)

        self._scrollViewR:setInnerContainerSize(cc.size(containerWidth, 112))
        for i = 1, infoLen do
            local cell = self:createCardCell(showInfo[i], false)
            self._scrollViewR:addChild(cell, infoLen - i)

            if i <= 2 then
                cell:setPosition((cellWidth * (i - 1) + (i - 1) * cellSpace) + maskWidth, 0)
            else
                cell:setPosition((cellWidth * i + i * cellSpace) + maskWidth, 0)
            end
            table.insert(self._cellListR, cell)
        end

        local divideIcon = cc.Sprite:createWithSpriteFrameName("citybattle_view_img29.png")
        divideIcon:setPosition((cellWidth * 2 + 2 * cellSpace) + maskWidth + 43, 53)
        self._scrollViewR:addChild(divideIcon, 99)
    end
end

function CityBattleFightView:sortScrollViewR()
    local cellLen = #self._cellListR
    for i = 1, cellLen do
        local cell = self._cellListR[i]
        if i <= 2 then
            cell:setPosition((cellWidth * (i - 1) + (i - 1) * cellSpace) + maskWidth, 0)
        else
            cell:setPosition((cellWidth * i + i * cellSpace) + maskWidth, 0)
        end
        cell:getParent():reorderChild(cell, cellLen - i)
    end

    local containerWidth = (cellLen + 1) * cellWidth + cellLen * cellSpace + maskWidth
    local scrollViewWidth = self._scrollViewR:getContentSize().width
    containerWidth = containerWidth < scrollViewWidth and  scrollViewWidth or containerWidth
    self._scrollViewR:setInnerContainerSize(cc.size(containerWidth, 112))
end

function CityBattleFightView:createCardCell(data, isLeft)
    local cell = ccui.Layout:create()
    cell:setContentSize(94, 112)
    cell:setCascadeOpacityEnabled(true)
    cell:setTouchEnabled(true)
    cell:setSwallowTouches(false)


--    cell:setBackGroundColor(cc.c3b(0, 0, 0))
--    cell:setBackGroundColorOpacity(255)
--    cell:setBackGroundColorType(1)

    if data == nil then
        local backBg = cc.Sprite:createWithSpriteFrameName("citybattle_view_img74.png")
        backBg:setPosition(47, 56)
        backBg:setFlippedX(not isLeft)
        cell:addChild(backBg)

        local backBg2 = cc.Sprite:createWithSpriteFrameName("citybattle_view_img80.png")
        backBg2:setPosition(49, 56)

        local clipNode = cc.ClippingNode:create()
        clipNode:setPosition(0,0)
        local mask = cc.Sprite:createWithSpriteFrameName("citybattle_view_img74.png")
        mask:setPosition(47, 56)
        mask:setFlippedX(not isLeft)
    --    clipNode:setInverted(true)
        clipNode:setStencil(mask)
        clipNode:setAlphaThreshold(0.5)
        clipNode:addChild(backBg2)
        clipNode:setCascadeOpacityEnabled(true)
        cell:addChild(clipNode)
    else
        self:addClickTouchEvent(cell, function()
            if data.sec == "" or data.sec == "npc" then
                self._viewMgr:showTip(lang("CITYBATTLE_TIP_37"))
                return
            end
            local param = {id = data.rid, sec = data.sec, fid = data.fid}
            self._serverMgr:sendMsg("CityBattleServer", "getInfo", param, true, {}, function(result) 
--                dump(result)
                local data1 = result
                data1.serverNum = data.sec
                self._viewMgr:showDialog("citybattle.DialogCityBattleUserInfo", data1, true)
            end)
        end)

        cell.rid = data.rid
        cell.fid = data.fid

        local flippedNode = ccui.Layout:create()
        flippedNode:setContentSize(94, 112)
        flippedNode:setFlippedX(not isLeft)
        flippedNode:setPositionX(isLeft and 0 or cellWidth)
        flippedNode:setCascadeOpacityEnabled(true)
        cell:addChild(flippedNode)

        local clipNode = cc.ClippingNode:create()
        clipNode:setPosition(0,0)
        local mask = cc.Sprite:createWithSpriteFrameName("citybattle_view_img74.png")
        mask:setPosition(47, 56)
    --    clipNode:setInverted(true)
        clipNode:setStencil(mask)
        clipNode:setAlphaThreshold(0.5)
        clipNode:setCascadeOpacityEnabled(true)
        flippedNode:addChild(clipNode)

        local heroPic = cc.Sprite:create("asset/uiother/dhero/" .. tab:Hero(data.hid)["heromp"] .. ".jpg")
        heroPic:setFlippedX(true)
        heroPic:setPosition(47, 56)
        heroPic:setScale(0.5)
        clipNode:addChild(heroPic)

        local goldBound = cc.Sprite:createWithSpriteFrameName("citybattle_view_img75.png")
        goldBound:setPosition(28, 56)
        flippedNode:addChild(goldBound)

        local numBg = cc.Sprite:createWithSpriteFrameName("citybattle_view_img67.png")
        numBg:setPosition(27, 99)
        flippedNode:addChild(numBg)

        
        local numLab = ccui.Text:create(tostring(data["i"]), UIUtils.ttfName, 20)
        numLab:setScaleX(isLeft and 1 or -1)
        numLab:setPosition(14, 13)
        numLab:setColor(cc.c3b(254, 249, 217))
        numLab:enable2Color(1, cc.c4b(255, 237, 145, 255))
        numBg:addChild(numLab)
        numBg:setCascadeOpacityEnabled(true)
        cell.numLab = numLab

        local bloodNode = cc.Node:create()
        flippedNode:addChild(bloodNode)
        bloodNode:setCascadeOpacityEnabled(true)
        cell.bloodNode = bloodNode

        for i = 1, 8 do
            local hpImg = nil
            local hpColorData = nil
            local colorPlan = self._occupyColorPlan[data.sec] or 4
            cell.colorPlan = colorPlan
            if i <= data.bl then
                hpColorData = hpColorTab[colorPlan]
                hpImg = cc.Sprite:createWithSpriteFrameName("citybattle_view_img77.png")
            else
                hpColorData = hpBgColorTab[colorPlan]
                hpImg = cc.Sprite:createWithSpriteFrameName("citybattle_view_img78.png")
            end

            self:setViewColor(hpImg, hpColorData)
            hpImg:setPosition((8 - i) * (hpImg:getContentSize().width - 3) + 10, hpImg:getContentSize().height * 0.5 + 3)
            bloodNode:addChild(hpImg)
        end

        if data.rid == self._rId and tonumber(data["i"]) > 2 then
            local exitBtn = ccui.Button:create("citybattle_view_img43.png", "citybattle_view_img43.png", "citybattle_view_img43.png", 1)
            exitBtn:setScaleAnim(true)
            cell:addChild(exitBtn, 99)
            cell.exitBtn = exitBtn

            self:registerClickEvent(exitBtn, function()
                self:leaveRoom(data.fid)
            end)

            if isLeft then
                exitBtn:setPosition(40, 30)
            else
                exitBtn:setPosition(55, 30)
            end
        end
    end
    return cell
end

function CityBattleFightView:updateCell(cell, data)
    if cell.bloodNode then
        cell.bloodNode:removeAllChildren()
        for i = 1, 8 do
            local hpImg = nil
            local hpColorData = nil
            local colorPlan = cell.colorPlan
            if i <= data.bl then
                hpColorData = hpColorTab[colorPlan]
                hpImg = cc.Sprite:createWithSpriteFrameName("citybattle_view_img77.png")
            else
                hpColorData = hpBgColorTab[colorPlan]
                hpImg = cc.Sprite:createWithSpriteFrameName("citybattle_view_img78.png")
            end

            self:setViewColor(hpImg, hpColorData)
            hpImg:setPosition((8 - i) * (hpImg:getContentSize().width - 3) + 10, hpImg:getContentSize().height * 0.5 + 3)
            cell.bloodNode:addChild(hpImg)
        end
    end

    if cell.numLab then
        cell.numLab:setString(tostring(data["i"]))
    end
    if cell.exitBtn and tonumber(data["i"]) <= 2 then
        cell.exitBtn:setVisible(false)
    end
end


function CityBattleFightView:setViewColor(view, colorData)
    view:setHue(colorData.hue)
    view:setSaturation(colorData.saturation)
    view:setBrightness(colorData.brightness)
    view:setContrast(colorData.contrast)
    view:setColor(colorData.color)
    view:setOpacity(colorData.opacity)
end

function CityBattleFightView:onShow()
    self._scrollViewL:jumpToRight()
    self:showBullet()

    self:showLoadingAni(true)
end

-- 显示战斗等待动画
local strList = {"", ".", "..", "..."}
function CityBattleFightView:showLoadingAni(bool)
    if bool then
        if self._aniBg == nil then
            self._aniBg = cc.Sprite:createWithSpriteFrameName("citybattle_view_img87.png")
            self._aniBg:setPosition(127, 87)
            self._aniBg:setScale(0)
            self:getUI("bg.aniNode"):addChild(self._aniBg)

            local label = cc.Label:createWithTTF("战斗即将开始", UIUtils.ttfName, 48)
            label:setPosition(340, 37)
            label:setColor(cc.c3b(255,255,242))
            label:enable2Color(1, cc.c4b(255,227,113,255))
            label:enableShadow(cc.c4b(0,0,0,255))
            self._aniBg:addChild(label)

            self._aniLabel = cc.Label:createWithTTF("...", UIUtils.ttfName, 48)
            self._aniLabel:setPosition(480, 37)
            self._aniLabel:setAnchorPoint(0, 0.5)
            self._aniLabel:setColor(cc.c3b(255,255,242))
            self._aniLabel:enable2Color(1, cc.c4b(255,227,113,255))
            self._aniLabel:enableShadow(cc.c4b(0,0,0,255))
            self._aniBg:addChild(self._aniLabel)
        end

        self._strIndex = 0
        self._aniBg:runAction(cc.Sequence:create(
            cc.ScaleTo:create(0.1, 1),
            cc.CallFunc:create(function()
                
                local dtTime = 0
                self._Labeltimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
                    dtTime = dtTime + dt
                    if dtTime > 0.5 then
                        self._strIndex = self._strIndex + 1
                        self._strIndex = self._strIndex > 4 and 1 or self._strIndex
                        self._aniLabel:setString(strList[self._strIndex])
                        dtTime = 0
                    end
                end, 0, false)
            end)
       ))

    else
        if self._Labeltimer then
            ScheduleMgr:unregSchedule(self._Labeltimer)
            self._Labeltimer = nil
        end

        if self._aniBg then
            self._aniBg:runAction(cc.ScaleTo:create(0.1, 0))
        end
    end
end

function CityBattleFightView:onTop()
    self._watchingReport = false

    self:continuePlay()
end

function CityBattleFightView:applicationDidEnterBackground()
    self._isInBackGround = true

    self:resetFight()
end

function CityBattleFightView:applicationWillEnterForeground(second)
    self._isInBackGround = false

    self:continuePlay()
end

-- 清空战场
function CityBattleFightView:resetFight()
    if self._solo then
        self._solo:clear()

        self._fightCurrent = nil
        self._atkFormation = nil
        self._defFormation = nil
        self._isBattleAniming = false
    end
end

function CityBattleFightView:continuePlay()
    self:setScreenGray(false)
    self._fightCurrent = nil

    local data = self._cModel:getCityData()
    if data == nil then return end

    self:createLeftCards(data["leftPerson"])
    self:createRightCards(data["rightPerson"])

    self._leftPerson = clone(data["leftPerson"])
    self._rightPerson = clone(data["rightPerson"])

    self:updateLD(data["leftPerson"])
    self:updateRD(data["rightPerson"])

    self._reportList = clone(data["reportList"])

    if self._reportList and  self._tableView then
        self._tableView:reloadData()
    end

    if data["finalDesStr"] ~= nil then
        self:showOverDialog(data["finalDesStr"])
    end
end

-- 更新战斗结果
function CityBattleFightView:updateFightData()
    local newData = self._cModel:getCityBattleData()
    local leftDataNew = newData["playerInfo"][1]
    local rightDataNew = newData["playerInfo"][2]
    local leftDataOld = self:getPlayerById(leftDataNew.rid, true)
    local rightDataOld = self:getPlayerById(rightDataNew.rid, false)

    -- 更新战斗序列
    local fightData = {}
    fightData["cityData"] = newData["cityData"]
    fightData["win"] = newData["isWin"]
    fightData["tie"] = leftDataNew["i"] == -1 and rightDataNew["i"] == -1 --平局 或 一方零血险胜
    fightData["reportKey"] = newData["reportKey"]
    fightData["solo"] = 5
    fightData["killCount"] = fightData["win"] and leftDataNew.kc or rightDataNew.kc
    fightData["csec"] = newData["csec"]

    if leftDataOld ~= nil then
        fightData["atkFormation"] = clone(leftDataNew)
        fightData["atkFormation"].i = 1
        fightData["atkFormation"].bl = leftDataOld.bl
        fightData["defFormation"] = clone(rightDataNew)
        fightData["defFormation"].i = 1
        fightData["defFormation"].bl = rightDataOld and rightDataOld.bl or 8
        if self._atkFormation == nil then
            self._atkFormation = fightData["atkFormation"]
        end
        if self._defFormation == nil then
            self._defFormation = fightData["defFormation"]
        end
    end

    local atkData = {}
    local defData = {}
    fightData["atk"] = atkData
    fightData["def"] = defData

    atkData["heroId"] = leftDataNew.hid
    atkData["after"] = leftDataNew.bl
    atkData["name"] = leftDataNew.n
    atkData["color"] = self._occupyColorPlan[leftDataNew.sec] or 4
    atkData["sec"] = leftDataNew.sec
    atkData["skin"] = leftDataNew.sk

    defData["heroId"] = rightDataNew.hid
    defData["before"] = rightDataOld and rightDataOld.bl or 8
    defData["after"] = rightDataNew.bl
    defData["name"] = rightDataNew.n == "" and "中立守卫" or rightDataNew.n
    defData["color"] = self._occupyColorPlan[rightDataNew.sec] or 4
    defData["sec"] = rightDataNew.sec
    defData["skin"] = rightDataNew.sk

    self._atkNum = newData.cityData["an"]
    self._defNum = newData.cityData["dn"]

    self._fightCurrent = fightData
    self:updatePersonList(newData)

    self:addReport(fightData)

    -- 开战前进入战场观战，没有进攻方初始数据
    if leftDataOld == nil then
        return
    end

    atkData["before"] = leftDataOld.bl

    -- dump(fightData)

    if not self._isPlayingBattle then
        if not self._isBattleAniming then
            self:playFight()
        end
    end
end

function CityBattleFightView:onPersonRefresh()
    local newData = self._cModel:getCityPersonData()
    -- dump(newData)
    self._atkNum = newData["an"]
    self._defNum = newData["dn"]

    self:updatePersonList(newData)
end

function CityBattleFightView:updatePersonList(newData)
    local isChange = self._fightCurrent ~= nil and self._fightCurrent.csec == 1

    self._myFormation = self._cModel:getMyCityFdata(self._cityId)

    -- 更新双方玩家队列
    if newData["atkf"] and not isChange then
        local atkfData = newData["atkf"]

        local newAtkf = clone(atkfData)
        if self._atkFormation ~= nil then
            if #newAtkf == 0 
                or self._atkFormation.rid ~= newAtkf[1].rid 
                or self._atkFormation.fid ~= newAtkf[1].fid 
            then
                table.insert(newAtkf, 1, self._atkFormation)
                for i = 2, #newAtkf do
                    newAtkf[i]["i"] = i
                end
                    
            elseif #newAtkf > 0 then
                newAtkf[1] = self._atkFormation
            end
        end

        self._leftPerson = newAtkf
    end

    if newData["deff"] then
        if isChange then
            self._rightPerson = {self._defFormation}
        else
            local deffData = newData["deff"]

            local newDeff = clone(deffData)
            if self._defFormation ~= nil then
                if #newDeff == 0 
                    or self._defFormation.rid ~= newDeff[1].rid 
                    or self._defFormation.fid ~= newDeff[1].fid 
                then
                    table.insert(newDeff, 1, self._defFormation)
                    for i = 2, #newDeff do
                        newDeff[i]["i"] = i
                    end

                elseif #newDeff > 0 then
                    newDeff[1] = self._defFormation
                end
            end

            self._rightPerson = newDeff

        end
    end

    self:createLeftCards(self._leftPerson)
    self:createRightCards(self._rightPerson)

    self:updateLD(self._leftPerson)
    self:updateRD(self._rightPerson)

    self:updateLocationBtn()
end

function CityBattleFightView:getPlayerById(id, isLeft)
    local playerList = nil
    if isLeft then
        playerList = self._leftPerson
    else
        playerList = self._rightPerson
    end
    for k, data in pairs(playerList) do
        if tostring(data.rid) == tostring(id) then
            return data
        end
    end
end

-- 播放本场战斗结果
function CityBattleFightView:playFight()
    if self._fightCurrent ~= nil then
        self:showLoadingAni(false)
        self:fightPanel()
    else
        self._isPlayingBattle = false
    end
end

function CityBattleFightView:playFightOver()
    local data = self._fightCurrent
    if data == nil then
        return
    end

    local overCallBack = function()
        if #self._leftPerson == 0 then
            if self._secId == "npc" then
                self:showOverDialog("中立守卫 防守成功")
            else
                self:showOverDialog(self._cModel:getServerName(self._secId) .. " ".. data.def.name .. " 防守成功")
            end

        elseif #self._rightPerson == 0 then
            self:showOverDialog("恭喜 ".. self._cModel:getServerName(data.atk.sec) .. " ".. data.atk.name .. " 进攻成功")
        end

        self._fightCurrent = nil
        self._atkFormation = nil
        self._defFormation = nil
        self._isBattleAniming = false
    end

    self:updateLeftCards(data, function()
        self:updateLD(self._leftPerson)

        overCallBack()
    end)

    self:updateRightCards(data, function()
        self:updateRD(self._rightPerson)

        overCallBack()
    end)

    if data.killCount and data.killCount >= 3 then
        self._viewMgr:showDialog("citybattle.CityBattleFightResultView", {data = data})
    end

    self._solo:walkLeave(nil, specialize(self.playFight, self))

    if data.win then
        if tonumber(data.def.sec) == self._cModel:getMineSec() then
            self:setScreenGray(true)
        end
    else
        if tonumber(data.atk.sec) == self._cModel:getMineSec() then
            self:setScreenGray(true)
        end
    end

    -- 更新城池信息
    self._cityHpLab:setString(string.format("城池耐久度  %d/%d", data.cityData.bl, self._cityHPMax))
    self._cityBloodImg:setContentSize(data.cityData.bl / self._cityHPMax * MAX_SCREEN_WIDTH, 26)

--    self:addReport(data)
end

-- 屏幕置灰
function CityBattleFightView:setScreenGray(bool)
    if bool then
        self:setSaturation(-50)
    else
        self:setSaturation(0)
    end
end


-- 显示战斗结束
function CityBattleFightView:showOverDialog(desStr)

    self._cModel:resetCityData()

    self._viewMgr:showDialog("global.GlobalOkDialog", {
        desc = desStr,
        button = "确定",
        title = "战斗结束",
        callback = function()
            self:onClose()
        end}, true)
end

-- 增加战报数据
function CityBattleFightView:addReport(data)
    local reportData = {}
    reportData["aname"] = data.atk.name
    reportData["asec"] = data.atk.sec
    reportData["dname"] = data.def.name
    reportData["dsec"] = data.def.sec
    reportData["win"] = data.win
    reportData["bk"] = data.reportKey

    table.insert(self._reportList, 1, reportData)
    if #self._reportList > 10 then
        table.remove(self._reportList, 11)
    end
    self._tableView:reloadData()
end

-- 玩家进入城池更新玩家信息
function CityBattleFightView:joinCityUpdate()
    local newData = self._cModel:getJoinCityData()
    -- dump(newData)
    for k, v in pairs(newData["df"]) do
        if tostring(v) == tostring(self._cityId) then
            self:leaveCityUpdate({rid = newData.rid, fid = k})
        end
    end

    local newFormation = {}
    for kF, vF in pairs(newData["f"]) do
        vF.fid = kF
        table.insert(newFormation, vF)
    end

    table.sort(newFormation, function(a,b)
        return tonumber(a["i"]) < tonumber(b["i"])
    end)

    for i = 1, #newFormation do
        local v = newFormation[i]
        if tostring(v.cid) == tostring(self._cityId) then
            v.rid = newData.rid
            -- 不是本城所属区服则属于攻击方
            if v.sec ~= self._secId then
                local personNum = #self._leftPerson
                local cell = self:createCardCell(v, true)
                if personNum < 5 then
                    self._cellListL[personNum + 1]:removeFromParent(true)
                    table.remove(self._cellListL, personNum + 1)
                    table.insert(self._cellListL, personNum + 1, cell)
                else
                    table.insert(self._cellListL, cell)
                end
                self._scrollViewL:addChild(cell)
                table.insert(self._leftPerson, v)
            else
                local personNum = #self._rightPerson
                local cell = self:createCardCell(v, false)
                if personNum < 5 then
                    self._cellListR[personNum + 1]:removeFromParent(true)
                    table.remove(self._cellListR, personNum + 1)
                    table.insert(self._cellListR, personNum + 1, cell)
                else
                    table.insert(self._cellListR, cell)
                end
                self._scrollViewR:addChild(cell)
                table.insert(self._rightPerson, v)
            end
        end
    end
    self:sortScrollViewL()
    self:sortScrollViewR()
end

function CityBattleFightView:leaveCityUpdate(lData)
    local leaveRid = nil
    local leaveFid = nil
    if lData == nil then
        local newData = self._cModel:getLeaveCityData()
        leaveRid = newData.rid

        for k, v in pairs(newData.f) do
            leaveFid = k
        end
    else
        leaveRid = lData.rid
        leaveFid = lData.fid
    end
    local leaveIndex = 0
    for i = 1, #self._cellListL do
        local pCell = self._cellListL[i]
        if pCell.rid == leaveRid and pCell.fid == leaveFid then
            leaveIndex = i
        end

        if leaveIndex ~= 0 and i > leaveIndex then
            local data = self._leftPerson[i]
            if data then
                data["i"] = data["i"] - 1
                self:updateCell(pCell, data)
            end
        end
    end

    if leaveIndex > 0 then
        self:cardRemove(leaveIndex, true)
    else
        for i = 1, #self._cellListR do
            local pCell = self._cellListR[i]
            if pCell.rid == leaveRid and pCell.fid == leaveFid then
                leaveIndex = i
            end

            if leaveIndex ~= 0 and i > leaveIndex then
                local data = self._rightPerson[i]
                if data then
                    data["i"] = data["i"] - 1
                    self:updateCell(pCell, data)
                end
            end
        end

        if leaveIndex > 0 then
            self:cardRemove(leaveIndex, false)
        end
    end
end

function CityBattleFightView:cardRemove(index, isLeft)
    if isLeft then
        self._cellListL[index]:removeFromParent(true)
        table.remove(self._cellListL, index)
        table.remove(self._leftPerson, index)
        self:sortScrollViewL()
        self:updateLD(self._leftPerson)
    else
        self._cellListR[index]:removeFromParent(true)
        table.remove(self._cellListR, index)
        table.remove(self._rightPerson, index)
        self:sortScrollViewR()
        self:updateRD(self._rightPerson)
    end
end

function CityBattleFightView:updateLeftCards(battleData, callBack)
    -- 进攻方战胜
    local curplayer = self._cellListL[1]
    if battleData["win"] == true and not battleData["tie"] then
        local curData = self._leftPerson[1]
        curData["bl"] = battleData["atk"].after
        self:updateCell(curplayer, curData)
    else
        self._scrollViewL:stopScroll()
        self:cardsDisappear(curplayer, function()
            curplayer:removeFromParent(true)
            table.remove(self._cellListL, 1)
            table.remove(self._leftPerson, 1)

            if callBack then 
                callBack()
            end

            for i = 1, #self._cellListL do
                local data = self._leftPerson[i]
                if data then
                    data["i"] = i
                    self:updateCell(self._cellListL[i], data)
                end
            end

            local frontNode = self._scrollViewL.frontNode
            self:changeParent(frontNode, self._leftView)
            frontNode:setPosition(0, 0)

            local frontNodeWidth = frontNode:getContentSize().width

            for i = 1, #self._cellListL do
                local cell = self._cellListL[i]

                if i < 2 then
                    cell:runAction(cc.MoveBy:create(0.1, cc.p(cellWidth + cellSpace, 0)))
                    cell:getParent():reorderChild(cell, #self._cellListL - i)
                elseif i == 2 then
                    -- 从备战区跳到作战区
                    cell:getParent():reorderChild(cell, 100)
                    self:cardJump(cell, cell:getPositionX() + 2 * (cellWidth + cellSpace), function()
                        cell:getParent():reorderChild(cell, #self._cellListL - i)
                    end)
--                    cell:setPositionX(cell:getPositionX() + 2 * (cellWidth + cellSpace))
                else
                    self:changeParent(cell, frontNode)
                    cell:setPositionX(frontNodeWidth - (cellWidth * (i+1) + i * cellSpace) - maskWidth)
                    cell:getParent():reorderChild(cell, #self._cellListL - i)
                end
            end

            if #self._cellListL < 2 then
                local cell = self:createCardCell(nil, true)
                cell:setPosition(frontNodeWidth - (cellWidth * 5 + 5 * cellSpace) - maskWidth, 0)
                frontNode:addChild(cell, -1)
                table.insert(self._cellListL, cell)
            end

            local sizeOld = self._scrollViewL:getInnerContainerSize()
            sizeOld.width = sizeOld.width - (cellWidth + cellSpace)
            sizeOld.width = sizeOld.width < frontNodeWidth and frontNodeWidth or sizeOld.width
            self._scrollViewL:setInnerContainerSize(sizeOld)

            self:runAction(cc.Sequence:create(
                cc.DelayTime:create(0.3),
                cc.CallFunc:create(function()
                    self:changeParent(frontNode, self._scrollViewL)
                    self._scrollViewL:reorderChild(frontNode, 99)
                    frontNode:setPositionX(sizeOld.width - self._scrollViewL:getContentSize().width)
                end
            )))
        end)
    end
end

function CityBattleFightView:updateRightCards(battleData, callBack)
    -- 防守方战胜
    local curplayer = self._cellListR[1]
    if battleData["win"] == false and not battleData["tie"] then
        local curData = self._rightPerson[1]
        curData["bl"] = battleData["def"].after
        self:updateCell(curplayer, curData)
    else
        self._scrollViewR:stopScroll()
        self:cardsDisappear(curplayer, function()
            curplayer:removeFromParent(true)
            table.remove(self._cellListR, 1)
            table.remove(self._rightPerson, 1)

            if callBack then 
                callBack()
            end

            for i = 1, #self._cellListR do
                local data = self._rightPerson[i]
                if data then
                    data["i"] = i
                    self:updateCell(self._cellListR[i], data)
                end
            end

            for i = 1, #self._cellListR do
                local cell = self._cellListR[i]

                if i < 2 then
                    cell:runAction(cc.MoveBy:create(0.1, cc.p(-(cellWidth + cellSpace), 0)))
                    cell:getParent():reorderChild(cell, #self._cellListR - i)
                elseif i == 2 then
                    -- 从备战区跳到作战区
                    cell:getParent():reorderChild(cell, 100)
                    self:cardJump(cell, cell:getPositionX() - 2 * (cellWidth + cellSpace), function()
                        cell:getParent():reorderChild(cell, #self._cellListR - i)
                    end)
                else

                    cell:setPositionX((cellWidth * i + i * cellSpace) + maskWidth)
                end
            end

            if #self._cellListR < 2 then
                local cell = self:createCardCell(nil, false)
                cell:setPosition(cellWidth * 1 + 1 * cellSpace + maskWidth, 0)
                self._scrollViewR:addChild(cell, -1)
                table.insert(self._cellListR, cell)
            end

            local sizeOld = self._scrollViewR:getInnerContainerSize()
            local minWidth = self._scrollViewR:getContentSize().width
            sizeOld.width = sizeOld.width - (cellWidth + cellSpace)
            sizeOld.width = sizeOld.width < minWidth and minWidth or sizeOld.width
            self._scrollViewR:setInnerContainerSize(sizeOld)
        end)
    end
end

local disappearTime = 0.3
function CityBattleFightView:cardsDisappear(cell, callBack)
    callBack()
--    cell:runAction(cc.Sequence:create(
--        cc.Sequence:create(
--            cc.FadeTo:create(0.1, 77),
--            cc.FadeTo:create(0.1, 255),
--            cc.FadeTo:create(0.1, 77),
--            cc.FadeTo:create(0.1, 255)
--        ),
--        cc.Spawn:create(
--            cc.FadeOut:create(disappearTime),
--            cc.CallFunc:create(function()
--                local dtTime = 0
--                self._schId = ScheduleMgr:regSchedule(0.01, self, function(self, dt)
--                    dtTime = dtTime + dt
--                    if dtTime > disappearTime then
--                        cell:setBrightness(255)
--                        ScheduleMgr:unregSchedule(self._schId)
--                        self._schId = nil

--                        callBack()
--                    else
--                        cell:setBrightness(255 * (disappearTime - dtTime) / disappearTime)
--                    end
--                end)
--            end)
--    )))
end


function CityBattleFightView:cardJump(cell, posX, callBack)
    local moveDistance = posX - cell:getPositionX()
    local cellColor = cell:getColor()
    cell:runAction(cc.Sequence:create(
        cc.EaseOut:create(cc.Spawn:create(
            cc.MoveBy:create(0.1, cc.p(moveDistance*0.5, 0)),
            cc.ScaleTo:create(0.1, 1.2)
        ), 3),
        cc.EaseIn:create(cc.Spawn:create(
            cc.MoveBy:create(0.1, cc.p(moveDistance*0.5, 0)),
            cc.ScaleTo:create(0.1, 1),
            cc.Sequence:create(
                cc.DelayTime:create(0.05),
                cc.TintTo:create(0.01, cc.c3b(255,255,255))
--                cc.TintTo:create(0.04, cellColor)
            )
        ), 3),
        cc.DelayTime:create(0.1),
        cc.CallFunc:create(function()
            if callBack then
                callBack()
            end
        end)
    ))
end

function CityBattleFightView:changeParent(node, parent)
    if node then
        node:retain()
        node:removeFromParent()
        node:setPosition(0, 0)
        parent:addChild(node)
        node:release()
    end
end

function CityBattleFightView:addTableView()
    local tableView = cc.TableView:create(cc.size(self._tableNode:getContentSize().width, self._tableNode:getContentSize().height-15))
    -- tableView:setColor(cc.c3b(255,255,255))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(0,0))
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

function CityBattleFightView:scrollViewDidScroll(view)
--    self._inScrolling = view:isDragging()
--    local printTxt = self._inScrolling and "true" or "fales"
--    print("self._inScrolling" .. printTxt)
    
    self._offsetX = view:getContentOffset().x
    self._offsetY = view:getContentOffset().y
    -- print("====================view:getContentOffset().y---------",view:getContentOffset().y)
end

function CityBattleFightView:scrollViewDidZoom(view)
    print("DidZoom")
end

function CityBattleFightView:tableCellTouched(table,cell)
    print("tableCellTouched")
end

function CityBattleFightView:cellSizeForTable(table,idx) 
    return self._tableCellH - 1,self._tableCellW
end

function CityBattleFightView:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    else
        cell:removeAllChildren()
    end
    local item = self:createItem(self._reportList[idx+1], idx)
    print("idx item",idx,item)
    if item then
        item:setPosition(cc.p(0,0))
        item:setAnchorPoint(cc.p(0,0))
        cell:addChild(item)
    end
    return cell
end

function CityBattleFightView:numberOfCellsInTableView(table)
    -- print("table num...",#self._reportList)
   return #self._reportList
end

function CityBattleFightView:createItem( data,idx )
    if data == nil  then return end
    item = self._reportItem:clone()
    item:setVisible(true)

--    dump(data)

    local leftName = item:getChildByFullName("nameLeft")
    leftName:setString(data.aname)

    local rightName = item:getChildByFullName("nameRight")
    rightName:setString(data.dname == "" and "中立守卫" or data.dname)

    local secLeft = item:getChildByFullName("secLeft")
    local leftColorType = self._occupyColorPlan[data.asec] or 4
    secLeft:loadTexture(secIconTab[leftColorType] .. ".png", 1)

    local secRight = item:getChildByFullName("secRight")
    local dsec = data.dname == "" and "npc" or data.dsec
    local rightColorType = self._occupyColorPlan[dsec] or 4
    secRight:loadTexture(secIconTab[rightColorType] .. ".png", 1)

    local winLeft = item:getChildByFullName("winLeft")
    winLeft:loadTexture(data.win and "citybattle_view_img85.png" or "citybattle_view_img86.png", 1)

    local winRight = item:getChildByFullName("winRight")
    winRight:loadTexture(data.win and "citybattle_view_img86.png" or "citybattle_view_img85.png", 1)

    local watchBtn = item:getChildByFullName("playBtn")
    self:registerClickEvent(watchBtn, function()
        local param = {reportKey = data.bk,jsonFormat = 1}
        self._serverMgr:sendMsg("CityBattleServer", "getBattleReport", param, true, {}, function (result, error)
            if result then
                self:reviewGvgBattle(result)
            end
        end)
    end)

    return item
end

--回放
function CityBattleFightView:reviewGvgBattle(result)
    self:resetFight()

    self._watchingReport = true

    local left,right  = self:initBattleData(result.atk,result.def)
    -- right = self:initBattleData(result.def)
    BattleUtils.disableSRData()
    BattleUtils.enterBattleView_GVG(left, right, result.r1, result.r2,
    function (info, callback)
        callback(info)
    end,
    function (info)
        -- 退出战斗
    end)
end

function CityBattleFightView:initBattleData(playerData, enemyData)
    local playerInfo = BattleUtils.jsonData2lua_battleData(playerData)
    local enemyInfo = BattleUtils.jsonData2lua_battleData(enemyData)
    return playerInfo, enemyInfo
end

-- 弹幕
function CityBattleFightView:updateBulletBtnState()
    -- BulletScreensUtils.clear()

    self._btnBullet = self:getUI("bg.leftDown.btn_bullet")
    self._labelBullet = self:getUI("bg.leftDown.label_bullet")
    self._labelBullet:enable2Color(1, cc.c4b(255, 195, 17, 255))
    self._labelBullet:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    self._sysBullet = tab:Bullet("gvg")
    
    if self._sysBullet == nil then 
        self._btnBullet:setVisible(false)
        self._labelBullet:setVisible(false)
        return
    else
        self._btnBullet:setVisible(true)
        self._labelBullet:setVisible(true)
    end
    self._labelBullet:enable2Color(1, cc.c4b(255, 195, 17, 255))
    self._labelBullet:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    self:registerClickEvent(self._btnBullet, function ()
        self._viewMgr:showDialog("global.BulletSettingView", {bulletD = self._sysBullet, kuaFuEnable = true,
            callback = function (open) 
                local fileName = open and "bullet_open_btn.png" or "bullet_close_btn.png"
                self._btnBullet:loadTextures(fileName, fileName, fileName, 1)       
            end})
    end)    
end

function CityBattleFightView:showBullet()
    if self._sysBullet == nil then 
        return
    end
    local open = BulletScreensUtils.getBulletChannelEnabled(self._sysBullet)
    local fileName = open and "bullet_open_btn.png" or "bullet_close_btn.png"
    self._btnBullet:loadTextures(fileName, fileName, fileName, 1)    
    if open then
        BulletScreensUtils.initBullet(self._sysBullet)
    end    
end

-- 战场中心
function CityBattleFightView:fightPanel()
    self:setScreenGray(false)

    local bg = self:getUI("bg")
    if not self._solo then
        self._solo = HeroSoloPlayer.new()
        self._solo:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5 - 160)
        bg:addChild(self._solo)
    end

    local heroData1, heroData2, groupID, atkCamp, winCamp = self:arrangementFightData()
    local param = {
        info1 = heroData1,
        info2 = heroData2,
        groupID = groupID,
        atkCamp = atkCamp,
        winCamp = winCamp,
    }
--    dump(param)

    self._isBattleAniming = true

    self._atkFormation = self._fightCurrent.atkFormation
    self._defFormation = self._fightCurrent.defFormation
    self._solo:init(param, specialize(self.playFightOver, self))
end

-- 组合数据
function CityBattleFightView:arrangementFightData()
    local data = self._fightCurrent
    if not data then
        return
    end
    local atk = data["atk"]
    local def = data["def"]

    local winFight = nil
    local atkCamp = nil
    local soloId = nil
    if data["win"] == true then
        winFight = 1
        atkCamp = 1
        soloId = self:getRandomSoloId(atk["after"])
    else
        winFight = 2
        atkCamp = 2
        soloId = self:getRandomSoloId(def["after"])
    end

    -- 左边信息
    local heroData1 =
    {
        heroID = atk["heroId"],
        HP_begin = atk["before"],
        HP_end = atk["after"],
        name = atk["name"],
        HP_color = atk["color"], -- 1红2蓝3绿
    }
    -- 右边信息
    local heroData2 =
    {
        heroID = def["heroId"],
        HP_begin = def["before"],
        HP_end = def["after"],
        name = def["name"],
        HP_color = def["color"],
    }

    -- heroSoloGroup表ID
    groupID = tonumber(soloId)
    -- 表里定义的进攻是左还是右
    atkCamp = atkCamp
    -- 胜利者 1 or 2 / 0 是平局
    winCamp = winFight

    return heroData1, heroData2, groupID, atkCamp, winCamp
end

function CityBattleFightView:addClickTouchEvent(inview, callBack)
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

-- 根据血量判断动作ID
function CityBattleFightView:getRandomSoloId(hp)
    local hpPer = math.floor(hp / 8 * 100)
    local randomList = {}
    for k, v in pairs(heroSoloGroupTab) do
        if hpPer >= v.trigger[1] and hpPer <= v.trigger[2] then
            table.insert(randomList, k)
        end
    end
    local randomLen = #randomList
    return randomList[math.random(1, randomLen)]
end


-- 撤退出城池
function CityBattleFightView:leaveRoom(inFid)
    local params = {}
    params.cid = self._cityId
    params.fid = inFid
    params.mapId = self._cModel:getMapId()
    params.rid = self._userModel:getData()._id
    params.name = self._userModel:getData().name
    params.sec = self._cModel:getMineSec()
    params._m = "leaveRoom_" .. self._userModel:getData()._id
    if not GameStatic.revertGvg_rebuild then
        local cmodel = self._cModel
        cmodel:addSendCallback(10003, function(result, error)
            if error == 0 then
                print("CityBattleFightView:leaveRoom2")
                cmodel:addLeaveData(self._cityId, inFid)
            end
        end)
    end
    ServerManager:getInstance():RS_sendMsg("PlayerProcessor", "leaveRoom", params or {})
end

-- 退出观战房间
function CityBattleFightView:onClose()
    self._serverMgr:RS_sendMsg("PlayerProcessor", "leaveCastle", 
        {
            mapId = self._cModel:getMapId(),
            cid = self._cityId,
            rid = self._modelMgr:getModel("UserModel"):getRID()
        }
    )

    self:close()
end

function CityBattleFightView:showLeidaTips(tp)
    local sec = nil
    if tp == "left" then
        if self._leftPerson[1] ~= nil then
            sec = self._leftPerson[1].sec
        end
    elseif tp == "right" then
        sec = self._secId
    end

    if sec ~= nil then
        local level = self._cModel:getReadlyLevel(sec)
        local readyData = self._cModel:getReadlyData()[sec] or {e1 = 0, e2 = 0, e3 = 0, e4 = 0, e5 = 0, e6 = 0}
        local partKey = self._cModel:getMinOpenDayKey()

        local secData = {}

        secData.side = tp
        if sec == "npc" then
            secData.secName = "中立区"
            secData.secDes = ""
        else
            secData.secName = self._cModel:getSecName(sec)

            local servers = self._cModel:fiterServers(sec)
            local str = ""
            for index,id in pairs (servers) do 
                local num = self._cModel:getRealNum(id)
                local platform = self._cModel:getPlatformName(id)
                platform = platform or ""
                str = str .. platform .. num .. "区"
                if index ~= table.nums(servers) then
                    str = str .. "、"
                end
            end
            secData.secDes = str
        end

        CityBattleUtils.createLeiDaTip(self,level,readyData, secData,partKey)
    end
end

function CityBattleFightView:onDestroy()
    self:showLoadingAni(false)
    self._cModel:resetCityData()
    BulletScreensUtils.clear()
    CityBattleFightView.super.onDestroy(self)
end

function CityBattleFightView.dtor()
    updateDrawLeida = nil
    drawLeida = nil
    zhenyingTable = nil
    severList = nil
end

return  CityBattleFightView
