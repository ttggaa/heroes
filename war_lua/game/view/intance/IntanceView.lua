--[[
    Filename:    IntanceView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-08-17 10:17:00
    Description: File description
--]]
local cc = cc
local IntanceView = class("IntanceView", BaseView, require("game.view.intance.IntanceBaseView"))


function IntanceView:ctor(inData)
    IntanceView.super.ctor(self)
    self._intanceModel = self._modelMgr:getModel("IntanceModel")
    self.noSound = true
    IntanceConst.WIDE_REWARD_ITEM_ID = nil
    IntanceConst.WIDE_REWARD_NEED_ITEM_NUM = nil
    IntanceConst.QUICK_ENTER_BY_WORLD = false

    local stepCacheSectionId = false
    -- 第三方跳转副本所需参数
    if inData ~= nil then
        self.__isReleaseAllOnShow = inData.isReleaseAllOnShow
        if inData.sectionId ~= nil then 
            self._curSectionId  = inData.sectionId
            self._quickCurSectionId = inData.sectionId   
        end
        if inData.quickStageId ~= nil then 
            self._quickStageId  = inData.quickStageId
            -- IntanceConst.GO_STAR_POINT = 0
            SystemUtils.saveAccountLocalData("GO_STAR_POINT", 0)
        end        

        if inData.itemId ~= nil and inData.needItemNum ~= nil then 
            IntanceConst.WIDE_REWARD_ITEM_ID = inData.itemId

            IntanceConst.WIDE_REWARD_NEED_ITEM_NUM = inData.needItemNum
        end
        -- 活动跳转
        if inData.superiorType ~= nil then 
            self._curSectionId = nil
            stepCacheSectionId = true
        end
    end

    -- 避免修改数据库时重复激活章节
    local acSectionId = self._intanceModel:getData().mainsData.acSectionId 
    local goStarPoint = SystemUtils.loadAccountLocalData("GO_STAR_POINT")
    if goStarPoint ~= nil and goStarPoint > acSectionId then
        SystemUtils.saveAccountLocalData("GO_STAR_POINT", 0)
    end

    self:setListenReflashWithParam(true)
    self:listenReflash("IntanceModel", self.listenModel) 

    self:listenReflash("UserModel", self.listenUserModel) 
    self:listenReflash("DailySiegeModel", self.listenDailySiegeMode) 
    -- 如果并没有跳转则获取本地存储
    -- if self._curSectionId == nil then 
    --     local tempSectionId = SystemUtils.loadAccountLocalData(IntanceConst.USE_SELECT_SECTION)
    --     if tempSectionId ~= nil then
    --         local acSectionId = self._intanceModel:getData().mainsData.acSectionId 
    --         if tonumber(acSectionId) >= tonumber(tempSectionId) and 
    --             stepCacheSectionId == false
    --             and tonumber(tempSectionId) ~= IntanceConst.FIRST_SECTION_ID then 
    --             self._curSectionId = tonumber(tempSectionId)
    --         end
    --     end
    -- end
end

function IntanceView:isAsyncRes()
    return false
end

function IntanceView:getAsyncRes()
    local intanceData = self._intanceModel:getData()
    local curStageId = 0
    if intanceData.mainsData ~= nil and intanceData.mainsData.curStageId ~= nil  then 
        curStageId = intanceData.mainsData.curStageId
    end
    if curStageId <= IntanceConst.FIRST_SECTION_LAST_STAGE_ID or self._quickStageId ~= nil then 
        return {            
                {"asset/ui/intance.plist", "asset/ui/intance.png"},
                {"asset/ui/intance2.plist", "asset/ui/intance2.png"},
                {"asset/ui/intance-HD.plist", "asset/ui/intance-HD.png"},
                }
    else
        -- 注意还有其他地方引用，在其他地方也需要添加
        return {
                {"asset/ui/intance.plist", "asset/ui/intance.png"},
                {"asset/ui/intance2.plist", "asset/ui/intance2.png"},
                {"asset/ui/intanceWorld.plist", "asset/ui/intanceWorld.png"},
                {"asset/ui/intanceWorld2.plist", "asset/ui/intanceWorld2.png"},
                {"asset/ui/intanceLightWord.plist", "asset/ui/intanceLightWord.png"},
                {"asset/ui/intance-HD.plist", "asset/ui/intance-HD.png"},
                }
    end
end

-- 第一次被加到父节点时候调用
function IntanceView:onBeforeAdd(callback, errorCallback)
    if self._quickStageId ~= nil then callback() return end 
    self._serverMgr:sendMsg("ExtraServer", "getSiegeInfo", {}, true, {}, function (result, error)
        if callback then
            callback()
        end
    end)
end

function IntanceView:enterBattle()
    if self._mapLayer ~= nil then
        self._mapLayer:enterBattle()
    end
end

function IntanceView:onDestroy()
    BulletScreensUtils.clear()
    audioMgr:playMusic("mainmenu", true)
    self:clearLock()
    
    ScheduleMgr:cleanMyselfDelayCall(self)
    IntanceView.super.onDestroy(self)
end

function IntanceView:onHide()
    if self._worldLayer ~= nil then 
        self._worldLayer:onHide()
    end
    BulletScreensUtils.clear()
end

function IntanceView:onTop()
    print("IntanceView:onTop===========================================")
    if self._mapLayer ~= nil then   --by wangyan 强制刷新英雄模型动画
        self._mapLayer:refreshSectionHero()
    end

    audioMgr:playMusic("campaign", true)
    -- 为2-2之前的章节特殊处理
    if IntanceConst.QUICK_ENTER_BY_WORLD == false and self._quickStageId == nil then 
        local acSectionId = self._intanceModel:getData().mainsData.acSectionId
        local curStageId = self._intanceModel:getData().mainsData.curStageId
        if (self._curSectionId > IntanceConst.FIRST_SECTION_ID or 
            acSectionId > IntanceConst.FIRST_SECTION_ID) and 
            curStageId > IntanceConst.GUILDE_SWITCH_WORLD_STAGE_ID then
            IntanceConst.QUICK_ENTER_BY_WORLD = true
        end
    end
    if self._mapLayer ~= nil then
        self._mapLayer:exitBattle()
    end
    if self._worldLayer ~= nil then 
        self._worldLayer:onTop()
    end

    self._modelMgr:getModel("GuildRedModel"):checkRandRed()
end

