--[[
    Filename:    ShareBaseView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2017-01-18 19:32:08
    Description: File description
--]]

local ShareBaseView = class("ShareBaseView", BasePopView)

--[[  =====getShareId====
ShareHeroModule  1
ShareTeamModule  2
ShareTreasureModule 3
ShareLeagueUpstageModule  4
ShareLeagueWinModule  5
ShareArenaModule  6
ShareCloudModule 7/8
ShareMainModule  9
ShareHeroDuelModel  10
ShareArenaWinModule 11
ShareTeamRaceModule 12
ShareTrainingModule 13
ShareHeroSkinModule 14
ShareSignModule 15
ShareElementAcModule 16
]]

function ShareBaseView:ctor()
    ShareBaseView.super.ctor(self)
end

function ShareBaseView:onDestroy()
    ShareBaseView.super.onDestroy(self)
end

function ShareBaseView:onInit()
    self._shareAwardStatus = 0
end

function ShareBaseView:reflashUI(data)
    self._callback = data.callback  
    self._callback1 = data.callback1  --by wangyan
    self._isEndClose = data.isEndClose or true
    if data.moduleName == nil then
        self._viewMgr:showTip("加载模块出错")
        return
    end 

    self._imgPath = nil

    self._callPlatform = 0

    self._canGetReward = data.canGetReward or 0
    registerClickEvent(self._widget, function()
        self:shareCloseCallBack()
    end)
    
    require("game.view.share." .. data.moduleName)
    if OS_IS_64 then
        package.loaded["game.view.share." .. data.moduleName .. "64"] = nil
    else
        package.loaded["game.view.share." .. data.moduleName] = nil
    end


    if not sdkMgr:isOpenSharePlatform() then 
        -- self._viewMgr:showTip("平台未开放分享")
        -- return
    end

    --分享按钮创建
    self:initShareBtn(data)

    -- 像model 传递数据
    self:transferData(data)

    if data.moduleType ~= nil and self["updateView" .. data.moduleType] ~= nil then 
        self["updateView" .. data.moduleType](self)
    else
        self["updateView"](self, data)
    end

    self:updateModuleView(data)
end

function ShareBaseView:initShareBtn(data)
    local btnWXFriend = self:getUI("bgPanel.btnWXFriend")
    local btnQQFriend = self:getUI("bgPanel.btnQQFriend")
    local btnGroup = self:getUI("bgPanel.btnGroup")
    local btnQQZone = self:getUI("bgPanel.btnQQZone")

    btnWXFriend:setPositionY(btnWXFriend:getPositionY() - 16)
    btnQQFriend:setPositionY(btnQQFriend:getPositionY() - 16)
    btnGroup:setPositionY(btnGroup:getPositionY() - 16)
    btnQQZone:setPositionY(btnQQZone:getPositionY() - 16)

    local title1 = btnWXFriend:getChildByFullName("title")
    title1:setFontSize(22)
    title1:enableOutline(cc.c4b(136, 20, 10, 255), 2)
    title1:setPositionY(25)

    local title2 = btnGroup:getChildByFullName("title")
    title2:setFontSize(22)
    title2:enableOutline(cc.c4b(136, 20, 10, 255), 2)
    title2:setPositionY(25)

    local title3 = btnQQZone:getChildByFullName("title")
    title3:setFontSize(22)
    title3:enableOutline(cc.c4b(136, 20, 10, 255), 2)
    title3:setPositionY(25)

    local title4 = btnQQFriend:getChildByFullName("title")
    title4:setFontSize(22)
    title4:enableOutline(cc.c4b(136, 20, 10, 255), 2)
    title4:setPositionY(25)

    btnWXFriend:setVisible(false)
    btnGroup:setVisible(false)
    btnQQFriend:setVisible(false)
    btnQQZone:setVisible(false)

    if sdkMgr:isWX() then
        btnWXFriend:setVisible(true)
        local isGroupBtnShow = (not data["shareBtn"] or data["shareBtn"].groupShare == nil)
        if isGroupBtnShow == true then
            btnGroup:setVisible(true)
        else
            btnWXFriend:setPositionX(480)
        end
        
    elseif sdkMgr:isQQ() then
        btnQQFriend:setVisible(true)
        local isZoneBtnShow = (not data["shareBtn"] or data["shareBtn"].zoneShare == nil)
        if isZoneBtnShow == true then
            btnQQZone:setVisible(true)
        else            
            btnQQFriend:setPositionX(480)
        end
        
    elseif OS_IS_WINDOWS then
        btnWXFriend:setVisible(true)
        local isGroupBtnShow = (not data["shareBtn"] or data["shareBtn"].groupShare == nil)
        if isGroupBtnShow == true then
            btnGroup:setVisible(true)
        else
            btnWXFriend:setPositionX(480)
        end
    end
