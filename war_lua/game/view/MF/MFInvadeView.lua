--[[
    Filename:    MFInvadeView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-09-27 16:56:48
    Description: File description
--]]

-- 入侵

local MFInvadeView = class("MFInvadeView",BaseView)
-- local MFInvadeView = class("MFInvadeView",BasePopView)
function MFInvadeView:ctor(data)
    self.super.ctor(self)
    -- dump(data, "data ===", 10)

    self._task = data.task
    self._selectIndex = self._task.position
    self._enemyData = data.rival

    self._token = data.token
    self._r1 = data.r1
    self._r2 = data.r2
    self._award = data.award
end

-- 初始化UI后会调用, 有需要请覆盖
function MFInvadeView:onInit()
    local title = self:getUI("bg.rightBg.titleBg.title")
    UIUtils:setTitleFormat(title, 1)
    -- title:setFontName(UIUtils.ttfName)
    -- -- title:setColor(cc.c3b(250, 242, 192))
    -- -- title:enable2Color(1, cc.c4b(255, 195, 20, 255))
    -- -- title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    -- title:setFontSize(30)


    local title = self:getUI("bg.titleBg.title")
    title:setFontName(UIUtils.ttfName)
    title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)


    local tipLab  = self:getUI("bg.rightBg.panel.lab1")
    tipLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    self._storyLabBg = self:getUI("bg.rightBg.panel.storyLabBg")

    self:registerClickEventByName("bg.closeBtn",function( )
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("MF.MFInvadeView")
        end
        self:close()
    end)

    local seekPerson = self:getUI("bg.rightBg.seekPerson")
    self:registerClickEvent(seekPerson, function()
        local playerTimesData = self._modelMgr:getModel("PlayerTodayModel"):getData()
        if (tab:Setting("G_MF_LOOT_NUM")["value"] - playerTimesData["day28"]) > 0 then
            self:seekEnemy()
        else
            self._viewMgr:showTip(lang("MF_LOOT4"))
        end
    end)

    local invade = self:getUI("bg.rightBg.invade")
    self:registerClickEvent(invade, function()
        local playerTimesData = self._modelMgr:getModel("PlayerTodayModel"):getData()
        if (tab:Setting("G_MF_LOOT_NUM")["value"] - playerTimesData["day28"]) > 0 then
            self:robEnemy()
        else
            self._viewMgr:showTip(lang("MF_LOOT2"))
        end
    end)

    self._taskDes = self:getUI("bg.rightBg.panel.taskDes")

    self:listenReflash("MFModel", self.reflashUI)
    self:listenReflash("UserModel", self.updateUserData)

    self._xuanrenAnim = true
    self._cloudOpen = true
    self:updateDaoyu()
    self:reflashUI()
    self:setHanghaiBg()
end

function MFInvadeView:updateDaoyu()
    local daoyuIcon = self:getUI("bg.daoyuBg.daoyuIcon")
    local cityTab = tab:MfOpen(self._selectIndex)
    if not cityTab then
        return
    end
    if cityTab.cityimage then
        daoyuIcon:loadTexture(cityTab.cityimage .. ".png", 1)
        daoyuIcon:setAnchorPoint(cc.p(0.5, 0.5))
        daoyuIcon:setPosition(cc.p(daoyuIcon:getContentSize().width*0.5, daoyuIcon:getContentSize().height*0.5))
        daoyuIcon:setScale(cityTab["city"][3])
    end

    -- local daoyuBg = self:getUI("bg.daoyuBg")
    self._taskdetail = self:getUI("bg.daoyuBg.taskdetail")
    self._taskdetail:setPosition(cc.p(cityTab["task"][1], cityTab["task"][2]))
    self._taskdetail:setScale(cityTab["task"][3])
    if self._selectIndex < 6 then
        local dibiao = self._taskdetail:getChildByName("dibiao")
        if dibiao then
            dibiao:setSpriteFrame("mftask_dibiao" .. self._selectIndex .. ".png")
        else
            dibiao = cc.Sprite:create()
            dibiao:setAnchorPoint(cc.p(0.5, 0))
            dibiao:setName("dibiao")
            dibiao:setSpriteFrame("mftask_dibiao" .. self._selectIndex .. ".png")
            dibiao:setPosition(cc.p(self._taskdetail:getContentSize().width*0.5, self._taskdetail:getContentSize().height*0 + 8))
            self._taskdetail:addChild(dibiao,1)
        end
    else
        self._taskdetail:setVisible(false)
    end
