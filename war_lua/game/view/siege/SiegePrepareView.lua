--[[
    @FileName   SiegePrepareView.lua
    @Authors    zhangtao
    @Date       2017-09-05 20:54:19
    @Email      <zhangtao@playcrad.com>
    @Description   攻城准备UI
--]]
local SiegePrepareView = class("SiegePrepareView",BasePopView)
function SiegePrepareView:ctor(data)
    self.super.ctor(self)
    self._siegeType = 1    --城池战类型 1-表示攻城活动  2-攻城活动主城   3-守城活动
    self._closeCallback = data.closeCallback
    self._battleCallback = data.battleCallback
    self._stageId = data.stageId   --城市id

    print("self._stageId=========",self._stageId)
    -- self._stageId = 30001
    self.popAnim = false
    self._siegeModel = self._modelMgr:getModel("SiegeModel")

    self._formationModel = self._modelMgr:getModel("FormationModel")
    self.FormationTypes  = {
                            self._formationModel.kFormationTypeWeapon,
                            self._formationModel.kFormationTypeWeapon,
                            self._formationModel.kFormationTypeWeaponDef
                        }
    self._battleFunciton = {
        [1] = BattleUtils.enterBattleView_Siege_Atk_WE,
        [2] = BattleUtils.enterBattleView_Siege_Atk_WE,
        [3] = BattleUtils.enterBattleView_Siege_Def_WE,
    }
    self._interfaceStr = {
        [2] = "getAtkProgressReward",
        [3] = "getDefendProgressReward"    
    }
    self._timesTitleDesc = {
                                [1] = "攻城次数：",
                                [2] = "攻城次数：",
                                [3] = "守城次数："
                            }
end

function SiegePrepareView:onShow()
    self:updateRealVisible(true)
end

function SiegePrepareView:onTop()
    self:updateRealVisible(true)
end

