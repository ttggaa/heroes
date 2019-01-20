--[[
    Filename:    BattleResultCrossPKWin.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-11-21 15:19:16
    Description: File description
--]]

local BattleResultCrossPKWin = class("BattleResultCrossPKWin", BasePopView)

function BattleResultCrossPKWin:ctor(data)
    BattleResultCrossPKWin.super.ctor(self)
    self._result = data.result
    self._callback = data.callback
    self._battleInfo = data.result
    -- dump(self._battleInfo,"self._battleInfo")
end
function BattleResultCrossPKWin:getBgName()
    return "battleResult_bg.jpg"
end
function BattleResultCrossPKWin:onInit()
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

    self._shareNode = require("game.view.share.GlobalShareBtnNode").new({mType = "ShareArenaWinModule"})
    self._shareNode:setSwallowTouches(true)
    self._shareNode:setEnabled(false)
    self._shareNode:setOpacity(0)
    self._shareNode:setPosition(212, 84)
    self._shareNode:setCascadeOpacityEnabled(true, true)
    self:getUI("bg_click"):addChild(self._shareNode, 5)

    self:initLabel(self:getUI("bg.bg1.des"),false)
    self:initLabel(self:getUI("bg.bg1.des1"),false)
    self:initLabel(self:getUI("bg.bg1.rank"),true)
    self:initLabel(self:getUI("bg.bg1.des2"),true)
    self:initLabel(self:getUI("bg.bg1.upRank"),true)

    self:initLabel(self:getUI("bg.bg3.des"),false)
    self:initLabel(self:getUI("bg.bg3.des1"),false)
    self._bg2 = self:getUI("bg_click.bg2") 
    self._gold = self:getUI("bg_click.bg2.gold")
    self._gold:loadTexture("globalImageUI_kuafuCoin.png",1)             
    -- local scaleNum1 = math.floor((32/self._gold:getContentSize().width)*100)
    -- self._gold:setScale(scaleNum1/100)
    self._goldLabel = self:getUI("bg_click.bg2.goldLabel")
    self._goldLabel:enableOutline(cc.c4b(48,20,0,255),1)
    self._goldLabel:setScale(1) 
    
    self._rank = self:getUI("bg.bg1.rank") 
    self._upRank = self:getUI("bg.bg1.upRank") 
    self._upArrow = self:getUI("bg.bg1.upArrow") 
    self._upArrow:runAction(cc.RepeatForever:create(cc.JumpBy:create(0.8,cc.p(0,0),5,1))) --cc.Sequence:create(cc.JumpBy:create(0.5,cc.p(0,5),5,1),cc.JumpBy:create(0.5,cc.p(0,0),0,1)) ))
    local crossInfo = self._result.crossInfo
    if crossInfo then
        local rank = crossInfo.rank or 0
        local preRank = crossInfo.preRank or 0
        
        if rank >= preRank then
            self._bg1:setVisible(false)
            self._bg1 = self:getUI("bg.bg3")
            self._bg1:setVisible(true)
        else
            self._rank:setString(rank)
            self:getUI("bg.bg1.des2"):setString("(")
            self._upArrow:setVisible(true)
            self._upRank:setString((math.min(preRank,10000)-rank) .. ")")
        end
        if crossInfo.award then
            self._goldLabel:setString(crossInfo.award[1]["num"] or "20")
        else
            self._goldLabel:setVisible(false)
            self._title:setVisible(false)
            self._gold:setVisible(false)
        end
        self._bg2:setVisible(true)
    end
    self._bg2:setVisible(true)
    -- dump(self._result)
    dump(crossInfo)
    -- if arenaInfo then
    --     local rank = arenaInfo.rank or 0
    --     local preRank = arenaInfo.preRank or 0
    --     local preHRank = arenaInfo.preHRank or preRank or 0
        
    --     if rank >= preRank then
    --         self._bg1:setVisible(false)
    --         self._bg1 = self:getUI("bg.bg3")
    --         self._bg1:setVisible(true)
    --     else
    --         self._rank:setString(rank)
    --         self:getUI("bg.bg1.des2"):setString("(")
    --         self._upArrow:setVisible(true)
    --         self._upRank:setString((math.min(preRank,10000)-rank) .. ")")
    --     end
    --     if rank < 10000 and rank < preHRank and arenaInfo.award then
    --         self._arenaCallback = function( callback )
    --             self._viewMgr:showDialog("arena.DialogArenaNewReCord",{award = arenaInfo.award or {},preHRank = math.min(preHRank,10000) ,rank = rank,callback = function(  )
    --                 if self._battleInfo.arenaInfo and self._battleInfo.arenaInfo.rewards and next(self._battleInfo.arenaInfo.rewards) then 
    --                     self._viewMgr:showDialog("arena.ArenaTurnCardView",{awards = self._battleInfo.arenaInfo.rewards,titleType=2},true)
    --                 end
    --             end},true,nil,nil,true)
    --         end
    --     else
    --         if self._battleInfo.arenaInfo and self._battleInfo.arenaInfo.rewards and next(self._battleInfo.arenaInfo.rewards) then
    --             self._arenaCallback = function( )
    --                 self._viewMgr:showDialog("arena.ArenaTurnCardView",{awards = self._battleInfo.arenaInfo.rewards,titleType=2},true)
    --             end 
    --         end
    --     end
    --     -- [[初次打竞技场引导 一万名开外特殊处理
    --     if rank >= 10000 then
    --         self._bg1:setVisible(false)
    --         self._bg1 = self:getUI("bg.bg1")
    --         self._bg1:setVisible(true)
    --         self._rank:setString(10000)
    --         self._rank:setPositionX(self._rank:getPositionX()+42)
    --         self:getUI("bg.bg1.des1"):setPositionX(self:getUI("bg.bg1.des1"):getPositionX()+38)
    --         self._upArrow:setVisible(false)
    --         self._upRank:setString("")
    --         self:getUI("bg.bg1.des2"):setString("")
    --     end
    --     --]]
    --     if arenaInfo.award then
    --         self._goldLabel:setString(arenaInfo.award.val or "20")
    --     else
    --         self._goldLabel:setVisible(false)
    --         self._title:setVisible(false)
    --         self._gold:setVisible(false)
    --     end
    --     self._bg2:setVisible(true)
    -- else
    -- end
    -- self._bg2:setVisible(false) -- 没有竞技币奖励 隐藏
    
    self:registerClickEvent(self._countBtn, specialize(self.onCount, self))

    local children1 = self._bg1:getChildren()
    for k,v in pairs(children1) do
        v:setOpacity(0)
    end
    local children2 = self._bg2:getChildren()
    for k,v in pairs(children2) do
        v:setOpacity(0)
    end

    -- self._expLabel:setString("")
    -- self._goldLabel:setString("")

    self._bestOutID = self._battleInfo.leftData[1].D["id"]
    self._lihuiId = self._battleInfo.leftData[1].D["id"]
    local outputValue = self._battleInfo.leftData[1].damage or 0
    local defendValue = self._battleInfo.leftData[1].hurt or 0
    local outputLihuiV = self._battleInfo.leftData[1].damage or 0
    self._shareLeftDamageD = self._battleInfo.leftData[1].teamData
    self._shareLeftHurtD = self._battleInfo.leftData[1].teamData
    for i = 1,#self._battleInfo.leftData do
        if self._battleInfo.leftData[i].damage then
            if tonumber(self._battleInfo.leftData[i].damage) > tonumber(outputValue) then
                outputValue = self._battleInfo.leftData[i].damage
                self._bestOutID = self._battleInfo.leftData[i].D["id"]
                if self._battleInfo.leftData[i].original then
                    self._shareLeftDamageD = self._battleInfo.leftData[i].teamData
                end
            end
            if tonumber(self._battleInfo.leftData[i].damage) > tonumber(outputLihuiV) and self._battleInfo.leftData[i].original then
                outputLihuiV = self._battleInfo.leftData[i].damage
                self._lihuiId = self._battleInfo.leftData[i].D["id"]
            end

            if self._battleInfo.leftData[i].hurt then
                if tonumber(self._battleInfo.leftData[i].hurt) > tonumber(defendValue) and self._battleInfo.leftData[i].original then
                    defendValue = self._battleInfo.leftData[i].hurt
                    self._shareLeftHurtD = self._battleInfo.leftData[i].teamData
                end
            end
        end
    end

    -- 分享 过滤出敌方 防御和输出 teamData
    self._shareRightDamageD = self._battleInfo.rightData[1].teamData
    self._shareRightHurtD = self._battleInfo.rightData[1].teamData
    outputValue = self._battleInfo.rightData[1].damage or 0
    defendValue = self._battleInfo.rightData[1].hurt or 0
    for i = 1,#self._battleInfo.rightData do
        if self._battleInfo.rightData[i].damage then
            if tonumber(self._battleInfo.rightData[i].damage) > tonumber(outputValue) and self._battleInfo.rightData[i].original then
                outputValue = self._battleInfo.rightData[i].damage
                if self._battleInfo.rightData[i].original then
                    self._shareRightDamageD = self._battleInfo.rightData[i].teamData
                end
            end
        end
        if self._battleInfo.rightData[i].hurt then
            if tonumber(self._battleInfo.rightData[i].hurt) > tonumber(defendValue) and self._battleInfo.rightData[i].original then
                defendValue = self._battleInfo.rightData[i].hurt
                self._shareRightHurtD = self._battleInfo.rightData[i].teamData
            end
        end
    end
     
    -- print(self._bestOutID ,"=====================",outputValue)
    -- print(self._lihuiId,"=====================",outputLihuiV)
    if not self._shareLeftDamageD then
        self._shareNode:setVisible(false)
    end
    self._shareNode:setVisible(false)
    -- 分享按钮事件
    self._shareNode:registerClick(function()
        local param = {
            moduleName = "ShareArenaWinModule",
            isHideBtn = true,
            left = {
                user = {art = self._battleInfo.hero1["herohead"]},
                name =  self._battleInfo.hero1["name"] or "",
                team1 = {sysTeamData = tab.team[self._shareLeftDamageD.teamId or 101] or tab.team[self._shareLeftDamageD.id or 101],teamData = self._shareLeftDamageD}, 
                team2 ={sysTeamData = tab.team[self._shareLeftHurtD.teamId or 101],teamData = self._shareLeftHurtD}},
            right = {
                user = {art = self._battleInfo.hero2["herohead"]}, 
                name =  self._battleInfo.hero2["name"],
                team1 = {sysTeamData = tab.team[self._shareRightDamageD.teamId or 101],teamData = self._shareRightDamageD}, 
                team2 ={sysTeamData = tab.team[self._shareRightHurtD.teamId or 101],teamData = self._shareRightHurtD}}
        }
        return param
    end)
    self._time = self._battleInfo.time

    local crossInfo = self._result.crossInfo
    if crossInfo and crossInfo.award then
        -- 物品
        local reward = {}
        local _reward = crossInfo.award
        dump(_reward)
        for k,v in pairs(_reward) do
            if IconUtils.iconIdMap[v.type] then
                v.typeId = IconUtils.iconIdMap[v.type]
            end
            table.insert(reward, v)
        end
        local itemCount = #reward
        self._items = {}
        local inv = 90
        local posX = (self._bg2:getContentSize().width - itemCount*inv)/2 + inv/2
        local beginX = posX
        for i = 1, itemCount do
            local sysItem = tab:Tool(reward[i].typeId)
            local item = IconUtils:createItemIconById({itemId = reward[i].typeId, num = reward[i].num, itemData = sysItem})
            item:setScale(2)
            item:setAnchorPoint(0.5, 0.5)
            item:setPosition(beginX + (i - 1) * inv - 8, inv/2 - 20)
            self._bg2:addChild(item)
            item:setVisible(false)
            self._items[i] = item
            if sysItem.typeId == ItemUtils.ITEM_TYPE_TREASURE then
                local mc1 = mcMgr:createViewMC("wupinguang_itemeffectcollection", true)
                mc1:setPosition(item:getContentSize().width/2 ,item:getContentSize().height/2)
                item:addChild(mc1, 10)
            end
        end
        self._bg2:setVisible(false)
    end

    local mcMgr = MovieClipManager:getInstance()
    self:animBegin()
