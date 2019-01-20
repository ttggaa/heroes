--[[
    Filename:    GodWarView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-05-05 15:01:55
    Description: File description
--]]

-- 争霸赛主场景
local GodWarView = class("GodWarView", BaseView)
local readlyTime = GodWarUtil.readlyTime -- 准备间隔
local fightTime = GodWarUtil.fightTime -- 战斗间隔
local showScoreTime = GodWarUtil.showScoreTime

local posTab = {
    [1] = {0, -2, 0.7},
    [2] = {-3, -5, 0.86},
    [3] = {0, 0, 0.95},
    [4] = {3, 0, 1},
    [5] = {0, 0, 0.7},
}
local playSelfPos = {
    [1] = {-2, 15, 0.7},
    [2] = {2, 12, 0.8},
    [3] = {5, 15, 0.9},
    [4] = {8, 10, 1},
    [5] = {-2, 15, 0.7},
}
local selectStr = {
    [1] = "xiaozuBtn",
    [2] = "zhengbaBtn",
    [3] = "guanjunBtn",
}
local promotionTab = GodWarUtil.promotion
local godWarGroupMax = 8

function GodWarView:ctor(data)
    GodWarView.super.ctor(self)
end

-- 1 火焰有 战斗中
-- 2 火焰无 战斗结束
-- 3 移除火焰
function GodWarView:updateHeroAnim(inView, state, indexId)
    -- print("state=========", state, self._animBattle)
    if not inView then
        return
    end
    if state == 1 then
        local fireMc = inView:getChildByName("fireMc")
        if not fireMc then
            fireMc = mcMgr:createViewMC("buffguangxiaoxia_duizhanui", true, false)
            fireMc:setName("fireMc")
            fireMc:setPosition(32, 0)
            inView:addChild(fireMc, -1)
        end
    elseif state == 2 then
        -- self:setMoveAnim(inView, indexId)
    elseif state == 3 then
        local fireMc = inView:getChildByName("fireMc")
        if fireMc then
            fireMc:removeFromParent()
        end
    end
end

function GodWarView:setMoveAnim(inView, indexId, proData, stateId)
    local powtu = self:getUI("bg.layer3.powtu")
    local headBg = inView:clone()
    powtu:addChild(headBg, 13)

    local moveTab = tab:GodWarMove(indexId).move
    local movePoint = {}
    for i=1,table.nums(moveTab) do
        local posX = moveTab[i][1] + 2
        local posY = moveTab[i][2] - 1
        local move = cc.MoveBy:create(0.2, cc.p(posX, posY))
        table.insert(movePoint, move)
    end

    local scale1 = cc.ScaleTo:create(0.3, 1.4)
    table.insert(movePoint, scale1)
    local scale2 = cc.ScaleTo:create(0.05, 1.1)
    table.insert(movePoint, scale2)
    local delay = cc.DelayTime:create(0.02)
    table.insert(movePoint, delay)
    local callFunc = cc.CallFunc:create(function()
        local yanhua = mcMgr:createViewMC("touxiangkuangguang_godwar", false, true)
        yanhua:setPosition(headBg:getContentSize().width*0.5,headBg:getContentSize().height*0.5)
        headBg:addChild(yanhua,5)
        local icon = headBg:getChildByName("icon")
        if icon then
            icon:setBrightness(60)
        end
        self:updatePowData(proData, stateId, false)
    end)
    table.insert(movePoint, callFunc)
    local delay = cc.DelayTime:create(0.1)
    table.insert(movePoint, delay)
    local callFunc = cc.CallFunc:create(function()
        local tround = stateId+1
        local proData = promotionTab[tround]
        self._godWarModel:replaceProgressWarData()
        self:updatePowData(proData, tround, false)
        self:updatePromotion()
    end)
    table.insert(movePoint, callFunc)
    local delay = cc.DelayTime:create(0.02)
    table.insert(movePoint, delay)
    local remove = cc.RemoveSelf:create(true)
    table.insert(movePoint, remove)
    local seq = cc.Sequence:create(movePoint)
    headBg:runAction(seq)
end

-- 更新晋级赛数据
function GodWarView:updatePromotion()
    -- self:getWarDataById()
    local war = self._godWarModel:getWarTuData()
    dump(war)
    for i=1,8 do
        local proData = promotionTab[i]
        self:updatePowData(proData, i, false)
    end
end

function GodWarView:getWeekly()
    local godWarConstData = self._userModel:getGodWarConstData()
    local fSeaTime = godWarConstData.RACE_BEG
    local weekly = false
    if fSeaTime ~= 0 then
        weekly = true
    end
    return weekly
end

function GodWarView:updateDirectHint(powData)
    if powData and powData.stake == 0 then
        self._directTip:setVisible(true)
    else
        self._directTip:setVisible(false)
    end
end


-- function GodWarView:getPromotionId()
--     local weekly = self:getWeekly()
--     if weekly == false then
--         return 0
--     end
--     local playId = 1
--     local curServerTime = self._userModel:getCurServerTime()
--     local weekday = tonumber(TimeUtils.date("%w", curServerTime))
--     if weekday == 3 then
--         local tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))

--     elseif weekday == 4 then
--         --todo
--     end
-- end

function GodWarView:updatePowData(proData, stateId, move)
    print('stateId============', stateId)
    if (not stateId) or (stateId > 8) then
        return
    end
    local chakan = self:getUI("bg.layer3.powtu.chakan" .. stateId)
    local tipLabBg = self:getUI("bg.layer3.powtu.tipLabBg" .. stateId)
    local tipLab = self:getUI("bg.layer3.powtu.tipLabBg" .. stateId .. ".tipLab")
    local powtu = self:getUI("bg.layer3.powtu")
    if not tipLabBg then
        return
    end
    local fightAnim = tipLabBg:getChildByFullName("fightAnim")
    local readyAnim = tipLabBg:getChildByFullName("readyAnim")
    if fightAnim then
        fightAnim:removeFromParent()
    end
    if readyAnim then
        readyAnim:removeFromParent()
    end
    local state = self:getGodwarPowData(stateId)
    local fireAnim = 3
    print("==state=====++++++++++======",stateId, state, move)
    local noWin = false 
    if state == 1 then -- 备战中
        if chakan then
            chakan:setVisible(false)
        end
        if tipLabBg then
            tipLabBg:setVisible(false)
        end
        fireAnim = 3
    elseif state == 2 then -- 即将开始
        if chakan then
            chakan:setVisible(false)
        end
        if tipLabBg then
            tipLabBg:setVisible(true)
        end
        if tipLab then
            tipLab:setString("备战中")
            tipLab:setColor(cc.c3b(39,247,58))
            tipLab:enableOutline(cc.c4b(60,30,10,255), 1)
        end
        readyAnim = mcMgr:createViewMC("beizhan_godwar", true, false)
        readyAnim:setPosition(tipLab:getPositionX(), tipLab:getPositionY()+30)
        readyAnim:setName("readyAnim")
        readyAnim:setScale(1.5)
        tipLabBg:addChild(readyAnim, 10)
        fireAnim = 3
    elseif state == 3 then -- 交战中
        if chakan then
            chakan:setVisible(false)
        end
        if tipLabBg then
            tipLabBg:setVisible(true)
        end
        if tipLab then
            tipLab:setString("激战中")
            tipLab:setColor(cc.c3b(39,247,58))
            tipLab:enableOutline(cc.c4b(60,30,10,255), 1)
        end
        fightAnim = mcMgr:createViewMC("shangfangjian_godwar", true, false)
        fightAnim:setPosition(tipLab:getPositionX(), tipLab:getPositionY()+40)
        fightAnim:setName("fightAnim")
        tipLabBg:addChild(fightAnim, 10)
        fireAnim = 1
        noWin = true
        -- TODO 上阵界面没消失就消失
            
    elseif state == 4 then -- 已结束
        if chakan then
            chakan:setVisible(true)
        end
        if tipLabBg then
            tipLabBg:setVisible(false)
        end
        fireAnim = 3
    end

    -- if tipLabBg then
    --     -- 时间到了点击可以进入直播界面
    --     self:registerClickEvent(tipLabBg, function()
    --         print("stateId=========", stateId)
    --         -- self:showWatchTV()
    --     end)
    -- end

    local powData = self._godWarModel:getPowData()
    if powData and powData[stateId] then
        -- dump(powData[stateId])
        powData = powData[stateId]
        if fireAnim == 2 then
            -- local indexId = proData[1]
            -- if powData.win == 1 then
            --     indexId = proData[1]
            -- elseif powData.win == 2 then
            --     indexId = proData[2]
            -- end
            -- -- local warData = war[indexId]
            -- -- self:updateRelationAnim(indexId, fireNum)
            -- local headBg = self:getUI("bg.layer3.powtu.headBg" .. indexId)
            -- self:setMoveAnim(headBg, indexId, proData)
            -- self:updateHeroAnim(headBg, stateId, indexId)
        else
            if stateId ~= 8 then
                for i=1,2 do -- 动画
                    local indexId = proData[i]
                    self:updateRelationAnim(indexId, fireAnim)
                end
            end
        end
        if move == true then
            local indexId = 0
            if powData.win == 1 then
                indexId = proData[1]
            elseif powData.win == 2 then
                indexId = proData[2]
            end
            if indexId ~= 0 then
                local headBg = self:getUI("bg.layer3.powtu.headBg" .. indexId)
                self:setMoveAnim(headBg, indexId, proData, stateId)
                return
            end
        end
    end


    local war = self._godWarModel:getWarTuData()
    local xian = self._godWarModel:getWarXianTuData()
    local winData = self._godWarModel:getWarWinData()
    -- dump(war)


    local lineType = 0
    for i=1,2 do
        local indexId = i + (stateId-1)*2
        if xian[indexId][1] ~= 0 and xian[indexId][2] == 1 then
            lineType = xian[indexId][1]
        end
    end
    -- lineType = 2
    -- winData[proData[i]]
    -- print("=+666666666666666666=========", stateId, lineType)

    -- 特效位置
    local verticalMc = self._powLine[stateId]
    local tverticalTab = GodWarUtil.powLineTab
    local verticalTab = tverticalTab[stateId*10+lineType]
    if verticalMc then
        if lineType == 1 then
            if stateId == 7 then
                self._powLine[8]:setVisible(true)
            end
            verticalMc:setPosition(verticalTab.posx, verticalTab.posy)
            verticalMc:setRotation(verticalTab.rotation)
            verticalMc:setVisible(true)
            if verticalTab.flip == -1 then
                verticalMc:setScaleX(-1)
            else
                verticalMc:setScaleX(1)
            end
        elseif lineType == 2 then
            if stateId == 7 then
                self._powLine[8]:setVisible(true)
            end
            verticalMc:setPosition(verticalTab.posx, verticalTab.posy)
            verticalMc:setRotation(verticalTab.rotation)
            verticalMc:setVisible(true)
            if verticalTab.flip == -1 then
                verticalMc:setScaleX(-1)
            else
                verticalMc:setScaleX(1)
            end
        else
            self._powLine[8]:setVisible(false)
            verticalMc:setVisible(false)
        end
    end

    -- local lineType = xian[indexId][1]
    -- print("indexId=======", indexId, showLine, lineType)
    -- if vertical then
    --     vertical:setVisible(false)
    -- end
    -- if lineType ~= 0 then
    --     vertical:setVisible(true)
    --     if lineType == 1 then
    --     elseif lineType == 2 then
    --         vertical:setVisible(true)
    --     end
    --     -- if resultImg then
    --     --     resultImg:setVisible(false)
    --     -- end
    -- end
    local tNum = 3
    if stateId == 8 then
        tNum = 2
        if tipLabBg then
            tipLabBg:setVisible(false)
        end
    end
    dump(proData)
    for i=1,tNum do
        local indexId = proData[i]
        local warData = war[indexId]
        self:updateRelationshipImg(indexId, war, xian, winData, state)
    end
end

function GodWarView:updateRelationAnim(indexId, stateId)
    -- print("indexId===", indexId)
    local headBg = self:getUI("bg.layer3.powtu.headBg" .. indexId)
    self:updateHeroAnim(headBg, stateId, indexId)
end

-- 备战中 1
-- 即将开始 2
-- 交战中 3
-- 已结束 4
function GodWarView:getGodwarPowData(indexId)
    local round = indexId
    local pow = 8
    if indexId > 6 then
        round = 1
        pow = 2
    elseif indexId > 4 then
        round = indexId - 4
        pow = 4
    end
    local war = self._godWarModel:getWarDataById(pow)
    if not war then
        return 1
    end
    local warData = war[tostring(round)]
    local flag = self:getGodWarPowState(pow, round)
    print("flag========", flag)
    local state = 4
    if flag == 0 then
        state = 1
    elseif flag == 1 then
        state = 2
    elseif flag == 2 then
        state = 3
    elseif flag == 3 then
        state = 4
    end
    print("state--------", state)
    return state, round
end

-- 0,1,2,3
function GodWarView:getGodWarPowState(powId, round)
    print("getGodWarPowS====66666666666666===", powId, round)
    local state = 0
    local godWarConstData = self._userModel:getGodWarConstData()
    local curServerTime = self._userModel:getCurServerTime()
    local begTime = godWarConstData["RACE_BEG"]
    local endTime = godWarConstData["RACE_END"]
    -- if curServerTime >= begTime and curServerTime <= endTime then
    if begTime ~= 0 then
        local weekday = tonumber(TimeUtils.date("%w", curServerTime))
        if weekday == 3 then
            if powId == 8 then
                local middleTime = readlyTime + fightTime*3
                local baseTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
                local tempTime1 = baseTime + (round-1)*middleTime
                local tempTime2 = baseTime + (round-1)*middleTime + readlyTime
                if round == 1 then
                    tempTime1 = tempTime1 - 1800
                end   
                local tempTime3 = baseTime + middleTime*round
                if curServerTime >= tempTime1 and curServerTime <= tempTime2 then
                    state = 1
                elseif curServerTime >= tempTime2 and curServerTime <= tempTime3 then
                    state = 2
                elseif curServerTime >= tempTime3 then
                    state = 3
                end
            end
        elseif weekday == 4 then
            if powId == 4 then
                local middleTime = readlyTime + fightTime*3
                local baseTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
                local tempTime1 = baseTime + (round-1)*middleTime
                local tempTime2 = baseTime + (round-1)*middleTime + readlyTime
                if round == 1 then
                    tempTime1 = tempTime1 - 1800
                end   
                local tempTime3 = baseTime + middleTime*round
                if curServerTime >= tempTime1 and curServerTime <= tempTime2 then
                    state = 1
                elseif curServerTime >= tempTime2 and curServerTime <= tempTime3 then
                    state = 2
                elseif curServerTime >= tempTime3 then
                    state = 3
                end
--            elseif powId == 3 then
 --               local readlyTime = 300
 --               local middleTime = readlyTime + fightTime*3
 --               local baseTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:18:00"))
 --               local tempTime1 = baseTime
 --               local tempTime2 = baseTime + readlyTime
 --               local tempTime3 = baseTime + middleTime
--
 --               if curServerTime >= tempTime1 and curServerTime <= tempTime2 then
 --                   state = 1
 --               elseif curServerTime >= tempTime2 and curServerTime <= tempTime3 then
 --                   state = 2
 --               elseif curServerTime >= tempTime3 then
 --                   state = 3
 --               end
            elseif powId == 2 then
                local readlyTime = 300
                local middleTime = readlyTime + fightTime*3
                local baseTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:18:00"))
                local tempTime1 = baseTime
                local tempTime2 = baseTime + readlyTime
                local tempTime3 = baseTime + middleTime

                if curServerTime >= tempTime1 and curServerTime <= tempTime2 then
                    state = 1
                elseif curServerTime >= tempTime2 and curServerTime <= tempTime3 then
                    state = 2
                elseif curServerTime >= tempTime3 then
                    state = 3
                end
            else
                state = 3
            end
        elseif weekday == 2 then
            state = 0
        else
            state = 3
        end
    else
        state = 4
    end
    print("getGodWarPowS=======", state)

    return state
end

function GodWarView:getPowBattle(powId, round)
    print("round==========", round)
    self._serverMgr:sendMsg("GodWarServer", "getPowBattle", {}, true, {}, function (result)
        -- dump(result, "result ===", 5)
        -- self._godWarModel:progressWarData()
        -- local round, ju = self:getStrPower(8)
        -- print("roudAnimRound=", round, self._oldAnimRound)
        -- if round ~= self._oldAnimRound then
        --     if powId then
        --         local tround = self._oldAnimRound
        --         if powId == 4 then
        --             tround = 4 + self._oldAnimRound
        --         elseif powId == 2 then
        --             tround = 7
        --         end
        --         local proData = promotionTab[tround]
        --         self:updatePowData(proData, self._oldAnimRound, true)
        --     end
        -- end
    end)
end

function GodWarView:createLine()
    self._powLine = {}
    local powtu = self:getUI("bg.layer3.powtu")

    for i=1,7 do
        local str = "xian1_xiantexiao"
        if i <= 4 then
            str = "xian1_xiantexiao"
        elseif i <= 6 then
            str = "xian2_xiantexiao"
        else
            str = "xian3_xiantexiao"
        end
        local tline = mcMgr:createViewMC(str, true, false)
        tline:setName("tline")
        powtu:addChild(tline)
        self._powLine[i] = tline
    end
    local tline = mcMgr:createViewMC("guanjun_xiantexiao", true, false)
    tline:setScale(0.96)
    tline:setPosition(484, 414)
    tline:setName("tline")
    powtu:addChild(tline)
    self._powLine[8] = tline
