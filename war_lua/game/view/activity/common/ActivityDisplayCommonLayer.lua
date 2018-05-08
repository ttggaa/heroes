--
-- Author: huangguofang
-- Date: 2017-05-06 16:02:26
-- Description: 没有配置描述文字

local ActivityDisplayCommonLayer = class("ActivityDisplayCommonLayer", require("game.view.activity.common.ActivityCommonLayer"))

function ActivityDisplayCommonLayer:getAsyncRes()
    return 
    {
        -- {"asset/ui/activityShare.plist", "asset/ui/activityShare.png"},
    }
end


function ActivityDisplayCommonLayer:ctor(data)
    self.super.ctor(self)
    -- print("=============================",data.activityId)
    self._activityId = tonumber(data.activityId) or 98
    self._activityData = {}
    self._acServerData = {}
    
end

function ActivityDisplayCommonLayer:onInit()
    self.super.onInit(self)

    self._activityModel = self._modelMgr:getModel("ActivityModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    --静态表数据
    -- print("=============================",self._activityId )
    -- self._activityId = 98
    
     self._goBtnPos = {
        [2078] = {500,60}
    }
    local goBtn = self:getUI("bg.goBtn")
    local pos = self._goBtnPos[self._activityId]
    if pos then
        goBtn:setPosition(pos[1], pos[2])
    end

    local goData = tab:ActPlus(self._activityId)
    self._goIndex = nil
    if goData and goData.att and goData.att[1] and goData.att[1][1] then
        self._goIndex = goData.att[1][1]
    end 
    self._activityData = tab:DailyActivity(self._activityId)
    self._bg = self:getUI("bg")
    self._bg:setBackGroundImage("asset/bg/" .. self._activityData.titlepic1 .. ".jpg")

    self._endTime = self:getUI("bg.endTime")
    self._endTime:setColor(UIUtils.colorTable.ccColorQuality2)
    self._endTime:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    --goBtn
    self:registerClickEventByName("bg.goBtn", function()
        -- 如果没找到goindex 根据ID跳转 17.09.23
        if self._goIndex then
            if self["jumpToView" .. self._goIndex] then
                self["jumpToView" .. self._goIndex](self,1)
            end
        else
            if self["jumpToViewById" .. self._activityId] then
                self["jumpToViewById" .. self._activityId](self,1)
            end
        end
    end)
    self:reflashUI()
end

function ActivityDisplayCommonLayer:reflashUI(data)
  
    self._acServerData = self._activityModel:getACCommonShowList(self._activityId)
    dump(self._acServerData,"self._acServerData==>")
    -- dump(sData,"sData==>")
    local starTime = self._acServerData.start_time or self._userModel:getCurServerTime() 
    local endTime = self._acServerData.end_time or self._userModel:getCurServerTime() 
    local tempTime = self._acServerData.end_time - self._userModel:getCurServerTime() 
    local startTb = TimeUtils.getDateString(starTime,"*t")
    local endTb = TimeUtils.getDateString(endTime,"*t")
    -- local dateString = string.format("%d月%d日%d时-%d月%d日%d时",startTb.month,startTb.day,startTb.hour,endTb.month,endTb.day,endTb.hour)  

    local day, hour, minute, second, tempValue    
    self:runAction(cc.RepeatForever:create(
        cc.Sequence:create(cc.CallFunc:create(function()
            tempTime = tempTime - 1
            tempValue = tempTime
            -- print("day======", tempValue)
            day = math.floor(tempValue/86400) 
            tempValue = tempValue - day*86400
            -- print("hour======", tempValue)
            hour = math.floor(tempValue/3600)
            tempValue = tempValue - hour*3600
            -- print("minute r======", tempValue)
            minute = math.floor(tempValue/60)
            tempValue = tempValue - minute*60
            -- print("second ======", tempValue)
            second = math.fmod(tempValue, 60)
            local showTime = string.format("%.2d天%.2d:%.2d:%.2d", day, hour, minute, second)
            if day == 0 then
                showTime = string.format("00天%.2d:%.2d:%.2d", hour, minute, second)
            end
            if tempTime <= 0 then
                showTime = "00天00:00:00"
            end
            self._endTime:setString(showTime)
            
        end), cc.DelayTime:create(1))
    ))

end
-- 远征
function ActivityDisplayCommonLayer:jumpToView401(num)
    if not SystemUtils:enableCrusade() then
        self._viewMgr:showTip(lang("TIP_Crusade"))
        return 
    end
    self._viewMgr:showView("crusade.CrusadeView")
end
-- 远征
function ActivityDisplayCommonLayer:jumpToView402(num)
    self:jumpToView401()
end

-- 矮人
function ActivityDisplayCommonLayer:jumpToView301() 
    if not SystemUtils:enableDwarvenTreasury() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    self._viewMgr:showView("pve.AiRenMuWuView") 
end
-- 墓穴
function ActivityDisplayCommonLayer:jumpToView302() 
    if not SystemUtils:enableCrypt() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    self._viewMgr:showView("pve.ZombieView") 
end
-- 龙之国
function ActivityDisplayCommonLayer:jumpToView303() 
    if not SystemUtils:enableBoss() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    self._viewMgr:showView("pve.DragonView") 
end
--兵营
function ActivityDisplayCommonLayer:jumpToView104() 
    local isOpen = SystemUtils:enableNests()
    if not isOpen then
        self._viewMgr:showTip(lang("TIP_GUILD_OPEN_5"))
        return 
    end
    self._viewMgr:showView("nests.NestsView",{cId = 101})
end
--兵营
function ActivityDisplayCommonLayer:jumpToView105() 
    self:jumpToView104()
end
-- 普通副本
function ActivityDisplayCommonLayer:jumpToView101()
    self._viewMgr:showView("intance.IntanceView") 
end
-- 普通副本
function ActivityDisplayCommonLayer:jumpToView10101() 
    self:jumpToView101() 
end
-- 普通副本
function ActivityDisplayCommonLayer:jumpToView10102()
    self:jumpToView101()
end
-- 普通副本
function ActivityDisplayCommonLayer:jumpToView10103() 
    self:jumpToView101()
end
-- 精英副本
function ActivityDisplayCommonLayer:jumpToView102() 
    
    if not SystemUtils:enableElite() then
        self._viewMgr:showTip(lang("TIP_JINGYING_1"))
        return 
    end
    self._viewMgr:showView("intance.IntanceEliteView", {superiorType = 1}) 
end

-- 跳转云中城
function ActivityDisplayCommonLayer:jumpToView304()     
    if not SystemUtils:enableCloudCity() then
        self._viewMgr:showTip(lang("TIP_TOWER"))
        return 
    end
    self._viewMgr:showView("cloudcity.CloudCityView")
end

-- 跳转航海
function ActivityDisplayCommonLayer:jumpToView601()     
    if not SystemUtils:enableMF() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    self._viewMgr:showView("MF.MFView")
end

-- 跳转交易所 金币双倍
function ActivityDisplayCommonLayer:jumpToView204()    
    if not SystemUtils:enableUser_buyGold() then
        local systemOpenTip = tab.systemOpen["User_buyGold"][3]
        if not systemOpenTip then
            self._viewMgr:showTip(tab.systemOpen["User_buyGold"][1] .. "级开启")
        else
            self._viewMgr:showTip(lang(systemOpenTip))
        end
        
        return 
    end 
    self._viewMgr:showDialog("global.GlobalTradeDialog",{goalType = "gold",tabIdx = 1}) --,closeCallback = callback
end

-- 跳转交易所 兵团经验双倍
function ActivityDisplayCommonLayer:jumpToView205()
    DialogUtils.showBuyRes({goalType = "texp"})  --callback = function( )end
end

-- 跳转交易所 法术卷轴双倍
function ActivityDisplayCommonLayer:jumpToView206()    
    DialogUtils.showBuyRes({goalType="magicNum"}) --callback = function( )end
end

-- 元素位面
function ActivityDisplayCommonLayer:jumpToView310()
    if not SystemUtils:enableElement() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    self._viewMgr:showView("elemental.ElementalView")

end

-- 大世界
function ActivityDisplayCommonLayer:jumpToView900()
    self._viewMgr:showView("intance.IntanceView")
end

-- 根据ID跳转 2059跳转大世界
function ActivityDisplayCommonLayer:jumpToViewById2059()
    self._viewMgr:showView("intance.IntanceView")
end

-- 根据ID跳转 2078跳转副本最新進度
function ActivityDisplayCommonLayer:jumpToViewById2078()
    self._viewMgr:showView("intance.IntanceView")
end

-- 根据ID跳转 2082跳转战役
function ActivityDisplayCommonLayer:jumpToViewById2082()
    if not SystemUtils:enableCrusade() then
        self._viewMgr:showTip(lang("TIP_Crusade"))
        return 
    end
    self._viewMgr:showView("crusade.CrusadeView")
end

-- 根据ID跳转 2087跳转每日任务
function ActivityDisplayCommonLayer:jumpToViewById2087()
    if not SystemUtils["enableDailyTask"]() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    self._viewMgr:showView("task.TaskView",{viewType = 2})
end
return ActivityDisplayCommonLayer