--[[
    Filename:    TeamLiftingNode.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2015-12-19 19:29:48
    Description: File description
--]]

local TeamLiftingNode = class("TeamLiftingNode", BaseLayer)

function TeamLiftingNode:ctor(param)
    TeamLiftingNode.super.ctor(self)
    self._fightCallback = param.fightCallback
end

function TeamLiftingNode:onInit()
    -- local title1 = self:getUI("bg.vessel.titleBg1.title")
    -- title1:setColor(cc.c3b(255,198,25))
    -- title1:enableOutline(cc.c4b(0,0,0,255), 2)
    -- local title2 = self:getUI("bg.vessel.titleBg2.title")
    -- title2:setColor(cc.c3b(255,198,25))
    -- title2:enableOutline(cc.c4b(0,0,0,255), 2)
    self:animBtn()

    self._teamModel = self._modelMgr:getModel("TeamModel")
    local runeBg = self:getUI("bg.vessel.runeBg")
    -- self._yijianqianghua = mcMgr:createViewMC("yijianqianghua_teamupgrade-HD", true, false, function()
    --     if self._yijianqianghua then
    --         self._yijianqianghua:gotoAndStop(1)
    --     end
    -- end)
    -- self._yijianqianghua:gotoAndStop(1)
    -- self._yijianqianghua:addCallbackAtFrame(12, function()
    --     for i=1,4 do
    --         local imgBg = self:getUI("bg.vessel.runeBg.equipBg" .. i)
    --         local mc1 = mcMgr:createViewMC("zhuangbeiqianghuatexiao_teamupgrade", false, true, function()
    --         end)
    --         mc1:setPosition(imgBg:getContentSize().width*0.5-2, imgBg:getContentSize().height*0.5-2)
    --         imgBg:addChild(mc1)
    --     end
    -- end)
    -- self._yijianqianghua:setPosition(143, 90)
    -- runeBg:addChild(self._yijianqianghua)

    local quickUpdateBtn = self:getUI("bg.vessel.quickUpdateBtn")
    self._yijianAnim = mcMgr:createViewMC("yijianqianghuaanniu_teamupgrade", true, false)
    self._yijianAnim:setPosition(quickUpdateBtn:getContentSize().width*0.5-2, quickUpdateBtn:getContentSize().height*0.5+10)
    quickUpdateBtn:addChild(self._yijianAnim, 100)

    -- 初始化装备图标
    for i=1,4 do
        local imgBg = self:getUI("bg.vessel.runeBg.equipBg" .. i)
        imgBg:setScaleAnim(true)
        imgBg:setAnchorPoint(0.5,0.5)  -- 点击缩放
        imgBg:setPosition(imgBg:getPositionX()+49,imgBg:getPositionY()+50)
    end

end

function TeamLiftingNode:updateGold()
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local goldValue = self:getUI("bg.vessel.goldValue")
    if userData.gold >= tab:TeamQuality(self._curSelectTeam.stage).cost then
        goldValue:setColor(cc.c3b(70,40,0))
        -- goldValue:enableOutline(cc.c4b(93,93,93,255), 1)
    else
        goldValue:setColor(cc.c3b(255,46,46))
        -- goldValue:enableOutline(cc.c4b(60,30,10,255), 1)
    end
end

function TeamLiftingNode:animBtn()
    local updateStageBtn = self:getUI("bg.vessel.updateStageBtn")
    local mc1 = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true, false)
    mc1:setName("anim")
    mc1:setScaleX(1.5)
    mc1:setPosition(updateStageBtn:getContentSize().width*updateStageBtn:getScaleX()*0.5, updateStageBtn:getContentSize().height*updateStageBtn:getScaleY()*0.5)
    updateStageBtn:addChild(mc1, 1)
    mc1:setVisible(false)
end

