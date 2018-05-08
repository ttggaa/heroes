--[[
    Filename:    DragonView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2015-11-05 15:10:43
    Description: File description
--]]


local FormationIconView = require("game.view.formation.FormationIconView")

local PVEID = {101, 201, 301}
local MAX_DIFF = 7

local DragonView = class("DragonView", BaseView)

function DragonView:ctor()
    DragonView.super.ctor(self)
    self._bossModel = self._modelMgr:getModel("BossModel")
    self._formationModel = self._modelMgr:getModel("FormationModel")

    self.FormationTypes = {self._formationModel.kFormationTypeDragon, 
                           self._formationModel.kFormationTypeDragon1,
                           self._formationModel.kFormationTypeDragon2
                           }
    self.fixMaxWidth = ADOPT_IPHONEX and 1136 or nil
end

function DragonView:onBeforeAdd(callback, errorCallback) 
    self._serverMgr:sendMsg("BossServer", "getBossInfo", {}, true, {}, function(result) 
--        dump(result,"result")
        if result == true then
            self:onModelReflash()
        end
        callback()
    end)  
end

function DragonView:getAsyncRes()
    return 
        {
            {"asset/ui/gLevelSelected.plist", "asset/ui/gLevelSelected.png"},
            {"asset/ui/pveDragon.plist", "asset/ui/pveDragon.png"},
            {"asset/ui/pveIn.plist", "asset/ui/pveIn.png"},
        }
end

function DragonView:getBgName()
    return "bg_dragon.jpg"
end

local dragonOutlineColor = cc.c4b(90,44,0,255)
function DragonView:onInit()
    self._tableData = {}
    for i = 1, #PVEID do
        self._tableData[i] = tab:PveSetting(PVEID[i])
    end

    self._label_enemy_name = self:getUI("bg.mainNode.image_enemy_bg.label_enemy_name")
    -- self._label_enemy_name:setColor(cc.c3b(239, 239, 1))
    self._label_enemy_name:enableOutline(dragonOutlineColor, 2)
    self._label_enemy_name:setFontName(UIUtils.ttfName_Title)

    self._labelRecommand = self:getUI("bg.mainNode.image_enemy_bg.label_enemy_recommand")
    self._labelRecommand:enableOutline(dragonOutlineColor, 1)

    self._dragonSelectedId = 0
    self._dragonSelectedHard = 0
    self._dragonLayer = {}  
    for i = 1, 3 do
        self._dragonLayer[i] = {}
        self._dragonLayer[i]._layer = self:getUI("bg.mainNode.layer_dragon.layer_dragon_" .. i)
        -- self._dragonLayer[i]._layer:setSaturation(-100)
        self._dragonLayer[i]._des = self:getUI("bg.mainNode.layer_dragon.layer_dragon_" .. i .. ".label_des")
        self._dragonLayer[i]._des:setString(lang(string.format("TIPS_PVE_BOSS_%d0", i)))
        self._dragonLayer[i]._des:enableOutline(dragonOutlineColor, 1)
        self._dragonLayer[i]._name = self:getUI("bg.mainNode.layer_dragon.layer_dragon_" .. i .. ".label_name")
        self._dragonLayer[i]._name:setString(lang(string.format("TIPS_PVE_BOSS_%d0", i)))
        -- self._dragonLayer[i]._name:setColor(cc.c4b(255,231,100,255))
        self._dragonLayer[i]._name:enableOutline(dragonOutlineColor,2)
        self._dragonLayer[i]._name:setFontName(UIUtils.ttfName_Title)
