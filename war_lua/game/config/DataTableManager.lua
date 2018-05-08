--[[
    Filename:    DataTableManager.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2014-12-24 15:28:56
    Description: csv配置表管理器
--]]

-- 是否对表格进行检查

local CHECK_TABLE = OS_IS_WINDOWS

local DataTableManager = class("DataTableManager")

-- 需要签名验证的表格列表, 防止内存修改
-- 1. 为整表验证  2. 为分表验证
local signatureTabs =
{
    team = 2, equipment = 2, hero = 2, npcHero = 2, 
    npc = 3, mainStage = 3, towerFight = 3, siege = 3, branchMonsterStage = 3,
    skill = 1, skillPassive = 1, skillAttackEffect = 1, skillCharacter = 1, skillBuff = 1, teamPokedex = 1,object = 1, 
    heroMastery = 1, playerSkillEffect = 1,  comTreasure = 1, disTreasure = 1, technique = 1, comTreasureStar = 1,
}
if OS_IS_WINDOWS then
    signatureTabs.setting = 2
end
local __encode
local __md5
local __pctool
local find = string.find
if not BATTLE_PROC then
    __encode = hjson.encode
    __md5 = pc.PCTools.md5
    __pctool = pc.PCTools
end
local function HJSON(tab)
    local str = "H"
    pcall(function ()
        str = __encode(tab)
    end)
    return str
