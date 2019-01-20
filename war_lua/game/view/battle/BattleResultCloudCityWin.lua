--
-- Author: <ligen@playcrab.com>
-- Date: 2016-09-23 15:32:04
--

local BattleResultCloudCityWin = class("BattleResultCloudCityWin", BasePopView)

function BattleResultCloudCityWin:ctor(data)
    BattleResultCloudCityWin.super.ctor(self)
    self._result = data.result

    self._callback = data.callback
    self._battleInfo = data.data
    self._rewards = data.reward or data.rewards
end

function BattleResultCloudCityWin:getBgName()
    return "battleResult_bg.jpg"
end

function BattleResultCloudCityWin:onInit()
    self._touchPanel = self:getUI("touchPanel")
    self._touchPanel:setSwallowTouches(false)
    self._touchPanel:setEnabled(false)
    self:registerClickEvent(self._touchPanel, specialize(self.onQuit, self))
    -- 防止流程中报错无法关界面
    ScheduleMgr:delayCall(8000, self, function( )
        if tolua.isnull(self._touchPanel) then return end
        self._touchPanel:setEnabled(true)
    end)

    self._bestOutID = nil
    self._lihuiId = nil
    self._bg = self:getUI("bg")
    self._rolePanel = self:getUI("bg.role_panel")    
    self._roleImg = self:getUI("bg.role_panel.role_img")    
    self._roleImgShadow = self:getUI("bg.role_panel.roleImg_shadow")
    self._bgImg = self:getUI("bg.bg_img")
    self._bgImg:loadTexture("asset/bg/battleResult_flagBg.png")

    local bg_click = self:getUI("bg_click")
    bg_click:setSwallowTouches(false)
    self._countBtn = self:getUI("bg_click.countBtn")
    self._countBtn:setSwallowTouches(true)
    self._countBtn:setEnabled(false)
    self._countBtn:setOpacity(0)
    self._countBtn:setCascadeOpacityEnabled(true)
    UIUtils:formatBattleResultBtnTxt(self._countBtn:getChildByFullName("nameTxt"))
    self._bg1 = self:getUI("bg.bg1")
    self._bg2 = self:getUI("bg_click.bg2")
    self._bg2:setSwallowTouches(true)

    self._title = self:getUI("bg.title")
    self._title:setScale(2)
    -- self._title:setPositionY(self._title:getPositionY() + 15)
    -- self._title:setFontName(UIUtils.ttfName)

    self:registerClickEvent(self._countBtn, specialize(self.onCount, self))

    self._title:setOpacity(0)

    self._bg1:setVisible(false)
    self._bg2:setVisible(false)

    local titleStr = nil
    local desStr = nil
    if self._result.subId == "1" then
        titleStr = "[fontsize = 24]光之试炼通关！[-]"
        desStr = lang("towerwin_1")
    elseif self._result.subId == "2" then
        titleStr = "[fontsize = 24]暗之试炼通关！[-]"
        desStr = lang("towerwin_2")
    end
