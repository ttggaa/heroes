--[[
    Filename:    HeroSoloPlayer.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2016-12-13 15:28:56
    Description: 英雄单挑播放器
--]]

local HeroSoloPlayer = class("HeroSoloPlayer", BaseMvcs, function ()
        return  cc.Node:create() 
    end)

function HeroSoloPlayer:ctor()
    HeroSoloPlayer.super.ctor(self)
    self:registerScriptHandler(function (state)
            if state == "exit" then
                self:clear()
            end
        end)
    self._heros = {nil, nil}

    self._timeLabel = cc.Label:createWithTTF("0", UIUtils.ttfName, 20)
    self._timeLabel:setPosition(0, 400)
    self:addChild(self._timeLabel)
end

function HeroSoloPlayer:clear()
	ScheduleMgr:cleanMyselfDelayCall(self)
	if self._updateId then
        ScheduleMgr:unregSchedule(self._updateId)
        self._updateId = nil
    end
	if self._heros[1] then
		self._heros[1]:removeFromParent()
	end
	if self._heros[2] then
		self._heros[2]:removeFromParent()
	end
	self._heros = {nil, nil}
	self._motionArray = {}
end

local common_motion_tab = {"stop", "run", "run2", "atk1", "atk2", "atk3", "die1", "die2", "dizzy", "hit1", "hit2", "suck", "win"}
-- 入场位置
local initPos = {{- MAX_SCREEN_WIDTH * 0.5 - 200, 0}, {MAX_SCREEN_WIDTH * 0.5 + 200, 0}}
-- 战斗位置
local battlePos = {{-150, 0}, {150, 0}}
function HeroSoloPlayer:init(data, overCallback)
	self:clear()
	self._data = data
	self._overCallback = overCallback
	local resDone = 0
	self._heros[1] = cc.Node:create()
	self._heros[1].D = tab.hero[data.info1.heroID]
	self._heros[1].ID = data.info1.heroID
	self._heros[1]:setPosition(initPos[1][1], initPos[1][2])
	self._heros[1]:setLocalZOrder(2)
	self:addChild(self._heros[1])
	self:setMotion(1, "stop")
    HeroAnim.new(self._heros[1], self._heros[1].D["heroart"], common_motion_tab, function (mc)
        mc:play()
        mc:changeMotion(self._heros[1].motion)
        self._heros[1].mc = mc
        resDone = resDone + 1
        if resDone == 3 then
    		self:initMotionData()
    	end
    end)
    self._heros[2] = cc.Node:create()
    self._heros[2].D = tab.hero[data.info2.heroID]
    self._heros[2].ID = data.info2.heroID
	self._heros[2]:setPosition(initPos[2][1], initPos[2][2])
	if self._data.winCamp == 1 then
		self._heros[2]:setLocalZOrder(1)
	else
		self._heros[2]:setLocalZOrder(3)
	end
	self:addChild(self._heros[2])
	self:setMotion(2, "stop")
    HeroAnim.new(self._heros[2], self._heros[2].D["heroart"], common_motion_tab, function (mc)
    	mc:setScaleX(-0.5)
        mc:play()
        mc:changeMotion(self._heros[2].motion)
        self._heros[2].mc = mc
        resDone = resDone + 1
        if resDone == 3 then
    		self:initMotionData()
    	end
    end) 
    self:createHUD(1)
    self:createHUD(2)
    self._updateId = ScheduleMgr:regSchedule(0, self, function(self, dt)
        self:update()
    end)
    self:walkIn(1, function ()
    	resDone = resDone + 1
    	if resDone == 3 then
    		self:initMotionData()
    	end
    end)
end

