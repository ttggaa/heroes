
-- local BATTLE_TYPE_Fuben = 1
-- local BATTLE_TYPE_Arena = 2
-- local BATTLE_TYPE_AiRenMuWu = 3
-- local BATTLE_TYPE_Zombie = 4
-- local BATTLE_TYPE_Siege = 5
-- local BATTLE_TYPE_BOSS_DuLong = 6
-- local BATTLE_TYPE_BOSS_XnLong = 7
-- local BATTLE_TYPE_BOSS_SjLong = 8
-- local BATTLE_TYPE_Crusade = 9
-- local BATTLE_TYPE_GuildPVE = 10
-- local BATTLE_TYPE_GuildPVP = 11
-- local BATTLE_TYPE_Biography = 12
-- local BATTLE_TYPE_League = 13
-- local BATTLE_TYPE_MF = 14               
-- local BATTLE_TYPE_CloudCity = 15        
-- local BATTLE_TYPE_CCSiege = 16       
-- local BATTLE_TYPE_GVG = 17                
-- local BATTLE_TYPE_GVGSiege = 18   
-- local BATTLE_TYPE_Training = 19
-- local BATTLE_TYPE_Adventure = 20
-- local BATTLE_TYPE_HeroDuel = 21
-- local BATTLE_TYPE_GBOSS_1 = 22
-- local BATTLE_TYPE_GBOSS_2 = 23
-- local BATTLE_TYPE_GBOSS_3 = 24 
-- local BATTLE_TYPE_GodWar = 25
-- local BATTLE_TYPE_Elemental_1 = 26
-- local BATTLE_TYPE_Elemental_2 = 27
-- local BATTLE_TYPE_Elemental_3 = 28
-- local BATTLE_TYPE_Elemental_4 = 29
-- local BATTLE_TYPE_Elemental_5 = 30
-- local BATTLE_TYPE_Siege_Atk = 31
-- local BATTLE_TYPE_Siege_Def = 32
-- local BATTLE_TYPE_Siege_Atk_WE = 33
-- local BATTLE_TYPE_Siege_Def_WE = 34
-- local BATTLE_TYPE_GuildFAM = 35

-- local ERROR_CODE_SUCCESS = 0
-- local ERROR_CODE_WRONG_TYPE = 1 -- 传入战斗类型错误
-- local ERROR_CODE_RUN_ERROR = 2  -- 战中发生lua错误
-- local ERROR_CODE_NO_INTANCEID = 3  -- 没有副本ID
--[[
        1
        副本战斗复盘
        支持: 副本 精英副本 副本攻城战 副本支线
        参数: 
            atk: 左方数据
            intanceId: 副本id
            skill: 技能序列
            npcHero: 是否用npc英雄
        注意:   
            r1为id号
            helpCondition不为空 则不能复盘
 ]]--
 --[[
 		2
        竞技场战斗复盘
        参数: 
            atk: 左方数据
            def: 右方数据
            r1r2: 随机种子
 ]]--
 --[[
        3
        矮人战斗复盘
        参数: 
            atk: 左方数据
            actId: 活动id
            exBattleTime: 额外时间, 单位秒
            r1r2: 随机种子
 ]]--
 --[[
        9
        远征复盘
        参数: 
            atk: 左方数据
            def: 右方数据
            skill: 技能序列
            crusadeId: 远征关卡ID
 ]]--
 --[[
        11
        联盟探索PVP战斗复盘
        参数: 
            atk: 左方数据
            def: 右方数据
 ]]--
 --[[
        13
        积分联赛复盘
        参数: 
            atk: 左方数据
            def: 右方数据
            skill: 技能序列
            r1r2: 随机种子
 ]]--
 --[[
        14
        航海抢夺复盘
        参数: 
            atk: 左方数据
            def: 右方数据
            skill: 技能序列
 ]]--
 
--[[
        15
        云中城复盘
        参数: 
            atk: 左方数据
            cctId: 关卡ID
            cctId2: 使用的buff的关卡ID
            skill: 技能序列
 ]]--
 --[[
        17
        GVG复盘
        参数: 
            atk: 左方数据
            def: 右方数据
            r1r2: 随机种子
 ]]--
--[[
        19
        训练所复盘
        参数: 
            atk: playerInfo 前端传过来的数据
            trainingId: 关卡ID
            skill: 技能序列
 ]]--
 --[[
        20
        大富翁战斗复盘
        参数: 
            atk: 左方数据
            def: 右方数据
            skill: 技能序列
 ]]--
 --[[
        21
        英雄交锋战斗复盘
        参数: 
            atk: 左方数据
            def: 右方数据
            r1r2: 随机种子
 ]]--
 --[[
        25
        众神之战战斗复盘
        参数: 
            atk: 左方数据
            def: 右方数据
            r1r2: 随机种子
 ]]--

 --[[
        26
        元素位面复盘
        支持: 副本 精英副本 副本攻城战 副本支线
        参数: 
            atk: 左方数据
            kind: 副本种类
            level 关卡级别
            skill: 技能序列
 ]]--

 --[[
        31
        攻城战(进攻)(日常)复盘
        参数: 
            atk: 左方数据
            levelid: 关卡id
            skill: 技能序列
 ]]--

--[[
        32
        攻城战(防守)(日常)复盘
        参数: 
            atk: 左方数据
            levelid: 关卡id
            skill: 技能序列
 ]]--

 --[[
        33
        攻城战(进攻)(世界事件)复盘
        参数: 
            atk: 左方数据
            levelid: 关卡id
            skill: 技能序列
 ]]--

 --[[
        34
        攻城战(防守)(世界事件)复盘
        参数: 
            atk: 左方数据
            levelid: 关卡id
            wallLv: 城墙等级
            skill: 技能序列
 ]]--