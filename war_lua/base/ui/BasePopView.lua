--[[
    Filename:    BasePopView.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2015-04-30 11:08:11
    Description: File description
--]]
local cc = cc
local BasePopView = class("BasePopView", BaseView)

function BasePopView:ctor()
    BasePopView.super.ctor(self)
    self.isPopView = true
    self.popAnim = true
end

function BasePopView:getMaskOpacity()
    return 210
end

function BasePopView:doPop(callback)
    self._widget:setBackGroundColorOpacity(0)
    self._widget:setTouchEnabled(true)
    local bg = self:getUI("bg")
    if bg and self.popAnim then
        bg:setAnchorPoint(0.5, 0.5)
        bg:stopAllActions()
        bg:setScale(0.7)
        self._doPopCallback = callback
        audioMgr:playSound("Popup")
        ScheduleMgr:delayCall(0, self, function()
            bg:runAction(cc.Sequence:create(cc.EaseOut:create(cc.ScaleTo:create(0.1, 1.05), 3), 
                cc.ScaleTo:create(0.07, 1.0),
                cc.CallFunc:create(function ()
                self._viewMgr:doPopShowGuide(self)
                if callback then
                    callback()
                end
                self._doPopCallback = nil
                self:onPopEnd()
            end)))
        end)
    else
        callback()
        audioMgr:playSound("Popup")
        self._viewMgr:doPopShowGuide(self)
        self:onPopEnd()
    end 
end

function BasePopView:onPopEnd()

end

-- 添加装饰的边角 用于悬浮窗界面
function BasePopView:addDecorateCorner( )
    local bg = self:getUI("bg")
    local bgW,bgH = bg:getContentSize().width, bg:getContentSize().height
    local offsetX = math.abs(bgW-MAX_SCREEN_WIDTH)/2
    local offsetY = math.abs(bgH-MAX_SCREEN_HEIGHT)/2

    local moveOffset = {25,25}

    local leftBottomPos = {x = -offsetX, y = -offsetY}
    local leftCornerImg = ccui.ImageView:create()
    leftCornerImg:loadTexture("globalImageUI_commonGetConner.png",1)
    leftCornerImg:setAnchorPoint(0,0)
    leftCornerImg:setPosition(leftBottomPos.x-moveOffset[1], leftBottomPos.y-moveOffset[2])
    bg:addChild(leftCornerImg)
    leftCornerImg:runAction(cc.MoveTo:create(0.1,cc.p(leftBottomPos.x, leftBottomPos.y)))

    local rightBottomPos = {x = bgW+offsetX-354, y = -offsetY}
    local rightCornerImg = ccui.ImageView:create()
    rightCornerImg:loadTexture("globalImageUI_commonGetConner.png",1)
    rightCornerImg:setFlippedX(true)
    rightCornerImg:setAnchorPoint(1,0)
    rightCornerImg:setPosition(rightBottomPos.x+moveOffset[1], rightBottomPos.y-moveOffset[2])
    bg:addChild(rightCornerImg)
    rightCornerImg:runAction(cc.MoveTo:create(0.1,cc.p(rightBottomPos.x, rightBottomPos.y)))
end