--        self._dragonLayer[i]._iconBg = self:getUI("bg.mainNode.layer_dragon.layer_dragon_" .. i .. ".image_dragon_bg")
--        self._dragonLayer[i]._iconBg:setScale(0.95)
--        self._dragonLayer[i]._selectBg = self._dragonLayer[i]._iconBg:getChildByFullName("image_selected")
--        self._dragonLayer[i]._selectBg:setZOrder(-1)
--        self._dragonLayer[i]._selected = mcMgr:createViewMC("beiguang_longzhiguobtn", true)
--        self._dragonLayer[i]._selected:setVisible(false)
--        self._dragonLayer[i]._selected:setPlaySpeed(1, true)
--        self._dragonLayer[i]._selected:setPosition(self._dragonLayer[i]._iconBg:getContentSize().width / 2, self._dragonLayer[i]._iconBg:getContentSize().height / 2)
--        self._dragonLayer[i]._iconBg:addChild(self._dragonLayer[i]._selected, 1)
        self._dragonLayer[i]._icon = self:getUI("bg.mainNode.layer_dragon.layer_dragon_" .. i .. ".dragonIcon")
        self._dragonLayer[i]._icon:setSaturation(-100)
        self._dragonLayer[i]._icon:setTouchEnabled(false)

        self._dragonLayer[i]._iconEffect = mcMgr:createViewMC("dargon" .. i .. "_dragonselectedanim", true,false)
        self._dragonLayer[i]._iconEffect:setPosition(self._dragonLayer[i]._icon:getContentSize().width*0.5, self._dragonLayer[i]._icon:getContentSize().height*0.5)
        self._dragonLayer[i]._iconEffect:setVisible(false)
        self._dragonLayer[i]._icon:addChild(self._dragonLayer[i]._iconEffect,-1)

        self:registerTouchEvent(self._dragonLayer[i]._layer,function(x,y) end,function(x,y) end,
            function(x,y)
                self:onDragonButtonClicked(i)
            end,
            function(x,y) end)
    end

    self._battleFunciton = {
        [1] = BattleUtils.enterBattleView_BOSS_DuLong,
        [2] = BattleUtils.enterBattleView_BOSS_XnLong,
        [3] = BattleUtils.enterBattleView_BOSS_SjLong,
    }

    self._recommandLayer = {} 
    self._container = self

    for i = 1, 5 do
        self._recommandLayer[i] = self:getUI("bg.mainNode.image_enemy_bg.layer_enemy_icon_" .. i)
    end

--    self._skillLayer = {}
--    for i = 1, 5 do
--        self._skillLayer[i] = self:getUI("bg.mainNode.image_bottom_bg.image_reward_bg.layer_skill_" .. i)
--    end

    self._imageDragon = self:getUI("bg.layer.image_log_dragon")
    self._posX = self._imageDragon:getPositionX()
    self._posY = self._imageDragon:getPositionY()

    --左下信息
    local rankNode = self:getUI("bg.rankNode")
    -- 排行榜
    self:registerClickEvent(self:getUI("bg.rankNode.rankBg"), function()
        self._modelMgr:getModel("RankModel"):setRankTypeAndStartNum(12,1)
        self._serverMgr:sendMsg("RankServer", "getRankList", {type=12,id=self._dragonSelectedId,startRank = 1}, true, {}, function(result) 
            self._viewMgr:showDialog("pve.DragonRankDialog",{bossId = self._dragonSelectedId, callback = function()
                    self:updateRankListPanel()
                end})
            -- 更新bossModel里的前三数据
            self._bossModel:setrankListByPveId(self._dragonSelectedId,result)
        end)        
    end)

    local myRankTxt = rankNode:getChildByFullName("rankBg.myRankTxt")
    -- myRankTxt:setColor(UIUtils.colorTable.ccUIBasePromptColor)
    myRankTxt:enableOutline(dragonOutlineColor, 1)
    self._rankNameNo1 = rankNode:getChildByFullName("rankBg.rankName1")
    self._rankNameNo2 = rankNode:getChildByFullName("rankBg.rankName2")
    self._rankNameNo3 = rankNode:getChildByFullName("rankBg.rankName3")
    self._rankNameNo1:enableOutline(dragonOutlineColor,1)
    self._rankNameNo2:enableOutline(dragonOutlineColor,1)
    self._rankNameNo3:enableOutline(dragonOutlineColor,1)
    self._myRank = rankNode:getChildByFullName("rankBg.myRankLabel")

    local rankTxt = rankNode:getChildByFullName("rankBg.rankTxt")
    rankTxt:setFontName(UIUtils.ttfName)
    rankTxt:setColor(cc.c3b(255, 224, 188))
    -- rankTxt:enable2Color(1, cc.c4b(255, 232, 125, 255))
    rankTxt:enableOutline(dragonOutlineColor, 2)    

    -- btn,titleTxt,pos,hasTextBg,fontSize )
    UIUtils:addFuncBtnName(rankNode:getChildByFullName("btn_rule"), "怪物信息",cc.p(rankNode:getChildByFullName("btn_rule"):getContentSize().width/2,0),true,18)
    UIUtils:addFuncBtnName(rankNode:getChildByFullName("btn_rank"), "排行榜",cc.p(rankNode:getChildByFullName("btn_rank"):getContentSize().width/2,0),true,18)

    -- 规则
    self._ruleBtn = rankNode:getChildByFullName("btn_rule")
    self:registerClickEvent(self._ruleBtn, function()
        self._viewMgr:showDialog("pve.DragonRuleView", {dragonId = self._dragonSelectedId,tableData = self._tableData}, true, true)
    end)
    -- 排行榜
    self:registerClickEvent(rankNode:getChildByFullName("btn_rank"), function()
        self._modelMgr:getModel("RankModel"):setRankTypeAndStartNum(12,1)
        self._serverMgr:sendMsg("RankServer", "getRankList", {type=12,id=self._dragonSelectedId,startRank = 1}, true, {}, function(result) 
            self._viewMgr:showDialog("pve.DragonRankDialog",{bossId = self._dragonSelectedId, callback = function()
                    self:updateRankListPanel()
                end})
            -- 更新bossModel里的前三数据
            self._bossModel:setrankListByPveId(self._dragonSelectedId,result)
        end)        
    end)

    self._btnBattle = self:getUI("bg.mainNode.btn_battle")
    -- self:formatButton(self._btnBattle)

