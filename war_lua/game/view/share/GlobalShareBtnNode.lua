--[[
    Filename:    GlobalShareBtnNode.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-2-8 16:24:21
    Description: 分享通用按钮
--]]

local GlobalShareBtnNode = class("GlobalShareBtnNode", BaseMvcs, ccui.Widget)

local showType = { --1开 0不开
    ShareArenaModule = 0,               --竞技场====
    ShareArenaWinModule = 1,            --竞技场胜利
    ShareLeagueWinModule = 0,           --积分联赛 胜利=====
    ShareLeagueUpstageModule = 1,       --积分联赛 段位升级
    ShareHeroDuelModel = 1,             --英雄交锋当前段位
    ShareTreasureModule = 1,            --宝物激活/宝物界面
    ShareTeamModule = 1,                --1抽卡获得兵团/2兵团界面
    ShareHeroModule = 1,                --1抽卡英雄解锁/2英雄界面
    ShareCloudModule = 0,               --云中城排行榜=====
    ShareMainModule = 1,                --玩家头像======
    ShareTeamRaceModule = 1,            --巢穴
    ShareTrainingModule = 1,            --训练场
    ShareHeroSkinModule = 1,            --英雄皮肤
}

local showType1 = {  --直接弹出分享界面
    ShareSignModuel = 1,                --签到

}

function GlobalShareBtnNode:ctor(param)
    GlobalShareBtnNode.super.ctor(self)

    self._viewMgr = ViewManager:getInstance()
    self._userModel = ModelManager:getInstance():getModel("UserModel")
    self._type = param.mType
    self._curType = param.curType
    self:onInit()
end

function GlobalShareBtnNode:onInit()
    self._shareTimes = 0
    -- dump(self._data, "GlobalShareBtnNode", 10)
    self._shareId, self._isPop = 1, true
    if self._type == "ShareArenaModule" or self._type == "ShareCloudModule" then  --竞技场/云中城
        self._isPop = false 
    end

    -- 分享关闭1
    -- if true then return end

    -- 分享关闭2
    local lvLimit = tab.systemOpen["Share"][1]
    local userLv = self._userModel:getData().lvl
    if userLv < lvLimit then
        return
    end

    -- 分享关闭3
    if GameStatic.appleExamine then
        return
    end

    -- 分享关闭4
    if showType[self._type] and showType[self._type] ~= 1 then
        return
    end
    
    --shareBtn
    --积分联赛段位升级
    if self._type == "ShareLeagueUpstageModule" then   
        local btnRes = "globalButtonUI13_3_2.png"
        self._shareBtn = ccui.Button:create()
        self._shareBtn:loadTextures(btnRes, btnRes, btnRes, 1)
        self._shareBtn:setTitleFontName(UIUtils.ttfName)
        self._shareBtn:setTitleColor(cc.c4b(255,243,229,255))
        self._shareBtn:getTitleRenderer():enableOutline(cc.c4b(85, 38, 10, 255), 1)
        self._shareBtn:setTitleText("分享")
        self._shareBtn:setTitleFontSize(22)
        self:addChild(self._shareBtn)

    --巢穴分享
    elseif self._type == "ShareTeamRaceModule" then     
        self._shareBtn = ccui.ImageView:create("campIcon_nests.png", 1)
        self:addChild(self._shareBtn)

        local txtBg = ccui.ImageView:create("globalImageUI11_btnTextBg.png", 1)
        txtBg:setScale(0.9)
        txtBg:setPosition(self._shareBtn:getContentSize().width*0.5, self._shareBtn:getContentSize().height*0.5 - 35)
        self._shareBtn:addChild(txtBg)

        local txt = ccui.Text:create()
        txt:setFontSize(18)
        txt:setString("阵营兵团")
        txt:setFontName(UIUtils.ttfName)
        txt:setColor(UIUtils.colorTable.ccUIBaseColor1)
        txt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        txt:setPosition(txtBg:getContentSize().width*0.5, txtBg:getContentSize().height*0.5)
        txtBg:addChild(txt)

    --积分联赛/竞技场战斗结束
    elseif self._type == "ShareLeagueWinModule" or self._type == "ShareArenaWinModule" then
        local btnRes = "result_share_n_battle.png"
        self._shareBtn = ccui.Button:create()
        self._shareBtn:loadTextures(btnRes, btnRes, btnRes, 1)
        self:addChild(self._shareBtn)

    --兵团/英雄/英雄皮肤
    elseif (self._type == "ShareTeamModule" and self._curType == 1) or 
            (self._type == "ShareHeroModule" and self._curType == 1) or 
            (self._type == "ShareHeroSkinModule" and self._curType == 1) then      
        local btnRes = "globalImageUI_shareBtn3.png"
        self._shareBtn = ccui.Button:create()
        self._shareBtn:loadTextures(btnRes, btnRes, btnRes, 1)
        self:addChild(self._shareBtn)

    else
        local btnRes = "globalImageUI_shareBtn.png"
        self._shareBtn = ccui.Button:create()
        self._shareBtn:loadTextures(btnRes, btnRes, btnRes, 1)
        self:addChild(self._shareBtn)

        local txt = cc.Label:createWithTTF("分享", UIUtils.ttfName, 14)
        txt:setColor(UIUtils.colorTable.ccUIBaseColor1)
        txt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        txt:setPosition(self._shareBtn:getContentSize().width*0.5, 3)
        self._shareBtn:addChild(txt)
    end

    --popBg
    if self._isPop == true then
        local isCanGet, rwdInfo = self._userModel:getShareStatus(self._shareId)
        if isCanGet == true then
            self:createPopBg(rwdInfo)
        end
    end
