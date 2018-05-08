--
-- Author: <wangguojun@playcrab.com>
-- Date: 2018-02-03 13:28:13
--
local PurgatoryView = class("PurgatoryView", BaseView)

function PurgatoryView:ctor( )
    PurgatoryView.super.ctor(self)
end

function PurgatoryView:getBgName( )
	return "purgatory_bg.jpg"
end

function PurgatoryView:getAsyncRes( )
    return {
        {"asset/ui/purgatory.plist", "asset/ui/purgatory.png"},
        {"asset/ui/siegeDaily.plist", "asset/ui/siegeDaily.png"},
        {"asset/ui/guildMapFam.plist", "asset/ui/guildMapFam.png"},
    }
end

function PurgatoryView:setNavigation( )
	self._viewMgr:showNavigation("global.UserInfoView", {hideInfo = true, title = "globalTitle_arena.png", titleTxt = "无尽炼狱"})
end

-- 第一次被加到父节点时候调用
function PurgatoryView:onBeforeAdd(callback, errorCallback)
    self._onBeforeAddCallback = function(inType)
        if inType == 1 then 
            callback()
        else
            errorCallback()
        end
    end
    self._serverMgr:sendMsg("PurgatoryServer", "getPurInfo", {}, true, {}, function ( result )
        self:getPurInfoFinish()
    end, function ( errorId )
        errorId = tonumber(errorId)
        print("errorId:" .. errorId)
        errorCallback()
        self._viewMgr:unlock()
    end)
end

function PurgatoryView:getStageInfo( data, callback )
    self._serverMgr:sendMsg("PurgatoryServer", "getStageInfo", {stageIds = data}, true, {}, function ( result )
        callback(result)
    end, function ( errorId )
        errorId = tonumber(errorId)
        print("errorId:" .. errorId)
        self._onBeforeAddCallback(2)
        self._viewMgr:unlock()
    end)
end

function PurgatoryView:getNeedStageInfoList(  )
    local stageInfos = self._purModel:getStageInfos()
    local curSite = self._purModel:getCurrentSite()
    local reqStageList = {}
    if not stageInfos[curSite] then
        table.insert(reqStageList, curSite)
    end
    local nextStage = curSite + 1
    if not stageInfos[nextStage] and nextStage <= self._maxStage then
        table.insert(reqStageList, nextStage)
    end
    nextStage = curSite + 2
    if not stageInfos[nextStage] and nextStage <= self._maxStage then
        table.insert(reqStageList, nextStage)
    end
    nextStage = curSite + 3
    if not stageInfos[nextStage] and nextStage <= self._maxStage then
        table.insert(reqStageList, nextStage)
    end
    return reqStageList
end

function PurgatoryView:getPurInfoFinish(  )
    self._purFightCfg = clone(tab.purFight)
    self._maxStage = #self._purFightCfg
    self._totalStage = self._maxStage + 2

    local reqStageList = self:getNeedStageInfoList()
    if #reqStageList <= 0 then
        self._onBeforeAddCallback(1)
        self:initView()
    else
        self:getStageInfo(reqStageList, function ( result )
            self._onBeforeAddCallback(1)
            self:initView()
        end)
    end
end

function PurgatoryView:initView(  )
    self._tableBg = self:getUI('bg.tableBg')
    
    self._maxInnerHeight = (self._totalStage - 1) * self._cellHeight + 32
    self._curStage = self._purModel:getCurrentSite()
    self._stageInfos = self._purModel:getStageInfos()
    self:addTableView()
    self:updateInfo()

    self._purModel:showBuffSelectDialog(nil, function (  )
        self:checkWinFirstStageGuide()
    end)
    self:checkWinFirstStageGuide()
end