end

function BattleResultCrossPKWin:initLabel(node,isGreen)     
    if isGreen then
        node:setColor(cc.c4b(39,250,0,255))
    else
        node:setColor(cc.c4b(255,255,221,255))
        node:enable2Color(1, cc.c4b(253,229,123,255)) 
    end
    node:setFontSize(28)    
    -- node:enableShadow(cc.c4b(0, 0, 0, 255))
    node:enableOutline(cc.c4b(0,0,0,255),1) 
end

function BattleResultCrossPKWin:onQuit()
    -- if self._arenaCallback then
    --  print("in arena callbakc....")
    --  self._arenaCallback(self._callback)
 --    else
        if self._callback then
            self._callback()
        end
    -- end
end

function BattleResultCrossPKWin:onCount()
    self._viewMgr:showView("battle.BattleCountView", self._battleInfo)
end

local delaytick = {1000, 1500, 380}
function BattleResultCrossPKWin:animBegin()
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
    ScheduleMgr:delayCall(100, self, function(sender)
        local posBgX,posBgY = self._posBgX,self._posBgY
        local mc2
        local moveBg = cc.Sequence:create(
            cc.MoveTo:create(0.15,cc.p(posBgX,posBgY-20)),
            cc.MoveTo:create(0.01,cc.p(posBgX,posBgY)),
            cc.DelayTime:create(0.1),
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
function BattleResultCrossPKWin:animNext(mc2)
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

        self._timeLabel:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.FadeIn:create(0.3),cc.CallFunc:create(function()
            self._labelMc:setVisible(true)
        end
        ))) 
    end
    local children2 = self._bg2:getChildren()
    for k,v in pairs(children2) do
        v:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.FadeIn:create(0.3)))
    end

    local children1 = self._bg1:getChildren()
    self._bg1:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.JumpBy:create(0.2,cc.p(0,5),10,1)))
    for k,v in pairs(children1) do
        v:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.FadeIn:create(0.1)))
    end

    self._countBtn:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.FadeIn:create(0.3),cc.CallFunc:create(function( )
        self._countBtn:setEnabled(true)
        if self._arenaCallback then
            self._arenaCallback()
        end   
    end)))

    self._shareNode:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.FadeIn:create(0.3), cc.CallFunc:create(function()
        self._shareNode:setEnabled(true)
    end)))

    self._touchPanel:runAction(cc.Sequence:create(cc.DelayTime:create(1.4), cc.CallFunc:create(function()
        self._touchPanel:setEnabled(true)

    end)))

    if self._items then
        ScheduleMgr:delayCall((1600), self, function()
            -- 显示获得道具
            if self._bg2 then
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

function BattleResultCrossPKWin.dtor()
    BattleResultCrossPKWin = nil
    delaytick = nil
end

return BattleResultCrossPKWin