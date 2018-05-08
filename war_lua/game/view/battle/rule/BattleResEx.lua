--[[
    Filename:    BattleResEx
    .lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-11-04 11:33:56
    Description: File description
--]]

local keyTable2 = {"frontoat_h", "frontoat_v","backoat_h", "backoat_v", "frontdis_v", "frontdis_h", "backdis_v", "backdis_h",
					"frontstk_v", "frontstk_h", "backstk_v", "backstk_h", 
					"frontimp_v1", "frontimp_h1", "backimp_v1", "backimp_h1", "frontlink1", "backlink1",
					"frontimp_v2", "frontimp_h2", "backimp_v2", "backimp_h2", "frontlink2", "backlink2"}

local function getResFileName(resname)
	local list = string.split(resname, "_")
	return list[#list]
end

local function BUFF_RES(buffid)
	if not tab.skillBuff[buffid]["buffart"] then return "" end
	return getResFileName(tab.skillBuff[buffid]["buffart"])
end
local function TOTEM_RES(totemid)
	if totemid == nil then return "" end
	local res = {}
	local buffD
	local totemD = tab.object[totemid]
	if totemD == nil then return "" end
	-- 图腾自身
	for i = 1, #keyTable2 do
		if totemD[keyTable2[i]] then
			res[getResFileName(totemD[keyTable2[i]])] = true
		end
	end
	for i = 1, 2 do
		-- buff
		if totemD["buffid"..i] then
			buffD = tab.skillBuff[totemD["buffid"..i]]
			if buffD["buffart"] then
				res[getResFileName(buffD["buffart"])] = true
			end
		end
	end
	return res
end
local teamEx = {
				[BattleUtils.BATTLE_TYPE_Guide] = {{107, 1}},
				}
local elementSkillPara = tab.elementSkillPara
local elementalPlane4
if tab.elementalPlane4 then 
	elementalPlane4 = tab.elementalPlane4[1]
end
-- local 
local npcEx = {
				[BattleUtils.BATTLE_TYPE_AiRenMuWu] = {{79001, 2}, {79002, 2}},
				[BattleUtils.BATTLE_TYPE_Zombie] = {{79011, 2}, {79012, 2}, {79013, 1}, {79014, 2}, {79016, 1}},
				[BattleUtils.BATTLE_TYPE_BOSS_SjLong] = {{8010401, 2}},
				[BattleUtils.BATTLE_TYPE_GBOSS_3] = {{8010401, 2}},
				}
if elementalPlane4 then
	local _id = BattleUtils.BATTLE_TYPE_Elemental_4
	npcEx[_id] =
	{
		{elementalPlane4["n1"][1], 2}, 
		{elementalPlane4["n2"][1], 2},
	}
	for i = 3, 6 do
		if elementalPlane4["n"..i] then
			npcEx[_id][#npcEx[_id] + 1] = {elementalPlane4["n"..i][1][1], 2}
		end
	end
end

local effEx = {
				[BattleUtils.BATTLE_TYPE_Guide] = {"fazhenzhaohuan"},
				[BattleUtils.BATTLE_TYPE_AiRenMuWu] = {"airenjisha", "airenjinbi", "huilan", "jingbi"},
				[BattleUtils.BATTLE_TYPE_Zombie] = {"muxuetexiao", "muzhuang", BUFF_RES(4997), "jingyan"},
				[BattleUtils.BATTLE_TYPE_Siege] = {"chengqiangshouji", "chengqiangcuihuiyan", "gongchengzhan"},
				[BattleUtils.BATTLE_TYPE_CCSiege] = {"chengqiangshouji", "chengqiangcuihuiyan", "gongchengzhan"},
				[BattleUtils.BATTLE_TYPE_BOSS_DuLong] = {"dulong", "dulongtexiao", "dragonboom",
														 BUFF_RES(4981), BUFF_RES(4982), BUFF_RES(4983), BUFF_RES(4984), BUFF_RES(4987)},
				[BattleUtils.BATTLE_TYPE_BOSS_XnLong] = {"xiannvlong", "shibi", "liansuoshandian", "xiannvlongtexiao",
														BUFF_RES(4991), BUFF_RES(4992), BUFF_RES(4993), BUFF_RES(4996)},
				[BattleUtils.BATTLE_TYPE_BOSS_SjLong] = {"shuijinglong", "dragonboom", "shuijingci", "rexuesongge", "baolieshuijing",
														BUFF_RES(4970), BUFF_RES(4971), BUFF_RES(4986)},
				[BattleUtils.BATTLE_TYPE_GBOSS_1] = {"bingjuren", "handi"},
				[BattleUtils.BATTLE_TYPE_GBOSS_2] = {"shijuren", "handi"},
				[BattleUtils.BATTLE_TYPE_GBOSS_3] = {"huojuren", "handi"},
				[BattleUtils.BATTLE_TYPE_Siege_Def] = {"airenjisha", "gongchengtanchuang"},
				[BattleUtils.BATTLE_TYPE_Siege_Def_WE] = {"airenjisha", "gongchengtanchuang"},
				}

if elementSkillPara then
	effEx[BattleUtils.BATTLE_TYPE_Elemental_1] = {TOTEM_RES(elementSkillPara[1]["buff"])}
	effEx[BattleUtils.BATTLE_TYPE_Elemental_2] = {TOTEM_RES(elementSkillPara[2]["buff"]), BUFF_RES(elementSkillPara[2]["buff1"])}
	effEx[BattleUtils.BATTLE_TYPE_Elemental_3] = {TOTEM_RES(elementSkillPara[3]["buff"]), BUFF_RES(elementSkillPara[3]["buff1"])}
	effEx[BattleUtils.BATTLE_TYPE_Elemental_4] = {}
	effEx[BattleUtils.BATTLE_TYPE_Elemental_5] = {}
end
elementSkillPara = nil
elementalPlane4 = nil
local ret = {}

ret.teamEx = teamEx
ret.npcEx = npcEx
ret.effEx = effEx

function ret.dtor()
	keyTable2 = nil
	getResFileName = nil
	BUFF_RES = nil
	TOTEM_RES = nil
	teamEx = nil
	npcEx = nil
	effEx = nil
end

return ret