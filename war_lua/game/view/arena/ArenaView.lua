--[[
    Filename:    ArenaView.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2015-09-17 16:54:59
    Description: File description
--]]

local ArenaView = class("ArenaView",BaseView)
function ArenaView:ctor(data)
    data = data or {}
    self.super.ctor(self)
    self.initAnimType = 1
    self._notSendEnterMsg = data.notSendEnterMsg
    self._arenaModel = self._modelMgr:getModel("ArenaModel")
end

function ArenaView:getAsyncRes()
    return 
    {
        {"asset/ui/arena.plist", "asset/ui/arena.png"},
        {"asset/ui/arena1.plist", "asset/ui/arena1.png"},
        {"asset/anim/arenarefreshanimimage.plist", "asset/anim/arenarefreshanimimage.png"},
    }
end

function ArenaView:getBgName()
    return "bg_007.jpg"
end

function ArenaView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{types = {"Currency","Gold","Gem"},hideHead=true,title = "globalTitle_arena.png",titleTxt = "竞技场"})
end

function ArenaView:setNoticeBar()
    self._viewMgr:hideNotice(true)
end

function ArenaView:onDestroy()
    if not tolua.isnull(self._tableView) then
        self._tableView:removeFromParent()--:removeAllChildren()
    end
    ArenaView.super.onDestroy(self)
end

-- function ArenaView:needCacheWidget()
--     return true
-- end

function ArenaView:onBeforeAdd(callback, errorCallback)
    if self._arenaModel:isEmpty() or (not self._notSendEnterMsg) then
    print("onBeforeAdd....in.... sendMsg")
        self:sendEnterArenaMsg(function (_error)
            if _error then
                errorCallback()
                return
            end

            local arenaShopD = self._arenaModel:getArenaShop().shop1
            if not arenaShopD then
                self._serverMgr:sendMsg("ArenaServer", "enterArenaShop", {}, true, {}, function(result)
                    if self.detectNotice then
                        self:detectNotice()
                    end
                    -- self:sendReflashArenaMsg(callback)
                    callback()
                end, function ()
                    errorCallback()
                end)
            else
                -- self:sendReflashArenaMsg(callback)
                callback()
            end
        end)
    else
        self:reflashUI()
        callback()
    end
end
function ArenaView:getBgName()
    return "bg_006.jpg", --name string xx.jpg
           nil, --color cc.c3b
           nil, --Brightness亮度 -100  100 
           nil, --Contrast对比度 -100  100
           nil, --Saturation饱和度 -100  100
           nil  --Hue色相 -180 180
end
-- 初始化UI后会调用, 有需要请覆盖
function ArenaView:onInit()
    -- 通用动态背景
    -- self:addAnimBg()
    -- 初始化按钮事件
    self:initBtnFunc()
    self._layer = self:getUI("bg.layer")
    self._bg = self:getUI("bg")
    self._enemyBoard = self:getUI("bg.layer.challengeNode_5")
    self._enemyBoard:setVisible(false)
    
    self._challengeIndx = 1

    --by wangyan 分享
    local shareNode = require("game.view.share.GlobalShareBtnNode").new({mType = "ShareArenaModule"})
    shareNode:setPosition(790, 21)
    shareNode:setCascadeOpacityEnabled(true, true)
    shareNode:setScale(0.7)
    self:getUI("bg.bottom"):addChild(shareNode)
    shareNode:registerClick(function()
        local curRank = self._modelMgr:getModel("ArenaModel"):getRank()
        return {moduleName = "ShareArenaModule", rank = curRank}
        end)

    -- self:sendEnterArenaMsg()
    local bottomBg = self:getUI("bg.bottom.bottomBg")
    if bottomBg then
        bottomBg:setScaleX(1.5)
    end

    self._firstIn =  true

    -- 界面元素 top
    self._rankLab = self:getUI("bg.infoBg.rankLab")
    -- self._rankLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    local rankDes = self:getUI("bg.infoBg.rankDes")
    rankDes:setFontName(UIUtils.ttfName)
    local zhandouliLab = ccui.TextBMFont:create("0", UIUtils.bmfName_zhandouli_little)
    zhandouliLab:setAnchorPoint(cc.p(1,0))
    zhandouliLab:setPosition(260,2)
    zhandouliLab:setScale(.5)
    self:getUI("bg.infoBg"):addChild(zhandouliLab,99)
    self._zhandouliLab = zhandouliLab
    self._zhandouliLab:setPositionY(self._zhandouliLab:getPositionY()+25)

    self._cdBg = self:getUI("bg.rightBottom.cdBg")
    self._cdBg:setVisible(false)
    self._cdTime = self:getUI("bg.rightBottom.cdBg.cdTime")
    self._cdTime:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._cdDes = self:getUI("bg.rightBottom.cdBg.cdDes")
    self._challengeBg = self:getUI("bg.rightBottom.challengeBg")
    self._cdDiamondImg = self:getUI("bg.rightBottom.cdBg.diamondImg")
            
    local scaleNum1 = math.floor((32/self._cdDiamondImg:getContentSize().width)*100)
    self._cdDiamondImg:setScale(scaleNum1/100)
    self._cdDiamondNum = self:getUI("bg.rightBottom.cdBg.diamondNum")   --.diamondImg
    self._cdDiamondNum:setPositionX(self._cdDiamondImg:getPositionX()+self._cdDiamondImg:getContentSize().width/2*scaleNum1/100)
    self._cdDiamondNum:setString(tab:Setting("G_ARENA_DEL_CD").value)

    self._headFrame = self:getUI("bg.infoBg.headFrame")
    self._sloganLab = self:getUI("bg.layer.sloganBg.sloganLab")
    self._sloganLab:setAnchorPoint(cc.p(0,0.5))
    local sloganLabRender = self._sloganLab:getVirtualRenderer()
    sloganLabRender:setMaxLineWidth(180)
    self._sloganLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._sloganBg = self:getUI("bg.layer.sloganBg")
    self._sloganBg:setVisible(false)
    self.sloganBCD = tab:Setting("G_ARENA_XUANYAN").value[1]
    self.sloganLCD = tab:Setting("G_ARENA_XUANYAN").value[2]
    self.sloganECD = tab:Setting("G_ARENA_XUANYAN").value[3]
    self.sloganLast = false
    self.sloganCCD = self.sloganBCD
    

    local rankDesLab_0 = self:getUI("bg.bottom.rankDesLab_0")
    local diaImg = self:getUI("bg.bottom.diamondImg")
    local scaleNum = math.floor((32/diaImg:getContentSize().width)*100)
    diaImg:setScale(scaleNum/100)
    local goldImg = self:getUI("bg.bottom.goldImg")
    goldImg:setScale(scaleNum/100)
    local currencyImg = self:getUI("bg.bottom.currencyImg")
    currencyImg:setScale(scaleNum/100)
    currencyImg:setPositionX(360)

    self._diamondNum = self:getUI("bg.bottom.diamondNum")
    self._diamondNum:setPositionX(diaImg:getPositionX()+diaImg:getContentSize().width*scaleNum/100/2+3)
    self._goldNum = self:getUI("bg.bottom.goldNum")
    self._goldNum:setPositionX(goldImg:getPositionX()+goldImg:getContentSize().width*scaleNum/100/2+3)
    self._currencyNum = self:getUI("bg.bottom.currencyNum")
    self._currencyNum:setPositionX(currencyImg:getPositionX()+currencyImg:getContentSize().width*scaleNum/100/2+3)

    -- left
    local todayDes = self:getUI("bg.rightBottom.challengeBg.todayDes")
    self._chanceNum = self:getUI("bg.rightBottom.challengeBg.chanceNum")
    self._addChanceBtn = self:getUI("bg.rightBottom.challengeBg.addChangeBtn")
    self._changeBtn = self:getUI("bg.bottom.changeBtn")

    self._sloganBtn = self:getUI("bg.bottom.sloganBtn")
    self._sloganBtn:setTitleFontName(UIUtils.ttfName)
    self._sloganBtn:setTitleColor(cc.c4b(255, 243, 193, 255))
    self._sloganBtn:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)

      -- 敌人板子
    self.enemyBoards = {}

    self:listenReflash("ArenaModel", self.reflashMainBoad)
    self:listenReflash("FormationModel",function( )
        if not self.reloadArenaTableData then return end
        self:reloadArenaTableData()
        self:detectNotice()
    end)
    self:listenReflash("PlayerTodayModel", function( )
        if self.detectNotice then
            self:detectNotice()
        end
    end )
    self:listenReflash("UserModel", function( )
        if self.detectNotice then
            self:detectNotice()
        end
    end)
    self:listenReflash("ItemModel", function( )
        if self.detectNotice then
            self:detectNotice()
        end
    end)
    self:arenaUpdate()
    -- 
    self._tableData = self._arenaModel:getEnemys() or {}
    ScheduleMgr:nextFrameCall(self,function( )
        self._refreshAnim = true
        if self.addTableView then
            self:addTableView()
            self:reflashUI()
        end
    end)

    ScheduleMgr:delayCall(1000, self, function( )
        if self and self._serverMgr then
            local arenaShopD = self._arenaModel:getArenaShop().shop1
            if not arenaShopD then
                self._serverMgr:sendMsg("ArenaServer", "enterArenaShop", {}, true, {}, function(result)
                    if self.detectNotice then
                        self:detectNotice()
                    end
                end)
            else
                if self.detectNotice then
                    self:detectNotice()
                end
            end
        end
    end)

    self:registerTimer(5,0,0,function( )
        if self.sendEnterArenaMsg then
            self:sendEnterArenaMsg()
        end
    end)

    -- 判断引导
    local firstIn = ModelManager:getInstance():getModel("UserModel"):hasTrigger("11")
    --SystemUtils.loadAccountLocalData("firstIn_Arena")
    self._inGuide = not firstIn 
    if self._arenaModel:getArena() and self._arenaModel:getArena().status and self._arenaModel:getArena().status ~= 0 then
        self._inGuide = false
    end
    self:addArrow()
end

-- 两边箭头
function ArenaView:addArrow( )
    -- 加上下箭头
    self._rightArrow = mcMgr:createViewMC("youjiantou_teamnatureanim", true, false)
    self._rightArrow:setPosition(MAX_SCREEN_WIDTH-50,250)
    -- self._rightArrow:setRotation(-65)
    self._bg:addChild(self._rightArrow, 99)
    -- = self:getUI("bg.layer.upArrow")
    -- self._rightArrow:runAction(cc.RepeatForever:create(cc.Sequence:create(
    --     cc.MoveBy:create(0.5,cc.p(10,0)),
    --     cc.MoveBy:create(0.5,cc.p(-10,0))
    -- )))

    self._leftArrow = mcMgr:createViewMC("zuojiantou_teamnatureanim", true, false)
    self._leftArrow:setPosition(50,250)
    -- self._leftArrow:setRotation(-180)
    self._bg:addChild(self._leftArrow, 99)
