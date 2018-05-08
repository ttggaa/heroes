--[[
    Filename:    BattleResultHeroDuelLose.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-12-14 17:46:43
    Description: File description
--]]

local BattleResultHeroDuelLose = class("BattleResultHeroDuelLose", BasePopView)

function BattleResultHeroDuelLose:ctor(data)
    BattleResultHeroDuelLose.super.ctor(self)

    self._result = data.result
    self._callback = data.callback
    self._battleInfo = data.data

    self._loseNum = data.result.d.heroDuel.loses or 0

    local battleInfo = data.battleInfo
    if battleInfo.reverse then
        local tmp = self._battleInfo.leftData
        self._battleInfo.leftData = self._battleInfo.rightData
        self._battleInfo.rightData = tmp
        tmp = self._battleInfo.hero1
        self._battleInfo.hero1 = self._battleInfo.hero2
        self._battleInfo.hero2 = tmp
    end
end

function BattleResultHeroDuelLose:getBgName()
    return "battleResult_bg.jpg"
end

function BattleResultHeroDuelLose:onInit()
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
    UIUtils:formatBattleResultBtnTxt(self._countBtn:getChildByFullName("nameTxt"))
    self._bg1 = self:getUI("bg.bg1")
    self._bg1:setCascadeOpacityEnabled(true)
    self._bg1:setOpacity(0)

    local title = self._bg1:getChildByFullName("title")
    title:setColor(cc.c3b(255, 209, 157))
    title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)

    local desLabel = self._bg1:getChildByFullName("desLabel")
    desLabel:setColor(cc.c3b(255, 209, 157))
    desLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)

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

    self._crossList = {}
    for i = 1, 3 do
        local crossIcon = self._bg1:getChildByFullName("cross" .. i)
        if i >= self._loseNum then
            crossIcon:setOpacity(0)
        end
        table.insert(self._crossList, crossIcon)
    end

    self._desLabel = self:getUI("bg.bg1.desLabel")

	self._time = self._battleInfo.time

	local mcMgr = MovieClipManager:getInstance()
    -- mcMgr:loadRes("commonwin", function ()
        self:animBegin()
    -- end)
end

function BattleResultHeroDuelLose:onQuit()
	if self._callback then
		self._callback()
	end
end

function BattleResultHeroDuelLose:onCount()
	self._viewMgr:showView("battle.BattleCountView",self._battleInfo,true)
end

local delaytick = {360, 380, 380}
function BattleResultHeroDuelLose:animBegin()
    audioMgr:stopMusic()
	audioMgr:playSoundForce("SurrenderBattle")

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
	local moveRole = cc.Sequence:create(cc.MoveTo:create(0.05,cc.p(posRoleX+20,posRoleY)),cc.MoveTo:create(0.01,cc.p(posRoleX,posRoleY)))
	self._rolePanel:runAction(moveRole)
	
	ScheduleMgr:delayCall(200, self, function(sender)
        local posBgX,posBgY = self._posBgX,self._posBgY
        local moveBg = cc.Sequence:create(cc.MoveTo:create(0.15,cc.p(posBgX,posBgY-20)),cc.MoveTo:create(0.01,cc.p(posBgX,posBgY)))
        self._bgImg:runAction(moveBg)
		self:animNext()
	end)
end

function BattleResultHeroDuelLose:animNext()	
	-- ScheduleMgr:delayCall(delaytick[self._star], self, function()
		local animPos = self:getUI("bg.animPos")
		-- mcMgr:loadRes("commonlight", function ()
	       	local mc1 = mcMgr:createViewMC("huodedaojudiguang_commonlight", true, false, function (_, sender)
		        sender:gotoAndPlay(80)
		    end,RGBA8888)
		    mc1:setPosition(animPos:getPosition())
		    self._bg:addChild(mc1, 1)
    	-- end,RGBA8888)		
	-- end)

    local mc2 = mcMgr:createViewMC("shibai_commonlose", true, false, function (_, sender)
        sender:gotoAndPlay(100)
    end)
    mc2:setPosition(animPos:getPosition())
    self._bg:addChild(mc2, 5)
    self._timeLabel = cc.Label:createWithTTF("00:00", UIUtils.ttfName,  26)
    self._timeLabel:setColor(cc.c3b(245, 20, 34))
    self._timeLabel:enableOutline(cc.c4b(0,0,0,255),2)
    self._timeLabel:setPosition(109, -8)
    self._timeLabel:setPosition(animPos:getPositionX(), animPos:getPositionY() - 82)
    self._bg:addChild(self._timeLabel, 6)
    if self._time then
    	self:labelAnimTo(self._timeLabel, 0, self._time, true)
    end

    if self._crossList and self._crossList[self._loseNum] then
        local curCrossIcon = self._crossList[self._loseNum]
        curCrossIcon:setScale(1.5)
        curCrossIcon:runAction(cc.Sequence:create(
            cc.DelayTime:create(1.0), 
            cc.Spawn:create(cc.EaseOut:create(cc.ScaleTo:create(0.1, 1),3),cc.FadeIn:create(0.01))
            )
        )
    end

    self._bg1:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.FadeIn:create(0.1)))
    self._countBtn:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.FadeIn:create(0.3),cc.CallFunc:create(function ()
    	self._countBtn:setEnabled(true)
    end)))
	self._touchPanel:runAction(cc.Sequence:create(cc.DelayTime:create(1.4), cc.CallFunc:create(function()
    	self._touchPanel:setEnabled(true)
    end)))
end


function BattleResultHeroDuelLose:labelAnimTo(label, src, dest, isTime)
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

function BattleResultHeroDuelLose.dtor()
	BattleResultHeroDuelLose = nil
end

return BattleResultHeroDuelLose