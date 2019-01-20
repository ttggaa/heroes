--
-- Author: <wangguojun@playcrab.com>
-- Date: 2016-06-25 14:58:46
--
local RankModel = class("RankModel", BaseModel)
-- #### 排行榜类型####
--    1   //PVE编组排行
--    2   //兵团排行
--    3   //英雄排行
--    4   //公会排行
--    5  //闯关排行
--    6  //宝物排行
--    7   //联盟击杀排行
--    8   //云中城最速通关排行
--    10   //云中城最低战力通关排行

--    12   //pve 龙之国


RankModel.kRankTypeCloudCity = 8
RankModel.kRankTypeCloudCity_MIN_fight = 10
RankModel.kRankTypeTraining = 9
RankModel.kRankTypePveDragon = 12
RankModel.kRankDuelRecommend1 = 16
RankModel.kRankDuelRecommend2 = 17
RankModel.kRankDuelRecommend3 = 18
RankModel.kRankDuelRecommend4 = 19
RankModel.kRankGuildMapAQ1 = 20
RankModel.kRankGuildMapAQ2 = 21
RankModel.kRankTypeElemQuick = 22 
RankModel.kRankTypeElemMinFight = 23 
RankModel.kRankTypeElemProgress = 24
RankModel.kRankTypeDailySiegeAtc = 26 
RankModel.kRankTypeDailySiegeDed = 27
RankModel.kRankTypeSiegeAttack = 28
RankModel.kRankTypeSiegeDefend = 29
RankModel.kRankTypeCloudCity_NEW_fight = 31 -- 云中城最近通关时间榜
RankModel.happyPopRank = 32
RankModel.kRankTypeStakeDamage = 34
RankModel.worldCupRank = 35


function RankModel:ctor()
    RankModel.super.ctor(self)
    self._data = {
        {},--    1    //PVE编组排行
        {},--    2    //兵团排行\
        {},--    3    //英雄排行
        {},--    4    //公会排行
        {},--    5    //闯关排行
        {},--    6    //宝物排行
        {},--    7    //联盟击杀排行
        {},--    8    //云中城最速排行
        {},--    9    //训练场排行榜
        {},--    10   //云中城最低排行
        {},--    11   //英雄交锋排行
        {},--    12   //pve龙之国排行
        {},--    13   //工会地图地下城杀人排行
        {},--    14   //工会地图地下城占领奖励排行   
        {},--    15   //训练场活动快照      
        {},--    16   //英雄交锋最强阵容       
        {},--    17   //英雄交锋最高输出      
        {},--    18   //英雄交锋最高承受    
        {}, --   19   //英雄交锋热门英雄  
        {},--    20   //联盟地图答题个人排行   
        {}, --   21   //联盟地图答题联盟排行    
        {}, --   22   //元素位面最快通关排行
        {}, --   23   //元素位面最低战力排行
        {}, --   24   //元素位面进度排行
        {}, --   25     // 觉醒排行榜
        {}, --   26   //攻城日常排行
        {}, --   27   //守城日常排行
        {}, --   28   //攻城战攻城
        {}, --   29   //攻城战守城
        {}, --   30   // 器械排行榜
        {}, --   31   // 云中城最近通关时间排行榜
        {}, --   32   // 法术特训小游戏排行版
        {}, --   33    //爬塔排行榜
        {}, --   34    //........未知
        {}, --   35    //世界杯竞猜排行
        {}, --   34    //木桩排行榜
        {}, --   35    //XX
        {}, --   36    //终极降临活动 联盟榜
        {}, --   37    //终极降临活动 个人榜
    }
    self._selfRankInfo = {}
end

function RankModel:setData(data)
    self:processRankList(data)
    self:reflashData()
end

function RankModel:getData()
    return self._data
end

function RankModel:getRankList( tp )
    return self._data[tp]
end

function RankModel:setSelfRankInfo( inData )
    if not inData then return end
    if next(inData) == nil then return end
    if self._curType == RankModel.kRankTypePveDragon then
        if not self._selfRankInfo[self._curType] then
            self._selfRankInfo[self._curType] = {}
            self._selfRankInfo[self._curType][tonumber(inData.id)] = inData
        else
            self._selfRankInfo[self._curType][tonumber(inData.id)] = inData
        end
    elseif self._curType == RankModel.kRankTypeTraining then
        if not self._selfRankInfo[self._curType] then
            self._selfRankInfo[self._curType] = {}
            self._selfRankInfo[self._curType][tonumber(inData.id)] = inData
        else
            self._selfRankInfo[self._curType][tonumber(inData.id)] = inData
        end
    elseif self._curType == RankModel.kRankTypeElemQuick or self._curType == RankModel.kRankTypeElemMinFight then
        if not self._selfRankInfo[self._curType] then
            self._selfRankInfo[self._curType] = {}
            self._selfRankInfo[self._curType][inData.key] = inData
        else
            self._selfRankInfo[self._curType][inData.key] = inData
        end
    elseif self._curType == RankModel.kRankTypeElemProgress then
        if not self._selfRankInfo[self._curType] then
            self._selfRankInfo[self._curType] = {}
            self._selfRankInfo[self._curType][tonumber(inData.key)] = inData
        else
            self._selfRankInfo[self._curType][tonumber(inData.key)] = inData
        end
    elseif self._curType == RankModel.kRankTypeDailySiegeAtc 
        or self._curType == RankModel.kRankTypeDailySiegeDed
        or self._curType == RankModel.kRankTypeSiegeAttack
        or self._curType == RankModel.kRankTypeSiegeDefend then
        if not self._selfRankInfo[self._curType] then
            self._selfRankInfo[self._curType] = {}
            self._selfRankInfo[self._curType][tonumber(inData.key)] = inData
        else
            self._selfRankInfo[self._curType][tonumber(inData.key)] = inData
        end
    else
        self._selfRankInfo[self._curType] = inData
    end
    
    -- dump(self._selfRankInfo,"self._selfRankInfo==>"..self._curType, 5)