-- 怪兽进阶
function TeamLiftingNode:reflashUI(data)

    self._clickSign = false
    self._curSelectTeam = data or {}
    self._curSelectSysTeam = tab:Team(self._curSelectTeam.teamId)
    local teamModel = self._modelMgr:getModel("TeamModel")
    local itemModel = self._modelMgr:getModel("ItemModel")
    -- 下一级的品质
    local Label_84_0 = self:getUI("bg.vessel.Label_84_0")
    local Label_84_0_1_0 = self:getUI("bg.vessel.Label_84_0_1_0")
    local tishidi = self:getUI("bg.vessel.tishidi")
    local goldFlag = 1

    local gold = self:getUI("bg.vessel.gold")
    gold:setScale(0.6)
    local goldValue = self:getUI("bg.vessel.goldValue")
    goldValue:setString(tab:TeamQuality(self._curSelectTeam.stage).cost)
    goldValue:setPositionX(gold:getPositionX() + gold:getContentSize().width * gold:getScale() + 10)
    local userData = self._modelMgr:getModel("UserModel"):getData()
    print("userData========", userData.gold, tab:TeamQuality(self._curSelectTeam.stage).cost)
    if userData.gold >= tab:TeamQuality(self._curSelectTeam.stage).cost then
        goldValue:setColor(cc.c3b(70,40,0))
        -- goldValue:enableOutline(cc.c4b(93,93,93,255), 1)
    else
        goldValue:setColor(cc.c3b(255,46,46))
        -- goldValue:enableOutline(cc.c4b(81,19,0,255), 1)
    end
    
    for i=1,4 do
        if self._curSelectTeam["es" .. i] <= self._curSelectTeam.stage then
            goldFlag = 2
        end
    end
    if self._curSelectTeam.stage < tab.setting["G_MAX_TEAMSTAGE"].value then
        local str = lang("TIPS_ADVANCED_" .. self._curSelectTeam.stage)
        Label_84_0:setString(str)
        Label_84_0:setFontSize(16)
        Label_84_0:disableEffect()
        
        local backQuality = teamModel:getTeamQualityByStage(self._curSelectTeam.stage+1)
        Label_84_0:setColor(UIUtils.colorTable["ccColorQuality" .. backQuality[1]])
        Label_84_0:enableOutline(UIUtils.colorTable["ccColorQualityOutLine" .. backQuality[1]], 1)
    else
        goldFlag = 3
    end
    local updateStageBtn = self:getUI("bg.vessel.updateStageBtn")
    local maxStage = self:getUI("bg.vessel.maxstage")
    -- maxStage:setFontName(UIUtils.ttfName)
    if goldFlag == 2 then
        Label_84_0_1_0:setVisible(true)
        tishidi:setVisible(true)
        Label_84_0:setVisible(true)
        gold:setVisible(false)
        goldValue:setVisible(false)
        updateStageBtn:setVisible(true)
        maxStage:setVisible(false)
    elseif goldFlag == 1 then
        --todo
        Label_84_0_1_0:setVisible(false)
        tishidi:setVisible(false)
        Label_84_0:setVisible(false)
        gold:setVisible(true)
        goldValue:setVisible(true)
        updateStageBtn:setVisible(true)
        maxStage:setVisible(false)
    elseif goldFlag == 3 then
        Label_84_0_1_0:setVisible(false)
        tishidi:setVisible(false)
        Label_84_0:setVisible(false)
        gold:setVisible(false)
        goldValue:setVisible(false)
        updateStageBtn:setVisible(false)
        maxStage:setVisible(true)
        maxStage:setString("兵团已达最高阶")
        maxStage:setColor(cc.c3b(117,73,34))
    end

    local runeBg = self:getUI("bg.vessel.runeBg")
    -- 符文
    local teamdata, _ = teamModel:getTeamAndIndexById(self._curSelectTeam.teamId)
    for k,v in pairs(self._curSelectSysTeam.equip) do
        local imgBg = self:getUI("bg.vessel.runeBg.equipBg" .. k)
        local flag = 1
        local sysEquip = tab:Equipment(v)
        local sysMater = sysEquip["mater" .. self._curSelectTeam["es" .. k]]
        -- 所需材料
        if sysMater then
            for k1,mater in pairs(sysMater) do
                -- systemItem = tab:Tool(mater[1])
                local _, tempItemCount = itemModel:getItemsById(mater[1])
                local approatchIsFlag = itemModel:approatchIsOpen(mater[1])
                print("tempItemCount=======", tempItemCount, mater[2])
                if tempItemCount < mater[2] then
                    -- print("材料不够")
                    flag = -1
                    if approatchIsFlag == false then
                        flag = -2
                        break
                    end
                end
            end    
        else
            flag = -3
        end
        local backQuality = teamModel:getTeamQualityByStage(self._curSelectTeam["es" .. k])

        local param = {teamData = self._curSelectTeam, index = k, sysRuneData = sysEquip,isUpdate = flag, quality = backQuality[1], quaAddition = backQuality[2],  eventStyle = 0}


        local iconRune = imgBg:getChildByFullName("runeIcon")
        if iconRune == nil then 
            iconRune = IconUtils:createTeamRuneIconById(param)
            iconRune:setName("runeIcon")
            -- iconRune:setScale(0.92)
            iconRune:setAnchorPoint(0, 0)
            iconRune:setPosition(18,18)
            imgBg:addChild(iconRune)
        else 
            IconUtils:updateTeamRuneIconByView(iconRune, param)
        end

        -- IconUtils:setTeamRuneAction(iconRune)

    -- 装备名称

        -- local sysTeam = tab:Team(self._curSelectTeam.teamId)
        -- -- local teamModel = self._modelMgr:getModel("TeamModel")
        -- local leftSysEquipment = tab:Equipment(sysTeam.equip[k])
        -- local leftEquipStage = tonumber(self._curSelectTeam["es" .. k])
        -- local leftBackQuality = teamModel:getTeamQualityByStage(leftEquipStage)
        -- local nameLab = runeBg:getChildByFullName("equipName" .. k)
        -- if leftBackQuality[2] > 0 then
        --     nameLab:setString(lang(leftSysEquipment.name) .. "+" .. leftBackQuality[2])
        -- else
        --     nameLab:setString(lang(leftSysEquipment.name))
        -- end
        -- nameLab:setColor(UIUtils.colorTable["ccColorQuality" .. leftBackQuality[1]])
        -- nameLab:disableEffect()
        -- -- nameLab:setColor(cc.c3b(28,153,224))
        -- nameLab:setFontSize(18)
        -- nameLab:enableOutline(cc.c4b(0,1,0,255), 1)

        self:registerClickEvent(imgBg, function (sender)
            print("self._teamRuneView-======",self._curSelectTeam, k)
            self._viewMgr:showDialog("team.TeamRuneView",{teamData = self._curSelectTeam, equipId = k, closeCallback = function()
                -- self.viewMgr:unlock()
                -- print("self._teamRuneView-======",self._teamRuneView)
            end}) 
            -- self._teamRuneView = self._viewMgr:showDialog("team.TeamRuneView",{teamData = self._curSelectTeam, equipId = k, closeCallback = function()
            --     self._teamRuneView = nil
            --     -- print("self._teamRuneView-======",self._teamRuneView)
            -- end}) 
        end)
    end

    -- if self._teamRuneView ~= nil then
    --     self._teamRuneView:reflashItemData()
    -- end

    -- local userData = self._modelMgr:getModel("UserModel"):getData()
    
    self:updateStage()
        -- self._oldTeamData = clone(self._curSelectTeam)
        -- local teamModel = self._modelMgr:getModel("TeamModel")
        -- local tempTeam,teampIndex = teamModel:getTeamAndIndexById(self._oldTeamData.teamId)
        -- local tempData = {}
        -- tempData.teamData = tempTeam
        -- tempData.skillIndex = 0 

    local sysEquipmentLevel
    local equipLevelFlag = 3
    local maxEquipLevel = 1
    for i=1,4 do
        local equipLevel = self._curSelectTeam["el" .. i]
        if equipLevel < tab.setting["G_MAX_TEAMLEVEL"].value then
            maxEquipLevel = 2
        end
        if self._curSelectTeam.level > equipLevel then
            equipLevelFlag = 2
            sysEquipmentLevel = tab:EquipmentLevel(equipLevel + 1)
            if (equipLevel + 1) > tab.setting["G_MAX_TEAMLEVEL"].value then
                sysEquipmentLevel = tab:EquipmentLevel(tab.setting["G_MAX_TEAMLEVEL"].value)
            end
            if userData.gold >= sysEquipmentLevel.cost then
                equipLevelFlag = 1
                break
            end
        end
    end

    local quickUpdateBtn = self:getUI("bg.vessel.quickUpdateBtn")
    quickUpdateBtn:setVisible(true)
    if maxEquipLevel == 2 and equipLevelFlag == 1 then
        self._yijianAnim:setVisible(true)
        self:registerClickEvent(quickUpdateBtn, function()
            self:autoUpgradeEquip()
        end)
    elseif maxEquipLevel == 2 and equipLevelFlag == 2 then
        self._yijianAnim:setVisible(false)
        self:registerClickEvent(quickUpdateBtn, function()
            DialogUtils.showLackRes()
        end)
    elseif maxEquipLevel == 2 and equipLevelFlag == 3 then
        self._yijianAnim:setVisible(false)
        -- quickUpdateBtn:setVisible(false)
        self:registerClickEvent(quickUpdateBtn, function()
            self._viewMgr:showTip(lang("TIPS_BINGTUAN_14"))
        end)
    elseif maxEquipLevel == 1 then
        self._yijianAnim:setVisible(false)
        quickUpdateBtn:setVisible(false)
    end

