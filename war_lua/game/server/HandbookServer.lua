--
-- Author: <ligen@playcrab.com>
-- Date: 2017-04-13 10:36:05
--
local HandbookServer = class("HandbookServer", BaseServer)

function HandbookServer:ctor()
    HandbookServer.super.ctor(self)

    self._hModel = self._modelMgr:getModel("HandbookModel")
end

function HandbookServer:onGetAllTaskInfo(result, error)
    if error ~= 0 then 
		return
	end
--    dump(result, nil, 10)
    self._hModel:setData(result)
	self:callback(result)
end

function HandbookServer:onGetTaskAward(result, error)
    if error ~= 0 then 
		return
	end

    if result["d"] ~= nil then
        if result["d"]["items"] ~= nil then 
            local itemModel = self._modelMgr:getModel("ItemModel")
            itemModel:updateItems(result["d"]["items"])
            result["d"]["items"] = nil
        end
        -- 更新用户数据
        local userModel = self._modelMgr:getModel("UserModel")
        userModel:updateUserData(result["d"])

        self._hModel:updateData(result["d"]["handbooks"])
    end

	self:callback(result)
end
return HandbookServer