--[[
    FilePath:    D:\works\war_kor\svn\Resources\script\game\view\global\GlobalSecondConfirmDialog.lua
    Author:      <zhuxinlei@playcrab.com>
    Datetime:    2018-03-31 10:30:33
    Description: second confirm 
--]]


local GlobalSecondConfirmDialog = class("GlobalSecondConfirmDialog",BasePopView)
function GlobalSecondConfirmDialog:ctor()
    GlobalSecondConfirmDialog.super.ctor(self)

end

-- 初始化UI后会调用, 有需要请覆盖
function GlobalSecondConfirmDialog:onInit()

    self._descLabel = self:getUI("bg.descLabel")
    self._bg = self:getUI("bg")
    self._descLabel:getVirtualRenderer():setMaxLineWidth(302)
    self._descLabel:getVirtualRenderer():setLineHeight(30)
    self._btn2 = self:getUI("bg.btn2")
    self._btn1 = self:getUI("bg.btn1")
    self._checkBox = self:getUI("bg.checkBox")  
    self._checkBox:setSelected(false)

    self:registerClickEvent(self._btn1, function ()
        self:close(false,self._callback1(self._checkBox:isSelected()))
    end)

    self:registerClickEvent(self._btn2, function ()
        self:close(false,self._callback2)
        UIUtils:reloadLuaFile("global.GlobalSecondConfirmDialog")
    end)
    self._title = self:getUI("bg.title")
	UIUtils:setTitleFormat(self._title, 6)

	self._titleTip = self:getUI("bg.titleTip")
	UIUtils:setTitleFormat(self._titleTip, 6)

end


-- 接收自定义消息
function GlobalSecondConfirmDialog:reflashUI(data)
   if type(data.desc) == "string" then
        if string.find(data.desc,"[-]") then
            self._descLabel:setString("")
            local rtx = DialogUtils.createRtxLabel( data.desc,{width = 302} )
            rtx:formatText()
            rtx:setPosition(cc.p(self._bg:getContentSize().width/2-3,self._bg:getContentSize().height/2+60))
            self._bg:addChild(rtx,10)
            UIUtils:alignRichText(rtx,{hAlign = "center"})
        else
            self._descLabel:setString(data.desc)
        end
            
    elseif type(data.desc) == "userdata" then
        self._descLabel:setString("")
        data.desc:setPosition(cc.p(self._bg:getContentSize().width/2,self._bg:getContentSize().height/2+60))
        self._bg:addChild(data.desc,99)
    end
    if not data.button1 or data.button1 == "" then data.button1 = "确定" end
    self._btn1:setTitleText(data.button1)
    --[[if not data.alignNum then
        if self._descLabel:getVirtualRenderer():getStringNumLines() > 1 then  
            self._descLabel:setTextHorizontalAlignment(3)
        else
            self._descLabel:setTextHorizontalAlignment(1)
        end
    else
        self._descLabel:setTextHorizontalAlignment(data.alignNum)
    end--]]
    self._callback1 = data.callback1
    self._callback2 = data.callback2
	if data.title then
		self._title:setString(data.title)
		self._titleTip:setString(data.title)
	end
end

return GlobalSecondConfirmDialog