--[[
--! @function createMapLayer
--! @desc 创建副本层
--! @param inSectionId 需要展示的章id
--! @return 
--]]
function IntanceView:createMapLayer(inSectionId)
    if inSectionId == nil then inSectionId = self._curSectionId end
    self._mapLayer = require("game.view.intance.IntanceMapLayer").new(self, self:getLayerNode())
    self._mapLayer:setLockCallback(function(inIsLock)
        -- if GameStatic.openDebugLog then 
        --     local traceback = string.split(debug.traceback("", 2), "\n")
        --     local tracde = traceback[5]
        --     if not tracde then 
        --         tracde = traceback[3]
        --     end
        --     if tracde then 
        --         print("setLock " .. tostring(inIsLock) .. " from: " .. string.trim(tracde) .. "Debug关闭则关闭，请忽略") 
        --     end  
        -- end
        self:lockViewBtn(not inIsLock)
    end)
    self:addChild(self._mapLayer, -1)
    self._mapLayer:reflashUI({curSectionId = inSectionId, quickStageId = self._quickStageId})
end


function IntanceView:onInit()
    self._guideIgnoreWorld = 0
    audioMgr:playMusic("campaign", true)
    self._enterIntance = true
    
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("intance.IntanceView")
            UIUtils:reloadLuaFile("intance.IntanceUtils")
            UIUtils:reloadLuaFile("global.GlobalExtendBarNode")
        elseif eventType == "enter" then 
        end
    end)

    local backSectionBtn = self:getUI("Panel_55.backSectionBtn")

    local backText = self:getUI("Panel_55.backText")
    backText:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)

    local preSectionBtn = self:getUI("Panel_55.preSectionBtn")

    local preText = self:getUI("Panel_55.preText")
    preText:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)

    -- self:registerTouchEventWithLight(backSectionBtn)
    -- self:registerTouchEventWithLight(preSectionBtn)

    local sectionName = self:getUI("Image_9.sectionName")
    sectionName:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)

    -- local backSectionBtn = self:getUI("Panel_17.backSectionBtn")
    self:registerClickEvent(backSectionBtn, function ()
        local curSelectedIndex = tonumber(string.sub(self._curSectionId, 3 , 5))
        local curChaptgerId = tonumber(string.sub(self._curSectionId, 1 , 2))
        local sysMainChapter = tab:MainChapter(curChaptgerId)
        if curSelectedIndex == 1 then
            self._viewMgr:showTip("已无章节可选")
        else
            self:backSection()
        end
        -- local param = {}
        -- param.oldLevel = 0
        -- param.branchId = 7100611
        -- param.newLevel = 2
        -- param.oldFight = 2
        -- self._viewMgr:showDialog("cloudcity.CloudCityPassView", {viewType = 2, param = param, callBack = function()
        -- end})
    end)


    -- local preSectionBtn = self:getUI("Panel_17.preSectionBtn")
    self:registerClickEvent(preSectionBtn, function ()
        if tab:Setting("G_FINISH_SECTION_STORY").value == self._curSectionId then
            self._viewMgr:showTip("暂未开启")
        else
            self:preSection(true)
        end
    end)
 
    local closeBtn = self:getUI("closeBtn")
    self:registerClickEvent(closeBtn, function ()
        print("IntanceConst.QUICK_ENTER_BY_WORLD====", IntanceConst.QUICK_ENTER_BY_WORLD)
        if IntanceConst.QUICK_ENTER_BY_WORLD == true and self._guideIgnoreWorld ==  0 then 
            self:switchWorldLayer(false, nil, self._curSectionId)
        else
            self:close()
        end
    end)

    local progPanel = self:getUI("Panel_18.progPanel")
    progPanel:setTouchEnabled(false)

    local undoneStageBtn = self:getUI("Panel_18.progPanel.undoneStageBtn")
    -- self:registerClickEvent(undoneStageBtn, function ()
    --     self._mapLayer:moveToUndoneStage()
    -- end)
    self:registerTouchEventWithLight(undoneStageBtn, function ()
        print("Panel_18.undoneStageBtn")
        self._mapLayer:moveToUndoneStage()
        end)

    local sectionInfoBtn = self:getUI("leftPanel.sectionInfoBtn")
    self:registerClickEvent(sectionInfoBtn, function ()
        -- 斥候密信只有一个地方会有红点，减少检测红点代码，直接用按钮状态提示
        local showBranchTip = 0
        if sectionInfoBtn.tip ~= nil and sectionInfoBtn.tip:isVisible() == true then 
            showBranchTip = 1
        end
        self._viewMgr:showDialog("intance.IntanceSectionInfoView",{
            sectionId = self._curSectionId, 
            showBranchTip = showBranchTip,
            callback = function(inShowStageId, inBranchId)
                self._mapLayer:runMagicEyeAction(inShowStageId, inBranchId)
            end,
            moveCallback = function(inBranchId)
                self._mapLayer:moveToBranchBuilding(inBranchId)
            end,
            updateCallback = function()
                self:updateSectionInfoBtnState()
            end}
        )
    end)

    mcMgr:loadRes("chihoumixin_intanceotherbtn-HD", function()
        if self._enterIntance ~= true then 
            return 
        end
        local amin3 = mcMgr:createViewMC("chihoumixin_intanceotherbtn-HD", true)
        amin3:setPosition(sectionInfoBtn:getContentSize().width/2, sectionInfoBtn:getContentSize().height/2)
        sectionInfoBtn:addChild(amin3)
        amin3:setOpacity(0)
        amin3:setCascadeOpacityEnabled(true, true)
        amin3:runAction(cc.FadeIn:create(1))
    end)

    -- 判断是否激活新章节（用户等级问题）
    self._intanceModel:updateSectionIdAndStageId()

    if self._curSectionId == nil then
        self._curSectionId = self._intanceModel:getCurMainSectionId()
    end

    self:updateSectionInfo(self._curSectionId)
    
    self:listenReflash("FormationModel", function()  --英雄形象更新 wangyan
            if self._mapLayer ~= nil then
                self._mapLayer:refreshSectionHero()
            end
        end)

    -- 是否展示大世界
    self._showWorld = false
    if self._quickStageId == nil then 
        local acSectionId = self._intanceModel:getData().mainsData.acSectionId
        local curStageId = self._intanceModel:getData().mainsData.curStageId
        if (self._curSectionId > IntanceConst.FIRST_SECTION_ID or 
            acSectionId > IntanceConst.FIRST_SECTION_ID) and 
            curStageId > IntanceConst.GUILDE_SWITCH_WORLD_STAGE_ID then
            IntanceConst.QUICK_ENTER_BY_WORLD = true
            self._showWorld = true
        end
    end
    -- 如果不是展示大世界则展示副本
    if self._showWorld == false then 
        self:createMapLayer()
        -- 单独提出执行，防止与其他锁冲突
        self._mapLayer:setSwitchSectionBegin()
        self._mapLayer:setSwitchSectionFinish()
        self:showIntanceBullet()
    end

    self:setListenReflashWithParam(true)
    self:listenReflash("SiegeModel", self.reflashSiegeEnterance)