end

function GodWarView:onInit()
    self._userModel = self._modelMgr:getModel("UserModel")
    self._godWarModel = self._modelMgr:getModel("GodWarModel")
    self._formationModel = self._modelMgr:getModel("FormationModel")
    self._xiaozu = false
    self._zhengba = false
    self._guanjun = false
    self._countDown = true
    self._selectpow = 1
    self._isHaveFormationView = false
    self._animRound = 1
    self._cumTime = 0 
    self._formationView = nil

    self._ju = 1
    self._pow = 8

    self._godWarModel:setShowRed(true)
    local groupId = self._godWarModel:getMyGroup()
    print("groupId=============", groupId)
    self._currentGroup = groupId
    self._groupFrist = true

    local saveBtn = self:getUI("bg.saveBtn7")
    saveBtn:setTitleText("打印数据")
    -- saveBtn:setVisible(true)
    self:registerClickEvent(saveBtn, function()
        -- local xian = self._godWarModel:getWarXianTuData()
        -- dump(xian)
        -- self:updatePromotion()
        local param1 = {powId = 2, callback = callback}
        UIUtils:reloadLuaFile("godwar.GodWarResultDialog")
        self._viewMgr:showDialog("godwar.GodWarResultDialog", param1)

    end)
    self:createLine()
    self._userid = self._userModel:getData()._id

-- title
    local godWarConstData = self._userModel:getGodWarConstData()
    local season = tonumber(godWarConstData["SEASON"]) or 1
    local title = self:getUI("titleBg.title")
    UIUtils:setTitleFormat(title, 1)
    local titleStr = "第" .. season .. "届 诸神之战"
    title:setString(titleStr)
    local num1 = self:getUI("bg.layer3.powtu.titleBg.seasonBg.num1")
    local num2 = self:getUI("bg.layer3.powtu.titleBg.seasonBg.num2")
    num2:setVisible(true)
    if season < 10 then
        num2:setVisible(false)
        local tn1 = tonumber(season)
        num1:loadTexture(GodWarUtil.numbers[tn1], 1)
    else
        num2:setVisible(true)
        local tn1 = math.floor(season/10)
        local tn2 = math.fmod(season, 10)
        num1:loadTexture(GodWarUtil.numbers[tn1], 1)
        num2:loadTexture(GodWarUtil.numbers[tn2], 1)
        num1:setScale(0.8)
        num2:setScale(0.8)
        local seasonBg = self:getUI("bg.layer3.powtu.titleBg.seasonBg")
        local posX = (seasonBg:getContentSize().width - num1:getContentSize().width*num1:getScaleX() - num2:getContentSize().width*num2:getScaleX())*0.5-2
        num1:setPositionX(posX)
        posX = posX + num1:getContentSize().width*num1:getScaleX()
        num2:setPositionX(posX)
    end

    -- 直播
    local zhibo = self:getUI("zhiboBg.zhibo")
    local zhiboBg = self:getUI("zhiboBg")

    local zhiboAnim = mcMgr:createViewMC("zhibo_godwar", true, false)
    zhiboAnim:setPosition(zhibo:getContentSize().width*0.5+2, zhibo:getContentSize().height*0.5+2)
    zhiboAnim:setScale(1.2)
    zhiboAnim:setName("zhiboAnim")
    zhiboAnim:setVisible(false)
    zhibo:addChild(zhiboAnim, -1)
    zhibo.zhiboAnim = zhiboAnim
    self._zhiboAnim = zhiboAnim

    self:updateBuff()

    local curServerTime = self._userModel:getCurServerTime()
    local begTime = godWarConstData.RACE_BEG
    local callFunc = cc.CallFunc:create(function()
        local curServerTime = self._userModel:getCurServerTime()
        local weekday = tonumber(TimeUtils.date("%w", curServerTime))
        if weekday == 3 then
            local tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
            local ttime = curServerTime - tempTime
            if ttime > 0 then
                local roundTime = readlyTime + fightTime*3
                local ptime = math.fmod(ttime, roundTime)
                if ptime > readlyTime then
                    self._zhiboAnim:setVisible(true)
                else
                    self._zhiboAnim:setVisible(false)
                end
                local hinttime = math.fmod(ttime, roundTime)
                if hinttime < readlyTime then
                    local powData = self:getNowBattleData()
                    self:updateDirectHint(powData)
                else
                    self:updateDirectHint()
                end
            else
                local powData = self:getNowBattleData()
                self:updateDirectHint(powData)
            end
        elseif weekday == 4 then
            local tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
            local tempTime1 = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:18:00"))
            local tempTime2 = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:23:00"))
            if curServerTime > tempTime then
                if curServerTime > tempTime1 and curServerTime < tempTime2 then
                    self._zhiboAnim:setVisible(false)
                    local powData = self:getNowBattleData()
                    self:updateDirectHint(powData)
                else
                    local readlyTime = readlyTime
                    local roundTime = readlyTime + fightTime*3
                    local ttime = curServerTime - tempTime
                    if self._pow == 2 then
                        readlyTime = 300
                        ttime = ttime - 1080
                    end
                    if ttime > 0 then
                        local ptime = math.fmod(ttime, roundTime)
                        if ptime > readlyTime then
                            self._zhiboAnim:setVisible(true)
                        else
                            self._zhiboAnim:setVisible(false)
                        end
                    end
                    local hinttime = math.fmod(ttime, roundTime)
                    if hinttime < readlyTime then
                        local powData = self:getNowBattleData()
                        self:updateDirectHint(powData)
                    else
                        self:updateDirectHint()
                    end
                end
            end
        end
    end)
    local seq = cc.Sequence:create(callFunc, cc.DelayTime:create(1))
    if begTime ~= 0 then
        self._zhiboAnim:runAction(cc.RepeatForever:create(seq))
    end

    local btnNameTip = cc.Sprite:createWithSpriteFrameName("globalImageUI_bag_keyihecheng.png")
    btnNameTip:setName("btnNameTip")
    btnNameTip:setAnchorPoint(cc.p(0,0))
    btnNameTip:setPosition(cc.p(zhiboBg:getContentSize().width - 26, 55))
    zhiboBg:addChild(btnNameTip, 10)
    btnNameTip:setVisible(false)
    self._directTip = btnNameTip
    self._zhibo = zhiboBg
    self._zhibo:setVisible(false)
    self:registerClickEvent(zhibo, function()
        self:watchTV()
    end)


    local buzhenBtn = self:getUI("btnbg.buzhenBtn")
    local mc1 = mcMgr:createViewMC("buzhenanniu_godwar", true, false)
    mc1:setPosition(buzhenBtn:getContentSize().width*0.5, buzhenBtn:getContentSize().height*0.5)
    mc1:setName("mc1")
    buzhenBtn:addChild(mc1)
    buzhenBtn.formationAnim = mc1
    buzhenBtn:setVisible(false)

    local callFunc = cc.CallFunc:create(function()
        local state = self:isShowFormation()
        buzhenBtn:setVisible(true)
        if state == 0 then
            buzhenBtn:setVisible(false)
        end
    end)
    local seq = cc.Sequence:create(callFunc, cc.DelayTime:create(1))
    if begTime ~= 0 then
        buzhenBtn.formationAnim:runAction(cc.RepeatForever:create(seq))
    end
    -- self:registerScriptHandler(function(eventType)
    --     if eventType == "exit" then 
    --         self:onExit()
    --     end
    -- end)

    self:initLayer()
    self:getGodWarTitle()
    self:setBtn()
    self:checkTips()
    self:closeAction()

    self:listenReflash("GodWarModel", self.reflashBattleTime)
    self:reflashBattleTime()
end

-- function GodWarView:getNowStrPower()
--     local powId, round, ju = 0, 0, 0
--     local curServerTime = self._userModel:getCurServerTime()
--     local godwarConst = self._userModel:getGodWarConstData()
--     local begTime = godwarConst.RACE_BEG
--     if begTime ~= 0 then
--         local weekday = tonumber(TimeUtils.date("%w", curServerTime))
--         local beginBattle = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
--         if weekday == 2 then
            
--         elseif weekday == 3 then
--             --todo
--         elseif weekday == 4 then
--             --todo
--         end
--     end
--     if powerId == 32 then
--         local beginBattle = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00")) - 3
--         local allTime = curServerTime - beginBattle + 3
--         ju = math.floor(allTime/jiange)
--         round = math.floor(ju/3)
--         ju = ju - round*3 + 1
--         round = round + 1
--     elseif powerId == 8 then
--         local beginBattle = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00")) - 3
--         local allTime = curServerTime - beginBattle + 3
--         print("=allTime========", allTime, jiange)
--         ju = math.floor(allTime/jiange)
--         round = math.floor(ju/3)
--         -- print("==getStrPower=====",ju, round)
--         ju = ju - round*3 + 1
--         round = round + 1
--         if curServerTime < beginBattle then
--             round = 1
--             ju = 1
--         end
--     elseif powerId == 4 then
--         local beginBattle = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00")) - 3
--         local allTime = curServerTime - beginBattle + 3
--         ju = math.floor(allTime/jiange)
--         -- print("===========", allTime, jiange)
--         round = math.floor(ju/3)
--         ju = ju - round*3 + 1
--         round = round + 1
--         if curServerTime < beginBattle then
--             round = 1
--             ju = 1
--         end
--         -- print("===round========", round, ju)
--     elseif powerId == 2 then
--         local beginBattle = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:40:00")) - 3
--         local allTime = curServerTime - beginBattle + 3
--         ju = math.floor(allTime/jiange) + 1
--         round = 1
--     end
--     return round, ju
-- end

function GodWarView:closeAction()
    local godWarConstData = self._userModel:getGodWarConstData()
    local begTime = godWarConstData.RACE_BEG
    local curServerTime = self._userModel:getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", curServerTime))
    local tempCloseTime = 0
    if weekday == 0 then
        tempCloseTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 23:59:59"))
    elseif weekday == 1 then
        tempCloseTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 00:00:01"))
    end
    local callFunc = cc.CallFunc:create(function()
        local curServerTime = self._userModel:getCurServerTime()
        local tTime = curServerTime - tempCloseTime
        if tTime > 0 then
            local viewMgr = ViewManager:getInstance()
            viewMgr:returnMain()
        end
    end)
    local closeAction = self:getUI("titleBg.Image_245_1_0")
    local seq = cc.Sequence:create(callFunc, cc.DelayTime:create(1))
    if begTime == 0 and weekday == 0 then
        closeAction:stopAllActions()
        closeAction:runAction(cc.RepeatForever:create(seq))
    elseif begTime ~= 0 and weekday == 1 then
        local tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 11:00:00"))
        if curServerTime < tempTime then
            closeAction:stopAllActions()
            closeAction:runAction(cc.RepeatForever:create(seq))
        end
    end
end

function GodWarView:onHide()
    local closeAction = self:getUI("titleBg.Image_245_1_0")
    closeAction:stopAllActions()
end

-- -- 单双周判定
-- function GodWarView:checkTime()
--     local godwarConst = self._userModel:getGodWarConstData()
--     local curServerTime = self._userModel:getCurServerTime()
--     local raceBeg = godwarConst.RACE_BEG
--     local weekday = tonumber(TimeUtils.date("%w", curServerTime))
--     if weekday == 0 then
--         weekday = 7
--     end
--     local isWeekly = self:getWeekly()
--     local tcurServerTime = curServerTime - (weekday-1)*86400
--     local starTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(tcurServerTime,"%Y-%m-%d 00:00:00"))
--     print("tcurServerTime===",starTime, weekday)
--     if raceBeg == 0 then -- 预告周
--         self._weekly = 1
--         self._powId = 0
--     else            -- 比赛周
--         self._weekly = 2
--         self._gwState = 0
--         if weekday == 3 then
            
--         elseif weekday == 4 then
            
--         end
--     end

-- end

-- function GodWarView:onExit()
--     print("onExit=============")
--     if self._updateId then
--         ScheduleMgr:unregSchedule(self._updateId)
--         self._updateId = nil
--     end
-- end

function GodWarView:showWatchTV()
    local zhiboBg = self:getUI("zhiboBg")
    local curServerTime = self._userModel:getCurServerTime()
    local begTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 19:30:00"))
    local ttime = begTime - curServerTime
    local callFunc = cc.CallFunc:create(function()
        local curServerTime = self._userModel:getCurServerTime()
        local subTime = begTime - curServerTime
        if subTime <= 0 then
            local flag = self:getShowFightDialog()
            if flag == true then
                self:watchTV()
                zhiboBg:stopAllActions()
            end
        end
    end)
    local seq = cc.Sequence:create(callFunc, cc.DelayTime:create(1))
    if ttime > 0 then
        local weekday = tonumber(TimeUtils.date("%w", curServerTime))
        if weekday == 3 or weekday == 4 then
            zhiboBg:runAction(cc.RepeatForever:create(seq))
        end
    else
        local flag = self:getShowFightDialog()
        if flag == true then
            self:watchTV()
        end
    end
end

function GodWarView:onAnimEnd()
    local showGuide = self._godWarModel:getShowGuide()
    local callback = function()
        local flag = self:getShowFightDialog()
        if flag == true then
            self:showWatchTV() -- 支持
        else
            self:showWatchTV()
            self:showResultDialog() -- 结果
        end
    end
    if showGuide == true then -- 引导
        local param = {callback = callback}
        self._viewMgr:showDialog("godwar.GodWarShowTuDialog", param, true)
    else
        callback()
    end
    -- local triggerFlag = self._viewMgr:doTriggerByName("1001")
    print("=triggerFlag=========", triggerFlag)
end

function GodWarView:showResultDialog()
    local showtype = self._godWarModel:getGodWarShowDialogType()
    if showtype ~= 0 then
        self:showGodWarResultDialog(showtype)
    else
        local worType = self._godWarModel:getWorShipType()
    print("showtype=====++++++++++=====", worType)
        if worType == true then
            self._viewMgr:showDialog("godwar.GodWarWorshipNumDialog", {}, true)
        end
    end
end

function GodWarView:onShow()

end

function GodWarView:getShowFightDialog()
    local curServerTime = self._userModel:getCurServerTime()
    local godwarConst = self._userModel:getGodWarConstData()
    local flag = false
    local begTime = godwarConst.RACE_BEG
    local endTime = godwarConst.RACE_END
    if curServerTime >= begTime and curServerTime <= endTime then
        local weekday = tonumber(TimeUtils.date("%w", curServerTime))
        local minTime, maxTime = 0, 0
        if weekday == 3 then
            minTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 19:30:01"))
            maxTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:36:00"))
            if curServerTime >= minTime and curServerTime <= maxTime then
                self._pow = 8
            end
        elseif weekday == 4 then
            minTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 19:30:01"))
            maxTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:29:00"))
            tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:18:00"))
            
            if curServerTime >= minTime and curServerTime <= tempTime then
                self._pow = 4
            elseif curServerTime >= tempTime and curServerTime <= maxTime then
                self._pow = 2
            end
        end
        if curServerTime >= minTime and curServerTime <= maxTime then
            flag = true
        end
    end
    print("flag==howFightDi=====", flag)
    return flag
end


function GodWarView:reflashUI()
    self:updateLayerState()
end

--[[
    4, 7 3冠军展示
    3, 6 争霸展示
    3, 5 争霸展示
    3, 4 争霸展示
    2, 3 小组展示
    2, 2 小组展示
    5, 1 周一到周二
    1, 8 1冠军展示
--]]
function GodWarView:updateLayerState()
    local layerNum, state = self:getLayerState()
    print("layerNum, state=========", layerNum, state)
    self:showViewLayer(layerNum)
    self:showBtnLayer(state)
    self:updateRightBtnPanel(state)
end


function GodWarView:getLayerState()
    local state, indexId = self._godWarModel:getStatus()
    -- local godWarConstData = self._userModel:getGodWarConstData()
    -- local season = godWarConstData.SEASON
    -- local win = godWarConstData.SEASON

    local warMatchTime = self._godWarModel:getGodWarMatchTime()
    local warMatchData = warMatchTime[indexId]
    -- dump(warMatchData, "=godWarConstData======")
    print("==statstateus====", state, indexId)
    local layerNum = 5
    if state == 7 then
        layerNum = 4
    elseif state == 8 then
        layerNum = 1
    elseif state == 3 or state == 2 then
        layerNum = 2
    elseif state == 4 or state == 5 or state == 6 then
        layerNum = 3
    -- elseif state == 2 then
    --     layerNum = 5
    end
    print("==status====", layerNum, state)
    return layerNum, state, indexId
end



-- 1 赛程预告
-- 2 小组赛
-- 3 8强争霸
-- 4 冠军展示
-- 5 第一赛季预告
-- 6 待定
-- 
function GodWarView:showViewLayer(typeId)
    for i=1,5 do
        local layer = self:getUI("bg.layer" .. i)
        layer:setVisible(false)
    end
    if self._promotionBg then
        self._promotionBg:setVisible(false)
    end
    local titleBg = self:getUI("titleBg")
    titleBg:setVisible(true)
    self["updateLayer" .. typeId](self)