end

function TeamLiftingNode:autoUpgradeEquip()
    local param = {teamId = self._curSelectTeam.teamId}
    self._oldTeamData = clone(self._curSelectTeam)
    self._oldFight = TeamUtils:updateFightNum()
    self._serverMgr:sendMsg("TeamServer", "batchUpgradeEquip", param, true, {}, function (result)
        if self.upgradeEquipFinish then
            self:upgradeEquipFinish(result)
        end
    end)
end


-- --[[
-- --! @function upgradeEquip
-- --! @desc 装备升级
-- --! @param 
-- --! @return 
-- --]]
-- function TeamLiftingNode:upgradeEquip(inIsAuto)
--     local param = {teamId = self._curSelectTeam.teamId, positionId = self._curSelectIndex, auto = inIsAuto}
--     self._serverMgr:sendMsg("TeamServer", "upgradeEquip", param, true, {}, function (result)
--         -- self:reflashUI()
--         self:upgradeEquipFinish(result)
--     end)
-- end

function TeamLiftingNode:upgradeEquipFinish(inResult)
    if inResult["d"] == nil then 
        self._viewMgr:showTip("升级失败")
        return
    end
    audioMgr:playSound("Forge")
    -- local teamModel = self._modelMgr:getModel("TeamModel")
    local tempTeam,_ = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(self._curSelectTeam.teamId)
    self._fightCallback({newFight = tempTeam.score, oldFight = self._oldTeamData.score})
    -- self:reflashItemData()

    local fightBg = self:getUI("bg")
    TeamUtils:setFightAnim(fightBg, {oldFight = self._oldFight, newFight = TeamUtils:updateFightNum(), x = -200, y = fightBg:getContentSize().height - 110})
    
    -- local runeBg = self:getUI("bg.vessel.runeBg")
    -- self._yijianqianghua:play()

    for i=1,4 do
        local imgBg = self:getUI("bg.vessel.runeBg.equipBg" .. i)
        local mc1 = mcMgr:createViewMC("zhuangbeiqianghuatexiao_teamupgrade", false, true, function()
        end)
        mc1:setPosition(imgBg:getContentSize().width*0.5-4, imgBg:getContentSize().height*0.5-4)
        imgBg:addChild(mc1)
    end

    -- self._viewMgr:showTip("升级成功")

    -- self._curSelectIndex = inData.equipId
    -- self._curSelectTeam = inData.teamData

    -- local tempTeamData,tempTeamIndex = teamModel:getTeamAndIndexById(self._curSelectTeam.teamId)
    -- local tempData = {}
    -- tempData.teamData = tempTeamData
    -- tempData.equipId = self._curSelectIndex
    -- self:reflashUI(tempData)
    -- for i=1,4 do
    --     local equipLevel = self._curSelectTeam["el" .. i] - self._oldTeamData["el" .. i]
    --     if equipLevel > 0 then
    --         local imgBg = self:getUI("bg.vessel.runeBg.equipBg" .. i)
    --         local mc1 = mcMgr:createViewMC("qianghua_teamskillanim", false, true)
    --         mc1:setScale(0.8)
    --         mc1:setPosition(73, 50)
    --         imgBg:addChild(mc1, 5)
    --     end
    -- end
