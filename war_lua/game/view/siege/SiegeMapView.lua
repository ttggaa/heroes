--
-- Author: <ligen@playcrab.com>
-- Date: 2017-09-07 21:25:06
--
local  SiegeMapView = class("SiegeMapView",BaseView)

require "game.view.siege.SiegeConst"
--2   地面动画层  self._aminLayer
--7   建筑状态
--9   装饰
--10   地面特效  self._effectLayer
--11  城池周围玩家
--20/19 支线icon


--100  绿点路线 传送门  
--101  英雄动画
--102  城池气泡
--104  self._topLayer(上层云鸟特效)  
--105  雾



SiegeMapView.SHOW_POINT_X = MAX_SCREEN_WIDTH * 0.4
SiegeMapView.SHOW_POINT_Y = MAX_SCREEN_HEIGHT * 0.6

function SiegeMapView:ctor()
    SiegeMapView.super.ctor(self)

    self._usingIcon = {}
    self._freeingIcon = {}
    self._usingFog = {}
    self._buildingFog = {}
    self._freeingFog = {}

    self._branchIcon = {}

    self._otherPlayer = {}

    self._bubbleList = {}

    self._lockCount = 0

    self._dtTime = 0

    self._sModel = self._modelMgr:getModel("SiegeModel")
    self._userModel = self._modelMgr:getModel("UserModel")

    self.dontAdoptIphoneX = true
end

function SiegeMapView:getAsyncRes()
    return 
        {
            {"asset/ui/siege.plist", "asset/ui/siege.png"},
        }
end

-- 第一次被加到父节点时候调用
function SiegeMapView:onBeforeAdd(callback, errorCallback)
    local stageId = self._sModel:getCurStageId()
    if stageId ~= nil then
        self._serverMgr:sendMsg("SiegeServer", "getStagePlayer", {stageId = stageId}, true, {}, function(result)
            self:reflashUI(result, true)

            if callback then
                callback()
            end
        end)
    else
        if callback then
            callback()
        end
    end
end

-- 初始化UI后会调用, 有需要请覆盖
function SiegeMapView:onInit()
    -- 地图层
    self._bgMapNode = cc.Layer:create()
    self._bgMapNode:setAnchorPoint(0, 0)
    self:getUI("bgMap"):addChild(self._bgMapNode)

    -- UI层
    self._bgUI = self:getUI("bgUI")
    self._bgUI:setContentSize(ADOPT_IPHONEX and MAX_SCREEN_WIDTH - 120 or MAX_SCREEN_WIDTH)

    local titleLabel = self._bgUI:getChildByFullName("titleNode.titleLabel")
    titleLabel:setString("斯坦德威克")
    UIUtils:setTitleFormat(titleLabel, 1)

    --活动规则描边
    self:getUI("bgUI.leftNode.ruleBtn.lab"):enableOutline(cc.c4b(60, 30, 10, 255), 1)

    local closeBtn = self:getUI("bgUI.btnClose")
    self:registerClickEvent(closeBtn, function()
        self:close()
        UIUtils:reloadLuaFile("siege.SiegeMapView")
    end)

    if ADOPT_IPHONEX then
        local parameter = closeBtn:getLayoutParameter()
        parameter:setMargin({left=0,top=0,right=60,bottom=0})
        closeBtn:setLayoutParameter(parameter)
    end

    self._tipNode = self._bgUI:getChildByFullName("titleNode.tipNode")
    self._tipNode:setVisible(false)
    self._tipNode1 = self._bgUI:getChildByFullName("titleNode.tipNode1")
    self._tipNode1:setVisible(false)

    local leftNode = self._bgUI:getChildByFullName("leftNode")
    if ADOPT_IPHONEX then
        local parameter = leftNode:getLayoutParameter()
        parameter:setMargin({left=60,top=0,right=0,bottom=0})
        leftNode:setLayoutParameter(parameter)
    end
    self._sectionInfoBtn = leftNode:getChildByFullName("sectionInfoBtn")

    self:registerClickEvent(self._sectionInfoBtn, function ()
--        self._viewMgr:showDialog("intance.IntanceSectionInfoView",{}
--        )
--        self:activeStageBuilding()

--        self._viewMgr:showDialog("siege.SiegeWinTipView", {tipType = 2}, true)

--        self:showWinTip()

--                        self._viewMgr:showView("siege.SiegeMcPlotView", 
--                            {
--                                plotId = 6,
--                                callback = function()
--                                    self._viewMgr:popView()
--                                end
--                            },true)

        -- 斥候密信只有一个地方会有红点，减少检测红点代码，直接用按钮状态提示
        local showBranchTip = 0
        if self._sectionInfoBtn.tip ~= nil and self._sectionInfoBtn.tip:isVisible() == true then 
            showBranchTip = 1
        end
        self._viewMgr:showDialog("siege.SiegeSectionInfoView",{
            sectionId = self._curSectionId, 
            showBranchTip = showBranchTip,
            callback = function(inShowStageId, inBranchId)
                self:runMagicEyeAction(inShowStageId, inBranchId)
            end,
            moveCallback = function(inBranchId)
                self:moveToBranchBuilding(inBranchId)
            end,
            updateCallback = function()
                self:updateSectionInfoBtnState()
            end}
        )
    end)

    self._ruleBtn = self:getUI("bgUI.leftNode.ruleBtn")
    -- UIUtils:addFuncBtnName(self._ruleBtn, "规则", cc.p(self._ruleBtn:getContentSize().width/2, -3), true, 18)
    self:registerClickEvent(self._ruleBtn, function()
        self._viewMgr:showDialog("siege.SiegeMapRuleView")
    end)

    mcMgr:loadRes("chihoumixin_intanceotherbtn-HD", function()
        local amin3 = mcMgr:createViewMC("chihoumixin_intanceotherbtn-HD", true)
        amin3:setPosition(self._sectionInfoBtn:getContentSize().width/2, self._sectionInfoBtn:getContentSize().height/2)
        self._sectionInfoBtn:addChild(amin3)
        amin3:setOpacity(0)
        amin3:setCascadeOpacityEnabled(true, true)
        amin3:runAction(cc.FadeIn:create(1))
    end)

    --  监测touch
    self._depleteSchedule = ScheduleMgr:regSchedule(1, self, function(self, dt)
        self:update(dt)
    end)

    self._bgTextureName = "asset/uiother/siege/map_siege.jpg"
    self._bgMap = cc.Sprite:create(self._bgTextureName)
    self.BGMAP_WIDTH = self._bgMap:getContentSize().width
    self.BGMAP_HEIGHT = self._bgMap:getContentSize().height
    self._bgMapNode:setContentSize(self.BGMAP_WIDTH, self.BGMAP_HEIGHT)
    self._bgMap:setPosition(0, 0)
    self._bgMap:setAnchorPoint(0, 0)
    self._bgMapNode:addChild(self._bgMap)

    self:initEvent()

    self:setListenReflashWithParam(true)
    self:listenReflash("SiegeModel", self.onModelReflash)

end

