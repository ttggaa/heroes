--[[
    Filename:    SiegeDailyPlotReviewView.lua
    Author:      <hexinping@playcrab.com>
    Datetime:    2017-12-28 
    Description: File description
--]]


local SiegeDailyPlotReviewView = class("SiegeDailyPlotReviewView", BasePopView)

function SiegeDailyPlotReviewView:ctor()
    SiegeDailyPlotReviewView.super.ctor(self)
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("siegeDaily.SiegeDailyPlotReviewView")
        end
    end)

end

function SiegeDailyPlotReviewView:onInit()
    local titleLab = self:getUI("bg.titleBg.titleLab")
    UIUtils:setTitleFormat(titleLab, 3)

    local closeBtgn = self:getUI("bg.closeBtn")
    registerClickEvent(closeBtgn, function ()
        self:close()
    end)
end

function SiegeDailyPlotReviewView:reflashUI()
    local cfg = tab.siegeMainPlot
    local ids = {1, 2, 5}
    for i = 1, 3 do
        local  plotId = ids[i]
        local  data = cfg[plotId]
        local  item = self:getUI("bg.pageBg.item"..i)
        local  uiTitle = item:getChildByName("titleLab")
        local  playBtn = item:getChildByName("playBtn")

        item:loadTexture(data.uiBg..".png",1)
        uiTitle:setColor(UIUtils.colorTable.ccUITxtColor1)
        uiTitle:enable2Color(1, UIUtils.colorTable.ccUITxtColor2)
        uiTitle:setString(lang(data.uiTitle))
        registerClickEvent(playBtn, function ()
            self:showPlot(plotId)
        end) 
    end
end

function SiegeDailyPlotReviewView:showPlot(plotId)
    self._viewMgr:showView("siege.SiegeMcPlotView", 
        {
            plotId = plotId,
            callback = function()
                self._viewMgr:popView()
            end
        },true)
end

function SiegeDailyPlotReviewView:onDestroy()
    SiegeDailyPlotReviewView.super.onDestroy(self)
end

return SiegeDailyPlotReviewView