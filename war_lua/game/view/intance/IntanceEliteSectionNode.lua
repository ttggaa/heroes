--[[
    Filename:    IntanceEliteSectionNode.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-11-03 15:04:50
    Description: File description
--]]

local IntanceEliteSectionNode = class("IntanceEliteSectionNode", BaseMvcs, function ()
        return  cc.Sprite:create() 
    end)


function IntanceEliteSectionNode:ctor()
    IntanceEliteSectionNode.super.ctor(self)
    self._usingIcon = {}
    self._freeingIcon = {}
    self._branchIcon = {}

    self._bgSprite = cc.Sprite:create()
    self._bgSprite:setAnchorPoint(0.5, 0.5)
    self:addChild(self._bgSprite)

    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            ScheduleMgr:cleanMyselfDelayCall(self)
        elseif eventType == "enter" then 
        end
    end)

end

local starPoint = {{27, 17},{58.5, 17},{91, 17}}
function IntanceEliteSectionNode:reflashUI(inData)
    ScheduleMgr:cleanMyselfDelayCall(self)
    self._curSectionId = inData.sectionId
    self._quickStageId = inData.quickStageId
    self._clickCallBack = inData.callBack
    local sysSection = tab:MainSection(self._curSectionId)
    local buildingIcon 
    while(true) do
        if #self._usingIcon <= 0 then 
            break
        end
        buildingIcon = self._usingIcon[#self._usingIcon]

        -- if buildingIcon.grenPoints ~= nil then 
        --     for k,v in pairs(buildingIcon.grenPoints) do
        --         v:removeFromParent()
        --     end
        --     buildingIcon.grenPoints = nil
        -- end
        -- buildingIcon:setVisible(false)
        buildingIcon:setEnabled(false)
        table.insert(self._freeingIcon,buildingIcon)
        table.remove(self._usingIcon)
    end
    if self._sectionEffect ~= nil then 
        self._sectionEffect:removeFromParent()
        self._sectionEffect = nil
    end
    local branchIcon
    for k,v in pairs(self._branchIcon) do
        local buildingIcon = self._branchIcon[k]
        if buildingIcon ~= nil then 
            buildingIcon:removeFromParent()
        end
    end
    self._branchIcon = {}

    local sysMainSectionMap = tab:MainSectionMap(self._curSectionId)
    -- self:setTexture("asset/uiother/map/" .. sysMainSectionMap.img)
    -- self:setScale(1.11)
    self._bgSprite:setTexture("asset/uiother/map/" .. sysMainSectionMap.img)
    self._bgSprite:setScale(1.11)

    self:setContentSize(cc.size(
            self._bgSprite:getContentSize().width * self._bgSprite:getScale(),
            self._bgSprite:getContentSize().height * self._bgSprite:getScale()))
    self._bgSprite:setPosition(self:getContentSize().width/2, self:getContentSize().height/2)
    -- self:setAnchorPoint(cc.p(0.5, 0.5))
    -- self:setPosition(sysMainSectionMap.x,sysMainSectionMap.y)
    if self._curIcon == nil then
        self._curIcon = mcMgr:createViewMC("dangqiantishi_intanceelitenow", true)
        -- self._curIcon:setPosition(self._curIcon:getContentSize().width/2, self._curIcon:getContentSize().height/2)
        self:addChild(self._curIcon)
    end
    local intanceEliteModel = self._modelMgr:getModel("IntanceEliteModel")
    local mainsData = intanceEliteModel:getData()

    self._curStageId = mainsData.curStageId
    local scrollDataId = sysSection.includeStage[1]
    -- local tempIcon

    for k,v in pairs(sysSection.includeStage) do
        local stageInfo = intanceEliteModel:getStageInfo(v)
        local sysMainStageMap = tab:MainStageMap(v)
        local sysMainStage = tab:MainStage(v)

        if #self._freeingIcon > 0  then 
            buildingIcon = self._freeingIcon[#self._freeingIcon]
            table.remove(self._freeingIcon)
        else
            buildingIcon = ccui.Widget:create()
            self:addChild(buildingIcon, 5)
            local starBg = self:createStarInfo()
            buildingIcon:addChild(starBg)
        end
        buildingIcon:setName("building_icon" .. sysMainStageMap.id)
        table.insert(self._usingIcon,buildingIcon)

        -- 更新信息
        self:updateBuildingIcon(buildingIcon, sysMainStageMap, stageInfo)

        self:updateBuildingStar(stageInfo.star, sysMainStageMap.id, buildingIcon:getChildByName("star_bg"))
        -- 精英副本显示物品头像
        local itemIcon = buildingIcon:getChildByName("item_icon")
        if itemIcon ~= nil then 
            itemIcon:removeFromParent()
        end
        itemIcon = self:createIcon(sysMainStageMap)
        itemIcon:setPosition(buildingIcon:getContentSize().width/2 , buildingIcon:getContentSize().height/2 + 10)
        itemIcon:setName("item_icon")
        -- local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 255))
        -- layer:setPosition(0, 20)
        -- layer:setContentSize(cc.size(buildingIcon:getContentSize().width, buildingIcon:getContentSize().height - 20))
        -- buildingIcon:addChild(layer)
        buildingIcon:addChild(itemIcon, 6)

        self:initStageBranch(stageInfo, sysMainStage, false)
    end

    self:updateBuildingCurIcon()
    self:loadSectionEffect(sysMainSectionMap)
