--[[
    Filename:    CrossGuildNewPlayer.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2018-07-18 15:28:56
    Description: 跨服联盟4v4比赛播放
--]]

local CrossGuildNewPlayer = class("CrossGuildNewPlayer", BaseMvcs, function ()
        return  cc.Node:create() 
    end)

function CrossGuildNewPlayer:ctor()
    CrossGuildNewPlayer.super.ctor(self)
    self:registerScriptHandler(function (state)
            if state == "exit" then
                self:clear()
            end
        end)
    self._aHeros = {nil, nil,nil,nil}
    self._dHeros = {nil, nil,nil,nil}

    self._timeLabel = cc.Label:createWithTTF("0", UIUtils.ttfName, 20)
    self._timeLabel:setPosition(0, 400)
    self:addChild(self._timeLabel)
end

function CrossGuildNewPlayer:clear()
	ScheduleMgr:cleanMyselfDelayCall(self)
	if self._updateId then
        ScheduleMgr:unregSchedule(self._updateId)
        self._updateId = nil
    end
    for k,v in ipairs(self._aHeros) do
    	v.curMotionIndex = 1
    	v.ma = {}
    	if v then
    		v:removeFromParent()
    	end
    end
    for k,v in ipairs(self._dHeros) do
    	v.curMotionIndex = 1
    	v.ma = {}
    	if v then
    		v:removeFromParent()
    	end
    end

	self._aHeros = {nil,nil,nil,nil}
    self._dHeros = {nil,nil,nil,nil}

end

local common_motion_tab = {"stop", "run", "run2", "atk1", "atk2", "atk3", "die2", "hit1", "hit2", "suck", "win"}
local killData = {
        {num = 3, picName = "citybattle_view_img82"},
        {num = 4, picName = "citybattle_view_img83"},
        {num = 5, picName = "citybattle_view_img84"},
        {num = 10, picName = "citybattle_killTen_img"},
        {num = 20, picName = "citybattle_killTwenty_img"},
        {num = 30, picName = "citybattle_killThirty_img"},
        {num = 50, picName = "citybattle_killFifty_img"},
    }
-- 入场位置
local initLeftPos = { {- MAX_SCREEN_WIDTH * 0.5 - 300, 120},{- MAX_SCREEN_WIDTH * 0.5 - 200, 60},{- MAX_SCREEN_WIDTH * 0.5 - 300, -60},{- MAX_SCREEN_WIDTH * 0.5 - 200, -120}}
local initRightPos = { { MAX_SCREEN_WIDTH * 0.5 + 200, 120},{ MAX_SCREEN_WIDTH * 0.5 + 300, 60},{ MAX_SCREEN_WIDTH * 0.5 + 200, -60},{ MAX_SCREEN_WIDTH * 0.5 + 300, -120}}
-- 战斗位置
local lBattlePos = {{-250, 120},{-150, 60},{-250, -60},{-150, -120},}
local rBattlePos = {{200, 120}, {300, 60}, {200, -60}, {300, -150},}
function CrossGuildNewPlayer:init(data, overCallback)
	self:clear()
	self._data = data
	self._data.winCamp = 1
	self._overCallback = overCallback
	local maxLoadResCount = #data.info1 + #data.info2
	local resDone = 0
	for i,v in ipairs(data.info1) do
		self._aHeros[i] = cc.Node:create()
		self._aHeros[i].D = tab.hero[v.heroID]
		self._aHeros[i].ID = v.heroID
		self._aHeros[i]:setPosition(initLeftPos[i][1], initLeftPos[i][2])
		self._aHeros[i]:setLocalZOrder(i)
		self._aHeros[i].isWin = v.isWin
		self._aHeros[i].ckc = v.ckc or 0
		self:addChild(self._aHeros[i])
		HeroAnim.new(self._aHeros[i], self._aHeros[i].D["heroart"], common_motion_tab, function (mc)
            print("=====", v.heroID)
	        mc:play()
	        mc:setScaleX(0.3)
	        mc:setScaleY(0.3)
	        mc:changeMotion(self._aHeros[i].motion)
	        self._aHeros[i].mc = mc
	        resDone = resDone + 1
    		-- self:initMotionData(self._aHeros[i],1)
	    	self._aHeros[i]._motionFrames = self._aHeros[i].mc:getMotionFrame()
	    end)
	    self:createHUD(true,i)
	end

	for i,v in ipairs(data.info2) do
		self._dHeros[i] = cc.Node:create()
	    self._dHeros[i].D = tab.hero[v.heroID]
	    self._dHeros[i].ID = v.heroID
		self._dHeros[i]:setPosition(initRightPos[i][1], initRightPos[i][2])
		self._dHeros[i].isWin = v.isWin
		self._dHeros[i].ckc = v.ckc or 0
		self._dHeros[i]:setLocalZOrder(i)

		self:addChild(self._dHeros[i])
		
	    HeroAnim.new(self._dHeros[i], self._dHeros[i].D["heroart"], common_motion_tab, function (mc)
	    	mc:setScaleX(-0.3)
	    	mc:setScaleY(0.3)
	        mc:play()
	        mc:changeMotion(self._dHeros[i].motion)
	        self._dHeros[i].mc = mc
	        resDone = resDone + 1
    		-- self:initMotionData(self._dHeros[i],2)
    		self._dHeros[i]._motionFrames = self._dHeros[i].mc:getMotionFrame()
	    end) 
	    self:createHUD(false,i)
	end
	self:setMotion( 1 , "stop")
    self:setMotion( 2 , "stop")
    self._updateId = ScheduleMgr:regSchedule(0, self, function(self, dt)
        self:update()
    end)
    print(" resDone ",resDone)
    print(" maxLoadResCount ",maxLoadResCount)
    -- self:walkIn(1, function ()
    -- 	if resDone == maxLoadResCount then
    -- 		--开始动画
    -- 		self:startAni()
    -- 	end
    -- end)
	ScheduleMgr:delayCall(1000, self, function()
		self:startAni()
	end)
    