-- 初始化UI后会调用, 有需要请覆盖
function PurgatoryView:onInit( )
    self._cellHeight = 180
    self._enemySp = {}

    self._purModel = self._modelMgr:getModel("PurgatoryModel")
    self._userModel = self._modelMgr:getModel("UserModel")

    self._layerCell = self:getUI("bg.layerCell")
    self._layerCell_0 = self:getUI('bg.layerCell_0')

    local battleBtn = self:getUI('bg.panel.buttons.cityInfoBtn')
    self:registerClickEvent(battleBtn, function()
        local rankModel = self._modelMgr:getModel("RankModel")
        rankModel:setRankTypeAndStartNum(33, 1)
        self._serverMgr:sendMsg("RankServer", "getRankList", {type = 33, startRank = 1}, true, {}, function(result)
            self._viewMgr:showDialog("purgatory.PurgatoryRuleView")
        end)
        UIUtils:reloadLuaFile("purgatory.PurgatoryView")
    end) 

    local rankBtn = self:getUI('bg.panel.buttons.rankBtn')
    self:registerClickEvent(rankBtn, function()
        local rankModel = self._modelMgr:getModel("RankModel")
        rankModel:setRankTypeAndStartNum(33, 1)
        self._serverMgr:sendMsg("RankServer", "getRankList", {type = 33, startRank = 1}, true, {}, function(result)
            self._viewMgr:showDialog("purgatory.PurgatoryRankView")
        end)
    end) 

    local rewardBtn = self:getUI('bg.panel.buttons.rewardBtn')
    self:registerClickEvent(rewardBtn, function()
        self._serverMgr:sendMsg("PurgatoryServer", "getPlatFriendInfo", {}, true, {}, function ( result )
            self._viewMgr:showDialog("purgatory.PurgatoryCareerDialog")
        end)
    end) 
    --800150817960
    local buffBtn = self:getUI('bg.panel.btn_buff')
    self:registerClickEvent(buffBtn, function()
        self:showBuffNode()
    end) 

    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            if self._scheduler then
                if self._scheduler1 then
                    self._scheduler:unscheduleScriptEntry(self._scheduler1)
                end
                self._scheduler = nil
                for k,v in pairs(self._freeCell) do
                    v:release() 
                end
            end
        elseif eventType == "enter" then 
            --倒计时
            self:setCountTime()
        end
    end)

    -- 保存气泡提示flag
    local curServerTime = self._userModel:getCurServerTime()
    local timeStr = TimeUtils.getDateString(curServerTime, "%Y%m%d")
    SystemUtils.saveGlobalLocalData("PURGATORY_IS_SHOW_QIPAO" .. timeStr, 1)

    self:listenReflash("FormationModel", self.reflashCurStage)
    self:listenReflash("PurgatoryModel", self.updateView)
end

function PurgatoryView:reflashCurStage(  )
    self._tableView:updateCellAtIndex(self._curStage - 1)
end

function PurgatoryView:showBuffNode(  )
    local sbuffIds = self._purModel:getBuffIds() or {}

    if table.nums(sbuffIds) <= 0 then
        self._viewMgr:showTip("您当前没有加成")
        return
    end
    
    local buffIds = {}
    for k, v in pairs(sbuffIds) do
        local buffId = tonumber(k)
        local buffNum = tonumber(v)

        local buffData = tab.purBuff[buffId]
        local buffV = buffData.pro[1][2] * buffNum
        local buffType = buffData.pro[1][1]

        local isHave = true
        for k1, v1 in pairs(buffIds) do
            if v1["buffType"] == buffType then
                isHave = false
                v1["buffNum"] = v1["buffNum"] + buffV
            end
        end
        if isHave then
            local dd = {}
            dd["buffType"] = buffType
            dd["buffNum"] = buffV
            buffIds[k] = dd
        end
    end

    local bgLayer = ccui.Layout:create()
    bgLayer:setBackGroundColorOpacity(0)
    bgLayer:setBackGroundColorType(1)
    bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
    bgLayer:setTouchEnabled(true)
    bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self._widget:addChild(bgLayer, 100)
    bgLayer:setName("bgLayer")

    registerClickEvent(bgLayer, function()
        local buffBg = self:getUI("bg.panel.buffBg")   
        buffBg:setVisible(false)
        buffBg:removeAllChildren()
        bgLayer:removeFromParent()
    end)

    local buffBg = self:getUI("bg.panel.buffBg")
    local buffNum = table.nums(buffIds)
    buffBg:setContentSize(buffBg:getContentSize().width, buffNum * (27 + 10) + 20)
    local posY = 27 / 2 + 10
    local i = 0
    for k, v in pairs(buffIds) do
        local buffNum = v["buffNum"]
        local buffId = tonumber(k)
        local buffData = tab.purBuff[buffId]
        local iconName = buffData.icon .. ".png"
        local icon = ccui.ImageView:create(iconName, 1)
        local scale = 27 / icon:getContentSize().height
        icon:setScale(scale)
        local y = posY + (icon:getContentSize().height * scale + 10) * i
        icon:setPosition(30, y)
        buffBg:addChild(icon)

        local picFrame = ccui.ImageView:create("globalImageUI4_squality5.png", 1)
        picFrame:setPosition(icon:getContentSize().width / 2, icon:getContentSize().height / 2)
        icon:addChild(picFrame)

        local desc = lang(buffData.des) 
        -- local buffNum = buffData.pro[1][2] * buffNum
        local result,count = string.gsub(desc, "$num", buffNum)
        if count > 0 then 
            desc = result
        end
        local richText = RichTextFactory:create(desc, 170 , 0)
        richText:formatText()
        richText:setPosition(60 + richText:getContentSize().width/2, y)
        buffBg:addChild(richText)
        i = i + 1
    end
    buffBg:setVisible(true)
