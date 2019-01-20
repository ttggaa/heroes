--[[
    Filename:    TeamView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-01-10 21:10:30
    Description: File description
--]]


local TeamView = class("TeamView", BaseView)
require "game.view.team.TeamConst"

function TeamView:ctor(data)
    TeamView.super.ctor(self)
    self.initAnimType = 2
    self._curSelectTeam = data.team
    self._index = data.index
    self._starPos = {}

    self._lihuiPool = {}
    self._lihuiCount = 0
    self._teamType = 7
end

function TeamView:onInit()
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("team.TeamView")
            UIUtils:reloadLuaFile("team.TeamSkillNode")
        end
    end)
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._teamModel:setTeamTreasure()
    local userData = self._modelMgr:getModel("UserModel"):getData()
    self._firstFight = true
    self._firstGuide = true

    self._titleNames = {
        "   进阶",
        "   升级",
        "   升星",
        "   技能",
        "   关联",
        "   专属",
    }
    self._shortTitleNames = {
        "   进阶",
        "   升级",
        "   升星",
        "   技能",
        "   关联",
        "   专属",
    }
    local nameBg = self:getUI("nameBg")
    nameBg:setZOrder(11)

    self._teamWidth = MAX_SCREEN_WIDTH
    if ADOPT_IPHONEX and not self.dontAdoptIphoneX then
        if self.fixMaxWidth then
            self._widget:setContentSize((MAX_SCREEN_WIDTH >= self.fixMaxWidth) and self.fixMaxWidth or MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
        else
            self._teamWidth = MAX_SCREEN_WIDTH - 120
            self._widget:setContentSize(self._teamWidth, MAX_SCREEN_HEIGHT)
        end
    end

    local tabPos6 = {366, 296, 226, 156, 17, 86}
    local tabPos5 = {346, 269, 192, 115, 38}

    -- 战斗力
    -- self._assess = self:getUI("bg1.assess")
    self._frame = self:getUI("bg1.rightSubBg.frame")
    self._frame:setZOrder(-1)
    -- 进阶
    local tab1 = self:getUI("bg1.rightSubBg.tab1")
    -- 升级
    local tab2 = self:getUI("bg1.rightSubBg.tab2")
    -- 升星
    local tab3 = self:getUI("bg1.rightSubBg.tab3")
    -- 技能
    local tab4 = self:getUI("bg1.rightSubBg.tab4")
    -- 关联
    local tab5 = self:getUI("bg1.rightSubBg.tab5")
    local tab6 = self:getUI("bg1.rightSubBg.tab6")

    self._up = self:getUI("downBg.right")
    local mc1 = mcMgr:createViewMC("youjiantou_teamnatureanim", true, false)
    mc1:setPosition(cc.p(self._up:getContentSize().width*0.5, self._up:getContentSize().height*0.5))
    self._up:addChild(mc1)

    self._down = self:getUI("downBg.left")
    local mc2 = mcMgr:createViewMC("zuojiantou_teamnatureanim", true, false)
    mc2:setPosition(cc.p(self._down:getContentSize().width*0.5+90, self._down:getContentSize().height*0.5))
    self._down:addChild(mc2)


    self._lookBtn = self:getUI("bg2.lookBtn")
    self._lookBtn:setVisible(false)

    UIUtils:setTabChangeAnimEnable(tab1,400,function(sender)self:tabButtonClick(sender, 1)end,nil,true)
    UIUtils:setTabChangeAnimEnable(tab2,400,function(sender)self:tabButtonClick(sender, 2)end,nil,true)
    UIUtils:setTabChangeAnimEnable(tab3,400,function(sender)self:tabButtonClick(sender, 3)end,nil,true)
    UIUtils:setTabChangeAnimEnable(tab4,400,function(sender)self:tabButtonClick(sender, 4)end,nil,true)
    UIUtils:setTabChangeAnimEnable(tab5,400,function(sender)self:tabButtonClick(sender, 5)end,nil,true)
    UIUtils:setTabChangeAnimEnable(tab6,400,function(sender)self:tabButtonClick(sender, 6)end,nil,true)

    self._tabEventTarget = {}
    table.insert(self._tabEventTarget, tab1)
    table.insert(self._tabEventTarget, tab2)
    table.insert(self._tabEventTarget, tab3)
    table.insert(self._tabEventTarget, tab4)
    table.insert(self._tabEventTarget, tab5)
    table.insert(self._tabEventTarget, tab6)

    local tabData = tab:SystemOpen("Exclusive")
    local exclusiveShowLevel = tabData[2]
    local userLevel = userData.lvl
    if userLevel >= exclusiveShowLevel then
        tab6:setVisible(true)
        for i = 1, 6 do
            self:getUI("bg1.rightSubBg.tab" .. i):setPositionY(tabPos6[i])
        end
    else
        tab6:setVisible(false)
        for i = 1, 5 do
            self:getUI("bg1.rightSubBg.tab" .. i):setPositionY(tabPos5[i])
        end
    end

    local attr = self:getUI("attr")
    attr:setVisible(false)
    
    local starTip = self:getUI("starTip")
    starTip:setVisible(false)
    
    self:registerClickEvent(self._lookBtn, function(sender)
        self:showDialog("team.TeamCardInfo", {teamD = tab:Team(self._curSelectTeam.teamId), level = self._curSelectTeam.level, teamData = self._curSelectTeam})
    end)

    self._teamModel:setTeamMap(self._teamModel:getData()) 
    self._teamModel:setTeamBaseData()
    self._teamsMapData = self._teamModel:getTeamBaseData()

    self._teamboost = self:getUI("bg1.teamboostBtn.txt")
    self._teamboost:setColor(UIUtils.colorTable.ccUIMenuBtnColor1)
    -- self._teamboost:enable2Color(1, UIUtils.colorTable.ccUIMenuBtnColor2)
    self._teamboost:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._teamboost:setFontSize(44)
    self._teamboostBtn = self:getUI("bg1.teamboostBtn")
    self._teamboostBtn:setScaleAnim(true)
    self:registerClickEvent(self._teamboostBtn, function()
        -- self:updateTeamBoost()
        if self._curSelectTeam.stage < 6 then
            local param = {indexId = 1}
            self._viewMgr:showDialog("global.GlobalPromptDialog", param)
            return
        end
        local param = {teamId = self._curSelectTeam.teamId, callback = function()
            self:updateTeamBoost()
        end}
        self._viewMgr:showView("teamboost.TeamBoostView", param)
    end)

    local talentBtn = self:getUI("bg1.talentBtn")
    -- UIUtils:addFuncBtnName(talentBtn,"天赋",nil,true,18)
    talentBtn:setScaleAnim(true)
    local tflag = false
    if userData.lvl < tab.systemOpen["TeamTalent"][1] then
        talentBtn:setVisible(false)
        tflag = true
    end
    self:registerClickEvent(talentBtn, function()
        self._viewMgr:showDialog("team.TeamTalentDialog", {teamId = self._curSelectTeam.teamId})
    end)

    local holyBtn = self:getUI("bg1.holyBtn")
    if userData.lvl <tab.systemOpen["Holy"][1] then
        holyBtn:setVisible(false)
    end
    self:registerClickEvent(holyBtn, function()
        self._viewMgr:showView("team.TeamHolyView",{teamId = self._curSelectTeam.teamId })
    end)

    --兵团皮肤
    self._teamSkinBtn = self:getUI("bg1.teamSkinBtn")
    self:registerClickEvent(self._teamSkinBtn, function()
        self._viewMgr:showDialog("team.TeamSkinView",{isHaveTeam = self._curSelectTeam.unlock,teamData = self._curSelectTeam,closeCallBack = function ( )
            self:updateTeamAmin()
            self:setTeamImgAction1()
        end},true)
    end)

    local pinglun = self:getUI("bg1.pinglun")
    -- UIUtils:addFuncBtnName(pinglun,"评价",nil,true,18)
    if userData.lvl < tab.systemOpen["CommentTeam"][1] then
        pinglun:setVisible(false)
    end
    if userData.lvl < tab.systemOpen["TeamBoost"][1] then
        self._teamboostBtn:setVisible(false)
    end
    if tflag == true then
        pinglun:setPositionX(-54)
    end
    self:registerClickEvent(pinglun, function()
        self:getCommentData()
    end)

    self:updateUI()

    local selectBtn = self:getUI("selectBtn")
    local btnBg = self:getUI("btnBg")
    btnBg:setAnchorPoint(0, 0)
    btnBg:setVisible(false)
    -- btnBg:setPosition(cc.p(10, 80))
    -- btnBg:setOpacity(150)
    -- btnBg:setScale(0.6)
    selectBtn:setScaleAnim(true)
    local scale = cc.ScaleTo:create(0.1, 0.6)
    local move = cc.MoveTo:create(0.1, cc.p(10, 80))
    local spawn = cc.Spawn:create(scale, move, cc.FadeTo:create(0.1, 0))
    local seq = cc.Sequence:create(spawn)
    btnBg:runAction(seq)

    self:registerClickEvent(selectBtn, function()
        local tflag = not btnBg:isVisible()
        local seq
        if tflag == true then
            local scale = cc.ScaleTo:create(0.1, 1)
            local move = cc.MoveTo:create(0.1, cc.p(10, 138))
            local spawn = cc.Spawn:create(scale, move, cc.FadeTo:create(0.1, 255))
            seq = cc.Sequence:create(cc.CallFunc:create(function()
                btnBg:setVisible(tflag)
            end), spawn)
            btnBg:runAction(seq)
        else
            -- btnBg:setVisible(tflag)
            local scale = cc.ScaleTo:create(0.1, 0.6)
            local move = cc.MoveTo:create(0.1, cc.p(10, 80))
            local spawn = cc.Spawn:create(scale, move, cc.FadeTo:create(0.1, 0))
            seq = cc.Sequence:create(spawn, cc.CallFunc:create(function()
                btnBg:setVisible(tflag)
            end))
            btnBg:runAction(seq)
        end
        -- btnBg:runAction(seq)
    end)

    local tempBaseInfoNode = self:getUI("bg1.rightSubBg")
    -- local teamInfoBg = ccui.ImageView:create()
    -- teamInfoBg:loadTexture("asset/bg/teaminfo_bg.jpg")
    -- teamInfoBg:setAnchorPoint(cc.p(0,0))
    -- tempBaseInfoNode:addChild(teamInfoBg)

    local volume = self:getUI("bg2.volume")
    volume:setColor(cc.c3b(240,240,0))
    -- volume:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    local zizhi = self:getUI("bg2.zizhi")

    -- local zizhiLab = self:getUI("bg2.zizhiLab")
    -- zizhiLab:setFontName(UIUtils.ttfName)
    -- zizhiLab:setColor(cc.c3b(255,255,255))
    -- zizhiLab:enable2Color(1, cc.c4b(255, 207, 52, 255))
    -- zizhiLab:enableOutline(cc.c4b(89, 48, 19, 255), 2)
    -- zizhiLab:setFontSize(26)

    
    local nameBg = self:getUI("nameBg")

    local zhandouli1 = cc.Label:createWithTTF("战斗力", UIUtils.ttfName, 16)
    zhandouli1:setAnchorPoint(0, 0.5)
    zhandouli1:setColor(cc.c3b(255, 238, 160))
    zhandouli1:enableOutline(UIUtils.colorTable.titleOutLineColor, 1)
    zhandouli1:setPosition(15, -73)
    zhandouli1:setName("zhandouli1")
    nameBg:addChild(zhandouli1) -- 4

    self._zhandouliLab = cc.LabelBMFont:create("1", UIUtils.bmfName_zhandouli_little)
    self._zhandouliLab:setName("zhandouli")
    self._zhandouliLab:setAnchorPoint(cc.p(0,0.5))
    self._zhandouliLab:setPosition(cc.p(15, -100))
    nameBg:addChild(self._zhandouliLab, 1)

    self._addfight = cc.LabelBMFont:create("1", UIUtils.bmfName_zhandouli_little)
    self._addfight:setName("addfight")
    self._addfight:setAnchorPoint(cc.p(0,0.5))
    self._addfight:setPosition(cc.p(99, -100))
    self._addfight:setOpacity(0)
    nameBg:addChild(self._addfight, 1)

    local nameLab = self:getUI("nameBg.nameLab")
    nameLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    -- nameLab:setFontName(UIUtils.ttfName)

    local iconGem = self:getUI("nameBg.nameStage") 
    iconGem:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    -- iconGem:setFontName(UIUtils.ttfName)

    self._levelLab = self:getUI("nameBg.level") 
    self._levelLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    -- self._levelLab:setFontName(UIUtils.ttfName)

    self._aminBg = self:getUI("bg2.aminBg")
    self._aminBg:setAnchorPoint(cc.p(0.5, 0.5))
    -- -- 升级
    -- self:registerClickEventByName("rightNode.baseInfoBg.updateTeamBtn", function ()
    --     self:upgradeTeam()
    -- end)

    -- self.updateStageBtn = self:getUI("bg.rightBg.vessel.updateStageBtn") 
    -- self:registerClickEventByName("bg.rightBg.vessel.updateStageBtn", function()
    --     self:updateStage()
    -- end)
    -- self:registerClickEventByName("bg.rightBg.vessel.updateStageBtn", function()
    --     self:close()     
    -- end)
    local bg1 = self:getUI("bg1")
    local teamIcon = self:getUI("panelBg.teamImgBg")
    -- teamIcon:setScale(0.9)
    teamIcon:setPositionX((self._teamWidth-bg1:getContentSize().width)/2 - 50)
  
    -- self._teamsData = self._modelMgr:getModel("TeamModel"):getData()
    local downBg = self:getUI("downBg.Panel_46")

    -- self._teamWidth - bg1:getContentSize().width - 50
    -- self._tableView = cc.TableView:create(cc.size(downBg:getContentSize().width, 100)) --cc.TableView:create(cc.size(downBg:getContentSize().width, 100))
    self._tableView = cc.TableView:create(cc.size(self._teamWidth-70, 105)) --cc.TableView:create(cc.size(downBg:getContentSize().width, 100))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self._tableView:setAnchorPoint(cc.p(0.5, 0))
    self._tableView:setPosition(cc.p(-0.5*(self._teamWidth-downBg:getContentSize().width)+70, -3))
    self._tableView:setDelegate()
    self._tableView:registerScriptHandler(function(view) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._tableView:registerScriptHandler(function(table, cell) self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:setBounceable(true)
    if self._tableView.setDragSlideable ~= nil then 
        self._tableView:setDragSlideable(true)
    end

    downBg:addChild(self._tableView)
    self._isReflashTeamList = true
    self._bigStarOpen = false

    self:listenReflash("ItemModel", self.updateTableView)
    self:listenReflash("UserModel", self.updateTableView)
    self:listenReflash("TeamModel", self.updateTableView)

    self:onFristReflashTeams()
    self:updateTeamAmin()
    -- 手动触发tab 事件
    self:tabButtonClick(self:getUI("bg1.rightSubBg.tab" .. (self._index or 1)), (self._index or 1))
    self:getUI("bg1.rightSubBg.tab" .. (self._index or 1))._appearSelect = true
    -- self._tableView:setBounceable(false)
    -- self:setScale(0.2)
    -- self:setPosition(cc.p(500,500))
    -- self:setAmin(1)
    self:setMoveAction()
    -- self:addAnimBg()
    self:addShareBtn()   --by wangyan
end

function TeamView:updateExclusiveState(  )
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local tab6 = self:getUI("bg1.rightSubBg.tab6")
    self._exclusiveFlag = 0
    local tabData = tab:SystemOpen("Exclusive")
    local exclusiveOpenLevel = tabData[1]
    local exclusiveShowLevel = tabData[2]
    if userData.lvl < exclusiveOpenLevel then
        if userData.lvl >= exclusiveShowLevel then
            UIUtils:setGray(tab6, true)
            self._exclusiveFlag = lang(tabData[3])
        end
    else
        local excData = tab.exclusive[self._curSelectTeam.teamId] or {}
        local isOpen = excData.isOpen
        if isOpen and isOpen == 1 then
            local openTime = tonumber(excData.openTime or 0)
            local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
            if curTime >= openTime then
                UIUtils:setGray(tab6, false)
                self._exclusiveFlag = 0
            else
                UIUtils:setGray(tab6, true)
                self._exclusiveFlag = lang("exclusive_tip_1")
            end
        else
            UIUtils:setGray(tab6, true)
            self._exclusiveFlag = lang("exclusive_tip_1")
        end
    end
end

function TeamView:updateUI()
    for i=1,11 do
        local raceBtn = self:getUI("btnBg.raceBtn" .. i)
        local selBtn = self:getUI("btnBg.raceBtn" .. i .. ".selBtn")
        local txt = self:getUI("btnBg.raceBtn" .. i .. ".txt")
        selBtn:setVisible(false)
        raceBtn:setScaleAnim(true)
        local tempTeams = self._teamModel:getClassTeam(TeamConst.TEAM_RACE_TYPE["RACE_" .. i])
        if table.nums(tempTeams) >= 1 then
            raceBtn:setSaturation(0)
            txt:setColor(cc.c3b(255,255,255))
            self:registerClickEvent(raceBtn, function()
                if self._teamType == i then
                    return
                end
                local _type = TeamConst.TEAM_RACE_TYPE["RACE_" .. i]
                self._firstFight = true
                self:selectTeamType(_type, i)
                selBtn:setVisible(true)
                local tempBtn = self:getUI("btnBg.raceBtn" .. self._teamType .. ".selBtn")
                tempBtn:setVisible(false)
                self._teamType = i 
                print("self._teamType 0  ",self._teamType)
                local btnBg = self:getUI("btnBg")
                btnBg:setVisible(false)
            end)
        else
            txt:setColor(cc.c3b(60,60,60))
            raceBtn:setSaturation(-100)
            self:registerClickEvent(raceBtn, function()
                self._viewMgr:showTip("暂无该类型兵团")
            end)
        end

        if conditions then
            selBtn:setVisible(true)
        end
    end
end

function TeamView:onTop()
    print("76666666666666666=====9999999999999999==========")
    self._teamModel:setTeamMap(self._teamModel:getData()) 
    self._teamModel:setTeamBaseData()
    self._teamsMapData = self._teamModel:getTeamBaseData()
    self._teamType = 7
    self:updateUI()

    self._isReflashTeamList = true
    self._bigStarOpen = false

    self:onFristReflashTeams()
    self:updateTeamAmin()
    -- 手动触发tab 事件
    self:tabButtonClick(self:getUI("bg1.rightSubBg.tab" .. (self._index or 1)), (self._index or 1))

    -- self:setMoveAction()
end

--分享按钮
function TeamView:addShareBtn()
    if self._shareNode == nil then
        self._shareNode = require("game.view.share.GlobalShareBtnNode").new({mType = "ShareTeamModule"})
        self._shareNode:setPosition(165, 35)
        self._shareNode:setCascadeOpacityEnabled(true, true)
        self:getUI("bg2"):addChild(self._shareNode, 5)
    end
    
    self._shareNode:registerClick(function()
        return {moduleName = "ShareTeamModule", teamId = self._curSelectTeam.teamId}
        end)
end

function TeamView:updateTeamBoost()
    local teamboost = self._teamModel:getTeamBoostData(self._curSelectTeam)
    local tbStage = TeamUtils:getTeamBoostName(teamboost)
    self._teamboost:setString(lang("TECHINIQUELEVEL_" .. teamboost))
    self._teamboostBtn:loadTexture("globalImageUI_teamboost" .. tbStage[1] .. ".png", 1)
end

function TeamView:selectTeamType(_type, indexId)
    -- print(self._teamType, "============_type=", _type)
    if self._teamType == indexId then
        return
    end
    self._isReflashTeamList = true
    self:onFristReflashTeams(_type)
    self:setUpdateTeam(1, 0, 0, true)
end

-- 资源释放 避免内存过高
function TeamView:useLihui(name)
    if self._lihuiCount > 5 then
        local tc = cc.Director:getInstance():getTextureCache()
        for name, _ in pairs(self._lihuiPool) do
            tc:removeTextureForKey("asset/uiother/team/".. name ..".png") 
        end
        self._lihuiCount = 0
        self._lihuiPool = {}
    end
    if self._lihuiPool[name] == nil then
        self._lihuiPool[name] = true
        self._lihuiCount = self._lihuiCount + 1
    end
end

function TeamView:addTeamRole()
    -- local sysTeam = tab:Team(self._curSelectTeam.teamId)
    -- local cardoffset = sysTeam["card"]
    -- local lihui = string.sub(sysTeam["art1"], 4, string.len(sysTeam["art1"]))
    local teamIcon = self:getUI("panelBg.teamImgBg")
    local roleSp = teamIcon:getChildByName("roleSp") -- xian
    local roleSp1 = teamIcon:getChildByName("roleSp1") -- = teamIcon:getChildByName("roleSpBg") -- xian

    if not roleSp then
        roleSp = cc.Sprite:create()
        roleSp:setAnchorPoint(0, 0)
        roleSp:setName("roleSp")
        teamIcon:addChild(roleSp)

        local roleSpBg = cc.Sprite:create()
        roleSpBg:setColor(cc.c4b(0,0,0,150))
        roleSpBg:setAnchorPoint(0, 0)
        roleSpBg:setName("roleSpBg")
        roleSp:addChild(roleSpBg, -1)
        roleSpBg:setVisible(false)
    end

    if not roleSp1 then
        roleSp1 = cc.Sprite:create()
        roleSp1:setAnchorPoint(0, 0)
        roleSp1:setName("roleSp1")
        roleSp1:setOpacity(0)
        teamIcon:addChild(roleSp1)

        local roleSpBg = cc.Sprite:create()
        roleSpBg:setColor(cc.c4b(0,0,0,150))
        roleSpBg:setAnchorPoint(0, 0)
        roleSpBg:setName("roleSpBg")
        roleSp1:addChild(roleSpBg, -1)
        roleSpBg:setVisible(false)
    end
end

function TeamView:setMoveAction()
    self:addTeamRole()
    self:setTeamImgAction1()
    -- local roleSp, roleSp1
    local action = self:getUI("action")
    local teamIcon = self:getUI("panelBg.teamImgBg")
    local downY, downX, endX
    local spBegin = {}
    registerTouchEvent(
        action,
        function (_, x, y)
            downY = y
            downX = x
            endX = x
            local roleSp = teamIcon:getChildByName("roleSp")
            -- local roleSp1 = teamIcon:getChildByName("roleSp1")
            -- roleSp1:stopAllActions()
            -- roleSp:stopAllActions()
            -- roleSp1:setOpacity(0)
            spBegin[1] = roleSp:getPositionX()
            spBegin[2] = roleSp:getPositionY()
            -- dump(spBegin)
        end, 
        function (_, x, y)
            local roleSp = teamIcon:getChildByName("roleSp")
            if downX - endX <= 300 then
                roleSp:setPositionX(roleSp:getPositionX()-(downX-x))
                downX = x
            else
                downX = x
            end
        end, 
        function (_, x, y)
            if math.abs(endX - x) > 100 then
                local roleSp = teamIcon:getChildByName("roleSp")
                local roleSp1 = teamIcon:getChildByName("roleSp1")
                roleSp1:stopAllActions()
                roleSp:stopAllActions()
                roleSp1:setOpacity(0)
                if endX - x > 0 then
                    self:setUpdateTeam(1, endX - x, spBegin)
                else
                    self:setUpdateTeam(-1, endX - x, spBegin)
                end
            else
                self:setUpdateTeam(0, endX - x, spBegin)
            end
        end,
        function (_, x, y)
            if math.abs(endX - x) > 100 then
                local roleSp = teamIcon:getChildByName("roleSp")
                local roleSp1 = teamIcon:getChildByName("roleSp1")
                roleSp1:stopAllActions()
                roleSp:stopAllActions()
                roleSp1:setOpacity(0)
                if endX - x > 0 then
                    self:setUpdateTeam(1, endX - x, spBegin)
                else
                    self:setUpdateTeam(-1, endX - x, spBegin)
                end
            else
                self:setUpdateTeam(0, endX - x, spBegin)
            end
        end)
end

function TeamView:setUpdateTeam(teamIndex, disX, tempX, reset, jxFlag)
    -- print("_curSelectIndex",self._curSelectIndex, teamIndex, table.nums(self._teamsData))
-- self:setTeamImgAction1(teamIndex, disX)
    -- print("self._curSelectIndex========", self._curSelectIndex)
    local tempCell = self._tableView:cellAtIndex(self._curSelectIndex)
    if tempCell ~= nil then 
        tempCell:switchListItemState(false)
    end
    if (self._curSelectIndex + teamIndex) < 0 then
        -- return
        self._curSelectIndex = table.nums(self._teamsMap)
    elseif (self._curSelectIndex + teamIndex) >= table.nums(self._teamsMap) then
        self._curSelectIndex = -1
    end
    self._curSelectIndex = self._curSelectIndex + teamIndex
    if reset == true then
        self._curSelectIndex = 0
    end

    local cell = self._tableView:cellAtIndex(self._curSelectIndex)
    if cell ~= nil then
        cell:switchListItemState(true)
    end
    -- print("self._curSelectIndex========", self._curSelectIndex)

    local tempTeamId = self._teamsMap[self._curSelectIndex + 1]
    local tempTeam = self._teamsMapData[tempTeamId]
    -- local tempTeam = self._teamsData[self._curSelectIndex + 1]
    -- print("==========", tempTeam.teamId, "==", self._curSelectTeam.teamId)
    if tempTeam.teamId == self._curSelectTeam.teamId and (jxFlag ~= true) then 
        local sysTeam = tab:Team(self._curSelectTeam.teamId)
        local cardoffset = sysTeam["card2"]
        local teamIcon = self:getUI("panelBg.teamImgBg")
        local roleSp = teamIcon:getChildByName("roleSp")
        -- roleSp:runAction(cc.MoveTo:create(0.1, cc.p(tempX[1], tempX[2])))
        -- roleSp:loadTexture("str", texturerestype)
        roleSp:runAction(cc.MoveTo:create(0.1, cc.p(cardoffset[1], cardoffset[2])))
        return 
    end
    -- self._teamShow = true
    self._curSelectTeam = tempTeam
    self._curSelectSysTeam = tab:Team(self._curSelectTeam.teamId)
    self:setTeamImgAction(teamIndex, disX, jxFlag)
    self._firstFight = true
    self:reflashTeamUI()
    self:updateTeamAmin()

    self:scrollToNext(self._curSelectIndex - 1, false)
end

function TeamView:setTeamImgAction(teamIndex, disX, jxFlag)
    local sysTeam = tab:Team(self._curSelectTeam.teamId)
    local cardoffset = sysTeam["card2"]
    local downBg = self:getUI("downBg")
    local lihui = string.sub(sysTeam["art1"], 4, string.len(sysTeam["art1"]))
    local teamIcon = self:getUI("panelBg.teamImgBg")
    local roleSp1 = teamIcon:getChildByName("roleSp1")
    local roleSp = teamIcon:getChildByName("roleSp")

    local _x 
    if teamIndex == 1 then
        _x = cardoffset[1] + 500
    elseif teamIndex == -1 then
        _x = cardoffset[1] - 500
    end
    local teamName, art1, art2, art3 = TeamUtils:getTeamAwakingTab(self._curSelectTeam, self._curSelectTeam.teamId)
    self:useLihui(art2)
    if roleSp1 then
        roleSp1:setTexture("asset/uiother/team/".. art2 ..".png")
        roleSp1:setPosition(cc.p(_x, cardoffset[2]))
        roleSp1:setScale(cardoffset[3])
        local roleSpBg = roleSp1:getChildByName("roleSpBg")
        if roleSpBg then
            roleSpBg:setTexture("asset/uiother/team/".. art2 ..".png")
            roleSpBg:setPosition(cc.p( -5, 0))
            roleSpBg:setScale(cardoffset[3])
        end
    end

    if teamIndex == 1 then
        roleSp1:setOpacity(255)
        -- roleSp1:setPosition(cc.p(800,roleSp:getPositionY()))
        roleSp1:runAction(cc.MoveTo:create(0.2, cc.p(cardoffset[1], cardoffset[2])))
        roleSp:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(disX - 500,0)), cc.FadeOut:create(0.2)))
        local roleSpBg = roleSp:getChildByName("roleSpBg")
        roleSpBg:setOpacity(255)
        roleSpBg:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(disX - 500,0)), cc.FadeOut:create(0.2)))
        roleSp1:setName("roleSp")
        roleSp:setName("roleSp1")
    elseif teamIndex == -1 then
        roleSp1:setOpacity(255)
        -- roleSp1:setPosition(cc.p(-300,roleSp:getPositionY()))
        roleSp1:runAction(cc.MoveTo:create(0.2, cc.p(cardoffset[1], cardoffset[2])))
        roleSp:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(disX + 500,0)), cc.FadeOut:create(0.2)))
        local roleSpBg = roleSp:getChildByName("roleSpBg")
        roleSpBg:setOpacity(255)
        roleSpBg:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(disX + 500,0)), cc.FadeOut:create(0.2)))
        roleSp1:setName("roleSp")
        roleSp:setName("roleSp1")
    elseif teamIndex == 0 then
        local roleSp = teamIcon:getChildByName("roleSp")
        if roleSp then
            roleSp:setTexture("asset/uiother/team/".. art2 ..".png")
            roleSp:setScale(cardoffset[3])
        end
        roleSp:runAction(cc.MoveBy:create(0.2, cc.p(disX,0)))
        -- return
    end

    -- teamIcon:setPositionX((MAX_SCREEN_WIDTH-bg1:getContentSize().width)/2)
    -- 如果是当前展示图，则不重新绘制
    local roleSp = teamIcon:getChildByName("roleSp")
    local roleSpBg = roleSp:getChildByName("roleSpBg")
    if roleSp.teamId == self._curSelectTeam.teamId then 
        return
    end

    self._firstGuide = true
    roleSp.teamId = self._curSelectTeam.teamId
