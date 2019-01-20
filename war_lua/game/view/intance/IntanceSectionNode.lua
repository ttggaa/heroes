--[[
    Filename:    IntanceSectionNode.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-08-21 10:55:24
    Description: File description
--]]

local IntanceSectionNode = class("IntanceSectionNode", BaseMvcs, function ()
        return  cc.Sprite:create() 
    end)

--0   传送门虚拟控件
--2   地面动画层  self._aminLayer
        -- 水怪 11
--9   装饰
--5/4 支线icon
--7   建筑星星
--8   地面特效  self._effectLayer
--100  绿点路线 传送门  
--104  self._topLayer(上层云鸟特效)  
--105  雾
--101  英雄动画
--9999 魔眼 传送门动画 

function IntanceSectionNode:ctor()
    IntanceSectionNode.super.ctor(self)
    self._usingIcon = {}
    self._freeingIcon = {}
    self._usingFog = {}
    self._buildingFog = {}
    self._freeingFog = {}

    self._effectLayer = cc.Layer:create()
    self:addChild(self._effectLayer,8)   

    self._topLayer = cc.Layer:create()
    self:addChild(self._topLayer, 104)  

    self._aminLayer = cc.Layer:create()
    self:addChild(self._aminLayer,2)

    self._branchIcon = {}

    self._undoneStageId = 0

    self._intanceModel = self._modelMgr:getModel("IntanceModel")

    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            ScheduleMgr:cleanMyselfDelayCall(self)
            UIUtils:reloadLuaFile("intance.IntanceSectionNode")
        elseif eventType == "enter" then 

        end
    end)
end



