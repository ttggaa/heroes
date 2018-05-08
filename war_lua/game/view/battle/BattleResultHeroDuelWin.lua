--[[
    Filename:    BattleResultHeroDuelWin.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-12-14 17:03:07
    Description: File description
--]]

local BattleResultHeroDuelWin = class("BattleResultHeroDuelWin", BasePopView)

function BattleResultHeroDuelWin:ctor(data)
    BattleResultHeroDuelWin.super.ctor(self)

    self._result = data.result
    self._callback = data.callback
    self._battleInfo = data.data
    self._star = self._result.star
    if self._star == nil then
    	self._star = 3
    end

    self._winNum = data.result.d.heroDuel.wins or 0

   	local battleInfo = data.battleInfo
   	if battleInfo.reverse then
        local tmp = self._battleInfo.leftData
        self._battleInfo.leftData = self._battleInfo.rightData
        self._battleInfo.rightData = tmp
        tmp = self._battleInfo.hero1
        self._battleInfo.hero1 = self._battleInfo.hero2
        self._battleInfo.hero2 = tmp
   	end

    self._kShieldType = {
        [1] = {name = "shitoudun_gezhongdun", mcX = 10, mcY = -10, fontX = 0, fontY = 0, scale = 0.8},
        [2] = {name = "tongdun_gezhongdun", mcX = 10, mcY = -10, fontX = 0, fontY = 0, scale = 0.6},
        [3] = {name = "yindun_gezhongdun", mcX = 10, mcY = -20, fontX = 2, fontY = -12, scale = 0.5},
        [4] = {name = "jindun_gezhongdun", mcX = 8, mcY = 0, fontX = 0, fontY = 0, scale = 0.5}
    }
end

function BattleResultHeroDuelWin:getBgName()
    return "battleResult_bg.jpg"
end
function BattleResultHeroDuelWin:onInit()
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
    
    self._roleImg = self:getUI("bg.role_panel.role_img")    
    self._roleImgShadow = self:getUI("bg.role_panel.roleImg_shadow")

    self._bgImg = self:getUI("bg.bg_img")
    self._bgImg:loadTexture("asset/bg/battleResult_flagBg.png")

    local bg_click =  self:getUI("bg_click")
    bg_click:setSwallowTouches(false)
    self._countBtn = self:getUI("bg_click.countBtn")
    self._countBtn:setSwallowTouches(true)
    self._countBtn:setEnabled(false)
    UIUtils:formatBattleResultBtnTxt(self._countBtn:getChildByFullName("nameTxt"))
    self._bg1 = self:getUI("bg.bg1")

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

    self:registerClickEvent(self._countBtn, specialize(self.onCount, self))

    self._countBtn:setOpacity(0)
    self._countBtn:setCascadeOpacityEnabled(true)

    self._desLabel = self:getUI("bg.bg1.desLabel")
    self._desLabel:setOpacity(0)
    self._desLabel:setColor(cc.c3b(255, 209, 157))
    self._desLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)

	self._time = self._battleInfo.time

	local mcMgr = MovieClipManager:getInstance()
    -- mcMgr:loadRes("commonwin", function ()
        self:animBegin()
    -- end)
end

function BattleResultHeroDuelWin:onQuit()
	if self._callback then
		self._callback()
	end
end

function BattleResultHeroDuelWin:onCount()
	self._viewMgr:showView("battle.BattleCountView",self._battleInfo,true)
end

local delaytick = {360, 380, 380}
function BattleResultHeroDuelWin:animBegin()
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
        if self._modelMgr:getModel("HeroDuelModel"):isTeamJx(lihuiId) then
            -- artUrl = "asset/uiother/team/ta_"..imgName..".png"
            -- 结算例会单独处理 读配置
            artUrl = "asset/uiother/team/" ..teamData.jxart2 .. ".png"
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

function BattleResultHeroDuelWin:animNext(mc2)	
	-- 动画
    local animPos = self:getUI("bg.animPos")
   
    local mc3 = mcMgr:createViewMC("shenglixing_commonwin", true)
    mc3:setPosition(animPos:getPositionX(),animPos:getPositionY() - 70)
    self._bg:addChild(mc3, 4)
    
    self._timeLabel = cc.Label:createWithTTF("00:00", UIUtils.ttfName,  26)
    self._timeLabel:setColor(cc.c3b(245, 20, 34))
    self._timeLabel:enableOutline(cc.c4b(0,0,0,255),2)
    self._timeLabel:setPosition(animPos:getPositionX(), animPos:getPositionY() - 82)
    self._bg:addChild(self._timeLabel, 6)
    if self._time then
    	self:labelAnimTo(self._timeLabel, 0, self._time, true)
    end

    local shieldType = nil
    if self._winNum >= 9 then

        shieldType = self._kShieldType[4]
    elseif self._winNum >= 5 then
        shieldType = self._kShieldType[3]
        
    elseif self._winNum >= 1 then
        shieldType = self._kShieldType[2]
    else
        shieldType = self._kShieldType[1]
    end

    local shieldMC = mcMgr:createViewMC(shieldType.name, false, false)
    shieldMC:setScale(shieldType.scale)
    shieldMC:setPosition(165 + shieldType.mcX, 124 + shieldType.mcY)
    self._bg1:addChild(shieldMC)

    if self._winNum > 0 then
        local winCountLabel = cc.LabelBMFont:create(tostring(self._winNum), UIUtils.bmfName_hduel_win)
        winCountLabel:setScale(shieldType.scale)
        winCountLabel:setPosition(174 + shieldType.fontX, 130 + shieldType.fontY)
        winCountLabel:setOpacity(0)
        self._bg1:addChild(winCountLabel)
        winCountLabel:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.FadeIn:create(0.1)))
    end

    self._desLabel:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.FadeIn:create(0.1)))
    self._countBtn:runAction(cc.Sequence:create(cc.DelayTime:create(0.8), cc.FadeIn:create(0.3),cc.CallFunc:create(function ()
    	self._countBtn:setEnabled(true)
    end)))
	self._touchPanel:runAction(cc.Sequence:create(cc.DelayTime:create(1.2), cc.CallFunc:create(function()
    	self._touchPanel:setEnabled(true)
    end)))
end


function BattleResultHeroDuelWin:labelAnimTo(label, src, dest, isTime)
	audioMgr:playSound("TimeCount")
	if dest == nil then return end
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

function BattleResultHeroDuelWin.dtor()
	BattleResultHeroDuelWin = nil
end

return BattleResultHeroDuelWin