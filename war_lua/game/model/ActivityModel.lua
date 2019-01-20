--[[
    Filename:    ActivityModel.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2016-01-26 20:26:41
    Description: File description
--]]

local ActivityModel = class("ActivityModel", BaseModel)

local tostring = tostring
local tonumber = tonumber
ActivityModel.kResetClock = 5

ActivityModel.PrivilegIDs = {
    PrivilegID_1 = 101, -- 普通副本掉落翻倍
    PrivilegID_2 = 102, -- 精英本挑战次数增加
    PrivilegID_3 = 103, -- 精英本购买额外挑战次数打折扣
    PrivilegID_4 = 201, -- 体力购买打折扣
    PrivilegID_5 = 202, -- 点金手花费打折扣
    PrivilegID_6 = 203, -- 经验购买打折扣
    PrivilegID_7 = 204, -- 点金手收益增加
    PrivilegID_8 = 205, -- 购买兵团经验收益增加
    PrivilegID_9 = 301, -- 矮人宝屋结算黄金增加（外面的阶段奖励不增加）
    PrivilegID_10 = 302, -- 矮阴森墓穴结算经验增加（外面的阶段奖励不增加
    PrivilegID_11 = 303, -- 龙之国结算符文盒子增加
    PrivilegID_12 = 401, -- 远征中远征币收益增加
    PrivilegID_13 = 402, -- 远征开小精灵的箱子的花费打折
    PrivilegID_14 = 403, -- 远征开小精灵的箱子的进阶石增加
    PrivilegID_15 = 501, -- 竞技场购买次数的花费打折
    PrivilegID_16 = 601, -- 航海任务所需时间缩短
    PrivilegID_17 = 404, -- 单抽宝物花费打折
    PrivilegID_18 = 405, -- 连抽宝物花费打折
    PrivilegID_19 = 502, -- 积分联赛购买挑战次数打折
    PrivilegID_20 = 602, -- 航海任务奖励翻倍花费打折（总任务数）
    -- PrivilegID_21 = 701, -- 联盟探索行动力恢复速度加快 -- 失效需求
    PrivilegID_22 = 801, -- 英雄专精刷新花费打折
    PrivilegID_23 = 802, -- 装备强化花费打折
    PrivilegID_24 = 803, -- 技能升级花费打折
    PrivilegID_25 = 804, -- 宝物进阶花费进阶石打折
    -- PrivilegID_26 = 901, -- 神秘商店刷新必出 -- 失效需求
    PrivilegID_27 = 902, -- 神秘商店折扣
    PrivilegID_28 = 903, -- 竞技商店折扣
    PrivilegID_29 = 904, -- 战役商店折扣
    PrivilegID_30 = 905, -- 宝物商店折扣
    PrivilegID_31 = 906, -- 联盟商店折扣
    PrivilegID_32 = 206, -- 交易所购买法术卷轴加成
    PrivilegID_33 = 304, -- 云中城双倍
    PrivilegID_34 = 310, -- 元素位面次数+1活动

    PrivilegID_35 = 305, -- 火位面双倍
    PrivilegID_36 = 306, -- 水位面双倍
    PrivilegID_37 = 307, -- 气位面双倍
    PrivilegID_38 = 308, -- 混沌位面双倍
    PrivilegID_39 = 309  -- 土位面双倍

}