end



function IntanceView:onAdd()
    -- self._viewMgr:showView("intance.IntanceGuideView", {})

    local sectionId = self._intanceModel:getCurMainSectionId()
    GuideUtils.checkTriggerByType("section", sectionId)
end
 

function IntanceView:onShow()
    local section = self._intanceModel:getSectionInfo(IntanceConst.FIRST_SECTION_ID)
    local sysMainSection = tab:MainSection(IntanceConst.FIRST_SECTION_ID)
    local flag = 1
    for k,v in pairs(sysMainSection.starNum) do
        -- 判断是否领取够
        if section[tostring(v)] == nil then
            flag = 0
        end
    end
    -- 特殊处理第一章
    if flag == 1 and 
        self._intanceModel:getData().mainsData.acSectionId == IntanceConst.FIRST_SECTION_ID and 
        self._intanceModel:getData().mainsData.curStageId > IntanceConst.FIRST_SECTION_LAST_STAGE_ID  then 
        self:setVisible(false)
        -- self._viewMgr:lock(-1)   
        self:lock(-1)
        ScheduleMgr:delayCall(100, self, function()
            local curSelectedIndex = tonumber(string.sub(self._curSectionId, 3 , 5))
            local includeSection = self._intanceModel:getSysSectionDatas()
            local newSysSection = includeSection[curSelectedIndex + 1]
            local param = {sectionId = newSysSection.id, type = 1}
            -- self._viewMgr:unlock()
            self:unlock()
            self._serverMgr:sendMsg("StageServer", "setSectionId", param, true, {}, function (result)
                if result == nil or result["d"] == nil then
                    self._viewMgr:showTip("激活下一章异常")
                    return 
                end
                if IntanceConst.FIRST_SECTION_ID +1 == self._intanceModel:getData().mainsData.acSectionId then
                    self._viewMgr:showView("intance.IntanceMcPlotView", {plotId = 2, callback = function()
                        self._viewMgr:popView()
                        SystemUtils.saveAccountLocalData("GO_STAR_POINT", newSysSection.id)
                        -- IntanceConst.GO_STAR_POINT = newSysSection.id
                        self:switchWorldLayer(false, newSysSection.id)
                        self:setVisible(true)
                    end})
                end
            end)
        end)
    end
    if self._showWorld == true then
        -- 快速跳转你特殊处理
        if self._quickCurSectionId == nil then 
            self._quickCurSectionId = 0
        end
        self:switchWorldLayer(false, nil, self._quickCurSectionId)
    end
    self:updateRealVisible(true)
end


function IntanceView:onModelReflash()
    self:updateSectionInfo(self._curSectionId)
    self:showIntanceBullet()
end

-- 更新攻城战入口
function IntanceView:reflashSiegeEnterance(eventName)
    if eventName == "stateUpdate" or eventName == "refleshUIEvent" then
        if self._worldLayer ~= nil then
            self._worldLayer:updateSiegeEntrance()
        end
    end
end

--[[
--! @function backSection
--! @desc 向后一章
--! @param 
--! @return 
--]]
function IntanceView:backSection()

    local curSelectedIndex = tonumber(string.sub(self._curSectionId, 3 , 5))
    
    local includeSection = self._intanceModel:getSysSectionDatas()

    local sysSection = includeSection[curSelectedIndex - 1]

    local newCurSectionId = self._intanceModel:getCurMainSectionId()
    if sysSection == nil then 
        self._viewMgr:showTip("已到达第一章节")
        return false
    end
    self:goToSection(sysSection.id)
end




--[[
--! @function backSection
--! @desc 向前一章
--! @param 
--! @return 
--]]
function IntanceView:activePreSection(callback)
    local curSelectedIndex = tonumber(string.sub(self._curSectionId, 3 , 5))
    local includeSection = self._intanceModel:getSysSectionDatas()
    local sysSection = includeSection[curSelectedIndex + 1]
    local callbackCode, otherParam = IntanceUtils:checkPreSection(self._curSectionId, sysSection)
    if callbackCode == 1 or callbackCode == 4 then 
        self._viewMgr:showTip("暂未开启")
        return
    elseif callbackCode == 2 then 
        self._viewMgr:showTip("需通本章所有关卡")
        
        return
    elseif callbackCode == 3 then 
        self._viewMgr:showTip("前往下一章需达到Lv." .. otherParam)
        return
    end

    local mainsData = self._intanceModel:getData().mainsData

    local newSectionId = tonumber(string.sub(mainsData.curStageId, 1 , 5))
    local acSectionId = mainsData.acSectionId
    if newSectionId == tonumber(sysSection.id) and 
        newSectionId > mainsData.acSectionId then 
        -- 向服务端传递激活下一章信息
        local param = {sectionId = newSectionId, type = 1}
        self._serverMgr:sendMsg("StageServer", "setSectionId", param, true, {}, function (result)
            if result == nil or result["d"] == nil then
                self._viewMgr:showTip("激活下一章出错")
                return false
            end
            local newSysSection = tab:MainSection(newSectionId)
            callback(newSysSection, 2)
        end) 
        return false
    end
    callback(sysSection, 1)
end

--[[
--! @function backSection
--! @desc 向前一章
--! @param 
--! @return 
--]]
function IntanceView:preSection(inTouchBtn)
    self:activePreSection(
        function(sysSection, inType)
            if inType == 1 then 
                self:goToSection(sysSection.id)
            else
                self._mapLayer:goNextSectionAction(sysSection.id, inTouchBtn)
            end
        end
    , 1)
end

function IntanceView:goToSection(inSectionId, anim)
    if self._curSectionId == inSectionId then 
        return 
    end
    self:updateSectionInfo(inSectionId)
    self._mapLayer:goNextSection(inSectionId, anim, function()
        self._mapLayer:setSwitchSectionFinish()
        self:showIntanceBullet()
    end)
end


function IntanceView:forceGoToSection(inSectionId, anim)
    self:updateSectionInfo(inSectionId)
    self._mapLayer:goNextSection(inSectionId, anim, function()
        self:showIntanceBullet()
    end)
