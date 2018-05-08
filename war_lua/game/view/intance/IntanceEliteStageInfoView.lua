--[[
    Filename:    IntanceEliteStageInfoView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-11-03 18:23:28
    Description: File description
--]]


local IntanceEliteStageInfoView = class("IntanceEliteStageInfoView", BasePopView)

function IntanceEliteStageInfoView:ctor()
    IntanceEliteStageInfoView.super.ctor(self)
end



function IntanceEliteStageInfoView:onInit()
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("intance.IntanceEliteStageInfoView")
        elseif eventType == "enter" then 

        end
    end)   

    self:registerClickEventByName("closeBtn", function ()
        self:close()
    end)
    if ADOPT_IPHONEX then
        local closeBtn = self:getUI("closeBtn")
        local parameter = closeBtn:getLayoutParameter()
        parameter:setMargin({left=0,top=0,right=125,bottom=0})
        closeBtn:setLayoutParameter(parameter)
    end

    local battleBtn = self:getUI("bg.battleBtn")

    local amin1 = mcMgr:createViewMC("zhandouguangxiao_battlebtn", true)
    amin1:setPosition(battleBtn:getContentSize().width/2, battleBtn:getContentSize().height/2) 
    battleBtn:addChild(amin1)   

    local Image_30 = self:getUI("bg.battleBtn.Image_30")
    local amin2 = mcMgr:createViewMC("zhandousaoguang_battlebtn", true)
    amin2:setPosition(Image_30:getContentSize().width/2, Image_30:getContentSize().height/2)
    Image_30:addChild(amin2)

    self:registerClickEvent(battleBtn, function ()
        self:clickEnterBtn()
    end)
    self:registerClickEventByName("bg.sweepMBtn", function ()
        self:wideEnterMBtn()
    end)

    self:registerClickEventByName("bg.sweepBtn", function ()
        self:wideEnterBtn(1)
    end)

    self:registerClickEventByName("bg.recordPanel.recordBtn", function ()
        self._battleResult = {}
        self:showReport(self._curStageBaseId, 2, function()
            self:showReport(self._curStageBaseId, 1, function()
                self._viewMgr:showDialog("intance.IntanceRecordView", {
                  stageId = self._curStageBaseId,
                  battleResult = self._battleResult,
                  callback = function()
                    end
                  })
            end)
        end) 
    end)

    local tipLab1 = self:getUI("bg.label")
    tipLab1:setFontName(UIUtils.ttfName)
    tipLab1:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    local tipLab2 = self:getUI("bg.Label_39")
    tipLab2:setFontName(UIUtils.ttfName)
    tipLab2:setColor(UIUtils.colorTable.ccUIBaseTextColor2)    


    local tipLab3 = self:getUI("bg.Label_97")
    tipLab3:setFontName(UIUtils.ttfName)
    tipLab3:setColor(UIUtils.colorTable.ccUIBaseTextColor2) 

    local tipLab4 = self:getUI("bg.tmpLab01")
    tipLab4:setFontName(UIUtils.ttfName)
    tipLab4:setColor(UIUtils.colorTable.ccUIBaseTextColor2) 
    
    local tipLab5 = self:getUI("bg.Label_136")
    tipLab5:setFontName(UIUtils.ttfName)
    tipLab5:setColor(UIUtils.colorTable.ccUIBaseTextColor2)   

    local titleLab = self:getUI("bg.infoBg.titleLab")
    titleLab:setFontName(UIUtils.ttfName)
    titleLab:setColor(cc.c4b(255, 255, 255, 255))
    titleLab:enableOutline(cc.c4b(60,30,10,255),2)



    local tili = self:getUI("bg.Image_26_0")
    local scaleNum1 = math.floor((26/tili:getContentSize().width)*100)
    tili:setScale(scaleNum1/100)

    local tili1 = self:getUI("bg.Image_26_0_0")
    local scaleNum1 = math.floor((26/tili:getContentSize().width)*100)
    tili1:setScale(scaleNum1/100)

    local leftArrowBtn1 = self:getUI("bg.leftArrowBtn.leftArrowBtn1")
    local x, y = leftArrowBtn1:getPosition()
    local action1 = cc.MoveTo:create(0.3, cc.p(x + 2, y))
    local action2 = cc.MoveTo:create(0.3, cc.p(x, y))
    leftArrowBtn1:runAction(cc.RepeatForever:create(cc.Sequence:create(action1, action2)))


    local rightArrowBtn1 = self:getUI("bg.rightArrowBtn.rightArrowBtn1")

    local x, y = rightArrowBtn1:getPosition()
    local action1 = cc.MoveTo:create(0.3, cc.p(x + 2, y))
    local action2 = cc.MoveTo:create(0.3, cc.p(x, y))
    rightArrowBtn1:runAction(cc.RepeatForever:create(cc.Sequence:create(action1, action2)))

    self:listenReflash("UserModel", self.updateAboutStage) 
