--[[
    Filename:    PrivilegeUtils.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-01-14 14:44:19
    Description: File description
--]]

local PrivilegeUtils = {}

-- 使用接口 function PrivilegesModel:getAbilityEffect(id) 
PrivilegeUtils.privileg_ID = {
    PRIVILEGENAME_1 = 105 ,   --副本特权
    PRIVILEGENAME_2 = 109 ,   --宝屋延长时间
    PRIVILEGENAME_3 = 110 ,   --墓穴延长时间
    PRIVILEGENAME_4 = 108 ,   --墓穴护栏生命
    PRIVILEGENAME_5 = 112 ,   --购买兵团经验增加
    PRIVILEGENAME_6 = 107 ,   --购买兵团经验次数
    PRIVILEGENAME_7 = 116 ,   --体力上限
    PRIVILEGENAME_8 = 103 ,   --免费抽卡次数
    PRIVILEGENAME_9 = 104 ,   --钻石抽卡CD
    PRIVILEGENAME_10 = 114 ,  --商店刷新次数增加
    PRIVILEGENAME_11 = 111 ,  --竞技CD
    PRIVILEGENAME_12 = 117 ,  --专精刷新次数
    PRIVILEGENAME_13 = 102 ,  --点金手次数
    PRIVILEGENAME_14 = 115 ,  --点金手收益
    PRIVILEGENAME_15 = 101 ,  --远征宝箱
    PRIVILEGENAME_16 = 113 ,  --任务获得经验
    PRIVILEGENAME_17 = 106 ,  --任务 18点 体力
    PRIVILEGENAME_18 = 118 ,  --任务 21点 体力
    PRIVILEGENAME_19 = 119 ,  --任务 12点 体力
}


-- 使用接口 function PrivilegesModel:getPeerageEffect(id)
-- 有效果的返回正常效果
-- 没有效果的返回0(0表示此功能未开启)
-- 等于0表示无该特权
PrivilegeUtils.peerage_ID = {
    ZuanShiChouKa = 1 ,     --钻石抽卡首次半价
    GouMaiBaoJi = 2 ,     --点金手和购买兵团经验可暴击
    JingYingCiShu = 3 ,    --精英副本每日挑战次数增加1 --副本获得玩家经验提高50%
    MuXueHuLan = 4 ,     --阴森墓穴护栏两层
    JingJiTiaoGuo = 5 ,   -- 竞技场快速跳过  --竞技场挑战奖励提高50%
    -- JingJiCD = 5 ,    -- 竞技场挑战无CD --精英副本每日挑战次数增加1
    AlliancePower1 = 0,     --联盟探索行动力上限提高50
    YuanZhengSaodang = 6 ,     --远征可扫荡关卡增加3关
    YuanZhengBUFF = 7 ,     --远征buff2到3
    LongZhiGuo = 0 ,     --龙之国快速通关
    CloudCityTimes = 8,     --云中城每日挑战次数+1
    BaoWuChouKa = 9 ,     --宝物抽卡免费一次
    AlliancePowerMax = 10 ,  --联盟探索行动力上限提高50 --副本获得玩家经验提高150%
}
-- PrivilegeUtils.privileg_ID = {
--     PRIVILEGENAME_1 = 1 ,    --通关特权
--     PRIVILEGENAME_2 = 106 ,    --任务
--     PRIVILEGENAME_3 = 116 ,    --体力
--     PRIVILEGENAME_4 = 103 ,    --抽卡
--     PRIVILEGENAME_5 = 5 ,    --重置
--     PRIVILEGENAME_6 = 6 ,    --竞技
--     PRIVILEGENAME_13 = 13 ,  --龙之国
--     PRIVILEGENAME_16 = 16 ,  --矮人
--     PRIVILEGENAME_17 = 110 ,  --墓室
--     PRIVILEGENAME_18 = 102 ,  --点金手
--     PRIVILEGENAME_19 = 101 ,  --远征
--     PRIVILEGENAME_20 = 20 ,  --天使军团
-- }

-- PrivilegeUtils.privileg_ID = {
--     PRIVILEGENAME_1 = 105 ,   --     副本特权
--     PRIVILEGENAME_5 = 112 ,   --购买兵团经验增加
--     PRIVILEGENAME_6 = 107 ,   --购买兵团经验次数
--     PRIVILEGENAME_7 = 116 ,   --体力上限
--     PRIVILEGENAME_8 = 103 ,   --免费抽卡次数
--     PRIVILEGENAME_9 = 104 ,   --钻石抽卡CD
--     PRIVILEGENAME_10 = 114 ,  --商店刷新次数增加
--     PRIVILEGENAME_11 = 111 ,  --竞技CD
--     PRIVILEGENAME_12 = 117 ,  --专精刷新次数
--     PRIVILEGENAME_13 = 102 ,  --点金手次数
--     PRIVILEGENAME_14 = 115 ,  --点金手收益
--     PRIVILEGENAME_15 = 101 ,  --远征宝箱
--     PRIVILEGENAME_16 = 113 ,  --任务获得经验
--     PRIVILEGENAME_17 = 106 ,  --任务 18点 体力
--     PRIVILEGENAME_18 = 118 ,  --任务 21点 体力
--     PRIVILEGENAME_19 = 119 ,  --任务 12点 体力
-- }


-- -- 使用接口 function PrivilegesModel:getPeerageEffect(id)
-- -- 有效果的返回正常效果
-- -- 没有效果的返回0或1(0表示此功能未开启)
-- PrivilegeUtils.peerage_ID = {
--     PEERAGE_2 = 2 ,     --点金手和购买兵团经验可暴击
--     PEERAGE_3 = 3 ,     --   副本获得玩家经验提高50%
--     PEERAGE_5 = 5 ,     --精英副本每日挑战次数增加1
--     PEERAGE_6 = 6 ,      --远征buff2到3
--     PEERAGE_7 = 7 ,     --   竞技场挑战奖励提高50%
--     PEERAGE_8 = 8 ,     --龙之国快速通关
--     PEERAGE_9 = 9 ,     --宝物抽卡免费一次
--     PEERAGE_10 = 10 ,   --   副本获得玩家经验提高150%
-- }

function PrivilegeUtils.dtor()
    PrivilegeUtils = nil
end

return PrivilegeUtils