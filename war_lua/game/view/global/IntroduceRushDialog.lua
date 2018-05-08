--[[
    Filename:    IntroduceRushDialog.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-03-24 11:47:40
    Description: File description
--]]

local IntroduceRushDialog = class("IntroduceRushDialog", BasePopView)

function IntroduceRushDialog:ctor(data)
    IntroduceRushDialog.super.ctor(self)
    self._kind = data.kind
    self._str = data.str
end

function IntroduceRushDialog:onInit()
    local showTick = os.clock()

    local title = self:getUI("bg.titlebg.title")
    title:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    self._titleTxt = self:getUI("bg.titleBg1.titleLab")
    self._titleTxt:setString(lang("CLASS_INTRODUCENAME_3"))
    UIUtils:adjustTitle(self:getUI("bg.titleBg1"))

    self:registerClickEventByName("bg.close", function ()
        self:close()
    end)

    local teamBg = self:getUI("bg.teamBg")
    local beijing = mcMgr:createViewMC("beijing_yindao", true, false)
    beijing:setName("beijing")
    beijing:setPosition(cc.p(teamBg:getContentSize().width*0.5, teamBg:getContentSize().height*0.5))
    teamBg:addChild(beijing)

    local bg = self:getUI("bg")
    self:registerClickEvent(bg, function ()
        if os.clock() > showTick + 1 then
            self:close()
        end
    end)
    local richText = RichTextFactory:create(lang(self._str), 600, 0)
    richText:formatText()
    richText:setPosition(bg:getContentSize().width * 0.5 + 20, 110)
    bg:addChild(richText)

    local teamBg = self:getUI("bg.teamBg")
    local beijing = mcMgr:createViewMC("beijing_yindao", true, false)
    beijing:setName("beijing")
    beijing:setPosition(cc.p(teamBg:getContentSize().width*0.5, teamBg:getContentSize().height*0.5))
    teamBg:addChild(beijing)

    local mask = ccui.Layout:create()
    mask:setAnchorPoint(0, 0)
    mask:setBackGroundColorOpacity(0)
    mask:setBackGroundColorType(1)
    mask:setClippingEnabled(true)
    mask:setContentSize(bg:getContentSize().width, bg:getContentSize().height)
    mask:setPosition(6, 6)
    bg:addChild(mask)

    -- qibing jinzhan yuanchengbing
    local mcNames = {"jinzhan_yindao", "qibing_yindao", "yuanchengbing_yindao"}
    local mc = mcMgr:createViewMC(mcNames[self._kind], true)
    mc:setPosition(bg:getContentSize().width * 0.5, 265)
    mask:addChild(mc)
end

return IntroduceRushDialog