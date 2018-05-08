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
function BattleTotem:ctor(totemD, level, attacker, x, y, soldier, index, heroSkill)
    super.ctor(self)

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
		if self._attacker.team.state == ETeamState.DIE then
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
			if totemD["frontoat_h"] then
				self.eff1 = objLayer:playEffect_totem2(totemD["frontoat_h"], soldier, pos, true, false, loop, _scale, _dir)
				showEff = true
			end
			if totemD["frontoat_v"] then
				self.eff2 = objLayer:playEffect_totem2(totemD["frontoat_v"], soldier, pos, true, true, loop, _scale, _dir)
				showEff = true
			end
			if totemD["backoat_h"] then
				self.eff3 = objLayer:playEffect_totem2(totemD["backoat_h"], soldier, pos, false, false, loop, _scale, _dir)
				showEff = true
			end
			if totemD["backoat_v"] then
				self.eff4 = objLayer:playEffect_totem2(totemD["backoat_v"], soldier, pos, false, true, loop, _scale, _dir)
				showEff = true
			end
		else
			local x, y = self.x, self.y
			local loop = totemD["objectloop"]
			local showEff = false
			if totemD["frontoat_h"] then
				self.eff1 = objLayer:playEffect_totem(totemD["frontoat_h"], x, y, true, false, loop, _scale, _dir)
				showEff = true
			end
			if totemD["frontoat_v"] then
				self.eff2 = objLayer:playEffect_totem(totemD["frontoat_v"], x, y, true, true, loop, _scale, _dir)
				showEff = true
			end
			if totemD["backoat_h"] then
				self.eff3 = objLayer:playEffect_totem(totemD["backoat_h"], x, y, false, false, loop, _scale, _dir)
				showEff = true
			end
			if totemD["backoat_v"] then
				self.eff4 = objLayer:playEffect_totem(totemD["backoat_v"], x, y, false, true, loop, _scale, _dir)
				showEff = true
			end
			self._showEff = showEff
			if showEff then
				self._showEffX = x
				self._showEffY = y 
			end
		end
		local quanpingstks = totemD["quanpingstk"]
		if quanpingstks then
			local eff5
			self.eff5 = {}
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
	local soldier = self._soldier
	local _scale = self._scale
	local _dir = self._dir
	if soldier then
		local pos = totemD["objectplace"]
		if totemD["frontdis_v"] then
			objLayer:playEffect_totemDisappear2(totemD["frontdis_v"], soldier, pos, true, true, _scale, _dir)
		end
		if totemD["frontdis_h"] then
			objLayer:playEffect_totemDisappear2(totemD["frontdis_h"], soldier, pos, true, false, _scale, _dir)
		end
		if totemD["backdis_v"] then
			objLayer:playEffect_totemDisappear2(totemD["backdis_v"], soldier, pos, false, true, _scale, _dir)
		end
		if totemD["backdis_h"] then
			objLayer:playEffect_totemDisappear2(totemD["backdis_h"], soldier, pos, false, false, _scale, _dir)
		end
	else
		local x, y = self.x, self.y
		if totemD["frontdis_v"] then
			objLayer:playEffect_totemDisappear(totemD["frontdis_v"], x, y, true, true, _scale, _dir)
		end
		if totemD["frontdis_h"] then
			objLayer:playEffect_totemDisappear(totemD["frontdis_h"], x, y, true, false, _scale, _dir)
		end
		if totemD["backdis_v"] then
			objLayer:playEffect_totemDisappear(totemD["backdis_v"], x, y, false, true, _scale, _dir)
		end
		if totemD["backdis_h"] then
			objLayer:playEffect_totemDisappear(totemD["backdis_h"], x, y, false, false, _scale, _dir)
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