end

function CrossGuildNewPlayer:startAni()
	for i,v in ipairs(self._aHeros) do
		v:runAction(cc.Sequence:create(self:initMotionData(v,1,i)))
	end
	for i,v in ipairs(self._dHeros) do
		v:runAction(cc.Sequence:create(self:initMotionData(v,2,i)))
	end
	ScheduleMgr:delayCall(3000, self, function()
		self:over()
	end)
end

-- 初始化动作序列 
--@param hero 英雄
--@param tp 1 攻  2 守
function CrossGuildNewPlayer:initMotionData(hero,tp,i)
	-- 动作帧数
	local actionArray  = {}
	local dir = 1 
	if tp == 2 then
		dir = -1
	end
    --进场
    local m1 = cc.MoveBy:create(0.6,cc.p(450*dir,0))
    local m2  = cc.CallFunc:create(function ( ... )
		hero.mc:changeMotion("run")
	end)
    local mm  = cc.Spawn:create(m1,m2)
    table.insert(actionArray,mm)
    table.insert(actionArray,cc.DelayTime:create(0.6))
    table.insert(actionArray,cc.CallFunc:create(function ( ... )
		hero.mc:changeMotion("stop")
	end))

	if #self._aHeros == 0 or #self._dHeros == 0 then
		return actionArray
	end
	-------- 上场
	local move1 = cc.MoveBy:create(0.3,cc.p(250*dir,0))
	local run1  = cc.CallFunc:create(function ( ... )
		hero.mc:changeMotion("run")
	end)
	local sc  = cc.Spawn:create(move1,run1)
	table.insert(actionArray,sc)
	table.insert(actionArray,cc.DelayTime:create(0.3))
	table.insert(actionArray,cc.CallFunc:create(function ( ... )
		hero.mc:changeMotion("stop")
	end))

	-- 一方没有数据时 没有后续动画

	-- changeMotion(motion, tick, callback, noloop, inv, startFrame, returnNull)
	--------- 上场停顿0.2s
	table.insert(actionArray,cc.DelayTime:create(0.2))

	---------- 攻击
	local atk1 = cc.CallFunc:create(function ( ... )
		hero.mc:changeMotion("atk1",nil,nil,false)
	end)
	local atk2 = cc.DelayTime:create(1)
	table.insert(actionArray,atk1)
	table.insert(actionArray,atk2)

	------攻击后续 胜利--停一下或者连杀特效  失败 -- 击飞
	local atkAfter
	if hero.isWin then
		atkAfter = cc.CallFunc:create(function ( ... )
			hero.mc:changeMotion("win",nil,function ( ... )
				hero.mc:changeMotion("stop")
			end)
		end)
		
	else
		--死亡
		local temp1 = cc.CallFunc:create(function ( ... )
			hero.mc:changeMotion("die2")
		end)
		--击飞
		local temp2 = cc.MoveBy:create(1,cc.p(-1000*dir,800))
		atkAfter =  cc.Spawn:create(temp1,temp2)
	end
	table.insert(actionArray,atkAfter)
	if hero.isWin then
		table.insert(actionArray,cc.CallFunc:create(function ( ... )
			self:createWinAni(hero)
		end))
	else
		table.insert(actionArray,cc.CallFunc:create(function ( ... )
			local mcName = "zuoji_" .. hero.D["heroart"]
			local mc = mcMgr:createViewMC(mcName, false, true)
			mc:setScaleX(hero.mc:getScale()*2)
			mc:setScaleY(math.abs(hero.mc:getScale())*2)
			mc:setPosition(hero:getPositionX(), lBattlePos[i][2])
			self:addChild(mc, 0)
		end))
	end
	
	table.insert(actionArray,cc.DelayTime:create(0.5))
	return actionArray