--    self._passTitle = RichTextFactory:create(titleStr, 170, 40)
--    self._passTitle:formatText()
--    self._passTitle:setVerticalSpace(7)
--    self._passTitle:setPosition(cc.p(768, 430))
--    self._bg:addChild(self._passTitle, 99)
--    self._passTitle:setOpacity(0)

    if self._rewards == nil or next(self._rewards) == nil then
        self._passDesLabel = RichTextFactory:create(desStr, 300, 40)
        self._passDesLabel:formatText()
        self._passDesLabel:setVerticalSpace(7)
        self._passDesLabel:setPosition(cc.p(768, 160))
        self._bg:addChild(self._passDesLabel, 99)
        self._passDesLabel:setCascadeOpacityEnabled(true)
        self._passDesLabel:setOpacity(0)
    end

    -- 人物
    local team
    self._teams = { }
    local invH = 100
    local invW = 90
    local count = #self._battleInfo.leftData
    local colume = 4
    local rowNum = math.ceil(count / colume)
    local teamModel = self._modelMgr:getModel("TeamModel")
    local outputID = self._battleInfo.leftData[1].D["id"]
    self._lihuiId = self._battleInfo.leftData[1].D["id"]
    local outputValue = self._battleInfo.leftData[1].damage or 0
    local outputLihuiV = self._battleInfo.leftData[1].damage or 0
    -- dump(self._battleInfo.leftData,"self._battleInfo.leftData==>")
    for i = 1, #self._battleInfo.leftData do
        if self._battleInfo.leftData[i].damage then
            if tonumber(self._battleInfo.leftData[i].damage) > tonumber(outputValue) then
                outputValue = self._battleInfo.leftData[i].damage
                outputID = self._battleInfo.leftData[i].D["id"]
            end
            if tonumber(self._battleInfo.leftData[i].damage) > tonumber(outputLihuiV) and self._battleInfo.leftData[i].original then
                outputLihuiV = self._battleInfo.leftData[i].damage
                self._lihuiId = self._battleInfo.leftData[i].D["id"]
            end
        end
    end

    local beginX = invW * 0.5
    local beginY = 200 - invH * 0.5
    local curHeroId = self._battleInfo.hero1["id"]
    local initTeamIconFunc = function(id,i)
        if self._result.d and teamModel:getTeamAndIndexById(id) then
            local teamD = tab:Team(id)
            -- dump(self._battleInfo.leftData[i].D,"self._battleInfo.leftData[i].D...")
            local teamData = teamModel:getTeamAndIndexById(id)
            local quality = teamModel:getTeamQualityByStage(teamData.stage)
            team = IconUtils:createTeamIconById( { teamData = teamData, sysTeamData = teamD, quality = quality[1], quaAddition = quality[2], eventStyle = 0 })
            team:setAnchorPoint(0.5, 0.5)
            -- team:setScale(0.5)
            -- 如果有专精变身替换icon

                local teampData = clone(teamData)
                teampData.teamId = id

                local art = nil
                local changeId = nil
                if curHeroId then 
                    art,changeId = TeamUtils.changeArtForHeroMastery(curHeroId,id)
                end
                local _,art = TeamUtils:getTeamAwakingTab(teamData,changeId,false)
                local teamIcon = team:getChildByFullName("teamIcon")
                teamIcon:loadTexture(art .. ".jpg",1)
            
            -- if curHeroId then
            --     local isAwaking, _ = TeamUtils:getTeamAwaking(teamData)
            --     local art,changeId = TeamUtils.changeArtForHeroMastery(curHeroId,id)
            --     if changeId and art then
            --         -- 觉醒优先
            --         if isAwaking then
            --             local tData = tab:Team(changeId)
            --             art = tData.jxart1
            --         end
            --         local teamIcon = team:getChildByFullName("teamIcon")
            --         teamIcon:loadTexture(art .. ".jpg",1)
            --     end
            -- end
            if i % 4 == 0 then
                team:setPosition(beginX, beginY)
                beginX = invW * 0.5
                beginY = beginY - invH
            else
                team:setPosition(beginX, beginY)
                beginX = beginX + invW
            end
            self._bg1:addChild(team)

--            if self._battleInfo.isTimeUp or self._battleInfo.leftData[i].die ~= -1 then
--                local dieIcon = cc.Sprite:createWithSpriteFrameName("globalImageUI4_dead.png")
--                dieIcon:setPosition(team:getContentSize().width / 2, team:getContentSize().height / 2)
--                -- team:setSaturation(-100)
--                dieIcon:setName("dieImg")
--                local child = team:getChildren()
--                for i = 1, #child do
--                    if child[i]:getName() ~= "dieImg" then
--                        child[i]:setSaturation(-100)
--                    end
--                end
--                team:addChild(dieIcon, 100)
--            end

            if outputID == id then
                team.isBestOutput = true
                local _, changeId = TeamUtils.changeArtForHeroMastery(curHeroId, id)
                self._bestOutID = changeId or outputID

            end

            self._teams[i] = team
        end
    end

    for i = 1, count do
        if self._battleInfo.leftData[i] and not self._battleInfo.leftData[i].copy then
            local id = self._battleInfo.leftData[i].D["id"]
            -- print("=============================",id)
            initTeamIconFunc(id,i)
        end
    end

    -- 物品
    if self._rewards ~= nil and next(self._rewards) ~= nil and not self._result.isFirstPass then
        rewards = {}
        for _,v in pairs(self._rewards) do
            table.insert(rewards, v)
        end
        local itemCount = table.nums(rewards)
        self._items = { }
        local inv = 90
        -- 计算初始位置
        local posX =(self._bg2:getContentSize().width - itemCount * inv) / 2 + inv / 2
        local beginX = posX
        for i = 1, itemCount do
            local item
            local itemId
            local isEffect = true
            if rewards[i] then
                itemId = rewards[i]["typeId"] or rewards[i][2]
                if itemId == 0 then
                    itemId = IconUtils.iconIdMap[rewards[i]["type"] or rewards[i][1]]
                end
                if tonumber(itemId) >= 3100 and tonumber(itemId) <= 4000 then
                    isEffect = false
                end
                item = IconUtils:createItemIconById( { itemId = itemId, num = rewards[i]["num"] or rewards[i][3], itemData = tab:Tool(rewards[i]["typeId"] or rewards[i][2]), effect = isEffect, isBranchDrop = true })

                -- 添加首次通关标志
                if self._result.isFirstPass then
                    local mc1 = mcMgr:createViewMC("wupinguang_itemeffectcollection", true)
                    mc1:setPosition(item:getContentSize().width / 2, item:getContentSize().height / 2)

                    item:addChild(mc1, 9)

                    local firstIcon = cc.Sprite:createWithSpriteFrameName("globalImageUI6_connerTag_r.png")
                    firstIcon:setAnchorPoint(cc.p(0, 0.5))
                    firstIcon:setPosition(firstIcon:getContentSize().width - 33, firstIcon:getContentSize().height + 20)
                    item:addChild(firstIcon, 8)

                    local firstTxt = cc.Label:createWithTTF("首通", UIUtils.ttfName, 22)
                    firstTxt:setRotation(41)
                    firstTxt:setPosition(cc.p(45, 37))
                    firstTxt:enableOutline(cc.c4b(146, 19, 5, 255), 3)
                    firstIcon:addChild(firstTxt)
                end

                item:setScale(2)
                item:setAnchorPoint(0.5, 0.5)
                item:setPosition(beginX +(i - 1) * inv, inv / 2)
                self._bg2:addChild(item)
                item:setVisible(false)
                self._items[i] = item
            end
        end
    end

    self._time = self._battleInfo.time

    local mcMgr = MovieClipManager:getInstance()
    -- mcMgr:loadRes("commonwin", function ()
    self:animBegin()
    -- end)