end

--[[
--! @function updateSectionInfo
--! @desc 更新章信息
--! @param  inSectionId 章id
--! @return 
--]]
function IntanceView:updateSectionInfo(inSectionId)

    self._curSectionId = inSectionId

    local intanceData = self._intanceModel:getData().mainsData

    local section = self._intanceModel:getSectionInfo(inSectionId)

    local sysMainSection = tab:MainSection(inSectionId)

    -- 章标题更新
    local sectionName = self:getUI("Image_9.sectionName")
    sectionName:setString(lang(sysMainSection.rank) .. "  " .. lang(sysMainSection.secTitle))

    local lastSectionNeedStar = sysMainSection.starNum[#sysMainSection.starNum]
    -- 更新星星获取数目
    local starNumLab = self:getUI("Panel_18.progPanel.starNumLab")
    starNumLab:enableOutline(cc.c4b(73,48,26,255),1)
    starNumLab:setString(section.num .. "/" .. lastSectionNeedStar)

    local bgPanel = self:getUI("Panel_18.star" .. #sysMainSection.starNum .. "Panel") 
    bgPanel:setVisible(true)

    local numOffset = 0
    if #sysMainSection.starNum == 1 then 
        numOffset = 2
    elseif #sysMainSection.starNum == 2 then 
        numOffset = 1
    end
    for k,v in pairs(sysMainSection.starNum) do

        local newStarLab = self:getUI("Panel_18.star" .. #sysMainSection.starNum .. "Panel.box" ..k.. ".needStarBg" .. k .. ".needStarLab") 
        newStarLab:enableOutline(cc.c4b(73,48,26,255),2)
        newStarLab:setString("x" .. v)

        -- 已领取
        local rewardIcon = self:getUI("Panel_18.star" .. #sysMainSection.starNum .. "Panel.box" ..k.. ".reward" .. k .. "Icon")
        -- 未领取
        local rewardBtn = self:getUI("Panel_18.star" .. #sysMainSection.starNum .. "Panel.box" ..k.. ".reward" .. k .. "Btn")

        self:registerClickEvent(rewardIcon, function()    
            if self._isLock == true then return end     
            self:clickTreasureCase(inSectionId, k, 1)
        end)

        self:registerClickEvent(rewardBtn, function() 
            if self._isLock == true then return end
            self:clickTreasureCase(inSectionId, k)
        end)   
        -- 为了效果特殊处理
        if rewardBtn.cacheSectionId ~= inSectionId then
            rewardBtn.showFullAnim = nil
            rewardBtn.cacheSectionId = inSectionId
        end  

        rewardBtn:stopAllActions()
        rewardBtn:removeAllChildren()
        if rewardBtn.boxLight ~= nil then 
            rewardBtn.boxLight:removeFromParent(true)
            rewardBtn.boxLight = nil
        end
        if rewardBtn.boxAnim ~= nil then 
            rewardBtn.boxAnim:removeFromParent(true)
            rewardBtn.boxAnim = nil
        end

        if tonumber(v) <= section.num  and 
            section[tostring(v)] == nil then 
            rewardBtn:setVisible(true)
            
            rewardIcon:setVisible(false)
            local function rewardBtnAnim()
                local btnParent = rewardBtn:getParent()
                local boxLight = btnParent:getChildByName("box_light")
                if boxLight == nil then 
                    boxLight = mcMgr:createViewMC("baoxiangguang1_baoxiang", true)
                    boxLight:setPosition(rewardBtn:getPositionX(), rewardBtn:getPositionY())
                    boxLight:setName("box_light")
                    btnParent:addChild(boxLight,10)
                    boxLight:setCascadeOpacityEnabled(true, true)
                    -- boxLight:setOpacity(rewardBtn:getOpacity())
                end
                boxLight:setVisible(true)  
                rewardBtn.boxLight = boxLight
                local boxAnim = btnParent:getChildByName("box_anim" .. k)
                if boxAnim == nil then 
                    boxAnim = mcMgr:createViewMC("baoxiang" .. (k + numOffset) .. "_baoxiang", true)
                    boxAnim:setPosition(rewardBtn:getPositionX(), rewardBtn:getPositionY())
                    boxAnim:setName("box_anim")
                    btnParent:addChild(boxAnim, 3)
                    boxAnim:setCascadeOpacityEnabled(true, true)
                end
                boxAnim:setVisible(true)
                rewardBtn.boxAnim = boxAnim
            end
            -- local action1 = cc.MoveBy:create(0.1, cc.p(0, 2))

            if rewardBtn.showFullAnim == false then
                rewardBtn:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(function()
                    local tmpStar = mcMgr:createViewMC("juxing_fubenbaoxiangkaiqijuxing", false, true)
                    tmpStar:addCallbackAtFrame(17, function()
                        rewardBtn:setOpacity(0)
                        rewardBtnAnim() 
                    end)
                    tmpStar:setPosition(rewardBtn:getContentSize().width/2, rewardBtn:getContentSize().height/2)
                    rewardBtn:addChild(tmpStar,10)
                    rewardBtn.showFullAnim = true

                end)))
            else
                rewardBtn:setOpacity(0)
                rewardBtnAnim()
            end
        else
            rewardBtn:setOpacity(255)
            if section[tostring(v)] ~= nil then 
                rewardBtn.showFullAnim = true
            else
                rewardBtn.showFullAnim = false
            end
            
            if section[tostring(v)] ~= nil then 
                rewardBtn:setVisible(false)
                rewardIcon:setVisible(true)
            else
                rewardBtn:setVisible(true)
                rewardIcon:setVisible(false)
            end
        end
    end
    local starBg = self:getUI("Panel_18")
    if starBg.animIcon ~= nil then 
        starBg.animIcon:removeFromParent()
        starBg.animIcon = nil
    end
    local starBoxBg = self:getUI("Panel_18.star" .. #sysMainSection.starNum .. "Panel.box" .. #sysMainSection.starNum)

    if section[tostring(lastSectionNeedStar)] == nil and sysMainSection.rewardShow ~= nil then 
        local animIcon = cc.Sprite:createWithSpriteFrameName("intanceImage_" .. sysMainSection.rewardShow .. ".png")
        animIcon:setPosition(starBoxBg:getContentSize().width + 5, starBoxBg:getContentSize().height + 20)
        starBoxBg:addChild(animIcon, 100)
        starBg.animIcon = animIcon

        if sysMainSection.showNum ~= nil then
            local labShowNum = cc.Label:createWithTTF(sysMainSection.showNum, UIUtils.ttfName, 16)
            labShowNum:setColor(UIUtils.colorTable.ccUIBaseColor1)
            labShowNum:enableOutline(cc.c4b(60, 30, 10, 255), 1)
            labShowNum:setAnchorPoint(0, 0)
            labShowNum:setPosition(animIcon:getContentSize().width * 0.5 - 5, animIcon:getContentSize().height * 0.5)
            animIcon:addChild(labShowNum)
        end
        local seq = cc.Sequence:create(cc.ScaleTo:create(0.6, 1.2), cc.ScaleTo:create(0.6, 1))
        animIcon:runAction(cc.RepeatForever:create(seq))
    end


    local prog = self:getUI("Panel_18.progPanel.prog1") 
    local perProg = section.num / tonumber(lastSectionNeedStar)  * 542
    prog:setContentSize(perProg, prog:getContentSize().height)
    if section.num <= 0 then
        prog:setVisible(false)
    else
        prog:setVisible(true)
    end

    for i=1,3 do
        if #sysMainSection.starNum ~= i then 
            local bgPanel = self:getUI("Panel_18.star" .. i .. "Panel") 
            bgPanel:setVisible(false)
        end
    end

    -- 标题上一章下一章按钮状态
    local preSectionBtn = self:getUI("Panel_55.preSectionBtn")
    local preRightTitle = self:getUI("Panel_55.preText")

    if preRightTitle.posX == nil then 
        preRightTitle.posX = preRightTitle:getPositionX()
    end

    local btnTip = preSectionBtn:getChildByName("tip")


    local mainsData = self._intanceModel:getData().mainsData
    local newSectionId = tonumber(string.sub(mainsData.curStageId, 1 , 5))
    local sysSection = tab:MainSection(newSectionId)
    local callbackCode, otherParam = IntanceUtils:checkPreSection(self._intanceModel:getCurMainSectionId(), sysSection)


    if callbackCode ~= 0 then
        if btnTip ~= nil then    
            btnTip:removeFromParent()
        end 
        preRightTitle:stopAllActions()
        preRightTitle:setPositionX(preRightTitle.posX)
    end

    if btnTip == nil and callbackCode == 0 then 
        btnTip = mcMgr:createViewMC("jingyingfuben_intancejiantou", true)
        btnTip:setPosition(preSectionBtn:getContentSize().width/2, preSectionBtn:getContentSize().height/2)
        btnTip:setName("tip")
        preSectionBtn:addChild(btnTip, -1)
        btnTip:setCascadeOpacityEnabled(true, true)
        btnTip:setOpacity(255)
        preRightTitle:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.2, cc.p(3, 0)),cc.MoveBy:create(0.2, cc.p(-3, 0)))))
    end
    
    self:updateSectionInfoBtnState()

    self:updateHeroUnlockBtnState()

    self:updateTaskState()

    self:updateBulletBtnState()
