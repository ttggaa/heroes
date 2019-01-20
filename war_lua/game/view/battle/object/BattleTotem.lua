--[[
    Filename:    BattleTotem.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-06-29 15:58:06
    Description: File description
--]]

local BC = BC
local pc = pc
local cc = _G.cc
local os = _G.os
local math = math
local pairs = pairs
local next = next
local tab = tab
local tonumber = tonumber
local tostring = tostring
local table = table
local mcMgr = mcMgr
local floor = math.floor
local ceil = math.ceil

local ETeamState = BC.ETeamState
local EMotion = BC.EMotion
local EDirect = BC.EDirect
local ECamp = BC.ECamp
local EState = BC.EState

local objLayer
local logic
-- 图腾
local BattleTotem = class("BattleTotem", require("game.view.battle.object.BattleObject"))

-- 类方法, 用于复制本地local
function BattleTotem.initialize()
    logic = BC.logic
    objLayer = BC.objLayer
end

local copyCaster = BC.copyCaster
local initSkillCaster = BC.initSkillCaster
local super = BattleTotem.super
local BC_reverse = BC.reverse
local MAX_SCENE_WIDTH_PIXEL = BC.MAX_SCENE_WIDTH_PIXEL

-- heroSkill为英雄法术
function BattleTotem:ctor(totemD, level, attacker, x, y, soldier, index, heroSkill, posIndex)
    super.ctor(self)
	self._posIndex = posIndex or 1
    self._totemD = totemD
    self.x, self.y = x, y
    self._soldier = soldier
    if soldier then
    	self._team = soldier.team
    end
    -- 类型 1. 跟随人  2. 跟随方阵  3. 地面不动
    self._objectplace = totemD["objectplace"]
    if self._soldier then
    	if self._objectplace == nil or self._objectplace <= 3 then
    		self._type = 1
    	else
    		self._type = 2
    	end
    else
    	self._type = 3
    end
    
    if totemD["objectscale"] then
        self._scale = totemD["objectscale"] * 0.01
    end
    if self._scale == nil then
    	self._scale = 1
    end

    -- 是否显示在最前层, 只有frontoat_v生效
    self._mostfront = totemD["most_front"]
    self._attacker = attacker
    self._level = level
    self._dir = self._attacker.direct
    local tick = BC.BATTLE_TOTEM_TICK

    local dur = totemD["last1"][1] + (level - 1) * totemD["last1"][2]

    self._endTick = tick + dur * 0.001
    local frontcd = 0
    if totemD["frontcd"] then
    	frontcd = totemD["frontcd"]
    end
    self._castTick = tick + frontcd * 0.001
    local interval = self._totemD["interval"]
    if interval then
    	self._castTickInv = interval * 0.001
    	-- 预计脉冲次数
    	self.castCount = ceil((dur - frontcd) / interval)
    else
    	self._castTick = nil
    end

    self.heroSkill = heroSkill

    if attacker.isCaster == nil then
    	self._caster = copyCaster(attacker)
    else
    	self._caster = attacker
    end
    self._caster.level = level

    self.die = false
    self.isTotem = true
    self.camp = self._caster.camp
    self.strength = totemD["strength"]
    self.skillIndex = index
    self.heroSkinD = nil
    if attacker.isCaster == true then
        --英雄皮肤
        if logic._heros and logic._heros[self.camp] then
            local skin = logic._heros[self.camp].skin
            if skin then
                self.heroSkinD = tab.heroSkin[skin]
            end
		end
	else
		--兵团皮肤
		if self._caster and self._caster.attacker and self._caster.attacker.team and self._caster.attacker.team.sId then
			self.heroSkinD = tab.teamSkin[self._caster.attacker.team.sId]
--            dump(self.heroSkinD)
		end
    end
    self.drag = totemD["objectrule"] or 0
    if self.drag == 1 then
    	self.speed = totemD["objectspeed"][1] + totemD["objectspeed"][2] * (level - 1)
    end
    self:start()
end

function BattleTotem:clear()
	super.clear(self)
end