end

-- 进阶
function TeamLiftingNode:updateStage()
    --进阶
    local data = self._curSelectTeam
    local sysTeam = tab:Team(data.teamId)
    local flag = 1
    for k,v in pairs(sysTeam.equip) do
        if tonumber(data["es" .. k]) <= data.stage then
            flag = 0
        end
    end
    -- baseInfoBg:getChildByFullName("updateStageBtn")
    -- local tip1Lab = baseInfoBg:getChildByFullName("Label_107")
    -- local tip2Lab = baseInfoBg:getChildByFullName("stageTipLab")
    -- local updateStageBtn = self:getUI("bg.vessel.updateStageBtn")
    -- updateStageBtn:setVisible(true)
    -- local updateStageBtn = self:getUI("bg.vessel.updateStageBtn")
    local anim = self:getUI("bg.vessel.updateStageBtn"):getChildByName("anim")
    if data.stage >= tab.setting["G_MAX_TEAMSTAGE"].value or flag == 0 then 
        anim:setVisible(false)
        local teamModel = self._modelMgr:getModel("TeamModel")
        local backQuality = teamModel:getTeamQualityByStage(data.stage)
        -- tip2Lab:setString(lang("TIPS_ADVANCED_" .. (data.stage + 1)))
        -- tip2Lab:setColor(UIUtils.colorTable["ccColorQuality" .. backQuality[1]])
        -- tip2Lab:setVisible(true)
        -- tip1Lab:setVisible(true)
        -- self:registerClickEvent(updateStageBtn, function (sender)
        if data.stage >= tab.setting["G_MAX_TEAMSTAGE"].value then
            
            -- updateStageBtn:setVisible(false)
            self:registerClickEventByName("bg.vessel.updateStageBtn", function()
                self._viewMgr:showTip(lang("TIPS_BINGTUAN_08"))
            end)
        else
            self:registerClickEventByName("bg.vessel.updateStageBtn", function()
                self._viewMgr:showTip(lang("TIPS_BINGTUAN_01") .. (lang("TIPS_ADVANCED_" .. self._curSelectTeam.stage) or ""))
            end)
        end
        -- end)
    else
        -- tip1Lab:setVisible(false)
        -- tip2Lab:setVisible(false)
        local userModel = self._modelMgr:getModel("UserModel"):getData()
        -- self:registerClickEventByName("bg.vessel.updateStageBtn", function (sender)
        if userModel.gold < tab:TeamQuality(self._curSelectTeam.stage).cost then
            anim:setVisible(false)
            self:registerClickEventByName("bg.vessel.updateStageBtn", function()
                DialogUtils.showLackRes( {goalType = "gold"})
            end)
            
        else
            
            anim:setVisible(true)
            -- print("=======兵团进阶")
            self:registerClickEventByName("bg.vessel.updateStageBtn", function()
                self:upgradeStageTeam()
            end)
        end
        -- end)
        -- print("======================",tab:TeamQuality(self._curSelectTeam.stage).cost)
    end