end

function IntanceEliteStageInfoView:onShow()
    local sysStage = tab:MainStage(tonumber(self._curStageBaseId))

    local showBg = self:getUI("bg.Panel_126")
    
    local sysTeam = tab:Team(sysStage.monsterRes)

    local x = sysTeam.elite[1]
    local y = sysTeam.elite[2] 
    local scale = sysTeam.elite[3]
    local flip = sysTeam.elite[4]
    local strArt = sysTeam["art1"]
    local result, count = string.gsub(strArt, "ti_", "t_")
    if count > 0 then 
        strArt = result
    end
    if self._mosterRes == nil then
        self._mosterRes = cc.Sprite:create("asset/uiother/team/".. strArt ..".png")
        showBg:addChild(self._mosterRes, 2)
    else
        self._mosterRes:setTexture("asset/uiother/team/".. strArt ..".png")
    end
    self._mosterRes:setAnchorPoint(0, 0)
    self._mosterRes:setPosition(-self._mosterRes:getContentSize().width, y)
    self._mosterRes:setScale(scale)
    self._mosterRes:setOpacity(255)
    if flip == 1 then 
        self._mosterRes:setFlipX(true)
    else
        self._mosterRes:setFlipX(false)
    end
    
    self._mosterRes:setColor(cc.c4b(0, 0, 0, 255))


    if self._mosterRes1 == nil then 
        self._mosterRes1 = cc.Sprite:create("asset/uiother/team/".. strArt ..".png")
        showBg:addChild(self._mosterRes1)
    else
        self._mosterRes1:setTexture("asset/uiother/team/".. strArt ..".png")
    end
    self._mosterRes1:setOpacity(255)
    self._mosterRes1:setAnchorPoint(0, 0)
    self._mosterRes1:setPosition(x, y)
    self._mosterRes1:setScale(scale)
    if flip == 1 then 
        self._mosterRes1:setFlipX(true)
    else
        self._mosterRes1:setFlipX(false)
    end
    
    self._mosterRes1:setVisible(false)
    ScheduleMgr:delayCall(0, self, function()
        self._mosterRes:runAction(cc.Sequence:create(
                                cc.MoveTo:create(0.1, cc.p(x, y)), 
                                cc.CallFunc:create(function()
                                    self._mosterRes1:setVisible(true)
                                end),
                                cc.FadeOut:create(0.2)
                                -- cc.RemoveSelf:create(true)
                            ))
    end)
end

function IntanceEliteStageInfoView:onOut(callback)
    if self._mosterRes == nil then 
        callback()
        return
    end
    self._mosterRes:setOpacity(255)
    self._mosterRes1:setOpacity(255)

    self._mosterRes1:setVisible(false)
    self._mosterRes:runAction(cc.Sequence:create(
                            cc.MoveTo:create(0.1, cc.p(-self._mosterRes:getContentSize().width, self._mosterRes1:getPositionY())), 
                            cc.FadeOut:create(0.2),
                            cc.CallFunc:create(function()
                                callback()
                            end)
                        ))
end