end

function PurgatoryView:setCountTime(  )
    local time = self._userModel:getCurServerTime()
    local endHour = tab.setting["PURGATORY_TIME"].value[2]
    local endTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(time, "%Y-%m-%d " .. endHour .. ":00:00"))
    self._countTime = endTime - time
    local countNum = self:getUI('bg.top_info.Label_73_0')
    self:runAction(cc.RepeatForever:create(
        cc.Sequence:create(cc.CallFunc:create(function()
            self._countTime = self._countTime - 1
            tempValue = self._countTime
            local showTime = "00:00:00"
            if tempValue > 0 then
                hour = math.floor(tempValue/3600)
                tempValue = tempValue - hour*3600
                minute = math.floor(tempValue/60)
                tempValue = tempValue - minute*60
                second = math.fmod(tempValue, 60)
                showTime = string.format("%.2d:%.2d:%.2d", hour, minute, second)
            end
            countNum:setString(showTime)
        end),cc.DelayTime:create(1))
    ))
end

-- 第一次进入调用, 有需要请覆盖
function PurgatoryView:onShow()

end

-- 被其他View盖住会调用, 有需要请覆盖
function PurgatoryView:onHide()

end

function PurgatoryView:updateView(  )
    if self._reflashTop then
        return
    end
    self:moveStage()
    self:updateInfo()
end

function PurgatoryView:onTop(  )
    self:updateView()
    self:checkWinFirstStageGuide()
end

-- 接收自定义消息
function PurgatoryView:reflashUI(data)

end

function PurgatoryView:checkWinFirstStageGuide(  )
    local showBuffList = self._purModel:getShowBuffIdList()
    if self._purModel:getCurrentSite() > 1 and #showBuffList <= 0 then
        GuideUtils.checkTriggerByType("purgatory", "winFirstStage")
    end
end

function PurgatoryView:moveStage(  )
    if self._isMoving then
        return
    end
    local newStage = self._purModel:getCurrentSite()
    if newStage <= self._curStage then
        self._tableView:updateCellAtIndex(self._curStage - 1)
        return
    end
    local stageNum = newStage - self._curStage
    self._curStage = newStage
    self._tableView:updateCellAtIndex(self._curStage - stageNum - 1)
    if stageNum <= 3 then
        self._tableView:updateCellAtIndex(newStage - 1)
    end
    local reqStageList = self:getNeedStageInfoList()
    if #reqStageList > 0 then
        self._isMoving = true
        self:getStageInfo(reqStageList, function ( result )
            self._stageInfos = self._purModel:getStageInfos()
            self:moveToCurrentStage(true)
            self:checkSkipStageReward()
            self._isMoving = false
        end)
        return
    end
    self:moveToCurrentStage(true)
    self:checkSkipStageReward()
end

function PurgatoryView:moveToCurrentStage( anim )
    local offsetY = self._cellHeight * (self._curStage - 1)
    local maxOffsetY = self._maxInnerHeight - MAX_SCREEN_HEIGHT
    if offsetY > maxOffsetY then
        offsetY = maxOffsetY
    end
    if anim then
        self._tableView:setContentOffsetInDuration(ccp(0, -offsetY), 1)
    else
        self._tableView:setContentOffset(ccp(0, -offsetY))
    end
