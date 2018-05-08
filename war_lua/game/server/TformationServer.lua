--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-08-03 21:06:55
--

local TformationServer = class("TformationServer",BaseServer)

function TformationServer:ctor(data)
    TformationServer.super.ctor(self,data)
    self._tFModel = self._modelMgr:getModel("TformationModel")
end

-- 获取玩家拥有的宝物阵型
function TformationServer:onGetFormation( result, error)
	if error ~= 0 then 
		return
	end
	dump(result,"TfSeerver...==========",10)
	self._tFModel:setData(result)
	self:callback(result)
end

-- 开启编组
function TformationServer:onOpenFormation( result, error)
	if error ~= 0 then 
		return
	end
	dump(result,"TfSeerver...==========",10)
	self:handleResult(result)
	self:callback(result)
end

-- 设置阵型
function TformationServer:onSetFormation( result, error)
	if error ~= 0 then 
		return
	end
	dump(result,"TfSeerver...==========",10)
	self:handleResult(result)
	self:callback(result)
end

-- 改名
function TformationServer:onChangeFormationName( result, error)
	if error ~= 0 then 
		return
	end
	dump(result,"TfSeerver...==========",10)
	self:handleResult(result)
	self:callback(result)
end

-- 移除阵型上的宝物
function TformationServer:onRemoveFormation( result, error)
	if error ~= 0 then 
		return
	end
	dump(result,"TfSeerver...==========",10)
	self:handleResult(result)
	self:callback(result)
end

function TformationServer:handleResult( result )
	if result and result.d and result.d.tformations then
		self._tFModel:updateData( result.d.tformations )
	end
	if result.d then
		local userModel = self._modelMgr:getModel("UserModel")
		userModel:updateUserData(result.d)
	end
	if result["unset"] then
		local itemModel = self._modelMgr:getModel("ItemModel")
		local removeItems = itemModel:handelUnsetItems(result["unset"])
        itemModel:delItems(removeItems, true)
	end
end

return TformationServer