function IntanceEliteStageInfoView:reflashUI(data)
    self._curStageBaseId = data.stageBaseId
    self._battleFinishCallback = data.battleFinishCallback
    self._wideFinishCallback = data.wideFinishCallback

    self._curSelectedIndex = tonumber(string.sub(self._curStageBaseId, string.len(self._curStageBaseId) -1 , string.len(self._curStageBaseId)))
    self._curSectionId = tonumber(string.sub(self._curStageBaseId, 1, string.len(self._curStageBaseId) -2))
    self._curSysSection = tab:MainSection(self._curSectionId)

    local intanceEliteModel = self._modelMgr:getModel("IntanceEliteModel")
    local mainsData = intanceEliteModel:getData()

    local isFirst = false
    local curStageInfo = intanceEliteModel:getStageInfo(self._curStageBaseId)
    if curStageInfo.star == 0 then 
        isFirst = true
        self._finishWarType = IntanceConst.FINISH_WAR_TYPE.FIRST_WAR
    elseif curStageInfo.star == 3 then
        self._finishWarType = IntanceConst.FINISH_WAR_TYPE.FULL_STAR
    else
        self._finishWarType = IntanceConst.FINISH_WAR_TYPE.OTHER
    end

    local sysStage = tab:MainStage(tonumber(self._curStageBaseId))

    
    local recordPanel = self:getUI("bg.recordPanel")
    if sysStage.record == 1 then
        recordPanel:setVisible(true)
    else
        recordPanel:setVisible(false)
    end

    local titleLab = self:getUI("bg.infoBg.titleLab")
    titleLab:setString(lang(sysStage.title))

    local descLab = self:getUI("bg.infoBg.descLab")
    descLab:setString(lang(sysStage.describe))

    local descLabAuthor = self:getUI("bg.infoBg.descLabAuthor")
    descLabAuthor:setFontSize(24)
    descLabAuthor:setString(lang(sysStage.describeBy))

    -- 觉醒活动
    local AwakingModel = self._modelMgr:getModel("AwakingModel")
    local warkingReward = AwakingModel:getAwakingTaskDungeonReward(self._curStageBaseId)
    if warkingReward ~= nil then 
        sysStage = clone(sysStage)
        sysStage["dropItem0"] = warkingReward[2]
    end

    -- 更新奖励
    IntanceUtils:updateDropNode(self:getUI("bg.dropNode"), sysStage, isFirst)


    self:updateAboutStage()

    self:updateSwitchStageBtnState()
end

function IntanceEliteStageInfoView:updateSwitchStageBtnState(inCallback)
    local intanceEliteModel = self._modelMgr:getModel("IntanceEliteModel")
    local mainsData = intanceEliteModel:getData()

    local leftArrowBtn = self:getUI("bg.leftArrowBtn")
    leftArrowBtn:setVisible(false)


 
    local rightArrowBtn = self:getUI("bg.rightArrowBtn")
    rightArrowBtn:setVisible(false)

    
    if self._curSelectedIndex > 1 then 
        leftArrowBtn:setVisible(true)
    end

    if self._curSelectedIndex < #self._curSysSection.includeStage and 
        mainsData.curStageId > self._curStageBaseId then
        rightArrowBtn:setVisible(true)
    end

    local goNextStage = function(inSelectedIndex)
        local stageId = self._curSysSection.includeStage[inSelectedIndex]
        local data = {}
        data.stageBaseId = stageId
        data.battleFinishCallback = self._battleFinishCallback
        data.wideFinishCallback = self._wideFinishCallback
        self._viewMgr:lock(-1)
        self:onOut(function()
            self._viewMgr:unlock()
            self:reflashUI(data)
            self:onShow()
        end)

        
    end
    self:registerClickEvent(leftArrowBtn, function()
        local selectedIndex = self._curSelectedIndex - 1
        goNextStage(selectedIndex)
    end)

    self:registerClickEvent(rightArrowBtn, function()
        local selectedIndex = self._curSelectedIndex + 1
        goNextStage(selectedIndex)
    end)
    
end

function IntanceEliteStageInfoView:setHideCallback(inCallback)
    self._hideCallback = inCallback
end


--[[
--! @function updateAboutStage
--! @desc  更新关卡星星
--! @param inCurStageLevel int (难度1，2，3)
--! @return 
--]]