end

function RankModel:getSelfRankInfo( tp )
    return self._selfRankInfo[tp] or {}
end

-- 根据类型andID获取自己排行榜
function RankModel:getSelfRankInfoById( tp ,id)
    local ownerData = {}
    if not self._selfRankInfo[tp] then
        ownerData = {}
    else
        ownerData = self._selfRankInfo[tp][id] or {}
    end

    return ownerData
end

function RankModel:processRankList( inData )
    if not inData then return end
    -- dump(inData,"======")
    if inData.rankList then
        for k,v in pairs(inData.rankList) do
            if v and type(v) == "table" and v.rank then
                if self._curType == RankModel.kRankTypeCloudCity 
                    or self._curType == RankModel.kRankTypeCloudCity_MIN_fight 
                    or self._curType == RankModel.kRankTypeCloudCity_NEW_fight
                then
                    if self._data[self._curType][inData.stageId] == nil then
                        self._data[self._curType][inData.stageId] = {}
                    end
                    self._data[self._curType][inData.stageId][tonumber(v.rank)] = v
                elseif self._curType == RankModel.kRankTypePveDragon then
                    if not self._data[self._curType][inData.id] then
                        self._data[self._curType][inData.id] = {}
                    end
                    self._data[self._curType][inData.id][tonumber(v.rank)] = v
                elseif self._curType == RankModel.kRankTypeTraining then
                    if not self._data[self._curType][inData.id] then
                        self._data[self._curType][inData.id] = {}
                    end
                    self._data[self._curType][inData.id][tonumber(v.rank)] = v
                elseif self._curType == RankModel.kRankTypeElemQuick or self._curType == RankModel.kRankTypeElemMinFight then
                    if not self._data[self._curType][inData.key] then
                        self._data[self._curType][inData.key] = {}
                    end
                    self._data[self._curType][inData.key][tonumber(v.rank)] = v
                elseif  self._curType == RankModel.kRankTypeElemProgress then
                    if not self._data[self._curType][tonumber(inData.key)] then
                        self._data[self._curType][tonumber(inData.key)] = {}
                    end
                    self._data[self._curType][tonumber(inData.key)][tonumber(v.rank)] = v
                elseif self._curType == RankModel.kRankTypeDailySiegeAtc 
                    or self._curType == RankModel.kRankTypeDailySiegeDed
                    or self._curType == RankModel.kRankTypeSiegeAttack
                    or self._curType == RankModel.kRankTypeSiegeDefend then
                    if not self._data[self._curType][inData.key] then
                        self._data[self._curType][inData.key] = {}
                    end
                    self._data[self._curType][inData.key][tonumber(v.rank)] = v
                else
                    if not self._data[self._curType][tonumber(v.rank)] then
                        self._data[self._curType][tonumber(v.rank)] = {}
                    end
                    self._data[self._curType][tonumber(v.rank)] = v
                end
            end
        end
    end
    --自己的排行榜
    if (self._curStart == 1) or (inData.owner and next(inData.owner) ~= nil) then
        self:setSelfRankInfo(inData.owner)
    end
end

function RankModel:getRankNextStart( tp )
    return #self._data[tp]+1
end

function RankModel:clearRankList()
    -- print("=================clear clear ==============")
    self._data = {
        {},--    1    //PVE编组排行
        {},--    2    //兵团排行\
        {},--    3    //英雄排行
        {},--    4    //公会排行
        {},--    5    //闯关排行
        {},--    6    //宝物排行
        {},--    7    //联盟击杀排行
        {},--    8    //云中城最速排行
        {},--    9    //训练场排行榜
        {},--    10   //云中城最低排行
        {},--    11   //英雄交锋排行
        {},--    12   //pve龙之国排行
        {},--    13   //工会地图地下城杀人排行
        {},--    14   //工会地图地下城占领奖励排行   
        {},--    15   //训练场活动快照      
        {},--    16   //英雄交锋最强阵容       
        {},--    17   //英雄交锋最高输出      
        {},--    18   //英雄交锋最高承受    
        {}, --   19   //英雄交锋热门英雄  
        {},--    20   //联盟地图答题个人排行   
        {}, --   21   //联盟地图答题联盟排行    
        {}, --   22   //元素位面最快通关排行
        {}, --   23   //元素位面最低战力排行
        {},  --  24   //元素位面进度排行
        {}, --   25     // 觉醒排行榜
        {}, --   26   //攻城日常排行
        {}, --   27   //守城日常排行
        {}, --   28   //攻城战攻城
        {}, --   29   //攻城战守城
        {}, --   30   // 器械排行榜
        {}, --   31   // 云中城最近通关时间排行榜
        {}, --   32   // 法术特训小游戏排行版
        {}, --   33    //爬塔排行榜
        {}, --   34    //........未知
        {}, --   35    //世界杯竞猜排行
        {}, --   34    //木桩排行榜
        {}, --   35    //XX
        {}, --   36    //终极降临活动 联盟榜
        {}, --   37    //终极降临活动 个人榜
    }
    self._selfRankInfo = {}
end

-- 设置默认的排行类型和起始位
function RankModel:setRankTypeAndStartNum( tp,start )
    self._curType,self._curStart = tp or 1,start or 1
end

return RankModel