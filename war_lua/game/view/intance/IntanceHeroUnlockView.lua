--[[
    Filename:    IntanceHeroUnlockView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2017-01-23 17:49:22
    Description: File description
--]]

local IntanceHeroUnlockView = class("IntanceHeroUnlockView", BasePopView)


function IntanceHeroUnlockView:ctor()
    IntanceHeroUnlockView.super.ctor(self)
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("intance.IntanceHeroUnlockView")
        elseif eventType == "enter" then 

        end
    end)
end

function IntanceHeroUnlockView:reflashUI(inData)
    local selectedStoryId = inData.storyId
    self._callback = inData.callback

    local closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(closeBtn, function ()
        if self._callback ~= nil then 
            self._callback()
        end
        self:close()
    end)
    if inData.showType == 1 then
        local bgLayer = ccui.Layout:create()
        bgLayer:setBackGroundColorOpacity(0)
        bgLayer:setBackGroundColorType(1)
        bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
        bgLayer:setTouchEnabled(true)
        bgLayer:setContentSize(IntanceConst.MAX_SCREEN_WIDTH, IntanceConst.MAX_SCREEN_HEIGHT)
        self:addChild(bgLayer, 1000)
        self:registerClickEvent(bgLayer, function ()
            if self._callback ~= nil then 
                self._callback()
            end
            self:close()
        end)
    end


    local intanceModel =  self._modelMgr:getModel("IntanceModel")

    local acSectionId = intanceModel:getData().mainsData.acSectionId 
    local curStageId = intanceModel:getData().mainsData.curStageId

    local sysMainStory = tab.mainStory[selectedStoryId]

    -- 当前大章总章数
    local sectionNum = #sysMainStory.include

    local rewardHeroId = sysMainStory.reward[1][2]

    local bg = self:getUI("bg.bg1")
    bg:loadTexture("asset/bg/intance/intanceImage_heroUnlockBg" .. rewardHeroId .. ".png")
    bg:setVisible(true)
    
    local progPanel = self:getUI("bg.progPanel3")
    progPanel:setVisible(false)

    local progPanel = self:getUI("bg.progPanel4")
    progPanel:setVisible(false)

    local progPanel = self:getUI("bg.progPanel" .. sectionNum)
    progPanel:setVisible(true)


    local imgChip = self:getUI("bg.imgChip" .. rewardHeroId)
    if imgChip ~= nil then 
        imgChip:setVisible(true)
    end

    local sysHero = tab:Hero(rewardHeroId)

    local desc = "[color=ffffff, fontsize=18, outlinecolor=3C1E0A, outlinesize=1]" .. lang(sysHero.herodes) .. "[-]"
    local descBg = self:getUI("bg.descBg")
    local richText = RichTextFactory:create(desc, descBg:getContentSize().width, descBg:getContentSize().height)
    richText:setPixelNewline(true)
    richText:formatText()
    richText:setPosition(descBg:getContentSize().width * 0.5, descBg:getContentSize().height - richText:getInnerSize().height * 0.5)
    richText:setName("descRichText")
    descBg:addChild(richText)

    local findHeroSpecialFirstEffectData = function(specialBaseId)
        local specialTableData = clone(tab.heroMastery)
        for k, v in pairs(specialTableData) do
            if 1 == v.class and specialBaseId == v.baseid then
                return v
            end
        end
    end

    local imgIcon = self:getUI("bg.imgIcon")
    local heroMasteryData = findHeroSpecialFirstEffectData(sysHero.special)
    imgIcon:loadTexture(IconUtils.iconPath .. heroMasteryData.icon .. ".jpg", 1)
    imgIcon:setScale(0.8)

    local masteryBg = self:getUI("bg.masteryBg")

    local richText = RichTextFactory:create(lang("TALENT_STORYHERO_" .. rewardHeroId), masteryBg:getContentSize().width, masteryBg:getContentSize().height)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(masteryBg:getContentSize().width * 0.5, masteryBg:getContentSize().height - richText:getInnerSize().height * 0.5)
    richText:setName("descRichText")
    masteryBg:addChild(richText)



    local labTip = self:getUI("bg.labTip")
    labTip:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    local labTip1 = self:getUI("bg.labTip1")
    -- labTip1:setColor(cc.c4b(255, 253, 226,255))
    -- labTip1:enable2Color(1,cc.c4b(255, 236, 83,255))
    -- labTip1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)    


    local labName = self:getUI("bg.labName")
    labName:setString(lang("HEROSPECIAL_" .. sysHero.special))
    labName:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    -- labName:enable2Color(1,cc.c4b(255, 236, 83,255))
    -- labName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)


    -- 通关后播放动画
    local finishSectionId = tab:Setting("G_FINISH_SECTION_STORY").value
    local curStageInfo = intanceModel:getStageInfo(curStageId)
    
    local maxStageNum = 0
    local curStageNum = 0
    for k,v in pairs(sysMainStory.include) do
        local sysMainSection = tab:MainSection(v)

        if sysMainSection.id == acSectionId then 
            for k1,v1 in pairs(sysMainSection.includeStage) do
                -- 最后一章特殊判断
                if (v1 < curStageId) or (v1 <= curStageId and curStageInfo.star > 0 and acSectionId == finishSectionId) then 
                    curStageNum = curStageNum + 1
                end
            end 
        elseif sysMainSection.id < acSectionId then 
            curStageNum = curStageNum + #sysMainSection.includeStage      
        end
        maxStageNum = maxStageNum + #sysMainSection.includeStage
        local imgTickBg = self:getUI("bg.progPanel" .. sectionNum .. ".progFront.imgTickBg" .. k)
        
        local curSectionNum = tonumber(string.sub(sysMainSection.id, 3 , 5))
        local labPanelTip = self:getUI("bg.progPanel" .. sectionNum .. ".labTip" .. k)
        labPanelTip:setFontName(UIUtils.ttfName)
        labPanelTip:setColor(UIUtils.colorTable.ccUIBasePromptColor)
        labPanelTip.stageNum = 0
        labPanelTip:setString(lang("FINISHSTAGEAWARD_6") .. lang("CHAR_DI") .. lang("NUM_" .. curSectionNum) .. lang("CHAR_ZHANG"))

        if imgTickBg ~= nil then
            local sectionInfo = intanceModel:getSectionInfo(sysMainSection.id)

            local iconId = 0
            local sReward = sysMainSection.sReward[1]
            if sReward[1] == "tool" then
                iconId = sReward[2]
            else
                iconId = IconUtils.iconIdMap[sReward[1]]
            end

            local rewardIcon = IconUtils:createItemIconById({itemId = iconId, itemData = tab:Tool(iconId), num = sReward[3], eventStyle = 0, effect = true})
            rewardIcon:setScale(0.5)
            rewardIcon:setAnchorPoint(cc.p(0.5, 0.5))
            rewardIcon:setPosition(imgTickBg:getContentSize().width * 0.5, imgTickBg:getContentSize().height * 0.5)
            imgTickBg:addChild(rewardIcon)
            rewardIcon.limitNum = maxStageNum


            if curStageNum >= rewardIcon.limitNum and sectionInfo.sr == nil then
                local mc1 = mcMgr:createViewMC("wupinguang_itemeffectcollection", true)
                mc1:setPosition(rewardIcon:getContentSize().width * 0.5 ,rewardIcon:getContentSize().height * 0.5)
                rewardIcon:addChild(mc1, 9)
                rewardIcon.mc = mc1
            end

            if sectionInfo.sr ~= nil then 
                local getIt = cc.Sprite:createWithSpriteFrameName("globalImageUI_activity_getItBlue.png")
                getIt:setPosition(rewardIcon:getContentSize().width * 0.5 ,rewardIcon:getContentSize().height * 0.5)
                rewardIcon:addChild(getIt, 9)
            end

            self:registerClickEvent(rewardIcon, function()
                self:clickTreasureCase(sysMainSection.id, curStageNum, rewardIcon)
            end)
            -- if maxStageNum > curStageNum and 
            --     curStageNum <= rewardIcon.limitNum and 
                -- labPanelTip.stageNum == 0 then

                -- labPanelTip:setVisible(true)
                -- local curSectionId = intanceModel:getCurMainSectionId()
                -- local curSectionNum = tonumber(string.sub(curSectionId, 3 , 5))
                -- labPanelTip:setString(lang("FINISHSTAGEAWARD_6") .. lang("CHAR_DI") .. lang("NUM_" .. curSectionNum) .. lang("CHAR_ZHANG"))
                -- labPanelTip:setPositionX(imgTickBg:getPositionX())
                -- labPanelTip.stageNum = rewardIcon.limitNum
            -- end
        end
    
    end

    local progBar = self:getUI("bg.progPanel" .. sectionNum .. ".progBar")
    local percentNum = curStageNum / maxStageNum * 100
    progBar:setPercent(percentNum)

    local rewardImg = "intanceImage_heroUnlockBtn" .. rewardHeroId .. ".png"
    self._heroUnlockBtn = self:getUI("bg.progPanel" .. sectionNum .. ".heroUnlockBtn")
    self._heroUnlockBtn:loadTextures(rewardImg, rewardImg, "", 1)

    self:registerClickEvent(self._heroUnlockBtn, function()
        print("curStageNum====", curStageNum, maxStageNum)
        if curStageNum ~= maxStageNum then 
            self._viewMgr:showTip("英雄努力吧")
            return
        end

        local lastSectionId = sysMainStory.include[sectionNum]
        local sectionInfo = intanceModel:getSectionInfo(lastSectionId)
        if sectionInfo.sr ~= nil then 
            self._viewMgr:showTip("已领取")
            return
        end
        self:getSectionReward(lastSectionId, rewardHeroId)
    end)

    if curStageNum == maxStageNum then 
        local lastSectionId = sysMainStory.include[sectionNum]
        local sectionInfo = intanceModel:getSectionInfo(lastSectionId)
        if sectionInfo.sr == nil then 
            local anim1 = mcMgr:createViewMC("huodewupindiguang_itemeffectcollection", true)
            anim1:setPosition(self._heroUnlockBtn:getPositionX(), self._heroUnlockBtn:getPositionY())
            self._heroUnlockBtn:getParent():addChild(anim1)
            self._heroUnlockBtn.anim1 = anim1

            local anim2 = mcMgr:createViewMC("mubiaojiangli_carnivaltargetanim", true)
            anim2:setPosition(self._heroUnlockBtn:getPositionX(), self._heroUnlockBtn:getPositionY())
            self._heroUnlockBtn:getParent():addChild(anim2, 11)
            self._heroUnlockBtn.anim2 = anim2
        end
    end


    local labStageProg = self:getUI("bg.labStageProg")
    local newSectionId = tonumber(string.sub(curStageId, 1 , 5))
    local newSectionNum = tonumber(string.sub(curStageId, 3 , 5))
    local newStageNum = 0
    -- 最后一章特殊判断
    if finishSectionId == newSectionId and  curStageInfo.star > 0  then
        newStageNum = tonumber(string.sub(curStageId, 6 , 7))
    else
        newStageNum = tonumber(string.sub(curStageId, 6 , 7)) - 1
    end
    if newStageNum == 0 then 
        local newSectionId = tonumber(string.sub(curStageId, 1 , 5)) - 1
        local newSysMainSection = tab:MainSection(newSectionId)
        local tempStageId = newSysMainSection.includeStage[#newSysMainSection.includeStage] 
        newSectionNum = tonumber(string.sub(tempStageId, 3 , 5))
        newStageNum =  tonumber(string.sub(tempStageId, 6 , 7))
    end

    labStageProg:setString("(" .. newSectionNum .. "-".. newStageNum .. ")")
    labStageProg:setColor(cc.c4b(255, 236, 83,255))
    labStageProg:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)    