function IntanceEliteStageInfoView:updateAboutStage()
    -- 更新当前界面
    local intanceEliteModel = self._modelMgr:getModel("IntanceEliteModel")

    local stage = intanceEliteModel:getStageInfo(self._curStageBaseId)


    local sysStage = tab:MainStage(tonumber(self._curStageBaseId))
 
    local userModel = self._modelMgr:getModel("UserModel")
    local residuePowerLab = self:getUI("bg.residuePowerLab")
    residuePowerLab:setString(userModel:getData().physcal)
    residuePowerLab:setColor(UIUtils.colorTable.ccUIBaseColor2)
    residuePowerLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    local powerLab = self:getUI("bg.powerLab")
    powerLab:setColor(UIUtils.colorTable.ccUIBaseColor2)
    powerLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    powerLab:setString(sysStage.costPhysical)

    local tmpLab01 = self:getUI("bg.tmpLab01")
    tmpLab01:setPosition(residuePowerLab:getPositionX() + residuePowerLab:getContentSize().width, tmpLab01:getPositionY())

    local privileges = self._modelMgr:getModel("PrivilegesModel"):getPeerageEffect(PrivilegeUtils.peerage_ID.JingYingCiShu) or 0

    local activityModel = self._modelMgr:getModel("ActivityModel") 
    -- 活动折扣
    local discount = self._modelMgr:getModel("ActivityModel"):getAbilityEffect(activityModel.PrivilegIDs.PrivilegID_2) or 0

    local lastNum = (sysStage.num + privileges + discount) - stage.num
    if lastNum < 0 then 
        lastNum = 0
    end
    local rollNumLab = self:getUI("bg.numLab")
    rollNumLab:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    rollNumLab:setString(lastNum)

    local maxNumLab = self:getUI("bg.maxNumLab") 
    maxNumLab:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    maxNumLab:setString("/" .. sysStage.num + privileges)

    for i=1,3 do
        local startIcon = self:getUI("bg.infoBg.star" .. i)
        if stage.star >= i then
            startIcon:setVisible(true)
        else
            startIcon:setVisible(false)
        end
    end


    local sweepBtn = self:getUI("bg.sweepBtn")
    local sweepMBtn = self:getUI("bg.sweepMBtn")
    local battleBtn = self:getUI("bg.battleBtn")

    local bg = self:getUI("bg")
    if stage.star <= 0 then 
        sweepMBtn:setVisible(false)
        sweepBtn:setVisible(false)
        battleBtn:setPositionX(sweepBtn:getPositionX() + 65)
    else
        sweepMBtn:setVisible(true)
        sweepBtn:setVisible(true)
        battleBtn:setPositionX(sweepBtn:getPositionX() + 155)
    end
end


--[[
--! @function wideEnterMBtn
--! @desc 多次扫荡
--]]
function IntanceEliteStageInfoView:wideEnterMBtn()
    local intanceEliteModel = self._modelMgr:getModel("IntanceEliteModel")
    local stage = intanceEliteModel:getStageInfo(self._curStageBaseId)
    local sysStage = tab:MainStage(tonumber(self._curStageBaseId))
    local privileges = self._modelMgr:getModel("PrivilegesModel"):getPeerageEffect(PrivilegeUtils.peerage_ID.JingYingCiShu) or 0

    local activityModel = self._modelMgr:getModel("ActivityModel") 
    -- 活动折扣
    local discount = self._modelMgr:getModel("ActivityModel"):getAbilityEffect(activityModel.PrivilegIDs.PrivilegID_2) or 0


    local subNum = (sysStage.num + privileges + discount) - stage.num
    if subNum <= 0 then 
        subNum = 1
    end
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local canDoTime = math.floor((userData.physcal / sysStage.costPhysical))
    if canDoTime < subNum then 
        subNum = canDoTime
    end
    if subNum <= 0 then 
        subNum = 1 
    end
    self:wideEnterBtn(subNum, true)
end