function ActivityModel:ctor()
    ActivityModel.super.ctor(self)
    self._data = {}
    self._acRmbData = {}
    self._isOpenCharde = nil
    self._modelMgr = ModelManager:getInstance()
    self._userModel = self._modelMgr:getModel("UserModel")
    self._vipModel = self._modelMgr:getModel("VipModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._heroModel = self._modelMgr:getModel("HeroModel")
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._arenaModel = self._modelMgr:getModel("ArenaModel")
    self._treasureModel = self._modelMgr:getModel("TreasureModel")
    self._formationModel = self._modelMgr:getModel("FormationModel")
    self._pokedexModel = self._modelMgr:getModel("PokedexModel")
    self._commentGuideModel = self._modelMgr:getModel("CommentGuideModel")
    self._leagueModel = self._modelMgr:getModel("LeagueModel")
    self._elementModel = self._modelMgr:getModel("ElementModel")
    self._lotterModel = self._modelMgr:getModel("AcLotteryModel")
    self._weaponsModel = self._modelMgr:getModel("WeaponsModel")

    --[[
    self._acTableData = tab.dailyActivity
    self._acTaskTableData = tab.dailyActivityTask
    self._acConditionData = tab.dailyActivityCondition
    ]]
    self:listenGlobalResponseAfter(specialize(self.onChangeActivity, self))
    self:listenReflash("ItemModel", self.evaluateActivityData)
    self:listenReflash("TrainingModel", self.evaluateActivityData)
end



function ActivityModel:isNeedRequest()
    --PCLuaLogDump(self._data, "taskData", 5)
    if not self._cached then
        self._cached = true
        return true
    end
    return false
    --[[
    local taskTableData = tab.task
    local currentTime = self._userModel:getCurServerTime()
    local currentHour = os.date("*t", currentTime).hour
    for k, v in pairs(taskTableData) do
        if v.conditiontype == 999 then
            local hide = false
            for kk, vv in pairs(v.hid) do
                local time1 = string.split(vv[1], ':')
                local time2 = string.split(vv[2], ':')
                if currentHour >= tonumber(time1[1]) and currentHour < tonumber(time2[1]) then
                    hide = true
                    if self._data.task.detailTasks[tostring(k)] then
                        return true
                    end
                end
            end
            if not hide and not self._data.task.detailTasks[tostring(k)] then
                return true
            end
        end
    end
    return false
    ]]
    --[[
    if not self._cached then
        self._cached = {}
        self._cached.updateCache = function()
            self._cached.lvl = self._userModel:getData().lvl
            self._cached.weekCard = self._vipModel:getData().weekCard and self._vipModel:getData().weekCard or 0
            self._cached.monthCard = self._vipModel:getData().monthCard and self._vipModel:getData().monthCard or 0
        end
        self._cached.updateCache()
        return true
    end
    local lvl = self._userModel:getData().lvl
    if lvl ~= self._cached.lvl then
        self._cached.updateCache()
        return true 
    end
    local weekCard = self._vipModel:getData().weekCard and self._vipModel:getData().weekCard or 0
    if weekCard ~= self._cached.weekCard then 
        self._cached.updateCache()
        return true 
    end
    local monthCard = self._vipModel:getData().mondCard and self._vipModel:getData().mondCard or 0
    if monthCard ~= self._cached.monthCard then 
        self._cached.updateCache()
        return true 
    end
    local taskTableData = tab.task
    local currentTime = self._userModel:getCurServerTime()
    local currentHour = os.date("*t", currentTime).hour
    for k, v in pairs(taskTableData) do
        if v.conditiontype == 999 then
            for kk, vv in pairs(v.hid) do
                local time1 = string.split(vv[1], ':')
                local time2 = string.split(vv[2], ':')
                if (currentHour >= tonumber(time1[1]) and currentHour <= tonumber(time2[1]) and self._data.task.detailTasks[tostring(k)]) then
                    return true
                end
            end
            if not self._data.task.detailTasks[tostring(k)] then
                return true
            end
        end
    end
    return false
    ]]
end

function ActivityModel:registerActivityTimer()
    local registerTab = {}
    registerTab[5 .. ":" .. 0 .. ":" .. 0] = true
    local activityOpenTableData = tab.activityopen
    if not activityOpenTableData then return end
    for k, v in pairs(activityOpenTableData) do
        local start_type, start_time, end_time, appear_time, disappear_time = v.start_type, v.start_time, v.end_time, v.appear_time, v.disappear_time
        if 1 == start_type then
            appear_time = appear_time or start_time
            disappear_time = disappear_time or end_time
            local times = {
                [1] = start_time,
                [2] = end_time,
                [3] = appear_time,
                [4] = disappear_time,
            }
            for i=1, 4 do
                repeat
                    if not times[i] then break end
                    local time = string.split(times[i], ' ')
                    if time[2] and time[2] ~= "" then
                        local time0 = string.split(time[2], ':')
                        registerTab[time0[1] .. ":" .. time0[2] .. ":" .. 0] = true
                    else
                        registerTab[5 .. ":" .. 0 .. ":" .. 0] = true
                    end
                until true
            end
        elseif 2 == start_type or 3 == start_type then
            start_time = start_time % 24
            end_time = end_time % 24
            appear_time = appear_time and (appear_time % 24) or start_time
            disappear_time = disappear_time and (disappear_time % 24) or end_time
            registerTab[5 + start_time .. ":" .. 0 .. ":" .. 0] = true
            registerTab[5 + end_time .. ":" .. 0 .. ":" .. 0] = true
            registerTab[5 + appear_time .. ":" .. 0 .. ":" .. 0] = true
            registerTab[5 + disappear_time .. ":" .. 0 .. ":" .. 0] = true
        end
    end

    for time, _ in pairs(registerTab) do
        local list = string.split(time, ":")
        if 5 == tonumber(list[1]) and 0 == tonumber(list[2]) and tonumber(list[3]) <= 10 then
            list[3] = tostring(15)
        end
        self:registerTimer(tonumber(list[1]), tonumber(list[2]), tonumber(list[3]), specialize(self.setOutOfDate, self))
    end
    self._isSetTimer = true

    if not self._modelMgr:isExistTimeKey("5_0_0",self) then
        self:registerTimer(5,0,0, function ()
            self._isOpenCharde = nil
            self:reflashData()
        end)
    end
end

function ActivityModel:setAllActivityData(success, data)
    --dump(data, "setAllActivityData", 5)
    if not success then return end
    if data.acShowList then
        self:setActivityShowList(data.acShowList)
    end

    if data.activity and data.activity.acTask then
        self:setActivityTaskData(data.activity.acTask)
    end

    if data.activity and data.activity.acSpecial then
        self:setActivitySpecialData(data.activity.acSpecial)
    end

    if data.statis then
        self._userModel:setActivityStatis(data.statis)
    end

    if data.activityStatis then
        self._userModel:setActivityStatis(data.activityStatis)
    end

    if data.sRcg then
        self:setSingleRechargeData(data.sRcg)
    end

    if data.acHeroDuel then
        self:setAcHeroDuelData(data.acHeroDuel)
    end


    if data.acRmb then
        self:setAcRmbData(data.acRmb)
    end
end

function ActivityModel:setOutOfDate(timeKey)
    if not SystemUtils:enableactivity() then
        print("activity is not open.")
        return
    end
    if timeKey == "5_0_0" then
        self._isOpenCharde = nil
    end
    self._cached = false
    self:checkOutData_107()
    self._serverMgr:sendMsg("ActivityServer", "getAcAll", {}, true, {}, function(success)
        if not success then return end
        self:evaluateActivityData("pushActivityEvent")
    end)
end

function ActivityModel:setData(data)
    -- dump(data, "ActivityModel:setData", 10)
    --self._data = data
    --[[
    self._data = {
        ["1"] = {
            acId = 8001,
            taskList = {
                ["130101"] = {
                    times = 0
                },
                ["130102"] = {
                    times = 0
                },
                ["130103"] = {
                    times = 0
                },
                ["130104"] = {
                   times = 0
                },
                ["130105"] = {
                    times = 0
                },
                ["130106"] = {
                    times = 0
                },
            },

            acStatis = {
                ["1301"] = {
                    v1 = 0,
                    v2 = 6
                }
            }
        },

        ["2"] = {
            acId = 8003,
            taskList = {
                ["120201"] = {
                    times = 0
                },
            },

            acStatis = {
                ["1202"] = {
                    v1 = 0,
                    v2 = 6
                }
            }
        },

        ["3"] = {
            acId = 8004,
            taskList = {
                ["80001"] = {
                    times = 0
                },

                ["80002"] = {
                    times = 0
                },

                ["80003"] = {
                    times = 0
                },
            }
        },
        
        ["4"] = {
            acId = 8005,
            taskList = {
                ["110203"] = {
                    times = 0
                },

                ["130105"] = {
                    times = 0
                },

                ["110101"] = {
                    times = 0
                },
            },

            acStatis = {
                ["1102"] = {
                    v1 = 0,
                    v2 = 3
                },
                ["1301"] = {
                    v1 = 0,
                    v2 = 6
                },
                ["1101"] = {
                    v1 = 0,
                    v2 = 300
                },
            }
        }
    }
    ]]
end

function ActivityModel:setActivityTaskData(data)
    -- dump(data, "ActivityModel:setData", 10)
    if not data then
        self._data.acTask = {}
        return
    end
    self._data.acTask = data
end

function ActivityModel:setActivitySpecialData(data)
    -- dump(data, "ActivityModel:setData", 10)
    if not data then
        self._data.acSpecial = {}
        return
    end
    self._data.acSpecial = data
end

function ActivityModel:setActivityShowList(data)
    -- dump(data, "ActivityModel:setActivityShowList", 5)
    if not data then
        self._showListData = {}
        self._cached = true
        return
    end
    self._showListData = data
    self._cached = true
end

function ActivityModel:setSingleRechargeData(data)
    -- dump(data, "ActivityModel:setSingleRechargeData", 5)
    if not data then
        self._sRechargeData = {}
        return
    end
    self._sRechargeData = data
end

function ActivityModel:setAcHeroDuelData(data)
    if not data then
        self._acHeroDuelData = {}
        return
    end
    self._acHeroDuelData = data
end


function ActivityModel:setAcRmbData(data)
    -- dump(data, "ActivityModel:setAcRmbData", 5)
    if not data then
        self._acRmbData = {}
        return
    end
    self._acRmbData = data
end

function ActivityModel:setIntRechargeData(data)
    -- dump(data, "ActivityModel:setIntRechargeData", 5)
    if not data then
        self._acIntRechargeData = {}
        return
    end
    self._acIntRechargeData = data
end

function ActivityModel:getTeHuiActivityOpen()
    --dump(self._acIntRechargeData, "ActivityModel:getTeHuiActivityOpen", 5)
    local acData = self:getIntRechargeData()
    if 0 == table.getn(table.keys(acData)) then return false end
    local currTime = self._userModel:getCurServerTime() 
    -- local starTime = self._data.startTime or currTime
    local endTime = acData.endTime or currTime
    local userLevel = self._userModel:getPlayerLevel() 
    return currTime < endTime and not (1 == acData.hasReceived and acData.rechargeNum >= acData.rechargeLimit) and userLevel >= 6
end

function ActivityModel:setTeHuiActivityChecked(isChecked)
    --dump(self._acIntRechargeData, "ActivityModel:getTeHuiActivityOpen", 5)
    if not self:getTeHuiActivityOpen() then return end
    SystemUtils.saveAccountLocalData("ACTIVITY_TEHUI", isChecked and 1 or 0)
end

function ActivityModel:getTeHuiActivityChecked()
    --dump(self._acIntRechargeData, "ActivityModel:getTeHuiActivityOpen", 5)
    if not self:getTeHuiActivityOpen() then return true end
    return 1 == SystemUtils.loadAccountLocalData("ACTIVITY_TEHUI")
end

function ActivityModel:getData()
    --return self._data
end

function ActivityModel:getActivityTaskData()
    return self._data.acTask
end

function ActivityModel:getActivitySpecialData()
    return self._data.acSpecial
end

function ActivityModel:getActivityShowList()
    return self._showListData
end

function ActivityModel:getSingleRechargeData()
    return self._sRechargeData
end

function ActivityModel:getAcHeroDuelData()
    return self._acHeroDuelData
end


function ActivityModel:getAcRmbData()
    return self._acRmbData
end

function ActivityModel:getIntRechargeData()
    return self._acIntRechargeData or {}
end

function ActivityModel:getIntRechargeCanGet()
    if not self:getTeHuiActivityOpen() then return false end
    local acData = self:getIntRechargeData()
    return ((0 == acData.hasReceived and acData.rechargeNum >= acData.rechargeLimit) or not self:getTeHuiActivityChecked())
end

-- 更新特殊活动信息
function ActivityModel:updateSpecialData(data)
    if data == nil or type(data) ~= "table" then
        return
    end

    for k,v in pairs(data.acSpecial) do
        if k == "102" then
            if self._data.acSpecial["102"] == nil then
                self._data.acSpecial["102"] = {}
            end
            for kk,vv in pairs(v) do
                self._data.acSpecial["102"][kk] = vv
            end
        elseif k == "101" then
            if self._data.acSpecial["101"] == nil then
                self._data.acSpecial["101"] = {}
            end
            if v.buyInfo then
                for kk,vv in pairs(v.buyInfo) do
                    if self._data.acSpecial["101"]["buyInfo"] == nil then
                        self._data.acSpecial["101"]["buyInfo"] = {}
                    end
                    self._data.acSpecial["101"]["buyInfo"][kk] = vv
                end
            end
        elseif k == "99" then
            if self._data.acSpecial["99"]== nil then
                self._data.acSpecial["99"] = {}
            end
            for kk,vv in pairs(v) do
                self._data.acSpecial["99"][kk] = vv
            end

        elseif k == "999" then
            if self._data.acSpecial["999"]== nil then
                self._data.acSpecial["999"] = {}
            end
            for kk,vv in pairs(v) do
                self._data.acSpecial["999"][kk] = vv
            end             
        end
    end
    self:reflashData("updateSpecialData")
end

-- 5点刷新数据
function ActivityModel:updateActivityUI()
    self:reflashData("ActivityModel")
end

--获取分享数据
function ActivityModel:getACShareList() 
    local ACShareData = {}
    for k,v in pairs(self._data.acSpecial) do
        if k == "99" then
            ACShareData = v
        end
    end
    return ACShareData
end
-- 获取分享数据
function ActivityModel:getACShareShowList() 
    local shareShowData = {}
    for k,v in pairs(self._showListData) do
        if v.activity_id == 99 then            
            shareShowData = v
        end
    end
    -- dump(shareShowData,"shareShowData")
    return shareShowData
end

-- 根据活动ID获取展示信息
-- 限时活动  eg. activityId = 98
function ActivityModel:getACCommonShowList( id ) 
    local commonShowData = {}
    for k,v in pairs(self._showListData) do
        if tonumber(v.activity_id) == tonumber(id) then            
            commonShowData = v
            break
        end
    end
    return commonShowData
end

-- 获取每日充值数据
function ActivityModel:getACERechargeShowList() 
    local aCERecharge = {}
    for k,v in pairs(self._showListData) do
        if v.activity_id == 102 then
            aCERecharge = v
        end
    end
    return aCERecharge
end

function ActivityModel:getACERechargeSpecialData() 
    local aCERecharge = {}
    for k,v in pairs(self._data.acSpecial) do
        if k == "102" then
            v.index = nil
            if not v.progress then
                v.progress = 0
            end
            aCERecharge = v
        end
    end
    return aCERecharge
end

-- 获取每日充值达到条件的天数
function ActivityModel:getACERechargeDay() 
    local userModel = self._userModel
    local everyRechargeTime = userModel:getActivityStatis()
    local rechargeShowList = self:getACERechargeShowList() 
    -- dump(rechargeShowList, "rechargeShowList ====================")
    -- dump(everyRechargeTime, "everyRechargeTime ====================")

    local curServerTime = userModel:getCurServerTime()
    local tempTime = rechargeShowList.start_time or 0
    local timeDate -- = TimeUtils.getDateString(tempTime,"%Y%m%d")
    -- print("===============", timeDate)
    local rechargeDate = {}
    for i=1,7 do
        timeDate = TimeUtils.getDateString(tempTime,"%Y%m%d")
        if everyRechargeTime[tostring(timeDate)] then
            -- print("timeDate ==============", timeDate)
            if everyRechargeTime[tostring(timeDate)]["sts" .. 1] and tonumber(everyRechargeTime[tostring(timeDate)]["sts" .. 1]) >= 60 then
                table.insert(rechargeDate, timeDate)
            end
        end
        tempTime = tempTime + 86400

    end
    -- dump(rechargeDate,"rechargeDate ======================")
    return rechargeDate
end

-- 获取当日充值数据
function ActivityModel:getTodayRechargeData() 
    local userModel = self._userModel
    local everyRechargeTime = userModel:getActivityStatis()
    -- local rechargeShowList = self:getACERechargeShowList() 
    -- dump(rechargeShowList, "rechargeShowList ====================")
    -- dump(everyRechargeTime, "everyRechargeTime ====================")

    local curServerTime = userModel:getCurServerTime()
    local timeDate
    local tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
    if curServerTime > tempCurDayTime then
        timeDate = TimeUtils.getDateString(curServerTime,"%Y%m%d")
    else
        timeDate = TimeUtils.getDateString(curServerTime - 86400,"%Y%m%d")
    end

    local rechargeDate = {}
    if everyRechargeTime[tostring(timeDate)] then
        rechargeDate = everyRechargeTime[tostring(timeDate)]
    else
        timeDate = TimeUtils.getDateString((curServerTime - 86400),"%Y%m%d")
        rechargeDate = everyRechargeTime[tostring(timeDate)]
    end
    return rechargeDate -- everyRechargeTime[table.nums(everyRechargeTime)]
end

-- -- 获取每日折扣数据
-- function ActivityModel:getACERebateShowList() 
--     local aCERebate = {}
--     for k,v in pairs(self._showListData) do
--         if v.activity_id == 101 then
--             if self._rebateData == nil then
--                 self._rebateData = {}
--                 self:updateACERebateAllPlayer(v.dailyDiscount) 
--             end
--             aCERebate = v
--         end
--     end
--     return aCERebate
-- end

-- 获取第五种活动类型 开启时间结束时间
--   eg. activityId = 906（提升战力送绿龙活动显示信息）
function ActivityModel:getACFiveTypeShowList( id ) 
    local ShowData = {}
    for k,v in pairs(self._showListData) do
        if tonumber(v.activity_id) == tonumber(id) then            
            ShowData = v
            break
        end
    end
    return ShowData
end

-- 获取巫妖直购礼包数据
function ActivityModel:getAcLichBuyData()
    for _, v in pairs(self._showListData) do
        if tonumber(v.ac_type) == 17 and 1 == v.is_open then            
            return clone(v)
        end
    end
    return false
end

-- 是否显示巫妖直购礼包数据
function ActivityModel:isShowAcLichBuy()
    if not SystemUtils:enableNests() then return false end
    local activityData = self:getAcLichBuyData()
    if not activityData then return false end
    return not self._userModel:isAcGoodsBuy(activityData.activity_id)
end

function ActivityModel:setACRebateShowDays(days) 
    self._ACRebateShowDays = days
end

function ActivityModel:getACRebateShowDays() 
    return self._ACRebateShowDays or 0
end

function ActivityModel:isShowBuyDays(flag) 
    if flag then
        self._isShowBuyDays = flag
    end
    return self._isShowBuyDays or false
end

-- 获取购买数据
function ActivityModel:getACERebateSpecialData() 
    local aCERebate = {}
    for k,v in pairs(self._data.acSpecial) do
        if k == "101" then
            aCERebate = v
        end
    end
    if aCERebate.buyInfo then
        -- dump(aCERebate.buyInfo)
        return aCERebate.buyInfo
    end

    return aCERebate
end

-- function ActivityModel:isACERebateData(flag)
    -- if flag == true and self._rebateNum == nil then
    --     self._rebateNum = true
    -- end    
    -- return self._rebateNum or false
-- end

-- -- 更新全服已购买道具数量
-- function ActivityModel:updateACERebateAllPlayer(data) 
--     if not data then
--         return
--     end
--     if self._rebateData == nil then
--         self:getACERebateShowList()
--         -- self:updateACERebateAllPlayer(data)
--     end
--     if self._rebateData == nil then
--         self._rebateData = {}
--     end
--     for k,v in pairs(data) do
--         self._rebateData[tostring(k)] = v 
--     end 
--     self:reflashData("updateACERebateAllPlayer")
-- end

-- -- 获取全服已购买道具数量
-- function ActivityModel:getACERebateAllPlayer()   
--     return self._rebateData
-- end

-- 每日充值红点提示
function ActivityModel:isACERechargeTip() 
    local flag = false
    local rechargeSpecial = self:getACERechargeSpecialData() 
    -- local rechargeDay = table.nums(self:getACERechargeDay())
    -- local userModel = self._userModel
    -- -- for i=1,rechargeDay do
    -- --     if not rechargeSpecial[tostring(i)] then
    -- --         flag = true
    -- --     end
    -- -- end
    -- dump(rechargeSpecial, "+++++++rechargeSpecial ============")

    local userTime = self._userModel:getCurServerTime()
    local todayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(userTime,"%Y-%m-%d 05:00:00"))
    local yesdayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(userTime-86400,"%Y-%m-%d 05:00:00"))

    print(" userTime > todayTime ========", userTime, todayTime)
    if self._userModel:getData().lvl >= 10 then
        if userTime > todayTime then -- 5~24
            if rechargeSpecial["rechargeTime"] and rechargeSpecial["rechargeTime"] > todayTime then
                print("判断是否领取")
                if rechargeSpecial["rewardTime"] and rechargeSpecial["rewardTime"] > todayTime then
                else
                    flag = true
                end
            end
        else -- 0~5
            if rechargeSpecial["rechargeTime"] and rechargeSpecial["rechargeTime"] < todayTime and (rechargeSpecial["rechargeTime"] or 0) > yesdayTime then
                print("判断是否领取")
                if rechargeSpecial["rewardTime"] and rechargeSpecial["rewardTime"] > yesdayTime then
                else
                    flag = true
                end
            end
        end
    end
    -- print("flag ==========", flag)
    if flag == true then
        if rechargeSpecial["amount"] and rechargeSpecial["amount"] < 60 then
            flag = false
        end
        if rechargeSpecial["progress"] and rechargeSpecial["progress"] >= 5 then
            flag = false
        end
    end

    return flag