end

function ShareBaseView:updateView(data)
    self._bg = ccui.Layout:create()
    self._bg:setClippingEnabled(true)
    self._bg:setContentSize(1136, 640)
    self._bg:setScale(self:getScale())
    self._bg:setAnchorPoint(0, 0)


    -- local labTitle = cc.Label:createWithTTF(lang("SHARE_DSC"), UIUtils.ttfName, 20)
    -- labTitle:setPosition(1136 * 0.5, 622)
    -- self._bg:addChild(labTitle, 100)
    -- labTitle:setColor(UIUtils.colorTable.ccUIBaseColor1)
    -- labTitle:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    local offsetX = 0 
    local offsetY = 0 
    if self:getScale() ~= 1 then 
        offsetY = 40
    end
    self._bg:setPosition(MAX_SCREEN_WIDTH * 0.5 - self._bg:getContentSize().width * self._bg:getScaleX() * 0.5, MAX_SCREEN_HEIGHT * 0.5 - self._bg:getContentSize().height * self._bg:getScaleY() * 0.5 + offsetY)
    self:addChild(self._bg, -1)

    local subBg = cc.Sprite:create(self:getShareBgName(data))
    subBg:setName("share_bg")
    subBg:setAnchorPoint(0.5, 0.5)
    subBg:setPosition(self._bg:getContentSize().width * 0.5, self._bg:getContentSize().height * 0.5)
    local xscale = 1136 / subBg:getContentSize().width
    local yscale = 640 / subBg:getContentSize().height
    if xscale > yscale then
        subBg:setScale(xscale)
    else
        subBg:setScale(yscale)
    end
    self._bg:addChild(subBg)

    local btnWXFriend = self:getUI("bgPanel.btnWXFriend")
    local btnQQFriend = self:getUI("bgPanel.btnQQFriend")
    local btnGroup = self:getUI("bgPanel.btnGroup")
    local btnQQZone = self:getUI("bgPanel.btnQQZone")
    btnWXFriend:setScaleAnim(true)
    btnQQFriend:setScaleAnim(true)
    btnGroup:setScaleAnim(true)
    btnQQZone:setScaleAnim(true)

    local callPlatformFunction = function(inScene)
        -- 使用变量的而不用锁屏防止意外发生导致玩家无法进行游戏
        if self._callPlatform >= os.time() then 
            -- self._viewMgr:showTip("分享进行中.......")
            return
        end
        self._callPlatform = os.time() + 5
        local param = {}
        param.scene = inScene
        param.path = self._imgPath
        param.media_tag = sdkMgr.SHARE_TAG.MSG_FRIEND_EXCEED
        if self._messageAction ~= nil then 
            param.action = self._messageAction  
        end
        sdkMgr:sendToPlatformWithPhoto(param, function(code, data)
            if code == sdkMgr.SDK_STATE.SDK_SHARE_SUCCESS then
                if not OS_IS_WINDOWS and self.getShareAward then 
                    self:getShareAward(inScene) 
                end

                if self.callBackShareFinish then
                    self:callBackShareFinish(1, inScene)
                end
            else
                if self.callBackShareFinish then
                    self:callBackShareFinish(0, inScene)
                end
            end
            sdkMgr:unregisterCallbackByEventType("TYPE_SHARE")
        end)
    end

    -- local infoNode = self:createInfoNode()
    -- self._bg:addChild(infoNode, 100000)
    -- local heardNode = self:createHeadNode()
    -- self._bg:addChild(heardNode)
    local shareFunction = function(inScene)
        local tempScale = self._bg:getScale()
        self._bg:setScale(1)
        self._viewMgr:lock(-1)
        -- local infoNode = self:createInfoNode()
        -- self._bg:addChild(infoNode)
        -- local heardNode = self:createHeadNode()
        -- self._bg:addChild(heardNode)
        self._bg:retain()
        self._bg:removeFromParent()
        UIUtils:shareToPlatfrom(1, self._bg, function(imgPath)
            -- infoNode:removeFromParent()
            -- heardNode:removeFromParent()
            self._bg:setScale(tempScale)
            self:addChild(self._bg, -1)
            self._bg:release()


            if OS_IS_WINDOWS then 
                self._viewMgr:showTip("分享图片路径：" .. imgPath)
            end
            if OS_IS_WINDOWS and self.getShareAward then 
                self:getShareAward(inScene)
            end
            if OS_IS_WINDOWS then 
                if self._callback1 ~= nil then 
                    self._callback1(inScene)
                end
            end

            self._viewMgr:unlock()
            
            self._imgPath = imgPath
            callPlatformFunction(inScene)
        end)
    end
    registerClickEvent(btnWXFriend, function()
        if self._imgPath == nil then
            shareFunction(2)
        else
            callPlatformFunction(2)
        end
    end)

    registerClickEvent(btnQQFriend, function()
        if self._imgPath == nil then
            shareFunction(2)
        else
            callPlatformFunction(2)
        end
    end)

    registerClickEvent(btnGroup, function()
        if data["shareBtn"] and data["isHideBtn"] == true then   --isHideBtn 只允许分享一次
            data["shareBtn"].groupShare = 1
        end
        if self._imgPath == nil then
            shareFunction(1)
        else
            callPlatformFunction(1)
        end        
    end)

    registerClickEvent(btnQQZone, function()
        if data["shareBtn"] and data["isHideBtn"] == true then
            data["shareBtn"].zoneShare = 1
        end
        if self._imgPath == nil then
            shareFunction(1)
        else
            callPlatformFunction(1)
        end          
    end)

    self._frontImg = cc.Scale9Sprite:createWithSpriteFrameName("shareImage_subBg.png")
    self._frontImg:setContentSize(self._bg:getContentSize().width + 6,self._bg:getContentSize().height + 6)
    self._frontImg:setAnchorPoint(0, 0)
    self._frontImg:setScale(self:getScale())
    self._frontImg:setCapInsets(cc.rect(18, 18, 1, 1))
    self._frontImg:setPosition(MAX_SCREEN_WIDTH * 0.5 - self._frontImg:getContentSize().width * self._bg:getScaleX() * 0.5, self._bg:getPositionY() - 3)
    self:addChild(self._frontImg, 100)
