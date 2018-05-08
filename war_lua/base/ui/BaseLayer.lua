--[[
    Filename:    BaseLayer.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2015-05-21 17:43:17
    Description: File description
--]]

-- layer和view的区别就是少了一些方法, 并且不会主动把root拉伸到全屏大小, 需要手动调用setFullScreen

local BaseLayer = class("BaseLayer", BaseMvcs , BaseEvent, function ()
    return ccui.Layout:create()
end)

function BaseLayer:ctor()
    BaseLayer.super.ctor(self)

    self:registerScriptHandler(function (state)
        if state == "exit" then
            if self.parentView then
                self.parentView:exitLayer(self)
            end
        end
    end)
    self.isLayer = true
end

function BaseLayer:initUI(name, async, callback)
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
    self._widget = ccs.GUIReader:getInstance():widgetFromBinaryFile(self.__jsonName)
    if self._widget then
        self._widget:setBackGroundColorOpacity(0)
        self:L10N_Text()
        self:addChild(self._widget)
    end
    self:onInit()
    if callback then callback(self) end
end

function BaseLayer:setFullScreen()
    if self._widget then
        self._widget:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    end
    self:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self._setFullScreen = true
end

function BaseLayer:setSelfContentSize(w, h)
    local _w = w < MAX_SCREEN_WIDTH and w or MAX_SCREEN_WIDTH
    if self._widget then
        self._widget:setContentSize(_w, h)
    end
    self:setContentSize(_w, h)
end

-- 初始化UI后会调用, 有需要请覆盖
function BaseLayer:onInit()

end

function BaseLayer:reflashUI(data)
    self._viewMgr:doLayerGuide(self)
end
-- 显示物品hint
function BaseLayer:showHintView(name, data, callback)
    return self.parentView:showHintView(name, data, callback)
end

function BaseLayer:closeHintView()
    self.parentView:closeHintView()
end

function BaseLayer:createLayer(name, params)
    return self.parentView:createLayer(name, params)
end

function BaseLayer:onWinSizeChange()
    if self._setFullScreen and self._widget then
        self._widget:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
        self:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    end
end

function BaseLayer.dtor()
    BaseLayer = nil
end

return BaseLayer