end

--[[
--! @function updateBulletBtnState
--! @desc 更新弹幕按钮
--! @return 
--]]
function IntanceView:updateBulletBtnState()

    BulletScreensUtils.clear()

    local bulletBtn = self:getUI("buttomPanel.bulletBtn")
    local bulletLab = self:getUI("buttomPanel.bulletLab")
    if tab.Bullet then
        self._sysBullet = tab:Bullet(self._curSectionId)
    end
    if self._sysBullet == nil or GameStatic.showIntanceBullet == false then 
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

function IntanceView:showIntanceBullet()
    if self._sysBullet == nil then 
        return
    end
    local bulletBtn = self:getUI("buttomPanel.bulletBtn")
    local open = BulletScreensUtils.getBulletChannelEnabled(self._sysBullet)
    local fileName = open and "bullet_open_btn.png" or "bullet_close_btn.png"
    bulletBtn:loadTextures(fileName, fileName, fileName, 1)    
    if open  then
        BulletScreensUtils.initBullet(self._sysBullet)
    end    
end

function IntanceView:lockMap()
    if self._mapLayer ~= nil then
        self._mapLayer:setLockMap(true)
    end
end

function IntanceView:unlockMap()
    if self._mapLayer ~= nil then
        self._mapLayer:setLockMap(false)
    end
end


function IntanceView:loadBigMap()
    if self._mapLayer ~= nil then
        self._mapLayer:loadBigMap()
    end
end

--[[
--! @function updateHeroUnlockBtnState
--! @desc 更新英雄解锁按钮
--! @return 
--]]
function IntanceView:updateHeroUnlockBtnState()
    local heroUnlockBtn = self:getUI("leftPanel.heroUnlockBtn")
    heroUnlockBtn:setVisible(false)
    if self._curSectionId <= IntanceConst.FIRST_SECTION_ID + 1 then 
        return
    end
    local sysMainStories = tab.mainStory
    local storyId 
    for k,v in pairs(sysMainStories) do
        repeat
            if v.reward == nil then break end
            local index = table.indexof(v.include, self._curSectionId)
            if index ~= false then 
                storyId = v.id
                break 
            end
        until true
        if storyId ~= nil then break end    
    end
    if storyId == nil then return end

    local sysMainStory = tab.mainStory[storyId]

    local finishSectionId = tab:Setting("G_FINISH_SECTION_STORY").value

    local mainData = self._intanceModel:getData().mainsData
    local acSectionId = mainData.acSectionId 
    local curStageId = mainData.curStageId 
    local curStageInfo = self._intanceModel:getStageInfo(curStageId)
    local maxStageNum = 0
    local curStageNum = 0

    local flag = 0
    local showTip = 0
    for k,v in pairs(sysMainStory.include) do
        local sysMainSection = tab:MainSection(v)

        if sysMainSection.id == acSectionId then 
            for k1,v1 in pairs(sysMainSection.includeStage) do
                if v1 < curStageId  or (v1 <= curStageId and curStageInfo.star > 0 and acSectionId == finishSectionId) then 
                    curStageNum = curStageNum + 1
                end
            end             
        elseif sysMainSection.id < acSectionId then     
            curStageNum = curStageNum + #sysMainSection.includeStage
        end
        maxStageNum = maxStageNum + #sysMainSection.includeStage

        local sectionInfo = self._intanceModel:getSectionInfo(v)
        if sectionInfo.sr == nil then 
            flag = 1
            if curStageNum == maxStageNum then 
                showTip = 1
            end
        end
    end

    local mainsData = self._intanceModel:getData().mainsData
    if flag == 0 then 
        heroUnlockBtn:setVisible(false)
        return
    end

    if showTip == 1 then 
        if heroUnlockBtn.tip == nil then 
            local tip = cc.Sprite:createWithSpriteFrameName("globalImageUI_bag_keyihecheng.png")
            tip:setPosition(cc.p(heroUnlockBtn:getContentSize().width - 30, heroUnlockBtn:getContentSize().height -5))
            tip:setAnchorPoint(cc.p(0.5, 0.5))
            heroUnlockBtn:addChild(tip, 10)
            tip:setScale(1/heroUnlockBtn:getScaleX())
            heroUnlockBtn.tip = tip
        end
        heroUnlockBtn.tip:setVisible(true)
    else
        if heroUnlockBtn.tip ~= nil then 
            heroUnlockBtn.tip:setVisible(false)
        end
    end

    heroUnlockBtn:setVisible(true)
    local rewardHeroId = sysMainStory.reward[1][2]

    local rewardImg = "intanceImage_heroUnlockBtn" .. rewardHeroId .. ".png"
    heroUnlockBtn:loadTextures(rewardImg, rewardImg, "", 1)
    heroUnlockBtn:setVisible(true)
    heroUnlockBtn:setScaleAnim(true)

    registerClickEvent(heroUnlockBtn, function()
        self._viewMgr:showDialog("intance.IntanceHeroUnlockView", {storyId = storyId, showType = 0, callback = function(inType)
            self:updateHeroUnlockBtnState()
        end})
    end) 