end

function BattleResultCloudCityWin:onQuit()
    if self._callback then
        self._callback()
    end
end

function BattleResultCloudCityWin:onCount()
    self._viewMgr:showView("battle.BattleCountView", self._battleInfo, true)
end

local soundDelaytick = { 400, 700, 1000 }
local delaytick = { 410, 440, 380 }

function BattleResultCloudCityWin:animBegin()
    audioMgr:stopMusic()
    audioMgr:playSoundForce("WinBattle")

    local liziAnim = mcMgr:createViewMC("liziguang_commonwin", true, false) 
    liziAnim:setPosition(MAX_SCREEN_WIDTH * 0.5, 135)
    self:getUI("bg_click"):addChild(liziAnim, 1000)

    -- 右侧旗子
    self._posBgX = self._bgImg:getPositionX()
    self._posBgY = self._bgImg:getPositionY()
    self._bgImg:setPositionY(self._posBgY+615)

    -- 如果兵团有变身技能，这里改变立汇
    local curHeroId = self._battleInfo.hero1["id"]
    local isChange = false
    local lihuiId = self._lihuiId
    if curHeroId then 
        local _,newId = TeamUtils.changeArtForHeroMastery(curHeroId,self._lihuiId)
        if newId then
            self._lihuiId = newId
            isChange = true
        end
    end

    local teamData = tab:Team(self._lihuiId) 
    if teamData then
        local imgName = string.sub(teamData["art1"], 4, string.len(teamData["art1"]))
        local artUrl = "asset/uiother/team/t_"..imgName..".png"
        -- 觉醒优先
        local teamModel = self._modelMgr:getModel("TeamModel")
        local tdata,_idx = teamModel:getTeamAndIndexById(lihuiId)
        local isAwaking,_ = TeamUtils:getTeamAwaking(tdata)
        local teamName, art1, art2, art3 = TeamUtils:getTeamAwakingTab(tdata, self._lihuiId)
        -- if isAwaking then 
        --     -- 结算例会单独处理 读配置
        --     imgName = teamData.jxart2
        --     artUrl = "asset/uiother/team/"..imgName..".png"
        -- end
        artUrl = "asset/uiother/team/".. art2 ..".png"

        if  teamData["jisuan"] then
            local teamX ,teamY = teamData["jisuan"][1], teamData["jisuan"][2]
            local scale = teamData["jisuan"][3] 
            self._roleImg:setPosition(teamX ,teamY)     
            self._roleImgShadow:setPosition(teamX+2,teamY-2)
            self._roleImg:setScale(scale)
            self._roleImgShadow:setScale(scale)
        end
        self._roleImg:loadTexture(artUrl)
        self._roleImgShadow:loadTexture(artUrl) 
    end
    local moveDis = 450
    local posRoleX, posRoleY = self._rolePanel:getPosition()
    local posBgX, posBgY = self._bgImg:getPosition()
    -- if not self._rolePanelLow then
    --     self._rolePanelLow = self._rolePanel:clone()
    --     self._rolePanelLow:setOpacity(150)
    --     -- self._rolePanelLow:setVisible(false)
    --     self._rolePanelLow:setCascadeOpacityEnabled(true)
    --     self._rolePanelLow:setPosition(self._rolePanel:getPosition())
    --     self._rolePanel:getParent():addChild(self._rolePanelLow, self._rolePanel:getZOrder() -1)
    -- end
    -- self._rolePanelLow:setPositionX(- moveDis)
    
    self._rolePanel:setPositionY(-moveDis)
    local moveRole = cc.Sequence:create(cc.MoveTo:create(0.1, cc.p(posRoleX, posRoleY+20)), cc.MoveTo:create(0.01, cc.p(posRoleX, posRoleY)))
    self._rolePanel:runAction(moveRole)
    -- local moveRoleLow = cc.Sequence:create(cc.DelayTime:create(0.06), cc.MoveTo:create(0.1, cc.p(posRoleX + 20, posRoleY)), cc.MoveTo:create(0.01, cc.p(posRoleX, posRoleY)))
    -- self._rolePanelLow:runAction(moveRoleLow)
    local animPos = self:getUI("bg.animPos")
     ScheduleMgr:delayCall(100, self, function(sender)
        local posBgX,posBgY = self._posBgX,self._posBgY
        local mc2
        local moveBg = cc.Sequence:create(
            cc.MoveTo:create(0.15,cc.p(posBgX,posBgY-20)),
            cc.MoveTo:create(0.01,cc.p(posBgX,posBgY)),
            cc.CallFunc:create(function()
                --胜利动画
                mc2 = mcMgr:createViewMC("shengli_commonwin", false)
                mc2:setPlaySpeed(1.5)
                mc2:setPosition(animPos:getPositionX(), animPos:getPositionY())
                self._bg:addChild(mc2, 5)
            end),
            cc.DelayTime:create(0.15),
            cc.CallFunc:create(function()
                -- 底光动画
                local mc1 = mcMgr:createViewMC("huodedaojudiguang_commonlight", true, false, function (_, sender)
                    sender:gotoAndPlay(80)         
                end,RGBA8888)
                mc1:setPosition(animPos:getPosition())

                local clipNode2 = cc.ClippingNode:create()
                clipNode2:setInverted(false)

                local mask = cc.Sprite:createWithSpriteFrameName("globalImage_IconMaskHalfCircle.png")
                mask:setScale(2.5)
                mask:setPosition(animPos:getPositionX(), animPos:getPositionY() + 140)
                clipNode2:setStencil(mask)
                clipNode2:setAlphaThreshold(0.01)
                clipNode2:addChild(mc1)
                clipNode2:setAnchorPoint(cc.p(0, 0))
                clipNode2:setPosition(0, 0)
                self._bg:addChild(clipNode2,4)
            end),
            cc.DelayTime:create(0.5),
            cc.CallFunc:create(function()
                --震屏
                UIUtils:shakeWindowRightAndLeft2(self._bg)
                end),
            cc.DelayTime:create(0.15),
            cc.CallFunc:create(function()
                self:animNext(mc2)
                end)
            )
        self._bgImg:runAction(moveBg)
    end )