end

function TeamView:setTeamImgAction1(teamIndex, disX)
    local sysTeam = tab:Team(self._curSelectTeam.teamId)
    local cardoffset = sysTeam["card2"]
    local downBg = self:getUI("downBg")
    local teamIcon = self:getUI("panelBg.teamImgBg")
    local roleSp1 = teamIcon:getChildByName("roleSp1")
    local roleSp = teamIcon:getChildByName("roleSp")
    local teamName, art1, art2, art3 = TeamUtils:getTeamAwakingTab(self._curSelectTeam, self._curSelectTeam.teamId)
    self:useLihui(art2)
    if roleSp then
        roleSp:setTexture("asset/uiother/team/".. art2 ..".png")
        local roleSpBg = roleSp:getChildByName("roleSpBg")
        if roleSpBg then
            roleSpBg:setTexture("asset/uiother/team/".. art2 ..".png")
        end
    end

    -- teamIcon:setPositionX((MAX_SCREEN_WIDTH-bg1:getContentSize().width)/2)
    -- 如果是当前展示图，则不重新绘制
    local roleSp = teamIcon:getChildByName("roleSp")
    local roleSpBg = roleSp:getChildByName("roleSpBg")
    -- if roleSp.teamId == self._curSelectTeam.teamId then 
    --     return
    -- end
    -- if roleSp.teamId ~= nil then 
    --     local seq = cc.Sequence:create(cc.FadeOut:create(0.1),
    --         cc.CallFunc:create(function()
    --             if roleSp then
    --                 -- roleSp:setTexture("asset/uiother/team/t_".. lihui ..".png")
    --                 roleSp:setPosition(cc.p(cardoffset[1], cardoffset[2]))
    --                 roleSp:setScale(cardoffset[3])
    --             end
    --         end),cc.DelayTime:create(0.1),
    --         cc.FadeIn:create(0.15))
    --     roleSp:runAction(seq)
    --     local seq = cc.Sequence:create(cc.FadeOut:create(0.1),
    --         cc.CallFunc:create(function()
    --             if roleSpBg then
    --                 -- roleSpBg:setTexture3("asset/uiother/team/t_".. lihui ..".png")
    --                 roleSpBg:setPosition(cc.p(cardoffset[1] - 5, cardoffset[2] - 5))
    --                 roleSpBg:setScale(cardoffset[3])
    --             end
    --         end),cc.DelayTime:create(0.1),
    --         cc.FadeIn:create(0.15))
    --     roleSpBg:runAction(seq)
    -- else
        roleSp:setPosition(cc.p(cardoffset[1], cardoffset[2]))
        roleSp:setScale(cardoffset[3])
        roleSpBg:setPosition(cc.p(cardoffset[1], cardoffset[2]))
        -- roleSpBg:setScale(cardoffset[3])
    -- end
    roleSp.teamId = self._curSelectTeam.teamId