end
local md5Tabs = {}
function DataTableManager:ctor(procBattle)
    if procBattle then
        self:initProcBattle() 
        return
    end
    -- -- 识别语言
    -- if cc.Application then
    --     local luabridge
    --     local platform = cc.Application:getInstance():getTargetPlatform()
    --     if cc.PLATFORM_OS_IPHONE == platform
    --         or cc.PLATFORM_OS_IPAD == platform then
    --         luabridge = require "cocos.cocos2d.luaoc"
    --         local ret, lkey = luabridge.callStaticMethod("AppController", "getSystemLanguage")
    --         GameStatic.languageKey = lkey
    --         LANGUAGE = require "game.config.lang.iosLangTable"
    --     elseif cc.PLATFORM_OS_ANDROID == platform then
    --         luabridge = require "cocos.cocos2d.luaj"
    --         local ret, lkey = luabridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "getSystemLanguage", {}, "()Ljava/lang/String;")
    --         GameStatic.languageKey = lkey
    --         LANGUAGE = require "game.config.lang.androidLangTable"
    --     else
    --         GameStatic.languageKey = ""
    --     end
    -- end
    -- GameStatic.language = LANGUAGE

    self._isInited = false
    self._tabs = {}
    self._guideTabs = {}

    local _decodeTab = self.decodeTab

    _decodeTab(self, "errorCode")
    _decodeTab(self, "battleVer")
    
    -- 技能BUFF
    _decodeTab(self, "skillBuff", true)
    -- 技能
    _decodeTab(self, "skill", true)
    -- 技能-被动加属性
    _decodeTab(self, "skillPassive", true)
    -- 技能-普攻附带buff
    _decodeTab(self, "skillAttackEffect", true)
    -- 技能-特殊处理部分
    _decodeTab(self, "skillCharacter", true)
    -- 怪兽
    _decodeTab(self, "team", true)
    _decodeTab(self, "potential")
    _decodeTab(self, "potentialAttr")

    _decodeTab(self, "npc")
    
    -- avatar
    _decodeTab(self, "roleAvatar")
    _decodeTab(self, "avatarFrame")

    -- 怪兽等级
    _decodeTab(self, "teamLevel", true)  

    -- 符文等级
    _decodeTab(self, "equipment", true)  

    -- 符文等级
    _decodeTab(self, "equipmentLevel")  

    -- 怪兽星
    _decodeTab(self, "star", true)  

    -- 技能升级
    _decodeTab(self, "levelSkill")  

    -- 种族
    _decodeTab(self, "race", true)

    -- 道具
    _decodeTab(self, "tool", true)

    if GLOBAL_VALUES.LANGUAGE == "cn" or GLOBAL_VALUES.LANGUAGE == "" then
        _decodeTab(self, "lang")
    else
        _decodeTab(self, "lang_" .. GLOBAL_VALUES.LANGUAGE)
    end
    if GLOBAL_VALUES.LANGUAGE == "cn" or GLOBAL_VALUES.LANGUAGE == "" then
        _decodeTab(self, "langvalue")
    else
        _decodeTab(self, "langvalue_" .. GLOBAL_VALUES.LANGUAGE)
    end

    -- 设置表
    _decodeTab(self, "setting", true)   

    _decodeTab(self, "toolSkillLevel")


    --玩家技能背包
    _decodeTab(self, "toolSkillBook")

    -- 攻城战表
    _decodeTab(self, "siege", true)

    -- 副本表
    _decodeTab(self, "mainStage", true)

    _decodeTab(self, "mainSection", true)

    _decodeTab(self, "mainChapter")

    _decodeTab(self, "sectionInfo", true)
   
    _decodeTab(self, "mainStory")

    --玩家技能合成
    _decodeTab(self, "playerSkillComposition")

    --礼包数据表
    _decodeTab(self, "toolGift")
    _decodeTab(self, "equipmentBox")

    --怪兽经验
    _decodeTab(self, "toolExp")

    --玩家技能
    _decodeTab(self, "playerSkill")

    --英雄技能效果
    _decodeTab(self, "playerSkillEffect", true)

    --英雄技能等级
    _decodeTab(self, "playerSkillExp")

    -- 图腾表
    _decodeTab(self, "object", true)

    -- 布阵
    _decodeTab(self, "classPosition")
    _decodeTab(self, "godWarPosition")
    _decodeTab(self, "formation_build")
    _decodeTab(self, "formation_team")
    _decodeTab(self, "formation_hero")

    -- 英雄表
    _decodeTab(self, "hero", true)
    _decodeTab(self, "npcHero", true)
    -- 英雄皮肤表
    _decodeTab(self, "heroSkin")
    -- 英雄装备表
    _decodeTab(self, "artifact")
    -- 英雄装备特效表
    _decodeTab(self, "artiEffect")

    -- 英雄专精专长表
    _decodeTab(self, "heroMastery", true)
    -- 英雄传记
    _decodeTab(self, "heroBio")
    _decodeTab(self, "heroStage")

    -- 玩家等级信息表
    _decodeTab(self, "userLevel")

    -- 怪兽成长显示
    _decodeTab(self, "artifact")

    -- 副本关卡地图
    _decodeTab(self, "mainStageMap", true)

    -- 副本章节地图
    _decodeTab(self, "mainSectionMap", true)
    
    -- 任务
    _decodeTab(self, "task")
    _decodeTab(self, "activeAward")
    _decodeTab(self, "growAward")
    _decodeTab(self, "awakingTask")
    
    -- 图鉴
    _decodeTab(self, "teamPokedex")
    _decodeTab(self, "tujian", true)
    _decodeTab(self, "tujianshengji")
    _decodeTab(self, "tujianpingjia")
    _decodeTab(self, "tujianjiesuo")
    _decodeTab(self, "heroPower", true)

    -- 充值,vip
    _decodeTab(self, "payment")
    _decodeTab(self, "vip")

    -- 竞技场
    _decodeTab(self, "arenaHonor")
    _decodeTab(self, "arenaHero")
    _decodeTab(self, "arenaNpc")
    _decodeTab(self, "arenaHighShop")
    _decodeTab(self, "arenaChoose")

    -- 商店
    _decodeTab(self, "shopArena")
    _decodeTab(self, "shopAward")
    _decodeTab(self, "shopCrusade")
    _decodeTab(self, "shopTreasure")
    _decodeTab(self, "shopGuild")
    _decodeTab(self, "shopGuildLimit")
    _decodeTab(self, "specialshop")
    _decodeTab(self, "specialshopauditing")
    _decodeTab(self, "shopExp")
    _decodeTab(self, "shopElement")
    _decodeTab(self, "shopSlot")

    
    -- 刷新及购买消耗配置表
    _decodeTab(self, "reflashCost")

    -- pve
    _decodeTab(self, "pveSetting")
    _decodeTab(self, "dwarfDailyReward")
    _decodeTab(self, "dwarfWeeklyReward")
    _decodeTab(self, "cryptDailyReward")
    _decodeTab(self, "cryptWeeklyReward")


    --特权
    _decodeTab(self, "peerage")
    _decodeTab(self, "ability")
    _decodeTab(self, "abilityEffect")
    _decodeTab(self, "peerShop")

    --邮件
    _decodeTab(self, "mail")
    -- 系统开启
    _decodeTab(self, "systemOpen", true)

    -- 远征
    _decodeTab(self, "crusadeMain")
    _decodeTab(self, "crusadeMap")
    _decodeTab(self, "crusadeBuffPic")

    
    _decodeTab(self, "crusadeBuild")
    _decodeTab(self, "crusadeEvent")

    _decodeTab(self, "crusadeTreaPosi")
    
    _decodeTab(self, "name")
    _decodeTab(self, "triggerEvent")

    -- 宝物表
    _decodeTab(self, "comTreasure")
    _decodeTab(self, "disTreasure")
    _decodeTab(self, "devDisTreasure")
    _decodeTab(self, "devComTreasure")
    _decodeTab(self, "drawTreasure")
    _decodeTab(self, "drawTreasureTe")
    _decodeTab(self, "comTreasureStar")
    _decodeTab(self, "comTreasureSkill")
    
    -- 抽卡预览
    _decodeTab(self, "choukashow")

    --法术书
    _decodeTab(self, "scrollHotSpot")
    _decodeTab(self, "scrollTemplate")
    _decodeTab(self, "skillBookBase", true)
    _decodeTab(self, "shopSkillBook")
    --法术天赋
    _decodeTab(self, "skillBookTalent")
    --法术天赋升级消耗
    _decodeTab(self, "skillBookTalentExp") 
    
    -- 副本支线
    _decodeTab(self, "branchStage", true)
    _decodeTab(self, "branchMonsterStage")
    -- 副本支线对话
    _decodeTab(self, "branchDialogue")
    -- 副本市场
    _decodeTab(self, "branchShop")

    _decodeTab(self, "teamQuality", true)

    -- 活动
    _decodeTab(self, "activityopen")
    _decodeTab(self, "activityopen_dev")
    _decodeTab(self, "dailyActivity")
    _decodeTab(self, "dailyActivityTask")
    _decodeTab(self, "dailyActivityCondition")
    _decodeTab(self, "actPlus")
    _decodeTab(self, "weeklyGift")
    _decodeTab(self, "lotterySetting")
    _decodeTab(self, "actExReward")

    -- 单笔充值
    _decodeTab(self, "actSingleRecharge")

    -- 英雄交锋
    _decodeTab(self, "acheroDuel")
    

    -- 1元购
    _decodeTab(self, "acRmb")

    -- 动态单笔充值
    _decodeTab(self, "intelligentRechargePrize")

    -- 商品库
    _decodeTab(self, "cashGoodsLib")

    -- 每日充值
    _decodeTab(self, "activity102")
    _decodeTab(self, "activity101")
    --分享有礼
    _decodeTab(self, "activity99")
    
    -- 嘉年华
    _decodeTab(self, "activity901")
    _decodeTab(self, "activity908")
    _decodeTab(self, "activity910")
    _decodeTab(self, "activity911")
    _decodeTab(self, "activity912")
    _decodeTab(self, "sevenAimConst")
    -- 7日
    _decodeTab(self, "activity902")
    -- 等级
    _decodeTab(self, "activity903")
    -- 半月
    _decodeTab(self, "activity904")
    -- 大富翁
    _decodeTab(self, "activity907")
    _decodeTab(self, "activity907gift")
    _decodeTab(self, "activity907dice")
    -- 广告
    _decodeTab(self, "advertise")

    --等级战力送绿龙
    _decodeTab(self, "combatRankAward")
    _decodeTab(self, "combatStageAward")

    --领体力
    _decodeTab(self, "dailyPhyscal")

    -- 气泡
    _decodeTab(self, "qipao")
    _decodeTab(self, "activityqipao")
    _decodeTab(self, "systemDes")

    -- 签到
    _decodeTab(self, "sign")
    _decodeTab(self, "signCount")
    _decodeTab(self, "signShare")

    -- 公测庆典 集字兑换
    _decodeTab(self, "celebrationExchange")
    -- 公测庆典 好友狂欢
    _decodeTab(self, "celebrationFriend")
    _decodeTab(self, "celebrationSetting")

    -- 幸运抽奖（圣徽）
    _decodeTab(self, "runeLottery")
    _decodeTab(self, "itemType")
    _decodeTab(self, "lotteryReward")
    _decodeTab(self, "shopLotteryReward")

    -- 圣徽周卡
    _decodeTab(self, "activity108")

    -- 好友邀请
    _decodeTab(self, "activityInviteNew")
    
    -- 表情
    _decodeTab(self, "emoji")

    -- 学院
    _decodeTab(self, "magicSeries")
    _decodeTab(self, "magicTalent")

    -- MF
    _decodeTab(self, "mfTask")
    _decodeTab(self, "mfOpen")

    -- 联盟
    _decodeTab(self, "guildPoint")
    _decodeTab(self, "guildRoad")
    _decodeTab(self, "guildFlag")
    _decodeTab(self, "technologyBase")
    _decodeTab(self, "technologyChild")
    _decodeTab(self, "guildContriReward")

    _decodeTab(self, "guildLevel")
    _decodeTab(self, "guildContribution")
    _decodeTab(self, "guildRed")
    _decodeTab(self, "guildUserRed")
    _decodeTab(self, "guildSystemDes")
    _decodeTab(self, "randomRed")

    _decodeTab(self, "zengyuan")

    -- 联盟探索
    _decodeTab(self, "guildMap")
    _decodeTab(self, "guildMap1")
    _decodeTab(self, "guildMap2")
    _decodeTab(self, "guildMap3")
    _decodeTab(self, "guildMap4")
    _decodeTab(self, "guildMap5")
    _decodeTab(self, "guildMap6")
    _decodeTab(self, "guildMap7")
    _decodeTab(self, "guildMap8")
    _decodeTab(self, "guildMap9")
    _decodeTab(self, "guildMap10")
    _decodeTab(self, "guildMap11")
         
    _decodeTab(self, "guildCenterMap")
    _decodeTab(self, "guildCenterMap2")  
    _decodeTab(self, "guildMapThing")
    _decodeTab(self, "guildMapReport")
    _decodeTab(self, "guildMapTask")
    _decodeTab(self, "guildMapSetting")
    _decodeTab(self, "guildMapTujian")
    _decodeTab(self, "guildEquipment")    
    _decodeTab(self, "guildMapActiv")   
    _decodeTab(self, "guildCenterMap2")
    _decodeTab(self, "guildMapInfo")
    _decodeTab(self, "sphinxGuildRank")   
    _decodeTab(self, "sphinxPersonRank")
    _decodeTab(self, "sphinxQuestion")
    _decodeTab(self, "sphinxZhongqiu")
    
    --联盟秘境
    _decodeTab(self, "famAppear")
    _decodeTab(self, "famFight")
    _decodeTab(self, "famWitch")
    _decodeTab(self, "famMap")
    
    
    -- 获取途径
    _decodeTab(self, "static")
    _decodeTab(self, "prompt")

    -- 积分联赛
    _decodeTab(self, "leagueRank")
    _decodeTab(self, "leagueHonor")
    _decodeTab(self, "shopLeague")
    _decodeTab(self, "leagueReward")
    _decodeTab(self, "leagueAct")

    -- 按时间开启的表
    _decodeTab(self, "sTimeOpen", true)
   
    -- 战力标准表 废弃
    _decodeTab(self, "standard")
    -- 失败结算标准表
    _decodeTab(self, "standardopen")
    _decodeTab(self, "standardscore")


    -- 云中城
    _decodeTab(self, "towerFloor")
    _decodeTab(self, "towerStage")
    _decodeTab(self, "towerFight")

    --射箭小游戏
    _decodeTab(self, "arrow")
    _decodeTab(self, "arrowAward")

    --训练所 
    _decodeTab(self, "training")
    _decodeTab(self, "trainingCup")
    _decodeTab(self, "evaluate")
    _decodeTab(self, "trainingRank")
    _decodeTab(self, "trainingAward")

    -- 兵团技巧
    _decodeTab(self, "technique")
    _decodeTab(self, "commentTeam")

    -- 巢穴
    _decodeTab(self, "nests")

    -- -- 领土战争
    _decodeTab(self, "cityBattleMap")
    _decodeTab(self, "cityBattlePrepare")
    _decodeTab(self, "cityBattleReward")
    _decodeTab(self, "cityBattlePrivilege")
    _decodeTab(self, "cityBattle")
    _decodeTab(self, "cityBattlePrepareReward")
    _decodeTab(self, "cityBattleHonor")
    _decodeTab(self, "shopCityBattle")
    _decodeTab(self, "cityBattleSbDes")
    _decodeTab(self, "cityBattleSbuff")

    -- -- 英雄solo
    _decodeTab(self, "heroSoloMotion")
    _decodeTab(self, "heroSoloGroup")
    _decodeTab(self, "heroSoloSpecial")

    -- 副本表
    _decodeTab(self, "mainShadeMap")
    _decodeTab(self, "branchHeroAdd")
    _decodeTab(self, "mainPlot", true)
    _decodeTab(self, "mainTask", true)
    _decodeTab(self, "mainPlotReview")
    
    
    -- 弹幕
    _decodeTab(self, "bullet")

    -- 英雄交锋
    _decodeTab(self, "heroDuel")
    _decodeTab(self, "heroDuelSelect")
    _decodeTab(self, "heroDuelAward")
    _decodeTab(self, "heroDuelSeason")
    _decodeTab(self, "heroDuejx")
    _decodeTab(self, "shopHeroDuel")
    _decodeTab(self, "systemOn")
    _decodeTab(self, "heroDuejx")

    -- 分享
    _decodeTab(self, "shareAward", true)
    --评论引导
    _decodeTab(self, "comaward", true)
    _decodeTab(self, "comterm", true)
    --分享好礼
    _decodeTab(self, "shareActivity", true)

    -- loading
    _decodeTab(self, "loading", true)

    -- qq特权和VIP
    _decodeTab(self, "qqVIP", true)

    --显示兵团
    _decodeTab(self, "limitTeamConfig")
    _decodeTab(self, "limitTeamBox")
    _decodeTab(self, "limitItemsDynamic")
    _decodeTab(self, "limitItemsConfig")
    _decodeTab(self, "limitItemsBox")
    _decodeTab(self, "limitTeamDynamic")

    -- 争霸赛
    _decodeTab(self, "shopGodWar")
    _decodeTab(self, "godWarRank")
    _decodeTab(self, "godWarTimer")
    _decodeTab(self, "godWarRed")
    _decodeTab(self, "godWarMove")

    -- 领主手册
    _decodeTab(self, "gameplayOpen", true)
    _decodeTab(self, "adventureQuest", true)

    --主界面白名单
    _decodeTab(self, "mainiconwhitelist")

    --周签到
    _decodeTab(self, "weeklySign")

    --位面配表
    _decodeTab(self, "elementalPlane1")
    _decodeTab(self, "elementalPlane2")
    _decodeTab(self, "elementalPlane3")
    _decodeTab(self, "elementalPlane4")
    _decodeTab(self, "elementalPlane5")

    -- 攻城战
    _decodeTab(self, "siegeWeaponType")
    _decodeTab(self, "siegeWeapon") 
    _decodeTab(self, "siegePower") 
    _decodeTab(self, "siegeWeaponExp")
    _decodeTab(self, "drawSWShow")
    _decodeTab(self, "siegeWeaponNpc")
    _decodeTab(self, "siegeOpenPoints")


    _decodeTab(self, "elementSkillPara")


    --攻城战配置
    _decodeTab(self, "siegeSetting")
    _decodeTab(self, "siegeMainSection", true)
    _decodeTab(self, "siegeMainStageMap")
    _decodeTab(self, "siegeMainStage")
    _decodeTab(self, "siegeWallBuild")
    _decodeTab(self, "siegeMainPlot")
    

    --攻城战日常  
    _decodeTab(self, "siegeBasicBattle")
    _decodeTab(self, "siegeBasicWeeklyReward")
    _decodeTab(self, "siegeBasicDailyReward")

    --攻城战剧情
    _decodeTab(self, "siegeMainStageMap")
    _decodeTab(self, "siegeSectionInfo")

    _decodeTab(self, "siegeEquip")
    _decodeTab(self, "siegeEquipExp")

    _decodeTab(self, "siegeMainStage")
    _decodeTab(self, "siegePeriodAward")
    _decodeTab(self, "siegeAward")

    _decodeTab(self, "siegeRank")
    _decodeTab(self, "siegeBattleGroup")

    _decodeTab(self, "siegeSkillDes")
    _decodeTab(self, "siegeDialog")
    _decodeTab(self, "siegeDailyAtkBuff")
    
    -- 攻城战分支
    _decodeTab(self, "siegeBranchStage")
    _decodeTab(self, "siegeBranchDialogue")

    _decodeTab(self, "svEnforcement")
   
    _decodeTab(self, "elementSkillPara")

    --联盟佣兵配表
    _decodeTab(self, "lansquenet")

    --好友召回
    _decodeTab(self, "friendQuest")
    _decodeTab(self, "friendShop")

    --法术特训
    _decodeTab(self, "magicTraining")
    _decodeTab(self, "magicTrainingCfg")
    _decodeTab(self, "magicTrainingRank")

    -- 跨服竞技场
    _decodeTab(self, "cpServerScore")
    _decodeTab(self, "cpLimitBattle")
    _decodeTab(self, "cpRegionSwitch")
    _decodeTab(self, "cpRankReward")
    _decodeTab(self, "cpShop")
    _decodeTab(self, "cpBuffDes")
    _decodeTab(self, "cpSeverBuff")
    _decodeTab(self, "cpActiveReward")


    -- 兵团宝石
    _decodeTab(self, "rune")
    _decodeTab(self, "runeSlot")
    _decodeTab(self, "runeClient")
    _decodeTab(self, "runeDisintegration")
    _decodeTab(self, "runeCasting")
    _decodeTab(self, "runeAwake")
    _decodeTab(self, "shopRune")
    _decodeTab(self, "shopRuneReward")
    _decodeTab(self, "attClient")

	_decodeTab(self, "runeCastingMastery")


    -- 主城小物件
    _decodeTab(self, "gadgetReward")
    _decodeTab(self, "gadgetConfig")
    _decodeTab(self, "gadgetTime")

    _decodeTab(self,"indulge")

    --春节红包
    _decodeTab(self, "actRedPacket")

    -- _decodeTab(self,"skillBookTalent")
    -- _decodeTab(self,"skillBookTalentExp")

    -- 爬塔
    _decodeTab(self, "purRank")
    _decodeTab(self, "purFight")
    _decodeTab(self, "purBuff")
    _decodeTab(self, "purAccuReward")

    --领主管家
    _decodeTab(self, "lordManager")
    --星图
    _decodeTab(self, "starChartsStars")
    _decodeTab(self, "starPosition")
    _decodeTab(self, "starCharts")
    _decodeTab(self, "starChartsCatena")

    _decodeTab(self, "leagueHeroOrder")
    