--[[
--! @function releaseBuildingIcon
--! @desc 释放建筑图标
--! @return 
--]]
function IntanceSectionNode:releaseBuildingIcon()
    -- 建筑数据初始化
    local buildingIcon 
    while(true) do
        if #self._usingIcon <= 0 then 
            break
        end
        buildingIcon = self._usingIcon[#self._usingIcon]
        buildingIcon:setVisible(false)
        buildingIcon:setEnabled(false)
        local starBg = buildingIcon:getChildByName("star_bg")
        if starBg ~= nil then 
            for i=1,3 do
                local star = starBg:getChildByName("star_" .. i)
                star:stop()
                star:setVisible(false)
            end
            if starBg:getChildByName("star_box") ~= nil then 
                starBg:getChildByName("star_box"):stop()
            end
        end
        table.insert(self._freeingIcon,buildingIcon)
        table.remove(self._usingIcon)
    end
end

--[[
--! @function releaseFogIcon
--! @desc 释放迷雾图标
--! @return 
--]]
function IntanceSectionNode:releaseFogIcon()
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
function IntanceSectionNode:releaseBranchIcon()
    for k,v in pairs(self._branchIcon) do
        self:removeBranchIcon(k, false, false)
    end
    self._branchIcon = {}
end 

function IntanceSectionNode:reflashUI(inData)
    self._sysSection  = inData.sysSection
    self._quickStageId  = inData.quickStageId 

    self._activeDecorate = {}

    -- 清理遗留绿点
    if self._tempPoints ~= nil then 
        for k,v in pairs(self._tempPoints) do
            v:removeFromParent()
        end
    end
    self._tempPoints = nil
    self._touchBack = true


    self._bg = cc.Sprite:create(UIUtils.noPic)
    self:addChild(self._bg)

    self:setBgTexture()

    -- 加载副本地图
    local sysMainSectionMap = tab:MainSectionMap(self._sysSection.id)

    -- self:setTexture("asset/uiother/map/" .. sysMainSectionMap.img)
    -- self:setAnchorPoint(cc.p(0.5, 0.5))
    -- self:setPosition(sysMainSectionMap.x, sysMainSectionMap.y)
    -- self._cacheName = "asset/uiother/map/" .. sysMainSectionMap.img

    -- self._cacheSize = self:getContentSize()

    
    local mainsData = self._intanceModel:getData().mainsData
    self._curStageId = mainsData.curStageId

    local goStarPoint = SystemUtils.loadAccountLocalData("GO_STAR_POINT")
    -- -- 初始化起始点
    --  第一章起始位置特殊处理
    if self._curStageId <= IntanceConst.FIRST_SECTION_FIRST_STAGE_ID then 
        goStarPoint = self._sysSection.id
    end

    if goStarPoint == self._sysSection.id then
        if self._sysSection.beginStage ~= nil then
            self._heroStandByStageId = self._sysSection.beginStage
        end
    else 
        self._heroStandByStageId = self._curStageId
    end

    -- 正常入口建筑展示
    local positionIcon
    local sysPositionStageMap = nil
    -- 迷雾数据
    local fogIcon 
    for k,v in pairs(self._sysSection.includeStage) do
        local stageInfo = self._intanceModel:getStageInfo(v)
        local sysMainStageMap = tab:MainStageMap(v)
        local sysMainStage = tab:MainStage(v)
        local buildingIcon
        local starBg = nil 
        if #self._freeingIcon > 0  then 
            buildingIcon = self._freeingIcon[#self._freeingIcon]
            table.remove(self._freeingIcon)
            starBg = buildingIcon:getChildByName("star_bg")
        else
            buildingIcon = ccui.Widget:create()
            if sysMainStage.siegeid then
                starBg = self:createCastleStarInfo()
            else
                starBg = self:createStarInfo()
            end
            buildingIcon:addChild(starBg)
            self:addChild(buildingIcon, 7)
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

        starBg:setPosition(buildingIcon:getContentSize().width/2,0)  
        -- 处理星星相关数据
        self:updateBuildingStar(stageInfo.star, sysMainStageMap.id, starBg)

        self:initStageFog(sysMainStageMap)
        self:initStageBranch(stageInfo, sysMainStage)
    end

    if IntanceConst.FIRST_SECTION_LAST_STAGE_ID >= self._curStageId then
        positionIcon = self:getStageBuildingById(self._curStageId - 1)
        sysPositionStageMap = tab:MainStageMap(self._curStageId - 1)
    else
        positionIcon = self:getStageBuildingById(self._curStageId)
        if positionIcon == nil then 
            local lastStageId = self._sysSection.includeStage[#self._sysSection.includeStage]
            positionIcon = self:getStageBuildingById(lastStageId)
            sysPositionStageMap = tab:MainStageMap(lastStageId)
        else
            sysPositionStageMap = tab:MainStageMap(self._curStageId)
        end
    end

    ----------------------------------英雄动画-------------------------------------
    self:refreshHeroAnim()

    -- 如果当前章是最新章，则用更新英雄位置到最新点（sysPositionStageMap= nil 为非最新章)
    if self._sysSection.id == mainsData.curSectionId then 
        if sysPositionStageMap ~= nil and self._heroStandByStageId > sysPositionStageMap.id then
            self._heroStandByStageId = sysPositionStageMap.id
        end
    end

    self._isFirstEnter = false
    -- 主要处理传送门情况
    if goStarPoint == self._sysSection.id  and self._sysSection.beginStage ~= nil then
        self._isFirstEnter = true
        -- 传送门虚拟控件，获取位置
        local guidebuildingIcon = ccui.Widget:create()
        guidebuildingIcon:setName("guide_building_icon_begin")

        local sysStageMap = tab:MainStageMap(self._sysSection.beginStage)
        guidebuildingIcon:setPosition(cc.p(sysStageMap.x, sysStageMap.y))

        self:addChild(guidebuildingIcon, 0)

        -- 偏移位置
        local offset = cc.p(0, 0)
        if positionIcon ~= nil then 
            local x = (positionIcon:getPositionX() - guidebuildingIcon:getPositionX()) /2
            local y = (positionIcon:getPositionY() + positionIcon:getContentSize().height/2 - guidebuildingIcon:getPositionY() + guidebuildingIcon:getContentSize().height/2) /2
            offset = cc.p(x, y)
        end

        self._moveCallBack(guidebuildingIcon, offset)

        guidebuildingIcon:removeFromParent()
        local iconPoint = sysStageMap.point[1]
        self:updateAminPos(iconPoint)

        self._heroStandByStageId = self._sysSection.beginStage
        
        print("self._heroStandByStageId=================", self._heroStandByStageId)

        SystemUtils.saveAccountLocalData("GO_STAR_POINT", 0)
        -- goStarPoint = 0
    else
        if IntanceConst.FIRST_SECTION_LAST_STAGE_ID >= self._curStageId then 
            self:activeStageBuilding()
        end
        -- 移动到最新的一个挑战建筑
        ----------------------------------英雄位置-------------------------------------
        local iconPoint = sysPositionStageMap.point[1]
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
        self._moveCallBack(positionIcon, offset)
        self:updateAminPos(iconPoint)
        if self._intanceMcAnimNode ~= nil then self._intanceMcAnimNode:setVisible(true) end
    end

    -- 默认是玩家要通过第一章才可以进行快速跳转,
    -- 因activeStageBuilding已锁定界面 所以无法载入信息界面，防止载入大图加上判断
    -- 材料（背包，任务）来源的快速跳转处理
    if self._quickStageId ~= nil and 
        IntanceConst.FIRST_SECTION_LAST_STAGE_ID < self._curStageId then 
        local buildingIcon = self:getStageBuildingById(tostring(self._quickStageId))
        if buildingIcon ~= nil then
            self._moveCallBack(buildingIcon, nil)
            self:loadBigIcon(buildingIcon, buildingIcon.showIndex)
        end
    end
    print("IntanceConst.FIRST_SECTION_FIRST_STAGE_ID == self._curStageId====", IntanceConst.FIRST_SECTION_LAST_STAGE_ID,self._curStageId)
    if IntanceConst.FIRST_SECTION_FIRST_STAGE_ID == self._curStageId then
        self:initSpecialStageBranch()
    end 
    self:initDecorate()

    local userSectionInfo = self._intanceModel:getSectionInfo(self._sysSection.id)

    -- 初始化章支线信息
    self:initSectionBranch(userSectionInfo, sysMainSectionMap)
end



--[[
--! @function activeHideDecorate
--! @desc 根据章节id激活隐藏装饰图
--! @return 
--]]
function IntanceSectionNode:activeHideDecorate(inStageId)
    if self._activeDecorate[inStageId] == nil then 
        return
    end
    for k,v in pairs(self._activeDecorate[inStageId]) do
        v:setVisible(true)
    end

    self._activeDecorate[inStageId] = nil
end

--[[
--! @function initDecorate
--! @desc 初始化装饰图
--! @return 
--]]
function IntanceSectionNode:initDecorate()
    local sysMainSectionMap = tab:MainSectionMap(self._sysSection.id)
    if sysMainSectionMap.shade == nil then return end
    for k,v in pairs(sysMainSectionMap.shade) do
        local sysMainShadeMap = tab.mainShadeMap[v]
        if sysMainShadeMap ~= nil then 
            local maskSp = cc.Sprite:create("asset/uiother/intance/" .. sysMainShadeMap.img .. ".png")
            maskSp:setPosition(sysMainShadeMap.posi[1], sysMainShadeMap.posi[2])
            self:addChild(maskSp, 6)
            if sysMainShadeMap.condition ~= nil then
                if sysMainShadeMap.condition[1] == 1 and sysMainShadeMap.condition[2] > self._curStageId then
                    maskSp:setVisible(false)
                    local stageId = sysMainShadeMap.condition[2]
                    if self._activeDecorate[stageId] == nil  then 
                        self._activeDecorate[stageId] = {}
                    end
                    table.insert(self._activeDecorate[stageId], maskSp)
                end
            end
        end
    end
end

--[[
--! @function refreshHeroAnim
--! @desc 刷新英雄动画（布阵中替换英雄）
--! @return 
--]]
function IntanceSectionNode:refreshHeroAnim()
    local curSectionId = self._intanceModel:getCurMainSectionId()
    if self._sysSection.id == curSectionId then 
        local heroId
        local heroart
        local sysSectionMap = tab:MainSectionMap(self._sysSection.id)
        if sysSectionMap.hero ~= nil then 
            heroId = sysSectionMap.hero
        end
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
            -- if self._intanceMcAnimNode.heroId == heroId then 
            --     return
            -- end
            cacheX, cacheY = self._intanceMcAnimNode:getPosition()
            isHas = true
            self._intanceMcAnimNode:clear()
            self._intanceMcAnimNode = nil
        end

        mcMgr:retain(heroart)
        local IntanceMcAnimNode = require("game.view.intance.IntanceMcAnimNode")
        self._intanceMcAnimNode = IntanceMcAnimNode.new({"stop", "win", "run", "run2"}, heroart,
        function(sender) 
            mcMgr:release(heroart)
            sender:runStandBy()
            end
            ,100,100,
            {"stop", "run2"},{{3,10}, {1,2}})
        self:addChild(self._intanceMcAnimNode, 101)
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
        return
    end
    if self._intanceMcAnimNode ~= nil then 
        self._intanceMcAnimNode:clear()
        self._intanceMcAnimNode = nil
    end
    
end


--[[
--! @function initStageFog
--! @desc 初始化关卡迷雾
--! @param inStageId 关卡id
--! @return 
--]]
function IntanceSectionNode:initStageFog(inSysMainStageMap)
    if (self._curStageId < inSysMainStageMap.id or 
        (self._curStageId == inSysMainStageMap.id and 
            self._curStageId ~= self._heroStandByStageId))  and 
        inSysMainStageMap.fog ~= nil then
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
                self:addChild(fogIcon, 105)
            end
            fogIcon:setPosition(sysFog[1], sysFog[2])
            table.insert(self._usingFog, fogIcon)
            if self._buildingFog[inSysMainStageMap.id] == nil then 
                self._buildingFog[inSysMainStageMap.id] = {}
            end
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
function IntanceSectionNode:fadeInStageFog(inAnim, inTime)
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
function IntanceSectionNode:fadeOutStageFog(inAnim, inTime)
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

function IntanceSectionNode:initSpecialStageBranch()
    local mainsData = self._intanceModel:getData().mainsData
    local stageInfo = {}
    local sysMainStage = {}
    stageInfo.branchInfo = {}
    stageInfo.star = 0
    if mainsData.spBranch ~= nil then 
        for k,v in pairs(mainsData.spBranch) do
            stageInfo.branchInfo[k] = v
        end
    end
    sysMainStage.branchId = {IntanceConst.SPECIAL_BRANCH_1_ID, IntanceConst.SPECIAL_BRANCH_2_ID}
    sysMainStage.id = 0
    self:initStageBranch(stageInfo, sysMainStage)
end

--[[
--! @function createBranchBuildIcon
--! @desc 创建支线信息
--! @param  sysBranch 系统支线信息
--! @return 
--]]
local AnimAp = require "base.anim.AnimAP"
function IntanceSectionNode:createBranchBuildIcon(sysBranch)
    local branchIcon
    local buildingIcon = ccui.Widget:create()
    buildingIcon:setContentSize(cc.size(130, 130))
    buildingIcon:setAnchorPoint(0.5, 0)
    if sysBranch.type == IntanceConst.STAGE_BRANCH_TYPE.WAR or 
     sysBranch.type == IntanceConst.STAGE_BRANCH_TYPE.REWARD_TEAM  or 
     sysBranch.type == IntanceConst.STAGE_BRANCH_TYPE.REWARD_ITEM_TEAM or 
     sysBranch.type == IntanceConst.STAGE_BRANCH_TYPE.COST_TEAM or 
     sysBranch.type == IntanceConst.STAGE_BRANCH_TYPE.COST_ITEM_CHIP or 
     sysBranch.type == IntanceConst.STAGE_BRANCH_TYPE.TALK then

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
    elseif sysBranch.type == IntanceConst.STAGE_BRANCH_TYPE.REWARD_ITEM or
       sysBranch.type == IntanceConst.STAGE_BRANCH_TYPE.REWARD_HERO or
       sysBranch.type == IntanceConst.STAGE_BRANCH_TYPE.TIP or
       sysBranch.type == IntanceConst.STAGE_BRANCH_TYPE.HERO_ATTR or
       sysBranch.type == IntanceConst.STAGE_BRANCH_TYPE.CHOOSE_REWARD or
       sysBranch.type == IntanceConst.STAGE_BRANCH_TYPE.MARKET then
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



    if branchIcon ~= nil then
        buildingIcon:setScale(sysBranch.scale / 100)
        
        return buildingIcon
    end
end


--[[
--! @function initSectionBranch
--! @desc 初始化章支线心细
--! @param  inSectionInfo 章信息
--! @param  inSysMainSectionMap 章节地图信息
--! @return
--]]
function IntanceSectionNode:initSectionBranch(inSectionInfo, inSysMainSectionMap)
    if inSysMainSectionMap.branchId == nil then return end
    for k,v in pairs(inSysMainSectionMap.branchId) do
        local sysBranch = tab:BranchStage(v)
        if inSectionInfo.sb[tostring(v)] == nil or 
        sysBranch.type == IntanceConst.STAGE_BRANCH_TYPE.HERO_ATTR then
            local buildingIcon = self:createBranchBuildIcon(sysBranch)
            if buildingIcon ~= nil then            
                buildingIcon:setName("branch_icon_" ..  v)
                buildingIcon.sectionId = inSysMainSectionMap.id

                self._branchIcon[v] = buildingIcon

                if sysBranch.type == IntanceConst.STAGE_BRANCH_TYPE.WAR or 
                sysBranch.type == IntanceConst.STAGE_BRANCH_TYPE.REWARD_TEAM or 
                sysBranch.type == IntanceConst.STAGE_BRANCH_TYPE.REWARD_ITEM_TEAM
                then 
                    self:addChild(buildingIcon,5)
                else
                    self:addChild(buildingIcon,4)
                end
                registerTouchEvent(buildingIcon, nil, nil, function ()
                    self._touchBack = self:touchBranchEventIcon(buildingIcon, v)
                end)
                buildingIcon:setTouchEnabled(false)

                self:updateBranchTalk(sysBranch, buildingIcon) 
            end
        end
    end
end

--[[
--! @function initStageBranch
--! @desc 初始化关卡支线信息
--! @param  inStageInfo 章节信息
--! @param  inSysMainStage 章节地图信息
--! @return 
--]]
function IntanceSectionNode:initStageBranch(inStageInfo, inSysMainStage)
    if inSysMainStage.branchId == nil then return end

    for k,v in pairs(inSysMainStage.branchId) do
        local sysBranch = tab:BranchStage(v)
        print("v====", v, sysBranch.type)
        if inStageInfo.branchInfo[tostring(v)] == nil or 
        sysBranch.type == IntanceConst.STAGE_BRANCH_TYPE.HERO_ATTR or 
        sysBranch.type == IntanceConst.STAGE_BRANCH_TYPE.MARKET then
            local buildingIcon = self:createBranchBuildIcon(sysBranch)
            if buildingIcon ~= nil then            
                buildingIcon:setName("branch_icon_" ..  v)
                buildingIcon.stageId = inSysMainStage.id

                self._branchIcon[v] = buildingIcon

                if sysBranch.type == IntanceConst.STAGE_BRANCH_TYPE.WAR or 
                sysBranch.type == IntanceConst.STAGE_BRANCH_TYPE.REWARD_TEAM or 
                sysBranch.type == IntanceConst.STAGE_BRANCH_TYPE.REWARD_ITEM_TEAM or 
                sysBranch.type == IntanceConst.STAGE_BRANCH_TYPE.TALK
                then 
                    self:addChild(buildingIcon,5)
                else
                    self:addChild(buildingIcon,4)
                end
                registerTouchEvent(buildingIcon, nil, nil, function ()
                    self._touchBack = self:touchBranchEventIcon(buildingIcon, v)
                end)
                buildingIcon:setTouchEnabled(false)
                -- 个别支线默认隐藏
                print("sysBranch====================", sysBranch.id, sysBranch.sign,inStageInfo.star )
                if sysBranch.sign == 1 and inStageInfo.star <= 0 then
                    buildingIcon:setVisible(false)
                end
                if inStageInfo.star > 0 then 
                    self:updateBranchTalk(sysBranch, buildingIcon) 
                end
                -- 处理一些特定类型的特殊处理
                if self["otherHandleBranch" .. sysBranch.type] ~= nil then 
                    self["otherHandleBranch" .. sysBranch.type](self, buildingIcon, sysBranch)
                end
            end
        end
    end
end


function IntanceSectionNode:otherHandleBranch13(buildingIcon, sysBranch)
    local nameBg = cc.Scale9Sprite:createWithSpriteFrameName("intanceImageUI_0421DayBranchNameBg1.png")
    local tip = cc.Label:createWithTTF(lang(sysBranch.title), UIUtils.ttfName, 18)
    tip:setAnchorPoint(0.5, 0.5)
    tip:setColor(cc.c4b(255, 253, 226,255))
    nameBg:addChild(tip)
    nameBg:setCapInsets(cc.rect(14, 0, 1, 1))
    nameBg:setContentSize(tip:getContentSize().width + 30, nameBg:getContentSize().height)
    nameBg:setAnchorPoint(0.5, 0)
    nameBg:setPosition(buildingIcon:getContentSize().width * 0.5, 0)
    nameBg:setScale(1 / buildingIcon:getScaleX())
    tip:setPosition(nameBg:getContentSize().width * 0.5, nameBg:getContentSize().height * 0.5)
    buildingIcon:addChild(nameBg, 10) 
end

function IntanceSectionNode:otherHandleBranch11(buildingIcon, sysBranch)
    local nameBg = cc.Scale9Sprite:createWithSpriteFrameName("intanceImageUI_0421DayBranchNameBg1.png")
    local tip = cc.Label:createWithTTF(lang(sysBranch.title), UIUtils.ttfName, 18)
    tip:setAnchorPoint(0.5, 0.5)
    tip:setColor(cc.c4b(255, 253, 226,255))
    nameBg:addChild(tip)
    nameBg:setCapInsets(cc.rect(14, 0, 1, 1))
    nameBg:setContentSize(tip:getContentSize().width + 30, nameBg:getContentSize().height)
    nameBg:setAnchorPoint(0.5, 0)
    nameBg:setPosition(buildingIcon:getContentSize().width * 0.5, 0)
    nameBg:setScale(1 / buildingIcon:getScaleX())
    tip:setPosition(nameBg:getContentSize().width * 0.5, nameBg:getContentSize().height * 0.5)
    buildingIcon.updateState = function()
        if buildingIcon.stateBg  ~= nil then 
            buildingIcon.stateBg:removeFromParent() 
            buildingIcon.stateBg = nil
        end
        local intanceModel = self._modelMgr:getModel("IntanceModel")
        local branchInfo = intanceModel:getStageInfo(buildingIcon.stageId).branchInfo
        local branchLevel = 0
        if branchInfo[tostring(sysBranch.id)] ~= nil then 
            branchLevel = tonumber(branchInfo[tostring(sysBranch.id)])
        end
        local branchLevels = {"C", "B", "A", "S"}
        local stateBg = cc.Sprite:createWithSpriteFrameName("intanceImageUI_0421DayTempBg1.png")                
        stateBg:setAnchorPoint(0.5, 1)    
        stateBg:setPosition(buildingIcon:getContentSize().width * 0.5, 0)

        local tips1 = {}
        tips1[1] = cc.Label:createWithTTF("认可度:", UIUtils.ttfName, 16)
        tips1[1]:setColor(cc.c4b(255, 253, 226,255))
        if branchLevel == 0 then
            tips1[2] = cc.Label:createWithTTF("无",UIUtils.ttfName, 16)
            tips1[2]:setColor(UIUtils.colorTable.ccUIBaseColor3)
        else
            tips1[2] = cc.Label:createWithTTF(branchLevels[branchLevel],UIUtils.ttfName, 16)
            tips1[2]:setColor(cc.c4b(255, 253, 226,255))
        end
        tips1[3] = cc.Label:createWithTTF("(", UIUtils.ttfName, 16)
        if branchLevel < 4 then
            tips1[4] = cc.Label:createWithTTF("可挑战", UIUtils.ttfName, 16)
            tips1[4]:setColor(UIUtils.colorTable.ccUIBaseColor2)
        else
            tips1[4] = cc.Label:createWithTTF("已完成", UIUtils.ttfName, 16)
            tips1[4]:setColor(UIUtils.colorTable.ccUIBaseColor7)
        end
        tips1[5] = cc.Label:createWithTTF(")", UIUtils.ttfName, 16)
        local nodeTip1 = UIUtils:createHorizontalNode(tips1)
        nodeTip1:setAnchorPoint(cc.p(0.5, 0.5))
        nodeTip1:setPosition(stateBg:getContentSize().width * 0.5, stateBg:getContentSize().height * 0.5)
        stateBg:addChild(nodeTip1, 1)                
        buildingIcon:addChild(stateBg)
        stateBg:setScale(1 / buildingIcon:getScaleX())
        buildingIcon.stateBg = stateBg
    end
    buildingIcon.updateState()
    buildingIcon:addChild(nameBg, 10)        
end
function IntanceSectionNode:activeStageBranch(inStageInfo, inSysMainStage)
    if inSysMainStage.branchId == nil then 
        return 
    end
    for k,v in pairs(inSysMainStage.branchId) do
        local branchIcon = self:getBranchBuildingById(v)
        if branchIcon ~= nil then 
            local sysBranch = tab:BranchStage(v)
            -- 个别支线默认隐藏
            if sysBranch.sign == 1 then
                local branchOpenAnim = mcMgr:createViewMC("zhixiankaiqi2_zhixiankaiqi", false)  
                branchOpenAnim:addCallbackAtFrame(34, function()
                    local branchOpenAnim1 = mcMgr:createViewMC("zhixiankaiqi1_zhixiankaiqi", false)
                    branchIcon:getParent():addChild(branchOpenAnim1, 6) 
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

--[[
--! @function createStarInfo
--! @desc 创建星星信息层
--! @return 
--]]
function IntanceSectionNode:createStarInfo()
    local starBg = cc.Sprite:createWithSpriteFrameName("intanceImageTps_starBg.png")
    -- starBg:setAnchorPoint(cc.p(0.5,0.5))
    starBg:setName("star_bg")
    
    for i=1,3 do
        local star = mcMgr:createViewMC("xingxingxunhuan_xingxingintanceanim", true)        
        star:setName("star_" .. i )
        star:setVisible(false)
        if i%2 ~= 0 then
            star:setScale(0.8)
            if i  == 1 then
                star:setPosition(17 + i * 29, starBg:getContentSize().height/2 - 2)
            else
                star:setPosition(14 + i * 29, starBg:getContentSize().height/2 - 2)
            end
        else
            star:setPosition(15 + i * 29, starBg:getContentSize().height/2 + 1)
        end
        starBg:addChild(star,5)
    end

    local starBox = mcMgr:createViewMC("xingxingkuangdonghua_xingxingintanceanim", false)
    starBox:setPosition(starBg:getContentSize().width/2, starBg:getContentSize().height/2 - 4)
    starBox:gotoAndStop(starBox:getTotalFrames())
    starBox:setName("star_box")
    starBox:setVisible(false)
    starBg:addChild(starBox)
    -- starBox:setOpacity(0)

    return starBg
end


--[[
--! @function createCastleStarInfo
--! @desc 创建攻城战星星信息层
--! @return 
--]]
function IntanceSectionNode:createCastleStarInfo()
    local starBg = cc.Sprite:createWithSpriteFrameName("intanceImageTps_starBg2.png")
    -- starBg:setAnchorPoint(cc.p(0.5,0.5))
    starBg:setName("star_bg")
    
    for i=1,3 do
        local star = mcMgr:createViewMC("xingxingxunhuan_xingxingintanceanim", true)
       
        star:setName("star_" .. i )
        star:setVisible(false)
        if i%2 ~= 0 then
            star:setScale(0.8)
            if i  == 1 then
                star:setPosition(24 + i * 29, starBg:getContentSize().height/2 - 2)
            else
                star:setPosition(22 + i * 29, starBg:getContentSize().height/2 - 2)
            end
        else
            star:setPosition(23 + i * 29, starBg:getContentSize().height/2 + 1)
        end
        starBg:addChild(star,5)
    end

    local starBox = mcMgr:createViewMC("xingxingkuangdonghua2_xingxingintanceanim", false)
    starBox:setPosition(starBg:getContentSize().width/2-2, starBg:getContentSize().height/2)
    starBox:gotoAndStop(starBox:getTotalFrames())
    starBox:setName("star_box")
    starBox:setVisible(false)
    starBg:addChild(starBox)
    -- starBox:setOpacity(0)

    return starBg
end


--[[
--! @function updateAminPos
--! @desc 更新地图英雄坐标点
--! @param inSysMapData 地图信息
--! @return 
--]]
function IntanceSectionNode:updateAminPos(inSysMapData)
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
function IntanceSectionNode:getStageBuildingById(inStageId)
    local stageView = self:getChildByName("building_icon" .. inStageId)
    -- if stageView == nil then 
    --     local tempStageId = self._sysSection.includeStage[#self._sysSection.includeStage]
    --     stageView = self:getChildByName("building_icon" .. tempStageId)
    -- end
    return stageView
end


function IntanceSectionNode:getBranchBuildingById(inBranchId)
    return self._branchIcon[inBranchId]
end


--[[
--! @function completeStage
--! @desc 完成章节并更新建筑相关
--! @param  inStageId 完成章节id
--! @return 
--]]
function IntanceSectionNode:completeStage(inStageId, inNotActive)
    if self._lockCallBack ~= nil then 
        self._lockCallBack(true)
    end
    if inNotActive == nil then
        inNotActive = false
    end
    local stageView = self:getChildByName("building_icon" .. inStageId)

    -- starBg:setPosition(stageView:getContentSize().width/2,-10)

    local mainsData = self._intanceModel:getData().mainsData
    self._curStageId = mainsData.curStageId

    -- 开启后再更新特效
    -- self:updateBuildingEffect(self._curStageId)
    -- self:updateBranchEffect(self._curStageId)

    local sysMainStageMap = tab:MainStageMap(inStageId)
    local sysMainStage = tab:MainStage(inStageId)

    local stageInfo = self._intanceModel:getStageInfo(inStageId)

    local starBg = stageView:getChildByName("star_bg")
    local haveStarNum = 0
    for i=1,3 do
        if starBg:getChildByName("star_" .. i):isVisible() then 
            haveStarNum = i
        end
    end

    if haveStarNum == 3 or haveStarNum == stageInfo.star then 
        if self._lockCallBack ~= nil then 
            self._lockCallBack(false)
        end
        return
    end

    --------------------------------获得星星阶段------------------------------------
    -- 胜利动画
    function runWinAction()
        -- local starBg = stageView:getChildByName("star_bg")
        starBg:setVisible(true)
        self._parentView:getParentView():runStarAnim(1)

        local animName = nil
        
        local posY = 0
        local  posX = 0
        animName = "xingxingdonghua_xingxingintanceanim"
        if sysMainStage.siegeid then
            posX = 16.5
            posY = 3         
        else
            posX = 14.5
            posY = -2
        end

        for i = haveStarNum + 1, stageInfo.star do
            local star = starBg:getChildByName("star_" .. i)
            local tmpStar = mcMgr:createViewMC(animName, false, true,
            function (_, sender)
                star:setVisible(true)
                
                star:gotoAndPlay(1)          
            end)

           
            tmpStar:setName("tmp_star")
            if i%2 ~= 0 then
                tmpStar:setScale(0.8)
            end
            tmpStar:setPosition(star:getPositionX(), star:getPositionY())

            starBg:addChild(tmpStar)
            tmpStar:stop()

            tmpStar:setVisible(false)
            tmpStar:runAction(cc.Sequence:create(cc.DelayTime:create((i - haveStarNum + 1) * 0.23), 
                cc.CallFunc:create(function ()
                    tmpStar:gotoAndPlay(1)
                    tmpStar:setVisible(true)
                end)))

        end

        if stageInfo.star == 3 then
            local starBox = starBg:getChildByName("star_box")
            starBox:runAction(cc.Sequence:create(cc.DelayTime:create((stageInfo.star - haveStarNum + 1) * 0.28), 
                cc.CallFunc:create(function ()
                    starBox:setVisible(true)
                    starBox:gotoAndPlay(1)
                end)))
        end
        -- 如果不是当前副本则不播放胜利动画
        if self._heroStandByStageId ~= inStageId then 
            if self._lockCallBack ~= nil then 
                self._lockCallBack(false)
            end   
            return
        end
        local i = 0
        self._intanceMcAnimNode:runByName("win", function(sender)
            i = i + 1
            if i == 2 then
                self._intanceMcAnimNode:runStandBy()
                return
            end
            if self._lockCallBack ~= nil then 
                self._lockCallBack(false)
            end
            if haveStarNum <= 0 and #sysMainStageMap.point > 1 then
                self:activeStageBranch(stageInfo, sysMainStage)
                if inNotActive == false then 
                    self:activeStageBuilding()
                else
                    if self._completeCallBack ~= nil then 
                        self._completeCallBack()
                        self._completeCallBack = nil
                    end
                end
            end
        end)
    end
    -- 默认支线都显示
    if haveStarNum == 0 then 
       self:activeHideDecorate(sysMainStage.id)
    end
    if haveStarNum < 3 then  
        runWinAction()
    end
end


--[[
--! @function updateBuildingStar
--! @desc 更新建筑星星信息
--! @param  inStar 当前建筑星级
--! @param  inStageId 副本章节ID
--! @param  starBg 星星背景层
--! @return 
--]]
function IntanceSectionNode:updateBuildingStar(inStar, inStageId, starBg)
    if inStar <= 0 and (self._curStageId < inStageId 
        or (inStageId == self._curStageId and self._heroStandByStageId ~= self._curStageId))then 
        starBg:setVisible(false)
    else
        starBg:setVisible(true)
        for i=1,3 do
            local star = starBg:getChildByName("star_" .. i)
            if inStar >= i then 
                star:play()
                star:setVisible(true)
            else
                star:stop()
                star:setVisible(false)
            end
        end
        local starBgBox = starBg:getChildByName("star_box")
        if inStar == 3 then 
            starBgBox:gotoAndStop(starBgBox:getTotalFrames())
            starBgBox:setVisible(true)
        else
            starBgBox:stop()
            starBgBox:setVisible(false)
        end
    end
end


--[[
--! @function loadBigIcon
--! @desc 加载大图
--! @param  inView 小图相关view
--! @param  inIndex 副本章节索引
--! @return 
--]]
function IntanceSectionNode:loadBigIcon(inView, inIndex)
    local stageId = self._sysSection.includeStage[inIndex]
    local sysMainStageMap = tab:MainStageMap(stageId)
    local stageInfo = self._intanceModel:getStageInfo(stageId)

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
    showIcon:loadTexture("asset/uiother/intance/" .. sysMainStageMap.img .. ".png")
    showIcon:setAnchorPoint(cc.p(0.5,0))
    showIcon:setPosition(inView:getContentSize().width/2,0)
    -- showIcon:setVisible(false)
    showIcon:setScale(0.48)
    showIcon.notError = 1
    -- 加载大图时隐藏星星相关信息
    local starBg = inView:getChildByName("star_bg")
    starBg:setVisible(false)

    for k,v in pairs(self._branchIcon) do
        -- cachevisible的原因是因为某些支线增加了默认隐藏
        v.cacheVisible = v:isVisible()
        v:setVisible(false)
        if v.talk ~= nil then 
            v.talk:setVisible(false)
        end
    end

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
    local buildingAnim = mcMgr:createViewMC("jianzhuguangxiao_intancebuildingeffect-HD", true, false)
    buildingAnim:setCascadeOpacityEnabled(true, true)
    buildingAnim:setOpacity(0)
    buildingAnim:setPosition(showIcon:getContentSize().width/2, 550)
    showIcon:addChild(buildingAnim, -1)
    buildingAnim:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.FadeIn:create(0.5)))
    buildingAnim.notError = 1
    -- 暂时隐藏英雄头顶的光标
    if self._intanceMcAnimNode ~= nil then
        local pointTip = self._intanceMcAnimNode:getChildByName("pointTip")
        pointTip:setVisible(false)
    end

    -- 关闭建筑面板的回调
    self._showCallBack(showIcon, sysMainStageMap.id, anim, function(inState)
        if inState == 1 then 
            -- 增加noterror 是因为buildingAnim 有可能被提前remove掉了，会导致这里继续执行runAction
            if buildingAnim ~= nil and buildingAnim.notError == 1 then
                buildingAnim:runAction(cc.FadeOut:create(0.4))
            end
            return
        end
        if self._intanceMcAnimNode ~= nil then
            local pointTip = self._intanceMcAnimNode:getChildByName("pointTip")
            pointTip:setVisible(true)  
        end
        if showIcon ~= nil and showIcon.notError == 1 then
            showIcon:removeFromParent()
        end
        self._viewMgr:removeTexture(self._parentView:getParentView():getClassName(), "asset/uiother/intance/" .. sysMainStageMap.img .. ".png")
        -- 星星相关处理
        self:updateBuildingStar(stageInfo.star, sysMainStageMap.id, starBg)
        for k,v in pairs(self._branchIcon) do
            if v.cacheVisible == true then
                v:setVisible(true)
                if v.talk ~= nil then 
                    v.talk:setVisible(true)
                end
            end
        end
        -- 攻城战提示
        local siegeTip = inView:getChildByName("siegeTip")
        if siegeTip ~= nil then 
            siegeTip:setVisible(true)
        end
    end)
end

--[[
--! @function setSwitchSectionBegin
--! @desc 切换关卡开始调用
--! @param  isMoveIn 是否移动进入
--! @return 
--]]
function IntanceSectionNode:setSwitchSectionBegin(isMoveIn)
    if not isMoveIn then
        self:releaseAminLayer()

        self:releaseBuildingIcon()

        self:releaseBranchIcon()
    end
    print("self._isFirstEnter==================")
    if self._isFirstEnter then 
        if self._intanceMcAnimNode ~= nil then 
            self._intanceMcAnimNode:setVisible(false)
        end
    end
end


--[[
--! @function setSwitchSectionFinish
--! @desc 切换关卡结束调用
--! @param  isMoveIn 是否移动进入
--! @return 
--]]
function IntanceSectionNode:setSwitchSectionFinish(isMoveIn)
    self._isMoveIn = isMoveIn
    self:runAminLayer() 
    if not self._isFirstEnter then 
        return
    end
    local function showHero()
        -- 新章节开启
        if self._sysSection.id > IntanceConst.FIRST_SECTION_ID  then 
            if self._lockCallBack ~= nil then 
                self._lockCallBack(true)
            end
            audioMgr:playSound("NewChapter_1")
            self._isFirstEnter = false
            local intancenopen = mcMgr:createViewMC("run_intancenopen", false, true, function()
                local sysSectionInfo = tab.sectionInfo[self._sysSection.id]
                if sysSectionInfo ~= nil and sysSectionInfo.position ~= nil then 
                    if self._lockCallBack ~= nil then 
                        self._lockCallBack(false)
                    end                                
                    self:activeStageBuilding()
                    return
                end
                if self._lockCallBack ~= nil then 
                    self._lockCallBack(false)
                end
                self:activeStageBuilding()
            end)
            intancenopen:setPosition(IntanceConst.MAX_SCREEN_WIDTH/2, IntanceConst.MAX_SCREEN_HEIGHT/2)
            self._parentView:addChild(intancenopen, 100000)
        else
            self:activeStageBuilding()
        end
    end

    local function showPlot()
        if self._sysSection.id == IntanceConst.FIRST_SECTION_ID then showHero() return end
        
        local sysMainSectionMap = tab:MainSectionMap(self._sysSection.id)
        if sysMainSectionMap.plotBegin == nil then showHero() return end

        self._viewMgr:showView("intance.IntanceMcPlotView", {plotId = sysMainSectionMap.plotBegin, callback = function()
            self._viewMgr:popView()
            showHero()
        end})        
    end


    if self["enterSectionAction" .. self._sysSection.id] ~= nil then 
        self["enterSectionAction" .. self._sysSection.id](self, showPlot)
    else
        showPlot()
    end
end
 
function IntanceSectionNode:runMagicEyeAction(inShowStageId, inBranchId, inCallback)
    local sysMainSectionMap = tab:MainSectionMap(self._sysSection.id)
    if sysMainSectionMap.eye == nil then 
        return
    end
    audioMgr:playSound("DoomEye")
    if self._lockCallBack ~= nil then 
        self._lockCallBack(true)
    end



    local showTip =  true
    for k,v in pairs(self._sysSection.includeStage) do
        local sysMainStageMap = tab:MainStageMap(v)
        if self._buildingFog[sysMainStageMap.id] ~= nil then
            showTip = false
            break
        end
    end

    if showTip then 
        if self._lockCallBack ~= nil then 
            self._lockCallBack(false)
        end
        self._viewMgr:showTip(lang("TIPS_MAGICEYES"))
        if inCallback ~= nil then 
            inCallback()
        end
        return
    end

    local sysBranchStage = tab:BranchStage(inBranchId)
    local magicEyeMc = mcMgr:createViewMC("moyan_intancemagiceye", false, false, function(_, sender)
        sender:setVisible(false)
    end, nil, nil, false)
    magicEyeMc:setPosition(self:getContentSize().width - 100, 0)
    self:addChild(magicEyeMc, 9999)
    magicEyeMc:setVisible(false)
    magicEyeMc:stop()
    
    local x, y = IntanceConst.MAX_SCREEN_WIDTH/2, IntanceConst.MAX_SCREEN_HEIGHT/2
    local cachePoint = self:convertToNodeSpace(cc.p(x, y))

    local point1 = self:convertToWorldSpace(cc.p(sysBranchStage.position[1], sysBranchStage.position[2]))
    local point = self._parentView:convertToMapSpace(point1)
    self._parentView:screenToPos(point.x, point.y, true, function()
        magicEyeMc:setPosition(sysBranchStage.position[1], sysBranchStage.position[2])
        magicEyeMc:setVisible(true)
        magicEyeMc:gotoAndPlay(1)
        local fogIcons = self._buildingFog[inShowStageId]
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
                                    local point1 = self:convertToWorldSpace(cachePoint)
                                    local point = self._parentView:convertToMapSpace(point1)
                                    self._parentView:screenToPos(point.x, point.y,true,function()
                                        if self._lockCallBack ~= nil then 
                                            self._lockCallBack(false)
                                        end
                                        if inCallback ~= nil then 
                                            inCallback()
                                        end
                                    end, 0.5)
                                end)
        ))
    end, 0.5)    