--[[
--! @function wideEnterBtn
--! @desc 扫荡
--! @param inTime int 次数
--]]
function IntanceEliteStageInfoView:wideEnterBtn(inTime, isMulti)
    local userModel = self._modelMgr:getModel("UserModel")
    if self._oldUserLevel == nil then 
        self._oldUserLevel = userModel:getData().lvl
    end
    -- 多次扫荡等级限制
    local limitLevel = tonumber(tab.systemOpen["Sweepdown"][1])
    if self._oldUserLevel < limitLevel then 
        local desc = lang("SAODANG_BEGIN")
        local result, count = string.gsub(desc, "$num", tab:Setting("G_SAODANG_BEGINS_LEVEL").value)
        if count > 0  then 
            desc = result
        end
        self._viewMgr:showTip(desc)
        return
    end
    -- 多次扫荡vip限制
    if inTime > 1 or isMulti == true then 
        local vipInfo = self._modelMgr:getModel("VipModel"):getData()
        local sysVip = tab:Vip(vipInfo.level)
        if sysVip.sweepTimes == 0 then
            local desc = lang("SAODANGS_BEGIN")
            local result, count = string.gsub(desc, "$num", tab:Setting("G_SAODANGS_BEGINS_LEVEL").value)
            if count > 0  then 
                desc = result
            end
            self._viewMgr:showTip(desc)
            return
        end
    end
    
    local intanceEliteModel = self._modelMgr:getModel("IntanceEliteModel")
    local curStageInfo = intanceEliteModel:getStageInfo(self._curStageBaseId)
    if curStageInfo.star < 1 then 
        self._viewMgr:showTip("三星通关可以扫荡")
        return
    end

    if self:checkBattle(inTime, true) == false then 
        return
    end

    local oldUserPrePhysic = userModel:getData().physcal

    local param = {id = self._curStageBaseId,num = inTime}
    self._serverMgr:sendMsg("StageServer", "sweepEliteStage", param, true, {}, function (result)
        if result == nil or result["rewards"] == nil then 
            return
        end
        -- 更新当前界面
        self:updateAboutStage()

        local mainStage = tab:MainStage(tonumber(self._curStageBaseId))
        
        -- -- 根据服务器返回数据进行重组
        local tmpRewards = IntanceUtils:handleWideReward(result["rewards"], result["tRewards"])

        local newUserData = userModel:getData()
        local isAutoClose = false
        if self._oldUserLevel < newUserData.lvl then 
            isAutoClose =  true
        end
        local function userUpdate()
            self._intanceWideRewardView = nil
            if self._oldUserLevel == nil or newUserData.lvl == nil then
                return
            end
            if self._oldUserLevel < newUserData.lvl then
                local tempOldUserLevel = self._oldUserLevel
                oldUserPrePhysic = oldUserPrePhysic - (mainStage.costPhysical * inTime)
                self._viewMgr:checkLevelUpReturnMain(newUserData.lvl)
                ViewManager:getInstance():showDialog("global.DialogUserLevelUp",{preLevel = tempOldUserLevel,level = newUserData.lvl,prePhysic = oldUserPrePhysic,physic = newUserData.physcal}, nil, nil, nil, false)
                self._oldUserLevel = nil
            end
        end
        local data = {type = 2, reward = tmpRewards, autoClose = isAutoClose, callback = userUpdate, againCallback = function()
                if inTime > 1 then 
                    self:wideEnterMBtn()
                else
                    self:wideEnterBtn(inTime)
                end
             end}
        if self._intanceWideRewardView ~= nil then 
            self._intanceWideRewardView:reflashUI(data)
        else
            self._intanceWideRewardView = self._viewMgr:showDialog("intance.IntanceWideRewardView",data,true)
        end
        if self._wideFinishCallback ~= nil then 
            self._wideFinishCallback(self._curStageBaseId)
        end
    end)
end




