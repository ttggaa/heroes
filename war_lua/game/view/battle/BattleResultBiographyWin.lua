--
-- Author: huangguofang
-- Date: 2017-03-31 21:17:26
--

local BattleResultBiographyWin = class("BattleResultBiographyWin", BasePopView)

function BattleResultBiographyWin:ctor(data)
    BattleResultBiographyWin.super.ctor(self)

    self._result = data.result
    self._bioData = data.result.bioData or {}
    self._battleInfo = data.result
    self._callback = data.callback   
    
end

function BattleResultBiographyWin:onInit()

    self._bg = self:getUI("bg")
    self._touchPanel = self:getUI("touchPanel")
    self._touchPanel:setSwallowTouches(false)
    self._touchPanel:setEnabled(false)
    self:registerClickEvent(self._touchPanel, specialize(self.onQuit, self))
    -- 防止流程中报错无法关界面
    ScheduleMgr:delayCall(8000, self, function( )
        if tolua.isnull(self._touchPanel) then return end
        self._touchPanel:setEnabled(true)
    end)
    
    self._countBtn = self:getUI("touchPanel.countBtn")
    self._countBtn:setEnabled(false)
    self._countBtn:setOpacity(0)
    self._countBtn:setCascadeOpacityEnabled(true)
    UIUtils:formatBattleResultBtnTxt(self._countBtn:getChildByFullName("nameTxt"))
    self:registerClickEvent(self._countBtn, specialize(self.onCount, self))

    self._bg = self:getUI("bg")
    self._rolePanel = self:getUI("bg.role_panel")
    self._rolePanelX , self._rolePanelY = self._rolePanel:getPosition()
    self._roleImg = self:getUI("bg.role_panel.role_img")    
    self._roleImgShadow = self:getUI("bg.role_panel.roleImg_shadow")

    self._bgImg = self:getUI("bg.bg_img")
    self._bgImg:loadTexture("asset/bg/battleResult_flagBg.png")

    self._infoBg = self:getUI("bg.infoBg")
    self._infoBg:setOpacity(0)
    self._infoBg:setCascadeOpacityEnabled(true)
    local desTxt = self:getUI("bg.infoBg.desTxt")
    desTxt:setString(lang("BIOBATTLE_01"))
    -- desTxt:setColor(cc.c4b(255,255,220,255))
    -- desTxt:enable2Color(1, cc.c4b(255,233,131,255)) 
    -- desTxt:setFontSize(28) 
    -- desTxt:setTextAreaSize(cc.size(286,80))   
    -- desTxt:enableOutline(cc.c4b(0,0,0,255),2) 

    local stageTxt = self:getUI("bg.infoBg.stageTxt")
    stageTxt:setColor(cc.c4b(255,252,226,255))
    stageTxt:enable2Color(1, cc.c4b(255,232,125,255)) 
    stageTxt:setFontSize(26)   
    stageTxt:enableOutline(cc.c4b(0,0,0,255),1)
    if self._bioData and self._bioData.clearingText then 
        stageTxt:setString(lang(self._bioData.clearingText))
    -- else
    --     stageTxt:setString("")
    end

    -- 最佳输出
    self._bestOutID = self._battleInfo.leftData[1].D["id"]
    self._lihuiId = self._battleInfo.leftData[1].D["id"]
    local outputValue = self._battleInfo.leftData[1].damage or 0
    local defendValue = self._battleInfo.leftData[1].hurt or 0
    local outputLihuiV = self._battleInfo.leftData[1].damage or 0
    self._shareLeftDamageD = self._battleInfo.leftData[1].D
    self._shareLeftHurtD = self._battleInfo.leftData[1].D
    for i = 1,#self._battleInfo.leftData do
        if self._battleInfo.leftData[i].damage then
            if tonumber(self._battleInfo.leftData[i].damage) > tonumber(outputValue) then
                outputValue = self._battleInfo.leftData[i].damage
                self._bestOutID = self._battleInfo.leftData[i].D["id"]
                if self._battleInfo.leftData[i].original then
                    self._shareLeftDamageD = self._battleInfo.leftData[i].D
                end
            end
            if tonumber(self._battleInfo.leftData[i].damage) > tonumber(outputLihuiV) and self._battleInfo.leftData[i].original then
                outputLihuiV = self._battleInfo.leftData[i].damage
                self._lihuiId = self._battleInfo.leftData[i].D["id"]
            end

            if self._battleInfo.leftData[i].hurt then
                if tonumber(self._battleInfo.leftData[i].hurt) > tonumber(defendValue) and self._battleInfo.leftData[i].original then
                    outputValue = self._battleInfo.leftData[i].hurt
                    self._shareLeftHurtD = self._battleInfo.leftData[i].D
                end
            end
        end
    end

    self:animBegin()

