--[[
    Filename:    IntanceEliteView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-11-02 17:44:28
    Description: File description
--]]

local IntanceEliteView = class("IntanceEliteView", BaseView, require("game.view.intance.IntanceBaseView"))

function IntanceEliteView:ctor(inData)
    IntanceEliteView.super.ctor(self)
    self.fixMaxWidth = 1136
    local stepCacheSectionId = false
    IntanceConst.WIDE_REWARD_ITEM_ID = nil
    IntanceConst.WIDE_REWARD_NEED_ITEM_NUM = nil


    if inData ~= nil then
        if inData.sectionId ~= nil then 
            self._curSectionId  = inData.sectionId
        end
        if inData.quickStageId ~= nil then 
            self._quickStageId  = inData.quickStageId
            IntanceConst.QUICK_ENTER_BY_ITEM = true
        end  

        if inData.itemId ~= nil and inData.needItemNum ~= nil then 
            IntanceConst.WIDE_REWARD_ITEM_ID = inData.itemId

            IntanceConst.WIDE_REWARD_NEED_ITEM_NUM = inData.needItemNum
        end

        if inData.superiorType ~= nil then 
            self._curSectionId = nil
            stepCacheSectionId = true
        end 
    end
    if self._curSectionId == nil then 
        local tempSectionId = SystemUtils.loadAccountLocalData(IntanceConst.USE_SELECT_ELITE_SECTION)
        if tempSectionId ~= nil then 
            local intanceEliteModel = self._modelMgr:getModel("IntanceEliteModel")
            local ecSectionId = intanceEliteModel:getData().ecSectionId
            if ecSectionId >= tonumber(tempSectionId) and stepCacheSectionId == false then 
                self._curSectionId = tonumber(tempSectionId)
            end
        end
    end
end

function IntanceEliteView:getAsyncRes()
    return {
        {"asset/ui/intance.plist", "asset/ui/intance.png"},
        {"asset/ui/intance2.plist", "asset/ui/intance2.png"},
        {"asset/ui/intance-HD.plist", "asset/ui/intance-HD.png"},
    }
end

function IntanceEliteView:onTop()
    self._viewMgr:enableScreenWidthBar()
    audioMgr:playMusic("dungeon", true)
end
function IntanceEliteView:onHide( )
    self._viewMgr:disableScreenWidthBar()
end
function IntanceEliteView:onComplete()
    self._viewMgr:enableScreenWidthBar()
end
function IntanceEliteView:onInit()
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("intance.IntanceEliteView")
            UIUtils:reloadLuaFile("intance.IntanceEliteSectionNode")
            UIUtils:reloadLuaFile("intance.IntanceEliteStageInfoView")
            UIUtils:reloadLuaFile("intance.IntanceUtils")
        elseif eventType == "enter" then 

        end
    end)       
    
    self._musicFileName = audioMgr:getMusicFileName()
    audioMgr:playMusic("dungeon", true)
    self:registerClickEventByName("closeBtn", function ()
        IntanceConst.QUICK_ENTER_BY_ITEM = false
        self:close()
    end)

    local sectionName = self:getUI("Image_45.sectionName")
    sectionName:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)

    local backSectionBtn = self:getUI("Panel_55.backSectionBtn")

    local backText = self:getUI("Panel_55.backText")
    backText:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)

    local preSectionBtn = self:getUI("Panel_55.preSectionBtn")

    local preText = self:getUI("Panel_55.preText")
    preText:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
    -- self:registerTouchEventWithLight(backSectionBtn)
    -- self:registerTouchEventWithLight(preSectionBtn)

    self:reflashUI()
end

function IntanceEliteView:onDestroy()
    if self._musicFileName then
        audioMgr:playMusic(self._musicFileName, true)
    end
    self._viewMgr:disableScreenWidthBar()
    IntanceEliteView.super.onDestroy(self)
end

function IntanceEliteView:setCloseCallback(inCallback)
    self._closeCallBack = inCallback
end