end


-- 判断每日折扣是否显示红点
function ActivityModel:isACERebateDateTip()  
    local userModel = self._userModel
    local flag = self:isActivityOpen(101)
    if userModel:getData().lvl < 15 or flag == false then
        return false
    end

    local curServerTime = userModel:getCurServerTime()
    local timeDate
    local tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
    if curServerTime > tempCurDayTime then
        timeDate = TimeUtils.getDateString(curServerTime,"%Y%m%d")
    else
        timeDate = TimeUtils.getDateString(curServerTime - 86400,"%Y%m%d")
    end
    local tempdate = SystemUtils.loadAccountLocalData("ACTIVITY_RebateDate")
    if tempdate ~= timeDate then
        print("ACTIVITY_RebateDate", timeDate)
        return true
    end
    return false
end

function ActivityModel:setACERebateDateTip()  
    local userModel = self._userModel
    local curServerTime = userModel:getCurServerTime()
    local timeDate
    local tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
    if curServerTime > tempCurDayTime then
        timeDate = TimeUtils.getDateString(curServerTime,"%Y%m%d")
    else
        timeDate = TimeUtils.getDateString(curServerTime - 86400,"%Y%m%d")
    end
    local tempdate = SystemUtils.loadAccountLocalData("ACTIVITY_RebateDate")
    if tempdate ~= timeDate then
        print("ACTIVITY_RebateDate", timeDate)
        SystemUtils.saveAccountLocalData("ACTIVITY_RebateDate", timeDate)
        return true
    end
    return false
end
--分享有利是否有红点提示
function ActivityModel:isShareDataTip()
    local shareData = self:getACShareList()
    local isHaveTip = false
    for k,v in pairs(shareData) do
        if 1 == tonumber(v) then
            isHaveTip = true
            break
        end
    end
    return isHaveTip
end

--[[
    //每日活动统计 AC_STATIS
    const AC_STATIS_RECHARGE = 1; //每日累计充值
    const AC_STATIS_LOGIN = 2;  //是否登录
    const AC_STATIS_RECHARGE_MAX = 3; //单笔最大充值
    const AC_STATIS_CONSUME_GOLD = 4; //消费金币累计
    const AC_STATIS_CONSUME_GEM = 5; //消耗钻石累计
    const AC_STATIS_CONSUME_GEM_MAX = 6; //单笔消耗钻石最大值
    const AC_STATIS_CONSUME_PHYSCAL = 7; //累计消耗体力
    const AC_STATIS_BUY_PHYSCAL_TIMES = 8; //购买体力次数
    const AC_STATIS_BUY_GOLD_TIMES = 9; //购买金币次数
    const AC_STATIS_DRAW_TOOL = 10; //道具抽卡次数
    const AC_STATIS_DRAW_GEM = 11; //钻石抽卡次数
    const AC_STATIS_ATTACK_STAGE = 12; //通关普通副本次数
    const AC_STATIS_ATTACK_ELITESTAGE = 13; //通关精英副本次数
    const AC_STATIS_ATTACK_ARENA = 14; //攻打竞技场次数
    const AC_STATIS_GOT_CURRENCY = 15; //累计获得竞技币
    const AC_STATIS_RF_ARENA_SHOP = 16; //刷新竞技商城次数
    const AC_STATIS_CRUSEADE_OPENBOX = 17; //远征开宝箱次数
    const AC_STATIS_GOT_CRUSADING = 18; //获取远征币
    const AC_STATIS_RF_CRUSEADE_SHOP = 19; //刷新远征商店次数
    const AC_STATIS_ATTACK_BOSS_DRAGON = 20; //攻击龙之国次数
    const AC_STATIS_ATTACK_BOSS_DWARF = 21; //攻击矮人次数
    const AC_STATIS_ATTACK_BOSS_VAULT = 22; //攻击阴森墓穴次数
    const AC_STATIS_RF_SECRET_SHOP = 25; //刷新神秘商店
    const AC_STATIS_SECRET_SHOP_CONSUME_GEM = 26; //神秘商店花费钻石
    const AC_STATIS_SECRET_SHOP_CONSUME_GOLD = 27; //神秘商店花费金币
    const AC_STATIS_SECRET_SHOP_BUY_TIMES = 28;     //神秘商店购买次数
    const AC_STATIS_DAILY_TASK = 29;        // 完成日常任务次数
    const AC_STATIS_UP_TEAM_SKILL = 30; //升级兵团技能次数
    const AC_STATIS_UP_TEAM_LV = 31; //升级兵团等级次数
    const AC_STATIS_UP_TEAM_STAR = 32; //兵团升大星
    const AC_STATIS_UP_TEAM_QUALITY = 33; //兵团生品质
    const AC_STATIS_EQUIP_STRENG = 34; //兵团装备强化
    const AC_STATIS_EQUIP_QUALITY = 35; //装备进阶
    const AC_STATIS_HERO_RF_MASTERY = 36; //英雄刷新专精次数
    const AC_STATIS_HERO_UP_STAR = 37; //英雄升星
    const AC_STATIS_HERO_UP_SKILL = 38; //英雄技能升级
    const AC_STATIS_BOSS_KILL_DEFAULT_DWARF =  39; //杀死普通矮人N个 
    const AC_STATIS_BOSS_KILL_MASTER_DWARF =  40; //杀死矮人领主N个 
    const AC_STATIS_BOSS_KILL_DEFAULT_VAULT = 41; //杀死普通僵尸N个 
    const AC_STATIS_BOSS_KILL_BOOM_VAULT = 42; //杀死炸弹僵尸N个
    const AC_STATIS_CRUSEADE_BUILD = 43; //获取远征方尖碑个数
    const AC_STATIS_POKEDEX_LVUP = 44; //图鉴升级次数

###活动推送玩家事件###
method: activity.pushUserEvent   
info：$type

    type定义

    //玩家操作定义 活动推送用
    const EVENT_AC_USER_LV_UP = 1;      //玩家升级
    const EVENT_AC_TEAM_LV_UP = 2;      //兵团升级
    const EVENT_AC_GET_TEAM = 3;      //获得兵团
    const EVENT_AC_GET_HERO = 4;      //获得英雄
    const EVENT_AC_HERO_UP_STAR = 6;  //英雄升星
    const EVENT_AC_TEAM_UP_STAR = 7;   //兵团升星
    const EVENT_AC_TEAM_UP_STAGE = 8;      //兵团升阶
    const EVENT_AC_EQUIP_LV_UP = 9;      //兵团装备升级
    const EVENT_AC_EQUIP_UP_STAGE = 10;      //兵团装备升阶
    const EVENT_AC_HERO_SKILL_LV_UP = 11;      //英雄技能升级
    const EVENT_AC_OPEN_TREASURE = 12;      //激活宝物
]]