end

function GodWarView:updateLayer1()
    print("updateLayer1=========")
    self:setBtnAnim(self._selectpow, false)
    self._selectpow = 3
    self:setBtnAnim(self._selectpow, true)
    local layer1 = self:getUI("bg.layer1")
    self:updateSaiChengLayer(layer1, true)
    self:showHeroWin()
    layer1:setVisible(true)
end

-- 小组赛
function GodWarView:updateLayer2()
    print("updateLayer2=========")
    self:setBtnAnim(self._selectpow, false)
    self._selectpow = 1
    self:setBtnAnim(self._selectpow, true)
    local layer2 = self:getUI("bg.layer2")
    layer2:setVisible(true) 
    self:addScrollView()
    self:updateScrollView()
    if self._groupFrist == true then
        self:scrollToNext(self._currentGroup)
        self._groupFrist = false
    end
end

-- 晋级赛
function GodWarView:updateLayer3()
    -- if not flag then
    --     return
    -- end
    if not self._promotionBg then
        local bg = self:getUI("bg")
        local promotionBg = cc.Sprite:create("asset/bg/bg_godwar_012.jpg")
        promotionBg:setPosition(bg:getContentSize().width*0.5, bg:getContentSize().height*0.5)
        promotionBg:setScale(1136/1022)
        bg:addChild(promotionBg, -1)
        self._promotionBg = promotionBg
    else
        self._promotionBg:setVisible(true)
    end
    local titleBg = self:getUI("titleBg")
    titleBg:setVisible(false)
    print("updateLayer3=========")
    self:setBtnAnim(self._selectpow, false)
    self._selectpow = 2
    self:setBtnAnim(self._selectpow, true)
    local layer3 = self:getUI("bg.layer3")
    layer3:setVisible(true)
    self:updatePromotion()
end

function GodWarView:updateLayer4()
    print("updateLayer4=========")
    local layer4 = self:getUI("bg.layer4")
    layer4:setVisible(true)
    self:setBtnAnim(self._selectpow, false)
    self._selectpow = 3
    self:setBtnAnim(self._selectpow, true)
    local data = self._godWarModel:getDispersedData()
    for i=1,3 do
        local firstData = data["r" .. i]
        if not firstData then
            return
        end
        local userId = firstData["rid"]
        local skin = firstData["skin"]
        local playerData = self._godWarModel:getPlayerById(userId)
        if not playerData then
            break
        end
        local heroBg = self:getUI("bg.layer4.rank" .. i)
        if heroBg.heroArt then
            heroBg.heroArt:removeFromParent()
        end
        local heroD = tab:Hero(playerData.hId)
        local heroArt = heroD["heroart"]
        if skin and skin ~= 0  then
            local heroSkinD = tab.heroSkin[skin]
            heroArt = heroSkinD["heroart"] or heroD["heroart"]
        end
        heroBg.heroArt = mcMgr:createViewMC("stop_" .. heroArt, true, false)
        heroBg.heroArt:setPosition(130, 180)
        heroBg.heroArt:setName("heroArt")
        heroBg:addChild(heroBg.heroArt, 20)

        local tname = self:getUI("bg.layer4.rank" .. i .. ".name")
        tname:setString(playerData.name)

        if heroBg.guanjunFightLab then
            local guanjunFightLab = heroBg.guanjunFightLab
            local tishi = self:getUI("bg.layer4.rank" .. i .. ".tishi")
            guanjunFightLab:setString(playerData.score)
            local posX = heroBg:getContentSize().width-tishi:getContentSize().width-guanjunFightLab:getContentSize().width*guanjunFightLab:getScaleX()
            posX = posX*0.5
            tishi:setPositionX(posX)
            posX = posX + tishi:getContentSize().width
            guanjunFightLab:setPosition(posX, tishi:getPositionY())
        end
        -- local fightScore = self:getUI("bg.layer4.rank" .. i .. ".fightScore")
        -- fightScore:setString(playerData.score)

        self:registerClickEvent(heroBg, function()
            local data = {tagId = userId, fid = 101}
            self:getTargetUserBattleInfo(data)
        end)
    end
end

function GodWarView:updateLayer5()
    self:setBtnAnim(self._selectpow, false)
    self._selectpow = 3
    self:setBtnAnim(self._selectpow, true)
    local layer5 = self:getUI("bg.layer5")
    self:updateSaiChengLayer(layer5, false)
    layer5:setVisible(true)
end

-- layer 1 & 5
function GodWarView:updateSaiChengLayer(inView, showEnd)
    local state, staIndexId = self._godWarModel:getStatus()
    print("state, staIndexId======", state, staIndexId)
    local warMatchTime = self._godWarModel:getGodWarMatchTime()
    local warMatchData = warMatchTime[staIndexId]
    local curServerTime = self._userModel:getCurServerTime()

    local titleLab = inView:getChildByName("titleLab")
    local leftAdorn = inView:getChildByName("leftAdorn")
    if leftAdorn ~= nil then
        leftAdorn:setPositionX(titleLab:getPositionX() - titleLab:getContentSize().width * 0.5 - 30)
    end
    local rightAdorn = inView:getChildByName("rightAdorn")
    if rightAdorn ~= nil then
        rightAdorn:setPositionX(titleLab:getPositionX() + titleLab:getContentSize().width * 0.5 + 30)
    end

    for i=1,6 do
        local anpai = inView:getChildByFullName("anpai" .. i) 
        local jinxing = anpai:getChildByFullName("jinxing")
        local jieshu = anpai:getChildByFullName("jieshu")
        jieshu:setVisible(false)
        local weekdey = anpai:getChildByFullName("weekdey")
        local time = anpai:getChildByFullName("time")
        local pname = anpai:getChildByFullName("pname")

        time:setString(lang("GODWARTIME_" .. i))
        pname:setString(lang("GODWARPART_" .. i))
        weekdey:setString(lang("GODWARDATE_" .. i))

        local flag = 1
        if state > i then
            flag = 4
        elseif state == i then
            if state == 1 then
                flag = 3
            elseif state == 2 then
                flag = 3
            else
                if warMatchData[4] == 0 then
                    flag = 2
                elseif warMatchData[4] == 1 then
                    if curServerTime > warMatchData[2] then
                        flag = 3
                    else
                        flag = 2
                    end
                else
                    flag = 4
                end
            end
        end
        print("============state=======", flag)
        if flag == 2 then -- 即将开始
            jieshu:setVisible(false)
            jinxing:setColor(cc.c3b(255,238,160))
            jinxing:setString("(即将开始)")
            jinxing:setVisible(true)
        elseif flag == 3 then -- 正在进行
            jieshu:setVisible(false)
            jinxing:setVisible(true)
            jinxing:setColor(cc.c3b(28,162,22))
            jinxing:setString("(正在进行)")
            local jinxingzhong = anpai:getChildByName("jinxingzhong")
            if not jinxingzhong then
                jinxingzhong = mcMgr:createViewMC("jinxingzhong_guanjundansheng", true, false)
                jinxingzhong:setPosition(anpai:getContentSize().width*0.5-2, anpai:getContentSize().height*0.5+1)
                jinxingzhong:setName("jinxingzhong")
                anpai:addChild(jinxingzhong)
            end
            jinxingzhong:setVisible(true)
        elseif flag == 4 then -- 已结束
            jieshu:setVisible(true)
            jinxing:setVisible(false)
            local jinxingzhong = anpai:getChildByName("jinxingzhong")
            if jinxingzhong then
                jinxingzhong:setVisible(false)
            end
        else
            jieshu:setVisible(false)
            jinxing:setVisible(false)
        end
        if showEnd == true then
            jieshu:setVisible(false)
            jinxing:setVisible(false)
        end
    end
end

function GodWarView:showHeroWin()
    local data = self._godWarModel:getDispersedData()
    local firstData = data["r1"]
    if not firstData then
        return
    end
    local userId = firstData["rid"]
    local skin = firstData["skin"]
    local playerData = self._godWarModel:getPlayerById(userId)
    if not playerData then
        return
    end

    local heroBg = self:getUI("bg.layer1.guanjunBg")
    if heroBg.heroArt then
        heroBg.heroArt:removeFromParent()
    end
    local heroD = tab:Hero(playerData.hId)
    local heroArt = heroD["heroart"]
    if skin and skin ~= 0  then
        local heroSkinD = tab.heroSkin[skin]
        heroArt = heroSkinD["heroart"] or heroD["heroart"]
    end
    heroBg.heroArt = mcMgr:createViewMC("stop_" .. heroArt, true, false)
    heroBg.heroArt:setPosition(130, 178)
    heroBg.heroArt:setScale(0.9)
    heroBg.heroArt:setName("heroArt")
    heroBg:addChild(heroBg.heroArt, 20)

    local pname = self:getUI("bg.layer1.guanjunBg.name")
    pname:setString(playerData.name)

    local guanjunBg = self:getUI("bg.layer1.guanjunBg")
    if guanjunBg.guanjunFightLab then
        local guanjunFightLab = guanjunBg.guanjunFightLab
        local zhandoulitishi = self:getUI("bg.layer1.guanjunBg.zhandoulitishi")
        guanjunBg.guanjunFightLab:setString(playerData.score)
        local posX = guanjunBg:getContentSize().width-zhandoulitishi:getContentSize().width-guanjunFightLab:getContentSize().width*guanjunFightLab:getScaleX()
        posX = posX*0.5
        zhandoulitishi:setPositionX(posX)
        posX = posX + zhandoulitishi:getContentSize().width
        guanjunFightLab:setPosition(posX, 103)
    end

    local mobai = self:getUI("bg.layer1.guanjunBg.mobai")
    local dayinfo = self._modelMgr:getModel("PlayerTodayModel"):getDayInfo(53)
    if dayinfo == 1 then
        mobai:setSaturation(-100)
        if mobai.anim then
            mobai.anim:setVisible(false)
        end
        self:registerClickEvent(mobai, function()
            self._viewMgr:showTip("你已经膜拜过")
        end)
    else
        mobai:setSaturation(0)
        self:registerClickEvent(mobai, function()
            self:worshipChampion(1, true)
        end)
        if not mobai.anim then
            local mc1 = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true, false)
            mc1:setName("anim")
            mc1:setPosition(mobai:getContentSize().width*0.5, mobai:getContentSize().height*0.5+1)
            mobai:addChild(mc1, 1)
            mobai.anim = mc1
        else
            mobai.anim:setVisible(true)
        end
    end

    self:registerClickEvent(guanjunBg, function()
        local data = {tagId = userId, fid = 101}
        self:getTargetUserBattleInfo(data)
    end)
end


-- 小组赛界面滑动 layer2
    -- local LAYER_WIDTH, LAYER_HEIGHT = 315, 300
    function GodWarView:addScrollView()
        if self._addScroll == true then
            return
        end
        self._addScroll = true
        self._scrollView = cc.ScrollView:create() 
        self._scrollView:setViewSize(cc.size(1136, 640))
        self._scrollView:setDirection(0) --设置滚动方向
        self._scrollView:setBounceable(false)
        self._scrollView:setTouchEnabled(false)
        self._scrollView:setDelegate()
        self._scrollView:registerScriptHandler(function() return self:scrollViewDidScroll() end ,cc.SCROLLVIEW_SCRIPT_SCROLL)

        local layer2 = self:getUI("bg.layer2")
        if MAX_SCREEN_HEIGHT > 640 then
            self._scrollView:setAnchorPoint(cc.p(0,0))
        else
            self._scrollView:setAnchorPoint(cc.p(0,0.5))
        end
        local godwarWidth = MAX_SCREEN_WIDTH
        if godwarWidth > 1136 then
            godwarWidth = 1136
        end
        self._scrollView:setPosition(cc.p((1136-godwarWidth)*0.5+28,-20))
        self._scrollView:setScale(godwarWidth/1136)
        layer2:addChild(self._scrollView, 1)

        local tgroupPanel = self:getUI("groupPanel")
        local tempX = 540 
        self._scrollView:setContentSize(cc.size(1780, 640))
        self._groupLayer = {}
        for i=1,godWarGroupMax do
            local groupLayer = tgroupPanel:clone()
            groupLayer:setName("groupLayer" .. i)
            groupLayer:setAnchorPoint(cc.p(0.5,0.5))
            groupLayer:setPosition(tempX + 80*i, MAX_SCREEN_HEIGHT*0.5)
            groupLayer:setVisible(true)
            self._scrollView:addChild(groupLayer)
            self._groupLayer[i] = groupLayer

            local groupName = groupLayer:getChildByName("groupName")
            groupName:setString("第" .. i .. "小组")
            groupName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            self._groupLayer[i].groupName = groupName
            local groupBtn = groupLayer:getChildByName("groupBtn")
            self._groupLayer[i].groupBtn = groupBtn
            self:registerClickEvent(groupBtn, function()
                self:showFightDialg(i)
            end)

            self:registerClickEvent(groupLayer, function()
                self:showFightDialg(i)
            end)

            local offsetX
            local flag = false
            -- self:registerTouchEvent(groupLayer, function(_, _x, _y)
            --     groupLayer:setSwallowTouches(false)
            --     offsetX = _x
            --     flag = false
            --     if self._selectClick ~= true then
            --         self._selectClick = true
            --     end
            -- end, function(_, _x, _y)
            --     if math.abs(_x - offsetX) > 10 then
            --         flag = true
            --     end
            -- end, function(_, _x, _y)
            --     if flag == false then
            --         self:scrollViewToIndex(i)
            --     end
            --     self._selectClick = false
            -- end, function(_, _x, _y)
            --     self._selectClick = false
            --     -- groupLayer:setSwallowTouches(false)
            -- end)
            -- groupLayer:setSwallowTouches(false)

        end
        self._selectClick = false
        self:update(true)
        -- self._updateId = ScheduleMgr:regSchedule(1, self, function()
        --     self:update()
        -- end)

        self._isClick = false
        self._isClick1 = false
        self:registerTouchEvent(layer2, function()
            self._isClick = true
        end, moveCallback, function()
            self._isClick = false
        end, function()
            self._isClick = false
        end, nil)

        self:setHeadClick()
    end

    function GodWarView:showFightDialg(indexId)
        print("··groupBtn======", indexId)
        local curServerTime = self._userModel:getCurServerTime()
        local weekday = tonumber(TimeUtils.date("%w", curServerTime))
        local tTimeBeg = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
        local tTimeEnd = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:18:00"))
        -- 小组赛
        if weekday == 2 then
            if tTimeBeg <= curServerTime and tTimeEnd >= curServerTime then
                local cTime = curServerTime - tTimeBeg
                local paramD = {groupId = indexId, indexId = 1, callbackFight = function(reportID, winlose, showDraw)
                    self:reviewTheBattle(reportID, 2, winlose, showDraw)
                    -- self:getBattleReport(reportID)
                end}
                self._viewMgr:showDialog("godwar.GodWarFightDialog", paramD)
            else
                local paramD = {groupId = indexId, indexId = 1, callbackFight = function(reportID, winlose, showDraw)
                    self:reviewTheBattle(reportID, 2, winlose, showDraw)
                    -- self:getBattleReport(reportID)
                end}
                self._viewMgr:showDialog("godwar.GodWarFightDialog", paramD)
            end
        else
            local paramD = {groupId = indexId, indexId = 1, callbackFight = function(reportID, winlose, showDraw)
                self:reviewTheBattle(reportID, 2, winlose, showDraw)
                -- self:getBattleReport(reportID)
            end}
            self._viewMgr:showDialog("godwar.GodWarFightDialog", paramD)
        end
    end

    function GodWarView:update(flag)
        if flag ~= true then
            if self._isClick == self._isClick1 then
                return
            end
        end

        local childs = self._scrollView:getContainer():getChildren()
        if #childs <= 0 then 
            return
        end

        local tempX, posIndex
        for k,v in pairs(childs) do
            local x,y = v:getPosition()
            local worldX = v:convertToWorldSpaceAR(cc.p(0,0)).x 
            if tonumber(k) == 1 then
                self._offsetX = worldX
            end
            
            local sca = 1/(1+0.000005*(math.sqrt(math.pow((worldX-MAX_SCREEN_WIDTH*0.5),4))))
            v:setScale(sca)
            -- print("k======", k, math.ceil(sca*10000))
            v:setLocalZOrder(math.ceil(sca*10000))
        end

    end

    function GodWarView:scrollViewToIndex(indexId)
        if self._selectClick == false then
            return
        end
    end

    -- 滑动偏移处理
    function GodWarView:scrollToNext(selectedIndex)
        local posX = self._scrollView:getContentOffset().x
        local offset = -1*selectedIndex*80
        self._scrollView:setContentOffset(cc.p(offset,0), true)
    end

    function GodWarView:getzuiding()
        local zorder = 0
        local zuigao = 0
        for i=1,godWarGroupMax do
            local groupLayer = self._groupLayer[i]
            local tempZorder = groupLayer:getZOrder()
            if zorder < tempZorder then
                zuigao = i
                zorder = tempZorder
            end
        end
        return zuigao
    end

    function GodWarView:scrollViewDidScroll()
        self._isClick1 = true
        self:update(true)
        self:setHeadClick()
    end

    -- 设置头像是否可点击
    function GodWarView:setHeadClick()
        local ding = self:getzuiding()
        for gid=1,godWarGroupMax do
            local groupLayer = self._groupLayer[gid]
            for i=1,4 do
                local iconBg = groupLayer:getChildByName("iconBg" .. i)
                local icon = iconBg:getChildByName("icon")
                if icon then
                    if gid == ding then
                        icon:setTouchEnabled(true)
                        groupLayer:setTouchEnabled(true)
                    else
                        icon:setTouchEnabled(false)
                        groupLayer:setTouchEnabled(false)
                    end
                end
            end
            local groupName = self._groupLayer[gid].groupName
            if groupName then
                if gid == ding then
                    groupName:setVisible(true)
                    groupLayer:setSaturation(0)
                    groupLayer:setBrightness(0)
                else
                    groupName:setVisible(false)
                    -- groupLayer:setSaturation(-40)
                    groupLayer:setBrightness(-60)
                end
            end
            local groupBtn = self._groupLayer[gid].groupBtn
            if groupBtn then
                if gid == ding then
                    groupBtn:setVisible(true)
                else
                    groupBtn:setVisible(false)
                end
            end
        end
    end

    function GodWarView:updateScrollView()
        local userId = self._userModel:getData()._id
        if not self._groupLayer then
            self:addScrollView()
        end
        local flag = self._godWarModel:isMyJoin()
        local tgroupId = 0
        if flag == true then
            tgroupId = self._godWarModel:getMyGroup()
        end
        for gid=1,godWarGroupMax do
            local groupLayer = self._groupLayer[gid]
            local groupData = self._godWarModel:getGroupPlayerById(gid)
            if tgroupId == gid then
                local panelBg = groupLayer:getChildByName("panelBg")
                panelBg:loadTexture("godwarImageUI_img131.png", 1)
                panelBg:setCapInsets(cc.rect(170, 100, 1, 1))
            end
            for i=1,4 do
                local gpData = self._godWarModel:getPlayerById(groupData[i])
                if not gpData then
                    break
                end
                -- dump(gpData)
                local pname = groupLayer:getChildByName("pname" .. i)
                local iconBg = groupLayer:getChildByName("iconBg" .. i)
                local gname = groupLayer:getChildByName("gname" .. i)
                local jscore = groupLayer:getChildByName("jscore" .. i)
                local seed = groupLayer:getChildByName("seed" .. i)
                local playSelf = groupLayer:getChildByName("playSelf" .. i)

                if pname then
                    pname:setString(gpData.name)
                    if userId == groupData[i] then
                        playSelf:setVisible(true)
                        pname:setColor(cc.c3b(255, 178, 103))
                    else
                        pname:setColor(cc.c3b(252, 244, 197))
                        playSelf:setVisible(false)
                    end
                end

                if seed then
                    if gpData.s == 1 then
                        seed:setVisible(true)
                    else
                        seed:setVisible(false)
                    end
                end

                if gname then
                    local str = "未加入"
                    if gpData.guildName ~= "" then
                        str = gpData.guildName
                    end
                    gname:setString(str)
                end

                if jscore then
                    jscore:setString(gpData.n)
                end

                if iconBg then
                    local param = {avatar = gpData.avatar, level = gpData.lvl, tp = 4, avatarFrame = gpData["avatarFrame"], plvl = gpData.plvl}
                    local icon = iconBg:getChildByName("icon")
                    if not icon then
                        icon = IconUtils:createHeadIconById(param)
                        icon:setName("icon")
                        icon:setScale(0.6)
                        icon:setPosition(cc.p(2,2))
                        iconBg:addChild(icon)
                    else
                        IconUtils:updateHeadIconByView(icon, param)
                    end

                    local clickFlag = false
                    local downY
                    local posX, posY
                    registerTouchEvent(
                        icon,
                        function (_, _, y)
                            downY = y
                            clickFlag = false
                        end, 
                        function (_, _, y)
                            if downY and math.abs(downY - y) > 5 then
                                clickFlag = true
                            end
                        end, 
                        function ()
                            if clickFlag == false then 
                                local data = {tagId = groupData[i], fid = 101}
                                self:getTargetGodWarUserInfo(data)
                            end
                        end,
                        function ()
                        end)
                end
            end
        end
    end

    function GodWarView:getTargetUserBattleInfo(param)
        self._serverMgr:sendMsg("UserServer", "getTargetUserBattleInfo", param, true, {}, function(result) 
            self._viewMgr:showDialog("arena.DialogArenaUserInfo", result, true)
        end)
    end

    function GodWarView:getTargetGodWarUserInfo(param)
        self._serverMgr:sendMsg("UserServer", "getTargetUserBattleInfo", param, true, {}, function(result) 
            self._viewMgr:showDialog("godwar.GodwarUserInfoDialog", result, true)
        end)
    end


