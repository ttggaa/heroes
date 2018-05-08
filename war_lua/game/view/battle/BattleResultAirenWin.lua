--[[
    Filename:    BattleAirenWin.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2015-12-21 19:30:50
    Description: File description
--]]

--[[
    Filename:    BattleResultAirenWin.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2015-12-21 19:00:55
    Description: File description
--]]

--[[
    Filename:    BattleResultAirenWin.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-12-09 16:29:51
    Description: File description
--]]

local BattleResultAirenWin = class("BattleResultAirenWin", BasePopView)

function BattleResultAirenWin:ctor(data)
    BattleResultAirenWin.super.ctor(self)
    -- dump(data.result, "result::::")
-- dump(data.result.leftData)
-- dump(data)
    self._result = data.result
    self._callback = data.callback
    self._rewards = data.rewards
    self._battleInfo = data.result --data.data
    self._star = self._result.star
    if self._star == nil then
    	self._star = 3
    end
    self._pveType = data.result.pveType

    self._acModel = self._modelMgr:getModel("ActivityModel")
end

function BattleResultAirenWin:getBgName()
    return "battleResult_bg.jpg"
end

function BattleResultAirenWin:onInit()
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
    -- self._quitBtn = self:getUI("bg_click.quitBtn")
    -- self._quitBtn:setSwallowTouches(true)
    self._countBtn = self:getUI("bg_click.countBtn")
    self._countBtn:setSwallowTouches(true)
    self._countBtn:setEnabled(false)
    self._countBtn:setOpacity(0)
    self._countBtn:setCascadeOpacityEnabled(true)
    UIUtils:formatBattleResultBtnTxt(self._countBtn:getChildByFullName("nameTxt"))
    self._bg1 = self:getUI("bg.bg1")
    self._addPanel = self:getUI("bg.addPanel")
    self._bg2 = self:getUI("bg_click.bg2")
    self._panel1 = self:getUI("bg.bg1.panel1")
    self._panel2 = self:getUI("bg.bg1.panel2")

    self._monsterName1 = self:getUI("bg.bg1.panel1.des1")
    self._monsterName1:enableOutline(cc.c4b(0,0,0,255),1)
    -- self._monsterName1:enableShadow(cc.c4b(0, 0, 0, 255))
    self._monsterName2 = self:getUI("bg.bg1.panel2.des2")
    self._monsterName2:enableOutline(cc.c4b(0,0,0,255),1)
    -- self._monsterName2:enableShadow(cc.c4b(0, 0, 0, 255))
    self._count1 = self:getUI("bg.bg1.panel1.count1")
    self._count1:enableOutline(cc.c4b(0,0,0,255),1)
    -- self._count1:enableShadow(cc.c4b(0, 0, 0, 255))
    self._count2 = self:getUI("bg.bg1.panel2.count2")
    self._count2:enableOutline(cc.c4b(0,0,0,255),1)
    -- self._count2:enableShadow(cc.c4b(0, 0, 0, 255))

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
    -- self._upLab12:enableShadow(cc.c4b(0, 0, 0, 255))
    self._upNum2 = self:getUI("bg.bg1.panel2.upNum")
    self._upLab21 = self:getUI("bg.bg1.panel2.upNum.Label_38")
    self._upLab22 = self:getUI("bg.bg1.panel2.upNum.Label_39")
    self._upLab21:setString("")
    self._upLab21:setOpacity(0)
    self._upLab21:enableOutline(cc.c4b(0,0,0,255),1)
    -- self._upLab21:enableShadow(cc.c4b(0, 0, 0, 255))
    self._upLab22:setString("")
    self._upLab22:setOpacity(0)
    self._upLab22:enableOutline(cc.c4b(0,0,0,255),1)
    -- self._upLab22:enableShadow(cc.c4b(0, 0, 0, 255))
    self._upImg = self:getUI("bg.historyUpImg")
    
    self._bg1:setOpacity(0)
    self._addPanel:setOpacity(0)
    self._addPanel:setCascadeOpacityEnabled(true)
    self._panel1:setOpacity(0)
    self._panel2:setOpacity(0)
    self._monsterName1:setOpacity(0)
    self._monsterName2:setOpacity(0)
    self._count1:setOpacity(0)
    self._count2:setOpacity(0)
    self._upNum1:setOpacity(0)
    self._upNum2:setOpacity(0)
    self._upImg:setOpacity(0)
    
    -- self._bg2 = self:getUI("bg.bg2")

    self._title = self:getUI("bg.title")
    self._title:setPositionY(self._title:getPositionY()+15)
    self._title:setFontName(UIUtils.ttfName)
    self._title:setVisible(false)

    if self._rewards and self._rewards[1] then
        self._goldValue = self._rewards[1].num or 0
	    -- self._goldLabel:setString(self._rewards[1].num or 0)
	end
    local animPos = self:getUI("bg.animPos")
    self._gold = self:getUI("bg.gold")             
    local scaleNum1 = math.floor((36/self._gold:getContentSize().width)*100)
    self._gold:setScale(scaleNum1/100)
    self._goldLabel = self:getUI("bg.goldLabel") 
    self._goldLabel:enableOutline(cc.c4b(48,20,0,255),1)
    self._goldLabel:setString(self._goldValue)
    self._goldLabel:setPositionX(animPos:getPositionX() - self._goldLabel:getContentSize().width*0.5 + self._gold:getContentSize().width*0.5*scaleNum1/100 - 10)
    self._gold:setPositionX(animPos:getPositionX() - self._goldLabel:getContentSize().width*0.5 - 10)

    -- UIUtils:center2Widget( self._gold,self._goldLabel,animPos:getPositionX())

    -- self:registerClickEvent(self._quitBtn, specialize(self.onQuit, self))
    self:registerClickEvent(self._countBtn, specialize(self.onCount, self))

    self._gold:setOpacity(0)
    self._goldLabel:setOpacity(0)
    -- self._title:setOpacity(0)
    -- self._quitBtn:setOpacity(0)

    local children = self._bg1:getChildren()
    for k,v in pairs(children) do
    	v:setOpacity(0)
    end
    if self._result.exInfo then
		if self._result.exInfo.damageCount then-- 阴森墓穴
			self._count1:setString(self._result.exInfo.waveCount)
		    self._count2:setString(self._result.exInfo.damageCount)
			-- local npcD = tab:Npc(self._result.exInfo.id1 or 79001)
			self._monsterName1:setString("波数:")
		    -- local npcD2 = tab:Npc(self._result.exInfo.id2 or 79002)
			self._monsterName2:setString("伤害:")

            self._count1:setPositionX(self._monsterName1:getPositionX()+self._monsterName1:getContentSize().width)
            self._count2:setPositionX(self._monsterName2:getPositionX()+self._monsterName2:getContentSize().width)
            self._gold:loadTexture(IconUtils.resImgMap.texp,1)

            local value = self._acModel:getAbilityEffect(self._acModel.PrivilegIDs.PrivilegID_10)
            if value ~= 0 then
                self._goldLabel:setColor(UIUtils.colorTable.ccColorQuality2)
            end
            self:initAbilityEffect("zombie", value)

            --by wangyan 历史新高
            local historyD = self._result["_preHValue"]
            local historyD1 = historyD["waves"] or 0
            local curD1 = self._result.exInfo.waveCount
            if historyD1 and historyD1 < curD1 then
                self._upLab11:setString("(")
                self._upLab12:setString((curD1 - historyD1) .. " )")
                self._upNum1.isShow = true                
            end
            local historyD2 = historyD["damage"] or 0
            local curD2 = self._result.exInfo.damageCount
            if historyD2 and historyD2 < curD2 then
                self._upLab21:setString("(")
                self._upLab22:setString((curD2 - historyD2) .. " )")
                self._upNum2.isShow = true                
            end

        else -- 矮人宝物
            self._count1:setString(self._result.exInfo.killCount1)
            self._count2:setString(self._result.exInfo.killCount2)
            local npcD = tab:Npc(self._result.exInfo.id1 or 79001)
            self._monsterName1:setString("击杀".. (lang(npcD.name) or "普通矮人") .. ":")
            local npcD2 = tab:Npc(self._result.exInfo.id2 or 79002)
            self._monsterName2:setString("击杀".. (lang(npcD2.name) or "金矮人") .. ":")
            self._count1:setPositionX(self._monsterName1:getPositionX()+self._monsterName1:getContentSize().width)
            self._count2:setPositionX(self._monsterName2:getPositionX()+self._monsterName2:getContentSize().width)
            self._gold:loadTexture(IconUtils.resImgMap.gold,1)

            local value = self._acModel:getAbilityEffect(self._acModel.PrivilegIDs.PrivilegID_9)
            if value ~= 0 then
                self._goldLabel:setColor(UIUtils.colorTable.ccColorQuality2)
            end
            self:initAbilityEffect("airen", value)

            --by wangyan 历史新高
            local historyD = self._result["_preHValue"]
            local historyD1 = historyD[tostring(self._result.exInfo.id1 or 79001)] or 0
            local curD1 = self._result.exInfo.killCount1
            if historyD1 and historyD1 < curD1 then
                self._upLab11:setString("(")
                self._upLab12:setString((curD1 - historyD1) .. " )")
                self._upNum1.isShow = true 
            end
            -- local historyD2 = historyD[tostring(self._result.exInfo.id2 or 79002)] or 0
            -- local curD2 = self._result.exInfo.killCount2
            -- if historyD2 and historyD2 < curD2 then
            --     self._upLab21:setString("(")
            --     self._upLab22:setString((curD2 - historyD2) .. " )")
            --     self._upNum2.isShow = true                
            -- end
		end

        local up1AddWidth = self._upNum1.isShow == true and 55 + self._upLab12:getContentSize().width or 0
        local up2AddWidth = self._upNum2.isShow == true and 55 + self._upLab22:getContentSize().width or 0
        local width1 = self._monsterName1:getContentSize().width+ self._count1:getContentSize().width + up1AddWidth
        local width2 = self._monsterName2:getContentSize().width+ self._count2:getContentSize().width + up2AddWidth
        self._panel1:setContentSize(width1,self._panel1:getContentSize().height)
        self._panel2:setContentSize(width2,self._panel2:getContentSize().height)

        self._panel1:setPositionX((self._bg1:getContentSize().width - self._panel1:getContentSize().width) / 2)
        self._panel2:setPositionX((self._bg1:getContentSize().width - self._panel2:getContentSize().width) / 2)
        self._upNum1:setPositionX(self._count1:getPositionX() + self._count1:getContentSize().width + 30)
        self._upNum2:setPositionX(self._count2:getPositionX() + self._count2:getContentSize().width + 30)
	end
  
	self._time = self._battleInfo.time