--    local mc = mcMgr:createViewMC("zhandouguangxiao_battlebtn", true)
--    mc:setPosition(btnBattle:getContentSize().width/2, btnBattle:getContentSize().height/2)
--    btnBattle:addChild(mc, 0)

--    local image_battle = self:getUI("bg.layer.image_bottom_bg.btn_battle.image_battle")
--    local amin2 = mcMgr:createViewMC("zhandousaoguang_battlebtn", true)
--    amin2:setPosition(image_battle:getContentSize().width/2, image_battle:getContentSize().height/2)
--    image_battle:addChild(amin2)

    self:registerClickEvent(self._btnBattle, function()
        if 0 == self._dragonSelectedId then
            self._viewMgr:showTip(lang("TIPS_PVE_BOSS_01"))
            return 
        end

        local pveData = self._bossModel:getDataByPveId(self._dragonSelectedId)
        local times = 0
        if pveData then
            times = pveData.times or 0
        end
        local currentTotalTimes = tab:Setting("G_PVE_" .. self._dragonSelectedId).value
        local totalTimes = 0
        for i = 1, 3 do
            if self._dragonData[i].open then
                totalTimes = totalTimes + tab:Setting("G_PVE_" .. i).value
            end
        end
        if times >= totalTimes then
            self._viewMgr:showTip(lang("TIPS_PVE_01"))
            return
        elseif times >= currentTotalTimes then
            self._viewMgr:showTip(lang("TIPS_PVE_03"))
            return
        end
        self._dragonLevelSelectedDialog = self._viewMgr:showDialog("pve.DragonLevelSelectedView", {container = self, data = self._dragonData[self._dragonSelectedId], dragonId = self._dragonSelectedId}, true, true)
    end)
    

    self:registerClickEventByName("bg.btn_return", function()
        self:close()
        UIUtils:reloadLuaFile("pve.DragonView")
    end)

    self:listenReflash("BossModel", self.onModelReflash)
end

function DragonView:formatButton(btn)
    if not btn then return end
    btn:enableOutline(cc.c4b(36,65,121,255), 2)
    btn:setTitleFontSize(28)  
    btn:setTitleFontName(UIUtils.ttfName)
end

function DragonView:initDragonData()
    local result = {
        [1] = {
            times = 0,
            diffList = { ["1"] = 0, ["2"] = 0, ["3"] = 0, ["4"] = 0, ["5"] = 0, ["6"] = 0, ["7"] = 0, ["8"] = 0, ["9"] = 0, ["10"] = 0, ["11"] = 0},
            open = false,
        },

        [2] = {
            times = 0,
            diffList = { ["1"] = 0, ["2"] = 0, ["3"] = 0, ["4"] = 0, ["5"] = 0, ["6"] = 0, ["7"] = 0, ["8"] = 0, ["9"] = 0, ["10"] = 0, ["11"] = 0},
            open = false,
        },

        [3] = {
            times = 0,
            diffList = { ["1"] = 0, ["2"] = 0, ["3"] = 0, ["4"] = 0, ["5"] = 0, ["6"] = 0, ["7"] = 0, ["8"] = 0, ["9"] = 0, ["10"] = 0, ["11"] = 0},
            open = false,
        }
    }
    for i = 1, 3 do
        local pveData = self._bossModel:getDataByPveId(i)
        if pveData then
            result[i].times = pveData.times or 0
            result[i].diffList = pveData.diffList
            result[i].open = true
        end
    end
    
    self._firstShow = true
    return result