--[[
--! @function checkBattle
--! @desc 检查战斗条件
--! @param inTime int 战斗次数
--! @param isCheckItem bool 是否检查扫荡卷
--! @return bool
--]]
function IntanceEliteStageInfoView:checkBattle(inTime,isCheckItem)
    local intanceEliteModel = self._modelMgr:getModel("IntanceEliteModel")
    -- local mainsData = intanceEliteModel:getData()
    local stage = intanceEliteModel:getStageInfo(self._curStageBaseId)
    local sysStage = tab:MainStage(tonumber(self._curStageBaseId))

    local privileges = self._modelMgr:getModel("PrivilegesModel"):getPeerageEffect(PrivilegeUtils.peerage_ID.JingYingCiShu) or 0

    local activityModel = self._modelMgr:getModel("ActivityModel") 
    -- 活动折扣
    local discount = self._modelMgr:getModel("ActivityModel"):getAbilityEffect(activityModel.PrivilegIDs.PrivilegID_2) or 0


    local maxGetNum = sysStage.num + privileges + discount


    if (stage.num + inTime) > maxGetNum then
        local vipInfo = self._modelMgr:getModel("VipModel"):getData()
        local sysVip = tab:Vip(vipInfo.level)
        if sysVip == nil or vipInfo.level == 0 then 
            DialogUtils.showNeedCharge({desc = lang("BUY_VIPRESET"),callback1 = function( )
                local viewMgr = ViewManager:getInstance()
                viewMgr:showView("vip.VipView", {viewType = 0})
            end})
            return false 
        end

        local limitVipLevel, limitVipTimes = self._modelMgr:getModel("VipModel"):getSysVipMaxLimitByField("sectionReset")
        if vipInfo.level >= limitVipLevel and 
            sysVip.sectionReset == stage.rNum then
            self._viewMgr:showTip("已达到当日挑战次数上限")
            return false
        end

        -- vip等级与次数判断
        local sysReflashCost = tab:ReflashCost(stage.rNum + 1)
        local player = self._modelMgr:getModel("UserModel"):getData()
        if (sysReflashCost ~= nil and player.gem < sysReflashCost.resetElite) or 
            sysVip.sectionReset == stage.rNum  then
            local desc = ""
            -- 钻石不足
            if player.gem < sysReflashCost.resetElite then 
                desc = lang("TIP_GLOBAL_LACK_GEM")
            else
                desc = lang("BUY_VIPRESET")
            end
            DialogUtils.showNeedCharge({desc = desc,callback1 = function( )
                print("充值去！")
                local viewMgr = ViewManager:getInstance()
                viewMgr:showView("vip.VipView", {viewType = 0})
            end})           
            return false
        end
        -- 挑战次数已经达到上限提示
        local desc = lang("BUY_RESET")
        -- 今日已购买x次
        local result, count1 = string.gsub(desc, "$num1", stage.rNum)
        if count1 > 0 then 
            desc = result
        end
    
        local activityModel = self._modelMgr:getModel("ActivityModel") 
        -- 活动折扣
        local discount =    self._modelMgr:getModel("ActivityModel"):getAbilityEffect(activityModel.PrivilegIDs.PrivilegID_3) or 0
        local resetElite = sysReflashCost.resetElite
        if discount ~= 0 then 
            resetElite = math.ceil(resetElite * (1 + discount))
        end
        -- 花费
        result, count1 = string.gsub(desc, "$num2", resetElite)
        if count1 > 0 then 
            desc = result
        end

        local privileges = self._modelMgr:getModel("PrivilegesModel"):getPeerageEffect(PrivilegeUtils.peerage_ID.JingYingCiShu) or 0
        -- 挑战次数
        result, count1 = string.gsub(desc, "$num", sysStage.num + privileges)
        if count1 > 0 then 
            desc = result
        end

        self._viewMgr:showDialog("global.GlobalSelectDialog",
            {desc = desc,
            button1 = "确定", 
            button2 = "取消" ,
            callback1 = function ()
                self:resetAtkNum()
            end,
            callback2 = nil})
       
        return false
    end

    local userData = self._modelMgr:getModel("UserModel"):getData()
    local sysStage = tab:MainStage(tonumber(self._curStageBaseId))
    if userData.physcal - (sysStage.costPhysical * inTime) < 0 then 
        DialogUtils.showBuyRes( {goalType = "physcal", callback = function(success)
            if success then 
                local userModel = self._modelMgr:getModel("UserModel")
                local residuePowerLab = self:getUI("bg.residuePowerLab")
                residuePowerLab:setString(userModel:getData().physcal)
                local tmpLab01 = self:getUI("bg.tmpLab01")
                tmpLab01:setPosition(residuePowerLab:getPositionX() + residuePowerLab:getContentSize().width, tmpLab01:getPositionY())
            end
        end})    
        return false
    end

    return true
