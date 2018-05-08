--
-- Author: <ligen@playcrab.com>
-- Date: 2017-04-05 20:53:31
--
local TencentPrivilegeView = class("TencentPrivilegeView", BasePopView)

function TencentPrivilegeView:ctor(data)
    TencentPrivilegeView.super.ctor(self)
end

function TencentPrivilegeView:getAsyncRes()
    return
    {
        { "asset/ui/tencentPrivilege.plist", "asset/ui/tencentPrivilege.png" }
    }
end

function TencentPrivilegeView:onInit()
    self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
        UIUtils:reloadLuaFile("tencentprivilege.TencentPrivilegeView")
    end)

    local title = self:getUI("bg.title")
    UIUtils:setTitleFormat(title, 1)

    if sdkMgr:isQQ() or OS_IS_WINDOWS then

        title:setString("QQ游戏中心启动特权")
        self:initQQ()
    elseif sdkMgr:isWX() then
    
        title:setString("微信游戏中心启动特权")
        self:initWX()
    end
end

function TencentPrivilegeView:initQQ()
    local qqNode = self:getUI("bg.qqNode")
    qqNode:setVisible(true)
    self:getUI("bg.wxNode"):setVisible(false)

    self:formatLabel(qqNode:getChildByFullName("label1"),"外显尊贵身份")
    self:formatLabel(qqNode:getChildByFullName("label2"),"连续登陆礼包")
    self:formatLabel(qqNode:getChildByFullName("label3"),"单局结算金币+5%")

    self:formatLabel(qqNode:getChildByFullName("labelDes1"),"启动路径：打开手Q按图示操作")
    self:formatLabel(qqNode:getChildByFullName("labelDes2"),"需直接从游戏中心启动，启动后仅当日有效")
end

function TencentPrivilegeView:initWX()
    local wxNode = self:getUI("bg.wxNode")
    wxNode:setVisible(true)
    self:getUI("bg.qqNode"):setVisible(false)

    self:formatLabel(wxNode:getChildByFullName("pNode.label1"),"外显特权")
    self:formatLabel(wxNode:getChildByFullName("pNode.label2"),"每日登陆礼包")
    self:formatLabel(wxNode:getChildByFullName("pNode.label3"),"金币+5%")

    self:formatLabel(wxNode:getChildByFullName("labelDes1"),"启动路径：打开微信按图示操作")
    self:formatLabel(wxNode:getChildByFullName("labelDes2"),"启动特权")
    self:formatLabel(wxNode:getChildByFullName("labelDes3"),"仅当日有效，仅限微信6.5.6及以上版本享受启动特权")
end

function TencentPrivilegeView:formatLabel(label, str)
    label:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    label:setString(str)
end

return TencentPrivilegeView