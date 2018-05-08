--
-- Author: <wangguojun@playcrab.com>
-- Date: 2016-10-14 15:20:42
--
-- 格子位置
require("game.view.activity.adventure.AdventureConst")
local gridPoses = AdventureConst.gridPoses
local WARP_GATE_FROMID -- 传送门对应的格子id
local WARP_GATE_TOID   -- 传送门出口对应的格子Id
local TREASUREMAP_ID   -- 藏宝图id
local GRID_TYPE = AdventureConst.GRID_TYPE
local AdventureView = class("AdventureView",BaseView)
function AdventureView:ctor()
    self.super.ctor(self)
    self._adModel = self._modelMgr:getModel("AdventureModel")
    self._naviBar = self._viewMgr:getNavigation("global.UserInfoView")
    self.fixMaxWidth = ADOPT_IPHONEX and 1136 or nil 
    -- 第一次不延迟刷新
    -- self._viewMgr:showNavigation("global.UserInfoView",{types = {"Dice","Gold","Gem",},title = "globalTitleUI_yijitanxian.png"})
end

function AdventureView:getAsyncRes()
    return 
    {
        {"asset/ui/adventure.plist", "asset/ui/adventure.png"},
        {"asset/bg/adventure_bg.plist", "asset/bg/adventure_bg.png"},
        {"asset/ui/task.plist", "asset/ui/task.png"},
    }
end

-- function AdventureView:getBgName()
--     return "bg_adventure.jpg"
-- end

function AdventureView:setNavigation()
    if  self._inHide then return end
    self._viewMgr:showNavigation("global.UserInfoView",{types = {"Dice","Gold","Gem",},title = "globalTitleUI_yijitanxian.png",titleTxt = "神秘宝藏",delayReflash = true}, nil, ADOPT_IPHONEX and self.fixMaxWidth or nil)
end

-- 不延迟刷导航条
function AdventureView:reflashNaviDiceOnly()
    -- self._viewMgr:showNavigation("global.UserInfoView",{types = {"Dice","Gold","Gem",},title = "globalTitleUI_yijitanxian.png"})
    self._naviBar:reflashDiceOnly()
    -- self:setNavigation()
end

-- 配合导航条延迟刷新 刷新方法
function AdventureView:reflashNaviBarRightNow( )
    if self._inHide then return end
    self._viewMgr:showNavigation("global.UserInfoView",{types = {"Dice","Gold","Gem",},titleTxt = "神秘宝藏",title = "globalTitleUI_yijitanxian.png"}, nil, ADOPT_IPHONEX and self.fixMaxWidth or nil)
    self:setNavigation()
end


function AdventureView:onBeforeAdd( callback,errorCallback )
    self._serverMgr:sendMsg("AdventureServer", "init", {}, true, { }, function(result)
        if _error then
            errorCallback()
        else
            callback()
        end
        -- dump(result)
        if self.reflashInitRolePos then
            self:reflashInitRolePos()
            self:refreshEventStatus()
            self:reflashAllGrids()
            self:refreshBoxStatus()
        end
    end,function( )
        ViewManager:getInstance():unlock()
        ViewManager:getInstance():popView()
        ViewManager:getInstance():showTip("活动未开启！")
        if self._leftTimeSche then
            ScheduleMgr:unregSchedule(self._leftTimeSche)
            self._leftTimeSche = nil
        end
    end )
end

-- 判断有没有 弹窗
function AdventureView:hadDialog( )
    return self.__modalLayer and #self.__modalLayer:getChildren() > 0 
end