end

--[[
--! @function wideEnterBtn
--! @desc 扫荡
--! @param inTime int 次数
--]]
function IntanceEliteStageInfoView:resetAtkNum()
    local param = {id = self._curStageBaseId}
    self._serverMgr:sendMsg("StageServer", "resetAtkNum", param, true, {}, function (result)
        if result == nil or result["d"] == nil then 
            return 
        end
        -- 更新当前界面
        if self._wideFinishCallback ~= nil then 
            self._wideFinishCallback(self._curStageBaseId)
        end
        self:updateAboutStage()
        self._viewMgr:showTip("重置成功")
    end)
end

--[[
--! @function clickEnterBtn
--! @desc 进入副本按钮
--! @return 
--]]
function IntanceEliteStageInfoView:clickEnterBtn()
    if self:checkBattle(1) == false then
        return
    end
    self:enterBattle()
end


function IntanceEliteStageInfoView:enterBattle()
    self._userUpdateCallBack = nil
    self._userUpdateReturnMain = nil

    local sysStage = tab:MainStage(tonumber(self._curStageBaseId))
    local enemyFormation = IntanceUtils:initFormationData(sysStage)
    local formationModel = self._modelMgr:getModel("FormationModel")
    self._viewMgr:showView("formation.NewFormationView", {
        formationType = formationModel.kFormationTypeCommon,
        enemyFormationData = {[formationModel.kFormationTypeCommon] = enemyFormation},
        extend = {
            physical = sysStage.costPhysical,
            hideWeapon = true
        },
        callback = 
            function(inLeftData)
                if self.formationCallBack == nil then return end
               self:formationCallBack(inLeftData)
            end}
        )
end