end

-- 接收自定义消息
function MFInvadeView:reflashUI(data)
    if self._cloudOpen == true then
        audioMgr:playSound("mf_qiehuanyun")
        local beijing = mcMgr:createViewMC("yunqiehuan1_mfqiehuanyun", false, true, function()
            self._viewMgr:unlock()
        end)
        beijing:setAnchorPoint(cc.p(0.5,0.5))
        beijing:setPosition(cc.p(MAX_SCREEN_WIDTH*0.5, MAX_SCREEN_HEIGHT*0.5))
        self:addChild(beijing)
        self._cloudOpen = false
    end

    local taskTab = tab:MfTask(self._task.taskId)
    local starBg = self:getUI("bg.titleBg.starBg")
    local x = (starBg:getContentSize().width - taskTab.star*48)*0.5
    for i=1,5 do
        local iconStar = starBg:getChildByName("star" .. i)
        if i <= taskTab.star then
            if iconStar == nil then
                iconStar = cc.Sprite:createWithSpriteFrameName("globalImageUI6_star1.png")
                iconStar:setScale(1)
                iconStar:setAnchorPoint(cc.p(0, 1))
                starBg:addChild(iconStar,3) 
                iconStar:setName("star" .. i)
            else
                iconStar:setVisible(true)
            end
            iconStar:setPosition(x, starBg:getContentSize().height)
            x = x + iconStar:getContentSize().width*iconStar:getScaleX()
        else
            if iconStar then
                iconStar:setVisible(false)
            end
        end
    end

    -- local storyLab = self:getUI("bg.rightBg.panel.storyLab")
    -- storyLab:setString(lang(taskTab.lootstory))

    local title = self:getUI("bg.titleBg.title")
    title:setString(lang(taskTab.name))

    self:reflashEnemyData()
    self:setAward()
    self:updateUserData()
end

-- 设置奖励
function MFInvadeView:setAward()
    for i=1,3 do
        local itemBg = self:getUI("bg.rightBg.panel.awardBg" .. i)
        if i <= table.nums(self._award.awards) then
            local itemIcon = itemBg:getChildByName("itemIcon")
            local itemId = self._award.awards[i][2]

            if self._award.awards[i][1] == "tool" then
                num = self._award.awards[i][3]
            else
                itemId = IconUtils.iconIdMap[self._award.awards[i][1]]
                num = self._award.awards[i][3]
            end
            local param = {itemId = itemId, effect = true, eventStyle = 1, num = num}
            
            if itemIcon then
                IconUtils:updateItemIconByView(itemIcon, param)
            else
                itemIcon = IconUtils:createItemIconById(param)
                itemIcon:setName("itemIcon")
                itemIcon:setScale(itemBg:getContentSize().width/itemIcon:getContentSize().width)
                itemIcon:setPosition(cc.p(0,0))
                itemBg:addChild(itemIcon)
            end
            itemBg:setVisible(true)
        else
            itemBg:setVisible(false)
        end
    end
end