end

function BattleResultBiographyWin:animBegin()
    audioMgr:stopMusic()
    audioMgr:playSoundForce("WinBattle")

    local liziAnim = mcMgr:createViewMC("liziguang_commonwin", true, false) 
    liziAnim:setPosition(MAX_SCREEN_WIDTH * 0.5, 135)
    self:getUI("bg"):addChild(liziAnim, 1000)

    -- 右侧旗子
    self._posBgX = self._bgImg:getPositionX()
    self._posBgY = self._bgImg:getPositionY()
    self._bgImg:setPositionY(self._posBgY+615)

    -- 如果兵团有变身技能，这里改变立汇
    local curHeroId = self._battleInfo.hero1["id"]
    if curHeroId then 
        local _,newId = TeamUtils.changeArtForHeroMastery(curHeroId,self._lihuiId)
        if newId then
            self._lihuiId = newId
        end
    end
    local teamData = tab:Npc(self._lihuiId)
    local imgName = "t_qishi"
    if teamData then
        if teamData.jx and teamData.jx == 1 then
            imgName = string.sub(teamData["art1"], 5, string.len(teamData["art1"]))
            imgName = "ta_" .. imgName 
        else
            imgName = string.sub(teamData["art1"], 4, string.len(teamData["art1"]))
            imgName = "t_" .. imgName 
        end        
        if  teamData["jisuan"] then
            local teamX ,teamY = teamData["jisuan"][1], teamData["jisuan"][2]
            local scale = teamData["jisuan"][3] 
            self._roleImg:setPosition(teamX ,teamY)
            self._roleImgShadow:setPosition(teamX+2,teamY-2)
            self._roleImg:setScale(scale)
            self._roleImgShadow:setScale(scale)
        end
    end 
    self._roleImg:loadTexture("asset/uiother/team/"..imgName..".png")
    self._roleImgShadow:loadTexture("asset/uiother/team/"..imgName..".png") 
    local moveDis = 600
    local posRoleX,posRoleY = self._rolePanel:getPosition()
    local posBgX,posBgY = self._bgImg:getPosition()
    self._rolePanel:setPositionY(-moveDis)
    
    local moveRole = cc.Sequence:create(cc.MoveTo:create(0.1,cc.p(posRoleX,posRoleY+20)),cc.MoveTo:create(0.01,cc.p(posRoleX,posRoleY)))
    self._rolePanel:runAction(moveRole)
  
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
                    sender:gotoAndPlay(20)         
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
            cc.DelayTime:create(0.65),
            cc.CallFunc:create(function()
                self:animNext(mc2)
                end)
            )
        self._bgImg:runAction(moveBg)
    end)    
end
function BattleResultBiographyWin:animNext(mc2)
    local animPos = self:getUI("bg.animPos")

    local mc3 = mcMgr:createViewMC("shenglixing_commonwin", true)
    mc3:setPosition(animPos:getPositionX(),animPos:getPositionY() - 70)
    self._bg:addChild(mc3, 4)

    self._timeLabel = cc.Label:createWithTTF("00:00", UIUtils.ttfName, 26)
    self._timeLabel:setColor(cc.c3b(249, 77 , 3))
    self._timeLabel:enable2Color(1, cc.c4b(255,120,80,255)) 
    self._timeLabel:enableOutline(cc.c4b(0,0,0,255),2)
    self._timeLabel:setPosition(animPos:getPositionX(),animPos:getPositionY()-125)    
    self._bg:addChild(self._timeLabel,99)
    self._time = self._result.time
    if self._time then
        self:labelAnimTo(self._timeLabel, 0, self._time, true)
    end

    self._infoBg:runAction(cc.FadeIn:create(0.1))

    self._touchPanel:runAction(cc.Sequence:create(cc.DelayTime:create(0.7), cc.CallFunc:create(function()
        self._touchPanel:setEnabled(true)

    end)))
    self._countBtn:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),  cc.FadeIn:create(0.2),cc.CallFunc:create(function( )
        self._countBtn:setEnabled(true)  
    end)))

end

-- 时间
function BattleResultBiographyWin:labelAnimTo(label, src, dest, isTime)
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

function BattleResultBiographyWin:onQuit()
    if self._callback then
        self._callback()
    end
    UIUtils:reloadLuaFile("battle.BattleResultBiographyWin")
end

function BattleResultBiographyWin:onCount()
	self._viewMgr:showView("battle.BattleCountView",self._battleInfo,true)
end

function BattleResultBiographyWin.dtor()
    BattleResultBiographyWin = nil 

end

return BattleResultBiographyWin