end

function IntanceSectionNode:enterSectionAction71002(callback)
    print('IntanceSectionNode:enterSectionAction71002======================')
    if self._lockCallBack ~= nil then 
        self._lockCallBack(true)
    end
    ScheduleMgr:delayCall(100, self, function()
        self._stopShip = mcMgr:createViewMC("shuibo_intanceguide2", false)
        self._stopShip:setPosition(self:getContentSize().width - 100, 0)
        self:addChild(self._stopShip, 3)
        self._stopShip:runAction(cc.Sequence:create(
            cc.EaseIn:create(cc.MoveTo:create(2, cc.p(self:getContentSize().width - 489, 70)), 1),
            cc.CallFunc:create(function()
                local x, y = self._stopShip:getPosition()
                self._stopShip:clearCallbacks()
                self._stopShip:stop()
                self._stopShip:removeFromParent()
                self._stopShip = mcMgr:createViewMC("fanguodu_intanceguide2", true, true, function(_, sender)  
                        local x, y = self._stopShip:getPosition()
                        self._stopShip:clearCallbacks()
                        self._stopShip:stop()
                        self._stopShip:removeFromParent()
                        self._stopShip = mcMgr:createViewMC("stopship_intanceguide2", true, false)
                        self._stopShip:setPosition(x, y)
                        self:addChild(self._stopShip, 3)
                        if self._lockCallBack ~= nil then 
                            self._lockCallBack(false)
                        end
                        callback()
                    end)
                -- 当前章被切换时会被remove掉，所以不用特别处理最后一个stopShip的停留
                self._stopShip:setPosition(x, y)
                self:addChild(self._stopShip, 3 )
                -- callback()
            end)))  
    end)