end

function DragonView:updateUI()
    --local openCount = 0
    if 0 == self._dragonSelectedId then
        for i = 3, 1, -1 do
            if self._dragonData[i].open then
                --openCount = openCount + 1
                self._dragonSelectedId = i
                self._dragonSelectedHard = 1
            end
        end
    end
    --[[
    if openCount > 1 then
        self._dragonSelectedId = 0
        self._dragonSelectedHard = 0
    end
    
    local times = 0
    local totalTimes = 0
    for i = 1, 3 do
        if self._dragonData[i].open then
            totalTimes = totalTimes + tab:Setting("G_PVE_" .. i).value
        end
    end
    ]]

    for i = 1, 3 do
        -- self._dragonLayer[i]._layer:setSaturation(self._dragonData[i].open and 0 or -100)
        self._dragonLayer[i]._icon:setSaturation(self._dragonData[i].open and 0 or -100)
        self._dragonLayer[i]._des:setSaturation(self._dragonData[i].open and 0 or -100)
        self._dragonLayer[i]._name:setSaturation(self._dragonData[i].open and 0 or -100)
        self._dragonLayer[i]._des:enableOutline(dragonOutlineColor,1)
        self._dragonLayer[i]._icon:setScale(self._dragonData[i].open and ( i == self._dragonSelectedId and 1.1 or 1) or 0.95)
--        self._dragonLayer[i]._selectBg:setVisible(self._dragonData[i].open --[[and 1 == openCount]])
--        self._dragonLayer[i]._selected:setVisible(self._dragonData[i].open --[[and 1 == openCount]])
--        times = times + self._dragonData[i].times
        if self._dragonLayer[i]._layer:getChildByName("LayoutPanel") ~= nil then
            self._dragonLayer[i]._layer:removeChildByName("LayoutPanel")
        end

        if self._dragonData[i].open then

            -- 剩余次数panel
            local layout = ccui.Layout:create()
            layout:setAnchorPoint(cc.p(0,0))
            layout:setContentSize(cc.size(150, 30))   
            -- layout:setBackGroundColorOpacity(255)
            -- layout:setBackGroundColorType(1)
            layout:setName("LayoutPanel")

            local desTxt = ccui.Text:create()
            desTxt:setFontSize(18)
            desTxt:setFontName(UIUtils.ttfName)
            desTxt:setAnchorPoint(0,0.5)
            desTxt:setString("剩余次数:")
            desTxt:setPosition(20, 15)
            -- desTxt:setColor(cc.c3b(255, 252, 226))
            -- desTxt:enable2Color(1, cc.c4b(255, 232, 125, 255))
            desTxt:enableOutline(dragonOutlineColor, 1)
            layout:addChild(desTxt)

            local times = tab:Setting("G_PVE_" .. i).value
            local remainTimes = times - self._dragonData[i].times            

            local countTxt = ccui.Text:create()
            countTxt:setFontName(UIUtils.ttfName)
            countTxt:setFontSize(18)
            countTxt:setColor(UIUtils.colorTable.ccUIBaseColor2)
            countTxt:enableOutline(dragonOutlineColor, 1)
            countTxt:setString(string.format("%d/%d", remainTimes, times))
            countTxt:setPosition(115, 15)
            layout:addChild(countTxt)

            if 0 == remainTimes then
                countTxt:setColor(UIUtils.colorTable.ccUIBaseColor6)         
            end
            
            layout:setPosition(cc.p(-5, self._dragonLayer[i]._des:getPositionY()-15))
            self._dragonLayer[i]._layer:addChild(layout, 99)

            self._dragonLayer[i]._des:setVisible(false)
        else
            local dateInfo = {
                [1] = "一",
                [2] = "二",
                [3] = "三",
                [4] = "四",
                [5] = "五",
                [6] = "六",
                [7] = "日",
            }
            local date = ""
            for dayI = 1, #self._tableData[i].time do
                date = date .. dateInfo[self._tableData[i].time[dayI]]
                if dayI < #self._tableData[i].time then
                    date = date .. "、"
                end
            end
            date = date .. "开放"
            self._dragonLayer[i]._des:setVisible(true)
            self._dragonLayer[i]._des:setString(date)
        end
    end

    --self._labelTimesValue:setString(string.format("%d/%d", totalTimes - times, totalTimes))

    --self._imageDragon:setVisible(0 ~= self._dragonSelectedId) -- fixed me temp comment
    --self._imageDragon:loadTexture("dragon_port.png", 1) -- fixed me temp comment

    --if 1 == openCount then
    self:onDragonButtonClicked(self._dragonSelectedId)
    --end
    -- self:updateRankListPanel()
   

