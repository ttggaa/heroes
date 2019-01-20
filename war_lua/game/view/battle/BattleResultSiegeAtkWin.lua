--[[
    @FileName   BattleResultSiegeAtkWinWin
    @Authors    zhangtao
    @Date       2017-09-27 19:42:58
    @Email      <zhangtao@playcrad.com>
    @Description   描述
--]]
local BattleResultSiegeAtkWin = class("BattleResultSiegeAtkWin", BasePopView)

function BattleResultSiegeAtkWin:ctor(data)
    BattleResultSiegeAtkWin.super.ctor(self)
    self._result = data.result
    self._callback = data.callback
    self._rewards = data.rewards
    self._battleInfo = data.result --data.data
    self._star = self._result.star
    if self._star == nil then
        self._star = 3
    end
end
function BattleResultSiegeAtkWin:getBgName()
    return "battleResult_bg.jpg"
end
function BattleResultSiegeAtkWin:onInit()
    self._touchPanel = self:getUI("touchPanel")
    self._touchPanel:setSwallowTouches(false)
    self._touchPanel:setEnabled(false)
    self:registerClickEvent(self._touchPanel, specialize(self.onQuit, self))
    -- 防止流程中报错无法关界面
    ScheduleMgr:delayCall(8000, self, function( )
        if tolua.isnull(self._touchPanel) then return end
        self._touchPanel:setEnabled(true)
    end)
    --角色
    self._bg = self:getUI("bg")
    self._rolePanel = self:getUI("bg.role_panel")
    self._rolePanelX , self._rolePanelY = self._rolePanel:getPosition()
    self._roleImg = self:getUI("bg.role_panel.role_img")    
    self._roleImgShadow = self:getUI("bg.role_panel.roleImg_shadow")
    --面板背景图片
    self._bgImg = self:getUI("bg.bg_img")
    self._bgImg:loadTexture("asset/bg/battleResult_flagBg.png")

    local bg_click =  self:getUI("bg_click")
    bg_click:setSwallowTouches(false)
    self._quitBtn = self:getUI("bg_click.quitBtn")
    self._quitBtn:setSwallowTouches(true)

    --统计按钮
    self._countBtn = self:getUI("bg_click.countBtn")
    self._countBtn:setSwallowTouches(true)
    self._countBtn:setEnabled(false)
    self._countBtn:setOpacity(0)
    self._countBtn:setCascadeOpacityEnabled(true)
    UIUtils:formatBattleResultBtnTxt(self._countBtn:getChildByFullName("nameTxt"))
    --右侧文字面板
    self._bg1 = self:getUI("bg.bg1")
    self._bg1:setOpacity(0)
    self._bg1:setCascadeOpacityEnabled(true)

    self._bg2 = self:getUI("bg_click.bg2")
    self._bg2:setSwallowTouches(true)
    --获得道具
    self._title = self:getUI("bg.title")
    self._title:setScale(2)
    self._title:setOpacity(0)

    --排名上升
    self._upNum2 = self:getUI("bg.bg1.upNum2")
    self._upNum2:setVisible(false)
    self._upLab21 = self:getUI("bg.bg1.upNum2.Label_38")
    self._upLab22 = self:getUI("bg.bg1.upNum2.Label_39")
    self._upLab21:setString("")
    self._upLab21:setOpacity(0)
    self._upLab21:enableOutline(cc.c4b(0,0,0,255),1)
    self._upLab22:setString("")
    self._upLab22:setOpacity(0)
    self._upLab22:enableOutline(cc.c4b(0,0,0,255),1)
    --历史新高
    self._historyImg = self:getUI("bg.bg1.historyImg")
    -- self._historyImg:setScale(0.85)
    self._historyImg:setVisible(false)

    --攻城伤害
    self._monsterName1 = self:getUI("bg.bg1.des1")
    self._monsterName1:enableOutline(cc.c4b(0,0,0,255),1)
    self._count1 = self:getUI("bg.bg1.count1")
    self._count1:enableOutline(cc.c4b(0,0,0,255),1)
    --女王鼓舞
    self._buff = self:getUI("bg.bg1.buff")
    self._buff:setVisible(false)
    --我的排名
    self._monsterName2 = self:getUI("bg.bg1.des2")
    self._monsterName2:enableOutline(cc.c4b(0,0,0,255),1)
    self._count2 = self:getUI("bg.bg1.count2")
    self._count2:enableOutline(cc.c4b(0,0,0,255),1)
    --攻城进度
    self._monsterName3 = self:getUI("bg.bg1.des3")
    self._monsterName3:enableOutline(cc.c4b(0,0,0,255),1)
    self._count3 = self:getUI("bg.bg1.count3")
    self._count3:enableOutline(cc.c4b(0,0,0,255),1)
    -- self._monsterName3:setVisible(false)
    -- self._count3:setVisible(false)
    --最后一击
    self._lastHurt = self:getUI("bg.bg1.lastKill")
    self._lastHurt:setVisible(false)

    --最后一击
    local isLast = self._result["extend"]["isLast"]
    if isLast and isLast == 1 then
        self._lastHurt:setVisible(true)
    end


    self:registerClickEvent(self._quitBtn, specialize(self.onQuit, self))
    self:registerClickEvent(self._countBtn, specialize(self.onCount, self))

    local isHasLucyAward = false   --幸运奖励
    local rewardsData = self._result.reward or self._rewards or {} 
    local exReward = self._result["extend"]["exReward"] or {}
    local tempRewards = clone(rewardsData)
    if next(exReward) then
        table.insert(tempRewards,exReward[1])
        isHasLucyAward = true
    end
    local itemCount = table.nums(tempRewards)
    if tempRewards and itemCount > 0 then
        self._items = {}
        local inv = 80
        local posX = (self._bg2:getContentSize().width - itemCount*inv)/2 + inv/2
        local beginX = posX
        for i = 1, itemCount do
            local itemId = tempRewards[i][2] or tempRewards[i]["typeId"]
            if itemId == 0 then
                itemId = IconUtils.iconIdMap[tempRewards[i][1] or tempRewards[i]["type"]] 
            end
            local item = IconUtils:createItemIconById({itemId = itemId, num = tempRewards[i][3] or tempRewards[i]["num"], itemData = tab:Tool( tempRewards[i][2])})
            -- item:setScale(0.7)
            item:setAnchorPoint(0.5, 0.5)
            item:setPosition(beginX + (i - 1) * inv, 30)
            self._bg2:addChild(item)
            item:setVisible(false)
            item._id = tempRewards[i][2] or tempRewards[i]["typeId"]
            self._items[i] = item
            if isHasLucyAward and i == itemCount then
                local luckNode = ccui.ImageView:create()
                luckNode:loadTexture("siege_luckyIcon.png",1)
                luckNode:setPosition(80,80)
                item:addChild(luckNode,100)
            end
        end
    end
    
    self._time = self._battleInfo.time

    --进度
    local siegeModel = self._modelMgr:getModel("SiegeModel")
    local buffNum = self._result["extend"]["buff"] or 0
    local damageValue = self._result.totalDamage1
    self._count1:setString(damageValue)
    -- local maxHurt = self._result["extend"]["maxhurt"] or 0
    local isMaxHurt = self._result["extend"]["isMax"] or false
    self._historyImg:setVisible(isMaxHurt) 
    -- self._historyImg:setVisible(true)
    
    local maxHp = self._result["extend"]["maxHp"]
    local progressValue = 0
    
    if tonumber(damageValue) >= tonumber(maxHp) then
        progressValue = 100
        self._count3:setString("+"..tonumber(progressValue) .."%")
    else
        progressValue = string.format("%0.3f",((damageValue*100)/maxHp))
            --女王鼓舞
            -- progressValue = 0.001
        if tonumber(progressValue) ~= 0 then
            local addBuffHurt = damageValue*(tonumber(buffNum)/100)
            local addProgress = string.format("%0.4f",(addBuffHurt*100/maxHp))
            if tonumber(addProgress) == 0 then
                addProgress = 0.0001

            end
            self._count3:setString("+"..tonumber(progressValue) .."%")
            self._buff:setString("(鼓舞+"..tonumber(addProgress).."%)")
            self._buff:setVisible(true)
        end

        if tonumber(progressValue) == 0 then
            if tonumber(damageValue) > 0 then
                progressValue = 0.001
                self._count3:setString("<"..tonumber(progressValue) .."%")
            else
                self._count3:setString("0%")
            end
            self._buff:setVisible(false)
        end
        self._count3:setVisible(true)

    end
    print("=======damageValue/maxHp========"..damageValue/maxHp)
    

    self._buff:setPositionX(self._count3:getPositionX() + self._count3:getContentSize().width)
    --我的排名
    local newRank = self._result["extend"]["newRank"] or 0
    self._count2:setString(newRank)
    local oldRank = self._result["extend"]["oldRank"] or 0
    -- self._historyImg:setVisible(oldRank>newRank)
    
    if oldRank > newRank then
        self._upLab21:setString("(")
        self._upLab22:setString((oldRank - newRank) .. " )")
        self._upNum2:setVisible(true)
        self._upNum2.isShow = true
    end
    self._upNum2:setPositionX(self._count2:getPositionX() + self._count2:getContentSize().width + 30)


    self._bestOutID = self._battleInfo.leftData[1].D["id"]
    self._lihuiId =   self._battleInfo.leftData[1].D["id"]
    local outputValue = self._battleInfo.leftData[1].damage or 0
    local outputLihuiV = self._battleInfo.leftData[1].damage or 0
    for i = 1,#self._battleInfo.leftData do
        if self._battleInfo.leftData[i].damage then
            if tonumber(self._battleInfo.leftData[i].damage) > tonumber(outputValue) then
                outputValue = self._battleInfo.leftData[i].damage
                self._bestOutID = self._battleInfo.leftData[i].D["id"]
            end
            if tonumber(self._battleInfo.leftData[i].damage) > tonumber(outputLihuiV) and self._battleInfo.leftData[i].original then
                outputLihuiV = self._battleInfo.leftData[i].damage
                self._lihuiId = self._battleInfo.leftData[i].D["id"]
            end
        end
    end
    -- local lihuiId = self._lihuiId

    local mcMgr = MovieClipManager:getInstance()
    if self._result.win then
        self:animBegin(true)
    else 
        self:animBegin()
    end
    --判断是否已攻破
    local bloodKey = {
        [10001] = "blood1",
        [10002] = "blood2",
        [10003] = "blood3",
        [10004] = "blood4",
        [10005] = "blood5"
    }
    local stageId = self._result["extend"]["stageId"]
    local blood = siegeModel:getData()[bloodKey[stageId]] or 0
    if isLast == 0 and blood == 0 then
        self._viewMgr:showTip(lang("TIPS_SIEGE_WARNINGTIPS1"))
    end