end

function DataTableManager:antiInit()
    self._isInited = false
end

function DataTableManager:clear()
    self._isInited = false
    local filename
    local aliasname
    for i = 1, #self._tabs do
        filename = self._tabs[i]
        if find(filename, "lang_") == 1 then
            aliasname = "lang"
        else
            if find(filename, "langvalue_") == 1 then
                aliasname = "langvalue"
            else
                aliasname = filename
            end
        end
        self[aliasname] = nil
        self[string.upper(string.sub(aliasname, 1, 1)) .. string.sub(aliasname, 2, string.len(aliasname))] = nil
    end
    ScheduleMgr:unregSchedule(self._updateId)
end

function DataTableManager:_decodeTab(filename)
    -- tab文件 filename.lua
    -- 添加变量 self.filename
    -- 添加方法 self:Filename(key)
    -- 获取全部数据 self.filename
    local aliasname
    if find(filename, "lang_") == 1 then
        aliasname = "lang"
    else
        if find(filename, "langvalue_") == 1 then
            aliasname = "langvalue"
        else
            aliasname = filename
        end
    end
    local __tab = self[aliasname]
    if __tab then return end
    print("tab: "..aliasname,filename)
    self[aliasname] = require(filename)
    if filename == "npc" then
        npcExtend = require(filename .. "1")
        table.merge(self[aliasname],npcExtend)
    end
    __tab = self[aliasname]
    self[string.upper(string.sub(aliasname, 1, 1)) .. string.sub(aliasname, 2, string.len(aliasname))] = function(self, key)
        if __tab[key] then
            return __tab[key]
        else
            --PCLuaError("tab [" .. aliasname.."] not found id ["..key .."]")
            if key == nil then
                print("tab [" .. aliasname.."] key 为空")
            else
                print("tab [" .. aliasname.."] not found id ["..tostring(key) .."]")
            end
            return nil
        end
    end
    if self["extend_"..aliasname] then
        self["extend_"..aliasname](self)
    end

    -- 生成表格签名
    if not BATTLE_PROC then
        if GameStatic.checkTable then
            local kind = signatureTabs[aliasname]
            if kind ~= nil then
                local md5, tabstring, md5TabsFile
                if kind == 1 then
                    tabstring = HJSON(__tab)
                    md5 = __md5(__pctool, tabstring)
                    md5Tabs[aliasname] = md5
                elseif kind >= 2 then
                    md5Tabs[aliasname] = {}
                    md5TabsFile = md5Tabs[aliasname]
                    for k, v in pairs(__tab) do
                        tabstring = HJSON(v)
                        md5 = __md5(__pctool, tabstring)
                        md5TabsFile[k] = md5
                    end
                end
            end
        end
    end