-- 根据场次获取时间
function GodWarView:getGodWarTime(powId, roundId)
    local minTime = 0
    local maxTime = 0

    local godWarConstData = self._userModel:getGodWarConstData()
    local curServerTime = self._userModel:getCurServerTime()
    local begTime = godWarConstData["RACE_BEG"]
    local endTime = godWarConstData["RACE_END"]
    if curServerTime >= begTime and curServerTime <= endTime then
        local weekday = tonumber(TimeUtils.date("%w", curServerTime))
        if weekday == 3 then
            local tempTime1 = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(timeBeg,"%Y-%m-%d 20:00:00"))
            local roundTime = readlyTime + fightTime*3
            minTime = tempTime1 + (roundId-1)*roundTime
            maxTime = tempTime1 + roundId*roundTime
        elseif weekday == 4 then
            local tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(timeBeg,"%Y-%m-%d 20:00:00"))
            if powId == 2 then
                minTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(timeBeg,"%Y-%m-%d 20:18:00"))
                local readlyTime = 300
                local roundTime = readlyTime + fightTime*3
                maxTime = minTime + roundTime
            elseif powId == 3 then
                minTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(timeBeg,"%Y-%m-%d 20:18:00"))
                local roundTime = readlyTime + fightTime*3
                maxTime = minTime + roundTime
            else
                local roundTime = readlyTime + fightTime*3
                minTime = tempTime1 + (roundId-1)*roundTime
                maxTime = tempTime1 + roundId*roundTime
            end
        end
    end

    return minTime, maxTime
end


function GodWarView:worshipChampion(indexId, layer)
    local param = {rank = indexId}
    self._serverMgr:sendMsg("GodWarServer", "worshipChampion", param, true, {}, function(result) 
        DialogUtils.showGiftGet({gifts = result.reward,notPop = true})
        local mobai = self:getUI("bg.layer4.rank" .. indexId .. ".mobai")
        if layer == true then
            mobai = self:getUI("bg.layer1.guanjunBg.mobai")
        end

        if mobai then
            if mobai.anim then
                mobai.anim:setVisible(false)
            end
            mobai:setSaturation(-100)
            self:registerClickEvent(mobai, function()
                self._viewMgr:showTip("你已经膜拜过")
            end)
        end
    end)
end

function GodWarView:progressGodWarBullet(notCleanBullet)
    local curServerTime = self._userModel:getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", curServerTime))
    local begTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 00:00:00"))
    local endTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
    if curServerTime >= begTime and curServerTime <= endTime then
        curServerTime = curServerTime - 86400
        weekday = tonumber(TimeUtils.date("%w", curServerTime))
    end
    self._sysBullet = tab:Bullet("GodWar")
    local godWarConstData = self._userModel:getGodWarConstData()
    local begTime = godWarConstData["RACE_BEG"]
    if begTime == 0 then
        self._sysBullet = nil
    end
    local bulletBtn = self:getUI("rightMenuNode.barrage")
    local bulletLab = self:getUI("rightMenuNode.bulletLab")
    if self._sysBullet == nil then 
        bulletBtn:setVisible(false)
        bulletLab:setVisible(false)
        if not notCleanBullet then
            BulletScreensUtils.clear()
        end
        return
    else
        bulletBtn:setVisible(true)
        bulletLab:setVisible(true)
    end
end

function GodWarView:showGodWarBullet(notCleanBullet)
    self:progressGodWarBullet(notCleanBullet)
    if self._sysBullet == nil then 
        return
    end
    local bulletBtn = self:getUI("rightMenuNode.barrage")
    local open = BulletScreensUtils.getBulletChannelEnabled(self._sysBullet)
    local fileName = open and "godwarImageUI_img145.png" or "godwarImageUI_img144.png"
    bulletBtn:loadTextures(fileName, fileName, fileName, 1)    
    if open and not notCleanBullet then
        BulletScreensUtils.initBullet(self._sysBullet)
    end    
end

function GodWarView:updateBulletBtnState()
    BulletScreensUtils.clear()

    local bulletBtn = self:getUI("rightMenuNode.barrage")
    local bulletLab = self:getUI("rightMenuNode.bulletLab")
    self._sysBullet = tab:Bullet("GodWar")
    if self._sysBullet == nil then 
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
                local fileName = open and "godwarImageUI_img145.png" or "godwarImageUI_img144.png"
                bulletBtn:loadTextures(fileName, fileName, fileName, 1)       
            end})
    end)    
end

function GodWarView:setBtn()
    local ruleBtn = self:getUI("leftMenuNode.ruleBtn")
    local shopBtn = self:getUI("leftMenuNode.shopBtn")
    local yazhuBtn = self:getUI("leftMenuNode.yazhuBtn")
    local saichengBtn = self:getUI("leftMenuNode.saichengBtn")
    local mingdanBtn = self:getUI("leftMenuNode.mingdanBtn")
    local zhichiBtn = self:getUI("leftMenuNode.zhichiBtn")
    zhichiBtn:setVisible(false)
    UIUtils:addFuncBtnName(ruleBtn, "规则", cc.p(ruleBtn:getContentSize().width/2,4))
    UIUtils:addFuncBtnName(shopBtn, "商店", cc.p(shopBtn:getContentSize().width/2,4))
    UIUtils:addFuncBtnName(yazhuBtn, "支持记录", cc.p(yazhuBtn:getContentSize().width/2,4))
    UIUtils:addFuncBtnName(saichengBtn, "赛程", cc.p(saichengBtn:getContentSize().width/2,4))
    UIUtils:addFuncBtnName(mingdanBtn, "名单", cc.p(mingdanBtn:getContentSize().width/2,4))
    UIUtils:addFuncBtnName(zhichiBtn, "支持记录", cc.p(zhichiBtn:getContentSize().width/2,4))

    self:registerClickEvent(ruleBtn, function()
        self._viewMgr:showDialog("godwar.GodWarRuleDialog")
    end)

    self:registerClickEvent(shopBtn, function()
        self._serverMgr:sendMsg("ShopServer", "getShopInfo", {type = "godWar"}, true, {}, function(result)
            self._viewMgr:showDialog("godwar.GodWarShopView",{},true)
        end)
    end)

    self:registerClickEvent(yazhuBtn, function()
        self:showStakeDialog()
    end)

    self:registerClickEvent(saichengBtn, function()
        self._viewMgr:showDialog("godwar.GodWarMatchTimeDialog")
    end)

    self:registerClickEvent(mingdanBtn, function()
        self._viewMgr:showDialog("godwar.GodWarAudienceDialog",{},true)
    end)

    self:registerClickEvent(zhichiBtn, function()
        self:showStakeDialog()
    end)

    local buzhenBtn = self:getUI("btnbg.buzhenBtn")
    UIUtils:addFuncBtnName(buzhenBtn, "布阵", nil, true)
    self:registerClickEvent(buzhenBtn, function()
        self._isHaveFormationView = true
        self:showFormation()
    end)

    local xiaozuBtn = self:getUI("rightMenuNode.xiaozuBtn")
    local zhengbaBtn = self:getUI("rightMenuNode.zhengbaBtn")
    local guanjunBtn = self:getUI("rightMenuNode.guanjunBtn")
    xiaozuBtn:setTitleFontSize(16) 
    zhengbaBtn:setTitleFontSize(16) 
    guanjunBtn:setTitleFontSize(16) 
    self:registerClickEvent(xiaozuBtn, function()
        if self._xiaozu == false then
            self._viewMgr:showTip("小组赛暂未开启")
            return
        end
        if self._selectpow == 1 then
            return
        end
        self:getGodWarSData(2)
        -- self:showViewLayer(2)
    end)

    self:registerClickEvent(zhengbaBtn, function()
        if self._zhengba == false then
            self._viewMgr:showTip("争霸赛暂未开启")
            return
        end
        if self._selectpow == 2 then
            return
        end
        self:getGodWarSData(3)
    end)

    self:registerClickEvent(guanjunBtn, function()
        if self._guanjun == false then
            self._viewMgr:showTip("冠军尚未出炉")
            return
        end
        if self._selectpow == 3 then
            return
        end
        self:getGodWarSData(4)
        -- local layerNum, state = self:getLayerState()
        -- self:showViewLayer(layerNum)
        -- self:showViewLayer(4)
    end)
end

function GodWarView:showStakeDialog()
    local layerNum, state = self:getLayerState()
    if state == 4 then
        local curServerTime = self._userModel:getCurServerTime()
        local weekday = tonumber(TimeUtils.date("%w", curServerTime))
        if weekday == 3 then
            local tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 19:30:00"))
            if curServerTime < tempTime then
                self._viewMgr:showTip(lang("zhushenzhizhan_tip"))
                return
            end
        elseif weekday == 2 then
            local tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime+86400,"%Y-%m-%d 19:30:00"))
            if curServerTime < tempTime then
                self._viewMgr:showTip(lang("zhushenzhizhan_tip"))
                return
            end
        end
    end
    self._serverMgr:sendMsg("GodWarServer", "getReceiveStakeList", {}, true, {}, function (result)
        self._viewMgr:showDialog("godwar.GodWarStackDialog", result)
    end)
end

function GodWarView:getGodWarSData(requestId)
    if requestId == 2 then
        self._serverMgr:sendMsg("GodWarServer", "getGroupBattle", {}, true, {}, function (result)
            self:showViewLayer(2)
        end)
    elseif requestId == 3 then
        self._serverMgr:sendMsg("GodWarServer", "getPowBattle", {}, true, {}, function (result)
            self:showViewLayer(3)
        end)
    elseif requestId == 4 then
        self._serverMgr:sendMsg("GodWarServer", "getTop3Skin", {}, true, {}, function (result)
            local layerNum, state, indexId = self:getLayerState()
            if indexId == 11 then
                layerNum = 4
            end
            self:showViewLayer(layerNum)
        end)
    end
end

function GodWarView:showBtnLayer(state)
    local ruleBtn = self:getUI("leftMenuNode.ruleBtn")
    local shopBtn = self:getUI("leftMenuNode.shopBtn")
    local saichengBtn = self:getUI("leftMenuNode.saichengBtn")
    local mingdanBtn = self:getUI("leftMenuNode.mingdanBtn")
    local yazhuBtn = self:getUI("leftMenuNode.yazhuBtn")
    local zhichiBtn = self:getUI("leftMenuNode.zhichiBtn")
    local imgline3 = self:getUI("leftMenuNode.imgline3")
    local imgline2 = self:getUI("leftMenuNode.imgline2")

    local rightMenuNode = self:getUI("rightMenuNode")
    local xiaozuBtn = self:getUI("rightMenuNode.xiaozuBtn")
    local zhengbaBtn = self:getUI("rightMenuNode.zhengbaBtn")
    local guanjunBtn = self:getUI("rightMenuNode.guanjunBtn")
    -- local buzhenBtn = self:getUI("btnbg.buzhenBtn")
    if state == 1 then -- 预告阶段
        ruleBtn:setVisible(true)
        shopBtn:setVisible(true)
        yazhuBtn:setVisible(false)
        saichengBtn:setVisible(false)
        mingdanBtn:setVisible(true)
        zhichiBtn:setVisible(false)
        imgline2:setVisible(true)
        imgline3:setVisible(false)
        rightMenuNode:setVisible(true)
    elseif state == 3 or state == 2 then -- 小组赛阶段
        ruleBtn:setVisible(true)
        shopBtn:setVisible(true)
        yazhuBtn:setVisible(false)
        saichengBtn:setVisible(true)
        mingdanBtn:setVisible(false)
        zhichiBtn:setVisible(false)
        imgline2:setVisible(true)
        imgline3:setVisible(false)
        rightMenuNode:setVisible(true)
    elseif state == 4 or state == 5 or state == 6 then -- 争霸赛
        ruleBtn:setVisible(true)
        shopBtn:setVisible(true)
        yazhuBtn:setVisible(false)
        saichengBtn:setVisible(true)
        mingdanBtn:setVisible(false)
        zhichiBtn:setVisible(true)
        imgline2:setVisible(true)
        imgline3:setVisible(true)
        rightMenuNode:setVisible(true)
    elseif state == 7 then
        ruleBtn:setVisible(true)
        shopBtn:setVisible(true)
        yazhuBtn:setVisible(true)
        saichengBtn:setVisible(false)
        mingdanBtn:setVisible(false)
        zhichiBtn:setVisible(false)
        imgline2:setVisible(true)
        imgline3:setVisible(false)
        rightMenuNode:setVisible(true)
        local curServerTime = self._userModel:getCurServerTime()
        local weekday = tonumber(TimeUtils.date("%w", curServerTime))
        if weekday == 0 then
            local tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 22:00:00"))
            local callFunc = cc.CallFunc:create(function()
                local curServerTime = self._userModel:getCurServerTime()
                if tempTime < curServerTime then
                    yazhuBtn:setVisible(false)
                    imgline2:setVisible(false)
                    imgline3:stopAllActions()
                end
            end)
            local seq = cc.Sequence:create(callFunc, cc.DelayTime:create(1))
            imgline3:runAction(cc.RepeatForever:create(seq))
        elseif weekday == 1 then
            yazhuBtn:setVisible(false)
            imgline2:setVisible(false)
        end
    elseif state == 8 then -- 膜拜
        ruleBtn:setVisible(true)
        shopBtn:setVisible(true)
        yazhuBtn:setVisible(false)
        saichengBtn:setVisible(false)
        mingdanBtn:setVisible(false)
        zhichiBtn:setVisible(false)
        imgline2:setVisible(false)
        imgline3:setVisible(false)
        rightMenuNode:setVisible(true)
    end

