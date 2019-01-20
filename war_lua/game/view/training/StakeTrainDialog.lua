--
-- Author: huangguofang
-- Date: 2018-04-27 20:02:50
--
local StakeTrainDialog = class("StakeTrainDialog",BasePopView)
function StakeTrainDialog:ctor(data)
    self.super.ctor(self)
    -- self.initAnimType = 1
    self._parent = data.parent
    self._callBack = data.callBack
    self._rankModel = self._modelMgr:getModel("RankModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._stakeModel = self._modelMgr:getModel("StakeModel")
    self._rankType = self._rankModel.kRankTypeStakeDamage

end
function BasePopView:getMaskOpacity()
    return 200
end
-- 初始化UI后会调用, 有需要请覆盖
function StakeTrainDialog:onInit()
    -- 定时五点刷新
    self:registerTimer(5, 0, GRandom(0, 5), function ()
        self:reflashDataAndUI()
    end)
	self._stakeData = self._stakeModel:getStakeData() or {}
	-- 关卡信息
   	self._stageId = 1
   	self._stageData = tab:StakeBattle(self._stageId) or {}
    -- 第几期热点英雄
    self._stakeNum = self._stakeData.hotId or 1

    self._closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEventByName("bg.closeBtn", function(  ) 
        if self._callBack then
            self._callBack()
        end    
        if self.close then
            self:close()
        end
        -- self._parent:unlockSeniorAnim()
        UIUtils:reloadLuaFile("training.StakeTrainDialog")
    end)
    -- local rankNode = 
    local infoPanel = self:getUI("bg.leftPanel.infoPanel")
    local lockPanel = self:getUI("bg.leftPanel.lockPanel")
    local desTxt 	= self:getUI("bg.leftPanel.lockPanel.desTxt")
    desTxt:setString(lang("STAKE_TIPS"))
    desTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    infoPanel:setVisible(true)
	lockPanel:setVisible(false)

	local titleTxt1 = self:getUI("bg.leftPanel.infoPanel.titleTxt")
	titleTxt1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	local titleTxt2 = self:getUI("bg.leftPanel.lockPanel.titleTxt")
	titleTxt2:setString(lang("STAKE_TITLE"))
	titleTxt2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

	self._hotPanel = self:getUI("bg.leftPanel.infoPanel.hotPanel")
	self:initHotPanel()

    self._rankBg = self:getUI("bg.leftPanel.infoPanel.rankBg")
    self._rankName = {}
    for i=1,3 do
        self._rankName[i] = self:getUI("bg.leftPanel.infoPanel.rankBg.rankName" .. i)
    end
    self._myRankLabel = self:getUI("bg.leftPanel.infoPanel.rankBg.myRankLabel")
    -- 前三排行榜
    -- self._rankList = self._stakeData.rankList or {}    
    self._rankModel:setRankTypeAndStartNum(self._rankType,1)
    self:updateRankListPanel()
    local btn_rule 	= self:getUI("bg.leftPanel.infoPanel.btn_rule")
    local btn_rank 	= self:getUI("bg.leftPanel.infoPanel.btn_rank")
    UIUtils:addFuncBtnName(btn_rule, "规则",cc.p(btn_rule:getContentSize().width/2,0),true,18)
    UIUtils:addFuncBtnName(btn_rank, "排行榜",cc.p(btn_rank:getContentSize().width/2,0),true,18)
    registerClickEvent(btn_rule,function(sender) 
        self._viewMgr:showDialog("training.StakeRuleDialog", {parent = self,stakeNum = self._stakeNum}, true)
    end)
    registerClickEvent(btn_rank,function(sender) 
        self:showRankDialog()        
    end)
    registerClickEvent(self:getUI("bg.leftPanel.infoPanel.rankBg"),function(sender) 
        self:showRankDialog()        
    end)

    local fightBtn1 = self:getUI("bg.detail_panel.fightBtn1")
    local fightBtn2 = self:getUI("bg.detail_panel.fightBtn2")
    fightBtn1:setTitleText("挑战练习")
    fightBtn2:setTitleText("自由练习")
    registerClickEvent(fightBtn1,function(sender) 
        self:goToFormation1()
    end)
    registerClickEvent(fightBtn2,function(sender) 
        self:goToFormation2()
    end)

    local roleName = self:getUI("bg.detail_panel.roleNameBg.roleName")
    roleName:setString("练习木桩")

end
-- 打开排行榜
function StakeTrainDialog:showRankDialog()
    self._serverMgr:sendMsg("RankServer", "getRankList", {type = self._rankType,id=self._stageId,startRank = 1}, true, {}, function(result) 
        -- 更新rankList 前三数据
        -- dump(result,"result==>",5)
        self._stakeModel:updateStakeRankList(result.rankList)
        self._viewMgr:showDialog("training.StakeRankDialog",{parent=self,stakeNum = self._stakeNum,callback = function()       
            -- 更新训练场前三显示            
            self:updateRankListPanel()
        end})
    end)
        
end
-- 
function StakeTrainDialog:initHotPanel()
	-- 三个热点英雄 返回长度
	local hotPanel = self._hotPanel
    hotPanel:removeAllChildren()
    local stakeHeroTb = tab:StakeHero(self._stakeNum)
    hotHero = stakeHeroTb.hotHero
    local count = #hotHero
    local nameStr = ""
    local itemIcon
    local posX = 43
    for k,v in pairs(hotHero) do
    	local heroData = tab:Hero(tonumber(v))
        itemIcon = IconUtils:createHeroIconById({sysHeroData = heroData})
        --itemIcon:setAnchorPoint(cc.p(0, 0))
        itemIcon:getChildByName("starBg"):setVisible(false)
        itemIcon:getChildByName("iconStar"):setVisible(false)
        itemIcon:setScale(0.7)
        itemIcon:setPosition(posX, hotPanel:getContentSize().height / 2)
        posX = posX + 78
        itemIcon:setSwallowTouches(false)
        hotPanel:addChild(itemIcon)
        -- registerClickEvent(itemIcon, function()
        --     local NewFormationIconView = require "game.view.formation.NewFormationIconView"
        --     self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = tonumber(v)}, true)
        -- end)
    end