-- dump(self._battleInfo.leftData,"self._battleInfo.leftData==>")
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

-- 显示VIP、活动加成
function BattleResultAirenWin:initAbilityEffect(tp, abilityValue)
    local vipTxtImg = self._addPanel:getChildByFullName("vipTxtImg")
    local vipCoinIcon = self._addPanel:getChildByFullName("vipCoinIcon")
    vipCoinIcon:setCascadeOpacityEnabled(true)
    local vipAddLabel = self._addPanel:getChildByFullName("vipAddLabel")
    local activityTxtImg = self._addPanel:getChildByFullName("activityTxtImg")
    local activityCoinIcon = self._addPanel:getChildByFullName("activityCoinIcon")
    activityCoinIcon:setCascadeOpacityEnabled(true)
    local activityAddLabel = self._addPanel:getChildByFullName("activityAddLabel")

    if tp == "airen" then
        local vipLv = self._modelMgr:getModel("VipModel"):getLevel()
        local vipAddValue = tab:Vip(self._modelMgr:getModel("VipModel"):getLevel()).buyOccupation
        if tonumber(vipAddValue) > 0 then
            vipTxtImg:setVisible(true)
            vipCoinIcon:setVisible(true)
            vipAddLabel:setVisible(true)

            vipAddLabel:setColor(cc.c3b(255, 252, 226))
            vipAddLabel:enable2Color(1, cc.c4b(255, 232, 125, 255))
            vipAddLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            vipAddLabel:setString("+" .. vipAddValue .. "%")

            if abilityValue <= 0 then
                vipTxtImg:setPositionX(vipTxtImg:getPositionX() + 73)
                vipCoinIcon:setPositionX(vipCoinIcon:getPositionX() + 73)
                vipAddLabel:setPositionX(vipAddLabel:getPositionX() + 73)
            end
        end

        if abilityValue > 0 then
            activityTxtImg:setVisible(true)
            activityCoinIcon:setVisible(true)
            activityAddLabel:setVisible(true)

            activityAddLabel:setColor(cc.c3b(255, 252, 226))
            activityAddLabel:enable2Color(1, cc.c4b(255, 232, 125, 255))
            activityAddLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            activityAddLabel:setString("+" .. abilityValue * 100 .. "%")

            if vipAddValue <= 0 then
                activityTxtImg:setPositionX(activityTxtImg:getPositionX() - 92)
                activityCoinIcon:setPositionX(activityCoinIcon:getPositionX() - 92)
                activityAddLabel:setPositionX(activityAddLabel:getPositionX() - 92)
            end
        end
    elseif tp == "zombie" then
        if abilityValue > 0 then
            activityTxtImg:setVisible(true)
            activityCoinIcon:setVisible(true)
            activityCoinIcon:loadTexture("exp_battle.png", 1)

            activityAddLabel:setVisible(true)
            activityAddLabel:setColor(cc.c3b(255, 252, 226))
            activityAddLabel:enable2Color(1, cc.c4b(255, 232, 125, 255))
            activityAddLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            activityAddLabel:setString("+" .. abilityValue * 100 .. "%")

            activityTxtImg:setPositionX(activityTxtImg:getPositionX() - 92)
            activityCoinIcon:setPositionX(activityCoinIcon:getPositionX() - 92)
            activityAddLabel:setPositionX(activityAddLabel:getPositionX() - 92)
        end
    end