end

--[[
--! @function updateSectionInfoBtnState
--! @desc 更新主界面infobtn状态
--! @return 
--]]
function IntanceView:updateSectionInfoBtnState()
    -- 章信息提示
    local sectionInfoBtn = self:getUI("leftPanel.sectionInfoBtn")
    local sysSectionInfo = tab.sectionInfo[self._curSectionId]
    if sysSectionInfo == nil or sysSectionInfo.openBranch == 0 then
        -- sectionInfoBtn:setVisible(false)
        if sectionInfoBtn.tip ~= nil then 
            sectionInfoBtn.tip:setVisible(false)
        end
        return
    end

    local mainsData = self._intanceModel:getData().mainsData
    local branchInfo = {}
    local sysMainSection = tab:MainSection(self._curSectionId)
    for k,v in pairs(sysMainSection.includeStage) do
        local sysMainStage = tab:MainStage(v)
        local stageInfo = self._intanceModel:getStageInfo(v)
        for k1,v1 in pairs(stageInfo.branchInfo) do
            branchInfo[tonumber(k1)] = true
        end
        if mainsData.curStageId <= v and sysMainStage.branchId ~= nil then
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
        local sectionInfo = self._intanceModel:getSectionInfo(self._curSectionId)
        local maxNum = sysSectionInfo.finishReward[1][1]
        local minNum = sectionInfo.b.num
        if minNum == maxNum then 
            if sectionInfo.b[tostring(maxNum)] == nil then 
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
function IntanceView:updateTaskState(inForced)
    local taskBg = self:getUI("leftPanel.taskBg")
    local sysMainSectionMap = tab:MainSectionMap(self._curSectionId)
    if sysMainSectionMap.task == nil then 
        taskBg.sectionId = self._curSectionId
        taskBg:setVisible(false)
        return
    end
    local branchWithStage = self._intanceModel:getSysBranchWithStageDatas()
    -- dump(branchWithStage, "test", 10)
    local lastTaskId = 0
    local curStageId = self._intanceModel:getData().mainsData.curStageId

    for k1,v1 in pairs(sysMainSectionMap.task) do
        local v = tab:MainTask(v1)
        local targetType = v.taskTarget[1]
        local targetId = v.taskTarget[2]
        if targetType == 1 then 
            local stageInfo = self._intanceModel:getStageInfo(targetId)
            if stageInfo.star <= 0 then
                lastTaskId = v.id
                break
            end
        else
            if curStageId <= IntanceConst.FIRST_SECTION_FIRST_STAGE_ID and
             (targetId == IntanceConst.SPECIAL_BRANCH_1_ID or 
                targetId == IntanceConst.SPECIAL_BRANCH_2_ID) then
                dump(self._intanceModel:getData().mainsData.spBranch, "test", 10)
                if self._intanceModel:getData().mainsData.spBranch[tostring(targetId)] == nil  then
                    lastTaskId = v.id
                    break
                end
            elseif branchWithStage[targetId] ~= nil then 
                local stageInfo = self._intanceModel:getStageInfo(branchWithStage[targetId])
                if stageInfo.branchInfo[targetId] == nil then
                    lastTaskId = v.id
                    break
                end
            end
        end
    end
    if lastTaskId == 0 then
        taskBg.sectionId = self._curSectionId
        taskBg:setVisible(false)
        return
    else
        taskBg:setVisible(true)
    end

    -- local taskImg = self:getUI("leftPanel.taskBg.taskImg")
    -- self:registerClickEvent(taskImg, function ()
    --     self._viewMgr:showDialog("intance.IntanceMissionInfoView",{
    --         taskId = lastTaskId}
    --     )
    -- end)


    local sysTask = tab:MainTask(lastTaskId)

    local labTaskTip = self:getUI("leftPanel.taskBg.labTaskTip")
    labTaskTip:setColor(cc.c4b(255, 236, 83,255))
    labTaskTip:enable2Color(1,cc.c4b(255, 253, 226,255))

    if taskBg.sectionId ~= self._curSectionId or inForced == true then 
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
    

    local labTaskDesc = self:getUI("leftPanel.taskBg.labTaskDesc")
    labTaskDesc:setString(lang(sysTask.taskDes))

    taskBg:setContentSize(cc.size(labTaskDesc:getPositionX() + labTaskDesc:getContentSize().width + 10, taskBg:getContentSize().height))

end