end

--前往布阵
function StakeTrainDialog:goToFormation1()
    print("============前往布阵11================")
    -- local formationData , enemyFormationData ,extendData = self:formatFormationData(self._stageData)
    -- extendData.stakeData = self._stageData
    local formationModel = self._modelMgr:getModel("FormationModel") 
    local stakeHeroTb = tab:StakeHero(self._stakeNum)  

    self._viewMgr:showView("formation.NewFormationView", {
        formationType = formationModel.kFormationTypeStakeAtk1,
        enemyFormationData = {[formationModel.kFormationTypeStakeAtk1] = self._modelMgr:getModel('StakeModel'):initEnemyFormationData(self._stageId)},
        recommend = stakeHeroTb.hotHero,     --recommend是热点英雄列表{60802}
        extend = {sortFront = stakeHeroTb.hotHero},
        callback = function(playerInfo, teamCount, filterCount, formationType)                            
            self._serverMgr:sendMsg("StakeServer", "beforeStakeAttack", {id = self._stageId, serverInfoEx = BattleUtils.getBeforeSIE()}, true, {}, function(result)
                self._viewMgr:popView()
                local token = result.token or nil
                -- dump(result,"-------",10)
                local leftInfo = BattleUtils.jsonData2lua_battleData(result["atk"])
                BattleUtils.enterBattleView_WoodPile_2(leftInfo, self._stageId, 
                    function (info, callback)
                    	-- 战斗结束
                        -- info.win = 1
                        self:afterStakeBattle(playerInfo, info,callback,data,token,1)                        
                    end,
                    function (info)
                        -- 退出战斗
                    end,false)
            end)
        end
        
    })

end

--前往布阵
function StakeTrainDialog:goToFormation2()
    print("============前往布阵22================")
    -- local extendData ={}
    -- extendData.stakeData = self._stageData
    local formationModel = self._modelMgr:getModel("FormationModel")    
    self._viewMgr:showView("formation.NewFormationView", {
        formationType = formationModel.kFormationTypeStakeAtk2,
        extend = {
            enterBattle = {
                [formationModel.kFormationTypeStakeAtk2] = false,
                [formationModel.kFormationTypeStakeDef2] = true
            }
        },
        callback = function(playerInfo, teamCount, filterCount, formationType)                            
            self._serverMgr:sendMsg("StakeServer", "stakeDefiningAttack", {id = self._stageId, serverInfoEx = BattleUtils.getBeforeSIE()}, true, {}, function(result)
                self._viewMgr:popView()
                local token = result.token or nil
                local leftInfo = BattleUtils.jsonData2lua_battleData(result["atk"])
                local rightInfo = BattleUtils.jsonData2lua_battleData(result["def"])
                BattleUtils.enterBattleView_WoodPile_1(leftInfo, rightInfo, 
                    function (info, callback)
                    -- 战斗结束
                        -- info.win = 1
                        self:afterStakeBattle(leftInfo, info,callback,data,token,2)
                        
                    end,
                    function (info)
                        -- 退出战斗
                    end,false)
            end)
        end
        
    })

end

