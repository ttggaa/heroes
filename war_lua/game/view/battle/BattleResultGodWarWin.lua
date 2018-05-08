--[[
    Filename:    BattleResultGodWarWin.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-05-15 17:57:47
    Description: File description
--]]


local BattleResultGodWarWin = class("BattleResultGodWarWin", BasePopView)

function BattleResultGodWarWin:ctor(data)
    BattleResultGodWarWin.super.ctor(self)
    self._result = data.result
    self._callback = data.callback
    self._battleInfo = data.result
    dump(self._battleInfo,"self._battleInfo")
end
function BattleResultGodWarWin:getBgName()
    return "battleResult_bg.jpg"
end
function BattleResultGodWarWin:onInit()
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
    self._countBtn = self:getUI("bg_click.countBtn")
    self._countBtn:setSwallowTouches(true)
    self._countBtn:setEnabled(false)
    self._countBtn:setOpacity(0)
    self._countBtn:setCascadeOpacityEnabled(true)
    UIUtils:formatBattleResultBtnTxt(self._countBtn:getChildByFullName("nameTxt"))
    self._bg1 = self:getUI("bg.bg1")

    self:initLabel(self:getUI("bg.bg1.des"),false)
    self:initLabel(self:getUI("bg.bg1.des1"),false)
    self:initLabel(self:getUI("bg.bg1.rank"),true)
    -- self:initLabel(self:getUI("bg.bg1.des2"),false)
    -- self:initLabel(self:getUI("bg.bg1.upRank"),true)
    local des2 = self:getUI("bg.bg1.des2")
    des2:setAnchorPoint(0.5, 0.5)
    des2:setPosition(181, 11)
    des2:setColor(cc.c3b(252,244,197))
    des2:setString("纪念币将通过邮件发放")
    -- des2:setVisible(false)
    local upRank = self:getUI("bg.bg1.upRank")
    upRank:setVisible(false)
    -- self._rank = self:getUI("bg.bg1.rank") 
    -- self._upRank = self:getUI("bg.bg1.upRank") 

    self:registerClickEvent(self._countBtn, specialize(self.onCount, self))
    -- self._shareNode:registerClick(function()
    --     local param = {
    --         moduleName = "ShareArenaWinModule",
    --         left = {
    --             user = {art = self._battleInfo.hero1["herohead"]},
    --             name =  self._battleInfo.hero1["name"] or "",
    --             team1 = {sysTeamData = tab.team[self._shareLeftDamageD.id or 101] or tab.team[self._shareLeftDamageD.id or 101]}, 
    --             team2 ={sysTeamData = tab.team[self._shareLeftHurtD.id or 101]}},
    --         right = {
    --             user = {art = self._battleInfo.hero2["herohead"]}, 
    --             name =  self._battleInfo.hero2["name"],
    --             team1 = {sysTeamData = tab.team[self._shareRightDamageD.id or 101]}, 
    --             team2 ={sysTeamData = tab.team[self._shareRightHurtD.id or 101]}}
    --     }
    --     return param
    -- end)

    local children1 = self._bg1:getChildren()
    for k,v in pairs(children1) do
        v:setOpacity(0)
    end
    -- local children2 = self._bg2:getChildren()
    -- for k,v in pairs(children2) do
    --     v:setOpacity(0)
    -- end

    -- self._expLabel:setString("")
    -- self._goldLabel:setString("")

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

    -- 分享 过滤出敌方 防御和输出 teamData
    self._shareRightDamageD = self._battleInfo.rightData[1].D
    self._shareRightHurtD = self._battleInfo.rightData[1].D
    for i = 1,#self._battleInfo.rightData do
        if self._battleInfo.rightData[i].damage then
            if tonumber(self._battleInfo.rightData[i].damage) > tonumber(outputValue) and self._battleInfo.rightData[i].original then
                outputValue = self._battleInfo.rightData[i].damage
                if self._battleInfo.rightData[i].original then
                    self._shareRightDamageD = self._battleInfo.rightData[i].D
                end
            end
        end
        if self._battleInfo.rightData[i].hurt then
            if tonumber(self._battleInfo.rightData[i].hurt) > tonumber(defendValue) and self._battleInfo.rightData[i].original then
                outputValue = self._battleInfo.rightData[i].hurt
                self._shareRightHurtD = self._battleInfo.rightData[i].D
            end
        end
    end
     
    -- print(self._bestOutID ,"=====================",outputValue)
    -- print(self._lihuiId,"=====================",outputLihuiV)

    self._time = self._battleInfo.time

    local mcMgr = MovieClipManager:getInstance()
    self:animBegin()