end

-- 初始化按钮事件
function ArenaView:initBtnFunc( )
    local dialogBtnName = {
        "bg.layer.mainBg.detailBtn",
        "bg.layer.mainBg.shopBtn",
        "bg.layer.mainBg.rankBtn",
        "bg.layer.mainBg.reportBtn",
        "bg.layer.mainBg.formationBtn",

        "bg.layer.mainBg.ruleBtn",
        "bg.bottom.sloganBtn",

        "bg.rightBottom.changeBtn",
        "bg.rightBottom.challengeBg.addChangeBtn",

        "bg.infoBg.changeSlogan",
    }
    
    local dialogFuncName = {
        -- 详情？
        function ( )
            local arenaShopD = self._arenaModel:getArenaShop().shop1
            if not arenaShopD then
                self._serverMgr:sendMsg("ArenaServer", "enterArenaShop", {}, true, {}, function(result)
                    self._viewMgr:showDialog( "arena.DialogArenaRankAward", {closeCallback = function (  )
                        if self.detectNotice then
                            self:detectNotice()
                        end
                    end},true,true)
                end)
            else
                self._viewMgr:showDialog( "arena.DialogArenaRankAward", {closeCallback = function (  )
                        if self.detectNotice then
                            self:detectNotice()
                        end
                    end},true,true)
            end
        end,
        -- 商店
        function( )
            self._serverMgr:sendMsg("ShopServer", "getShopInfo", {type = "arena"}, true, {}, function(result)
                self._viewMgr:showView("shop.ShopView",{idx = 2})
            end)
        end,
        -- 排行
        function ( )
            self._serverMgr:sendMsg("ArenaServer", "getRank", {}, true, {}, function(result) 
                self._viewMgr:showDialog("arena.DialogArenaRank", {},true)
            end)
            
        end,
        -- 战报
        "arena.DialogArenaReport",
        -- 布阵
        function( ) -- 防守按钮
            self._viewMgr:showView("formation.NewFormationView", {
                formationType = self._modelMgr:getModel("FormationModel").kFormationTypeArenaDef,
            })
        end,
        -- 规则
        "arena.ArenaRuleView",
        -- 宣言
        "arena.DialogArenaSlogan",
        -- 刷新
        function ( )
            if self._challengeCD then
                local gem = self._modelMgr:getModel("UserModel"):getData()["gem"]
                local cost = tab:Setting("G_ARENA_DEL_CD").value
                self._arenaCDView = self._viewMgr:showDialog("arena.ArenaDialogCD",
                    {desc = "[color=462800,fontsize=24]是否花费[pic=globalImageUI_littleDiamond.png][-][color=462800,fontsize=24]"..cost.."[-][-][color=462800,fontsize=24]消除冷却时间继续挑战[-]",
                    --确定回调
                    callBack1 = function()
                        self:CDCallbackFunc(true)
                    end,  
                    --取消回调 
                     callBack2 = function()
                        if self._arenaCDView then
                            self._viewMgr:closeDialog(self._arenaCDView)
                            self._arenaCDView = nil
                        end
                    end            
                })   
                -- 更新倒计时显示                 
                if self._arenaCDView then
                    self._arenaCDView:CDupdate(self._cdTimeNum)
                end
            else
                -- self:enterArenaFirstBattle()
                if self._reflashCD then
                    self._viewMgr:showTip(lang("TIPS_ARENA_09") or "刷新太频繁！")
                else
                    self._refreshAnim = true
                    self:sendReflashArenaMsg()
                    self._reflashCD = tab:Setting("G_ARENA_REFLASH").value or 1
                end 
                -- self:arenaUpdate()
                -- self._changeBtn:setBright(false)
                -- self._changeBtn:setEnabled(false)
            end
        end,
        -- 购买次数
        function ()
            self:sendBuyChallengeNumMsg()
        end,
        -- 修改宣言
        function ()
            self._viewMgr:showDialog("arena.DialogArenaSlogan")
        end,
    }
    local funcBtnNames = {"奖励","商店","排行","战报","防守","规则"} -- 对应不到就不设置
    for i,name in ipairs(dialogBtnName) do
        local txt = UIUtils:addFuncBtnName( self:getUI(name),funcBtnNames[i],nil,nil,18)
        txt:setScale(1.16)
        self:registerClickEventByName(name,function( )
            if type(dialogFuncName[i]) == "string" then
                self._viewMgr:showDialog(dialogFuncName[i])
            elseif type(dialogFuncName[i]) == "function" then
                dialogFuncName[i]()
            end
        end)
    end
end

function ArenaView:CDCallbackFunc(notChallenge)
    if self._challengeCD then
        local gem = self._modelMgr:getModel("UserModel"):getData()["gem"]
        local cost = tab:Setting("G_ARENA_DEL_CD").value
        if cost <= gem then
            local param = {}
            self._serverMgr:sendMsg("ArenaServer", "clearBattleCd", param, true, {}, function(result) 
                local cdTime = result.d.arena.cdTime
                self._arenaModel:getArena().cdTime = cdTime
                self._arenaModel:updateArena(result.d.arena)
                result.d.arena = nil
                self._modelMgr:getModel("UserModel"):updateUserData(result.d)
                if self._cdBg:isVisible() and not self._reflashCD  then
                    self._cdBg:setVisible(false)
                    self._challengeCD = false
                    self._challengeBg:setVisible(true)
                    self._changeBtn:setTitleText("")
                     self._changeBtn:loadTextures("arena_refreshBtn.png","arena_refreshBtn.png",nil,1)
                end
                self:arenaUpdate()
                if not notChallenge then
                    self:challengeEnemy(self._challengeIndx)
                end
            end)    
        else
            DialogUtils.showNeedCharge({callback1=function( )
                local viewMgr = ViewManager:getInstance()
                viewMgr:showView("vip.VipView", {viewType = 0})
            end})
        end

    end
end

-- 2017.1.9 修改增加回调参数 by guojun
function ArenaView:addCountBackFunc(callback)
    local buyNum = self._arenaModel:getArena().buyNum
    local vip = self._modelMgr:getModel("VipModel"):getData().level

    local canBuyNum = tonumber(tab:Vip(vip).buyArena) 
    if buyNum >= canBuyNum then
        -- self._viewMgr:showTip("已达购买上限！")
        self._viewMgr:showDialog("global.GlobalResTipDialog",{},true)
        return 
    end 
    local costIdx = math.min(self._arenaModel:getArena().buyNum+1,#tab.reflashCost)-- tab:Setting("G_ARENA_BUY_GEM").value
    local nextCost = math.ceil(tab:ReflashCost(costIdx).costArena*self:getActivityDiscount())

    local gem = self._modelMgr:getModel("UserModel"):getData()["gem"]
    if nextCost < gem then
        local param = {}
        self._serverMgr:sendMsg("ArenaServer", "buyChallengeNum", param, true, {}, function(result) 
            self:reflashMainBoad()
            if callback then 
                callback()
            end                
            -- self:challengeEnemy(self._challengeIndx)
        end) 
    else
        DialogUtils.showNeedCharge({callback1=function( )
            local viewMgr = ViewManager:getInstance()
            viewMgr:showView("vip.VipView", {viewType = 0})
        end})
    end
end
function ArenaView:onShow( )
    if not self._arenaSchedule then
        self._arenaSchedule = ScheduleMgr:regSchedule(1000,self,function( )
            self:arenaUpdate()
        end)
    end
end

function ArenaView:arenaUpdate( )
    if self._arenaModel:isEmpty() then return end
    -- 宣言。。。。
    self.sloganCCD = self.sloganCCD-1
    if self.sloganCCD == 0 then
        self.sloganLast = not self.sloganLast
        if self.sloganLast then
            self.sloganCCD = self.sloganLCD
            self:randomSlogan()
            if self._curSlogan then
                self._curSlogan:setVisible(true)
            end
        else
            if self._curSlogan then
                self._curSlogan:setVisible(false)
            end
            self.sloganCCD = self.sloganECD
        end
    end
    -- 
    if self._reflashCD then
        if  self._reflashCD > 0 then
            -- if not self._cdBg:isVisible() then
            --     self._cdBg:setVisible(true)
            --     self._cdDiamondImg:setVisible(false)
            --     self._cdDes:setString("后可刷新")
            --     self._challengeBg:setVisible(false)
            -- end
            -- self._cdTime:setString(self._reflashCD .. "秒")
            self._reflashCD = self._reflashCD-1
        else
            self._reflashCD = nil
        --     self._changeBtn:setBright(true)
        --     self._changeBtn:setEnabled(true)
        --     if self._cdBg:isVisible() then
        --         self._cdBg:setVisible(false)
        --         self._cdDiamondImg:setVisible(true)
        --         self._challengeBg:setVisible(true)
            -- end
        end
    end
    local privilgeCD = self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_11) or 0
    local peerageCD = self._modelMgr:getModel("PrivilegesModel"):getPeerageEffect(PrivilegeUtils.peerage_ID.JingJiCD) or 0

    local lastChallengeTime = (self._arenaModel:getArena().cdTime or 0) - privilgeCD
    -- if peerageCD ~= 0 then
    --     lastChallengeTime = 0
    -- end

    if lastChallengeTime and lastChallengeTime > 0 then
        local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
        if lastChallengeTime+10 > curTime then
            local cdTime = lastChallengeTime-curTime+10 
            self._cdTimeNum = cdTime
            self._cdTime:setString(string.format("%02d:%02d",math.floor(cdTime/60),math.floor(cdTime%60)))
            -- 如果有消除CD的二级 则更新CDView 的倒计时的显示
            if self._arenaCDView then
                self._arenaCDView:CDupdate(cdTime)
            end

            self._cdDes:setString("冷却时间")
            if not self._cdBg:isVisible() and self._changeBtn then
                self._cdBg:setVisible(true)
                self._challengeCD = true
                self._challengeBg:setVisible(false)
                self._changeBtn:setTitleText("")
                self._changeBtn:loadTextures("arena_resetBtn.png","arena_resetBtn.png",nil,1)
                self._cdDiamondImg:setVisible(true)
            end
        else
            if self._arenaCDView then
                self._arenaCDView:CDupdate(0)
            end
            if self._cdBg:isVisible() and not self._reflashCD and self._changeBtn then
                self._cdBg:setVisible(false)
                self._challengeCD = false
                self._challengeBg:setVisible(true)
                self._changeBtn:setTitleText("")
                self._changeBtn:loadTextures("arena_refreshBtn.png","arena_refreshBtn.png",nil,1)
            end
        end
    end
    -- 十点结算倒计时
    local settleLab = self:getUI("bg.bottom.settleLab")
    settleLab:setColor(UIUtils.colorTable.ccUIBaseColor2)
    settleLab:setFontSize(20)
    settleLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local settleStartTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(nowTime,"%Y-%m-%d 20:00:00"))
    local settleEndTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(nowTime,"%Y-%m-%d 21:00:00"))
    if nowTime > settleStartTime and nowTime < settleEndTime then
        settleLab:setVisible(true)
        local leftTime = settleEndTime-nowTime
        settleLab:setString(string.format("%02d:%02d后结算",math.floor(leftTime/60),leftTime%60))
    else
        settleLab:setVisible(false)
    end

    
