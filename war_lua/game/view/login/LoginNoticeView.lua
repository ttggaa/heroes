--[[
    Filename:    LoginNoticeView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-02-23 20:03:08
    Description: File description
--]]

local LoginNoticeView = class("LoginNoticeView", BasePopView)


function LoginNoticeView:ctor(data)
    LoginNoticeView.super.ctor(self)
    self._data = data.data
    self._callback = data.callback
end

function LoginNoticeView:onDestroy()
    if self._updateId then
        ScheduleMgr:unregSchedule(self._updateId)
        self._updateId = nil
    end
    LoginNoticeView.super.onDestroy(self)
end


function LoginNoticeView:onInit()
    local closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(closeBtn, function ()
        local callback = self._callback
        self:close(false, callback)
    end)
    local closeBtn2 = self:getUI("bg.closeBtn2")
    self:registerClickEvent(closeBtn2, function ()
        local callback = self._callback
        self:close(false, callback)
    end)

    self._scrollView = self:getUI("bg.ScrollView")
    UIUtils:uiScrollViewAddScrollBar(self._scrollView, cc.c3b(169, 124, 75), cc.c3b(32, 16, 6), 4, 6)
    self._title = self:getUI("bg.title")
    self._title:setFontName(UIUtils.ttfName_Title)
    self._title:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
    self._title:setFontSize(26)
    self._updateId = ScheduleMgr:regSchedule(0, self, function(self, dt)
        UIUtils:uiScrollViewUpdateScrollBar(self._scrollView)
    end)
    local str =  "[color=ffffff]暂无公告[-]"


    if not trycall("LoginNoticeView:reflashView", self.reflashView, self, self._data) then 
        self:reflashView(str)        
    end
end

function LoginNoticeView:reflashView(data)
    if string.find(data, "color=") == nil then
        data = "[color=452800]"..data.."[-]"
    end
    local richText = RichTextFactory:create(data, self._scrollView:getContentSize().width-24, 0)
    richText:setPixelNewline(true)
    richText:formatText()
    local height  = self._scrollView:getContentSize().height
    if height < richText:getRealSize().height then
        height = richText:getRealSize().height
    end
    self._scrollView:setInnerContainerSize(cc.size(self._scrollView:getContentSize().width, height))
    richText:setPosition(self._scrollView:getContentSize().width/2+6, self._scrollView:getInnerContainerSize().height - richText:getRealSize().height/2)
    self._scrollView:addChild(richText)
end

return LoginNoticeView