end

function BattleResultSiegeAtkWin:onQuit()
    if self._callback then
        self._callback()
        -- UIUtils:reloadLuaFile("battle.BattleResultSiegeAtkWin")
    end
end

function BattleResultSiegeAtkWin:onCount()
    self._viewMgr:showView("battle.BattleCountView",self._battleInfo,true)
end

local delaytick = {360, 380, 380}
function BattleResultSiegeAtkWin:animBegin(isWin)
    audioMgr:stopMusic()
    if isWin then
        audioMgr:playSoundForce("WinBattle")
    else
        audioMgr:playSoundForce("SurrenderBattle")
    end

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
        local moveDis = 450
        local posRoleX,posRoleY = self._rolePanel:getPosition()
        local posBgX,posBgY = self._bgImg:getPosition()
     --    if not self._rolePanelLow then 
        --  self._rolePanelLow = self._rolePanel:clone()
        --  self._rolePanelLow:setOpacity(150)
        --  self._rolePanelLow:setCascadeOpacityEnabled(true)
        --  self._rolePanelLow:setPosition(self._rolePanel:getPosition())
        --  self._rolePanel:getParent():addChild(self._rolePanelLow, self._rolePanel:getZOrder()-1)
        -- end
        -- self._rolePanelLow:setPositionX(-moveDis)
        self._rolePanel:setPositionY(-moveDis)
        local moveRole = cc.Sequence:create(cc.MoveTo:create(0.1,cc.p(posRoleX,posRoleY+20)),cc.MoveTo:create(0.01,cc.p(posRoleX,posRoleY)))
        self._rolePanel:runAction(moveRole)
     --    local moveRoleLow = cc.Sequence:create(cc.DelayTime:create(0.06), cc.MoveTo:create(0.1,cc.p(posRoleX+20,posRoleY)),cc.MoveTo:create(0.01,cc.p(posRoleX,posRoleY)))
        -- self._rolePanelLow:runAction(moveRoleLow)        
    end

    local animPos = self:getUI("bg.animPos")
    ScheduleMgr:delayCall(100, self, function(sender)
        local posBgX,posBgY = self._posBgX,self._posBgY
        local moveBg, mc2
        if isWin then
            moveBg = cc.Sequence:create(
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
                cc.DelayTime:create(0.3),
                cc.CallFunc:create(function()
                    --震屏
                    UIUtils:shakeWindowRightAndLeft2(self._bg)
                    end),
                cc.DelayTime:create(0.15),
                cc.CallFunc:create(function()
                    self:animNext(isWin, mc2)
                    end)
                )
            self._bgImg:runAction(moveBg)
        else
            moveBg = cc.Sequence:create(
                cc.MoveTo:create(0.15,cc.p(posBgX,posBgY-20)),
                cc.MoveTo:create(0.01,cc.p(posBgX,posBgY)))
            self._bgImg:runAction(moveBg)
            self:animNext(isWin)
        end        
    end)