-- 时间到,则返回false
local abs = math.abs
function BattleTotem:update(tick)
	local soldier = self._soldier
	local team = self._team
	local totemD = self._totemD

	if self.die then
		if not BATTLE_PROC then self:over() end
		return false
	end
	-- 坐标跟随挂载者
	local objectdisappear = totemD["objectdisappear"]
	local objectplace = totemD["objectplace"]
	local posDirty = false
	local followTeam = false
	if objectplace then
		if self._type == 1 and soldier then
			self.x, self.y = soldier.x, soldier.y
			-- 挂载者死亡移除
			if objectdisappear == 2 then
				if soldier.die then
					if not BATTLE_PROC then self:over() end
					return false
				end
			end
		elseif self._type == 2 and team then
			self.x, self.y = team.x, team.y
			posDirty = true
			followTeam = true
			if objectdisappear == 4 then
				if team.state == ETeamState.DIE then
					if not BATTLE_PROC then self:over() end
					return false
				end
			end
		end
	else
		if self.isMove then
			super.updateMove(self, tick)
		end
	end
	if not BC.jump then
		if self._showEff and posDirty then
			local x, y = self.x, self.y
			if followTeam then
				local _x, _y = self._showEffX, self._showEffY
				if abs(_x - x) > 1 then
					_x = _x + (x - _x) * 0.4
					x = _x
				end
				if abs(_y - y) > 1 then
					_y = _y + (y - _y) * 0.4
					y = _y
				end
				self._showEffX = x
				self._showEffY = y
			end
			local _x = BC_reverse and MAX_SCENE_WIDTH_PIXEL - x or x
			if self.eff1 then
				self.eff1:setPosition(_x, y)
				self.eff1:setLocalZOrder(-y)
			end
			if self.eff2 then
				self.eff2:setPosition(_x, y)
				if not self._mostfront then
					self.eff2:setLocalZOrder(-y)
				end
			end
			if self.eff3 then
				self.eff3:setPosition(_x, y)
			end
			if self.eff4 then
				self.eff4:setPosition(_x, y)
			end
		end
	end
	-- 释放者死亡移除
	if objectdisappear == 1 then
		if self._attacker.die then
			if not BATTLE_PROC then self:over() end
			return false
		end
	end
	if objectdisappear == 3 and self._attacker and self._attacker.team then
		if self._attacker.team.state == ETeamState.DIE and not self._attacker.team._hasInvokeRevive then
			if not BATTLE_PROC then self:over() end
			return false
		end
	end

	-- 时间到移除
	if tick > self._endTick + 0.00000001 then
		if not BATTLE_PROC then self:over() end
		return false
	end

	return true
end

function BattleTotem:updateTotem(tick)
	if self._castTick == nil then return end
	if tick > self._castTick + 0.00000001 then
		self._castTick = self._castTick + self._castTickInv
		-- 脉冲
		logic:totemCastSkill(self, self._totemD, self._level, self._caster, self.x, self.y, self.yunBuff)
		if self.yunBuff then
			self.yunBuff = false
		end
		return true
	end
end

--设置子物体死亡
function BattleTotem:setDie()
    self.die = true
end

--获取皮肤特效没有返回nil
function BattleTotem:getSkinEffectStr(name)
    local totemD = self._totemD
    local strName = name .. "2"
    if self.heroSkinD and self.heroSkinD.objectstk and totemD[strName] and totemD[strName][self.heroSkinD.objectstk] then
        local _name = totemD[strName][self.heroSkinD.objectstk][1]
        return _name
    end
    return nil
end

function BattleTotem:playEffect_totem2(name, soldier, pos, isfront, isstand, loop, scale, dir)
    local totemD = self._totemD
    if totemD[name] then
        local _name = self:getSkinEffectStr(name) or totemD[name]
        local effe = objLayer:playEffect_totem2(_name, soldier, pos, isfront, isstand, loop, scale, dir)
        return effe
    end
    return nil
end

function BattleTotem:playEffect_totem(name, x, y, isfront, isstand, loop, scale, dir)
    local totemD = self._totemD
    if totemD[name] then
        local _name = self:getSkinEffectStr(name) or totemD[name]
        local effe = objLayer:playEffect_totem(_name, x, y, isfront, isstand, loop, scale, dir)
        return effe
    end
    return nil
end