end

--[[
--! @function activeStageBuilding
--! @desc 激活可攻打建筑
--! @return 
--]]
function IntanceSectionNode:activeStageBuilding()
    if self._lockCallBack ~= nil then 
        self._lockCallBack(true)
    end
    local pointTip = self._intanceMcAnimNode:getChildByName("pointTip")
    if pointTip ~= nil then 
        pointTip:setVisible(false)
    end
    local sysMainStageMap = tab:MainStageMap(self._heroStandByStageId)
    local lastPointType = sysMainStageMap.lastPointType
    local firstPointType = sysMainStageMap.firstPointType
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
                if self._lockCallBack ~= nil then 
                    self._lockCallBack(false)
                end
                if self._completeCallBack ~= nil then 
                    self._completeCallBack()
                    self._completeCallBack = nil
                end

                if self._buildingFog[self._curStageId] ~= nil then 
                    for h,g in pairs(self._buildingFog[self._curStageId]) do
                        local action2 = cc.FadeOut:create(0.3 * h)
                        local call1 = cc.CallFunc:create(function()
                            g:removeFromParent()
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
        if k == maxSize and lastPointType == IntanceConst.LAST_POINT_TYPE.PORTAL then
            isLastPoint = true
            -- if lastPointType == IntanceConst.LAST_POINT_TYPE.PORTAL then
            --     tempPoint = cc.Sprite:createWithSpriteFrameName("intanceImageTps_temp1.png")
            --     local tempPoint1 = cc.Sprite:createWithSpriteFrameName("intanceImageTps_temp1.png")
            --     tempPoint1:setAnchorPoint(0.5, 0.5)
            --     tempPoint1:setName("tempPoint1")
            --     tempPoint1:setPosition(tempPoint:getContentSize().width/2, tempPoint:getContentSize().height/2)
            --     tempPoint:addChild(tempPoint1)
            -- else
            --     tempPoint = cc.Sprite:createWithSpriteFrameName("intanceImageUI4_starPortal.png")
            tempPoint = cc.Sprite:createWithSpriteFrameName("intanceImageUI4_starPortal.png")
            tempPoint:setAnchorPoint(0.5, 0)
            audioMgr:playSound("telptout")
            local anim = mcMgr:createViewMC("chuansongmenlan_intanceportal", true)
            anim:setPosition(tempPoint:getContentSize().width/2, tempPoint:getContentSize().height/2)
            tempPoint:addChild(anim)
            -- end
            tempPoint:setPosition(v[1], v[2])
            tempPoint:setName("temp_point" .. k)
            self:addChild(tempPoint,100)
        elseif k ~= 1  then 
            tempPoint = cc.Sprite:createWithSpriteFrameName("intanceImageTps_temp2.png")
            tempPoint:setPosition(v[1], v[2])
            tempPoint:setName("temp_point" .. k)
            self:addChild(tempPoint,100)
        else
            self._intanceMcAnimNode:setVisible(true)
            if firstPointType == IntanceConst.LAST_POINT_TYPE.GENERAL then
                tempPoint = cc.Sprite:createWithSpriteFrameName("intanceImageTps_temp2.png")
            else
                tempPoint = cc.Sprite:createWithSpriteFrameName("intanceImageUI4_endPortal.png")
                tempPoint:setAnchorPoint(0.5, 0)

                local anim = mcMgr:createViewMC("chuansongmenhuang_intanceportal", true)
                anim:setPosition(tempPoint:getContentSize().width/2, tempPoint:getContentSize().height/2)
                tempPoint:addChild(anim)

                local anim1 = mcMgr:createViewMC("shanhuang_intanceportal", false, true)
                anim1:setPosition(v[1], v[2] + tempPoint:getContentSize().height/2)
                self:addChild(anim1, 9999)
                self._intanceMcAnimNode:setCascadeOpacityEnabled(true, true)
                self._intanceMcAnimNode:setOpacity(0)
                self._intanceMcAnimNode:runAction(cc.Sequence:create(cc.FadeIn:create(1.2)))
            end
            tempPoint:setPosition(v[1], v[2])
            tempPoint:setName("temp_point" .. k)
            self:addChild(tempPoint,100)
        end
        if curbuildView == nil and k == maxSize then 
            isLastPoint = true
        end
        updatePointState(tempPoint, isLastPoint)
    end
    -- 特殊X点特殊处理 在建筑中间
    if lastPointType == IntanceConst.LAST_POINT_TYPE.GENERAL and 
        curbuildView ~= nil then
        local tempPoint = cc.Sprite:createWithSpriteFrameName("intanceImageTps_temp1.png")
            local tempPoint1 = cc.Sprite:createWithSpriteFrameName("intanceImageTps_temp1.png")
            tempPoint1:setAnchorPoint(0.5, 0.5)
            tempPoint1:setName("tempPoint1")
            tempPoint1:setPosition(tempPoint:getContentSize().width/2, tempPoint:getContentSize().height/2)
        tempPoint:addChild(tempPoint1)
        tempPoint:setName("temp_point" .. (maxSize + 1))
        tempPoint:setPosition(curbuildView:getPositionX(), curbuildView:getPositionY() + curbuildView:getContentSize().height/2)
        self:addChild(tempPoint,100)
        updatePointState(tempPoint, true)
    end
end

--[[
--! @function heroRunningAmin
--! @desc 英雄跑向建筑
--！@param inIndex 地图绿点Index
--! @return 
--]]
function IntanceSectionNode:heroRunningAmin(inIndex)
    local sysMainStageMap = tab:MainStageMap(self._heroStandByStageId)
    local sysMapData = sysMainStageMap.point[inIndex]
    local maxSize = #sysMainStageMap.point
    local lastPointType = sysMainStageMap.lastPointType
    -- local delay = cc.DelayTime:create(1)
    self._tempPoints = nil
    local function tempCallback()
        local tempPoint = self:getChildByName("temp_point" .. inIndex)
        -- 传送门特殊处理
        if tempPoint ~= nil then 
            if inIndex == maxSize and 
                lastPointType == IntanceConst.LAST_POINT_TYPE.PORTAL then 
                self._tempPoints = {}
                table.insert(self._tempPoints, tempPoint)
            else
                tempPoint:removeFromParent()
            end
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
            if lastPointType == IntanceConst.LAST_POINT_TYPE.GENERAL then
                local tempPoint = self:getChildByName("temp_point" .. (inIndex +1))
                if tempPoint ~= nil then 
                    tempPoint:removeFromParent()
                end
            end
            self._intanceMcAnimNode:runStandBy()
            self:updateAminPos(sysMapData)

            -- 更改英雄实际站位
            self._heroStandByStageId = self._curStageId

            local curSectionId = self._intanceModel:getCurMainSectionId()
            

            local function finishCallback ()
                if self._heroRunningCallback ~= nil then 
                    self._heroRunningCallback()
                    self._heroRunningCallback = nil
                end
                if self._sysSection ~= nil and 
                    curSectionId == self._sysSection.id then
                    local curSysMainStageMap = tab:MainStageMap(self._curStageId)
                    dump(curSysMainStageMap, "test", 10)

                    if curSysMainStageMap.showPic ~= nil then
                        self._viewMgr:showDialog("intance.IntanceStagePlotView", 
                            {
                                stageId = curSysMainStageMap.id, 
                                callback = function()
                                    local buildingIcon = self:getChildByName("building_icon" .. self._curStageId)
                                    self:loadBigIcon(buildingIcon, buildingIcon.showIndex)
                                end
                            },true)
                    else
                        local buildingIcon = self:getChildByName("building_icon" .. self._curStageId)
                        self:loadBigIcon(buildingIcon, buildingIcon.showIndex)
                    end
                end
            end
            local pointTip = self._intanceMcAnimNode:getChildByName("pointTip")
            if pointTip ~= nil then 
                pointTip:setVisible(true)
            end
            if lastPointType == IntanceConst.LAST_POINT_TYPE.PORTAL then
                ScheduleMgr:delayCall(500, self, function()
                    audioMgr:playSound("telptin")
                end) 
                local anim1 = mcMgr:createViewMC("shanlan_intanceportal", false, true)
                anim1:setPosition(tempPoint:getPositionX(), tempPoint:getPositionY() + tempPoint:getContentSize().height/2)
                self:addChild(anim1, 9999)
                self._intanceMcAnimNode:runAction(cc.Sequence:create(cc.FadeOut:create(0.48), cc.CallFunc:create(finishCallback)))
            else
                finishCallback()
            end

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
--! @function runAminLayer
--! @desc 运行其他动画，鸟云
--! @return 
--]]
function IntanceSectionNode:releaseAminLayer(isClearMc)
    self._aminLayer:stopAllActions()
    self._effectLayer:stopAllActions()

    self._topLayer:stopAllActions()

    self._aminLayer:removeAllChildren()
    self._effectLayer:removeAllChildren()
    self._topLayer:removeAllChildren()

    if isClearMc ~= nil and isClearMc == true then 
        mcMgr:clear()
    end