-- 弹出悬浮窗（如：获得物品）title动画
function BasePopView:addPopViewTitleAnim( view,mcName,x,y)
    local mcStar = mcMgr:createViewMC( mcName or "gongxihuode_huodetitleanim", false, false, function (_, sender)
        
    end,RGBA8888)
    mcStar:setPosition(x,y+35)
    view:addChild(mcStar,99)

    mcStar:addCallbackAtFrame(6,function( )
        local mc = mcMgr:createViewMC("caidai_huodetitleanim", false, false, function (_, sender)
        --sender:gotoAndPlay(80)
        end,RGBA8888)
        -- mc:setPlaySpeed(1)
        mc:setPosition(cc.p(x,y))
        view:addChild(mc,100)

        local mc1 = mcMgr:createViewMC("xingxingpiao_huodetitleanim", true, false, function (_, sender)
        --sender:gotoAndPlay(80)
        end,RGBA8888)
        -- mc1:setPlaySpeed(2)
        mc1:setPosition(x,y+35)
        view:addChild(mc1,1)
                 
        local mc1bg = mcMgr:createViewMC("huodedaojudiguang_commonlight", true, false, function (_, sender)
            sender:gotoAndPlay(0)
        end,RGBA8888)
        mc1bg:setPlaySpeed(1)
        mc1bg:setScale(1.5)

        local clipNode2 = cc.ClippingNode:create()
        clipNode2:setPosition(x,y+45)
        local mask = cc.Sprite:createWithSpriteFrameName("globalImage_IconMaskHalfCircle.png")
        mask:setScale(2.5)
        mask:setPosition(0,138)
        clipNode2:setStencil(mask)
        clipNode2:setAlphaThreshold(0.5)
        mc1bg:setPositionY(-10)
        clipNode2:addChild(mc1bg)
        view:addChild(clipNode2,-1)
        UIUtils:shakeWindow(view)
    end) 
end

function BasePopView:close(noAnim, callback)
    if self.__closing then return end
    self.__closing = true
    if noAnim then
        self._viewMgr:doPopCloseGuide(self)  
        audioMgr:playSound("Close")
        self:_remove()
        if callback then
            callback()
        end
    else
        local bg = self:getUI("bg")
        if bg and self.popAnim then
            audioMgr:playSound("Close")
            bg:setAnchorPoint(0.5, 0.5)
            bg:stopAllActions()
            if self._delayClose then
                bg:runAction(cc.Sequence:create(
                    cc.DelayTime:create(0.5),
                    cc.ScaleTo:create(0.05, 1.1),
                    cc.ScaleTo:create(0.09, 0.6), cc.CallFunc:create(function () bg:setVisible(false) end), cc.DelayTime:create(0.05), 
                    cc.CallFunc:create(function ()
                    self._viewMgr:doPopCloseGuide(self)  
                    self:_remove()
                    if callback then
                        callback()
                    end
                end)))
            else
                bg:runAction(cc.Sequence:create(
                    cc.ScaleTo:create(0.05, 1.1),
                    cc.ScaleTo:create(0.06, 0.6), cc.CallFunc:create(function () bg:setVisible(false) end), cc.DelayTime:create(0.05), 
                    cc.CallFunc:create(function ()
                    self._viewMgr:doPopCloseGuide(self)  
                    self:_remove()
                    if callback then
                        callback()
                    end
                end)))
            end
        else
            self._viewMgr:doPopCloseGuide(self)
            audioMgr:playSound("Close")
            self:_remove()
            if callback then
                callback()
            end
        end
    end
end
local sfc = cc.SpriteFrameCache:getInstance()
local tc = cc.Director:getInstance():getTextureCache()
function BasePopView:_remove()
    if self._closeCallback then
        self._closeCallback()
    end
    if self.parentView then
        self.parentView:closeDialog(self)
    else
        self:destroy()
        self:removeFromParent()
    end
end

function BasePopView:removeRes()
    if not self.dontRemoveRes then
        for k, v in pairs(self.__plistMap) do
            -- print("release plist", k)
            sfc:removeSpriteFramesFromFile(k)
            tc:removeTextureForKey(v)
        end
    end
end

function BasePopView:setCloseCallback(cb)
    self._closeCallback = cb
end

function BasePopView:onDestroy()
    -- print("onDestroy", self:getClassName())
    self:removeRes()
    if self._doPopCallback then
        self._doPopCallback()
    end
    ScheduleMgr:cleanMyselfDelayCall(self)
    ScheduleMgr:cleanMyselfTicker(self)
    BasePopView.super.onDestroy(self)
end


function BasePopView.dtor()
    BasePopView = nil
    sfc = nil
    tc = nil
    cc = nil
end

return BasePopView