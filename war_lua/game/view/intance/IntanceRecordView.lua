--[[
    Filename:    IntanceRecordView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2017-03-29 20:54:40
    Description: File description
--]]


local IntanceRecordView = class("IntanceRecordView", BasePopView)


function IntanceRecordView:ctor()
    IntanceRecordView.super.ctor(self)
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("intance.IntanceRecordView")
        elseif eventType == "enter" then 
        end
    end)
end

function IntanceRecordView:reflashUI(inData)
    local branchId = inData.branchId 

    local stageId = inData.stageId 


    self._battleResult = inData.battleResult   
    self._callback = inData.callback

    self:registerClickEventByName("bg.closeBtn", function()
        self:close()
    end)

    local titleLab = self:getUI("bg.titleBg.titleLab")
    UIUtils:setTitleFormat(titleLab, 1)    


    UIUtils:adjustTitle(self:getUI("bg"))

    local descLab = self:getUI("bg.descLab")
    descLab:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
    
    local tipLab = self:getUI("bg.tipLab")
    tipLab:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)

    local tapLab1 = self:getUI("bg.bestBg.tapLab1")
    tapLab1:setColor(cc.c3b(250, 249, 213))
    tapLab1:enable2Color(1, cc.c4b(255, 239, 111, 255))
    tapLab1:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    local tapLab1 = self:getUI("bg.weekBg.tapLab1")
    tapLab1:setColor(cc.c3b(250, 249, 213))
    tapLab1:enable2Color(1, cc.c4b(255, 239, 111, 255))
    tapLab1:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    self._battleType = 0
    if branchId ~= nil then 
        self._battleType = 1
        self:reflashUI1(branchId)
    elseif stageId ~= nil then
        self._battleType = 2
        self:reflashUI2(stageId)
    end
end

function IntanceRecordView:reflashUI1(branchId)
    print("reflashUI1=================================")
    local sysBranchStage = tab:BranchStage(branchId)

    local descLab = self:getUI("bg.descLab")
    descLab:setString(lang(sysBranchStage.recordtip))

    local nameLab = self:getUI("bg.nameLab")
    nameLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)  
    local teamD = tab:Team(sysBranchStage.recordicon)
    nameLab:setString(lang(teamD.name))        
    local icon = IconUtils:createSysTeamIconById({sysTeamData = teamD,isGray = false ,eventStyle = 1,isJin=true})

    local iconBg = self:getUI("bg.iconBg")
    icon:setPosition(iconBg:getContentSize().width * 0.5, iconBg:getContentSize().height * 0.5)
    icon:setAnchorPoint(0.5, 0.5)
    iconBg:addChild(icon)
    iconBg:setScale(0.8)

    local bestBg = self:getUI("bg.bestBg")

    local weekBg = self:getUI("bg.weekBg")

    self:updateBattleInfo(bestBg, self._battleResult[2], 1)

    self:updateBattleInfo(weekBg, self._battleResult[1], 2)
end


function IntanceRecordView:reflashUI2(stageId)
    local sysMainStage = tab:MainStage(stageId)

    local descLab = self:getUI("bg.descLab")
    descLab:setString(lang(sysMainStage.recordtip))

    local nameLab = self:getUI("bg.nameLab")
    nameLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)  

    local targetType = sysMainStage.recordicon[1]
    local targetId = sysMainStage.recordicon[2]
    local teamD = tab:Team(sysMainStage.recordicon)        

    local iconBg = self:getUI("bg.iconBg")
    iconBg:setScale(0.8)
    if targetType == 1 then 
        local sysHero = tab:Hero(targetId)
        dump(sysHero, "test", 10)
        local icon = IconUtils:createHeroIconById({sysHeroData = sysHero})
        icon:setPosition(iconBg:getContentSize().width * 0.5, iconBg:getContentSize().height * 0.5)
        icon:setAnchorPoint(0.5, 0.5)
        iconBg:addChild(icon)     
        nameLab:setString(lang(sysHero.heroname))
    else
        local teamD = tab:Team(targetId)        
        
        local icon = IconUtils:createSysTeamIconById({sysTeamData = teamD,isGray = false ,eventStyle = 1,isJin=true})
        icon:setPosition(iconBg:getContentSize().width * 0.5, iconBg:getContentSize().height * 0.5)
        icon:setAnchorPoint(0.5, 0.5)
        iconBg:addChild(icon)

        nameLab:setString(lang(teamD.name))

    end

    local bestBg = self:getUI("bg.bestBg")

    local weekBg = self:getUI("bg.weekBg")

    self:updateBattleInfo(bestBg, self._battleResult[2], 1)

    self:updateBattleInfo(weekBg, self._battleResult[1], 2)