end

function CrossGuildNewPlayer:createWinAni(hero)

	local num = hero.ckc 
	local img = nil
	for i,v in ipairs(killData) do
		if v.num == num then
			img = v.picName
			break
		end
	end
	if not img then
		return
	end
	local sp = cc.Sprite:createWithSpriteFrameName(img..".png")
	sp:setPosition(hero:getPositionX(),hero:getPositionY()+150)
	sp:setScale(0.5)
	self:addChild(sp,999)
	sp:runAction(cc.Sequence:create({   
		cc.Spawn:create(cc.ScaleTo:create(0.4,1),cc.FadeIn:create(0.4)),
		cc.CallFunc:create(function ( ... )
			local mc = mcMgr:createViewMC("jishaguangxiao_kuafulunci", false, true)
		    mc:gotoAndPlay(0)
		    mc:setPosition(sp:getContentSize().width/2,sp:getContentSize().height/2)
		    sp:addChild(mc,999)
		end),
		cc.DelayTime:create(0.5),
		cc.CallFunc:create(function ()
			sp:removeFromParent()
			sp = nil
		end)
	}))
end

--index 1 攻 2 守
function CrossGuildNewPlayer:setMotion(index, motion, speed, noloop, callback)
	local heros
	if index == 1 then
		heros = self._aHeros
	else
		heros = self._dHeros
	end

	for k,v in ipairs(heros) do
		print("setMotion ",index,k)
		local hero = v 
		hero.motion = motion
		if hero.mc then
			local inv = 0.05
			if speed then
				inv = 0.05 / speed
			end
			hero.mc:changeMotion(motion, nil, callback, noloop, inv)
		end
	end
	
end

function CrossGuildNewPlayer:setMotion1(hero,index, motion, speed, noloop, callback)
	hero.motion = motion
	if hero.mc then
		local inv = 0.05
		if speed then
			inv = 0.05 / speed
		end
		hero.mc:changeMotion(motion, nil, callback, noloop, inv)
	end
end



-- function CrossGuildNewPlayer:hpAnim(index, hp)
-- 	local hero = self._heros[index]

--     local dHP = 0
--     if hero.maxHP == "MISS" then
--         dHP = "MISS"
--     else
-- 	    local oldPro = math.floor(hero.HP / hero.maxHP * 100 * hero.HPPro)
-- 	    hero.HP = hero.HP - hp
-- 	    hero.destHP = math.floor(hero.HP / hero.maxHP * 100 * hero.HPPro)
-- 	    dHP = (oldPro - hero.destHP) * 100
--     end

-- 	-- 跳字
-- 	local HPLabel = cc.Label:createWithTTF(dHP, UIUtils.ttfName, 35)
--     HPLabel:setPosition(0, 220)
--     HPLabel:setColor(cc.c3b(255, 50, 50))
--     HPLabel:enableOutline(cc.c4b(0,0,0,255), 2)
--     hero:addChild(HPLabel, 10)

--     HPLabel:setScale(0)
--     HPLabel:runAction(cc.Sequence:create(
--     					cc.ScaleTo:create(0.05, 2),
--     					cc.ScaleTo:create(0.15, 1),
--     					cc.MoveBy:create(0.3, cc.p(0, 30)),
--     					cc.Spawn:create(cc.MoveBy:create(0.3, cc.p(0, 30)), cc.FadeOut:create(0.3))
--     				))
-- end

--@param dir 方向
--@param pos 位置
--@param x 移动x终点
--@param y 移动y终点
--@param time 时间
--@param callback 回调
function CrossGuildNewPlayer:moveTo(dir, pos , x, y, time, callback)
	local heros
	if dir == 1 then
		heros = self._aHeros
	else
	 	heros = self._dHeros
 	end 
	local hero = heros[pos]
	if hero then
		print("moveTo 123456",dir,pos)
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
end