end

-- 后台切回来, 检查全部表
function DataTableManager:checkAllSignatureTabs()
    local _tab, tabstring, md5
    local ErrorList = {}
    local first = true
    for filename, kind in pairs(signatureTabs) do
        _tab = self[filename]
        if _tab then
            if kind == 1 then
                tabstring = HJSON(_tab)
                md5 = __md5(__pctool, tabstring)
                if md5Tabs[filename] ~= md5 then
                    if first then
                        if md5Tabs[filename] then
                            ErrorList[filename] = tabstring .. "#" .. md5Tabs[filename] .. "#" .. md5
                        else
                            ErrorList[filename] = tabstring .. "#" .. "nil" .. "#" .. md5
                        end
                        first = false
                    else
                        ErrorList[filename] = md5Tabs[filename] .. "#" .. md5
                    end
                end
            elseif kind == 2 then
                if md5Tabs[filename] then
                    for k, v in pairs(_tab) do
                        tabstring = HJSON(v)
                        md5 = __md5(__pctool, tabstring)
                        if md5Tabs[filename][k] ~= md5 then
                            if first then
                                if md5Tabs[filename][k] then
                                    ErrorList[filename] = tabstring .. "#" .. md5Tabs[filename][k] .. "#" .. md5
                                else
                                    ErrorList[filename] = tabstring .. "#" .. "nil" .. "#" .. md5
                                end
                                first = false
                            else
                                ErrorList[filename] = md5Tabs[filename][k] .. "#" .. md5
                            end
                            break
                        end
                    end
                end
            end
        end
    end
    local res = ""
    for filename, _ in pairs(ErrorList) do
        res = res .. filename .. ":" .. _ .. "\n"
        print("重新载入表格"..filename)
        -- 重新载入表格
        local tmp = self[filename]
        self[filename] = nil
        self[string.upper(string.sub(filename, 1, 1)) .. string.sub(filename, 2, string.len(filename))] = nil
        if OS_IS_64 then
            package.loaded[filename.."64"] = nil
        else
            package.loaded[filename] = nil
        end
        self:_decodeTab(filename)
        if OS_IS_WINDOWS then
            local new = self[filename]
            for k, v in pairs(tmp) do
                if HJSON(new[k]) ~= HJSON(v) then
                    print("表被修改", filename, k, HJSON(new[k]), HJSON(v))
                end
            end
        end
        tmp = nil
    end
    if res == "" then
        res = nil
    end
    -- print(res)
    return res