end




function IntanceEliteSectionNode:loadSectionEffect(sysMainStageMap)
    if sysMainStageMap.id > 72010 then 
        return
    end
    ScheduleMgr:delayCall(0, self, function()
        self._sectionEffect = mcMgr:createViewMC("a" ..sysMainStageMap.id .. "_intanceeliteeffect", true)
        self._sectionEffect:setPosition(self:getContentSize().width/2, self:getContentSize().height/2)
        self:addChild(self._sectionEffect, 4)
        self._sectionEffect:setCascadeOpacityEnabled(true, true)
        self._sectionEffect:setOpacity(0)
        self._sectionEffect:runAction(cc.FadeIn:create(1))
        self._sectionEffect:setScale(1.11)
    end)
end


function IntanceEliteSectionNode:createIcon(sysMainStageMap)
    local AwakingModel = self._modelMgr:getModel("AwakingModel")
    local warkingReward = AwakingModel:getAwakingTaskDungeonReward(sysMainStageMap.id)
    local icon
    if warkingReward ~= nil then 
        local sysItem = tab:Tool(warkingReward[2])
        icon = IconUtils:createItemIconById({itemId = warkingReward[2],itemData = sysItem, eventStyle = 0})        
    else
        local sysItem = tab:Tool(sysMainStageMap.toolId)
        icon = IconUtils:createItemIconById({itemId = sysMainStageMap.toolId,itemData = sysItem, eventStyle = 0})        
    end
    icon:setScale(0.70)
    icon:setAnchorPoint(0.5, 0.5)
    return icon
end
--[[
--! @function createStarInfo
--! @desc 创建星星信息层
--! @return 
--]]
function IntanceEliteSectionNode:createStarInfo()

    local starBg = cc.Sprite:createWithSpriteFrameName("intanceImageUI4_eliteStarBg.png")
    -- starBg:setAnchorPoint(cc.p(0.5,0.5))
    starBg:setName("star_bg")

    for i=1,3 do
        -- local star = cc.Sprite:createWithSpriteFrameName("intanceImageUI4_eliteStar1.png")
        -- star:setPosition(starPoint[i][1], starPoint[i][2])
        -- star:setName("star_" .. i )
        -- star:setVisible(false)
        -- starBg:addChild(star, 2)

        local star1 = cc.Sprite:createWithSpriteFrameName("intanceImageUI4_smallEliteStar.png")
        -- star1:setPosition(starPoint[i][1] + 5, starPoint[i][2])
        star1:setPosition(starPoint[i][1], starPoint[i][2])
        star1:setName("star_" .. i  )
        starBg:addChild(star1, 4 - i)
    end

    local selectedState = cc.Sprite:createWithSpriteFrameName("intanceImageUI4_eliteStarBgSelected.png")
    selectedState:setPosition(starBg:getContentSize().width/2, starBg:getContentSize().height/2)
    selectedState:setVisible(false)
    selectedState:setName("selected_state")
    starBg:addChild(selectedState)

    -- local starBox = mcMgr:createViewMC("xingxingkuangdonghua_xingxingintanceanim", false)
    -- starBox:setPosition(starBg:getContentSize().width/2, starBg:getContentSize().height/2)
    -- starBox:gotoAndStop(starBox:getTotalFrames())
    -- starBox:setName("star_box")
    -- starBox:setVisible(false)
    -- starBg:addChild(starBox)

    return starBg
end

function IntanceEliteSectionNode:updateBuildingCurIcon()
    local buildingView = self:getChildByName("building_icon" .. self._curStageId)
    if buildingView == nil then 
        self._curIcon:setVisible(false)
    else
        self._curIcon:setVisible(true)
        self._curIcon:setPosition(buildingView:getPositionX(),buildingView:getPositionY() + 8)
    end


end

