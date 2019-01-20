--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

--[[
    Filename:    NewHeroSoloPlayer.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2016-12-13 15:28:56
    Description: 英雄单挑播放器
--]]

local NewHeroSoloPlayer = class("NewHeroSoloPlayer", BaseMvcs, function ()
        return  cc.Node:create() 
    end)

function NewHeroSoloPlayer:ctor()
    NewHeroSoloPlayer.super.ctor(self)
    self:registerScriptHandler(function (state)
            if state == "exit" then
                self:clear()
            end
        end)
    self._heros = {}

    self._timeLabel = cc.Label:createWithTTF("0", UIUtils.ttfName, 20)
    self._timeLabel:setPosition(0, 400)
    self._timeLabel:setVisible(false)
    self:addChild(self._timeLabel)
end

function NewHeroSoloPlayer:clear()
	ScheduleMgr:cleanMyselfDelayCall(self)
	if self._updateId then
        ScheduleMgr:unregSchedule(self._updateId)
        self._updateId = nil
    end
    for key, var in ipairs(self._heros) do
        if var then
            var:removeFromParent()
            var =  nil
        end
    end
    self._heros = {}
	self._motionArray = {}
end

local common_motion_tab = {"stop", "run", "run2", "atk1", "atk2", "atk3", "die1", "die2", "dizzy", "hit1", "hit2", "suck", "win", "zuoji"}
------ 入场位置
--local initPos = { {- MAX_SCREEN_WIDTH * 0.5 - 300, 180},{- MAX_SCREEN_WIDTH * 0.5 - 200, 60},{- MAX_SCREEN_WIDTH * 0.5 - 300, -100}, { MAX_SCREEN_WIDTH * 0.5 + 200, 180},{ MAX_SCREEN_WIDTH * 0.5 + 300, 60},{ MAX_SCREEN_WIDTH * 0.5 + 200, -100}}
------ 战斗位置
--local battlePos = {{-250, 180},{-150, 60},{-250, -100}, {200, 180}, {300, 60}, {200, -100}}

function NewHeroSoloPlayer:createPlayer(data, nIndex)
    local hero = cc.Node:create()
	hero.D = tab.hero[data.heroID]
	hero.ID = data.heroID
    hero._data = data
--    print("createPlayer ",data.startPos.x, data.startPos.y)
	hero:setPosition(data.startPos)
    hero._nIndex = nIndex
    local zorDer = 0
    local bIWin = false
    if nIndex > self._disCount then
        hero._bIsLeft = false
        zorDer = (nIndex - self._disCount) * 3
        if self._data.atkCamp[nIndex] == 2 then
            bIWin = true
        end
    else
        hero._bIsLeft = true
        zorDer = nIndex * 3
        if self._data.atkCamp[nIndex] == 1 then
            bIWin = true
        end
    end
    hero._isWin = bIWin
    if bIWin then
	    hero:setLocalZOrder(zorDer + 1)
    else
        hero:setLocalZOrder(zorDer - 1)
    end
	self:addChild(hero)
--	hero:setScale(0.4)
    HeroAnim.new(hero, hero.D["heroart"], common_motion_tab, function (mc)
        mc:play()
        mc:changeMotion(1)
        mc:setScaleX((mc._parentNode._bIsLeft) and self._data.scale or (-1 * self._data.scale))
        mc:setScaleY(self._data.scale)

        mc._parentNode.mc = mc
        self.resDone = self.resDone + 1
--        print("self.resDone ", self.resDone)
        if self.resDone == self._totalCount then
            self._bIsUpdate = true
            ScheduleMgr:delayCall(1, self, function()
		        self:walkIn(1, function ()
                    self:initMotionData()
                end)
	        end)
            
    	end
    end)
    return hero
end

function NewHeroSoloPlayer:init(data, overCallback)
    self._bIsUpdate = false
	self:clear()
	self._data = data
	self._overCallback = overCallback
	self.resDone = 0
    self._disCount = #data.info1
    self._totalCount = #data.info1 + #data.info2
    for i,v in ipairs(data.info1) do
        if v then
            local index = #self._heros + 1
	        self._heros[index] = self:createPlayer(v, index)
        end
    end

    for i,v in ipairs(data.info2) do
        if v then
            local index = #self._heros + 1
	        self._heros[index] = self:createPlayer(v, index)
        end
    end
    
    for key, var in ipairs(self._heros) do
        if var then
            self:createHUD(key)
        end
    end
    
    self._updateId = ScheduleMgr:regSchedule(0, self, function(self, dt)
        self:update()
    end)
    