-- 初始化动作序列 
function HeroSoloPlayer:initMotionData()
	-- 动作帧数
	self._heros[1]._motionFrames = self._heros[1].mc:getMotionFrame()
	self._heros[2]._motionFrames = self._heros[2].mc:getMotionFrame()

	self._curMotionIndex = 1
	local camps = {self._data.atkCamp, 3 - self._data.atkCamp}
	local groupD = tab:HeroSoloGroup(self._data.groupID)
	local ma = self._motionArray
	local group, motion, motionD, _type, tick, camp, direct
	local specailID, specailD, hitins, subMotionD
	local hpCamp
	local maxHP = {0, 0}
	for i = 1, 500 do
		group = groupD["m"..i]
		if group == nil then break end
		tick = group[1]
		camp = camps[group[2]]
		motion = group[3]
		_type = motion[1]
		if _type == 1 then
			-- 动作
			motionD = tab.heroSoloMotion[motion[2]]
			if motionD then
				ma[#ma + 1] = {tick = tick, index = camp, _type = _type, motion = motionD["motion"], speed = motionD["speed"], 
								noloop = motionD["loop"] == 0, doneMotion = motionD["eMotion"]}
				-- 掉血
				if motionD["damage"] then
					if motionD["damagetgt"] == 1 then
						hpCamp = 3 - camp
					else
						hpCamp = camp
					end
					ma[#ma + 1] = {tick = tick + motionD["damagetime"] * 0.05 / motionD["speed"], index = hpCamp, _type = 9, hp = motionD["damage"]}
					maxHP[hpCamp] = maxHP[hpCamp] + motionD["damage"]
				end

				-- 检查specail表是否有额外需求
				specailID = self._heros[camp].ID .. "_" .. motionD["motion"]
				specailD = tab.heroSoloSpecial[specailID]
				if specailD then
					-- 给对方补受击动作
					hitins = specailD["hitins"]
					for i = 1, #hitins do
						subMotionD = tab.heroSoloMotion[hitins[i][1]]
						local subTick = tick + hitins[i][2] * 0.05 / subMotionD["speed"]
						ma[#ma + 1] = {tick = subTick, index = 3 - camp, _type = _type, motion = subMotionD["motion"], speed = subMotionD["speed"], 
								noloop = subMotionD["loop"] == 0, doneMotion = subMotionD["eMotion"]}	
												-- 掉血
						if subMotionD["damage"] then
							if subMotionD["damagetgt"] == 1 then
								hpCamp = camp
							else
								hpCamp = 3 - camp
							end
							ma[#ma + 1] = {tick = subTick + subMotionD["damagetime"] * 0.05 / subMotionD["speed"], index = hpCamp, _type = 9, hp = subMotionD["damage"]}
							maxHP[hpCamp] = maxHP[hpCamp] + subMotionD["damage"]
						end	
					end
					-- 动画
				end
			end
		elseif _type == 2 then
			-- 位移
			direct = motion[2]
			if direct == 1 then
				-- 正
				if camp ~= 1 then
					direct = -1
				end
			else
				-- 反
				if camp == 1 then
					direct = -1
				else
					direct = 1
				end
			end
			local _data = {tick = tick, index = camp, _type = _type, direct = direct, time = motion[3], disx = motion[4], disy = motion[5]}
			if not _data.disy then
				_data.disy = 0
			end
			ma[#ma + 1] = _data
		elseif _type == 3 then
			-- 震屏
		elseif _type == 4 then
			-- 特效
		end
	end
	table.sort(ma, function(a, b)
		return a.tick < b.tick
	end)
	-- 插入结束动作
	local lastTick = ma[#ma].tick + 0.01
	ma[#ma + 1] = {tick = lastTick, _type = 0}
	-- 根据战前战后血量 计算出总血量
	for i = 1, 2 do
		local info = self._data["info"..i]
		local hero = self._heros[i]
		local pro = (info.HP_begin - info.HP_end) / info.HP_begin
		local maxHP = pro == 0 and "MISS" or math.floor(maxHP[i] / pro)
		hero.maxHP = maxHP
		hero.HPPro = info.HP_begin / 8
		hero.HP = maxHP
		hero.destHP = info.HP_begin / 8 * 100
	end

	ScheduleMgr:delayCall(0, self, function()
		self._beginMotionTick = socket.gettime()
	end)
end

function HeroSoloPlayer:setMotion(index, motion, speed, noloop, callback)
	local hero = self._heros[index]
	hero.motion = motion
	if hero.mc then
		local inv = 0.05
		if speed then
			inv = 0.05 / speed
		end
		hero.mc:changeMotion(motion, nil, callback, noloop, inv)
	end
end

function HeroSoloPlayer:hpAnim(index, hp)
	local hero = self._heros[index]

    local dHP = 0
    if hero.maxHP == "MISS" then
        dHP = "MISS"
    else
	    local oldPro = math.floor(hero.HP / hero.maxHP * 100 * hero.HPPro)
	    hero.HP = hero.HP - hp
	    hero.destHP = math.floor(hero.HP / hero.maxHP * 100 * hero.HPPro)
	    dHP = (oldPro - hero.destHP) * 100
    end

	-- 跳字
	local HPLabel = cc.Label:createWithTTF(dHP, UIUtils.ttfName, 35)
    HPLabel:setPosition(0, 220)
    HPLabel:setColor(cc.c3b(255, 50, 50))
    HPLabel:enableOutline(cc.c4b(0,0,0,255), 2)
    hero:addChild(HPLabel, 10)

    HPLabel:setScale(0)
    HPLabel:runAction(cc.Sequence:create(
    					cc.ScaleTo:create(0.05, 2),
    					cc.ScaleTo:create(0.15, 1),
    					cc.MoveBy:create(0.3, cc.p(0, 30)),
    					cc.Spawn:create(cc.MoveBy:create(0.3, cc.p(0, 30)), cc.FadeOut:create(0.3))
    				))
end

function HeroSoloPlayer:moveTo(index, x, y, time, callback)
	local hero = self._heros[index]
	local tick = socket.gettime()
    hero._moveScrx = hero:getPositionX()
    hero._moveScry = hero:getPositionY()
    hero._moveDstx = x
    hero._moveDsty = y
    hero._moveDeltax = hero._moveDstx - hero._moveScrx
    hero._moveDeltay = hero._moveDsty - hero._moveScry
	hero._moveTick = time
	hero._beginMoveTick = tick
	hero._endMoveTick = tick + time
	hero._isMove = true
	hero._moveCallback = callback
end

function HeroSoloPlayer:update()
	local tick = socket.gettime()
	-- 计算移动
	for i = 1, 2 do
		local hero = self._heros[i]
		if hero._isMove then
			if tick >= hero._endMoveTick then
				hero._isMove = false
				hero:setPosition(hero._moveDstx, hero._moveDsty)
				if hero._moveCallback then
					hero._moveCallback()
				end
			else
				local rate = (tick - hero._beginMoveTick) / (hero._moveTick)
				hero:setPosition(hero._moveScrx + hero._moveDeltax * rate, hero._moveScry + hero._moveDeltay * rate)
			end
		end
	end
	if self._beginMotionTick then
		self._timeLabel:setString(tick - self._beginMotionTick)
		local ma = self._motionArray
		local data = ma[self._curMotionIndex]
		while data and tick >= data.tick + self._beginMotionTick do
			local _data = data
			if _data._type == 1 then
				-- 动作
				self:setMotion(_data.index, _data.motion, _data.speed, _data.noloop, function ()
					if _data.doneMotion then
						self:setMotion(_data.index, _data.doneMotion)
					end
				end)
			elseif _data._type == 2 then
				-- 位移
				local x = self._heros[_data.index]:getPositionX() + _data.disx * _data.direct
				local y = self._heros[_data.index]:getPositionY() + _data.disy
				self:moveTo(_data.index, x, y, _data.time)
			elseif _data._type == 9 then
				-- 跳血
				self:hpAnim(_data.index, _data.hp)
			elseif _data._type == 0 then
				-- 结束了
				self._beginMotionTick = nil
				self:over()
				break
			end
			self._curMotionIndex = self._curMotionIndex + 1
			data = ma[self._curMotionIndex]
		end
	end
	-- 血条缓动
	for i = 1, 2 do
		local hero = self._heros[i]
		if hero.destHP then
			local nowHP = hero.HPUI:getPercentage()
			if nowHP ~= hero.destHP then
				nowHP = nowHP + (hero.destHP - nowHP) * 0.6
				if math.abs((hero.destHP - nowHP)) < 1 then
					nowHP = hero.destHP
				end
				hero.HPUI:setPercentage(nowHP)
				local line
				for k = 1, #hero.HPUI.lines do
					line = hero.HPUI.lines[k]
					if line.visible and nowHP <= line.pro then 
						line.visible = false
						line:setVisible(false)
					end
				end
			end
			local nowHP = hero.HPUI_shadow:getPercentage()
			if nowHP ~= hero.destHP then
				nowHP = nowHP + (hero.destHP - nowHP) * 0.1
				if math.abs((hero.destHP - nowHP)) < 1 then
					nowHP = hero.destHP
				end
				hero.HPUI_shadow:setPercentage(nowHP)
			end
		end
	end
end

-- 进场
function HeroSoloPlayer:walkIn(time, callback)
	self:setMotion(1, "run")
	self:moveTo(1, battlePos[1][1], battlePos[1][2], time)

	self:setMotion(2, "run")
	self:moveTo(2, battlePos[2][1], battlePos[2][2], time, function ()
		self:setMotion(1, "stop")
		self:setMotion(2, "stop")
		if callback then callback() end
	end)
end

-- 退场
function HeroSoloPlayer:walkLeave(indexId, callback)
    local time = 1
    self:setMotion(1, "run")
    self:setMotion(2, "run")
    self._heros[1].mc:setScaleX(self._heros[1].mc:getScale() * -1)
    self._heros[2].mc:setScaleX(self._heros[2].mc:getScale() * -1)

    self:moveTo(1, initPos[1][1], initPos[1][2], time)
    self:moveTo(2, initPos[2][1], initPos[2][2], time, function ()
        self:setMotion(1, "stop")
        self:setMotion(2, "stop")
        if callback then callback() end
    end)
end

function HeroSoloPlayer:over()
	if self._data.winCamp ~= 0 then
		-- 一方胜利
		local winner = self._data.winCamp
		local loser = 3 - winner
		ScheduleMgr:delayCall(1000, self, function()
			self:setMotion(winner, "win")
			if self._overCallback then 
				self._overCallback()
			end
		end)
		local mcName = "zuoji_" .. self._heros[loser].D["heroart"]
		local mc = mcMgr:createViewMC(mcName, false, true)
		mc:setScaleX(self._heros[loser].mc:getScale() * 2)
		mc:setPosition(self._heros[loser]:getPositionX(), 0)
		self:addChild(mc, 0)
	else
		-- 平局
		if self._overCallback then 
			self._overCallback()
		end
	end
end

function HeroSoloPlayer:createHUD(index)
	local hero = self._heros[index]
	-- 血条背景
	local hpbg = cc.Sprite:createWithSpriteFrameName("heroSoloHP_0.png")
	hpbg:setPosition(0, 220)
	hero:addChild(hpbg, 5)

	local info = self._data["info"..index]
	info.HP_begin = info.HP_begin or 8
	local _pro = info.HP_begin / 8 * 100

	-- 血条
	local sp = cc.Sprite:createWithSpriteFrameName("heroSoloHP_"..info.HP_color..".png")
    local hp = cc.ProgressTimer:create(sp)
    hp:setPurityColor(255, 0, 0)
    hp:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    hp:setMidpoint(cc.p(0, 0.5))
    hp:setBarChangeRate(cc.p(1, 0))    
    if index == 2 then
    	hp:setScaleX(-1)
    	hp:setAnchorPoint(1, 0)
    else
    	hp:setAnchorPoint(0, 0)
    end
    hp:setPercentage(_pro)
	hpbg:addChild(hp)
	hero.HPUI_shadow = hp

	local sp = cc.Sprite:createWithSpriteFrameName("heroSoloHP_"..info.HP_color..".png")
    local hp = cc.ProgressTimer:create(sp)
    hp:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    hp:setMidpoint(cc.p(0, 0.5))
    hp:setBarChangeRate(cc.p(1, 0))    
    if index == 2 then
    	hp:setScaleX(-1)
    	hp:setAnchorPoint(1, 0)
    else
    	hp:setAnchorPoint(0, 0)
    end
    hp:setPercentage(_pro)

	hpbg:addChild(hp)
	hero.HPUI = hp

	-- 血条格子
	hp.lines = {}
	local num = 8--info.HP_begin
	local width = 164
	for i = 1, num - 1 do
		local line = cc.Sprite:createWithSpriteFrameName("heroSoloHP_line.png")
		line:setAnchorPoint(0, 0)
		line:setPositionX(1 / num * i * 164)
		hpbg:addChild(line)
		if index == 2 then
			line.pro = (1 - 1 / num * i) * 100
		else
			line.pro = 1 / num * i * 100
		end
		line.visible = (100 - line.pro) > (100 - _pro)
		line:setVisible(line.visible)
		hp.lines[i] = line
	end
	
	-- 名字
    local nameLabel = cc.Label:createWithTTF(info.name, UIUtils.ttfName, 20)
    nameLabel:setPosition(0, 240)
    nameLabel:enableOutline(cc.c4b(0,0,0,255), 2)
    hero:addChild(nameLabel, 6)
end

function HeroSoloPlayer.dtor()
	common_motion_tab = nil
end

return HeroSoloPlayer