--[[
--! @function updateBuildingIcon
--! @desc 更新建筑信息
--! @param  inView 当前建筑
--! @param  sysMainStageMap 系统副本章节坐标等信息
--! @param  stageInfo 用户章节信息
--! @return 
--]]
function IntanceEliteSectionNode:updateBuildingIcon(inView, sysMainStageMap, stageInfo)
    local starBg = inView:getChildByName("star_bg")

    inView:setContentSize(cc.size(starBg:getContentSize().width, starBg:getContentSize().height))
    inView:setPosition(cc.p(sysMainStageMap.x,sysMainStageMap.y))
    inView:setAnchorPoint(cc.p(sysMainStageMap.anchorPointX,sysMainStageMap.anchorPointY))

    starBg:setPosition(inView:getContentSize().width/2,inView:getContentSize().height/2 - 10)


    if inView.grenPoints ~= nil then 
        for k,v in pairs(inView.grenPoints) do
            v:removeFromParent()
        end
    end
    inView.grenPoints = {}
    local intanceEliteModel = self._modelMgr:getModel("IntanceEliteModel")
    local stageInfo = intanceEliteModel:getStageInfo(sysMainStageMap.id)

    if self._curStageId >= sysMainStageMap.id then
        if stageInfo.star > 0 then 
            local tempPoint
            for k,v in pairs(sysMainStageMap.point) do
                 tempPoint = cc.Sprite:createWithSpriteFrameName("intanceImageTps_temp3.png")
                 tempPoint:setPosition(v[1], v[2])
                 tempPoint:setName("temp_point" .. k)
                 self:addChild(tempPoint)
                 table.insert(inView.grenPoints, tempPoint)
            end
        end
        inView:setSaturation(0)
        inView:setEnabled(true)
        registerTouchEvent(inView,
            function() 
                inView:getChildByName("star_bg"):getChildByName("selected_state"):setVisible(true)
            end, nil,
            function ()
                inView:getChildByName("star_bg"):getChildByName("selected_state"):setVisible(false)
                self._clickCallBack(sysMainStageMap.id)
            end,
            function ()
                inView:getChildByName("star_bg"):getChildByName("selected_state"):setVisible(false)
            end)
        if self._quickStageId ~= nil and self._quickStageId == sysMainStageMap.id then 
            self._clickCallBack(sysMainStageMap.id)
            self._quickStageId = nil
        end
        self:udpateLastNum(sysMainStageMap.id)
        return
    end
    if inView.lastNumLab ~= nil then 
        inView.lastNumLab:getParent():setVisible(false)
    end
    inView:setEnabled(false)
    inView:setSaturation(-100)
end


function IntanceEliteSectionNode:udpateLastNum(inStageId)
    if self._curStageId < inStageId then
        return
    end
    local inView = self:getBuildingObjectById(inStageId)
    local intanceEliteModel = self._modelMgr:getModel("IntanceEliteModel")
    local sysStage = tab:MainStage(inStageId)
    local privileges = self._modelMgr:getModel("PrivilegesModel"):getPeerageEffect(PrivilegeUtils.peerage_ID.JingYingCiShu) or 0
    -- (sysStage.num + privileges) - stage.num
    local stage = intanceEliteModel:getStageInfo(inStageId)

    local activityModel = self._modelMgr:getModel("ActivityModel") 
    -- 活动折扣
    local discount = self._modelMgr:getModel("ActivityModel"):getAbilityEffect(activityModel.PrivilegIDs.PrivilegID_2) or 0


    local lastNum = (sysStage.num + privileges + discount) - stage.num
    if lastNum < 0 then
        lastNum = 0
    end
    if lastNum >= 0 then 
        if inView.lastNumLab == nil then 
            local lastNumBg = cc.Sprite:createWithSpriteFrameName("intanceImageUI_elitePowerBg.png")
            lastNumBg:setPosition(82, 60)
            inView:addChild(lastNumBg, 100)
            inView.lastNumLab = cc.Label:createWithTTF("", UIUtils.ttfName, 20)
            inView.lastNumLab:setPosition(lastNumBg:getContentSize().width/2, lastNumBg:getContentSize().height/2)
            lastNumBg:addChild(inView.lastNumLab)
        end
        inView.lastNumLab:setString(lastNum)
        inView.lastNumLab:getParent():setVisible(true)
    else
        if inView.lastNumLab ~= nil then 
            inView.lastNumLab:getParent():setVisible(false)
        end
    end    