end

--[[
--! @function createHeadNode
--! @desc 创建通用头部层
--! @return node 通用头部层
--]]
function ShareBaseView:createHeadNode()

    local infoBg = cc.Node:create()
    infoBg:setContentSize(self._bg:getContentSize().width, 140)
    infoBg:setAnchorPoint(0, 1)
    infoBg:setPosition(0, self._bg:getContentSize().height)

    local logo = cc.Sprite:create("asset/bg/logo.png")
    logo:setPosition(130, 60)
    infoBg:addChild(logo)
    logo:setScale(0.47)

    return infoBg
end

--[[
--! @function createInfoNode
--! @desc 创建用户信息层
--! @return node 用户信息层
--]]
function ShareBaseView:createInfoNode()
    local x, y = self:getInfoPosition()
    local infoNode = cc.Node:create()
    if x == nil then 
        return infoNode
    end
    local userInfo = self._modelMgr:getModel("UserModel"):getData()
    if next(userInfo) == nil then
        return infoNode
    end
    infoNode:setContentSize(290, 130)
    infoNode:setPosition(x, y)

    local infoBg = cc.Sprite:createWithSpriteFrameName("shareImage_infoBg.png")
    infoBg:setAnchorPoint(0, 0)
    infoBg:setPosition(0, 0)
    infoNode:addChild(infoBg)


    -- local userAvatar = IconUtils:createHeadIconById({avatar = userInfo.avatar,level = userInfo.lvl or 0,tp = 4, isSelf = true})   --,tp = 2
    -- userAvatar:setAnchorPoint(0, 0.5)
    -- userAvatar:getChildByFullName("iconColor"):getChildByFullName("levelTxt"):setVisible(false)
    -- userAvatar:setPosition(10, infoNode:getContentSize().height * 0.5)
    -- infoNode:addChild(userAvatar)

    local labName = cc.Label:createWithTTF(userInfo.name, UIUtils.ttfName, 20)
    labName:setPosition(infoBg:getContentSize().width * 0.5, infoBg:getContentSize().height * 0.5 + 8)
    infoNode:addChild(labName)
    labName:setColor(cc.c3b(254,255,221))
    labName:enable2Color(1, cc.c4b(253,190,77,255))

    local labServerName = cc.Label:createWithTTF(GameStatic.serverName, UIUtils.ttfName, 20)
    labServerName:setPosition(infoBg:getContentSize().width * 0.5, infoBg:getContentSize().height * 0.5 - 18)
    infoNode:addChild(labServerName)
    labServerName:setColor(cc.c3b(254,255,221))
    labServerName:enable2Color(1, cc.c4b(253,190,77,255))
    labServerName:setHorizontalAlignment(10)

    -- labName:setAdditionalKerning(2)

    -- local labLvl = cc.Label:createWithTTF("等级" .. userInfo.lvl, UIUtils.ttfName, 24)
    -- labLvl:setAnchorPoint(0, 0)
    -- labLvl:setPosition(120, 41)
    -- infoNode:addChild(labLvl)


    -- local formationModel = self._modelMgr:getModel("FormationModel")
    -- local battleScore = formationModel:getCurrentFightScoreByType(formationModel.kFormationTypeCommon)
    -- local labBattleScore = cc.Label:createWithTTF("战斗力" .. battleScore, UIUtils.ttfName, 24)
    -- labBattleScore:setAnchorPoint(0, 0)
    -- labBattleScore:setPosition(120, 17)
    -- infoNode:addChild(labBattleScore)

    return infoNode