function BattleTotem:start()
	-- 光影开始
	if not BC.jump then
		local totemD = self._totemD
		local soldier = self._soldier
		local _scale = self._scale
		local _dir = self._dir
		if self._type == 1 then
			local loop = totemD["objectloop"]
			local pos = totemD["objectplace"]
			local showEff = false
           
            self.eff1 = self:playEffect_totem2("frontoat_h", soldier, pos, true, false, loop, _scale, _dir)
            self.eff2 = self:playEffect_totem2("frontoat_v", soldier, pos, true, true, loop, _scale, _dir)
            self.eff3 = self:playEffect_totem2("backoat_h", soldier, pos, false, false, loop, _scale, _dir)
            self.eff4 = self:playEffect_totem2("backoat_v", soldier, pos, false, true, loop, _scale, _dir)
            if self.eff1 or self.eff2 or self.eff3 or self.eff4 then
                showEff = true
            end
		else
			local x, y = self.x, self.y
			local loop = totemD["objectloop"]
			local showEff = false

            self.eff1 = self:playEffect_totem("frontoat_h", x, y, true, false, loop, _scale, _dir)
            self.eff2 = self:playEffect_totem("frontoat_v", x, y, true, true, loop, _scale, _dir)
            self.eff3 = self:playEffect_totem("backoat_h", x, y, false, false, loop, _scale, _dir)
            self.eff4 = self:playEffect_totem("backoat_v", x, y, false, true, loop, _scale, _dir)

            if self.eff1 or self.eff2 or self.eff3 or self.eff4 then
                showEff = true
            end
			self._showEff = showEff
			if showEff then
				self._showEffX = x
				self._showEffY = y 
			end
		end
		local quanpingstks = totemD["quanpingstk"]
        local camp = self.camp
        if camp and logic and logic.getHero then
            local heroSkinD, skin
            local heroData = logic:getHero(camp)
            if heroData then
                skin = heroData.skin
                heroSkinD = tab.heroSkin[skin]
                if heroSkinD and heroSkinD["quanpingstk_obj"] and totemD["quanpingstk" .. heroSkinD["quanpingstk_obj"]] then
                    quanpingstks = totemD["quanpingstk" .. heroSkinD["quanpingstk_obj"]]
                end
            end
        end
        
		if quanpingstks then
            self.eff5 = {}
			local eff5
			eff5 = self.eff5
			local quanpingstk
			for i = 1, #quanpingstks do
				quanpingstk = quanpingstks[i]
				eff5[#eff5 + 1] = objLayer:playEffect_totem3(quanpingstk[1], quanpingstk[3], quanpingstk[2])
			end	
		end
		if self.eff2 and self._mostfront then
			self.eff2:setLocalZOrder(0)
		end

        local spaceoat_v = totemD["spaceoat_v"]
        if spaceoat_v then
            for key, var in ipairs(spaceoat_v) do
                if var then
                    -- ScheduleMgr:delayCall(var[2] / 2, self, function()
                        if var[3] == 1 then
                        --全屏
                            local toteamEffect = objLayer:playEffect_totem3(var[1], 20, 0, true)
                            local tTotalFrames = toteamEffect:getTotalFrames()
                            --防止特效卡住修改
                            ScheduleMgr:delayCall(tTotalFrames * 24 * 1.2, self, function()
								if not tolua.isnull(toteamEffect) then
                                    toteamEffect:clearCallbacks()
                                    toteamEffect:stop()
                                    toteamEffect:removeFromParent()
                                end
                            end)
                        elseif var[3] == 2 then
                            --地面(现在的坐标只支持地表中心的)
                            local offectPos = {var[4] or 0, var[5] or 0}
                            objLayer:playEffect_totem4(var[1], BC.MAX_SCENE_WIDTH_PIXEL / 2 + offectPos[1], BC.MAX_SCENE_HEIGHT_PIXEL / 2 + offectPos[2], false, true, var[6])
                        end
                        
                    -- end)
                    
                end            
            end
        end

        local spaceoat_r = totemD["spaceoat_r"]
        if spaceoat_r then
            self.eff6 = {}
            local eff5
			eff5 = self.eff6 
            for key, var in ipairs(spaceoat_r) do
                if var then
                    -- ScheduleMgr:delayCall(var[2] / 2, self, function()
                        if var[3] == 1 then
                        --全屏
                            eff5[#eff5 + 1] = objLayer:playEffect_totem3(var[1], 20, 1)
                        elseif var[3] == 2 then
                            --地面(现在的坐标只支持地表中心的)
                            local offectPos = {var[4] or 0, var[5] or 0}--cc.p(-10, 180)--cc.p(var[4] or 0, var[5] or 0)
                            eff5[#eff5 + 1] = objLayer:playEffect_totem(var[1], BC.MAX_SCENE_WIDTH_PIXEL / 2 + offectPos[1], BC.MAX_SCENE_HEIGHT_PIXEL / 2 + offectPos[2], false, true, 1, var[6])
                        end
                        
                    -- end)
                    
                end            
            end
        end

        if totemD["afterEffect1"] then
			logic:addSwitchMap(totemD.id, totemD["afterEffect1"], self._posIndex)
			-- if BC.BATTLE_SPEED ~= 0 then
			-- 	self._HSSpeed = BC.BATTLE_SPEED
			-- 	logic:setBattleSpeed(0)
			-- end
			-- ScheduleMgr:delayCall(BC.frameInv * 10 * 1000 , self, function()
			-- 	if self and self._HSSpeed then
			-- 		logic:setBattleSpeed(self._HSSpeed)
            --         self._HSSpeed = nil
			-- 	end
			-- end)
        end
	end
end

function BattleTotem:LoopEffectSet(bIsPause)
    if not self.die and self.eff6 then
        if bIsPause then
            for key, var in ipairs(self.eff6) do
                if var and not tolua.isnull(var) then
                    var:stop(true)
                    var:setVisible(false)
                end
            end
        else
            for key, var in ipairs(self.eff6) do
                if var and not tolua.isnull(var) then
                    var:play(true)
                    var:setVisible(true)
                end
            end
        end
    end
end

function BattleTotem:endEffect()
	local totemD = self._totemD
	local spaceoat_h = totemD["spaceoat_h"]
	if spaceoat_h then
		for key, var in ipairs(spaceoat_h) do
			if var then
                
				-- ScheduleMgr:delayCall(var[2] / 2, self, function()
					if var[3] == 1 then
					--全屏
						local var = objLayer:playEffect_totem3(var[1], 20, 0)
					elseif var[3] == 2 then
						--地面(现在的坐标只支持地表中心的)
                        local offectPos = {var[4] or 0, var[5] or 0}
						objLayer:playEffect_totem4(var[1], BC.MAX_SCENE_WIDTH_PIXEL / 2 + offectPos[1], BC.MAX_SCENE_HEIGHT_PIXEL / 2 + offectPos[2], false, true, var[6])
					end
				-- end)
			end            
		end
	end
end

function BattleTotem:playEffect_totemDisappear2(name, soldier, pos, isfront, isstand, scale)
    local totemD = self._totemD
    if totemD[name] then
        local _name = self:getSkinEffectStr(name) or totemD[name]
        objLayer:playEffect_totemDisappear2(_name, soldier, pos, isfront, isstand, scale)
    end
end

function BattleTotem:playEffect_totemDisappear(name, x, y, isfront, isstand, scale, dir)
    local totemD = self._totemD
    if totemD[name] then
        local _name = self:getSkinEffectStr(name) or totemD[name]
        objLayer:playEffect_totemDisappear(_name, x, y, isfront, isstand, scale, dir)
    end
end

function BattleTotem:over()
	local totemD = self._totemD
	-- 光影消失
	if self.eff1 then
		objLayer:stopEffect(self.eff1)
	end
	if self.eff2 then
		objLayer:stopEffect(self.eff2)
	end
	if self.eff3 then
		objLayer:stopEffect(self.eff3)
	end
	if self.eff4 then
		objLayer:stopEffect(self.eff4)
	end
	local eff5 = self.eff5
	if eff5 then
		for i = 1, #eff5 do
			objLayer:stopEffect(eff5[i])
		end
	end
    self.eff5 = nil
    local eff6 = self.eff6
	if eff6 then
		for i = 1, #eff6 do
			objLayer:stopEffect(eff6[i])
		end
	end
    self.eff6 = nil
	local soldier = self._soldier
	local _scale = self._scale
	local _dir = self._dir
	if soldier then
		local pos = totemD["objectplace"]
        self:playEffect_totemDisappear2("frontdis_v", soldier, pos, true, true, _scale, _dir)
        self:playEffect_totemDisappear2("frontdis_h", soldier, pos, true, false, _scale, _dir)
        self:playEffect_totemDisappear2("backdis_v", soldier, pos, false, true, _scale, _dir)
        self:playEffect_totemDisappear2("backdis_h", soldier, pos, false, false, _scale, _dir)
	else
		local x, y = self.x, self.y
        self:playEffect_totemDisappear("frontdis_v", x, y, true, true, _scale, _dir)
        self:playEffect_totemDisappear("frontdis_h", x, y, true, false, _scale, _dir)
        self:playEffect_totemDisappear("backdis_v", x, y, false, true, _scale, _dir)
        self:playEffect_totemDisappear("backdis_h", x, y, false, false, _scale, _dir)
	end
    if not BC.jump then
        if totemD["afterEffect1"] then
            logic:delSwitchMap(totemD.id, self)
		end
		if ScheduleMgr then
			ScheduleMgr:cleanMyselfDelayCall(self)
		end
    end
end

function BattleTotem.dtor()
	
	BattleTotem = nil 
	BC = nil -- BC
	cc = nil -- _G.cc
	
	copyCaster = nil -- BC.copyCaster
	ECamp = nil -- BC.ECamp
	EDirect = nil -- BC.EDirect
	EMotion = nil -- BC.EMotion
	EState = nil -- BC.EState
	ETeamState = nil -- BC.ETeamState
	initSkillCaster = nil -- BC.initSkillCaster
	logic = nil
	math = nil -- math
	mcMgr = nil -- mcMgr
	next = nil -- next
	objLayer = nil
	os = nil -- _G.os
	pairs = nil -- pairs
	pc = nil -- pc
	tab = nil -- tab
	table = nil -- table
	tonumber = nil -- tonumber
	tostring = nil -- tostring
	super = nil
	abs = nil
	BC_reverse = nil
	MAX_SCENE_WIDTH_PIXEL = nil
	floor = nil
end

return BattleTotem