end

function BattleResultAirenWin:onQuit()
	if self._callback then
		self._callback()
	end
    -- UIUtils.reloadLuaFile("battle.BattleResultAirenWin")
end

function BattleResultAirenWin:onCount()
    local battleInfo=clone(self._battleInfo)
    self:add2AirenRightData(battleInfo)
    -- UIUtils.reloadLuaFile("battle.BattleCountView")
	self._viewMgr:showView("battle.BattleCountView",battleInfo,true)
end

-- local delaytick = {360, 380, 380}
function BattleResultAirenWin:animBegin()
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

function BattleResultAirenWin:animNext(mc2)
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

    self._gold:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.FadeIn:create(0.3)))
    self._goldLabel:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.FadeIn:create(0.3)))
    -- self._title:runAction(cc.Sequence:create(cc.DelayTime:create(3.0), cc.FadeIn:create(0.3)))
    self._countBtn:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.FadeIn:create(0.3),cc.CallFunc:create(function ()
        self._countBtn:setEnabled(true)
    end)))
    self._touchPanel:runAction(cc.Sequence:create(cc.DelayTime:create(1.8), cc.CallFunc:create(function()
        self._touchPanel:setEnabled(true)
    end)))
    if self._goldValue then
        self._goldLabel:setString("0")
        ScheduleMgr:delayCall(100, self, function()
            -- self:labelAnimTo(self._expLabel, 0, self._expValue)
            self:labelAnimTo(self._goldLabel, 0, self._goldValue)
        end)
    end
    self._bg1:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.FadeIn:create(0.1)))
    self._addPanel:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.FadeIn:create(0.1)))
    self._panel1:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.FadeIn:create(0.2),cc.JumpBy:create(0.2,cc.p(0,5),15,1)))
    self._monsterName1:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.FadeIn:create(0.2)))
    self._count1:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.FadeIn:create(0.2)))
    
    --by wangyan
    if self._upNum1.isShow == true then
        self._upNum1:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.FadeIn:create(0.2)))
        self._upLab11:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.FadeIn:create(0.2)))
        self._upLab12:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.FadeIn:create(0.2)))
    end
   
    self._panel2:runAction(cc.Sequence:create(cc.DelayTime:create(0.4), cc.FadeIn:create(0.2),cc.JumpBy:create(0.2,cc.p(0,5),15,1)))
    self._monsterName2:runAction(cc.Sequence:create(cc.DelayTime:create(0.4), cc.FadeIn:create(0.2)))
    self._count2:runAction(cc.Sequence:create(cc.DelayTime:create(0.4), cc.FadeIn:create(0.2)))
    --by wangyan
    if self._upNum2.isShow == true then
        self._upNum2:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.FadeIn:create(0.2)))
        self._upLab21:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.FadeIn:create(0.2)))
        self._upLab22:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.FadeIn:create(0.2)))
    end

    if self._upNum1.isShow == true or self._upNum2.isShow == true then
        self._upImg:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.FadeIn:create(0.2)))
    end
    
    -- local children = self._bg1:getChildren()
    -- for k,v in pairs(children) do
    --     v:runAction(cc.Sequence:create(cc.DelayTime:create(0.4), cc.FadeIn:create(0.2)))
    -- end
