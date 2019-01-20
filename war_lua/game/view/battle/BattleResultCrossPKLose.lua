--[[
    Filename:    BattleResultCrossPKLose.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-11-21 15:19:25
    Description: File description
--]]


local BattleResultCrossPKLose = class("BattleResultCrossPKLose", BasePopView)

function BattleResultCrossPKLose:ctor(data)
    BattleResultCrossPKLose.super.ctor(self, data)

    self._result = data.result
    self._callback = data.callback
    self._battleInfo = data.result
end
function BattleResultCrossPKLose:getBgName()
    return "battleResult_bg.jpg"
end
function BattleResultCrossPKLose:onInit()
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

    self._bg2 = self:getUI("bg_click.bg2")
    self._gold = self:getUI("bg_click.bg2.gold")
    self._gold:loadTexture("globalImage_jingjibi.png",1)  
    self._gold:setVisible(false)
    self._goldLabel = self:getUI("bg_click.bg2.goldLabel") 
    self._goldLabel:setVisible(false)
    self._goldLabel:enableOutline(cc.c4b(48,20,0,255),1)

    -- self._bg2:setVisible(false) -- 没有竞技币奖励
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
--  print(self._bestOutID ,"=====================",outputValue)
--  print(self._lihuiId,"=====================",outputLihuiV)
    self:registerClickEvent(self._countBtn, specialize(self.onCount, self))

    local children1 = self._bg1:getChildren()
    for k,v in pairs(children1) do
        v:setOpacity(0)
    end
    local children2 = self._bg2:getChildren()
    for k,v in pairs(children2) do
        v:setOpacity(0)
    end


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
            item:setPosition(beginX + (i - 1) * inv - 15, inv/2- 20)
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
    -- mcMgr:loadRes("commonlose", function ()
        self:animBegin()
    -- end)
end

function BattleResultCrossPKLose:initLabel(node,isGreen)      
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

function BattleResultCrossPKLose:onQuit()
    if self._callback then
        self._callback()
    end
end
function BattleResultCrossPKLose:onShow( )
    -- self._countBtn:setVisible(false)
    local leftAllDie = true
    for k,v in ipairs(self._result.leftData) do
        if v.die ~= -1 then
            leftAllDie = false
            break
        end
        if v.damage > 0 or v.hurt > 0 or v.heal > 0 then
            self._countBtn:setVisible(true)
            -- return 
        end
    end
    local rightAllDie = true
    for k,v in ipairs(self._result.rightData) do
        if v.die ~= -1 then
            rightAllDie = false
            break
        end
        if v.damage > 0 or v.hurt > 0 or v.heal > 0 then
            self._countBtn:setVisible(true)
            -- return 
        end
    end
    -- if not (leftAllDie or rightAllDie) then
    --     self._countBtn:setVisible(false)
    -- end
end

function BattleResultCrossPKLose:onCount()
    self._viewMgr:showView("battle.BattleCountView",self._battleInfo,true)
    
end

function BattleResultCrossPKLose:animBegin()
    audioMgr:stopMusic()
    audioMgr:playSoundForce("SurrenderBattle")

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

    ScheduleMgr:delayCall(200, self, function(sender)
        local posBgX,posBgY = self._posBgX,self._posBgY
        local moveBg = cc.Sequence:create(cc.MoveTo:create(0.15,cc.p(posBgX,posBgY-20)),cc.MoveTo:create(0.01,cc.p(posBgX,posBgY)))
        self._bgImg:runAction(moveBg)
        self:animNext()
    end)    
end
function BattleResultCrossPKLose:animNext()
    local animPos = self:getUI("bg.animPos")
    -- local mc1 = mcMgr:createViewMC("huodedaojudiguang_commonlight", true, false, function (_, sender)
    --         sender:gotoAndPlay(20)
    --     end,RGBA8888)
    -- mc1:setPosition(animPos:getPosition())
    -- mc1:setScale(0.8)
    -- self._bg:addChild(mc1)
    local mc2 = mcMgr:createViewMC("shibai_commonlose", false)
    mc2:setPosition(animPos:getPosition())
    self._bg:addChild(mc2, 5)
    
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
    end
    if self._timeLabel then
        self._timeLabel:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.FadeIn:create(0.3),cc.CallFunc:create(function()
                self._labelMc:setVisible(true)
            end
            )))
    end

    local children2 = self._bg2:getChildren()
    for k,v in pairs(children2) do
        v:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.FadeIn:create(0.3)))
    end
    if self._timeLabel then
        self._timeLabel:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.FadeIn:create(0.3)))
    end
    local children1 = self._bg1:getChildren()
    self._bg1:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.JumpBy:create(0.2,cc.p(0,5),10,1)))
    for k,v in pairs(children1) do
        v:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.FadeIn:create(0.1)))
    end

    self._countBtn:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.FadeIn:create(0.3),cc.CallFunc:create(function ()
        self._countBtn:setEnabled(true)
        if self._arenaCallback then
            self._arenaCallback()
        end
    end)))
     self._touchPanel:runAction(cc.Sequence:create(cc.DelayTime:create(1.9), cc.CallFunc:create(function()
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

function BattleResultCrossPKLose.dtor()
    BattleResultCrossPKLose = nil
end

return BattleResultCrossPKLose