function SiegeMapView:initEvent()
    -- 注册多点触摸
    local dispatcher = cc.Director:getInstance():getEventDispatcher()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(function (touch, event)
        return self:onTouchBegan(touch, event)
    end, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function (touch, event)
        self:onTouchMoved(touch, event)
    end, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(function (touch, event)
        self:onTouchEnded(touch, event)
    end, cc.Handler.EVENT_TOUCH_ENDED)
    dispatcher:addEventListenerWithSceneGraphPriority(listener, self._bgMapNode)
    self._touchDispatcher = dispatcher
end

-- 接收自定义消息
function SiegeMapView:reflashUI(data, isInit)
    self._mainData = self._sModel:getData()
    self._curStatus = self._mainData.status
    self._curStageId = self._sModel:getCurStageId()
    self._curSectionId = self._sModel:getCurSectionId()
    self._sysSection = tab:SiegeMainSection(self._curSectionId)

    if self._curSectionId == 2 then
        self._hadAttack = true

    elseif self._curSectionId == 1 then
        if (SystemUtils.loadAccountLocalData("SiegeStageId") == nil 
            or self._curStageId > SystemUtils.loadAccountLocalData("SiegeStageId"))
            and self._mainData.status == self._sModel.STATUS_SIEGE
        then
            self._hadAttack = false
        else
            self._hadAttack = true
        end
    end

    if self._mainData.status >= self._sModel.STATUS_PREDEFEND then
        self:initOtherPlayer()
    else
        self:initOtherPlayer(data)
    end

    -- 初始化要等到onshow才展示
    if not isInit then
        self:initDesTips()
    end
    self:showWinTip()

    if self._hadAttack then
        self._heroStandByStageId = self._curStageId
    else
        self._heroStandByStageId = self._curStageId - 1
    end


    -- 清理遗留绿点
    if self._tempPoints ~= nil then 
        for k,v in pairs(self._tempPoints) do
            v:removeFromParent()
        end
    end
    self._tempPoints = nil
    self._touchBack = true

    self:releaseFogIcon()
    self:releaseBranchIcon()
    self:releaseBuildingIcon()

    -- 正常入口建筑展示
    local positionIcon
    local sysPositionStageMap = nil
    -- 迷雾数据
    local fogIcon 
    for k,v in pairs(self._sysSection.includeStage) do
        local branchInfo = self._sModel:getBranchInfo()
        local sysMainStageMap = tab:SiegeMainStageMap(v)
        local sysMainStage = tab:SiegeMainStage(v)
        local buildingIcon
        local starBg = nil 
        if #self._freeingIcon > 0  then 
            buildingIcon = self._freeingIcon[#self._freeingIcon]
            table.remove(self._freeingIcon)
        else
            buildingIcon = ccui.Widget:create()
            self._bgMapNode:addChild(buildingIcon, 7)
        end
        

        buildingIcon.showIndex = k
        buildingIcon:setName("building_icon" .. sysMainStageMap.id)

        buildingIcon:setVisible(true)
        buildingIcon:setContentSize(cc.size(sysMainStageMap.w,sysMainStageMap.h))
        buildingIcon:setPosition(cc.p(sysMainStageMap.x,sysMainStageMap.y))
        buildingIcon:setAnchorPoint(cc.p(sysMainStageMap.anchorPointX,sysMainStageMap.anchorPointY))

        registerTouchEvent(buildingIcon, nil, nil, function ()
            self._touchBack = self:touchEventIcon(buildingIcon, buildingIcon.showIndex)
        end)
        buildingIcon:setTouchEnabled(false)

        table.insert(self._usingIcon,buildingIcon)

        if v < 10005 and v < self._curStageId then
            local completeIcon = cc.Sprite:createWithSpriteFrameName("siege_breached.png")
            completeIcon:setPosition(sysMainStageMap.w * 0.5 + 21, sysMainStageMap.h + 18)
            buildingIcon:addChild(completeIcon, 1)

        elseif v == 10005 and self._mainData.status == self._sModel.STATUS_PREDEFEND then
            local completeIcon = cc.Sprite:createWithSpriteFrameName("siege_breached1.png")
            completeIcon:setPosition(sysMainStageMap.w * 0.5 + 20, sysMainStageMap.h * 0.5 - 19)
            buildingIcon:addChild(completeIcon, 1)
        end

        self:initStageFog(sysMainStageMap)
        self:initStageBranch(branchInfo, sysMainStage)
    end

    self:initAttackState()

    if self._hadAttack then
        positionIcon = self:getStageBuildingById(self._curStageId)
        sysPositionStageMap = tab:SiegeMainStageMap(self._curStageId)
    else
        positionIcon = self:getStageBuildingById(self._curStageId - 1)
        sysPositionStageMap = tab:SiegeMainStageMap(self._curStageId - 1)
    end

    ----------------------------------英雄动画-------------------------------------
    self:refreshHeroAnim()


    if self._hadAttack then 
        if positionIcon then
            self:screenToObject(positionIcon, cc.p(0,0), false)
        end

        local preStageTemp = tab:SiegeMainStageMap(self._curStageId - 1)
        if preStageTemp == nil then
            preStageTemp = tab:SiegeMainStageMap(10004)
        end
        local iconPoint = preStageTemp.point[#preStageTemp.point]
        self:updateAminPos(iconPoint)
    else
        -- 移动到最新的一个挑战建筑
        ----------------------------------英雄位置-------------------------------------
        local iconPoint = sysPositionStageMap.point[1]
        self:updateAminPos(iconPoint)
        self:activeStageBuilding()

        if positionIcon then
            -- 偏移位置
            local offset = cc.p(0, 0)
            if sysPositionStageMap.id + 1 <= self._curStageId then
                local nextView = self:getStageBuildingById(sysPositionStageMap.id + 1)
                if nextView ~= nil then 
                    local x = (nextView:getPositionX() - positionIcon:getPositionX()) /2
                    local y = (nextView:getPositionY() + nextView:getContentSize().height/2 - positionIcon:getPositionY() + positionIcon:getContentSize().height/2) /2
                    offset = cc.p(x, y)
                end
            end
        --    self._moveCallBack(positionIcon, offset)
            self:screenToObject (positionIcon, offset, false)
        end
    end

    if self._intanceMcAnimNode ~= nil then self._intanceMcAnimNode:setVisible(true) end

    self:initDecorate()
    self:updateSectionInfoBtnState()
    self:updateTaskState()
    self:updateBuildingBubble()
end


function SiegeMapView:onModelReflash(eventName)
    if eventName == "stateUpdate" then
        if self._mainData.status == self._sModel.STATUS_OVER then
            self._viewMgr:showTip("资料篇活动结束")
            self:close()
        else
            self:updateBuildingState()
            if not self:isPrepareViewOpen() then
                if self._sModel:getCurStageId() > self._curStageId or
                    self._mainData.status == self._sModel.STATUS_OVER
                then
                    self._curStageId = self._sModel:getCurStageId()
                    self._serverMgr:sendMsg("SiegeServer", "getStagePlayer", {stageId = self._curStageId}, true, {}, function(result)
                        self:reflashUI(result)
                        self:fadeInStageFog(false)
                        self:showDefBeforeAni()
                    end)
                end
            end
        end
    end
end


function SiegeMapView:isPrepareViewOpen()
    local popViews = self:getPopViews()
    for k, v in pairs(popViews) do
        if v:getClassName() == "siege.SiegePrepareView" then
            return true 
        end
    end
    return false
end

--[[
--! @function refreshHeroAnim
--! @desc 刷新英雄动画（布阵中替换英雄）
--! @return 
--]]
function SiegeMapView:refreshHeroAnim()
    local heroId
    local heroart
    if heroId == nil  then 
        local formationModel = self._modelMgr:getModel("FormationModel")
        heroId = formationModel:getFormationDataByType(formationModel.kFormationTypeCommon).heroId
    
        local heroModel = self._modelMgr:getModel("HeroModel")
        local userHeroData = heroModel:getHeroData(heroId)
        if userHeroData.skin ~= nil then 
            local heroSkinD = tab.heroSkin[userHeroData.skin]
            heroart =  heroSkinD.heroart
        end
    end
    -- 如果没有走皮肤，则获取默认的
    if heroart == nil then
        local sysHero = tab:Hero(heroId)
        if sysHero == nil then 
            sysHero = tab:NpcHero(heroId)
        end
        heroart = sysHero.heroart
    end
    
    local isHas = false
    local cacheX, cacheY = 0, 0
    if self._intanceMcAnimNode ~= nil then
        -- 布阵中如果替换兵团也会触发此方法所以如果相同英雄就不进行英雄替换
        if self._intanceMcAnimNode.heroId == heroId then 
            return
        end
        cacheX, cacheY = self._intanceMcAnimNode:getPosition()
        isHas = true
        self._intanceMcAnimNode:clear()
        self._intanceMcAnimNode = nil
    end
    
    local IntanceMcAnimNode = require("game.view.intance.IntanceMcAnimNode")
    self._intanceMcAnimNode = IntanceMcAnimNode.new({"stop", "win", "run", "run2"}, heroart,
    function(sender) 
        sender:runStandBy()
        end
        ,100,100,
        {"stop", "run2"},{{3,10}, {1,2}})
    self._bgMapNode:addChild(self._intanceMcAnimNode, 101)
    self._intanceMcAnimNode:setScale(0.4)
    self._intanceMcAnimNode:setPosition(200, 200)
    self._intanceMcAnimNode:setVisible(true)
    self._intanceMcAnimNode:setName("IntanceMcAnimNode")
    
    self._intanceMcAnimNode.heroId = heroId
    
    local pointTip = mcMgr:createViewMC("jiantou_intancejiantou", true)
    pointTip:setPosition(0, 260)
    pointTip:setScale(2)
    pointTip:setName("pointTip")
    self._intanceMcAnimNode:addChild(pointTip)
    
    self._intanceMcAnimNode:setPosition(cacheX, cacheY)

--    if self._intanceMcAnimNode ~= nil then 
--        self._intanceMcAnimNode:clear()
--        self._intanceMcAnimNode = nil
--    end
    
end

--[[
--! @function updateAminPos
--! @desc 更新地图英雄坐标点
--! @param inSysMapData 地图信息
--! @return 
--]]
function SiegeMapView:updateAminPos(inSysMapData)
    if self._intanceMcAnimNode ~= nil then 
        if inSysMapData[3] == 1 then
            self._intanceMcAnimNode:setFlipX(false)
        else
            self._intanceMcAnimNode:setFlipX(true)
        end
        self._intanceMcAnimNode:setPosition(inSysMapData[1], inSysMapData[2])
    end
end

--[[
--! @function getStageBuildingById
--! @desc 根据章节id获得副本章节的view
--! @param  inStageId 完成章节id
--! @return 
--]]
function SiegeMapView:getStageBuildingById(inStageId)
    local stageView = self._bgMapNode:getChildByName("building_icon" .. inStageId)
    -- if stageView == nil then 
    --     local tempStageId = self._sysSection.includeStage[#self._sysSection.includeStage]
    --     stageView = self:getChildByName("building_icon" .. tempStageId)
    -- end
    return stageView
end


function SiegeMapView:getBranchBuildingById(inBranchId)
    return self._branchIcon[inBranchId]
end

--[[
--! @function initOtherPlayer
--! @desc 初始化城池周围玩家形象
--]]
function SiegeMapView:initOtherPlayer(infos)
    if #self._otherPlayer > 0 then
        for k,v in pairs(self._otherPlayer) do
            v:removeFromParent(true)
            v = nil
        end
        self._otherPlayer = {}
    end

    if infos == nil then return end
    dump(infos)

    local posList = tab:SiegeMainStageMap(self._curStageId).randomPosition
    for k, v in pairs(infos) do
        local pos = posList[k]

        if v.hero == nil then
            print("城池旁英雄信息缺失")
            return
        end

        local heroSkinD = tab.heroSkin[v.hero.skin]
        local heroArt = (heroSkinD and heroSkinD["heroart"]) and heroSkinD["heroart"] or nil

        if heroArt and pos then

            mcMgr:loadRes("stop_" .. heroArt, function()
                if not tolua.isnull(self._bgMapNode) then
                    local sp = mcMgr:createViewMC("stop_" .. heroArt, true)
                    sp:setScale(0.4)
        --            sp:setAnchorPoint(0.5,0)
                    sp:setPosition(pos[1], pos[2])
                    sp:setScaleX(pos[3] == 0 and -1 * sp:getScaleX() or sp:getScaleX())
                    self._bgMapNode:addChild(sp,11)
                    table.insert(self._otherPlayer, sp)

                    local nameBg = cc.Scale9Sprite:createWithSpriteFrameName("siege_nameBg.png")
                    nameBg:setScaleY(2.5)
                    nameBg:setScaleX(pos[3] == 0 and -1 *2.5 or 2.5)
                    nameBg:setPosition(0, 225)
                    sp:addChild(nameBg, 30)
                    nameBg:setOpacity(80)
        
                    local nameLab = cc.Label:createWithTTF(v.name, UIUtils.ttfName, 20) 
                    nameLab:setColor(UIUtils.colorTable.ccUIBaseColor2)
                    nameLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
                    local width = 92 
                    if (nameLab:getContentSize().width + 60) > width then 
                        width = nameLab:getContentSize().width + 60
                    end
                    nameBg:setContentSize(width, 30)

                    nameLab:setPosition(nameBg:getContentSize().width/2, nameBg:getContentSize().height/2)
                    nameBg:addChild(nameLab)
                end
            end)
        end
    end
end

--[[
--! @function initAttackState
--! @desc 初始化城池状态
--]]
function SiegeMapView:initAttackState()
    print("=====================" .. self._curStageId)
    local curBuilding = self:getStageBuildingById(self._curStageId)
    local centerPosX = curBuilding:getContentSize().width*0.5
    local centerPosY = curBuilding:getContentSize().height*0.5

    if curBuilding ~= nil and curBuilding.stateNode ~= nil then
        curBuilding.stateNode:removeFromParent(true)
        curBuilding.stateNode = nil
    end

    if self._curStageId < 10005 then
        local stateNode = cc.Node:create()
        curBuilding.stateNode = stateNode
        curBuilding:addChild(stateNode)

        local fightAni = mcMgr:createViewMC("zhandou_citybattlechengchidianji", true, false)
        fightAni:setPosition(centerPosX + 15, centerPosY * 2 + 30)
        stateNode:addChild(fightAni)

    elseif self._curStageId == 10005 and self._mainData.status == self._sModel.STATUS_SIEGE then
        local stateNode = cc.Node:create()
        curBuilding.stateNode = stateNode
        curBuilding:addChild(stateNode)

        local defAni = mcMgr:createViewMC("zhandou_citybattlechengchidianji", true, false)
        defAni:setPosition(centerPosX - 95, centerPosY - 100)
        stateNode:addChild(defAni)
        
        local hpBg = ccui.Scale9Sprite:createWithSpriteFrameName("siege_hpProgressBg.png")
        hpBg:setCapInsets(cc.rect(20, 9, 1, 1))
        hpBg:setContentSize(192, 18)
        hpBg:setPosition(centerPosX +34 , centerPosY - 110)
        stateNode:addChild(hpBg)

        local percent = self._mainData.blood5 / tab:SiegeMainStage(self._curStageId).hp * 100
        local hpBar = ccui.LoadingBar:create("siege_hpProgress.png", 1, percent)
        hpBar:setOpacity(255)
        hpBar:setPosition(centerPosX + 34 , centerPosY - 110)
        stateNode.hpBar = hpBar
        stateNode:addChild(hpBar)

        local rateLabel = cc.Label:createWithTTF(self:numberFormat(self._mainData.blood5) .. "/" .. self:numberFormat(tab:SiegeMainStage(self._curStageId).hp), UIUtils.ttfName, 18)
        rateLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        rateLabel:setPosition(centerPosX + 33 , centerPosY - 92)
        stateNode.rateLabel = rateLabel
        stateNode:addChild(rateLabel)

    elseif self._curStageId == 30001 and self._mainData.status == self._sModel.STATUS_DEFEND  then

        local stateNode = cc.Node:create()
        curBuilding.stateNode = stateNode
        curBuilding:addChild(stateNode)

        local defAni = mcMgr:createViewMC("fangshoudun_gongcheng", true, false)
        defAni:setPosition(centerPosX - 95, centerPosY - 100)
        stateNode:addChild(defAni)
        
        local hpBg = ccui.Scale9Sprite:createWithSpriteFrameName("siege_hpProgressBg.png")
        hpBg:setCapInsets(cc.rect(20, 9, 1, 1))
        hpBg:setContentSize(192, 18)
        hpBg:setPosition(centerPosX + 34 , centerPosY - 110)
        stateNode:addChild(hpBg)

        local percent = self._mainData.waves / tab:SiegeMainStage(self._curStageId).enemyAmount * 100
        local hpBar = ccui.LoadingBar:create("siege_hpProgress.png", 1, percent)
        hpBar:setOpacity(255)
        hpBar:setPosition(centerPosX + 34 , centerPosY - 110)
        stateNode.hpBar = hpBar
        stateNode:addChild(hpBar)

        local rateLabel = cc.Label:createWithTTF("剩余波数" .. self:numberFormat(self._mainData.waves), UIUtils.ttfName, 18)
        rateLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        rateLabel:setPosition(centerPosX + 33 , centerPosY - 92)
        stateNode.rateLabel = rateLabel
        stateNode:addChild(rateLabel)
    end
end

--[[
--! @function initStageFog
--! @desc 初始化关卡迷雾
--! @param inStageId 关卡id
--! @return 
--]]
function SiegeMapView:initStageFog(inSysMainStageMap)
--    if (self._curStageId < inSysMainStageMap.id or 
--        (self._curStageId == inSysMainStageMap.id and 
--            self._curStageId ~= self._heroStandByStageId))  and 
--        inSysMainStageMap.fog ~= nil 

    if self._curStageId < inSysMainStageMap.id and inSysMainStageMap.fog ~= nil then
        local fogIcon
        for i=1, #inSysMainStageMap.fog do
            local sysFog = inSysMainStageMap.fog[i]
            if #self._freeingFog > 0  then 
                fogIcon = self._freeingFog[#self._freeingFog]
                fogIcon:setVisible(true)
                table.remove(self._freeingFog)
            else
                fogIcon = cc.Sprite:create("asset/uiother/intance/intanceImageUI4_fog.png")
                fogIcon:setScaleY(1.06)
                self._bgMapNode:addChild(fogIcon, 105)
            end
            fogIcon:setPosition(sysFog[1], sysFog[2])
            table.insert(self._usingFog, fogIcon)
            if self._buildingFog[inSysMainStageMap.id] == nil then 
                self._buildingFog[inSysMainStageMap.id] = {}
            end
            fogIcon:setOpacity(0)
            table.insert(self._buildingFog[inSysMainStageMap.id], fogIcon)
        end
    end
end


--[[
--! @function fadeInStageFog
--! @desc 迷雾淡入
--! @param inAnim 是否动画
--! @param inTime 时间
--! @return 
--]]
function SiegeMapView:fadeInStageFog(inAnim, inTime)
    if self._buildingFog == nil then 
        return 
    end
    if inTime ~= nil and inTime < 0.1 then  
        inTime = 0.1
    end
    for k,v in pairs(self._buildingFog) do
        for u,e in pairs(v) do
            if e ~= nil and e.setCascadeOpacityEnabled ~= nil then
                e:setCascadeOpacityEnabled(true, true)
                if inAnim then 
                    local time = math.random(1, inTime * 10) / 10
                    e:runAction(cc.FadeIn:create(time))
                else
                    e:setOpacity(255)
                end
            end
        end
    end
end

--[[
--! @function fadeOutStageFog
--! @desc 迷雾淡出
--! @param inAnim 是否动画
--! @param inTime 时间
--! @return 
--]]
function SiegeMapView:fadeOutStageFog(inAnim, inTime)
    if self._buildingFog == nil then 
        return 
    end
    if inTime ~= nil and inTime < 0.1 then 
        inTime = 0.1
    end
    for k,v in pairs(self._buildingFog) do
        for u,e in pairs(v) do
            if e ~= nil and e.setCascadeOpacityEnabled ~= nil then
                e:setCascadeOpacityEnabled(true)
                if inAnim then 
                    local time = math.random(1, inTime * 10) / 10
                    e:runAction(cc.FadeOut:create(time))
                else
                    e:setOpacity(0)
                end
            end
        end
    end
end

--[[
--! @function createBranchBuildIcon
--! @desc 创建支线信息
--! @param  sysBranch 系统支线信息
--! @return 
--]]
local AnimAp = require "base.anim.AnimAP"
function SiegeMapView:createBranchBuildIcon(sysBranch)
    local branchIcon
    local buildingIcon = ccui.Widget:create()
    buildingIcon:setContentSize(cc.size(130, 130))
    buildingIcon:setAnchorPoint(0.5, 0)
    if sysBranch.type == SiegeConst.STAGE_BRANCH_TYPE.WAR or 
     sysBranch.type == SiegeConst.STAGE_BRANCH_TYPE.REWARD_TEAM  or 
     sysBranch.type == SiegeConst.STAGE_BRANCH_TYPE.REWARD_ITEM_TEAM or 
     sysBranch.type == SiegeConst.STAGE_BRANCH_TYPE.COST_TEAM or 
     sysBranch.type == SiegeConst.STAGE_BRANCH_TYPE.COST_ITEM_CHIP or 
     sysBranch.type == SiegeConst.STAGE_BRANCH_TYPE.TALK then

        local relColor = false 
        -- 控制地图怪物显示颜色
        if sysBranch.camp == 2 then relColor = true end

        if sysBranch.subType ~= nil and sysBranch.subType[1] == 1 then 
            branchIcon = mcMgr:createViewMC(sysBranch.res, true, false)
            buildingIcon:setContentSize(100, 100)
            buildingIcon:setPosition(sysBranch.position[1], sysBranch.position[2])

            branchIcon:setPosition(buildingIcon:getContentSize().width/2, buildingIcon:getContentSize().height/2)
            buildingIcon:addChild(branchIcon)
        else
            if AnimAp["mcList"][sysBranch.res] then 
                mcMgr:loadRes(sysBranch.res, function ()
                    if not tolua.isnull(buildingIcon) then
                        branchIcon = MovieClipAnim.new(buildingIcon, sysBranch.res, function (sp)
                            local w, h = sp:getSize()

                            buildingIcon:setContentSize(cc.size(w, h ))

                            sp:setPosition(buildingIcon:getContentSize().width/2, 0)
                            sp:changeMotion(1)
                            sp:play()

                            buildingIcon.animSp = sp
                        end, relColor)
                        if sysBranch.flipX == 1 then 
                            buildingIcon:setPosition(sysBranch.position[1], sysBranch.position[2])
                            buildingIcon:setFlippedX(true)
                        else
                            buildingIcon:setPosition(sysBranch.position[1], sysBranch.position[2])
                            buildingIcon:setFlippedX(false)
                        end  
                    end
                end)
            else
                branchIcon = SpriteFrameAnim.new(buildingIcon, sysBranch.res, function (sp)
                    local w, h = sp:getSize()

                    buildingIcon:setContentSize(cc.size(w, h))

                    sp:setName("anim_sp")
                    sp:setPosition(buildingIcon:getContentSize().width/2, 0)
                    sp:play()
                    buildingIcon.animSp = sp
                    local shandowIcon = cc.Sprite:createWithSpriteFrameName("intanceBtnUI4_shadow" .. sysBranch.shadow ..  ".png")
                    shandowIcon:setAnchorPoint(0.5, 0.5)
                    shandowIcon:setPosition(buildingIcon:getContentSize().width/2, 0)
                    buildingIcon:addChild(shandowIcon, -1)
                    shandowIcon:setOpacity(120)
                    if sysBranch.flipX == 1 then 
                        sp:setScaleX(-1)
                    else
                        sp:setScaleX(1)
                    end
                    buildingIcon:setScale(sysBranch.scale / 100)
                    buildingIcon:setPosition(sysBranch.position[1], sysBranch.position[2])
                end, relColor)
                buildingIcon:setPosition(sysBranch.position[1], sysBranch.position[2])
            end
        end
    elseif sysBranch.type == SiegeConst.STAGE_BRANCH_TYPE.REWARD_ITEM_HERO or
        sysBranch.type == SiegeConst.STAGE_BRANCH_TYPE.TALK_REWARD then
        mcMgr:loadRes(sysBranch.res, function ()
            if not tolua.isnull(buildingIcon) then
                branchIcon = mcMgr:createViewMC("stop_" .. sysBranch.res, true, false)
                buildingIcon:setContentSize(100, 100)
                buildingIcon:setPosition(sysBranch.position[1], sysBranch.position[2])
                branchIcon:setScale(sysBranch.flipX == 1 and -0.4 or 0.4, 0.4)
                branchIcon:setPosition(buildingIcon:getContentSize().width/2, buildingIcon:getContentSize().height/2)
                buildingIcon:addChild(branchIcon)
            end
        end)
    elseif sysBranch.type == SiegeConst.STAGE_BRANCH_TYPE.REWARD_ITEM or
       sysBranch.type == SiegeConst.STAGE_BRANCH_TYPE.REWARD_HERO or
       sysBranch.type == SiegeConst.STAGE_BRANCH_TYPE.TIP or
       sysBranch.type == SiegeConst.STAGE_BRANCH_TYPE.HERO_ATTR or
       sysBranch.type == SiegeConst.STAGE_BRANCH_TYPE.CHOOSE_REWARD or
       sysBranch.type == SiegeConst.STAGE_BRANCH_TYPE.MARKET then
        branchIcon = cc.Sprite:create("asset/uiother/intance/" .. sysBranch.res .. ".png")
        buildingIcon:setContentSize(cc.size(branchIcon:getContentSize().width, branchIcon:getContentSize().height))
        -- self:addChild(branchIcon,5)
        branchIcon:setPosition(buildingIcon:getContentSize().width/2, buildingIcon:getContentSize().height/2)
        branchIcon:setAnchorPoint(0.5,0.5)
        buildingIcon:setPosition(sysBranch.position[1], sysBranch.position[2])
        buildingIcon:addChild(branchIcon, 1)
        if sysBranch.flipX == 1 then 
            branchIcon:setScaleX(-1)
        else
            branchIcon:setScaleX(1)
        end
    end



    -- if branchIcon ~= nil then
    buildingIcon:setScale(sysBranch.scale / 100)
    return buildingIcon
    -- end
end

--[[
--! @function initStageBranch
--! @desc 初始化关卡支线信息
--! @param  branchInfo 支线信息
--! @param  inSysMainStage 章节地图信息
--! @return 
--]]
function SiegeMapView:initStageBranch(branchInfo, inSysMainStage)
    if inSysMainStage.branchId == nil then return end

    for k,v in pairs(inSysMainStage.branchId) do
        local sysBranch = tab:SiegeBranchStage(v)
        print("v====", v, sysBranch.type)
        if branchInfo[tostring(v)] == nil then
            local buildingIcon = self:createBranchBuildIcon(sysBranch)
            if buildingIcon ~= nil then            
                buildingIcon:setName("branch_icon_" ..  v)
                buildingIcon.stageId = inSysMainStage.id

                self._branchIcon[v] = buildingIcon

                if sysBranch.type == SiegeConst.STAGE_BRANCH_TYPE.WAR or 
                sysBranch.type == SiegeConst.STAGE_BRANCH_TYPE.REWARD_TEAM or 
                sysBranch.type == SiegeConst.STAGE_BRANCH_TYPE.REWARD_ITEM_TEAM or 
                sysBranch.type == SiegeConst.STAGE_BRANCH_TYPE.TALK or
                sysBranch.type == SiegeConst.STAGE_BRANCH_TYPE.TALK_REWARD or
                sysBranch.type == SiegeConst.STAGE_BRANCH_TYPE.REWARD_ITEM_HERO
                then 
                    self._bgMapNode:addChild(buildingIcon,20)
                else
                    self._bgMapNode:addChild(buildingIcon,19)
                end
                registerTouchEvent(buildingIcon, nil, nil, function ()
                    self._touchBack = self:touchBranchEventIcon(buildingIcon, v)
                end)
                buildingIcon:setTouchEnabled(false)

                if inSysMainStage.id <= self._curStageId then 
                    self:updateBranchTalk(sysBranch, buildingIcon) 
                end
            end
        end
    end
end

function SiegeMapView:activeStageBranch(inSysMainStage)
    if inSysMainStage.branchId == nil then 
        return 
    end
    for k,v in pairs(inSysMainStage.branchId) do
        local branchIcon = self:getBranchBuildingById(v)
        if branchIcon ~= nil then 
            local sysBranch = tab:SiegeBranchStage(v)
            -- 个别支线默认隐藏
            if sysBranch.sign == 1 then
                local branchOpenAnim = mcMgr:createViewMC("zhixiankaiqi2_zhixiankaiqi", false)  
                branchOpenAnim:addCallbackAtFrame(34, function()
                    local branchOpenAnim1 = mcMgr:createViewMC("zhixiankaiqi1_zhixiankaiqi", false)
                    branchIcon:getParent():addChild(branchOpenAnim1, 12) 
                    branchOpenAnim1:setPosition(branchIcon:getPositionX(), branchIcon:getPositionY())
                end)
                branchOpenAnim:addCallbackAtFrame(38, function()
                    branchIcon:setVisible(true)
                    self:updateBranchTalk(sysBranch, branchIcon)
                end)
                branchOpenAnim:setPosition(branchIcon:getPositionX(), branchIcon:getPositionY())
                branchIcon:getParent():addChild(branchOpenAnim, 3)
            else
                self:updateBranchTalk(sysBranch, branchIcon)
            end
        end
    end
end

-- 初始化装饰
local defAniTemp = {
    {name = "shouchengdonghua2_shouchengdonghua", pos = {867, 1034}, scale = 1},
    {name = "shouchengdonghua1_shouchengdonghua", pos = {867, 934}, scale = 1},
    {name = "shouchengdonghua3_shouchengdonghua", pos = {987, 794}, scale = -1}
}
function SiegeMapView:initDecorate()
    if self._curStageId == 10005 and not self._sModel:isStagePass(self._curStageId) then
        if self._decorateImg == nil then
            self._decorateImg = cc.Sprite:create("asset/uiother/siege/shape1_siege.png")
            self._decorateImg:setPosition(625, 890)
            self._bgMapNode:addChild(self._decorateImg, 9)
        end
    else
        if self._decorateImg ~= nil then
            self._decorateImg:removeFromParent(true)
        end
    end

    if self._mainData.status == self._sModel.STATUS_PREOVER then
        if self._yanhuaMc == nil then
            self._yanhuaMc = mcMgr:createViewMC("yanhua_gezhongdun", true, false)
            self._yanhuaMc:setPosition(537, 1164)
            self._yanhuaMc:setScale(0.6)
            self._bgMapNode:addChild(self._yanhuaMc, 9)
        end
    else
        if self._yanhuaMc ~= nil then
            self._yanhuaMc:removeFromParent(true)
            self._yanhuaMc = nil
        end
    end

    if self._curStageId == 30001 and self._mainData.status ==  self._sModel.STATUS_DEFEND then
        if self._defAniList == nil then
            self._defAniList = {}
        end
        for i = 1, #defAniTemp do
            local ani = mcMgr:createViewMC(defAniTemp[i].name, true, false)
            ani:setPosition(defAniTemp[i].pos[1], defAniTemp[i].pos[2])
            ani:setScaleX(defAniTemp[i].scale)
            self._bgMapNode:addChild(ani)
            table.insert(self._defAniList, ani)
        end
    else
        if self._defAniList then
            for k, v in pairs(self._defAniList) do
                v:removeFromParent(true)
                v = nil
            end
            self._defAniList = {}
        end
    end
end

-- 初始化标题下方描述信息
function SiegeMapView:initDesTips()
    if self._mainData.status == self._sModel.STATUS_PREDEFEND then  
        self._tipNode:setVisible(true)
        self._tipNode1:setVisible(false)
        local timeLabel = self._tipNode:getChildByFullName("timeLabel")
        timeLabel:setString(self:_formatTimeStr(self._mainData.nextTime))
        timeLabel:setColor(UIUtils.colorTable.ccUIBaseColor2)
        timeLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

        local desLabel = self._tipNode:getChildByFullName("tipLabel")
        desLabel:setString("后敌人反扑，守城战开启")
        desLabel:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
        desLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        local desWidth = desLabel:getContentSize().width
        self:_addCountDown("desTip", function()
            timeLabel:setString(self:_formatTimeStr(self._mainData.nextTime))

            local timeWidth = timeLabel:getContentSize().width
            timeLabel:setPositionX(self._tipNode:getContentSize().width * 0.5 -(timeWidth + desWidth) * 0.5)
            desLabel:setPositionX(timeLabel:getPositionX() + timeWidth)
        end)

        if SystemUtils.loadAccountLocalData("siegeWinTip") ~= 1 then
            self._tipNode:setOpacity(0)
            self._viewMgr:showDialog("siege.SiegeWinTipView", {tipType = 1, callback = function()
                self:playDesTipsAni(self._tipNode)
            end}, true)
        end

    elseif self._mainData.status == self._sModel.STATUS_PREOVER then
        self._tipNode:setVisible(false)
        self._tipNode1:setVisible(true)
        local timeLabel = self._tipNode1:getChildByFullName("timeLabel")
        timeLabel:setString(self:_formatTimeStr(self._mainData.nextTime))
        timeLabel:setColor(UIUtils.colorTable.ccUIBaseColor2)
        timeLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

        local desLabel = self._tipNode1:getChildByFullName("tipLabel")
        desLabel:setString("守城成功，")
        desLabel:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
        desLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        local desWidth = desLabel:getContentSize().width

        local desLabel1 = self._tipNode1:getChildByFullName("tipLabel1")
        desLabel1:setString("后活动结束")
        desLabel1:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
        desLabel1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        local desWidth1 = desLabel1:getContentSize().width

        self:_addCountDown("desTip", function()
            timeLabel:setString(self:_formatTimeStr(self._mainData.nextTime))
 
            local timeWidth = timeLabel:getContentSize().width
            desLabel:setPositionX(self._tipNode1:getContentSize().width * 0.5-(timeWidth + desWidth + desWidth1) * 0.5)
            timeLabel:setPositionX(desLabel:getPositionX() + desWidth)
            desLabel1:setPositionX(timeLabel:getPositionX() + timeWidth)
        end)

        if SystemUtils.loadAccountLocalData("siegeWinTip") ~= 2 and self:prepareViewIsShow() == false then
            self._tipNode1:setOpacity(0)
            self._viewMgr:showDialog("siege.SiegeWinTipView", 
                {tipType = 2, callback = specialize(self.showDefAfterAni, self)}, 
                true
            )
        end
    else 
        self._tipNode:setVisible(false)
        self._tipNode1:setVisible(false)
        self:_addCountDown("desTip", nil)
    end
end

function SiegeMapView:prepareViewIsShow()
    for k , v in pairs(self:getPopViews()) do
        if v:getClassName() == "siege.SiegePrepareView" or v:getClassName() == "siege.SiegeWallReinforceView" then
            return true
        end
    end
    return false
end

-- 播放标题下方描述信息出现动画
function SiegeMapView:playDesTipsAni(inView)
    if inView == nil then return end
    inView:setPositionY(inView:getPositionY() - 200)
    inView:setOpacity(0)
    inView:setScale(0)

    local tempMc = mcMgr:createViewMC("zitiguang_kaiqi", false, true)
    tempMc:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5 + 45)
    self._bgUI:addChild(tempMc, 1000)

    inView:runAction(cc.Sequence:create(
        cc.Spawn:create(cc.EaseBackOut:create(cc.ScaleTo:create(0.3, 1.5)),
            cc.FadeIn:create(0.3)),
        cc.DelayTime:create(0.5),
        cc.Spawn:create(cc.EaseIn:create(cc.MoveBy:create(0.2, cc.p(0, 200)), 2),
            cc.EaseIn:create(cc.ScaleTo:create(0.2, 1), 2))
    ))

end

-- 转换倒计时时间格式
function SiegeMapView:_formatTimeStr(toTime)
    local leftTime = toTime - self._userModel:getCurServerTime()
    if leftTime <= 86400 then
        return TimeUtils.getTimeString(leftTime)
    else
        return TimeUtils:getTimeDisByFormat(leftTime)
    end
end

-- 更新倒计时时间
function SiegeMapView:_addCountDown(key, callback)
    if self._countDownList == nil then
        self._countDownList = {}
    end

    self._countDownList[key] = callback
end

function SiegeMapView:update(dt)
    if self._touchDown then 
        self:updateTouch()
    end

    self._dtTime = self._dtTime + dt
    if self._dtTime >= 1 and self._countDownList ~= nil then
        for k, func in pairs(self._countDownList) do
            if func then
                func()
            end
        end
    end
end

function SiegeMapView:updateTouch()
    self:updateMapPos(self._touchMoveX, self._touchMoveY, true)
end

function SiegeMapView:onTouchBegan(touch)
    self._bgMapNode:stopAllActions()
    self._touchDown = true
    self._touchBeganPositionX = touch:getLocation().x
    self._touchBeganPositionY = touch:getLocation().y

    self._touchBeganScenePositionX = self._bgMapNode:getPositionX()
    self._touchBeganScenePositionY = self._bgMapNode:getPositionY()

    self:touchMoved(self._touchBeganPositionX, self._touchBeganPositionY)
    return true
end

function SiegeMapView:onTouchMoved(touch)
    local x, y = touch:getLocation().x, touch:getLocation().y
    self:touchMoved(x, y)
end

function SiegeMapView:touchMoved(x, y)
    -- 地图移动
    local lastPtx = self._touchBeganPositionX
    local lastPty = self._touchBeganPositionY
    local dx = x - lastPtx
    local dy = y - lastPty
    local nx = self._touchBeganScenePositionX + dx
    local ny = self._touchBeganScenePositionY + dy
    self._touchMoveX = nx
    self._touchMoveY = ny
end

function SiegeMapView:onTouchEnded(touch)
    self._touchBeganScenePositionX = self._bgMapNode:getPositionX()
    self._touchBeganScenePositionY = self._bgMapNode:getPositionY()
    self._touchDown = false
    if math.abs(self._touchBeganPositionX - touch:getLocation().x) <= 10
        or math.abs(self._touchBeganPositionY- touch:getLocation().y) <= 10 then 
        local backR = self:touchIcon(self._touchBeganPositionX, self._touchBeganPositionY)
        if backR == true then 
            return 
        end
    end
    self._touchBeganPositionX = touch:getLocation().x
    self._touchBeganPositionY = touch:getLocation().y
    self:touchMoved(touch:getLocation().x, touch:getLocation().y)

end

function SiegeMapView:distance(pt1x, pt1y, pt2x, pt2y)
    local dx = math.abs(pt2x - pt1x)
    local dy = math.abs(pt2y - pt1y)
    return math.sqrt(dx * dx + dy * dy)
end


-- 矫正坐标
function SiegeMapView:adjustPos(x, y, inScale)
    local nx = x
    local ny = y
    if inScale == nil then 
        inScale  = self._bgMapNode:getScaleX()
    end
    local minX = MAX_SCREEN_WIDTH - self.BGMAP_WIDTH * inScale
    local maxX = 0
    local minY = MAX_SCREEN_HEIGHT - self.BGMAP_HEIGHT * inScale
    local maxY = 0

    if nx > maxX then
      nx = maxX
    end
    if nx < minX then
       nx = minX 
    end
    if ny > maxY then
        ny = maxY
    end
    if ny < minY then
       ny = minY
    end

    return math.floor(nx), math.floor(ny)
end

-- 以某点为屏幕中心
function SiegeMapView:screenToObject(inTempIcon, offset, anim, inCallback, inTime)
    local pt1 = inTempIcon:convertToWorldSpaceAR(cc.p(0, 0))
    local pt =  self._bgMapNode:convertToNodeSpace(cc.p(pt1.x,pt1.y))
    if offset ~= nil then 
        pt.x = pt.x + offset.x 
        pt.y = pt.y + offset.y 
    end
    self:screenToPos(pt.x, pt.y, anim, inCallback, inTime)
end

function SiegeMapView:moveBuildingInScreen(inTempIcon, inCallback)
    self:setLockMap(true)
    local pt = inTempIcon:convertToWorldSpace(cc.p(0, 0))
    local offsetX = 0
    local offsetY = 0
    local flag = 0
    if pt.x < 0 then 
        offsetX = pt.x
    end 
    if (pt.y - 100) < 0 then 
        offsetY = pt.y - 100
    end
    if pt.x + inTempIcon:getContentSize().width > IntanceConst.MAX_SCREEN_WIDTH then 
        offsetX = (pt.x + inTempIcon:getContentSize().width - IntanceConst.MAX_SCREEN_WIDTH)
    end
    if pt.y + inTempIcon:getContentSize().height > IntanceConst.MAX_SCREEN_HEIGHT then 
        offsetY = (pt.y + inTempIcon:getContentSize().height - IntanceConst.MAX_SCREEN_HEIGHT)
    end

    if offsetX ~= 0 or offsetY ~= 0  then 
        local nx = self._bgMapNode:getPositionX() - offsetX 
        local ny = self._bgMapNode:getPositionY() - offsetY
        nx ,ny = self:adjustPos(nx, ny)
        local action1 = cc.MoveTo:create(0.5, cc.p(nx, ny))
        self._bgMapNode:runAction(cc.Sequence:create(action1,
            cc.CallFunc:create(function()
                    
                    if inCallback ~= nil then 
                        inCallback()
                    end
                end)))
        return
    end 
    if inCallback ~= nil then 
        inCallback()
    end
end

-- 以某点为屏幕中心
function SiegeMapView:screenToPos(x, y, anim, callback, inTime)
    if inTime == nil then 
        inTime = 0.5
    end
    local scale = self._bgMapNode:getScale()
    local nx = MAX_SCREEN_WIDTH * 0.5 - x
    local ny = MAX_SCREEN_HEIGHT * 0.5- y
    if anim == true then 
        nx ,ny = self:adjustPos(nx, ny)
        local action1 = cc.MoveTo:create(inTime, cc.p(nx, ny))
        self._bgMapNode:runAction(cc.Sequence:create(action1,
            cc.CallFunc:create(function()
                    if callback ~= nil then 
                        callback()
                    end
                end)))
        return
    end
    self:updateMapPos(nx * scale, ny * scale)
    if callback ~= nil then 
        callback()
    end
end

function SiegeMapView:screenToSize(scale)
    local x = self._bgMapNode:getPositionX() / self._bgMapNode:getScale()
    local y = self._bgMapNode:getPositionY() / self._bgMapNode:getScale()
    self._bgMapNode:setScale(scale)
    local nx = x * scale
    local ny = y * scale
    self:updateMapPos(nx, ny)
end

-- 第一次进入调用, 有需要请覆盖
function SiegeMapView:onShow()
    self:fadeInStageFog(true, 0.5)

    local callbackFunc = function()
        self:initDesTips()
        self:showDefBeforeAni()
    end

    if SystemUtils.loadAccountLocalData("ShowSiegeRuleDetail") == nil then
        SystemUtils.saveAccountLocalData("ShowSiegeRuleDetail", 1)
        self._viewMgr:showDialog("siege.SiegeMapRuleDetailView", {callback = callbackFunc}, true)
    else
        callbackFunc()
    end

    self:updateRealVisible(true)
    local popViews = self:getPopViews()
    if popViews ~= nil and next(popViews) ~= nil then
        for k, view in pairs(popViews) do
            if view and view.updateRealVisible then
                view:updateRealVisible(true)
            end
        end
    end
    self:initBullet()
end

-- 播放守城开启动画
function SiegeMapView:showDefBeforeAni()
    -- 判断是否播放守城开启和结束动画
    local defAniCache = SystemUtils.loadAccountLocalData("SiegeDefAni")
    if self._mainData.status == self._sModel.STATUS_DEFEND and defAniCache == nil then
        self._viewMgr:showView("siege.SiegeMcPlotView", 
            {
                plotId = 6,
                callback = function()
                    self._viewMgr:popView()
                end
            },true)
        SystemUtils.saveAccountLocalData("SiegeDefAni", 1)
    end
end

-- 播放守城结束动画
function SiegeMapView:showDefAfterAni()
    self._viewMgr:lock(-1)
    local defAniCache = SystemUtils.loadAccountLocalData("SiegeDefAni")
    if self._mainData.status == self._sModel.STATUS_PREOVER and defAniCache ~= 2 then
        self._viewMgr:showView("siege.SiegeMcPlotView", 
        {
            plotId = 7,
            callback = function()
                self._viewMgr:popView()
                self._viewMgr:unlock()
                self:playDesTipsAni(self._tipNode1)
            end
        },true)
        SystemUtils.saveAccountLocalData("SiegeDefAni", 2)
    end
end

--[[
--! @function updateCurNodeOffset
--! @desc 更新章地图偏移坐标
--! @return 
--]]
function SiegeMapView:updateCurNodeOffset()
--    local x, y = self._curSelectedNode:getPosition()
--    local size = self._curSelectedNode:getCacheContentSize()
--    self._curOffsetMinX, self._curOffsetMinY = x - size.width/2, y - size.height/2
--    self._curOffsetMaxX = IntanceConst.MAX_VIEW_WIDTH_PIXEL - (x + size.width/2)
--    self._curOffsetMaxY = IntanceConst.MAX_VIEW_HEIGHT_PIXEL - (y + size.height/2)
end

--[[
--! @function updateMapPos
--! @desc 更新地图坐标
--! @param  x
--! @param  y
--! @param  anim 是否动画
--! @return 
--]]
function SiegeMapView:updateMapPos(x, y, anim)
    self._bgMapNode:stopAllActions()
    if anim then
        local _x = self._bgMapNode:getPositionX()
        local _y = self._bgMapNode:getPositionY()
        local nx 
        local ny
        nx = _x + (x - _x) * 0.7
        ny = _y + (y - _y) * 0.7
        self._bgMapNode:setPosition(self:adjustPos(nx, ny))
    else
        self._bgMapNode:setPosition(self:adjustPos(x, y))
    end
end

--[[
--! @function touchIcon
--! @desc 点击事件
--！@param x x坐标
--！@param y y坐标
--! @return 
--]]
function SiegeMapView:touchIcon(x, y)
    if self._usingIcon ~= nil and next(self._usingIcon) ~= nil then 
        if self:touchBuildingIcon(x, y) == true then 
          return true
        end
    end
    if self._branchIcon ~= nil and next(self._branchIcon) ~= nil then 
      if self:touchBranchIcon(x, y) == true then 
        return true
      end
    end

    return false
end

function SiegeMapView:touchBuildingIcon(x, y)
    for k,v in pairs(self._usingIcon) do
        local pt = v:convertToWorldSpace(cc.p(0, 0))
        if pt.x < x and pt.y < y and (pt.x + v:getContentSize().width) > x and (pt.y + v:getContentSize().height) > y  then
            v.eventDownCallback(pt.x, pt.y, v)
            v.eventUpCallback(pt.x, pt.y, v)
            return self._touchBack
        end
    end
    return false
end

function SiegeMapView:touchEventIcon(v, k)
    local stageId = self._sysSection.includeStage[k]
    if self._curStageId > stageId or 
        (self._heroStandByStageId == stageId and self._curStageId == stageId) 
    then 
        self:loadBigIcon(v,k)
        return true
    elseif self._heroStandByStageId ~= stageId and 
        self._curStageId == stageId then
        -- self._locckClick = true 

        self._intanceMcAnimNode:runByName("run")
        self:setLockMap(true)
        self:setHeroRunningCallback(function()
            self:setLockMap(false)
        end)
        self:heroRunningAmin(1)
        return true
    end
    return false
end

--[[
--! @function activeStageBuilding
--! @desc 激活可攻打建筑
--! @return 
--]]
function SiegeMapView:activeStageBuilding()
    self._viewMgr:lock(-1)
    local pointTip = self._intanceMcAnimNode:getChildByName("pointTip")
    if pointTip ~= nil then 
        pointTip:setVisible(false)
    end
    local sysMainStageMap = tab:SiegeMainStageMap(self._heroStandByStageId)
    self._tempPoints = {}
    local maxSize = #sysMainStageMap.point
    local function updatePointState(tempPoint, isLastPoint)
        if tempPoint == nil then 
            return
        end
        tempPoint:setCascadeOpacityEnabled(true, true)
        tempPoint:setOpacity(0)
        table.insert(self._tempPoints, tempPoint)
        local delay = cc.DelayTime:create(0.5)
        local action1 = cc.FadeIn:create(0.2)
        local seqs
        if isLastPoint then
            local call = cc.CallFunc:create(function()
                self._viewMgr:unlock()
                if self._completeCallBack ~= nil then 
                    self._completeCallBack()
                    self._completeCallBack = nil
                end

                if self._buildingFog[self._curStageId] ~= nil then 
                    for h,g in pairs(self._buildingFog[self._curStageId]) do
                        local action2 = cc.FadeOut:create(0.3 * h)
                        local call1 = cc.CallFunc:create(function()
--                            g:removeFromParent()
                        end)
                        g:runAction(cc.Sequence:create(action2, call1))
                    end
                    self._buildingFog[self._curStageId] = nil
                end

                local tempPoint1 = tempPoint:getChildByName("tempPoint1")
                if tempPoint1 ~= nil then 
                    local ac1 = cc.DelayTime:create(0.2)
                    local ac2 = cc.FadeTo:create(0.5, 0)
                    local ac3 = cc.ScaleTo:create(0.5, 1.5, 1.5)
                    local ac4 = cc.CallFunc:create(function() 
                        tempPoint1:setOpacity(255)
                        tempPoint1:setScale(1)
                    end)
                    tempPoint1:runAction(cc.RepeatForever:create(cc.Sequence:create(ac1, cc.Spawn:create(ac2, ac3), ac4)))
                end
            end)
            seqs = cc.Sequence:create(delay, action1, call)
        else 
            seqs = cc.Sequence:create(delay, action1)                   
        end
        tempPoint:runAction(seqs)
    end

    local curbuildView = self:getStageBuildingById(self._curStageId)

    local isLastPoint = false
    for k,v in pairs(sysMainStageMap.point) do
        local tempPoint
        if k ~= 1  then 
            tempPoint = cc.Sprite:createWithSpriteFrameName("siege_point2.png")
            tempPoint:setPosition(v[1], v[2])
            tempPoint:setName("temp_point" .. k)
            self._bgMapNode:addChild(tempPoint,100)
        else
            self._intanceMcAnimNode:setVisible(true)
            tempPoint = cc.Sprite:createWithSpriteFrameName("siege_point2.png")
            tempPoint:setPosition(v[1], v[2])
            tempPoint:setName("temp_point" .. k)
            self._bgMapNode:addChild(tempPoint,100)
        end
        if curbuildView == nil and k == maxSize then 
            isLastPoint = true
        end
        updatePointState(tempPoint, isLastPoint)
    end

    -- 特殊X点特殊处理 在建筑中间
    if curbuildView ~= nil then
        local tempPoint = cc.Sprite:createWithSpriteFrameName("siege_point1.png")
            local tempPoint1 = cc.Sprite:createWithSpriteFrameName("siege_point1.png")
            tempPoint1:setAnchorPoint(0.5, 0.5)
            tempPoint1:setName("tempPoint1")
            tempPoint1:setPosition(tempPoint:getContentSize().width/2, tempPoint:getContentSize().height/2)
        tempPoint:addChild(tempPoint1)
        tempPoint:setName("temp_point" .. (maxSize + 1))
        tempPoint:setPosition(curbuildView:getPositionX(), curbuildView:getPositionY() + curbuildView:getContentSize().height/2)
        self._bgMapNode:addChild(tempPoint,100)
        updatePointState(tempPoint, true)
    end
end

--[[
--! @function heroRunningAmin
--! @desc 英雄跑向建筑
--！@param inIndex 地图绿点Index
--! @return 
--]]
function SiegeMapView:heroRunningAmin(inIndex)
    local sysMainStageMap = tab:SiegeMainStageMap(self._heroStandByStageId)
    local sysMapData = sysMainStageMap.point[inIndex]
    local maxSize = #sysMainStageMap.point
    -- local delay = cc.DelayTime:create(1)
    self._tempPoints = nil
    local function tempCallback()
        local tempPoint = self._bgMapNode:getChildByName("temp_point" .. inIndex)
        -- 传送门特殊处理
        if tempPoint ~= nil then 
            tempPoint:removeFromParent()
        end
        -- 方向更改
        if sysMapData[3] == 1 then
            self._intanceMcAnimNode:setFlipX(false)
        else
            self._intanceMcAnimNode:setFlipX(true)
        end
        --  最后一个点逻辑处理
        if inIndex == maxSize then
            -- 特殊处理GENERAL类型的X
            local tempPoint = self._bgMapNode:getChildByName("temp_point" .. (inIndex +1))
            if tempPoint ~= nil then 
                tempPoint:removeFromParent()
            end
            self._intanceMcAnimNode:runStandBy()
            self:updateAminPos(sysMapData)

            -- 更改英雄实际站位
            self._heroStandByStageId = self._curStageId

--            local curSectionId = self._intanceModel:getCurMainSectionId()
            local curSectionId = 1

            local function finishCallback ()
                if self._heroRunningCallback ~= nil then 
                    self._heroRunningCallback()
                    self._heroRunningCallback = nil
                end
                if self._sysSection ~= nil and curSectionId == self._sysSection.id then
                    local curSysMainStageMap = tab:SiegeMainStageMap(self._curStageId)
--                    dump(curSysMainStageMap, "test", 10)

                    if curSysMainStageMap.plot ~= nil then
                        self._viewMgr:showView("siege.SiegeMcPlotView", 
                            {
                                plotId = curSysMainStageMap.plot,
                                callback = function()
                                    self._viewMgr:popView()
                                    local buildingIcon = self._bgMapNode:getChildByName("building_icon" .. self._curStageId)
                                    self:loadBigIcon(buildingIcon, buildingIcon.showIndex)
                                end
                            },true)

                    elseif curSysMainStageMap.story ~= nil then
                        self._storyView = self._viewMgr:enableTalking(curSysMainStageMap.story, "", function()
                            local buildingIcon = self._bgMapNode:getChildByName("building_icon" .. self._curStageId)
                            self:loadBigIcon(buildingIcon, buildingIcon.showIndex)
                        end)
                    else
                        local buildingIcon = self._bgMapNode:getChildByName("building_icon" .. self._curStageId)
                        self:loadBigIcon(buildingIcon, buildingIcon.showIndex)
                    end
                end

            end
            local pointTip = self._intanceMcAnimNode:getChildByName("pointTip")
            if pointTip ~= nil then 
                pointTip:setVisible(true)
            end
--            if lastPointType == IntanceConst.LAST_POINT_TYPE.PORTAL then
--                ScheduleMgr:delayCall(500, self, function()
--                    audioMgr:playSound("telptin")
--                end) 
--                local anim1 = mcMgr:createViewMC("shanlan_intanceportal", false, true)
--                anim1:setPosition(tempPoint:getPositionX(), tempPoint:getPositionY() + tempPoint:getContentSize().height/2)
--                self._bgMapNode:addChild(anim1, 9999)
--                self._intanceMcAnimNode:runAction(cc.Sequence:create(cc.FadeOut:create(0.48), cc.CallFunc:create(finishCallback)))
--            else
                finishCallback()
--            end

            return
        end
        self:heroRunningAmin(inIndex + 1)
    end
    if inIndex == 1 then 
        tempCallback()
        return
    end
    local action1 = cc.MoveTo:create(0.2, cc.p(sysMapData[1], sysMapData[2]))
    local callFunc = cc.CallFunc:create(tempCallback)
    self._intanceMcAnimNode:runByName("run")
    self._intanceMcAnimNode:runAction(cc.Sequence:create(action1, callFunc))
end


--[[
--! @function loadBigIcon
--! @desc 加载大图
--! @param  inView 小图相关view
--! @param  inIndex 副本章节索引
--! @return 
--]]
function SiegeMapView:loadBigIcon(inView, inIndex)
    local stageId = self._sysSection.includeStage[inIndex]
    local sysMainStageMap = tab:SiegeMainStageMap(stageId)

    local showIcon = ccui.ImageView:create()
    showIcon:setContentSize(cc.size(150, 150))

    if sysMainStageMap.flipX == 1 then 
      showIcon:setFlippedX(true)
    end
    if sysMainStageMap.flipY == 1 then 
      showIcon:setFlippedY(true)
    end
    
    showIcon:setName("show_icon")
    inView:addChild(showIcon)

    if sysMainStageMap.img then
        showIcon:loadTexture("asset/uiother/siege/" .. sysMainStageMap.img .. ".png")
        showIcon.isBigIcon = true
    else
        showIcon:loadTexture("globalImageUI6_meiyoutu.png", 1)
        showIcon.isBigIcon = false
    end
    showIcon:setAnchorPoint(cc.p(0.5,0))
    showIcon:setPosition(inView:getContentSize().width/2 + 8, -2)
    -- showIcon:setVisible(false)
    showIcon:setScale(sysMainStageMap.rate or 0.463)
    showIcon.notError = 1

    for k,v in pairs(self._branchIcon) do
        -- cachevisible的原因是因为某些支线增加了默认隐藏
        v.cacheVisible = v:isVisible()
        v:setVisible(false)
        if v.talk ~= nil then 
            v.talk:setVisible(false)
        end
    end

    self:showBuildingBubble(false)

    -- 攻城战标识隐藏
    local siegeTip = inView:getChildByName("siegeTip")
    if siegeTip ~= nil then 
        siegeTip:setVisible(false)
    end
    
    local anim = true
    if self._quickStageId == stageId 
        and stageId < self._curStageId then 
        anim = false
        self._quickStageId = nil
    end

    -- 建筑光效
--    local buildingAnim = mcMgr:createViewMC("jianzhuguangxiao_intancebuildingeffect-HD", true, false)
--    buildingAnim:setCascadeOpacityEnabled(true, true)
--    buildingAnim:setOpacity(0)
--    buildingAnim:setPosition(showIcon:getContentSize().width/2, 550)
--    showIcon:addChild(buildingAnim, -1)
--    buildingAnim:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.FadeIn:create(0.5)))
--    buildingAnim.notError = 1
    -- 暂时隐藏英雄头顶的光标
    if self._intanceMcAnimNode ~= nil then
        local pointTip = self._intanceMcAnimNode:getChildByName("pointTip")
        pointTip:setVisible(false)
    end

    -- 关闭建筑面板的回调
    self:showStageInfo(showIcon, sysMainStageMap.id, anim, function(inState)

    end)

    self._closeStageFun = function(inState)
        if inState == 1 then 
            -- 增加noterror 是因为buildingAnim 有可能被提前remove掉了，会导致这里继续执行runAction
--            if buildingAnim ~= nil and buildingAnim.notError == 1 then
--                buildingAnim:runAction(cc.FadeOut:create(0.4))
--            end
            return
        end
        if self._intanceMcAnimNode ~= nil then
            local pointTip = self._intanceMcAnimNode:getChildByName("pointTip")
            pointTip:setVisible(true)  
        end
        if showIcon ~= nil and showIcon.notError == 1 then
            showIcon:removeFromParent()
        end

        if sysMainStageMap.img then
            self._viewMgr:removeTexture(self:getClassName(), "asset/uiother/siege/" .. sysMainStageMap.img .. ".png")
        end
--        -- 星星相关处理
--        self:updateBuildingStar(stageInfo.star, sysMainStageMap.id, starBg)
        for k,v in pairs(self._branchIcon) do
            if v.cacheVisible == true then
                v:setVisible(true)
                if v.talk ~= nil then 
                    v.talk:setVisible(true)
                end
            end
        end

        self:showBuildingBubble(true)

        -- 攻城战提示
        local siegeTip = inView:getChildByName("siegeTip")
        if siegeTip ~= nil then 
            siegeTip:setVisible(true)
        end
    end
end

--[[
--! @function showStageInfo
--! @desc 展示章节信息
--! @param  inView 展示icon
--! @param  inStageId 副本id
--! @param  callback 回调
--! @param  anim 是否动画
--! @return 
--]]
function SiegeMapView:showStageInfo(inView, inStageId, inAmin, callback)
    local tarPoint = inView.isBigIcon and cc.p(0, 0) or cc.p(0, 400)
    local pt = inView:convertToWorldSpaceAR(tarPoint)
    pt.y = pt.y + (inView:getContentSize().height * inView:getScale() * 0.5)

    self:setLockMap(true)
    ScheduleMgr:delayCall(0, self, function()
        self._sectionNodeCallback = callback

        self:showPoint(pt.x, pt.y, 
            function()
                self._serverMgr:sendMsg("SiegeServer", "getStageInfo", {stageId = inStageId}, true, {},function (result,errorCode)
                        -- dump(result,"====result=====")
                        if errorCode ~= 0 then
                            self._SiegePrepareView = self._viewMgr:showDialog("siege.SiegePrepareView", {
                                stageId = inStageId,
                                closeCallback = specialize(self.stageClose, self),
                                battleCallback = specialize(self.battleCallBack, self)
                            })
                        end 
                end)
                self._bgUI:setVisible(false)
            end, inAmin, inView.isBigIcon)
    end)
end

-- 关卡信息界面关闭回调
function SiegeMapView:stageClose(isClose)
    if self._curStageId ~= nil then 
        if self._closeStageFun ~= nil then 
            self._closeStageFun(1)
        end

        self._bgUI:setVisible(true)
        local action1 = cc.MoveTo:create(0.4, cc.p(self._showPointBeginX, self._showPointBeginY))
        local action2 = cc.ScaleTo:create(0.4, 1, 1)
        self._bgMapNode:runAction(cc.Sequence:create(cc.Spawn:create(action1,action2),
            cc.CallFunc:create(function()
                if self._closeStageFun ~= nil then 
                    self._closeStageFun(2)
                end

                self:updateCurNodeOffset()
                self:updateBuildingBubble()

                self:updateMapState()
                self:setLockMap(false)
            end)))
    end
end

-- 战后更新地图状态
function SiegeMapView:updateMapState()
    if self._curStageId < 10005 and self._curStageId < self._sModel:getCurStageId() then
        -- 判读关卡是否已被其他玩家攻打超过两个城
        if self._sModel:getCurStageId() - self._curStageId > 1 then
            self._curStageId = self._sModel:getCurStageId()
            self._serverMgr:sendMsg("SiegeServer", "getStagePlayer", {stageId = self._curStageId}, true, {}, function(result)
                self:reflashUI(result)
                self:fadeInStageFog(false)
                self:showDefBeforeAni()
            end)

        else
            local positionIcon = self:getStageBuildingById(self._curStageId)
            -- 偏移位置
            local offset = cc.p(0, 0)
            local nextView = self:getStageBuildingById(self._sModel:getCurStageId())
            if nextView ~= nil then 
                local x = (nextView:getPositionX() - positionIcon:getPositionX()) /2
                local y = (nextView:getPositionY() + nextView:getContentSize().height/2 - positionIcon:getPositionY() + positionIcon:getContentSize().height/2) /2
                offset = cc.p(x, y)
            end
            self:screenToObject (positionIcon, offset, true, function()
                self._curStageId = self._sModel:getCurStageId()

                local sysMainStage = tab:SiegeMainStage(self._curStageId)
                self:activeStageBranch(sysMainStage)
                self:activeStageBuilding()
                self:initAttackState()

                self:initDecorate()

                self:showWinTip()

                self._serverMgr:sendMsg("SiegeServer", "getStagePlayer", {stageId = self._curStageId}, true, {}, function(result)
                    self:initOtherPlayer(result)
                end)
            end)
        end

    elseif self._curStatus ~= self._mainData.status and (self._curStageId == 10005 or self._curStageId == 30001) then
        self._curStatus = self._mainData.status
        local sysMainStage = tab:SiegeMainStage(self._curStageId)
        self:activeStageBranch(sysMainStage)

        self:initAttackState()
        self:initDecorate()
        self:initOtherPlayer()
    end

    if self._curStageId == 10005 and self._mainData.status >= self._sModel.STATUS_PREDEFEND then
        self:initDesTips()
    end

    if self._curStageId == 30001 and self._mainData.status >= self._sModel.STATUS_PREOVER then
        self:initDesTips()
        self:initDecorate()
    end

    self:updateTaskState()
end


-- 播放前四小关攻陷提示
function SiegeMapView:showWinTip()
    local stageName = nil
    local cacheId = SystemUtils.loadAccountLocalData("SiegeWinTipId")
    if self._curStageId > 10001 
        and self._curStageId <= 10005 
        and (cacheId == nil or cacheId < self._curStageId - 1 )
    then
        stageName = tab:SiegeMainStage(self._curStageId - 1).sectionName
    else
        return
    end

    SystemUtils.saveAccountLocalData("SiegeWinTipId",  self._curStageId - 1)

    local fallTip = nil 

    if self._bgUI.fallTip ~= nil then
        fallTip = self._bgUI.fallTip
        fallTip:removeAllChildren(true)
    else
        fallTip = cc.Sprite:createWithSpriteFrameName("siege_tipBg1.png")
        fallTip:setAnchorPoint(0.5, 0.5)
        fallTip:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
        self._bgUI.fallTip = fallTip
        self._bgUI:addChild(fallTip, 1000)
    end

    local label = cc.Label:createWithTTF("成功攻占" .. lang(stageName), UIUtils.ttfName, 30)
    label:setColor(UIUtils.colorTable.ccUIBasePromptColor)
    label:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    label:setPosition(fallTip:getContentSize().width*0.5, fallTip:getContentSize().height*0.5 - 3)
    fallTip:addChild(label)

    fallTip:setCascadeOpacityEnabled(true, true)
    fallTip:setOpacity(0)
    fallTip:setScale(0)
    fallTip:runAction(cc.Sequence:create(
        cc.EaseIn:create(cc.Spawn:create(
                cc.FadeIn:create(0.2),
                cc.ScaleTo:create(0.2, 1, 1)
            ), 0.1),
        cc.DelayTime:create(1),
        cc.Spawn:create(
                    cc.FadeOut:create(0.1),
                    cc.ScaleTo:create(0.1, 0, 0)
                ),
        cc.DelayTime:create(0.5),
        cc.CallFunc:create(function()
--            self._actionCityFall = false
--            self:activeFallTipShow()
        end)
        ))
    local tempMc = mcMgr:createViewMC("zitiguang_kaiqi", false, true)
    tempMc:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
    self._bgUI:addChild(tempMc, 1000)
end

-- 战后回调
function SiegeMapView:battleCallBack()


end

--[[
--! @function showPoint
--! @desc 放大展示某一点
--! @param  x 
--! @param  y
--! @param  callback
--! @param  amin 是否缓动
--! @param  isScale 是否放大
--! @return 
--]]
function SiegeMapView:showPoint(x, y, callback, amin, isScale)
    print("x,y===================", x, y)
    self._curOffsetMinX = 0
    self._curOffsetMinY = 0
    self._curOffsetMaxX = 0
    self._curOffsetMaxY = 0

    local scale = isScale and 1.6 or 1
    self._showPointBeginX = self._bgMapNode:getPositionX() 
    self._showPointBeginY = self._bgMapNode:getPositionY() 

    local moveToX = ADOPT_IPHONEX and MAX_SCREEN_WIDTH * 0.5 or SiegeMapView.SHOW_POINT_X
    if not isScale and ADOPT_IPHONEX then
        moveToX = MAX_SCREEN_WIDTH * 0.35
    end
    local nx = self._bgMapNode:getPositionX() * scale - ((scale - 1) * x) + (moveToX - x )
    local ny = self._bgMapNode:getPositionY()  * scale - ((scale - 1) * y) + (SiegeMapView.SHOW_POINT_Y - y )

--    nx = (SiegeMapView.SHOW_POINT_X - x ) * scale
--    ny = (SiegeMapView.SHOW_POINT_Y - y ) * scale

    local runTime = 0.4
    if amin == false then 
        runTime = 0
    end
    print("nx, ny==================", nx, ny)
    local action1 = cc.MoveTo:create(runTime, cc.p(nx, ny))
    local action2 = cc.ScaleTo:create(runTime, scale, scale)

    self._bgMapNode:runAction(cc.Sequence:create(cc.Spawn:create(action1,action2),
        cc.CallFunc:create(function()
                if callback ~= nil then
                    callback()
                end
            end)))
end


function SiegeMapView:setHeroRunningCallback(inCallback)
    self._heroRunningCallback = inCallback
end

function SiegeMapView:runMagicEyeAction(inShowStageId, inBranchId, inCallback)
    audioMgr:playSound("DoomEye")
    self:setLockMap(true)

    local showTip =  true
    for k,v in pairs(self._sysSection.includeStage) do
        local sysMainStageMap = tab:SiegeMainStageMap(v)
        if self._buildingFog[sysMainStageMap.id] ~= nil then
            showTip = false
            break
        end
    end

    if showTip then 
        self:setLockMap(false)
        self._viewMgr:showTip(lang("TIPS_MAGICEYES"))
        if inCallback ~= nil then 
            inCallback()
        end
        return
    end

    local sysBranchStage = tab:SiegeBranchStage(inBranchId)
    local magicEyeMc = mcMgr:createViewMC("moyan_intancemagiceye", false, false, function(_, sender)
        sender:setVisible(false)
    end, nil, nil, false)
    magicEyeMc:setPosition(self:getContentSize().width - 100, 0)
    self._bgMapNode:addChild(magicEyeMc, 9999)
    magicEyeMc:setVisible(false)
    magicEyeMc:stop()
    
    local cachePointX = MAX_SCREEN_WIDTH * 0.5 - self._bgMapNode:getPositionX()
    local cachePointY = MAX_SCREEN_HEIGHT * 0.5 - self._bgMapNode:getPositionY()
    self:screenToPos(sysBranchStage.position[1], sysBranchStage.position[2], true, function()
        magicEyeMc:setPosition(sysBranchStage.position[1], sysBranchStage.position[2])
        magicEyeMc:setVisible(true)
        magicEyeMc:gotoAndPlay(1)
        local fogStageId = tab:SiegeBranchStage(inBranchId).fogOpen == 1 and inShowStageId + 1 or inShowStageId
        local fogIcons = self._buildingFog[fogStageId]
        if fogIcons ~= nil then 
            for k,v in pairs(fogIcons) do
                v:runAction(
                    cc.Sequence:create(
                            cc.FadeOut:create(0.5), 
                            cc.DelayTime:create(2.5),
                            cc.FadeIn:create(0.5)
                        )
                )
            end
        end
        self:runAction(cc.Sequence:create(
                                cc.DelayTime:create(1.8),                                    
                                cc.CallFunc:create(function()
                                    magicEyeMc:clearCallbacks()
                                    magicEyeMc:stop()
                                    magicEyeMc:removeFromParent()
                                    self:screenToPos(cachePointX, cachePointY,true,function()
                                        self:setLockMap(false)
                                        if inCallback ~= nil then 
                                            inCallback()
                                        end
                                    end, 0.5)
                                end)
        ))
    end, 0.5)    
end

--[[
--! @function moveToBranchBuilding
--! @desc 移动到支线建筑位置
--! @return 
--]]
function SiegeMapView:moveToBranchBuilding(inBranchId)
    -- IntanceSectionNode
    local branchBuild = self:getBranchBuildingById(inBranchId)
    if branchBuild == nil then 
        return
    end
    self:setLockMap(true)
    self:screenToObject(branchBuild, cc.p(0,0), true, function()
        self:setLockMap(false)
    end, 0.5)
    
end

--[[
--! @function releaseBuildingIcon
--! @desc 释放建筑图标
--! @return 
--]]
function SiegeMapView:releaseBuildingIcon()
    -- 建筑数据初始化
    local buildingIcon 
    while(true) do
        if #self._usingIcon <= 0 then 
            break
        end
        buildingIcon = self._usingIcon[#self._usingIcon]
        buildingIcon:setVisible(false)
        buildingIcon:setEnabled(false)
        buildingIcon:removeAllChildren()
        table.insert(self._freeingIcon,buildingIcon)
        table.remove(self._usingIcon)
    end
end

--[[
--! @function releaseFogIcon
--! @desc 释放迷雾图标
--! @return 
--]]
function SiegeMapView:releaseFogIcon()
    -- 迷雾cache初始化
    local fogIcon 
    while(true) do
        if #self._usingFog <= 0 then 
            break
        end
        fogIcon = self._usingFog[#self._usingFog]
        fogIcon:setVisible(false)
        fogIcon:setOpacity(255)
        table.insert(self._freeingFog, fogIcon)
        table.remove(self._usingFog)
    end
    self._buildingFog = {}
end

--[[
--! @function releaseBranchIcon
--! @desc 释放支线图标
--! @return 
--]]
function SiegeMapView:releaseBranchIcon()
    for k,v in pairs(self._branchIcon) do
        self:removeBranchIcon(k, false, false)
    end
    self._branchIcon = {}
end 

function SiegeMapView:setLockMap(inLock)
    if inLock then
        self._lockCount = self._lockCount + 1
        self:lockTouch()
        print("lock map lockCount========", self._lockCount)
    else
        self._lockCount = self._lockCount - 1
        self:unLockTouch()
        print("unlock map lockCount========", self._lockCount)
    end
end

function SiegeMapView:unLockTouch()
    -- self._isLouck = false
    self._touchDispatcher:resumeEventListenersForTarget(self._bgMapNode,false)
end

function SiegeMapView:lockTouch()
    -- self._isLouck = true
    self._touchDispatcher:pauseEventListenersForTarget(self._bgMapNode,false)
end

-- 成为topView会调用, 有需要请覆盖
function SiegeMapView:onTop()
    self:updateRealVisible(true)
    local popViews = self:getPopViews()
    if popViews ~= nil and next(popViews) ~= nil then
        for k, view in pairs(popViews) do
            if view and view.updateRealVisible then
                view:updateRealVisible(true)
            end
        end
    end
    self:updateBuildingState()

    self:setLockMap(false)
end

-- 被其他View盖住会调用, 有需要请覆盖
function SiegeMapView:onHide()
    self:setLockMap(true)
end

function SiegeMapView:updateBuildingState()
    if self._curStageId < self._sModel:getCurStageId() and self._curStageId < 10005 then
        local curBuilding = self:getStageBuildingById(self._curStageId)
        if curBuilding.stateNode ~= nil then
            curBuilding.stateNode:removeFromParent(true)
            curBuilding.stateNode = nil
        end
        local completeIcon = cc.Sprite:createWithSpriteFrameName("siege_breached.png")
        completeIcon:setPosition(curBuilding:getContentSize().width * 0.5 + 21, curBuilding:getContentSize().height + 20)
        curBuilding:addChild(completeIcon, 1)

        self:initOtherPlayer()
    end

    if self._curStageId == 10005 then
        local curBuilding = self:getStageBuildingById(self._curStageId)

        if curBuilding.stateNode then
            local percent = self._mainData.blood5 / tab:SiegeMainStage(self._curStageId).hp * 100
            curBuilding.stateNode.hpBar:setPercent(percent)
            curBuilding.stateNode.rateLabel:setString(self:numberFormat(self._mainData.blood5) .. "/" .. self:numberFormat(tab:SiegeMainStage(self._curStageId).hp))
        end

        if self._mainData.status >= self._sModel.STATUS_PREDEFEND then
            local completeIcon = cc.Sprite:createWithSpriteFrameName("siege_breached1.png")
            completeIcon:setPosition(curBuilding:getContentSize().width * 0.5 + 20, curBuilding:getContentSize().height * 0.5 - 19)
            curBuilding:addChild(completeIcon, 1)

            self:initOtherPlayer()
        end
    end


    if self._curStageId == 30001 then
        local curBuilding = self:getStageBuildingById(self._curStageId)
        if curBuilding.stateNode then
            local percent = self._mainData.waves / tab:SiegeMainStage(self._curStageId).enemyAmount * 100
            curBuilding.stateNode.hpBar:setPercent(percent)
            curBuilding.stateNode.rateLabel:setString("剩余波数" .. self:numberFormat(self._mainData.waves))
        end
    end
end

function SiegeMapView:numberFormat(damageValue)
    local damage = damageValue
    if tonumber(damageValue) > 99999 then
        if tonumber(damageValue) > 99999999 then
            damage = tonumber(string.format("%0.2f",damageValue/100000000)).."亿"
        else
            damage = tonumber(string.format("%0.2f",damageValue/10000)).."万"
        end
    end
    return damage
end

-- 更新城池上的气泡
function SiegeMapView:updateBuildingBubble()
    for _, bubble in pairs(self._bubbleList) do
        bubble:stopAllActions()
        bubble:removeFromParent(true)
        bubble = nil
    end
    self._bubbleList = {}
    local tabStageMap = tab.siegeMainStageMap
    for k,v in pairs(self._sysSection.includeStage) do
        local popPath = nil 
        if self._sModel:checkNoticeAward(v) then
            popPath = "qipao_lingqu"
            
        elseif self._sModel:checkWallBuildMaterial(v) and self._curStageId == 30001 then
            popPath = "qipao_build"
        end
        if popPath ~= nil then
            local bubble = UIUtils:addShowBubble(nil, {pic = popPath, position = tabStageMap[v].bubble})
            self._bgMapNode:addChild(bubble, 102)
            table.insert(self._bubbleList, bubble)

            local popViews = self:getPopViews()
            if popViews ~= nil and next(popViews) ~= nil then
                bubble:setVisible(false)
            end
        end
    end
end

-- 是否显示气泡
function SiegeMapView:showBuildingBubble(bool)
    for _, bubble in pairs(self._bubbleList) do
        bubble:setVisible(bool)
    end
end

--[[
--! @function updateBranchEffect
--! @desc 更新支线特效
--！@param inStageId 关卡id
--! @return 
--]]
function SiegeMapView:updateBranchEffect(inStageId)
    local sysMainStage = tab:SiegeMainStage(inStageId)
    if sysMainStage.branchId == nil then 
        return 
    end
    for k,v in pairs(sysMainStage.branchId) do
        local sysBranch = tab:SiegeBranchStage(v)
        local branchIcon = self._branchIcon[v]
        if branchIcon ~= nil and 
            sysBranch.effect ~= nil then
            local effectName = sysBranch.effect .. "_brancheffect"
            if branchIcon:getChildByName(effectName) == nil then 
                local amin1 = mcMgr:createViewMC(effectName, true)
                amin1:setPosition(branchIcon:getContentSize().width/2, branchIcon:getContentSize().height/2)
                if sysBranch.type ~= SiegeConst.STAGE_BRANCH_TYPE.REWARD_HERO then 
                    amin1:setScale(3.0)
                end
                amin1:setName(effectName)
                branchIcon:addChild(amin1,99)
                amin1:setCascadeOpacityEnabled(true, true)
                amin1:setOpacity(0)
                amin1:runAction(cc.FadeIn:create(1))
                if sysBranch.type == SiegeConst.STAGE_BRANCH_TYPE.REWARD_ITEM or
                   sysBranch.type == SiegeConst.STAGE_BRANCH_TYPE.REWARD_HERO or
                   sysBranch.type == SiegeConst.STAGE_BRANCH_TYPE.TIP then 
                    local amin1 = branchIcon:getChildByName("guang")
                    if amin1 == nil then 
                        amin1 = mcMgr:createViewMC("zhixianwuopintishi_brancheffect", true)
                        if sysBranch.type == SiegeConst.STAGE_BRANCH_TYPE.TIP then 
                            amin1:setPosition(branchIcon:getContentSize().width/2 + 30, branchIcon:getContentSize().height/2 - 100)
                            amin1:setScale(3.0)
                        elseif sysBranch.type == SiegeConst.STAGE_BRANCH_TYPE.REWARD_HERO then
                            amin1:setPosition(branchIcon:getContentSize().width/2, branchIcon:getContentSize().height/2 - 20)
                        else
                            amin1:setPosition(branchIcon:getContentSize().width/2, branchIcon:getContentSize().height/2)
                            amin1:setScale(3.0)
                        end
                        amin1:setCascadeOpacityEnabled(true, true)
                        amin1:setOpacity(0)
                        amin1:runAction(cc.FadeIn:create(1))
                        amin1:setName("guang")
                        branchIcon:addChild(amin1, -1)      
                    end
                end 
            end    
        end
    end
end

function SiegeMapView:showBranchTalk(inSysBranch, inBuildingIcon, inBranchDialogue, inPt)
    inBuildingIcon.talkIndex = inBuildingIcon.talkIndex + 1
    if inBuildingIcon.talkIndex > #inBranchDialogue.words then 
        inBuildingIcon.talkIndex = 1
    end
    local talkContent = inBranchDialogue.words[inBuildingIcon.talkIndex]
    local labTalk = nil 
    local talkBg = nil
    if inBuildingIcon.talk == nil then 
        talkBg = cc.Sprite:createWithSpriteFrameName("globalImageUI5_sayBg.png")
        talkBg:setPosition(inPt.x, inPt.y)
        talkBg:setAnchorPoint(0, 0)
        labTalk = cc.Label:createWithTTF(lang(talkContent), UIUtils.ttfName, 16, cc.size(100, 0))
        labTalk:setColor(UIUtils.colorTable.ccUIBasePromptColor)
        labTalk:setPosition(68, 45)
        labTalk:setAnchorPoint(0.5, 0.5)
        labTalk:setDimensions(100, 0)
        labTalk:setVerticalAlignment(1)
        labTalk:setHorizontalAlignment(1)
        labTalk:setName("labTalk")
        talkBg:addChild(labTalk)
        inBuildingIcon:getParent():addChild(talkBg, 102)
        inBuildingIcon.talk = talkBg
    else
        talkBg = inBuildingIcon.talk
        labTalk = talkBg:getChildByName("labTalk")
    end
    talkBg:stopAllActions()
    talkBg:setVisible(inBuildingIcon:isVisible())

    labTalk:setString(lang(talkContent))
    labTalk:setScale(0.8)
    if (labTalk:getContentSize().height * labTalk:getScaleX())> (30* labTalk:getScaleX()) then
        labTalk:setScale(0.8)
    else
        labTalk:setScale(1)
    end
    labTalk:setPosition(talkBg:getContentSize().width/2, talkBg:getContentSize().height/2+ 10)
    talkBg:setScale(1)

    if inSysBranch.flipX == 1 then 
        talkBg:setFlipX(true)
    end
    -- talkBg:setCascadeOpacityEnabled(true, true)
    talkBg:runAction(cc.Sequence:create(
        -- cc.ScaleTo:create(0.15, 1.2), 
        -- cc.ScaleTo:create(0.05, 1),
        cc.DelayTime:create(3), 
        cc.CallFunc:create(function() talkBg:setScale(0) end), 
        cc.DelayTime:create(3),
        cc.CallFunc:create(function() 
            if inSysBranch.type == SiegeConst.STAGE_BRANCH_TYPE.TALK_REWARD
            then
                self:showBranchTalk(inSysBranch, inBuildingIcon, inBranchDialogue, inPt) 
            end
            end)
        ))
end



function SiegeMapView:showBranchDieTalk(inSysBranch, inBuildingIcon, inBranchDialogue, inPt, callback, inAnim)
    inBuildingIcon.talkIndex =  1
    local talkContent = inBranchDialogue.words[inBuildingIcon.talkIndex]
    local labTalk = nil
    local talkBg = nil
    if inBuildingIcon.talk == nil then 
        talkBg = cc.Sprite:createWithSpriteFrameName("globalImageUI5_sayBg.png")
        talkBg:setPosition(inPt.x, inPt.y)
        talkBg:setAnchorPoint(0, 0)
        inBuildingIcon:getParent():addChild(talkBg, 102)
        labTalk = cc.Label:createWithTTF(lang(talkContent), UIUtils.ttfName, 16, cc.size(100, 0))
        labTalk:setColor(UIUtils.colorTable.ccUIBasePromptColor)

        labTalk:setDimensions(100, 0)
        labTalk:setVerticalAlignment(1)
        labTalk:setHorizontalAlignment(1)
        labTalk:setName("labTalk")
        talkBg:addChild(labTalk)
        inBuildingIcon.talk = talkBg
    else
        talkBg = inBuildingIcon.talk
        labTalk = talkBg:getChildByName("labTalk")
    end
    talkBg:setScale(1)
    talkBg:setPosition(inPt.x, inPt.y)
    talkBg:setOpacity(255)
    talkBg:stopAllActions()
    if inSysBranch.flipX == 1 then 
        talkBg:setFlipX(true)
    end
    labTalk:setString(lang(talkContent))
    labTalk:setScale(0.8)
    if (labTalk:getContentSize().height * labTalk:getScaleX())> (30* labTalk:getScaleX()) then
        labTalk:setScale(0.8)
    else
        labTalk:setScale(1)
    end
    labTalk:setPosition(talkBg:getContentSize().width/2, talkBg:getContentSize().height/2+ 10)

    if inAnim and inBuildingIcon.animSp ~= nil then 
        if talkBg.getPositionY == nil  then 
            return 
        end
        talkBg:setPositionY(talkBg:getPositionY() - 10)
        inBuildingIcon:setCascadeOpacityEnabled(true, true)
        inBuildingIcon:runAction(cc.Sequence:create(
            cc.DelayTime:create(3),
            cc.FadeTo:create(0.3, 80),
            cc.FadeTo:create(0.2, 220),
            cc.FadeTo:create(0.3, 0),
            cc.CallFunc:create(function() callback() end) 
            ))
    else
        talkBg:setScale(1)
        talkBg:runAction(cc.Sequence:create(
            cc.DelayTime:create(3),
            cc.CallFunc:create(function() callback() end) 
            ))
    end
end

--[[
--! @function updateBranchTalk
--! @desc 更新支线对话
--！@param inSysBranch 支线系统信息
--！@param inBuildingIcon 支线建筑
--! @return 
--]]
function SiegeMapView:updateBranchTalk(inSysBranch, inBuildingIcon)
    if inSysBranch.words ~= nil and self._branchIcon[inSysBranch.id] then 
        local sysBranchDialogue = tab:SiegeBranchDialogue(inSysBranch.words)
        inBuildingIcon.talkIndex = 0
        inBuildingIcon.nextTalk = function()
            print("inBuildingIcon.nextTalk============================")
            self:showBranchTalk(inSysBranch, inBuildingIcon, sysBranchDialogue, cc.p(inSysBranch.wordsPosi[1], inSysBranch.wordsPosi[2]))
        end
        if inSysBranch.type == SiegeConst.STAGE_BRANCH_TYPE.TALK_REWARD then 
            inBuildingIcon:runAction(cc.Sequence:create(
                cc.DelayTime:create(sysBranchDialogue.time), 
                cc.CallFunc:create(function() 
                    self:showBranchTalk(inSysBranch, inBuildingIcon, sysBranchDialogue, cc.p(inSysBranch.wordsPosi[1], inSysBranch.wordsPosi[2]))
                    end)
                ))
        end
    end
end

function SiegeMapView:touchBranchIcon(x, y)
    local touchBranchId = 0
    local touchX = 0
    local touchY = 0
    for k,v in pairs(self._branchIcon) do
        local pt = v:convertToWorldSpace(cc.p(0, 0))
        local scale = math.abs(v:getScaleY())
        local flag = 0
        local flip = 1
        -- 经过反转的sprite左边会发生变化，需要单独
        if v.isFlippedX ~= nil and v:isFlippedX() == true then 
            flip = -1
        end
        if flip == -1 and pt.x > x and pt.y < y and 
            (pt.x - v:getContentSize().width * scale) < x and 
            (pt.y + v:getContentSize().height * scale) > y then
            flag = 1
        elseif flip == 1 and pt.x < x and pt.y < y and 
            (pt.x + v:getContentSize().width * scale) > x and 
            (pt.y + v:getContentSize().height * scale) > y then
            -- self:touchBranchEventIcon(v, k)
            flag = 1
        end

        if v.isDie ~= nil and v.isDie ==  true  then 
            flag = 0
        end
        if flag == 1 then
            if k < touchBranchId or touchBranchId == 0 then
                touchBranchId = k
                touchX = pt.x
                touchY = pt.y
            end
        end
    end
    if touchBranchId ~= 0 then 
        local v = self._branchIcon[touchBranchId]
        v.eventDownCallback(touchX, touchY, v)
        v.eventUpCallback(touchX, touchY, v)
        return self._touchBack
    end
    return false
end

function SiegeMapView:touchBranchEventIcon(v, k)
    print("touchBranchEventIcon======================================")

    local sysBranchStage = tab:SiegeBranchStage(k)

    if sysBranchStage.subType ~= nil then
        -- 特殊处理，此类型的点击判断英雄是否存在
        if sysBranchStage.subType[1] == 1 then 
            local heroModel = self._modelMgr:getModel("HeroModel")
            local isLoaded = heroModel:isHeroLoaded(sysBranchStage.subType[2])
            if isLoaded == false then 
                self._viewMgr:showTip(lang("branchtips_1"))
                return false
            end

        end
    end
    local needPreBranch = false 
    if sysBranchStage.preId ~= nil then 
        for k,v in pairs(sysBranchStage.preId) do
            local branchInfo = self._sModel:getBranchInfo()
            if branchInfo[tostring(v[2])] == nil then 
                needPreBranch = true
            end
        end        
    end 
    -- 特殊处理，此类型的点击后只切换对话
    if sysBranchStage.type == SiegeConst.STAGE_BRANCH_TYPE.TALK or
        sysBranchStage.type == SiegeConst.STAGE_BRANCH_TYPE.REWARD_ITEM_HERO then 

        if self:isBranchOpen(sysBranchStage.subType) then
            self:getMainBranchReward(v.stageId, sysBranchStage.id)
            return false
        else
            -- 针对类型10特殊处理，preid只限制是否展示对话，并不限制是否可以领奖
            print("needPreBranch-=================", needPreBranch, v.nextTalk)
            if needPreBranch == false then 
                if v.nextTalk ~= nil then
                    v:nextTalk()
                end
            else
                self._viewMgr:showTip(lang(sysBranchStage.tips))
            end
        end
        return true
    end
    -- 特殊处理，此类型的点击后只切换对话（和TALK类型有区别)
    if sysBranchStage.type == SiegeConst.STAGE_BRANCH_TYPE.TALK_REWARD then 
        if self:isBranchOpen(sysBranchStage.subType) then
           self._viewMgr:showDialog("siege.SiegeBranchView", {branchId = k,
                callback = function(inBranchId, inType)
                    self:getMainBranchReward(v.stageId, inBranchId)
                end})
            return false
        else
            -- 针对类型10特殊处理，preid只限制是否展示对话，并不限制是否可以领奖
            print("needPreBranch-=================", needPreBranch, v.nextTalk)
            if needPreBranch == false then 
                if v.nextTalk ~= nil then
                    v:nextTalk()
                end
            else
                self._viewMgr:showTip(lang(sysBranchStage.tips))
            end
        end
        return true
    end

    if needPreBranch == true then 
        self._viewMgr:showTip(lang(sysBranchStage.tips))
        return
    end

    -- 只在攻城阶段判断，守城所有都开启
    if self._curSectionId == 1 and not self._sModel:isStagePass(v.stageId) then
        local sysStage = tab:SiegeMainStage(v.stageId)
        local title = lang(sysStage.sectionName)
        local desc = lang("STAGE_TIPS_1")
        local result, count = string.gsub(desc, "$t", title)
        if count > 0  then 
            desc = result
        end
        self._viewMgr:showTip(desc)
        return false
    end

    if sysBranchStage.type == SiegeConst.STAGE_BRANCH_TYPE.TIP then
        audioMgr:playSound("temple")
    elseif sysBranchStage.type == SiegeConst.STAGE_BRANCH_TYPE.REWARD_ITEM then
        audioMgr:playSound("pickup")
    elseif sysBranchStage.type == SiegeConst.STAGE_BRANCH_TYPE.WAR or 
        sysBranchStage.type == SiegeConst.STAGE_BRANCH_TYPE.REWARD_TEAM then
        audioMgr:playSound("rogue")
    end
    -- 关卡支线
    if v.stageId ~= nil then
        print('sysBranchStage.type=====', sysBranchStage.type)
        if sysBranchStage.type == SiegeConst.STAGE_BRANCH_TYPE.HERO_ATTR then
            self._viewMgr:showDialog("siege.SiegeHeroAttrBranchView", {
                stageId = v.stageId, 
                branchId = k,
                callback = function(inBranchId, inType)
                    self:atkBeforeMainBranch(v.stageId, inBranchId)
                end})
        elseif sysBranchStage.type == SiegeConst.STAGE_BRANCH_TYPE.CHOOSE_REWARD then
            self._viewMgr:showDialog("siege.SiegeChooseBranchView", {branchId = k,
            callback = function(inBranchId, inType, inChoose)
                self:getMainBranchReward(v.stageId, inBranchId, inChoose)
            end})
        elseif sysBranchStage.type == SiegeConst.STAGE_BRANCH_TYPE.MARKET then
            self._viewMgr:showDialog("siege.SiegeBranchMarketView", {
                branchId = k,
                stageId = v.stageId, 
            callback = function(inBranchId, inType, inChoose)
                self:getMainBranchReward(v.stageId, inBranchId, inChoose)
            end})
        else
            self._viewMgr:showDialog("siege.SiegeBranchView", {branchId = k,
                callback = function(inBranchId, inType, inChoose)
                    if inType == 2 then 
                        self:getMainBranchReward(v.stageId, inBranchId, inChoose)
                    else

                        self:atkBeforeMainBranch(v.stageId, inBranchId)
                    end
                end})
        end
        return
    end
    if v.sectionId ~= nil then
        -- 章支线
        if sysBranchStage.type == SiegeConst.STAGE_BRANCH_TYPE.REWARD_TEAM then
            self._viewMgr:showDialog("intance.IntanceBranchView", {branchId = k,
                callback = function(inBranchId, inType, inChoose)
                    self:getSectionBranchReward(v.sectionId, inBranchId, inChoose)
                end})
        end
    end

    return true
end

function SiegeMapView:isBranchOpen(subType)
    if subType == nil then return false end

    if subType[1] == 2 then
        if not self._sModel:isStagePass(subType[2]) then
            return false
        end

        local branchInfo = self._sModel:getBranchInfo()
        if branchInfo[tostring(subType[3])] == nil then
            return false
        end

    elseif subType[1] == 3 then
        if not self._sModel:isStagePass(subType[2]) then
            return false
        end
    end
    return true
end

function SiegeMapView:handleBranchReward(inBranchId, result)
    local sysBranchStage = tab:SiegeBranchStage(inBranchId)
    dump(result, "test", 10)
    if sysBranchStage.type == SiegeConst.STAGE_BRANCH_TYPE.REWARD_TEAM then
        if result["reward"] ~= nil then
          if result["reward"][1] ~= nil and 
            result["reward"][1][1] == "team" then
              DialogUtils.showTeam({teamId = result["reward"][1][2],callback = function() 
              end})
            else
                DialogUtils.showGiftGet({
                  gifts = result["reward"],
                })
            end
        end
    elseif sysBranchStage.type == SiegeConst.STAGE_BRANCH_TYPE.REWARD_ITEM or 
        sysBranchStage.type == SiegeConst.STAGE_BRANCH_TYPE.REWARD_ITEM_TEAM or 
        sysBranchStage.type == SiegeConst.STAGE_BRANCH_TYPE.COST_TEAM or 
        sysBranchStage.type == SiegeConst.STAGE_BRANCH_TYPE.COST_ITEM_CHIP or 
        sysBranchStage.type == SiegeConst.STAGE_BRANCH_TYPE.CHOOSE_REWARD or
        sysBranchStage.type == SiegeConst.STAGE_BRANCH_TYPE.REWARD_ITEM_HERO then
        DialogUtils.showGiftGet({
          gifts = result["reward"],
        })
        -- if sysBranchStage.type == SiegeConst.STAGE_BRANCH_TYPE.REWARD_ITEM then
        --     audioMgr:playSound("pickup")
        -- end
    elseif sysBranchStage.type == SiegeConst.STAGE_BRANCH_TYPE.REWARD_HERO then
        -- self._viewMgr:showTip("恭喜您，解锁英雄")
        if self._showHero ~= nil  then
            audioMgr:playSound("NewHero")
            self._showHero:runHeroUnlockAction()
            self._showHero = nil
        end
    end
    
    if sysBranchStage.type == SiegeConst.STAGE_BRANCH_TYPE.TALK or
        sysBranchStage.type == SiegeConst.STAGE_BRANCH_TYPE.TALK_REWARD or
        sysBranchStage.type == SiegeConst.STAGE_BRANCH_TYPE.REWARD_ITEM_HERO
    then
        if result["reward"] ~= nil and next(result["reward"]) ~= nil then        
            DialogUtils.showGiftGet( {
                gifts = result["reward"], 
                callback = function() self:removeBranchIcon(inBranchId, true, true) end
            })
        else
            self:removeBranchIcon(inBranchId, true, true)             
        end
    else
        if sysBranchStage.subType ~= nil and sysBranchStage.subType[1] == 1 then 
            self:removeBranchIcon(inBranchId, true, false)
        else
            self:removeBranchIcon(inBranchId, true, true)
        end
    end
    self:updateSectionInfoBtnState()
end


--[[
--! @function getSectionBranchReward
--! @desc章节奖励支线
--! @param inSectionId  关卡id
--! @param inBranchId  支线id
--]]
function SiegeMapView:getSectionBranchReward(inSectionId, inBranchId)
    local param = {sid = inSectionId, bid = inBranchId}
    self._serverMgr:sendMsg("StageServer", "getSectionBranchReward", param, true, {}, function (result)
        if result == nil or result["d"] == nil then 
            if self._showHero ~= nil  then
                self._showHero:clear()
            end
            return 
        end
        self:handleBranchReward(inBranchId, result)
    end)  
end

--[[
--! @function getMainBranchReward
--! @desc 关卡奖励支线
--! @param inStageId  关卡id
--! @param inBranchId  支线id
--]]
function SiegeMapView:getMainBranchReward(inStageId, inBranchId)
    local param = {stageId = inStageId, bid = inBranchId}
    self._serverMgr:sendMsg("SiegeServer", "getBranchReward", param, true, {}, function (result)
        if result == nil or result["d"] == nil then 
            if self._showHero ~= nil  then
                self._showHero:clear()
            end
            return 
        end
        self:handleBranchReward(inBranchId, result)
    end)  
end

--[[
--! @function atkBeforeMainBranch
--! @desc 关卡战斗支线
--! @param inStageId  关卡id
--! @param inBranchId  支线id
--]]
function SiegeMapView:atkBeforeMainBranch(inStageId, inBranchId)
    self._battaleStageId = inStageId
    self._battaleBranchId = inBranchId

    local sysBranchStage = tab:SiegeBranchStage(inBranchId)

    local sysBranchMonsterStage = tab:BranchMonsterStage(self._sModel:getBranchRealId(sysBranchStage.id))
    local enemyFormation = IntanceUtils:initFormationData(sysBranchMonsterStage)

    local formationModel = self._modelMgr:getModel("FormationModel")

    local sysSectionMap = tab:MainSectionMap(self._sysSection.id)

    local sysStageMap = tab:MainStageMap(inStageId)

    BulletScreensUtils.clear()
    self._viewMgr:showView("formation.NewFormationView", {
        formationType = formationModel.kFormationTypeCommon,
        enemyFormationData = {[formationModel.kFormationTypeCommon] = enemyFormation},
        heroes = heroes,
        callback = 
            function(inLeftData)
               self:formationCallBack(inLeftData)
            end,
        closeCallback = 
            function()
--                self:handleParentIntanceBullet()
            end}
        )       
end

function SiegeMapView:handleParentIntanceBullet()
    print("handleParentIntanceBullet==============================")
    self._intanceModel:noticeView("showIntanceBullet")
end

--[[
--! @function formationCallBack
--! @desc 布阵callback
--! @param inLeftData table 左侧阵容
--]]
function SiegeMapView:formationCallBack(inLeftData)
    local oldFight = TeamUtils:updateFightNum()
    self._formationData = inLeftData
    local cacheBranchInfo  = clone(self._sModel:getBranchInfo())
    local param = {
        stageId = self._battaleStageId, 
        bid = self._battaleBranchId, 
        serverInfoEx = BattleUtils.getBeforeSIE()
    }
    self._serverMgr:sendMsg("SiegeServer", "atkBeforeBranch", param, true, {}, function (result)
        dump(result)
        self._battleToken = result["token"]
        self._viewMgr:popView()
        self:setLockMap(true)
        BattleUtils.enterBattleView_FubenBranch(BattleUtils.jsonData2lua_battleData(result["atk"]), self._sModel:getBranchRealId(self._battaleBranchId), false, function (info,callBack)
            self:battleCallBack(info,callBack)
        end,
        function (info)
            if self._battleWin == 1 then
                local sysBranchStage = tab:SiegeBranchStage(self._battaleBranchId)
                if sysBranchStage.type == SiegeConst.STAGE_BRANCH_TYPE.HERO_ATTR then
                    local branchInfo  = self._sModel:getBranchInfo()
                    -- 特殊处理英雄属性类型
                    local param = {}
                    if cacheBranchInfo[tostring(self._battaleBranchId)] ~= nil then 
                        param.oldLevel = tonumber(cacheBranchInfo[tostring(self._battaleBranchId)])
                    else
                        param.oldLevel = 0
                    end
                    param.branchId = self._battaleBranchId
                    param.newLevel = tonumber(branchInfo[tostring(self._battaleBranchId)])
                    param.oldFight = oldFight
                    self._viewMgr:showDialog("cloudcity.CloudCityPassView", {viewType = 2, param = param, callBack = function()
                        IntanceConst.IS_OPEN_BRANCH_HERO_ATTR_ANIM = true
                        local branchBuildIcon = self:getBranchBuildingById(self._battaleBranchId)
                        self:touchBranchEventIcon(branchBuildIcon, self._battaleBranchId)
                        if branchBuildIcon.updateState ~= nil then 
                            branchBuildIcon.updateState()
                        end
                    end})
                else
                    if sysBranchStage.subType ~= nil and sysBranchStage.subType[1] == 1 then 
                        self:removeBranchIcon(self._battaleBranchId, true, false)
                    else
                        self:removeBranchIcon(self._battaleBranchId, true, true)
                    end
                end         
                -- 胜利
                GuideUtils.checkTriggerByType("branchWin", self._battaleBranchId)
--                self:handleParentIntanceBullet()
            end
            self:setLockMap(false)
        end)
    end)
end



--[[
--! @function battleCallBack
--! @desc 战斗结束callback
--! @param inResult table 战斗相关
--! @param inCallBack function 是否检查扫荡卷
--! @return bool
--]]
function SiegeMapView:battleCallBack(inResult,inCallBack)
    if inResult == nil then 
        self:setLockMap(false)
        return 
    end
    -- 配合战斗做的性能优化，支线战斗结束后重新加载地图
    -- self:setTexture(self:getBgName())
--    self:setBgTexture()
    self._battleWin = 0
    if inResult.win ~= nil 
        and inResult.win == true then 
       self._battleWin = 1
    end
    if self._battleWin == 0 then 
        if inCallBack then 
          inCallBack({})
        end
        return
    end
    -- 缓存数据对比是否升级
    local teamModel = self._modelMgr:getModel("TeamModel")
    local tempCacheTeams = {}
    for k,v in pairs(self._formationData.team) do
        local team, index = teamModel:getTeamAndIndexById(v.id)
        if index > 0 then 
            table.insert(tempCacheTeams,table.deepCopy(team))
        end
    end
    local mySelfHp = math.ceil(inResult.hp[1] / inResult.hp[2] * 100)

    GuideUtils.saveIndex(GuideUtils.getNextBeginningIndex())
    local param = {stageId = self._battaleStageId, bid = self._battaleBranchId,
        args = json.encode({
                    win = self._battleWin, 
                    time = inResult.time, 
                    dieCount = inResult.dieCount, 
                    serverInfoEx = inResult.serverInfoEx,
                    skillList = inResult.skillList,
                    uhp = mySelfHp
                }),
                token = self._battleToken}
   
    if self._formationData.hero.npcHero == true then 
        param.npcHero = "1"
    end
    self._serverMgr:sendMsg("SiegeServer", "atkAfterBranch", param, true, {}, function (result)
        if result == nil then 
            self._battleWin = 0
            if inCallBack ~= nil then
                inCallBack({failed = true, __code = 5, extract = result["extract"]})
            end
            return 
        end
        if result["cheat"] == 1 then
            self._battleWin = 0
            if inCallBack ~= nil then
                inCallBack({failed = true, __code = 6, extract = result["extract"]})
            end
            return
        end
        local sysBranch = tab:SiegeBranchStage(self._battaleBranchId)
        if sysBranch.type ~= SiegeConst.STAGE_BRANCH_TYPE.HERO_ATTR then 
            if result["d"] == nil then 
                self._battleWin = 0
                if inCallBack ~= nil then
                    inCallBack({failed = true, __code = 7, extract = result["extract"]})
                end
                return 
            end
        end
        if result["extract"] then dump(result["extract"]["hp"]) end
        if self._battaleBranchId == 710021 then
            local has = SystemUtils.loadAccountLocalData("guideFuben_"..self._battaleBranchId)
            if has == nil or has == "" then
                SystemUtils.saveAccountLocalData("guideFuben_"..self._battaleBranchId, 1)
                ApiUtils.playcrab_monitor_action("fuben"..self._battaleBranchId)
            end
        end

        if result == nil then 
            self._viewMgr:showTip("请求战斗失败")
            return 
        end
        -- -- 支线默认3星
        -- result.star = 3
        if result.rs ~= nil then 
            result.star = result.rs.star
        end
        -- 像战斗层传送数据
        if inCallBack ~= nil then
            inCallBack(result)
        end
        self:updateSectionInfoBtnState()
    end, function (error)
        if error then
            self._battleWin = 0
            if inCallBack ~= nil then
                inCallBack({failed = true, __code = 8, __error = error})
            end
        end
    end)
end

function SiegeMapView:removeBranchIcon(inBranchId, inTalk, inAnim)
    local branchIcon = self._branchIcon[inBranchId]
    branchIcon.isDie = true
    local removeBranch = function()
        local branchIcon = self._branchIcon[inBranchId]
        if branchIcon == nil then return end
        if branchIcon.talk ~= nil then 
            branchIcon.talk:stopAllActions()
            branchIcon.talk:removeFromParent()
            branchIcon.talk = nil
        end
        if branchIcon.removeFromParent ~= nil then 
            branchIcon:removeFromParent()
        else
            branchIcon:clear()
        end
        self._branchIcon[inBranchId] = nil
        -- 移除关联支线
    end
    local sysBranch = tab:SiegeBranchStage(inBranchId)


    if sysBranch.lastWords and inTalk then
        if branchIcon.talk ~= nil then 
            branchIcon.talk:stopAllActions()
            branchIcon.talk:setScale(0)
        end
        local sysBranchDialogue = tab:SiegeBranchDialogue(sysBranch.lastWords)
        self:showBranchDieTalk(
            sysBranch,
            branchIcon, 
            sysBranchDialogue, 
            cc.p(sysBranch.wordsPosi[1], sysBranch.wordsPosi[2]),
            function()  
                removeBranch()
            end, inAnim)
        return
    end
    removeBranch()
    -- local effectIcon = self._branchEffectIcon[inBranchId]
    -- if effectIcon ~= nil then
     --     effectIcon:clearCallbacks()
    --     effectIcon:stop()
    --     effectIcon:removeFromParent()
    --     self._branchEffectIcon[inBranchId] = nil
    -- end
end


-- 更新斥候密信状态
function SiegeMapView:updateSectionInfoBtnState()
-- 章信息提示
    local sectionInfoBtn = self._sectionInfoBtn
    local sysSectionInfo = tab.siegeSectionInfo[self._curSectionId]
    if sysSectionInfo == nil or sysSectionInfo.openBranch == 0 then
        -- sectionInfoBtn:setVisible(false)
        if sectionInfoBtn.tip ~= nil then 
            sectionInfoBtn.tip:setVisible(false)
        end
        return
    end
    
    local branchInfo = {}
    local sysMainSection = tab:SiegeMainSection(self._curSectionId)
    for k,v in pairs(sysMainSection.includeStage) do
        local sysMainStage = tab:SiegeMainStage(v)
        local serverBranchInfo = self._sModel:getBranchInfo()
        for k1,v1 in pairs(serverBranchInfo) do
            branchInfo[tonumber(k1)] = true
        end
        if not self._sModel:isStagePass(v) and self._curSectionId == 1 and sysMainStage.branchId ~= nil then
            for k1,v1 in pairs(sysMainStage.branchId) do
                branchInfo[tonumber(v1)] = true                      
            end
        end
    end

    local showTip = 1
    for k,v in pairs(sysSectionInfo.branchId) do
        if branchInfo[v] == nil then 
            showTip = 2
            break
        end
    end
    if showTip == 1 then 
        local maxNum = sysSectionInfo.finishReward[1][1]
        local minNum = self._sModel:getSectionBranchRate()
        if minNum == maxNum then 
            if not self._sModel:hasGetMainAward(maxNum) then 
                showTip = 2
            end
        end
    end
    if showTip == 2 then 
        if sectionInfoBtn.tip == nil then 
            local tip = cc.Sprite:createWithSpriteFrameName("globalImageUI_bag_keyihecheng.png")
            tip:setPosition(cc.p(sectionInfoBtn:getContentSize().width - 5, sectionInfoBtn:getContentSize().height -5))
            tip:setAnchorPoint(cc.p(0.5, 0.5))
            sectionInfoBtn:addChild(tip, 10)
            sectionInfoBtn.tip = tip
        end
        sectionInfoBtn.tip:setVisible(true)
        sectionInfoBtn:setVisible(true)
    else
        if sectionInfoBtn.tip ~= nil then 
            sectionInfoBtn.tip:setVisible(false)
        end
    end

    sectionInfoBtn:setVisible(true)
end

--[[
--! @function updateTaskState
--! @desc 更新任务状态
--! @return
--]]
function SiegeMapView:updateTaskState(inForced)
    local taskBg = self:getUI("bgUI.leftNode.taskBg")
    local sysMainSection = tab:SiegeMainSection(self._curSectionId)
    if sysMainSection.task == nil then 
        taskBg:setVisible(false)
        return
    end
    local branchWithStage = self._sModel:getSysBranchWithStageDatas()
    -- dump(branchWithStage, "test", 10)
    local lastTaskId = 0
    local curStageId = self._sModel:getCurStageId()

    for k1,v1 in pairs(sysMainSection.task) do
        local v = tab:MainTask(v1)
        local targetType = v.taskTarget[1]
        local targetId = v.taskTarget[2]
        if targetType == 3 or targetType == 4 then 
            if curStageId <= targetId then
                lastTaskId = v.id
                break
            end
        end
    end
    if lastTaskId == 0 then
        taskBg:setVisible(false)
        return
    else
        taskBg.lastTaskId = lastTaskId
        taskBg:setVisible(true)
    end

    -- local taskImg = self:getUI("leftPanel.taskBg.taskImg")
    -- self:registerClickEvent(taskImg, function ()
    --     self._viewMgr:showDialog("intance.IntanceMissionInfoView",{
    --         taskId = lastTaskId}
    --     )
    -- end)


    local sysTask = tab:MainTask(lastTaskId)

    local labTaskTip = self:getUI("bgUI.leftNode.taskBg.labTaskTip")
    labTaskTip:setColor(cc.c4b(255, 236, 83,255))
    labTaskTip:enable2Color(1,cc.c4b(255, 253, 226,255))

    if taskBg.lastTaskId ~= lastTaskId or inForced == true then 
        if taskBg.amin2 ~= nil then
            taskBg.amin2:stop(true)
            taskBg.amin2:removeFromParent()
            taskBg.amin2 = nil
        end
        local amin2 = mcMgr:createViewMC("shuaxinguangxiao_shuaxinguangxiao", false, true, function()
            taskBg.amin2 = nil
        end)
        amin2:setPosition(taskBg:getContentSize().width * 0.5, taskBg:getContentSize().height * 0.5)
        taskBg:addChild(amin2)
        taskBg.amin2 = amin2
    end

    local labTaskDesc = self:getUI("bgUI.leftNode.taskBg.labTaskDesc")
    labTaskDesc:setString(lang(sysTask.taskDes))
    taskBg:setContentSize(math.max(labTaskDesc:getPositionX() + labTaskDesc:getContentSize().width + 10,160), taskBg:getContentSize().height)
end

-- [[弹幕begin
function SiegeMapView:initBullet( )
    if not self._bulletLab then
        local bulletBtn = ccui.Button:create("bullet_close_btn.png","bullet_close_btn.png","",1)
        local leftNode = self:getUI("bgUI.leftNode")
        bulletBtn:setPosition(60,50)
        leftNode:addChild(bulletBtn,100)
        self._bulletBtn = bulletBtn
        local bulletLab = ccui.Text:create()
        bulletLab:setFontName(UIUtils.ttfName)
        bulletLab:setString("弹幕")
        bulletLab:setColor(cc.c3b(255,238,160))
        bulletLab:enable2Color(1, cc.c4b(255, 195, 17, 255))
        bulletLab:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        bulletLab:setFontSize(20)
        bulletLab:setPosition(40, -10)
        self._bulletLab = bulletLab
        bulletBtn:addChild(self._bulletLab)
    end
    -- if true then return end
    -- 弹幕
    ScheduleMgr:delayCall(0, self, function ()
        if not self.updateBulletBtnState or tolua.isnull(self._bulletLab) then return end
        self:updateBulletBtnState()
        self:showSiegeBullet()
    end)
end
function SiegeMapView:progressSiegeBullet(notCleanBullet)
    local curServerTime = self._userModel:getCurServerTime()
    local bulletType = self._sModel:getBulletType() or 1
    self._sysBullet = tab.bullet["Steadvik" .. bulletType] --tab:Bullet("Steadvik1")
    local bulletBtn = self._bulletBtn --self:getUI("rightMenuNode.barrage")
    local bulletLab = self._bulletLab --self:getUI("rightMenuNode.bulletLab")
    if self._sysBullet == nil then 
        bulletBtn:setVisible(false)
        bulletLab:setVisible(false)
        if not notCleanBullet then
            BulletScreensUtils.clear()
        end
        return
    else
        bulletBtn:setVisible(true)
        bulletLab:setVisible(true)
    end
end

function SiegeMapView:showSiegeBullet(notCleanBullet)
    self:progressSiegeBullet(notCleanBullet)
    if self._sysBullet == nil then 
        return
    end
    local bulletBtn = self._bulletBtn --self:getUI("rightMenuNode.barrage")
    local open = BulletScreensUtils.getBulletChannelEnabled(self._sysBullet)
    local fileName = open and "bullet_open_btn.png" or "bullet_close_btn.png"
    bulletBtn:loadTextures(fileName, fileName, fileName, 1)    
    if open and not notCleanBullet then
        BulletScreensUtils.initBullet(self._sysBullet)
    end    
end

function SiegeMapView:updateBulletBtnState()
    -- BulletScreensUtils.clear()

    local bulletBtn = self._bulletBtn --self:getUI("rightMenuNode.barrage")
    local bulletLab = self._bulletLab --self:getUI("rightMenuNode.bulletLab")
    self._sysBullet = tab:Bullet("Steadvik1")
    if self._sysBullet == nil then 
        bulletBtn:setVisible(false)
        bulletLab:setVisible(false)
        return
    else
        bulletBtn:setVisible(true)
        bulletLab:setVisible(true)
    end
    bulletLab:enable2Color(1, cc.c4b(255, 195, 17, 255))
    bulletLab:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    self:registerClickEvent(bulletBtn, function ()
        self._viewMgr:showDialog("global.BulletSettingView", {bulletD = self._sysBullet, 
            callback = function (open) 
                local fileName = open and "bullet_open_btn.png" or "bullet_close_btn.png"
                bulletBtn:loadTextures(fileName, fileName, fileName, 1)       
            end})
    end)    
end
--]]弹幕end

function SiegeMapView:onDestroy()
    BulletScreensUtils.clear()
    if self._depleteSchedule ~= nil then 
        ScheduleMgr:unregSchedule(self._depleteSchedule)
        self._depleteSchedule = nil
    end

    cc.Director:getInstance():getTextureCache():removeTextureForKey(self._bgTextureName)
    SiegeMapView.super.onDestroy(self)
end
return SiegeMapView