-- 初始化UI后会调用, 有需要请覆盖
function SiegePrepareView:onInit()
    self:setWidgetContentSize(ADOPT_IPHONEX and MAX_SCREEN_WIDTH - 120 or MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self:getUI("topBg"):setContentSize(MAX_SCREEN_WIDTH, 84)
    self:getUI("bottomImage"):setContentSize(MAX_SCREEN_WIDTH, 190)


    self._siegeType = tab.siegeMainStage[self._stageId]["type"]    --城市类型
    print("======self._siegeType======="..self._siegeType)
    local btn_return = self:getUI("btn_return")
    registerClickEvent(btn_return,function()
        self:close()
        UIUtils:reloadLuaFile("siege.SiegePrepareView")
    end)

    self:getUI("bottomNode.fightBg.fightTimesDes"):setString(self._timesTitleDesc[self._siegeType])
    --修建城墙
    self._fixWallBtn = self:getUI("fixWallBtn")
    registerClickEvent(self._fixWallBtn,function()
     self._viewMgr:showDialog("siege.SiegeWallReinforceView",{callBack = specialize(self.checkWallRedFlag, self)},true)
    end)
    --开战按钮
    self.fightBg = self:getUI("bottomNode.fightBg")
    self._fightBtn = self:getUI("bottomNode.fightBg.fightBtn")
    self._fightImage = self:getUI("bottomNode.fightBg.fightBtn.fightImage")
    registerClickEvent(self._fightBtn,function()
        local isPass = self._siegeModel:isStagePass(self._stageId)
        if isPass then
            local noticeString = {[1]="城池已经被攻破",[2]="城池已经被攻破",[3]="守城活动已结束"}
            self._viewMgr:showTip(noticeString[self._siegeType])

            return
        end

        local totalTimes,hasTimes = self._siegeModel:getChannelTimes()
        if hasTimes == 0 then
            self._viewMgr:showTip("今日挑战次数已用完")
            return
        end
        self:enterFormation()
    end)
    --最后一击背景
    self._luckyBg = self:getUI("bottomNode.luckyBg")
    --排行
    self._rankNameList = {
        self:getUI("bottomNode.rankBg.rankName1"),
        self:getUI("bottomNode.rankBg.rankName2"),
        self:getUI("bottomNode.rankBg.rankName3")
    }
    self._rankValueList = {
        self:getUI("bottomNode.rankBg.hurtValue1"),
        self:getUI("bottomNode.rankBg.hurtValue2"),
        self:getUI("bottomNode.rankBg.hurtValue3")
    }
    --攻城活动top背景
    self._itemBg = self:getUI("itemBg")
    --攻城、守城 主城top背景
    self._itemAwardBg = self:getUI("itemAwardBg")

    --初始化最大血量配表
    -- local siegeData = self._siegeModel:getData()
    -- dump(siegeData,"siegeData")
    -- self.maxBloodTable = 
    -- {
    --     [10001] = siegeData["blood1"],
    --     [10002] = siegeData["blood2"],
    --     [10003] = siegeData["blood3"],
    --     [10004] = siegeData["blood4"],
    --     [10005] = siegeData["blood5"]
    -- }
    -- --初始化攻打血量
    -- self.hurtBloodTable = 
    -- {
    --     [10001] = siegeData["sbl1"],
    --     [10002] = siegeData["sbl2"],
    --     [10003] = siegeData["sbl3"],
    --     [10004] = siegeData["sbl4"],
    --     [10005] = siegeData["sbl5"]
    -- }
    --宝箱进度和奖励
    self._progressTable = {}
    self._boxAwardTable = {}
    --血量进度条
    self._bloodProgress = self:getUI("itemBg.progressBg.progressBar")
    --奖励进度条
    self._awardProgress = self:getUI("itemAwardBg.progressBg.progressBar")
    self:adjustFightBtn()
    self:setMenuClick()

    -- self:showWallOpen()
    -- self:upDataUI()
    local cacheId = SystemUtils.loadAccountLocalData("SiegeStageId")
    if cacheId == nil or self._stageId > cacheId then
        SystemUtils.saveAccountLocalData("SiegeStageId", self._stageId)
    end
    self:setListenReflashWithParam(true)
    self:listenReflash("SiegeModel", self.pushUpDataCurSiegeUI)
end

--城池部位开启提示
function SiegePrepareView:showWallOpen()
    if self._siegeType == 3 then
        local cityDatas = self._siegeModel:getWallFunctionInfo()
        local currLevel = self._siegeModel:getWallCurLevel()
        -- currLevel = 10
        for i,v in ipairs(cityDatas) do
            local condition = v.openLevel
            if condition <= currLevel then
                local openState = SystemUtils.loadAccountLocalData("SiegeWall_"..v["tags"])
                if not openState then
                    SystemUtils.saveAccountLocalData("SiegeWall_"..v["tags"], 1)
                    self._viewMgr:showDialog("siege.SiegeWallOpenAniView",{callBack = specialize(self.showWallOpen, self),name = v.name,icon = v.icon})
                end
            end 
        end
    end
end

--调整战斗按钮位置
function SiegePrepareView:adjustFightBtn()
    if MAX_SCREEN_WIDTH == 960 then return end
    local x,y = self._luckyBg:getPosition()
    local contentSize = self._luckyBg:getContentSize()
    local fightPosX = (MAX_SCREEN_WIDTH - x - contentSize.width/2)/2 + x + contentSize.width/2 - 90
    self.fightBg:setPosition(fightPosX,0)
end

function SiegePrepareView:upDataUI(result)
    self._progress = result["progress"]    --进度
    -- self._progress = 100
    local cityName = tab.siegeMainStage[self._stageId]["sectionName"]
    if self._siegeType == 1 then  --小城攻城
        self._itemBg:setVisible(true)
        self._itemAwardBg:setVisible(false)
        dump(self.maxBloodTable,"self.maxBloodTable")
        dump(self.hurtBloodTable,"self.hurtBloodTable")
        -- local maxValue = self.maxBloodTable[self._stageId]
        -- local hurtValue = self.hurtBloodTable[self._stageId]
        -- local hasBloodValue = maxValue - hurtValue
        
        -- print("barValue===="..barValue)
        -- self._bloodProgress:setPercent(barValue)
        local barValue = 100 - self._progress
        -- local scaleValue = barValue/100
        -- self._bloodProgress:setScale(scaleValue)

        self._bloodProgress:setPercent(barValue)

        local nameNode = self:getUI("itemBg.progressBg.cityName")
        nameNode:setString(lang(cityName))

        local labTexNode = self:getUI("itemBg.progressBg.labTex")
        -- labTexNode:setString("剩余血量:"..barValue .."%")
        local bloodKey = {
            [10001] = "blood1",
            [10002] = "blood2",
            [10003] = "blood3",
            [10004] = "blood4",
            [10005] = "blood5"
        }
        local blood = result["siege"][bloodKey[self._stageId]] or 0
        local bloodFormat = self:damageFormat(blood)
        labTexNode:setString("剩余血量:"..bloodFormat)
        self._fixWallBtn:setVisible(false)
    else
        self._itemBg:setVisible(false)
        self._itemAwardBg:setVisible(true)
        local nameNode = self:getUI("itemAwardBg.progressBg.cityName")
        nameNode:setString(lang(cityName)) 
        local barValue = self._progress
        self._awardProgress:setPercent(self._progress)
        local labTex1 = self._itemAwardBg:getChildByFullName("labTex1")
        local labTex2 = self._itemAwardBg:getChildByFullName("labTex2")
        if self._siegeType == 2 then   --主城攻城
            labTex2:setVisible(false)
            labTex1:setVisible(true)
            -- local maxValue = self.maxBloodTable[self._stageId]
            -- local hurtValue = self.hurtBloodTable[self._stageId]
            -- local hasBloodValue = maxValue - hurtValue
            labTex1:setString("攻城进度:"..barValue .."%")
            self._fixWallBtn:setVisible(false)
        else
            self._fixWallBtn:setVisible(true)
            labTex2:setVisible(true)
            labTex1:setVisible(false)
            local isPass = self._siegeModel:isStagePass(self._stageId)
            if not isPass then
                labTex2:setString("守城完成度:"..barValue .."%")
            else
                labTex2:setString("斯坦德威克守卫结束")
            end
        end
        self:setBoxAward()
    end

end
--设置奖励宝箱
function SiegePrepareView:setBoxAward()
    local rewardIdTable = self:getRewardIds()
    dump(rewardIdTable)
    local i = 3
    for id , value in pairs(rewardIdTable) do 
        -- 未领取
        local rewardBtn = self:getUI("itemAwardBg.progressBg.box" .. i .. ".notOpenState")
        -- 已领取
        local hasRewardBtn = self:getUI("itemAwardBg.progressBg.box" .. i .. ".openState")
        -- 动画节点
        local aniNodeBtn = self:getUI("itemAwardBg.progressBg.box" .. i .. ".aniNode")

        local mcName = "baoxiang"..i .."_baoxiang"
        if self._progress >= self._progressTable[id] then    --进度大于指定进度
            if value == 0 then                        --未领取
                rewardBtn:setVisible(false)
                hasRewardBtn:setVisible(false)
                if aniNodeBtn.boxAni == nil then 
                    boxAni = mcMgr:createViewMC(mcName, true)
                    boxAni:setPosition(aniNodeBtn:getPositionX(), aniNodeBtn:getPositionY())
                    aniNodeBtn.boxAni = boxAni
                    aniNodeBtn:addChild(boxAni,10)
                end
            else
                if aniNodeBtn.boxAni then
                    aniNodeBtn:removeAllChildren()
                    aniNodeBtn.boxAni = nil
                end
                rewardBtn:setVisible(false)
                hasRewardBtn:setVisible(true)
            end
        else
            rewardBtn:setVisible(true)
            hasRewardBtn:setVisible(false)
        end
        --未领取
        self:registerClickEvent(rewardBtn, function()
            local proText = lang("TIPS_SIEGE_AWARD_1")
            if self._siegeType == 3 then
                local proText = lang("TIPS_SIEGE_AWARD_2")
            end 
            proText = string.gsub(proText,"{$num}",self._progressTable[id])    
            DialogUtils.showGiftGet({ gifts = self._boxAwardTable[id], viewType = 2, des = proText}) 
        end)
        --已领取
        self:registerClickEvent(hasRewardBtn, function() 
            self._viewMgr:showTip(lang("TiPS_YILINGQU"))
        end)
        --领取
        self:registerClickEvent(aniNodeBtn, function() 
            self._serverMgr:sendMsg("SiegeServer", self._interfaceStr[self._siegeType], {rewardId = id}, true, {},function (result,errorCode)
                if errorCode ~= 0 then
                    dump(result,"result")
                    local key = "atkRewardIds"
                    if self._siegeType == 3 then
                        key = "defRewardIds"
                    end
                    self._siegeModel:changeBoxState(key,id)
                    DialogUtils.showGiftGet({gifts = result["reward"], 
                        callback = function()
                            if aniNodeBtn.boxAni then
                                aniNodeBtn:removeAllChildren()
                                aniNodeBtn.boxAni = nil
                            end
                            hasRewardBtn:setVisible(true)
                        end,
                        notPop = true})
                end 
            end)
        end)
        i = i - 1
    end
end
--获取宝箱阶段奖励
function SiegePrepareView:getRewardIds()
    local rewardIdsTable = {}   --领奖id
    for k , v in pairs(tab.siegePeriodAward) do
        if self._stageId == v["sectionID"] then
            rewardIdsTable[v["id"]] = 0
            self._progressTable[v["id"]] = v["condition"]
            self._boxAwardTable[v["id"]] = v["award"]
        end
    end
    local siegeData = self._siegeModel:getData()
    if self._siegeType == 2 then
        if siegeData["atkRewardIds"] ~= nil then
            for k , v in pairs(siegeData["atkRewardIds"]) do
                rewardIdsTable[tonumber(k)] = v
            end
        end
    elseif self._siegeType == 3 then
        if siegeData["defRewardIds"] ~= nil then
            for k , v in pairs(siegeData["defRewardIds"]) do
                rewardIdsTable[tonumber(k)] = v
            end
        end
    end
    return rewardIdsTable
end

function SiegePrepareView:setMenuClick()
    local orderBtn = self:getUI("menu.menuList.btnBg01")
    orderBtn:setScaleAnim(true)
    self:registerClickEvent(orderBtn, function()
        local rankModel = self._modelMgr:getModel("RankModel")
        local rankType = rankModel.kRankTypeSiegeAttack
        if self._siegeType == 3 then
            rankType = rankModel.kRankTypeSiegeDefend
        end
        rankModel:setRankTypeAndStartNum(rankType, 1) 
        self._serverMgr:sendMsg("RankServer", "getRankList", {type = rankModel.kRankTypeSiegeAttack, startRank = 1, id = self._stageId}, true, {}, function(result)
            self._viewMgr:showDialog("siege.SiegeRankView",{rankType = rankType,stageId = self._stageId},true)
        end)
    end)

    local ruleBtn = self:getUI("menu.menuList.btnBg02")
    ruleBtn:setScaleAnim(true)
    self:registerClickEvent(ruleBtn, function()
        self._viewMgr:showDialog("siege.SiegeRuleView",{stageId = self._stageId})
    end)
    
    local awardBtn = self:getUI("menu.menuList.btnBg03")
    awardBtn:setScaleAnim(true)
    self:registerClickEvent(awardBtn, function()
        if self._siegeType == 3 then
            self._viewMgr:showDialog("siege.SiegeDefendAwardView",{stageId = self._stageId,callBack = specialize(self.checkAwardRedFlag, self)},true)
        else
            self._viewMgr:showDialog("siege.SiegeAttackAwardView",{stageId = self._stageId,callBack = specialize(self.checkAwardRedFlag, self)},true)
        end
    end)

end

-- 第一次进入调用, 有需要请覆盖
function SiegePrepareView:onShow()

end

function SiegePrepareView:getMaskOpacity()
    return 0
end

-- 接收自定义消息
function SiegePrepareView:reflashUI(data)
    self._prepareData = self._siegeModel:getPrepareData()
    dump(self._prepareData)
    if not next(self._prepareData) then return end
    self:upDataUI(self._prepareData)
    self:initOrder(self._prepareData)
    self:showKillInfo(self._prepareData)
    self:setPassAward()
    self:showBuff()
    self:setChallengeTimes()
    self:setBtnState()
    self:checkAwardRedFlag()
    self:checkWallRedFlag()
end
--奖励红点
function SiegePrepareView:checkAwardRedFlag()
    local hasAward = false
    if self._siegeType == 3 then
        hasAward = self._siegeModel:checkDefNoticeAward()

    else
        hasAward = self._siegeModel:checkHurtAward(self._stageId,1)
    end
    local awardRed = self:getUI("menu.menuList.btnBg03.award.redFlag")
    awardRed:setVisible(hasAward)

end
--城墙加固材料红点
function SiegePrepareView:checkWallRedFlag()
    local hasMaterial = self._siegeModel:checkWallBuildMaterial()
    local materialRed = self:getUI("fixWallBtn.redFlag")
    materialRed:setVisible(hasMaterial)
end

function SiegePrepareView:onShow()
    self:showWallOpen()
end

--按钮状态
function SiegePrepareView:setBtnState()
    local isPass = self._siegeModel:isStagePass(self._stageId)
    if isPass then
        UIUtils:setGray(self._fightBtn,true)
        if self._fightBtn.amin1 then
            self._fightBtn.amin1:removeFromParent()
            self._fightBtn.amin1 = nil
        end
        if self._fightImage.amin2 then
            self._fightImage.amin2:removeFromParent()
            self._fightImage.amin2 = nil
        end
    else
        UIUtils:setGray(self._fightBtn,false)
        local totalTimes,hasTimes = self._siegeModel:getChannelTimes()
        if hasTimes > 0 then
            if not self._fightBtn.amin1 then
                local amin1 = mcMgr:createViewMC("zhandouguangxiao_battlebtn", true)
                amin1:setPosition(self._fightBtn:getContentSize().width/2, self._fightBtn:getContentSize().height/2) 
                self._fightBtn:addChild(amin1)   
                self._fightBtn.amin1 = amin1
            end
            if not self._fightImage.amin2 then
                local amin2 = mcMgr:createViewMC("zhandousaoguang_battlebtn", true)
                amin2:setPosition(self._fightImage:getContentSize().width/2, self._fightImage:getContentSize().height/2)
                self._fightImage:addChild(amin2)
                self._fightImage.amin2 = amin2
            end
        else
            if self._fightBtn.amin1 then
                self._fightBtn.amin1:removeFromParent()
                self._fightBtn.amin1 = nil
            end
            if self._fightImage.amin2 then
                self._fightImage.amin2:removeFromParent()
                self._fightImage.amin2 = nil
            end
        end
    end
end

--排行奖励
function SiegePrepareView:initOrder(result)
    -- print("========initOrder======")
    for k , node in pairs(self._rankNameList) do
        node:setString("暂无数据")
    end
    for k , node in pairs(self._rankValueList) do
        node:setVisible(false)
    end
    if result == nil or not next(result) then return end 
    if result["rankInfo"] then
        for k , v in pairs(result["rankInfo"]) do
            self._rankNameList[v["rank"]]:setString(v["name"])
            local score = self:damageFormat(v["score"])
            self._rankValueList[v["rank"]]:setString(score)
            self._rankValueList[v["rank"]]:setVisible(true)
        end
    end
    if result["ownerInfo"] then
        self:getUI("bottomNode.rankBg.myRankLabel"):setString(result["ownerInfo"]["rank"])
        local score = self:damageFormat(result["ownerInfo"]["score"])
        self:getUI("bottomNode.rankBg.myHurtValue"):setString("伤害:"..score)
    else
        self:getUI("bottomNode.rankBg.myRankLabel"):setString(0)
        self:getUI("bottomNode.rankBg.myHurtValue"):setString("伤害:0")
    end
end

function SiegePrepareView:damageFormat(damageValue)
    local damage = damageValue
    if tonumber(damageValue) > 99999 then
        if tonumber(damageValue) > 99999999 then
            damage = tonumber(string.format("%0.2f",damageValue/100000000)).."亿"
        else
            damage = tonumber(string.format("%0.2f",damageValue/10000)).."万"
        end
    end
    return damage
end

--通关奖励
function SiegePrepareView:setPassAward()
    local awardTable = tab.siegeMainStage[self._stageId]["endMaterial"]
    local createAwardItem = function(data,indexId)
        local itemBg = self:getUI("bottomNode.awardBg.awardIcon" .. indexId)
        itemBg:removeAllChildren()
        local itemId
        local teamId
        local num
        local starlevel 
        if data[1] == "tool" then
            itemId = data[2]
            num = data[3]
        elseif data[1] == "team" then 
            teamId = data[2]
            num = data[3]
            starlevel = data[4]
        elseif data[1] == "hero" then
            return
        else
            itemId = IconUtils.iconIdMap[data[1]]
            num = data[3]
        end
        local itemIcon = itemBg:getChildByName("awardItemIcon")
        if itemId then
            local param = {itemId = itemId, effect = false, eventStyle = 1, num = num}
            -- local itemIcon = itemBg:getChildByName("itemIcon")
            if itemIcon then
                IconUtils:updateItemIconByView(itemIcon, param)
            else
                itemIcon = IconUtils:createItemIconById(param)
                itemIcon:setName("awardItemIcon")
                local itemNormalScale = 78/itemIcon:getContentSize().width
                itemIcon:setScale(itemNormalScale)
                itemIcon:setPosition(cc.p(0,0))
                itemBg:addChild(itemIcon)
            end
        elseif teamId then
            local sysTeamData = clone(tab.team[teamId])
            if starlevel ~= nil  then 
                sysTeamData.starlevel = starlevel
            end
            local param = {sysTeamData = sysTeamData, effect = false, eventStyle = 0, isJin = true}
            if itemIcon then
                IconUtils:updateSysTeamIconByView(itemIcon, param)
            else
                itemIcon = IconUtils:createSysTeamIconById(param)
                itemIcon:setName("awardItemIcon")
                local itemNormalScale = 78/teamIcon:getContentSize().width
                itemIcon:setScale(itemNormalScale)
                itemIcon:setPosition(cc.p(0,0))
                itemBg:addChild(itemIcon)
            end
        end
    end
    for k , v in pairs(awardTable) do
        createAwardItem(v,k)
    end
end

--击杀信息
function SiegePrepareView:showKillInfo(result)
    local luckyUserHead = self:getUI("bottomNode.luckyBg.luckyUserHead")
    local luckyUserName = self:getUI("bottomNode.luckyBg.luckyUserName")
    if self._luckyBg.luckyDes then
        self._luckyBg.luckyDes:setVisible(false)
    end

    if not next(result["killInfo"]) then
        luckyUserHead:setVisible(false)
        luckyUserName:setVisible(false)
        if self._luckyBg.luckyDes then
            self._luckyBg.luckyDes:setVisible(true)
        else
            local rtxStr = "[color=3C2A1E,fontsize=20]完成最后一击的玩家额外获得丰厚的奖励[-]"   
            local luckyDes = RichTextFactory:create(rtxStr,190,30)
            luckyDes:formatText()
            luckyDes:setVerticalSpace(0)
            luckyDes:setAnchorPoint(cc.p(0.5,0.5))
            local w = self._luckyBg:getContentSize().width
            local h = self._luckyBg:getContentSize().height
            luckyDes:setName("luckyDes")
            luckyDes:setPosition(w/2,h/2-10)
            self._luckyBg.luckyDes = luckyDes
            self._luckyBg:addChild(luckyDes,4)
        end
    else
        luckyUserHead:setVisible(true)
        luckyUserName:setVisible(true)
        local killInfo = result["killInfo"]
        local headIcon = luckyUserHead:getChildByName("avatar")
        if headIcon == nil then
            headIcon = IconUtils:createHeadIconById({avatar = killInfo.avatar,level = killInfo.lvl or "0" ,
                tp = 4,avatarFrame = killInfo["avatarFrame"], tencetTp = killInfo["qqVip"], plvl = killInfo.plvl})
            headIcon:setAnchorPoint(0, 0.5)
            headIcon:setPosition(0, luckyUserHead:getContentSize().height*0.5)
            headIcon:setScale(1)
            headIcon:setName("avatar")
            luckyUserHead:addChild(headIcon, 2)
        else
            IconUtils:updateHeadIconByView({avatar = killInfo.avatar,level = killInfo.lvl or "0" ,
                tp = 4,avatarFrame = killInfo["avatarFrame"], tencetTp = killInfo["qqVip"]})            
        end
        luckyUserName:setString(killInfo["name"])

        self:registerClickEvent(luckyUserHead,function()
                self._serverMgr:sendMsg("UserServer", 
                    "getTargetUserBattleInfo", 
                    {tagId = killInfo._id, fid = self.FormationTypes[self._siegeType]}, true, {}, 
                    function(result) 
--                        local info = result.info
--                        info.battle.msg = info.msg
--                        info.battle.rank = info.rank
                        self._viewMgr:showDialog("arena.DialogArenaUserInfo",result,true)
                    end)
        end)

    end
end

--女王buf
function SiegePrepareView:showBuff()
    local isPass = self._siegeModel:isStagePass(self._stageId)
    local rightBk = self:getUI("rightBk")
    rightBk:setVisible(not isPass)
    local bufTitle = self:getUI("rightBk.bufTitle")
    local bufValue = self:getUI("rightBk.bufValue")
    local bufDesc = self:getUI("rightBk.bufDesc")
    local buffNum = self._siegeModel:getData()["curBuff"] or 0

    local desTxt = lang("SIEGE_EVENT_QUEEN_EFFECT")
    desTxt = string.gsub(desTxt,"{$num}",buffNum)                
    bufValue:setString(desTxt)
    bufTitle:setString(lang("SIEGE_EVENT_QUEEN_TITLE"))
    bufDesc:setString(lang("SIEGE_EVENT_QUEEN_DES"))

    local buffRuleBtn = self:getUI("rightBk.buffRuleBtn")
    self:registerClickEvent(buffRuleBtn, function()
        self._viewMgr:showDialog("siege.SiegeBuffRuleView",{stageId = self._stageId})
    end)
end

--剩余挑战次数
function SiegePrepareView:setChallengeTimes()
    local fightTimes = self:getUI("bottomNode.fightBg.fightTimes")
    local fightTimesDes = self:getUI("bottomNode.fightBg.fightTimesDes")
    local totalTimes,hasTimes = self._siegeModel:getChannelTimes()
    fightTimes:setString(hasTimes .."/"..totalTimes)
    fightTimes:setColor(hasTimes == 0 and cc.c3b(255,0,0) or cc.c3b(28,162,22))
    fightTimesDes:setColor(hasTimes == 0 and cc.c3b(255,0,0) or cc.c3b(28,162,22))
    -- if hasTimes > 0 then
    --     fightTimes:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    -- end
end

--进入布阵
function SiegePrepareView:enterFormation()
    local battleId = tab.siegeMainStage[self._stageId]["battleId"]
    local sysStage = tab.siegeBattleGroup[battleId]
    -- local storyMachine = tab.siegeMainStage[self._stageId]["storyMachine"]   --器械
    -- local enemyFormation = IntanceUtils:initFormationData(sysStage)
    -- dump(enemyFormation,"========enemyFormation======")
    if self._siegeType == 3 then
        self._viewMgr:showView("formation.NewFormationView", {
            formationType = self.FormationTypes[self._siegeType],
            recommend = tab.siegeMainStage[self._stageId]["recommend"] or {},
            extend = {hideDefWeapon = true},
            callback = function(formationData)
               self:enterFight(formationData)
            end,
            closeCallback = function(inIsNpcHero)
            end
        })
    else
        self._viewMgr:showView("formation.NewFormationView", {
            formationType = self.FormationTypes[self._siegeType],
            recommend = tab.siegeMainStage[self._stageId]["recommend"] or {},
            enemyFormationData = {[self.FormationTypes[self._siegeType]] = IntanceUtils:initFormationData(sysStage)},
            heroes = sysStage.hero,
            extend = {fixedWeapon = tab.siegeMainStage[self._stageId]["storyMachine"] or {}},
            callback = function(formationData)
               self:enterFight(formationData)
            end,
            closeCallback = function(inIsNpcHero)
            end
        })
    end
end
--进入战斗
function SiegePrepareView:enterFight(formationData)
    self._formationData = formationData
    local battleId = tab.siegeMainStage[self._stageId]["battleId"]
    local param = {}
    local interfaceString
    local wallLv = self._siegeModel:getWallCurLevel()
    if self._siegeType == 3 then   --守城战
        param = {}
        interfaceStr = "atkBeforeDefend"
    else
        param = {stageId = self._stageId}
        interfaceStr = "atkBeforeSiege"
    end
    self._serverMgr:sendMsg("SiegeServer", interfaceStr, param, true, {}, function (result,errorCode)
        self._battleToken = result["token"]
        self._viewMgr:popView()
        if self._lockCallBack ~= nil then 
            self._lockCallBack(true)
        end
        if self._siegeType == 3 then
            self._battleFunciton[self._siegeType](BattleUtils.jsonData2lua_battleData(result["atk"]),wallLv,battleId,false, function (info,callBack)
                self:battleCallBack(info,callBack)
            end,
            function (info)
                if self._battleWin == 1 then
                    --更新UI

                end
                if self._lockCallBack ~= nil then 
                    self._lockCallBack(false)
                end
            end)
        else
            self._battleFunciton[self._siegeType](BattleUtils.jsonData2lua_battleData(result["atk"]),battleId,false, function (info,callBack)
                self:battleCallBack(info,callBack)
            end,
            function (info)
                if self._battleWin == 1 then
                    --更新UI
                end
                local isPass = self._siegeModel:isStagePass(self._stageId)
                local bg = self:getUI("bg")
                if self._siegeType == 1 and isPass then
                    self:lock()
                    local mc = mcMgr:createViewMC("gongzhanchenggong_intancenopen", false, true, function (_, sender)
                        self:unlock()
                    end, RGBA8888)       
                    mc:setPosition(bg:getContentSize().width * 0.5, bg:getContentSize().height * 0.5 + 70)
                    bg:addChild(mc, 1)
                end
                
                if self._lockCallBack ~= nil then 
                    self._lockCallBack(false)
                end
            end)
        end
    end,
    function (errorCode)

    end)
end
--战斗返回
function SiegePrepareView:battleCallBack(inResult,inCallBack)
    -- dump(inResult,"==========inResult===========")
    self._battleWin = 0
    if inResult == nil or inResult.isSurrender then 
        if self._lockCallBack ~= nil then 
            self._lockCallBack(false)
        end
        if inCallBack ~= nil then
            inCallBack(inResult)
        end
        return 
    end
    if inResult.win ~= nil and inResult.win == true then 
       self._battleWin = 1
    end
    local interfaceString
    local param = {}
    if self._siegeType == 3 then   --守城战
        param = {
                        args = json.encode({
                        win = self._battleWin, 
                        serverInfoEx = inResult.serverInfoEx,
                        skillList = inResult.skillList,
                        zzid = GameStatic.zzid8,
                        damage = inResult["exInfo"]["damageCount"],
                        waves = inResult["exInfo"]["waveCount"],
                        time = inResult["time"]
                        }),
                    token = self._battleToken}

        interfaceStr = "atkAfterDefend"
    else
        param = { 
                        stageId = self._stageId,
                        args = json.encode({
                        win = self._battleWin, 
                        serverInfoEx = inResult.serverInfoEx, 
                        skillList = inResult.skillList,
                        zzid = GameStatic.zzid7,
                        damage = inResult.totalDamage1,
                        time = inResult["time"]
                        }),
                    token = self._battleToken}  
        interfaceStr = "atkAfterSiege"
    end

    self._serverMgr:sendMsg("SiegeServer", interfaceStr, param, true, {}, function (result)
        dump(result,"result")
        if result == nil then 
            self._battleWin = 0
            if inCallBack ~= nil then
                inCallBack({failed = true, __code = 5, extract = result["extract"]})
            end
            return 
        end
        -- 向战斗层传送数据
        -- local resultData = clone(result)
        -- if resultData["cheat"] == 1 then
        --     resultData.failed = true
        -- end
        self:upDataCurSiegeUI()   --刷新UI
        if inCallBack ~= nil then
            local inResultData = clone(inResult)
            inResultData["extend"] = {}
            inResultData["extend"]["isLast"] = result["isLast"] or 0                    --最后一击
            inResultData["extend"]["stageId"] = self._stageId                           --城市id
            inResultData["extend"]["maxHp"] = tab.siegeMainStage[self._stageId]["hp"]   --最大血量
            inResultData["extend"]["exReward"] = result["exReward"]                     --幸运奖
            inResultData["extend"]["oldRank"] = result["oldRank"]                       --上次排名
            inResultData["extend"]["newRank"] = result["newRank"]                       --当前排名
            inResultData["extend"]["buff"] = result["orgBuff"]                          --buff
            inResultData["extend"]["isMax"] = result["isMax"]
            -- inResultData["extend"]["maxhurt"] = result["d"]["siege"][self._hurtKey[self._stageId]]
            -- if self._siegeType == 3 then
            --     inResultData["extend"]["maxWaves"] = result["d"]["siege"]["maxWaves"] or 0
            -- end
            inResultData.win = true
            inCallBack(inResultData,result.reward)
        end
    end, function (error)
        if error then
            self._battleWin = 0
            if inCallBack ~= nil then
                inCallBack({failed = true, __code = 8, __error = error})
            end
        end
    end)
end

--刷新当前城池信息
function SiegePrepareView:upDataCurSiegeUI()
    self._serverMgr:sendMsg("SiegeServer", "getStageInfo", {stageId = self._stageId}, true, {},function (result,errorCode)
        if errorCode ~= 0 then
            self:reflashUI()
        end 
    end)
end

function SiegePrepareView:pushUpDataCurSiegeUI(eventName)
    if eventName == "statePushUpdate" or eventName == "refleshUIEvent" then
        self._serverMgr:sendMsg("SiegeServer", "getStageInfo", {stageId = self._stageId}, true, {},function (result,errorCode)
            if errorCode ~= 0 then
                if self._viewMgr ~= nil then
                    self._viewMgr:unlock(51)
                    self:reflashUI()
                end
            end 
        end)
    end
end


function SiegePrepareView:getAsyncRes()
    return {
            -- {"asset/ui/siege.plist", "asset/ui/siege.png"},
            -- {"asset/ui/team.plist", "asset/ui/team.png"},
           }
end

return SiegePrepareView