end

-- 更新左下角排行信息      
function DragonView:updateRankListPanel()
    local bossData = self._bossModel:getDataByPveId(self._dragonSelectedId) or {}
    local rankData = bossData.rankList or {}
    -- 按照rank排个序
    if rankData then
        table.sort(rankData, function(a, b)
            if not a.rank or not b.rank then
                return true
            else
                return a.rank < b.rank
            end
        end)
    end
    -- dump(bossData,"bossData",5)
    for i=1,3 do
        if rankData[i] then
            self["_rankNameNo" .. i]:setString(rankData[i].name or "")
        else
            self["_rankNameNo" .. i]:setString("暂无")
        end
    end
    local myRank = bossData.rank
    if not myRank or 0 == myRank then
        myRank = "暂无排名"
    end
    self._myRank:setString(myRank)
end

function DragonView:onDragonButtonClicked(index)
    if not self._dragonData[index].open then
        self._viewMgr:showTip(lang(string.format("TIPS_PVE_BOSS_%d2", index)))
        return
    end

    if self._dragonSelectedId == index and not self._firstShow then return end

    self._dragonSelectedId = index
    self._dragonSelectedHard = 1

    for i = 1, 3 do
--        self._dragonLayer[i]._selectBg:setVisible(i == index)
--        self._dragonLayer[i]._selected:setVisible(i == index)
        self._dragonLayer[i]._icon:setScale(self._dragonData[i].open and ( i == index and 1.1 or 1) or 0.95)
        self._dragonLayer[i]._icon:setScale(1.1)
        self._dragonLayer[i]._iconEffect:setVisible(self._dragonData[i].open and i == index)
    end

    local times = tab:Setting("G_PVE_" .. index).value
    local remainTimes = times - self._dragonData[index].times
--    if 0 == remainTimes then
--        self._labelTimesValue:setColor(UIUtils.colorTable.ccUIBaseColor6)
--        self._labelTimesValue:enableOutline(dragonOutlineColor, 2)
--    else
--        self._labelTimesValue:setColor(UIUtils.colorTable.ccUIBaseColor1)
--        self._labelTimesValue:enableOutline(dragonOutlineColor, 2)
--    end
--    self._labelTimesValue:setString(string.format("%d/%d", remainTimes, times))



    -- 对应boss的图标