function AdventureView:closeAdventureDialog( )
    if self:hadDialog() then
        self:closeDialog(self.__modalLayer:getChildren()[#self.__modalLayer:getChildren()])
    end
end
function AdventureView:onHide( )
    self._inHide = true
    print("onhide......===============================",self._inHide)
    self._viewMgr:disableScreenWidthBar()
end
-- 
function AdventureView:onShow( )
     self._inHide = nil
    self._inSecondView = nil
    self:reflashNaviBarRightNow()
    if self._adModel:isMagicBoxClosing() then
        self:showPrompt( GRID_TYPE.MAGIC_BOX,1,nil,true)
    end 
end
function AdventureView:onTop( )
     self._inHide = nil
    self._inSecondView = nil
    self:reflashNaviBarRightNow()
    if self._adModel:isMagicBoxClosing() then
        self:showPrompt( GRID_TYPE.MAGIC_BOX,1,function( )
            local panRwd = self._adModel:getPanRwd()
            if panRwd then
                DialogUtils.showGiftGet(panRwd)
            end
        end,true)
    end 
    self._viewMgr:enableScreenWidthBar()
end

function AdventureView:onComplete()
    self._viewMgr:enableScreenWidthBar()
end
-- 初始化UI后会调用, 有需要请覆盖
function AdventureView:onInit()
    self._preBGMName = audioMgr:getMusicFileName()
    audioMgr:playMusic("HappyGame", true)
    if --[[
        false and
        --]] 
        OS_IS_WINDOWS then
        for i=1,6 do
            self:registerClickEventByName("bg.testLayer.dice1_" .. (i-1),function( )
                self:throwDiceFunc(i)
                -- self:testEvent()
            end)
        end
        self:registerTouchEventByName("bg.numBg",nil,nil,nil,nil,function( )
            print("testLayer...")
            self:getUI("bg.testLayer"):setVisible(not self:getUI("bg.testLayer"):isVisible())
        end)
    end
    self:getUI("bg.testLayer"):setVisible(false)
    ------ 初始化UI对象
    --- 初始化背景图
    self._inner_bg = self:getUI("bg.gridLayer.inner_bg")
    self._inner_bg:loadTexture("adventure_innerBg.png",1)
    self._bottom_bg = self:getUI("bg.gridLayer.bottom_bg")
    self._bottom_bg:loadTexture("adventure_bg.jpg",1)
    self._leftbottom_bg = self:getUI("bg.gridLayer.leftbottom_bg")
    self._leftbottom_bg:loadTexture("adventure_leftbottom.png",1)

    self._bg = self:getUI("bg")
    self._gridLayer = self:getUI("bg.gridLayer")
    self._gridLayer:setVisible(true)
    -- self._diceLab = self:getUI("bg.right.saizi")
    -- self._diceLab:setString("投掷")
    self._numLab = self:getUI("bg.right.num")
    self._numLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._startBtn = self:getUI("bg.right.startBtn")
    self._touchTip = self:getUI("bg.gridLayer.touchTip")
    self._touchTip:setVisible(false)
    self._touchTipTxt = self:getUI("bg.gridLayer.touchTip.tipTxt")

    local awardTxt = self:getUI("bg.bottom.awardTxt")
    if awardTxt then
        awardTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    end

    UIUtils:addFuncBtnName(self:getUI("bg.bottom.awardBtn"),"已得奖励",nil,true)

    -- 奖励宝箱
    self._proBar = self:getUI("bg.bottom.proBar")
    self._proBar:setScale9Enabled(true)
    self._proBar:setCapInsets(cc.rect(10,6,1,1))
    self._boxes = {}
    for i=1,6 do
        local lab = self:getUI("bg.bottom.lab" .. i)
        if lab then
            lab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        end
        local box = self:getUI("bg.bottom.rewardBox" .. i)
        table.insert(self._boxes,box)
        self:registerClickEvent(box,function( )
            local status = self._adModel:hadBoxGeted(i)
            if status == 1 then
                self._serverMgr:sendMsg("AdventureServer", "getRoundReward", {bid = i}, true, { }, function(result)
                    dump(result,"领取奖励宝箱",10)
                    local reward = result.rwd 
                    DialogUtils.showGiftGet(reward)
                    self:refreshBoxStatus()
                    self:reflashNaviBarRightNow()
                end)
            elseif status == 2 then
            elseif status == 0 then -- 不满足条件时候预览宝箱
                local reward = tab.activity907[i+6].param
                DialogUtils.showGiftGet({gifts=reward,viewType=1,des="第".. i .. "圈宝箱奖励"})
            end
        end)

    end
    -- 提示
    self._promptPanel = self:getUI("bg.promptPanel")
    self._promptPanel:setVisible(false)
    self._promptPage = 1
    self._proNext = self:getUI("bg.promptPanel.next")
    self._proDesLab = self:getUI("bg.promptPanel.desLab")
    self._proIcon = self:getUI("bg.promptPanel.icon")
    self:registerClickEvent(self._promptPanel,function() 
        if self._tempPromptParams then
            local eventType,idx,callback,isEnd,prompts,isTest = unpack(self._tempPromptParams)
            self:showPrompt(eventType,idx+1,callback,isEnd,prompts,isTest)
        end
    end)
    -- 控制
    self._grids = {}
    self._path = {}

    ------ 按钮事件
    local btnNames = {"bg.bottom.ruleBtn","bg.bottom.awardBtn","bg.right.startBtn"}
    local btnEvents = {"showRule","showGetedAward","throwDiceFunc","testEvent"}
    for i,btnName in ipairs(btnNames) do
        self:registerClickEventByName(btnName,function( )
            self[btnEvents[i]](self)
        end)
    end

    -- 格子 类型对应事件
    self._gridEvents = AdventureConst.gridEvents

    self._eventStatus = { -- 记录 触发魔井 魔盒之后的事件状态
        magicBox = 0,     -- 计数 0 表示未触发
        magicWell = 0,
        treasureMap = 0,
        magicBoxMcTrigger = false,    -- 是否触发动画用于动画播放控制
        magicWelMcTrigger = false,    -- 
        treasureMapMcTrigger = false, --
    } 

    -- -- 生成小人动画状态机
    self:initStateMachine()
    -- 初始化走格子动画
    local adMcAnimNode = require("game.view.intance.IntanceMcAnimNode")
    local actionMap = {
        "stop1","stop2","stop3",
        "run1k", "run2k", "run3k", 
        "win1", "win2","win3",
        "cry1", "cry2", "cry3",
        "run1", "run2", "run3", 
    }
    self._mcAnimNode = nil
    self._mcAnimNode = adMcAnimNode.new(actionMap, "dafuwengniuzai",
        function(sender) 
            -- mcMgr:release(tab:Hero(60102).heroart)
            -- sender:runStandBy()
            -- 创建完成之后设置一下朝向
            if self._mcAnimNode then
                local curGridId = self._adModel:getCurGridId()
                self:doPlayerEvent("stop",curGridId)
            end
        end,100,100,
        {"stop2"},{{3,10},1})
    -- print(self._adModel:getCurGridId(),"curGrid.....")
    local curGridId = self._adModel:getCurGridId()
    self._tempInGridId = curGridId
    self._mcAnimNode:setAnchorPoint(0.5,0)
    self._mcAnimNode:setPosition(cc.pAdd(gridPoses[curGridId],cc.p(0,30)))
    self._gridLayer:addChild(self._mcAnimNode,99)

    -- 
    self:initGrids()

    self:listenReflash("AdventureModel", self.reflashUI)
    local hadDiceNum = self._adModel:getHadDiceNum()
    self._numLab:setString(hadDiceNum)
    -- self:registerTimer(5,0,1,function( )
    --     self._serverMgr:sendMsg("AdventureServer", "init", {}, true, { }, function(result)
    --         -- if _error then
    --         --     errorCallback()
    --         -- else
    --         --     callback()
    --         -- end
    --         -- dump(result)
    --         dump(result," five clock update.........   五点刷新ing reg...")
    --         self._adModel:resetData()
    --         self:reflashInitRolePos()
    --         self:refreshEventStatusAtMoveEnd()
    --         self:refreshBoxStatus()
    --         self:reflashAllGrids()
    --         self:reflashNaviBarRightNow()
    --     end )
    -- end)

    -- 初始化通用mc
    ScheduleMgr:delayCall(0, self, function( )
        if self._gridLayer and not self._mcEnd then
            local mcEnd = mcMgr:createViewMC("moveend_adventurecangbaotu", false, false, function (_, sender)
                sender:stop()
                sender:setVisible(false)
            end,RGBA8888)
            mcEnd:setPosition(gridPoses[self._tempInGridId].x,gridPoses[self._tempInGridId].y+50)
            self._gridLayer:addChild(mcEnd,1000)
            self._mcEnd = mcEnd 
            self._mcEnd:setVisible(false)
        end
    end)
    ScheduleMgr:delayCall(100, self, function( )
        if self._gridLayer and not self._targetMc then
            local targetMc = mcMgr:createViewMC("mubiaodianjiantou_adventurecangbaotu", true, false, function (_, sender)
            end,RGBA8888)
            self._gridLayer:addChild(targetMc,999)
            self._targetMc = targetMc
            self._targetMc:setVisible(false)
        end
    end)
    -- 倒计时
    local timeLab = self:getUI("bg.numBg.timeLab")
    self._timeLab = timeLab
    self._leftTimeSche = ScheduleMgr:regSchedule(1000, self, function( )
        self:updateTime()
    end)
    self:updateTime()
end

function AdventureView:updateTime( )
    local restTime = self._adModel:getRestTime()
    local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    if restTime then
        local timeLab = self._timeLab
        local leftTime = restTime - nowTime 
        if leftTime > 86400 then -- 天小时
            local day = math.floor(leftTime/86400)
            local hour = math.floor((leftTime%86400)/3600)
            timeLab:setString(string.format("%2d天%2d小时",day,hour))
        elseif leftTime > 3600 then --小时分
            local hour = math.floor(leftTime/3600)
            local min = math.floor((leftTime%3600)/60)
            timeLab:setString(string.format("%2d小时%2d分",hour,min))
        elseif leftTime > 0 then -- 分秒
            local min = math.floor(leftTime/60)
            local sec = math.floor(leftTime%60)
            timeLab:setString(string.format("%2d分%2d秒",min,sec))
        else
            self:close()
            return 
        end
    end
    -- if self._adModel:inResetTime() then end
    -- 五点刷新
    local reflashTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(nowTime,"%Y-%m-%d 05:00:11"))
    if nowTime == reflashTime then
        self._serverMgr:sendMsg("AdventureServer", "init", {}, true, { }, function(result)
            dump(result," five clock update.........   五点刷新ing")
            if not self.reflashInitRolePos then return end
            self:reflashInitRolePos()
            self:refreshEventStatusAtMoveEnd()
            self:refreshBoxStatus()
            self:reflashAllGrids()
            self:reflashNaviBarRightNow()
            if self._inSecondView then -- 在
                self._viewMgr:showTip("小骷髅正在准备开启新的冒险，还请耐心等待一会哦~")
                self._inSecondView = nil
                self._viewMgr:popView()
            end
            if self:hadDialog() then
                self:closeAdventureDialog()
            end
        end )
    end
end

function AdventureView:testEvent(  )
    -- self._viewMgr:showDialog("activity.adventure.AdventureStarView",{exactStars={3,5}})
    -- self._viewMgr:showDialog("activity.adventure.GuessFingerView")
    -- self:magicBoxEvent()
    self:rewardEvent({rwd={{"tool",39985,2}}})
end

-- 初始化小人状态机
function AdventureView:initStateMachine( )
    self._stateMachine = {
        ["stop"] = function( gridId )
            local dir = self:getDir(gridId)
            local curActionIdx = math.abs(dir)
            if dir < 0 then
                self._mcAnimNode:setScaleX(-1)
            else
                self._mcAnimNode:setScaleX(1)
            end
            self._mcAnimNode:changeMotion(curActionIdx)
        end,
        ["runk"] = function( gridId,args )
            local fromPos,toPos,callback = args.fromPos,args.toPos,args.callback
            local dir = self:getDir(gridId)
            local curActionIdx = math.abs(dir)+3
            if dir < 0 then
                self._mcAnimNode:setScaleX(-1)
            else
                self._mcAnimNode:setScaleX(1)
            end
            local toPosDown = cc.pAdd(toPos, cc.p(0,-10))
            local nextGridId = (gridId+1)%AdventureConst.ROUND_GRID_NUM
            if nextGridId == 0 then
                nextGridId = AdventureConst.ROUND_GRID_NUM
            end
            audioMgr:playSound("Treasure_move")
            local gridCell = self._grids[nextGridId].stone
            gridCell:runAction(cc.Sequence:create(
                cc.DelayTime:create(0.40)
                ,cc.MoveTo:create(0.05,toPosDown)
                ,cc.MoveTo:create(0.05,toPos)
            ))
            -- 矫正小人位置
            toPos = cc.pAdd(toPos,cc.p(0,30))
            toPosDown = cc.pAdd(toPos, cc.p(0,-10))
            self._mcAnimNode:changeMotion(curActionIdx)
            self._mcAnimNode:stopAllActions()
            self._mcAnimNode:runAction(cc.Sequence:create(
                cc.DelayTime:create(0.2)
                ,cc.MoveTo:create(0.2,toPos)
                ,cc.Spawn:create(
                    cc.MoveTo:create(0.05,toPosDown)
                    ,cc.CallFunc:create(function (  )
                        if callback then
                            callback()
                        end
                    end)
                )
                ,cc.MoveTo:create(0.05,toPos)
                -- ,cc.DelayTime:create(0.1)
                ,cc.CallFunc:create(function( )
                    self:doPlayerEvent("stop",gridId)
                end)
            ))
        end,
        ["run"] = function( gridId,args )
            local fromPos,toPos,callback = args.fromPos,args.toPos,args.callback
            local dir = self:getDir(gridId)
            local curActionIdx = math.abs(dir)+12
            if dir < 0 then
                self._mcAnimNode:setScaleX(-1)
            else
                self._mcAnimNode:setScaleX(1)
            end
            local toPosDown = cc.pAdd(toPos, cc.p(0,-20))
            local nextGridId = (gridId+1)%AdventureConst.ROUND_GRID_NUM
            if nextGridId == 0 then
                nextGridId = AdventureConst.ROUND_GRID_NUM
            end
            local gridCell = self._grids[nextGridId].stone
            gridCell:runAction(cc.Sequence:create(
                cc.DelayTime:create(0.1)
                ,cc.CallFunc:create(function( )
                    audioMgr:playSound("Treasure_move")
                    -- self:refreshGridWhenMoveEnd(nextGridId)
                end)
                ,cc.DelayTime:create(0.52)
                ,cc.MoveTo:create(0.1,toPosDown)
                ,cc.MoveTo:create(0.2,toPos)
            ))
            -- 矫正小人位置
            toPos = cc.pAdd(toPos,cc.p(0,30))
            toPosDown = cc.pAdd(toPos, cc.p(0,-20))
            self._mcAnimNode:changeMotion(curActionIdx)
            self._mcAnimNode:stopAllActions()
            self._mcAnimNode:runAction(cc.Sequence:create(
                cc.DelayTime:create(0.32)
                ,cc.MoveTo:create(0.3,toPos)
                ,cc.CallFunc:create(function( )
                    if callback then
                        callback()
                    end
                end)
                ,cc.MoveTo:create(0.1,toPosDown)
                ,cc.MoveTo:create(0.2,toPos)
                ,cc.DelayTime:create(0.1)
                ,cc.CallFunc:create(function( )
                    self:doPlayerEvent("stop",gridId)
                end)
            ))
        end,
        ["win"] = function( gridId )
            local dir = self:getDir(gridId)
            local curActionIdx = math.abs(dir)+6
            self._mcAnimNode:changeMotion(curActionIdx)
            self._mcAnimNode:stopAllActions()
            self._mcAnimNode:runAction(cc.Sequence:create(
                cc.DelayTime:create(0.8)
                ,cc.CallFunc:create(function( )
                    self:doPlayerEvent("stop",gridId)
                end)
            ))
        end,
        ["cry"] = function( gridId )
            local dir = self:getDir(gridId)
            local curActionIdx = math.abs(dir)+9
            self._mcAnimNode:changeMotion(curActionIdx)
            self._mcAnimNode:stopAllActions()
            self._mcAnimNode:runAction(cc.Sequence:create(
                cc.DelayTime:create(0.8)
                ,cc.CallFunc:create(function( )
                    self:doPlayerEvent("stop",gridId)
                end)
            ))
        end,
    }
end

-- 小人事件
function AdventureView:doPlayerEvent( eventName,grid,args )
    self._stateMachine[eventName](grid,args)
end

-- 接收自定义消息
function AdventureView:reflashUI(data)
    local hadDiceNum = self._adModel:getHadDiceNum()
    self._numLab:setString(hadDiceNum)
    -- self:reflashNaviBarRightNow()
    -- self:enableStarBtn(hadDiceNum ~= 0 and not next(self._path))
end

-- 刷新开始按钮状态
function AdventureView:enableStarBtn( enable )
    UIUtils:setGray(self._startBtn,not enable)
    self._startBtn:setEnabled(enable)
end

-- 刷新eventStatus
function AdventureView:refreshEventStatus( )
    self._eventStatus.treasureMap = self._adModel:getData().tmo or 0
    self._eventStatus.magicBox = self._adModel:getData().po or 0
    self._eventStatus.magicWell = self._adModel:getData().mw or 0
end

-------- 界面刷新处理
-- 色子动画
function AdventureView:diceAnim( dicePoint,callback )
    local gridLyW,gridLyH = self._gridLayer:getContentSize().width,self._gridLayer:getContentSize().height
    
    if not self._mcDice then
        local mcDice = mcMgr:createViewMC("toushaizi_adventuretoushaizi", false, false, function (_, sender)
        end,RGBA8888)

        mcDice:setPosition(gridLyW/2+450,gridLyH/2-80)
        self._gridLayer:addChild(mcDice,999)
        self._mcDice = mcDice 
    end
    self:updateDiceMc(self._mcDice,dicePoint,callback)

    -- self._diceLab:setString(dicePoint)
end

-- 更新掷骰子动画
function AdventureView:updateDiceMc( diceMc,dicePoint,callback )
    if not diceMc then return end
    diceMc:setVisible(true)
    diceMc:gotoAndPlay(0)
    local mcCallback1
    mcCallback1 = diceMc:addCallbackAtFrame(20,function( )
        local beginFrame = (dicePoint+2)*10
        local endFrame = math.min((dicePoint+2)*10+9,76)
        if dicePoint == 6 then
            beginFrame = 20
            endFrame = 29
        end
        diceMc:removeCallback(mcCallback1)
        diceMc:gotoAndPlay(beginFrame)
        local mcCallback2
        mcCallback2 = diceMc:addCallbackAtFrame(endFrame,function( )
            diceMc:stop()
            diceMc:removeCallback(mcCallback2)
            diceMc:runAction(cc.Sequence:create(
                cc.DelayTime:create(0.5),
                cc.CallFunc:create(function( )
                    diceMc:setVisible(false)
                    if callback then
                        callback()
                    end
                end)
            ))
        end)
    end)
end

-- 目标点动画
function AdventureView:showTargetGridMc( gridId )
    local grid = self._grids[gridId]
    if not self._targetMc then
        local targetMc = mcMgr:createViewMC("mubiaodianjiantou_adventurecangbaotu", true, false, function (_, sender)
        end,RGBA8888)

        self._gridLayer:addChild(targetMc,999)
        self._targetMc = targetMc
    end
    self._targetMc:setPosition(gridPoses[gridId].x,gridPoses[gridId].y+35)
    self._targetMc:gotoAndPlay(0)
    self._targetMc:setVisible(true)
end

-- 隐藏目标箭头动画
function AdventureView:hideTargetGridMc( )
    if self._targetMc then
        self._targetMc:setVisible(false)
    end
end
-- 添加箱子动画
function AdventureView:addBoxAnim( box, boxId)
    box:setOpacity(0)
    local boxLight = box:getChildByName("box_light")
    if boxLight == nil then 
        boxLight = mcMgr:createViewMC("baoxiang".. math.floor((boxId+1)/2) .."_baoxiang", true)
        boxLight:setPosition(box:getContentSize().width/2, box:getContentSize().height/2)
        boxLight:setName("box_light")
        box:addChild(boxLight,10)
        boxLight:setCascadeOpacityEnabled(true, true)
        
        local boxMc = mcMgr:createViewMC("baoxiangguang".. math.floor((boxId+1)/2) .."_baoxiang", true)
        boxMc:setPosition(0,0)
        boxMc:setName("box_light")
        boxLight:addChild(boxMc,10)
        boxMc:setCascadeOpacityEnabled(true, true)

        -- boxLight:setOpacity(rewardBtn:getOpacity())
    else
        return 
    end
    boxLight:setVisible(true)
    -- local boxOrignScale = box:getScale()  
    -- -- box:setOpacity(0)  
    -- local action1 = cc.ScaleTo:create(0.1, 1*boxOrignScale, 1.1*boxOrignScale)
    -- local action2 = cc.ScaleTo:create(0.07, 1*boxOrignScale, 0.9*boxOrignScale)
    -- local action3 = cc.Spawn:create(cc.ScaleTo:create(0.2, 1*boxOrignScale, 1.1*boxOrignScale), cc.MoveBy:create(0.2, cc.p(0, 3)))
    -- local action4 = cc.Spawn:create(cc.ScaleTo:create(0.2, 1*boxOrignScale, 1.0*boxOrignScale), cc.MoveBy:create(0.2, cc.p(0, -3)))
    -- box:runAction(cc.RepeatForever:create(cc.Sequence:create(action1, action2, action3, action4)))
end

-- 移除箱子动画
function AdventureView:removeBoxAnim( box )
    local boxLight = box:getChildByName("box_light")
    if boxLight then 
        boxLight:removeFromParent()
    end
    box:setOpacity(255)
    box:stopAllActions()
end

-- 不可领取
function AdventureView:setBoxNotGet( box,boxId )
    box:loadTexture("box_".. math.floor((boxId+1)/2) .."_n.png",1)
    self:removeBoxAnim(box)
end

-- 可领取状态
function AdventureView:setBoxToBeGet( box,boxId )
    self:addBoxAnim(box,boxId)
end

-- 已领取状态
function AdventureView:setBoxGeted( box,boxId )
    self:removeBoxAnim(box)
    box:loadTexture("box_".. math.floor((boxId+1)/2) .."_p.png",1)
end

local boxStatusFunc = {[0] = "setBoxNotGet",[1] = "setBoxToBeGet",[2] = "setBoxGeted"}
local boxProBarSizeWs = {[0]=0,60,160,250,350,430,530}
-- 更新奖励箱子状态
function AdventureView:refreshBoxStatus( )
    local roundNum = self._adModel:getData().rn or 0
    -- dump(roundNum)
    local boxCanGetId = 0
    for i,box in ipairs(self._boxes) do
        local status = self._adModel:hadBoxGeted(i)
        if status ~= 0 then
            boxCanGetId = i
        end
        self[boxStatusFunc[status]](self,box,i)
    end
    print("boxCanGetId",boxCanGetId,boxProBarSizeWs[boxCanGetId])
    self._proBar:setVisible(boxProBarSizeWs[boxCanGetId]~=0)
    self._proBar:setCapInsets(cc.rect(5,9,1,1))
    self._proBar:setContentSize(cc.size(boxProBarSizeWs[boxCanGetId],19))
end

-------- 按钮事件
-- 查看规则说明
function AdventureView:showRule( )
    self._viewMgr:showDialog("activity.adventure.AdventureRuleView")
end

-- 查看已获得奖励
function AdventureView:showGetedAward( )
    self._serverMgr:sendMsg("AdventureServer", "getRewardList", {}, true, { }, function(result)
        -- dump(result,"show award.....")
        if not self._viewMgr then return end
        self._viewMgr:showDialog("activity.adventure.AdventureAwardView",{awards=result.rwd})
    end)
end

-- 开始冒险 掷骰子
function AdventureView:throwDiceFunc( dicePoint )
    local hadDiceNum = self._adModel:getHadDiceNum()
    if hadDiceNum == 0 then
        -- self._viewMgr:showTip("次数不足")
        -- DialogUtils.showShowSelect({desc = "骰子不足，是否前往任务界面获得骰子？",callback1=function( )
        --     self._viewMgr:showView("task.TaskView", {viewType = 2,superiorType = 3})
        -- end})
        DialogUtils.showBuyRes({goalType = "dice"})
        return 
    end
    local serverFuncName = "throwDice" 
    if dicePoint then
        -- dicePoint = GRandom(1,6)
        serverFuncName = "throwDiceTest" 
    end
    if OS_IS_WINDOWS then
        -- widowns 下防测试连点
        if not self._startBtn:isEnabled() then
            return 
        end
    end
    if self._adModel:inResetTime() then
        self._viewMgr:showTip("小骷髅正在准备开启新的冒险，还请耐心等待一会哦~")
        return 
    end
    self:enableStarBtn(false)
    local curGrid = self._adModel:getCurGridId()
    if dicePoint then curGrid = nil end
    self._serverMgr:sendMsg("AdventureServer", serverFuncName, {dp = dicePoint,grid = curGrid}, true, { }, function(result)
        dump(result)
        if not result or not self._adModel then return end
        local showDiceNum = result.dn
        local preDiceNum = self._adModel:getHadDiceNum() -- 之前的骰子数目
        if preDiceNum == showDiceNum then
            showDiceNum = showDiceNum-1
        end
        self._adModel:updateAdventure({dn=showDiceNum,pgids=result.pgids})
        self:reflashNaviDiceOnly(showDiceNum,result.dn)
        local fromId = self._adModel:getCurGridId()
        self._startId = fromId
        local toId = result.gid
        if result.type == 7 then -- 传送门
            toId = WARP_GATE_FROMID
        end
        ScheduleMgr:delayCall(500, self, function( )
            if self.showTargetGridMc then
                self:showTargetGridMc(toId)
            end
        end)
        audioMgr:playSound("Treasure_throw")
        self:diceAnim(result.dp,function( )
            local reward = result.rwd
            local resultD = result
            self:enableStarBtn(false)
            self:moveToGrid(fromId,toId,function( )
                self:hideTargetGridMc(toId)
                self:doGridEvent(toId,resultD,function( )
                    self:enableStarBtn(true)
                    self:reflashNaviBarRightNow()
                end)
            end)
        end)
        
    end)
end

-------- 界面通知

-------- 格子状态控制
-- 初始化格子
function AdventureView:initGrids( )
    local gridConfig = tab:Activity907(1).param
    local gridGift = tab.activity907gift
    -- local gridPosesStr = "{\n"
    for i=1,AdventureConst.ROUND_GRID_NUM do
        local grid = {}
        grid.gridId = i
        grid.pos = gridPoses[i]
        grid.gridType = gridConfig[i]
        if grid.gridType == 7 then
            WARP_GATE_FROMID = i
        elseif grid.gridType == 8 then
            WARP_GATE_TOID = i
        elseif grid.gridType == AdventureConst.GRID_TYPE.TREASURE_MAP then
            TREASUREMAP_ID = i
        elseif grid.gridType == AdventureConst.GRID_TYPE.NULL then
            if not self._nullGrids then
                self._nullGrids = {}
            end
            self._nullGrids[i] = true
        end
        grid.reward = gridGift[grid.gridType+1].reward 
        grid.stone = self:getUI("bg.gridLayer.stone_" .. (i-1))
        self._grids[i] = grid
        self:reflashGridStatus(i)
        -- 点击出tip
        self:addTouchTip(grid)
        -- gridPosesStr = gridPosesStr .. "[" .. i .. "]=cc.p(" .. grid.stone:getPositionX() .. "," .. grid.stone:getPositionY() .."),\n"
    end
    -- gridPosesStr = gridPosesStr .. "\n}"
    -- local file = io.open("adventureposes.lua","w")
    -- file:write(gridPosesStr)
    -- file:close()
end

-- 格子上加点击事件
function AdventureView:addTouchTip( grid )
    self:registerClickEvent(grid.stone,function() 
        local gridType = self:changeGridType(grid.gridId) 
        local gridPos = gridPoses[grid.gridId]
        local stableTouchTip = self._gridEvents[gridType].touchTip 
        local touchTip
        if type(stableTouchTip) == "table" then
            touchTip = ""
            local magicBoxOpen = self._adModel:getMagicBoxStatus()
            if gridType == GRID_TYPE.MAGIC_BOX then
                if magicBoxOpen then
                    touchTip = stableTouchTip[2]
                else
                    touchTip = stableTouchTip[1]
                end
            elseif gridType == GRID_TYPE.BATTLE then
                if magicBoxOpen then
                    touchTip = stableTouchTip[2]
                else
                    touchTip = stableTouchTip[1]
                end
            elseif gridType == GRID_TYPE.MAGIC_WELL then
                local wellStatus = self._adModel:getMagicWellStatus()
                touchTip = stableTouchTip[math.floor(wellStatus/2)+1]
            end
        else
            touchTip = self._gridEvents[gridType].touchTip 
        end 
        if touchTip and (not self._adModel:isGridPassed(grid.gridId) or AdventureConst.TREASUREMAP_EXCEPTS[gridType]) then
            self:showGridTouchTip(touchTip,gridPos,grid.gridId == 8)
        end
    end)
end

-- 格子tip
function AdventureView:showGridTouchTip( tipDes,pos,isArrowRight )
    self._touchTipTxt:setString(tipDes or "")
    local txtLabW = self._touchTipTxt:getContentSize().width+30
    self._touchTip:setContentSize(cc.size(txtLabW,52))
    local offsetX,offsetY = -40,70
    if isArrowRight then
        self._touchTip:setCapInsets(cc.rect(10,0,1,1))
        offsetX = 40-txtLabW
    else
        self._touchTip:setCapInsets(cc.rect(70,0,1,1))
    end
    self._touchTipTxt:setPosition(txtLabW/2,33)
    self._touchTip:setVisible(true)
    self._touchTip:setPosition(pos.x+offsetX,pos.y+offsetY)
    self._touchTip:stopAllActions()
    self._touchTip:runAction(cc.Sequence:create(
        cc.DelayTime:create(2),
        cc.CallFunc:create(function( )
            self._touchTip:setVisible(false)
        end)
    ))
end

-- 更新格子状态,包括上边的物品...
function AdventureView:reflashGridStatus( grid,forceShow )
    local gridNum = grid
    if type(grid) == "number" then
        grid = self._grids[grid]
    else 
        gridNum = grid.gridId
    end
    local gridType,changeType = self:changeGridType(gridNum) 
    local orignGridType = grid.gridType
    -- 存储转换过的格子，用于重置
    if gridType ~= orignGridType then
        if not self._changedGridIds then
            self._changedGridIds = {}
        end
        self._changedGridIds[gridNum] = true
    end
    local icon = self._gridEvents[gridType].icon
    if not icon or icon == "null" then
        local gridAwardImg = grid.stone:getChildByName("gridAwardImg")
        local shadow = grid.stone:getChildByName("gridShadow")
        if gridType == GRID_TYPE.NULL then
            if gridAwardImg then
                gridAwardImg:removeFromParent()
            end
            if shadow then
                shadow:removeFromParent()
            end
        end 
        return 
    end
    local awardImageName =  "icon_" .. icon .. "_adventure.png"
    local gridAwardImg = grid.stone:getChildByName("gridAwardImg")
    local shadow = grid.stone:getChildByName("gridShadow")
    local awardPosX,awardPosY = grid.stone:getContentSize().width/2,grid.stone:getContentSize().height/2
    local offsetY = 50
    if not gridAwardImg then
        local upY = offsetY+5
        gridAwardImg = ccui.ImageView:create()
        -- 特做小恶魔
        if gridType == GRID_TYPE.BATTLE then 
            awardImageName = "asset/uiother/steam/" .. tab.team[501].art .. ".png"
            print("ddsafaga")
            gridAwardImg:loadTexture(awardImageName,1)
        else 
            gridAwardImg:loadTexture(awardImageName,1)
        end
        gridAwardImg:setName("gridAwardImg")
        gridAwardImg:setPosition(awardPosX,awardPosY+offsetY)
        grid.stone:addChild(gridAwardImg,10)
        shadow = ccui.ImageView:create()
        shadow:loadTexture("shadow_adventure.png",1)
        shadow:setName("gridShadow")
        shadow:setPosition(awardPosX,awardPosY+offsetY/2)
        shadow:setScale(0.8)
        
        grid.stone:addChild(shadow,8)
        grid.awardImg = gridAwardImg

        -- if not AdventureConst.TREASUREMAP_EXCEPTS[gridType] then
        --     gridAwardImg:runAction(cc.RepeatForever:create(
        --         cc.Sequence:create(
        --             cc.MoveTo:create(1,cc.p(awardPosX,awardPosY+offsetY)),
        --             cc.MoveTo:create(1,cc.p(awardPosX,awardPosY+upY))
        --         )
        --     ))
        --     -- shadow:setPosition(gridAwardImg:getContentSize().width/2,-5)
        --     shadow:runAction(cc.RepeatForever:create(
        --         cc.Sequence:create(
        --             cc.ScaleTo:create(1,0.9),
        --             cc.ScaleTo:create(1,0.8)
        --         )
        --     ))
        -- end
        -- 这里生成的是更icon的静态特效 特效和icon 同生同灭
        if gridType == GRID_TYPE.TREASURE_MAP then
            local clipNode = cc.ClippingNode:create()
            clipNode:setPosition(35,27)
            clipNode:setContentSize(cc.size(109, 114))
            local mask = cc.Sprite:createWithSpriteFrameName("icon_treasureMap_adventure.png")
            mask:setAnchorPoint(0.5,0.5)
            mask:setScale(0.95)
            clipNode:setStencil(mask)
            clipNode:setAlphaThreshold(0.05)
            -- clipNode:setInverted(true)
            clipNode:setCascadeOpacityEnabled(true)

            local mcCangbaotu = mcMgr:createViewMC("cangbaotu_adventurechufa", true,false)
            mcCangbaotu:setPosition(mcx or 0,mcy or 0)
            clipNode:addChild(mcCangbaotu)
            mcCangbaotu:setCascadeOpacityEnabled(true)

            -- local mcWarpGate = mcMgr:createViewMC("cangbaotu_adventurechufa", true, false)
            -- mcWarpGate:setPosition(25,35)
            -- mcWarpGate:setScale(0.8)
            gridAwardImg:addChild(clipNode,999)
        end
        if orignGridType == GRID_TYPE.NULL and gridType == GRID_TYPE.AWARD_BIGGEM then
            local mcChange = grid.stone:getChildByName("mcChange")
            if self._eventStatus.treasureMapMcTrigger then
                gridAwardImg:setVisible(false)
                if not mcChange then
                    local mcChange 
                    mcChange = mcMgr:createViewMC("shuaxinzuanshi1_adventurecangbaotu", true, false, function (_, sender)
                    end,RGBA8888)
                    
                    mcChange:setPosition(awardPosX,awardPosY+30)
                    mcChange:setName("mcChange")
                    grid.stone:addChild(mcChange,9)
                end
            else
                -- 特做小恶魔
                if gridType == GRID_TYPE.BATTLE then 
                    awardImageName = "asset/uiother/steam/" .. tab.team[501].art .. ".png"
                    print("ddsafaga")
                    gridAwardImg:loadTexture(awardImageName)
                else 
                    gridAwardImg:loadTexture(awardImageName,1)
                end
            end
        end
        -- 调整位置 怪物木乃伊位置需要上调一点
        if (gridType == GRID_TYPE.BATTLE 
            and ( not self._adModel:isTreasureMapOpen() or gridNum < 8)) then
            gridAwardImg:setPosition(awardPosX+5,awardPosY+offsetY+10)
        else
            gridAwardImg:setPosition(awardPosX,awardPosY+offsetY)
        end
    else
        if changeType and changeType == 1 then
            local mcChange = grid.stone:getChildByName("mcChange")
            if self._eventStatus.treasureMapMcTrigger then
                if not mcChange then
                    local mcChange 
                    mcChange = mcMgr:createViewMC("shuaxinzuanshi1_adventurecangbaotu", true, false, function (_, sender)
                    end,RGBA8888)
                    
                    mcChange:setPosition(awardPosX,awardPosY+30)
                    mcChange:setName("mcChange")
                    grid.stone:addChild(mcChange,9)
                else
                    ScheduleMgr:delayCall(100*gridNum, self, function( )
                        if not tolua.isnull(mcChange) then
                            local mcFloor = mcMgr:createViewMC("shuaxinzuanshi2_adventurecangbaotu", false, true, function (_, sender)
                            end,RGBA8888)
                            mcChange:removeFromParent()
                            mcFloor:setPosition(awardPosX,awardPosY+30)
                            grid.stone:addChild(mcFloor,999)
                            if orignGridType == GRID_TYPE.NULL and gridType == GRID_TYPE.AWARD_BIGGEM then
                                mcFloor:addCallbackAtFrame(5,function( )
                                    if self.showGridAward then
                                        local isPassed = self._adModel:isGridPassed(gridNum)
                                        self:showGridAward(gridNum, not isPassed)
                                    end
                                end)
                            end
                            -- 特做小恶魔
                            if gridType == GRID_TYPE.BATTLE then 
                                awardImageName = "asset/uiother/steam/" .. tab.team[501].art .. ".png"
                                print("ddsafaga")
                                gridAwardImg:loadTexture(awardImageName)
                            else 
                                gridAwardImg:loadTexture(awardImageName,1)
                            end
                            if gridNum == 22 then
                                local mcCangbaotu = self._gridLayer:getChildByName("mcCangbaotu")
                                if mcCangbaotu then
                                    mcCangbaotu:removeFromParent()
                                end
                            end
                        end
                        if not tolua.isnull(gridAwardImg) then
                            local contentSizeW = gridAwardImg:getContentSize().width
                            if contentSizeW > 100 then
                                gridAwardImg:setScale(0.5)
                            else
                                gridAwardImg:setScale(1)
                            end
                            -- 调整位置 怪物木乃伊位置需要上调一点
                            if (gridType == GRID_TYPE.BATTLE 
                                and ( not self._adModel:isTreasureMapOpen() or gridNum < 8)) then
                                gridAwardImg:setPosition(awardPosX+5,awardPosY+offsetY+10)
                            else
                                gridAwardImg:setPosition(awardPosX,awardPosY+offsetY)
                            end
                        end
                    end)
                    
                end
            else
                -- 特做小恶魔
                if gridType == GRID_TYPE.BATTLE then 
                    awardImageName = "asset/uiother/steam/" .. tab.team[501].art .. ".png"
                    print("ddsafaga")
                    gridAwardImg:loadTexture(awardImageName)
                else 
                    gridAwardImg:loadTexture(awardImageName,1)
                end
            end
        else
            -- 特做小恶魔
                if gridType == GRID_TYPE.BATTLE then 
                    awardImageName = "asset/uiother/steam/" .. tab.team[501].art .. ".png"
                    print("ddsafaga")
                    gridAwardImg:loadTexture(awardImageName)
                else 
                    gridAwardImg:loadTexture(awardImageName,1)
                end
        end
        if gridType == GRID_TYPE.NULL then
            gridAwardImg:removeFromParent()
            if shadow then
                shadow:removeFromParent()
            end
        end
    end

    -- 这里生成的是更icon的动态特效 特效变化 icon不跟着变
    if gridType == GRID_TYPE.BATTLE then
        local mcBoxBattle = gridAwardImg:getChildByName("mcBoxBattle")
        local mcTarget = gridAwardImg:getChildByName("mcTarget")
        if self._adModel:getMagicBoxStatus() then
            if not mcBoxBattle then
                mcTarget = mcMgr:createViewMC("mubiaotongji_adventurecangbaotu", true, false,function( _,sender )
                    -- mcShowCount = mcShowCount+1
                    -- if mcShowCount == 100 then
                    --     sender:removeFromParent()
                    -- end 
                end)
                mcTarget:setPosition(38+90,20+30)
                mcTarget:setScale(2.2)
                mcTarget:setName("mcTarget")
                gridAwardImg:addChild(mcTarget,-1)

                mcBoxBattle = mcMgr:createViewMC("mohetongji_adventurecangbaotu", true, false,function( _,sender )
                    sender:gotoAndPlay(21)
                end)
                mcBoxBattle:setPosition(40+90,15+30)
                mcBoxBattle:setScale(2.2)
                mcBoxBattle:setName("mcBoxBattle")
                if not self._adModel:isMagicBoxOpening() then
                    mcBoxBattle:gotoAndPlay(21)
                end
                gridAwardImg:addChild(mcBoxBattle,999)
            else
                if not self._adModel:isMagicBoxOpening() then
                    mcBoxBattle:gotoAndPlay(21)
                else
                    mcBoxBattle:gotoAndPlay(0)
                end
                mcBoxBattle:setVisible(true)
                mcTarget:setVisible(true)
            end
        else
            if mcBoxBattle then
                mcBoxBattle:setVisible(false)
            end
            if mcTarget then
                mcTarget:setVisible(false)
            end
        end
    elseif gridType == GRID_TYPE.MAGIC_BOX then
        local mcBoxEff = gridAwardImg:getChildByName("mcBoxEff")
        if not self._adModel:getMagicBoxStatus() then
            if not mcBoxEff then
                mcBoxEff = mcMgr:createViewMC("mohe_adventurechufa", true, false)
                mcBoxEff:setPosition(30,30)
                -- mcWarpGate:setScale(0.8)
                mcBoxEff:setName("mcBoxEff")
                gridAwardImg:addChild(mcBoxEff,999)
            else
                mcBoxEff:setVisible(true)
            end
        else
            if mcBoxEff then
                mcBoxEff:setVisible(false)
            end
        end
    elseif gridType == GRID_TYPE.WARPGATE_ENTER then
        local mcWarpGate = gridAwardImg:getChildByName("mcWarpGate")
        if not self._adModel:isGridPassed(WARP_GATE_FROMID) then
            if not mcWarpGate then
                mcWarpGate = mcMgr:createViewMC("chuansongmen_adventurecangbaotu", true, false)
                mcWarpGate:setPosition(35,35)
                mcWarpGate:setScale(0.67)
                mcWarpGate:setName("mcWarpGate")
                gridAwardImg:addChild(mcWarpGate,999)
            else
                mcWarpGate:setVisible(true)
            end
        else
            if mcWarpGate then
                mcWarpGate:setVisible(false)
            end
        end
    elseif gridType == GRID_TYPE.MAGIC_WELL then
        local mcMagicWell = gridAwardImg:getChildByName("mcMagicWell")
        local status = self._adModel:getMagicWellStatus()
        local changed = self._adModel:isMagicWellStatusChanged()
        if mcMagicWell then
            mcMagicWell:removeFromParent()
        end
        print(status,"magicwell status...")
        if status ~= 1 then -- 一倍不显示状态
            if tolua.isnull(mcMagicWell) then
                local mcName = "mofaquan"
                if status == 2 then
                    mcName = "mofaquan1"
                end
                mcMagicWell = mcMgr:createViewMC(mcName .. "_adventurechufa", true, false)
                mcMagicWell:setPosition(40,40)
                -- mcWarpGate:setScale(0.8)
                mcMagicWell:setName("mcMagicWell")
                gridAwardImg:addChild(mcMagicWell,999)
            else
                if not tolua.isnull(mcMagicWell) then
                    mcMagicWell:setVisible(true)
                end
            end
        else
            if  not tolua.isnull(mcMagicWell) then
                mcMagicWell:setVisible(false)
            end
        end
    elseif gridType == GRID_TYPE.STAR then
        local mcStar = gridAwardImg:getChildByName("mcStar")
        if not self._adModel:isGridPassed(gridNum) then
            if not mcStar then
                mcStar = mcMgr:createViewMC("zhanxingshi_adventurechufa", true, false)
                mcStar:setPosition(25,35)
                -- mcStar:setScale(0.8)
                mcStar:setName("mcStar")
                gridAwardImg:addChild(mcStar,999)
            else
                mcStar:setVisible(true)
            end
        else
            if mcStar then
                mcStar:setVisible(false)
            end
        end
    end
    if orignGridType ==  GRID_TYPE.BATTLE and gridType ~= GRID_TYPE.BATTLE then
        local mcBoxBattle = gridAwardImg:getChildByName("mcBoxBattle")
        local mcTarget = gridAwardImg:getChildByName("mcTarget")
        if mcBoxBattle then
            mcBoxBattle:setVisible(false)
        end
        if mcTarget then
            mcTarget:setVisible(false)
        end
    end
    -- 判断走过的格子
    local isPassed = self._adModel:isGridPassed(gridNum)
    if not AdventureConst.TREASUREMAP_EXCEPTS[gridType] then
        if orignGridType == GRID_TYPE.NULL and gridType == GRID_TYPE.AWARD_BIGGEM
           and not tolua.isnull(gridAwardImg) and not gridAwardImg:isVisible() then
           self:showGridAward(gridNum, false)
        else
            self:showGridAward(gridNum, not isPassed,forceShow)
        end
    else
    end
    if not tolua.isnull(gridAwardImg) then
        -- 调整缩放 复用的骰子图片需要缩放
        local contentSizeW = gridAwardImg:getContentSize().width
        if contentSizeW > 110 then
            gridAwardImg:setScale(0.5)
        else
            gridAwardImg:setScale(1)
        end
    end
end

function AdventureView:reflashAllGrids( )
    for i=1,22 do
        self:reflashGridStatus(i)
    end
end

-- 控制单个格子奖励展示
function AdventureView:showGridAward( gridId,isShow ,forceShow)
    if not gridId then 
        return 
    end
    local grid = self._grids[gridId]
    if AdventureConst.TREASUREMAP_EXCEPTS[grid.gridType] then 
        return 
    end
    if self._adModel:isGridPassed(gridId) then
        isShow = false
    end
    if forceShow then
        isShow = true
    end
    local gridAwardImg = grid.stone:getChildByName("gridAwardImg")
    local shadow = grid.stone:getChildByName("gridShadow")
    if gridAwardImg then
        gridAwardImg:setVisible(isShow)
    end
    if shadow then
        shadow:setVisible(isShow)
    end
end

-------- 人物控制
-- 初始化后刷新人物位置
function AdventureView:reflashInitRolePos( )
    local curGridId = self._adModel:getCurGridId()
    self._mcAnimNode:setPosition(gridPoses[curGridId].x,gridPoses[curGridId].y+30)
    self._tempInGridId = curGridId
    self:doPlayerEvent("stop",curGridId)
end

-- 移动控制 按格子逐步移动
function AdventureView:moveToGrid( fromGrid,toGrid,callback )
    if next(self._path) then
        self:generatePath(fromGrid,toGrid)
    else
        self:generatePath(fromGrid,toGrid)
        self:moveToNextGrid(callback)
    end
end

-- 形成路径数组
function AdventureView:generatePath( fromId,toId )
    local addRound = fromId > toId
    local stepFrom,stepTo = self:getStep(fromId),self:getStep(toId,addRound)
    for grid=stepFrom,stepTo do
        self:addGridToPath(grid)
    end
    if #self._path > 2 then
        self._runSpeed = "k"
    else
        self._runSpeed = ""
    end
    -- dump(self._path,"path...=======================================")
end

-- 路径增长
function AdventureView:addGridToPath( grid )
    table.insert(self._path,1,grid)
end

-- 走到下一格 队列存储
function AdventureView:moveToNextGrid( callback )
    -- dump(self._path,"path======")
    if not self:isMoveEnd() then
        local curGrid = self:convertStepToGrid(self._path[#self._path])
        local nextGrid = self:convertStepToGrid(self._path[#self._path-1])
        local curPos = gridPoses[curGrid]
        local nextPos = gridPoses[nextGrid]
        if curGrid ~= self._startId then
            self:showGridAward(curGrid,true)
        end
        self:moveTo(curGrid,curPos,nextPos,function( )
            -- print("nextGrid,curGrid--------------",nextGrid,curGrid)
            if nextGrid == 1 and #self._path > 2 then -- 原点取消藏宝图效果
                -- self._adModel:getData().tmo = 0
                -- self._eventStatus.treasureMap = 0
                self:startGridEvent({},function( )
                    self:showGridAward(nextGrid,false)
                    self._tempInGridId = nextGrid
                    self:refreshEventStatusOnMove()
                    self._path[#self._path] = nil
                    self:moveToNextGrid(callback)
                end)
            else
                self:showGridAward(nextGrid,false)
                self._tempInGridId = nextGrid
                self:refreshEventStatusOnMove()
                self._path[#self._path] = nil
                self:moveToNextGrid(callback)
            end
        end)
    else
        self._path = {}
        self._tempInGridId = self._adModel:getCurGridId()
        self:refreshEventStatusOnMove()
        -- self:refreshEventStatusAtMoveEnd()

        if callback then
            callback()
        end
    end
end

function AdventureView:isMoveEnd( )
    return #self._path < 2
end

-- 移动
function AdventureView:moveTo( curGrid,fromPos,toPos,callback )
    local dir = self:getDir(curGrid)
    self:doPlayerEvent("run" .. self._runSpeed,curGrid,{fromPos=fromPos,toPos=toPos,callback=callback})
end

-- 取得方向
function AdventureView:getDir( curId )
    if curId < AdventureConst.CORNER_1 then
        return AdventureConst.ROLE_DIR_RIGHT
    elseif curId < AdventureConst.CORNER_2 then
        return AdventureConst.ROLE_DIR_DOWN
    elseif curId < AdventureConst.CORNER_3 then
        return AdventureConst.ROLE_DIR_LEFT
    elseif curId < AdventureConst.CORNER_4 then
        return AdventureConst.ROLE_DIR_UP
    end
end

-- 改变方向
function AdventureView:changeDir( dir )
    if dir and (dir == AdventureConst.ROLE_DIR_LEFT or dir == AdventureConst.ROLE_DIR_RIGHT or dir == AdventureConst.ROLE_DIR_UP or dir == AdventureConst.ROLE_DIR_DOWN) then
        self._mcAnimNode:setScaleX(dir)
        return 
    end

    local dir = self._mcAnimNode:getScaleX()
    local newDir = -dir 
    self._mcAnimNode:setScaleX(newDir)
    return newDir
end

-- 获得当前步数 = 圈数*22 + 当前格子
function AdventureView:getStep( grid,addRound,round )
    grid = grid or self._adModel:getCurGridId()
    round = round or self._adModel:getRoundNum()
    if addRound then
        round = round+1
    end
    local step = round*AdventureConst.ROUND_GRID_NUM+grid
    return step
end

-- 步数格子转换
function AdventureView:convertStepToGrid( step )
    local grid = step%AdventureConst.ROUND_GRID_NUM
    if grid == 0 then
        grid = AdventureConst.ROUND_GRID_NUM
    end
    return grid
end

------------ 格子事件
-- 格子事件 根据格子类型选择触发
function AdventureView:doGridEvent( gridId,args,callback )
    local grid = self._grids[gridId]
    if not grid then
        if callback then
            callback()
        end
        return
    end
    local gridType = self:changeGridType(gridId)
    print("gridType=========",gridType)
    local event = self._gridEvents[gridType]
    -- self:showPrompt(gridType,1,function( )
        if event and event.funcName and self[event.funcName .. "Event"] then
            self[event.funcName .. "Event"](self,args,callback)
        else
            if callback then
                callback()
            end
        end
        
    -- end)
end

-- 根据 加成 改变 gridType
function AdventureView:changeGridType( gridId )
    local gridType = self._grids[gridId].gridType
    -- print("gridType..........",gridType,self._eventStatus.treasureMap ~= 0)
    local changeType -- 转换类型
    if self._eventStatus.treasureMap ~= 0 and 
        not AdventureConst.TREASUREMAP_EXCEPTS[gridType] and
        gridId > TREASUREMAP_ID then
        gridType = GRID_TYPE.AWARD_BIGGEM
        changeType = 1
    end
    return gridType,changeType
end

-- 移动结束格子更新已触发事件状态
function AdventureView:refreshEventStatusAtMoveEnd( )
    print("refresh每格子更新已触发事件状态")
    -- if true then return end
    
    -- if isRefreshStatus then
    -- end
    self._eventStatus.treasureMap = self._adModel:getData().tmo or 0
    self._eventStatus.magicBox = self._adModel:getData().po or 0
    self._eventStatus.magicWell = self._adModel:getData().mw or 0
    self:reflashAllGrids()
    self:refreshBoxStatus()
end

-- 每格事件
function AdventureView:refreshEventStatusOnMove( )
    if self:isMoveEnd() then
        self:refreshGridWhenMoveEnd()
    end
    if self._tempInGridId == 1 then
        self:refreshBoxStatus()
        -- self:refreshEventStatusAtMoveEnd()
    end
end

-- 移动结束刷新 格子状态
function AdventureView:refreshGridWhenMoveEnd( gridId )
    gridId = gridId or self._tempInGridId
    local grid = self._grids[gridId]
    if not grid then return end
    local gridType = grid.gridType
    local gridAwardImg = grid.stone:getChildByName("gridAwardImg")
    if gridAwardImg and self._tempInGridId ~= WARP_GATE_TOID then
        if not self._mcEnd then
            local mcEnd = mcMgr:createViewMC("moveend_adventurecangbaotu", false, false, function (_, sender)
                sender:stop()
                sender:setVisible(false)
            end,RGBA8888)
            mcEnd:setPosition(gridPoses[self._tempInGridId].x,gridPoses[self._tempInGridId].y+50)
            self._gridLayer:addChild(mcEnd,1000)
            self._mcEnd = mcEnd 
        end
        self._mcEnd:setPosition(gridPoses[self._tempInGridId].x,gridPoses[self._tempInGridId].y+50)
        self._mcEnd:setVisible(true)
        self._mcEnd:gotoAndPlay(0)
        self._mcEnd:addCallbackAtFrame(20,function( )
            self._mcEnd:stop()
            self._mcEnd:setVisible(false)
        end)
    end
end

-- 藏宝图
function AdventureView:treasureMapEvent( args,callback )
    audioMgr:playSound("Treasure_cangbaotu")
    local gridLyW,gridLyH = self._gridLayer:getContentSize().width,self._gridLayer:getContentSize().height
    local mcCangbaotu
    mcCangbaotu = mcMgr:createViewMC("cangbaotu_adventurecangbaotu", true, false, function (_, sender)
    end,RGBA8888)
    mcCangbaotu:setPosition(gridLyW/2+400,gridLyH/2+160)
    mcCangbaotu:setName("mcCangbaotu")
    self._gridLayer:addChild(mcCangbaotu,999)
    self._eventStatus.treasureMap = self._adModel:getData().tmo or 0
    self._eventStatus.treasureMapMcTrigger = true
    self:reflashAllGrids()
    self:showPrompt(AdventureConst.GRID_TYPE.TREASURE_MAP,1,function( )
        ScheduleMgr:delayCall(500, self, function( )
            if not tolua.isnull(mcCangbaotu) then
                self:reflashAllGrids()
                self._eventStatus.treasureMapMcTrigger = false
                ScheduleMgr:delayCall(1100, self, function( )
                    if not tolua.isnull(mcCangbaotu) then
                        mcCangbaotu:removeFromParent()
                        if callback then
                            callback()
                        end
                    end
                end)
            end
        end)

    end)
end

-- 星轴
function AdventureView:starEvent( args,callback )
    local clockT = math.floor(os.clock()*10)
    GRandomSeed(tostring(os.time()+clockT):reverse():sub(1, 6)) 
    local star1 = GRandom(1,12)
    local star2 = GRandom(star1,star1+11)%12+1
    if star1 == star2 then
        star2 = (star1+1)%12+1
    end
    local prompts = self._gridEvents[GRID_TYPE.STAR].prompt
    local prompt1 = self._gridEvents[GRID_TYPE.STAR].prompt[1] 
    local prompt2 = self._gridEvents[GRID_TYPE.STAR].prompt[2] 
    prompt2 = string.gsub(prompt2,"{$star1}","[color=f5951e00]" .. AdventureConst.STATRS[star1] .. "[-]")
    prompt2 = string.gsub(prompt2,"{$star2}","[color=f5951e00]" .. AdventureConst.STATRS[star2] .. "[-]")
    prompt1 = string.gsub(prompt1,"6d98d8","865c30")
    prompt2 = string.gsub(prompt2,"6d98d8","865c30" )
    self:reflashGridStatus(self._tempInGridId)
    self:showPrompt(GRID_TYPE.STAR,1,function( )
        if callback then
            callback()
        end
        self._viewMgr:showDialog("activity.adventure.AdventureStarView",{exactStars={star1,star2},callback=function( )
            self:reflashNaviBarRightNow()
        end},nil, nil, nil, true)
    end,nil,{prompt1,prompt2})
end

-- 潘多拉魔盒
function AdventureView:magicBoxEvent( args,callback )
    -- print(self._adModel:getMagicBoxStatus(),"self._adModel:getMagicBoxStatus()",self._adModel:getData().po)
    if self._adModel:isMagicBoxOpening() then
        self:showPrompt(AdventureConst.GRID_TYPE.MAGIC_BOX,1,function(  )
                -- print("in callback after prompts...........")
                audioMgr:playSound("Treasure_mohe")
                self._adModel:getData().po = 1
                self:reflashAllGrids()
                if callback then
                    callback()
                end
        end,nil)--,{"潘多拉魔盒","魔盒第二页"})
    elseif self._adModel:getMagicBoxStatus() then
        self:showPrompt(AdventureConst.GRID_TYPE.MAGIC_BOX,1,function(  )
                if callback then
                    callback()
                end
        end,nil,{lang("mohe_3")})
    else
        if callback then
            callback()
        end
    end
end

-- 魔井
function AdventureView:magicWellEvent( args,callback )
    self:showPrompt(AdventureConst.GRID_TYPE.MAGIC_WELL,1,function(  )
        audioMgr:playSound("Treasure_magic")
        local addNum = (args.rwd[1][3] or args.rwd[1]["num"])/50
        local curGrid = self._adModel:getCurGridId()
        self:reflashGridStatus(curGrid)
        if addNum == 1 then
            DialogUtils.showGiftGet({gifts=args.rwd})  
            if callback then
                callback()
            end
        else
            local pos = gridPoses[curGrid]
            local iconPicName = tab.tool[3004].art
            local filename = iconPicName .. ".png"
            local sfc = cc.SpriteFrameCache:getInstance()
            if not sfc:getSpriteFrameByName(filename) then
                filename = iconPicName .. ".jpg"
            end
            self:doRewardFloatAnim(pos,function( )
                DialogUtils.showGiftGet({gifts=args.rwd})  
                if callback then
                    callback()
                end
            end,"x" .. addNum,filename)
        end
    end,nil)--,{"魔井。。。。","魔井第二页"})
end

-- 猜拳
function AdventureView:fingerGuessEvent( args,callback )
    ScheduleMgr:delayCall(500, self, function( )
        if self._viewMgr then
            self._viewMgr:showDialog("activity.adventure.GuessFingerView",{callback=function( )
                self:reflashNaviBarRightNow()
            end})
            if callback then
                callback()
            end
        end
    end)
end

-- 传送门 入
function AdventureView:warpGateEnterEvent( args,callback )
    local gridFrom = self._grids[WARP_GATE_FROMID]
    self:reflashGridStatus(gridFrom)
    local gridFromPos = gridPoses[WARP_GATE_FROMID]
    audioMgr:playSound("Treasure_portal")
    local mcWarpGate = mcMgr:createViewMC("chuansongmen1_adventurecangbaotu", false, true, function (_, sender)
        local gridTo = self._grids[WARP_GATE_TOID]
        local mcWarpGateOut = mcMgr:createViewMC("chuansongmen2_adventurecangbaotu", false, true, function (_, sender)
            if callback then
                callback()
            end
        end,RGBA8888)
        local gridPos = gridPoses[WARP_GATE_TOID]
        mcWarpGateOut:setPosition(gridPos.x,gridPos.y+50)
        mcWarpGateOut:addCallbackAtFrame(6,function( )
            self._mcAnimNode:setVisible(true)
        end)
        audioMgr:playSound("Treasure_portal")
        self._gridLayer:addChild(mcWarpGateOut,999)
        self._mcAnimNode:stopAllActions()
        self._mcAnimNode:setPosition(gridPos.x,gridPos.y+30)
        -- self._mcAnimNode:runAction(cc.FadeIn:create(0.5))
        self:doPlayerEvent("stop",WARP_GATE_TOID)
    end,RGBA8888)
    mcWarpGate:setPosition(gridFromPos.x,gridFromPos.y+50)
    mcWarpGate:addCallbackAtFrame(6,function( )
        self._mcAnimNode:setVisible(false)
    end)
    -- self._mcAnimNode:runAction(cc.FadeOut:create(0.5))
    self._gridLayer:addChild(mcWarpGate,999)
end

-- 传送门 出
function AdventureView:warpGateExitEvent( args,callback )
    self:showPrompt(AdventureConst.GRID_TYPE.WARPGATE_EXIT,1,function(  )
        if callback then
            callback()
        end
    end,{lang("chuansongmenchukou")})
    -- self._viewMgr:showTip()
end

-- 敌人
function AdventureView:battleEvent( args,callback )
    self._serverMgr:sendMsg("AdventureServer", "fightBefore", {serverInfoEx = BattleUtils.getBeforeSIE()}, true, { }, function(result)
        -- dump(result)
        self:pveBeforeFinish(result)
        -- local param = {token = result.token, args = json.encode({win = 0})}
        -- self._serverMgr:sendMsg("AdventureServer", "fightAfter", param, true, {}, function(result)
        --     dump(result)
        --     if result == nil then 
        --         return 
        --     end
            
        --     -- 像战斗层传送数据
        --     if inCallBack ~= nil then
        --         inCallBack(result)
        --     end
        -- end)
        if callback then
            callback()
        end
    end)
end

-- 组装战斗数据 copy from GlobalFormationView
function AdventureView:pveBeforeFinish(result)
    dump(result)
    if result == nil or result.token == nil then 
        return
    end
    self._token = result.token
    result.lvl = result.formation.lvl

    local GuildMapUtils = require "game.view.guild.map.GuildMapUtils"
    local enemyInfo = GuildMapUtils:initBattleData(result)
    -- enemyInfo.score = result.formation.score
     -- 给布阵传递怪兽数据
    self._modelMgr:getModel("AdventureModel"):setEnemyTeamData(enemyInfo.team)
    -- 给布阵传递英雄数据
    self._modelMgr:getModel("AdventureModel"):setEnemyHeroData(enemyInfo.hero)

    local function callBattle(inLeftData)
        -- 我方联盟探索buffer
        local buff = {}
        local userData = self._modelMgr:getModel("UserModel"):getData()
        
        if userData.roleGuild and userData.roleGuild.mapbuff ~= nil then 
            for k,v in pairs(userData.roleGuild.mapbuff) do
                buff[tonumber(k)] = v
            end
        end
        inLeftData.hero.buff = buff
        -- self._viewMgr:popView(false)
        BattleUtils.enterBattleView_Adventure(inLeftData, enemyInfo, 
        function (info, callback)
            -- 战斗结束
            -- callback(info)
            if info.isSurrender then 
                callback(nil)
                return
            end
            self:pveAfter(info, callback)
        end,
        function (info)
            print("退出战斗")
 
            -- if self._battleWin == 1 then
            -- if self._callback ~= nil and self._battleResult ~= nil then 
            --     self._battleResult.win = self._battleWin
            --     self._callback(self._battleResult)
            -- end
            -- end
            -- 退出战斗
            self:close(true)
        end)
    end
    if result.formation.hero ~= nil and enemyInfo.hero ~= nil then
        result.formation.hero.score = enemyInfo.hero.score
    end
    result.formation.score = enemyInfo.score
    -- local enemyFormation = IntanceUtils:initFormationData(sysStage)
    local formationModel = self._modelMgr:getModel("FormationModel")
    self._inSecondView = true
    self._viewMgr:showView("formation.NewFormationView", {
        formationType = formationModel.kFormationTypeAdventure,
        enemyFormationData = {[formationModel.kFormationTypeAdventure] = result.formation},
        callback = function(inLeftData)
            self._inSecondView = nil
            callBattle(inLeftData)
        end,
        closeCallback = function()
            self._inSecondView = nil
        end
        }
    )
end

function AdventureView:pveAfter(data, inCallBack)
    local win = false
    if data.win then
        win = 1
    end
    -- win = 1
    -- data.win = 1    
    local param = {token = self._token, args = json.encode({win= win, time = data.time, serverInfoEx = data.serverInfoEx})}
    self._serverMgr:sendMsg("AdventureServer", "fightAfter", param, true, {}, function(result)
        dump(result,"battleAfter....")
        if result == nil then 
            ViewManager:getInstance():popView()
            return 
        end
        if result.po == 0 then
            self:reflashAllGrids()
        end
        
        -- 像战斗层传送数据
        if inCallBack ~= nil then
            data.result = result
            data.reward = result.rwd
            data.d = {}
            inCallBack(data)
        end
    end)
end

-- 起点
function AdventureView:startGridEvent( args,callback )
    print("startGridEvent startGridEvent startGridEvent···")
    local pos = gridPoses[1]
    local toolD = tab:Tool(tonumber(IconUtils.iconIdMap["dice"]))
    local itemNum = 1
    if self._eventStatus.treasureMap ~= 0 then
        self._adModel:getData().tmo = 0
        self._eventStatus.treasureMap = 0
        self:showPrompt(GRID_TYPE.START_POINT,1,function( )
            self:doPlayerEvent("win",1)
            self:doRewardFloatAnim(pos,function( )
                local diceImg = ccui.ImageView:create()
                diceImg:loadTexture(fileName or "icon_dice_adventure.png",1)
                diceImg:setScale(0.5)
                diceImg:setPosition(pos.x,pos.y+50)
                self._gridLayer:addChild(diceImg)
                self:flyToNaviAnim(diceImg,0,1)
                diceImg:setVisible(false)
                diceImg:removeFromParent()
                if toolD then
                    self._viewMgr:showTip(lang("start"))
                    self:reflashNaviBarRightNow()
                end
                self:resetGridsAnim(callback)
            end,"")
            self:doRewardFloatAnim(pos,function( )
            end,"")
        end,nil)
    else
        self:doPlayerEvent("win",1)
        self:doRewardFloatAnim(pos,function( )
            local diceImg = ccui.ImageView:create()
            diceImg:loadTexture(fileName or "icon_dice_adventure.png",1)
            diceImg:setScale(0.5)
            diceImg:setPosition(pos.x,pos.y+50)
            self._gridLayer:addChild(diceImg)
            self:flyToNaviAnim(diceImg,0,1)
            diceImg:setVisible(false)
            diceImg:removeFromParent()
            if toolD then
                self._viewMgr:showTip(lang("start"))
                self:reflashNaviBarRightNow()
            end
            self:resetGridsAnim(callback)
        end,"")
    end
end

-- 起点重置动画
function AdventureView:resetGridsAnim( callback )
    local reflashGridIds = self._adModel:getPrePassedGridIds()
    table.merge(reflashGridIds,self._nullGrids or {})
    table.merge(reflashGridIds,self._changedGridIds or {})
    self._changedGridIds = {}
    local count = table.nums(reflashGridIds)
    local countIdx = 0
    for i=1,22 do
        if reflashGridIds[i] then
            local awardImg = self._grids[i].stone:getChildByName("gridAwardImg")
            if self._nullGrids[i] and (tolua.isnull(awardImg) or not awardImg:isVisible()) then
                -- 空节点上没有资源不刷新
                count = count-1
            else
                local grid = self._grids[i]
                local awardPosX,awardPosY = grid.stone:getContentSize().width/2,grid.stone:getContentSize().height/2-10
                -- local mcChange 
                -- mcChange = mcMgr:createViewMC("shuaxinzuanshi1_adventurecangbaotu", true, false, function (_, sender)
                -- end,RGBA8888)
                
                -- mcChange:setPosition(awardPosX,awardPosY+40)
                -- -- mcChange:setName("mcChange")
                -- grid.stone:addChild(mcChange,9)
                ScheduleMgr:delayCall(100*i, self, function( )
                    countIdx = countIdx + 1
                    if not self.reflashGridStatus then return end
                    self:reflashGridStatus(i,true)
                    if grid.gridType == GRID_TYPE.BATTLE then
                        print("grid.gridType == GRID_TYPE.BATTLE",grid.gridType == GRID_TYPE.BATTLE)
                        awardImg:setPosition(awardPosX+5,awardPosY+70)
                    end
                    local mcUpLight = mcMgr:createViewMC("shuaxinzuanshi2_adventurecangbaotu", false, true, function (_, sender)
                    end,RGBA8888)
                    -- if not tolua.isnull(mcChange) then
                    --     mcChange:removeFromParent()
                    -- end
                    mcUpLight:setPosition(awardPosX,awardPosY+50)
                    if grid.gridId ~= 1 then
                        grid.stone:addChild(mcUpLight,999)
                    end
                    if countIdx == count then
                        if callback then 
                            callback()
                        end
                    end
                end)
            end
        end
    end
end

-- 钻石 金币 骰子 
function AdventureView:rewardEvent( args,callback )
    local rwd = args.rwd
    if rwd and type(rwd) == "table" and #rwd == 1 then
        local itemStr = ""
        local itemId
        local itemNum = rwd[1][3] or rwd[1]["num"]
        local flyToIdx
        local rwdMcName
        local rwdType   = rwd[1][1] or rwd[1]["type"] 
        local rwdTypeId = rwd[1][2] or rwd[1]["typeId"]
        if rwdType == "tool" then
            itemId = rwdTypeId
        else
            itemId = IconUtils.iconIdMap[rwdType]
            if rwdType == "gem" then
                flyToIdx=3
                rwdMcName = "zuanshi"
            elseif rwdType == "gold" then
                flyToIdx=2
                rwdMcName = "jinbi"
            end
        end
        local toolD = tab:Tool(tonumber(itemId))
        local curGrid = self._adModel:getCurGridId()
        self:doPlayerEvent("win",curGrid)
        local gridStone = self._grids[curGrid].stone
        local pos = gridPoses[curGrid]
        if rwdMcName then 
            audioMgr:playSound("Treasure_gold")
            local x,y = gridStone:getContentSize().width/2,gridStone:getContentSize().height/2
            for i=1,6 do
                local rwdMcGuang
                rwdMcGuang = mcMgr:createViewMC(rwdMcName .. i .. "_adventurechufa", false, true, function (_, sender)
                    if i == 6 then
                        self:flyToNaviAnim(rwdMcGuang,i,flyToIdx,function( )
                            if not self._viewMgr then return end
                            if toolD then
                                self._viewMgr:showTip("恭喜获得    ".. lang(toolD.name) .. "x" .. itemNum )
                            end
                            if callback then
                                callback()
                            end
                        end)
                    else
                        self:flyToNaviAnim(rwdMcGuang,i,flyToIdx)
                    end
                end,RGBA8888)
                rwdMcGuang:setPosition(pos.x,pos.y+30)
                self._gridLayer:addChild(rwdMcGuang,999)
            end
            -- local rwdMc = mcMgr:createViewMC(rwdMcName .. "zhuangji_adventurechufa", false, true, function (_, sender)
            -- end,RGBA8888)
            -- rwdMc:setPosition(pos.x,pos.y+30)
            -- self._gridLayer:addChild(rwdMc,999)
        elseif itemId == IconUtils.iconIdMap["dice"] then
            self:doRewardFloatAnim(pos,function( )
                local diceImg = ccui.ImageView:create()
                diceImg:loadTexture(fileName or "icon_dice_adventure.png",1)
                diceImg:setScale(0.5)
                diceImg:setPosition(pos.x,pos.y+50)
                self._gridLayer:addChild(diceImg)
                self:flyToNaviAnim(diceImg,0,1,function( )
                    if toolD then
                        self._viewMgr:showTip("恭喜获得    ".. lang(toolD.name) .. "x" .. itemNum )
                    end
                    if callback then
                        callback()
                    end
                end)
                diceImg:setVisible(false)
                diceImg:removeFromParent()
            end,"")
        else
            if toolD then
                self._viewMgr:showTip("恭喜获得    ".. lang(toolD.name) .. "x" .. itemNum )
            end
            if callback then
                callback()
            end
        end
    end
end

-- 获得物品飞向导航条动画
function AdventureView:flyToNaviAnim( mcNode,mcIdx,flyToIdx,callback )
    local navigationObj = self._viewMgr:getNavigation("global.UserInfoView")
    local mcFly 
    local mcName 
    local offset
    if mcIdx > 0 then
        if flyToIdx == 3 then
            mcName = "zuanshifeixiang_adventurechufa"
            offset = AdventureConst.flyOffset["zhuanshi"][mcIdx]
        else
            mcName = "jinbifeixing_adventurechufa"
            offset = AdventureConst.flyOffset["jinbi"][mcIdx]
        end
        mcFly =  mcMgr:createViewMC(mcName, true, false, function (_, sender)
        end,RGBA8888)
        mcFly:setScale(1)
    else -- mcIdx 为零食直接复制 传入物品
        mcFly = mcNode:clone()
        offset = {-30,10}
    end
    navigationObj:addChild(mcFly,1)
    local btnPos = mcNode:getParent():convertToWorldSpace(cc.p(mcNode:getPositionX()+30,mcNode:getPositionY()+30))
    -- print("=========btnPos=========",btnPos.x,btnPos.y,mcNode:getPositionX(),mcNode:getPositionY())
    local phyObj = navigationObj:getIconsArr()[flyToIdx]
    local phyPos = cc.p(0,0)
    if phyObj then
        phyPos = phyObj:getParent():convertToWorldSpace(cc.p(phyObj:getPositionX()-offset[1],phyObj:getPositionY()-offset[2]))
    end
    -- 按钮相对于导航条的位置
    local navigationPos = navigationObj:convertToNodeSpace(cc.p(btnPos.x+offset[1],btnPos.y+offset[2]))
    mcFly:setPosition(navigationPos)
    --体力飞到导航条
    local seqAction = cc.Sequence:create(
        cc.DelayTime:create(0.1),
        cc.MoveBy:create(0.4,cc.p(phyPos.x - btnPos.x , phyPos.y - btnPos.y)),
        cc.CallFunc:create(function ()  
            mcFly:setVisible(false)
        end),
        cc.DelayTime:create(0.1),
        cc.CallFunc:create(function ()      
            phyObj:setBrightness(40)
        end),
        cc.DelayTime:create(0.1),
        cc.CallFunc:create(function ()      
            phyObj:setBrightness(0)
            mcFly:removeFromParent()
            if callback then
                callback()
            end
        end))
    mcFly:runAction(seqAction)
end

-- 获得物品上漂动画
function AdventureView:doRewardFloatAnim( pos,callback,textStr,fileName )
    local diceImg = ccui.ImageView:create()
    diceImg:loadTexture(fileName or "icon_dice_adventure.png",1)
    diceImg:setScale(0.5)
    diceImg:setPosition(pos.x,pos.y+50)

    self._gridLayer:addChild(diceImg,999)

    local text = ccui.Text:create()
    text:setFontSize(30)
    text:setFontName(UIUtils.ttfName)
    text:setPosition(140,60)
    text:setScale(2)
    text:setString(textStr or "+1")
    text:setColor(cc.c3b(0, 255, 30))
    diceImg:addChild(text)

    diceImg:runAction(cc.Sequence:create(
        cc.MoveBy:create(0.05,cc.p(0,30)),
        cc.MoveBy:create(0.2,cc.p(0,10)),
        cc.CallFunc:create(function( )
            diceImg:removeFromParent()
            if callback then
                callback()
            end
        end)
    ))
end

-- 提示
function AdventureView:showPrompt( eventType,idx,callback,isEnd,prompts,test )
    idx = idx or 1
    local isPromptsFromConfig = not test
    self._tempPromptParams = {eventType,idx,callback,isEnd,prompts}
    local eventConfig = self._gridEvents[eventType]
    if not prompts or not type(prompts) == "table" then
        prompts = (isEnd and eventConfig.endPrompt or eventConfig.prompt) or {}
    end
    if idx > #prompts or not prompts[idx] then 
        if self._promptSch then 
            ScheduleMgr:unregSchedule(self._promptSch)
            self._promptSch = nil
        end
        self._tempPromptParams = nil
        self._promptPanel:setVisible(false)
        if callback then 
            callback()
        end
        return
    end
    self._proDesLab:setString("")
    self._proDesLab:setVisible(true)
    local icon = eventConfig.icon 
    if icon == "null" then
        icon = "treasureMap"
    end
    self._proIcon:loadTexture("icon_" .. icon .. "_adventure.png",1)
    local iconW = self._proIcon:getContentSize().width
    if iconW > 100 then
        self._proIcon:setScale(60/iconW)
    end
    self._promptPanel:setVisible(true)

    local rtx = self._proDesLab:getChildByName("rtx")
    if rtx then
        rtx:removeFromParent()
    end
    local prompt = prompts[idx]
    -- if isPromptsFromConfi then
    --     prompt = lang(prompt)
    -- end
    prompt = "[color=865c30]" .. prompt .."[-]"
    local lenth = string.len(prompt)
    rtx = RichTextFactory:create(prompt,self._proDesLab:getContentSize().width,self._proDesLab:getContentSize().height)
    -- rtx:enablePrinter(true)
    rtx:formatText()
    -- rtx:setVerticalSpace(5)
    -- rtx:setAnchorPoint(cc.p(0,0))
    local w = rtx:getInnerSize().width
    local h = rtx:getInnerSize().height
    rtx:setPosition(cc.p(w/2,self._proDesLab:getContentSize().height-h/2))
    UIUtils:alignRichText(rtx,{hAlign = "left"})
    rtx:setName("rtx")
    self._proDesLab:addChild(rtx,99)
    if not self._promptSch then
        self._promptSch = ScheduleMgr:regSchedule(2000, self, function( )
            if rtx and not tolua.isnull(rtx) and rtx:allFinished() then
                if self._promptSch then 
                    ScheduleMgr:unregSchedule(self._promptSch)
                    self._promptSch = nil
                end
                self:showPrompt( eventType,idx+1,callback,isEnd,prompts,test )
            end
        end)
    end
end

-- 销毁
function AdventureView:onDestroy( )
    if self._leftTimeSche then
        ScheduleMgr:unregSchedule(self._leftTimeSche)
        self._leftTimeSche = nil
    end
    -- self._preBGMName = audioMgr:getMusicFileName()
    -- audioMgr:playMusic("HappyGame", true)
    if self._preBGMName then
        audioMgr:playMusic(self._preBGMName, true)
    end
    self._viewMgr:disableScreenWidthBar()
    AdventureView.super.onDestroy(self)
end

return AdventureView