end

--不需遮罩特效
function IntanceSectionNode:sectionEffect(sectionEffectName, sfc, tc)
    if sectionEffectName[self._sysSection.id] == nil then
        return
    end
    if sectionEffectName[self._sysSection.id] ~= nil then 
        mcMgr:loadRes(sectionEffectName[self._sysSection.id], function()
            -- if not self._isMoveIn then 
            --     sfc:removeSpriteFramesFromFile("asset/anim/intanceeffectimage.plist")
            --     tc:removeTextureForKey("asset/anim/intanceeffectimage.png")
            --     return
            -- end
            local amin1 = mcMgr:createViewMC(sectionEffectName[self._sysSection.id], true)
            amin1:setPosition(self:getContentSize().width/2, self:getContentSize().height/2)
            self._aminLayer:addChild(amin1)
            amin1:setCascadeOpacityEnabled(true, true)
            amin1:setOpacity(0)
            amin1:runAction(cc.FadeIn:create(0.5))
        end)
    end
end

--需加遮罩特效
function IntanceSectionNode:sectionMEffect(sectionMEffectName, sectionMEffectName2, sectionMaskName, sectionAdjustImg, sfc, tc)
    if sectionMEffectName[self._sysSection.id] == nil then
        return
    end
    
    local addMEffect = function(width, height, widthOffset, heightOffset, offsetX, offsetY, maskImg, adjustImg)
        --添加资源
        mcMgr:loadRes(sectionMEffectName[self._sysSection.id], function()
            if not self._isMoveIn then 
                sfc:removeSpriteFramesFromFile("asset/anim/intanceeffectimage.plist")
                tc:removeTextureForKey("asset/anim/intanceeffectimage.png")
                return
            end

            local mc1 = mcMgr:createViewMC(sectionMEffectName[self._sysSection.id], true)    --特效1 岩浆
            mc1:setPosition(width + offsetX, height + offsetY)   --跟地图中点对齐

            local clipNode = cc.ClippingNode:create()   
            clipNode:setInverted(false)   --false显示抠掉部分

            local mask = cc.Sprite:create(maskImg .. ".png")  --遮罩
            mask:setPosition(cc.p(width, height))
            mask:setAnchorPoint(0.5, 0.5)
            clipNode:setStencil(mask)  --遮罩和地图对齐
            clipNode:setAlphaThreshold(0.01)
            clipNode:addChild(mc1)  --添加裁剪对象
            clipNode:setAnchorPoint(cc.p(0, 0))
            clipNode:setPosition(0, 0)
            self._aminLayer:addChild(clipNode)
            clipNode:setCascadeOpacityEnabled(true, true)
            clipNode:setOpacity(0)
            clipNode:runAction(cc.FadeIn:create(0.5))

            local mc2 = mcMgr:createViewMC(sectionMEffectName2[self._sysSection.id], true)    --特效2 烟
            mc2:setAnchorPoint(0.5, 0.5)
            mc2:setPosition(self:getContentSize().width/2 , self:getContentSize().height/2)
            self._aminLayer:addChild(mc2, 10)
            mc2:setCascadeOpacityEnabled(true, true)
            mc2:setOpacity(0)
            mc2:runAction(cc.FadeIn:create(0.5))

            local adjustImg = cc.Sprite:create(adjustImg .. ".png")  --调整图   
            adjustImg:setAnchorPoint(0.5, 0.5)
            adjustImg:setPosition(width+widthOffset, height+heightOffset)
            self._aminLayer:addChild(adjustImg, 8)
            adjustImg:setCascadeOpacityEnabled(true, true)
            adjustImg:setOpacity(0)
            adjustImg:runAction(cc.FadeIn:create(0.5))
        end)
    end

    local mapSize = self:getContentSize()
    if self._sysSection.id == 71004 then
        local width, height, widthOffset, heightOffset = 812, 412, -1, -2   --调整图
        local offsetX, offsetY = 88, 379   
        local maskImg = "asset/uiother/map/" .. sectionMaskName[self._sysSection.id]
        local adjustImg = "asset/uiother/map/" .. sectionAdjustImg[self._sysSection.id]
        addMEffect(width, height, widthOffset, heightOffset, offsetX, offsetY, maskImg, adjustImg)
    elseif self._sysSection.id == 71005 then
        local width, height, widthOffset, heightOffset = mapSize.width/2 - 81, mapSize.height/2 - 220, -1, 0 
        local offsetX, offsetY = 0, 0 
        local maskImg = "asset/uiother/map/" .. sectionMaskName[self._sysSection.id]
        local adjustImg = "asset/uiother/map/" .. sectionAdjustImg[self._sysSection.id]
        addMEffect(width, height, widthOffset, heightOffset, offsetX, offsetY, maskImg, adjustImg)
    elseif self._sysSection.id == 71006 then
        for i=1,2 do
            local width, height, widthOffset, heightOffset
            local offsetX, offsetY = 788, 79  
            if i == 1 then
                width, height, widthOffset, heightOffset = mapSize.width/2 - 458, mapSize.height/2 +400 , 0, 3 --上
            elseif i == 2 then
                width, height, widthOffset, heightOffset = mapSize.width/2 - 456, mapSize.height/2 -213, 1, 0  --下
            end
            local maskImg = "asset/uiother/map/" .. sectionMaskName[self._sysSection.id][i]
            local adjustImg = "asset/uiother/map/" .. sectionAdjustImg[self._sysSection.id][i]
            addMEffect(width, height, widthOffset, heightOffset, offsetX, offsetY, maskImg, adjustImg) 
        end
    end