-- 刷新敌人数据
function MFInvadeView:reflashEnemyData()
    local iconBg = self:getUI("bg.rightBg.titleBg2.iconBg")
    if iconBg then
        local param1 = {avatar = self._enemyData.avatar, tp = 4,avatarFrame = self._enemyData["avatarFrame"]}
        local icon = iconBg:getChildByName("icon")
        if not icon then
            icon = IconUtils:createHeadIconById(param1)
            -- icon:setScale(0.9)
            icon:setPosition(cc.p(-5,-5))
            icon:setName("icon")
            iconBg:addChild(icon)
        else
            IconUtils:updateHeadIconByView(icon, param1)
        end
    end

    local name = self:getUI("bg.rightBg.titleBg2.name")
    name:setColor(UIUtils.colorTable.ccUIBaseOutlineColor)
    -- name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    name:setString(self._enemyData.name)

    local viplvl = self:getUI("bg.rightBg.titleBg2.viplvl")
    if (not self._enemyData.vipLvl) or tonumber(self._enemyData.vipLvl) == 0 then
        viplvl:setVisible(false)
    else
        viplvl:setVisible(true)
        viplvl:setFntFile(UIUtils.bmfName_vip)
        viplvl:setString("V" .. self._enemyData.vipLvl)
        viplvl:setPosition(cc.p(name:getPositionX() + name:getContentSize().width+10, name:getPositionY()-3))
    end

    local fightShow = self:getUI("bg.rightBg.titleBg2.fightShow")
    fightShow:setFntFile(UIUtils.bmfName_zhandouli)
    fightShow:setScale(0.6)
    if not self._enemyData.formation.score then
        self._enemyData.formation.score = 0
    end
    fightShow:setString("a" .. self._enemyData.formation.score)

    

    local richText = self._storyLabBg:getChildByName("richText")
    if richText then
        richText:removeFromParent()
    end

    local scoreLevel = 1
    local scoreNum = 0
    if TeamUtils:updateFightNum() ~= 0 then
        local formationModel = self._modelMgr:getModel("FormationModel")
        local tempscore = formationModel:getCurrentFightScoreByType(formationModel.kFormationTypeMF)
        print("tempscore ===========", tempscore, TeamUtils:updateFightNum())
        scoreNum = self._enemyData.formation.score / tempscore
        -- scoreNum = tempscore / TeamUtils:updateFightNum()
    end

    if scoreNum > 1.4 then
        scoreLevel = 5
    elseif scoreNum > 1.1 then
        scoreLevel = 4
    elseif scoreNum > 0.9 then
        scoreLevel = 3
    elseif scoreNum > 0.6 then
        scoreLevel = 2
    else
        scoreLevel = 1
    end

    local str = lang("MF_CE" .. scoreLevel)
    richText = RichTextFactory:create(str, self._storyLabBg:getContentSize().width, 0)
    richText:formatText()
    richText:setName("richText")
    richText:setPosition(self._storyLabBg:getContentSize().width/2, self._storyLabBg:getContentSize().height - richText:getRealSize().height/2)
    self._storyLabBg:addChild(richText)
end

-- 更新玩家数据
function MFInvadeView:updateUserData()
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local playerTimesData = self._modelMgr:getModel("PlayerTodayModel"):getData()

    local invadeNum = self:getUI("bg.rightBg.panel.invadeNum")
    local nowTimes = (tab:Setting("G_MF_LOOT_NUM")["value"] - playerTimesData["day28"]) 
    if nowTimes < 0 then
        nowTimes = 0
    end
    invadeNum:setString(nowTimes .. "/" .. tab:Setting("G_MF_LOOT_NUM")["value"])
    if nowTimes > 0 then
        invadeNum:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    else
        invadeNum:setColor(UIUtils.colorTable.ccUIBaseColor6)
    end

    local goldNum = self:getUI("bg.rightBg.goldNum")
    local goldIcon = self:getUI("bg.rightBg.goldIcon")
    goldNum:disableEffect()
    -- goldNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local tempgold = 0
    if playerTimesData["day29"] >= table.nums(tab:Setting("G_MF_COST")["value"]) then
        tempgold = tab:Setting("G_MF_COST")["value"][table.nums(tab:Setting("G_MF_COST")["value"])]
    elseif playerTimesData["day29"] == 0 then
        tempgold = 0
    else
        tempgold = tab:Setting("G_MF_COST")["value"][playerTimesData["day29"]]
    end
    if tempgold == 0 then
        tempgold = "免费"
        goldNum:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        -- goldNum:setVisible(false)
        -- goldIcon:setVisible(false)
    else
        goldNum:setVisible(true)
        goldIcon:setVisible(true)
        if tempgold <= userData.gold then
            
            goldNum:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        else
            goldNum:setColor(UIUtils.colorTable.ccUIBaseColor6)
            goldNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        end
    end
    
    goldNum:setString(tempgold)
