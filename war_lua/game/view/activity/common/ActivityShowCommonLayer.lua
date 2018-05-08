--[[
    Filename:    ActivityShowCommonLayer.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2016-07-28 16:05:25
    Description: 有配置描述文字
--]]

local ActivityShowCommonLayer = class("ActivityShowCommonLayer", require("game.view.activity.common.ActivityCommonLayer"))

function ActivityShowCommonLayer:getAsyncRes()
    return 
    {
        -- {"asset/ui/activityShare.plist", "asset/ui/activityShare.png"},
    }
end

function ActivityShowCommonLayer:ctor(data)
    self.super.ctor(self)
    -- print("=============================",data.activityId)
    self._activityId = tonumber(data.activityId) or 98
    self._activityData = {}
    self._acServerData = {}
    
end

function ActivityShowCommonLayer:onInit()
    self.super.onInit(self)

    self._activityModel = self._modelMgr:getModel("ActivityModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    --静态表数据
    -- print("=============================",self._activityId )
    -- self._activityId = 98
    
    local goData = tab:ActPlus(self._activityId)
    self._goIndex = nil
    if goData and goData.att and goData.att[1] and goData.att[1][1] then
        self._goIndex = goData.att[1][1]
    end 
    self._activityData = tab:DailyActivity(self._activityId)
    self._bg = self:getUI("bg")
    self._bg:setBackGroundImage("asset/bg/" .. self._activityData.titlepic1 .. ".jpg")

    self._activityDate = self:getUI("bg.activity_date")
    self._endTime = self:getUI("bg.endTime")

    local desTxt = self:getUI("bg.desTxt")
    local str = lang(self._activityData.description) or ""
    if string.find(str, "color=") == nil then
        str = "[color=fff9b2]"..str.."[-]"
    end
    local desTxtRich = RichTextFactory:create(str, 330, 40)
    desTxtRich:formatText()
    desTxtRich:setName("desTxtRichTxt")
    -- desTxtRich:setVerticalSpace(3)
    -- desTxtRich:setAnchorPoint(cc.p(0,1))
    desTxtRich:setPosition(225,225)
    -- desTxtRich:setPosition(desTxt:getPosition())
    self._bg:addChild(desTxtRich, 5)
    desTxt:setString("")

    -- local mc = mcMgr:createViewMC("xuanshihuodong_carnivaltargetanim", true,false)
    -- mc:setPosition(70, 70)
    -- self._bg:addChild(mc,10)

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

function ActivityShowCommonLayer:reflashUI(data)
  
    self._acServerData = self._activityModel:getACCommonShowList(self._activityId)
    -- dump(self._acServerData,"self._acServerData==>") 
    -- dump(sData,"sData==>")
    local starTime = self._acServerData.start_time or self._userModel:getCurServerTime() 
    local endTime = self._acServerData.end_time or self._userModel:getCurServerTime() 
    local tempTime = self._acServerData.end_time - self._userModel:getCurServerTime() 
    local startTb = TimeUtils.getDateString(starTime,"*t")
    local endTb = TimeUtils.getDateString(endTime,"*t")
    local dateString = string.format("%d月%d日%d时-%d月%d日%d时",startTb.month,startTb.day,startTb.hour,endTb.month,endTb.day,endTb.hour)  
    self._activityDate:setString(dateString)

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
function ActivityShowCommonLayer:jumpToView401(num)
    if not SystemUtils:enableCrusade() then
        self._viewMgr:showTip(lang("TIP_Crusade"))
        return 
    end
    self._viewMgr:showView("crusade.CrusadeView")
end
-- 远征
function ActivityShowCommonLayer:jumpToView402(num)
    self:jumpToView401()
end

-- 矮人
function ActivityShowCommonLayer:jumpToView301() 
    if not SystemUtils:enableDwarvenTreasury() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    self._viewMgr:showView("pve.AiRenMuWuView") 
end
-- 墓穴
function ActivityShowCommonLayer:jumpToView302() 
    if not SystemUtils:enableCrypt() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    self._viewMgr:showView("pve.ZombieView") 
end
-- 龙之国
function ActivityShowCommonLayer:jumpToView303() 
    if not SystemUtils:enableBoss() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    self._viewMgr:showView("pve.DragonView") 
end
--兵营
function ActivityShowCommonLayer:jumpToView104() 
    local isOpen = SystemUtils:enableNests()
    if not isOpen then
        self._viewMgr:showTip(lang("TIP_GUILD_OPEN_5"))
        return 
    end
    self._viewMgr:showView("nests.NestsView",{cId = 101})
end
--兵营
function ActivityShowCommonLayer:jumpToView105() 
    self:jumpToView104()
end
-- 普通副本
function ActivityShowCommonLayer:jumpToView101()
    self._viewMgr:showView("intance.IntanceView") 
end
-- 普通副本
function ActivityShowCommonLayer:jumpToView10101() 
    self:jumpToView101() 
end
-- 普通副本
function ActivityShowCommonLayer:jumpToView10102()
    self:jumpToView101()
end
-- 普通副本
function ActivityShowCommonLayer:jumpToView10103() 
    self:jumpToView101()
end
-- 精英副本
function ActivityShowCommonLayer:jumpToView102() 
    
    if not SystemUtils:enableElite() then
        self._viewMgr:showTip(lang("TIP_JINGYING_1"))
        return 
    end
    self._viewMgr:showView("intance.IntanceEliteView", {superiorType = 1}) 
end

-- 跳转云中城
function ActivityShowCommonLayer:jumpToView304()     
    if not SystemUtils:enableCloudCity() then
        self._viewMgr:showTip(lang("TIP_TOWER"))
        return 
    end
    self._viewMgr:showView("cloudcity.CloudCityView")
end

-- 跳转航海
function ActivityShowCommonLayer:jumpToView601()     
    if not SystemUtils:enableMF() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    self._viewMgr:showView("MF.MFView")
end

-- 跳转交易所 金币双倍
function ActivityShowCommonLayer:jumpToView204()    
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
function ActivityShowCommonLayer:jumpToView205()
    DialogUtils.showBuyRes({goalType = "texp"})  --callback = function( )end
end

-- 跳转交易所 法术卷轴双倍
function ActivityShowCommonLayer:jumpToView206()    
    DialogUtils.showBuyRes({goalType="magicNum"})  --callback = function( )end
end

-- 元素位面
function ActivityShowCommonLayer:jumpToView310()
    if not SystemUtils:enableElement() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    self._viewMgr:showView("elemental.ElementalView")

end

-- 大世界
function ActivityShowCommonLayer:jumpToView900()
    self._viewMgr:showView("intance.IntanceView")
end


-- 根据ID跳转 2059跳转大世界
function ActivityShowCommonLayer:jumpToViewById2059()
    self._viewMgr:showView("intance.IntanceView")
end

return ActivityShowCommonLayer