end

function GodWarView:updateRightBtnPanel(state)
    local buzhenBtn = self:getUI("btnbg.buzhenBtn")
    local rightMenuNode = self:getUI("rightMenuNode")
    local xiaozuBtn = self:getUI("rightMenuNode.xiaozuBtn")
    local zhengbaBtn = self:getUI("rightMenuNode.zhengbaBtn")
    local guanjunBtn = self:getUI("rightMenuNode.guanjunBtn")

    local myJoin = self._godWarModel:isMyJoin()
    if myJoin == true then
        buzhenBtn:setVisible(true)
        local fState = self:isShowFormation()
        if fState == 0 then
            buzhenBtn:setVisible(false) 
        end
    end

    if state == 1 then
        xiaozuBtn:setVisible(false)
        zhengbaBtn:setVisible(false)
        guanjunBtn:setVisible(false)
        xiaozuBtn:setSaturation(-100)
        zhengbaBtn:setSaturation(-100)
        guanjunBtn:setSaturation(-100)
    elseif state == 2 or state == 3 then
        xiaozuBtn:setSaturation(0)
        zhengbaBtn:setSaturation(-100)
        guanjunBtn:setSaturation(-100)
        self._xiaozu = true
        self._zhengba = false
        self._guanjun = false
    elseif state == 4 or state == 5 or state == 6 then
        xiaozuBtn:setSaturation(0)
        zhengbaBtn:setSaturation(0)
        guanjunBtn:setSaturation(-100)
        self._xiaozu = true
        self._zhengba = true
        self._guanjun = false
        if state == 6 then
            local state, indexId = self._godWarModel:getStatus()
            if indexId == 11 then
                guanjunBtn:setSaturation(0)
                self._guanjun = true
            end
        end
    elseif state == 7 or state == 8 then
        xiaozuBtn:setSaturation(0)
        zhengbaBtn:setSaturation(0)
        guanjunBtn:setSaturation(0)
        buzhenBtn:setVisible(false)
        self._xiaozu = true
        self._zhengba = true
        self._guanjun = true
    end
end

function GodWarView:onBeforeAdd(callback, errorCallback)
    self._onBeforeAddCallback = function(inType)
        if inType == 1 then 
            callback()
        else
            errorCallback()
        end
    end
    -- local state, indexId = self._modelMgr:getModel("GodWarModel"):getStatus()
    -- local requestId = 5
    -- if state == 7 then
    --     requestId = 4
    -- elseif state == 8 then
    --     requestId = 1
    -- elseif state == 3 or state == 2 then
    --     requestId = 2
    -- elseif state == 4 or state == 5 or state == 6 then
    --     requestId = 3
    -- end
    self:enterGodWar(requestId)
    
end


-- function GodWarView:getEnterGodWar(requestId)
--     if requestId == 1 then
--         self:enterGodWarFinish(1)
--     elseif requestId == 2 then
--         self._serverMgr:sendMsg("GodWarServer", "getGroupBattle", {}, true, {}, function (result)
--             dump(result, "result ===", 2)
--             self:enterGodWarFinish(result)
--         end)
--     elseif requestId == 3 then
--         self._serverMgr:sendMsg("GodWarServer", "getPowBattle", {}, true, {}, function (result)
--             dump(result, "result ===", 2)
--             self:enterGodWarFinish(result)
--         end)
--     elseif requestId == 4 then
--         self._serverMgr:sendMsg("GodWarServer", "enterGodWar", {}, true, {}, function (result)
--             dump(result, "result ===", 2)
--             self:enterGodWarFinish(result)
--         end)
--     elseif requestId == 5 then
--         self._serverMgr:sendMsg("GodWarServer", "enterGodWar", {}, true, {}, function (result)
--             dump(result, "result ===", 2)
--             self:enterGodWarFinish(result)
--         end)
--     end
-- end

function GodWarView:enterGodWar()
    self._serverMgr:sendMsg("GodWarServer", "enterGodWar", {}, true, {}, function (result)
        dump(result, "result ===", 2)
        self._serverMgr:sendMsg("GodWarServer", "getTop3Skin", {}, true, {}, function (result)
            local layerNum, state, indexId = self:getLayerState()
            if indexId == 11 then
                layerNum = 4
            end
            self:showViewLayer(layerNum)
            self:enterGodWarFinish(result)
        end)
    end)
end

function GodWarView:enterGodWarFinish(result)
    if result == nil then
        self._onBeforeAddCallback(2)
        return 
    end
    self._onBeforeAddCallback(1)
    self:reflashUI()
    -- 弹幕
    self:updateBulletBtnState()
    self:showGodWarBullet()
end

function GodWarView:getNowBattleData()
    local curServerTime = self._userModel:getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", curServerTime))
    local godWarConstData = self._userModel:getGodWarConstData()
    local begTime = godWarConstData["RACE_BEG"]
    local powData
    if begTime ~= 0 then
        local powAllData = self._godWarModel:getWarDataById(self._pow)
        local round, _ = self:getStrPower(self._pow)
        if weekday == 3 then
            local tTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 19:30:00"))
            local eTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:36:00"))
            if curServerTime > tTime and curServerTime < eTime then
                if powAllData then
                    powData = powAllData[tostring(round)]
                end
            end
        elseif weekday == 4 then
            local tTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 19:30:00"))
            local eTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:29:00"))
            if curServerTime > tTime and curServerTime < eTime then
                if powAllData then
                    powData = powAllData[tostring(round)]
                end
            end
        end
    end

    return powData
end

-- 8点之间进行战斗处理
function GodWarView:reflashBattleTime()
    self:checkTips()

    local curServerTime = self._userModel:getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", curServerTime))
    local randTime = 0 -- GRandom(5)
    local tTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
    local cTime = curServerTime - tTime
    local bg1 = self:getUI("btnbg")

    local godWarConstData = self._userModel:getGodWarConstData()
    local begTime = godWarConstData["RACE_BEG"]
    local endTime = godWarConstData["RACE_END"]
    if (curServerTime < begTime) or (curServerTime > endTime) then
        return
    end

    -- local powData = self:getNowBattleData()
    -- self:updateDirectHint(powData)

    -- print("cTime >= 0 and cTime=======", cTime)
    if cTime >= -1805 and cTime <= 2160 then
        local tempTime = curServerTime - tTime
        local callFunc = cc.CallFunc:create(function()
            tempTime = tempTime + 1
            self:updateWeek(weekday, tTime)
        end)
        local seq = cc.Sequence:create(callFunc, cc.DelayTime:create(1))
        bg1:stopAllActions()
        bg1:runAction(cc.RepeatForever:create(seq))
    end
end


function GodWarView:updateWeek(weekday, tTime)
    local curServerTime = self._userModel:getCurServerTime()
    local cTime = curServerTime - tTime
--    print("time .. ",cTime)
    if weekday == 2 then -- 小组赛
        if cTime > 1081 then
            local bg1 = self:getUI("btnbg")
            self._zhibo:setVisible(false)
            bg1:stopAllActions()
        end
        -- local ju = math.floor(cTime/jiange) + 1
        -- local chang = math.floor(cTime/(jiange*3)) + 1
        -- print("=22222=======", cTime, chang, jiange*ju-1)
        -- local tju = ju - chang * 3
        -- if tju == 0 then
        --     self._ju = 3
        -- end
        -- print('jiange=========', cTime, ju)
        -- if cTime >= jiange*ju-1 then
        --     if ju > 0 and ju <= 9 then
        --         self:getJoinList()
        --         self:getGroupBattle(chang)
        --     end
        -- end
        -- print("cTime=========", cTime, jiange)
        local showTime = 60
        if math.fmod(cTime, showTime) == (showTime - 3) then
            self:getJoinList()
            self:getGroupBattle(chang)
            print("kaishi ============================")
            -- if self._cumTime < cTime then
            --     self._cumTime = cTime
            -- end
        end
    elseif weekday == 3 then -- 争霸赛
        self._zhibo:setVisible(true)
        if cTime > 2160 then
            local bg1 = self:getUI("btnbg")
            self._zhibo:setVisible(false)
            bg1:stopAllActions()
        end
        -- local ju = math.floor(cTime/jiange) + 1
        -- local chang = math.floor(cTime/(jiange*3)) + 1
        -- -- print("=33333=======", cTime, chang, jiange*ju-1)
        -- local tju = ju - chang * 3

        self._pow = 8
        -- self:addFlame()
        if cTime > 0 then
            local middleTime = readlyTime + fightTime*3
            local _tTime = math.fmod(cTime, middleTime)
            local ttime = _tTime - readlyTime
            -- print("cTime===========", ttime, _tTime, jiange, math.fmod(ttime, jiange))
            if math.fmod(ttime, fightTime) == 3 then
                print("进入战斗=================")
                local callback = function()
                    local round, ju = self:getStrPower(8)
                    local param = {pow = 8, round = round, ju = ju}
                    self:getPowBattleInfo(param, 0)
                end
                local param = {callback = callback}
                if self._countDown == true then
                    self._viewMgr:showDialog("godwar.GodWarCountDownDialog", param)
                end
            end
            -- print("self._ju====", cTime)
            if math.fmod(ttime, fightTime) == showScoreTime then
                if self._cumTime < cTime then
                    local round, ju = self:getStrPower(self._pow)
                    self:getPowBattle(self._pow, round)
                    self._cumTime = cTime
                end
            end
            if math.fmod(ttime, fightTime) == 117 then
                if self._cumTime < cTime then
                    local round, ju = self:getStrPower(self._pow)
                    self:getPowBattle(self._pow, round)
                    self._cumTime = cTime
                end
                -- self._godWarModel:replaceProgressWarData()
            end

            --正在战斗中
            print(" 正在战斗中  ")
            print(" fmod" .. math.fmod(ttime, fightTime))
            if math.fmod(ttime, fightTime) >3 and math.fmod(ttime, fightTime) < 117 then
                if self._formationView then
                    print("关闭上阵界面")
                    self._viewMgr:popView()
                    self._formationView = nil
                end
            end

            if _tTime == 0 then
                -- self._godWarModel:replaceProgressWarData()
                local round, ju = self:getStrPower(8)
                print("roudAnimRound=", round,ju, self._oldAnimRound)
                local tround = round - 1
                local proData = promotionTab[tround]
                self._oldAnimRound = round - 1
                self:updatePowData(proData, tround, true)
            end

            if cTime == 1 then
                local tround = 1
                local proData = promotionTab[tround]
                self:updatePowData(proData, tround, false)
            end
        end
    elseif weekday == 4 then -- 争霸赛
        self._zhibo:setVisible(true)
        -- print("cTime======", cTime, tTime)
        if cTime > 1741 then
            local bg1 = self:getUI("btnbg")
            self._zhibo:setVisible(false)
            bg1:stopAllActions()
        end

        if cTime > 1080 then -- 决赛
            self._pow = 2
            local _cTime = cTime - 1080
            local readlyTime = 300
            local middleTime = readlyTime + fightTime*3
            local _tTime = math.fmod(_cTime, middleTime)
            local ttime = _tTime - readlyTime

            -- print("ttime===========", ttime, _tTime)
            if math.fmod(ttime, fightTime) == 3 then
                print("进入战斗=================")
                if self._pow == 2 then
                    local callback = function()
                        local round, ju = self:getStrPower(2)
                        local param = {pow = 2, round = 1, ju = ju}
                        self:getPowBattleInfo(param, 0)
                    end
                    local param = {callback = callback}
                    if self._countDown == true then
                        self._viewMgr:showDialog("godwar.GodWarCountDownDialog", param)
                    end
                else
                    local callback = function()
                        local round, ju = self:getStrPower(4)
                        local param = {pow = 4, round = round, ju = ju}
                        self:getPowBattleInfo(param, 0)
                    end
                    local param = {callback = callback}
                    if self._countDown == true then
                        self._viewMgr:showDialog("godwar.GodWarCountDownDialog", param)
                    end
                end
            end

            if math.fmod(ttime, fightTime) == showScoreTime then
                if self._cumTime < cTime then
                    local round, ju = self:getStrPower(self._pow)
                    self:getPowBattle(self._pow, round)
                    self._cumTime = cTime
                end
            end

            if math.fmod(ttime, fightTime) == 117 then
                if self._cumTime < cTime then
                    local round, ju = self:getStrPower(self._pow)
                    self:getPowBattle(self._pow, round)
                    self._cumTime = cTime
                end
            end

            if math.fmod(ttime, fightTime) >3 and math.fmod(ttime, fightTime) < 117 then
                if self._formationView then
                    self._viewMgr:popView()
                    self._formationView = nil
                end
            end
            if _tTime == 0 then
                -- self._godWarModel:replaceProgressWarData()
                local round, ju = self:getStrPower(self._pow)
                if self._pow == 2 then
                    round = 7
                elseif self._pow == 4 then
                    round = round + 4
                end
                print("roudAnimRound=", round,ju, self._oldAnimRound)
                local tround = round
                local proData = promotionTab[tround]
                self._oldAnimRound = round
                self:updatePowData(proData, tround, true)
            end

            if cTime == 1 then
                local tround = 5
                local proData = promotionTab[tround]
                self:updatePowData(proData, tround, false)
            end
        else
            self._pow = 4
            if cTime > 0 then
                local readlyTime = readlyTime
                if self._pow == 2 then
                    readlyTime = 300
                end
                local middleTime = readlyTime + fightTime*3
                local _tTime = math.fmod(cTime, middleTime)
                local ttime = _tTime - readlyTime

                print("ttime===========", ttime, _tTime)
                if math.fmod(ttime, fightTime) == 3 then
                    print("进入战斗=================")
                    if self._pow == 2 then
                        local callback = function()
                            local round, ju = self:getStrPower(2)
                            local param = {pow = 2, round = 1, ju = ju}
                            self:getPowBattleInfo(param, 0)
                        end
                        local param = {callback = callback}
                        if self._countDown == true then
                            self._viewMgr:showDialog("godwar.GodWarCountDownDialog", param)
                        end
                    else
                        local callback = function()
                            local round, ju = self:getStrPower(4)
                            local param = {pow = 4, round = round, ju = ju}
                            self:getPowBattleInfo(param, 0)
                        end
                        local param = {callback = callback}
                        if self._countDown == true then
                            self._viewMgr:showDialog("godwar.GodWarCountDownDialog", param)
                        end
                    end
                end

                if math.fmod(ttime, fightTime) == showScoreTime then
                    if self._cumTime < cTime then
                        local round, ju = self:getStrPower(self._pow)
                        self:getPowBattle(self._pow, round)
                        self._cumTime = cTime
                    end
                end

                if math.fmod(ttime, fightTime) == 117 then
                    if self._cumTime < cTime then
                        local round, ju = self:getStrPower(self._pow)
                        self:getPowBattle(self._pow, round)
                        self._cumTime = cTime
                    end
                end

                if math.fmod(ttime, fightTime) >3 and math.fmod(ttime, fightTime) < 117 then
                    if self._formationView then
                        self._viewMgr:popView()
                        self._formationView = nil
                    end
                end


                if _tTime == 0 then
                    -- self._godWarModel:replaceProgressWarData()
                    local round, ju = self:getStrPower(self._pow)
                    if self._pow == 2 then
                        round = 7
                    elseif self._pow == 4 then
                        round = round + 4
                    end
                    print("roudAnimRound=", round,ju, self._oldAnimRound)
                    local tround = round - 1
                    local proData = promotionTab[tround]
                    self._oldAnimRound = round - 1
                    self:updatePowData(proData, tround, true)
                end

                -- if cTime >= 0 then
                --     if math.fmod(cTime, jiange) == 0 then
                --         if self._pow == 4 then
                --             local round = math.ceil(cTime/900)
                --             local round, ju = self:getStrPower(4)
                --             -- print("roudAnimRound=", round,"+++++========", self._oldAnimRound)
                --             round = round + 4
                --             if round ~= self._oldAnimRound then
                --                 if ju == 1 then
                --                     local tround = self._oldAnimRound or 5
                --                     local proData = promotionTab[tround]
                --                     print("==troundtround============", round, tround)
                --                     self._oldAnimRound = round
                --                     self:updatePowData(proData, self._oldAnimRound, true)
                --                 end
                --             end
                --         elseif self._pow == 2 then
                --             local round = math.ceil(cTime/900)
                --             local round, ju = self:getStrPower(2)
                --             round = round + 6
                --             print("roudAnimRound=", round, self._oldAnimRound)
                --             if round ~= self._oldAnimRound then
                --                 if ju == 1 then
                --                     local tround = self._oldAnimRound or 7
                --                     local proData = promotionTab[tround]
                --                     self._oldAnimRound = round
                --                     self:updatePowData(proData, self._oldAnimRound, true)
                --                 end
                --             end
                --         end
                --     end
                -- end
                if cTime == 1 then
                    local tround = 5
                    local proData = promotionTab[tround]
                    self:updatePowData(proData, tround, false)
                end
            end
        end

        -- local ju = math.floor(cTime/jiange) + 1
        -- local chang = math.floor(ju/3) + 1
        -- local tju = ju - chang * 3
        -- if tju == 0 then
        --     self._ju = 3
        -- end
        
        -- if (ju <= 6) then
        --     self._pow = 4
        -- elseif (ju >= 7 and ju <= 11) then
        --     self._pow = 2
        -- end
        -- print("=44444=======", math.fmod(cTime, jiange), ju)
        -- if cTime > 0 then
        --     if math.fmod(cTime, jiange) == 180 then
        --         if (ju > 0 and ju <= 6) then
        --             local callback = function()
        --                 local round, ju = self:getStrPower(4)
        --                 local param = {pow = 4, round = round, ju = ju}
        --                 self:getPowBattleInfo(param, 0)
        --             end
        --             local param = {callback = callback}
        --             if self._countDown == true then
        --                 self._viewMgr:showDialog("godwar.GodWarCountDownDialog", param)
        --             end
        --         elseif (ju >= 9 and ju <= 11) then
        --             local callback = function()
        --                 local round, ju = self:getStrPower(2)
        --                 local param = {pow = 2, round = 1, ju = ju}
        --                 self:getPowBattleInfo(param, 0)
        --             end
        --             local param = {callback = callback}
        --             if self._countDown == true then
        --                 self._viewMgr:showDialog("godwar.GodWarCountDownDialog", param)
        --             end
        --         end
        --     end
        --     if math.fmod(cTime, jiange) == 295 then
        --         if self._cumTime < cTime then
        --             self._cumTime = cTime
        --             self:getPowBattle()
        --         end
        --     end

        --     if cTime >= 0 then
        --         if math.fmod(cTime, jiange) == 0 then
        --             if self._pow == 4 then
        --                 local round = math.ceil(cTime/900)
        --                 local round, ju = self:getStrPower(4)
        --                 -- print("roudAnimRound=", round,"+++++========", self._oldAnimRound)
        --                 round = round + 4
        --                 if round ~= self._oldAnimRound then
        --                     if ju == 1 then
        --                         local tround = self._oldAnimRound or 5
        --                         local proData = promotionTab[tround]
        --                         print("==troundtround============", round, tround)
        --                         self._oldAnimRound = round
        --                         self:updatePowData(proData, self._oldAnimRound, true)
        --                     end
        --                 end
        --             elseif self._pow == 2 then
        --                 local round = math.ceil(cTime/900)
        --                 local round, ju = self:getStrPower(2)
        --                 round = round + 6
        --                 print("roudAnimRound=", round, self._oldAnimRound)
        --                 if round ~= self._oldAnimRound then
        --                     if ju == 1 then
        --                         local tround = self._oldAnimRound or 7
        --                         local proData = promotionTab[tround]
        --                         self._oldAnimRound = round
        --                         self:updatePowData(proData, self._oldAnimRound, true)
        --                     end
        --                 end
        --             end
        --         end
        --     end
        --     if cTime == 1 then
        --         local tround = 5
        --         local proData = promotionTab[tround]
        --         self:updatePowData(proData, tround, false)
        --     end
        -- end

        -- if cTime >= jiange*ju-1 then
        --     if (ju > 0 and ju <= 6) then
        --         self:getPowBattle()
        --     elseif (ju >= 7 and ju <= 11) then
        --         self:getPowBattle()
        --     end
        -- end
    end