end

function ArenaView:detectNotice( )
    local formationModel = self._modelMgr:getModel("FormationModel")
    local formationBtn = self:getUI("bg.layer.mainBg.formationBtn")
    local isFullWeapons = formationModel:isHaveWeaponCanLoaded(formationModel.kFormationTypeArenaDef)
    -- if formationCount < max then
    -- end
    -- self:reloadArenaTableData()
    local isFormationFull = formationModel:isFormationTeamFullByType(formationModel.kFormationTypeArenaDef)
    print("teamIsfull....",isFormationFull)
    self:addDot(formationBtn,isFormationFull and not isFullWeapons)

    -- 新战报红点
    local playerTodayModel = self._modelMgr:getModel("PlayerTodayModel")
    local reportBtn = self:getUI("bg.layer.mainBg.reportBtn")
    local addNewReport = playerTodayModel.newArenaReport
    self:addDot(reportBtn,true)-- 先remove
    local nowDetectRank = self._arenaModel:getRank()
    if addNewReport then
        local oldRank = self._arenaModel:getRank()
        if not self._inGuide then
            self:sendEnterArenaMsg(function()
                if self and self._arenaModel and playerTodayModel then
                    local newRank = self._arenaModel:getRank()
                    if oldRank and newRank and oldRank < newRank then
                        self._refreshAnim = true
                        self:addDot(reportBtn,not addNewReport)-- 满足这就变
                    end 
                    playerTodayModel.newArenaReport = nil
                    playerTodayModel.arenaReportRank = nil
                end
            end)
        end
    end

    local awardD = tab["arenaHighShop"]
    local rank = self._arenaModel:getData().rank or 0
    local shopData = self._arenaModel:getArenaShop().shop1
    local shopNotice = false

    if shopData then
        local currency = self._modelMgr:getModel("UserModel"):getData().currency or 0
        -- local addTime = self._modelMgr:getModel("UserModel"):getCurServerTime()-self._modelMgr:getModel("ArenaModel"):getArena().shopTime
        for i,v in ipairs(awardD) do
            -- local leftTime = tonumber(v.countlim)-addTime-tonumber(shopData[tostring(v.id)])  
            if v.ranklim and v.cost then
                if rank <= v.ranklim and shopData[tostring(v.id)] == nil and currency >= v.cost then  --and leftTime <= 0 
                    shopNotice = true
                    break
                end
            end
        end
    else
         shopNotice = rank <=  awardD[1].ranklim
    end
    local showAwardOnce = SystemUtils.loadAccountLocalData("arena_showAwardOnce")
    if showAwardOnce then 
        shopNotice = false
    end
    local detailBtn = self:getUI("bg.layer.mainBg.detailBtn")

    self:addDot(detailBtn, not shopNotice or self._inGuide)
end
function ArenaView:addDot( node,isRemove )
    if isRemove then
        local dot = node:getChildByFullName("dot")
        if dot then 
            dot:removeFromParent()
        else
        end
        -- node:removeAllChildren()
    else
        local dot = node:getChildByName("dot")
        if not dot then 
            dot = ccui.ImageView:create()
            dot:loadTexture("globalImageUI_bag_keyihecheng.png", 1)
            dot:setScale(0.9)
            dot:setPosition(cc.p(node:getContentSize().width-10,node:getContentSize().height-20))
            dot:setName("dot")
            node:addChild(dot)
        end
    end 
end

function ArenaView:onTop( )
    if not self._arenaSchedule then
        self._arenaSchedule = ScheduleMgr:regSchedule(1000,self,function( )
            self:arenaUpdate()
        end)
    end
    self:arenaUpdate()
    self:updateFightNum()
    if self._battleRefreshAnim then
        self._refreshAnim = true
        self:reflashEnemys()
        self._battleRefreshAnim = false
    end
    print("onTop....arena...")
    if self.detectNotice then 
        self:detectNotice()
    end
    self._serverMgr:sendMsg("ArenaServer", "enterArenaShop", {}, true, {}, function(result)
        if self and self.detectNotice then
            self:detectNotice()
        end
    end)
    -- 评论
    local _,hRank = self._modelMgr:getModel("ArenaModel"):getRank()
    if hRank then
        local param = {inType = 5, num = hRank}
        local isPop, popData = self._modelMgr:getModel("CommentGuideModel"):checkCommentGuide(param)
        if isPop == true then
            self._viewMgr:showDialog("global.GlobalCommentGuideView", popData, true)
        end
    end
end

function ArenaView:updateFightNum( )
    local formationModel = self._modelMgr:getModel("FormationModel")
    local fightCapacity = formationModel:getCurrentFightScoreByType(formationModel.kFormationTypeArenaDef) or 0
    self._zhandouliLab:setString(fightCapacity or 0)
end

function ArenaView:updateDefFightNum( )
    local formationModel = self._modelMgr:getModel("FormationModel")
    -- local data = formationModel:getFormationData()[formationModel.kFormationTypeArenaDef]
    local fightCapacity = formationModel:getCurrentFightScoreByType(formationModel.kFormationTypeArenaDef)
    --[[ 记录之前的获取方式，没有接口自己算的
        -- local teamModel = self._modelMgr:getModel("TeamModel")
        -- if data then
        --     table.walk(data, function(v, k)
        --         if 0 == v then return end
        --         if string.find(tostring(k), "team") and not string.find(tostring(k), "g") then
        --             local teamData = teamModel:getTeamAndIndexById(v)
        --             fightCapacity = fightCapacity + teamData.score
        --         end
        --     end)
        --     local heroData = self._modelMgr:getModel("HeroModel"):getData()[tostring(data.heroId)]
        --     fightCapacity = fightCapacity + heroData.score + self._modelMgr:getModel("TreasureModel"):getTreasureScore()
        -- end
    --]]
    return fightCapacity
end

function ArenaView:onHide( )
    if self._arenaSchedule then
        ScheduleMgr:unregSchedule(self._arenaSchedule)
        self._arenaSchedule = nil
    end
