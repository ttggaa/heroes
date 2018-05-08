--
-- Author: <ligen@playcrab.com>
-- Date: 2017-04-22 16:36:26
--
local HeroDuelDesView = class("HeroDuelDesView",BasePopView)
function HeroDuelDesView:ctor()
    HeroDuelDesView.super.ctor(self)

    self._curIndex = 1
end

-- 初始化UI后会调用, 有需要请覆盖
function HeroDuelDesView:onInit()
    self:registerClickEventByName("bg.layer.closeBtn", function ()
        self:close()
        if OS_IS_WINDOWS then
            package.loaded["game.view.heroduel.HeroDuelDesView"] = nil
        end
    end)

    self._layer = self:getUI("bg.layer")

    self._titleLabel = self:getUI("bg.layer.titleLabel")
    self._titleLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    self._titleLabel:setFontName(UIUtils.ttfName_Title)

    self._desImg = self:getUI("bg.layer.imgDes")

    self:registerClickEventByName("bg.layer.leftBtn", function ()
        self:changePage("left")
    end)

    self:registerClickEventByName("bg.layer.rightBtn", function ()
        self:changePage("right")
    end)

    self._leftBtn = self:getUI("bg.layer.leftBtn")
    self._rightBtn = self:getUI("bg.layer.rightBtn")

    local maxPage = 4
    local space = 24
    local startPosX = 460-space*(maxPage-1)/2

    self._pointList = {}
    for i = 1 , maxPage do
        local pointBg = cc.Sprite:createWithSpriteFrameName("globaImageUI_pagePointGray.png")
        pointBg:setPosition(startPosX + (i-1)*space, 30)
        self._layer:addChild(pointBg)
        table.insert(self._pointList, pointBg)
    end

    self:updateUI(self._curIndex)
end

function HeroDuelDesView:changePage(tp)
    if tp == "left" then
        self._curIndex = self._curIndex - 1
        self._curIndex = self._curIndex == 0 and 4 or self._curIndex
    elseif tp == "right" then
        self._curIndex = self._curIndex + 1
        self._curIndex = self._curIndex == 5 and 1 or self._curIndex
    end

    self:updateUI(self._curIndex)
end

function HeroDuelDesView:updateUI(index)
    if self._curPoint == nil then
        self._curPoint = cc.Sprite:createWithSpriteFrameName("globaImageUI_pagePointRed.png")
        self._layer:addChild(self._curPoint)
    end
    self._curPoint:setPosition(self._pointList[index]:getPosition())

    self._titleLabel:setString(lang("HERODUEL_TITLE" .. index))

    if self._desRich ~= nil then
        self._desRich:removeFromParent(true)
        self._desRich = nil
    end
    self._desRich = RichTextFactory:create(lang("HERODUEL_TIPS" .. index), 820, 30)
    self._desRich:formatText()
    self._desRich:enablePrinter(true)
    self._desRich:setPosition(473, 57)
    self._layer:addChild(self._desRich)
	UIUtils:alignRichText(self._desRich,{hAlign = "center"})

    if index <= 1 then
        self._leftBtn:setVisible(false)
        self._rightBtn:setVisible(true)
    elseif index >= 4 then
        self._leftBtn:setVisible(true)
        self._rightBtn:setVisible(false)
    else
        self._leftBtn:setVisible(true)
        self._rightBtn:setVisible(true)
    end

    self._desImg:loadTexture("asset/uiother/heroduel/imgGuild" .. index .. "_heroduel.jpg")
end
return HeroDuelDesView