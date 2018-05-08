--[[
    Filename:    FriendPhyTipView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-01-04 10:57
    Description: 平台好友赠送体力
--]]

local FriendPhyTipView = class("FriendPhyTipView", BasePopView)

function FriendPhyTipView:ctor(param)
	self.super.ctor(self)
	self._data = param
end

function FriendPhyTipView:onInit()
	local title = self:getUI("bg.Image_2.Label_3")
	UIUtils:setTitleFormat(title, 6)

	self:registerClickEventByName("bg.closeBtn", function()
 		self:close()
		end)

	self:registerClickEventByName("bg.nextBtn", function()
 		self:close()
		end)

	self:registerClickEventByName("bg.noticeBtn", function()
        local tipDes = ""
        if sdkMgr:isQQ() then
            tipDes = lang("QQ_FRIENDTIPS")
        elseif sdkMgr:isWX() then
            tipDes = lang("WEIXIN_FRIENDTIPS")
        elseif OS_IS_WINDOWS then
            tipDes = "当前是pc端，查看提示用手机~"
        end
        self:setVisible(false)
        self._viewMgr:showDialog("global.GlobalSelectDialog",
            {desc = tipDes,
            button1 = "确定",
            button2 = "取消", 
            callback1 = function ()
                local param = {}
                param.fopenid = self._data["openid"]
                param.title = lang("FRIEND_GIVE_1")
                param.desc = lang("FRIEND_GIVE_2")
                param.media_tag = sdkMgr.SHARE_TAG.MSG_HEART_SEND
                -- param.path = "/storage/emulated/0/Android/data/com.tencent.tmgp.yxwdzzjy/share.png"
                sdkMgr:sendToPlatformFriend(param, function(code, data) end)
                self._viewMgr:showTip(lang("SUC_FRIENDTIPS"))
                self:close()
            end,
            callback2 = function()
                
            end})
		end)
end

return FriendPhyTipView