function IntanceEliteView:reflashUI()
    local intanceEliteModel = self._modelMgr:getModel("IntanceEliteModel")
    if self._curSectionId == nil then
        self._curSectionId = intanceEliteModel:getCheckCurSectionId()
    end

    local function backFun()
        local curSelectedIndex = tonumber(string.sub(self._curSectionId, 3 , 5))
        local curChaptgerId = tonumber(string.sub(self._curSectionId, 1 , 2))
        local sysMainChapter = tab:MainChapter(curChaptgerId)
        if curSelectedIndex == 1 then
            self._viewMgr:showTip("已无章节可选")
        else
            self:backSection()
        end
    end
    local backSectionBtn = self:getUI("Panel_55.backSectionBtn")
    backSectionBtn:setScaleAnim(false)
    self:registerClickEvent(backSectionBtn, function ()
        backFun()
    end)

    local leftBtn = self:getUI("leftPanel.leftBtn")
    leftBtn:setScaleAnim(false)
    -- self:registerClickEvent(leftBtn, function ()
    --     backFun()
    -- end)

    local function preFun()
        if tab:Setting("G_FINISH_SECTION_HARD").value == self._curSectionId then
            self._viewMgr:showTip("暂未开启")
        else
            self:preSection()
        end
    end
    local preSectionBtn = self:getUI("Panel_55.preSectionBtn")
    preSectionBtn:setScaleAnim(false)
    self:registerClickEvent(preSectionBtn, function ()
        preFun()
    end)

    local rightBtn = self:getUI("rightPanel.rightBtn")
    rightBtn:setScaleAnim(false)
    -- self:registerClickEvent(rightBtn, function ()
    --     preFun()
    -- end)
    print("rightBtn:getPositionX()====", rightBtn:getPositionX())

    self:registerTouchEventWithLight(leftBtn, function ()
        backFun()
    end)
    self:registerTouchEventWithLight(rightBtn, function ()
        preFun()
    end)

    self._intanceEliteSectionNode = require("game.view.intance.IntanceEliteSectionNode").new()
    self._intanceEliteSectionNode:setAnchorPoint(0.5, 0.5)
    self._intanceEliteSectionNode:setParentView(self)
    local offsetX = 0
    if ADOPT_IPHONEX then
        offsetX = -128
    end
    self._intanceEliteSectionNode:setPosition(self._widget:getContentSize().width/2+offsetX, self._widget:getContentSize().height/2)
    self._widget:addChild(self._intanceEliteSectionNode)

    self:onModelReflash()
end

function IntanceEliteView:onAdd()
    self._intanceEliteSectionNode:reflashUI({sectionId = self._curSectionId, 
                                            quickStageId = self._quickStageId, 
                                            callBack = function(inStageId) 
                                                self:showStageInfo(inStageId)  
                                            end})
    self._quickStageId = nil
    -- audioMgr:playSound("cavehead")
end

function IntanceEliteView:onModelReflash()
    self:updateSectionInfo(self._curSectionId)
end

--[[
--! @function backSection
--! @desc 向后一章
--! @param 
--! @return 
--]]
function IntanceEliteView:backSection()
    local intanceEliteModel = self._modelMgr:getModel("IntanceEliteModel")

    local curSelectedIndex = tonumber(string.sub(self._curSectionId, 3 , 5))

    local includeSection = intanceEliteModel:getSysSectionDatas()

    local sysSection = includeSection[curSelectedIndex - 1]

    if sysSection == nil then 
        self._viewMgr:showTip("已到达第一章节")
        return false
    end
    self._curSectionId = sysSection.id

    self:updateSectionInfo(self._curSectionId)

    self._intanceEliteSectionNode:reflashUI({sectionId = self._curSectionId,callBack = function(inStageId) 
                                                    self:showStageInfo(inStageId)  
                                                end})
end

