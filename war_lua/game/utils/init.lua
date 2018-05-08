--[[
    Filename:    init.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2015-05-22 17:46:29
    Description: File description
--]]

-- 游戏逻辑用utils

ScheduleMgr = require("game.utils.ScheduleManager").new()
require "game.utils.RichTextFactory"
require "game.utils.richTextDecode"
Random = require("game.utils.random").new()
function GRandom(...)
	return Random:ran(...)
end
function GRandomSeed(...)
	return Random:setSeed(...)
end

require "game.utils.Functions"

BattleUtils = require "game.utils.BattleUtils"
require "game.utils.BattleUtils2"
require "game.utils.BattleUtils3"
ItemUtils = require "game.utils.ItemUtils"
IconUtils = require "game.utils.IconUtils"
TeamUtils = require "game.utils.TeamUtils"
UIUtils = require "game.utils.UIUtils"
SkillUtils = require "game.utils.SkillUtils"
DialogUtils = require "game.utils.DialogUtils"
SystemUtils = require "game.utils.SystemUtils"
GuideUtils = require "game.utils.GuideUtils"
GuideBattleHelpUtils = require "game.utils.GuideBattleHelpUtils"
CardUtils = require "game.utils.CardUtils"
PrivilegeUtils = require "game.utils.PrivilegeUtils"
MathUtils = require "game.utils.MathUtils"
GuildUtils = require "game.utils.GuildUtils"
TimeUtils = require "game.utils.TimeUtils"
LeagueUtils = require "game.utils.LeagueUtils"
BulletScreensUtils = require "game.utils.BulletScreensUtils"
CityBattleUtils = require "game.utils.CityBattleUtils"
VoiceUtils = require "game.utils.VoiceUtils"
CustomServiceUtils = require "game.utils.CustomServiceUtils"
WakeUpUtils = require "game.utils.WakeUpUtils"
GodWarUtil = require "game.utils.GodWarUtil"
CrossUtils = require "game.utils.CrossUtils"
LordManagerUtils = require "game.utils.LordManagerUtils"