end


function TeamLiftingNode:upgradeStageTeam()
    self._oldTeamData = clone(self._curSelectTeam) --copyTab(self._curSelectTeam)
    local param = {teamId = self._curSelectTeam.teamId}
    local oldTeamStage = self._modelMgr:getModel("TeamModel"):isTeamStageHave(3)
    local oldTeamAwaking = self._modelMgr:getModel("TeamModel"):isTeamStageHave(10)
    self._oldFight = TeamUtils:updateFightNum()
    self._serverMgr:sendMsg("TeamServer", "upgradeStageTeam", param, true, {}, function (result)
        print("进阶")
        local newTeamStage = self._modelMgr:getModel("TeamModel"):isTeamStageHave(3)
        if oldTeamStage == false and newTeamStage == true then
            print("有了新的品阶")
            self._guideOpen = true
        end
        local newTeamAwaking = self._modelMgr:getModel("TeamModel"):isTeamStageHave(10)
        local tempTeam,teampIndex = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(self._oldTeamData.teamId)
        if newTeamAwaking == true and tempTeam.stage >= 10 then
            print("兵团觉醒")
            -- local teamTab = tab:Team(self._curSelectTeam.teamId)
            local tflag = self._teamModel:getAwakingOpen(self._curSelectTeam.teamId)
            if tflag == true then
                self._guideOpen = true
            end
        end
        self:upgradeStageTeamFinish(result)
    end)