--    for i = 1, #self._tableData[index].NPC do
--        local iconGrid = self._enemyLayer[i]
--        local teamId = self._tableData[index].NPC[i]
--        local teamTableData = tab:Npc(teamId)
--        local backQuality = self._modelMgr:getModel("TeamModel"):getTeamQualityByStage(teamTableData.stage)
--        local icon = IconUtils:createTeamIconById({teamData = {id = teamId, star = teamTableData.star}, sysTeamData = teamTableData, quality = backQuality[1], quaAddition = backQuality[2], tipType = 9, eventStyle = 2})
--        IconUtils:setTeamIconStarVisible(icon, false)
--        IconUtils:setTeamIconStageVisible(icon, false)
--        IconUtils:setTeamIconLevelVisible(icon, false)
--        icon:setScale(0.8)
--        icon:setPosition(0, 0)
--        iconGrid:addChild(icon, 15)
--    end

    self._label_enemy_name:setString(lang(string.format("TIPS_PVE_BOSS_%d0", index)) .. "推荐:")
    self._labelRecommand:setString(lang(string.format("TIPS_PVE_BOSS_%d1", index)))
    
    for i = 1, #self._recommandLayer do
        self._recommandLayer[i]:removeAllChildren()
    end
    for i = 1, #self._tableData[index]["recommend"] do
        local iconGrid = self._recommandLayer[i]
        iconGrid:removeAllChildren()
        local id = self._tableData[index]["recommend"][i]
        local icon = nil
        print("=====================",id)
        if string.len(id) == 5 then
            local sysHeroData = clone(tab:Hero(id))
            sysHeroData.hideFlag = true
            icon = IconUtils:createHeroIconById({sysHeroData = sysHeroData})
            -- icon:setAnchorPoint(cc.p(0,0))
            -- icon:setScale(0.67)
            icon:getChildByName("starBg"):setVisible(false)
            for i=1,6 do
                if icon:getChildByName("star" .. i) then
                    icon:getChildByName("star" .. i):setPositionY(icon:getChildByName("star" .. i):getPositionY() + 5)
                end
            end
            icon:setSwallowTouches(false)
            icon:setPosition(34, 34)
            icon:setScale(70 / icon:getContentSize().width)
            registerClickEvent(icon, function()
                local NewFormationIconView = require "game.view.formation.NewFormationIconView"
                self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = id}, true)
            end)

        else
            local teamId = id
            local teamTableData = tab:Team(teamId)
            -- dump(teamTableData,"teamTableData")
            local star = 0
            local stage = 1
            if teamTableData then
                star = teamTableData.star
                stage = teamTableData.stage
            end
            local backQuality = self._modelMgr:getModel("TeamModel"):getTeamQualityByStage(stage)
             icon = IconUtils:createTeamIconById({teamData = {id = teamId, star = star}, sysTeamData = teamTableData, quality = nil, quaAddition = backQuality[2], tipType = 9, eventStyle = 2})
--            icon = IconUtils:createSysTeamIconById({teamData = {id = teamId, star = star}, sysTeamData = tab:Team(teamId), quality = nil, quaAddition = backQuality[2], tipType = 8, eventStyle = 1})
           
            icon:setScale(67 / icon:getContentSize().width)
            icon:setPosition(0, 0)
            if star == 0 then
                icon:setSaturation(-100)
            end
            IconUtils:setTeamIconStarVisible(icon, false)
            IconUtils:setTeamIconStageVisible(icon, false)
            IconUtils:setTeamIconLevelVisible(icon, false)            
        end        
        iconGrid:setVisible(true)
        iconGrid:addChild(icon, 15)
    end  
    
--    for i = 1, #self._skillLayer do
--        self._skillLayer[i]:removeAllChildren()
--    end

--    for i = 1, #self._tableData[index]["skill"] do
--        local skillNode = self._skillLayer[i]
--        local skillIcon = IconUtils:createPveBossSkillIconById(
--            {bossSkill = {id = tostring(self._tableData[index]["skill"][i]), 
--                          art = "sk_longzhiguo_".. self._tableData[index]["skill"][i],
--                          name = "LONGZHIGUO_" .. self._tableData[index]["skill"][i],
--                          des = "LONGZHIGUODES_" .. self._tableData[index]["skill"][i]
--                          },
--                           eventStyle = 1
--            })
--        skillIcon:setScale(64 / skillIcon:getContentSize().width)
--        skillNode:addChild(skillIcon)
--    end
      
    -- 屏幕分辨率
    local screenW = math.min(MAX_SCREEN_WIDTH, 1136)
    local screenH = MAX_SCREEN_HEIGHT
    if ADOPT_IPHONEX then
        screenW = 1136
        screenH = 640
    end
    -- 龙的缩放比例
    local drangonW = screenW / 960
    
    if 0 ~= self._dragonSelectedId then
        if not self._firstShow then
            self._imageDragon:setVisible(true)
            local posX = self._posX
            local posY = self._posY
            local seq = cc.Sequence:create(
                    cc.MoveTo:create(0.2,cc.p(posX+50,posY)),
                    cc.CallFunc:create(function ()
                        local teamId = self._tableData[index].NPC[1]
                        local teamTableData = tab:Npc(teamId)
                        self._imageDragon:loadTexture("asset/uiother/team/" .. teamTableData.port .. ".png")
                        local drangonH = screenH / self._imageDragon:getContentSize().height                       
                        local scale = 1
                        -- 背景等比缩放比例
                        if drangonW > drangonH then
                            scale = drangonW
                        else
                            scale = drangonH
                        end
                        -- if self._imageDragon:getContentSize().height < 640 then
                            scale = scale + 0.1
                        -- end
                        -- print(self._imageDragon:getContentSize().height,"===******==========================",drangonW,drangonH,scale)
                        self._imageDragon:setScale(scale)
                        self._imageDragon:setPosition(posX-200, posY)
                    end),
                    cc.MoveTo:create(0.2,cc.p(posX+50,posY)),
                    cc.MoveTo:create(0.1,cc.p(posX,posY)))
            self._imageDragon:runAction(seq)
        else
            local teamId = self._tableData[index].NPC[1]
            local teamTableData = tab:Npc(teamId)
            self._imageDragon:loadTexture("asset/uiother/team/" .. teamTableData.port .. ".png")
            local drangonH = screenH / self._imageDragon:getContentSize().height
            local scale = 1
            -- 背景等比缩放比例
            if drangonW > drangonH then
                scale = drangonW
            else
                scale = drangonH
            end
            -- if self._imageDragon:getContentSize().height < 640 then
                scale = scale + 0.1
            -- end
            -- print(self._imageDragon:getContentSize().height,"=============================",drangonW,drangonH,scale)
            self._imageDragon:setScale(scale)
            self._imageDragon:setVisible(true)
            self._firstShow = false
        end
    end

    self:updateRankListPanel()
