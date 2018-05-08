--
-- Author: huangguofang
-- Date: 2016-05-03 17:50:31
--
local ArenaDialogBuyCounts = class("ArenaDialogBuyCounts",BasePopView)
function ArenaDialogBuyCounts:ctor()
    self.super.ctor(self)

end

-- 第一次被加到父节点时候调用
function ArenaDialogBuyCounts:onAdd()

end
-- 初始化UI后会调用, 有需要请覆盖
function ArenaDialogBuyCounts:onInit()
	self:registerClickEventByName("bg.cancelBtn", function( )
		self:close()
        UIUtils:reloadLuaFile("arena.ArenaDialogBuyCounts")
	end)
	self._sureCallback = nil
	self._descLabel = self:getUI("bg.descLabel")    

    local title = self:getUI("bg.title")
    UIUtils:setTitleFormat(title, 6)

    self:registerClickEventByName("bg.confirmBtn", function( )        
        self:close()
        if self._sureCallback ~= nil then
            self._sureCallback()
        end
    end)
end

-- 第一次进入调用, 有需要请覆盖
function ArenaDialogBuyCounts:onShow()

end

-- 成为topView会调用, 有需要请覆盖
function ArenaDialogBuyCounts:onTop()

end

-- 被其他View盖住会调用, 有需要请覆盖
function ArenaDialogBuyCounts:onHide()

end

-- 接收自定义消息
function ArenaDialogBuyCounts:reflashUI(data)
	--
	if string.find(data.desc,"[-]") then
        self._descLabel:setString("")
        local rtx = DialogUtils.createRtxLabel(data.desc,{width = 370} )
        rtx:setPixelNewline(true)
        rtx:formatText()
        rtx:setPosition(cc.p(self._descLabel:getPositionX()+10,self._descLabel:getPositionY()))
        self._descLabel:getParent():addChild(rtx,10)
    else
        self._descLabel:setString(data.desc)
    end
    
    if data.callBack1 then
        self._sureCallback = data.callBack1
    end
end

return ArenaDialogBuyCounts