end

function NewHeroSoloPlayer:getMa(groupID, nIndex)
    local atkCamp = self._data.atkCamp[nIndex] or 1
    local camps = {atkCamp, 3 - atkCamp}
    local groupD = tab:HonorArenaSoloGroup(groupID)
	local ma = {}
	local group, motion, motionD, _type, tick, camp, direct, nPos
	local specailID, specailD, hitins, subMotionD
	local hpCamp, hpCampIndex
    local posIndex = {nIndex, nIndex + self._disCount}
	local maxHP = {0, 0}
	for i = 1, 500 do
		group = groupD["m"..i]
		if group == nil then break end
		tick = group[1]
		camp = camps[group[2]]
        nPos = posIndex[camp]
		motion = group[3]
		_type = motion[1]
		if _type == 1 then
			-- 动作
			motionD = clone(tab.heroSoloMotion[motion[2]])
			if motionD then
				ma[#ma + 1] = {tick = tick, index = nPos, _type = _type, motion = motionD["motion"], speed = motionD["speed"], 
								noloop = motionD["loop"] == 0, doneMotion = motionD["eMotion"]}
				-- 掉血
				if motionD["damage"] then
					if motionD["damagetgt"] == 1 then
						hpCamp = 3 - camp
                        hpCampIndex = posIndex[3 - camp]
					else
						hpCamp = camp
                        hpCampIndex = posIndex[camp]
					end
					ma[#ma + 1] = {tick = tick + motionD["damagetime"] * 0.05 / motionD["speed"], index = hpCampIndex, _type = 9, hp = motionD["damage"]}
--                    print("**************", 1,hpCamp or "q", maxHP[hpCamp] or "w", motionD["damage"] or "e", hpCampIndex or "r", #ma)
					maxHP[hpCamp] = maxHP[hpCamp] + motionD["damage"]
				end

				-- 检查specail表是否有额外需求
				specailID = self._heros[nPos].ID .. "_" .. motionD["motion"]
				specailD = clone(tab.heroSoloSpecial[specailID])
				if specailD then
					-- 给对方补受击动作
					hitins = specailD["hitins"]
					for i = 1, #hitins do
--                        if i == 1 then
--                        print("++++++++222222222222222222+++++++", specailID)
--                        end
						subMotionD = clone(tab.heroSoloMotion[hitins[i][1]])
						local subTick = tick + hitins[i][2] * 0.05 / subMotionD["speed"]
						ma[#ma + 1] = {tick = subTick, index = posIndex[3 - camp], _type = _type, motion = subMotionD["motion"], speed = subMotionD["speed"], 
								noloop = subMotionD["loop"] == 0, doneMotion = subMotionD["eMotion"]}	
												-- 掉血
						if subMotionD["damage"] then
							if subMotionD["damagetgt"] == 1 then
								hpCamp = camp
                                hpCampIndex = posIndex[camp]
							else
								hpCamp = 3 - camp
                                hpCampIndex = posIndex[3 - camp]
							end
							ma[#ma + 1] = {tick = subTick + subMotionD["damagetime"] * 0.05 / subMotionD["speed"], index = hpCampIndex, _type = 9, hp = subMotionD["damage"]}
--                            print("**************", 2, hpCamp or "q", maxHP[hpCamp] or "w", subMotionD["damage"] or "e", hpCampIndex or "r", #ma, i)
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
			local _data = {tick = tick, index = nPos, _type = _type, direct = direct, time = motion[3], disx = motion[4], disy = motion[5]}
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
--	ma.maxHP = maxHP
--    print("+++++++++++++++", nIndex, nIndex + self._disCount, #ma)
    maxHP[atkCamp] = maxHP[atkCamp] + 4
    maxHP[3 - atkCamp] = maxHP[3 - atkCamp] + 1
    for key = nIndex, self._totalCount, self._disCount do
        -- 根据战前战后血量 计算出总血量
        local hero = self._heros[key]
        local _camp = key > self._disCount and camps[3 - atkCamp] or camps[atkCamp]
        if hero then
	        local info = hero._data
	        local pro = (info.HP_begin - info.HP_end) / info.HP_begin
	        local maxHP = pro == 0 and "MISS" or math.floor(maxHP[_camp] / pro)
	        hero.maxHP = maxHP
	        hero.HPPro = info.HP_begin / 8
	        hero.HP = maxHP
			hero.destHP = info.HP_begin / 8 * 100

--            print(key, hero.maxHP, hero.HPPro, hero.HP, hero.destHP)

        else
            print("error 1")
        end
    end
    

    return ma
end

-- 初始化动作序列 
function NewHeroSoloPlayer:initMotionData()
	-- 动作帧数
    for key, var in ipairs(self._heros) do
        if var then
            var._motionFrames = var.mc:getMotionFrame()
        end
    end
    self._curMotionIndex = 1
    for i = 1, self._disCount do
        self._motionArray[i] = self:getMa(self._data.groupID[i] or 1, i)
        self._motionArray[i]._curMotionIndex = 1
    end

	ScheduleMgr:delayCall(0, self, function()
		self._beginMotionTick = socket.gettime()
	end)
end

function NewHeroSoloPlayer:setMotion(index, motion, speed, noloop, callback)
	local hero = self._heros[index]
	hero.motion = motion
	if hero.mc then
		local inv = 0.05
		if speed then
			inv = 0.05 / speed
		end
        if motion == "atk1" or motion == "atk2" or motion == "atk3" then
            audioMgr:playSoundForce("gloryArena_attack")
        end
		hero.mc:changeMotion(motion, nil, callback, noloop, inv)
	end
end

function NewHeroSoloPlayer:hpAnim(index, hp)
	local hero = self._heros[index]

    local dHP = 0
    if hero.maxHP == "MISS" then
        dHP = "MISS"
    else
--        print("index", index)
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

function NewHeroSoloPlayer:moveTo(index, x, y, time, callback)
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

function NewHeroSoloPlayer:update()
    if not self._bIsUpdate then
        return
    end
	local tick = socket.gettime()
	-- 计算移动
	for i = 1, self._totalCount do
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
				hero:setPosition((hero._moveScrx + hero._moveDeltax * rate), hero._moveScry + hero._moveDeltay * rate)
			end
		end
	end
	if self._beginMotionTick then
--		self._timeLabel:setString(tick - self._beginMotionTick)
        local isBack ={}
        for i = 1, self._disCount do
            local ma = self._motionArray[i]
            local data = ma[ma._curMotionIndex]
		    if data and tick >= data.tick + self._beginMotionTick then
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
--                    if _data.index > 3 then
--                        print("++++++++++++++++", _data.index, _data.hp)
--                    end
				    self:hpAnim(_data.index, _data.hp)
			    elseif _data._type == 0 then
				    -- 结束了
				    self:over(i)
                    isBack[i] = true
			    end
			    ma._curMotionIndex = ma._curMotionIndex + 1
			    data = ma[ma._curMotionIndex]
            else
                isBack[i] = true
		    end
        end
	end
	-- 血条缓动
    if self._beginMotionTick then
	    for i = 1, self._totalCount do
		    local hero = self._heros[i]
		    if hero and hero.destHP then
			    local nowHP = hero.HPUI:getPercentage()
			    if nowHP ~= hero.destHP then
				    nowHP = nowHP + (hero.destHP - nowHP) * 0.6
				    if math.abs((hero.destHP - nowHP)) < 1 then
					    nowHP = hero.destHP
				    end
				    hero.HPUI:setPercentage(nowHP)
--				    local line
--				    for k = 1, #hero.HPUI.lines do
--					    line = hero.HPUI.lines[k]
--					    if line.visible and nowHP <= line.pro then 
--						    line.visible = false
--						    line:setVisible(false)
--					    end
--				    end
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
end

-- 进场
function NewHeroSoloPlayer:walkIn(time, callback)
    self._startCount = 0
    self._entBattle = {}
    for key, var in ipairs(self._heros) do
        if var then
            self:setMotion(key, "run")
            if var.mc then
                var.mc:setScaleX((var._bIsLeft) and self._data.scale or (-1 * self._data.scale))
            end
--            print("walkIn",var._data.battlePos.x, var._data.battlePos.y)
	        self:moveTo(key, var._data.battlePos.x, var._data.battlePos.y, time, function ()
                self._startCount = self._startCount + 1
		        self:setMotion(key, "stop")
                if self._startCount >= self._totalCount then
		            if callback then callback() end
                end
	        end)
        end
    end
end

-- 退场
function NewHeroSoloPlayer:walkLeave(indexId, callback)
    local time = 1
    self._endCount = 0

    for key, var in ipairs(self._heros) do
        if var then
             self:setMotion(key, "run")
             var.mc:setScaleX(var.mc:getScale() * -1)
             self:moveTo(key, var._data.startPos.x, var._data.startPos.y, time, function ()
                self._endCount = self._endCount + 1
                self:setMotion(key, "stop")
                if self._endCount >= self._totalCount then
                    if callback then callback() end
                end
            end)
        end
    end

    
end

function NewHeroSoloPlayer:isOver()
    local bIsOver = true
    for i = 1, self._disCount do
        if not self._entBattle[i] then
            bIsOver = false
            break
        end
    end
    if bIsOver then
        self._beginMotionTick = nil
        if self._overCallback then 
			self._overCallback()
		end
    end
end

function NewHeroSoloPlayer:setDie(index)
    local hero = self._heros[index]
    if hero then
        hero.HPUI_shadow:setVisible(false)
        hero.HPUI:setVisible(false)
        hero.nameLabel:setVisible(false)
        hero._hpbg:setVisible(false)
    end
end

function NewHeroSoloPlayer:over(nIndex)
    if not self._entBattle[nIndex] then
        local data = self._data.info1[nIndex]
        self._entBattle[nIndex] = true
	    if self._data.atkCamp[nIndex] and self._data.atkCamp[nIndex] ~= 0 then
		    -- 一方胜利
            local winner, loser
            if self._data.atkCamp[nIndex] == 1 then
                winner = nIndex
		        loser = nIndex + self._disCount
            elseif self._data.atkCamp[nIndex] == 2 then
                winner = nIndex + self._disCount
		        loser = nIndex
            end
		
		    ScheduleMgr:delayCall(1000, self, function()
--                print("winner",  winner)
--                print("loser",  loser)
			    self:setMotion(winner, "win")
			    self:isOver()
		    end)
            self:setDie(loser)
--            self._heros[loser].mc:setScaleX(self._heros[loser].mc:getScale() * -1)
--            self:setMotion(loser, "zuoji", nil, true, function()
----                        self._heros[loser]:setVisible(false)
--            end)
	    end
    end
end

function NewHeroSoloPlayer:createHUD(index)
	local hero = self._heros[index]
	-- 血条背景
	local hpbg = cc.Sprite:createWithSpriteFrameName("heroSoloHP_0.png")
	hpbg:setPosition(0, 180)
	hero:addChild(hpbg, 5)
    hero._hpbg = hpbg
	local info = hero._data
	info.HP_begin = info.HP_begin or 8
	local _pro = info.HP_begin / 8 * 100
    info.HP_color = info.HP_color or 1
	-- 血条
	local sp = cc.Sprite:createWithSpriteFrameName("heroSoloHP_"..info.HP_color..".png")
    local hp = cc.ProgressTimer:create(sp)
    hp:setPurityColor(255, 0, 0)
    hp:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    hp:setMidpoint(cc.p(0, 0.5))
    hp:setBarChangeRate(cc.p(1, 0))    
    if not hero._bIsLeft then
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
    if not hero._bIsLeft then
    	hp:setScaleX(-1)
    	hp:setAnchorPoint(1, 0)
    else
    	hp:setAnchorPoint(0, 0)
    end
    hp:setPercentage(_pro)

	hpbg:addChild(hp)
	hero.HPUI = hp

	-- 血条格子
--	hp.lines = {}
--	local num = 8--info.HP_begin
--	local width = 164
--	for i = 1, num - 1 do
--		local line = cc.Sprite:createWithSpriteFrameName("heroSoloHP_line.png")
--		line:setAnchorPoint(0, 0)
--		line:setPositionX(1 / num * i * 164)
--		hpbg:addChild(line)
--		if index == 2 then
--			line.pro = (1 - 1 / num * i) * 100
--		else
--			line.pro = 1 / num * i * 100
--		end
--		line.visible = (100 - line.pro) > (100 - _pro)
--		line:setVisible(line.visible)
--		hp.lines[i] = line
--	end
	
	-- 名字
    local nameLabel = cc.Label:createWithTTF(info.name, UIUtils.ttfName, 20)
    nameLabel:setPosition(0, 240)
    nameLabel:enableOutline(cc.c4b(0,0,0,255), 2)
    hero.nameLabel = nameLabel
    hero:addChild(nameLabel, 6)
end

function NewHeroSoloPlayer.dtor()
	common_motion_tab = nil
end

return NewHeroSoloPlayer

--endregion