end


--[[
--! @function runAminLayer
--! @desc 运行其他动画，鸟云
--! @return 
--]]
function IntanceSectionNode:runAminLayer()
    local sfc = cc.SpriteFrameCache:getInstance()
    local tc = cc.Director:getInstance():getTextureCache()
    local sectionEffectName = {[71001] = "humian_intanceeffecthumian",[71002] = "daditu02_intanceeffect",[71007] = "daditu07_intanceeffect", [71008]="daditu08_intanceeffect", [71009]="daditu09_intanceeffect", [71010]="daditu10_intanceeffect",[71011]="daditu11_intanceeffect", [71012]="daditu12_intanceeffect"}
    local sectionMEffectName = {[71004] = "daditu04_intanceeffectyjsm1", [71005] = "daditu05_intanceeffectyjsm1", [71006] = "daditu06_intanceeffectyjsm1"}  --岩浆
    local sectionMEffectName2 = {[71004] = "daditu041_intanceeffectyjsm1", [71005] = "daditu051_intanceeffectyjsm1", [71006] = "daditu061_intanceeffectyjsm1"}  --烟雾
    local sectionMaskName = {[71004] = "_0000_pve_daditueffect4", [71005] = "_0000_pve_daditueffect5", [71006] = {"_0000_pve_daditueffectBottom6", "_0000_pve_daditueffectTop6"} }  --遮罩
    local sectionAdjustImg = {[71004] = "_1111_pve_daditueffect4", [71005] = "_1111_pve_daditueffect5",[71006] = {"_1111_pve_daditueffectBottom6", "_1111_pve_daditueffectTop6"} }  --锯齿遮盖
    -- local otherMEffectName = "daditu06_intanceeffectyjsm"
    -- local otherMaskName1 = "_0000_pve_daditueffectTop6"
    -- local otherMaskName2 = "_0000_pve_daditueffectBottom6"

    self._aminLayer:setContentSize(self:getContentSize().width, self:getContentSize().height)
    self._topLayer:setContentSize(self:getContentSize().width, self:getContentSize().height)
    -- local bg = cc.LayerColor:create(cc.c4b(0, 0, 0, 76))
    -- bg:setContentSize(self:getContentSize().width, self:getContentSize().height)
    -- self._aminLayer:addChild(bg, 100)

    local delay = cc.DelayTime:create(3)
    local call1 = cc.CallFunc:create(function()
        -- --大地图
        -- self:sectionEffect(sectionEffectName,sfc, tc)  --不需遮罩特效
        -- self:sectionMEffect(sectionMEffectName, sectionMEffectName2, sectionMaskName, sectionAdjustImg, sfc, tc)  --加遮罩特效

        --云鸟特效
        mcMgr:loadRes("1_juqingfubenyunniao", function()
            if not self._isMoveIn or self._sysSection.id > 71012 then
                return
            end
            local cloudAnim = mcMgr:createViewMC("q"..self._sysSection.id .."_juqingfubenyunniao", true) 
            cloudAnim:setPosition(self:getContentSize().width/2 , self:getContentSize().height/2)
            self._topLayer:addChild(cloudAnim, 11)
            cloudAnim:setCascadeOpacityEnabled(true, true)
            cloudAnim:setOpacity(0)
            cloudAnim:runAction(cc.FadeIn:create(0.5))
        end)
    end)
    self._aminLayer:runAction(cc.Sequence:create(delay, call1))

    -- local delay = cc.DelayTime:create(0.5)
    -- local call1 = cc.CallFunc:create(function()
    --     mcMgr:loadRes("1_buildingeffect", function()
    --         if not self._isMoveIn then 
    --             sfc:removeSpriteFramesFromFile("asset/anim/buildingeffectimage.plist")
    --             tc:removeTextureForKey("asset/anim/buildingeffectimage.png")
    --             return
    --         end
    --         for k,v in pairs(self._sysSection.includeStage) do
    --             if self._curStageId >= v  then 
    --                 self:updateBuildingEffect(v)
    --             end
    --         end
    --     end)
    --     if self._branchIcon ~= nil and next(self._branchIcon) ~= nil then 
    --         mcMgr:loadRes("1_brancheffect", function()
    --             if not self._isMoveIn then 
    --                 sfc:removeSpriteFramesFromFile("asset/anim/brancheffectimage.plist")
    --                 tc:removeTextureForKey("asset/anim/brancheffectimage.png")
    --                 return
    --             end
    --             for k,v in pairs(self._sysSection.includeStage) do
    --                 if self._curStageId >= v  then 
    --                     self:updateBranchEffect(v)
    --                 end
    --             end
    --         end)
    --     end
    -- end)
    -- self._effectLayer:runAction(cc.Sequence:create(delay, call1))
end

--[[
--! @function updateBuildingEffect
--! @desc 更新建筑特效
--！@param inStageId 关卡id
--! @return 
--]]
function IntanceSectionNode:updateBuildingEffect(inStageId)
    local sysMainStageMap = tab:MainStageMap(inStageId)
    if sysMainStageMap.effect ~= nil then 
        print("updateBuildingEffectsysMainStageMap====", sysMainStageMap.id)
        local stageView = self:getChildByName("building_icon" .. sysMainStageMap.id)
        local effectName = sysMainStageMap.effect .. "_buildingeffect"
        if stageView ~= nil  and self._effectLayer:getChildByName(effectName .. sysMainStageMap.id) == nil then
            local amin1 = mcMgr:createViewMC(effectName, true)
            amin1:setPosition(sysMainStageMap.x, sysMainStageMap.y + stageView:getContentSize().height/2)
            amin1:setName(effectName .. sysMainStageMap.id)
            self._effectLayer:addChild(amin1)
            if sysMainStageMap.flipX == 1 then 
              amin1:setScaleX(-1)
            end
            if sysMainStageMap.flipY == 1 then 
              amin1:setScaleY(-1)
            end
            amin1:setCascadeOpacityEnabled(true, true)
            amin1:setOpacity(0)
            amin1:runAction(cc.FadeIn:create(1))
        end
    end
end


-- --[[
-- --! @function updateBuildingEffect
-- --! @desc 更新建筑特效
-- --！@param inStageId 关卡id
-- --! @return 
-- --]]
-- function IntanceSectionNode:updateBuildingEffect(inStageId)
--     local sysMainStageMap = tab:MainStageMap(inStageId)
--     if sysMainStageMap.effect ~= nil then 
--         local stageView = self:getChildByName("building_icon" .. sysMainStageMap.id)
--         local effectName = sysMainStageMap.effect .. "_buildingeffect"
--         if stageView ~= nil  and self._effectLayer:getChildByName(effectName) == nil then
--             local amin1 = mcMgr:createViewMC(effectName, true)
--             amin1:setPosition(sysMainStageMap.x, sysMainStageMap.y + stageView:getContentSize().height/2)
--             amin1:setName(effectName)
--             self._effectLayer:addChild(amin1)
--             if sysMainStageMap.flipX == 1 then 
--               amin1:setScaleX(-1)
--             end
--             if sysMainStageMap.flipY == 1 then 
--               amin1:setScaleY(-1)
--             end
--             amin1:setCascadeOpacityEnabled(true, true)
--             amin1:setOpacity(0)
--             amin1:runAction(cc.FadeIn:create(1))
--         end
--     end
-- end

