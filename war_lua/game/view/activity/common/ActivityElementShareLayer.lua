--
-- Author: huangguofang
-- Date: 2017-07-15 14:32:18
--

local ActivityElementShareLayer = class("ActivityElementShareLayer", require("game.view.activity.common.ActivityCommonLayer"))

function ActivityElementShareLayer:getAsyncRes()
    return 
    {
        -- {"asset/ui/activityShare.plist", "asset/ui/activityShare.png"},
    }
end


function ActivityElementShareLayer:ctor(data)
    self.super.ctor(self)
    -- print("=============================",data.activityId)
    self._activityId = tonumber(data.activityId) or 1
    self._acServerData = {}
    self._activityModel = self._modelMgr:getModel("ActivityModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    
end

function ActivityElementShareLayer:onInit()
    self.super.onInit(self)

    self._bg = self:getUI("bg")
    self._activityData = tab:DailyActivity(self._activityId)
    self._bg:setBackGroundImage("asset/bg/" .. self._activityData.titlepic1 .. ".jpg")

    self._getImg = self:getUI("bg.getImg")
    self._goBtn = self:getUI("bg.goBtn")
    self._getImg:setVisible(false)
    self._goBtn:setVisible(true)
    local shareAward = tab:Setting("G_SHARE_" .. self._activityId)
    self._reward = shareAward and shareAward.value or {}
    if not self._reward then 
        self._reward = {}
    end
    local itemW = 90
    local rewardPanel = self:getUI("bg.rewardPanel")
    local subX = rewardPanel:getContentSize().width - table.nums(self._reward)*itemW 
    subX = subX * 0.5
    for k,v in pairs(self._reward) do
        local icon 
        local itemId 
        if v[1] == "team" then
            local teamId  = v[2]
            local teamD = tab.team[teamId]
            itemData = teamD
            icon = IconUtils:createSysTeamIconById({sysTeamData = teamD})
            icon:setName("icon" .. k)
            -- local iconColor = item:getChildByName("iconColor")
            -- iconColor:loadTexture("globalImageUI_squality_jin.png",1)
            -- iconColor:setContentSize(cc.size(107, 107))
            icon:setScale(0.75)
        else
            if v[1] == "tool"then
                itemId = v[2]
            else
                itemId = IconUtils.iconIdMap[v[1]]
            end
            local toolD = tab:Tool(tonumber(itemId))
            icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = v[3]})
            icon:setName("icon" .. k)
            icon:setScale(0.85)
        end
        icon:setPosition(subX + (tonumber(k) - 1)*itemW,8)
        icon:setAnchorPoint(0,0)
        rewardPanel:addChild(icon)
    end
    -- share now
    self:registerClickEventByName("bg.goBtn", function()
        self:shareBtnClicked()
    end)
    self:addCutDownTxt()
    self:reflashUI()
end

-- 添加倒计时
function ActivityElementShareLayer:addCutDownTxt()

    self._acServerData = self._activityModel:getACCommonShowList(self._activityId)
    -- dump(self._acServerData,"self._acServerData==>") 

    -- 活动时间
    local starTime = self._acServerData.start_time or self._userModel:getCurServerTime() 
    local endTime = self._acServerData.end_time or self._userModel:getCurServerTime() 
    local currTime = self._userModel:getCurServerTime()
    local time = tonumber(endTime) - tonumber(currTime)
    local timeStr = TimeUtils.getTimeStringFont1(time)

    local timeDes = self:getUI("bg.cdDes")
    local endTimeTxt = self:getUI("bg.endTime")
    timeDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    endTimeTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    endTimeTxt:setString(timeStr)
    if currTime >= endTime then
        endTimeTxt:setString("0天00:00:00")
    else
        local repeatAction = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
            local currTime = self._userModel:getCurServerTime()
            local time = tonumber(endTime) - tonumber(currTime)
            local timeStr = TimeUtils.getTimeStringFont1(time)
            endTimeTxt:setString(timeStr)
            if currTime >= endTime then
                endTimeTxt:setString("0天00:00:00")
                endTimeTxt:stopAllActions()
            end
        end)))
        endTimeTxt:runAction(repeatAction)
    end
end
function ActivityElementShareLayer:reflashUI(data)
    local state = self._activityModel:isElementAcGetAward(self._activityId) 
    self._getImg:setVisible(state)
    self._goBtn:setVisible(not state)
end

-- 立即分享
function ActivityElementShareLayer:shareBtnClicked()
	-- print("==========立即分享=====================")
	local param = {moduleName = "ShareElementAcModule",acId = self._activityId}   --share_team_race_107
    param["callback1"] = function(inType)
        if self.getShareAward then
            self:getShareAward(inType)
        end
    end

    self._viewMgr:showDialog("share.ShareBaseView", param)
end

-- 领奖
function ActivityElementShareLayer:getShareAward(inType)
	--发送领奖协议,更新当前状态
    self._serverMgr:sendMsg("UserServer", "shareWithNoCondition", {id=self._activityId}, true, {}, function(data)
        self:reflashUI()

        if data["reward"] then 
            DialogUtils.showGiftGet({ gifts = data["reward"]})
        end        
    end)
end
return ActivityElementShareLayer