--[[
-- 格式化传入布阵的参数
function StakeTrainDialog:formatFormationData(data)
    local formationData = {} 

    -- 敌方上阵兵团
    local enemyFormationData = {}
    local enemynpc = data.enemynpc or {}
    local fightScore = 0

    for i=1,8 do
        local npcData = enemynpc[i]
        if npcData then
            enemyFormationData["team" .. i] = tonumber(npcData[1])
            enemyFormationData["g" .. i] = tonumber(npcData[2])
            local enemyData = tab:Npc(tonumber(npcData[1]))
            if enemyData and enemyData.score then
                fightScore = fightScore + tonumber(enemyData.score) 
            end
        else
            enemyFormationData["team" .. i] = 0
            enemyFormationData["g" .. i] = 0
        end
    end

    -- 过滤不显示的兵团id
    enemyFormationData.filter = ""    

    --上阵英雄
    enemyFormationData.heroId = tonumber(data.enemyhero)
    local heroData = tab:NpcHero(tonumber(data.enemyhero))
    if heroData and heroData.score then
        fightScore = fightScore + tonumber(heroData.score) 
    end
    -- 战斗力
    enemyFormationData.score = fightScore

	local extend = {}

    return formationData ,enemyFormationData ,extend
end
]]
--战后数据处理
function StakeTrainDialog:afterStakeBattle(playerInfo, info,callback,data,token,fightType)
 
    local currToken = token or ""
    -- print("========================currToken===",currToken)
    local win = true--info.win or 0
    local hp = info.hp or {} 
    local time = info.time or 1
    local damageNum = info.totalDamage1 or 0
    if info.leftData[0] and info.leftData[0]["damage"] then
        for k,v in pairs(info.leftData[0]["damage"]) do
            damageNum = damageNum + tonumber(v)
        end
    end
    damageNum = damageNum
  
    local formationHeroID
    if playerInfo and playerInfo.hero then
        formationHeroID = playerInfo.hero.id
    end

    info.win = true
    local param = {id = self._stageId,
			    	token = currToken,
			    	args = json.encode({win = win,
			    						time = time,
			    						damage = damageNum,
			    						-- heroId = formationHeroID,
			    						-- skillList = info.skillList,
			    						-- serverInfoEx = info.serverInfoEx,
			    						-- playerInfo=json.encode(playerInfo)
			    					})}
    info.totalDamageNum = damageNum
    info.fightType = fightType
    local hDamage = self._stakeData.hDamage or damageNum
    if fightType == 1 then
        local stakeHeroTb = tab:StakeHero(self._stakeNum) 
        local isHaveFind = table.find(stakeHeroTb.hotHero,formationHeroID)
        info.isHot = not (isHaveFind == nil)
        info.heroId = formationHeroID
        info.subDamgeNum = damageNum - hDamage
        self._serverMgr:sendMsg("StakeServer", "afterStakeAttack", param, true, {}, function(result) 
           	-- 更新前三数据
            self:updateRankListPanel()  
            --结算
            callback(info)
        end)
    else
        self._serverMgr:sendMsg("StakeServer", "stakeDefiningAttackAfter", param, true, {}, function(result) 
            --结算
            callback(info)
        end)        
    end
    
end

-- 接收自定义消息
function StakeTrainDialog:reflashUI(data)
    
end
--[[
function StakeTrainDialog:updaterankListData(ressult)
	dump(result,"updaterankListData==>",5)
    local rankData = result and result.rankList
    if not rankData then
        rankData = result["d"] and result["d"].rankList
    end
    if rankData then
        print("================12121212====")
        table.sort(rankData ,function (a,b)
            if a.rank and b.rank then
                return a.rank < b.rank
            else
                return true 
            end
        end)
        for i=1,3 do
            if rankData[i] then
                self._rankList[i] = rankData[i]
            else
               rankData[i] = {}
            end
        end
        self:updateRankListPanel()
    end
end
]]
function StakeTrainDialog:updateRankListPanel()
    -- 前三排行榜
    self._rankList = self._stakeData.rankList or {}
    -- 获取自己排行榜
    self._serverMgr:sendMsg("RankServer", "getMyRank", {type=self._rankType,id=self._stageId}, true, {}, function(result) 
        -- dump(result,"result==>",5)
        local rankNum = result.rank
        if not rankNum or 0 == rankNum then
            rankNum = "暂无排名"
        end
        self._myRankLabel:setString(rankNum)
    end)
    
    for i=1,3 do
        if self._rankName and self._rankName[i] then
            if self._rankList[i] then
                self._rankName[i]:setString(self._rankList[i].name or "")
            else
                self._rankName[i]:setString("暂无")
            end
        end
    end
end

--  五点 刷新数据和显示
function StakeTrainDialog:reflashDataAndUI()
    self._serverMgr:sendMsg("StakeServer", "getStakeInfo", {}, true, {}, function()
        self._stakeData = self._stakeModel:getStakeData() or {}
        -- 关卡信息
        self._stageId = 1
        self._stageData = tab:StakeBattle(self._stageId) or {}
        -- 第几期热点英雄
        self._stakeNum = self._stakeData.hotId or 1

        self:initHotPanel()
        self:updateRankListPanel()
    end)
end

return StakeTrainDialog