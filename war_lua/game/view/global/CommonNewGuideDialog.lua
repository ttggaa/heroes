


local CommonNewGuideDialog = class("CommonNewGuideDialog",BasePopView)

local imageMiddelList = {
    {
        "asset/bg/alliance_fenxiang_guide1.jpg",
        "asset/bg/alliance_fenxiang_guide2.jpg"
    },
    {
        "asset/uiother/heroduel/imgGuild1_heroduel.jpg",
        "asset/uiother/heroduel/imgGuild2_heroduel.jpg",
        "asset/uiother/heroduel/imgGuild3_heroduel.jpg",
        "asset/uiother/heroduel/imgGuild4_heroduel.jpg"
    },
    {
        "asset/uiother/gvg/citybattle_rule1.jpg",
        "asset/uiother/gvg/citybattle_rule2.jpg",
        "asset/uiother/gvg/citybattle_rule3.jpg",
        "asset/uiother/gvg/citybattle_rule4.jpg",
    }
}
local titleText = {
    {
        "加入联盟",
        "联盟探索"
    },
    {
        lang("HERODUEL_TITLE1"),
        lang("HERODUEL_TITLE2"),
        lang("HERODUEL_TITLE3"),
        lang("HERODUEL_TITLE4")
    },
    {
        "全民备战",
        "攻城略地",
        "战斗盛宴",
        "万千豪礼"
    }
}

local bottomText = {
    {
        lang("GUILD_GUIDE1"),
        lang("GUILD_GUIDE2")
    },
    {
        lang("HERODUEL_TIPS1"),
        lang("HERODUEL_TIPS2"),
        lang("HERODUEL_TIPS3"),
        lang("HERODUEL_TIPS4")
    },
    {
        lang("RULE_CITYBATTLE_TIP_01"),
        lang("RULE_CITYBATTLE_TIP_02"),
        lang("RULE_CITYBATTLE_TIP_03"),
        lang("RULE_CITYBATTLE_TIP_04")
    }
}


--showType 
--1 联盟
--2 英雄交锋
--3 gvg 领土争夺

function CommonNewGuideDialog:ctor(param)
    CommonNewGuideDialog.super.ctor(self)
    self._curIndex = 1
    if param.firstPage then
        self._curIndex = param.firstPage
    end
    self._initGuideType = param.showType or 1
    self._callBack = param and param.callBack
end

function CommonNewGuideDialog:onInit()
    self:registerClickEventByName("bg.imageBg.closeBtn", function ()
        if self._callBack then
            self._callBack()
        end
        self:close()
        if OS_IS_WINDOWS then
            package.loaded["view.global.CommonNewGuideDialog"] = nil
        end
    end)

    self._layer = self:getUI("bg.imageBg")
    self._titleLabel = self:getUI("bg.imageBg.titleLabel")
    self._titleLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    self._titleLabel:setFontName(UIUtils.ttfName_Title)

    self._imageMiddle = self:getUI("bg.imageBg.imageMiddle")
    self:registerClickEventByName("bg.imageBg.leftBtn", function ()
        self:changePage("left")
    end)
    self:registerClickEventByName("bg.imageBg.rightBtn", function ()
        self:changePage("right")
    end)

    self._leftBtn = self:getUI("bg.imageBg.leftBtn")
    self._rightBtn = self:getUI("bg.imageBg.rightBtn")

    local maxPage = table.nums(imageMiddelList[self._initGuideType])
    self._maxPage = maxPage
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

function CommonNewGuideDialog:changePage(tp)
    local maxPage = table.nums(imageMiddelList[self._initGuideType])
    if tp == "left" then
        self._curIndex = self._curIndex - 1
        self._curIndex = self._curIndex == 0 and maxPage or self._curIndex
    elseif tp == "right" then
        self._curIndex = self._curIndex + 1
        self._curIndex = self._curIndex == maxPage+1 and 1 or self._curIndex
    end

    self:updateUI(self._curIndex)
end

function CommonNewGuideDialog:updateUI(index)

    if self._curPoint == nil then
        self._curPoint = cc.Sprite:createWithSpriteFrameName("globaImageUI_pagePointRed.png")
        self._layer:addChild(self._curPoint)
    end
    self._curPoint:setPosition(self._pointList[index]:getPosition())

    self._titleLabel:setString(titleText[self._initGuideType][self._curIndex])
    if self._desRich ~= nil then
        self._desRich:removeFromParent(true)
        self._desRich = nil
    end
    self._desRich = RichTextFactory:create(bottomText[self._initGuideType][self._curIndex], 820, 30)
    self._desRich:formatText()
    self._desRich:enablePrinter(true)
    self._desRich:setPosition(473, 57)
    self._layer:addChild(self._desRich)
	UIUtils:alignRichText(self._desRich,{hAlign = "center"})

    self._imageMiddle:loadTexture(imageMiddelList[self._initGuideType][self._curIndex])
    if index <= 1 then
        self._leftBtn:setVisible(false)
        self._rightBtn:setVisible(true)
    elseif index >= self._maxPage then
        self._leftBtn:setVisible(true)
        self._rightBtn:setVisible(false)
    else
        self._leftBtn:setVisible(true)
        self._rightBtn:setVisible(true)
    end

end

function CommonNewGuideDialog.dtor()
    imageMiddelList = nil
    titleText = nil
    bottomText = nil
end
return CommonNewGuideDialog