end


function GodWarView:getJoinList()
    print("====getJoinList=========获取列表")
    self._serverMgr:sendMsg("GodWarServer", "getJoinList", {}, true, {}, function (result)
        dump(result, "result ===", 5)
        self:updateScrollView()
    end)
end


-- 获取小组赛数据
function GodWarView:getGroupBattle(roundId)
    print("roundId=========", roundId)
    local param = {gp = self._groupId, round = roundId}
    self._serverMgr:sendMsg("GodWarServer", "getGroupBattle", param, true, {}, function (result)
        dump(result, "result ===", 5)
        self:getGroupBattleFinish(result)
    end)
end

function GodWarView:getGroupBattleFinish(result)
    -- 更新小组赛数据
    self:showViewLayer(2)
end


-- -- 获取争霸赛数据
-- function GodWarView:getPowBattle(powId)
--     local param = {pow = powId}
--     if self:getPowBattleResult() == true then
--         return
--     end
--     print("powId==========", powId)
--     self._serverMgr:sendMsg("GodWarServer", "getPowBattle", param, true, {}, function (result)
--         dump(result, "result ===", 5)
--         self:getPowBattleFinish(result)
--     end)
-- end

-- function GodWarView:getPowBattleFinish(result)
--     self._animBattle = true
--     -- self:reflashUI()
--     -- self:addFlame()
-- end

-- 获取下一阶段的时间
function GodWarView:getNextTimer()
    local status = 8
    local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local warMatchTime = self._godWarModel:getGodWarMatchTime()
    local indexId = 0
    for i=1,13 do
        if curServerTime > warMatchTime[i][2] then
            indexId = i
        end
    end
    
    if indexId < 13 then
        -- print("curServerTime===============", curServerTime, warMatchTime[indexId][2])
        if curServerTime > warMatchTime[indexId][2] then
        end
        indexId = indexId + 1
    end

    return indexId
end

function GodWarView:getNowChangAndJu()
    local round, ju = self:getStrPower(self._pow)
    return round, ju, self._pow
end


function GodWarView:getResultData(showtype)
    print("self._battleFight===888888888888888888===========",self._resultShow, self._battleFight, showtype)
    if self._resultShow == true then
        return
    end
    self._resultShow = true
    -- self._serverMgr:sendMsg("GodWarServer", "getPowBattle", {}, true, {}, function (result)
    self._serverMgr:sendMsg("GodWarServer", "enterGodWar", {}, true, {}, function (result)
        if self._battleFight == true then
            self._showDialogResult = showtype
        else
            self:showGodWarResultDialog(showtype)
        end
    end)
end

function GodWarView:showGodWarResultDialog(showtype)
    local callback = function()
        self:reflashUI()
        self._resultShow = false
        self._showDialogResult = nil
    end
    local param = {callback = callback}
    if showtype == 1 then
        self._viewMgr:showDialog("godwar.GodWarFenzuDialog", param)
    elseif showtype == 2 then
        self:getJoinList()
        local param1 = {powId = 8, callback = callback}
        self._viewMgr:showDialog("godwar.GodWarResultDialog", param1)
    elseif showtype == 3 then
        self:getJoinList()
        local param1 = {powId = 4, callback = callback}
        self._viewMgr:showDialog("godwar.GodWarResultDialog", param1)
    elseif showtype == 4 then
        self:getJoinList()
        local param1 = {powId = 2, callback = callback}
        self._viewMgr:showDialog("godwar.GodWarResultDialog", param1)
    elseif showtype == 5 then
        self:getJoinList()
        self._serverMgr:sendMsg("GodWarServer", "getTop3Skin", {}, true, {}, function (result)
            local param1 = {powId = 1, callback = callback}
            self._viewMgr:showDialog("godwar.GodWarBirthChampionDialog", param1)
        end)
    end
end

function GodWarView:onTop()
    print("onTop======================")
    self:updateBuffBtn()
    self:closeAction()
    self:checkTips()
    self:reflashUI()    
end

function GodWarView:onDestroy()
    GodWarView.super.onDestroy(self)
    BulletScreensUtils.clear()
end

function GodWarView:setNoticeBar()
    self._viewMgr:hideNotice(true)
end

function GodWarView:setNavigation()
    local callback = function()
        self._godWarModel:setShowRed(false)
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("godwar.GodWarView")
        end
        self._serverMgr:sendMsg("GodWarServer","exitRoom",{},true,{},function(result )
            local viewMgr = ViewManager:getInstance()
            -- viewMgr:returnMain()
        end)
    end
    self._viewMgr:showNavigation("global.UserInfoView",{hideHead=true,hideInfo=true, callback = callback})
end

function GodWarView:getBgName()
    return "bg_009.jpg"
end

function GodWarView:getAsyncRes()
    return {
        {"asset/ui/godwar2.plist", "asset/ui/godwar2.png"},
        {"asset/ui/godwar1.plist", "asset/ui/godwar1.png"},
        {"asset/ui/godwar.plist", "asset/ui/godwar.png"},
    }
end

function GodWarView:watchTV()
    local callback1 = function()
        return self:getNowChangAndJu()
    end
    local callback2 = function(param)
        self:getPowBattleInfo(param, 2)
    end
    local callback3 = function()
        self:showGodWarBullet(true)
        self._watchBattleDialog = nil
    end
    local callback4 = function(powData)
        self:updateDirectHint(powData)
    end
    local param = {callback1 = callback1, callback2 = callback2, callback3 = callback3, callback4 = callback4}
    self._watchBattleDialog = self._viewMgr:showDialog("godwar.GodWarWatchBattleDialog", param, true)
end

function GodWarView:getBattleReplayType(param, tType)
    dump(param)
    local replayType = 2
    local winlose = {0,0,0}
    local userId = self._userModel:getData()._id 
    local warData = self._godWarModel:getWarDataById(param.pow)
    if not warData then
        return 100
    end
    local battleData = warData[tostring(param.round)]
    if not battleData then
        return 100
    end
    dump(battleData)
    local rid = battleData.def
    local reverse = false
    if self._userid == rid then
        reverse = true
    end
    local reps = battleData["reps"] or {}
    for i=1,3 do
        local indexId = tostring(i)
        local battleD = reps[indexId]
        if battleD then
            if reverse == true then
                if battleD["w"] == 2 then
                    winlose[i] = 1
                else
                    winlose[i] = 2
                end
            else
                winlose[i] = battleD["w"]
            end
        end
    end
    local atkId = battleData.atk
    local defId = battleData.def
    print("==getBattleReplayType=====", atkId, userId, defId)
    if atkId == userId or defId == userId then
        if tType == 0 then
            replayType = 0
        end
    end
    return replayType, winlose
end


-- 战斗相关
function GodWarView:initBattleData( reportData )
    return BattleUtils.jsonData2lua_battleData(reportData)
end

-- 获取晋级赛某场战斗攻方，守方数据
function GodWarView:getPowBattleInfo(param, replayType)
    if not param then
        return
    end
    if replayType == 0 or replayType == 2 then
        replayType, winlose = self:getBattleReplayType(param, replayType)
    end
    if replayType == 100 then
        self._viewMgr:showTip(lang("GUILDMAPTIPS_13"))
        return
    end
    dump(param, "param=======")
    self._serverMgr:sendMsg("GodWarServer","getPowBattleInfo",param,true,{},function( result )
        if result and result["reportKey"] then
            self:getBattleReport(result["reportKey"], replayType, winlose)
        else
            self:reviewTheBattle(result, replayType, winlose)
        end
    end)
end

-- 根据战报获取战斗数据
function GodWarView:getBattleReport(reportID, replayType, winlose)
    print("reportID===", reportID)
    if not replayType then
        replayType = 2
    end
    self._serverMgr:sendMsg("BattleServer","getBattleReport",{reportKey = reportID},true,{},function( result )
        self:reviewTheBattle(result, replayType, winlose)
    end, function(errorId)
        if tonumber(errorId) == 113 then
            self._viewMgr:showTip(lang("REPLAY_CLEAR_TIP"))
        end
    end)
end

function GodWarView:reviewTheBattle(result, replayType, winlose, showDraw)
    if not result then
        return
    end
    dump(winlose)
    self:joinBattle()
    local left = self:initBattleData(result.atk)
    local right = self:initBattleData(result.def)
    local rid = result.def.rid
    local reverse = false
    local showSkill = false
    if self._userid == rid then
        reverse = true
        showSkill = true
    end
    if self._userid == result.atk.rid then
        showSkill = true
    end
    if not showDraw then
        showDraw = false
    end
    -- 同步名字
    local atkId = result.atk.rid
    local atkData = self._godWarModel:getPlayerById(atkId)
    result.atk.name = atkData.name
    local defId = result.def.rid
    local defData = self._godWarModel:getPlayerById(defId)
    result.def.name = defData.name
    
    local winlose = winlose
    BattleUtils.disableSRData()
    BattleUtils.enterBattleView_GodWar(left, right, result.r1, result.r2, replayType, reverse, winlose, showDraw, showSkill,
    function (info, callback)
        callback(info)
    end,
    function (info)
        -- 退出战斗
        self:exitBattle()
    end)
end

function GodWarView:joinBattle()
    self._countDown = false
    BulletScreensUtils.clear()
    self._battleFight = true
end

function GodWarView:exitBattle()
    self._countDown = true
    self:showGodWarBullet()
    self._battleFight = false
    if self._showDialogResult then
        local showtype = self._godWarModel:getGodWarShowDialogType()
        self._resultShow = false
        self:getResultData(showtype)
    end 
    if self._watchBattleDialog and self._watchBattleDialog.realTimeData then
        self._watchBattleDialog:realTimeData()
    end
    local layerNum, state = self:getLayerState()
    if layerNum == 4 then
        local curServerTime = self._userModel:getCurServerTime()
        local weekday = tonumber(TimeUtils.date("%w", curServerTime))
        local tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(timeBeg,"%Y-%m-%d 20:29:00"))
        if weekday == 4 and curServerTime > tempTime then
            self:getGodWarSData(4)
        end
    end
    self:reflashUI()
end