end

-- 战前检查配置表是否被修改
function DataTableManager:checkSignatureTabs(teams, npcs, heroMap, npcHeroMap, intanceD, branchD, cctD, siegeId)
    local res
    pcall(function ()
        res = self:_checkSignatureTabs(teams, npcs, heroMap, npcHeroMap, intanceD, branchD, cctD, siegeId)
    end)
    return res
end
function DataTableManager:_checkSignatureTabs(teams, npcs, heroMap, npcHeroMap, intanceD, branchD, cctD, siegeId)
    local _tab, tabstring, md5
    -- 检查这些表, 由于比较小, 所以全部查
    -- skill = 1, skillPassive = 1, skillAttackEffect = 1, skillCharacter = 1, skillBuff = 1, teamPokedex = 1,object = 1, 
    -- heroMastery = 1, playerSkillEffect = 1,  comTreasure = 1, disTreasure = 1,
    local ErrorList = {}
    local res = ""
    local first = true
    for filename, kind in pairs(signatureTabs) do
        _tab = self[filename]
        if _tab then
            if kind == 1 then
                tabstring = HJSON(_tab)
                md5 = __md5(__pctool, tabstring)
                if md5Tabs[filename] ~= md5 then
                    if first then
                        if md5Tabs[filename] then
                            ErrorList[filename] = tabstring .. "#" .. md5Tabs[filename] .. "#" .. md5
                        else
                            ErrorList[filename] = tabstring .. "#" .. "nil" .. "#" .. md5
                        end
                        first = false
                    else
                        ErrorList[filename] = md5Tabs[filename] .. "#" .. md5
                    end
                    res = res .. filename .. ":" .. ErrorList[filename] .. "\n"
                end
            end
        end
    end
    -- 检查team表
    if teams then
        local teamTab = self.team
        if teamTab then
            local teamD, equipD, eid, teamid
            for _teamid, _ in pairs(teams) do
                teamid = _teamid % 100000000
                teamD = teamTab[teamid]
                if teamD then
                    tabstring = HJSON(teamD)
                    md5 = __md5(__pctool, tabstring)
                    if md5Tabs["team"][teamid] ~= md5 then
                        -- dump(teamD)
                        if first then
                            if md5Tabs["team"][teamid] then
                                ErrorList["team"] = tabstring .. "#" .. md5Tabs["team"][teamid] .. "#" .. md5
                            else
                                ErrorList["team"] = tabstring .. "#" .. "nil" .. "#" .. md5
                            end
                            first = false
                        else
                            ErrorList["team"] = md5Tabs["team"][teamid] .. "#" .. md5
                        end
                        res = res .. "team_" .. teamid .. ":" .. ErrorList["team"] .. "\n"
                        break
                    end
                    for i = 1, 4 do
                        eid = teamD["equip"][i]
                        equipD = self.equipment[eid]
                        if equipD then
                            tabstring = HJSON(equipD)
                            md5 = __md5(__pctool, tabstring)
                            if md5Tabs["equipment"][eid] ~= md5 then
                                -- dump(equipD)
                                if first then
                                    if md5Tabs["equipment"][eid] then
                                        ErrorList["equipment"] = tabstring .. "#" .. md5Tabs["equipment"][eid] .. "#" .. md5
                                    else
                                        ErrorList["equipment"] = tabstring .. "#" .. "nil" .. "#" .. md5
                                    end
                                    first = false
                                else
                                    ErrorList["equipment"] = md5Tabs["equipment"][eid] .. "#" .. md5
                                end
                                res = res .. "equipment_" .. eid .. ":" .. ErrorList["equipment"] .. "\n"
                                break
                            end
                        end
                    end
                    if not first then
                        break
                    end
                end
            end
        end
    end
    -- 检查npc表
    if npcs then
        local npcTab = self.npc
        if npcTab then
            for npcid, _ in pairs(npcs) do
                tabstring = HJSON(npcTab[npcid])
                md5 = __md5(__pctool, tabstring)
                if md5Tabs["npc"][npcid] ~= md5 then
                    -- dump(npcTab[npcid])
                    if first then
                        if md5Tabs["npc"][npcid] then
                            ErrorList["npc"] = tabstring .. "#" .. md5Tabs["npc"][npcid] .. "#" .. md5
                        else
                            ErrorList["npc"] = tabstring .. "#" .. "nil" .. "#" .. md5
                        end
                        first = false
                    else
                        ErrorList["npc"] = md5Tabs["npc"][npcid] .. "#" .. md5
                    end
                    res = res .. "npc_" .. npcid .. ":" .. ErrorList["npc"] .. "\n"
                    break
                end
            end
        end
    end
    -- 检查英雄表
    if heroMap then
        local heroTab = self.hero
        if heroTab then
            for heroid, _ in pairs(heroMap) do
                tabstring = HJSON(heroTab[heroid])
                md5 = __md5(__pctool, tabstring)
                if md5Tabs["hero"][heroid] ~= md5 then
                    -- dump(heroTab[heroid])
                    res = res.. "hero " .. heroid .. "\n"
                    ErrorList["hero"] = true
                    break
                end
            end
        end
    end
    -- 检查npc英雄表
    if npcHeroMap then
        local heroTab = self.npcHero
        if heroTab then
            for heroid, _ in pairs(npcHeroMap) do
                tabstring = HJSON(heroTab[heroid])
                md5 = __md5(__pctool, tabstring)
                if md5Tabs["npcHero"][heroid] ~= md5 then
                    -- dump(heroTab[heroid])
                    res = res.. "npcHero " .. heroid .. "\n"
                    ErrorList["npcHero"] = true
                    break
                end
            end
        end
    end
    -- 检查副本表, 只有在打副本的时候才检查
    if intanceD then
        tabstring = HJSON(intanceD)
        md5 = __md5(__pctool, tabstring)
        if md5Tabs["mainStage"][intanceD["id"]] and md5Tabs["mainStage"][intanceD["id"]] ~= md5 then
            -- dump(intanceD)
            res = res.. "mainStage " .. intanceD["id"] .. "\n"
            ErrorList["mainStage"] = true
        end
    end
    if branchD then
        tabstring = HJSON(branchD)
        md5 = __md5(__pctool, tabstring)
        if md5Tabs["branchMonsterStage"][branchD["id"]] and md5Tabs["branchMonsterStage"][branchD["id"]] ~= md5 then
            -- dump(branchD)
            res = res.. "branchMonsterStage " .. branchD["id"] .. "\n"
            ErrorList["branchMonsterStage"] = true
        end
    end
    -- 检查云中城表
    if cctD then
        tabstring = HJSON(cctD)
        md5 = __md5(__pctool, tabstring)
        if md5Tabs["towerFight"][cctD["id"]] ~= md5 then
            -- dump(cctD)
            res = res.. "towerFight " .. cctD["id"] .. "\n"
            ErrorList["towerFight"] = true
        end
    end
    -- 检查攻城战表
    if siegeId then
        tabstring = HJSON(self.siege[siegeId])
        md5 = __md5(__pctool, tabstring)
        if md5Tabs["siege"][siegeId] ~= md5 then
            -- dump(self.siege[siegeId])
            res = res.. "siege " .. siegeId .. "\n"
            ErrorList["siege"] = true
        end
    end
    for filename, _ in pairs(ErrorList) do
        print("重新载入表格"..filename)
        -- 重新载入表格
        self[filename] = nil
        self[string.upper(string.sub(filename, 1, 1)) .. string.sub(filename, 2, string.len(filename))] = nil
        if OS_IS_64 then
            package.loaded[filename.."64"] = nil
        else
            package.loaded[filename] = nil
        end
        self:_decodeTab(filename)
    end
    if res == "" then
        res = nil
    end
    print(res)
    return res
