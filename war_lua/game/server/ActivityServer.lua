--[[
    Filename:    ActivityServer.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2016-01-26 20:29:17
    Description: File description
--]]

local ActivityServer = class("ActivityServer", BaseServer)

function ActivityServer:ctor()
    ActivityServer.super.ctor(self)

    -- 庆典model
    self._celebrationModel = self._modelMgr:getModel("CelebrationModel")
    self._acLotteryModel = self._modelMgr:getModel("AcLotteryModel")    -- 通用活动整点抽奖
end

function ActivityServer:onGetAcAll(result, error)
    --dump(result, "ActivityServer:onGetTaskAcInfo", 5)
    if not self._activityModel then
        self._activityModel = self._modelMgr:getModel("ActivityModel")
    end
    self._activityModel:setAllActivityData(0 == tonumber(error), result)
    self:callback(0 == tonumber(error))
end

function ActivityServer:onGetTaskAcInfo(result, error)
    --dump(result, "ActivityServer:onGetTaskAcInfo", 5)
    if not self._activityModel then
        self._activityModel = self._modelMgr:getModel("ActivityModel")
    end
    self._activityModel:setActivityTaskData(result)
    self:callback(0 == tonumber(error))
end

function ActivityServer:onGetShowList(result, error)
    --dump(result, "ActivityServer:onGetShowList", 5)
    if not self._activityModel then
        self._activityModel = self._modelMgr:getModel("ActivityModel")
    end
    self._activityModel:setActivityShowList(result)
    self:callback(0 == tonumber(error))
end

function ActivityServer:onChangeActivityList(result, error)
    --dump(result, "ActivityServer:onChangeActivityList", 5)
    if not self._activityModel then
        self._activityModel = self._modelMgr:getModel("ActivityModel")
    end
    self._activityModel:onChangeActivityList(result, 0 == error)
end

function ActivityServer:onChangeOpenInfo(result, error)
    --dump(result, "ActivityServer:onChangeOpenInfo", 5)
    if not self._activityModel then
        self._activityModel = self._modelMgr:getModel("ActivityModel")
    end
    self._activityModel:onChangeOpenInfo(result, 0 == error)
end

function ActivityServer:onGetTaskAcReward(result, error)
    --dump(result, "ActivityServer:onMainActivityReward", 5)
    if not self._activityModel then
        self._activityModel = self._modelMgr:getModel("ActivityModel")
    end
    self._activityModel:updateActivityData(result, 0 == tonumber(error))
    self:callback(0 == tonumber(error), result)
end

function ActivityServer:onGetSpecialAcReward(result, error)
    if error ~= 0 then 
        return
    end 
    self:handAboutServerData(result)
    self:callback(result)
    -- dump(result, "ActivityServer:onMainActivityReward", 5)
    -- self._activityModel:updateActivityData(result, 0 == tonumber(error))
    -- self:callback(0 == tonumber(error))
end

function ActivityServer:onDetailActivityReward(result, error)
    --dump(result, "ActivityServer:onDetailActivityReward", 5)
    --self._activityModel:updateDetailActivityData(result["d"], 0 == tonumber(error))
    --self:callback(0 == tonumber(error), result["d"])
end

function ActivityServer:onFinishShare(result, error)
    -- dump(result, "shareResult")
    self:handAboutServerData(result)
    self:callback(0 == tonumber(error))