function GodWarView:initLayer()
    -- layer 1
    -- local dizuo = self:getUI("bg.layer1.guanjunBg.dizuo")
    -- dizuo:loadTexture("asset/uiother/dizuo/heroDizuo.png", 0)
    local guanjunBg = self:getUI("bg.layer1.guanjunBg")
    local guanjunFightLab = cc.LabelBMFont:create("1000000", UIUtils.bmfName_zhandouli_little)
    guanjunFightLab:setName("guanjunFightLab")
    guanjunFightLab:setAnchorPoint(0, 0.5)
    guanjunFightLab:setScale(0.35)
    guanjunFightLab:setPosition(140, 103)
    guanjunBg:addChild(guanjunFightLab, 1)
    guanjunBg.guanjunFightLab = guanjunFightLab

    -- local guanjuntitle = self:getUI("bg.layer3.powtu.titleBg.title")
    -- guanjuntitle:setColor(cc.c3b(255, 253, 253))
    -- guanjuntitle:enable2Color(1, cc.c4b(253, 229, 175, 255))
    -- guanjuntitle:setFontSize(24)

    -- local donghua = self:getUI("bg.layer1.guanjunBg.guanjundi.Image_60")
    -- local mc1 = mcMgr:createViewMC("guangjun_godwar", true, false)
    -- mc1:setPosition(donghua:getContentSize().width*0.5, donghua:getContentSize().height*0.5)
    -- mc1:setName("mc1")
    -- donghua:addChild(mc1)

    local mobai = self:getUI("bg.layer1.guanjunBg.mobai")
    local dayinfo = self._modelMgr:getModel("PlayerTodayModel"):getDayInfo(53)
    if dayinfo == 1 then
        if mobai.anim then
            mobai.anim:setVisible(false)
        end
        mobai:setSaturation(-100)
        self:registerClickEvent(mobai, function()
            self._viewMgr:showTip("你已经膜拜过")
        end)
    else
        mobai:setSaturation(0)
        self:registerClickEvent(mobai, function()
            self:worshipChampion(1, true)
        end)
        if not mobai.anim then
            local mc1 = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true, false)
            mc1:setName("anim")
            mc1:setPosition(mobai:getContentSize().width*0.5, mobai:getContentSize().height*0.5+1)
            mobai:addChild(mc1, 1)
            mobai.anim = mc1
        else
            mobai.anim:setVisible(true)
        end
    end

    -- layer 2
    local leftBtn = self:getUI("bg.layer2.leftBtn")
    local rightBtn = self:getUI("bg.layer2.rightBtn")
    if self._currentGroup == 1 then
        leftBtn:setVisible(false)
        rightBtn:setVisible(true)
    elseif self._currentGroup == 8 then
        leftBtn:setVisible(true)
        rightBtn:setVisible(false)
    else
        leftBtn:setVisible(true)
        rightBtn:setVisible(true)
    end
    self:registerClickEvent(leftBtn, function()
        self._currentGroup = self._currentGroup - 1
        if self._currentGroup == 1 then
            leftBtn:setVisible(false)
        else
            leftBtn:setVisible(true)
            rightBtn:setVisible(true)
        end
        self:scrollToNext(self._currentGroup)
        print("true======", self._currentGroup)
    end)
    self:registerClickEvent(rightBtn, function()
        self._currentGroup = self._currentGroup + 1
        if self._currentGroup == 8 then
            rightBtn:setVisible(false)
        else
            leftBtn:setVisible(true)
            rightBtn:setVisible(true)
        end
        self:scrollToNext(self._currentGroup)
        print("rightBtn======", self._currentGroup)
    end)

    -- layer3
    for i=1,8 do
        local chakan = self:getUI("bg.layer3.powtu.chakan" .. i)
        -- local fangdajing = mcMgr:createViewMC("fangdajing_godwar", true, false)
        -- fangdajing:setPosition(chakan:getContentSize().width*0.5, chakan:getContentSize().height*0.5)
        -- fangdajing:setName("fangdajing")
        -- chakan:addChild(fangdajing)
        -- fangdajing:stop()
        -- chakan:setOpacity(0)
        chakan:setScaleAnim(true)
        self:registerClickEvent(chakan, function()
            -- local state = self:getCheckBtnState(i)
            -- if state == true then
            --     return
            -- end
            local paramD = {groupId = 1, indexId = 2, scrollId = i, callbackFight = function(reportID, winlose)
                -- self:getBattleReport(reportID)
                self:reviewTheBattle(reportID, 2, winlose)
            end}
            self._viewMgr:showDialog("godwar.GodWarFightDialog", paramD)
        end)
        local tipLabBg = self:getUI("bg.layer3.powtu.tipLabBg" .. i)
        self:registerClickEvent(tipLabBg, function()
            local state = self:getCheckBtnState(i)
            if state == true then
                self:showWatchTV()
            end
        end)
    end

    -- layer 4
    for i=1,3 do
        local rank = self:getUI("bg.layer4.rank" .. i)
        local guanjunFightLab = cc.LabelBMFont:create("1000000", UIUtils.bmfName_zhandouli_little)
        guanjunFightLab:setName("guanjunFightLab")
        guanjunFightLab:setAnchorPoint(0, 0.5)
        guanjunFightLab:setScale(0.35)
        guanjunFightLab:setPosition(140, 95)
        rank:addChild(guanjunFightLab, 1)
        rank.guanjunFightLab = guanjunFightLab


        local mobai = self:getUI("bg.layer4.rank" .. i .. ".mobai")
        local dayinfo = self._modelMgr:getModel("PlayerTodayModel"):getDayInfo(52+i)
        if dayinfo == 1 then
            if mobai.anim then
                mobai.anim:setVisible(false)
            end
            mobai:setSaturation(-100)
            self:registerClickEvent(mobai, function()
                self._viewMgr:showTip("你已经膜拜过")
            end)
        else
            mobai:setSaturation(0)
            self:registerClickEvent(mobai, function()
                self:worshipChampion(i)
            end)
            if not mobai.anim then
                local mc1 = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true, false)
                mc1:setName("anim")
                mc1:setPosition(mobai:getContentSize().width*0.5, mobai:getContentSize().height*0.5+1)
                mobai:addChild(mc1, 1)
                mobai.anim = mc1
            else
                mobai.anim:setVisible(true)
            end
        end
    end


    -- 按钮
    for i=1,3 do
        local selectBtn = self:getUI("rightMenuNode." .. selectStr[i])
        local selectAnim = mcMgr:createViewMC("zhengbasaixuanzhong_zhandoukaiqi", true, false)
        selectAnim:setPosition(selectBtn:getContentSize().width*0.5,selectBtn:getContentSize().height*0.5-10)
        selectBtn:addChild(selectAnim, 5)
        selectAnim:setVisible(false)
        selectBtn.selectAnim = selectAnim
    end
end

function GodWarView:setBtnAnim(powId, isSelected)
    local selectBtn = self:getUI("rightMenuNode." .. selectStr[powId])
    if selectBtn.selectAnim then
        selectBtn.selectAnim:setVisible(isSelected)
    end
    if isSelected == true then
        selectBtn:setBright(false)
        selectBtn:setEnabled(false)
    else
        selectBtn:setBright(true)
        selectBtn:setEnabled(true)
    end
end

function GodWarView:getCheckBtnState(powerId)
    print("powerId============",powerId)
    local curServerTime = self._userModel:getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", curServerTime))
    local flag = false
    if weekday == 3 then
        if powerId == 1 then
            local begTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 19:30:00"))
            local endTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:09:00"))
            if curServerTime >= begTime and curServerTime <= endTime then
                flag = true
            end
        elseif powerId == 2 or powerId == 3 or powerId == 4 then
            local roundTime = readlyTime + fightTime*3
            local minTime = math.floor((roundTime*powerId)/60)
            local begTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
            local endTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:" .. minTime .. ":00"))
            if curServerTime >= begTime and curServerTime <= endTime then
                flag = true
            end
        end
    elseif weekday == 4 then
        if powerId == 5 then
            local begTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 19:30:00"))
            local endTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:" .. 9 .. ":00"))
            if curServerTime >= begTime and curServerTime <= endTime then
                flag = true
            end
        elseif powerId == 6 then
            local begTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
            local endTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:" .. 18 .. ":00"))
            if curServerTime >= begTime and curServerTime <= endTime then
                flag = true
            end
        elseif powerId == 7 then
            local begTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:18:00"))
            local endTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:29:00"))
            if curServerTime >= begTime and curServerTime <= endTime then
                flag = true
            end
        elseif powerId == 8 then
            local begTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:18:00"))
            local endTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:29:00"))
            if curServerTime >= begTime and curServerTime <= endTime then
                flag = true
            end
        end
    end

    print("flag============", flag)
    return flag
end


-- 获取当前是哪一场
function GodWarView:getStrPower(powerId)
    -- print("powerId=====", powerId, debug.traceback())
    local round, ju = 1, 1
    local curServerTime = self._userModel:getCurServerTime()
    if powerId == 32 then
        local beginBattle = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
        local allTime = curServerTime - beginBattle
        ju = math.floor(allTime/fightTime)
        round = math.floor(ju/3)
        ju = ju - round*3 + 1
        round = round + 1
    elseif powerId == 8 then
        local beginBattle = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
        local roundTime = readlyTime+fightTime*3
        local allTime = curServerTime - beginBattle
        round = math.floor(allTime/roundTime)

        local tTime = allTime - round*roundTime
        if tTime < (readlyTime+fightTime) then
            ju = 1
        elseif tTime < (readlyTime+fightTime*2) then
            ju = 2
        elseif tTime < (readlyTime+fightTime*3) then
            ju = 3
        end
        round = round + 1
        if curServerTime < beginBattle then
            round = 1
            ju = 1
        end
        -- print("round, ju=======", round, ju)
    elseif powerId == 4 then
        local beginBattle = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
        local roundTime = readlyTime+fightTime*3
        local allTime = curServerTime - beginBattle
        round = math.floor(allTime/roundTime)

        local tTime = allTime - round*roundTime
        if tTime < (readlyTime+fightTime) then
            ju = 1
        elseif tTime < (readlyTime+fightTime*2) then
            ju = 2
        elseif tTime < (readlyTime+fightTime*3) then
            ju = 3
        end
        round = round + 1
        if curServerTime < beginBattle then
            round = 1
            ju = 1
        end
        -- local allTime = curServerTime - beginBattle
        -- ju = math.floor(allTime/fightTime)
        -- -- print("===========", allTime, jiange)
        -- round = math.floor(ju/3)
        -- ju = ju - round*3 + 1
        -- round = round + 1
        -- if curServerTime < beginBattle then
        --     round = 1
        --     ju = 1
        -- end
        -- print("===round========", round, ju)
    -- elseif powerId == 3 then
    --     local beginBattle = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:18:00"))
    --     local readlyTime = 300
    --     local roundTime = readlyTime+fightTime*3
    --     local allTime = curServerTime - beginBattle
    --     round = math.floor(allTime/roundTime)

    --     local tTime = allTime - round*roundTime
    --     if tTime < (readlyTime+fightTime) then
    --         ju = 1
    --     elseif tTime < (readlyTime+fightTime*2) then
    --         ju = 2
    --     elseif tTime < (readlyTime+fightTime*3) then
    --         ju = 3
    --     end
    --     round = 1
    elseif powerId == 2 then
        local beginBattle = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:18:00"))
        local readlyTime = 300
        local roundTime = readlyTime+fightTime*3
        local allTime = curServerTime - beginBattle
        round = math.floor(allTime/roundTime)

        local tTime = allTime - round*roundTime
        if tTime < (readlyTime+fightTime) then
            ju = 1
        elseif tTime < (readlyTime+fightTime*2) then
            ju = 2
        elseif tTime < (readlyTime+fightTime*3) then
            ju = 3
        end
        round = 1
    end
    return round, ju
end


function GodWarView:getGodWarTitle()
    -- local state, indexId = self._godWarModel:getStatus()
    local indexId = self:getNextTimer()
    local matchTime = self._godWarModel:getGodWarMatchTime()
    print("indexId========", indexId)
    dump(matchTime)
    local battleTime = matchTime[indexId]
    -- local data = tab:GodWarTimer(indexId)
    local isshow = true
    local power = 0
    local updateLayer = 0
    local calpos = 0

    -- 展示
    local str = ""
        if indexId == 0 or indexId == 1 then
            isshow = false
            power = 0
            calpos = 0
        elseif indexId == 2 then
            str = "分组抽签倒计时: "
            power = 0
            updateLayer = 1
            calpos = 1
        elseif indexId == 3 then
            str = "小组赛开启倒计时: "
            power = 0
            calpos = 1
        elseif indexId == 4 then
            str = "正在进行: 小组赛第"
            power = 32
            updateLayer = 2
            calpos = 0
        elseif indexId == 5 then
            str = "8强赛开启倒计时: "
            power = 0
            calpos = 1
        elseif indexId == 6 then
            str = "正在进行: 8强赛第"
            power = 8
            updateLayer = 3
            calpos = 0
        elseif indexId == 7 then
            str = "4强赛开启倒计时: "
            power = 0
            calpos = 1
        elseif indexId == 8 then
            str = "正在进行: 半决赛第"
            power = 4
            updateLayer = 4
            calpos = 0
        elseif indexId == 9 then
            str = "  总决赛准备中"
            power = 0
            calpos = 0
        elseif indexId == 10 then
            str = "正在进行: 总决赛"
            power = 2
            updateLayer = 5
            calpos = 0
        else
            battleTime = matchTime[14]
            str = "  下届开启: "
            power = 0
            calpos = 1
        end

    -- local timeBg = self:getUI("titleBg.timeBg")
    -- timeBg:setVisible(isshow)

    local maxTime = battleTime[2]
    local fuTitle = self:getUI("titleBg.timeBg.fuTitle")
    local fuTime = self:getUI("titleBg.timeBg.fuTime")
    local fuTitle1 = self:getUI("bg.layer3.powtu.poetimeBg.fuTitle")
    local fuTime1 = self:getUI("bg.layer3.powtu.poetimeBg.fuTime")
    local callFunc = cc.CallFunc:create(function()
        local curServerTime = self._userModel:getCurServerTime()
        local tempTime = maxTime - curServerTime
        local showTime = ""
        if power == 0 then
            local tempValue = tempTime
            local day, hour, minute, second
            day = math.floor(tempValue/86400)
            tempValue = tempValue - day*86400
            hour = math.floor(tempValue/3600)
            tempValue = tempValue - hour*3600
            minute = math.floor(tempValue/60)
            tempValue = tempValue - minute*60
            second = math.fmod(tempValue, 60)

            if tempTime < 86400 and tempTime > 0 then
                showTime = string.format("%.2d:%.2d:%.2d", hour, minute, second)
            elseif tempTime > 0 then
                showTime = string.format("%d天%.2d:%.2d:%.2d", day, hour, minute, second)
            else
                showTime = string.format("%.2d:%.2d:%.2d", 0, 0, 0)
            end
        else
            local round = self:getStrPower(power)
            -- if self._tRound ~= round then
            --     --todo 忘了要写啥
            -- end
            -- self._tRound = round
            showTime = round .. "场"
        end
        -- local showStr = str .. showTime
        -- print("getGodWarTitle >= getGodWarTitle====", curServerTime, maxTime)
        if curServerTime > maxTime+1 then
            if updateLayer ~= 0 then
                self:getResultData(updateLayer)
            end
            self:getGodWarTitle()
        end
        if calpos == 1 then -- 算位置
            fuTitle:setString(str)
            fuTitle1:setString(str)
            fuTime:setString(showTime)
            fuTime1:setString(showTime)
            local timeBg = self:getUI("titleBg.timeBg")
            local posx = timeBg:getContentSize().width - fuTitle:getContentSize().width - fuTime:getContentSize().width
            local posBeg = 29
            fuTitle:setPositionX(posBeg)
            fuTitle1:setPositionX(posBeg)
            posBeg = posBeg + fuTitle:getContentSize().width
            fuTime:setPositionX(posBeg)
            fuTime1:setPositionX(posBeg)
        else -- 固定位置
            fuTitle:setString(str)
            fuTitle1:setString(str)
            fuTime:setString(showTime)
            fuTime1:setString(showTime)
            local timeBg = self:getUI("titleBg.timeBg")
            local posx = timeBg:getContentSize().width - fuTitle:getContentSize().width - fuTime:getContentSize().width
            local posBeg = posx * 0.5
            fuTitle:setPositionX(posBeg)
            fuTitle1:setPositionX(posBeg)
            posBeg = posBeg + fuTitle:getContentSize().width
            fuTime:setPositionX(posBeg)
            fuTime1:setPositionX(posBeg)
        end
    end)
    local seq = cc.Sequence:create(callFunc, cc.DelayTime:create(1))
    fuTitle:stopAllActions()
    fuTitle:runAction(cc.RepeatForever:create(seq))
end


-- 布阵

-- 是否展示布阵按钮
function GodWarView:isShowFormation()
    local formationState = 1
    local curServerTime = self._userModel:getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", curServerTime))
    local userId = self._userModel:getData()._id
    local playerData = self._godWarModel:getPlayerById(userId)
    if not playerData then
        return 0
    end
    if weekday == 2 then
        local tminTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:18:00"))
        if curServerTime > tminTime then
            if playerData.r >= 32 then
                formationState = 0
            end
        end
        local tBegTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
        local tEndTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:18:00"))
        if curServerTime > tBegTime and curServerTime < tEndTime then
            formationState = 0
        end
    elseif weekday == 3 then
        local tminTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:36:00"))
        if curServerTime > tminTime then
            if playerData.r >= 8 then
                formationState = 0
            end
        elseif playerData.r > 8 then
            formationState = 0
        end
        local tBegTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
        local tEndTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:36:00"))
        if curServerTime > tBegTime and curServerTime < tEndTime then
            formationState = 0
        end
    elseif weekday == 4 then
        local tminTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:29:00"))
        if curServerTime > tminTime then
            formationState = 0
        elseif playerData.r > 4 then
            formationState = 0
        end
        local tBegTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
        local tEndTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:18:00"))
        if curServerTime > tBegTime and curServerTime < tEndTime then
            formationState = 0
        end
        -- local tBegTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:18:00"))
        -- local tEndTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:23:00"))
        -- if playerData.r == 4 then
        --     if curServerTime > tBegTime and curServerTime < tEndTime then
        --         formationState = 0
        --     end
        -- end
        local tBegTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:23:00"))
        local tEndTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:29:00"))
        -- if curServerTime > tBegTime and curServerTime < tEndTime then
        --     formationState = 0
        -- end
        if curServerTime > tBegTime then
            formationState = 0
        end
    end
    -- 只在比赛周的膜拜之前显示
    local idx = self:getNextTimer()
    if idx >= 11 then
        formationState = 0
    end
    -- print("====formationState+++++==========", formationState)
    return formationState
end

-- 布阵
function GodWarView:showFormation()
    local param = self:getformationAfferentData()
    self._viewMgr:showView("formation.NewFormationView", param)
    self._formationView = true
end

-- 布阵
function GodWarView:getformationAfferentData()
    local allowBattle, endTime, formationType = self:getformationParameter()
    local formationModel = self._formationModel
    local formationType = formationModel["kFormationTypeGodWar" .. formationType]
    dump(allowBattle)
    print("endTime========", endTime)
    if not endTime then
        endTime = 0
    end
    local param = {
        formationType = formationType,
        extend = {
            godWarInfo = {endTime = endTime},
            allowBattle = {
                [formationModel.kFormationTypeGodWar1] = allowBattle[1],
                [formationModel.kFormationTypeGodWar2] = allowBattle[2],
                [formationModel.kFormationTypeGodWar3] = allowBattle[3],
            }
        },
        closeCallback = function ( ... )
            self._viewMgr:popView()
            self._formationView = nil
        end
    }
    return param
end

function GodWarView:getPow()
    local curServerTime = self._userModel:getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", curServerTime))
    local tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:36:00"))
    local pow = 8
    if weekday == 3 then
        if tempTime < curServerTime then
            pow = 4
        end
    elseif weekday == 4 then
        tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:18:00"))
        pow = 4
        if tempTime < curServerTime then
            pow = 2
        end
    end
    print("selfroundpow===", pow)
    return pow
