local CrossGodWarServer = class("CrossGodWarServer", BaseServer)

function CrossGodWarServer:ctor(data)
	CrossGodWarServer.super.ctor( self, data )
	self._crossGodWarModel = self._modelMgr:getModel("CrossGodWarModel")
end


function CrossGodWarServer:onEnter(result, error)--进入获取数据
	if error and error~=0 then
		return
	end
	self._crossGodWarModel:setData(result)
	if result.formations then
		local formationModel = self._modelMgr:getModel("FormationModel")
		formationModel:updateAllFormationData(result.formations)
	end
	self:handleAboutServerData(result)
	self:callback(result)
end

function CrossGodWarServer:onGetBattleReport(result, error)--获取战斗数据，观看录像
	if error and error~=0 then
		return
	end
	self:handleAboutServerData(result)
	self:callback(result)
end

function CrossGodWarServer:onSignUp(result, error)--报名
	if error and error~=0 then
		return
	end
	self._crossGodWarModel:changeStateToSignUp(result.sRank)
	self:handleAboutServerData(result)
	self:callback(result)
end

function CrossGodWarServer:onGetFormationInfo( result, error )
	if error ~= 0 then
		return
	end
	if result.formations and result.dFId then
		self._crossGodWarModel:setUseFormationId(result.dFId)
		local formationModel = self._modelMgr:getModel("FormationModel")
	    formationModel:updateAllFormationData(result.formations)
		self:callback()
	end
end

function CrossGodWarServer:onGetFormationUseInfo( result, error )
	if error ~= 0 then
		return
	end
	self:callback(result.c)
end
-- 获取其他人的编组信息
function CrossGodWarServer:onGetThreeFormationInfoById( result, error )
	if error ~= 0 then
		return
	end
	self:callback(result)
end

function CrossGodWarServer:onGetGroupReportList(result, error)
	if error~=0 then
		return
	end
	self._crossGodWarModel:decodeGroupReportData(result)
	self:handleAboutServerData(result)
	self:callback(result)
end

function CrossGodWarServer:onGetGroupRival(result, error)
	if error~=0 then
		return
	end
	self._crossGodWarModel:setGroupRivalData(result)
	self:callback(result)
end

--获取下注信息
function CrossGodWarServer:onGetStakeInfo( result, error )
	if error ~= 0 then
		return
	end
	self:callback(result)
end

--下注
function CrossGodWarServer:onStakeFight( result, error )
	if error ~= 0 then
		return
	end
	self:callback(result)
end

--获取押注列表
function CrossGodWarServer:onGetStakeList( result, error )
	if error ~=0 then
		return
	end
	self:callback(result)
end

function CrossGodWarServer:onGetGroupBattleInfo(result, error)
	if error ~=0 then
		return
	end
	self:callback(result)
end

function CrossGodWarServer:onReceiveStakeRewards( result, error )
	if error ~= 0 then
		return
	end
	local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(result["d"])
	self:callback(result)
end

function CrossGodWarServer:onOnekeyReceiveStakeRewards( result, error )
	if error ~= 0 then
		return
	end
	local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(result["d"])
	self:callback(result)
end

function CrossGodWarServer:onGetElisBattleInfo(result, error)
	if error~=0 then
		return
	end
	local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(result["d"])
	self:callback(result)
end

function CrossGodWarServer:onGetWarBattleInfo(result, error)
	if error~=0 then
		return
	end
	self:handleAboutServerData(result)
	self:callback(result)
end

function CrossGodWarServer:onSelectFormation( result, error )
	if error~=0 then
		return
	end
	self:callback(result,error==0)
end

function CrossGodWarServer:onPushSighUp(result, error)
	if error~=0 then
		return
	end
	self._crossGodWarModel:reflashSignUp(result)
end	

function CrossGodWarServer:handleAboutServerData(result, reflash)
	
end

return CrossGodWarServer