end

function TeamView:updateTip()
    -- 是否上阵
    local formationModel = self._modelMgr:getModel("FormationModel")
    -- local isInFormation = formationModel:isTeamLoaded(self._curSelectTeam.teamId)
    local hint1 = self:getUI("bg1.rightSubBg.tab1.hint")
    hint1:setVisible(false)
    local hint2 = self:getUI("bg1.rightSubBg.tab2.hint")
    hint2:setVisible(false)
    local hint3 = self:getUI("bg1.rightSubBg.tab3.hint")
    hint3:setVisible(false)
    local hint4 = self:getUI("bg1.rightSubBg.tab4.hint")
    hint4:setVisible(false)
    local hint6 = self:getUI("bg1.rightSubBg.tab6.hint")
    hint6:setVisible(false)
    if self._curSelectTeam.onStage == true then
        hint1:setVisible(true)
    end
    if self._curSelectTeam.onGrade == true then
        hint2:setVisible(true)
    end
    if self._curSelectTeam.onStar == true then
        hint3:setVisible(true)
    end
    if self._curSelectTeam.onSkill == true then
        hint4:setVisible(true)
    end
    if self._curSelectTeam.onExclusive == true then
        hint6:setVisible(true)
    end
end

function TeamView:updateItem()
    if self._upStarNode ~= nil and self._upStarNode:isVisible() == true then
        self._upStarNode:reflashUI({teamData = self._curSelectTeam})
    end