--[[
--! @function updateBranchEffect
--! @desc 更新支线特效
--！@param inStageId 关卡id
--! @return 
--]]
function IntanceSectionNode:updateBranchEffect(inStageId)
    local sysMainStage = tab:MainStage(inStageId)
    if sysMainStage.branchId == nil then 
        return 
    end
    for k,v in pairs(sysMainStage.branchId) do
        local sysBranch = tab:BranchStage(v)
        local branchIcon = self._branchIcon[v]
        if branchIcon ~= nil and 
            sysBranch.effect ~= nil then
            local effectName = sysBranch.effect .. "_brancheffect"
            if branchIcon:getChildByName(effectName) == nil then 
                local amin1 = mcMgr:createViewMC(effectName, true)
                amin1:setPosition(branchIcon:getContentSize().width/2, branchIcon:getContentSize().height/2)
                if sysBranch.type ~= IntanceConst.STAGE_BRANCH_TYPE.REWARD_HERO then 
                    amin1:setScale(3.0)
                end
                amin1:setName(effectName)
                branchIcon:addChild(amin1,99)
                amin1:setCascadeOpacityEnabled(true, true)
                amin1:setOpacity(0)
                amin1:runAction(cc.FadeIn:create(1))
                if sysBranch.type == IntanceConst.STAGE_BRANCH_TYPE.REWARD_ITEM or
                   sysBranch.type == IntanceConst.STAGE_BRANCH_TYPE.REWARD_HERO or
                   sysBranch.type == IntanceConst.STAGE_BRANCH_TYPE.TIP then 
                    local amin1 = branchIcon:getChildByName("guang")
                    if amin1 == nil then 
                        amin1 = mcMgr:createViewMC("zhixianwuopintishi_brancheffect", true)
                        if sysBranch.type == IntanceConst.STAGE_BRANCH_TYPE.TIP then 
                            amin1:setPosition(branchIcon:getContentSize().width/2 + 30, branchIcon:getContentSize().height/2 - 100)
                            amin1:setScale(3.0)
                        elseif sysBranch.type == IntanceConst.STAGE_BRANCH_TYPE.REWARD_HERO then
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

function IntanceSectionNode:showBranchTalk(inSysBranch, inBuildingIcon, inBranchDialogue, inPt)
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
        inBuildingIcon:getParent():addChild(talkBg, 8)
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
            if inSysBranch.type ~= IntanceConst.STAGE_BRANCH_TYPE.TALK then
                self:showBranchTalk(inSysBranch, inBuildingIcon, inBranchDialogue, inPt) 
            end
            end)
        ))
end



function IntanceSectionNode:showBranchDieTalk(inSysBranch, inBuildingIcon, inBranchDialogue, inPt, callback, inAnim)
    inBuildingIcon.talkIndex =  1
    local talkContent = inBranchDialogue.words[inBuildingIcon.talkIndex]
    local labTalk = nil
    local talkBg = nil
    if inBuildingIcon.talk == nil then 
        talkBg = cc.Sprite:createWithSpriteFrameName("globalImageUI5_sayBg.png")
        talkBg:setPosition(inPt.x, inPt.y)
        talkBg:setAnchorPoint(0, 0)
        inBuildingIcon:getParent():addChild(talkBg, 8)
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
function IntanceSectionNode:updateBranchTalk(inSysBranch, inBuildingIcon)
    if inSysBranch.words ~= nil and self._branchIcon[inSysBranch.id] then 
        local sysBranchDialogue = tab:BranchDialogue(inSysBranch.words)
        inBuildingIcon.talkIndex = 0
        inBuildingIcon.nextTalk = function()
            print("inBuildingIcon.nextTalk============================")
            self:showBranchTalk(inSysBranch, inBuildingIcon, sysBranchDialogue, cc.p(inSysBranch.wordsPosi[1], inSysBranch.wordsPosi[2]))
        end
        if inSysBranch.type ~= IntanceConst.STAGE_BRANCH_TYPE.TALK then 
            inBuildingIcon:runAction(cc.Sequence:create(
                cc.DelayTime:create(sysBranchDialogue.time), 
                cc.CallFunc:create(function() 
                    self:showBranchTalk(inSysBranch, inBuildingIcon, sysBranchDialogue, cc.p(inSysBranch.wordsPosi[1], inSysBranch.wordsPosi[2]))
                    end)
                ))
        end
    end
end



--[[
--! @function touchIcon
--! @desc 点击事件
--！@param x x坐标
--！@param y y坐标
--! @return 
--]]
function IntanceSectionNode:touchIcon(x, y)
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

function IntanceSectionNode:touchBuildingIcon(x, y)
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

function IntanceSectionNode:touchEventIcon(v, k)
    local stageId = self._sysSection.includeStage[k]
    if self._curStageId > stageId or 
    (self._heroStandByStageId == stageId and 
        self._curStageId == stageId) then 
        self:loadBigIcon(v,k)
        return true
    elseif self._heroStandByStageId ~= stageId and 
        self._curStageId == stageId then
        -- self._locckClick = true 

        self._intanceMcAnimNode:runByName("run")
        if self._lockCallBack ~= nil then 
            self._lockCallBack(true)
        end
        self:setHeroRunningCallback(function()
           if self._lockCallBack ~= nil then 
                self._lockCallBack(false)
            end
        end)
        self:heroRunningAmin(1)
        return true
    end
    return false
end

function IntanceSectionNode:touchBranchIcon(x, y)
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

