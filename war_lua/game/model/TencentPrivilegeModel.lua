--
-- Author: <ligen@playcrab.com>
-- Date: 2017-03-31 20:36:45
--
local TencentPrivilegeModel = class("TencentPrivilegeModel", BaseModel)

TencentPrivilegeModel.WX_GAME_CENTER = "wx_gamecenter";
TencentPrivilegeModel.QQ_GAME_CENTER = "sq_gamecenter";
TencentPrivilegeModel.IS_QQ_VIP = "is_qq_vip";
TencentPrivilegeModel.IS_QQ_SVIP = "is_qq_svip";

function TencentPrivilegeModel:ctor()
    TencentPrivilegeModel.super.ctor(self)

    self._data = {}
end

function TencentPrivilegeModel:setData(data)
    self._data = data or {}
    self:reflashData()
end

-- 获取QQvip类型
function TencentPrivilegeModel:getQQVip()
    if self:isOpenPrivilege() then
        return self._data.qqVip
    else
        return nil
    end
end

-- 获取腾讯特权
function TencentPrivilegeModel:getTencentTeQuan()
    if self:isOpenPrivilege() then
        return self._data.tequan
    else
        return nil
    end
end

-- 是否开启腾讯特权
function TencentPrivilegeModel:isOpenPrivilege()
    if GameStatic.appleExamine then
        return false
    else
        return tab:Setting("VIP_PRIV").value == 1
    end
end

-- 获取腾讯特权相关 H5
function TencentPrivilegeModel:getPrivilegeUrl()
    local userModel = self._modelMgr:getModel("UserModel")
    print(GameStatic.qqPrivilegeUrl.. string.format("sRoleId=%s&sPartition=%s&Pfkey=%s", tostring(userModel:getUSID()), tostring(GameStatic.sec), tostring(userModel:getPFKey())))
    return GameStatic.qqPrivilegeUrl.. string.format("sRoleId=%s&sPartition=%s&Pfkey=%s", tostring(userModel:getUSID()), tostring(GameStatic.sec), tostring(userModel:getPFKey()))
end

-- 判断主界面QQ特权是否显示红点
function TencentPrivilegeModel:isQQPrivilegeTip()  
    local userModel = self._modelMgr:getModel("UserModel")
    local curServerTime = userModel:getCurServerTime()
    local timeDate
    local tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
    if curServerTime > tempCurDayTime then
        timeDate = TimeUtils.getDateString(curServerTime,"%Y%m%d")
    else
        timeDate = TimeUtils.getDateString(curServerTime - 86400,"%Y%m%d")
    end
    local tempdate = SystemUtils.loadAccountLocalData("QQVIP_HAD_CLICKED")
    if tempdate ~= timeDate then
        print("QQVIP_HAD_CLICKED", timeDate)
        return true
    end
    return false
end

-- 保存主界面QQ特权已点击（每日重置）
function TencentPrivilegeModel:setHideQQPrivilegeTip()  
    local userModel = self._modelMgr:getModel("UserModel")
    local curServerTime = userModel:getCurServerTime()
    local timeDate
    local tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
    if curServerTime > tempCurDayTime then
        timeDate = TimeUtils.getDateString(curServerTime,"%Y%m%d")
    else
        timeDate = TimeUtils.getDateString(curServerTime - 86400,"%Y%m%d")
    end
    local tempdate = SystemUtils.loadAccountLocalData("QQVIP_HAD_CLICKED")
    if tempdate ~= timeDate then
        print("QQVIP_HAD_CLICKED", timeDate)
        SystemUtils.saveAccountLocalData("QQVIP_HAD_CLICKED", timeDate)
        return true
    end
    return false
end
return TencentPrivilegeModel