end

function GlobalShareBtnNode:createPopBg(rwdInfo)
    -- dump(rwdInfo, "rwdInfo", 10)
    local posX, posY = 0, self._shareBtn:getContentSize().height + 32

    --popNode
    self._popNode = ccui.Layout:create()
    self._shareBtn:addChild(self._popNode)

    --popBg
    self._popBg = ccui.ImageView:create("globalImageUI_shout_qipaobg.png", 1)
    self._popBg:setScale9Enabled(true)
    self._popBg:setCapInsets(cc.rect(70, 31, 1, 1))
    self._popBg:ignoreContentAdaptWithSize(false)
    self._popBg:setAnchorPoint(cc.p(0, 0.5))
    self._popBg:setName("popBg")
    self._popBg:setPosition(0, 0)
    self._popNode:addChild(self._popBg)

    --des
    self._des1 = ccui.Text:create()
    self._des1:setString("本次分享得")
    self._des1:setFontSize(22)
    self._des1:setFontName(UIUtils.ttfName)
    self._des1:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    self._des1:setAnchorPoint(cc.p(0, 0.5))
    self._popNode:addChild(self._des1) 

    --rewardIcon
    local posX2 = self._des1:getPositionX() + self._des1:getContentSize().width + 3
    self._rwdIcon = ccui.ImageView:create()
    self._rwdIcon:setScale(0.6)
    self._rwdIcon:setAnchorPoint(cc.p(0, 0.5))
    self._rwdIcon:loadTexture(IconUtils.resImgMap[rwdInfo[1][1]], 1)
    self._popNode:addChild(self._rwdIcon)

    --rewardNum
    local posX3 = self._rwdIcon:getPositionX() + self._rwdIcon:getContentSize().width * self._rwdIcon:getScale() + 3
    self._rwdNum = ccui.Text:create()
    self._rwdNum:setFontSize(22)
    self._rwdNum:setFontName(UIUtils.ttfName)
    self._rwdNum:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    self._rwdNum:setAnchorPoint(cc.p(0, 0.5))
    self._rwdNum:setString(rwdInfo[1][3])
    self._popNode:addChild(self._rwdNum) 


    local posX, posY = 0, self._shareBtn:getContentSize().height + 25
    local posX2, posX3
    --积分联赛段位升级
    if self._type == "ShareLeagueUpstageModule" then  
        posX, posY = posX, posY - 105
        self._popBg:setScaleY(-1)
        self._des1:setPosition(15, -4)
        self._rwdIcon:setPositionY(-4)
        self._rwdNum:setPositionY(-4)
        self._popNode:setScale(0.9)

    --巢穴分享
    elseif self._type == "ShareTeamRaceModule" then   
        posX, posY = posX + 65, posY
        self._popBg:setScaleX(-1)
        self._des1:setPosition(-185, 4)
        self._rwdIcon:setPositionY(4)
        self._rwdNum:setPositionY(4)
        self._popNode:setScale(0.8)

    --积分联赛/竞技场战斗结束
    elseif self._type == "ShareLeagueWinModule" or self._type == "ShareArenaWinModule" then  
        posX, posY = posX + 10, posY
        self._des1:setPosition(15, 4)
        self._rwdIcon:setPositionY(4)
        self._rwdNum:setPositionY(4)

    elseif (self._type == "ShareTeamModule" and self._curType == 1) or 
            (self._type == "ShareHeroModule" and self._curType == 1) or 
            self._type == "ShareHeroSkinModule" then 
        posX, posY = posX - 4, posY + 5
        self._des1:setPosition(15, 4)
        self._rwdIcon:setPositionY(4)
        self._rwdNum:setPositionY(4)

    else
        posX, posY = posX - 10, posY
        self._des1:setPosition(15, 4)
        self._rwdIcon:setPositionY(4)
        self._rwdNum:setPositionY(4)
        self._popNode:setScale(0.8)
    end
    local posX2 = self._des1:getPositionX() + self._des1:getContentSize().width + 3
    self._rwdIcon:setPositionX(posX2)
    local posX3 = self._rwdIcon:getPositionX() + self._rwdIcon:getContentSize().width * self._rwdIcon:getScale() + 3
    self._rwdNum:setPositionX(posX3)
    self._popBg:setContentSize(177 + self._rwdNum:getContentSize().width, 63)
    self._popNode:setPosition(posX, posY)


    local time = 0
    self._popNode:runAction(cc.RepeatForever:create(
        cc.Sequence:create(
            cc.MoveTo:create(0.5, cc.p(posX, posY + 3)),
            cc.MoveTo:create(0.5, cc.p(posX, posY - 3)),
            cc.CallFunc:create(function()
                time = time + 1
                if time >= 6 then
                    self._popNode:stopAllActions()
                    self._popNode:removeFromParent(true)
                    self._popNode = nil
                end
                end)
            )))