function ActivityModel:getActivityInfo(activityId)
    for _, v in ipairs(self._showListData) do
        if tonumber(v.activity_id) == tonumber(activityId) then
            return v
        end
    end
end

function ActivityModel:getActivityStatisInfo(activityInfo, activityStatis, isReset)
    local result = {}
    if isReset then
        if activityInfo.is_open then
            table.insert(result, activityStatis[#activityStatis])
            return true, result
        else
            return false, 0
        end
    else
        if activityInfo.is_open then
            local startTime = activityInfo.start_time
            for _, v in ipairs(activityStatis) do
                if v.time >= startTime then
                    table.insert(result, v)
                end
            end
            return true, result
        else
            local startTime = activityInfo.start_time
            local endTime = activityInfo.end_time
            for _, v in ipairs(activityStatis) do
                if v.time >= startTime and v.time < endTime then
                    table.insert(result, v)
                end
            end
            return true, result
        end
    end
end

-- 兑换活动是否满足前提条件
function ActivityModel:isPremiseCondition( taskConditionData , taskTableData, activityInfo, activityStatis)

    local conditionId = taskConditionData.id
    if conditionId == nil then return false end
    local isReach = false
    local value,condition
    if conditionId == 6301 then
        --某个英雄达到X星
        local heroId = taskTableData.condition_num[1]
        local star = taskTableData.condition_num[2]
        value = self._heroModel:getHeroStar(heroId)
        condition = star
        isReach = value >= condition
        return isReach
    elseif conditionId == 1301 then
        -- 玩家等级
        value = self._userModel:getData().lvl
    elseif conditionId == 1002  then
         -- 累积登录X天
         local isStatisInfo, activityStatisInfo = self:getActivityStatisInfo(activityInfo, activityStatis, 1 == taskConditionData.reset)
         local getAccumulateValue = function(statisId)
            local count = 0
            for _, v in ipairs(activityStatisInfo) do
                local value = v.value["sts" .. statisId]
                if value and value > 0 then
                    count = count + 1
                end
            end
            return count
        end
        value = getAccumulateValue(2)
    elseif conditionId == 1202  then
        --累积消耗钻石达到X
        value = self._userModel:getTotalConsumeDiamond()
    end
    condition = taskTableData.condition_num[1]
    isReach = value >= condition
    return isReach
    
end

function ActivityModel:getTaskStatusInfo(taskData, activityInfo, activityStatis, playerStatis)
    local isFinished, isGot = true, taskData.times > 0
    local statisInfo = {
        status = -1,
        value = 0,
        condition = 0,
        premiseCondition = 1, --前提条件 1为满足，0为不满足
        isHideValue = false
    }

    local taskTableData = self._acTaskTableData[taskData.id]

    if not taskTableData then
        print("invalid task id:", taskData.id)
        return statisInfo
    end


    -- type为2 or 3 表示兑换活动
    if taskTableData.type == 2 or taskTableData.type == 3 then
        if taskTableData.finish_max then
            isGot = taskData.times >= taskTableData.finish_max
        else
            isGot = taskData.times > 0
        end
        local taskConditionData = self._acConditionData[taskTableData.condition]
        for i = 1, #taskTableData.exchange_num do

            -- 添加前提条件 不满足直接isFinished = false
            if taskTableData.type == 3 and taskConditionData then
                local isReach  = self:isPremiseCondition(taskConditionData, taskTableData, activityInfo, activityStatis)
                if not isReach then
                    isFinished = false
                    statisInfo.premiseCondition = 0
                    break
                end 
            end

            local have, consume = 0, taskTableData.exchange_num[i][3]
            if "tool" == taskTableData.exchange_num[i][1] then
                local _, toolNum = self._itemModel:getItemsById(taskTableData.exchange_num[i][2])
                have = toolNum
            elseif "gold" == taskTableData.exchange_num[i][1] then
                have = self._userModel:getData().gold
            elseif "gem" == taskTableData.exchange_num[i][1] then
                have = self._userModel:getData().freeGem + self._userModel:getData().payGem
            elseif "hDuelCoin" == taskTableData.exchange_num[i][1] then
                have = self._userModel:getData().hDuelCoin
            end
            if consume > have then
                isFinished = false
                break
            end
        end
    else
        local taskConditionData = self._acConditionData[taskTableData.condition]
        if taskConditionData.stsId then
            local isStatisInfo, activityStatisInfo = self:getActivityStatisInfo(activityInfo, activityStatis, 1 == taskConditionData.reset)
            if not isStatisInfo then
                statisInfo.value = activityStatisInfo
                statisInfo.condition = taskTableData.condition_num[1]
            else
                for _, v in ipairs(activityStatisInfo) do
                    local value = v.value["sts" .. taskConditionData.stsId]
                    if value then
                        statisInfo.value = statisInfo.value + value
                    end
                end
            end
            statisInfo.condition = taskTableData.condition_num[1]
            isFinished = statisInfo.value >= statisInfo.condition
        else

            --[[
                1 == taskConditionData.reset
                activityInfo.is_open == true

                ==>return true, result
            ]]
            local isStatisInfo, activityStatisInfo = self:getActivityStatisInfo(activityInfo, activityStatis, 1 == taskConditionData.reset)
            if not isStatisInfo then
                statisInfo.value = activityStatisInfo
                statisInfo.condition = taskTableData.condition_num[1]
                isFinished = statisInfo.value >= statisInfo.condition
            else
                local getContinuousValue = function(statisId)
                    local i = 1
                    local count = 0
                    local maxCount = 0
                    while i <= #activityStatisInfo do
                        local value = activityStatisInfo[i].value["sts" .. statisId]
                        if value and value > 0 then
                            count = 0
                            while value and value > 0 and i <= #activityStatisInfo do
                                count = count + 1
                                i = i + 1
                            end
                            if count > maxCount then
                                maxCount = count
                            end
                        end
                        i = i + 1
                    end

                    return maxCount
                end

                local getAccumulateValue = function(statisId)
                    local count = 0
                    for _, v in ipairs(activityStatisInfo) do
                        local value = v.value["sts" .. statisId]
                        if value and value > 0 then
                            count = count + 1
                        end
                    end

                    return count
                end

                if 1001 == taskConditionData.id then
                    -- 连续登录X天
                    statisInfo.value = getContinuousValue(2)
                    statisInfo.condition = taskTableData.condition_num[1]
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 1002 == taskConditionData.id or 1003 == taskConditionData.id then
                    -- 累积登录X天
                    statisInfo.value = getAccumulateValue(2)
                    statisInfo.condition = taskTableData.condition_num[1]
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 1103 == taskConditionData.id then
                    -- 连续充值X天
                    statisInfo.value = getContinuousValue(1)
                    statisInfo.condition = taskTableData.condition_num[1]
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 1104 == taskConditionData.id then
                    -- 累积充值X天
                    statisInfo.value = getAccumulateValue(1)
                    statisInfo.condition = taskTableData.condition_num[1]
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 1301 == taskConditionData.id then
                    -- 玩家等级
                    statisInfo.value = self._userModel:getData().lvl
                    statisInfo.condition = taskTableData.condition_num[1]
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 1302 == taskConditionData.id then
                    -- 兵团等级
                    local allTeamData = self._teamModel:getData()
                    local maxTeamLevel = tab:Setting("G_MAX_TEAMLEVEL").value
                    local teamLevel = 0
                    for k, v in pairs(allTeamData) do

                        if v.level > teamLevel then
                            teamLevel = v.level
                        end

                        if teamLevel >= maxTeamLevel then
                            teamLevel = maxTeamLevel
                            break
                        end
                    end
                    statisInfo.value = teamLevel
                    statisInfo.condition = taskTableData.condition_num[1]
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 1402 == taskConditionData.id then
                    -- 历史分享次数
                    statisInfo.value = playerStatis.snum16 and playerStatis.snum16 or 0
                    statisInfo.condition = taskTableData.condition_num[1]
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 2003 == taskConditionData.id then
                elseif 2004 == taskConditionData.id then
                elseif 2104 == taskConditionData.id then
                    -- 竞技场排名
                    --[[
                    local _, rank = self._arenaModel:getRank()
                    statisInfo.value = rank
                    statisInfo.condition = taskTableData.condition_num[1]
                    isFinished = statisInfo.value >= statisInfo.condition
                    ]]
                    statisInfo.value = playerStatis.snum7 and playerStatis.snum7 or 0
                    statisInfo.condition = taskTableData.condition_num[1]
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 2201 == taskConditionData.id then
                    -- 远征到X关
                    statisInfo.value = playerStatis.snum8 and playerStatis.snum8 or 0
                    statisInfo.condition = taskTableData.condition_num[1]
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 2207 == taskConditionData.id then
                    -- 历史开方尖碑数
                    statisInfo.value = playerStatis.snum12 and playerStatis.snum12 or 0
                    statisInfo.condition = taskTableData.condition_num[1]
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 2209 == taskConditionData.id then
                    -- 远征今日通过X关
                    local found = false
                    local info = playerStatis.dstr1
                    if info then
                        local t = string.split(tostring(info), ",")
                        if t then
                            for _, v in ipairs(t) do
                                if tonumber(v) == tonumber(taskTableData.condition_num[1]) then
                                    found = true
                                    break
                                end
                            end
                        end
                    end
                    statisInfo.value = found and taskTableData.condition_num[1] or 0
                    statisInfo.condition = taskTableData.condition_num[1]
                    statisInfo.isHideValue = true
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 3102 == taskConditionData.id then
                elseif 3201 == taskConditionData.id then
                elseif 3505 == taskConditionData.id then
                elseif 4001 == taskConditionData.id then
                elseif 4002 == taskConditionData.id then
                elseif 4101 == taskConditionData.id then
                elseif 4102 == taskConditionData.id then
                elseif 4103 == taskConditionData.id then
                elseif 4104 == taskConditionData.id then
                elseif 4105 == taskConditionData.id then                    
                elseif 4106 == taskConditionData.id then
                elseif 4107 == taskConditionData.id then
                elseif 4112 == taskConditionData.id then
                    -- 历史获得魔法之星数
                    statisInfo.value = playerStatis.snum15 and playerStatis.snum15 or 0
                    statisInfo.condition = taskTableData.condition_num[1]
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 4201 == taskConditionData.id then
                elseif 4202 == taskConditionData.id then
                elseif 4203 == taskConditionData.id then
                elseif 4204 == taskConditionData.id then
                elseif 4302 == taskConditionData.id then
                    -- 图鉴达到X级（取最高)
                    statisInfo.value = playerStatis.snum9 and playerStatis.snum9 or 0
                    statisInfo.condition = taskTableData.condition_num[1]
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 4303 == taskConditionData.id then
                    -- 图鉴放送
                    statisInfo.value = self._pokedexModel:getPokedexOnTeamByNum()
                    statisInfo.condition = taskTableData.condition_num[1]
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 4401 == taskConditionData.id then
                elseif 4501 == taskConditionData.id then
                elseif 4502 == taskConditionData.id then
                elseif 5001 == taskConditionData.id then
                elseif 5002 == taskConditionData.id then
                elseif 5003 == taskConditionData.id then
                    statisInfo.value = self._leagueModel:getCurZone()
                    statisInfo.condition = taskTableData.condition_num[1]
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 5004 == taskConditionData.id then
                    statisInfo.value = self._leagueModel:getMaxWin()
                    statisInfo.condition = taskTableData.condition_num[1]
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 5101 == taskConditionData.id then
                elseif 5102 == taskConditionData.id then
                elseif 5103 == taskConditionData.id then
                elseif 5104 == taskConditionData.id then
                elseif 5206 == taskConditionData.id then
                    statisInfo.value = self._userModel:getTaskStatisByType(6)
                    statisInfo.condition = taskTableData.condition_num[1]
                    isFinished = statisInfo.value >= statisInfo.condition    
                elseif 6001 == taskConditionData.id then
                    -- 拥有某个兵团
                    local teamId = taskTableData.condition_num[1]
                    local teamData = self._teamModel:getTeamAndIndexById(teamId)
                    statisInfo.value = teamData and 1 or 0
                    statisInfo.condition = 1
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 6101 == taskConditionData.id then
                    -- 拥有某个英雄
                    local heroId = taskTableData.condition_num[1]
                    statisInfo.value = self._heroModel:checkHero(heroId) and 1 or 0
                    statisInfo.condition = 1
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 6201 == taskConditionData.id then
                    -- 拥有某个宝物
                    local treasureId = taskTableData.condition_num[1]
                    statisInfo.value = self._treasureModel:getTreasureById(tostring(treasureId)) and 1 or 0
                    statisInfo.condition = 1
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 6301 == taskConditionData.id then
                    -- 某个英雄达到X星
                    local heroId = taskTableData.condition_num[1]
                    local star = taskTableData.condition_num[2]
                    local heroData = self._heroModel:getHeroData(heroId)
                    statisInfo.value = heroData and heroData.star or 0
                    statisInfo.condition = star
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 6302 == taskConditionData.id then
                    -- 某个英雄达到X星
                    local found = false
                    if taskTableData.condition_num then
                        for _, heroInfo in ipairs(taskTableData.condition_num) do
                            if type(heroInfo) == "table" then
                                local heroId = heroInfo[1]
                                local star = heroInfo[2]
                                local heroData = self._heroModel:getHeroData(heroId)
                                local heroStar = heroData and heroData.star or 0
                                if heroStar < star then
                                    found = true
                                    break
                                end
                            end
                        end
                    end
                    statisInfo.value = 0
                    statisInfo.condition = 0
                    isFinished = taskTableData.condition_num and not found
                elseif 6401 == taskConditionData.id then
                    -- 某个兵团达到X星
                    local found = false
                    if taskTableData.condition_num then
                        for _, teamInfo in ipairs(taskTableData.condition_num) do
                            if type(teamInfo) == "table" then
                                local teamId = teamInfo[1]
                                local star = teamInfo[2]
                                local teamData = self._teamModel:getTeamAndIndexById(teamId)
                                local teamStar = teamData and teamData.star or 0
                                if teamStar < star then
                                    found = true
                                    break
                                end
                            end
                        end
                    end
                    statisInfo.value = 0
                    statisInfo.condition = 0
                    isFinished = taskTableData.condition_num and not found
                elseif 6402 == taskConditionData.id then
                    -- 某个兵团达到X级
                    local teamId = taskTableData.condition_num[1]
                    local level = taskTableData.condition_num[2]
                    local teamData = self._teamModel:getTeamAndIndexById(teamId)
                    statisInfo.value = teamData and teamData.level or 0
                    statisInfo.condition = level
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 6403 == taskConditionData.id then
                    -- 某个兵团达到X品质
                    local teamId = taskTableData.condition_num[1]
                    local stage = taskTableData.condition_num[2]
                    local teamData = self._teamModel:getTeamAndIndexById(teamId)
                    statisInfo.value = teamData and teamData.stage or 0
                    statisInfo.condition = stage
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 6501 == taskConditionData.id then
                    -- X星英雄数量达到多少数量
                    local star = taskTableData.condition_num[1]
                    local count = taskTableData.condition_num[2]
                    local num = 0
                    local allHeroData = self._heroModel:getData()
                    for k, v in pairs(allHeroData) do
                        if v.star >= star then
                            num = num + 1
                        end
                    end
                    statisInfo.value = num
                    statisInfo.condition = count
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 6502 == taskConditionData.id then
                    -- X星兵团数量达到多少数量
                    local star = taskTableData.condition_num[1]
                    local count = taskTableData.condition_num[2]
                    local num = 0
                    local allTeamData = self._teamModel:getData()
                    for k, v in pairs(allTeamData) do
                        if v.star >= star then
                            num = num + 1
                        end
                    end
                    statisInfo.value = num
                    statisInfo.condition = count
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 6503 == taskConditionData.id then
                    -- X等级兵团数量达到多少数量
                    local level = taskTableData.condition_num[1]
                    local count = taskTableData.condition_num[2]
                    local num = 0
                    local allTeamData = self._teamModel:getData()
                    for k, v in pairs(allTeamData) do
                        if v.level >= level then
                            num = num + 1
                        end
                    end
                    statisInfo.value = num
                    statisInfo.condition = count
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 6504 == taskConditionData.id then
                    -- X品质兵团数量达到多少数量
                    local stage = taskTableData.condition_num[1]
                    local count = taskTableData.condition_num[2]
                    local num = 0
                    local allTeamData = self._teamModel:getData()
                    for k, v in pairs(allTeamData) do
                        if v.stage >= stage then
                            num = num + 1
                        end
                    end
                    statisInfo.value = num
                    statisInfo.condition = count
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 6505 == taskConditionData.id then
                    -- X级兵团符文有多少个
                    local level = taskTableData.condition_num[1]
                    local count = taskTableData.condition_num[2]
                    local num = 0
                    local allTeamData = self._teamModel:getData()
                    for k, v in pairs(allTeamData) do
                        for i = 1, 4 do
                            if v["el" .. i] >= level then
                                num = num + 1
                            end
                        end
                    end
                    statisInfo.value = num
                    statisInfo.condition = count
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 6506 == taskConditionData.id then
                    -- X品质兵团符文有多少个
                    local stage = taskTableData.condition_num[1]
                    local count = taskTableData.condition_num[2]
                    local num = 0
                    local allTeamData = self._teamModel:getData()
                    for k, v in pairs(allTeamData) do
                        for i = 1, 4 do
                            if v["es" .. i] >= stage then
                                num = num + 1
                            end
                        end
                    end
                    statisInfo.value = num
                    statisInfo.condition = count
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 6507 == taskConditionData.id then
                    -- X级英雄法术有多少个
                    local level = taskTableData.condition_num[1]
                    local count = taskTableData.condition_num[2]
                    local num = 0
                    local allHeroData = self._heroModel:getData()
                    for k, v in pairs(allHeroData) do
                        for i = 1, 5 do
                            if v["sl" .. i] >= level then
                                num = num + 1
                            end
                        end
                    end
                    statisInfo.value = num
                    statisInfo.condition = count
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 6405 == taskConditionData.id then
                    --某个兵团觉醒达到X星 
                    local teamId = taskTableData.condition_num[1]
                    local count = taskTableData.condition_num[2]
                    local tdata,_id = self._teamModel:getTeamAndIndexById(teamId)
                    local isAwaking, aLvl = TeamUtils:getTeamAwaking(tdata)
                    statisInfo.value = aLvl
                    statisInfo.condition = count
                    isFinished =  isAwaking and (statisInfo.value >= statisInfo.condition)
                elseif 6013 == taskConditionData.id then
                    --拥有X个觉醒兵团
                    local tb = self._teamModel:getAllAwakingTeam()
                    local value = #tb
                    local count = taskTableData.condition_num[1]
                    statisInfo.value = value
                    statisInfo.condition = count
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 7001 == taskConditionData.id then
                    --通过火元素位面第XX关  1
                    local count = taskTableData.condition_num[1]
                    local value = self._elementModel:getElementData()[1]
                    statisInfo.value = value
                    statisInfo.condition = count
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 7002 == taskConditionData.id then
                    --通过水元素位面第XX关 2
                    local count = taskTableData.condition_num[1]
                    local value = self._elementModel:getElementData()[2]
                    statisInfo.value = value
                    statisInfo.condition = count
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 7003 == taskConditionData.id then
                    --通过气元素位面第XX关 3
                    local count = taskTableData.condition_num[1]
                    local value = self._elementModel:getElementData()[3]
                    statisInfo.value = value
                    statisInfo.condition = count
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 7004 == taskConditionData.id then
                    --通过混乱元素位面第XX关 5
                    local count = taskTableData.condition_num[1]
                    local value = self._elementModel:getElementData()[5]
                    statisInfo.value = value
                    statisInfo.condition = count
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 7005 == taskConditionData.id then
                    --通过土元素位面第XX关 4
                    local count = taskTableData.condition_num[1]
                    local value = self._elementModel:getElementData()[4]
                    statisInfo.value = value
                    statisInfo.condition = count
                    isFinished = statisInfo.value >= statisInfo.condition
                 elseif 5105 == taskConditionData.id then
                    --联盟达到X级
                    local count = taskTableData.condition_num[1]
                    local value = self._modelMgr:getModel("GuildModel"):getAllianceDetail().level or 0
                    statisInfo.value = value
                    statisInfo.condition = count
                    isFinished = statisInfo.value >= statisInfo.condition
                elseif 8002 == taskConditionData.id then
                    --通关xx训练营
                    local trainedId = taskTableData.condition_num[1]
                    local trainingModel = self._modelMgr:getModel("TrainingModel")
                    statisInfo.isHideValue = true
                    isFinished = trainingModel["isTrainPassByType" ..trainedId](trainingModel)
                elseif 8003 == taskConditionData.id then
                    --在皇家演练场获得X个S
                    local count = taskTableData.condition_num[1]
                    local score = taskTableData.condition_num[2]
                    local trainingModel = self._modelMgr:getModel("TrainingModel")
                    local value = trainingModel:getNumByScore(score)
                    statisInfo.value = value
                    statisInfo.condition = count
                    isFinished = statisInfo.value >= statisInfo.condition
                end
            end
        end
    end

    if isGot then
        statisInfo.status = 0
    elseif isFinished then
        statisInfo.status = 1
    else
        statisInfo.status = -1
    end

    return statisInfo
end

function ActivityModel:evaluateActivityData(eventName, norefresh)

    if not self._isSetTimer then
        self:registerActivityTimer()
    end
    --[[
    if not self._isSetActivityData and self:isMonthCardCandGet() then
        SystemUtils.saveAccountLocalData("ACTIVITY_" .. 100, 0)
        self._isSetActivityData = true
    end
    ]]
    --[[
    if not self._isSetActivityData then
        SystemUtils.saveAccountLocalData("ACTIVITY_100000", 0)
        self._isSetActivityData = true
    end
    ]]

    if not self._setFlag1 and self:getTeHuiActivityOpen() then
        self:setTeHuiActivityChecked(false)
        self._setFlag1 = true
    end

    if not (self._acTableData and self._acTaskTableData and self._acConditionData) then
        self._acTableData = tab.dailyActivity
        self._acTaskTableData = tab.dailyActivityTask
        self._acConditionData = tab.dailyActivityCondition
    end

    local activityStatis = {}
    local tempActivityStatis = self._userModel:getActivityStatis()
    --dump(tempActivityStatis, "tempActivityStatis", 5)
    local index = 1
    if tempActivityStatis then
        for k, v in pairs(tempActivityStatis) do
            local timeFormat = string.sub(tostring(k), 1, 4) .. "-" .. string.sub(tostring(k), 5, 6) .. "-" .. string.sub(tostring(k), -2)  .. " 05:00:00"
            activityStatis[index] = {
                time = TimeUtils.getIntervalByTimeString(timeFormat),
                value = v
            }
            index = index + 1
        end

        table.sort(activityStatis, function(a, b)
            return a.time < b.time
        end)
    end 


    --dump(activityStatis, "activityStatis", 5)

    local playerStatis = self._userModel:getPlayerStatis()

    local self_getTaskStatusInfo = self.getTaskStatusInfo
    if self._data.acTask then
        for k, v in pairs(self._data.acTask) do
            repeat
                local activityInfo = self:getActivityInfo(tonumber(k))
                if not activityInfo then
                    self._data.acTask[tostring(k)] = nil
                    break 
                end
                local taskList = nil
                if self._acTableData[tonumber(k)] then
                    taskList = self._acTableData[tonumber(k)].task_list
                end
                v.taskList = {}
                if taskList then
                    for _, taskId in ipairs(taskList) do
                        local t = {}
                        t.id = tonumber(taskId)
                        t.times = v[tostring(taskId)] and v[tostring(taskId)] or 0
                        t.statusInfo = self_getTaskStatusInfo(self, t, activityInfo, activityStatis, playerStatis)
                        table.insert(v.taskList, t)
                    end
                end
            until true
        end
    end
    --dump(self._data, "activity data", 10)
    if not norefresh then
        self:reflashData(eventName and eventName or "evaluateActivityData")
    end
end

function ActivityModel:pushUserEvent()
    --print("pushUserEvent")
    self:evaluateActivityData("pushUserEvent")
end

function ActivityModel:onChangeActivity(data)
    -- self._modelMgr:getModel("GuildModel"):onGetRandRed(data)
    if not (data and data._carry_ and data._carry_.activity and data._carry_.activity.userEvent) then return end
    --print("onChangeActivity")
    self:evaluateActivityData("pushUserEvent")
end

--[[
--这个推送已经废弃
function ActivityModel:pushUserEvent(eventType)
    print("pushUserEvent:eventType", eventType)
    self:evaluateActivityData("pushUserEvent")
end
--这个推送已经废弃
function ActivityModel:pushActivityEvent(data)
    dump(data, "pushActivityEvent:data", 10)
    if data.acShowList then
        self:setActivityShowList(data.acShowList)
    end

    if data.activity.acSpecial then
       self:setActivitySpecialData(data.activity.acSpecial) 
    end

    if data.activity.acTask then
       self:setActivityTaskData(data.activity.acTask) 
    end

    self:evaluateActivityData("pushActivityEvent")
end
]]

function ActivityModel:onChangeActivityList(data, success)
    if not success then return end
    -- dump(self._data, "onChangeActivityList:data", 5)
    if data then
        for k, v in pairs(data) do
            if v.acStatisList then
                for k0, v0 in pairs(v.acStatisList) do
                    for k1, v1 in pairs(v0) do
                        self._data[tostring(k)].acStatisList[tostring(k0)][tostring(k1)] = v1
                    end
                end
                v.acStatisList = nil
            end

            if v.acTaskList then
                for k2, v2 in pairs(v.acTaskList) do
                    self._data[tostring(k)].acTaskList[tostring(k2)] = v2
                end
                v.acTaskList = nil
            end
            if v and type(v) == "table" and table.getn(v) > 0 then
                table.merge(self._data[tostring(k)], v)
            end
        end
    end
    -- dump(self._data, "onChangeActivityList:data", 5)
    self:reflashData("ActivityModel")
end

function ActivityModel:onChangeOpenInfo(data, success)
    if not success then return end
    -- dump(self._showListData, "ActivityModel:onChangeOpenInfo", 5)
    for k, v in pairs(data) do
        table.merge(self._showListData, v)
    end
    -- dump(self._showListData, "ActivityModel:onChangeOpenInfo", 5)
end

function ActivityModel:updateReward(data)
     dump(data, "updateReward", 5)

    if data["unset"] then 
        local removeItems = self._itemModel:handelUnsetItems(data["unset"])
        self._itemModel:delItems(removeItems, true)
    end

    if data["d"].items then
        self._itemModel:updateItems(data["d"].items)
        data["d"].items = nil
    end

    if data["d"].formations then
        self._formationModel:updateAllFormationData(data["d"].formations)
        data["d"].formations = nil
    end

    if data["d"].teams then
        self._teamModel:updateTeamData(data["d"].teams)
        data["d"].teams = nil
    end

    if data["d"].heros then
        self._heroModel:unlockHero(data["d"].heros)
        data["d"].heros = nil
    end

    if data["d"].vip then
        self._vipModel:updateVipExpData(data["d"].vip)
    end

    if data["d"].weaponInfo then
        self._weaponsModel:updateWeaponsInfo(data["d"].weaponInfo)
    end

    self._userModel:updateUserData(data["d"])
end

function ActivityModel:updateActivityData(data, success)
    if not success then return end
    -- dump(self._data, "updateActivityData:data", 5)
    if data["d"].activity then
        for k, v in pairs(data["d"].activity) do
            if "table" == type(v) then
                for k0, v0 in pairs(v) do
                    if "table" == type(v0) then
                        for k1, v1 in pairs(v0) do
                            self._data[tostring(k)][tostring(k0)][tostring(k1)] = v1
                        end
                    end
                end
            end
        end
    end
    data["d"].activity = nil
    self:updateReward(data)
    self:evaluateActivityData()
    --dump(self._data, "updateActivityData:data", 5)
end

function ActivityModel:updateSingleRechargeData(data, success)
    if not success then return end
    if data and data["d"].sRcg then
        local m = nil
        m = function(a, b)
            for k, v in pairs(b) do
                if type(a[k]) == "table" and type(v) == "table" then
                    m(a[k], v)
                else
                    a[k] = v
                end
            end
        end
        m(self._sRechargeData, data["d"].sRcg)
        data["d"].sRcg = nil
    end
    self:updateReward(data)
    self:evaluateActivityData()
end



function ActivityModel:updateAcHeroDuelDataAfterF(data)
    local acHeroDuel = data
    if self._acHeroDuelData == nil then
        self._acHeroDuelData = acHeroDuel
        return 
    end 
    if acHeroDuel.heroWin then
        if self._acHeroDuelData.heroWin == nil then
            self._acHeroDuelData.heroWin = {}
        end 
        for k,v in pairs(acHeroDuel.heroWin) do
            self._acHeroDuelData.heroWin[tostring(k)] = v
        end
    end 

    if acHeroDuel.winTotal then
        self._acHeroDuelData.winTotal = acHeroDuel.winTotal 
    end 

    if acHeroDuel.index then
        self._acHeroDuelData.index = acHeroDuel.index
    end 

    if acHeroDuel.tWins then
        if self._acHeroDuelData.tWins == nil then
            self._acHeroDuelData.tWins = {}
        end 
        for k,v in pairs(acHeroDuel.tWins) do
            self._acHeroDuelData.tWins[tostring(k)] = v
        end
    end 

    if acHeroDuel.taskList then
        if self._acHeroDuelData.taskList == nil then
            self._acHeroDuelData.taskList = {}
        end
        for k,v in pairs(acHeroDuel.taskList) do
            self._acHeroDuelData.taskList[tostring(k)] = v
        end
    end 
end
function ActivityModel:updateAcHeroDuelData(data, success)
    if not success then return end
    if data and data["d"].acHeroDuel then
        local acHeroDuel = data["d"].acHeroDuel
        self:updateAcHeroDuelDataAfterF(acHeroDuel)
        data["d"].acHeroDuel = nil
    end
    self:updateReward(data)
    self:evaluateActivityData()
end

function ActivityModel:updateAcRmbData(data, success)
    if not success then return end
    if data and data["d"].acRmb then
        local m = nil
        m = function(a, b)
            for k, v in pairs(b) do
                if type(a[k]) == "table" and type(v) == "table" then
                    m(a[k], v)
                else
                    a[k] = v
                end
            end
        end
        m(self._acRmbData, data["d"].acRmb)
        data["d"].acRmb = nil
    end
    self:updateReward(data)
    self:evaluateActivityData()
end

function ActivityModel:updateIntRechargeData(data, success)
    if not success then return end
    if data and data["d"].intelligentRecharge then
        local m = nil
        m = function(a, b)
            for k, v in pairs(b) do
                if type(a[k]) == "table" and type(v) == "table" then
                    m(a[k], v)
                else
                    a[k] = v
                end
            end
        end
        m(self._acIntRechargeData, data["d"].intelligentRecharge)
        data["d"].intelligentRecharge = nil
    end
    self:updateReward(data)
    self:evaluateActivityData()
end

function ActivityModel:isSingleRechargeCanGet(id)
    if not (self._sRechargeData and self._sRechargeData[tostring(id)]) then return false end
    for k, v in pairs(self._sRechargeData[tostring(id)]) do
        if 1 == v.status then
            return true
        end
    end
    return false
end

function ActivityModel:isAcHeroDuelCanGet()
    if not self._acHeroDuelData then return false end
    local acHeroDuleTb = tab.acheroDuel
    local acData = self._acHeroDuelData
    local isCan = false

    local isAlreadyGet = function (id)
        if acData.taskList == nil then return false end
        for k,v in pairs(acData.taskList) do
            if tonumber(k) == id and v == 1 then
                return true
            end 
        end
        return false
    end
    for k,v in pairs(acHeroDuleTb) do
        local data = v
        local conditionNum = v.condition_num
        if data.type == 1 then
            local value = acData.winTotal or 0
            isCan = value >= conditionNum[1] and not isAlreadyGet(data.id)
        elseif data.type == 2 then
            local condition = conditionNum[1]
            local value = 0 
            if type(acData.tWins) == "table" then
                local num = conditionNum[2]
                for k,v in pairs(acData.tWins) do
                   if v >= num then
                        value = value + 1
                   end
                end
            end
            isCan = value >= condition and not isAlreadyGet(data.id)
        elseif data.type == 3 then
            local heroId = conditionNum[1]
            local value = 0
            if type(acData.heroWin) == "table" then
                for k,v in pairs(acData.heroWin) do
                    if heroId == tonumber(k) then
                        value = tonumber(v)
                        break
                    end 
                end
            end
            isCan = value >= conditionNum[2] and not isAlreadyGet(data.id)
        end
        if isCan then
            break
        end
    end
    return isCan
end

function ActivityModel:isAcRmbCanGet(id)
    if not (self._acRmbData and self._acRmbData[tostring(id)]) then return false end
    for k, v in pairs(self._acRmbData[tostring(id)]) do
        if 1 == v.status then
            return true
        end
    end

    return false
end

function ActivityModel:hasActivityTaskCanGet()
    if self._data.acTask then
        local acOpenInfoTableData = tab.activityopen
        local findacOpenInfoTableData = function(acId)
            for k, v in pairs(acOpenInfoTableData) do
                if tonumber(v.activity_id) == tonumber(acId) then
                    local t = clone(v)
                    return true, t
                end
            end
            return false
        end

        for k, v in pairs(self._data.acTask) do
            repeat
                local f, d = findacOpenInfoTableData(tonumber(k))
                if f then
                    if d.level_limit then
                        local userLevel = self._userModel:getPlayerLevel()
                        if userLevel < d.level_limit then break end
                    end
                    if d.vip_limit then
                        local vipLevel = self._vipModel:getLevel()
                        if vipLevel < d.vip_limit then break end
                    end
                end
                if v.taskList then
                    for _, v in ipairs(v.taskList) do
                        if 1 == v.statusInfo.status then
                            return true
                        end
                    end
                end
            until true
        end
    end
    if self:isACERechargeTip() then
        return true
    end

    local isShow, isShowOnce = self:isMonthCardCandGet()
    if isShow then
        if isShowOnce then
            if not self._monthCardShowOnce then
                self._monthCardShowOnce = true
                return true
            end
        else
            return true
        end
    end

    if self:isShareDataTip() then
        return true
    end

    if self:isACERebateDateTip() then
        return true
    end

    --领取体力
    if self:isPhysicalCandGet() then
        return true
    end

    local singleRechargeId = self:getSignleRechargeId()
    if self:isSingleRechargeCanGet(singleRechargeId) then
        return true
    end

    if self:isAcRmbCanGet() then
        return true
    end

    if self._commentGuideModel:isAcShowRed() then
        return true
    end

    --是否有可找回的资源
    if self:checkRedTag_Acid_99998() then
        return true
    end

    --VIP周礼包红点
    if self:checkRedTag_Acid_107() then
        return true
    end

    --整点狂欢红点
    if self._lotterModel:isLotteryRed() then
        return true
    end

    -- 好友邀请红点
    if self:isFriendInvitedRed() then
        return true
    end

    -- 圣徽周卡
    if self:isRuneCardCandGet() then
        return true
    end
    if self:isZhuboCandGet() then
        return true
    end

    if self:isElementGiftRed() then
        return true
    end
    
    return false
end

function ActivityModel:hasActivityOpen()
    if not self._data.acTask then return 0 end
    return #self._data.acTask > 0
end

function ActivityModel:isMonthCardCandGet()
    local vipData = self._vipModel:getData()
    local curTime = self._userModel:getCurServerTime()
    local start_time = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 05:00:00"))
    if curTime < start_time then   --过零点判断
        start_time = start_time - 86400
    end

    local mCardData = (vipData["mCard"] and vipData["mCard"]["payment_month"]) or nil
    local isMCardBuy = (mCardData and mCardData["expireTime"]) and mCardData["expireTime"] >= curTime or false  --是否已购买
    local isMCardGet = (mCardData and mCardData["lastUpTime"]) and mCardData["lastUpTime"] >= start_time or false  --是否已领奖

    local hMCardData = vipData["mCard"] and vipData["mCard"]["payment_monthsuper"] or nil   
    local isHMCardBuy = (hMCardData and hMCardData["expireTime"]) and hMCardData["expireTime"] >= curTime or false  --是否已购买
    local isHMCardGet = (hMCardData and hMCardData["lastUpTime"]) and hMCardData["lastUpTime"] >= start_time or false  --是否已领奖

    if (isMCardBuy and not isMCardGet) or (isHMCardBuy and not isHMCardGet)  then   --已买未领奖
        return true, false
    end  
    if not isMCardBuy and not isHMCardBuy and not self._isCheckMonthCard then  --均未买+未查看过
        return true, true
    end

    -- if (not isMCardBuy and isHMCardGet) or       --卡1未买 卡2已领
    --         (isMCardGet and not isHMCardBuy) and not self._isCheckMonthCard then  --卡1已领 卡2未买  + 未查看过
    --         print("****************************456")
    --     return true
    -- end

    return false, false
end

function ActivityModel:setCheckMCardState()
    self._isCheckMonthCard = true
end

function ActivityModel:getDragonOpenData()
    -- body
    -- TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(self._userModel:getData()._it,"%Y-%m-%d 05:00:00"))
    
    -- 开服时间
    -- local serverStarTime = self._userModel:getData().sec_open_time or 0
    -- local starTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(serverStarTime,"%Y-%m-%d 05:00:00"))
    -- if serverStarTime < startTime then
    --     startTime = startTime - 86400
    -- end
    -- local subTime = createTime - firstReshTime
    -- if subTime < 0 then
    --     firstReshTime = firstReshTime - 86400
    -- end
    -- local openTime = startTime + 2 * 86400
    -- local endTime = startTime + 8 * 86400