end


function IntanceRecordView:updateBattleInfo(inNode, inResult, inType)
    -- dump(inResult, "test", 10)
    if inResult.atk == nil then inNode:setVisible(false) return end
    local userInfo = inResult.atk
    local nameLab = inNode:getChildByName("nameLab")
    nameLab:setString(userInfo.name)
    nameLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    local iconBg = inNode:getChildByName("iconBg")
    local avatar = IconUtils:createHeadIconById({avatar = userInfo.avatar, level = userInfo.lvl , tp = 4, avatarFrame = userInfo.avatarFrame, plvl = userInfo.plvl})
    iconBg:addChild(avatar)

    local battleBg = inNode:getChildByName("battleBg")
    if inType == 2 then
        local scoreLab = cc.LabelBMFont:create("a1000", UIUtils.bmfName_zhandouli)
        scoreLab:setAnchorPoint(cc.p(0, 0.5))
        scoreLab:setPosition(0, battleBg:getContentSize().height * 0.5 + 5)
        scoreLab:setScale(0.5)
        battleBg:addChild(scoreLab, 1)
        scoreLab:setString("a" .. userInfo.formation.score)
    else
        local timeLab = inNode:getChildByName("timeLab")
        timeLab:setColor(cc.c3b(250, 249, 213))
        timeLab:enable2Color(1, cc.c4b(255, 239, 111, 255))
        timeLab:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        timeLab:setString("通关时间 " .. TimeUtils.getStringTimeForInt(inResult.bt or 0))
    end

    local recordBtn = inNode:getChildByName("recordBtn")
    self:registerClickEvent(recordBtn, function()
        if self._battleType == 1 then
            self:reviewBranchBattle(clone(inResult))
        else
            self:reviewStageBattle(clone(inResult))
        end
    end)
end

function IntanceRecordView:reviewBranchBattle(result)
    local intanceModel = self._modelMgr:getModel("IntanceModel")
    intanceModel:noticeView("lockMap")
    BulletScreensUtils.clear()
    local left = BattleUtils.jsonData2lua_battleData(result.atk)
    BattleUtils.enterBattleView_FubenBranch(left, result.def, true,
    function (info, callback)
        info.star = 3
        callback(info)
    end,
    function (info)
        -- 退出战斗
        
        intanceModel:noticeView("showIntanceBullet")
        intanceModel:noticeView("unlockMap")
    end)
end

function IntanceRecordView:reviewStageBattle(result)
    BulletScreensUtils.clear()
    local left = BattleUtils.jsonData2lua_battleData(result.atk)
    BattleUtils.enterBattleView_Fuben(left, result.def, true,
    function (info, callback)
        callback(info)
    end,
    function (info)
        -- print("self.parentView===========", self.parentView, self.parentView.loadBigMap)
        -- self.parentView:loadBigMap()
        -- parentView = IntanceView
        local intanceModel = self._modelMgr:getModel("IntanceModel")
        intanceModel:noticeView("showIntanceBullet")
        if self._callback ~= nil then 
            self._callback()
        end
    end)
end

return IntanceRecordView