end

-- 外调，用于解决部分功能界面创建按钮时并没有分享数据
function GlobalShareBtnNode:registerClick(inCallback)
    if self._shareBtn == nil then
        return
    end

    registerClickEvent(self._shareBtn, function ()
        local shareData
        if inCallback ~= nil and type(inCallback) == "function" then
            shareData = inCallback()
        else
            self._viewMgr:showTip("分享失败")
            return
        end

        if not(sdkMgr:isWX() or sdkMgr:isQQ() or OS_IS_WINDOWS) then
            self._viewMgr:showTip(lang("SHARE_BAN"))
            return
        end

        if shareData["callback"] == nil then
            shareData["callback"] = function()
                self._shareTimes = self._shareTimes + 1
                local popBg1 = self._shareBtn:getChildByName("popBg")
                if popBg1 ~= nil then
                    popBg1:removeFromParent(true)
                    popBg1 = nil
                end
            end
        end
        
        if shareData["canGetReward"] == nil then
            if self._shareTimes > 0 then
                shareData["canGetReward"] = 0
            else
                shareData["canGetReward"] = 1
            end
        end

        if shareData["shareBtn"] == nil then
            shareData["shareBtn"] = self._shareBtn
        end
        
        -- dump(shareData,"shareData22", 10)
        self._viewMgr:showDialog("share.ShareBaseView", shareData)
    end)
end

return GlobalShareBtnNode