function IntanceSectionNode:touchBranchEventIcon(v, k)
    print("touchBranchEventIcon======================================")
    if k == IntanceConst.SPECIAL_BRANCH_1_ID or k == IntanceConst.SPECIAL_BRANCH_2_ID then 
        if k == IntanceConst.SPECIAL_BRANCH_1_ID then
            SystemUtils.saveGlobalLocalData(GameStatic.deviceGuideKey_Index, 2)
            DialogUtils.showTeam({teamId = 106,notShowCard=true,callback = function() 
                ApiUtils.playcrab_device_monitor_action("qishi")
                self:removeBranchIcon(k, true, false)
                self._intanceModel:updateMainsData({spBranch = {[IntanceConst.SPECIAL_BRANCH_1_ID .. ""] = 1}})
                self._parentView:updateTaskState(true)
            end})
        end
        if k == IntanceConst.SPECIAL_BRANCH_2_ID then
            SystemUtils.saveGlobalLocalData(GameStatic.deviceGuideKey_Index, 3)
            DialogUtils.showTeam({teamId = 102,notShowCard=true,callback = function() 
                ApiUtils.playcrab_device_monitor_action("nushou")
                self:removeBranchIcon(k, true, false)
                self._intanceModel:updateMainsData({spBranch = {[IntanceConst.SPECIAL_BRANCH_2_ID .. ""] = 1}})
                self._parentView:updateTaskState(true)
            end})       
        end
        return
    end
    if v.stageId ~= nil then
        local stageInfo = self._intanceModel:getStageInfo(v.stageId)
        if stageInfo.star == 0 then
            local sysStage = tab:MainStage(v.stageId)
            local title = lang(sysStage.title) 
            local desc = lang("STAGE_TIPS_1")
            local result, count = string.gsub(desc, "$t", title)
            if count > 0  then 
                desc = result
            end
            self._viewMgr:showTip(desc)
            return false
        end
    end
    local sysBranchStage = tab:BranchStage(k)

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
            local otherStageInfo = self._intanceModel:getStageInfo(v[1])
            if otherStageInfo.branchInfo[tostring(v[2])] == nil then 
                needPreBranch = true
            end
        end        
    end 
    -- 特殊处理，此类型的点击后只切换对话
    if sysBranchStage.type == IntanceConst.STAGE_BRANCH_TYPE.TALK then 
        local otherStageInfo = self._intanceModel:getStageInfo(sysBranchStage.subType[2])
        if otherStageInfo.branchInfo[tostring(sysBranchStage.subType[3])] ~= nil then
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
    if needPreBranch == true then 
        self._viewMgr:showTip(lang(sysBranchStage.tips))
        return
    end
    if sysBranchStage.type == IntanceConst.STAGE_BRANCH_TYPE.TIP then
        audioMgr:playSound("temple")
    elseif sysBranchStage.type == IntanceConst.STAGE_BRANCH_TYPE.REWARD_ITEM then
        audioMgr:playSound("pickup")
    elseif sysBranchStage.type == IntanceConst.STAGE_BRANCH_TYPE.WAR or 
        sysBranchStage.type == IntanceConst.STAGE_BRANCH_TYPE.REWARD_TEAM then
        audioMgr:playSound("rogue")
    end
    -- 关卡支线
    if v.stageId ~= nil then
        print('sysBranchStage.type=====', sysBranchStage.type)
        if sysBranchStage.type == IntanceConst.STAGE_BRANCH_TYPE.HERO_ATTR then
            self._viewMgr:showDialog("intance.IntanceHeroAttrBranchView", {
                stageId = v.stageId, 
                branchId = k,
                callback = function(inBranchId, inType)
                    self:atkBeforeMainBranch(v.stageId, inBranchId)
                end})
        elseif sysBranchStage.type == IntanceConst.STAGE_BRANCH_TYPE.CHOOSE_REWARD then
            self._viewMgr:showDialog("intance.IntanceChooseBranchView", {branchId = k,
            callback = function(inBranchId, inType, inChoose)
                self:getMainBranchReward(v.stageId, inBranchId, inChoose)
            end})
        elseif sysBranchStage.type == IntanceConst.STAGE_BRANCH_TYPE.MARKET then
            self._viewMgr:showDialog("intance.IntanceBranchMarketView", {
                branchId = k,
                stageId = v.stageId, 
            callback = function(inBranchId, inType, inChoose)
                self:getMainBranchReward(v.stageId, inBranchId, inChoose)
            end})
        else
            self._viewMgr:showDialog("intance.IntanceBranchView", {branchId = k,
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
        if sysBranchStage.type == IntanceConst.STAGE_BRANCH_TYPE.REWARD_TEAM then
            self._viewMgr:showDialog("intance.IntanceBranchView", {branchId = k,
                callback = function(inBranchId, inType, inChoose)
                    self:getSectionBranchReward(v.sectionId, inBranchId, inChoose)
                end})
        end
    end

    return true
end

function IntanceSectionNode:handleBranchReward(inBranchId, result)
    local sysBranchStage = tab:BranchStage(inBranchId)
    dump(result, "test", 10)
    if sysBranchStage.type == IntanceConst.STAGE_BRANCH_TYPE.REWARD_TEAM then
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
    elseif sysBranchStage.type == IntanceConst.STAGE_BRANCH_TYPE.REWARD_ITEM or 
        sysBranchStage.type == IntanceConst.STAGE_BRANCH_TYPE.REWARD_ITEM_TEAM or 
        sysBranchStage.type == IntanceConst.STAGE_BRANCH_TYPE.COST_TEAM or 
        sysBranchStage.type == IntanceConst.STAGE_BRANCH_TYPE.COST_ITEM_CHIP or 
        sysBranchStage.type == IntanceConst.STAGE_BRANCH_TYPE.CHOOSE_REWARD then
        DialogUtils.showGiftGet({
          gifts = result["reward"],
        })
        -- if sysBranchStage.type == IntanceConst.STAGE_BRANCH_TYPE.REWARD_ITEM then
        --     audioMgr:playSound("pickup")
        -- end
    elseif sysBranchStage.type == IntanceConst.STAGE_BRANCH_TYPE.REWARD_HERO then
        -- self._viewMgr:showTip("恭喜您，解锁英雄")
        if self._showHero ~= nil  then
            audioMgr:playSound("NewHero")
            self._showHero:runHeroUnlockAction()
            self._showHero = nil
        end
    end
    
    if sysBranchStage.type == IntanceConst.STAGE_BRANCH_TYPE.TIP then
        -- self._viewMgr:showTip(lang("MOFASHENDIAN_LOSE_TIPS"))
        local bgLayer = ccui.Layout:create()
        bgLayer:setBackGroundColorOpacity(200)
        bgLayer:setBackGroundColorType(1)
        bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
        bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
        self._parentView:getParent():addChild(bgLayer, 100)
        -- bgLayer:setTouchEnabled(true)
        
        local tmpWidget = ccui.Layout:create()
        tmpWidget:setBackGroundColorOpacity(0)
        tmpWidget:setBackGroundColorType(1)
        tmpWidget:setBackGroundColor(cc.c3b(0, 0, 0))
        tmpWidget:setContentSize(MAX_SCREEN_WIDTH, 469)
        tmpWidget:setPosition(MAX_SCREEN_WIDTH/2, MAX_SCREEN_HEIGHT/2)
        tmpWidget:setAnchorPoint(0.5, 0.5)
        tmpWidget:setClippingEnabled(true)
        bgLayer:addChild(tmpWidget)
        local templeAnim = mcMgr:createViewMC("mofashendian_intance_shendianandshijiu", false, true, function(_, sender)
            bgLayer:removeFromParent(true)
            end)
        templeAnim:setPosition(cc.p(IntanceConst.MAX_SCREEN_WIDTH/2, tmpWidget:getContentSize().height/2))   
        -- registerClickEvent(bgLayer, function()
        --     templeAnim:stop()
        --     bgLayer:removeFromParent(true)
        -- end)
        tmpWidget:addChild(templeAnim)

        local branchIcon = self._branchIcon[inBranchId]
        if branchIcon ~= nil then 
            branchIcon:setCascadeOpacityEnabled(true)
            branchIcon:setOpacity(255)
            branchIcon:runAction(
                cc.Sequence:create(
                    cc.FadeOut:create(0.5), 
                    cc.CallFunc:create(function() 
                                self:removeBranchIcon(inBranchId, true, true)
                                -- self._viewMgr:unlock()
                            end
                        )))
        end
    elseif sysBranchStage.type == IntanceConst.STAGE_BRANCH_TYPE.TALK then
        if result["reward"] ~= nil then        
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
    self._parentView:updateSectionInfoBtnState()
end


--[[
--! @function getSectionBranchReward
--! @desc章节奖励支线
--! @param inSectionId  关卡id
--! @param inBranchId  支线id
--]]
function IntanceSectionNode:getSectionBranchReward(inSectionId, inBranchId)
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
--! @param inChoose  选择奖励
--]]
function IntanceSectionNode:getMainBranchReward(inStageId, inBranchId, inChoose)
    local param = {mid = inStageId, bid = inBranchId, ext = inChoose}
    self._serverMgr:sendMsg("StageServer", "getMainBranchReward", param, true, {}, function (result)
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
function IntanceSectionNode:atkBeforeMainBranch(inStageId, inBranchId)
    self._battaleStageId = inStageId
    self._battaleBranchId = inBranchId

    local sysBranchStage = tab:BranchStage(inBranchId)

    local sysBranchMonsterStage = tab:BranchMonsterStage(tonumber(inBranchId))
    local enemyFormation = IntanceUtils:initFormationData(sysBranchMonsterStage)

    local formationModel = self._modelMgr:getModel("FormationModel")

    local acSectionId = self._intanceModel:getData().mainsData.acSectionId 

    local sysSectionMap = tab:MainSectionMap(self._sysSection.id)

    local sysStageMap = tab:MainStageMap(inStageId)

    BulletScreensUtils.clear()
    self._viewMgr:showView("formation.NewFormationView", {
        formationType = formationModel.kFormationTypeCommon,
        enemyFormationData = {[formationModel.kFormationTypeCommon] = enemyFormation},
        heroes = heroes,
        extend = {
            hideWeapon = true
        },
        callback = 
            function(inLeftData)
               self:formationCallBack(inLeftData)
            end,
        closeCallback = 
            function()
                self:handleParentIntanceBullet()
            end}
        )       
end

function IntanceSectionNode:handleParentIntanceBullet()
    print("handleParentIntanceBullet==============================")
    self._intanceModel:noticeView("showIntanceBullet")
end

--[[
--! @function formationCallBack
--! @desc 布阵callback
--! @param inLeftData table 左侧阵容
--]]
function IntanceSectionNode:formationCallBack(inLeftData)
    local oldFight = TeamUtils:updateFightNum()
    self._formationData = inLeftData
    local cacheBranchInfo  = clone(self._intanceModel:getStageInfo(self._battaleStageId).branchInfo)
    local param = {mid = self._battaleStageId, bid = self._battaleBranchId, serverInfoEx = BattleUtils.getBeforeSIE()}
    self._serverMgr:sendMsg("StageServer", "atkBeforeMainBranch", param, true, {}, function (result)
        self._battleToken = result["token"]
        self._viewMgr:popView()
        if self._lockCallBack ~= nil then 
            self._lockCallBack(true)
        end
        BattleUtils.enterBattleView_FubenBranch(BattleUtils.jsonData2lua_battleData(result["atk"]), tonumber(self._battaleBranchId), false, function (info,callBack)
            self:battleCallBack(info,callBack)
        end,
        function (info)
            if self._battleWin == 1 then
                local sysBranchStage = tab:BranchStage(self._battaleBranchId)
                if sysBranchStage.type == IntanceConst.STAGE_BRANCH_TYPE.HERO_ATTR then
                    local branchInfo  = self._intanceModel:getStageInfo(self._battaleStageId).branchInfo
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
                self:handleParentIntanceBullet()
            end
            if self._lockCallBack ~= nil then 
                self._lockCallBack(false)
            end
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
function IntanceSectionNode:battleCallBack(inResult,inCallBack)
    if inResult == nil then 
        if self._lockCallBack ~= nil then 
            self._lockCallBack(false)
        end
        return 
    end
    -- 配合战斗做的性能优化，支线战斗结束后重新加载地图
    -- self:setTexture(self:getBgName())
    self:setBgTexture()
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
    local param = {mid = self._battaleStageId, bid = self._battaleBranchId,
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
    self._serverMgr:sendMsg("StageServer", "atkAfterMainBranch", param, true, {}, function (result)
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
        local sysBranch = tab:BranchStage(self._battaleBranchId)
        if sysBranch.type ~= IntanceConst.STAGE_BRANCH_TYPE.HERO_ATTR then 
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
        self._parentView:updateSectionInfoBtnState()
    end, function (error)
        if error then
            self._battleWin = 0
            if inCallBack ~= nil then
                inCallBack({failed = true, __code = 8, __error = error})
            end
        end
    end)
end

function IntanceSectionNode:removeBranchIcon(inBranchId, inTalk, inAnim)
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
    local sysBranch = tab:BranchStage(inBranchId)


    if sysBranch.lastWords and inTalk then
        if branchIcon.talk ~= nil then 
            branchIcon.talk:stopAllActions()
            branchIcon.talk:setScale(0)
        end
        local sysBranchDialogue = tab:BranchDialogue(sysBranch.lastWords)
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



function IntanceSectionNode:getNextBuildOffset(inStageId)
    local mainsData = self._intanceModel:getData().mainsData
    local stageView = self:getStageBuildingById(inStageId)
    local nextView = self:getStageBuildingById(mainsData.curStageId)
    if nextView ~= nil then 
        local x = (nextView:getPositionX() - stageView:getPositionX()) /2
        local y = (nextView:getPositionY() + nextView:getContentSize().height/2 - (stageView:getPositionY() + stageView:getContentSize().height/2)) /2
        return cc.p(x, y)
    else
        local sysMainStageMap = tab:MainStageMap(inStageId)
        if sysMainStageMap ~= nil and sysMainStageMap.point ~= nil then 
            local point = sysMainStageMap.point[#sysMainStageMap.point]
            local x = (point[1] - stageView:getPositionX()) /2
            local y = (point[2] + 100 - (stageView:getPositionY() + stageView:getContentSize().height/2)) /2
            return cc.p(x, y)
        end
    end
    return cc.p(0, 0)
end


--[[
--! @function getNextUndoneBuild
--! @desc 获取未满星通过关卡建筑
--! @return object
--]]
function IntanceSectionNode:getNextUndoneBuild()
    local tempUndoneStageId = 0
    for k,v in pairs(self._sysSection.includeStage) do
        if v > self._curStageId then 
            break
        end
        local stageInfo = self._intanceModel:getStageInfo(v)
        if stageInfo.star < 3 then
            
            if tempUndoneStageId == 0 then
                tempUndoneStageId = v
                if self._undoneStageId == 0 then 
                    break
                end
            end
            if v > self._undoneStageId then 
                tempUndoneStageId = v
                break
            end
        end

    end
    if tempUndoneStageId == 0 then 
        self._undoneStageId = 0
        return nil
    end
    self._undoneStageId = tempUndoneStageId
    return self:getStageBuildingById(self._undoneStageId)
end

function IntanceSectionNode:setBgTexture(isRelease)
    if isRelease == true then 
        self._bg:setTexture(UIUtils.noPic)
        return
    end
    local sysMainSectionMap = tab:MainSectionMap(self._sysSection.id)
    self._bg:setTexture("asset/uiother/map/" .. sysMainSectionMap.img)

    self:setContentSize(sysMainSectionMap.mapWidth, self._bg:getContentSize().height)
    self:setPosition(sysMainSectionMap.x - (self._bg:getContentSize().width - sysMainSectionMap.mapWidth) * 0.5, sysMainSectionMap.y)
    self._cacheSize = self:getContentSize()
    self._cacheName = "asset/uiother/map/" .. sysMainSectionMap.img
    self._bg:setPosition(0, 0)
    self._bg:setAnchorPoint(0, 0)
end

function IntanceSectionNode:getCacheContentSize()
    return self._cacheSize
end

function IntanceSectionNode:getBgName()
    return self._cacheName
end

function IntanceSectionNode:setShowCallback(inCallback)
    self._showCallBack = inCallback
end

function IntanceSectionNode:setParentView(inParentView)
    self._parentView = inParentView
end

function IntanceSectionNode:setMoveCallback(inCallback)
    self._moveCallBack = inCallback
end

function IntanceSectionNode:setLockCallback(inCallback)
    self._lockCallBack = inCallback
end

function IntanceSectionNode:setCompleteCallback(inCallback)
    self._completeCallBack = inCallback
end

function IntanceSectionNode:setHeroRunningCallback(inCallback)
    self._heroRunningCallback = inCallback
end
return IntanceSectionNode