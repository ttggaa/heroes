--[[
    Filename:    MailServer.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2015-07-18 16:00:29
    Description: File description
--]]

local MailServer = class("MailServer",BaseServer)

function MailServer:ctor(data)
    MailServer.super.ctor(self,data)
    self._mailBoxModel = self._modelMgr:getModel("MailBoxModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._userModel = self._modelMgr:getModel("UserModel")
end


--获取邮件信息
function MailServer:onGetMails( result, error)
	if error ~= 0 then 
		return
	end
    print("清楚数据")
	local oldNum = table.nums(self._mailBoxModel:getData())
    local newNum = table.nums(result)
    if oldNum ~= newNum then 
	    self._mailBoxModel:setData(result)
	end
	self:callback(result)
end

-- 读邮件
function MailServer:onReadMail( result, error)
	if error ~= 0 then 
		print("error ....",error)
		return
	end
	self:callback(result)
end

--领取附件
function MailServer:onGetAttachment( result, error) 
    print("获取附件信息")
    -- dump(result)
    -- PCLuaLogDump("MailServer", result, "self._data")
	if error ~= 0 then 
		return
	end

    if result["d"] ~= nil then 
        if result["d"]["items"] then
            self._itemModel:updateItems(result["d"]["items"])
            result["d"]["items"] = nil
        end
        if result["d"]["vip"] then
            self._modelMgr:getModel("VipModel"):updateData(result["d"]["vip"])
            result["d"]["vip"] = nil
        end
        if result["d"]["activity"] then
            self._modelMgr:getModel("ActivityModel"):updateSpecialData(result["d"]["activity"])
            result["d"]["activity"] = nil
        end

        if result["d"]["sRcg"] then
            self._modelMgr:getModel("ActivityModel"):updateSingleRechargeData(result, true)
            result["d"]["sRcg"] = nil
        end

        if result["d"]["intelligentRecharge"] then
            self._modelMgr:getModel("ActivityModel"):updateIntRechargeData(result, true)
            result["d"]["intelligentRecharge"] = nil
        end

        if result["d"]["teams"] then
            local teamModel = self._modelMgr:getModel("TeamModel")
            teamModel:updateTeamData(result["d"]["teams"])
            result["d"]["teams"] = nil
        end

        if result["d"]["heros"] then
            local heroModel = self._modelMgr:getModel("HeroModel")
            heroModel:unlockHero(result["d"]["heros"])
            result["d"]["heros"] = nil
        end

    	self._userModel:updateUserData(result["d"])
    end
	self:callback(result)
    print("************")
end

function MailServer:onNewMail( result, error)
    if error ~= 0 then 
        -- self._viewMgr:showTip("获取新邮件失败" .. error)
        return
    end
    print("****************")
    print("更新邮箱数据")
    dump(result)
    self._mailBoxModel:addData(result)
    self._modelMgr:getModel("MainViewModel"):reflashMainView()
    print("查看邮件内容")
end


--删除邮件
-- function MailServer:onDelMail( result, error)
--  if error ~= 0 then 
--         print("error ....",error)
--      return
--  end
--     print("删邮件",result)
--  dump(result)
--  self:callback(result)
-- end

return MailServer