end
--[[
--! @function getBuildingObjectById
--! @desc 根据章节id获得副本章节的view
--! @param  inStageId 完成章节id
--! @return 
--]]
function IntanceEliteSectionNode:getBuildingObjectById(inStageId)
    local stageView = self:getChildByName("building_icon" .. inStageId)
    return stageView
end


--[[
--! @function updateBuildingStar
--! @desc 更新建筑星星信息
--! @param  inStar 当前建筑星级
--! @param  inStageId 副本章节ID
--! @param  starBg 星星背景层
--! @param  clickIcon 可点击层展示大图
--! @return 
--]]
function IntanceEliteSectionNode:updateBuildingStar(inStar, inStageId, starBg)
    -- if self._curStageId >= inStageId then
    -- local starPoint = {
    --     {{30.5, 10},{57.5, 10},{84.5, 10}}
    -- }
    for i=1,3 do
        local star = starBg:getChildByName("star_" .. i)
        if inStar >= i  then 
            star:setVisible(true)
            star:setPosition(starPoint[i][1], starPoint[i][2])
        else
            star:setVisible(false)
        end
        print("inStar===========", inStar)
    end 
    -- end
end




--[[
--! @function completeStage
--! @desc 完成章节并更新建筑相关
--! @param  inStageId 完成章节id
--! @return 
--]]
function IntanceEliteSectionNode:completeStage(inStageId)
    local stageView = self:getChildByName("building_icon" .. inStageId)
    if stageView == nil then 
        return 
    end
    local intanceEliteModel = self._modelMgr:getModel("IntanceEliteModel")
    local mainsData = intanceEliteModel:getData()
    self._curStageId = mainsData.curStageId

    -- local stageIndex = tonumber(string.sub(inStageId, 4 , 5))


    local stageInfo = intanceEliteModel:getStageInfo(inStageId)
    local sysMainStageMap = tab:MainStageMap(inStageId)

    local haveStarNum = 0
    local starBg = stageView:getChildByName("star_bg")
    if starBg ~= nil then
        for i=1,3 do
            if starBg:getChildByName("star_" .. i):isVisible() then 
                haveStarNum = i
            end
        end
    end

    self:updateBuildingIcon(stageView, sysMainStageMap, stageInfo)
    if self._curStageId ~= inStageId and haveStarNum < 3 then 
        -- local starPoint = {{24, 127}, {52, 138}, {80, 127}}
        for i = haveStarNum + 1, stageInfo.star do
            local tmpStar = mcMgr:createViewMC("xingxingdonghua_intanceelitestar", false, true,
            function (_, sender)
                local star = starBg:getChildByName("star_" .. i)
                star:setVisible(true)
                -- star:gotoAndPlay(1)          
            end)
            tmpStar:setPosition(starPoint[i][1] - 2, starPoint[i][2] + 2)
            tmpStar:setName("tmp_star")
            starBg:addChild(tmpStar)
            tmpStar:stop()

            tmpStar:setVisible(false)
            tmpStar:runAction(cc.Sequence:create(cc.DelayTime:create((i - haveStarNum + 1) * 0.23), 
                cc.CallFunc:create(function ()
                    tmpStar:gotoAndPlay(1)
                    tmpStar:setVisible(true)

                end)))
        end
    else
        self:updateBuildingStar(stageInfo.star, sysMainStageMap.id, starBg)
    end
    if self._curStageId ~= inStageId then
        starBg:runAction(cc.Sequence:create(cc.DelayTime:create((stageInfo.star - haveStarNum + 1) * 0.28), 
            cc.CallFunc:create(function ()
                if haveStarNum == 0 and stageInfo.star > 0 and inStageId == IntanceConst.STAR_OPEN_PASS then
                        local sysSection = tab:MainSection(self._curSectionId)
                        for k,v in pairs(sysSection.includeStage) do
                           local stageInfo = intanceEliteModel:getStageInfo(v)
                           local sysMainStage = tab:MainStage(v)
                           self:initStageBranch(stageInfo, sysMainStage, true)
                        end
                end               
                self:updateBuildingCurIcon()
                self:completeStage(self._curStageId)    
            end)))
    end
-- self:updateBuildingStar(stageInfo.star, sysMainStageMap.id, buildingIcon:getChildByName("star_bg"))
    -- self:updateBuildingCurIcon()
    -- if self._curStageId ~= inStageId then 
    --     self:completeStage(self._curStageId)
    -- end
end



