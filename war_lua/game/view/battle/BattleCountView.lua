--[[
    Filename:    BattleCountView.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2017-03-28 17:53:37
    Description: File description
--]]

local floor = math.floor
local BattleCountView = class("BattleCountView", BaseView)

function BattleCountView:ctor(data)
    BattleCountView.super.ctor(self)

    self._reverse = data.reverse

    self._data = {{}, {}}
    self._spellData = {{}, {}}
    local leftData, rightData
	leftData = clone(data.leftData)
	rightData = clone(data.rightData)
	local d, skills, skill, DEx, damageSkill, skillPassiveD
	local _type, skillid, skillid2, skillPassive, compose
	local datas = {leftData, rightData}
	local alltime = data.time
	local _data
    local spellTempData = {{},{}}
	for k = 1, 2 do
        local spellData = datas[k][0]
        for kName, nValue in pairs(spellData) do
            for kId, dValue in pairs(nValue) do
                if spellTempData[k][kId] == nil then
                    spellTempData[k][kId] = {}
                end
                spellTempData[k][kId][kName] = floor(math.abs(dValue))
            end
        end
		for i = 1, #datas[k] do
			d = datas[k][i]
            d.realDamage = (d.realDamage == nil or d.damage == -1) and -1 or d.realDamage -- damage为-1，则不显示(真实)伤害值
            d.realHurt = (d.realHurt == nil or d.hurt == -1) and -1 or d.realHurt -- hurt为-1，则不显示(真实)承受伤害值
			DEx = d.DEx
			_data = 
			{
				ID = DEx["id"],
				die = d.die == -1 and alltime or d.die,
                realDamage = floor(d.realDamage > d.damage and d.damage or d.realDamage),
				damage = floor(d.damage),
                boss = d.boss,
				heal = floor(d.heal),
                realHurt = floor(d.realHurt),
				hurt = floor(d.realHurt > d.hurt and d.realHurt or d.hurt),
				art1 = TeamUtils.getNpcTableValueByTeam(DEx, "art1"),
				name = DEx["name"],
				skills = d.skills,
                skillLevels = d.skillLevels,
				teamData = ((d.DType == 2) and d.D or d.teamData) or d.D or d.DEx,
				copy = d.copy,
                jx = d.jx or (d.D and d.D.jx),
                isMercenary = d.isMercenary,
                lzyscore = d.lzyscore,
                lzystar = d.lzystar,
                lzylvdis = d.lzylvdis,
                lzyquality = d.lzyquality,
			}
			-- dump(d.skills)
			if d.summonTick then
				_data.die = _data.die - d.summonTick
			end
			self._data[k][i] = _data
			skills = clone(TeamUtils.getNpcTableValueByTeam(DEx, "skill"))
			local cs = TeamUtils.getNpcTableValueByTeam(DEx, "cs")
			if cs then
				skills[#skills + 1] = cs
			end
			skill = {}
			if skills then
				damageSkill = d.damageSkill
				-- 把伤害中的图腾伤害加到技能伤害中
				-- dump(damageSkill)
				pcall(function ()

					local skillFunc = function ( ... )
						for m = 1, #skills do
							_type = skills[m][1]
							skillid = skills[m][2]
							local oid
							if _type == 1 then
								if tab.skill[skillid] then
									oid = tab.skill[skillid]["objectid"]
									if oid and damageSkill[oid] then
										if damageSkill[skillid] then
											damageSkill[skillid] = damageSkill[skillid] + damageSkill[oid]
											damageSkill[oid] = nil
										else
											damageSkill[skillid] = damageSkill[oid]
											damageSkill[oid] = nil
										end
									end
									oid = tab.skill[skillid]["objectid1"]
                                    if oid and damageSkill[oid] then
                                        if damageSkill[skillid] then
                                            damageSkill[skillid] = damageSkill[skillid] + damageSkill[oid]
                                            damageSkill[oid] = nil
                                        else
                                            damageSkill[skillid] = damageSkill[oid]
                                            damageSkill[oid] = nil
                                        end
                                    end

                                    -- 前提必须是有子物体存在  delete by hxp
                                    -- local obj = tab.skill[skillid]["objectid"]
									-- oid = tab.skill[skillid]["buffid1"]
									-- if oid and damageSkill[oid]  then
									-- 	if damageSkill[skillid] then
									-- 		damageSkill[skillid] = damageSkill[skillid] + damageSkill[oid]
									-- 		damageSkill[oid] = nil
									-- 	else
									-- 		damageSkill[skillid] = damageSkill[oid]
									-- 		damageSkill[oid] = nil
									-- 	end
									-- end
									-- obj = tab.skill[skillid]["objectid2"]
									-- oid = tab.skill[skillid]["buffid2"]
									-- if oid and damageSkill[oid]  then
									-- 	if damageSkill[skillid] then
									-- 		damageSkill[skillid] = damageSkill[skillid] + damageSkill[oid]
									-- 		damageSkill[oid] = nil
									-- 	else
									-- 		damageSkill[skillid] = damageSkill[oid]
									-- 		damageSkill[oid] = nil
									-- 	end
									-- end

									-- -- add by hxp
									local obj = tab.skill[skillid]["objectid"]
									local buffId = tab.skill[skillid]["buffid1"]
									-- 子物体用了buff，统计的时候用了buffId
									if obj  then
										local oid = tab.object[obj]["buffid1"]
										if oid and damageSkill[oid] then
											if damageSkill[skillid] then
												damageSkill[skillid] = damageSkill[skillid] + damageSkill[oid]
												damageSkill[oid] = nil
											else
												damageSkill[skillid] = damageSkill[oid]
												damageSkill[oid] = nil
											end
										end
									end 

									obj = tab.skill[skillid]["objectid1"]
									buffId = tab.skill[skillid]["buffid2"]
									-- 子物体用了buff，统计的时候用了buffId
									if obj  then
										for k,v in pairs(obj) do
											local objId = v[3]
											local oid = tab.object[objId]["buffid2"]
											if oid and damageSkill[oid] then
												if damageSkill[skillid] then
													damageSkill[skillid] = damageSkill[skillid] + damageSkill[oid]
													damageSkill[oid] = nil
												else
													damageSkill[skillid] = damageSkill[oid]
													damageSkill[oid] = nil
												end
											end
										end
										
									end 

								end
							elseif _type == 2 then
								skillPassiveD = tab.skillPassive[skillid]
								compose = skillPassiveD["compose"]
								if compose then
									for n = 1, #compose do
										if compose[n][1] == 1 then
											skillid2 = compose[n][2]
											if tab.skill[skillid2] then
												oid = tab.skill[skillid2]["objectid"]
												if oid and damageSkill[oid] then
													if damageSkill[skillid2] then
														damageSkill[skillid2] = damageSkill[skillid2] + damageSkill[oid]
														damageSkill[oid] = nil
													else
														damageSkill[skillid2] = damageSkill[oid]
														damageSkill[oid] = nil
													end
												end
												oid = tab.skill[skillid2]["objectid1"]
												if oid and damageSkill[oid] then
													if damageSkill[skillid2] then
														damageSkill[skillid2] = damageSkill[skillid2] + damageSkill[oid]
														damageSkill[oid] = nil
													else
														damageSkill[skillid2] = damageSkill[oid]
														damageSkill[oid] = nil
													end
												end

											    -- 前提必须是有子物体存在  delete by hxp
                                     			-- local obj = tab.skill[skillid2]["objectid"]
												-- oid = tab.skill[skillid2]["buffid1"]
												-- if oid and damageSkill[oid]  then
												-- 	if damageSkill[skillid2] then
												-- 		damageSkill[skillid2] = damageSkill[skillid2] + damageSkill[oid]
												-- 		damageSkill[oid] = nil
												-- 	else
												-- 		damageSkill[skillid2] = damageSkill[oid]
												-- 		damageSkill[oid] = nil
												-- 	end
												-- end
												-- obj = tab.skill[skillid2]["objectid1"]
												-- oid = tab.skill[skillid2]["buffid2"]
												-- if oid and damageSkill[oid] then
												-- 	if damageSkill[skillid2] then
												-- 		damageSkill[skillid2] = damageSkill[skillid2] + damageSkill[oid]
												-- 		damageSkill[oid] = nil
												-- 	else
												-- 		damageSkill[skillid2] = damageSkill[oid]
												-- 		damageSkill[oid] = nil
												-- 	end
												-- end

												-- -- add by hxp
												local obj = tab.skill[skillid2]["objectid"]
												-- 子物体用了buff，统计的时候用了buffId
												if obj then
													local oid = tab.object[obj]["buffid1"]
													if oid and damageSkill[oid] then
														if damageSkill[skillid2] then
															damageSkill[skillid2] = damageSkill[skillid2] + damageSkill[oid]
															damageSkill[oid] = nil
														else
															damageSkill[skillid2] = damageSkill[oid]
															damageSkill[oid] = nil
														end
													end
												end 

												obj = tab.skill[skillid2]["objectid1"]
												-- 子物体用了buff，统计的时候用了buffId
												if obj then
													for k,v in pairs(obj) do
														local objId = v[3]
														local oid = tab.object[objId]["buffid2"]
														if oid and damageSkill[oid] then
															if damageSkill[skillid2] then
																damageSkill[skillid2] = damageSkill[skillid2] + damageSkill[oid]
																damageSkill[oid] = nil
															else
																damageSkill[skillid2] = damageSkill[oid]
																damageSkill[oid] = nil
															end
														end
													end
												end 

											end
										end
									end
								end
							end
						end
					end
					skillFunc()
					if d.jx then
						-- 觉醒技能替换，把改变的技能伤害算到原始技能里面
						local changeMap = {}
						local jxskill = DEx["talentTree1"]
						skills[#skills + 1] = jxskill[2]
						changeMap[jxskill[2][2]] = DEx["skill"][jxskill[1]][2]
						skills[#skills + 1] = jxskill[3]
						changeMap[jxskill[3][2]] = DEx["skill"][jxskill[1]][2]
						jxskill = DEx["talentTree2"]
						skills[#skills + 1] = jxskill[2]
						changeMap[jxskill[2][2]] = DEx["skill"][jxskill[1]][2]
						skills[#skills + 1] = jxskill[3]
						changeMap[jxskill[3][2]] = DEx["skill"][jxskill[1]][2]
						jxskill = DEx["talentTree3"]
						skills[#skills + 1] = jxskill[2]
						changeMap[jxskill[2][2]] = DEx["skill"][jxskill[1]][2]
						skills[#skills + 1] = jxskill[3]
						changeMap[jxskill[3][2]] = DEx["skill"][jxskill[1]][2]
						-- dump(changeMap)
						-- 这里面还有组合技能，再拆
						local skillPassiveD, compose, skillid2
						for newid, oldid in pairs(changeMap) do
							local skillPassiveD = tab.skillPassive[newid]
							if skillPassiveD then
								compose = skillPassiveD["compose"]
								if compose then
									for n = 1, #compose do
										if compose[n][1] == 1 then
											skillid2 = compose[n][2]
											changeMap[skillid2] = oldid
										end
									end
								end
							end
						end
						-- dump(changeMap)

						for newid, oldid in pairs(changeMap) do
							if damageSkill[newid] then
								damageSkill[oldid] = damageSkill[newid]
								damageSkill[newid] = nil
								if _data.skills[newid] then
									_data.skills[oldid] = _data.skills[newid]
								end
							end
						end
						skillFunc()
					end
					-- dump(damageSkill)

				end)
				-- dump(skills)
				for m = 1, #skills do
					if #skill >= 2 then break end
					_type = skills[m][1]
					skillid = skills[m][2]
					if _type == 1 then
						-- 主动技能
						if damageSkill[skillid] then
							if tab.skill[skillid]["kind"] ~= 8 then
								skill[#skill + 1] = {skillid, damageSkill[skillid]}
							end
						end
					elseif _type == 2 then
						-- 组合技能，需要拆开再看
						local damage = damageSkill[skillid] or 0
						local has = damage > 0
						skillPassiveD = tab.skillPassive[skillid]
						compose = skillPassiveD["compose"]
						if compose then
							for n = 1, #compose do
								if compose[n][1] == 1 then
									skillid2 = compose[n][2]
									if damageSkill[skillid2] then
										has = true
										if tab.skill[skillid2]["kind"] == 8 then
											if damage == 0 then
												has = false
											end
										else
											damage = damage + damageSkill[skillid2]
										end
									end
								end
							end
						end
						if has then
							skill[#skill + 1] = {skillid, damage}
						end
					end
				end
			end
			self._data[k][i].skill = skill
		end
	end

	local count1 = #self._data[1]
	local count2 = #self._data[2]
	self._allCount = count1 > count2 and count1 or count2
	self._count1 = count1
	self._count2 = count2

    for i = 1, 2 do
        for k, v in pairs(spellTempData[i]) do
            v.id = k
            v.damage = v.damage or 0
            v.realDamage = v.realDamage or 0
            v.realDamage = v.realDamage > v.damage and v.damage or v.realDamage
            v.heal = v.heal or 0
            v.hurt = v.hurt or 0
            v.realHurt = v.realHurt or 0

            if v.damage ~= 0 or v.realDamage ~= 0 or v.heal ~= 0 then
                table.insert(self._spellData[i], v)
            end
        end
    end

    local spellCount1 = #self._spellData[1]
    local spellCount2 = #self._spellData[2]
    self._spellCount = spellCount1 > spellCount2 and spellCount1 or spellCount2
    self._spellCount1 = spellCount1
    self._spellCount2 = spellCount2

    self._curTab = nil
    self._isShowReal = false
    self._isShowSpell = false
end

function BattleCountView:onDestroy()
    self._viewMgr:disableScreenWidthBar()

	for i = 1, #self._cellViews[1] do
		self._cellViews[1][i]:release()
	end
	for i = 1, #self._cellViews[2] do
		self._cellViews[2][i]:release()
	end
    for i = 1, #self._spellCellViews[1] do
		self._spellCellViews[1][i]:release()
	end
	for i = 1, #self._spellCellViews[2] do
		self._spellCellViews[2][i]:release()
	end
	BattleCountView.super.onDestroy(self)
end

function BattleCountView:getAsyncRes()
    return 
    {

    }
end

function BattleCountView:getBgName()
    return "bg_011.jpg"
end

function BattleCountView:onInit()
    self._maxScreenWidth = ADOPT_IPHONEX and 1266 or MAX_SCREEN_WIDTH

	local closeBtn = self:getUI("bg.panel.bar2.closeBtn")
	self:registerClickEvent(closeBtn, function() 
        self:close() 
        UIUtils:reloadLuaFile("battle.BattleCountView")
    end)

	self._panel = self:getUI("bg.panel")
	self._bar = self:getUI("bg.panel.bar")
	self._bar2 = self:getUI("bg.panel.bar2")

	self._title1 = self:getUI("bg.panel.bar.title1")
	self._title2 = self:getUI("bg.panel.bar.title2")
	self._title3 = self:getUI("bg.panel.bar.title3")

	self._filterBtn1 = self:getUI("bg.panel.bar.filterBtn1")
	self._filterBtn2 = self:getUI("bg.panel.bar.filterBtn2")
	self._filterBtn3 = self:getUI("bg.panel.bar.filterBtn3")
	self:registerClickEvent(self._filterBtn1, function() if self:onFilter(1) then self:onUpdate() end end)
	self:registerClickEvent(self._filterBtn2, function() if self:onFilter(2) then self:onUpdate() end end)
	self:registerClickEvent(self._filterBtn3, function() if self:onFilter(3) then self:onUpdate() end end)

	self._page1 = self:getUI("bg.panel.bar2.page1")
	self._page2 = self:getUI("bg.panel.bar2.page2")
	self:registerClickEvent(self._page1, function() if self:onPage(1) then self:onUpdate() end end)
	self:registerClickEvent(self._page2, function() if self:onPage(2) then self:onUpdate() end end)

	local bgScale = self.__viewBg:getScale()
	self._bar:setPosition((self._maxScreenWidth - 960) * 0.5, MAX_SCREEN_HEIGHT - 78 * bgScale)
	self._bar2:setPosition((self._maxScreenWidth - 960) * 0.5, 0)

	local btn
	for i = 1, 3 do
		btn = self["_filterBtn"..i]
		btn:setTitleFontSize(18)
		btn:enableOutline(cc.c4b(0,0,0,255), 1)
	end
	for i = 1, 2 do
		btn = self["_page"..i]
	end

    self._teamBtn = self:getUI("bg.panel.bar.teamBtn")
    self._spellBtn = self:getUI("bg.panel.bar.spellBtn")

    local teamBtnLabel = self._teamBtn:getTitleRenderer()
    teamBtnLabel:setColor(cc.c3b(148,106,81))
    self._teamBtn:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self:registerClickEvent(self._teamBtn, function(sender) if self:onTab(1) then self:onUpdate() end end)

    local spellBtnLabel = self._spellBtn:getTitleRenderer()
    spellBtnLabel:setColor(cc.c3b(148,106,81))
    self._spellBtn:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self:registerClickEvent(self._spellBtn, function(sender) if self:onTab(2) then self:onUpdate() end end)

    self._tabBtns = {self._teamBtn, self._spellBtn}


    self._realBox = self:getUI("bg.panel.bar2.realBox")
    self._realBox:addEventListener(function (sender, state)
        self:updateToReal(state == 0)
    end)
    self._boxLabel = self:getUI("bg.panel.bar2.boxLabel")
    self._boxLabel:setColor(cc.c3b(244,187,98))
    self._boxLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

	-- 创建内容
	local maxDamage = 0
	local maxHeal = 0
	local maxHurt = 0
    local maxRealDamage = 0
    local maxRealHurt = 0
	local data1s = self._data[1]
	local data2s = self._data[2]
	for i = 1, self._count1 do
		maxDamage = maxDamage + data1s[i].damage
        maxRealDamage = maxRealDamage + data1s[i].realDamage
		maxHeal = maxHeal + data1s[i].heal
		maxHurt = maxHurt + data1s[i].hurt
        maxRealHurt = maxRealHurt + data1s[i].realHurt
	end
	if maxDamage == 0 then maxDamage = 1 end
	if maxHeal == 0 then maxHeal = 1 end
	if maxHurt == 0 then maxHurt = 1 end
	if maxRealDamage == 0 then maxRealDamage = 1 end
	if maxRealHurt == 0 then maxRealHurt = 1 end
	for i = 1, self._count1 do
		data1s[i].damagePro = tonumber(string.format("%.1f", data1s[i].damage / maxDamage * 100))
		data1s[i].healPro = tonumber(string.format("%.1f", data1s[i].heal / maxHeal * 100))
		data1s[i].hurtPro = tonumber(string.format("%.1f", data1s[i].hurt / maxHurt * 100))
		data1s[i].realDamagePro = tonumber(string.format("%.1f", data1s[i].realDamage / maxRealDamage * 100))
		data1s[i].realHurtPro = tonumber(string.format("%.1f", data1s[i].realHurt / maxRealHurt * 100))
	end
	maxDamage = 0
	maxHeal = 0
	maxHurt = 0
    maxRealDamage = 0
    maxRealHurt = 0
	for i = 1, self._count2 do
		maxDamage = maxDamage + data2s[i].damage
        maxRealDamage = maxRealDamage + data2s[i].realDamage
		maxHeal = maxHeal + data2s[i].heal
		maxHurt = maxHurt + data2s[i].hurt
        maxRealHurt = maxRealHurt + data2s[i].realHurt
	end
	if maxDamage == 0 then maxDamage = 1 end
	if maxHeal == 0 then maxHeal = 1 end
	if maxHurt == 0 then maxHurt = 1 end
    if maxRealDamage == 0 then maxRealDamage = 1 end
	if maxRealHurt == 0 then maxRealHurt = 1 end
	for i = 1, self._count2 do
		data2s[i].damagePro = tonumber(string.format("%.1f", data2s[i].damage / maxDamage * 100))
		data2s[i].healPro = tonumber(string.format("%.1f", data2s[i].heal / maxHeal * 100))
		data2s[i].hurtPro = tonumber(string.format("%.1f", data2s[i].hurt / maxHurt * 100))
        data2s[i].realDamagePro = tonumber(string.format("%.1f", data2s[i].realDamage / maxRealDamage * 100))
		data2s[i].realHurtPro = tonumber(string.format("%.1f", data2s[i].realHurt / maxRealHurt * 100))
	end

	maxDamage = 0
	maxHeal = 0
    maxRealDamage = 0
    local spellDatas1 = self._spellData[1]
    local spellDatas2 = self._spellData[2]
    for i = 1, self._spellCount1 do
        maxDamage = maxDamage + spellDatas1[i].damage
        maxHeal = maxHeal + spellDatas1[i].heal or 0
        maxRealDamage = maxRealDamage + spellDatas1[i].realDamage
    end
    if maxDamage == 0 then maxDamage = 1 end
	if maxHeal == 0 then maxHeal = 1 end
    if maxRealDamage == 0 then maxRealDamage = 1 end
    for i = 1, self._spellCount1 do
        spellDatas1[i].damagePro = tonumber(string.format("%.1f", spellDatas1[i].damage / maxDamage * 100))
		spellDatas1[i].healPro = tonumber(string.format("%.1f", spellDatas1[i].heal / maxHeal * 100))
        spellDatas1[i].realDamagePro = tonumber(string.format("%.1f", spellDatas1[i].realDamage / maxRealDamage * 100))
    end

    maxDamage = 0
	maxHeal = 0
    maxRealDamage = 0
    for i = 1, self._spellCount2 do
        maxDamage = maxDamage + spellDatas2[i].damage
        maxHeal = maxHeal + spellDatas2[i].heal
        maxRealDamage = maxRealDamage + spellDatas2[i].realDamage
    end
    if maxDamage == 0 then maxDamage = 1 end
	if maxHeal == 0 then maxHeal = 1 end
    if maxRealDamage == 0 then maxRealDamage = 1 end
    for i = 1, self._spellCount2 do
        spellDatas2[i].damagePro = tonumber(string.format("%.1f", spellDatas2[i].damage / maxDamage * 100))
		spellDatas2[i].healPro = tonumber(string.format("%.1f", spellDatas2[i].heal / maxHeal * 100))
        spellDatas2[i].realDamagePro = tonumber(string.format("%.1f", spellDatas2[i].realDamage / maxRealDamage * 100))
    end
--	local maxDamagePro = 0.1
--	local maxHealPro = 0.1
--	local maxHurtPro = 0.1
--	for i = 1, self._count1 do
--		if data1s[i].damagePro > maxDamagePro then
--			maxDamagePro = data1s[i].damagePro
--		end
--		if data1s[i].healPro > maxHealPro then
--			maxHealPro = data1s[i].healPro
--		end
--		if data1s[i].hurtPro > maxHurtPro then
--			maxHurtPro = data1s[i].hurtPro
--		end
--	end
--	for i = 1, self._count2 do
--		if data2s[i].damagePro > maxDamagePro then
--			maxDamagePro = data2s[i].damagePro
--		end
--		if data2s[i].healPro > maxHealPro then
--			maxHealPro = data2s[i].healPro
--		end
--		if data2s[i].hurtPro > maxHurtPro then
--			maxHurtPro = data2s[i].hurtPro
--		end
--	end

	local red = cc.c3b(254, 24, 24)
	local blue = cc.c3b(64, 239, 244)
	local gray = cc.c3b(204, 206, 209)
	local yellow = cc.c3b(255, 238, 160)
	local black = cc.c4b(0, 0, 0, 255)
	local mainCamp = self._reverse and 2 or 1
	local teamModel = self._modelMgr:getModel("TeamModel")
	local function fillCell(cell, data, camp)
		cell:setCascadeOpacityEnabled(true)
		-- 头像
		local stage = data.lzyquality and data.lzyquality or data.teamData.stage
		local quality = teamModel:getTeamQualityByStage(stage or 1)
		local teamD = tab.team[tonumber(data.ID)] or tab.npc[tonumber(data.ID)]
		local es = 0
--		if teamD["skill"] == nil or #teamD["skill"] ~= 4 then
--			es = 0
--		end
        if data.teamData.summon or data.damage == -1 or data.boss then
            data.teamData.isSummon = true
        end
        --召唤物不显示兵团信息页面 add by yuxiaojing
        local eventStyle = 0
        if data.lzylvdis then
        	eventStyle = 1 
        end
        if data.teamData.summon and data.teamData.summon == 2 then
        	eventStyle = 0
        end
		local icon = IconUtils:createTeamIconById({teamData = data.teamData, sysTeamData = teamD, quality = quality[1] , quaAddition = quality[2], eventStyle = eventStyle, lzylvdis = data.lzylvdis, lzystar = data.lzystar})

		-- local icon = cc.Sprite:createWithSpriteFrameName(data.art1 .. ".jpg")
		icon:setPosition(47, 44)
		icon:setScale(.75)
        icon:setAnchorPoint(0.5, 0.5)
        icon:setScaleAnim(true)
		cell:addChild(icon)

		--佣兵标志
		if data.isMercenary then
	    	local hireIcon = cc.Sprite:createWithSpriteFrameName("globalImageUI_hireIcon.png") 
	    	hireIcon:setScale(1.4)
	    	hireIcon:setPosition(icon:getContentSize().width * 0.5 - 45, 100)
    		icon:addChild(hireIcon,100)	
    	end	

        if not data.teamData.isSummon and not data.lzylvdis then --召唤物不可点击
            self:registerClickEvent(icon, function()
--                package.loaded["game.view.battle.BattleResultTeamDescView"] = nil
                self._viewMgr:showDialog("battle.BattleResultTeamDescView", {teamData = data, teamD = teamD}, true)
            end)
        end

		-- local circle = cc.Sprite:createWithSpriteFrameName("bg_head_mainView.png")
		-- circle:setPosition(54, 44)
		-- circle:setScale(.8)
		-- cell:addChild(circle)

		local proBg1 = cc.Sprite:createWithSpriteFrameName("battleCount_proBg.png")
		proBg1:setPosition(157, 18)
		cell:addChild(proBg1)

		local proBg2 = cc.Sprite:createWithSpriteFrameName("battleCount_proBg.png")
		proBg2:setPosition(271, 18)
		cell:addChild(proBg2)

		local proBg3 = cc.Sprite:createWithSpriteFrameName("battleCount_proBg.png")
		proBg3:setPosition(385, 18)
		cell:addChild(proBg3)

		local sp = cc.Sprite:createWithSpriteFrameName("battleCount_pro1.png")
	    local pro1 = cc.ProgressTimer:create(sp)
	    pro1:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	    pro1:setMidpoint(cc.p(0, 0.5))
	    pro1:setBarChangeRate(cc.p(1, 0))    
	    pro1:setAnchorPoint(0, 0)
	    pro1:setPosition(3, 2)
	    proBg1:addChild(pro1)

		local sp = cc.Sprite:createWithSpriteFrameName("battleCount_pro2.png")
	    local pro2 = cc.ProgressTimer:create(sp)
	    pro2:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	    pro2:setMidpoint(cc.p(0, 0.5))
	    pro2:setBarChangeRate(cc.p(1, 0))    
	    pro2:setAnchorPoint(0, 0)
	    pro2:setPosition(2, 2)
	    proBg2:addChild(pro2)

	    local sp = cc.Sprite:createWithSpriteFrameName("battleCount_pro3.png")
	    local pro3 = cc.ProgressTimer:create(sp)
	    pro3:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	    pro3:setMidpoint(cc.p(0, 0.5))
	    pro3:setBarChangeRate(cc.p(1, 0))    
	    pro3:setAnchorPoint(0, 0)
	    pro3:setPosition(2, 2)
	    proBg3:addChild(pro3)

	    local nameStr = lang(data.name)
	    --如果是NPC and jx=1则取NPC表的名字	edit by yuxiaojing
        if data.jx and not tab.npc[data.ID] then
            dump(data)
            nameStr = lang(TeamUtils:getTeamAwakingTab(data.teamData, data.teamData.match or data.ID))
        end
	    if data.copy then
	    	nameStr = nameStr .. "镜像"
	    end
	    local name = cc.Label:createWithTTF(nameStr, UIUtils.ttfName, 26)
	    if camp == mainCamp then
	    	name:setColor(blue)
	    else
	    	name:setColor(red)
	    end
	    name:setAnchorPoint(0, 0.5)
	    name:setPosition(106, 68)
	    cell:addChild(name)

	    local time = cc.Label:createWithTTF("存活时间："..data.die.."s", UIUtils.ttfName, 18)
	    time:setAnchorPoint(1, 0.5)
	    time:setColor(yellow)
	    time:setPosition(434, 71)
	    cell:addChild(time)

	    local label1 = cc.Label:createWithTTF(self._isShowReal and data.realDamage or data.damage, UIUtils.ttfName, 18)
	    label1:setAnchorPoint(0, 0.5)
	    label1:setColor(gray)
	    label1:setPosition(108, 38)
	    cell:addChild(label1)
	    local label2 = cc.Label:createWithTTF(data.heal, UIUtils.ttfName, 18)
	    label2:setAnchorPoint(0, 0.5)
	    label2:setColor(gray)
	    label2:setPosition(222, 38)
	    cell:addChild(label2)
	   	local label3 = cc.Label:createWithTTF(self._isShowReal and data.realHurt or data.hurt, UIUtils.ttfName, 18)
	    label3:setAnchorPoint(0, 0.5)
	    label3:setColor(gray)
	    label3:setPosition(336, 38)
	    cell:addChild(label3)

	    local prolabel1 = cc.Label:createWithTTF(self._isShowReal and data.realDamagePro or data.damagePro.."%", UIUtils.ttfName, 14)
	    prolabel1:setAnchorPoint(1, 0.5)
	    prolabel1:setColor(gray)
	    prolabel1:enableOutline(black, 1)
	    prolabel1:setPosition(200, 17)
	    cell:addChild(prolabel1)
	    local prolabel2 = cc.Label:createWithTTF(data.healPro.."%", UIUtils.ttfName, 14)
	    prolabel2:setAnchorPoint(1, 0.5)
	    prolabel2:setColor(gray)
	    prolabel2:enableOutline(black, 1)
	    prolabel2:setPosition(314, 17)
	    cell:addChild(prolabel2)
	   	local prolabel3 = cc.Label:createWithTTF(self._isShowReal and data.realHurtPro or data.hurtPro.."%", UIUtils.ttfName, 14)
	    prolabel3:setAnchorPoint(1, 0.5)
	    prolabel3:setColor(gray)
	    prolabel3:enableOutline(black, 1)
	    prolabel3:setPosition(428, 17)
	    cell:addChild(prolabel3)

	    cell.time = time
		cell.pro1 = pro1
		cell.pro2 = pro2
		cell.pro3 = pro3
		cell.proBg1 = proBg1
		cell.proBg2 = proBg2
		cell.proBg3 = proBg3
		cell.label1 = label1
		cell.label2 = label2
		cell.label3 = label3
		cell.prolabel1 = prolabel1
		cell.prolabel2 = prolabel2
		cell.prolabel3 = prolabel3
		label1.value = self._isShowReal and data.realDamage or data.damage
		label2.value = self._isShowReal and data.realHurt or data.hurt
		label3.value = data.heal
		prolabel1.value = self._isShowReal and data.realDamagePro or data.damagePro
		prolabel2.value = self._isShowReal and data.realHurtPro or data.hurtPro
		prolabel3.value = data.healPro
		pro1.value = self._isShowReal and data.realDamagePro or data.damagePro --/ maxDamagePro * 100
		pro2.value = self._isShowReal and data.realHurtPro or data.hurtPro --/ maxHealPro * 100
		pro3.value = data.healPro --/ maxHurtPro * 100
		if pro1.value < 5 and pro1.value ~= 0 then pro1.value = 5 end
		if pro2.value < 5 and pro2.value ~= 0 then pro2.value = 5 end
		if pro3.value < 5 and pro3.value ~= 0 then pro3.value = 5 end
		pro1:setPercentage(pro1.value)
		pro2:setPercentage(pro2.value)
		pro3:setPercentage(pro3.value)
		-- 技能
		-- dump(data.skill)

        local iconTeamData = clone(data.teamData)
        iconTeamData.teamId = data.ID
		for i = 1, #data.skill do
			local dx = (i - 1) * 108
			local skillD = tab.skill[data.skill[i][1]]
			if skillD == nil then
				skillD = tab.skillPassive[data.skill[i][1]]
			end

			local level = data.skills[skillD["id"]] or 1
			local icon = IconUtils:createTeamSkillIconById({teamSkill = skillD ,eventStyle = 1, teamData = iconTeamData, level = level})
			icon:setPosition(232 + dx, 0)
			icon:setScale(.65)
			icon:setCascadeOpacityEnabled(true)
			cell:addChild(icon)

			local value = math.floor(data.skill[i][2] / data.damage * 100)
			if value < 1 then
				value = 1
			end
		    local label = cc.Label:createWithTTF(value .."%", UIUtils.ttfName, 28)
		    label.value = value
		    label:setAnchorPoint(0, 0.5)
		    label:setColor(gray)
		    label:setPosition(110, 55)
		    icon:addChild(label)
		    if i == 1 then
		    	cell.skill1 = icon
		    	cell.skilllabel1 = label
		    else
		    	cell.skill2 = icon
		    	cell.skilllabel2 = label
		    end
		end

		data.cell = cell
	end

	self._cellViews = {{}, {}}
	local cell
	for i = 1, self._count1 do
		cell = cc.Node:create()
		fillCell(cell, self._data[1][i], 1)
		cell:setPosition(104, 0)
		cell:retain()
		self._cellViews[1][i] = cell
	end
	for i = 1, self._count2 do
		cell = cc.Node:create()
		fillCell(cell, self._data[2][i], 2)
		cell:setPosition(595, 0)
		cell:retain()
		self._cellViews[2][i] = cell
	end

    local function fillSpellCell(cell, data, camp)
		cell:setCascadeOpacityEnabled(true)

        -- 判断是否为器械技能
        local skillTabData = tab:PlayerSkillEffect(tonumber(data.id))
        if skillTabData.type == 8 then
            local siegeSkillData = tab:SiegeSkillDes(tonumber(string.sub(data.id,1,4))) -- 器械技能图标显示第一个技能的图标，截取id前4位
            local icon = IconUtils:createWeaponsSkillIcon({sysSkill = siegeSkillData})
            icon:setScale(0.9)
            icon:setPosition(47, 44)
            icon:setAnchorPoint(0.5, 0.5)
            cell:addChild(icon)

            local nameStr = lang(siegeSkillData.name)
	        local name = cc.Label:createWithTTF(nameStr, UIUtils.ttfName, 26)
	        if camp == mainCamp then
	    	    name:setColor(blue)
	        else
	    	    name:setColor(red)
	        end
	        name:setAnchorPoint(0, 0.5)
	        name:setPosition(106, 68)
	        cell:addChild(name)

            local siegeTabData = tab:SiegeWeapon(tonumber(string.sub(data.id, 3, 4))) -- 技能id的三四位对应器械id
            local name1 = cc.Label:createWithTTF("(" .. lang(siegeTabData.name) .. ")", UIUtils.ttfName, 16)
	    	name1:setColor(cc.c3b(186,186,186))
	        name1:setAnchorPoint(0, 0.5)
	        name1:setPosition(name:getPositionX() + name:getContentSize().width + 5, 63)
	        cell:addChild(name1)
        else
            local icon = ccui.ImageView:create()
            icon:loadTexture(IconUtils.iconPath .. skillTabData.art .. ".png",1)
            icon:setScale(0.9)
            icon:setAnchorPoint(0.5,0.5)
            icon:setPosition(47, 44)
            cell:addChild(icon)

            local iconBound = nil
            if skillTabData.dazhao == 1 then
                iconBound = cc.Sprite:createWithSpriteFrameName("hero_skill_bg1_forma.png")
                iconBound:setScale(1.05)
            else
                iconBound = cc.Sprite:createWithSpriteFrameName("hero_skill_bg2_forma.png")
            end
            iconBound:setPosition(icon:getContentSize().width * 0.5, icon:getContentSize().height * 0.5)
            icon:addChild(iconBound)

            local nameStr = lang(skillTabData.name)
	        local name = cc.Label:createWithTTF(nameStr, UIUtils.ttfName, 26)
	        if camp == mainCamp then
	    	    name:setColor(blue)
	        else
	    	    name:setColor(red)
	        end
	        name:setAnchorPoint(0, 0.5)
	        name:setPosition(106, 68)
	        cell:addChild(name)
        end

		local proBg1 = cc.Sprite:createWithSpriteFrameName("battleCount_proBg.png")
		proBg1:setPosition(157, 18)
		cell:addChild(proBg1)

		local proBg2 = cc.Sprite:createWithSpriteFrameName("battleCount_proBg.png")
		proBg2:setPosition(321, 18)
		cell:addChild(proBg2)

		local sp = cc.Sprite:createWithSpriteFrameName("battleCount_pro1.png")
	    local pro1 = cc.ProgressTimer:create(sp)
	    pro1:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	    pro1:setMidpoint(cc.p(0, 0.5))
	    pro1:setBarChangeRate(cc.p(1, 0))    
	    pro1:setAnchorPoint(0, 0)
	    pro1:setPosition(3, 2)
	    proBg1:addChild(pro1)

		local sp = cc.Sprite:createWithSpriteFrameName("battleCount_pro3.png")
	    local pro2 = cc.ProgressTimer:create(sp)
	    pro2:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	    pro2:setMidpoint(cc.p(0, 0.5))
	    pro2:setBarChangeRate(cc.p(1, 0))    
	    pro2:setAnchorPoint(0, 0)
	    pro2:setPosition(2, 2)
	    proBg2:addChild(pro2)



	    local label1 = cc.Label:createWithTTF(self._isShowReal and data.realDamage or data.damage, UIUtils.ttfName, 18)
	    label1:setAnchorPoint(0, 0.5)
	    label1:setColor(gray)
	    label1:setPosition(108, 38)
	    cell:addChild(label1)
	    local label2 = cc.Label:createWithTTF(data.heal, UIUtils.ttfName, 18)
	    label2:setAnchorPoint(0, 0.5)
	    label2:setColor(gray)
	    label2:setPosition(272, 38)
	    cell:addChild(label2)

	    local prolabel1 = cc.Label:createWithTTF(self._isShowReal and data.realDamagePro or data.damagePro.."%", UIUtils.ttfName, 14)
	    prolabel1:setAnchorPoint(1, 0.5)
	    prolabel1:setColor(gray)
	    prolabel1:enableOutline(black, 1)
	    prolabel1:setPosition(200, 17)
	    cell:addChild(prolabel1)
	    local prolabel2 = cc.Label:createWithTTF(data.healPro.."%", UIUtils.ttfName, 14)
	    prolabel2:setAnchorPoint(1, 0.5)
	    prolabel2:setColor(gray)
	    prolabel2:enableOutline(black, 1)
	    prolabel2:setPosition(364, 17)
	    cell:addChild(prolabel2)

	    cell.time = time
		cell.pro1 = pro1
		cell.pro2 = pro2
		cell.proBg1 = proBg1
		cell.proBg2 = proBg2
		cell.label1 = label1
		cell.label2 = label2
		cell.prolabel1 = prolabel1
		cell.prolabel2 = prolabel2
		label1.value = self._isShowReal and data.realDamage or data.damage
		label2.value = data.heal
		prolabel1.value = self._isShowReal and data.realDamagePro or data.damagePro
		prolabel2.value = data.healPro
		pro1.value = self._isShowReal and data.realDamagePro or data.damagePro --/ maxDamagePro * 100
		pro2.value = data.healPro --/ maxHurtPro * 100
		if pro1.value < 5 and pro1.value ~= 0 then pro1.value = 5 end
		if pro2.value < 5 and pro2.value ~= 0 then pro2.value = 5 end
		pro1:setPercentage(pro1.value)
		pro2:setPercentage(pro2.value)

		data.cell = cell
	end

    self._spellCellViews = {{}, {}}
	local cell
	for i = 1, self._spellCount1 do
		cell = cc.Node:create()
		fillSpellCell(cell, self._spellData[1][i], 1)
		cell:setPosition(104, 0)
		cell:retain()
		self._spellCellViews[1][i] = cell
	end
	for i = 1, self._spellCount2 do
		cell = cc.Node:create()
		fillSpellCell(cell, self._spellData[2][i], 2)
		cell:setPosition(595, 0)
		cell:retain()
		self._spellCellViews[2][i] = cell
	end

    self._tableViewNum = self._allCount
    local tableView = cc.TableView:create(cc.size(1136, 384 * bgScale))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition((self._maxScreenWidth - 1136) * 0.5, 75 * bgScale)
    tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._panel:addChild(tableView)
    self._tableView = tableView

    self:onTab(1)
	self:onFilter(1)
	self:onPage(1)
	self:onUpdate()
end

function BattleCountView:cellSizeForTable(table,index)
    return 93, 1136
end

function BattleCountView:tableCellAtIndex(table,index)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
        cell:setCascadeOpacityEnabled(true)
        local bg1, bg2
        if self._reverse then
		    bg1 = cc.Sprite:createWithSpriteFrameName("battleCount_bg2.png")
		    bg1:setScaleX(-1)
		    bg1:setPosition(281, 45)
		    bg2 = cc.Sprite:createWithSpriteFrameName("battleCount_bg1.png")
		    bg2:setScaleX(-1)
		    bg2:setPosition(856, 45)
        else
		    bg1 = cc.Sprite:createWithSpriteFrameName("battleCount_bg1.png")
		    bg1:setPosition(281, 45)
		    bg2 = cc.Sprite:createWithSpriteFrameName("battleCount_bg2.png")
		    bg2:setPosition(856, 45)
		end

	    cell:addChild(bg1)
	    cell.bg1 = bg1
	    cell:addChild(bg2)
	    cell.bg2 = bg2
	    local node = cc.Node:create()
	    cell:addChild(node)
	    cell.node = node
    end

    local showData = self._isShowSpell and self._data or self._spellData
    local showCount1 = self._isShowSpell and self._count1 or self._spellCount1
    local showCount2 = self._isShowSpell and self._count2 or self._spellCount2

    local idx = index + 1
	cell.bg1:setVisible(idx <= showCount1)
	cell.bg2:setVisible(idx <= showCount2)
    
    cell.node:removeAllChildren()

    local cell1, cell2
    if showData[1][idx] then
    	cell1 = showData[1][idx].cell
    end
    if showData[2][idx] then
    	cell2 = showData[2][idx].cell
    end
    cell:stopAllActions()
    cell:setOpacity(255)

    local gray = cc.c3b(204, 206, 209)
    local yellow = cc.c3b(240, 240, 0)

    if self._isShowSpell then
        if cell1 then
    	    cell1:removeFromParent()
    	    cell1:stopAllActions()
    	    cell1:setOpacity(255)
    	    if cell1.label1.value == -1 then
	    	    cell1.label1:setString("??")
	    	    cell1.label2:setString("??")
	    	    cell1.label3:setString("??")
	    	    cell1.prolabel1:setString("??")
	    	    cell1.prolabel2:setString("??")
	    	    cell1.prolabel3:setString("??")
    	    else
                cell1.label1.value = self._isShowReal and showData[1][idx].realDamage or showData[1][idx].damage
                cell1.label2.value = self._isShowReal and showData[1][idx].realHurt or showData[1][idx].hurt
	    	    cell1.label1:setString(cell1.label1.value)
	    	    cell1.label2:setString(cell1.label2.value)
	    	    cell1.label3:setString(cell1.label3.value)
                cell1.prolabel1.value = self._isShowReal and showData[1][idx].realDamagePro or showData[1][idx].damagePro
                cell1.prolabel2.value = self._isShowReal and showData[1][idx].realHurtPro or showData[1][idx].hurtPro
	    	    cell1.prolabel1:setString(string.format("%.1f", cell1.prolabel1.value).."%")
	    	    cell1.prolabel2:setString(string.format("%.1f", cell1.prolabel2.value).."%")
	    	    cell1.prolabel3:setString(string.format("%.1f", cell1.prolabel3.value).."%")
	        end
            cell1.pro1.value = self._isShowReal and showData[1][idx].realDamagePro or showData[1][idx].damagePro
            cell1.pro2.value = self._isShowReal and showData[1][idx].realHurtPro or showData[1][idx].hurtPro
    	    cell1.pro1:setPercentage(cell1.pro1.value)
    	    cell1.pro2:setPercentage(cell1.pro2.value)
    	    cell1.pro3:setPercentage(cell1.pro3.value)
		    if cell1.skilllabel1 then
			    cell1.skilllabel1:setString(cell1.skilllabel1.value.."%")
		    end
		    if cell1.skilllabel2 then
			    cell1.skilllabel2:setString(cell1.skilllabel2.value.."%")
		    end
    	    cell.node:addChild(cell1)

            cell1.label1:setColor(self._isShowReal and yellow or gray)
            cell1.label2:setColor(self._isShowReal and yellow or gray)
            cell1.label3:setColor(self._isShowReal and yellow or gray)
            cell1.prolabel1:setColor(self._isShowReal and yellow or gray)
            cell1.prolabel2:setColor(self._isShowReal and yellow or gray)
            cell1.prolabel3:setColor(self._isShowReal and yellow or gray)
        end
        if cell2 then
    	    cell2:removeFromParent()
    	    cell2:stopAllActions()
    	    cell2:setOpacity(255)
    	    if cell2.label1.value == -1 then
	    	    cell2.label1:setString("??")
	    	    cell2.label2:setString("??")
	    	    cell2.label3:setString("??")
	    	    cell2.prolabel1:setString("??")
	    	    cell2.prolabel2:setString("??")
	    	    cell2.prolabel3:setString("??")
    	    else
                cell2.label1.value = self._isShowReal and showData[2][idx].realDamage or showData[2][idx].damage
                cell2.label2.value = self._isShowReal and showData[2][idx].realHurt or showData[2][idx].hurt
	    	    cell2.label1:setString(cell2.label1.value)
	    	    cell2.label2:setString(cell2.label2.value)
	    	    cell2.label3:setString(cell2.label3.value)
                cell2.prolabel1.value = self._isShowReal and showData[2][idx].realDamagePro or showData[2][idx].damagePro
                cell2.prolabel2.value = self._isShowReal and showData[2][idx].realHurtPro or showData[2][idx].hurtPro
	    	    cell2.prolabel1:setString(string.format("%.1f", cell2.prolabel1.value).."%")
	    	    cell2.prolabel2:setString(string.format("%.1f", cell2.prolabel2.value).."%")
	    	    cell2.prolabel3:setString(string.format("%.1f", cell2.prolabel3.value).."%")
	        end
            cell2.pro1.value = self._isShowReal and showData[2][idx].realDamagePro or showData[2][idx].damagePro
            cell2.pro2.value = self._isShowReal and showData[2][idx].realHurtPro or showData[2][idx].hurtPro
    	    cell2.pro1:setPercentage(cell2.pro1.value)
    	    cell2.pro2:setPercentage(cell2.pro2.value)
    	    cell2.pro3:setPercentage(cell2.pro3.value)
    	    if cell2.skilllabel1 then
			    cell2.skilllabel1:setString(cell2.skilllabel1.value.."%")
		    end
		    if cell2.skilllabel2 then
			    cell2.skilllabel2:setString(cell2.skilllabel2.value.."%")
		    end
    	    cell.node:addChild(cell2)

            cell2.label1:setColor(self._isShowReal and yellow or gray)
            cell2.label2:setColor(self._isShowReal and yellow or gray)
            cell2.label3:setColor(self._isShowReal and yellow or gray)
            cell2.prolabel1:setColor(self._isShowReal and yellow or gray)
            cell2.prolabel2:setColor(self._isShowReal and yellow or gray)
            cell2.prolabel3:setColor(self._isShowReal and yellow or gray)
        end
    else
        if cell1 then
    	    cell1:removeFromParent()
    	    cell1:stopAllActions()
    	    cell1:setOpacity(255)
    	    if cell1.label1.value == -1 then
	    	    cell1.label1:setString("??")
	    	    cell1.label2:setString("??")
	    	    cell1.prolabel1:setString("??")
	    	    cell1.prolabel2:setString("??")
    	    else
                cell1.label1.value = self._isShowReal and showData[1][idx].realDamage or showData[1][idx].damage
                cell1.prolabel1.value = self._isShowReal and showData[1][idx].realDamagePro or showData[1][idx].damagePro
	    	    cell1.label1:setString(cell1.label1.value)
	    	    cell1.prolabel1:setString(string.format("%.1f", cell1.prolabel1.value).."%")
                cell1.label2:setString(cell1.label2.value)
	    	    cell1.prolabel2:setString(string.format("%.1f", cell1.prolabel2.value).."%")
	        end
            cell1.pro1.value = self._isShowReal and showData[1][idx].realDamagePro or showData[1][idx].damagePro
    	    cell1.pro1:setPercentage(cell1.pro1.value)
    	    cell1.pro2:setPercentage(cell1.pro2.value)
    	    cell.node:addChild(cell1)

            cell1.label1:setColor(self._isShowReal and yellow or gray)
            cell1.label2:setColor(self._isShowReal and yellow or gray)
            cell1.prolabel1:setColor(self._isShowReal and yellow or gray)
            cell1.prolabel2:setColor(self._isShowReal and yellow or gray)
        end
        if cell2 then
    	    cell2:removeFromParent()
    	    cell2:stopAllActions()
    	    cell2:setOpacity(255)
    	    if cell2.label1.value == -1 then
	    	    cell2.label1:setString("??")
	    	    cell2.label2:setString("??")
	    	    cell2.prolabel1:setString("??")
	    	    cell2.prolabel2:setString("??")
    	    else
                cell2.label1.value = self._isShowReal and showData[2][idx].realDamage or showData[2][idx].damage
	    	    cell2.label1:setString(cell2.label1.value)
                cell2.prolabel1.value = self._isShowReal and showData[2][idx].realDamagePro or showData[2][idx].damagePro
	    	    cell2.prolabel1:setString(string.format("%.1f", cell2.prolabel1.value).."%")
                cell2.label2:setString(cell2.label2.value)
	    	    cell2.prolabel2:setString(string.format("%.1f", cell2.prolabel2.value).."%")
	        end
            cell2.pro1.value = self._isShowReal and showData[2][idx].realDamagePro or showData[2][idx].damagePro
    	    cell2.pro1:setPercentage(cell2.pro1.value)
    	    cell2.pro2:setPercentage(cell2.pro2.value)
    	    cell.node:addChild(cell2)

            cell2.label1:setColor(self._isShowReal and yellow or gray)
            cell2.label2:setColor(self._isShowReal and yellow or gray)
            cell2.prolabel1:setColor(self._isShowReal and yellow or gray)
            cell2.prolabel2:setColor(self._isShowReal and yellow or gray)
        end
    end
    return cell
end

function BattleCountView:tableCellWillRecycle(table,cell)
    cell:removeAllChildren()
end

function BattleCountView:numberOfCellsInTableView(table)
    return self._tableViewNum
end


function BattleCountView:onTab(index)
    if index == self._curTab then return end

    self:setTabBtnEnabled(self._tabBtns[self._curTab], true)
    self:setTabBtnEnabled(self._tabBtns[index], false)
    self._curTab = index
    self._isShowSpell = self._curTab == 1
    if self._isShowSpell then
        self._filterBtn1:setVisible(true)
        self._filterBtn2:setVisible(true)
        self._filterBtn3:setVisible(true)
        self._filterBtn3:setPositionX(891)
        self._realBox:setPositionX(226)
        self._boxLabel:setPositionX(253)
        self._page1:setVisible(false)
	    self._page2:setVisible(true)
        self._title1:setVisible(true)
	    self._title2:setVisible(false)
	    self._title3:setVisible(false)

        self._tableViewNum = self._allCount
    else
        self._filterBtn1:setVisible(true)
        self._filterBtn2:setVisible(false)
        self._filterBtn3:setVisible(true)
        self._filterBtn3:setPositionX(777)
        self._realBox:setPositionX(50)
        self._boxLabel:setPositionX(77)
        self._page1:setVisible(false)
	    self._page2:setVisible(false)
        self._title1:setVisible(false)
	    self._title2:setVisible(false)
	    self._title3:setVisible(true)

        self._tableViewNum = self._spellCount
    end
    self:onFilter(1)
    return true
end

function BattleCountView:setTabBtnEnabled(btn, bool)
    if btn == nil then return end

    btn:setTouchEnabled(bool)
    if bool then
        btn:loadTextures("countTab2_battle.png","countTab2_battle.png","",1)
        btn:getTitleRenderer():setColor(cc.c3b(148,106,81))
    else
        btn:loadTextures("countTab1_battle.png","countTab1_battle.png","",1)
        btn:getTitleRenderer():setColor(bool and cc.c3b(148,106,81) or cc.c3b(252,244,198))
    end
end

function BattleCountView:updateToReal(bool)
    if bool ~= self._isShowReal then
        self._isShowReal = bool
        self:onUpdate()
    end
end

function BattleCountView:onFilter(filter)
	if self._filterIndex == filter then return end
	self._filterIndex = filter
	local color1 = cc.c3b(255, 255, 255)
	local color2 = cc.c3b(128, 128, 128)
	self._filterBtn1:setColor(filter == 1 and color1 or color2)
	self._filterBtn2:setColor(filter == 2 and color1 or color2)
	self._filterBtn3:setColor(filter == 3 and color1 or color2)
	self._filterBtn1:setTouchEnabled(filter ~= 1)
	self._filterBtn2:setTouchEnabled(filter ~= 2)
	self._filterBtn3:setTouchEnabled(filter ~= 3)
	return true
end

function BattleCountView:onPage(index)
	if self._pageIndex == index then return end
	self._pageIndex = index
	self._page1:setVisible(index == 2)
	self._page2:setVisible(index == 1)
	self._title1:setVisible(index == 1)
	self._title2:setVisible(index == 2)
	self:onFilter(1)
	self._filterBtn1:setVisible(index == 1)
	self._filterBtn2:setVisible(index == 1)
	self._filterBtn3:setVisible(index == 1)
	return true
end

local function compare1(self, a, b)
    if self._isShowReal then
    	if a.realDamage == b.realDamage then
		    if a.heal == b.heal then
			    return a.realHurt > b.realHurt
		    else
			    return a.heal > b.heal
		    end
	    else
		    return a.realDamage > b.realDamage
	    end
    else
	    if a.damage == b.damage then
		    if a.heal == b.heal then
			    return a.hurt > b.hurt
		    else
			    return a.heal > b.heal
		    end
	    else
		    return a.damage > b.damage
	    end
    end
end
local function compare2(self, a, b)
    if self._isShowReal then
        if a.realHurt == b.realHurt then
		    if a.realDamage == b.realDamage then
			    return a.heal > b.heal
		    else
			    return a.realDamage > b.realDamage
		    end
	    else
		    return a.realHurt > b.realHurt
	    end
    else
	    if a.hurt == b.hurt then
		    if a.damage == b.damage then
			    return a.heal > b.heal
		    else
			    return a.damage > b.damage
		    end
	    else
		    return a.hurt > b.hurt
	    end
    end
end
local function compare3(self, a, b)
	if a.heal == b.heal then
        if self._isShowReal then
        	if a.realDamage == b.realDamage then
			    return a.realHurt > b.realHurt
		    else
			    return a.realDamage > b.realDamage
		    end
        else
		    if a.damage == b.damage then
			    return a.hurt > b.hurt
		    else
			    return a.damage > b.damage
		    end
        end
	else
		return a.heal > b.heal
	end
end
-- 重新刷新tableView
function BattleCountView:onUpdate()
	-- 重新排序
	local showSkill = self._pageIndex == 2
	local data1s = self._isShowSpell and self._data[1] or self._spellData[1]
	local data2s = self._isShowSpell and self._data[2] or self._spellData[2]

	local filter = self._filterIndex
	if filter == 1 then
		table.sort(data1s, function(a,b) return compare1(self, a, b) end)
		table.sort(data2s, function(a,b) return compare1(self, a, b) end)
	elseif filter == 2 then
		table.sort(data1s, function(a,b) return compare2(self, a, b) end)
		table.sort(data2s, function(a,b) return compare2(self, a, b) end)
	else
		table.sort(data1s, function(a,b) return compare3(self, a, b) end)
		table.sort(data2s, function(a,b) return compare3(self, a, b) end)
	end
	self._tableView:stopScroll()
	self._tableView:reloadData()

	-- 动画
	local floor = math.floor
	local function updateValue(cell, pro)
		if cell.label1.value ~= -1 then
			cell.label1:setString(floor(cell.label1.value * pro))
			cell.label2:setString(floor(cell.label2.value * pro))
			cell.prolabel1:setString(string.format("%.1f", cell.prolabel1.value * pro).."%")
			cell.prolabel2:setString(string.format("%.1f", cell.prolabel2.value * pro).."%")
			cell.pro1:setPercentage(cell.pro1.value * pro)
			cell.pro2:setPercentage(cell.pro2.value * pro)
			if cell.label3 then
                cell.label3:setString(floor(cell.label3.value * pro))
			    cell.prolabel3:setString(string.format("%.1f", cell.prolabel3.value * pro).."%")
			    cell.pro3:setPercentage(cell.pro3.value * pro)
            end
		end
		if cell.skilllabel1 then
			cell.skilllabel1:setString(floor(cell.skilllabel1.value * pro) .. "%")
		end
		if cell.skilllabel2 then
			cell.skilllabel2:setString(floor(cell.skilllabel2.value * pro) .. "%")
		end
	end
	local datas = {data1s, data2s}
	for k = 1, 2 do
		for i = 1, #datas[k] do
			local cell = datas[k][i].cell
			cell:stopAllActions()
			cell:setOpacity(1)
			if cell.label1.value ~= -1 then
				cell.label1:setString(0)
				cell.label2:setString(0)
				if cell.label3 then cell.label3:setString(0) end
				cell.prolabel1:setString("0.0%")
				cell.prolabel2:setString("0.0%")
				if cell.prolabel3 then cell.prolabel3:setString("0.0%") end
			end
			cell.pro1:setPercentage(0)
			cell.pro2:setPercentage(0)
			if cell.pro3 then cell.pro3:setPercentage(0) end
			if cell.skilllabel1 then
				cell.skilllabel1:setString("0%")
			end
			if cell.skilllabel2 then
				cell.skilllabel2:setString("0%")
			end
			local pro1show = cell.pro1.value > 0
			local pro2show = cell.pro2.value > 0
			cell.label1:setVisible(pro1show)
			cell.label2:setVisible(not showSkill and pro2show)
			cell.pro1:setVisible(pro1show)
			cell.pro2:setVisible(not showSkill and pro2show)
			cell.proBg1:setVisible(pro1show)
			cell.proBg2:setVisible(not showSkill and pro2show)
			cell.prolabel1:setVisible(pro1show)
			cell.prolabel2:setVisible(not showSkill and pro2show)

            if cell.label3 then
			    cell.time:setVisible(not showSkill)
			    local pro3show = cell.pro3.value > 0
			    cell.label3:setVisible(not showSkill and pro3show)
			    cell.pro3:setVisible(not showSkill and pro3show)
			    cell.proBg3:setVisible(not showSkill and pro3show)
			    cell.prolabel3:setVisible(not showSkill and pro3show)
            end

			if cell.skill1 then
				cell.skill1:setVisible(showSkill)
			end
			if cell.skill2 then
				cell.skill2:setVisible(showSkill)
			end
			local parent = cell:getParent()
			if parent then
				parent = parent:getParent()
				parent:setOpacity(1)
				parent:stopAllActions()
				parent:runAction(cc.Sequence:create(cc.DelayTime:create((i - 1) * 0.05), cc.FadeIn:create(0.05)))
				cell:runAction(
					cc.Sequence:create(
						cc.DelayTime:create(i * 0.05), 
						cc.FadeIn:create(0.05),
						cc.DelayTime:create(0.05),
						cc.CallFunc:create(function ()	updateValue(cell, 0.1) end), cc.FadeIn:create(0.02),
						cc.CallFunc:create(function ()	updateValue(cell, 0.2) end), cc.FadeIn:create(0.02),
						cc.CallFunc:create(function ()	updateValue(cell, 0.3) end), cc.FadeIn:create(0.02),
						cc.CallFunc:create(function ()	updateValue(cell, 0.4) end), cc.FadeIn:create(0.02),  
						cc.CallFunc:create(function ()	updateValue(cell, 0.5) end), cc.FadeIn:create(0.02),
						cc.CallFunc:create(function ()	updateValue(cell, 0.6) end), cc.FadeIn:create(0.02),
						cc.CallFunc:create(function ()	updateValue(cell, 0.7) end), cc.FadeIn:create(0.02),
						cc.CallFunc:create(function ()	updateValue(cell, 0.8) end), cc.FadeIn:create(0.02),
						cc.CallFunc:create(function ()	updateValue(cell, 0.9) end), cc.FadeIn:create(0.02),
						cc.CallFunc:create(function ()	updateValue(cell, 1.0) end)
					)
				)
			end
		end
	end
end

function BattleCountView:onWinSizeChange()
	BattleCountView.super.onWinSizeChange(self)
	local bgScale = self.__viewBg:getScale()

	self._bar:setPosition((self._maxScreenWidth - 960) * 0.5, MAX_SCREEN_HEIGHT - 78 * bgScale)
	self._bar2:setPosition((self._maxScreenWidth - 960) * 0.5, 0)
	self._tableView:setPosition((self._maxScreenWidth - 1136) * 0.5, 75 * bgScale)
	self._tableView:setViewSize(cc.size(1136, 384 * bgScale))
	self._tableView:reloadData()
end

function BattleCountView:adjustBg()
    if self.__viewBg == nil then return end
    local xscale = math.min(1136, MAX_SCREEN_WIDTH) / self.__viewBg:getContentSize().width
    local yscale = MAX_SCREEN_HEIGHT / self.__viewBg:getContentSize().height
    if xscale > yscale then
        self.__viewBg:setScale(xscale)
    else
        self.__viewBg:setScale(yscale)
    end
    self.__viewBg:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
end

function BattleCountView:onShow()
    self._viewMgr:enableScreenWidthBar()
end

function BattleCountView:onTop()
    self._viewMgr:enableScreenWidthBar()
end

function BattleCountView:onHide()
    self._viewMgr:disableScreenWidthBar()
end

function BattleCountView.dtor()
	compare1 = nil
	compare2 = nil
	compare3 = nil
end

return BattleCountView