function CrossGuildNewPlayer:update()
	-- local tick = socket.gettime()
	-- -- 计算移动
	-- for i = 1, 4 do
	-- 	local hero = self._aHeros[i]
	-- 	if hero then
	-- 		if hero._isMove then
	-- 			if tick >= hero._endMoveTick then
	-- 				hero._isMove = false
	-- 				hero:setPosition(hero._moveDstx, hero._moveDsty)
	-- 				if hero._moveCallback then
	-- 					hero._moveCallback()
	-- 				end
	-- 			else
	-- 				local rate = (tick - hero._beginMoveTick) / (hero._moveTick)
	-- 				hero:setPosition(hero._moveScrx + hero._moveDeltax * rate, hero._moveScry + hero._moveDeltay * rate)
	-- 			end
	-- 		end
	-- 	end
	-- 	local dhero = self._dHeros[i]
	-- 	if dhero then
	-- 		if dhero._isMove then
	-- 			if tick >= dhero._endMoveTick then
	-- 				dhero._isMove = false
	-- 				dhero:setPosition(dhero._moveDstx, dhero._moveDsty)
	-- 				if dhero._moveCallback then
	-- 					dhero._moveCallback()
	-- 				end
	-- 			else
	-- 				local rate = (tick - dhero._beginMoveTick) / (dhero._moveTick)
	-- 				dhero:setPosition(dhero._moveScrx + dhero._moveDeltax * rate, dhero._moveScry + dhero._moveDeltay * rate)
	-- 			end
	-- 		end
	-- 	end
	-- end
end

-- 进场
function CrossGuildNewPlayer:walkIn(time, callback)
	for i,v in ipairs(self._aHeros) do
		print("move1111")
		self:moveTo(1,i, lBattlePos[i][1], lBattlePos[i][2], time)
	end
	ScheduleMgr:delayCall(1, self, function()
		self:setMotion(1, "run")
		self:setMotion(2, "run")
	end)
	
	for i,v in ipairs(self._dHeros) do
		self:moveTo(2 , i, rBattlePos[i][1], rBattlePos[i][2], time, function ()
			self:setMotion(1, "stop")
			self:setMotion(2, "stop")
			if callback then callback() end
		end)
	end
end

-- 退场
function CrossGuildNewPlayer:walkLeave(indexId, callback)
    local time = 1
    self:setMotion(1, "run")
    self:setMotion(2, "run")
    for i,v in ipairs(self._aHeros) do
    	print("atk atk")
    	if v.isWin then
    		v.mc:setScaleX(v.mc:getScale() * -1)
    		v:runAction(cc.MoveTo:create(1,cc.p(initLeftPos[i][1], initLeftPos[i][2])))
		end
	end

	for i,v in ipairs(self._dHeros) do
		print("def def")
		if v.isWin then
			v.mc:setScaleX(v.mc:getScale() * -1)
			v:runAction(cc.MoveTo:create(1,cc.p(initRightPos[i][1], initRightPos[i][2])))
		end
	end
	ScheduleMgr:delayCall(1000, self, function()
		if callback then
			callback()
		end
	end)
end

function CrossGuildNewPlayer:over()
	-- for i=1,4 do
	-- 	local hero = self._aHeros[i]
	-- 	if hero then
	-- 		if hero.isWin then
	-- 			hero = self._dHeros[i]
	-- 		end
	-- 		if hero then
	-- 			local mcName = "zuoji_" .. hero.D["heroart"]
	-- 			local mc = mcMgr:createViewMC(mcName, false, true)
	-- 			mc:setScaleX(hero.mc:getScale()*2)
	-- 			mc:setScaleY(math.abs(hero.mc:getScale())*2)
	-- 			mc:setPosition(hero:getPositionX(), lBattlePos[i][2])
	-- 			self:addChild(mc, 0)
	-- 		end
	-- 	end
	-- end
	if self._overCallback then 
		self._overCallback()
	end

end

function CrossGuildNewPlayer:createHUD(isAtk,index)
	local hero 
	local info
	if isAtk then
		hero = self._aHeros[index]
		info = self._data["info1"][index]
	else
		hero = self._dHeros[index]
		info = self._data["info2"][index]
	end
	
	local guildImg
	if info.flag ~= 0 then
	    guildImg = ccui.ImageView:create()
	    guildImg:setAnchorPoint(cc.p(0,0.5))
	    guildImg:setPosition(-100, 130)
	    guildImg:setScale(0.3)
	    guildImg:loadTexture("flag".. info.flag ..".png",1)
	    hero:addChild(guildImg, 6)
	end

	-- 名字
	local x = -100
	if guildImg then
		x = x + guildImg:getContentSize().width * 0.3 + 10
	end
    local nameLabel = cc.Label:createWithTTF(info.name, UIUtils.ttfName, 20)
    nameLabel:setPosition(x, 130)
    nameLabel:setAnchorPoint(cc.p(0,0.5))
    nameLabel:enableOutline(cc.c4b(0,0,0,255), 2)
    hero:addChild(nameLabel, 6)

end

function CrossGuildNewPlayer.dtor()
	common_motion_tab = nil
	killData = nil
end

return CrossGuildNewPlayer