end 

-- function TeamView:updateTableView()
--     local teamData, _ = self._teamModel:getTeamAndIndexById(self._curSelectTeam.teamId)
--     local tempTeamD = clone(teamData)
    
--     local tempTeamsData = {}
--     tempTeamsData[self._curSelectTeam.teamId] = tempTeamD

--     for k,v in pairs(self._teamsData) do
--         if tempTeamsData[v.teamId] ~= nil then 
--             self._teamsData[k] = tempTeamsData[v.teamId]
--             self._tableView:updateCellAtIndex(k - 1)
--         end
--     end

--     self._curSelectTeam = tempTeamD
--     self:reflashTeamUI()
-- end

function TeamView:updateTableView()
    -- 获取当前所有最新的怪兽数据
    local tempTeamsData = self._teamModel:getTeamBaseData()

    for k,v in pairs(self._teamsMap) do
        if tempTeamsData[v] ~= nil then 
            -- self._teamsData[k] = tempTeamsData[v]
            self._tableView:updateCellAtIndex(k - 1)
        end
    end
    self._curSelectTeam = tempTeamsData[self._curSelectTeam.teamId]

    self:reflashTeamUI()
    
end

-- awakingActivate 觉醒
function TeamView:awakingActivate()
    local oldTeamData = clone(self._curSelectTeam)
    -- self._viewMgr:showDialog("team.TeamAwakenSuccessDialog", param)
    self._serverMgr:sendMsg("AwakingServer", "awakingActivate", {}, true, {}, function (result)
        dump(result, "result ===", 10)
        local newteamData = self._teamModel:getTeamAndIndexById(self._curSelectTeam.teamId)
        local callback = function()
            self:setUpdateTeam(0, 0, 0, false, true)
            self:updateTeamAmin()
        end
        local param = {teamId = self._curSelectTeam.teamId, old = oldTeamData, new = newteamData, callback = callback}
        self._viewMgr:showDialog("team.TeamAwakenAnimDialog", param)
    end)
end


-- 开启觉醒任务
function TeamView:openAwakingTask()
    local param = {teamId = self._curSelectTeam.teamId}
    self._serverMgr:sendMsg("AwakingServer", "openAwakingTask", param, true, {}, function (result)
        -- dump(result, "result ===", 10)
        local selectTeamData = self._teamModel:getTeamAndIndexById(self._curSelectTeam.teamId)
        dump(selectTeamData, "tttttttttt")
        print("跳转到任务") 
    end)
end

function TeamView:onFristReflashTeams(_type)
    local teamModel = self._modelMgr:getModel("TeamModel")
    if not _type then
        teamModel:setTeamMap(self._teamModel:getData())
    else
        self._teamModel:setTeamMap(self._teamModel:getClassTeam(_type))
    end
    self._teamsMap = self._teamModel:getTeamMap()

    if self._teamsMap == nil or next(self._teamsMap) == nil then
        local userInfo = self._modelMgr:getModel("UserModel"):getData()
        self._viewMgr:onLuaError(serialize({userId = userInfo._id, msg = "team is empty"}))
        -- print("TeamView:onFristReflashTeams() self._curSelectTeam error")
    end
    if self._curSelectTeam == nil then 
        self._curSelectIndex = 0
        local tempTeamId = self._teamsMap[self._curSelectIndex + 1]
        self._curSelectTeam = self._teamsMapData[tempTeamId]
        -- self._curSelectTeam = self._teamsData[self._curSelectIndex + 1]
    end
    
    local tempTeamData, tempTeamIndex = teamModel:getTeamAndIndexById(self._curSelectTeam.teamId)
    -- 判断是否没有找到之前的当前team 如果未找到重置当前界面
    self._curSelectTeam = tempTeamData
    self._curSelectIndex = tempTeamIndex - 1
    self._curSelectSysTeam = tab:Team(self._curSelectTeam.teamId)
    -- print("=======", self._curSelectTeam.teamId)
    if self._isReflashTeamList == true then
        self._tableView:reloadData()
        self:scrollToNext(self._curSelectIndex - 1, false)
        self._isReflashTeamList =false
    end
    self._firstFight = true
    self:reflashTeamUI()
end

function TeamView:updateBiaoqian()
    if self._curSelectTeam.avn == 1 then
        self._titleNames = {
            " 进阶",
            " 升级",
            " 潜能",
            " 技能",
            " 关联",
            " 专属",
        }
        self._shortTitleNames = {
            " 进阶",
            " 升级",
            " 潜能",
            " 技能",
            " 关联",
            " 专属",
        }
    else
        self._titleNames = {
            " 进阶",
            " 升级",
            " 升星",
            " 技能",
            " 关联",
            " 专属",
        }
        self._shortTitleNames = {
            " 进阶",
            " 升级",
            " 升星",
            " 技能",
            " 关联",
            " 专属",
        }
    end
    local tab3 = self:getUI("bg1.rightSubBg.tab3")
    if tab3 then
        local tabStr = self._shortTitleNames[3]
        if self._index == 3 then
            tabStr = self._titleNames[3]
        end
        tab3:setTitleText(tabStr)
    end
end

-- 觉醒按钮动画
-- 开启觉醒 动画1
-- 跳转到任务  动画2
-- 可觉醒动画  动画3
function TeamView:updateAwakingAnim(teamData)
    local state = self._teamModel:getTeamAwakingState(teamData)
    local awakingBtn = self:getUI("bg1.awakingBtn")
    local eyeAnim1 = awakingBtn:getChildByFullName("eyeAnim1")
    if not eyeAnim1 then
        eyeAnim1 = mcMgr:createViewMC("juexing1_juexingtubiao", true, false)
        eyeAnim1:setPosition(awakingBtn:getContentSize().width*0.5, awakingBtn:getContentSize().height*0.5)
        eyeAnim1:setName("eyeAnim1")
        awakingBtn:addChild(eyeAnim1,5)
    end
    local eyeBgAnim1 = awakingBtn:getChildByFullName("eyeBgAnim1")
    if not eyeBgAnim1 then
        eyeBgAnim1 = mcMgr:createViewMC("lingzhushouce_lianmengjihuo", true, false) 
        eyeBgAnim1:setScale(1.2)
        eyeBgAnim1:setPosition(cc.p(awakingBtn:getContentSize().width*0.5, awakingBtn:getContentSize().height*0.5))
        eyeBgAnim1:setName("eyeBgAnim1")
        awakingBtn:addChild(eyeBgAnim1)
    end
    local eyeAnim2 = awakingBtn:getChildByFullName("eyeAnim2")
    if not eyeAnim2 then
        eyeAnim2 = mcMgr:createViewMC("juexing2_juexingtubiao", true, false)
        eyeAnim2:setName("eyeAnim2")
        eyeAnim2:setPosition(awakingBtn:getContentSize().width*0.5, awakingBtn:getContentSize().height*0.5)
        awakingBtn:addChild(eyeAnim2,5)
    end
    local eyeBgAnim2 = awakingBtn:getChildByFullName("eyeBgAnim2")
    if not eyeBgAnim2 then
        eyeBgAnim2 = cc.Label:createWithTTF("觉醒中", UIUtils.ttfName, 16)
        eyeBgAnim2:setAnchorPoint(0, 0.5)
        eyeBgAnim2:setPosition(0, awakingBtn:getContentSize().height*0.5+50)
        eyeBgAnim2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        eyeBgAnim2:setName("eyeBgAnim2")
        awakingBtn:addChild(eyeBgAnim2, 3)
        local count = 0
        local awakLab = {[0] = "觉醒中", "觉醒中.", "觉醒中..", "觉醒中..."}
        local callFunc = cc.CallFunc:create(function()
            local idx = math.fmod(count, 4)
            local str = awakLab[idx]
            count = count + 1
            eyeBgAnim2:setString(str)
        end)
        local seq = cc.Sequence:create(callFunc, cc.DelayTime:create(0.3))
        eyeBgAnim2:runAction(cc.RepeatForever:create(seq))
    end
    local eyeAnim3 = awakingBtn:getChildByFullName("eyeAnim3")
    if not eyeAnim3 then
        eyeAnim3 = mcMgr:createViewMC("juexingtubiao_juexingtubiao", true, false)
        eyeAnim3:setName("eyeAnim3")
        eyeAnim3:setPosition(awakingBtn:getContentSize().width*0.5, awakingBtn:getContentSize().height*0.5)
        awakingBtn:addChild(eyeAnim3,5)
    end
    local eyeBgAnim3 = awakingBtn:getChildByFullName("eyeBgAnim3")
    if not eyeBgAnim3 then
        eyeBgAnim3 = mcMgr:createViewMC("buffguangxiaoxia_duizhanui", true, false) 
        eyeBgAnim3:setScale(0.7)
        eyeBgAnim3:setPosition(cc.p(awakingBtn:getContentSize().width*0.5, awakingBtn:getContentSize().height*0.5-10))
        eyeBgAnim3:setName("eyeBgAnim3")
        awakingBtn:addChild(eyeBgAnim3)
    end
    print("state=========", state)
    -- state = 5
    self:setHintTip(awakingBtn, false)

    if state == 1 then
        eyeAnim1:setVisible(true)
        eyeBgAnim1:setVisible(false)
        eyeAnim2:setVisible(false)
        eyeBgAnim2:setVisible(false)
        eyeAnim3:setVisible(false)
        eyeBgAnim3:setVisible(false)
    elseif state == 2 then
        if self._firstGuide == true then
            GuideUtils.checkTriggerByType("action", "16")
            self._firstGuide = false
        end
        eyeAnim1:setVisible(true)
        eyeBgAnim1:setVisible(true)
        eyeAnim2:setVisible(false)
        eyeBgAnim2:setVisible(false)
        eyeAnim3:setVisible(false)
        eyeBgAnim3:setVisible(false)
    elseif state == 3 then
        eyeAnim1:setVisible(false)
        eyeBgAnim1:setVisible(false)
        eyeAnim2:setVisible(true)
        eyeBgAnim2:setVisible(true)
        eyeAnim3:setVisible(false)
        eyeBgAnim3:setVisible(false)
    elseif state == 4 then
        eyeAnim1:setVisible(false)
        eyeBgAnim1:setVisible(false)
        eyeAnim2:setVisible(false)
        eyeBgAnim2:setVisible(false)
        eyeAnim3:setVisible(true)
        eyeAnim3:gotoAndPlay(1)
        eyeBgAnim3:setVisible(true)
    elseif state == 5 then
        eyeAnim1:setVisible(false)
        eyeBgAnim1:setVisible(false)
        eyeAnim2:setVisible(false)
        eyeBgAnim2:setVisible(false)
        eyeAnim3:setVisible(true)
        eyeAnim3:gotoAndStop(1)
        eyeBgAnim3:setVisible(false)
        if teamData.onTree == 1 or teamData.onTree == 2 then
            self:setHintTip(awakingBtn, true)
        else
            self:setHintTip(awakingBtn, false)
        end
    else
        eyeAnim1:setVisible(false)
        eyeBgAnim1:setVisible(false)
        eyeAnim2:setVisible(false)
        eyeBgAnim2:setVisible(false)
        eyeAnim3:setVisible(false)
        eyeBgAnim3:setVisible(false)
    end