--[[
--! @function clickTreasureCase
--! @desc 点击进入奖励界面
--! @param  inSectionId 章id
--! @param  inIndex 箱子索引
--! @param  inItemId 物品id
--! @return 
--]]
function IntanceView:clickTreasureCase(inSectionId, inIndex, inShowType)
    local section = self._intanceModel:getSectionInfo(inSectionId)

    local sysMainSection = tab:MainSection(inSectionId)

    local needStarNum = sysMainSection.starNum[inIndex]

    local desc = ""
    local canGet = false

    local viewType 
    if inShowType ~= 1 then 
        if needStarNum > section.num then 
            desc = lang("FINISHSTAGEAWARD_1")
            viewType = 1
        else
            desc = lang("FINISHSTAGEAWARD_2")
            
            canGet = true
        end
    else
        desc = lang("FINISHSTAGEAWARD_2")
        viewType = 1
    end

    local result,count = string.gsub(desc, "$num1", needStarNum)
    if count > 0 then 
        desc = result
    end
    local result,count = string.gsub(desc, "$num", section.num)
    if count > 0 then 
        desc = result
    end

    local rewards = {}
    for k,v in pairs(sysMainSection.package) do
        local itemIcon = nil
        if v[1]  == needStarNum then 
            local tempData = table.deepCopy(v)
            table.remove(tempData, 1)
            table.insert(rewards, tempData)
        end
    end

    local function showGiftGet(inBtnTitle,inRewards)
        DialogUtils.showGiftGet( {
        gifts = inRewards or rewards,
        viewType = viewType,
        canGet = canGet, 
        des = desc,
        title = lang("FINISHSTAGETITLE"),
        btnTitle = inBtnTitle, 
        callback = function()

        end,notPop = not viewType} )
    end
    if inShowType == nil then
        if viewType == nil then 
            local param = {type = needStarNum, section = inSectionId}
            self._serverMgr:sendMsg("StageServer", "collectStarReward", param, true, {}, function (result)
                showGiftGet(nil, result.reward)
                self:onModelReflash()
            end)
        else 
            showGiftGet()
        end
    else
        showGiftGet("已领取")
    end
end


function IntanceView:lockViewBtn(inState)
    self._isLock = not inState



    -- 锁定星星宝箱
    for i=1, 3 do
        local bgPanel = self:getUI("Panel_18.star" .. i .. "Panel") 
        if bgPanel ~= nil then 
            for k=1,3 do
            -- 已领取
            local rewardIcon = self:getUI("Panel_18.star" .. i .. "Panel.box" ..k.. ".reward" .. k .. "Icon")
            -- 未领取
            local rewardBtn = self:getUI("Panel_18.star" .. i .. "Panel.box" ..k.. ".reward" .. k .. "Btn")    
                if rewardIcon ~= nil then 
                    rewardIcon:setTouchEnabled(inState)
                end
                if rewardBtn ~= nil then 
                    rewardBtn:setTouchEnabled(inState)
                end                
            end
        end
    end

    -- local eliteBtn = self:getUI("eliteBtn")
    -- eliteBtn:setTouchEnabled(inState)

    local backSectionBtn = self:getUI("Panel_55.backSectionBtn")
    

    backSectionBtn:setTouchEnabled(inState)

    local preSectionBtn = self:getUI("Panel_55.preSectionBtn")
    preSectionBtn:setTouchEnabled(inState)

    -- local worldBtn = self:getUI("worldBtn")
    -- worldBtn:setTouchEnabled(inState)

    local undoneStageBtn = self:getUI("Panel_18.progPanel.undoneStageBtn")
    undoneStageBtn:setTouchEnabled(inState)

    local sectionInfoBtn = self:getUI("leftPanel.sectionInfoBtn")
    sectionInfoBtn:setTouchEnabled(inState)

    local heroUnlockBtn = self:getUI("leftPanel.heroUnlockBtn")
    heroUnlockBtn:setTouchEnabled(inState)

    local closeBtn = self:getUI("closeBtn")
    closeBtn:setTouchEnabled(inState)

    local bulletBtn = self:getUI("buttomPanel.bulletBtn")
    bulletBtn:setTouchEnabled(inState)
end

function IntanceView:runStarAnim(inNum)
    local undoneStageBtn = self:getUI("Panel_18.progPanel.undoneStageBtn")
    local amin2 = mcMgr:createViewMC("fankuiguang_intancegetstar", true, false, function(_, sender)
        if sender.time == inNum then 
            sender:clearCallbacks()
            sender:stop(affectSub)
            sender:removeFromParent()
            return
        end 
        sender.time = sender.time + 1
    end)
    amin2:setPosition(undoneStageBtn:getContentSize().width/2 + 26, undoneStageBtn:getContentSize().height/2 + 2)
    undoneStageBtn:addChild(amin2)
    amin2.time = 1
end

