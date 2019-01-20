--
-- Author: huangguofang
-- Date: 2018-05-03 17:45:34
--

local BattleResultStakeWin = class("BattleResultStakeWin", BasePopView)

function BattleResultStakeWin:ctor(data)
    BattleResultStakeWin.super.ctor(self)

    self._result = data.result
    self._callback = data.callback
    self._battleInfo = data.result --data.data
    self._heroId = self._battleInfo.heroId
    self._isHot = self._battleInfo.isHot
    self._totalDamageNum = self._battleInfo.totalDamageNum or 0
    self._subDamgeNum = self._battleInfo.subDamgeNum or 0
    self._fightType = self._battleInfo.fightType
end

function BattleResultStakeWin:getBgName()
    return "battleResult_bg.jpg"
end

function BattleResultStakeWin:onInit()
    self._touchPanel = self:getUI("touchPanel")
    self._touchPanel:setSwallowTouches(false)
    self._touchPanel:setEnabled(false)
    self:registerClickEvent(self._touchPanel, specialize(self.onQuit, self))
    -- 防止流程中报错无法关界面
    ScheduleMgr:delayCall(8000, self, function( )
        if tolua.isnull(self._touchPanel) then return end
        self._touchPanel:setEnabled(true)
    end)
    self._time = self._battleInfo.time

    self._bg = self:getUI("bg")
    self._rolePanel = self:getUI("bg.role_panel")
    self._rolePanelX , self._rolePanelY = self._rolePanel:getPosition()
    self._roleImg = self:getUI("bg.role_panel.role_img")    
    self._roleImgShadow = self:getUI("bg.role_panel.roleImg_shadow")

    self._bgImg = self:getUI("bg.bg_img")
    self._bgImg:loadTexture("asset/bg/battleResult_flagBg.png")

    local bg_click =  self:getUI("bg_click")
    bg_click:setSwallowTouches(false)
    -- self._quitBtn = self:getUI("bg_click.quitBtn")
    -- self._quitBtn:setSwallowTouches(true)
    self._countBtn = self:getUI("bg_click.countBtn")
    self._countBtn:setSwallowTouches(true)
    self._countBtn:setEnabled(false)
    self._countBtn:setOpacity(0)
    self._countBtn:setCascadeOpacityEnabled(true)
    UIUtils:formatBattleResultBtnTxt(self._countBtn:getChildByFullName("nameTxt"))
    self._bg1 = self:getUI("bg.bg1")
    self._defineFightTxt = self:getUI("bg.defineFightTxt")
    self._defineFightTxt:enableOutline(cc.c4b(0,0,0,255),1) 
    if self._fightType and self._fightType == 1 then
        self._bg1:setVisible(true) 
        self._defineFightTxt:setVisible(false)
    else
        self._bg1:setVisible(false)
        self._defineFightTxt:setVisible(true)
        self._defineFightTxt:setPositionX(752)
        self._defineFightTxt:setString(lang("STAKE_RESULT_TIPS"))
    end
    self._panel1 = self:getUI("bg.bg1.panel1")

    self._heroIcon = self:getUI("bg.bg1.heroIcon")
    self._heroIcon:setVisible(false)
    if self._isHot then
        -- self._heroId
        local heroData = clone(tab:Hero(self._heroId))
        if heroData then
            local itemIcon = IconUtils:createHeroIconById({sysHeroData = heroData})
            --itemIcon:setAnchorPoint(cc.p(0, 0))
            itemIcon:getChildByName("starBg"):setVisible(false)
            itemIcon:getChildByName("iconStar"):setVisible(false)
            itemIcon:setPosition(self._heroIcon:getContentSize().width * 0.5, self._heroIcon:getContentSize().height * 0.5)
            itemIcon:setSwallowTouches(false)
            itemIcon:setScale(0.85)
            self._heroIcon:addChild(itemIcon)
        end
    end

    self._monsterName1 = self:getUI("bg.bg1.panel1.des1")
    self._monsterName1:enableOutline(cc.c4b(0,0,0,255),1)
    
    self._count1 = self:getUI("bg.bg1.panel1.count1")

    local numStr = self._totalDamageNum
    if numStr > 10000 then
        numStr = math.floor(self._totalDamageNum / 1000)
        numStr = numStr / 10
        numStr = numStr .. "万"
    end
    self._count1:setString(numStr)
    self._count1:enableOutline(cc.c4b(0,0,0,255),1)   

    self._upNum1 = self:getUI("bg.bg1.panel1.upNum")
    self._upLab11 = self:getUI("bg.bg1.panel1.upNum.Label_38")
    self._upLab12 = self:getUI("bg.bg1.panel1.upNum.Label_39")
    self._upLab11:setString("")
    self._upLab11:setOpacity(0)
    self._upLab11:enableOutline(cc.c4b(0,0,0,255),1)
    -- self._upLab11:enableShadow(cc.c4b(0, 0, 0, 255))
    self._upLab12:setString("")
    self._upLab12:setOpacity(0)
    self._upLab12:enableOutline(cc.c4b(0,0,0,255),1)
    
    self._upImg = self:getUI("bg.historyUpImg")
    
    self._bg1:setOpacity(0)
    self._panel1:setOpacity(0)
    self._monsterName1:setOpacity(0)
    self._count1:setOpacity(0)
    self._upNum1:setOpacity(0)
    self._upImg:setOpacity(0)
    self._defineFightTxt:setOpacity(0)
    

    local animPos = self:getUI("bg.animPos")

    -- self:registerClickEvent(self._quitBtn, specialize(self.onQuit, self))
    self:registerClickEvent(self._countBtn, specialize(self.onCount, self))

    local children = self._bg1:getChildren()
    for k,v in pairs(children) do
        v:setOpacity(0)
    end
    
    self._monsterName1:setString("伤害:")

    self._count1:setPositionX(self._monsterName1:getPositionX()+self._monsterName1:getContentSize().width)
    self._upLab11:setString("(")

    numStr = self._subDamgeNum
    if numStr > 10000 then
        numStr = math.floor(self._subDamgeNum / 1000)
        numStr = numStr / 10
        numStr = numStr .. "万"
    end
    self._upLab12:setString(numStr .. " )")
    self._upNum1.isShow = self._subDamgeNum and self._subDamgeNum > 0

    local up1AddWidth = self._upNum1.isShow == true and 55 + self._upLab12:getContentSize().width or 0
    local width1 = self._monsterName1:getContentSize().width+ self._count1:getContentSize().width + up1AddWidth
    self._panel1:setContentSize(width1,self._panel1:getContentSize().height)

    self._panel1:setPositionX((self._bg1:getContentSize().width - self._panel1:getContentSize().width) / 2)
    self._upNum1:setPositionX(self._count1:getPositionX() + self._count1:getContentSize().width + 30)
    
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
    self:animBegin()