end

function PurgatoryView:addTableView( )
    local tableView = cc.TableView:create(cc.size(688, MAX_SCREEN_HEIGHT))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(0,0))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_BOTTOMUP)
    tableView:setBounceable(true)
    self._tableBg:addChild(tableView)
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

    tableView:reloadData()

    self._tableView = tableView

    self:moveToCurrentStage()
end

function PurgatoryView:scrollViewDidScroll(view)
    -- print("scrollViewDidScroll")
end

function PurgatoryView:scrollViewDidZoom(view)
    -- print("scrollViewDidZoom")
end

function PurgatoryView:tableCellTouched(table,cell)
    -- print("cell touched at index: " .. cell:getIdx())
end

function PurgatoryView:cellSizeForTable(table,idx) 
    if idx == self._totalStage - 1 then
        return 32, 688
    else 
        return self._cellHeight, 688
    end
end

function PurgatoryView:numberOfCellsInTableView(table)
   return self._totalStage
end

local AnimAp = require "base.anim.AnimAP"

function PurgatoryView:tableCellAtIndex(table, idx)
    local serverData = self._stageInfos[idx + 1]
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
    end

    local cellBoard = cell:getChildByFullName("cellBoard")
    local cellBoard_0 = cell:getChildByFullName("cellBoard_0")
    if tolua.isnull(cellBoard) then
    	cellBoard = self._layerCell:clone()
    	cellBoard:setPosition(0, 0)
    	cellBoard:setCascadeOpacityEnabled(true, true)
    	cellBoard:setName("cellBoard")
    	cell:addChild(cellBoard, 999)
    end
    if tolua.isnull(cellBoard_0) then
        cellBoard_0 = self._layerCell_0:clone()
        cellBoard_0:setPosition(0, 0)
        cellBoard_0:setCascadeOpacityEnabled(true, true)
        cellBoard_0:setName("cellBoard_0")
        cell:addChild(cellBoard_0, 999)
    end
    if idx == self._totalStage - 1 then
        cellBoard_0:setVisible(true)
        cellBoard:setVisible(false)
    else
        cellBoard_0:setVisible(false)
        cellBoard:setVisible(true)
        self:updateCellBoard(cellBoard, idx + 1, serverData)
    end
    -- cellBoard:setSwallowTouches(false)
    -- cellBoard_0:setSwallowTouches(false)
    return cell
end

local IntanceMcAnimNode = require("game.view.intance.IntanceMcAnimNode")
function PurgatoryView:createWizard( cellBoard )
    local enemyBg = cellBoard:getChildByFullName('enemy')
    local img_talk = cellBoard:getChildByFullName('img_talk')
    if self._curStage == self._totalStage - 1 then
        img_talk:setVisible(true)
    end
    local talkBg = img_talk:getChildByFullName('Panel_117')
    local talkTx = talkBg:getChildByFullName('talkTx')
    if talkTx then
        talkTx:removeFromParent()
    end
    local talkTx = RichTextFactory:create(lang("TIP_PURGATORY_2"), 130)
    talkTx:setPixelNewline(true)
    talkTx:formatText()
    talkTx:setAnchorPoint(cc.p(0, 0))
    talkTx:setName("talkTx")
    local w = talkTx:getInnerSize().width
    talkTx:setPosition(cc.p(-w * 0.5 + 10, 2))
    talkBg:addChild(talkTx)

    local heroMc = IntanceMcAnimNode.new({"stop"}, "lianmengxuezhe",
        function(sender)
            -- sender:changeMotion(1, nil, true)
        end
        ,100,100,
        {"stop"},{{3,10},1}, true)
    heroMc:setPosition(enemyBg:getContentSize().width * 0.5, 10)
    enemyBg:addChild(heroMc)
end