--[[
--! @function backSection
--! @desc 向前一章
--! @param 
--! @return 
--]]
function IntanceEliteView:preSection()

    local intanceEliteModel = self._modelMgr:getModel("IntanceEliteModel")

    local curSelectedIndex = tonumber(string.sub(self._curSectionId, 3 , 5))
    local includeSection = intanceEliteModel:getSysSectionDatas()
    local sysSection = includeSection[curSelectedIndex + 1]

    if sysSection == nil then 
        self._viewMgr:showTip("已到达最大章节")
        return false
    end

        
    local curSysSection = tab:MainSection(self._curSectionId)
    local curSysMainStage = tab:MainStage(curSysSection.includeStage[#curSysSection.includeStage])
    local stageInfo = intanceEliteModel:getStageInfo(curSysMainStage.id)
    if stageInfo.star == 0 then
        self._viewMgr:showTip("需通关本章所有关卡")
        return false
    end
    
    local userInfo = self._modelMgr:getModel("UserModel"):getData()
    if sysSection.level > userInfo.lvl then 
        self._viewMgr:showTip("前往下一章需达到" .. sysSection.level .. "级")
        return false
    end

    local intanceModel = self._modelMgr:getModel("IntanceModel")

    local sysMainStage = tab:MainStage(sysSection.includeStage[1])
    local stageInfo = intanceModel:getStageInfo(sysMainStage.PreId)
    if stageInfo.star == 0 then 
        local sctionId = tonumber(string.sub(sysMainStage.PreId, 1 , 5))
        local sysMainSection = tab:MainSection(sctionId)
        self._viewMgr:showTip("需通关剧情副本" .. lang(sysMainSection.rank))
        return false
    end

    local newSectionId = tonumber(string.sub(intanceEliteModel:getData().curStageId, 1 , 5))
    if newSectionId == tonumber(sysSection.id) and 
        newSectionId > intanceEliteModel:getData().ecSectionId then 
        -- 向服务端传递激活下一章信息
        local param = {sectionId = newSectionId, type = 2}
        self._serverMgr:sendMsg("StageServer", "setSectionId", param, true, {}, function (result)
            if result == nil or result["d"] == nil then
                self._viewMgr:showTip("激活下一章出错")
                return false
            end
            self:gotNextSection(newSectionId)
            -- 新章节开启
            audioMgr:playSound("NewChapter_1")
            local intancenopen = mcMgr:createViewMC("run_intancenopen", false, true)
            intancenopen:setPosition(IntanceConst.MAX_SCREEN_WIDTH/2, IntanceConst.MAX_SCREEN_HEIGHT/2)
            self:addChild(intancenopen, 100000)
        end) 
        return false
    end


    self:gotNextSection(sysSection.id)
end

function IntanceEliteView:gotNextSection(inNewSectionId)
    self._curSectionId = inNewSectionId
    self:updateSectionInfo(self._curSectionId)

    -- -- 新章节开启
    self._intanceEliteSectionNode:reflashUI({sectionId = self._curSectionId,callBack = function(inStageId) 
                                                    self:showStageInfo(inStageId)  
                                                end})
end
--[[
--! @function updateSectionInfo
--! @desc 更新章信息
--! @param  inSectionId 章id
--! @return 
--]]
function IntanceEliteView:updateSectionInfo(inSectionId)
    print("IntanceEliteView:updateSectionInfo================================")
    if IntanceConst.QUICK_ENTER_BY_ITEM == false then 
        SystemUtils.saveAccountLocalData(IntanceConst.USE_SELECT_ELITE_SECTION, tostring(inSectionId))
    end

    -- 更新星星获取数目
    local intanceEliteModel = self._modelMgr:getModel("IntanceEliteModel")

    local tempStarNum = 0
    local section = intanceEliteModel:getData().sectionInfo[tostring(inSectionId)]
    if section ~= nil then 
        tempStarNum = section.num
    else
        section = {}
    end

    local sysMainSection = tab:MainSection(inSectionId)
    local starNumLab = self:getUI("Panel_18.progPanel.starNumLab")
    starNumLab:enableOutline(cc.c4b(73,48,26,255),1)
    starNumLab:setString(tempStarNum .. "/" .. sysMainSection.starNum[#sysMainSection.starNum])

    local sectionName = self:getUI("Image_45.sectionName")
    sectionName:setString(lang(sysMainSection.rank) .. "  " .. lang(sysMainSection.secTitle))

    local tempNum = 0
    local bgPanel = self:getUI("Panel_18.star" .. #sysMainSection.starNum .. "Panel") 
    bgPanel:setVisible(true)

    local numOffset = 0
    if #sysMainSection.starNum == 1 then 
        numOffset = 2
    elseif #sysMainSection.starNum == 2 then 
        numOffset =1
    end

    for k,v in pairs(sysMainSection.starNum) do
        local rewardIcon = self:getUI("Panel_18.star" .. #sysMainSection.starNum .. "Panel.box" ..k.. ".reward" .. k .. "Icon")
        local rewardBtn = self:getUI("Panel_18.star" .. #sysMainSection.starNum .. "Panel.box" ..k.. ".reward" .. k .. "Btn")
        -- 为了效果特殊处理 
        if rewardBtn.cacheSectionId ~= inSectionId then
            rewardBtn.showFullAnim = nil
            rewardBtn.cacheSectionId = inSectionId
        end        
        if rewardBtn.posY == nil then 
            rewardBtn.posY = rewardBtn:getPositionY()
        end
        rewardBtn:stopAllActions()
        rewardBtn:setPosition(rewardBtn:getPositionX(), rewardBtn.posY)
        rewardBtn:setScale(1)
        rewardBtn:removeAllChildren()
        
        if rewardBtn.boxAnim ~= nil then 
            rewardBtn.boxAnim:removeFromParent()
            rewardBtn.boxAnim = nil
        end

        if rewardBtn.boxLight ~= nil then
            rewardBtn.boxLight:removeFromParent()
            rewardBtn.boxLight = nil
        end
        local newStarLab = self:getUI("Panel_18.star" .. #sysMainSection.starNum .. "Panel.box" ..k.. ".needStarBg" .. k .. ".needStarLab")
        newStarLab:enableOutline(cc.c4b(73,48,26,255),2)
        newStarLab:setString("x" .. v)
        self:registerClickEvent(rewardBtn, function() 
            self:clickTreasureCase(inSectionId, k)
        end)
        self:registerClickEvent(rewardIcon, function() 
            self:clickTreasureCase(inSectionId, k, 1)
        end)
        if tonumber(v) <= tempStarNum  and 
            section[tostring(v)] == nil then 
            rewardBtn:setVisible(true)
            rewardIcon:setVisible(false)
            local function rewardBtnAnim()
                print("rewardBtnAnim===================================")
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
                    boxAnim:setName("box_anim" .. k)
                    btnParent:addChild(boxAnim, 3)
                    boxAnim:setCascadeOpacityEnabled(true, true)
                    -- boxAnim:setOpacity(rewardBtn:getOpacity())
                end
                boxAnim:setVisible(true)
                rewardBtn.boxAnim = boxAnim
            end
            -- local action1 = cc.MoveBy:create(0.1, cc.p(0, 2))

            if rewardBtn.showFullAnim == nil then 
                rewardBtn.showFullAnim = true
            end
            if rewardBtn.showFullAnim == false then
                rewardBtn:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.CallFunc:create(function()
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

        tempNum = tempNum + v
    end
    print("tempStarNu============================", tempStarNum)
    local prog = self:getUI("Panel_18.progPanel.prog1") 
    local perProg = tempStarNum / tonumber(sysMainSection.starNum[#sysMainSection.starNum])  * 542
    prog:setContentSize(perProg, prog:getContentSize().height)
    if tempStarNum <= 0 then
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

    local mcTipPanel = self:getUI("Image_45.mcTipPanel")
    local preSectionBtn = self:getUI("Panel_55.preSectionBtn") 
    local btnTip = preSectionBtn:getChildByName("tip")
    local btnTip1 = mcTipPanel:getChildByName("tip1")
    local preRightTitle = self:getUI("Panel_55.preText")
    if preRightTitle.posX == nil then 
        preRightTitle.posX = preRightTitle:getPositionX()
    end

    local rightBtn = self:getUI("rightPanel.rightBtn")
    if rightBtn.posX == nil then 
        rightBtn.posX = rightBtn:getPositionX()
    end
    print("1rightBtn:getPositionX()====", rightBtn:getPositionX())
    -- 各种条件判断，是否出下一章提示
    local flag = true
    local mainsData = intanceEliteModel:getData()
    local newSectionId = tonumber(string.sub(mainsData.curStageId, 1 , 5))
    local sysSection = tab:MainSection(newSectionId)
    -- 章判断
    if mainsData.ecSectionId >= newSectionId then
        flag = false
    end

    -- 等级判断
    local userInfo = self._modelMgr:getModel("UserModel"):getData()
    if sysSection.level > userInfo.lvl then 
        flag = false
    end

    local intanceModel = self._modelMgr:getModel("IntanceModel")
    -- 几颗星判断
    local sysMainStage = tab:MainStage(sysSection.includeStage[1])
    local stageInfo = intanceModel:getStageInfo(sysMainStage.PreId)
    if stageInfo.star == 0 then 
        flag = false
    end

    if flag == false then 
        if btnTip ~= nil then 
            btnTip:removeFromParent()
        end
        if btnTip1 ~= nil then 
            btnTip1:removeFromParent()
        end        
        preRightTitle:stopAllActions()
        preRightTitle:setPositionX(preRightTitle.posX) 

        rightBtn:stopAllActions()
        rightBtn:setPositionX(rightBtn.posX)                
        return false
    end
    if btnTip == nil then 
        btnTip = mcMgr:createViewMC("jingyingfuben_intancejiantou", true)
        btnTip:setPosition(preSectionBtn:getContentSize().width/2, preSectionBtn:getContentSize().height/2)
        btnTip:setName("tip")
        preSectionBtn:addChild(btnTip, -1)

        btnTip1 = mcMgr:createViewMC("c1_guidecircle-HD", true)
        btnTip1:setPosition(mcTipPanel:getContentSize().width * 0.5, mcTipPanel:getContentSize().height * 0.5)
        btnTip1:setName("tip1")
        mcTipPanel:addChild(btnTip1, 1000)       
        -- preRightTitle:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.2, cc.p(3, 0)),cc.MoveBy:create(0.2, cc.p(-3, 0)))))
        -- rightBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.2, cc.p(3, 0)),cc.MoveBy:create(0.2, cc.p(-3, 0)))))
    end
end


--[[
--! @function updateSectionInfo
--! @desc 更新章信息
--! @param  inSectionId 章id
--! @return 
--]]
function IntanceEliteView:showStageInfo(inStageId)
    self._stageInfoView = self:showDialog("intance.IntanceEliteStageInfoView",{stageBaseId = inStageId,
                                                                battleFinishCallback = function(inStageId, inWinType, inFinishWarType, closeView)
                                                                    if closeView ~= true then 
                                                                        self._stageInfoView = nil
                                                                    end
                                                                    if self._stageInfoView  ~= nil and closeView == true then 
                                                                        self:setMaskLayerOpacity(0)
                                                                        self._stageInfoView:setVisible(false)
                                                                        self._stageInfoView:close(false)
                                                                    end
                                                                    self:completeStage(inStageId, inWinType, inFinishWarType)
                                                                end,
                                                                wideFinishCallback = function(inStageId)
                                                                    self._intanceEliteSectionNode:udpateLastNum(inStageId)
                                                                end}
                                                                ,true)
end

--[[
--! @function completeStageActoin
--! @desc 异步加载资源
--! @param  inStageId 副本id
--! @param  inWinType 战斗结果类型 
--! @return 
--]]
function IntanceEliteView:completeStage(inStageId, inWinType, inFinishWarType)
    local intanceEliteModel = self._modelMgr:getModel("IntanceEliteModel")
    local mainsData = intanceEliteModel:getData()
    local stageInfo = intanceEliteModel:getStageInfo(inStageId)
    local sectionId = tonumber(string.sub(inStageId, 1 , 5))
    local newSectionId = tonumber(string.sub(mainsData.curStageId, 1 , 5))
    if inWinType ~= 2 then 
        return
    end
    if sectionId ~= newSectionId and 
        mainsData.ecSectionId < newSectionId and 
        inFinishWarType == IntanceConst.FINISH_WAR_TYPE.FIRST_WAR then
        self._intanceEliteSectionNode:completeStage(inStageId)
        self:updateSectionInfo(sectionId)
        self:confirmEnterNextStection(newSectionId)
    else
        self:updateSectionInfo(sectionId)
        self._intanceEliteSectionNode:completeStage(inStageId)
    end
end



function IntanceEliteView:confirmEnterNextStection(inNewSectionId)
    local bgLayer = ccui.Layout:create()
    bgLayer:setBackGroundColorOpacity(120)
    bgLayer:setBackGroundColorType(1)
    bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
    bgLayer:setTouchEnabled(true)
    bgLayer:setContentSize(IntanceConst.MAX_SCREEN_WIDTH, IntanceConst.MAX_SCREEN_HEIGHT)
    self:addChild(bgLayer, 1000)

    local amin1 = mcMgr:createViewMC("run_nextsection", false, true, function(_, sender)
        bgLayer:removeFromParent()
    end, nil, false)

    amin1:setPosition(IntanceConst.MAX_SCREEN_WIDTH/2, IntanceConst.MAX_SCREEN_HEIGHT/2 + 100)
    bgLayer:addChild(amin1)

end

--[[
--! @function clickTreasureCase
--! @desc 点击进入奖励界面
--! @param  inSectionId 章id
--! @param  inIndex 箱子索引
--! @param  inItemId 物品id
--! @return 
--]]
function IntanceEliteView:clickTreasureCase(inSectionId, inIndex, inShowType)
   local intanceEliteModel = self._modelMgr:getModel("IntanceEliteModel")
    local section = intanceEliteModel:getSectionInfo(inSectionId)

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
    local function showGiftGet(inBtnTitle)
        DialogUtils.showGiftGet( {
        gifts = rewards,
        viewType = viewType,
        canGet = canGet, 
        des = desc,
        title = lang("FINISHSTAGETITLE"),
        btnTitle = inBtnTitle, 
        callback = function()

        end,notPop = not viewType})
    end
    if inShowType ~= 1 then
        if viewType == nil then 
            local param = {type = needStarNum, section = inSectionId}
            self._serverMgr:sendMsg("StageServer", "collectEliteStarReward", param, true, {}, function (result)
                showGiftGet()
                self:onModelReflash()
            end)
        else 
            showGiftGet()
        end
    else
        showGiftGet("已领取")
    end
end


function IntanceEliteView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView", {hideInfo = true, hideBtn = true})
end

return IntanceEliteView