end 

function BattleResultCloudCityWin:animNext(mc2)
    if mc2 == nil then
        return
    end

    local delayT = 400
    local animPos = self:getUI("bg.animPos")
 
    local mc3 = mcMgr:createViewMC("shenglixing_commonwin", true)
    mc3:setPosition(animPos:getPositionX(),animPos:getPositionY() - 70)
    self._bg:addChild(mc3, 4)

    self._timeLabel = cc.Label:createWithTTF("00:00", UIUtils.ttfName, 26)
    self._timeLabel:setColor(cc.c3b(245, 20, 34))
    self._timeLabel:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    self._timeLabel:setPosition(210, -32)
    mc2:getChildren()[1]:getChildren()[1]:addChild(self._timeLabel)
    if self._time then
        self:labelAnimTo(self._timeLabel, 0, self._time, true)
    end

--    self._passTitle:runAction(cc.Sequence:create(cc.DelayTime:create(2 -(delayT / 1000)), cc.FadeIn:create(0.3)))

    if self._passDesLabel ~= nil then
        self._passDesLabel:runAction(cc.Sequence:create(cc.DelayTime:create(2 -(delayT / 1000)), cc.FadeIn:create(0.3)))
    else
        if self._items and #self._items > 0 then
            self._title:runAction(cc.Sequence:create(
                cc.DelayTime:create(2 -(delayT / 1000)), 
                cc.FadeIn:create(0.01),
                cc.CallFunc:create(function()
                    local getAnim = mcMgr:createViewMC("huodedaojuguang_commonwin", false)
                    getAnim:setPosition(self._title:getPositionX(),  self._title:getPositionY() + 4)
                    self._title:getParent():addChild(getAnim, 3)
                    end),
                cc.EaseOut:create(cc.ScaleTo:create(0.3, 1), 1.5)
                ))
        end
    end
    self._countBtn:runAction(cc.Sequence:create(cc.DelayTime:create(2.3 -(delayT / 1000)), cc.FadeIn:create(0.3), cc.CallFunc:create( function()
        self._countBtn:setEnabled(true)

    
    end )))
    self._touchPanel:runAction(cc.Sequence:create(cc.DelayTime:create(2.7 -(delayT / 1000)), cc.CallFunc:create( function()
        self._touchPanel:setEnabled(true)
    end )))

    if self._teams then
        ScheduleMgr:delayCall((500 - delayT), self, function()
            self._bg1:setVisible(true)
            for i = 1, #self._teams do
                local team = self._teams[i]
                if team then
                    team:setScale(0.5)
                    team:setVisible(false)
                    ScheduleMgr:delayCall(i * 100, self, function()
                        team:setVisible(true)
                        local action = cc.Sequence:create(cc.ScaleTo:create(0.1, 1.2), cc.ScaleTo:create(0.1, 0.7))
                        team:runAction(action)

                        if team.isBestOutput and true == team.isBestOutput then
                            ScheduleMgr:delayCall(800, self, function()
                                if team then
                                    local bestOutImg = ccui.ImageView:create()
                                    bestOutImg:loadTexture("battleCount_bestOut.png", 1)
                                    bestOutImg:setScale(3)
                                    bestOutImg:setRotation(40)
                                    bestOutImg:setPosition(team:getContentSize().width - 15, team:getContentSize().height - bestOutImg:getContentSize().height / 2 - 5)
                                    bestOutImg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 0.8), cc.ScaleTo:create(0.1, 1)))
                                    team:addChild(bestOutImg, 10)
                                    team:setZOrder(10)
                                    --      local mc = mcMgr:createViewMC("zuijiashuchu_commonresultbest", false,false)
                                    --    mc:setPosition(team:getContentSize().width - 15, team:getContentSize().height - mc:getContentSize().height/2-18)
                                    -- team:addChild(mc,10)
                                    -- team:setZOrder(10)
                                end
                            end )
                        end
                    end )
                end
            end
        end )
    end

    if self._items then
        ScheduleMgr:delayCall((1600 - delayT), self, function()
            -- 显示获得道具
            if self._bg2 and self._title then
                self._bg2:setVisible(true)
                for i = 1, #self._items do
                    local item = self._items[i]
                    item:setScaleAnim(false)
                    item:runAction(cc.Sequence:create(
                        cc.DelayTime:create(i * 0.1+0.1), 
                        cc.CallFunc:create(function() 
                            item:setVisible(true)
                            local rwdAnim = mcMgr:createViewMC("daojuguang_commonwin", false)
                            rwdAnim:setPosition(item:getPosition())
                            item:getParent():addChild(rwdAnim, 7) 
                            end), 
                        cc.Spawn:create(cc.FadeIn:create(0.3), cc.ScaleTo:create(0.3, 0.78)),
                        cc.CallFunc:create(function() 
                            item:setScaleAnim(true) 
                            end)))
                end
            end
        end )
    end
end

function BattleResultCloudCityWin:labelAnimTo(label, src, dest, isTime)
    audioMgr:playSound("TimeCount")
    label.src = src
    label.now = src
    label.dest = dest
    label:setString(src)
    label.isTime = isTime
    label.step = 1
    label.updateId = ScheduleMgr:regSchedule(1, self, function(self, dt)
        if label:isVisible() then
            if label.isTime then
                local value = math.floor((label.dest - label.now) * 0.05)
                if value < 1 then
                    value = 1
                end
                label.now = label.now + value
            else
                label.now = label.src + math.floor((label.dest - label.src) *(label.step / 50))
                label.step = label.step + 1
            end
            if math.abs(label.dest - label.now) < 5 then
                label.now = label.dest
                ScheduleMgr:unregSchedule(label.updateId)
            end
            if label.isTime then
                label:setString(formatTime(label.now))
            else
                label:setString(label.now)
            end
        end
    end )
end

function BattleResultCloudCityWin.dtor()
    BattleResultCloudCityWin = nil
    delaytick = nil
    soundDelaytick = nil
end


return BattleResultCloudCityWin