end

function GodWarView:getSelfRound()
    local powData = self._godWarModel:getPowData()
    local userid = self._userid
    local round = 0
    local pow = self:getPow()
    if not powData then
        return 1
    end
    for k,v in ipairs(powData) do
        if userid == v.atk or userid == v.def then
            if v.pow == pow then
                round = v.round
                break
            end
        end
    end
    dump(powData)
    print("selfroundpow===", pow, round)
    return round
end

function GodWarView:getformationParameter()
    local formationState, formationTime = 0, 0
    local curServerTime = self._userModel:getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", curServerTime))
    local godwarConst = self._userModel:getGodWarConstData()
    local season = godwarConst.SEASON

    local tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
    print("tempTime  ",tempTime)
    local endTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:36:00"))
    print("endTime  ",endTime)
    local round = self:getSelfRound()
    print("getSelfRound  ",getSelfRound)
    local readlyTime = readlyTime
    local roundTime = readlyTime + fightTime*3
    local begTime = tempTime
    local tfortime = 0
    local canForType = 0
    if weekday == 1 then
        endTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 12:00:00"))
        if curServerTime > endTime then
            tfortime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime+86400,"%Y-%m-%d 20:00:00"))
        end
    elseif weekday == 2 then
        endTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:18:00"))
        local round, _ = self:getStrPower(self._pow)
        -- roundTime = math.abs((round-1)*3*jiange)
        begTime = begTime + roundTime
        if curServerTime > endTime then
            tfortime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime+86400,"%Y-%m-%d 20:00:00"))
            canForType = 5
        end
        -- local ttime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 19:30:00"))
        -- if season == 1 and curServerTime < ttime then
        --     tfortime = ttime
        -- end
    elseif weekday == 3 then
        endTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:36:00"))
        begTime = begTime + roundTime
        if curServerTime > endTime then
            tfortime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime+86400,"%Y-%m-%d 20:00:00"))
            canForType = 5
        end
    elseif weekday == 4 then
        endTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:22:55"))
        if self._pow == 2 then
            readlyTime = 300
            roundTime = readlyTime + fightTime*3
            endTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:29:00"))
            tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:23:00"))
            begTime = tempTime
        end
        begTime = begTime + math.abs(roundTime)
        if curServerTime > endTime then
            tfortime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime+86400,"%Y-%m-%d 20:00:00"))
            canForType = 5
        end
    end

    print("begTime==========", self._pow, begTime, endTime)
    local tTime = {}
    local wholeTime = {}
    for i=1,3 do
        local indexId = i
        local closeTime = begTime + indexId*fightTime + readlyTime - 3
        tTime[indexId] = closeTime
        if indexId == 3 then
            tTime[4] = begTime + indexId*fightTime + readlyTime
        end
        local wTime = {}
        wTime[1] = closeTime
        wTime[2] = begTime + indexId*fightTime + readlyTime
        wholeTime[indexId] = wTime
    end
    table.insert(tTime, endTime)
    dump(tTime)
    -- dump(wholeTime)
    local canForamtion = 5
    for i=1,4 do
        local sTime = tTime[i]
        if curServerTime < sTime then
            canForamtion = i
            break
        end
    end
    if canForType ~= 0 then
        canForamtion = canForType
    end
    local allowBattle = {}
    local formationType = 1
    local formationTime = tTime[canForamtion]
    if canForamtion == 0 or canForamtion == 1 then
        allowBattle[1] = true
        allowBattle[2] = true
        allowBattle[3] = true
        formationType = 1
        formationTime = tTime[1]
    elseif canForamtion == 2 then
        allowBattle[1] = false
        allowBattle[2] = true
        allowBattle[3] = true
        formationType = 2
    elseif canForamtion == 3 then
        allowBattle[1] = false
        allowBattle[2] = false
        allowBattle[3] = true
        formationType = 3
    elseif canForamtion == 4 then
        allowBattle[1] = true
        allowBattle[2] = true
        allowBattle[3] = false
        formationType = 1
    elseif canForamtion == 5 then
        allowBattle[1] = true
        allowBattle[2] = true
        allowBattle[3] = true
        formationType = 1
    end
    if tfortime ~= 0 then
        formationTime = tfortime
        formationType = 1
    end
    if weekday == 1 then
        allowBattle[1] = true
        allowBattle[2] = true
        allowBattle[3] = true
        formationType = 1
    end
    print("formationTime=========",canForamtion, formationTime, formationType)
    return allowBattle, formationTime, formationType
end

function GodWarView:updateRelationshipImg(indexId, war, xian, winData, state)
    local data = war[indexId]
    -- print("indexId=++++++++++++==", indexId, data, state)
    local headBg = self:getUI("bg.layer3.powtu.headBg" .. indexId)
    local headName = self:getUI("bg.layer3.powtu.headBg" .. indexId .. ".name")
    local headNameBg = self:getUI("bg.layer3.powtu.headBg" .. indexId .. ".nameBg")
    local line = self:getUI("bg.layer3.powtu.line" .. indexId)
    local vertical = self:getUI("bg.layer3.powtu.vertical" .. indexId)
    local resultImg = self:getUI("bg.layer3.powtu.headBg" .. indexId .. ".resultImg")

    local posId = 4
    if indexId <= 8 then
        posId = 1
    elseif indexId <= 12 then
        posId = 2
    elseif indexId <= 14 then
        posId = 3
    elseif indexId > 15 then
        posId = 5
    end
    local tPosTab = posTab[posId]
    if self._userid == data then
        local playSelf = headBg:getChildByName("playSelf")
        local rplaySelfPos = playSelfPos[posId]
        if not playSelf then
            playSelf = cc.Sprite:createWithSpriteFrameName("godwarImageUI_img129.png")
            playSelf:setName("playSelf")
            headBg:addChild(playSelf, 10)
        end
        playSelf:setScale(rplaySelfPos[3])
        playSelf:setPosition(rplaySelfPos[1], headBg:getContentSize().height*0.5 + rplaySelfPos[2])
        playSelf:setVisible(true)

        headName:setColor(cc.c3b(255,208,65))
    else
        local playSelf = headBg:getChildByName("playSelf")
        if playSelf then
            playSelf:setVisible(false)
        end
    end
    -- print("data============", data)
    if data ~= 0 then
        local atkData = self._godWarModel:getPlayerById(data)
        local param1 = {avatar = atkData.avatar, tp = 4,avatarFrame = atkData["avatarFrame"]}
        local icon = headBg:getChildByName("icon")
        if not icon then
            icon = IconUtils:createHeadIconById(param1)
            icon:setName("icon")
            icon:setScale(tPosTab[3])
            icon:setPosition(tPosTab[1], tPosTab[2])
            headBg:addChild(icon)
        else
            IconUtils:updateHeadIconByView(icon, param1)
        end
        self:registerClickEvent(headBg, function()
            local data = {tagId = data, fid = 101}
            self:getTargetGodWarUserInfo(data)
        end)

        headNameBg:setVisible(true)
        headName:setVisible(true)
        headName:setString(atkData.name)

        -- local showLine = math.floor((indexId+1)/2)
        -- local vertical = self:getUI("bg.layer3.powtu.vertical" .. showLine)
        -- local lineType = xian[indexId][1]
        -- print("indexId=======", indexId, showLine, lineType)
        -- if vertical then
        --     vertical:setVisible(false)
        -- end
        -- if lineType ~= 0 then
        --     vertical:setVisible(true)
        --     if lineType == 1 then
        --     elseif lineType == 2 then
        --         vertical:setVisible(true)
        --     end
        --     -- if resultImg then
        --     --     resultImg:setVisible(false)
        --     -- end
        -- end
        -- if xian[indexId][2] == 1 then
        --     if vertical then
        --         vertical:setVisible(true)
        --     end
        -- else
        --     if vertical then
        --         vertical:setVisible(false)
        --     end
        -- end
        if state == 4 then
            if winData[indexId] == 0 then
                if resultImg then
                    resultImg:setVisible(true)
                    resultImg:loadTexture("godwarImageUI_img79.png", 1)
                    icon:setSaturation(-100)
                end
            else
                if resultImg then
                    resultImg:setVisible(false)
                end
            end
        else
            icon:setSaturation(0)
            if resultImg then
                resultImg:setVisible(false)
            end
        end
    else
        local param1 = {art = "globalImageUI_secretIcon", tp = 4,avatarFrame = 1000}
        local icon = headBg:getChildByName("icon")
        if not icon then
            icon = IconUtils:createHeadIconById(param1)
            icon:setName("icon")
            icon:setScale(tPosTab[3])
            icon:setPosition(tPosTab[1], tPosTab[2])
            headBg:addChild(icon)
        else
            IconUtils:updateHeadIconByView(icon, param1)
        end

        resultImg:setVisible(false)
        headName:setVisible(false)
        headNameBg:setVisible(false)

        if line then
            -- line:loadTexture("godwarImageUI_img26.png", 1)
            line:setVisible(false)
        end
        if vertical then
            -- vertical:loadTexture("godwarImageUI_img26.png", 1)
            vertical:setVisible(false)
        end
    end
end


function GodWarView:checkTips()
    local noticeMap = {
        -- 布阵
        {iconName = "btnbg.buzhenBtn",detectFuc = function()
            local godWarModel = self._modelMgr:getModel("GodWarModel")
            local flag = godWarModel:getGodwarFormationTip()
            return flag 
        end},

        -- 押注
        {iconName = "leftMenuNode.yazhuBtn",detectFuc = function()
            local godWarModel = self._modelMgr:getModel("GodWarModel")
            local flag = godWarModel:getWarStakeTip()
            return flag 
        end},
        -- 押注
        {iconName = "leftMenuNode.zhichiBtn",detectFuc = function()
            local godWarModel = self._modelMgr:getModel("GodWarModel")
            local flag = godWarModel:getWarStakeTip()
            return flag 
        end},
    }

    -- 红点处理
    for k,v in pairs(noticeMap) do
        local hint = false
        if v.detectFuc then
            hint = v.detectFuc()
        end
        if v.iconName == "btnbg.buzhenBtn" then
            local buzhenBtn = self:getUI(v.iconName)
            if buzhenBtn.formationAnim then
                if hint == true then
                    buzhenBtn.formationAnim:play()
                else
                    buzhenBtn.formationAnim:stop()
                end
            end
        end
        print("=hinthint========", v.iconName, hint)
        self:setHintTip(v.iconName, hint)
    end
end

function GodWarView:setHintTip(btnName, hint)
    local btnName = self:getUI(btnName)
    if not btnName then
        return
    end
    if btnName then
        btnNameTip = btnName:getChildByName("btnNameTip")
        if btnNameTip then
            btnNameTip:setVisible(hint)
        else
            btnNameTip = cc.Sprite:createWithSpriteFrameName("globalImageUI_bag_keyihecheng.png")
            btnNameTip:setName("btnNameTip")
            btnNameTip:setAnchorPoint(cc.p(0,0))
            btnNameTip:setPosition(cc.p(btnName:getContentSize().width - 26, btnName:getContentSize().height*0.5 + 17))
            btnName:addChild(btnNameTip, 10)
            btnNameTip:setVisible(hint)
        end
    end
end

function GodWarView:applicationWillEnterForeground(second)
    print("second=====", second)
    self._serverMgr:sendMsg("GodWarServer", "enterGodWar", {}, true, {}, function (result)
        self:reflashUI()
    end)
end

function GodWarView:updateBuff()
    local buffBg = self:getUI("bg.buffBg")

    local curServerTime = self._userModel:getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", curServerTime))
    local godWarConstData = self._userModel:getGodWarConstData()
    local begTime = godWarConstData["RACE_BEG"] + 17*3600
    local endTime = godWarConstData["RACE_END"]
    if (curServerTime < begTime) or (curServerTime > endTime) then
        buffBg:setVisible(false)
        return
    else
        buffBg:setVisible(true)
    end

    self:updateBuffBtn()
    local buffBtn = self:getUI("bg.buffBg.buffBtn")
    local buyBuff = self:getUI("bg.buffBg.buyBuff")
    buyBuff:setTitleFontSize(18)

    local privilegesTip = self:getUI("privilegesTip")
    privilegesTip:setVisible(false)
    local closePrivilegesTip = self:getUI("privilegesTip.closePrivilegesTip")
    self:registerClickEvent(closePrivilegesTip, function()
        privilegesTip:setVisible(false)
    end)

    self:registerClickEvent(buyBuff, function()
        self._viewMgr:showView("privileges.PrivilegesView")
    end)

    self:registerClickEvent(buffBtn, function()
        local privilegesTip = self:getUI("privilegesTip")
        privilegesTip:setCapInsets(cc.rect(30, 30, 30, 30))
        self:showPrivilegesBuffTip(privilegesTip)
    end)
end

function GodWarView:updateBuffBtn()
    local buyBuff = self:getUI("bg.buffBg.buyBuff")
    local buyBuffBg = self:getUI("bg.buffBg.buyBuffBg")
    local buffNum = self:showPrivilegesBuffTipNum()
    local tbuffNum = tab:Setting("G_PRIVILEGES_SHOP_BUFF_NUM").value
    if buffNum >= tbuffNum then
        buyBuff:setVisible(false)
        buyBuffBg:setVisible(false)
    else
        buyBuff:setVisible(true)
        buyBuffBg:setVisible(true)
    end
end

function GodWarView:showPrivilegesBuffTipNum()
    self._privilegeModel = self._modelMgr:getModel("PrivilegesModel")
    local buffSum = {}
    local tbuffNum = tab:Setting("G_PRIVILEGES_SHOP_BUFF_NUM").value
    for i=1,tbuffNum do
        local flag, buffId = self._privilegeModel:getKingBuff(i)
        local buffNum = tonumber(buffId)
        local buffTab = tab:PeerShop(buffNum)
        if flag == true then
            table.insert(buffSum, i)
        end
    end
    return table.nums(buffSum)
end

-- 特权buff tips
function GodWarView:showPrivilegesBuffTip(inView)
    inView:setVisible(true)
    self._privilegeModel = self._modelMgr:getModel("PrivilegesModel")
    local buffSum = {}
    local tbuffNum = tab:Setting("G_PRIVILEGES_SHOP_BUFF_NUM").value
    for i=1,tbuffNum do
        local buffIcon = inView:getChildByName("buffIcon" .. i)
        if buffIcon then
            buffIcon:setVisible(false)
        end
        local richText = inView:getChildByName("richText" .. i)
        if richText then
            richText:removeFromParent()
        end
        local flag, buffId = self._privilegeModel:getKingBuff(i)
        local buffNum = tonumber(buffId)
        local buffTab = tab:PeerShop(buffNum)
        if flag == true then
            table.insert(buffSum, i)
        end
    end

    if buffSum and table.nums(buffSum) < 1 then
        -- self._viewMgr:showTip("暂未购买特权buff")
        local callback = function()
            self._viewMgr:showView("privileges.PrivilegesView")
        end
        self._viewMgr:showDialog("global.GlobalSelectDialog", {desc = lang("TIPS_UI_DES_12"), button1 = "", callback1 = callback, 
            button2 = "", callback2 = nil,titileTip="温馨提示", title = "温馨提示"},true)
        inView:setVisible(false)
    end

    local tsplit = function(str,reps)
        local des = string.gsub(str,"%b{}",function( lvStr )
            local str = string.gsub(lvStr,"%$num",reps)
            return loadstring("return " .. string.gsub(str, "[{}]", ""))()
        end)
        return des 
    end

    local posY = table.nums(buffSum)*40 + 20
    inView:setContentSize(cc.size(220, posY))
    posY = posY - 10
    for i=1,table.nums(buffSum) do
        local indexId = buffSum[i]
        local flag, buffId = self._privilegeModel:getKingBuff(indexId)
        local buffNum = tonumber(buffId)
        local buffTab = tab:PeerShop(buffNum)
        local param = {image = buffTab.icon .. ".png", quality = 5, scale = 0.90, bigpeer = true}
        local buffIcon = inView:getChildByName("buffIcon" .. i)
        if buffIcon then
            IconUtils:updatePeerageIconByView(buffIcon, param)
        else
            buffIcon = IconUtils:createPeerageIconById(param)
            buffIcon:setAnchorPoint(0.5, 0.5)
            buffIcon:setScale(0.3)
            buffIcon:setName("buffIcon" .. i)
            inView:addChild(buffIcon)
        end
        buffIcon:setPosition(35,posY - i*38 + 19)
        buffIcon:setVisible(true)

        local sysBuf = buffTab.buff
        local str = lang(buffTab.des)
        str = tsplit(str,sysBuf[2])
        local result, count = string.gsub(str, "$num", sysBuf[2])
        if count > 0 then 
            str = result
        end
        local richText = inView:getChildByName("richText" .. i)
        if richText then
            richText:removeFromParent()
        end
        richText = RichTextFactory:create(str, 180, 40)
        richText:formatText()
        richText:setPosition(140, posY - i*38 + 19)
        richText:setName("richText" .. i)
        inView:addChild(richText)
    end
end




function GodWarView.dtor()
    posTab = nil 
    promotionTab = nil 
    godWarGroupMax = nil 
    selectStr = nil
end 

return GodWarView