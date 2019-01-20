--
-- Author: huangguofang
-- Date: 2018-12-19 17:23:22
--

local BattleResultLegionsWin = class("BattleResultLegionsWin", BasePopView)

function BattleResultLegionsWin:ctor(data)
    BattleResultLegionsWin.super.ctor(self)

    self._battleInfo = data.result
    self._callback = data.callback
    self._rewards = data.rewards

    self._hpPercent = self._battleInfo.hpPercent or 0
    self._proPercent = 100 - self._hpPercent
    self._stageData = self._battleInfo.stageData or {}
end
function BattleResultLegionsWin:getBgName()
    return "battleResult_bg.jpg"
end
function BattleResultLegionsWin:onInit()
    self._touchPanel = self:getUI("touchPanel")
    self._touchPanel:setSwallowTouches(false)
    self._touchPanel:setEnabled(false)
    self:registerClickEvent(self._touchPanel, specialize(self.onQuit, self))
    -- 防止流程中报错无法关界面
    ScheduleMgr:delayCall(8000, self, function( )
        if tolua.isnull(self._touchPanel) then return end
        self._touchPanel:setEnabled(true)
    end)
    
    self._bg = self:getUI("bg")
    self._rolePanel = self:getUI("bg.role_panel")
    self._rolePanelX , self._rolePanelY = self._rolePanel:getPosition()
    self._roleImg = self:getUI("bg.role_panel.role_img")    
    self._roleImgShadow = self:getUI("bg.role_panel.roleImg_shadow")

    self._bgImg = self:getUI("bg.bg_img")
    self._bgImg:loadTexture("asset/bg/battleResult_flagBg.png")

    local bg_click =  self:getUI("bg_click")
    bg_click:setSwallowTouches(false)
    self._quitBtn = self:getUI("bg_click.quitBtn")
    self._quitBtn:setSwallowTouches(true)
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
 

    self._pro = self:getUI("bg.bg1.progressBar")
    self._proSplit = self:getUI("bg.bg1.progrFrame.progressSplit")
    self._proFrame = self:getUI("bg.bg1.progrFrame")
    self._des2 = self:getUI("bg.bg1.des2")
    self._des2:enableOutline(cc.c4b(0,0,0,255),1)
    self._count2 = self:getUI("bg.bg1.count2")
    self._count2:enableOutline(cc.c4b(0,0,0,255),1)    

    self:registerClickEvent(self._quitBtn, specialize(self.onQuit, self))
    self:registerClickEvent(self._countBtn, specialize(self.onCount, self))

    self._title:setOpacity(0)   
    self._bg1:setOpacity(0)
    self._bg1:setCascadeOpacityEnabled(true)
    self._proFrame:setVisible(false)
    local tempRewards = self._stageData.reward or {} 
    local itemCount = table.nums(tempRewards)
    if tempRewards and itemCount > 0 then
        self._items = {}
        local inv = 80
        local posX = (self._bg2:getContentSize().width - itemCount*inv)/2 + inv/2
        local beginX = posX
        for i = 1, itemCount do
            local item = IconUtils:createItemIconById({itemId = tempRewards[i][2] or tempRewards[i]["typeId"], num = tempRewards[i][3] or tempRewards[i]["num"], itemData = tab:Tool( tempRewards[i][2])})
            item:setScale(0.7)
            item:setAnchorPoint(0.5, 0.5)
            item:setPosition(beginX + (i - 1) * inv, 24)
            self._bg2:addChild(item)
            item:setVisible(false)
            item._id = tempRewards[i][2] or tempRewards[i]["typeId"]
            self._items[i] = item
        end
    end

    self._time = self._battleInfo.time
    self._count2:setString(self._proPercent .. "%")
    self:initMark()

    self._bestOutID = self._battleInfo.leftData[1].D["id"]
    self._lihuiId = self._battleInfo.leftData[1].D["id"]
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

    local mcMgr = MovieClipManager:getInstance()
    if self._battleInfo.win then
        self:animBegin(true)
    else 
        self:animBegin()
    end
end

function BattleResultLegionsWin:onQuit()
    if self._callback then
        self._callback()
        -- UIUtils:reloadLuaFile("battle.BattleResultLegionsWin")
    end
end

function BattleResultLegionsWin:onCount()
    self._viewMgr:showView("battle.BattleCountView",self._battleInfo,true)
end

local delaytick = {360, 380, 380}
function BattleResultLegionsWin:animBegin(isWin)
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
    
        self._rolePanel:setPositionY(-moveDis)
        local moveRole = cc.Sequence:create(cc.MoveTo:create(0.1,cc.p(posRoleX,posRoleY+20)),cc.MoveTo:create(0.01,cc.p(posRoleX,posRoleY)))
        self._rolePanel:runAction(moveRole)
        
    end

    local animPos = self:getUI("bg.animPos")
    ScheduleMgr:delayCall(100, self, function(sender)
        local posBgX,posBgY = self._posBgX,self._posBgY
        local moveBg, mc2
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
               
    end)