end 

-- function TeamView:checkTree(inTeam, sysTeamData)
--     local flag = 0
--     -- 是否可觉醒
--     local state = self._modelMgr:getModel("TeamModel"):getTeamAwakingState(inTeam)
--     -- print("state========", state)
--     if state == 4 or state == 2 then
--         flag = 1
--         return flag
--     end
--     -- dump(inTeam)
--     -- 是否可选择
--     if state == 5 then
--         if flag == 0 then
--             local awakingLimit = tab:Setting("AWAKINGLIMIT").value
--             local branchData = inTeam.tree
--             local teamStage = inTeam.stage
--             local tskill = sysTeamData.skill 
--             for tree=1,3 do
--                 local talentTree = sysTeamData["talentTree" .. tree]
--                 local _tskill = tskill[talentTree[1]]
--                 if teamStage >= awakingLimit[tree] then
--                     if branchData["b" .. tree] == 0 then
--                         flag = 1
--                         break
--                     end
--                 end
--             end
--         end
--         if flag == 0 then
--             local purpleStar = inTeam.aLvl
--             local yellowStar = inTeam.star 
--             local itemId = sysTeamData.awakingUp
--             local awakingUpTab = sysTeamData.awakingUpNum
--             local costNum = awakingUpTab[purpleStar]
--             local _, tempItemCount = self._modelMgr:getModel("ItemModel"):getItemsById(itemId)
--             if costNum and tempItemCount >= costNum then
--                 if purpleStar < yellowStar then
--                     flag = 2
--                 end
--             end
--         end
--     end
--     print("flag======", flag)
--     return flag
-- end



-- 刷新整体数据
function TeamView:reflashTeamUI()
    local teamTab = tab.team[self._curSelectTeam.teamId]
    local awakingBtn = self:getUI("bg1.awakingBtn")
    awakingBtn:setVisible(false)

    self:updateExclusiveState()
    if self._exclusiveFlag ~= 0 and self._preBtn and self._preBtn:getName() == "tab6" then
        self:tabButtonClick(self:getUI("bg1.rightSubBg.tab4"), 4)
    end

    local flag = self._teamModel:getAwakingOpen(self._curSelectTeam.teamId)
    if flag == true then
        awakingBtn:setVisible(true)
        self:updateAwakingAnim(self._curSelectTeam)
    end

    self._teamSkinBtn:setVisible(self._teamModel:checkTeamSkin(self._curSelectTeam.teamId))

    self._firstGuide = false
    -- 觉醒666
    awakingBtn:setScaleAnim(true)
    self:registerClickEvent(awakingBtn, function()
        -- dump(self._curSelectTeam)
        -- if true then
        --     local sysTeamData = tab:Team(self._curSelectTeam.teamId)
        --     self:checkTree(self._curSelectTeam, sysTeamData)
        --     return
        -- end
        local ast = self._curSelectTeam.ast
        print("params =============", ast)
        -- ast = 0
        if (not ast) or ast == 0 then -- 开启觉醒
            local param = {teamId = self._curSelectTeam.teamId} 
            -- self._viewMgr:showDialog("team.TeamAwakenOpenTaskDialog", param)
            self._viewMgr:showDialog("team.TeamAwakenShowDialog", param)
        elseif ast and ast == 1 then -- 跳转到任务
            print("跳转到任务") 
            ViewManager:getInstance():switchView("task.TaskView",{viewType = 1000})
        elseif ast and ast == 2 then -- 觉醒动画
            self:awakingActivate()
            -- local oldTeamData = clone(self._curSelectTeam)
            -- local newteamData = self._teamModel:getTeamAndIndexById(self._curSelectTeam.teamId)
            -- local param = {teamId = self._curSelectTeam.teamId, old = oldTeamData, new = newteamData}
            -- self._viewMgr:showDialog("team.TeamAwakenAnimDialog", param)
        elseif ast and ast == 3 then -- 选择觉醒树
            local param = {teamId = self._curSelectTeam.teamId}
            self._viewMgr:showDialog("team.TeamAwakenDialog", param)
        end
    end)

    -- if self._curSelectTeam.teamId == 202 then
        -- dump(self._curSelectTeam) 
    -- end
    -- self._zhandouliLab = self._assess:getChildByFullName("fight")
    -- self._zhandouliLab:setFntFile(UIUtils.bmfName_team_fight) 
    self:updateBiaoqian()
    if self._firstFight == true then
        self._zhandouliLab:setString(self._curSelectTeam.score)
        self._firstFight = false
    end
    ScheduleMgr:delayCall(1000, self, function()
        if not self._zhandouliLab then return end
        self._zhandouliLab:setString(self._curSelectTeam.score)
    end)

    local userInfo = self._modelMgr:getModel("UserModel"):getData()

    if self._curSelectTeam.newFlag == 1 then
        self._curSelectTeam.newFlag = 0
        local tempTeamData = {}
        tempTeamData[self._curSelectTeam.teamId] = self._curSelectTeam
        local teamModel = self._modelMgr:getModel("TeamModel")
        teamModel:updateTeamData(tempTeamData)
    end

    local sysTeam = tab:Team(self._curSelectTeam.teamId)
    local barBg 
    local str1,str2,temp

    local teamModel = self._modelMgr:getModel("TeamModel")
    local itemModel = self._modelMgr:getModel("ItemModel")

    if self._infoNode ~= nil and self._infoNode:isVisible() == true then 
        self._infoNode:reflashUI(self._curSelectTeam)
    end
    if self._upStarNode ~= nil and self._upStarNode:isVisible() == true then
        self._upStarNode:reflashUI({teamData = self._curSelectTeam})
        -- self._upStarNode:reflashUI(self._curSelectTeam)
    end
    if self._gradeNode ~= nil and self._gradeNode:isVisible() == true then
        local aminBg = self:getUI("panelBg.teamImgBg")
        self._gradeNode:reflashUI(self._curSelectTeam,aminBg)
        -- self._gradeNode:reflashUI({teamData = self._curSelectTeam, starPos = self._starPos})
    end
    if self._skillNode ~= nil and self._skillNode:isVisible() == true then
        self._skillNode:reflashUI({teamData = self._curSelectTeam, refTop = true})
    end
    if self._heroNode ~= nil and self._heroNode:isVisible() == true then
        self._heroNode:reflashUI({teamData = self._curSelectTeam})
    end

    if self._exclusiveNode ~= nil and self._exclusiveNode:isVisible() == true and self._exclusiveFlag == 0 then
        self._exclusiveNode:reflashUI({teamData = self._curSelectTeam})
    end

    self:refreshTeamBigStar(self._curSelectTeam.star)
    -- dump(self._starPos,"self._starPos")
    local starBg = self:getUI("nameBg.Panel_33")
    local nameBg = self:getUI("nameBg")


    local teamName, art1, art2, art3 = TeamUtils:getTeamAwakingTab(self._curSelectTeam, self._curSelectTeam.teamId)
    local sysLangName = lang(teamName)
    -- 名称
    local nameLab = self:getUI("nameBg.nameLab")
    nameLab:setString(sysLangName)
    -- nameLab:setAnchorPoint(cc.p(0, 0.5))

    local levelLab = self:getUI("nameBg.level")
    levelLab:setString("Lv." ..self._curSelectTeam.level)
    -- levelLab:setAnchorPoint(cc.p(0, 0.5))

    -- 阶显示处理
    local backQuality = teamModel:getTeamQualityByStage(self._curSelectTeam.stage)
    -- local gemAllWidth = nameBg:getContentSize().width - levelLab:getContentSize().width - nameLab:getContentSize().width - starBg:getContentSize().width
    local iconGem = self:getUI("nameBg.nameStage")  --nameBg:getChildByFullName("gem" .. i)
    nameLab:setColor(UIUtils.colorTable["ccColorQuality" .. backQuality[1]])
    if backQuality[2] ~= 0 then 
        iconGem:setVisible(true)
        iconGem:setString("+" .. backQuality[2])
        iconGem:setAnchorPoint(cc.p(0, 0.5))
        iconGem:setColor(UIUtils.colorTable["ccColorQuality" .. backQuality[1]])

        -- gemAllWidth = gemAllWidth - iconGem:getContentSize().width
    else
        if iconGem ~= nil then
            iconGem:setVisible(false)
        end
    end
    local beginX = 0
    -- local beginX  = gemAllWidth / 2 + 20
    -- levelLab:setPositionX(beginX)
    beginX = levelLab:getPositionX() + levelLab:getContentSize().width + 8
    nameLab:setPositionX(beginX)
    beginX = nameLab:getPositionX() + nameLab:getContentSize().width+2
    iconGem:setPositionX(beginX)

    if OS_IS_WINDOWS then
        nameLab:setString(sysLangName .. "    [" .. self._curSelectTeam.teamId .. "]")
    end

    local volume = self:getUI("bg2.volume")
    volume:setString("人数: " .. self._curSelectTeam.volume)

    local isAwaking, aLvl = TeamUtils:getTeamAwaking(self._curSelectTeam)
    local zizhi = self:getUI("bg2.zizhi")
    local zizhi_16 = self:getUI("bg2.zizhi_16")
    local sysTeamData = tab:Team(self._curSelectTeam.teamId)
    if sysTeamData.zizhi == 4 then
        zizhi_16:setVisible(true)
        zizhi:setVisible(false)
        local zizhiAnim = zizhi_16:getChildByFullName("anim16")
        if not zizhiAnim then
            zizhiAnim = mcMgr:createViewMC("shenpanguanbiaoqian_shenpanguanbiaoqian", true, false)
            zizhiAnim:setPosition(zizhi_16:getContentSize().width / 2 + 2, zizhi_16:getContentSize().height / 2 + 15)
            zizhiAnim:setName("anim16")
            zizhi_16:addChild(zizhiAnim, 2)
        end
        zizhiAnim:setVisible(true)
    else
        zizhi:setString(TeamConst.TEAM_ZIZHI_TYPE["ZIZHI_" .. sysTeamData.zizhi])
        zizhi:setVisible(true)
        zizhi_16:setVisible(false)
    end

    local classLabelIcon = self:getUI("nameBg.icon")
    --此处和其他地方不一样 配表字段 classlabel1
    local className = TeamUtils:getClassIconNameByTeamD(self._curSelectTeam, "classlabel1")
    classLabelIcon:loadTexture(IconUtils.iconPath .. className .. ".png", 1)
    self:registerClickEvent(classLabelIcon, function()
        self._viewMgr:showDialog("team.TeamGradeDialog", {classlabel = self._curSelectTeam.teamId})
    end)
    -- TeamUtils.showTeamLabelTip(classLabelIcon, 7, self._curSelectTeam.teamId)
    
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local flagMaxLevel = 0
    local flagMaxGold = 0
    local flagLevel = 0
    local sysEquipmentLevel
    for k,v in pairs(self._curSelectSysTeam.equip) do
        local sysEquip = tab:Equipment(v)
        local tempEquipLevel = table.nums(tab.equipmentLevel)
        if (self._curSelectTeam["el" .. k] + 1) <= tempEquipLevel then
            sysEquipmentLevel = tab:EquipmentLevel(self._curSelectTeam["el" .. k] + 1)
        else
            sysEquipmentLevel = nil
        end
        if (sysEquipmentLevel == nil) then 
            flagMaxLevel = flagMaxLevel + 1
        else
            if userData.gold > sysEquipmentLevel.cost then 
                flagMaxGold= flagMaxGold + 1
            end
            if self._curSelectTeam.level == self._curSelectTeam["el" .. k] then 
                flagLevel = flagLevel + 1
            end
        end
    end

    -- self:setTeamImgAction()
    self:updateTip()
    self:updateTeamBoost()