function PurgatoryView:updateEnemyMC( stageType, cellBoard, idx, serverData )
    local enemyBg = cellBoard:getChildByFullName('enemy')
    local action = cc.RepeatForever:create(
        cc.Sequence:create(
            cc.MoveBy:create(0.5,cc.p(0, -10)),
            cc.MoveBy:create(0.5,cc.p(0, 10))
        )
        )
    if stageType == 1 and serverData and serverData.teams then
        -- local rid = GRandom(1, #serverData.teams)
        -- rid = self._purModel:getStageRandomEnemy(idx, rid)
        local rid = 1
        local npcId = serverData.teams[rid].npcid
        local artName = tab:Npc(npcId).art
        local animSp
        if AnimAp["mcList"][artName] then
            MovieClipAnim.new(enemyBg, artName, function (sp)
                animSp = sp
                animSp:setPosition(enemyBg:getContentSize().width * 0.5 - 20, 0)
                animSp:changeMotion(10)
                animSp:play()
                animSp:setScale(0.35)
                animSp:setScaleX(-0.35)
                -- if self._curStage < idx and animSp then
                --     animSp:pause()
                --     animSp:setBrightness(-100)
                -- end
            end, 2)
        else
            SpriteFrameAnim.new(enemyBg, artName, function (sp)
                animSp = sp
                animSp:setName("anim_sp")
                animSp:setPosition(enemyBg:getContentSize().width * 0.5 - 20, 0)
                animSp:setLocalZOrder(8)
                animSp:setScaleX(-1)
                animSp:play()
                -- if self._curStage < idx and animSp then
                --     animSp:stop()
                --     animSp:setBrightness(-100)
                -- end    
            end, true)
        end
    elseif stageType == 2 then
        local buffMC = mcMgr:createViewMC("bufftexiao_pata", true)
        buffMC:setPosition(enemyBg:getContentSize().width * 0.5 - 20, 0)
        enemyBg:addChild(buffMC)
        local icon = cc.Sprite:create("asset/uiother/battle/b_qidao.png")
        icon:setPosition(enemyBg:getContentSize().width * 0.5 - 20, enemyBg:getContentSize().height * 0.5 + 20)
        enemyBg:addChild(icon)
        icon:runAction(action)
    elseif stageType == 3 then
        local rewardMC = mcMgr:createViewMC("baoxiang1_patabaoxiang", true)
        rewardMC:setPosition(enemyBg:getContentSize().width * 0.5 - 20, 10)
        enemyBg:addChild(rewardMC)
        -- local icon = ccui.ImageView:create("rune_art_104.png", 1)
        -- icon:setPosition(enemyBg:getContentSize().width * 0.5, enemyBg:getContentSize().height * 0.5 + 20)
        -- enemyBg:addChild(icon)
        -- icon:runAction(action)
    end
end

function PurgatoryView:showRewardAnim( callback )
    local cell = self._tableView:cellAtIndex(self._curStage - 1)
    local cellBoard = cell:getChildByFullName('cellBoard')
    local enemyBg = cellBoard:getChildByFullName('enemy')
    enemyBg:removeAllChildren()
    local rewardMC = mcMgr:createViewMC("baoxiang2_patabaoxiang", false, true, function (  )
        if callback then
            callback()
        end
    end)
    rewardMC:setPosition(enemyBg:getContentSize().width * 0.5 - 20, 10)
    enemyBg:addChild(rewardMC)
end

function PurgatoryView:updateCellBoard( cellBoard, idx, serverData )
    local stageData = self._purFightCfg[idx] or {}

    local bgIndex = idx % 3
    if bgIndex == 0 then
        bgIndex = 3
    end

    local bgImg = "purgatory_layer_" .. bgIndex .. ".png"
    cellBoard:getChildByFullName('layerbg'):loadTexture(bgImg, 1)

    local cengNum = cellBoard:getChildByFullName('cengNum')
    cengNum:setVisible(true)
    cengNum:setString("第" .. idx .. "层")

    if idx > self._curStage then
        cengNum:setColor(cc.c3b(173, 168, 170))
    else
        cengNum:setColor(cc.c3b(242, 231, 137, 255))
    end

    local enemyBg = cellBoard:getChildByFullName('enemy')
    local heroBg = cellBoard:getChildByFullName('hero')
    local img_talk = cellBoard:getChildByFullName('img_talk')

    img_talk:setVisible(false)
    enemyBg:removeAllChildren()
    heroBg:removeAllChildren()

    --1.战斗
    --2.选择buff
    --3.直接给奖励
    --100.圣诞老人

    local stageType = stageData.type or 100
    if self._curStage <= idx then
        if (idx == self._totalStage - 1) then
            cengNum:setVisible(false)
            self:createWizard(cellBoard)
        else
            self:updateEnemyMC(stageType, cellBoard, idx, serverData)
        end
    end

    local enemyBtn = cellBoard:getChildByFullName('enemyBtn')
    self:registerClickEvent(enemyBtn, function()
        if stageType == 1 then
            self:enterBattle(idx)
        elseif stageType == 2 and self._curStage == idx then
            self._purModel:showBuffSelectDialog(idx, function (  )
                self:checkWinFirstStageGuide()
            end)
        elseif stageType == 3 and self._curStage == idx then
            self._serverMgr:sendMsg("PurgatoryServer", "getStageReward", {stageId = self._curStage}, true, {}, function ( result )
                self._reflashTop = true
                self:lock(-1)
                self:showRewardAnim(function (  )
                    self._reflashTop = false
                    self:updateView()
                    self:unlock(-1)
                    DialogUtils.showGiftGet({gifts = result.reward, callback = function (  )
                        self:checkWinFirstStageGuide()
                    end})
                end)
            end, function ( errorId )
                
            end)
        end
    end) 

    if self._curStage == idx then
        --myself
        local formationModel = self._modelMgr:getModel("FormationModel")
        local heroId = formationModel:getFormationDataByType(formationModel.kFormationTypeClimbTower).heroId
        if not heroId or heroId == 0 then
            heroId = 60102
        end
        local skin_name = tab:Hero(heroId).heroart
        local userHeroData = self._modelMgr:getModel("HeroModel"):getHeroData(heroId)
        if userHeroData.skin then
            local heroSkinD = tab.heroSkin[userHeroData.skin]
            skin_name = (heroSkinD and heroSkinD["heroart"]) and heroSkinD["heroart"] or skin_name
        end
        HeroAnim.new(heroBg, skin_name, {"stop", "run"}, function (mc)
            mc:play()
            mc:setPosition(60, 0)
            mc:setScale(0.35)
        end, false, nil, nil, false)
    end

    --reward
    local rewradBg = cellBoard:getChildByFullName('Panel_38')
    rewradBg:removeAllChildren()
    rewradBg:setVisible(false)

    local quick_battle = cellBoard:getChildByFullName('btn_quick_battle')
    quick_battle:setVisible(false)
    
    if self._curStage == idx and stageType == 1 then

        --quickBattle
        local curServerTime = self._userModel:getCurServerTime()
        local timeStr = TimeUtils.getDateString(curServerTime, "%Y%m%d")
        local quickFlag = SystemUtils.loadAccountLocalData("purgatory_quick_battle_" .. idx .. "_" .. timeStr) or ""
        if not quickFlag or quickFlag == "" then
            quick_battle:setVisible(true)
            self:registerClickEvent(quick_battle, function (  )
                self:quickEnterBattle(idx, true)
            end)
        end

        --reward
        local rewardData = serverData.rewards or {}
        local posY = 3
        for i = 1, #rewardData do
            local num = rewardData[i][3]
			local itemType = rewardData[i][1]
            local itemId = rewardData[i][2]
            if itemType ~= "tool" and itemType ~= "rune" then
				itemId = IconUtils.iconIdMap[itemType]
            end
            local itemIcon = rewradBg:getChildByName("itemIcon" .. i)
            local param = {itemId = itemId, num = num}
			if itemType == "rune" then--兼容宝石
				param = {suitData = tab.rune[itemId]}
			end
            if itemIcon and itemIcon.itemType==itemType then
				if itemType=="rune" then
					IconUtils:updateHolyIcon(itemIcon, param)--宝石刷新icon
				else
					IconUtils:updateItemIconByView(itemIcon, param)
				end
            else
				if itemIcon then
					itemIcon:removeFromParent()--icon类型不同无法刷新，需remove重新创建icon
				end
				if itemType=="rune" then
					itemIcon = IconUtils:createHolyIconById(param)
				else
					itemIcon = IconUtils:createItemIconById(param)
				end
                itemIcon:setScale(0.45)
				itemIcon.itemType = itemType--添加icon的类型属性
                itemIcon:setName("itemIcon" .. i)
                rewradBg:addChild(itemIcon)
				local posX = rewradBg:getContentSize().width / 2 - 14
				if itemType=="rune" then
					posX = posX - 2
				end
                itemIcon:setPosition(posX, posY)
                posY = posY + 58
            end
        end
        rewradBg:setVisible(true)
        -- rewradBg:setPositionX(510 - (#rewardData - 1) * 25)
    end
end

function PurgatoryView:forwardStage(  )
    if self._countTime <= 0 then
        self._viewMgr:showTip("活动已结束")
        return
    end
    local open, txt = self._purModel:isOpenPurgatory()
    if not open then
        self._viewMgr:showTip(txt)
        return
    end
    self._serverMgr:sendMsg("PurgatoryServer", "skipStage", {}, true, {}, function ( result )
        self._skipStageReward = result.reward
        self:moveStage()
        self:updateInfo()
    end, function ( errorId )
        
    end)
end

function PurgatoryView:updateInfo(  )
	local top_info = self:getUI('bg.top_info')
    local forwardLab = top_info:getChildByFullName('Label_73_1')
    local forwardBtn = top_info:getChildByFullName('btn_go')
    self:registerClickEvent(forwardBtn, function (  )
        self:forwardStage()
    end)
    local hScoreStage = self._purModel:getHighScoreStage()
    if hScoreStage > self._curStage then
        forwardBtn:setVisible(true)
        forwardLab:setVisible(true)
        forwardLab:setString("您当前战力可直接前往第" .. (hScoreStage + 1) .. "层")
    else
        forwardBtn:setVisible(false)
        forwardLab:setVisible(false)
    end
end

-- 把点击  前往  后奖励和buff展示 单独挪出来是为了解决  点前往后点战斗会崩溃的问题
-- 因为前往后会请求前往后的塔层数据，会消息堵塞 崩溃
function PurgatoryView:checkSkipStageReward(  )
    if not self._skipStageReward then
        return
    end
    DialogUtils.showGiftGet({gifts = self._skipStageReward, callback = function (  )
        self._purModel:showBuffSelectDialog(nil, function (  )
            self:checkWinFirstStageGuide()
        end)
        self:checkWinFirstStageGuide()
    end})
    self._skipStageReward = nil
end

----------------------------------------------------------------------------
----------------------------------------------------------------------------

function PurgatoryView:quickEnterBattle( id, isQuick )
    if self._curStage ~= id then
        return
    end
    if self._countTime <= 0 then
        self._viewMgr:showTip("活动已结束")
        return
    end
    local open, txt = self._purModel:isOpenPurgatory()
    if not open then
        self._viewMgr:showTip(txt)
        return
    end
    if isQuick then
        BattleUtils.onceFastBattle = true
        local curServerTime = self._userModel:getCurServerTime()
        local timeStr = TimeUtils.getDateString(curServerTime, "%Y%m%d")
        SystemUtils.saveAccountLocalData("purgatory_quick_battle_" .. id .. "_" .. timeStr, 1)
    end
    self._serverMgr:sendMsg("PurgatoryServer", "atkBeforePurgatory", {stageId = id}, true, {}, function(_result) 
        if not isQuick then
            self._viewMgr:popView()
        end
        self:enterPurgatoryBattle( BattleUtils.jsonData2lua_battleData(_result["atk"]), _result.r1, _result.r2,_result["def"],_result.token)
    end)
end

function PurgatoryView:enterBattle( id )
    if self._curStage ~= id then
        return
    end
    if self._countTime <= 0 then
        self._viewMgr:showTip("活动已结束")
        return
    end
    local open, txt = self._purModel:isOpenPurgatory()
    if not open then
        self._viewMgr:showTip(txt)
        return
    end

    local battleData = self:initBattleData(id)
    self._purModel:setEnemyData(battleData.teams)
    self._purModel:setStageId(id)
    
    self._purModel:setEnemyHeroData(battleData.hero)
    local formationType = self._modelMgr:getModel("FormationModel").kFormationTypeClimbTower
    self._viewMgr:showView("formation.NewFormationView", {
        formationType = formationType,
        recommend = self._hotIds or {},
        enemyFormationData = {[formationType] = battleData.formation},
        extend = {
            purgatoryId = self._curStage,
            -- heroes = self._leagueModel:getLeagueHeroIds(),
            -- helpHero = {self._modelMgr:getModel("LeagueModel"):getCurHelpHeroId()},
            -- nextHelpHero = {self._modelMgr:getModel("LeagueModel"):getNextHelpHeroId()},
            -- showHelpTag = true,
        },
        callback = function(leftData)
            self:quickEnterBattle(id)
        end,
    })
end

function PurgatoryView:initBattleData( stageId )
    local battleData = clone(self._stageInfos[stageId])
    local cfg = tab.purFight[stageId]
    dump(cfg,"cfg----------")

    local enemyFormation = {}
    -- 组布阵信息
    for i,team in ipairs(battleData.teams) do
        enemyFormation["g" .. i] = team.pos
        enemyFormation["team" .. i] = team.npcid 
    end
    enemyFormation.tid = 1
    enemyFormation.heroId = battleData.hero.heroId
    enemyFormation.star = battleData.hero.star
    enemyFormation.score = cfg.score
    enemyFormation.weapon1 = 0
    enemyFormation.weapon2 = 0
    enemyFormation.weapon3 = 0
    enemyFormation.weapon4 = 0
    enemyFormation.filter = ""
    battleData.formation = enemyFormation
    
    local hero = battleData.hero 
    hero.star = cfg.herostar or 1
    hero.level = 1
    local slevel = cfg.heroskill or 1
    hero.slevel = {slevel, slevel, slevel, slevel, slevel}
    hero.hAb = cfg.herobase

    -- 初始化npc数据
    battleData.npc = {}
    local monsters = battleData.teams
    local count = 1
    local teamlv = cfg["teamlv"]
    local teamskill = cfg["teamskill"]
    for k,v in pairs(monsters) do
        battleData.npc[count] = {v["npcid"], v["pos"] , teamlv, teamskill}
        if cfg then
            battleData.npc[count].jxLv = cfg.jxLv
            battleData.npc[count].jxSkill1 = cfg.jxSkill1
            battleData.npc[count].jxSkill2 = cfg.jxSkill2
            battleData.npc[count].jxSkill3 = cfg.jxSkill3
        end
        count = count + 1
    end
    -- 拼接觉醒


    dump(battleData,"battleData============")

    return battleData
end

function PurgatoryView:enterPurgatoryBattle( playerInfo, r1, r2,enemyD,token)
    local enemyInfo = enemyD --self:initBattleData(enemyD)
    -- for i,team in ipairs(playerInfo.team) do
    --     if self._hotBuff[tonumber(team.id)] then
    --         team.leagueBuff = self._hotBuff[tonumber(team.id)]
    --     end
    -- end
    -- dump(playerInfo,"playerInfo...--------------",10)
    -- local playerInfo  = self:getVirtualPlayerInfo()
    self._enterBattle = true
    BattleUtils.enterBattleView_ClimbTower(playerInfo, enemyInfo, r1, r2,
    function (info, callback)
        self:afterPurgatoryBattle(info,callback,token)
    end,
    function (info)
        -- 退出战斗
    end)
end

function PurgatoryView:afterPurgatoryBattle( data,callback,token )
    local win = 0
    if data.win then
        win = 1
    end
    dump(data,"afterPurgatoryBattle",2)
    -- 后端统计数据要加入time by guojun 2016.9.6
    local crash
    if data.isSurrender then
        crash = 1
    end
    local zzid = GameStatic.zzid10
    local param = {stageId = self._curStage,
        args = json.encode({
                    win = win, 
                    time = data.time, 
                    serverInfoEx = data.serverInfoEx,
                    skillList = data.skillList,
                    zzid = 1,
                }),
                token =token}
    self._serverMgr:sendMsg("PurgatoryServer", "atkAfterPurgatory", 
        param, true, {}, function(result)
        dump(result)
        data.reward = result.reward
        if result["cheat"] == 1 then
            data.failed = true
            data.extract = result["extract"]
        end
        callback(data)
    end)
end
----------------------------------------------------------------------------

return PurgatoryView