end
function BattleResultSiegeAtkWin:animNext(isWin, mc2)
    local animPos = self:getUI("bg.animPos")
    if isWin then
        local mc3 = mcMgr:createViewMC("shenglixing_commonwin", true)
        mc3:setPosition(animPos:getPositionX(),animPos:getPositionY() - 70)
        self._bg:addChild(mc3, 4)
    
        self._timeLabel = cc.Label:createWithTTF("00:00", UIUtils.ttfName, 26)
        self._timeLabel:setColor(cc.c3b(245, 20, 34))
        self._timeLabel:enableOutline(cc.c4b(0,0,0,255),1)
        self._timeLabel:setPosition(213, -28)
        mc2:getChildren()[1]:getChildren()[1]:addChild(self._timeLabel)
        if self._time then
            self:labelAnimTo(self._timeLabel, 0, self._time, true)
        end

    else
        mc2 = mcMgr:createViewMC("shibai_commonlose", true, false, function (_, sender)
            sender:gotoAndPlay(100)
        end)
        mc2:setPosition(animPos:getPosition())
        self._bg:addChild(mc2,11)
    end

    self._title:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.5), 
        cc.FadeIn:create(0.01),
        cc.CallFunc:create(function()
            local getAnim = mcMgr:createViewMC("huodedaojuguang_commonwin", false)
            getAnim:setPosition(self._title:getPositionX(),  self._title:getPositionY() + 4)
            self._title:getParent():addChild(getAnim, 3)
            end),
        cc.EaseOut:create(cc.ScaleTo:create(0.3, 1), 1.5)
        ))

    self._countBtn:runAction(cc.Sequence:create(cc.DelayTime:create(2.0), cc.FadeIn:create(0.3),cc.CallFunc:create(function ()
        self._countBtn:setEnabled(true)
    end)))
    self._bg1:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.FadeIn:create(0.3)))
    -- if self._upNum1.isShow == true then
    --  self._upLab11:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.FadeIn:create(0.3)))
    --  self._upLab12:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.FadeIn:create(0.3)))
    -- end
    if self._upNum2.isShow == true then
        self._upLab21:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.FadeIn:create(0.3)))
        self._upLab22:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.FadeIn:create(0.3)))
    end
    --  self._proFrame:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
    --     self._proFrame:setVisible(true)
    -- end)))
    self._touchPanel:runAction(cc.Sequence:create(cc.DelayTime:create(2.2), cc.CallFunc:create(function()
        self._touchPanel:setEnabled(true)

    end)))

    --奖励icon
    if self._items then
        ScheduleMgr:delayCall(1000, self, function()
            -- 显示获得道具
            if self._bg2 and self._title then 
                self._bg2:setVisible(true)
                -- self._title:runAction(cc.MoveBy:create(0.05,cc.p(0,-15)))
                for i = 1, #self._items do
                    local item = self._items[i]
                    item:setScaleAnim(false)
                    item:runAction(cc.Sequence:create(
                        cc.CallFunc:create(function() 
                            item:setVisible(true) 
                            local rwdAnim = mcMgr:createViewMC("daojuguang_commonwin", false)
                            rwdAnim:setPosition(item:getPosition())
                            item:getParent():addChild(rwdAnim, 7)
                            end), 

                        cc.Spawn:create(cc.FadeIn:create(0.2), cc.ScaleTo:create(0.2, 0.78)),
                        cc.CallFunc:create(function() item:setScaleAnim(true) end)))
                end
            end
        end)
    end
end



function BattleResultSiegeAtkWin:labelAnimTo(label, src, dest, isTime)
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
                label.now = label.src + math.floor((label.dest - label.src) * (label.step / 50))
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
    end)
end

function BattleResultSiegeAtkWin.dtor()
    BattleResultSiegeAtkWin = nil
    delaytick = nil
    -- diffList = nil
end

return BattleResultSiegeAtkWin