end

-- 判断是否滑动到结束
function TeamView:scrollViewDidScroll(view)
    self._inScrolling = view:isDragging()
    local tempPos = view:getContentSize().width + view:getContainer():getPositionX()
    -- print("==============",tempPos, view:getContainer():getPositionX(), view:getContentSize().width)
    -- down left
    -- up   right
    if view:getContainer():getPositionX() == 0 then
        if view:getContentSize().width < 960 then
            self._up:setVisible(false)
            self._down:setVisible(false)
        else
            self._up:setVisible(true)
            self._down:setVisible(false)
        end
    elseif tempPos <= 960 then
        if view:getContentSize().width < 960 then
            self._up:setVisible(false)
            self._down:setVisible(false)
        else
            self._up:setVisible(false)
            self._down:setVisible(true)
        end
    elseif tempPos == 1036 then
        if view:getContentSize().width < 960 then
            self._up:setVisible(false)
            self._down:setVisible(false)
        else
            self._up:setVisible(false)
            self._down:setVisible(true)
        end
    elseif view:getContentSize().width > 960 then
        self._up:setVisible(true)
        self._down:setVisible(true)
    end
end

-- 触摸时调用
function TeamView:tableCellTouched(table,cell)
    local tempCell = table:cellAtIndex(self._curSelectIndex)
    if tempCell ~= nil then 
        tempCell:switchListItemState(false)
    end
    cell:switchListItemState(true)

    self._curSelectIndex = cell:getIdx()
    audioMgr:playSound("click")
    -- local tempTeam = self._teamsData[1 + cell:getIdx()]
    local tempTeamId = self._teamsMap[cell:getIdx() + 1]
    local tempTeam = self._teamsMapData[tempTeamId] or {}
    -- local tempTeam = self._teamsData[cell:getIdx() + 1]
    -- local tempTeam = self._teamsData[#self._teamsData - cell:getIdx()]
    -- print("=========",tempTeam.teamId , self._curSelectTeam.teamId)
    if tempTeam.teamId == self._curSelectTeam.teamId then 
        return 
    end
    self._curSelectTeam = tempTeam
    self._curSelectSysTeam = tab:Team(self._curSelectTeam.teamId)
    self:setTeamImgAction1()
    self._firstFight = true
    self:reflashTeamUI()
    self:updateTeamAmin()
end

-- cell的尺寸大小
function TeamView:cellSizeForTable(table,idx) 
    return 110,110
end

-- 创建在某个位置的cell
function TeamView:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()

    local tempTeamId = self._teamsMap[idx + 1]
    local teamData = self._teamsMapData[tempTeamId]
    -- local teamData = self._teamsData[idx + 1]
    -- print("===============", #self._teamsData , idx, #self._teamsData - idx)
    -- local teamData = self._teamsData[#self._teamsData - idx]
    -- teamData.index = idx + 1
    if nil == cell then
        -- cell = self:createLayer("team.TeamItemCell")
        cell = require("game.view.team.TeamItemCell"):new()
    end
    -- cell:setName("Celll.index" .. idx)
    cell:reflashUI(teamData)
    -- print("=============", self._curSelectIndex + 1,(idx + 1))
    if self._curSelectIndex == idx then 
        cell:switchListItemState(true)
    else
        cell:switchListItemState(false)
    end
    return cell
end

-- 返回cell的数量
function TeamView:numberOfCellsInTableView(table)
   return #self._teamsMap
end

-- 滑动偏移处理
function TeamView:scrollToNext( selectedIndex, isAnimated )
    if(isAnimated == nil) then
        isAnimated = true
    end
    local animatedDuration = 0
    if(isAnimated) then
        animatedDuration = 0.2
    end
    -- print("========", selectedIndex, isAnimated)
    local tempWidth = 110*(#self._teamsMap) -- self._tableView:getContentSize().width
    local downBg = self:getUI("downBg.Panel_46")
    -- print("====",#self._teamsData, tempWidth ,downBg:getContentSize().width)
    local maxWidth = self._teamWidth - 70
    if tempWidth < maxWidth then
        self._tableView:setContentOffset(cc.p(0, 0))
    elseif selectedIndex < 0 then
        self._tableView:setContentOffset(cc.p(-(selectedIndex+1)*110, 0))
    else
        if (tempWidth - (selectedIndex)*110) > maxWidth then
            self._tableView:setContentOffset(cc.p(-(selectedIndex)*110, 0))
        else
            self._tableView:setContentOffset(cc.p(-(tempWidth-maxWidth), 0))
        end
    end
    
    -- self._tableView:setContentOffset(cc.p(-(selectedIndex)*110, 0))
    -- self._tableView:setContentOffsetInDuration(cc.p(selectedIndex*110 , 0), animatedDuration)
end

function TeamView:getMaxPingding(param,tempIndex,tempNum)
    local tempPing = {}
    table.insert(tempPing, {tempIndex,tempNum})
    local tempIndex1,tempNum1 = 0, 0
    for i=1,4 do
        if i ~= tempIndex then
            if param[i] == tempNum then
                tempIndex1 = i
                tempNum1 = param[i] 
                table.insert(tempPing, {tempIndex1,tempNum1})
                tempIndex1,tempNum1 = 0, 0
            end
        end
    end
    return tempPing
end

-- -- 战斗力评定
-- function TeamView:createPingding(count,check,max)
--     local beginX = -3
--     local barBg = self._assess:getChildByFullName("check" .. count .. ".progressBg") 
--     local pingBar
--     local posX = 0
--     for i=1,check do
--         pingBar = barBg:getChildByName("bar" .. i)
--         if pingBar then
--             pingBar:setVisible(true)
--             if max == true then
--                 pingBar:setSpriteFrame("globalImageUI6_teamImg3.png")
--             else
--                 pingBar:setSpriteFrame("globalImageUI_teamImg1.png")
--             end
--         else
--             pingBar = cc.Sprite:createWithSpriteFrameName("globalImageUI_teamImg1.png")
--             pingBar:setName("bar" .. i)
--             posX = beginX + 8 * i
--             pingBar:setPosition(posX,7)
--             barBg:addChild(pingBar)
--         end
--     end
-- end

function TeamView:refreshTeamBigStar(bigStarNum)
-- 设置星
    local bigStarOpen = self._modelMgr:getModel("TeamModel"):getBigStar()
    if bigStarOpen == true then
        bigStarNum = bigStarNum - 1
    end
    local starBg = self:getUI("nameBg.Panel_33")
    local starx = starBg:getContentSize().width - 25
    local stary = starBg:getContentSize().height + 5
    local isAwaking, aLvl = TeamUtils:getTeamAwaking(self._curSelectTeam)
    print("bigStarNum========", bigStarNum, aLvl)
    if isAwaking == true then
        for i= 1 , 6 do
            local iconStar = starBg:getChildByName("star" .. i)
            if i <= 6 - bigStarNum then 
                local fileName = "globalImageUI6_star2.png"
                if i > 6 - aLvl then
                    fileName = "globalImageUI_teamskillBigStar2.png"
                end
                if iconStar == nil then
                    iconStar = cc.Sprite:createWithSpriteFrameName(fileName)
                    -- iconStar:setScale(0.6)
                    iconStar:setAnchorPoint(cc.p(0.5, 1))
                    starBg:addChild(iconStar,3) 
                    -- iconStar:setScale(0.7)
                    iconStar:setName("star" .. i)
                    iconStar:setPosition(starx, stary)
                    starx = starx - iconStar:getContentSize().width * iconStar:getScale() /2 - 5
                else
                    iconStar:setSpriteFrame(fileName)
                end
            else
                local fileName = "globalImageUI6_star1.png"
                if i > 6 - aLvl then
                    fileName = "globalImageUI_teamskillBigStar1.png"
                end
                if iconStar == nil then
                    iconStar = cc.Sprite:createWithSpriteFrameName(fileName)
                    -- iconStar:setScale(0.6)
                    iconStar:setAnchorPoint(cc.p(0.5, 1))
                    starBg:addChild(iconStar,3)                -- iconStar:setScale(0.7)
                    iconStar:setName("star" .. i)
                    iconStar:setPosition(starx, stary)
                    starx = starx - iconStar:getContentSize().width * iconStar:getScale()/2 - 5
                else
                    iconStar:setSpriteFrame(fileName)
                end
            end
        end
    else
        for i= 1 , 6 do
            local iconStar = starBg:getChildByName("star" .. i)
            if i <= 6 - bigStarNum then 
                if iconStar == nil then
                    iconStar = cc.Sprite:createWithSpriteFrameName("globalImageUI6_star2.png")
                    -- iconStar:setScale(0.6)
                    iconStar:setAnchorPoint(cc.p(0.5, 1))
                    starBg:addChild(iconStar,3) 
                    -- iconStar:setScale(0.7)
                    iconStar:setName("star" .. i)
                    iconStar:setPosition(starx, stary)
                    starx = starx - iconStar:getContentSize().width * iconStar:getScale() /2 - 5
                else
                    iconStar:setSpriteFrame("globalImageUI6_star2.png")
                end
            else
                if iconStar == nil then
                    iconStar = cc.Sprite:createWithSpriteFrameName("globalImageUI6_star1.png")
                    -- iconStar:setScale(0.6)
                    iconStar:setAnchorPoint(cc.p(0.5, 1))
                    starBg:addChild(iconStar,3)                -- iconStar:setScale(0.7)
                    iconStar:setName("star" .. i)
                    iconStar:setPosition(starx, stary)
                    starx = starx - iconStar:getContentSize().width * iconStar:getScale()/2 - 5
                else
                    iconStar:setSpriteFrame("globalImageUI6_star1.png")
                end
            end
        end
    end
end

-- 更新军团展示怪兽
function TeamView:updateTeamAmin()
    local backBgNode = self._aminBg:getChildByName("backBgNode")
    local sysTeamData = tab:Team(self._curSelectTeam.teamId)
    local pos = sysTeamData.xiaoren
    local teamBg = self:getUI("bg2.teamBg")
    if teamBg then
        teamBg:loadTexture("asset/uiother/dizuo/teamBgDizuo" .. tab:Team(self._curSelectTeam.teamId)["race"][1] .. ".png", 0)
    end

    local isAwaking, aLvl = TeamUtils:getTeamAwaking(self._curSelectTeam)
    local zizhiBg = self:getUI("bg2.Image_40")
    local poss = cc.p(2, 38)
    if zizhiBg then
        local zzImg = "teamImageUI_img29.png"
        if isAwaking == true then
            zzImg = "TeamAwakenImageUI_img23.png"
            if sysTeamData.zizhi == 4 then
                zzImg = "TeamAwakenImageUI_img23.png"
            end
        else
            if sysTeamData.zizhi == 4 then
                zzImg = "TeamzizhiBg16.png"
                poss = cc.p(0, 48)
            end
        end
        zizhiBg:loadTexture(zzImg, 1)
        zizhiBg:setPosition(poss)
    end

    local teamName, art1, art2, steam = TeamUtils:getTeamAwakingTab(self._curSelectTeam, self._curSelectTeam.teamId)
    if backBgNode then
        backBgNode:setTexture("asset/uiother/steam/"..steam..".png")
    else
        backBgNode = cc.Sprite:create("asset/uiother/steam/"..steam..".png")
        -- backBgNode:setAnchorPoint(cc.p(0.5, 0))
        -- backBgNode:setPosition(cc.p(self._aminBg:getContentSize().width/2, 0)) --self._aminBg:getContentSize().height/2 - 10))
        backBgNode:setAnchorPoint(cc.p(0.5, 0))
         --self._aminBg:getContentSize().height/2 - 10))
        backBgNode:setScale(0.5)
        backBgNode:setName("backBgNode")
        self._aminBg:addChild(backBgNode)
    end
    backBgNode:setPosition(cc.p(self._aminBg:getContentSize().width/2+pos[1], pos[2]-10))
end

-- 选项卡状态切换
function TeamView:tabButtonState(sender, isSelected, key)
    local titleNames = self._titleNames
    local shortTitleNames = self._shortTitleNames

    local tabtxt = sender:getChildByFullName("tabtxt")
    tabtxt:setString("")

    sender:setBright(not isSelected)
    sender:setEnabled(not isSelected)
    sender:getTitleRenderer():disableEffect()
    -- sender:setTitleFontSize(32)
    if isSelected then
        sender:setTitleText(titleNames[key])
        sender:setTitleColor(UIUtils.colorTable.ccUITabColor2)
    else
        sender:setTitleText(shortTitleNames[key])
        sender:setTitleColor(UIUtils.colorTable.ccUITabColor1)
    end
end

-- function TeamView:tabButtonState(sender, isSelected)
--     -- local tabtxt01 = sender:getChildByFullName("tabtxt_01")
--     -- local tabtxt02 = sender:getChildByFullName("tabtxt_02")
--     local tabtxt = sender:getChildByFullName("tabtxt")
--     -- tabtxt:setFontName(UIUtils.ttfName)

--     sender:setBright(not isSelected)
--     sender:setEnabled(not isSelected)
--     -- tabtxt01:setVisible(not isSelected)
--     -- tabtxt02:setVisible( isSelected)
--     if isSelected then
--         tabtxt:setColor(cc.c3b(145,105,50))
--         tabtxt:setPositionX(75)
--         tabtxt:setFontSize(32)
--     else
--         tabtxt:setColor(cc.c3b(240,200,145))
--         tabtxt:setPositionX(95)
--         tabtxt:disableEffect()
--         tabtxt:setFontSize(32)
--     end
-- end


function TeamView:setBigStarPos()
    local starBg = self:getUI("nameBg.Panel_33")
    for i= 1 , 6 do
        local iconStar = starBg:getChildByName("star" .. i)
        if iconStar then
            local tempPos = iconStar:convertToWorldSpace(cc.p(iconStar:getContentSize().width/2,iconStar:getContentSize().height/2))
            self._starPos[7-i] = {}
            self._starPos[7-i].posX = tempPos.x
            self._starPos[7-i].posY = tempPos.y
        end
    end
end

function TeamView:tabButtonClick(sender, key)
    -- sender = nil 
    -- local teamImgBg = self:getUI("teamImgBg")
    -- TeamUtils:setFightAnim(teamImgBg, {oldFight = 1020, newFight = 1023, x = 200, y = 450})
    if sender == nil then 
        return 
    end
    if self._tabName == sender:getName() then 
        return 
    end

    if sender:getName() == "tab6" and self._exclusiveFlag ~= 0 then
        UIUtils:tabTouchAnimOut(sender)
        self._viewMgr:showTip(self._exclusiveFlag)
        return
    end
    for k,v in pairs(self._tabEventTarget) do
        if v ~= sender then
            self:tabButtonState(v, false, k)
        end
    end
    local isFirst = not self._preBtn
    if self._preBtn then
        UIUtils:tabChangeAnim(self._preBtn,nil,true,true)
    else
        self:switchPanel( sender,key )
    end
    self._preBtn = sender
    UIUtils:tabChangeAnim(sender,function( )
        self:tabButtonState(sender, true, key)
        -- if not isFirst then
        ScheduleMgr:delayCall(5, self, function( )
            if not self.switchPanel then return end
            self:switchPanel( sender,key )
        end)
        -- end
    end,nil,true)


end

function TeamView:switchPanel( sender,key )
    -- for k,v in pairs(self._tabEventTarget) do
    --     if v:getName() ~= sender:getName() then 
    --         self:tabButtonState(v, false)
    --     end
    -- end
    -- self:tabButtonState(sender, true)
    local tempBaseInfoNode = self:getUI("bg1.rightSubBg")
    if sender:getName() == "tab1" then
        self._index = 1
        if self._infoNode == nil then 
            -- self._infoNode = self:getUI("bg.rightBg.vessel")--self:createLayer("team.TeamInfoNode")
            -- self:reflashsysTeamUI()
            self._infoNode = self:createLayer("team.TeamLiftingNode", {fightCallback = function(inTable) self:setFightAnim(inTable) end})
            tempBaseInfoNode:addChild(self._infoNode,5)
        end
        -- self:reflashsysTeamUI()
        -- self:reflashsysTeamUI(self._curSelectTeam) -- reflashData(self._curSelectTeam)
        self._infoNode:reflashUI(self._curSelectTeam)
        self._infoNode:setVisible(true)
        -- self._aminBg:setVisible(true)
        -- self._upStarBg:setVisible(false)
        if self._upStarNode ~= nil then 
            self._upStarNode:setVisible(false)
            -- self._upStarBg:setVisible(false)
        end
        if self._gradeNode ~= nil then 
            self._gradeNode:setVisible(false)
        end
        if self._skillNode ~= nil then 
            self._skillNode:setVisible(false)
        end
        if self._heroNode ~= nil then 
            self._heroNode:setVisible(false)
        end
        if self._exclusiveNode ~= nil then
            self._exclusiveNode:setVisible(false)
        end
    elseif sender:getName() == "tab2" then 
        -- print("升级")
        self._index = 2
        if self._gradeNode == nil then 
            local attr = self:getUI("attr")
            self._gradeNode = self:createLayer("team.TeamGradeNode", {attr = attr, fightCallback = function(inTable) self:setFightAnim(inTable) end})
            tempBaseInfoNode:addChild(self._gradeNode,5)
        end
        local aminBg = self:getUI("panelBg.teamImgBg")
        self._gradeNode:reflashUI(self._curSelectTeam, aminBg)
        -- self._gradeNode:setPianyi()
        -- self._gradeNode:getTipCount()
        self._gradeNode:setVisible(true)
        -- self._aminBg:setVisible(true)
        -- self._upStarBg:setVisible(false)

        if self._upStarNode ~= nil then 
            -- print("==============",self._upStarNode)
            self._upStarNode:setVisible(false)
            -- self._upStarBg:setVisible(false)
        end
        if self._infoNode ~= nil then 
            self._infoNode:setVisible(false)
        end
        if self._skillNode ~= nil then 
            self._skillNode:setVisible(false)
        end
        if self._heroNode ~= nil then 
            self._heroNode:setVisible(false)
        end
        if self._exclusiveNode ~= nil then
            self._exclusiveNode:setVisible(false)
        end
    elseif sender:getName() == "tab3" then 
        self._index = 3
        -- print("升星暂未开放")
        -- self._viewMgr:showTip("升星暂未开放")
        if self._upStarNode == nil then 
            self:setBigStarPos()
            local starTip = self:getUI("starTip")
            self._upStarNode = self:createLayer("team.TeamUpStarNode",{starPos = self._starPos,
                starTip = starTip,
                callback = function(num) self:refreshTeamBigStar(num) end, 
                fightCallback = function(inTable) self:setFightAnim(inTable) end})
            -- self._upStarBg:addChild(self._upStarNode)
            tempBaseInfoNode:addChild(self._upStarNode, 5)
        end
        self._upStarNode:reflashUI({teamData = self._curSelectTeam})
        -- self._aminBg:setVisible(false)
        self._upStarNode:setVisible(true)
        -- self._upStarBg:setVisible(true)

        if self._infoNode ~= nil then 
            self._infoNode:setVisible(false)
        end
        if self._gradeNode ~= nil then 
            self._gradeNode:setVisible(false)
        end
        if self._skillNode ~= nil then 
            self._skillNode:setVisible(false)
        end
        if self._heroNode ~= nil then 
            self._heroNode:setVisible(false)
        end
        if self._exclusiveNode ~= nil then
            self._exclusiveNode:setVisible(false)
        end
    elseif sender:getName() == "tab4" then 
        print("技能")
        -- self._viewMgr:showTip("技能暂未开放")
        self._index = 4
        if self._skillNode == nil then 
            self._skillNode = self:createLayer("team.TeamSkillNode", {fightCallback = function(inTable) self:setFightAnim(inTable) end})
            tempBaseInfoNode:addChild(self._skillNode,5)
        end
        print("======================1111", type(self._skillNode))
        self._skillNode:reflashUI({teamData = self._curSelectTeam, refTop = true})
        self._skillNode:setVisible(true)
        -- self._aminBg:setVisible(true)
        -- self._upStarBg:setVisible(false)
        if self._upStarNode ~= nil then 
            self._upStarNode:setVisible(false)
            -- self._upStarBg:setVisible(false)
        end
        if self._gradeNode ~= nil then 
            self._gradeNode:setVisible(false)
        end
        if self._infoNode ~= nil then 
            self._infoNode:setVisible(false)
        end
        if self._heroNode ~= nil then 
            self._heroNode:setVisible(false)
        end
        if self._exclusiveNode ~= nil then
            self._exclusiveNode:setVisible(false)
        end
    elseif sender:getName() == "tab5" then
        self._index = 5
        if self._heroNode == nil then 
            self._heroNode = self:createLayer("team.TeamHeroNode")
            tempBaseInfoNode:addChild(self._heroNode,5)
        end
        self._heroNode:reflashUI({teamData = self._curSelectTeam})
        self._heroNode:setVisible(true)

        if self._upStarNode ~= nil then 
            self._upStarNode:setVisible(false)
        end
        if self._gradeNode ~= nil then 
            self._gradeNode:setVisible(false)
        end
        if self._skillNode ~= nil then 
            self._skillNode:setVisible(false)
        end
        if self._infoNode ~= nil then 
            self._infoNode:setVisible(false)
        end
        if self._exclusiveNode ~= nil then
            self._exclusiveNode:setVisible(false)
        end
    elseif sender:getName() == "tab6" then
        self._index = 6
        if self._exclusiveNode == nil then 
            self._exclusiveNode = self:createLayer("team.TeamExclusiveNode")
            tempBaseInfoNode:addChild(self._exclusiveNode,5)
        end
        self._exclusiveNode:reflashUI({teamData = self._curSelectTeam})
        self._exclusiveNode:setVisible(true)

        if self._upStarNode ~= nil then 
            self._upStarNode:setVisible(false)
        end
        if self._gradeNode ~= nil then 
            self._gradeNode:setVisible(false)
        end
        if self._skillNode ~= nil then 
            self._skillNode:setVisible(false)
        end
        if self._infoNode ~= nil then 
            self._infoNode:setVisible(false)
        end
        if self._heroNode ~= nil then 
            self._heroNode:setVisible(false)
        end
    end
end

-- -- 一键强化装备
-- function TeamView:autoUpgradeStageEquip()
--     local param = {teamId = self._curSelectTeam.teamId}
--     self._serverMgr:sendMsg("TeamServer", "batchUpgradeEquip", param, true, {}, function (result)
--         self:autoUpgradeStageEquipFinish(result)
--     end)
-- end

-- function TeamView:autoUpgradeStageEquipFinish(inResult)
--     if inResult["d"] == nil then
--         self._viewMgr:showTip("强化失败")
--         return 
--     end
--     self._viewMgr:showTip("强化成功")
-- end

function TeamView:setFightAnim(inTable)
    local fightLabel = self._zhandouliLab
    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function()
        audioMgr:playSound("PowerCount")
    end)))
    local addfight = self._addfight

    fightLabel:stopAllActions()
    addfight:setString("+" .. (inTable.newFight - inTable.oldFight))
    local tempGunlun, tempFight 
    -- if (inTable.newFight - inTable.oldFight) < 10 then
    --     tempFight = math.floor(inTable.newFight * 0.01) * 100
    --     tempGunlun = inTable.newFight - tempFight
    -- elseif (inTable.newFight - inTable.oldFight) < 100 then
    --     tempFight = math.floor(inTable.newFight * 0.001) * 1000
    --     tempGunlun = inTable.newFight - tempFight
    -- else
    --     tempFight = 0
    --     tempGunlun = inTable.newFight - tempFight
    -- end
    tempGunlun = inTable.newFight - inTable.oldFight
    tempFight = inTable.oldFight
    local fightNum = tempGunlun / 20
    local numsch = 1
    local sequence = cc.Sequence:create(
        cc.ScaleTo:create(0.05, 1.1),
        cc.Repeat:create(cc.Sequence:create(cc.DelayTime:create(0.05),cc.CallFunc:create(function()
            fightLabel:setString((tempFight + math.ceil(fightNum * numsch)))
            numsch = numsch + 1
        end)), 20),
        cc.CallFunc:create(function()
            fightLabel:setString(inTable.newFight)
            addfight:setPositionX(fightLabel:getPositionX() + fightLabel:getContentSize().width + 8)
            addfight:runAction(cc.Sequence:create(
                cc.FadeIn:create(0.2),
                cc.FadeTo:create(0.3, 80),
                -- cc.FadeOut:create(0.3),
                cc.FadeIn:create(0.2),
                cc.FadeOut:create(0.3)
                )
            )
        end),
        cc.ScaleTo:create(0.05, 1)
        )
    fightLabel:runAction(sequence)