end

function ActivityModel:isActivityOpen(activityId)
    if not self._showListData then return false end
    for _, v in ipairs(self._showListData) do
        if v.activity_id == activityId and 1 == v.is_open then
            return true
        end
    end
    return false
end

function ActivityModel:getAbilityEffect(privilegID)
    for k, v in pairs(tab.actPlus) do
        if v.att[1][1] == privilegID and self:isActivityOpen(v.id) then
            return v.att[1][2]
        end
    end
    return 0
end

--是否有可领取的体力
function ActivityModel:isPhysicalCandGet()    
    return self._modelMgr:getModel("PhysicalPowerModel"):isHaveRedTag()
end

-- 根据类型获取活动数据
-- 14 幸运星
-- 33 幸运星（图灵）
function ActivityModel:getAcShowDataByType(acType)
    local luckShowData = {}
    for k,v in pairs(self._showListData) do
        if acType == v.ac_type then            
            luckShowData = clone(v)
            break
        end
    end
    -- dump(shareShowData,"shareShowData")
    return luckShowData
end

-- 幸运星数据
function ActivityModel:getLuckStarData()
    -- self._userModel
    local luckShowData = self:getAcShowDataByType(14)
    local luckStarData = {}
    local userData = self._userModel:getData()

    if userData and userData.award and userData.award.luckStar then
        local luckData = userData.award.luckStar         
        local acId = luckShowData.activity_id
        if luckData and luckData[tostring(acId)] then
            luckStarData = luckData[tostring(acId)]
            luckStarData.level_limit = luckShowData.level_limit or 0
            luckStarData.vip_limit = luckShowData.vip_limit or 0
        end
    end

    -- dump(luckStarData,"luckStarData==>")
    return luckStarData