end
--[[
--这个推送已经废弃
function ActivityServer:onPushUserEvent(eventType)
    --print("ActivityServer:pushUserEvent", eventType)
    if not self._activityModel then
        self._activityModel = self._modelMgr:getModel("ActivityModel")
    end
    self._activityModel:pushUserEvent(eventType)
end

--这个推送已经废弃
function ActivityServer:onPushActivityEvent(data)
    --dump(data, "pushActivityEvent:data", 10)
    if not self._activityModel then
        self._activityModel = self._modelMgr:getModel("ActivityModel")
    end
    self._activityModel:pushActivityEvent(data)
    
    -- 更新嘉年华活动的开启
    self._modelMgr:getModel("ActivityCarnivalModel"):updateCarnivalData()
end
]]
function ActivityServer:handAboutServerData(result)
    if result == nil then 
        return 
    end

    if result["d"]["activity"] ~= nil then
        local activityModel = self._modelMgr:getModel("ActivityModel")
        activityModel:updateSpecialData(result["d"]["activity"])
        result["d"]["activity"] = nil 
    end
    -- -- 物品数据处理要优先于怪兽
    if result["d"]["items"] ~= nil then
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(result["d"]["items"], true)
        result["d"]["items"] = nil 
    end
    -- 删除背包中道具 
    if result["unset"] ~= nil then 
        local itemModel = self._modelMgr:getModel("ItemModel")
        local removeItems = itemModel:handelUnsetItems(result["unset"])
        itemModel:delItems(removeItems, true)
    end

    if result["d"]["teams"] ~= nil  then 
        local teamModel = self._modelMgr:getModel("TeamModel")
        teamModel:updateTeamData(result["d"]["teams"])
        result["d"]["teams"] = nil
    end 

    if result["d"]["hero"] ~= nil  then 
        local heroModel = self._modelMgr:getModel("HeroModel")
        heroModel:unlockHero(result["d"]["hero"])
        result["d"]["hero"] = nil
    end 

    if result["d"]["weaponInfo"] ~= nil  then 
        local weaponsModel = self._modelMgr:getModel("WeaponsModel")
        weaponsModel:updateWeaponsInfo(result["d"]["weaponInfo"])
        result["d"]["weaponInfo"] = nil
    end

    local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(result["d"])
end

-- -- 每日折扣服务端调用回调方法:购买数量变更推送
function ActivityServer:onDailyDiscount(result, error)
    if error ~= 0 then 
        return
    end
    if not self._activityRebateModel then
        self._activityRebateModel = self._modelMgr:getModel("ActivityRebateModel")
    end
    self._activityRebateModel:updateACERebateAllPlayer(result)
    self:callback(result)
end

-- 获取每日折扣活动信息
function ActivityServer:onGetDailyDiscountInfo(result, error)
    if error ~= 0 then 
        return
    end
    if not self._activityRebateModel then
        self._activityRebateModel = self._modelMgr:getModel("ActivityRebateModel")
    end
    -- self._activityRebateModel:isACERebateData(true)
    self:callback(result)
    self._activityRebateModel:updateACERebateAllPlayer(result)
end

-- 获取特殊活动信息
function ActivityServer:onGetSpecialInfo(result, error)
    if error ~= 0 then 
        return
    end
    if not self._activityModel then
        self._activityModel = self._modelMgr:getModel("ActivityModel")
    end
    if result["d"] and result["d"]["activity"] then
        self._activityModel:updateSpecialData(result["d"]["activity"])
    end
    -- self._activityModel:isACERebateData(true)
    -- self._activityModel:updateACERebateAllPlayer(result)
    self:callback(result)
end

function ActivityServer:onGetReward(result, error)
    if 0 ~= tonumber(error) then return end

    if not self._activityModel then
        self._activityModel = self._modelMgr:getModel("ActivityModel")
    end

    self._activityModel:updateSingleRechargeData(result, 0 == tonumber(error))
    self:callback(0 == tonumber(error), result)
end

function ActivityServer:onGetIntelligentReward(result, error)
    if 0 ~= tonumber(error) then return end

    if not self._activityModel then
        self._activityModel = self._modelMgr:getModel("ActivityModel")
    end

    self._activityModel:updateIntRechargeData(result, 0 == tonumber(error))
    self:callback(0 == tonumber(error), result)
end

-- 公测庆典
-- 获取集字信息
function ActivityServer:onGetCollectionTextInfo(result, error)
    -- body
    if 0 ~= tonumber(error) then return end

    -- dump(result["celebrity"],"activityServer---->",5)
    if result["celebrity"] then
        self._celebrationModel:updateData(result["celebrity"])
        result["celebrity"] = nil
    end

    self:callback(result,0 == tonumber(error))
end
-- 获取集字奖励
function ActivityServer:onGetCollectionReward(result, error)
    -- body
    if 0 ~= tonumber(error) then return end

    -- dump(result["celebrity"],"activityServer---->",5)
    if result["d"] and result["d"]["celebrity"] then
        self._celebrationModel:updateData(result["d"]["celebrity"])
        result["d"]["celebrity"] = nil
    end

    self:handAboutServerData(result)
    self:callback(result,0 == tonumber(error))

end
-- 获取好友赠送文字列表
function ActivityServer:onGetFriendSendTexts(result, error)
    -- body
    if 0 ~= tonumber(error) then return end

    -- dump(result,"result==>",5)
    self:callback(result,0 == tonumber(error))

