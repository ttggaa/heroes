--[[
    Filename:    GodWarCountDownDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-05-19 19:54:14
    Description: File description
--]]


-- 倒计时
local GodWarCountDownDialog = class("GodWarCountDownDialog", BasePopView)

function GodWarCountDownDialog:ctor(param)
    GodWarCountDownDialog.super.ctor(self)
    self._callback = param.callback
    self._first = 1
end

-- function GodWarCountDownDialog:getMaskOpacity()
--     return 0
-- end

function GodWarCountDownDialog:onInit()
    -- self:registerClickEventByName("bg", function ()
    --     if OS_IS_WINDOWS then
    --         UIUtils:reloadLuaFile("godwar.GodWarCountDownDialog")
    --     end
    --     if self._callback then
    --         self._callback()
    --     end
    --     self:close()
    -- end)  
    self._prepareNode = self:getUI("countPanel")
    self:formationPrepare(self._callback)
end

function GodWarCountDownDialog:reflashUI()
 
end

-- 前往布阵前倒计时
function GodWarCountDownDialog:formationPrepare(callback)
    self._prepareNode:setVisible(true)
    local countInNum = 3
    local animLab1 = ccui.Text:create()
    animLab1:setFontSize(150)
    animLab1:setFontName(UIUtils.ttfName)
    animLab1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    animLab1:setPosition(MAX_SCREEN_WIDTH *0.5, MAX_SCREEN_HEIGHT*0.5 + 100)
    animLab1:setString(" ")
    self._prepareNode:addChild(animLab1,99)
    local countMc = mcMgr:createViewMC("daojishi_leagueredian", false, false,function( _,sender )
        -- sender:gotoAndPlay(10)
        sender:stop()
    end,RGBA8888)
    -- countMc:setPlaySpeed(0.5)
    countMc:setPosition(50,100)
    -- countMc:stop()
    animLab1:addChild(countMc,2)
    local animLab2 = animLab1:clone()
    animLab2:setPosition(MAX_SCREEN_WIDTH*0.5, MAX_SCREEN_HEIGHT *0.5 + 100)
    animLab2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    animLab2:setString(" ")
    self._prepareNode:addChild(animLab2,99)
    animLab2:runAction(
        cc.RepeatForever:create(
            cc.Sequence:create(
                cc.Spawn:create(cc.ScaleTo:create(0.2,1.5),cc.FadeTo:create(0.2,180)),
                cc.Spawn:create(cc.ScaleTo:create(0.3,2.5),cc.FadeOut:create(0.3)),
                cc.DelayTime:create(0.5),
                cc.CallFunc:create(function( )
                    -- animLab2:setScale(1)
                    -- animLab2:setOpacity(255)
                    countInNum = countInNum-1
                    print("countInNum========", countInNum)
                    if countInNum < 1 then
                        -- audioMgr:stopAll()
                        
                        local bg = self:getUI("bg")
                        local countMc = mcMgr:createViewMC("zhandoukaiqi_zhandoukaiqi", false, true, function( _,sender )
                            print( "self.close==========", self.close)
                            if self._first ~= 1 then
                                if self.close then
                                    self:close()
                                end
                                return
                            end
                            self._first = 2
                            if self.parentView:getClassName() ~= "godwar.GodWarView" then
                                if callback then
                                    callback()
                                end
                                if self.parentView and self.parentView.close then
                                    self.parentView:close()
                                end
                                if self.close then
                                    self:close()
                                end
                            else
                                if callback then
                                    callback()
                                end
                                if self.close then
                                    self:close()
                                end
                            end
                        end,RGBA8888)
                        countMc:setName("countMc")
                        animLab2:stopAllActions()
                        animLab1:setVisible(false)
                        animLab2:setVisible(false)
                        local tipLab = self:getUI("countPanel.tipLab")
                        tipLab:setVisible(false)
                        countMc:setPosition(bg:getContentSize().width*0.5, bg:getContentSize().height*0.5+100)
                        bg:addChild(countMc, 1)
                        return
                    end
                    animLab1:setString(" ")
                    animLab2:setString(" ")
                    -- countMc:gotoAndPlay(0)
                    -- countMc:addEndCallback(function (_, sender)
                    --     sender:stop()
                    -- end)
                end)
            )
        ))

end
return GodWarCountDownDialog