end


function BattleResultStakeWin:onQuit()
    if self._callback then
        self._callback()
    end
    -- UIUtils.reloadLuaFile("battle.BattleResultStakeWin")
end

function BattleResultStakeWin:onCount()
    local battleInfo=clone(self._battleInfo)
    
    -- UIUtils.reloadLuaFile("battle.BattleCountView")
    self._viewMgr:showView("battle.BattleCountView",battleInfo,true)
end

-- local delaytick = {360, 380, 380}
function BattleResultStakeWin:animBegin()
    audioMgr:stopMusic()
    audioMgr:playSoundForce("WinBattle")

    local liziAnim = mcMgr:createViewMC("liziguang_commonwin", true, false) 
    liziAnim:setPosition(MAX_SCREEN_WIDTH * 0.5, 135)
    self:getUI("bg_click"):addChild(liziAnim, 1000)

    -- 右侧旗子
    self._posBgX = self._bgImg:getPositionX()
    self._posBgY = self._bgImg:getPositionY()
    self._bgImg:setPositionY(self._posBgY+615)

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
        artUrl = "asset/uiother/team/"..art2..".png"

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
    local posRoleX,posRoleY = self._rolePanel:getPosition()
    -- if not self._rolePanelLow then 
    --     self._rolePanelLow = self._rolePanel:clone()
    --     self._rolePanelLow:setOpacity(150)
    --     self._rolePanelLow:setCascadeOpacityEnabled(true)
    --     self._rolePanelLow:setPosition(self._rolePanel:getPosition())
    --     self._rolePanel:getParent():addChild(self._rolePanelLow, self._rolePanel:getZOrder()-1)
    -- end
    -- self._rolePanelLow:setPositionX(-moveDis)
    self._rolePanel:setPositionY(-moveDis)
    local moveRole = cc.Sequence:create(cc.MoveTo:create(0.1,cc.p(posRoleX,posRoleY+20)),cc.MoveTo:create(0.01,cc.p(posRoleX,posRoleY)))
    self._rolePanel:runAction(moveRole)
    -- local moveRoleLow = cc.Sequence:create(cc.DelayTime:create(0.06), cc.MoveTo:create(0.1,cc.p(posRoleX+20,posRoleY)),cc.MoveTo:create(0.01,cc.p(posRoleX,posRoleY)))
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
            cc.DelayTime:create(0.3),
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
    end)
end

function BattleResultStakeWin:animNext(mc2)
    -- 动画
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

    self._countBtn:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.FadeIn:create(0.3),cc.CallFunc:create(function ()
        self._countBtn:setEnabled(true)
    end)))
    self._touchPanel:runAction(cc.Sequence:create(cc.DelayTime:create(1.3), cc.CallFunc:create(function()
        self._touchPanel:setEnabled(true)
    end)))
    self._defineFightTxt:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.FadeIn:create(0.1)))
    self._bg1:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.FadeIn:create(0.1)))
    self._panel1:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.FadeIn:create(0.2),cc.JumpBy:create(0.2,cc.p(0,5),10,1)))
    self._monsterName1:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.FadeIn:create(0.2)))
    self._count1:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.FadeIn:create(0.2)))
    if self._isHot then
        self._heroIcon:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),CCCallFunc:create(function( ... )
            self._heroIcon:setVisible(true)
        end)))
    end
    if self._upNum1.isShow == true then
        self._upNum1:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.FadeIn:create(0.2)))
        self._upLab11:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.FadeIn:create(0.2)))
        self._upLab12:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.FadeIn:create(0.2)))
        self._upImg:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.FadeIn:create(0.2)))
    end
   
end
function BattleResultStakeWin:labelAnimTo(label, src, dest, isTime)
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

function BattleResultStakeWin.dtor()
    BattleResultStakeWin = nil
    -- delaytick = nil
end

return BattleResultStakeWin