end
-- 接收好友送的字
function ActivityServer:onReceiveFriendText(result, error)
    -- body
    if 0 ~= tonumber(error) then return end
    -- dump(result,"result==>",5)
    if result["d"] and result["d"]["celebrity"] then
        self._celebrationModel:updateData(result["d"]["celebrity"])
        result["d"]["celebrity"] = nil
    end
    self:handAboutServerData(result)
    self:callback(result,0 == tonumber(error))

end

-- 获取赠送好友列表
function ActivityServer:onGetInsufficientTextFriends(result, error)
    -- body
    if 0 ~= tonumber(error) then return end
    self:callback(result,0 == tonumber(error))
end

-- 赠送好友文字
function ActivityServer:onGiveTextToFriend(result, error)
    -- body
    if 0 ~= tonumber(error) then return end
    
    if  result["d"] and result["d"]["celebrity"] then
        self._celebrationModel:updateData(result["d"]["celebrity"])
        result["d"]["celebrity"] = nil
    end
    self:handAboutServerData(result)
    self:callback(result,0 == tonumber(error))
end

-- 兑换道具
function ActivityServer:onExchangeItem(result, error)
    -- body
    if 0 ~= tonumber(error) then return end
    -- dump(result,"result==>",5)
    if  result["d"] and result["d"]["celebrity"] then
        self._celebrationModel:updateData(result["d"]["celebrity"])
        result["d"]["celebrity"] = nil
    end
    self:handAboutServerData(result)
    self:callback(result,0 == tonumber(error))
end

-- 好友狂欢 领取好友奖励
function ActivityServer:onReceiveFriendCeleGift(result, error)
    -- print("=======================error==",error)
    if 0 ~= tonumber(error) then return end
    -- dump(result,"result==>",5)
    if  result["d"] and result["d"]["celebrity"] then
        self._celebrationModel:updateData(result["d"]["celebrity"])
        result["d"]["celebrity"] = nil
    end
    self:handAboutServerData(result)
    self:callback(result,0 == tonumber(error))
end

-- 获取整点狂欢信息
function ActivityServer:onGetCelebrityInfo(result, error)
    -- body
    if 0 ~= tonumber(error) then return end

    -- dump(result["celebrity"],"activityServer---->",5)
    if result["celebrity"] then
        self._celebrationModel:updateData(result["celebrity"])
        result["celebrity"] = nil
    end

    self:callback(result, 0 == tonumber(error))
end

-- 获取整点狂欢参与人数
function ActivityServer:onGetTakeInPunctualityActiveNum(result, error)

    -- body
    if 0 ~= tonumber(error) then return end

    -- dump(result["celebrity"],"activityServer---->",5)
    if result["d"]["celebrity"] then
        self._celebrationModel:updateData(result["d"]["celebrity"], "punctualityActiveNum")
        result["d"]["celebrity"] = nil
    end

    self:callback(result, 0 == tonumber(error))
end

-- 整点狂欢参与抽奖
function ActivityServer:onParticipatePunctuality(result, error)
    -- body
    if 0 ~= tonumber(error) then return end

    --dump(result,"activityServer---->",5)
    if result["d"]["celebrity"] then
        self._celebrationModel:updateData(result["d"]["celebrity"])
        result["d"]["celebrity"] = nil
    end

    self:callback(result, 0 == tonumber(error))
end

-- 整点狂欢领取奖励
function ActivityServer:onGetPuncReward(result, error)
    if 0 ~= tonumber(error) then return end
    -- dump(result,"result==>",5)
    if  result["d"] and result["d"]["celebrity"] then
        self._celebrationModel:updateData(result["d"]["celebrity"])
        result["d"]["celebrity"] = nil
    end
    self:handAboutServerData(result)
    self:callback(result, 0 == tonumber(error))
end

-- 整点狂欢开奖
function ActivityServer:onPushUserWinInfo(result, error)
    -- body
    if 0 ~= tonumber(error) then return end

    -- dump(result,"activityServer---->",5)
    if result["d"]["celebrity"] then
        self._celebrationModel:updateData(result["d"]["celebrity"], "pushUserWinInfo")
        result["d"]["celebrity"] = nil
    end
end

