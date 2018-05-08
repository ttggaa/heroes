--[[
    Filename:    BaseView.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2015-04-27 17:37:46
    Description: File description
--]]
local cc = cc
local BaseView = class("BaseView", BaseMvcs, BaseEvent, function ()
    return ccui.Layout:create()
end)
local Z_LAYER_NODE = 20000 --node
local Z_BLACK_MASK = 30000 --node
local Z_DIALOG_LAYER = 40000 --node
local Z_LOCK_MASK = 90000 --node

local sfc = cc.SpriteFrameCache:getInstance()
local tc = cc.Director:getInstance():getTextureCache()
function BaseView:ctor()
    self.__memoryCheckTable = {}
    for k ,v in pairs(_G) do
        self.__memoryCheckTable[k] = v
    end
    BaseView.super.ctor(self)

    self.__eventTarget = {}
    self.__dispatching = false
    self.__dispatchCallback = {}

    self.__maskLayer = nil
    self.__modalLayer = nil
    self.__layerNode = nil

    -- popview和layer的资源map
    self.__plistMap = {}

    -- layer
    self.__layerMap = {}

    self.__maskLayer = ccui.Layout:create()
    self.__maskLayer:setBackGroundColorOpacity(255)
    self.__maskLayer:setBackGroundColorType(1)
    self.__maskLayer:setBackGroundColor(cc.c3b(0,0,0))
    self.__maskLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self.__maskLayer:setOpacity(0)
    self.__maskLayer:retain()

    self:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)

    -- 个别功能需要开通快速通知，例如联盟地图
    self.__isOpenQuickDispatch = false

    -- 在本界面调用全局锁的次数
    self.__lockCount = 0

    -- 本界面弹出的所有popView 
    self.__popViews = {}
    
    pcall(function () self:cpatch() end)
end

function BaseView:onDestroy()
    self.__dispatchCallback = nil
    self.__eventTarget = nil
    self.__maskLayer = nil
    self.__modalLayer = nil
    self.__layerNode = nil
    self.__plistMap = nil
    self.__layerMap = nil

    self:removeGlobalResponseListener()
    self:removeRSResponseListener()
    self._modelMgr:clearSelfTimer(self)
    local count = ScheduleMgr:cleanMyselfTicker(self)
    -- if count > 0 then
    --     self._viewMgr:showTip(self:getClassName().." ScheduleMgr count: " .. count)
    -- end
    -- print("onDestroy Classname =", self:getClassName())
    for k, v in pairs(_G) do
        if self.__memoryCheckTable[k] == nil then
            print("memory leak in _G:", k, type(k), v)
        end
    end
end