--[[
--! @function initStageBranch
--! @desc 初始化关卡支线信息
--! @param  inStageInfo 章节信息
--! @param  inSysMainStage 章节地图信息
--! @return 
--]]
function IntanceEliteSectionNode:initStageBranch(inStageInfo, inSysMainStage, isNewOpen)
    if inSysMainStage.branchId == nil then 
      return 
    end

    if self._curStageId <= IntanceConst.STAR_OPEN_PASS then
        return
    end

    for k,v in pairs(inSysMainStage.branchId) do
      local sysBranch = tab:BranchStage(v)
      local branchIcon
      if inStageInfo.branchInfo[tostring(v)] == nil then 
        local buildingIcon = ccui.Widget:create()
        if sysBranch.type == IntanceConst.STAGE_BRANCH_TYPE.STAR then
            buildingIcon:setContentSize(cc.size(74, 115))
            if isNewOpen then 
                branchIcon = mcMgr:createViewMC("borm_fubenlingqunxingxing", false, true, function()
                    buildingIcon.mc = nil
                    buildingIcon:removeAllChildren()
                    branchIcon = mcMgr:createViewMC("stop_fubenlingqunxingxing", true)       
                    branchIcon.stageId = inSysMainStage.id
                    branchIcon:setPosition(buildingIcon:getContentSize().width/2, 0)
                    buildingIcon:addChild(branchIcon)
                    buildingIcon.mc = branchIcon
                end)     
                buildingIcon.mc = branchIcon
            else
                branchIcon = mcMgr:createViewMC("stop_fubenlingqunxingxing", true)        
                buildingIcon.mc = branchIcon
            end
        end
        if branchIcon ~= nil then
            branchIcon:setName("branch_icon_" ..  v)
            branchIcon.stageId = inSysMainStage.id
            branchIcon:setPosition(buildingIcon:getContentSize().width/2, 0)
            buildingIcon:setPosition(sysBranch.position[1], sysBranch.position[2] +buildingIcon:getContentSize().height/2 + 5)
            buildingIcon:addChild(branchIcon)
            self._branchIcon[v] = buildingIcon

            self:addChild(buildingIcon, 6)
            registerTouchEvent(buildingIcon,nil, nil,function ()
                if inStageInfo.star <= 0 then 
                    local sectionIndex = tonumber(string.sub(inSysMainStage.id, 3 , 5))
                    local stageIndex = tonumber(string.sub(inSysMainStage.id, 6 , 7))
                    self._viewMgr:showTip("通关" .. sectionIndex .. "-" .. stageIndex .. "关可以领取")
                    return
                end
                local sysBranchStage = tab:BranchStage(v)

                self._viewMgr:showDialog("intance.IntanceBranchView",
                {
                branchId = v,
                callback = function(inBranchId, inType)
                    self:getMainBranchReward(inSysMainStage.id, inBranchId)
                end})
            end,
            nil)
        end
      end
    end
end

--[[
--! @function getMainBranchReward
--! @desc 支线服务端返回数据处理
--! @param  inStageId 副本id
--! @param  inBranchId 支线id
--! @return 
--]]
function IntanceEliteSectionNode:getMainBranchReward(inStageId, inBranchId)
    local param = {mid = inStageId, bid = inBranchId}
    self._serverMgr:sendMsg("StageServer", "getEliteBranchReward", param, true, {}, function (result)
        if result == nil or result["d"] == nil then 
            return 
        end
        local sysBranchStage = tab:BranchStage(inBranchId)
        if sysBranchStage.type == IntanceConst.STAGE_BRANCH_TYPE.STAR then
            dump(result["reward"])
            DialogUtils.showGiftGet({
              gifts = result["reward"],
              callback = function()
                self:removeBranchIcon(inBranchId)
              end
            })
        end
    end)  
end

--[[
--! @function removeBranchIcon
--! @desc 根据支线Id移除界面图标
--! @param  inBranchId 支线id
--! @return 
--]]
function IntanceEliteSectionNode:removeBranchIcon(inBranchId)
    local buildingIcon = self._branchIcon[inBranchId]
    if buildingIcon.mc == nil and buildingIcon.removeFromParent ~= nil then 
        buildingIcon:removeFromParent()
    else
        if buildingIcon.mc ~= nil then 
            buildingIcon:removeAllChildren()
            local branchIcon = mcMgr:createViewMC("die_fubenlingqunxingxing", false, true, function()
                buildingIcon:removeFromParent()
            end)
            branchIcon:setPosition(buildingIcon:getContentSize().width/2, 0)
            buildingIcon:addChild(branchIcon)
            buildingIcon:setTouchEnabled(false)  
        end
    end
    self._branchIcon[inBranchId] = nil
end

function IntanceEliteSectionNode:setParentView(inParentView)
    self._parentView = inParentView
end

function IntanceEliteSectionNode.dtor()
    starPoint = nil
end

return IntanceEliteSectionNode