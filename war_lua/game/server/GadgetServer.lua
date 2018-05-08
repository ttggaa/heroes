--
-- Author: <ligen@playcrab.com>
-- Date: 2017-12-13 20:54:44
--
local GadgetServer = class("GadgetServer", BaseServer)

function GadgetServer:ctor()
    GadgetServer.super.ctor(self)
end

function GadgetServer:onExchange(result, error)
	if error ~= 0 then 
		return
	end

    -- 更新用户数据
    self._modelMgr:getModel("UserModel"):updateUserData(result["d"])

    if result["d"] and result["d"]["items"] ~= nil then 
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(result["d"]["items"])
        result["d"]["items"] = nil
    end
	self:callback(result)
end

--function GadgetServer:onShowDialog(result, error)
--	if error ~= 0 then 
--		return
--	end
--    self._modelMgr:getModel("MainViewModel"):addGadget(1)
--	self:callback(result)
--end
return GadgetServer