end

function BattleResultAirenWin:labelAnimTo(label, src, dest, isTime)
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

function BattleResultAirenWin:add2AirenRightData( battleData )
    if not battleData then return end
    local battleInfo  = battleData.rightData
    local npcD = tab:Npc(self._result.exInfo.id1 or 79001)
    local D = {art1=TeamUtils.getNpcTableValueByTeam(npcD, "art1")}
    local airen1 = {D = D, DEx = npcD, damageSkill = {}, damage = -1,hurt=-1,heal=-1,die = "?"}
    table.insert(battleInfo,airen1)
    
    local npcD = tab:Npc(self._result.exInfo.id2 or 79001)
    local D = {art1=TeamUtils.getNpcTableValueByTeam(npcD, "art1")}
    local airen2 = {D = D, DEx = npcD, damageSkill = {}, damage = -1,hurt=-1,heal=-1,die = "?"}
    table.insert(battleInfo,airen2)
    local thirdId 
    if self._result.exInfo.damageCount then
        thirdId = tab:PveSetting(902).NPC[3]
        battleData.bIsDrawf = false        
    else
        battleData.bIsDrawf = true
        thirdId = tab:PveSetting(901).NPC[3]
    end
    local npcD = tab:Npc(thirdId or 79001)
    local D = {art1=TeamUtils.getNpcTableValueByTeam(npcD, "art1")}
    local airen3 = {D = D, DEx = npcD, damageSkill = {},damage = -1,hurt=-1,heal=-1,die = "?"}
    table.insert(battleInfo,airen3)

end

function BattleResultAirenWin.dtor()
    BattleResultAirenWin = nil
    -- delaytick = nil
end

return BattleResultAirenWin