-- 通用活动整点抽奖
-- 获取抽奖数据
function ActivityServer:onGetLotteryInfo(result, error)
    if 0 ~= tonumber(error) then return end

    -- dump(result,"activityServer---->",5)
    if result["d"] and result["d"]["lottery"] then
        self._acLotteryModel:updateData(result["d"]["lottery"])
        result["lottery"] = nil
    end

    self:callback(result, 0 == tonumber(error))
    
end
-- 获取抽奖奖励
function ActivityServer:onGetLotteryReward(result, error)
    if 0 ~= tonumber(error) then return end

    dump(result,"getLotteryReward",5)
    if  result["d"] and result["d"]["lottery"] then
        self._acLotteryModel:updateData(result["d"]["lottery"])
        result["d"]["lottery"] = nil
    end
    self:handAboutServerData(result)

    self:callback(result, 0 == tonumber(error))
end
-- 参与抽奖
function ActivityServer:onParticipateLottery(result, error)
    if 0 ~= tonumber(error) then return end

    -- dump(result,"participateLottery",5)
    if result["d"]["lottery"] then
        self._acLotteryModel:updateData(result["d"]["lottery"])
        result["d"]["lottery"] = nil
    end

    self:callback(result, 0 == tonumber(error))
end
-- 获取参与人数
function ActivityServer:onGetLotteryActiveNum(result, error)
    if 0 ~= tonumber(error) then return end

    -- dump(result,"getLotteryActiveNum",5)
    if result["d"]["lottery"] then
        self._acLotteryModel:updateData(result["d"]["lottery"], "getLotteryActiveNum")
        result["d"]["lottery"] = nil
    end

    self:callback(result, 0 == tonumber(error))
end
-- 开奖推送
function ActivityServer:onPushLotteryWinInfo(result, error)
    -- body
    if 0 ~= tonumber(error) then return end

    -- dump(result,"activityServer---->",5)
    if result["d"]["lottery"] then
        self._acLotteryModel:updateData(result["d"]["lottery"], "onPushLotteryWinInfo")
        result["d"]["lottery"] = nil
    end
end



--[[
    giftId  1~16  VIP周礼包随机立减
]]
function ActivityServer:onWeeklyGiftRandomCut(result, error)
    if 0 ~= tonumber(error) then return end
    dump(result,"ActivityServer:onWeeklyGiftRandomCut",10)
    self:callback(result)
end

--[[
    giftId  1~16  购买VIP周礼包
]]
function ActivityServer:onBuyWeeklyGift(result, error)
    if 0 ~= tonumber(error) then return end
    self:handAboutServerData(result)
    self:callback(result)
end

--[[
    获取VIP 周礼包最新20条消息
]]
function ActivityServer:onGetWeeklyGiftNotice(result, error)
    -- dump(result,"onGetWeeklyGiftNotice",10)
    if 0 ~= tonumber(error) then return end
    for _,v in pairs (result) do 
        v.init = true
    end
    self:callback(result)
end

-- 原生推广员(好友邀请) 获取数据
function ActivityServer:onGetPromotionInfo(result, error)
    if 0 ~= tonumber(error) then return end
    -- dump(result,"onGetPromotionInfo==>",5)
    if result["promotion"] then
        local acModel = self._modelMgr:getModel("ActivityModel")
        acModel:updateInvitedData(result["promotion"])
    end
    self:callback(result)
end
-- 原生推广员(好友邀请) 邀请好友
function ActivityServer:onInviteFriend(result, error)
    if 0 ~= tonumber(error) then return end
    -- dump(result,"onInviteFriend==>",5)
    if result["d"] and result["d"]["promotion"] then
        local acModel = self._modelMgr:getModel("ActivityModel")
        acModel:updateInvitedData(result["d"]["promotion"])
    end
    self:callback(result)
end
-- 原生推广员(好友邀请) 领取奖励
function ActivityServer:onGetPromotionReward(result, error)
    if 0 ~= tonumber(error) then return end
    -- dump(result,"onGetPromotionReward==>",5)
    if result["d"] and result["d"]["promotion"] then
        local acModel = self._modelMgr:getModel("ActivityModel")
        acModel:updateInvitedData(result["d"]["promotion"])
    end
    self:handAboutServerData(result)
    self:callback(result)
end

function ActivityServer:onGetRadioReward(result, error)
    if 0 ~= tonumber(error) then return end
    -- dump(result,"onGetPromotionReward==>",5)
    self:handAboutServerData(result)
    self:callback(result)
end

return ActivityServer