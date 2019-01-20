--
-- Author: <ligen@playcrab.com>
-- Date: 2017-09-20 18:37:31
-- Description: 未开启功能协议
--
local ExtraServer = class("ExtraServer",BaseServer)

function ExtraServer:ctor(data)
    ExtraServer.super.ctor(self,data)
end


-- 获取攻城战数据
function ExtraServer:onGetSiegeInfo(result, error)
    if error ~= 0 then 
		return
	end

    if result then
        -- dump(result)
        if result["d"] ~= nil and result["d"]["formations"] ~= nil then
            local formationModel = self._modelMgr:getModel("FormationModel")
            formationModel:updateAllFormationData(result["d"]["formations"])
        end
        self._modelMgr:getModel("SiegeModel"):setData(result)
    end
	self:callback(result)
end
return ExtraServer