end

function BattleResultGodWarWin:initLabel(node,isGreen)     
    if isGreen then
        node:setColor(cc.c4b(39,250,0,255))
    else
        node:setColor(cc.c4b(255,255,221,255))
        node:enable2Color(1, cc.c4b(253,229,123,255)) 
    end
    node:setFontSize(28)    
    -- node:enableShadow(cc.c4b(0, 0, 0, 255))
    node:enableOutline(cc.c4b(0,0,0,255),2) 
end

function BattleResultGodWarWin:onQuit()
    -- if self._arenaCallback then
    --  print("in arena callbakc....")
    --  self._arenaCallback(self._callback)
 --    else
        if self._callback then
            self._callback()
        end
    -- end
end

function BattleResultGodWarWin:onCount()
    self._viewMgr:showView("battle.BattleCountView", self._battleInfo)
end

local delaytick = {1000, 1500, 380}
function BattleResultGodWarWin:animBegin()
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
        local teamName, art1, art2, art3 = TeamUtils:getTeamAwakingTab(tdata, tdata.id)
        if isAwaking then 
            -- 结算例会单独处理 读配置
            imgName = teamData.jxart2
            artUrl = "asset/uiother/team/"..imgName..".png"
        end

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
    local moveDis = 600
    local posRoleX,posRoleY = self._rolePanel:getPosition()
    local posBgX,posBgY = self._bgImg:getPosition()
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
    ScheduleMgr:delayCall(200, self, function(sender)
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
            cc.DelayTime:create(0.15),
            cc.CallFunc:create(function()
                self:animNext(mc2)
                end)

            )
        self._bgImg:runAction(moveBg)
    end)    
end
function BattleResultGodWarWin:animNext(mc2)
    local animPos = self:getUI("bg.animPos")

    local mc3 = mcMgr:createViewMC("shenglixing_commonwin", true)
    mc3:setPosition(animPos:getPositionX(),animPos:getPositionY() - 70)
    self._bg:addChild(mc3, 4)
    
    local arenaInfo = self._result.arenaInfo
    if arenaInfo then
        self._timeLabel = ccui.TextBMFont:create("r" .. math.min(self._result.arenaInfo.rank,10000), UIUtils.bmfName_timecount)
        self._timeLabel:setScale(0.46)
        self._timeLabel:setPosition(animPos:getPositionX()-2, animPos:getPositionY() - 120)
        self._timeLabel:setAnchorPoint(0.5,1)
        self._timeLabel:setOpacity(0)
        self._bg:addChild(self._timeLabel,10)

        self._labelMc = mcMgr:createViewMC("jingjichangpaimingshanguang_commonwin", true, false, function (_, sender)
            sender:gotoAndPlay(0)
        end,RGBA8888)
        self._labelMc:setVisible(false)
        self._labelMc:setPosition(animPos:getPositionX()+10, animPos:getPositionY() - 124)
        self._bg:addChild( self._labelMc,10)

        self._timeLabel:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.FadeIn:create(0.3),cc.CallFunc:create(function()
            self._labelMc:setVisible(true)
        end
        ))) 
    end
    -- local children2 = self._bg2:getChildren()
    -- for k,v in pairs(children2) do
    --     v:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.FadeIn:create(0.3)))
    -- end

    local children1 = self._bg1:getChildren()
    self._bg1:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.JumpBy:create(0.2,cc.p(0,5),10,1)))
    for k,v in pairs(children1) do
        v:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.FadeIn:create(0.1)))
    end

    self._countBtn:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.FadeIn:create(0.3),cc.CallFunc:create(function( )
        self._countBtn:setEnabled(true)
        if self._arenaCallback then
            self._arenaCallback()
        end   
    end)))

    -- self._shareNode:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.FadeIn:create(0.3), cc.CallFunc:create(function()
    --     self._shareNode:setEnabled(true)
    -- end)))

    self._touchPanel:runAction(cc.Sequence:create(cc.DelayTime:create(1.9), cc.CallFunc:create(function()
        self._touchPanel:setEnabled(true)
    end)))
end

function BattleResultGodWarWin.dtor()
    BattleResultGodWarWin = nil
    delaytick = nil
end

return BattleResultGodWarWin