end


function TeamView:setAmin(amin)
    if amin == 1 then
        -- local zhandouliSaoguang = self:getUI("zhandouliBg.Image_151")
        -- local mc2 = mcMgr:createViewMC("saoguang_teamupgrade", true, false, function(_, sender)
        --     sender:stop()
        -- end)
        -- mc2:setPosition(cc.p(zhandouliSaoguang:getContentSize().width/2,zhandouliSaoguang:getContentSize().height/2))
        -- zhandouliSaoguang:addChild(mc2,10)
        -- mc2:stop()
        -- zhandouliSaoguang:runAction(
        --     cc.RepeatForever:create(
        --         cc.Sequence:create(
        --             cc.CallFunc:create(function() mc2:gotoAndPlay(1) end),
        --             cc.DelayTime:create(math.random(3,8))
        --             )
        --         )
        --     )
    elseif amin == 2 then
        -- local zhandouliBg = self:getUI("zhandouliBg")
        -- local mc2 = mcMgr:createViewMC("zhandouliguang_teamupgrade", false, true, function (_, sender)

        -- end)
        -- mc2:setPosition(cc.p(zhandouliBg:getContentSize().width/2,zhandouliBg:getContentSize().height/2 + 3))
        -- zhandouliBg:addChild(mc2,10)
    end
