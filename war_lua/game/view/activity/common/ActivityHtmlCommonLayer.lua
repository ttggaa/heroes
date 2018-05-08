--
-- Author: huangguofang
-- Date: 2017-05-15 16:02:26
--

local ActivityHtmlCommonLayer = class("ActivityHtmlCommonLayer", require("game.view.activity.common.ActivityCommonLayer"))

function ActivityHtmlCommonLayer:getAsyncRes()
    return 
    {
        -- {"asset/ui/activityShare.plist", "asset/ui/activityShare.png"},
    }
end


function ActivityHtmlCommonLayer:ctor(data)
    self.super.ctor(self)
    -- print("=============================",data.activityId)
    self._activityId = tonumber(data.activityId) or 98
    self._activityData = {}
    
end
--[[
    2023  分享有礼
    99990 关注有礼
    99992 龙珠直播
    99994 邀请有礼wx
    99995 邀请有礼qq
    99991 权利游戏
    99989 腾讯大王卡
    99986 华夏银行
]]
function ActivityHtmlCommonLayer:onInit()
    self.super.onInit(self)
    self._btnImg = {
        [2023] = "globalBtnUI_special1.png",
        [99990] = "globalBtnUI_special1.png",
        [99991] = "powerGameBtn.png",
        [99992] = "globalBtnUI_special1.png",
        [99994] = "globalButtonUI13_3_1.png",
        [99995] = "globalButtonUI13_3_1.png",
        [99989] = "tencentCard_btn.png",
        [99986] = "ac_huaxiaBankBtn.png",
    }
    self._btnOutline = {
        [2023] = UIUtils.colorTable.ccUICommonBtnOutLine1,
        [99990] = UIUtils.colorTable.ccUICommonBtnOutLine1,
        [99992] = UIUtils.colorTable.ccUICommonBtnOutLine1,
        [99994] = UIUtils.colorTable.ccUICommonBtnOutLine6,
        [99995] = UIUtils.colorTable.ccUICommonBtnOutLine6,
    }
    self._btnText = {
        [2023] = "关注有礼",
        [99990] = "关注有礼",
        [99989] = "",
        [99986] = "",
    }

    self._btnPos = {
        [99990] = {284, 50},
        [99991] = {456, 220},
        [99989] = {416, 95},
        [99986] = {550,270},
    }
    self._activityModel = self._modelMgr:getModel("ActivityModel")

    self._activityData = tab:DailyActivity(self._activityId)
    self._bg = self:getUI("bg")
    self._bg:setBackGroundImage("asset/bg/" .. self._activityData.titlepic1 .. ".jpg")

    --goBtn
    local btnImgName = self._btnImg[self._activityId]--(self._activityId == 2023) and "globalBtnUI_special1.png" or "globalButtonUI13_2_1.png"
    if not btnImgName then
        btnImgName = "globalButtonUI13_2_1.png"
    end
    local btnTxt = self._btnText[self._activityId] or "立即前往"
    if self._activityId == 99991 then 
        btnTxt = ""
    end
    local outlineColor = self._btnOutline[self._activityId]--(self._activityId == 2023) and UIUtils.colorTable.ccUICommonBtnOutLine1 or UIUtils.colorTable.ccUICommonBtnOutLine7
    if not outlineColor then
        outlineColor = UIUtils.colorTable.ccUICommonBtnOutLine7
    end
    local goBtn = self:getUI("bg.goBtn")
    if self._btnPos[self._activityId] then 
        goBtn:setPosition(self._btnPos[self._activityId][1], self._btnPos[self._activityId][2])
    end
    goBtn:loadTextures(btnImgName,btnImgName,btnImgName,1)
    goBtn:setTitleText(btnTxt)
    goBtn:getTitleRenderer():enableOutline(outlineColor, 2)
    self:registerClickEventByName("bg.goBtn", function()
        if self._activityId and self["jumpToView" .. self._activityId] then
            self["jumpToView" .. self._activityId](self,1)
        end
    end)
    self:reflashUI()
end

function ActivityHtmlCommonLayer:reflashUI(data)
  
