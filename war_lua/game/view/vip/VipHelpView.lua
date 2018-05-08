--[[
    Filename:    VipHelpView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2017-06-17 11:42:08
    Description: File description
--]]

local VipHelpView = class("VipHelpView",BasePopView)
function VipHelpView:ctor()
    VipHelpView.super.ctor(self)

    self._curIndex = 1
end

-- 初始化UI后会调用, 有需要请覆盖
function VipHelpView:onInit()
    self:registerClickEventByName("bg.layer.closeBtn", function ()
        self:close()
        if OS_IS_WINDOWS then
            package.loaded["game.view.heroduel.VipHelpView"] = nil
        end
    end)

    self._layer = self:getUI("bg.layer")

    self._titleLabel = self:getUI("bg.layer.titleLabel")
    self._titleLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    self._titleLabel:setFontName(UIUtils.ttfName_Title)
    self._titleLabel:setString("iOS充值引导")

    self._desImg = self:getUI("bg.layer.imgDes")

    self:registerClickEventByName("bg.layer.leftBtn", function ()
        self:changePage("left")
    end)

    self:registerClickEventByName("bg.layer.rightBtn", function ()
        self:changePage("right")
    end)

    self._leftBtn = self:getUI("bg.layer.leftBtn")
    self._rightBtn = self:getUI("bg.layer.rightBtn")

    self:updateUI(self._curIndex)
end

function VipHelpView:changePage(tp)
    if tp == "left" then
        self._curIndex = self._curIndex - 1
        self._curIndex = self._curIndex == 0 and 3 or self._curIndex
    elseif tp == "right" then
        self._curIndex = self._curIndex + 1
        self._curIndex = self._curIndex == 4 and 1 or self._curIndex
    end

    self:updateUI(self._curIndex)
end

function VipHelpView:updateUI(index)
    if index <= 1 then
        self._leftBtn:setVisible(false)
        self._rightBtn:setVisible(true)
    elseif index >= 3 then
        self._leftBtn:setVisible(true)
        self._rightBtn:setVisible(false)
    else
        self._leftBtn:setVisible(true)
        self._rightBtn:setVisible(true)
    end

    self._desImg:loadTexture("asset/uiother/vip/step_" .. self._curIndex  .. "_vip.png", 0)
end
return VipHelpView