end


--[[
--! @function transferData
--! @desc 用于传递数据
--! @return 
--]]
function ShareBaseView:transferData()

end

--[[
--! @function updateModuleView
--! @desc 模块更新页面时调用
--! @return 
--]]
function ShareBaseView:updateModuleView()
end


function ShareBaseView:getShareAward(inScene)
    if self._canGetReward == 0 then return end
    if self._shareAwardStatus == 1 then return end
    local shareAwardId = self:getShareAwardId()
    if shareAwardId == 0 then return end

    local shareId = self:getShareId()
    if shareId == 0 then return end
    local userModel = self._modelMgr:getModel("UserModel")
    local status, rewards = userModel:getShareStatus(shareAwardId)
    -- if status == false then return end
    local param = {id = shareAwardId, type = shareId, shareType = inScene}
    if self:getMonitorContent() ~= nil then 
        param.content = self:getMonitorContent()
    end
    self._serverMgr:sendMsg("UserServer", "share", param, true, {}, function (result)
        self._shareAwardStatus = 1
        if result.award == nil or #result.award <= 0 then 
            return
        end
        DialogUtils.showGiftGet({
            gifts = result.award,
        })
    end)
end

--[[
--! @function callBackShareFinish
--! @desc 分享回调
--! @param inState 0失败，1成功
--! @param inEleId  固件id
--! @return 
--]]
function ShareBaseView:callBackShareFinish(inState, inScene)
    if inState == 1 and self._callback1 ~= nil then 
        self._callback1(inScene)
    end

    if self._isEndClose == true then
        self:shareCloseCallBack()
    end
end

function ShareBaseView:shareCloseCallBack()
    if self._shareAwardStatus == 1 then 
        if self._callback ~= nil then 
            self._callback()
        end
    end
    if OS_IS_64 then
        package.loaded["game.view.share.ShareBaseView64"] = nil
    else
        package.loaded["game.view.share.ShareBaseView"] = nil
    end
    ScheduleMgr:delayCall(0, nil, function()
        if self.close ~= nil then
            self:close(true)
        end
    end)
end

--[[
--! @function getShareLayer
--! @desc 获取分享页面层   
--! @return layer
--]]
function ShareBaseView:getShareLayer()
    return self._bg
end

--[[
--! @function getInfoPosition
--! @desc 获取信息层摆放位置，如果 传nil表示不显示
--! @return x, y
--]]
function ShareBaseView:getInfoPosition()
    return 846, 15
end

--[[
--! @function getShareBgName
--! @desc 获取分享背景
--! @return string 背景路径
--]]
function ShareBaseView:getShareBgName()
    return "asset/bg/share/share_treasure.jpg"
end

function ShareBaseView:getScale()
    return 0.84
end

function ShareBaseView:getShareAwardId()
    return 1
end


function ShareBaseView:getShareId()
    return 1
end

function ShareBaseView:getAsyncRes()
    return {
            --{"asset/ui/share.plist", "asset/ui/share.png"}
            }
end


function ShareBaseView:getMonitorContent()
    return nil
end

return ShareBaseView 