end
local sloganIdx = 0
-- 随机宣言
function ArenaView:randomSlogan()
-- if true then return end
    if not self._sloganLab then return end
    local sloganNum = 10
    if not self.slogans then
        self.slogans = {}
        for i=1,10 do
            local setName = string.format("CALL_ARENA_%02d", i)
            local slogan = lang(setName) or "哈哈"
            table.insert(self.slogans,slogan)
        end
        -- local sloganPoses = {}
        -- for k,v in pairs(self.enemyBoards) do
        --     table.insert(sloganPoses,cc.p(v:getPositionX()-30,v:getPositionY()+v:getContentSize().height/2-50))
        -- end
        -- self.sloganPoses = sloganPoses
    end
    if self._curSlogan then 
        self._curSlogan:setVisible(false)
    end
    if self._tableView then
        local lowIdx = #self._tableData
        local highIdx = 1
        local viewRect = self._tableView:getViewSize().width
        local offsetX = self._tableView:getContentOffset().x
        local leftBoard,rightBoard = -offsetX-160,-offsetX+viewRect-160
        if self._tableView then
            for i=1,#self._tableData do
                local cell = self._tableView:cellAtIndex(i-1)
                if cell and cell:isVisible() and 
                    cell:getPositionX() > leftBoard and
                    cell:getPositionX() <= rightBoard then
                    -- print("cell pos",leftBoard,rightBoard,i,cell:getIdx(),cell:getPositionX(),self._tableView:getContentOffset().x)
                    if i >= highIdx then
                        highIdx = i
                    end
                    if i <= lowIdx then
                        lowIdx = i
                    end
                end 
            end
        end
        local clockT = math.floor(os.clock()*1000*1.1%10+os.clock()*100%10)
        -- GRandomSeed(tostring(clockT))
        local randStep = clockT%(highIdx-lowIdx+1)
        local sloganIdx = randStep+lowIdx-- GRandom(lowIdx,highIdx)
        if self._preSloganIdx and sloganIdx == self._preSloganIdx then
            if sloganIdx == highIdx then
                sloganIdx = self._preSloganIdx-1
            else
                sloganIdx = self._preSloganIdx+1
            end
        end
        sloganIdx = math.max(1,sloganIdx)
        sloganIdx = math.min(#self._tableData,sloganIdx)
        self._preSloganIdx = sloganIdx
        local sloganStr = self.slogans[sloganIdx%10+1]
        local cell = self._tableView:cellAtIndex(sloganIdx-1)
        local enemyD = self._tableData[sloganIdx]
        if cell then 
            if enemyD and self._arenaModel:getRank() and enemyD.rank == self._arenaModel:getRank() and ( not self._modelMgr:getModel("UserModel"):getSlogan() or self._modelMgr:getModel("UserModel"):getSlogan() == "") then
                return 
            end
            local slogan = cell:getChildByFullName("slogan")
            if not slogan then 
                slogan = self._sloganBg:clone()
                slogan:setPositionY(20)
                local sloganLab = slogan:getChildByFullName("sloganLab")
                sloganLab:setFontSize(18)
                sloganLab:setColor(cc.c3b(61, 31, 0))
                -- sloganLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
                sloganLab:setAnchorPoint(cc.p(0,0.5))
                slogan:setContentSize(cc.size(181,75))
                slogan:setScale(1)
                slogan:setName("slogan")
                sloganLab:setPosition(cc.p(10,0))
                sloganLab:getVirtualRenderer():setMaxLineWidth(150)
                sloganLab:setLineBreakWithoutSpace(true)
                cell:addChild(slogan)
            end
            local enemyD = self._arenaModel:getEnemys()[sloganIdx]
            local msg = enemyD.msg or ""
            if msg and msg ~= "" then
                sloganStr = msg 
                if enemyD.rank == self._arenaModel:getRank() then
                    sloganStr = self._modelMgr:getModel("UserModel"):getData().msg 
                end
            end
            local sloganLab = slogan:getChildByFullName("sloganLab")
            sloganLab:setString(sloganStr)
            local sloganLab = slogan:getChildByFullName("sloganLab")
            local sloganWidth = math.max(sloganLab:getContentSize().width+22,170)
            local sloganHeight = math.max(sloganLab:getContentSize().height+30,57)
            -- if sloganWidth > slogan:getContentSize().width then
                slogan:setContentSize(cc.size(sloganWidth,sloganHeight))
                -- slogan:setScaleY(sloganHeight/75)
            -- end
            slogan:setPosition(cc.p(28,150))
            sloganLab:setPosition(cc.p(13,sloganHeight/2))
            slogan:setVisible(true)
            self._curSlogan = slogan
            -- [[ 跟随宣言气泡改变英雄动画
            local enemyBoard = cell:getChildByName("cellBoard")
            if enemyBoard and enemyBoard.spWin and enemyBoard.sp then
                enemyBoard.sp:setVisible(false)
                enemyBoard.spWin:setVisible(true)
                enemyBoard.spWin:gotoAndPlay(0)
            end
            --]]
        end
    end
    -- local slogan = self.slogans[(sloganIdx%sloganNum+1)]
    -- sloganIdx = (sloganIdx)%sloganNum+1
    -- enemyIdx = (sloganIdx)%5+1
    -- if self._arenaModel:getEnemys() and self._arenaModel:getEnemys()[enemyIdx] then
    --     local enemyD = self._arenaModel:getEnemys()[enemyIdx]
    --     if  enemyD and enemyD.msg and enemyD.msg ~= "" then
    --         slogan = enemyD.msg
    --     end
    -- end
    -- local sloganPos = self.sloganPoses[(sloganIdx)%5+1]
    -- -- self._sloganLab:setFontSize(15)
    -- self._sloganLab:setString(slogan)
    -- local sloganWidth = self._sloganLab:getContentSize().width+50
    -- local sloganHeight = self._sloganLab:getContentSize().height+40
    -- self._sloganLab:setAnchorPoint(cc.p(0,0.5))
    -- self._sloganLab:setPositionY(sloganHeight/2+10)
    -- self._sloganBg:setContentSize(cc.size(181,75))
    -- self._sloganBg:setScale(1)
    -- if sloganWidth > self._sloganBg:getContentSize().width then
    --     self._sloganBg:setContentSize(cc.size(sloganWidth,sloganHeight))
    -- end
    -- self._sloganBg:setPosition(sloganPos)
    -- self._sloganLab:setPosition(cc.p(10,28))
end

-- 接收自定义消息
function ArenaView:reflashUI(data)
    self:reflashMainBoad()
    self:reflashEnemys()
end

-- 刷新主界面
function ArenaView:reflashMainBoad( data )
    local arenaData = self._arenaModel:getData()
    local enemys = self._arenaModel:getEnemys()
    if not enemys or #enemys==0 then return end
    local rank = arenaData.rank or 10000
    if self._inGuide then
        self._rankLab:setString("暂无排名")
    else
        if rank > 10000 then 
            rank = 10000
        end
        self._rankLab:setString(rank)
    end


    local tencetTp = nil
    if self._modelMgr:getModel("TencentPrivilegeModel"):isOpenPrivilege() then
        if sdkMgr:isWX() then
            tencetTp = self._modelMgr:getModel("TencentPrivilegeModel"):getTencentTeQuan()
        elseif sdkMgr:isQQ()  then
            tencetTp = self._modelMgr:getModel("TencentPrivilegeModel"):getQQVip()
        end
    end

    local userInfo = self._modelMgr:getModel("UserModel"):getData()
    if not self._avatar then
        self._avatar = IconUtils:createHeadIconById({avatar = userInfo.avatar,level = userInfo.lvl or "0" ,tp = 4, isSelf = true,avatarFrame = userInfo["avatarFrame"], tencetTp = tencetTp}) 
        -- self._avatar:getChildByFullName("iconColor"):loadTexture("globalImageUI6_headBg.png",1)
        self._avatar:setPosition(cc.p(-5,-3))
        self._headFrame:addChild(self._avatar,-1)
    else
        IconUtils:updateHeadIconByView(self._avatar,{avatar = userInfo.avatar,level = userInfo.lvl or "0" ,tp = 4, isSelf = true, tencetTp = tencetTp})
        -- self._avatar:getChildByFullName("iconColor"):loadTexture("globalImageUI6_headBg.png",1)
    end
       
    local awardGem,awardGold,awardCurrency = self:getRankAward(rank)
    self._diamondNum:setString(awardGem)
    self._goldNum:setString(awardGold)
    self._currencyNum:setString(awardCurrency)

    local chanceNum = arenaData.arena.num or 0
    if chanceNum == 0 then
        self._addChanceBtn:setVisible(true)
        self._chanceNum:setColor(UIUtils.colorTable.ccUIBaseColor6)
    else
        self._addChanceBtn:setVisible(false)
        self._chanceNum:setColor(UIUtils.colorTable.ccUIBaseColor2)
    end
    self._chanceNum:setString(chanceNum or 0)
    self:updateFightNum()

    -- vip 
    local vip = self._modelMgr:getModel("VipModel"):getData().level or 0
    self:getUI("bg.infoBg.vipIcon"):loadTexture(("chatPri_vipLv".. vip ..".png"), 1)
    local userInfo = self._modelMgr:getModel("UserModel"):getData()
    local needExp = tab:UserLevel(userInfo.lvl).exp
    if needExp then
        self:getUI("bg.infoBg.progressBar"):setPercent(userInfo.exp/needExp*100)
    end
end
-- 获取奖励区间
function ArenaView:getRankAward( rank )
    local _,_,honerD = self._arenaModel:getArenaAwardByRank(rank)
    local awardGem,awardGold,awardCurrency = honerD.diamond,honerD.gold,honerD.currency
    return awardGem,awardGold,awardCurrency
end

-- 刷新敌人
function ArenaView:reflashEnemys( )
    self._tableData = self._arenaModel:getEnemys() or {}
    self:reloadArenaTableData()
    -- self._tableView:reloadData()
    -- -- local offset = -self._tableView:getContainer():getContentSize().width+self._tableView:getViewRect().width
    -- self._tableView:setContentOffset(cc.p(-(#self._tableData-5)*175,0)) -- 
end

-- 获得板子和名字的颜色索引号
function ArenaView:getBoardColorIndex( rank )
    if not rank then return 2--[[安全数]] end
    -- 头五名不同颜色
    if rank <= 3 then
        return rank 
    elseif rank <= 10 then
        return 4
    else 
        return 5
    end
    -- return rank <= 5 and rank or 
    -- 之前是根据范围返回板子颜色
    if true then return end
    if not self._boardNameColorMap then        
        self._boardNameColorMap =  tab:Setting("G_ARENA_COLOR").value    --{3000,1000,300,60,10} -- 白绿蓝紫橙红
        -- table.insert(self._boardNameColorMap, 0) 
    end
    local index = 1
    for i,v in ipairs(self._boardNameColorMap) do   
        if rank > v then
            break
        end     
        index = i
    end
    return index
end

function ArenaView:enterArenaBattle(idx, r1, r2, playerInfo, enemyInfo)
    local playerInfo, enemyInfo = self:initBattleData(playerInfo, enemyInfo)

    -- 检查静态数据表
    -- if GameStatic.checkTable then
    --     local res = BattleUtils.checkTable_Arena(playerInfo, enemyInfo)
    --     if res ~= nil then
    --         if OS_IS_WINDOWS then
    --             ViewManager:getInstance():onLuaError("配置表被更改: "..res)
    --         else
    --             ApiUtils.playcrab_lua_error("tab_xiugai_arena", res)
    --             if GameStatic.kickTable then
    --                 AppExit()
    --                 return
    --             end
    --         end
    --     end
    -- end
    local arenaServerRank = GameStatic.arenaServerRank or 100
    local curEnemyD = self._arenaModel:getCurEnemyInfo()
    local defrank = curEnemyD.def.rank
    -- 前100名，传空给后端，直接走服务器复盘
    if defrank <= arenaServerRank then
        local token = curEnemyD.token
        local defid = curEnemyD.def.battle.rid 
        local _result
        self:sendFightAfterMsg(defid,defrank,token,-1,0,{},function (result)
            _result = result
            BattleUtils.enterBattleView_Arena(playerInfo, enemyInfo, r1, r2, 0, false,
            function (info, callback)
                if self._inGuide then
                    self:sendChangeStatusMsg(function( )
                        if self._arenaModel:getArena() and self._arenaModel:getArena().status and self._arenaModel:getArena().status ~= 0 then
                            self._inGuide = false
                        end
                        self:reflashUI()
                    end)
                end
                self:sendEnterArenaMsg()
                local arenaInfo   = {}
                arenaInfo.award   = result.award
                arenaInfo.rank    = result.rank
                arenaInfo.rewards = result.rewards
                -- arenaInfo.preRank = defrank
                arenaInfo.preRank,arenaInfo.preHRank = self._modelMgr:getModel("ArenaModel"):getPreRank()
                -- if true then return end
                info =  _battleCountInfo or info
                info.arenaInfo = arenaInfo
                if arenaInfo.rank - arenaInfo.preRank < 0 then 
                    self._battleRefreshAnim = true
                end
                if result["cheat"] == 1 then
                    info.failed = true
                    info.extract = result["extract"]
                end

                callback(info)
            end,
            function (info)
                -- 退出战斗
                ViewManager:getInstance():popView()
            end,false)
        end)
    else
        BattleUtils.enterBattleView_Arena(playerInfo, enemyInfo, r1, r2, 0, false,
        function (info, callback)
            local win = 0
            if info.win then
                win = 1
            end
            local token = curEnemyD.token
            local defid = curEnemyD.def.battle.rid 
            self:sendFightAfterMsg(defid,defrank,token,win,info.time,info.serverInfoEx,function (result)
                -- 战斗结束
                -- self:afterArenaBattle(info,callback,{r1,r2,playerInfo,enemyInfo--[[battleinfo]]})
                -- callback(info)
                if self._inGuide then
                    self:sendChangeStatusMsg(function( )
                        if self._arenaModel:getArena() and self._arenaModel:getArena().status and self._arenaModel:getArena().status ~= 0 then
                            self._inGuide = false
                        end
                        self:reflashUI()
                    end)
                end
                self:sendEnterArenaMsg()
                local arenaInfo   = {}
                arenaInfo.award   = result.award
                arenaInfo.rank    = result.rank
                arenaInfo.rewards = result.rewards
                -- arenaInfo.preRank = defrank
                arenaInfo.preRank,arenaInfo.preHRank = self._modelMgr:getModel("ArenaModel"):getPreRank()
                -- if true then return end
                info =  _battleCountInfo or info
                info.arenaInfo = arenaInfo
                if arenaInfo.rank - arenaInfo.preRank < 0 then 
                    self._battleRefreshAnim = true
                end
                if result["cheat"] == 1 then
                    info.failed = true
                    info.extract = result["extract"]
                end
                callback(info)
            end)
        end,
        function (info)
            -- 退出战斗
            ViewManager:getInstance():popView()
        end,false)
    end
end

function ArenaView:enterArenaFirstBattle( )
    self._serverMgr:sendMsg("UserServer", "getEmptyInfo", {}, true, {}, function(result)
        if callback then
            callback(result)
        end
        SystemUtils.saveAccountLocalData("firstIn_Arena", true)
        local playerInfo = self:initBattlePlayerDataData()
        local enemyInfo = self:generateEmenyInfo()
         -- 给布阵传递数据
        
        local formationType = self._modelMgr:getModel("FormationModel").kFormationTypeArena
        self._viewMgr:showView("formation.NewFormationView", {
            formationType = formationType,
            enemyFormationData = {[formationType] = enemyInfo.formation},
            callback = function(leftData)
                self._viewMgr:popView()
                BattleUtils.enterBattleView_Arena(playerInfo, enemyInfo, 19870515, 1, 0, false,
                function (info, callback)
                    -- 战斗结束
                    self:afterArenaFirstBattle(info,callback)
                    -- callback(info)
                end,
                function (info)
                    -- 退出战斗
                    -- ViewManager:getInstance():popView()
                end)
            end,
            extend = {},
        })
        
    end)   
end

function ArenaView:afterArenaFirstBattle( data,callback )
    local win = 0
    if data.win then
        win = 1
    end
    -- self:sendFightAfterMsg(defid,defrank,token,win,function (result)
    local rank = self._modelMgr:getModel("ArenaModel"):getRank()
    local gem = self._modelMgr:getModel("ArenaModel"):getFirstAwardGem()
    local result = {
        rank = rank,
        preRank = 10000,
        preHRank = 10000,
        award = {
            gem = gem or 100,
            val = 20,
        }
    }
    data.arenaInfo = result
    callback(data)
    -- 重设引导判断
    local firstIn = ModelManager:getInstance():getModel("UserModel"):hasTrigger("11")
    --SystemUtils.loadAccountLocalData("firstIn_Arena")
    self._inGuide = not firstIn 
    self:sendChangeStatusMsg(function( )
        if self._arenaModel:getArena() and self._arenaModel:getArena().status and self._arenaModel:getArena().status ~= 0 then
            self._inGuide = false
        end
        self:reflashUI()
    end)
    if self._arenaModel:getArena() and self._arenaModel:getArena().status and self._arenaModel:getArena().status ~= 0 then
        self._inGuide = false
    end
    self:reflashUI()
    -- end)
end

-- 挑战按钮回调
function ArenaView:challengeEnemy( idx )
    if not self._arenaModel:getEnemys() then 
        return
    end
    self._serverMgr:sendMsg("ArenaServer", "checkTargetRange", {defId = self._arenaModel:getEnemys()[idx]._id or self._arenaModel:getEnemys()[idx].rid,defRankId = self._arenaModel:getEnemys()[idx].rank}, true, {}, function(result)
        if result.status == 0 then
            local curRank = self._arenaModel:getRank()
            if result.rank and result.rank ~= curRank then
                self._refreshAnim = true
                self:sendEnterArenaMsg()
                ViewManager:getInstance():showTip(lang("TIPS_ARENA_08"))
                return 
            end
            self._serverMgr:sendMsg("ArenaServer", "getDetailInfo", {roleId = self._arenaModel:getEnemys()[idx]._id or self._arenaModel:getEnemys()[idx].rid}, true, {}, function(result) 
                local info = result.info
                info.battle.msg = info.msg
                info.battle.rank = info.rank
                local enemyFormation = clone(info.battle.formation)
                enemyFormation.filter = ""
                 -- 给布阵传递数据
                self._arenaModel:setEnemyData(info.battle.teams)
                
                self._arenaModel:setEnemyHeroData(info.battle.hero)

                local formationType = self._modelMgr:getModel("FormationModel").kFormationTypeArena
                self._viewMgr:showView("formation.NewFormationView", {
                    formationType = formationType,
                    enemyFormationData = {[formationType] = enemyFormation},
                    callback = function(leftData)
                        -- self._viewMgr:showDialog("arena.DialogArenaUserInfo",info.battle,true)
                        local enemyD = info.battle--self._arenaModel:getEnemys()[idx]
                        local rid = enemyD.rid
                        local rank = enemyD.rank
                        self._viewMgr:lock(-1)
                        local isNotUnlock = true
                        self:sendFightBeforeMsg(rid,rank,idx,function (r1, r2,battleInfo)
                            -- self:enterArenaBattle(idx, r1, r2,battleInfo or info.battle)
                            self._viewMgr:unlock()
                            isNotUnlock = false
                        end)
                        ScheduleMgr:delayCall(2000, self, function( )
                            if isNotUnlock then
                                ViewManager:getInstance():unlock()
                            end
                        end)
                    end,
                })
            end)
        else
            if result.status == 1 then
                self._viewMgr:showTip(lang("TIPS_ARENA_07"))
            elseif result.status == 2 then
                self._viewMgr:showTip(lang("TIPS_ARENA_08"))
            end
            self._refreshAnim = true
            self:sendEnterArenaMsg()
        end        
    end,function( )
        -- 网络延迟没有推送到名次变更 造成 "挑战自己"的报错处理
        if self.sendEnterArenaMsg then
            ViewManager:getInstance():showTip(lang("TIPS_ARENA_07"))
            self:sendEnterArenaMsg()
        end
    end)
end
-- 组装战斗数据 copy from GlobalFormationView
function ArenaView:initBattlePlayerDataData()
    local formationModel = self._modelMgr:getModel("FormationModel")
    local playerInfo = formationModel:initBattleData(formationModel.kFormationTypeArena)[1]
    playerInfo.level = ModelManager:getInstance():getModel("UserModel"):getData().lvl

    return playerInfo
end

function ArenaView:initBattleData(playerData, enemyData)
    local playerInfo = BattleUtils.jsonData2lua_battleData(playerData)
    local enemyInfo = BattleUtils.jsonData2lua_battleData(enemyData)

    -- 给布阵设数据
    -- self._arenaModel:setEnemyHeroData(enemyInfo.hero)
    -- self._arenaModel:setEnemyData(enemyData.teams)
    --
    return playerInfo, enemyInfo
end

function ArenaView:getArenaHero( id )
    local arenaHero = tab["arenaHero"]
    for k,v in pairs(arenaHero) do
        if v.heroid == id then
            return v
        end
    end
    return arenaHero[1]
end
-- 集中处理msg
function ArenaView:sendEnterArenaMsg(callback)
    local param = {}
    self._serverMgr:sendMsg("ArenaServer", "enterArena", param, true, {}, function(result)
        -- self._inGuide = true -- 调试时放开
        if self and self.reflashUI then
            self:reflashUI()
        end
        if callback then
            callback() 
        end
    end, function ()
        if callback then callback(true) end
    end)
end

-- 改变竞技场引导状态
function ArenaView:sendChangeStatusMsg(callback)
    local param = {}
    self._serverMgr:sendMsg("ArenaServer", "changeStatus", param, true, {}, function(result)
        -- self._inGuide = true -- 调试时放开
        if callback then callback() end
    end, function ()
        if callback then callback(true) end
    end)
end

function ArenaView:sendBuyChallengeNumMsg()
    local buyNum = self._arenaModel:getArena().buyNum
    local vip = self._modelMgr:getModel("VipModel"):getData().level

    local canBuyNum = tonumber(tab:Vip(vip).buyArena) 
    if buyNum >= canBuyNum then
        -- self._viewMgr:showTip("已达购买上限！")
        self._viewMgr:showDialog("global.GlobalResTipDialog",{},true)
        return 
    end
    -- local buySetting = 
    local costIdx = math.min(self._arenaModel:getArena().buyNum+1,#tab.reflashCost)-- tab:Setting("G_ARENA_BUY_GEM").value
    local nextCost = math.ceil(tab:ReflashCost(costIdx).costArena*self:getActivityDiscount())

    local gem = self._modelMgr:getModel("UserModel"):getData()["gem"]
    if nextCost < gem then
        local canBuyNum = self._arenaModel:canBuyChanllengeNum()
        local canBuyDes = lang("TIPS_ARENA_12")
        canBuyDes = string.gsub(canBuyDes,"{$resetlim}",canBuyNum)
        DialogUtils.showBuyDialog({costNum = nextCost,goods = "购买一次挑战次数(" .. canBuyDes .. ")",callback1 = function( )
            local param = {}
            self._serverMgr:sendMsg("ArenaServer", "buyChallengeNum", param, true, {}, function(result) 
                self:reflashMainBoad()
            end)    
        end})
    else
        DialogUtils.showNeedCharge({callback1=function( )
            local viewMgr = ViewManager:getInstance()
            viewMgr:showView("vip.VipView", {viewType = 0})
        end})
    end
end

function ArenaView:getRank()
    local param = {}
    self._serverMgr:sendMsg("ArenaServer", "getRank", param, true, {}, function(result) 
    end)
end

function ArenaView:sendReflashArenaMsg(callback)
    -- local buyNum = self._arenaModel:getArena().buyNum
    -- local buySetting = tab:Setting("G_ARENA_REFLASH").value
    -- local nextCost = 0
    -- for i,v in ipairs(buySetting) do
    --     if buyNum >= v[1] then
    --         nextCost = v[2]
    --     else
    --         break
    --     end
    -- end
    -- local gem = self._modelMgr:getModel("UserModel"):getData()["gem"]
    -- if nextCost < gem then
    audioMgr:playSound("Reflash")
    local param = {}
    self._serverMgr:sendMsg("ArenaServer", "reflashArena", param, true, {}, function(result) 
        if type(callback) == "function" then 
            callback()
        end
        self._refreshAnim = true
        self:reflashEnemys()
    end)
    -- else
    --     DialogUtils.showNeedCharge({callback1=function( )
    --             local viewMgr = ViewManager:getInstance()
    --             viewMgr:showView("vip.VipView", {viewType = 0})
    --         end})
    -- end
end

--[[
    竞技场复盘策略
    1. fightBefore -> 返回 攻守双方的数据
    2. 前端检查表格
    3. 前端快速战斗
    4. fightAfter  1-50名 服务器复盘 
    5. 播放战斗动画
]]--
function ArenaView:sendFightBeforeMsg(defid,defrank,idx,callback)
    local chanceNum = self._arenaModel:getArena().num
    if chanceNum <= 0 then
        self._viewMgr:showTip("今日挑战次数已达上限！")
        return 
    end
    local param = {defId = defid,defRankId = defrank,serverInfoEx = BattleUtils.getBeforeSIE()}
    self._serverMgr:sendMsg("ArenaServer", "fightBefore", param, true, {}, function(result)
        if result.errorCode or not result then
            self:sendEnterArenaMsg()
            return 
        end
        if callback then
            callback()
        end
        local curEnemyInfo = self._arenaModel:getCurEnemyInfo() -- 传入fightBefore 返回的战斗信息
        self:enterArenaBattle(idx, result.r1, result.r2, curEnemyInfo.atk.battle, curEnemyInfo.def.battle)
        -- callback(result.r1, result.r2,curEnemyInfo.def.battle)
    end)
end

function ArenaView:sendFightAfterMsg(defid,defrank,token,win,time,serverInfoEx,callback)
    local zzid = GameStatic.zzid4
    local param = {defId = defid,defRankId = defrank,token=token,args = json.encode({zzid=zzid,win=win,time=time or 0,serverInfoEx = serverInfoEx})}
    self._serverMgr:sendMsg("ArenaServer", "fightAfter", param, true, {}, function(result)
        if result["extract"] then dump(result["extract"]["hp"], "fightAfter", 10) end
        if callback then
            callback(result)
        end        
    end)
   
end

-- 暂定 引导用
function ArenaView:generateEmenyInfo(  )
    local enemyHero = tab:ArenaHero(9999)
    --  合成敌人数据
    local enemyHid = enemyHero.heroid or 60001
    local heroD = tab:Hero(enemyHid) or tab:NpcHero(enemyHid) or tab:Hero(60102)
    local slevel = {enemyHero.sl1, enemyHero.sl2, enemyHero.sl3, enemyHero.sl4, enemyHero.sl5}
    local enemyInfo = {lv = enemyHero.herolv or 15, team = {}, hero = {id = enemyHid, level = enemyHero.herolv, slevel = BattleUtils.RIGHT_HERO_SKILL_LEVEL, 
                                            star = enemyHero.herostar, mastery = {}, equip = {}}, 
                        pokedex = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, globalMasterys = nil, treasure = {}}
    for i = 1, 4 do
        repeat
            local mastery =heroD["m" .. i]
            if not mastery then break end
            table.insert(enemyInfo.hero.mastery, tonumber(mastery))
        until true
    end
    -- 不加 神器？
    -- for i = 1, 6 do
    --     repeat
    --         local artifact = enemyD.hero["artifact" .. i] or 0
    --         if not artifact or artifact == 0 then break end
    --         local stage = 0
    --         table.insert(enemyInfo.hero.equip, {id = tonumber(artifact), stage = tonumber(stage)})
    --     until true
    -- end
    enemyInfo.name = ItemUtils.randUserName()
    GRandomSeed(tostring(os.time()):reverse():sub(1, 6)) 
    enemyInfo.fScore = 1000
    enemyInfo.pokedex = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}          
    -- 随机生成 四个位置-- TODO 暂时写钱四个
    local formation = {}
    formation.heroId = enemyHero.heroid or 60001
    local teams = {}
    formation.score = 0
    for i=1,8 do
        if i < 5 then
            local arenaNpc = tab:ArenaNpc(9990+i-1)
            formation["team" .. i] = arenaNpc.npcid
            formation["g" .. i] = 4*(arenaNpc.pos)+i
            local team = {}
            team.stage = arenaNpc.stage
            team.star = arenaNpc.star
            team.level = enemyHero.herolv
            teams[arenaNpc.npcid] = team
            formation.score = formation.score + tab:Team(arenaNpc.npcid or 101).score
        else
            formation["team" .. i] = 0
            formation["g" .. i] = 0
        end
    end
    formation.filter = ""
    enemyInfo.formation = formation
    enemyInfo.fScore = enemyInfo.fScore + formation.score
    local formationPD = {}
    for i=1,100 do
        local team = formation["team" .. i]
        local g = formation["g" .. i]
        if team == nil then
            break
        else
            formationPD[tonumber(team)] = tonumber(g)
        end
    end
    enemyInfo.team = {}
    local setTeams = {}
    for k,v in pairs(teams) do
        local tid = tonumber(k)
        local team = {
            id = tid,
            pos = formationPD[tid],
            level = v.level,
            star = v.star,
            stage = v.stage,
            equip = {
                -- {stage = 1,level=0},
                -- {stage = 1,level=0},
                -- {stage = 1,level=0},
                -- {stage = 1,level=0},
            },
            skill = {
                -- 0,0,0,0
            }
        }
        for i=1,4 do
            local equipStage = enemyHero["equipstage"]
            local equipLevel = enemyHero["equiplv"]
            table.insert(team.equip,{stage=equipStage,level=equipLevel})
            local skillLevel = enemyHero["skilllv"]
            table.insert(team.skill,skillLevel)
        end
        table.insert(enemyInfo.team,team)
        setTeams[tid] = team
    end
    -- local teamModel = self._modelMgr:getModel("TeamModel")
    -- teamModel:setEnemyData(setTeams)
    self._arenaModel:setEnemyHeroData(enemyInfo.hero)
    self._arenaModel:setEnemyData(setTeams)
    
    return enemyInfo
end

-- 2016.5.25 by guojun -- 改竞技长列表为tableView
function ArenaView:addTableView( )
    local tableWidth = 1136
    local tableOffsetX = -88
    if MAX_SCREEN_WIDTH == 960 then
        tableWidth = 960
        tableOffsetX = 0
    end
    local tableView = cc.TableView:create(cc.size(tableWidth, 480))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    tableView:setPosition(cc.p(tableOffsetX,100))
    tableView:setDelegate()
    -- tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    tableView:setName("tableView")
    self._layer:addChild(tableView)
    tableView:registerScriptHandler(function( view )
        return self:scrollViewDidScroll(view)
    end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(function( view )
        return self:scrollViewDidZoom(view)
    end ,cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(function ( table,cell )
        return self:tableCellTouched(table,cell)
    end,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(function( table,index )
        return self:cellSizeForTable(table,index)
    end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function ( table,index )
        return self:tableCellAtIndex(table,index)
    end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function ( table )
        return self:numberOfCellsInTableView(table)
    end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self:reloadArenaTableData()
    -- tableView:reloadData()
    -- tableView:setContentOffset(cc.p(-(#self._tableData-5)*175,0))
    self._tableView = tableView
end

function ArenaView:scrollViewDidScroll(view)
    if view:isDragging() then
        self._refreshAnim = false
    end
    local container = self._tableView:getContainer()
    if container and self._rightArrow and self._leftArrow then
        local x = container:getPositionX()
        local offMax = self._tableView:maxContainerOffset().x
        local offMin = self._tableView:minContainerOffset().x
        self._leftArrow:setVisible(x < offMax-20 )
        self._rightArrow:setVisible(x > offMin+20)
    end
end

function ArenaView:scrollViewDidZoom(view)
end

function ArenaView:tableCellTouched(table,cell)
end

function ArenaView:cellSizeForTable(table,idx) 
    return 340,194
end

function ArenaView:tableCellAtIndex(table, idx)
    local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
    else
        local enemyBoard = cell:getChildByName("cellBoard")
        if enemyBoard then
            local refreshMc = enemyBoard:getChildByName("refreshMc")
            if refreshMc and table:isDragging() then
                refreshMc:removeFromParent()
                enemyBoard.mc = nil
            end
        end
        local slogan = cell:getChildByFullName("slogan")
        if slogan then
            slogan:setVisible(false)
        end
    end
    local enemyBoard = cell:getChildByName("cellBoard")
    if enemyBoard then
        -- local refreshMc = enemyBoard:getChildByName("refreshMc")
        -- if refreshMc and table:isDragging() then
        --     refreshMc:removeFromParent()
        -- end
        self:updateCellBoard(enemyBoard,idx+1)
    else 
        local enemyBoard = self._enemyBoard:clone() 
        enemyBoard:setVisible(true)
        self:L10N_Text(enemyBoard)
        self:updateCellBoard(enemyBoard,idx+1)
        enemyBoard:setAnchorPoint(cc.p(0,0))
        enemyBoard:setName("cellBoard")
        enemyBoard:setPosition(5,0)
        cell:addChild(enemyBoard)
    end
    if idx == #self._tableData-1 then 
        cell:setName("guidCell")
    else
        cell:setName("commonCell")
    end
    return cell
end

function ArenaView:numberOfCellsInTableView(table)
   return #(self._tableData or {})
end

function ArenaView:updateCellBoard( enemyBoard,idx )
    local enemyD = self._arenaModel:getEnemys()[idx]
    local challengeBtn = enemyBoard:getChildByFullName("challengeBtn")
    local erank = enemyD.rank
    local myRank = self._arenaModel:getRank() 
    if self._inGuide and erank == myRank then
        enemyD = self:generateEmenyInfo()
    end
    local mineDes = enemyBoard:getChildByName("selfImg") -- 标志自己
    if not tolua.isnull(mineDes) then
        mineDes:setVisible(false)
    end
    if erank ~= myRank then
        if (erank <=10 and myRank <= 20) or (erank > 10 ) then
            self:registerClickEvent(challengeBtn,function()
                self._challengeIndx = idx
                local challengeNum = self._arenaModel:getArena().num or 0
                if challengeNum <= 0 then
                    local buyNum = self._arenaModel:getArena().buyNum
                    local vip = self._modelMgr:getModel("VipModel"):getData().level

                    local canBuyNum = tonumber(tab:Vip(vip).buyArena) 
                    if buyNum >= canBuyNum then
                        -- self._viewMgr:showTip("已达购买上限！")
                        self._viewMgr:showDialog("global.GlobalResTipDialog",{},true)
                        return 
                    end 
                    local costIdx = math.min(self._arenaModel:getArena().buyNum+1,#tab.reflashCost)-- tab:Setting("G_ARENA_BUY_GEM").value
                    local nextCost = math.ceil(tab:ReflashCost(costIdx).costArena*self:getActivityDiscount())
                    local canBuyNum = self._arenaModel:canBuyChanllengeNum()
                    local canBuyDes = lang("TIPS_ARENA_12")
                    canBuyDes = string.gsub(canBuyDes,"{$resetlim}",canBuyNum)
                    self._viewMgr:showDialog("arena.ArenaDialogBuyCounts",{desc = "[color=462800,fontsize=24]是否花费[pic=globalImageUI_littleDiamond.png][-][color=462800,fontsize=24]"..nextCost.."[-][-][color=462800,fontsize=24]购买一次挑战次数(".. canBuyDes ..")并进入战斗[-]",
                        callBack1 = function()
                            self:addCountBackFunc(function( )
                                self:challengeEnemy(self._challengeIndx)
                            end)
                        end                 
                    })
                    -- self._viewMgr:showTip("今日挑战次数已达上限！")
                    return 
                end
                if self._challengeCD then
                    local gem = self._modelMgr:getModel("UserModel"):getData()["gem"]
                    local cost = tab:Setting("G_ARENA_DEL_CD").value
                    self._arenaCDView = self._viewMgr:showDialog("arena.ArenaDialogCD",
                        {desc = "[color=462800,fontsize=24]是否花费[pic=globalImageUI_littleDiamond.png][-][color=462800,fontsize=24]"..cost.."[-][-][color=462800,fontsize=24]消除冷却，并进入战斗[-]",
                        --确定回调
                        callBack1 = function()
                            self:CDCallbackFunc()
                        end,  
                        --取消回调 
                         callBack2 = function()
                            if self._arenaCDView then
                                self._viewMgr:closeDialog(self._arenaCDView)
                                self._arenaCDView = nil
                            end
                        end            
                    })   
                    -- 更新倒计时显示                 
                    if self._arenaCDView then
                        self._arenaCDView:CDupdate(self._cdTimeNum)
                    end
                    -- local des = (self._cdTime:getString() or "") .. (self._cdDes:getString() or "")
                    -- local des = string.gsub(lang("TIPS_ARENA_10"),"%b{}",function( )
                    --     return self._cdTime:getString() or ""
                    -- end )
                    -- self._viewMgr:showTip(des)
                    return  
                end
                local formationModel = self._modelMgr:getModel("FormationModel")
                local data = formationModel:getFormationData()[formationModel.kFormationTypeArena] or {}
                local hadFormation = false
                for k,v in pairs(data) do
                    if string.find(k,"g") and v ~= 0 then
                        hadFormation = true
                    end
                end
                if hadFormation then
                    if self._inGuide and erank == myRank then
                        self:enterArenaFirstBattle()
                        self._inGuide = false
                    else
                        self:challengeEnemy(idx)
                    end
                else
                    self._viewMgr:showTip("请先设置阵型！")
                end
            end)
            challengeBtn:setSwallowTouches(true)
            challengeBtn:loadTextures("globalButtonUI13_1_1.png","globalButtonUI13_1_1.png","",1)
            challengeBtn:setTitleText("挑战")
        else
            self:registerClickEvent(challengeBtn,function()
            end)
            challengeBtn:setSwallowTouches(false)
            challengeBtn:loadTextures("globalButtonUI13_3_1.png","globalButtonUI13_3_1.png","",1)
            challengeBtn:setTitleText("查看")
        end
        challengeBtn:setVisible(true)
        local beginX
        self:registerTouchEvent(enemyBoard,function( _,x,y )
            beginX = x
        end,nil,function( _,x,y )
            if beginX and math.abs(x-beginX) < 5 then
                self._serverMgr:sendMsg("ArenaServer", "getDetailInfo", {roleId = self._arenaModel:getEnemys()[idx].rid or  self._arenaModel:getEnemys()[idx]._id}, true, {}, function(result) 
                    local info = result.info
                    info.battle.msg = info.msg
                    info.battle.rank = info.rank
                    self._viewMgr:showDialog("arena.DialogArenaUserInfo",info.battle,true)
                end)
                -- local enemyD = self._arenaModel:getEnemys()[idx]
                -- self._viewMgr:showDialog("arena.DialogArenaUserInfo",enemyD,true)
            end
        end,nil)
    else
        if self._inGuide then
            challengeBtn:setVisible(true)
            challengeBtn:setTitleText("挑战")
            challengeBtn:loadTextures("globalButtonUI13_1_1.png","globalButtonUI13_1_1.png","",1)
            mineDes:setVisible(false)
        else
            challengeBtn:setVisible(false)
            mineDes:setVisible(true)
        end
        self:registerClickEvent(challengeBtn,function( _,x,y )
            if self._inGuide then
                self:enterArenaFirstBattle()
            end
        end)
        self:registerClickEvent(enemyBoard,function( _,x,y )
        end)
    end 
    enemyBoard:setSwallowTouches(false)
    enemyBoard.data = enemyD
    local name = enemyBoard:getChildByFullName("name")
    name:setString(enemyD.name or "没有名字")
    name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    name:setZOrder(10)
    local des1 = enemyBoard:getChildByFullName("des1")
    des1:setZOrder(10)
    local des2 = enemyBoard:getChildByFullName("des2")
    des2:setZOrder(10)
    -- des1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    -- des1:setVisible(false) -- 隐藏des1 : 战斗力 用rank直接表示
    local level = enemyBoard:getChildByFullName("level")
    level:setString("lv." .. (enemyD.lv or "0"))
    local rank = enemyBoard:getChildByFullName("rank")
    rank:setZOrder(10)
    -- rank:setAnchorPoint(cc.p(0.5,0.5))
    -- rank:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    rank:setString((erank or "0"))
    if erank > 10000 then
        rank:setString("10000")
    end
    -- local heroBg = enemyBoard:getChildByName("heroBg")
    -- heroBg:loadTexture("asset/uiother/dizuo/heroDizuo.png")
    local zhandouliLab = enemyBoard:getChildByFullName("zhandouliLab")
    if not zhandouliLab then
        zhandouliLab = ccui.TextBMFont:create("0", UIUtils.bmfName_zhandouli_little)
        zhandouliLab:setAnchorPoint(cc.p(1,0.5))
        zhandouliLab:setPosition(160,303)
        zhandouliLab:setName("zhandouliLab")
        enemyBoard:addChild(zhandouliLab,99)
        zhandouliLab:setFntFile(UIUtils.bmfName_zhandouli_little)  
    end      
    zhandouliLab:setString("" .. (enemyD.fScore or "0"))
    zhandouliLab:setScale(0.41)
    if erank == myRank then
        if erank > 10000 then 
            erank = 10000
        end
        local selfDefScore = self:updateDefFightNum()
        if selfDefScore and selfDefScore > 0 and not self._inGuide then
            zhandouliLab:setString(selfDefScore) -- 矫正没及时刷新自己战斗力
        end
        if self._inGuide then
            level:setString("lv.15")
        end
    end

    if self._inGuide then
        challengeBtn:setVisible(true)
        mineDes:setVisible(false)
    elseif erank == myRank then
        challengeBtn:setVisible(false)
        mineDes:setVisible(true)
    end
    -- 序列帧形象
    if enemyBoard.sp and not tolua.isnull(enemyBoard.sp) then
        enemyBoard.sp:removeFromParent()
    end
    if enemyBoard.spWin and not tolua.isnull(enemyBoard.spWin) then
        enemyBoard.spWin:removeFromParent()
    end
    enemyBoard.sp = nil
    local avatar = 1204
    if enemyD.avatar and enemyD.avatar > 0 then
        avatar = enemyD.avatar
    end
    local enemyId = enemyD.heroId
    if erank == myRank then
        local formationModel = self._modelMgr:getModel("FormationModel")
        local data = formationModel:getFormationData()[formationModel.kFormationTypeArenaDef]
        enemyId = data.heroId 
    end
    enemyBoard.heroId = enemyId
    if not enemyBoard.sp then
        if not self._spLoadIdx or self._spLoadIdx > 5 then
            self._spLoadIdx = 0
        end
        self._spLoadIdx = self._spLoadIdx + 1
        local function addSp( )
            if enemyBoard and not tolua.isnull(enemyBoard) then
                local isReload = false
                if enemyBoard.sp and not tolua.isnull(enemyBoard.sp) then -- 因为是异步防止重复添加
                    enemyBoard.sp:removeFromParent()
                    isReload = true
                end
                if enemyBoard.spWin and not tolua.isnull(enemyBoard.spWin) then -- 因为是异步防止重复添加
                    enemyBoard.spWin:removeFromParent()
                end
                local enemyId = enemyBoard.heroId or enemyId or 60001
                local heroD = tab:Hero(enemyId or 60001)
                if not heroD then
                    print("没有英雄数据！！")
                    heroD = tab:Hero(60001)
                end 
                local heroArt = heroD["heroart"]
                if enemyD.heroSkin and enemyD.heroSkin ~= 0  then
                    local heroSkinD = tab.heroSkin[enemyD.heroSkin]
                    heroArt = heroSkinD["heroart"] or heroD["heroart"]
                end
                local sp = mcMgr:createViewMC("stop_" .. heroArt, true)
                -- sp:setVisible(false)
                sp:setScale(-0.8,0.8)
                -- 判断艾德雷得 飞行类 降低显示高度
                local specialLow = 0
                if enemyId == 60001 then
                    specialLow = 18
                end
                sp:setPosition(enemyBoard:getContentSize().width / 2, enemyBoard:getContentSize().height / 2 -80-specialLow)
                enemyBoard:addChild(sp,8)
                enemyBoard.sp = sp
                

                -- [[ 跟气泡一起展示
                local spWin = mcMgr:createViewMC("win_" .. heroArt, true,false,function( )
                    if enemyBoard and enemyBoard.sp and not enemyBoard.sp:isVisible() then
                        enemyBoard.spWin:setVisible(false)
                        enemyBoard.spWin:gotoAndStop(0)
                        enemyBoard.sp:setVisible(true)
                    end
                end)
                -- sp:setVisible(false)
                spWin:setScale(-0.8,0.8)
                -- 判断艾德雷得 飞行类 降低显示高度
                local specialLow = 0
                if enemyId == 60001 then
                    specialLow = 18
                end
                spWin:setPosition(enemyBoard:getContentSize().width / 2, enemyBoard:getContentSize().height / 2 -80-specialLow)
                enemyBoard:addChild(spWin,8)
                enemyBoard.spWin = spWin
                --]]

                enemyBoard.sp:setVisible(true)
                enemyBoard.spWin:setVisible(false)
                enemyBoard.spWin:stop()
                if self._refreshAnim or isReload then
                    enemyBoard.sp:setVisible(false)
                    enemyBoard.spWin:setVisible(true)
                    enemyBoard.spWin:gotoAndPlay(0)
                end

                if self._refreshAnim then
                    local refreshMc = enemyBoard:getChildByName("refreshMc")
                    if refreshMc then
                        refreshMc:removeFromParent()
                        enemyBoard.mc = nil
                    end
                    local mc = mcMgr:createViewMC("shangdianshuaxin_arenarefreshanim", false, true,function( )
                        self._refreshAnim = false
                        enemyBoard.mc = nil
                    end)
                    mc:setPosition(cc.p(85,80))
                    mc:setName("refreshMc")
                    enemyBoard:addChild(mc,10)
                    enemyBoard.mc = mc
                end
            end
        end
        if self._initLoadAllready then
            local heroD = tab:Hero(enemyId or 60001)
            if not heroD then
                print("没有英雄数据")
                heroD = tab:Hero(60001)
            end
            enemyBoard.__heroare = heroD.heroart
            mcMgr:loadRes(heroD.heroart, function (filename)
                if enemyBoard.__heroare ~= filename then return end
                addSp(true)
            end)
        else
            enemyBoard:runAction(cc.Sequence:create(cc.DelayTime:create(0.06*self._spLoadIdx),cc.CallFunc:create(function( )
                local heroD = tab:Hero(enemyId or 60001)
                enemyBoard.__heroare = heroD.heroart
                mcMgr:loadRes(heroD.heroart, function (filename)
                    if enemyBoard.__heroare ~= filename then return end
                    addSp(true)
                end)
                if self._spLoadIdx and self._spLoadIdx > 4 and not self._initLoadAllready then
                    self._initLoadAllready = true
                end
            end)))
        end
    end

    local index = self:getBoardColorIndex(erank)
    -- local boardName = "arenaMain_cellBg" .. index .. ".png"
    -- enemyBoard:loadTexture(boardName,1)
    -- enemyBoard:setScale9Enabled(true)
    -- enemyBoard:setCapInsets(cc.rect(16,40,4,1))
    -- name:setColor(UIUtils.colorTable["ccColorQuality" .. index])
    local infoBg = enemyBoard:getChildByFullName("infoBg")
    infoBg:loadTexture("arenaMain_infoBg" .. index .. ".png",1)
    enemyBoard:setOpacity(0)

    -- 换底座
    local heroBg = enemyBoard:getChildByFullName("heroBg")
    heroBg:loadTexture("arenaMain_heroBg" .. index .. ".png",1)
    heroBg:setScale(1)
    heroBg:setPositionY(98)

    -- [[2017.1.4 新增扫荡逻辑
    local havePrivilege = ModelManager:getInstance():getModel("PrivilegesModel"):getPeerageEffect(PrivilegeUtils.peerage_ID.JingJiTiaoGuo) == 1
    local isBeyondBojue   = ModelManager:getInstance():getModel("PrivilegesModel"):getPeerage() >= 4
    local text = challengeBtn:getTitleRenderer()
    local sweepBtn = enemyBoard:getChildByName("sweepBtn")
    self:L10N_Text(challengeBtn)
    challengeBtn:setScale(.9)
    if erank > myRank and (havePrivilege or isBeyondBojue)then
        challengeBtn:loadTextures("little_btn_o_arena.png","little_btn_o_arena.png","",1)
        text:setString("挑战")
        -- text:setScaleX(2)
        challengeBtn:setPositionX(48)
        challengeBtn:setScale(0.9)
        if not sweepBtn then
            sweepBtn = challengeBtn:clone()
            sweepBtn:loadTextures("little_btn_b_arena.png","little_btn_b_arena.png","",1)
            sweepBtn:setPositionX(123.5)
            sweepBtn:setName("sweepBtn")
            sweepBtn:setTitleText("扫荡")
            self:L10N_Text(sweepBtn)
            sweepBtn:enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine2,2)
            local textS = sweepBtn:getTitleRenderer()
            -- textS:setScaleX(2)
            enemyBoard:addChild(sweepBtn)
        else
            sweepBtn:setVisible(true)
        end
        sweepBtn:setScale(0.9)
        if havePrivilege then
            UIUtils:setGray(sweepBtn,false)
            self:registerClickEvent(sweepBtn,function() 
                self:sendSweepMsg(enemyD)
            end)
        else
            UIUtils:setGray(sweepBtn,true)
            self:registerClickEvent(sweepBtn,function() 
                self._viewMgr:showTip(lang("TIPS_ARENA_13"))
            end)
        end
    else
        -- text:setScaleX(1)
        -- challengeBtn:setScaleX(.9)
        -- challengeBtn:loadTextures("globalButtonUI13_1_1.png","globalButtonUI13_1_1.png","",1)
        challengeBtn:setPositionX(83.5)
        if sweepBtn then
            sweepBtn:setVisible(false)
        end
    end
    --]]

    return enemyBoard
end

-- 扫荡协议
function ArenaView:sendSweepMsg( enemyD )
    local buyNum = self._arenaModel:getArena().buyNum
    local vip = self._modelMgr:getModel("VipModel"):getData().level
    local challengeNum = self._arenaModel:getArena().num or 0
print("buyNum",buyNum)
    local canBuyNum = tonumber(tab:Vip(vip).buyArena) 
    if buyNum >= canBuyNum and challengeNum <= 0 then
        -- self._viewMgr:showTip("已达购买上限！")
        self._viewMgr:showDialog("global.GlobalResTipDialog",{},true)
        return 
    end 
    local costIdx = math.min(self._arenaModel:getArena().buyNum+1,#tab.reflashCost)-- tab:Setting("G_ARENA_BUY_GEM").value
    local nextCost = math.ceil(tab:ReflashCost(costIdx).costArena*self:getActivityDiscount())

    local gem = self._modelMgr:getModel("UserModel"):getData()["gem"]
    if nextCost < gem or challengeNum > 0 then
        local challengeNum = self._arenaModel:getArena().num or 0
        if challengeNum <= 0 then
            local buyNum = self._arenaModel:getArena().buyNum
            local vip = self._modelMgr:getModel("VipModel"):getData().level

            local canBuyNum = tonumber(tab:Vip(vip).buyArena) 
            if buyNum >= canBuyNum then
                -- self._viewMgr:showTip("已达购买上限！")
                self._viewMgr:showDialog("global.GlobalResTipDialog",{},true)
                return 
            end 
            local costIdx = math.min(self._arenaModel:getArena().buyNum+1,#tab.reflashCost)-- tab:Setting("G_ARENA_BUY_GEM").value
            local nextCost = math.ceil(tab:ReflashCost(costIdx).costArena*self:getActivityDiscount())
            local canBuyNum = self._arenaModel:canBuyChanllengeNum()
            local canBuyDes = lang("TIPS_ARENA_12")
            canBuyDes = string.gsub(canBuyDes,"{$resetlim}",canBuyNum)
            self._viewMgr:showDialog("arena.ArenaDialogBuyCounts",{desc = "[color=462800,fontsize=24]是否花费[pic=globalImageUI_littleDiamond.png][-][color=462800,fontsize=24]"..nextCost.."[-][-][color=462800,fontsize=24]购买一次挑战次数(".. canBuyDes ..")并扫荡[-]",
                callBack1 = function()
                    self:addCountBackFunc(function( )
                        self._serverMgr:sendMsg("ArenaServer", "sweepEnemy", {defId = enemyD.rid,defRank = enemyD.rank}, true, {}, function(result)
                           dump(result)
                           self._viewMgr:showDialog("arena.ArenaTurnCardView",{awards = result.rewards})
                           -- DialogUtils.showGiftGet({gifts={result.rewards["1"]}})
                        end, function ()
                            
                        end)
                    end)
                end                 
            })
            -- self._viewMgr:showTip("今日挑战次数已达上限！")
            return 
        else
            self._serverMgr:sendMsg("ArenaServer", "sweepEnemy", {defId = enemyD.rid,defRank = enemyD.rank}, true, {}, function(result)
               dump(result)
               self._viewMgr:showDialog("arena.ArenaTurnCardView",{awards = result.rewards})
               -- DialogUtils.showGiftGet({gifts={result.rewards["1"]}})
            end, function ()
                
            end)
        end
    else
        DialogUtils.showNeedCharge({callback1=function( )
            local viewMgr = ViewManager:getInstance()
            viewMgr:showView("vip.VipView", {viewType = 0})
        end})
    end
end

function ArenaView:getSelfBoardIdxInTable( )
    if not self._tableData or #self._tableData < 1 then return 0 end
    local myRank = self._arenaModel:getRank()
    for i,v in ipairs(self._tableData) do
        local erank = v.rank
        if erank == myRank then
            return i
        end
    end
    return #self._tableData
end

-- 调整自己的位置在第二个（非前4)
function ArenaView:reloadArenaTableData( )

    -- body
    if not self._tableView then return end
    self._tableView:reloadData()
    local selfDataIdx = self:getSelfBoardIdxInTable() or 0
    local myRank = self._arenaModel:getRank() or 0
    local preNum = MAX_SCREEN_WIDTH == 960 and 4 or 5
    local isSelfLast = #self._tableData == selfDataIdx
    if isSelfLast then
        preNum = MAX_SCREEN_WIDTH == 960 and 5 or 6
    end

    self._tableView:setContentOffset(cc.p(-(selfDataIdx-math.min(preNum,myRank))*194,0))

    -- if true then return end 

--[[
    local selfDataIdx = self:getSelfBoardIdxInTable() or 0
    local myRank = self._arenaModel:getRank() or 0
    local preNum = 5 

    -- print("self._inguide firstIn....", self._inGuide or not self._firstIn, self._inGuide , not self._firstIn)
    
    -- 在引导中 or 不是首次进竞技场 or 最后一个是自己 then --> tableview不需要移动
    -- 首进移动到最后一个是自己的位置
    local isSelfLast = #self._tableData == selfDataIdx
    if self._inGuide or not self._firstIn or isSelfLast or myRank < 5 then  
        self._tableView:setContentOffset(cc.p(-(selfDataIdx-math.min(preNum,myRank))*175-5,0))
        -- if self._updateScroll then
        --     ScheduleMgr:unregSchedule(self._updateScroll)
        --     self._updateScroll = nil
        --     self._viewMgr:unlock()
        --     self._firstIn = false
        -- end
    else  
        -- [[ 
        -- print("=====================selfDataIdx,===",selfDataIdx)
        preNum = 4
        self._tableView:setContentOffset(cc.p(-(selfDataIdx-math.min(preNum,myRank))*175,0))
        self._viewMgr:lock(-1)
        --time  延迟移动动画用 停一下在滑动
        local time = 0        
        self._updateScroll = ScheduleMgr:regSchedule(1,self,function()
            time = time + 1 
            if time > 20 then
                local offsetX = self._tableView:getContentOffset().x
                if offsetX < -(selfDataIdx-math.min(preNum+1,myRank))*175 - 5 then
                    self._tableView:setContentOffset(cc.p(offsetX+10,0))
                else
                    self._viewMgr:unlock()
                    ScheduleMgr:unregSchedule(self._updateScroll)
                    self._updateScroll = nil
                end
            end
        end)
        --]]

        --[[
            
        -- 1.引导 or 非首次进 or 排名小于30     不自动滑动，定位到最后一个是自己的位置
        -- 2.非引导 and 首次进 and 排名大于30   自动滑动到可挑战的第一个人的位置
        -- 规则修改 2017.01.13
        self._tableView:setContentOffset(cc.p(-(#self._tableData-5)*175,0))
        self._viewMgr:lock(-1)
        --time  延迟移动动画用 停一下在滑动,为了看清后面有可挑战的敌人
        local time = 0        
        self._updateScroll = ScheduleMgr:regSchedule(1,self,function()
            time = time + 1 
            if time > 20 then
                local offsetX = self._tableView:getContentOffset().x
                -- 最终位置是第十一名的位置
                local num = selfDataIdx == 11 and 11 or 10
                if offsetX < -1*num*175 - 5 then
                    self._tableView:setContentOffset(cc.p(offsetX+10,0))
                else
                    self._viewMgr:unlock()
                    ScheduleMgr:unregSchedule(self._updateScroll)
                    self._updateScroll = nil
                end
            end
        end)
        self._firstIn = false
        --]]
        --[[
    end
    self._firstIn = false
]]
end

function ArenaView:getActivityDiscount( )
    local actModel = self._modelMgr:getModel("ActivityModel")
    local actCostLess = actModel:getAbilityEffect(actModel.PrivilegIDs.PrivilegID_15)
    return (1+actCostLess)
end

return ArenaView