end


--[[
--! @function clickTreasureCase
--! @desc 点击进入奖励界面
--! @param  inSectionId 章id
--! @return 
--]]
function IntanceHeroUnlockView:clickTreasureCase(inSectionId, inCurStageNum, inRewardIcon, inShowType)
    local limitNum = inRewardIcon.limitNum
    local intanceModel =  self._modelMgr:getModel("IntanceModel")
    local sectionInfo = intanceModel:getSectionInfo(inSectionId)
    local sysMainSection = tab:MainSection(inSectionId)

    local desc = ""
    local canGet = false

    local viewType 
    if (inCurStageNum < limitNum or sectionInfo.sr == nil) or 
        (inCurStageNum >= limitNum and sectionInfo.sr ~= nil) and inShowType ~= 1 then 
        desc = lang("FINISHSTAGEAWARD_5")
        viewType = 1
    else
        desc = lang("FINISHSTAGEAWARD_5")
        canGet = true
    end
    local newSectionNum = tonumber(string.sub(inSectionId, 3 , 5))
    local result,count = string.gsub(desc, "$num", newSectionNum)
    if count > 0 then 
        desc = result
    end

    local rewards = {}
    for k,v in pairs(sysMainSection.sReward) do
        local tempData = table.deepCopy(v)
        table.insert(rewards, tempData)
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

        end} )
    end

    if inCurStageNum < limitNum and sectionInfo.sr == nil then 
        showGiftGet()
    elseif inCurStageNum >= limitNum and sectionInfo.sr == nil then 
        local param = {sId = inSectionId}
        self._serverMgr:sendMsg("StageServer", "getSectionReward", param, true, {}, function (result)
            if result == nil or result.d == nil then return end
            self:clickTreasureCase(inSectionId, inCurStageNum, inRewardIcon, 1)
            local getIt = cc.Sprite:createWithSpriteFrameName("globalImageUI_activity_getItBlue.png")
            getIt:setPosition(inRewardIcon:getContentSize().width * 0.5 ,inRewardIcon:getContentSize().height * 0.5)
            inRewardIcon:addChild(getIt, 9)
            if inRewardIcon.mc ~= nil then 
                inRewardIcon.mc:removeFromParent()
                inRewardIcon.mc = nil 
            end
        end)
    else
        showGiftGet("已领取")
    end

end

function IntanceHeroUnlockView:getSectionReward(inSectionId, inHeroId)
    local param = {sId = inSectionId}
    self._serverMgr:sendMsg("StageServer", "getSectionReward", param, true, {}, function (result)
        if result == nil or result.d == nil then return end
        if result.reward then
            DialogUtils.showGiftGet(result.reward)
        else
            local heroView = self._viewMgr:createLayer("hero.HeroUnlockView", {heroId = inHeroId, callBack = function() 
            end})
            self:addChild(heroView, 1000)
        end
        if self._heroUnlockBtn.anim1 ~= nil then 
            self._heroUnlockBtn.anim1:removeFromParent()
            self._heroUnlockBtn.anim1 = nil
        end
        if self._heroUnlockBtn.anim2 ~= nil then 
            self._heroUnlockBtn.anim2:removeFromParent()
            self._heroUnlockBtn.anim2 = nil
        end
    end)
end


function IntanceHeroUnlockView:getAsyncRes()
    return  {
        {"asset/ui/hero1.plist", "asset/ui/hero1.png"},
        {"asset/ui/hero.plist", "asset/ui/hero.png"},
    }
end

return IntanceHeroUnlockView