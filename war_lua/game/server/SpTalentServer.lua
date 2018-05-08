--[[
    Filename:    SpTalentServer.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2017-12-11 18:54:41
    Description: File description
--]]


local SpTalentServer = class("SpTalentServer",BaseServer)

function SpTalentServer:ctor(data)
    SpTalentServer.super.ctor(self,data)
    self._userModel = self._modelMgr:getModel("UserModel")
    self._skillTalentModel = self._modelMgr:getModel("SkillTalentModel")
end

--[[
   天赋激活
]]
function SpTalentServer:onActiveSpTalent( result, error)
	-- dump(result , "SpTalentServer:onActiveSpTalent", 10)
	if error ~= 0 then 
		return
	end
	if result["d"] then
		if result["d"]["spTalent"] then
			self._skillTalentModel:updateData(result["d"]["spTalent"])
		end
		self._userModel:updateUserData(result["d"])
	end
	self:callback(result)
end

--[[
	天赋升级
]]
function SpTalentServer:onUpSpTalent( result, error)
	-- dump(result , "SpTalentServer:onUpSpTalent", 10)
	if error ~= 0 then 
		return
	end
	
	if result["d"] then
		if result["d"]["spTalent"] then
			self._skillTalentModel:updateData(result["d"]["spTalent"])
		end
		self._userModel:updateUserData(result["d"])
	end
	self:callback(result)
end

--一元购推送接口

function SpTalentServer:onPushOneCash(result,error)
	if error ~= 0 then
		return
	end
	dump(result)

	--更新vip
	local old_vip = self._vipModel:getLevel()
    local vip = result["d"].vip
    if vip and vip.level and old_vip then
        if vip.level > old_vip then
            ApiUtils.playcrab_monitor_vip_upgrade(old_vip, vip.level)
        end
    end
    self._vipModel:updateData(result["d"].vip)

	if result["d"] then
		self._directShopModel:setOneCashResult(result)
		self._itemModel:updateItems(result["d"]["items"])
		result["d"]["items"] = nil
		self._userModel:updateUserData(result["d"])
		self:callback(result)
	end
end

return SpTalentServer