--[[
    Filename:    MFTaskDetailDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-07-12 20:15:59
    Description: File description
--]]

local MFTaskDetailDialog = class("MFTaskDetailDialog", BasePopView)

function MFTaskDetailDialog:ctor()
    MFTaskDetailDialog.super.ctor(self)
    self._model = self._modelMgr:getModel("MailBoxModel")
end

function MFTaskDetailDialog:onInit()

    self._scrollView = self:getUI("bg.scrollView")
    -- self._titleBg = self:getUI("bg.titleBg")
    self._title = self:getUI("bg.layer.titleBg.title")
    UIUtils:setTitleFormat(self._title, 6)
    -- self._title:setFontName(UIUtils.ttfName)
    -- self._title:setColor(UIUtils.colorTable.ccUIBaseColor1)
    -- -- self._title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    -- self._title:setFontSize(30)

    -- self._content = self:getUI("bg.scrollView.content")
    -- self._content:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    -- self._content:setFontName(UIUtils.ttfName)
    -- self._sender = self:getUI("bg.scrollView.sender")
    -- self._sender:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    -- self._sender:setFontName(UIUtils.ttfName)

    -- self._titleBg:setAnchorPoint(0.5, 1)
    -- self._title:enable2Color(1, cc.c4b(240, 165, 40, 255))

    local closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(closeBtn, function()
        self:close()
    end)
end

function MFTaskDetailDialog:reflashUI(data)
    -- local str = "委托人: 商会管事"
    -- self._sender:setString(str)

    local str = lang(tab:MfTask(data.taskId).story)
    local concentBg = self:getUI("bg.scrollView.concentBg")
    if string.find(str, "color=") == nil then
        str = "[color=3D1F00]"..str.."[-]"
    -- else
    --     local i,j = string.find(str, "color=")
    --     local str1 = string.sub(str, 1, j)
    --     local str2 = string.sub(str, j+6, string.len(str))
    --     str = str1.."3D1F00"..str2
    end  

    local richText = RichTextFactory:create(str, concentBg:getContentSize().width, 0)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(concentBg:getContentSize().width/2, concentBg:getContentSize().height - richText:getInnerSize().height/2)
    concentBg:addChild(richText)

    local descHeight = richText:getRealSize().height
    -- maxHeight = maxHeight + self._content:getContentSize().height
    local maxHeight = descHeight -- + self._sender:getContentSize().height
    if maxHeight > self._scrollView:getContentSize().height then
        self._scrollView:setInnerContainerSize(cc.size(self._scrollView:getContentSize().width,maxHeight))
    else
        maxHeight = self._scrollView:getContentSize().height      
    end
    local posY = 20

    concentBg:setPositionY(maxHeight-posY)
    -- posY = posY + descHeight + 20
    -- self._sender:setPositionY(maxHeight - posY)
    -- print("领取附件")

end

return MFTaskDetailDialog