end

-- function TeamView:addAnimBg()
--     local bg = self:getUI("bg")
--     -- bg:setTouchEnabled(false)
--     local bar = cc.Sprite:create("asset/bg/commonWin_bg.png")
--     bar:setAnchorPoint(cc.p(0,0.5))
--     bar:setScale(1.27)
--     bar:setPosition(cc.p(0,MAX_SCREEN_HEIGHT*0.5+10))
--     bg:addChild(bar,1)

--     local mc1 = mcMgr:createViewMC("hengbanliudong_itemeffectcollection", true, false)
--     mc1:setPlaySpeed(0.3)
--     mc1:setCascadeOpacityEnabled(true, true)
--     mc1:setOpacity(60)
--     -- mc1:setPosition(self._detailCell[index]["effect" .. i]:getContentSize().width/2 ,self._detailCell[index]["effect" .. i]:getContentSize().height/2)
--     local clipNode = cc.ClippingNode:create()
--     clipNode:setInverted(false)

--     local mask = cc.Sprite:create("asset/bg/commonWin_bg.png")
--     mask:setAnchorPoint(cc.p(0,0.5))
--     clipNode:setStencil(mask)
--     clipNode:setAlphaThreshold(0.1)
--     clipNode:addChild(mc1)
--     clipNode:setName("clipNode")
--     clipNode:setAnchorPoint(cc.p(0,0.5))
--     clipNode:setScale(1.1)
--     clipNode:setPosition(cc.p(0,MAX_SCREEN_HEIGHT*0.5 - 5))
--     clipNode:setOpacity(0)
--     bg:addChild(clipNode,2)

--     -- local beijing = mcMgr:createViewMC("beijing_itemeffectcollection", true, false)
--     -- beijing:setAnchorPoint(cc.p(0,0))
--     -- beijing:setPosition(cc.p(MAX_SCREEN_WIDTH*0.5,MAX_SCREEN_HEIGHT*0.5-50))
--     -- beijing:setZOrder(-1)
--     -- bg:addChild(beijing)
-- end

function TeamView:getAsyncRes()
    return 
        {
            {"asset/ui/team.plist", "asset/ui/team.png"},
            {"asset/ui/team1.plist", "asset/ui/team1.png"},
            {"asset/ui/team2.plist", "asset/ui/team2.png"},
            {"asset/ui/exclusive.plist", "asset/ui/exclusive.png"},
        }
end

function TeamView:getBgName()
    return "bg_005.jpg" 
end

function TeamView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{types = {"Texp","Gold","Gem"},title = "globalTitleUI_team.png",titleTxt = "兵团"})
end

function TeamView:setNoticeBar()
    self._viewMgr:hideNotice(true)
end

function TeamView:getCommentData()
    -- dump(self._curSelectTeam)
    local param = {ctype = 1, id = self._curSelectTeam.teamId}
    self._serverMgr:sendMsg("CommentServer", "getCommentData", param, true, {}, function(result)
        dump(result)
        self._viewMgr:showDialog("team.TeamCommentDialog", {teamId = self._curSelectTeam.teamId})
    end)
end

function TeamView:setHintTip(btnName, hint)
    if btnName then
        local btnNameTip = btnName:getChildByName("btnNameTip")
        if btnNameTip then
            btnNameTip:setVisible(hint)
        else
            btnNameTip = cc.Sprite:createWithSpriteFrameName("globalImageUI_bag_keyihecheng.png")
            btnNameTip:setName("btnNameTip")
            btnNameTip:setAnchorPoint(cc.p(0,0))
            btnNameTip:setPosition(cc.p(btnName:getContentSize().width - 25, btnName:getContentSize().height*0.5 + 14))
            btnName:addChild(btnNameTip, 10)
            btnNameTip:setVisible(hint)
        end
    end
end


return TeamView