end

-- 幸运星 红点
function ActivityModel:isLuckStarRed()
    local luckShowData = self:getAcShowDataByType(14)
    local luckStarData = {}
    local userData = self._userModel:getData()
    local isRed = false

    if userData and userData.award and userData.award.luckStar then
        local luckData = userData.award.luckStar         
        local acId = luckShowData.activity_id
        if luckData and luckData[tostring(acId)] then
            luckStarData = luckData[tostring(acId)]
            if luckStarData.status and luckStarData.status == 2 then
                isRed = true
            end
        end
    end

    return isRed
end

-- 幸运领主（图灵）数据
function ActivityModel:getLuckTulingData()
    -- self._userModel
    local luckStarData = self:getAcShowDataByType(33)
    local userData = self._userModel:getData()

    if userData and userData.award and userData.award.turingLuckStar then
        local luckData = userData.award.turingLuckStar         
        local acId = luckStarData.activity_id
        local sData = luckData and luckData[tostring(acId)] or {}
        if sData then
            luckStarData.reward = sData.reward or {}
            luckStarData.status = sData.status or 1
            luckStarData.recharge = sData.recharge or 6

        end
    end

    dump(luckStarData,"tulling--luckStarData==>")
    return luckStarData
end

-- 幸运领主（图灵）红点
function ActivityModel:isLuckTulingRed()
    local isRed = not self._isTulingClicked
    if isRed then 
        return true
    end
    local luckShowData = self:getAcShowDataByType(33)
    local userData = self._userModel:getData()
    if userData and userData.award and userData.award.turingLuckStar then
        local luckData = userData.award.turingLuckStar         
        local acId = luckShowData.activity_id
        local sData = luckData and luckData[tostring(acId)] or {}
        if sData then
            if sData.status and sData.status == 2 then
                isRed = true
            end
        end
    end

    return isRed
