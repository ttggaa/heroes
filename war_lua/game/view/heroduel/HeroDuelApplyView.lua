--
-- Author: <ligen@playcrab.com>
-- Date: 2017-01-24 15:32:53
--
local HeroDuelApplyView = class("HeroDuelApplyView", BasePopView)
function HeroDuelApplyView:ctor(data)
    HeroDuelApplyView.super.ctor(self)

    self._enterCallBack = data.callBack
end

function HeroDuelApplyView:onInit()
    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 6)
    title:setString("报名成功")

    self:registerClickEventByName("bg.goBtn", function()
        self:onGoBtn()
    end )

    local descLabel = self:getUI("bg.descLabel")
    descLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    descLabel:setString("快去打造您的无敌队伍吧！")
end

function HeroDuelApplyView:onGoBtn()
    self._serverMgr:sendMsg("HeroDuelServer", "hDuelGetSelectInfo", {}, true, {}, function(result)
        self._enterCallBack(result)
        self:close()
        UIUtils:reloadLuaFile("heroduel.HeroDuelApplyView")
    end)
end

return HeroDuelApplyView