--[[
--! @function formationCallBack
--! @desc 布阵callback
--! @param inLeftData table 左侧阵容
--]]
function IntanceEliteStageInfoView:formationCallBack(inLeftData)
    self._formationData = inLeftData
    local param = {id = self._curStageBaseId, serverInfoEx = BattleUtils.getBeforeSIE()}
    self._serverMgr:sendMsg("StageServer", "atkBeforeEliteStage", param, true, {}, function (result)
        if result == nil or result["d"] == nil or result["d"]["physcal"] == nil then 
            self._viewMgr:showTip("请求战斗失败")
            return  
        end
        self._battleToken = result["token"]
        
        local userModel = self._modelMgr:getModel("UserModel")
        userModel:updateUserData(result["d"])
        
        self:setVisible(false)

        --进入战斗
        self._viewMgr:popView()
        local lose = false
        BattleUtils.enterBattleView_Fuben(BattleUtils.jsonData2lua_battleData(result["atk"]), tonumber(self._curStageBaseId), false, function (info,callBack)
            self:battleCallBack(info, callBack)
            lose = (info.win == false and info.isSurrender == false)
        end,
        function (_type)
            local winType = self._battleWin
            -- 如果是通关副本，则动画到下一个关卡
            if self._battleWin == 1 then 
                winType = 2
            end
            local closeView = false
            if self._userUpdateCallBack == nil then 
                closeView = true
            end
            if self._battleFinishCallback ~= nil then 
                self._battleFinishCallback(self._curStageBaseId, winType, self._finishWarType, closeView)
            end

            if self._userUpdateCallBack ~= nil then 
                if self._userUpdateReturnMain then
                    self._userUpdateCallBack()
                else
                    if lose and _type ~= 1 then
                        GuideUtils.checkTriggerByType("action", "2", function ()
                            if self._userUpdateCallBack then
                                self._userUpdateCallBack()
                            end
                        end)   
                    else
                        self._userUpdateCallBack()
                    end
                end
            else
                if lose and _type ~= 1 then
                    GuideUtils.checkTriggerByType("action", "2")   
                end
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
function IntanceEliteStageInfoView:battleCallBack(inResult, inCallBack)
    if inResult == nil then return end
    -- 请求参数
    local tempTeams = {}
    for k,v in pairs(self._formationData.team) do
        table.insert(tempTeams,v.id)
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

    self._battleWin = 0
    if inResult.win ~= nil 
        and inResult.win == true then 
       self._battleWin = 1
    end
    local zzid = GameStatic.zzid2
    local param = {id = self._curStageBaseId, args = json.encode({win = self._battleWin, zzid = zzid, time = inResult.time, dieCount = inResult.dieCount, 
        skillList = inResult.skillList, serverInfoEx = inResult.serverInfoEx}), token = self._battleToken}
    if self._battleWin == 0 then 
        self._serverMgr:sendMsg("StageServer", "atkEliteStageLose", param, true, {}, function (result)
            if inCallBack ~= nil then
                inCallBack({})
            end
        end)
        return
    end
    local userModel = self._modelMgr:getModel("UserModel")

    local oldUserLevel = userModel:getData().lvl
    local oldUserPrePhysic = userModel:getData().physcal



    self._serverMgr:sendMsg("StageServer", "atkAfterEliteStage", param, true, {}, function (result)
        if result == nil then 
            self._battleWin = 0
            if inCallBack ~= nil then
                inCallBack({failed = true, __code = 1, extract = result["extract"]})
            end
            return 
        end
        if result["cheat"] == 1 then
            self._battleWin = 0
            if inCallBack ~= nil then
                inCallBack({failed = true, __code = 2, extract = result["extract"]})
            end
            return
        end
        if result["d"] == nil then 
            self._battleWin = 0
            if inCallBack ~= nil then
                inCallBack({failed = true, __code = 3, extract = result["extract"]})
            end
            return 
        end
        if result["extract"] then dump(result["extract"]["hp"]) end
        local resultData = table.deepCopy(result)

        -- 缓存数据对比是否升级
        local teamModel = self._modelMgr:getModel("TeamModel")
        local tempLevelIds = {}
        local teamD
        for k,v in pairs(tempCacheTeams) do
            local team, index = teamModel:getTeamAndIndexById(v.teamId)
            if index ~= nil and 
                resultData.d.teams[""..v.teamId] ~= nil then
                resultData.d.teams[""..v.teamId].oldLevel = v.level
                resultData.d.teams[""..v.teamId].totalExp = tab:TeamLevel(team.level).exp
            end
        end

        -- 升级提示
        local newUserData = userModel:getData()
        local mainStage = tab:MainStage(tonumber(self._curStageBaseId))
        if oldUserLevel < newUserData.lvl then 
            self._userUpdateCallBack = function()
                oldUserPrePhysic = oldUserPrePhysic - mainStage.costPhysical + 1
                self._viewMgr:checkLevelUpReturnMain(newUserData.lvl)
                ViewManager:getInstance():showDialog("global.DialogUserLevelUp",{preLevel = oldUserLevel,level = newUserData.lvl,prePhysic = oldUserPrePhysic,physic = newUserData.physcal}, nil, nil, nil, false)
            end
            local gotoview = tab.userLevel[newUserData.lvl]["gotoview"]
            if gotoview and gotoview == 1 then
                self._userUpdateReturnMain = true
            end
        else
            self._userUpdateCallBack = nil
        end
        resultData.star = resultData.rs.star
        if self._finishWarType == IntanceConst.FINISH_WAR_TYPE.FIRST_WAR then 
            resultData.firstReward = mainStage["firstReward"]
        end
        -- 像战斗层传送数据
        if inCallBack ~= nil then
            inCallBack(resultData)
        end
    end, function (error)
        if error then
            self._battleWin = 0
            if inCallBack ~= nil then
                inCallBack({failed = true, __code = 4, __error = error})
            end
        end
    end)
end

function IntanceEliteStageInfoView:showReport(inId, inSubType, inCallback)
    --回放
    local param = {id = inId, type  = 2, subType  = inSubType}
    self._serverMgr:sendMsg("StageServer", "showReport", param, true, {}, function (result)
        if result == nil or next(result) == nil then 
            self._viewMgr:showTip(lang("TIP_ZHUXIAN_8"))
            return
        end
        self._battleResult[inSubType] = result
        if inCallback ~= nil then 
            inCallback()
        end
    end)    
end



return IntanceEliteStageInfoView