end

function DragonView:onShow()
    if self._bossModel:isNeedRequest() then
        self:doRequestData()
    else
        self._dragonData = self:initDragonData()
        self:updateUI()
        if self._dragonLevelSelectedDialog then
            self._dragonLevelSelectedDialog:updateUI()
        end
    end
end

function DragonView:onTop()
    if self._bossModel:isNeedRequest() then
        self:doRequestData()
    else
        self._dragonData = self:initDragonData()
        self:updateUI()
        if self._dragonLevelSelectedDialog then
            self._dragonLevelSelectedDialog:updateUI()
        end
    end
    self._viewMgr:enableScreenWidthBar()
end

function DragonView:onHide( )
    self._viewMgr:disableScreenWidthBar()
end
function DragonView:onComplete()
    self._viewMgr:enableScreenWidthBar()
end
function DragonView:onDestroy( )
    self._viewMgr:disableScreenWidthBar()
    DragonView.super.onDestroy(self)
end

function DragonView:onModelReflash()
    if self._bossModel:isNeedRequest() then
        self:doRequestData()
    else
        self._dragonData = self:initDragonData()
        self:updateUI()
        if self._dragonLevelSelectedDialog then
            self._dragonLevelSelectedDialog:updateUI()
        end
    end
end

function DragonView:doRequestData()
    self._serverMgr:sendMsg("BossServer", "getBossInfo", {}, true, {}, function(success)
        self._dragonSelectedId = 0
        self._dragonSelectedHard = 0
        self._dragonData = self:initDragonData()
        self:updateUI()
        if self._dragonLevelSelectedDialog then
            self._dragonLevelSelectedDialog:updateUI()
        end
    end)
end

function DragonView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView", {offset = {0, 0}, hideBtn = true,hideInfo = true},nil,ADOPT_IPHONEX and self.fixMaxWidth or nil)
end

function DragonView:onIconPressOn(icon)
    print("onIconPressOn")
end

function DragonView:onIconPressOff()
    print("onIconPressOff")
end