end

function DataTableManager:_procDecodeTab(filename)
    if self[filename] then return end
    self[filename] = require(filename)
    if self["extend_"..filename] then
        self["extend_"..filename](self)
    end
end

function DataTableManager:decodeTab(filename, isGuide)
    self._tabs[#self._tabs + 1] = filename
    if isGuide then
        self._guideTabs[#self._guideTabs + 1] = filename
    end
end

-- 初始化配置表 
-- 例如item表 通过 tab:Item(key) 来获取
-- key可以是字符串 也可以是数字, 要和表中一致

-- 取出全部数据
-- tab.item

-- 只需要把config中用到的表添加在这里即可

function DataTableManager:getInitCount(isGuide, dontInit)
    if dontInit then return 0 end
    if not self._isInited then
        if isGuide then
            return #self._guideTabs
        else
            return #self._tabs
        end
    else
        return 0
    end
end

function DataTableManager:initTab_Async(_type, proCallback, endCallback)
    self._proCallback = proCallback
    self._endCallback = endCallback

    if not self._isInited then
        self._decodeIndex = 0
        self._updateId = ScheduleMgr:regSchedule(1, self, function(self, dt)
            self:update(dt)
        end)
    else
        self._endCallback()
        return 0
    end
    if _type == 1 then
        -- 全部异步加载
        self._asyncTabs = self._tabs
    else
        -- 假新手引导异步加载
        self._asyncTabs = self._guideTabs
    end
    self._asyncType = _type
    return #self._asyncTabs
end

local clock = os.clock
function DataTableManager:update(dt)
    local tick = clock()
    local count = 0
    while self._decodeIndex < #self._asyncTabs do
        count = count + 1
        self._decodeIndex = self._decodeIndex + 1
        trycall("_decodeTab", self._decodeTab, self, self._asyncTabs[self._decodeIndex])
        if self._asyncType == 1 then
            if clock() - tick > 0.030 then
                break
            end
        else
            break
        end
    end
    self._proCallback(count)
    if self._decodeIndex == #self._asyncTabs then
        ScheduleMgr:unregSchedule(self._updateId)
        self:extend()
        if CHECK_TABLE then
            self:check()
        end
        self._endCallback()
        self._isInited = true
    end
end

function DataTableManager:initTab_Sync()
    if not self._isInited then
        for i = 1, #self._tabs do
            self:_decodeTab(self._tabs[i])
        end
        self:extend()
        if CHECK_TABLE then
            self:check()
        end
        self._isInited = true
    end
end

-- 复盘使用
function DataTableManager:initProcBattle()
    local _procDecodeTab = self._procDecodeTab
    _procDecodeTab(self, "battleVer")
    _procDecodeTab(self, "team")
    _procDecodeTab(self, "skillBuff")
    _procDecodeTab(self, "skill")
    _procDecodeTab(self, "skillPassive")
    _procDecodeTab(self, "skillAttackEffect")
    _procDecodeTab(self, "skillCharacter")
    _procDecodeTab(self, "npc")
    _procDecodeTab(self, "teamPokedex")
    _procDecodeTab(self, "object")
    _procDecodeTab(self, "hero")
    _procDecodeTab(self, "heroMastery")
    _procDecodeTab(self, "playerSkillEffect")
    _procDecodeTab(self, "equipment")

    _procDecodeTab(self, "comTreasure")
    _procDecodeTab(self, "disTreasure")
    _procDecodeTab(self, "comTreasureStar")

    _procDecodeTab(self, "userLevel")
    _procDecodeTab(self, "magicSeries")
    _procDecodeTab(self, "magicTalent")

    _procDecodeTab(self, "mainStage")
    _procDecodeTab(self, "towerFight")
    _procDecodeTab(self, "siege")
    _procDecodeTab(self, "branchMonsterStage")
    _procDecodeTab(self, "npcHero")
    _procDecodeTab(self, "heroSkin")

    _procDecodeTab(self, "pveSetting")
    _procDecodeTab(self, "training")

    _procDecodeTab(self, "technique")

    _procDecodeTab(self, "crusadeMain")

    _procDecodeTab(self, "elementalPlane1")
    _procDecodeTab(self, "elementalPlane2")
    _procDecodeTab(self, "elementalPlane3")
    _procDecodeTab(self, "elementalPlane4")
    _procDecodeTab(self, "elementalPlane5")

    _procDecodeTab(self, "elementSkillPara")

    _procDecodeTab(self, "skillBookBase")

    _procDecodeTab(self, "siegeBattleGroup")
    _procDecodeTab(self, "siegeWallBuild")
    _procDecodeTab(self, "siegeEquip")
    _procDecodeTab(self, "siegeWeapon")

    _procDecodeTab(self, "svEnforcement")
    _procDecodeTab(self, "skillBookTalent")
    _procDecodeTab(self, "rune")
    _procDecodeTab(self, "starChartsStars")
    _procDecodeTab(self, "starChartsCatena")
    _procDecodeTab(self, "starCharts")
    _procDecodeTab(self, "attClient")

--    _procDecodeTab(self, "purFight")
end

-- 天使恶魔战斗使用
function DataTableManager:initGuideBattle()
    self:_decodeTab("skillBuff")
    self:_decodeTab("skill")
    self:_decodeTab("skillPassive")
    self:_decodeTab("skillAttackEffect")
    self:_decodeTab("skillCharacter")
    self:_decodeTab("npc")
    self:_decodeTab("siege")
    self:_decodeTab("object")
    self:_decodeTab("hero")
    self:_decodeTab("heroMastery")
    self:_decodeTab("playerSkillEffect")
end

-- 假新手引导读条用
function DataTableManager:initIntanceLoading()
    self:_decodeTab("mainSection")
    self:_decodeTab("mainSectionMap")
end

-- 因为npc表太大了, 所以单独载入
function DataTableManager:initNpc()
    self:_decodeTab("npc")
end

-- 游戏启动后使用
function DataTableManager:initLoading()
    self:_decodeTab("team")

    if GLOBAL_VALUES.LANGUAGE == "cn" or GLOBAL_VALUES.LANGUAGE == "" then
        self:_decodeTab("lang")
    else
        self:_decodeTab("lang_" .. GLOBAL_VALUES.LANGUAGE)
    end
    if GLOBAL_VALUES.LANGUAGE == "cn" or GLOBAL_VALUES.LANGUAGE == "" then
        self:_decodeTab("langvalue")
    else
        self:_decodeTab("langvalue_" .. GLOBAL_VALUES.LANGUAGE)
    end

    -- self:_decodeTab("newlang")
    self:_decodeTab("errorCode")
    self:_decodeTab("roleAvatar")
    self:_decodeTab("loading")
    self:_decodeTab("battleVer")
    if OS_IS_WINDOWS then
        self:_decodeTab("elementSkillPara")
        -- 编辑英雄solo用
        -- self:_decodeTab("heroSoloMotion")
        -- self:_decodeTab("heroSoloGroup")
        -- self:_decodeTab("heroSoloSpecial")
        -- self:_decodeTab("hero")
        -- 宝物分享
        -- self:_decodeTab("comTreasure")
    end

    local _lang = self.lang
    local _langvalue = self.langvalue
    lang = function(key)
        if _lang[key] then
            return _langvalue[_lang[key]] or ""
        else
            return ""
        end
    end
end

function DataTableManager:extend_team()
    -- 为碎片注入teamid属性, 对应碎片合成后的怪兽
    local smallstaradd, value
    local indexTable = {1, 0, 0, 2, 0, 0, 3, 4}
    for k, v in pairs(self.team) do
        -- 计算小星属性
        smallstaradd = v["smallstaradd"]
        local value = {0, 0, 0, 0}
        local newValue = {}
        for i = 1, #smallstaradd do
            value[indexTable[smallstaradd[i][1]]] = value[indexTable[smallstaradd[i][1]]] + smallstaradd[i][2]
            newValue[i] = {value[1], value[2], value[3], value[4]}
        end

        v["smallstaraddcount"] = newValue
    end
end

function DataTableManager:extend_skillBuff()
    -- 安全日志
    local fastFindTab1 = {nil, nil, 9, nil, nil, nil, 11, nil, nil, 10}
    local fastFindTab2 = {}
    fastFindTab2[35] = 1
    fastFindTab2[2] = 2
    fastFindTab2[9] = 3
    fastFindTab2[31] = 4
    fastFindTab2[14] = 5
    fastFindTab2[21] = 6
    fastFindTab2[32] = 7
    if GameStatic.useSR then
        local kind, label
        for k, v in pairs(self.skillBuff) do
            kind = v.kind
            if kind then
                if kind == 2 then
                    v.sr = 12
                elseif kind <= 1 then
                    label = v.label
                    if fastFindTab1[label] then
                        v.sr = fastFindTab1[label]
                    else
                        local addattr = v.addattr
                        if addattr and addattr[1] then
                            local index = fastFindTab2[addattr[1][1]]
                            if index then
                                v.sr = index
                            end
                        end
                    end
                end
            end
        end
    end
end

function DataTableManager:extend_npcHero()
    for k, v in pairs(self.npcHero) do
        v.star = v.herostar
    end
end

function DataTableManager:extend_bullet()
    for k, v in pairs(self.bullet) do
        v.id = k
    end
end

function DataTableManager:extend_newlang()
    local newlang = self.newlang
    local lang = self.lang
    for k, v in pairs(newlang) do
        lang[k] = v
    end
    self.newlang = nil
end

-- 额外对应关系, 需要手动编写
function DataTableManager:extend()
    -- 数据表
    global = function(key)
        if tab:Global(key) then
            return tab:Global(key).value
        else
            return nil 
        end
    end

    -- 为碎片注入teamid属性, 对应碎片合成后的怪兽
    if self.team and self.tool then
        for k, v in pairs(self.team) do
            if self.tool[v["goods"]] then
                self.tool[v["goods"]]["teamId"] = k
            end
        end
    end

    --[[
    -- 向玩家技能合成表追加技能type数据
    for k, v in pairs(self.playerSkillComposition) do
        -- 技能baseId 加阶获得技能背包数据
        if self.skillBook[v["id"] + 1] then
            v["type"] = self.skillBook[v["id"] + 1].type
        end
    end
    ]]
    -- 向材料表追加可合成装备id
    local tempMaterEquip = {}
    for k, v in pairs(self.equipment) do
        self:addMaterEquipId(tempMaterEquip,v,1)
        self:addMaterEquipId(tempMaterEquip,v,2)
        self:addMaterEquipId(tempMaterEquip,v,3)
    end

    -- 系统开启表
    if self.systemOpen then
        if not SystemUtils.isInit() then
            local system
            local ids = {}
            for i, v in pairs(self.systemOpen) do
                ids[#ids + 1] = i
            end
            for i = 1, #ids do
                system = self.systemOpen[ids[i]]
                if system["action"] then
                    self.systemOpen[system["system"] .. "_" .. system["action"]] = {system["openLevel"], system["showLevel"], system["systemOpenTip"]}
                else
                    self.systemOpen[system["system"]] = {system["openLevel"], system["showLevel"], system["systemOpenTip"]}
                end
                
                self.systemOpen[ids[i]] = nil
            end
            SystemUtils.init()
        end
    end
end

function DataTableManager:addMaterEquipId(inTempMaterEquip,inEquip,inIndex)
    local meter = inEquip["mater" .. inIndex]
    if meter == nil  then 
        return 
    end
    if inTempMaterEquip[tostring(meter[1])] == nil then 
        inTempMaterEquip[tostring(meter[1])] = {}
    end
    if self.tool[meter[1]] and 
        inTempMaterEquip[tostring(meter[1])][inEquip.mapid] == nil then 

        if self.tool[meter[1]].equip == nil then 
            self.tool[meter[1]].equip = {}
        end
        inTempMaterEquip[tostring(meter[1])][inEquip.mapid] = true
        table.insert(self.tool[meter[1]].equip,inEquip.id)
    end
end

-- 检查表
function DataTableManager:check()
    self:checkSkill()
end

-- 检查技能表
function DataTableManager:checkSkill()
    local errorTab = {}
    if self.mainStage then
        for k, v in pairs(self.mainStage) do
            local t = {}
            for i = 1, 8 do
                if v["m"..i] then
                    if t[v["m"..i][2]] then
                        errorTab[k] = true
                        break
                    end
                    t[v["m"..i][2]] = true
                end
            end
        end
    end
    if next(errorTab) then
        local str = "副本配置表站位重复: "
        for k, v in pairs(errorTab) do
            str = str .. k .. " " 
        end
        ViewManager:getInstance():showTip(str)
    end

    if self.mail then
        local flag = false
        for i=1,table.nums(self.mail) do
            if not self.mail[i] then
                flag = true
            end
            if flag == true then
                ViewManager:getInstance():showTip("邮件表模板缺少 id==" .. i)
                break
            end
        end
    end
    
    -- if self.qipao then
    --     for i=1,table.nums(self.qipao) do
    --         local flag = false
    --         for k,v in pairs(self.qipao) do
    --             if i == v.rank then
    --                 flag = true
    --                 break
    --             end
    --         end
    --         if flag == false then
    --             ViewManager:getInstance():showTip("气泡表优先级配置错误 ==" .. i)
    --             break
    --         end
    --     end
    -- end


end

function DataTableManager.dtor()
    CHECK_TABLE = nil
    clock = nil
    DataTableManager = nil
    LANGUAGE = nil
    signatureTabs = nil
end

return DataTableManager