function IntanceView:switchWorldLayer(anim, actNewSectionId, curSectionId)
    print("switchWorldLayer==================================")
    local regainLock = function(inState) 
        self:lockViewBtn(inState)
        if self._mapLayer ~= nil then
            self._mapLayer:setLockMap(not inState, true)
        end
    end 
    local timeOffset = 0.4
    -- 跳转到相应章节
    local switchSectoin = function(inSectionId)
        print("switchSectoin inSectionId=============", inSectionId)

        local isCreateLayer = false
        if self._mapLayer == nil then 
            isCreateLayer = true
            self:createMapLayer(inSectionId)
            self._mapLayer:setSwitchSectionBegin()
            self:updateSectionInfo(inSectionId)
            self:showIntanceBullet()
        end
        -- self._viewMgr:lock(-1)
        regainLock(false)
        self:lock(-1)
        self._widget:setCascadeOpacityEnabled(true, true)
        self._widget:setOpacity(1)

        -- 次sectionLock 参数是判断是否要开锁，goToSection中会有开锁加锁功能
        -- 会影响goToSection的加锁解锁功能
        local sectionLock = false 
        if (inSectionId ~= nil and self._curSectionId ~= inSectionId and isCreateLayer == false) or 
            (actNewSectionId ~= nil and actNewSectionId > 0 and actNewSectionId ~=  inSectionId) then
            self._curSectionId = 0
            -- self:goToSection(inSectionId, false)
            regainLock(false)
            self:updateSectionInfo(inSectionId)
            self._mapLayer:goNextSection(inSectionId, false, function()
                self:showIntanceBullet()
            end)
            regainLock(true)
        end
        self._worldLayer:lockTouch()
        ScheduleMgr:delayCall(0, self, function()
            self._worldLayer:runAction(cc.Sequence:create(cc.FadeOut:create(0.5 * timeOffset),
                cc.CallFunc:create(function() 
                        self._worldLayer:unLockTouch()
                        self._worldLayer:removeFromParent()
                        self._worldLayer = nil
                    end)))

            self:runAction(cc.Sequence:create(
                cc.CallFunc:create(function()
                    self._mapLayer:setVisible(true)
                    self._mapLayer:loadBigMap()
                    self._mapLayer:switchWorldMapActionOut(function() 
                        self:unlock()
                        -- if not sectionLock then
                        regainLock(true)
                        -- end

                        self._mapLayer:setSwitchSectionFinish()
                    end, true , timeOffset)
                    self:updateTaskState(true)
                    self:showIntanceBullet()

                end),cc.DelayTime:create(1 * timeOffset),
                cc.CallFunc:create(function() 
                    self._widget:runAction(cc.FadeIn:create(1.5 * timeOffset))
                end)
            ))
        end)
    end
    if self._quickStageId ~= nil then
        self:loadSyncRes({
                        {"asset/ui/intanceWorld.plist", "asset/ui/intanceWorld.png"},
                        {"asset/ui/intanceWorld2.plist", "asset/ui/intanceWorld2.png"},
                        {"asset/ui/intanceLightWord.plist", "asset/ui/intanceLightWord.png"},
                    })
    end
    BulletScreensUtils.clear()
    if anim then 
        self:lock(-1)
        ScheduleMgr:delayCall(0, self, function()
            if self._mapLayer ~= nil then
                self._mapLayer:loadBigMap()
                self._mapLayer:enterWorld()
            end
            ScheduleMgr:delayCall(0, self, function()
                if self._worldLayer == nil then
                    self._worldLayer = require("game.view.intance.IntanceWorldLayer").new(
                        function(inSectionId)
                            regainLock(true)
                            switchSectoin(inSectionId)
                        end, self, actNewSectionId)
                    self:addChild(self._worldLayer, 100)
                else
                    self._worldLayer:onTop()
                end
                self._worldLayer:setCascadeOpacityEnabled(true, true)
                self._worldLayer:setOpacity(0)
                -- WorldTipRichText 气泡提示特殊处理
                if self._worldLayer:getWorldTipRichText() ~= nil then 
                    self._worldLayer:getWorldTipRichText():setCascadeOpacityEnabled(true, true)
                    self._worldLayer:getWorldTipRichText():setOpacity(0)
                end
                ScheduleMgr:delayCall(0, self, function()
                    if curSectionId ~= nil and not(actNewSectionId ~= nil and actNewSectionId > 0) then 
                        self._worldLayer:showSection(curSectionId)
                    elseif actNewSectionId ~= nil and actNewSectionId > 0 then
                        self._worldLayer:showSection(actNewSectionId, true)    
                    end
                    if self._worldLayer:getWorldTipRichText() ~= nil then 
                        self._worldLayer:getWorldTipRichText():setOpacity(0)
                        self._worldLayer:getWorldTipRichText():runAction(
                            cc.Sequence:create(
                                cc.DelayTime:create(1.2 * timeOffset), 
                                cc.FadeIn:create(0.1 * timeOffset)
                            )
                        )                        
                    end
                    self._worldLayer:runAction(
                        cc.Sequence:create(
                            cc.DelayTime:create(1.2 * timeOffset), 
                            cc.FadeIn:create(0.1 * timeOffset),
                            cc.CallFunc:create(
                                function()
                                    if self._mapLayer ~= nil then
                                        self._mapLayer:setVisible(false)
                                        self._mapLayer:resumeMapState()
                                    end
                                    self:unlock()
                                    if actNewSectionId ~= nil and actNewSectionId > 0 then 
                                        self._worldLayer:activeNewSectionStory()
                                    else
                                        self._worldLayer:quickCheckActiveNewSection()
                                    end
                                end
                            )
                        )
                    )

                    self._widget:setCascadeOpacityEnabled(true, true)
                    self._widget:setOpacity(255)
                    self._widget:runAction(cc.Sequence:create(
                        cc.FadeOut:create(0.5 * timeOffset)))
                end)
            end)    
        end)
    else
        if self._mapLayer ~= nil then 
            self._mapLayer:enterWorld()
        end
        if self._worldLayer == nil then
            self._worldLayer = require("game.view.intance.IntanceWorldLayer").new(
            function(inSectionId)
                regainLock(true)
                switchSectoin(inSectionId)
            end, self, actNewSectionId)
            
            self:addChild(self._worldLayer, 100)
        else
            -- 两个view间切换会无法走onTop,所以手动走
            self._worldLayer:onTop()
        end
        if curSectionId ~= nil and not(actNewSectionId ~= nil and actNewSectionId > 0) then 
            self._worldLayer:showSection(curSectionId)
            self._worldLayer:quickCheckActiveNewSection()
        elseif actNewSectionId ~= nil and actNewSectionId > 0 then
            self._worldLayer:showSection(actNewSectionId, true)
            self._worldLayer:activeNewSectionStory()
        end
    end
    regainLock(false)
end

function IntanceView:onDoGuide(config)
    if self._worldLayer ~= nil then 
        if config.moveto ~= nil then
            self._worldLayer:setMapPosition(config.moveto.x, config.moveto.y)    
        end
        if config.showBtn ~= nil then
            self._worldLayer:quickShowBtn(config.showBtn)  
        end
    end
    if config.closeWorld ~= nil then
        self._guideIgnoreWorld = 1
    end
end



function IntanceView:listenUserModel()
    if self._mapLayer == nil then return end
    local intanceStageInfoNode = self._mapLayer:getStageInfoNode()
    if intanceStageInfoNode == nil or intanceStageInfoNode:isVisible() == false then return end
    intanceStageInfoNode:updateAboutStage()
end

function IntanceView:listenModel(inType)
    if inType == nil then
        return
    end

    if self[inType] == nil then
        return
    end
    if self[inType] then
        self[inType](self)
    end
end

function IntanceView:listenDailySiegeMode(eventName)
    if "refleshUIEvent" == eventName then
        if self._worldLayer then
            self._worldLayer:onTop()
        end 
    end 
end


function IntanceView:getReleaseDelay()
    return -1
end

function IntanceView:isReleaseAllOnPop()
    return true
end

function IntanceView:isReleaseAllOnShow()
    return self.__isReleaseAllOnShow
end

function IntanceView:getHideListInStory()
    return {self._widget}
end

function IntanceView:destroy(removeRes)
    if self._worldLayer ~= nil then 
        self._worldLayer:removeFromParent()
        self._worldLayer = nil
    end
    self._quickStageId = nil
    self._enterIntance = false
    if self._mapLayer ~= nil then
        self._mapLayer:closeLayer()
        self._mapLayer:setVisible(false)
    end
    IntanceView.super.destroy(self, removeRes)
end

function IntanceView.dtor()
    cc = nil
end

return IntanceView