end

function MFInvadeView:setNoticeBar()
    self._viewMgr:hideNotice(true)
end

function MFInvadeView:setHanghaiBg()
    local bg = self:getUI("bg")
    -- 背景
    local mc3 = mcMgr:createViewMC("haimian_mfhanghaifengweitexiao", true, false)
    mc3:setName("haimian")
    mc3:setScale(1.5)
    mc3:setPosition(480, 320)
    bg:addChild(mc3, -1)
end

-- 重新寻找敌人
function MFInvadeView:seekEnemy()
    print("重新寻找敌人 ===")
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local playerTimesData = self._modelMgr:getModel("PlayerTodayModel"):getData()
    local tempgold = 0
    if playerTimesData["day29"] >= table.nums(tab:Setting("G_MF_COST")["value"]) then
        tempgold = tab:Setting("G_MF_COST")["value"][table.nums(tab:Setting("G_MF_COST")["value"])]
    elseif playerTimesData["day29"] == 0 then
        tempgold = 0
    else
        tempgold = tab:Setting("G_MF_COST")["value"][playerTimesData["day29"]]
    end

    -- dump(playerTimesData, "playerTimesData===")
    -- dump(tab:Setting("G_MF_COST")["value"])
    -- print("gold ========", playerTimesData["day29"], tempgold , userData.gold)
    if tempgold <= userData.gold then
        self._serverMgr:sendMsg("MFServer", "matchRival", {}, true, {}, function(result) 
            -- dump(result, "vresult ===", 10)
            self._task = result.task
            self._selectIndex = self._task.position
            self._enemyData = result.rival

            self._token = result.token
            self._r1 = result.r1
            self._r2 = result.r2
            self._award = result.award

            self._viewMgr:lock(-1)
            local beijing = mcMgr:createViewMC("yunqiehuan_mfqiehuanyun", false, true)
            beijing:setAnchorPoint(cc.p(0.5,0.5))
            beijing:setPosition(cc.p(MAX_SCREEN_WIDTH*0.5, MAX_SCREEN_HEIGHT*0.5))
            self:addChild(beijing)

            beijing:addCallbackAtFrame(15, function(_, sender)
                self._cloudOpen = true
                self:updateDaoyu()
                self:reflashUI()
            end)
        end)
    else
        DialogUtils.showLackRes({goalType = "gold"})
    end
end