end
function ActivityModel:setTulingClicked()
    self._isTulingClicked = true
end


-- 一元购活动是否打开过
function ActivityModel:isOneChargeOpen()
    return self._isOpenCharde
end

function ActivityModel:setOneChargeOpenStatus(status)
    self._isOpenCharde = status
end

--[[
    VIP 周礼包
]]
function ActivityModel:setVipWeeklyGifts(result)
    self._weekGiftData = result or {}
end

function ActivityModel:getWeeklyGift()
    return self._weekGiftData
end

--[[
    五点检测活动是否过期
]]
function ActivityModel:checkOutData_107()
    local currTime = self._userModel:getCurServerTime()
    if self._weekGiftData and table.nums(self._weekGiftData) > 0 then
        if self._weekGiftData.endTime and currTime >= self._weekGiftData.endTime then
           self._weekGiftData.outData = true
        end
    end
end

--[[
    是否显示周礼包
]]
function ActivityModel:isShowWeeklyGift()
    local level = self._userModel:getData().lvl
    if self._weekGiftData and table.nums(self._weekGiftData) > 0 and not self._weekGiftData.outData and level >= 6 then
        return true
    end
end

--[[
    更新礼包领取状态
]]
function ActivityModel:updateWeeklyGiftDataAfterGet(index)
    self._weekGiftData.weeklyGifts[tostring(index)].hasBuy = 1
end

--[[
    更新礼包试手气
]]
function ActivityModel:updateWeeklyGiftAfterLuck(id,result)
    local data = self._weekGiftData.weeklyGifts[tostring(id)]
    for k,v in pairs (result) do 
        data[k] = result[k]
    end
end