function BaseView:initUI(name, Async, callback)
    local filename = nil
    for i = #name, 1, -1 do
        if string.sub(name, i, i) == "." then
            filename = string.sub(name, i + 1, #name)
            break
        end
    end
    if filename == nil then
        filename = name
    end
    self.__jsonName = "asset/ui/".. filename ..".csb"

    self:retain()
    -- 多线程载图
    if Async then
        local classname = self:getClassName()
        local resList = self:getAsyncRes()
        local bgName = self:getBgName()
        if bgName ~= nil then
            resList[#resList + 1] = "asset/bg/" .. bgName
        end
        for i = 1, #resList do
            if type(resList[i]) ~= "string" then
                self.__plistMap[resList[i][1]] = resList[i][2]
            else
                if not self.isPopView then
                    self._viewMgr:addTexture(classname, resList[i])
                end
            end
        end
        UIUtils:aysncLoadRes(resList, function ()
            local ret = self:_widgetFromJsonFile() 
            if callback then
                callback(ret)
            end
        end)
    else
        -- 同步载入plist
        local classname = self:getClassName()
        local resList = self:getAsyncRes()
        local count = #resList
        for i = 1, count do
            local task
            local res = resList[i]
            if type(res) ~= "string" then
                if string.find(res[1], "asset/ui") ~= nil then
                    cc.Texture2D:setDefaultAlphaPixelFormat(RGBAUTO)
                else
                    if res[3] then
                        cc.Texture2D:setDefaultAlphaPixelFormat(res[3])
                    else
                        cc.Texture2D:setDefaultAlphaPixelFormat(RGBAUTO)
                    end
                end
                sfc:addSpriteFrames(res[1], res[2])
                cc.Texture2D:setDefaultAlphaPixelFormat(RGBAUTO)
                self.__plistMap[res[1]] = res[2]
            else

                if not self.isPopView then
                    print("classname---", classname, res)
                    self._viewMgr:addTexture(classname, res)
                end
            end
        end
        local ret = self:_widgetFromJsonFile()
        if callback then
            callback(ret)
        end
    end
    
    self._viewMgr:addToPlistList(self.__plistMap)
end
-- 获取需要在进入界面之前,多线程载入的资源列表, 子类有需要, 覆写该方法
function BaseView:getAsyncRes()
    -- return 
    -- {
    --     "abc.png", 
    --     "aaa.jpg", 
    --     {"bb.plist", "bb.png"},
    --     {"bb.plist", "bb.pvr.ccz"}
    -- }
    return {}
end

-- 注册UI节点 {name,"bg.name"} self._name为获取的节点
function BaseView:getRegisterNames()
    return {}
end

-- 同步载入资源，加入资源管理
function BaseView:loadSyncRes(resList)
    for i = 1, #resList do
        if type(resList[i]) ~= "string" then
            self.__plistMap[resList[i][1]] = resList[i][2]
            sfc:addSpriteFrames(resList[i][1], resList[i][2])
        else
            tc:addImage(resList[i])
            if not self.isPopView then
                self._viewMgr:addTexture(self:getClassName(), resList[i])
            end
        end
    end
end

-- 获取背景图名称, 覆写该方法
function BaseView:getBgName()
    return nil, --name string xx.jpg
           nil, --color cc.c3b
           nil, --Brightness亮度 -100  100 
           nil, --Contrast对比度 -100  100
           nil, --Saturation饱和度 -100  100
           nil  --Hue色相 -180 180
end

function BaseView:_widgetFromJsonFile()
    local ret, result = trycall("__widgetFromJsonFile", self.__widgetFromJsonFile, self)
    if not ret or result == false then
        return 1
    end     
    return 0
end
-- 根据json文件创建UI
function BaseView:__widgetFromJsonFile()
    local bgName, color, brightness, contrast, saturation, hue = self:getBgName()
    if bgName then
        self.__viewBg = cc.Sprite:create("asset/bg/" .. bgName)
        if color then
            self.__viewBg:setColor(color)
        end
        if brightness then
            self.__viewBg:setBrightness(brightness)
        end
        if contrast then
            self.__viewBg:setContrast(contrast)
        end
        if saturation then
            self.__viewBg:setSaturation(saturation)
        end
        if hue then
            self.__viewBg:setHue(hue)
        end
        self:addChild(self.__viewBg, -10)
        self:adjustBg()
    end
    if cc.FileUtils:getInstance():isFileExist(self.__jsonName) then
        self._widget = ccs.GUIReader:getInstance():widgetFromBinaryFile(self.__jsonName)
        self._widget:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
        self._widget:setAnchorPoint(0.5, 0.5)
        self:L10N_Text()
        self._widgetNode = cc.Node:create()
        self._widgetNode:addChild(self._widget)
        self._widgetNode:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
        self:addChild(self._widgetNode)     
    end
    if self.getClassName and self:getClassName() then
        print("oninit " .. self:getClassName())
    end

    local keys = self:getRegisterNames()
    self:registerUI(keys)

    if not trycall("onInit", self.onInit, self) then
        return false
    end
    -- 适配iphoneX
    if self._widget then
        if ADOPT_IPHONEX and not self.isPopView and not self.dontAdoptIphoneX then
            if self.fixMaxWidth then
                self._widget:setContentSize((MAX_SCREEN_WIDTH > self.fixMaxWidth) and self.fixMaxWidth or MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
            else
                self._widget:setContentSize(MAX_SCREEN_WIDTH - 120, MAX_SCREEN_HEIGHT)
            end
        end
    end
    pcall(function () self:patch() end)
end

function BaseView:setWidgetContentSize(w, h)
    if self._widget then
        self._widget:setContentSize(w, h)
    end
end

function BaseView:beforePopAnim()
    if self.initAnimType == 1 or self.initAnimType == 2 or self.initAnimType == 3 or self.initAnimType == 4 or self.initAnimType == 5 or self.initAnimType == 6 then
        local navigation = self._viewMgr:getNavigation("global.UserInfoView")
        if navigation and navigation.visible then
            navigation:setOpacity(0)
        end
        if self._dropWithNavigation then
            self._dropWithNavigation:setCascadeOpacityEnabled(true,true)
            self._dropWithNavigation:setOpacity(0)
        end
    end
    if self.initAnimType == 3 and self._animBtns then
        for i,v in ipairs(self._animBtns) do
            if v.setOpacity then
                v:setCascadeOpacityEnabled(true)
                v:setOpacity(0)
            end
        end
    elseif self.initAnimType == 5 and self._animBtns then
        for i,v in ipairs(self._animBtns) do
            if v.setOpacity then
                v:setCascadeOpacityEnabled(true)
                v:setOpacity(0)
            end
        end
    end
end

function BaseView:popAnim(callback)
    if self.initAnimType == 1 then
        if self._widgetNode then
            self._widgetNode:setVisible(false)
            ScheduleMgr:nextFrameCall(self, function()
                self._widgetNode:setVisible(true)
                self._widgetNode:stopAllActions()
                self._widgetNode:setScale(0.7)
                self._widgetNode:runAction(cc.Sequence:create(cc.EaseOut:create(cc.ScaleTo:create(0.15, 1.05), 3), 
                    cc.ScaleTo:create(0.10, 1.0),
                    cc.CallFunc:create(function ()
                        self.__popAnimOver = true
                        if callback then callback() end
                    end)
                ))
            end)
            local navigation = self._viewMgr:getNavigation("global.UserInfoView")
            if navigation and navigation.visible then
                ScheduleMgr:nextFrameCall(self, function()
                    navigation:stopAllActions()
                    navigation:setOpacity(255)
                    local x, y = navigation:getPosition()
                    navigation:setPosition(x, y + 80)
                    navigation:runAction(cc.Sequence:create(
                        cc.DelayTime:create(0.13),
                        cc.EaseOut:create(cc.MoveTo:create(0.1, cc.p(x, y - 5)), 3),
                        cc.MoveTo:create(0.07, cc.p(x, y))
                    ))
                end)
            end
        else
            self.__popAnimOver = true
        end
    elseif self.initAnimType == 2 then
        local navigation = self._viewMgr:getNavigation("global.UserInfoView")
        if navigation and navigation.visible then
            ScheduleMgr:nextFrameCall(self, function()
                navigation:stopAllActions()
                navigation:setOpacity(255)
                local x, y = navigation:getPosition()
                navigation:setPosition(x, y + 80)
                navigation:runAction(cc.Sequence:create(
                    cc.EaseOut:create(cc.MoveTo:create(0.1, cc.p(x, y - 5)), 3),
                    cc.MoveTo:create(0.07, cc.p(x, y)),
                    cc.CallFunc:create(function ()
                        self.__popAnimOver = true
                        if callback then callback() end
                    end)
                ))
            end)
        else
            self.__popAnimOver = true
        end
        
    elseif self.initAnimType == 3 and self._playAnimBg then  -- 新版出现效果 by guojun 2017.1.13
        self._widget:setVisible(false)
        self._playAnimBg:setOpacity(0)
        local initPosX,initPosY = self._widget:getPosition()
        local playAnimBgC = ccui.ImageView:create()
        playAnimBgC:setCapInsets(cc.rect(118,80,1,1))
        playAnimBgC:loadTexture("globalPanelUI7_frame1.png",1)
        playAnimBgC:setScale9Enabled(true)
        playAnimBgC:setContentSize(cc.size(self._playAnimBg:getContentSize().width,self._playAnimBg:getContentSize().height))
        playAnimBgC:setAnchorPoint(0.5,0.5)
        playAnimBgC:setPosition(initPosX+(self._playAnimBgOffX or 0),initPosY+(self._playAnimBgOffY or 0))
        self._widgetNode:addChild(playAnimBgC,-1)
        -- if not self._notPlayAnimLogo then 
            local logoImg = ccui.ImageView:create()
            logoImg:loadTexture("globalImageUI_dardHeroesBg.png",1)
            logoImg:setScale(2)
            logoImg:setPosition(playAnimBgC:getContentSize().width/2,playAnimBgC:getContentSize().height/2)
            playAnimBgC:addChild(logoImg)

            -- local clipNode = cc.ClippingNode:create()
            -- clipNode:setPosition(171.5,127)
            -- clipNode:setContentSize(cc.size(343, 254))
            -- local mask = cc.Sprite:createWithSpriteFrameName("globalImageUI_dardHeroesBg.png")
            -- mask:setScale(1.0)
            -- mask:setAnchorPoint(0.5,0.5)
            -- clipNode:setStencil(mask)
            -- clipNode:setAlphaThreshold(0.5)
            -- -- clipNode:setOpacity(128)
            -- -- clipNode:setBrightness(-50)
            -- -- clipNode:setInverted(true)
            -- playAnimBgC:setVisible(false)

            -- local mc = mcMgr:createViewMC("yingxiongwudisaoguang_itemeffectcollection", true)
            -- mc:setPosition(0,-45)
            -- clipNode:setScale(1)
            -- clipNode:addChild(mc)

            -- logoImg:addChild(clipNode)
        -- end
        ScheduleMgr:nextFrameCall(self, function()
            self._widget:setPositionY(initPosY-500)
            self._widgetNode:setVisible(true)
            playAnimBgC:setScale(0.7)
            playAnimBgC:setVisible(true)
            playAnimBgC:runAction(cc.Sequence:create(
                -- cc.EaseOut:create(cc.ScaleTo:create(0.10, 1.05), 3),
                cc.Spawn:create(
                    cc.ScaleTo:create(0.10, 1.0),
                    cc.CallFunc:create(function( )
                        self._widget:setVisible(true)
                        self._widget:setOpacity(180)
                        self._widget:runAction(cc.Sequence:create(
                            cc.Spawn:create(
                                cc.EaseOut:create(cc.MoveTo:create(0.10, cc.p(initPosX,initPosY)), 3),
                                cc.FadeIn:create(0.10),
                                cc.CallFunc:create(function( )
                                    if self._animBtns then
                                        UIUtils:setTabAppearAnim(self._animBtns,-2,nil,self._animFinishFun)
                                    end
                                end) 
                            ),
                            -- cc.EaseOut:create(cc.MoveTo:create(0.1, cc.p(initPosX,initPosY)), 7), 
                            -- cc.EaseOut:create(cc.ScaleTo:create(0.15, 1.05), 3), 
                            -- cc.ScaleTo:create(0.10, 1.0),
                            cc.CallFunc:create(function ()
                                self._playAnimBg:setVisible(true)
                                -- playAnimBgC:setColor(cc.c3b(0, 0, 0)) -- for test
                                self._playAnimBg:runAction(cc.Sequence:create(
                                    cc.FadeIn:create(0.1),
                                    cc.CallFunc:create(function( )
                                        playAnimBgC:removeFromParent()
                                    end)
                                ))
                                logoImg:removeFromParent()
                                self.__popAnimOver = true
                                if callback then callback() end
                            end)
                        ))
                    end)
                ) 
            ))
            self._widgetNode:stopAllActions()
            local navigation = self._viewMgr:getNavigation("global.UserInfoView")
            if navigation and navigation.visible then
                ScheduleMgr:nextFrameCall(self, function()
                    navigation:stopAllActions()
                    navigation:setOpacity(255)
                    local x, y = navigation:getPosition()
                    navigation:setPosition(x, y + 80)
                    navigation:runAction(cc.Sequence:create(
                        cc.DelayTime:create(0.13),
                        cc.EaseOut:create(cc.MoveTo:create(0.1, cc.p(x, y - 5)), 3),
                        cc.MoveTo:create(0.07, cc.p(x, y))
                    ))
                end)
            end
        end)
    elseif self.initAnimType == 4 and self._playAnimBg then  
        local playAnimBgC = self._playAnimBg
        local initPosX,initPosY = playAnimBgC:getPosition()
        self._widget:setVisible(false)
        if self._dropWithNavigationOffY and self._dropWithNavigation then
            self._dropWithNavigation:setPositionY(self._dropWithNavigation:getPositionY()+self._dropWithNavigationOffY)
            self._dropWithNavigation:setVisible(false)
        end
        playAnimBgC:setVisible(false)

        local navigation = self._viewMgr:getNavigation("global.UserInfoView")
        if navigation and navigation.visible then
            navigation:setOpacity(0)
        end
        ScheduleMgr:nextFrameCall(self, function()
            self._widgetNode:setVisible(true)
            playAnimBgC:setVisible(true)
            ScheduleMgr:delayCall(100,self,function()
                    if self._dropWithNavigation then
                    self._dropWithNavigation:setCascadeOpacityEnabled(true,true)
                    -- self._dropWithNavigation:setOpacity(180)
                    self._dropWithNavigation:stopAllActions()
                    self._dropWithNavigation:setVisible(true)
                    local y = self._dropWithNavigation:getPositionY()-self._dropWithNavigationOffY
                    local x = self._dropWithNavigation:getPositionX()
                    self._dropWithNavigation:runAction(cc.Sequence:create(
                        cc.Spawn:create(
                            cc.FadeIn:create(0.2),
                            cc.Sequence:create(
                                cc.EaseOut:create(cc.MoveTo:create(0.1, cc.p(x, y - 20)), 3),
                                cc.MoveTo:create(0.1, cc.p(x, y))
                            )
                        )
                    ))
                end

                --cell 至透明
                local beginIndex = 1
                if self._aniItemList and #self._aniItemList > 0 then
                   for index,item in pairs (self._aniItemList) do 
                       item:setCascadeOpacityEnabled(true,true)
                       item:setOpacity(0)
                       item:setPositionX(item:getPositionX()-self._animCellOff)
                   end
                end

                self._widget:setVisible(true)

                local function ShowOneByOne(index)
                    self._aniItemList = self._aniItemList or {}
                    local item = self._aniItemList[index]
                    if item then
                        item:stopAllActions()
                        item:runAction(cc.Sequence:create(
                            cc.Spawn:create(
                                cc.Spawn:create(
                                    cc.Sequence:create(
                                        cc.EaseOut:create(cc.MoveBy:create(0.1, cc.p(self._animCellOff-15,0)), 3),
                                        cc.MoveBy:create(0.1, cc.p(15,0))
                                    ),
                                    cc.FadeIn:create(0.2)
                                ),
                                cc.Sequence:create(
                                    cc.DelayTime:create(0.1),
                                    cc.CallFunc:create(function()
                                        ShowOneByOne(index+1)
                                    end)
                                )
                            ),
                            cc.CallFunc:create(function()
                                if index >= #self._aniItemList then
                                    self.__popAnimOver = true
                                    if callback then callback() end
                                end
                            end)
                        ))
                    elseif #self._aniItemList <= 0 then
                        self.__popAnimOver = true
                        if callback then callback() end
                    end
                end

                ShowOneByOne(beginIndex)

                self._widgetNode:stopAllActions()
                local navigation = self._viewMgr:getNavigation("global.UserInfoView")
                if navigation and navigation.visible then
                    ScheduleMgr:nextFrameCall(self, function()
                        navigation:stopAllActions()
                        navigation:setOpacity(255)
                        local x, y = navigation:getPosition()
                        navigation:setPosition(x, y + 80)
                        navigation:runAction(cc.Sequence:create(
                            cc.DelayTime:create(0.13),
                            cc.EaseOut:create(cc.MoveTo:create(0.1, cc.p(x, y - 5)), 3),
                            cc.MoveTo:create(0.07, cc.p(x, y))
                        ))
                    end)
                end
            end)
        end)
    elseif self.initAnimType == 5 and self._playAnimBg then
        self._widget:setVisible(false)
        self._playAnimBg:setOpacity(0)
        local initPosX,initPosY = self._widget:getPosition()
        local playAnimBgC = ccui.ImageView:create()
        playAnimBgC:loadTexture("globalPanelUI7_frame1.png",1)
        self._widgetNode:addChild(playAnimBgC,-1)
        playAnimBgC:setVisible(false)
        ScheduleMgr:nextFrameCall(self, function()
            self._widget:setPositionY(initPosY-500)
            self._widgetNode:setVisible(true)
            playAnimBgC:runAction(cc.Sequence:create(
                cc.EaseOut:create(cc.ScaleTo:create(0.2, 1.05), 3),
                cc.Spawn:create(
                    cc.ScaleTo:create(0.10, 1.0),
                    cc.CallFunc:create(function( )
                        self._widget:setVisible(true)
                        self._widget:setOpacity(180)
                        self._widget:runAction(cc.Sequence:create(
                            cc.Spawn:create(
                                cc.EaseOut:create(cc.MoveTo:create(0.10, cc.p(initPosX,initPosY+10)), 3),
                                cc.FadeIn:create(0.10),
                                cc.CallFunc:create(function( )
                                    if self._animBtns then
                                        UIUtils:setTabAppearAnim(self._animBtns,-2,-50)
                                    end
                                end) 
                            ),
                            cc.EaseOut:create(cc.MoveTo:create(0.1, cc.p(initPosX,initPosY)), 7), 
                            cc.CallFunc:create(function ()
                                self._playAnimBg:runAction(cc.Sequence:create(
                                    cc.FadeIn:create(1),
                                    cc.CallFunc:create(function( )
                                        playAnimBgC:removeFromParent()
                                    end)
                                ))
                                self.__popAnimOver = true
                                if callback then callback() end
                            end)
                        ))
                    end)
                ) 
            ))
            self._widgetNode:stopAllActions()
            local navigation = self._viewMgr:getNavigation("global.UserInfoView")
            if navigation and navigation.visible then
                ScheduleMgr:nextFrameCall(self, function()
                    navigation:stopAllActions()
                    navigation:setOpacity(255)
                    local x, y = navigation:getPosition()
                    navigation:setPosition(x, y + 80)
                    navigation:runAction(cc.Sequence:create(
                        cc.DelayTime:create(0.13),
                        cc.EaseOut:create(cc.MoveTo:create(0.1, cc.p(x, y - 5)), 3),
                        cc.MoveTo:create(0.07, cc.p(x, y))
                    ))
                end)
            end
        end)
    elseif self.initAnimType == 6 and self._playAnimBg then 
        self._widget:setVisible(false)
        self._playAnimBg:setOpacity(0)
        local navigation = self._viewMgr:getNavigation("global.UserInfoView")
        if navigation then
            navigation:setVisible(false)
        end
        local initPosX,initPosY = self._widget:getPosition()
        self._widget:setPositionY(initPosY-500)
        local playAnimBgC = ccui.ImageView:create()
        playAnimBgC:setCapInsets(cc.rect(204,30,1,1))
        playAnimBgC:loadTexture("globalPanelUI7_frame1.png",1)
        playAnimBgC:setScale9Enabled(true)
        playAnimBgC:setContentSize(cc.size(self._playAnimBg:getContentSize().width,self._playAnimBg:getContentSize().height))
        playAnimBgC:setAnchorPoint(0.5,0.5)
        playAnimBgC:setPosition(initPosX+(self._playAnimBgOffX or 0),initPosY+(self._playAnimBgOffY or 0))
        self._widgetNode:addChild(playAnimBgC,-1)
        local logoImg = ccui.ImageView:create()
        logoImg:loadTexture("globalImageUI_dardHeroesBg.png",1)
        logoImg:setScale(2)
        logoImg:setPosition(playAnimBgC:getContentSize().width/2,playAnimBgC:getContentSize().height/2)
        playAnimBgC:addChild(logoImg)
        playAnimBgC:setVisible(false)
        local delay = self._delayAnima or 0

        ScheduleMgr:delayCall(delay,self,function()
            ScheduleMgr:nextFrameCall(self, function()
                self._widgetNode:setVisible(true)
                -- playAnimBgC:setScale(0.7)
                playAnimBgC:setVisible(true)

                playAnimBgC:runAction(cc.Sequence:create(
                    cc.EaseOut:create(cc.ScaleTo:create(0.01, 1), 3),
                    cc.Spawn:create(
                        cc.ScaleTo:create(0.10, 1.0),
                        cc.CallFunc:create(function( )
                            self._widget:setVisible(true)
                            self._widget:setOpacity(180)
                            self._widget:runAction(cc.Sequence:create(
                                cc.Spawn:create(
                                    cc.EaseOut:create(cc.MoveTo:create(0.10, cc.p(initPosX,initPosY)), 3),
                                    cc.FadeIn:create(0.10),
                                    cc.CallFunc:create(function( )
                                        if self._animBtns then
                                            UIUtils:setTabAppearAnim(self._animBtns,-2)
                                        end
                                    end) 
                                ),
                                cc.CallFunc:create(function ()
                                    self._playAnimBg:setVisible(true)
                                    self._playAnimBg:runAction(cc.Sequence:create(
                                        cc.FadeIn:create(0.01),
                                        cc.CallFunc:create(function( )
                                            playAnimBgC:removeFromParent()
                                        end)
                                    ))
                                    logoImg:removeFromParent()
                                    self.__popAnimOver = true
                                    if callback then callback() end
                                end)
                            ))
                        end)
                    ) 
                ))
                self._widgetNode:stopAllActions()
                if navigation and navigation.visible then
                    ScheduleMgr:nextFrameCall(self, function()
                        navigation:stopAllActions()
                        navigation:setOpacity(255)
                        local x, y = navigation:getPosition()
                        navigation:setPosition(x, y + 80)
                        navigation:setVisible(true)
                        navigation:runAction(cc.Sequence:create(
                            cc.DelayTime:create(0.13),
                            cc.EaseOut:create(cc.MoveTo:create(0.1, cc.p(x, y - 5)), 3),
                            cc.MoveTo:create(0.07, cc.p(x, y))
                        ))
                    end)
                end
            end)
        end)
    elseif self.initAnimType == 7 then
        if self._animationBg then
            self._animationBg:setVisible(false)
            self._titleBg:setVisible(false)
            self._titleBg:setScale(3)
            ScheduleMgr:nextFrameCall(self, function()
                self._titleBg:setVisible(true)
                self._titleBg:stopAllActions()
                self._titleBg:runAction(cc.Sequence:create(cc.EaseOut:create(cc.ScaleTo:create(0.15, 1.05), 3),
                    cc.CallFunc:create(function()
                        self.__popAnimOver = true
                        if callback then callback() end
                    end),
                    cc.ScaleTo:create(0.10, 1.0),
                    cc.CallFunc:create(function ()
                        self._animationBg:setVisible(true)
                        self._animationBg:stopAllActions()
                        self._animationBg:setScale(0.7)
                        self._animationBg:runAction(cc.Sequence:create(cc.EaseOut:create(cc.ScaleTo:create(0.15, 1.05), 3), 
                            cc.ScaleTo:create(0.10, 1.0),
                            cc.CallFunc:create(function ()
                                
                            end)
                        ))
                    end)
                ))
            end)
            local navigation = self._viewMgr:getNavigation("global.UserInfoView")
            if navigation and navigation.visible then
                ScheduleMgr:nextFrameCall(self, function()
                    navigation:stopAllActions()
                    navigation:setOpacity(255)
                    local x, y = navigation:getPosition()
                    navigation:setPosition(x, y + 80)
                    navigation:runAction(cc.Sequence:create(
                        cc.DelayTime:create(0.13),
                        cc.EaseOut:create(cc.MoveTo:create(0.1, cc.p(x, y - 5)), 3),
                        cc.MoveTo:create(0.07, cc.p(x, y))
                    ))
                end)
            end
        else
            self.__popAnimOver = true
            if callback then callback() end
        end
    else
        local navigation = self._viewMgr:getNavigation("global.UserInfoView")
        ScheduleMgr:nextFrameCall(self, function()
            if navigation and navigation.visible then
                navigation:setOpacity(255)
            end
            self.__popAnimOver = true
            if callback then callback() end
        end)
    end
end

--  通用动态背景
function BaseView:addAnimBg()
    -- local beijing = mcMgr:createViewMC("beijing_itemeffectcollection", true, false)
    -- beijing:setAnchorPoint(cc.p(0.5,0.5))
    -- beijing:setPosition(cc.p(MAX_SCREEN_WIDTH*0.5,MAX_SCREEN_HEIGHT*0.5-50))
    -- beijing:setZOrder(-1)
    -- self:addChild(beijing)
    
    -- local imgBG = ccui.ImageView:create()
    -- imgBG:loadTexture("globalImageUI8_naviButtom.png",1)
    -- imgBG:setContentSize(1160,35)
    -- imgBG:setScale9Enabled(true)
    -- imgBG:setCapInsets(cc.rect(35,1,2,33))
    -- imgBG:setAnchorPoint(cc.p(0.5,0))
    -- imgBG:setPosition(MAX_SCREEN_WIDTH*0.5, -10)
    -- self:addChild(imgBG,-1)
end

function BaseView:adjustBg()
    if self.__viewBg == nil then return end
    local xscale = MAX_SCREEN_WIDTH / self.__viewBg:getContentSize().width
    local yscale = MAX_SCREEN_HEIGHT / self.__viewBg:getContentSize().height
    if xscale > yscale then
        self.__viewBg:setScale(xscale)
    else
        self.__viewBg:setScale(yscale)
    end
    self.__viewBg:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
end

function BaseView:close(noAnim)
    do
        self._viewMgr:popView()
        return
    end
    if noAnim then
        self._viewMgr:popView()
    else
        if self.initAnimType == 1 then
            if self._widgetNode then
                self._widgetNode:stopAllActions()
                self._widgetNode:setScale(1.0)
                self:lock(-1)
                self._widgetNode:runAction(cc.Sequence:create(
                    cc.ScaleTo:create(0.1, 1.1),
                    cc.ScaleTo:create(0.1, 0.5),
                    cc.CallFunc:create(function ()
                        self._widgetNode:setVisible(false)
                        ScheduleMgr:nextFrameCall(self, function()
                            self:unlock()
                            self._viewMgr:popView()
                        end)
                    end)))
            end
            local navigation = self._viewMgr:getNavigation("global.UserInfoView")
            if navigation and navigation.visible then
                ScheduleMgr:nextFrameCall(self, function()
                    navigation:stopAllActions()
                    navigation:setOpacity(255)
                    local x, y = navigation:getPosition()
                    navigation:runAction(cc.Sequence:create(
                        cc.Spawn:create(cc.MoveTo:create(0.1, cc.p(x, y + 40)), cc.FadeOut:create(0.1)),
                        cc.CallFunc:create(function ()
                            navigation:setPosition(x, y)
                        end)
                    ))
                end)
            end
        elseif self.initAnimType == 2 then
            local navigation = self._viewMgr:getNavigation("global.UserInfoView")
            if navigation and navigation.visible then
                self:lock(-1)
                ScheduleMgr:nextFrameCall(self, function()
                    navigation:stopAllActions()
                    navigation:setOpacity(255)
                    local x, y = navigation:getPosition()
                    navigation:runAction(cc.Sequence:create(
                        cc.Spawn:create(cc.MoveTo:create(0.1, cc.p(x, y + 40)), cc.FadeOut:create(0.1)),
                        cc.DelayTime:create(0.01),
                        cc.CallFunc:create(function ()
                            self:unlock()
                            navigation:setPosition(x, y)
                            self._viewMgr:popView()
                        end)
                    ))
                end)
            end
        else
            self._viewMgr:popView()
        end
    end
end

function BaseView:addModalLayer()
    local parent = self:getParent()

    self.__layerNode = ccui.Layout:create()
    self.__layerNode:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self.__layerNode:setLocalZOrder(Z_LAYER_NODE)
    parent:addChild(self.__layerNode)

    -- 弹出框基于每一个View
    self.__modalLayer = cc.Node:create()
    self.__modalLayer:setLocalZOrder(Z_DIALOG_LAYER)
    parent:addChild(self.__modalLayer)

    -- 模态层队列头指针
    self._modalQueueBegin = nil
end

-- 获取layer节点 在widget至上  dialog之下
function BaseView:getLayerNode()
    return self.__layerNode
end

-- 禁止直接调用
-- forceShow 参数废弃
function BaseView:showDialog(name, data, forceShow, Async, callback, noPop)
    if self.__modalLayer == nil then
        return nil
    end
    -- 弹窗前关闭tip 解决点击出tip和出弹窗的冲突问题 by guojun 2017.5.16
    self:closeHintView()
    local view = require("game.view."..name).new(data)
    if view.isPopView == nil then
        self._viewMgr:showTip(name .. " is not a BasePopView")
        view:destroy()
        return
    end
    view.visible = true
    view.parentView = self
    -- view:setBgBlur()

    if noPop then
        self:lock(-1)
    else
        self:lock(-1)
    end

    view:setClassName(name)
    self.__popViews[view] = view
    view:initUI(name, Async, function (ret)
        trycall("reflashUI", view.reflashUI, view, data)

        view.forceShow = true
        
        self:addToModalLayer(view)
        view:onShow()
        if not noPop then
            view:doPop(function ()
                self:unlock(41)
                if callback then
                    callback()
                end
            end)
        else
            self:unlock(42)
            if callback then
                callback()
            end
        end
        if ret ~= 0 then
            self:onShowDialogError(view)
        end
        return view
    end)

    return view
end

-- showDialog 出错了
function BaseView:onShowDialogError(view)
    print("onShowDialogError")
    view:close()
    self._viewMgr:showTip("界面好像出错了")
end

function BaseView:showGlobalDialog(...)
    self._viewMgr:showGlobalDialog(...)
end

-- 显示物品hint
function BaseView:showHintView(name, data, callback)
    local hint = self._viewMgr:showHintView(name, data, callback)
    return hint
end

function BaseView:closeHintView()
    self._viewMgr:closeHintView()
end

function BaseView:addToModalLayer(popView)
    self.__modalLayer:addChild(popView)
    self:_setMaskLayer(popView)
end

function BaseView:removeFromModalLayer(popView)
    self.__modalLayer:removeChild(popView)
    local count = #self.__modalLayer:getChildren()
    if count > 0 then
        self:_setMaskLayer(self.__modalLayer:getChildren()[count])
    else
        self:onModalClose()
    end
end

function BaseView:onModalClose()
    if self.__maskLayer:getParent() then
        self.__maskLayer:removeFromParent()
    end
    self:getParent():addChild(self.__maskLayer, Z_BLACK_MASK)
    self.__maskLayer:stopAllActions()
    self.__maskLayer:runAction(cc.FadeOut:create(0.2))
end

function BaseView:setMaskLayerOpacity(opacity)
    self.__maskLayer:setOpacity(opacity)
end

function BaseView:_setMaskLayer(popView)
    if self.__maskLayer:getParent() then
        self.__maskLayer:removeFromParent()
    end
    popView:addChild(self.__maskLayer, -Z_BLACK_MASK)
    self.__maskLayer:stopAllActions()
    if popView:isVisible() then
        self.__maskLayer:runAction(cc.FadeTo:create(0.3, popView:getMaskOpacity()))
    else
        self.__maskLayer:setOpacity(0)
    end
end

function BaseView:_addToModalQueue(view)
    local data = {}
    data.view = view
    data.next = nil
    if self._modalQueueBegin == nil then
        self._modalQueueBegin = data
    else
        local d = self._modalQueueBegin
        while d.next ~= nil do
            d = d.next
        end
        d.next = data
    end
end

function BaseView:_popModalQueue()
    if self._modalQueueBegin ~= nil then
        local data = self._modalQueueBegin
        self._modalQueueBegin = self._modalQueueBegin.next
        return data
    end
    return nil
end

function BaseView:_removeFromModalQueue(view)
    if self._modalQueueBegin == nil then
        return
    else
        local data = self._modalQueueBegin
        local lastdata = nil
        while data ~= nil do
            if data.view == view then
                view:destroy()
                if lastdata == nil then
                    self._modalQueueBegin = data.next
                else
                    lastdata.next = data.next
                end
                break
            end
            lastdata = data
            data = data.next
        end
    end
end

-- 禁止直接调用
function BaseView:closeDialogByName(name)

end

-- 获取所有由本界面弹出popview
function BaseView:getPopViews()
    return self.__popViews
end

-- 禁止直接调用
function BaseView:closeDialog(view)

    if view.forceShow then
        self:removeFromModalLayer(view)
        self.__popViews[view] = nil
        view:destroy()
        return
    end
    -- 从队首取出作比较
    local d = self._modalQueueBegin
    if d == nil then
        return
    end
    if d.view == view then

        
        -- 在队首 移除
        local queuetop = self:_popModalQueue()
        self.__popViews[queuetop.view] = nil
        queuetop.view:destroy()
        self:removeFromModalLayer(view)

        -- 如果队中还有, 就继续弹出
        local data = self._modalQueueBegin
        if data ~= nil then
            self:addToModalLayer(data.view)
            data.view:onShow()
            data.view:doPop()
        end
    else
        -- 不在队首 从队列中移除
        self.__popViews[view] = nil
        self:_removeFromModalQueue(view)
        return
    end
end
-- removeRes 释放资源 popview和layer的texture资源由baseview释放
function BaseView:destroy(removeRes)
    print("--destroy--", self:getClassName())
    -- 释放未弹出的dialog
    local point = self._modalQueueBegin
    local last
    while point do
        if point ~= self._modalQueueBegin then
            point.view:destroy()
        end
        last = point
        last.next = nil
        point = point.next
    end
    if self.__modalLayer then
        for i = 1, #self.__modalLayer:getChildren() do
            if self.__modalLayer:getChildren()[i].isPopView then
                self.__modalLayer:getChildren()[i]:destroy()
            end
        end
    end

    if self.__eventTarget then
        for modelName, _ in pairs(self.__eventTarget) do
            self._modelMgr:removeModelReflashListener(modelName, self)
        end
    end
    if removeRes then
        -- 释放资源
        self._viewMgr:ReleaseRes(self:getClassName(), self:getReleaseDelay())
        self._viewMgr:removeFromPlistList(self.__plistMap, self:getReleaseDelay())
        self.__plistMap = nil
        ScheduleMgr:delayCall(0, self, function()
            -- sfResMgr:clear(true)
            -- mcMgr:clear(true)
            spineMgr:clear()
            -- print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
        end)
        IconUtils:clearCache()
    end
    if self.__layerMap then
        for _, layer in pairs(self.__layerMap) do
            if layer.layerDestroy then
                layer:layerDestroy()
            end
            layer.parentView = nil
            local count = ScheduleMgr:cleanMyselfTicker(layer)
            if count > 0 then
                self._viewMgr:showTip(layer:getClassName().." ScheduleMgr count: " .. count)
            end  
        end
    end
    if self.__maskLayer then
        self.__maskLayer:release()
    end

    self:onDestroy()
    self:release()
end

-- 监听某model的数据刷新事件
-- 这里的逻辑改成 只有view可见的时候才会接收到消息, 如果不可见, 则在onTop的时候收到事件
function BaseView:listenReflash(modelname, callback)
    self._modelMgr:listenModelReflash(modelname, self)
    if self.__eventTarget[modelname] == nil then
        self.__eventTarget[modelname] = callback
    end
end

-- 设置监听回调的时候是否接受参数, 如果不接收, 则自动合并一帧之内的任何回调
function BaseView:setListenReflashWithParam(value)
    self.__listenReflashWithParem = value
end

-- 延迟发送事件, 可以合并一帧之内的重复回调
-- data 可为空或者字符串
function BaseView:dispatchReflash(modelname, data)
    local eventTargetCallback = self.__eventTarget[modelname]
    if data and self.__listenReflashWithParem then
        self.__dispatchCallback[modelname .. "  " .. data] = eventTargetCallback
    else
        self.__dispatchCallback[eventTargetCallback] = eventTargetCallback
    end
    if self.parentView then
        if not self.parentView.visible then return end
    end
    if (self.__isOpenQuickDispatch == true or self.visible) and not self.__dispatching then
        self.__dispatching = true
        ScheduleMgr:delayCall(0, self, function()
            if self.__dispatchCallback == nil then return end
            self.__dispatching = false
            for k, callback in pairs(self.__dispatchCallback) do
                if type(k) == "function" then
                    callback(self)
                elseif type(k) == "string" then
                    callback(self, string.split(k, "  ")[2])
                end
            end
            self.__dispatchCallback = {}
        end)
    end
end


-- onTop之前会调用, 把需要刷新的事件发送出去
function BaseView:dispatchModelEvent()
    for k, callback in pairs(self.__dispatchCallback) do
        if type(k) == "function" then
            callback(self)
        elseif type(k) == "string" then
            callback(self, string.split(k, "  ")[2])
        end
    end
    self.__dispatchCallback = {}
    -- popview
    if self.__modalLayer then
        local point = self._modalQueueBegin
        while point do
            point.view:dispatchModelEvent()
            point = point.next
        end

        for i = 1, #self.__modalLayer:getChildren() do
            self.__modalLayer:getChildren()[i]:dispatchModelEvent()
        end
    end
end

-- 渲染时会调用, 改变元件坐标在这里
function BaseView:onAdd()

end
-- 切换动画完毕时候调用, 界面动画在这里, 发请求最好也在这里
function BaseView:onAnimEnd()

end
-- 初始化UI后会调用, 有需要请覆盖
function BaseView:onInit()

end
function BaseView:onComplete()

end
-- 第一次进入界面会调用, 有需要请覆盖
function BaseView:onShow()
    pcall(function()
        for dialogName,dialogView in pairs (self.__popViews) do 
            if dialogView.onShow then
                dialogView:onShow()
            end
        end
    end)
end

-- 成为topView会调用, 有需要请覆盖
function BaseView:onTop()

end

-- 被其他View盖住会调用, 有需要请覆盖
function BaseView:onHide()

end

-- 获取对话时,需要隐藏的UI列表
function BaseView:getHideListInStory()
    return nil
end

-- 重新设置导航, 默认隐藏
function BaseView:setNavigation()
    self._viewMgr:hideNavigation("global.UserInfoView")
end

function BaseView:hideNoticeBar()
    self._viewMgr:hideNotice()
end

-- 重新设置导航, 默认显示
function BaseView:setNoticeBar()
    self._viewMgr:showNotice()
end

-- 重新设置红包显示
function BaseView:setGiftMoneyTip()
    self._viewMgr:showGiftMoneyTip()
end

function BaseView:hideGiftMoneyTip()
    self._viewMgr:hideGiftMoneyTip()
end

-- 服务器error
function BaseView:onError()
    print(self:getClassName() .. " onError")
end

-- 异步方法, 进入系统之前需要做的事情, 比如请求
function BaseView:onBeforeAdd(callback)
    if callback then
        callback()
    end
end

-- 主要用于内存优化
-- 进入战斗之前要做的事
function BaseView:enterBattle()

end

-- 退出战斗要做的事
function BaseView:exitBattle()

end

-- 接收自定义消息
function BaseView:reflashUI(data)

end

function BaseView:lock(delay)
    self._viewMgr:lock(delay)
    self.__lockCount = self.__lockCount + 1
end

function BaseView:unlock(value)
    self._viewMgr:unlock(value)
    self.__lockCount = self.__lockCount - 1
end

-- 清除自己界面调用的全局锁
function BaseView:clearLock()
    while self.__lockCount > 0 do
        self:unlock(777)
    end
end

function BaseView:createLayer(name, params, async, callback)
    local layer = self._viewMgr:createLayer(name, params, async, callback)
    layer.parentView = self
    layer.visible = true
    self.__layerMap[layer] = layer
    return layer
end

function BaseView:exitLayer(layer)
    if self.__layerMap then
        self.__layerMap[layer] = nil
    end
end

function BaseView:setBgBlur()
    local blurSp = UIUtils:getScreenBlurSprite()
    self:addChild(blurSp, -100)
    blurSp:setOpacity(0)
    blurSp:runAction(cc.FadeIn:create(0.3))
end

function BaseView:onWinSizeChange()
    if self._widget then
        self._widget:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
        self._widgetNode:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)

        -- 适配iphoneX
        if self._widget then
            if ADOPT_IPHONEX and not self.isPopView and not self.dontAdoptIphoneX then
                self._widget:setContentSize(MAX_SCREEN_WIDTH - 120, MAX_SCREEN_HEIGHT)
            end
        end
    end
    -- 子layer
    for _, layer in pairs(self.__layerMap) do
        if layer.onWinSizeChange then
            layer:onWinSizeChange()
        end
    end
    -- dialog遮罩
    if self.__maskLayer then
        self.__maskLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    end
    -- dialog
    if self.__modalLayer then
        for _, dialog in pairs(self.__modalLayer:getChildren()) do
            dialog:onWinSizeChange()
        end
        local point = self._modalQueueBegin
        while point do
            point.view:onWinSizeChange()
            point = point.next
        end
    end
    self:adjustBg()
end

--注意：在同一个view中，仅支持监听一个方法
function BaseView:listenGlobalResponse(callback)
    self._hasGlobalListener = true
    self._serverMgr:listenGlobalResponse(self, callback)
end

function BaseView:removeGlobalResponseListener()
    if self._hasGlobalListener then
        self._hasGlobalListener = false
        self._serverMgr:removeGlobalResponseListener(self)
    end
end

-- 监听来自java服务器的请求
function BaseView:listenRSResponse(callback)
    self._hasRSListener = true
    self._serverMgr:listenRSResponse(self, callback)
end

function BaseView:removeRSResponseListener()
    if self._hasRSListener then
        self._hasRSListener = false
        self._serverMgr:removeRSResponseListener(self)
    end
end

-- 默认释放资源延迟时间, 如有特殊需要, 请重写
function BaseView:getReleaseDelay()
    return 15
end

-- 当view进入时候是否卸载所有能卸载的资源
function BaseView:isReleaseAllOnShow()
    return false
end

function BaseView:isReleaseTextureOnShow()
    return true
end

function BaseView:isReleaseTextureOnPop()
    return true
end

-- 当view退出时候是否卸载所有能卸载的资源
function BaseView:isReleaseAllOnPop()
    return false
end

-- 是否多线程载入资源
function BaseView:isAsyncRes()
    return true
end

function BaseView:applicationDidBecomeActive()

end

function BaseView:applicationDidEnterBackground()

end

function BaseView:applicationDidEnterBackground_popView()
    if self.__popViews then
        for view, _ in pairs(self.__popViews) do
            view:applicationDidEnterBackground(second)
        end
    end 
end

function BaseView:applicationWillEnterForeground(second)

end

function BaseView:applicationWillEnterForeground_popView(second)
    if self.__popViews then
        for view, _ in pairs(self.__popViews) do
            view:applicationWillEnterForeground(second)
        end
    end 
end

function BaseView:registerTimer(hour, min, sec, callback)
    self._modelMgr:registerTimer(hour, min, sec, self, callback)
end

-- 重启游戏之前要做的事
function BaseView:onRestart()

end

function BaseView:setOpenQuickDispatch()
    self.__isOpenQuickDispatch = true
end

function BaseView:onDoGuide(config)
    
end

function BaseView:onReconnect()
    
end

function BaseView:cpatch()

end

function BaseView:patch()

end

function BaseView.dtor()
    BaseView = nil
    sfc = nil
    tc = nil
    Z_BLACK_MASK = nil
    Z_DIALOG_LAYER = nil
    Z_LAYER_NODE = nil
    Z_LOCK_MASK = nil
    cc = nil
end

return BaseView