end
-- id 25000  微信推广员
function ActivityHtmlCommonLayer:jumpToView25000()
    local userModel = self._modelMgr:getModel("UserModel")
    local tempUrl = string.format(GameStatic.wxTuiGuangYuanUrl, tostring(GameStatic.sec), tostring(userModel:getRID()),tostring(userModel:getUserName()))
    sdkMgr:loadUrl({url = tempUrl})
    -- print("============userModel:getRID()===",userModel:getRID(),GameStatic.sec,userModel:getUserName())
    -- print("============tempUrl===",tempUrl)
end

-- id 2023  微信关注公众号
function ActivityHtmlCommonLayer:jumpToView2023()
    if OS_IS_IOS then
        -- ios
        sdkMgr:loadUrl({url = GameStatic.wxPublicUrlIOS})
    elseif OS_IS_ANDROID then
        -- Android
        sdkMgr:loadUrl({url = GameStatic.wxPublicUrl})
    else
        sdkMgr:loadUrl({url = GameStatic.wxPublicUrl})
    end
end

-- ID 99994 微信邀请有礼
function ActivityHtmlCommonLayer:jumpToView99994()
    -- if sdkMgr:isQQ() then
    --     print("==qqUrl==",GameStatic.qqInviteUrl)
    --     sdkMgr:loadUrl({url = GameStatic.qqInviteUrl})
    -- elseif sdkMgr:isWX() then
    print("==wxUrl==",GameStatic.wxInviteUrl)
    sdkMgr:loadUrl({url = GameStatic.wxInviteUrl})
    -- else
    --     print("==wxUrl==",GameStatic.qqInviteUrl)
    -- end
end

-- ID 99995 QQ邀请有礼
function ActivityHtmlCommonLayer:jumpToView99995()    
    print("==qqUrl==",GameStatic.qqInviteUrl)
    sdkMgr:loadUrl({url = GameStatic.qqInviteUrl})   
end

-- ID 99992 龙珠直播
function ActivityHtmlCommonLayer:jumpToView99992()    
    print("==longzhuLiveUrl==",GameStatic.longzhuLiveUrl)
    sdkMgr:loadUrl({url = GameStatic.longzhuLiveUrl})   
end

-- ID 99991 权利游戏
function ActivityHtmlCommonLayer:jumpToView99991()    
    print("==powerGameUrl==",GameStatic.powerGameUrl)
    if GameStatic.powerGameUrl and GameStatic.powerGameUrl ~= "" then 
        local userModel = self._modelMgr:getModel("UserModel")
        local tempUrl = GameStatic.powerGameUrl
        local platid = 0   --平台 安卓1  ios0
        local areaid = 1   -- 微信 1   qq 2

        if OS_IS_IOS then
            platid = 0
        elseif OS_IS_ANDROID then
            platid = 1
        end
        if sdkMgr:isQQ() then
            areaid = 2
        elseif sdkMgr:isWX() then
            areaid = 1
        end
        local flag = "?"
        if string.find(tempUrl,"?") then
            flag = ""
        end
        tempUrl = tempUrl .. flag .. string.format("partition=%s&roleid=%s&platId=%s&areaId=%s", 
            tostring(GameStatic.sec), 
            tostring(userModel:getRID()),
            platid,
            areaid)

        sdkMgr:loadUrl({url = tempUrl})
    end 
end

-- ID 99990 关注有礼
function ActivityHtmlCommonLayer:jumpToView99990() 
    print("==wxPublicUrl==",GameStatic.wxPublicUrl)   
    if OS_IS_IOS then
        -- ios
        sdkMgr:loadUrl({url = GameStatic.wxPublicUrlIOS})
    elseif OS_IS_ANDROID then
        -- Android
        sdkMgr:loadUrl({url = GameStatic.wxPublicUrl})
    else
        sdkMgr:loadUrl({url = GameStatic.wxPublicUrl})
    end   
end

-- ID 99989 腾讯大王卡
function ActivityHtmlCommonLayer:jumpToView99989() 
    print("==tencentCardUrl==",GameStatic.tencentCardUrl)   
    sdkMgr:loadUrl({url = GameStatic.tencentCardUrl})
end

-- ID 99986 华夏银行
function ActivityHtmlCommonLayer:jumpToView99986() 
    print("==huaxiaBankUrl==",GameStatic.huaxiaBankUrl)   
    sdkMgr:loadUrl({url = GameStatic.huaxiaBankUrl})
end

return ActivityHtmlCommonLayer