--[[
    周礼包红点
]]
function ActivityModel:checkRedTag_Acid_107()
    print("ActivityModel:checkRedTag_Acid_107 1")
    local vipLv = self._vipModel:getLevel()
    if self._weekGiftData and self._weekGiftData.weeklyGifts 
        and table.nums(self._weekGiftData.weeklyGifts) > 0 and not self._weekGiftData.haveIn then
        print("ActivityModel:checkRedTag_Acid_107 2")
        local data = self._weekGiftData.weeklyGifts
        for i=1,16 do 
            local gift = data[tostring(i)]
            if vipLv + 1 > i then
                if gift.hasBuy ~= 1 then
                    return true
                end
            else
                break
            end
        end
    end
    return false
end

-- offLine 

-- 'exp'=>core_Schema::NUM, //玩家领取经验
-- 'gold'=>core_Schema::NUM, //玩家领取金币
-- 'tExp'=>core_Schema::NUM, //玩家领取兵团经验
-- 'lt'=>core_Schema::NUM, //上次结算时间
-- 'gExp'=>core_Schema::NUM, //玩家免费该补的经验
-- 'gGold'=>core_Schema::NUM, //玩家免费该补的金币
-- 'gtExp'=>core_Schema::NUM, //玩家免费该补的兵团经验
-- 'gExp2'=>core_Schema::NUM, //玩家收费该补的经验
-- 'gGold2'=>core_Schema::NUM, //玩家收费该补的金币
-- 'gtExp2'=>core_Schema::NUM, //玩家收费该补的兵团经验
-- 'expCost'=>core_Schema::NUM,//付费离线经验的花费
-- 'goldCost'=>core_Schema::NUM,//付费金币的花费
-- 'tExpCost'=>core_Schema::NUM,//付费兵团经验的花费
--离线找回
function ActivityModel:setRetrieveData(result)
    if not result or table.nums(result) <= 0 then
        self._retrieveData = {}
        self._retrieveData.gExp = -15000
        self._retrieveData.gGold = 15000
        self._retrieveData.gtExp = 0
        self._retrieveData.gExp2 = -20000
        self._retrieveData.gGold2 = 3500000
        self._retrieveData.gtExp2 = 0
        self._retrieveData.expCost = 200
        self._retrieveData.goldCost = 200
        self._retrieveData.tExpCost = 200
        return
    end
    self._retrieveData = result
end

function ActivityModel:getRetrieveData()
    return self._retrieveData or {}
end

function ActivityModel:setRetrieveDataAfterGet(key)
    if not self._retrieveData then return end
    if not self._retrieveData[key] then self._retrieveData[key] = 0 end
    if self._retrieveData[key] > 0 then
         self._retrieveData[key] = -self._retrieveData[key]
        dump(self._retrieveData)
    end
end

function ActivityModel:updateRetrieveData(data)
    for key,value in pairs (data) do 
        self._retrieveData[key] = value
    end
end

--是否有可免费找回的离线奖励
function ActivityModel:checkRedTag_Acid_99998()
    if not self._retrieveData or table.nums(self._retrieveData) <= 0 then
        return false
    end
    if (self._retrieveData.gExp and self._retrieveData.gExp > 0 and self._retrieveData.gExp2 and self._retrieveData.gExp2 > 0)
        or (self._retrieveData.gGold and self._retrieveData.gGold > 0 and self._retrieveData.gGold2 and self._retrieveData.gGold2 > 0)
            or (self._retrieveData.gtExp and self._retrieveData.gtExp > 0 and self._retrieveData.gtExp2 and self._retrieveData.gtExp2 > 0) then
        return true
    end
    return false
end

--是否活动列表显示时间市场
function ActivityModel:isShowOffLine()
    if not self._retrieveData or table.nums(self._retrieveData) <= 0 then
        return false
    end

    local lvl = self._userModel:getData().lvl --开启等级34
    if lvl < 34 then
        return
    end

    if  (self._retrieveData.gExp2 and self._retrieveData.gExp2 > 0)
            or (self._retrieveData.gGold2 and self._retrieveData.gGold2 > 0)
                or (self._retrieveData.gtExp2 and self._retrieveData.gtExp2 > 0) then
        return true
    end
    return false
end

-- 元素庆典活动是否领奖
function ActivityModel:isElementAcGetAward(activityId)
    return self._userModel:getElementGetState(activityId)
end

function ActivityModel:setMCardClickType(inType)
    self._mCardClickType = inType
end

function ActivityModel:getMCardClickType()
    return self._mCardClickType or -1
end


function ActivityModel:getSignleRechargeId()
    for _, v in ipairs(self._showListData) do
        if v.ac_type == 8  then
            return v.activity_id
        end
    end
end

-- 获取好友邀请活动数据
function ActivityModel:getInvitedData()
    if not self._invitedData then
        self._invitedData = self._userModel:getPromotionData()
    end
    return self._invitedData or {}
end
-- 更新
function ActivityModel:updateInvitedData(data)
    if not data then return end
    if not self._invitedData then
        self._invitedData = self._userModel:getPromotionData()
    end

    local func = nil
    func = function(a, b)
        for k, v in pairs(b) do
            if type(a[k]) == "table" and type(v) == "table" then
                func(a[k], v)
            else
                a[k] = v
            end
        end
    end
    func(self._invitedData, data)

    -- print("=========更新邀请好友数据========")
    -- dump(data,"data==>",6)
    -- dump(self._invitedData,"upadteData==>",6)
end

--好友邀请活动红点
function ActivityModel:isFriendInvitedRed()
    if not self._invitedData then
        self._invitedData = self._userModel:getPromotionData()
    end
    local isRed = false
    -- 任务列表
    if not self._invitedTbData then
        self._invitedTbData = clone(tab.activityInviteNew)
    end
    local taskData = self._invitedTbData

    local sOpenIds = self._invitedData.sOpenIds or {}          -- 已发送的玩家sOpenId列表
    local bSOpenIds = self._invitedData.bSOpenIds or {}        -- 已绑定的玩家sOpenId 列表
    local sSOpenIds = self._invitedData.sSOpenIds or {}        -- 已达成的sOpenId 列表
    local rewardList = self._invitedData.rewardList or {}      -- 已领取的奖励 列表

    local achieveNum = table.nums(sSOpenIds) or 0   
    -- 完成数量
    local comNum = 0
    for k,v in pairs(taskData) do
        if v.condition and v.condition <= achieveNum then
            comNum = comNum + 1
        end        
    end
    -- 领取数量
    local getNum = table.nums(rewardList) or 0    
    isRed = comNum ~= 0 and comNum > getNum or false

    return isRed
end
-- 获取某类型的所有活动
function ActivityModel:getAcAllShowDataByType(acType)
    local showData = {}
    for k,v in pairs(self._showListData) do
        if acType == v.ac_type then            
            table.insert(showData, v)
        end
    end
    return showData
end

-- 获取每日任务界面物品掉落
function ActivityModel:getDailyTaskAward()
    -- 获取额外掉落类型活动
    local acData = self:getAcAllShowDataByType(6)
    if not acData then 
        return {}
    end
    local arrData = {}
    for k,v in pairs(acData) do
        local isOpen = self:isActivityOpen(v.activity_id) 
        if isOpen then
            local exReward = tab:ActExReward(tonumber(v.activity_id))
            local awards = {}            
            if exReward and exReward.att then
                for k,v in pairs(exReward.att) do
                    if 5 == v[1] then
                        awards = v[2]
                    end

                end
            end
            for k,v in pairs(awards) do
                if v[4] and v[4] == 100 then
                    if not arrData[v[5]] then 
                        arrData[v[5]] = {}
                    end
                    table.insert(arrData[v[5]], v)
                end
            end 
        end        
    end  

    return arrData
end

-- 获取圣徽周卡数据
function ActivityModel:isRuneCardCandGet()
    local runeCard = self._userModel:getRuneCardData()
    local currTime = self._userModel:getCurServerTime()
    if not runeCard or not runeCard.expireTime or runeCard.expireTime < currTime then
        return false
    end
    if runeCard and runeCard.oneTimeStatus and runeCard.oneTimeStatus == 0 then
        return true
    end
    local infoNum = self._modelMgr:getModel("PlayerTodayModel"):getDayInfo(87)
    if infoNum == 0 then
        return true
    end
    return false
end


-- 主播活动红点
function ActivityModel:isZhuboCandGet()
    local acData = self:getAcShowDataByType(41)
    local currT = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local startT = acData.start_time or 0
    local endT = acData.disappear_time or 0

    local dayInfo = self._modelMgr:getModel("PlayerTodayModel"):getData() or {}
    local isRed = not (dayInfo and dayInfo.day88 == 1)
    if currT < startT or currT >= endT then
        isRed = false
    end

    return isRed
end

--元素馈赠红点
function ActivityModel:isElementGiftRed()
    local isRed = false
    if not self._eleGift then
        self._eleGift = clone(tab.eleGift)
    end
    -- 有可领奖励
    local acData = self._userModel:getElementGiftData()
    -- 活动没开
    if not self:isElementGiftOpen() then
        return false
    end
    local gIds = acData.gIds or {}
    local aday = acData.aday or 0
    local Active_day = 0
    for k,v in pairs(self._eleGift) do
        if aday >= v.Active_day and not gIds[tostring(v.id)] then
            isRed = true
            break
        end
    end
    -- 当天第一次红点
    if not isRed then
        local curServerTime = self._userModel:getCurServerTime()
        local timeDate
        local tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
        if curServerTime > tempCurDayTime then
            timeDate = TimeUtils.getDateString(curServerTime,"%Y%m%d")
        else
            timeDate = TimeUtils.getDateString(curServerTime - 86400,"%Y%m%d")
        end
        local tempdate = SystemUtils.loadAccountLocalData("ACTIVITY_ELEMGIFT")
        if tempdate ~= timeDate then
            isRed = true
        end
    end
    return isRed
end

--元素馈赠是否开启
function ActivityModel:isElementGiftOpen()
    if not GameStatic.is_show_eleGift then
        return false
    end
    if not self._eleGift then
        self._eleGift = clone(tab.eleGift)
    end
    local openTimeStr = tab:Setting("ELEMENT_GIFT_OPENING_TIME").value
    if openTimeStr then 
        -- print("openTimeStr==================",openTimeStr)
        local openTime = TimeUtils.getIntervalByTimeString(openTimeStr)
        local currTime = self._userModel:getCurServerTime()
        -- print("===============openTime,currTime======",openTime,currTime)
        if currTime < openTime then
            return false
        end
    end
    local giftNum = table.nums(self._eleGift)
    local isOpen = false
    local acData = self._userModel:getElementGiftData()
    dump(acData,"acData==>",5)
    if acData and acData.sts and tonumber(acData.sts) == 1 then
        isOpen = true
    end
    if isOpen and acData.gIds and type(acData.gIds) == "table" then
        -- 活动奖励全部领取 活动结束
        if giftNum == table.nums(acData.gIds) then
           isOpen = false
        end
    end

    return isOpen
end

function ActivityModel.dtor()
    tostring = nil
    tonumber = nil
end

return ActivityModel