-- 入侵
function MFInvadeView:robEnemy()
        -- local playerInfo = self:getPlayerInfo()
        -- 
        -- dump(playerInfo)
        -- dump(enemyInfo, "enemyInfo ===")
        -- local playerInfo = self:getPlayerInfo()
        -- local enemyInfo = self:getEnemyInfo()
        self._modelMgr:getModel("MFModel"):setEnemyHeroData(self._enemyData.hero)
        self._modelMgr:getModel("MFModel"):setEnemyData(self._enemyData.teams)

        local formationType = self._modelMgr:getModel("FormationModel").kFormationTypeMF
        self._viewMgr:showView("formation.NewFormationView", {
            formationType = formationType,
            enemyFormationData = {[formationType] = clone(self._enemyData.formation)},
            callback = function(leftData)
                dump(self._award, "_award666==============", 5)
                self._serverMgr:sendMsg("MFServer", "deCnt", {serverInfoEx = BattleUtils.getBeforeSIE(), token = self._token}, true, {}, function(result)
                    local playerInfo = BattleUtils.jsonData2lua_battleData(result["atk"])
                    local enemyInfo = BattleUtils.jsonData2lua_battleData(self._enemyData) -- self:getEnemyInfo()
                    self._viewMgr:popView()
                    BattleUtils.enterBattleView_MF(playerInfo, enemyInfo,
                    function (info, callback)
                        -- 战斗结束
                        self:robMF(info, callback)
                    end,
                    function (info)
                        -- 退出战斗
                        -- print("啦啦啦啦啦")
                        -- ViewManager:getInstance():popView()
                            dump(self._award, "_award777==============", 5)
                            self._cloudOpen = true
                            self:updateDaoyu()
                            self:reflashUI()

                        
                        -- ViewManager:getInstance():lock(-1)
                        -- local beijing = mcMgr:createViewMC("yunqiehuan_mfqiehuanyun", false, true)
                        -- beijing:setAnchorPoint(cc.p(0.5,0.5))
                        -- beijing:setPosition(cc.p(MAX_SCREEN_WIDTH*0.5, MAX_SCREEN_HEIGHT*0.5))
                        -- self:addChild(beijing)

                        -- beijing:addCallbackAtFrame(15, function(_, sender)
                        --     self._cloudOpen = true
                        --     self:updateDaoyu()
                        --     self:reflashUI()
                        -- end)
                    end)
                end)  
            end,
            extend = {},
        })
end

function MFInvadeView:robMF(data, inCallBack)
    if data.win then
        self._battleWin = 1
    else
        self._battleWin = 0
    end

    local param = {data=json.encode({token = self._token, 
                    win = self._battleWin, 
                    time = data.time,
                    skillList = data.skillList,
                    serverInfoEx = data.serverInfoEx,
                    taskId = self._task["taskId"], 
                    postion = self._task["position"], 
                    awardId = self._award["id"]})}

    dump(self._award, "robMF=beg66666============", 5)
    self._serverMgr:sendMsg("MFServer", "robMF", param, true, {}, function(result)
        -- 像战斗层传送数据
        if result["extract"] then dump(result["extract"]["hp"], "robMF", 10) end
        if result.newRival then
            self._task = result.newRival.task
            self._selectIndex = self._task.position
            self._enemyData = result.newRival.rival

            self._token = result.newRival.token
            self._r1 = result.newRival.r1
            self._r2 = result.newRival.r2
            self._award = result.newRival.award

            if result.newRival.d and result.newRival.d.dayInfo then
                self._modelMgr:getModel("PlayerTodayModel"):updateDayInfo(result.newRival.d.dayInfo)
            end
            -- self:updateDaoyu()
            -- self:reflashUI()
        end
        if inCallBack ~= nil then
            inCallBack(result)
        end
    end)
end

-- 组装战斗数据 copy from GlobalFormationView
function MFInvadeView:getPlayerInfo()
    local formationModel = self._modelMgr:getModel("FormationModel")
    local playerInfo = formationModel:initBattleData(formationModel.kFormationTypeMF)[1]
    playerInfo.level = ModelManager:getInstance():getModel("UserModel"):getData().lvl
    return playerInfo
end

-- 组装战斗数据 copy from GlobalFormationView
function MFInvadeView:getEnemyInfo()
    local enemyInfo = BattleUtils.jsonData2lua_battleData(self._enemyData)

    -- 给布阵设数据
    -- self._modelMgr:getModel("MFModel"):setEnemyHeroData(self._enemyData.hero)
    -- self._modelMgr:getModel("MFModel"):setEnemyData(self._enemyData.teams)
    --
    return enemyInfo
end

return MFInvadeView