end

-- 进阶完成
function TeamLiftingNode:upgradeStageTeamFinish(inResult)
    if inResult["d"] == nil then 
        self._viewMgr:showTip("怪兽进阶失败")
        return 
    end
    audioMgr:playSound("TeamAd")
    local teamModel = self._modelMgr:getModel("TeamModel")
    local tempTeam,teampIndex = teamModel:getTeamAndIndexById(self._oldTeamData.teamId)
    local flag = 0

    local fightBg = self:getUI("bg")
    TeamUtils:setFightAnim(fightBg, {oldFight = self._oldFight, newFight = TeamUtils:updateFightNum(), x = -200, y = fightBg:getContentSize().height - 110})

    -- 如果老数据和新数据技能不符合说明激活新技能
    -- self._fightCallback({newFight = tempTeam.score, oldFight = self._oldTeamData.score})
    for i=1, 5 do
        if i == 5 then
            local quality1 = self._teamModel:getTeamQualityByStage(self._oldTeamData["stage"]) 
            local quality2 = self._teamModel:getTeamQualityByStage(tempTeam["stage"])
            if quality1[1] ~= quality2[1] and quality2[1] == 6 then
                flag = 5   --by wangyan 红色解锁新特技的时候，用通用技能id 6900050
            end
        else
            if tonumber(self._oldTeamData["sl" .. i]) ~= tonumber(tempTeam["sl" .. i]) then
                flag = i
            end
        end
    end
    local tempData = {}
    tempData.teamData = tempTeam
    tempData.skillIndex = flag 
    tempData.oldTeamData = self._oldTeamData
    if self._guideOpen == true then
        tempData.callback = function()
            print("=======引导")
            GuideUtils.checkTriggerByType("action", "1")
            GuideUtils.checkTriggerByType("action", "16")
        end
        self._guideOpen = false
    end

    self._viewMgr:showDialog("team.TeamUpStageSuccessView", tempData, true) 
end

return TeamLiftingNode