function DragonView:onDragonLevelSelected(dragonLevel)
    if not (self._battleFunciton[self._dragonSelectedId] and type(self._battleFunciton[self._dragonSelectedId]) == "function") then
        return 
    end
    local battle = function(battleData)
        self._dragonSelectedHard = dragonLevel
        local pveId = self._dragonSelectedId * 100 + self._dragonSelectedHard
        self._serverMgr:sendMsg("BossServer", "beforeAttackBoss", {id = pveId, serverInfoEx = BattleUtils.getBeforeSIE()}, true, {}, function(errorCode, result)
            if 0 ~= errorCode then 
                print("beforeAttackBoss error:", pveId, errorCode)
                -- self._viewMgr:onLuaError("beforeAttackBoss error:" .. "id:" .. pveId .. "error code:" .. errorCode)
                self._viewMgr:showTip(lang("TIPS_PVE_BOSS_02"))
                return 
            end
            if self._dragonLevelSelectedDialog then
                self._dragonLevelSelectedDialog:close()
                self._dragonLevelSelectedDialog = nil
            end
            self._token = result.token
            self._viewMgr:popView()
            local formationModel = self._modelMgr:getModel("FormationModel")
            self._battleFunciton[self._dragonSelectedId](pveId, BattleUtils.jsonData2lua_battleData(result["atk"]),
                function (info, callback)
                    dump(info, "battle info", 3)
                    if info.isSurrender then
                        callback(info)
                        return
                    end
                    local args = {win = info.win and 1 or 0,
                                  hp = info.exInfo.pro,
                                  damage = info.exInfo.damage,
                                  time = info.time,
                                  serverInfoEx = info.serverInfoEx,
                                  }
                    self._serverMgr:sendMsg("BossServer", "afterAttackBoss", {id = pveId, token = self._token, args = json.encode(args)}, true, {}, function(errorCode, result)
                        dump(result, "result", 5)
                        if 0 ~= errorCode then 
                            print("afterAttackBoss error:", PVEID, errorCode)
                            self._viewMgr:onLuaError("afterAttackBoss error:" .. "id:" .. pveId .. "error code:" .. errorCode)
                            return 
                        end
                        self._bossModel:setTimes(self._dragonSelectedId, result["d"]["boss"][tostring(self._dragonSelectedId)].times)
                        if result["d"]["boss"][tostring(self._dragonSelectedId)].diffList then
                            self._bossModel:updateDiffList(self._dragonSelectedId, result["d"]["boss"][tostring(self._dragonSelectedId)].diffList)
                        end
                        -- 更新排名和击杀矮人数量  wangyan
                        local subid = info.exInfo.subid or 1
                        --战斗前历史记录 wangyan
                        local curbossData = self._bossModel:getData()
                        if curbossData[tostring(subid)] and curbossData[tostring(subid)]["hValue"] then
                            info._preHValue = clone(curbossData[tostring(subid)]["hValue"])
                        else
                            info._preHValue = {}
                        end 

                        self._bossModel:setHighScore(subid, result["d"]["boss"][tostring(subid)])
                        -- info.exInfo.subid = self._dragonSelectedId
                        -- info.exInfo.diff = self._dragonSelectedHard
                        callback(info, result.reward)
                    end)
                end,
                function (info) end, GRandom(99999999))
        end)
    end

    self._viewMgr:showView("formation.NewFormationView", {
        formationType = self.FormationTypes[self._dragonSelectedId],
        recommend = self._tableData[self._dragonSelectedId]["recommend"],
        extend = {pveData = tab:PveSetting(self._dragonSelectedId * 100 + dragonLevel)},
        subType = self._dragonSelectedId * 100 + self._dragonSelectedHard,
        callback = function(formationData)
           battle(formationData)
        end
    })
end

function DragonView:onQuickPass(dragonLevel)
    --DialogUtils.showBuyDialog({costType = "gem", costNum = tonumber(tab:Setting("G_DRAGON_PASS").value), goods = "快速通关该难度", callback1 = function()
        self._dragonSelectedHard = dragonLevel
        local pveId = self._dragonSelectedId * 100 + self._dragonSelectedHard
        local dragonInfo = tab:Npc(tab:PveSetting(pveId).NPC[1])
        self._serverMgr:sendMsg("BossServer", "sweepBoss", {id = pveId, damage = dragonInfo.a4[1] and dragonInfo.a4[1] or 0}, true, {}, function(success, result)
            if not success then
                self._viewMgr:showTip("扫荡失败。请策划配表")
                return
            end
            local challengeTimes = result["d"]["boss"][tostring(self._dragonSelectedId)].times
            self._bossModel:setTimes(self._dragonSelectedId, challengeTimes)
            local params = {gifts = result.reward}
            if result then
                params.callback = function()
                    local currentTotalTimes = tab:Setting("G_PVE_" .. self._dragonSelectedId).value                    
                    -- 扫荡之后还能扫 不关闭选择界面    17.3.31 hgf
                    if challengeTimes >= currentTotalTimes and self._dragonLevelSelectedDialog then
                        self._dragonLevelSelectedDialog:close()
                        self._dragonLevelSelectedDialog = nil
                    end
                    self._dragonData = self:initDragonData()
                    self:updateUI()
                end
            end
            DialogUtils.showGiftGet(params)
        end)
    --end})
end

function DragonView:onDragonLevelClose()
   self._dragonLevelSelectedDialog = nil
end
function DragonView.dtor()
    -- body
    FormationIconView = nil
    PVEID = nil
    dragonOutlineColor = nil
end
return DragonView