end
function BattleResultLegionsWin:animNext(isWin, mc2)
    local animPos = self:getUI("bg.animPos")

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

    self._title:runAction(cc.Sequence:create(
        cc.DelayTime:create(1), 
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
    
    self._proFrame:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
        self._proFrame:setVisible(true)
    end)))
    self._touchPanel:runAction(cc.Sequence:create(cc.DelayTime:create(2.2), cc.CallFunc:create(function()
        self._touchPanel:setEnabled(true)

    end)))
    local proIdx = 1
    local proStep = 3
    local proNow = 0
    local progressSch 
    if self._items then
        ScheduleMgr:delayCall(500, self, function()
            -- 显示获得道具
            self._bg2:setVisible(true)
            progressSch = ScheduleMgr:regSchedule(1,self,function()
                proNow = math.min(self._proPercent,proNow+proStep)
                if proNow <= self._proPercent or (self._proPercent == 0 and proNow <= self._proPercent+proStep) then
                    self._pro:setPercent(proNow)
                    if self._proPercent == 0 then
                        self._pro:setPercent(0)
                    end
                    for i=1,#self._marks do
                        local mark = self._marks[i]
                        if proNow >= mark._value and not mark._fixed and mark._to and mark._target then
                            mark._fixed = true
                            -- mark:setBrightness(40)
                            if mark.split2 then
                                if i == 4 or i == 6 then
                                    mark.split2:loadTexture("dragonSplit2_light_battle.png",1)
                                else
                                    mark.split2:loadTexture("dragonSplit_light_battle.png",1)
                                end
                            end
                            local mc1 = mcMgr:createViewMC("feixingguang_dragonwin", false, true)
                            mc1:addCallbackAtFrame(7,function( )
                                local item = self._items[i]
                                if item then
                                    item:setVisible(true) 
                                    item:setScaleAnim(true)
                                    local itemMc = mcMgr:createViewMC("wupinshanguang_dragonwin", false, true, function (_, sender)
                                        -- sender:gotoAndPlay(1)
                                    end)
                                    itemMc:setPosition(mark._to)
                                    self._bg:addChild(itemMc, 99)
                                end
                            end)
                            mc1:setPlaySpeed(1.2)
                            mc1:setPosition(mark._to) --cc.p(0,0)) -- cc.p(mark._to.x-135,mark_to))
                            local angle = math.atan2(mark._from.y-mark._to.y,mark._from.x-mark._to.x)
                            local rotation = -angle*180/3.14+180
                            mc1:setRotation(rotation)
                            self._bg:addChild(mc1, 999)

                            local mc2
                            if i == 4 or i == 6 then
                                mc2 = mcMgr:createViewMC("kuosanguangxiao_dragonwin", true, false, function (_, sender)
                                    sender:gotoAndPlay(20)
                                end)
                            else
                                mc2 = mcMgr:createViewMC("kuosanguangxiao_dragonwin", true, false, function (_, sender)
                                    sender:gotoAndPlay(20)
                                end)
                            end
                            mc2:setPosition(mark:getContentSize().width/2+2, mark:getContentSize().height/2)
                            mark:addChild(mc2)
                        end
                    end
                    if proNow == self._proPercent or proNow >= 100 then
                        ScheduleMgr:unregSchedule(progressSch)
                    end
                else
                    ScheduleMgr:unregSchedule(progressSch)
                end
            end )
        end)
    else
        progressSch = ScheduleMgr:regSchedule(1,self,function()
            proNow = proNow+proStep
            if proNow <= self._proPercent then
                self._pro:setPercent(proNow)
            else
                ScheduleMgr:unregSchedule(progressSch)
            end
        end)
        self._title:setVisible(false)
    end

end

function BattleResultLegionsWin:initMark( )
    
    local marks = {}
    local proWidth = self._pro:getContentSize().width
    if self._stageData and self._stageData.reward then
        local reward = self._stageData.reward
        for k,v in pairs(reward) do
            local pos = cc.p((v[4]/100)*proWidth,0)
            local split
            if not self._proSplit._used then
                split = self._proSplit
                self._proSplit._used = true
            else
                split = self._proSplit:clone()
                self._proFrame:addChild(split)
            end
            split:setPositionX(pos.x)           
            table.insert(marks,split)

            local split2 = ccui.ImageView:create()
            split2:loadTexture("dragonSplit_gray_battle.png",1)
            split2:setPosition(pos.x, split:getPositionY()-20)
            self._proFrame:addChild(split2)
            split.split2 = split2
            split._value = v[4]
            if v[4] == 100 then 
                split:setOpacity(0)
            end
            local splitWorldPos = split:convertToWorldSpaceAR(cc.p(0,0)) 
            split._from = splitWorldPos -- self._bg:convertToWorldSpace(pos) 
            -- dump(split._from)
            if self._items then
                for k1,v1 in pairs(self._items) do
                    print("v1 id ,...",v1._id == v[2],v1._id ,v[2])
                    if not v1._dirty then
                        v1._dirty = true
                        local v1Pos = cc.p(v1:getPosition())
                        -- local v1worldPos = v1:convertToWorldSpaceAR(cc.p(0,0))
                        -- local toPos = split:convertToNodeSpace(v1worldPos)
                        split._to = cc.p(v1Pos.x+self._bg2:getPositionX(),v1Pos.y+self._bg2:getPositionY())
                        split._target = v1
                        break
                    end
                end
            end
        end
        table.sort(marks,function( a,b )
            return a:getPositionX() < b:getPositionX()
        end)
    end
    self._marks = marks
end

function BattleResultLegionsWin:labelAnimTo(label, src, dest, isTime)
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

function BattleResultLegionsWin.dtor()
    BattleResultLegionsWin = nil
    delaytick = nil
end

return BattleResultLegionsWin