--[[
 	@FileName 	GrowthWayModel.lua
	@Authors 	cuiyake
	@Date    	2018-05-23 16:25:58
	@Email    	<cuiyake@playcrad.com>
	@Description   成长之路
--]]
require ("game.view.activity.growthway.GrowthWayConst")

local GrowthWayModel = class("GrowthWayModel", BaseModel)

function GrowthWayModel:ctor()
	GrowthWayModel.super.ctor(self)
	self._vipModel = self._modelMgr:getModel("VipModel")
	self._awardStatus = false
	self:onInit()
end

function GrowthWayModel:onInit()
	self._data = {}
end

function GrowthWayModel:setData(inData)
	self._data = inData.data 
	--第一页
	local Y,M,D = self:getDate(self._data.createTime)
	local loginDays = self._data.loginDays or 1
	--第二页
	local heroCount = self._data.heroCount 
	local teamCount = self._data.teamCount
	local arenaHeroId = self._data.arenaHero
	local campId = nil
	local teamCamp = nil
	local campHeroName = nil
	if arenaHeroId and arenaHeroId ~= "" then
		campId = tab.hero[tonumber(arenaHeroId)]["masterytype"]
		teamCamp = GrowthWayConst.HeroCamp[campId][1]
		campHeroName = lang(tab.hero[tonumber(arenaHeroId)]["heroname"]) 
	end
	
	--第三页
	local costCoin = self._data.consumeCoin
	costCoin = tonumber(costCoin)
	if costCoin > 10000 then
		costCoin = math.floor(costCoin / 10000) .. "w"
	end
	local costTeamExp = self._data.consumeTeamExp
	costTeamExp = tonumber(costTeamExp)
	if costTeamExp > 10000 then
		costTeamExp = math.floor(costTeamExp / 10000) .. "w"
	end
	local costPower = self._data.consumePower
	costPower = tonumber(costPower)
	if costPower > 10000 then
		costPower = string.format("%0.2f",costPower / 10000) .. "w"
	end

	local vipName = self:getVipShowName()
	--第四页
	local crusadeCount = self._data.crusadeCount
	local arenaRank = self._data.arenaRank
	local arenaWins = self._data.arenaWins
	local championshipWins = self._data.championshipWins
	--第五页
	local fristRName = self._data.fristRName
	local fristGuild_Y,fristGuild_M,fristGuild_D = nil,nil,nil
	local fristJoinGuildName = nil
	if self._data.fristJoinGuildTime and self._data.fristJoinGuildTime ~= ""  then
		fristGuild_Y,fristGuild_M,fristGuild_D = self:getDate(self._data.fristJoinGuildTime)
		fristJoinGuildName = self._data.fristJoinGuildName
	end
	local frist15_Y,frist15_M,frist15_D = nil,nil,nil
	local frist15LvTeamId = nil
	local frist15LvTeamName = nil
	if self._data.frist15LvTeamTime and self._data.frist15LvTeamTime ~= "" then
		frist15_Y,frist15_M,frist15_D = self:getDate(self._data.frist15LvTeamTime) 
		frist15LvTeamId = self._data.frist15LvTeamId
		frist15LvTeamName = lang(tab.team[tonumber(frist15LvTeamId)]["name"])
	end
	
	--第六页
	local underCityId = self._data.underCityId
	local underSection = nil
    local underLevel = nil
	local underCount = nil
	if underCityId and underCityId ~= "" then
		underSection = tonumber(string.sub(underCityId, 3 , 5)) 
    	underLevel = tonumber(string.sub(underCityId, -2 , -1))
		underCount = tonumber(self._data.underCityCount)
	end
	
	local cloudCityId = self._data.cloudCityId
	local cloudSection,cloudLevel,cloudCityCount = nil,nil,nil
	if cloudCityId and cloudCityId ~= "" then
		cloudSection,cloudLevel = self:getFloorAndStageById(tonumber(cloudCityId))
		cloudCityCount = tonumber(self._data.cloudCityCount)
	end
	local planeId = self._data.planeId
	local planeName = nil
	local planeCount = nil
	if planeId and planeId ~= "" then
		planeName = GrowthWayConst.PlaneData[tonumber(planeId)]
		planeCount = tonumber(self._data.planeCount)
	end
	
	self._pageDataTab = {
		[1] = {Y,M,D,loginDays},
		[2] = {heroCount,teamCount,teamCamp,campHeroName},
		[3] = {costCoin,costTeamExp,costPower,vipName},
		[4] = {crusadeCount,arenaRank,arenaWins,championshipWins},
		[5] = {fristRName,fristGuild_Y,fristGuild_M,fristGuild_D,fristJoinGuildName,frist15_Y,frist15_M,frist15_D,frist15LvTeamName},
		[6] = {underSection,underLevel,underCount,cloudSection,cloudLevel,cloudCityCount,planeName,planeCount}
	}

end

function GrowthWayModel:getData()
	return self._data or {}
end

-- 根据总的阶ID获得对应层数和本层阶数
function GrowthWayModel:getFloorAndStageById(stageId)
    return tab:TowerStage(stageId).floor, stageId % 4 == 0 and 4 or stageId % 4
end

function GrowthWayModel:getVipShowName()
	local vipLevel = self._vipModel:getLevel()
	local vipShowName = ""
	if vipLevel <= 4 then
		vipShowName = GrowthWayConst.VIPStates[1]
	elseif vipLevel <= 9 then
		vipShowName = GrowthWayConst.VIPStates[2]
	elseif vipLevel <= 14 then
		vipShowName = GrowthWayConst.VIPStates[3]
	elseif vipLevel <= 15 then	
		vipShowName = GrowthWayConst.VIPStates[4]
	end
	return vipShowName
	
end
function GrowthWayModel:getDate(time)  
   	local Y = os.date("%Y",time)
	local M = os.date("%m",time)
	local D = os.date("%d",time)

    return Y,M,D
end  
function GrowthWayModel:getPageDataByIndex(index)
	local desText = nil
	if self["getPageData" .. index] then
		desText	= self["getPageData" .. index](self)
	end	

   	return desText
end

function GrowthWayModel:getPageData1()
	local desText = lang("growthwaypage_1_1")
	desText = string.gsub(desText, "{$year}", self._pageDataTab[1][1])
	desText = string.gsub(desText, "{$month}", self._pageDataTab[1][2])
	desText = string.gsub(desText, "{$day}", self._pageDataTab[1][3])
	desText = string.gsub(desText, "{$logindays}", self._pageDataTab[1][4])	

	return desText		
end

function GrowthWayModel:getPageData2()
	local desText = ""
	local desText1 = lang("growthwaypage_2_1")
	local desText2 = lang("growthwaypage_2_2")
	local desText3 = lang("growthwaypage_2_3")
	local desText4 =  lang("growthwaypage_2_4")
	local desText5 = lang("growthwaypage_2_5")
	desText = desText .. desText1
	if self._pageDataTab[2][1] and self._pageDataTab[2][1] ~= "" then
		local tempDes = string.gsub(desText2, "{$heroCount}", self._pageDataTab[2][1])
		desText = desText .. tempDes
	end

	if self._pageDataTab[2][2] and self._pageDataTab[2][2] ~= "" then
		local tempDes = string.gsub(desText3, "{$teamCount}", self._pageDataTab[2][2])
		desText = desText .. tempDes
	end
	
	if self._pageDataTab[2][3] and self._pageDataTab[2][3] ~= "" then
		local tempDes = string.gsub(desText4, "{$teamCamp}", self._pageDataTab[2][3])
		desText = desText .. tempDes
	end

	if self._pageDataTab[2][4] and self._pageDataTab[2][4] ~= "" then
		local tempDes = string.gsub(desText5, "{$arenaHero}", self._pageDataTab[2][4])
		desText = desText .. tempDes
	end

	return desText		
end

function GrowthWayModel:getPageData3()
	local desText = ""
	local desText1 = lang("growthwaypage_3_1")
	local desText2 = lang("growthwaypage_3_2")
	local desText3 = lang("growthwaypage_3_3")
	desText = desText .. desText1
	local tempDes1 = string.gsub(desText2, "{$consumeCoin}", self._pageDataTab[3][1])
	local tempDes2 = string.gsub(tempDes1, "{$consumeTeamExp}", self._pageDataTab[3][2])
	local tempDes3 = string.gsub(tempDes2, "{$consumePower}", self._pageDataTab[3][3])
	desText = desText .. tempDes3
	local tempDes4 = string.gsub(desText3, "{$VipLevel}", self._pageDataTab[3][4])
	desText = desText .. tempDes4

	return desText		
end

function GrowthWayModel:getPageData4()
	local desText = ""
	local desText1 = lang("growthwaypage_4_1")
	local desText2 = lang("growthwaypage_4_2")
	local desText3 = lang("growthwaypage_4_3")
	local desText4 = lang("growthwaypage_4_4")
	local desText5 = lang("growthwaypage_4_5")
	local desText6 = lang("growthwaypage_4_6")
	desText = desText .. desText1
	if self._pageDataTab[4][1] and self._pageDataTab[4][1] ~= "" then
		local tempDes = string.gsub(desText2, "{$crusadeCount}", self._pageDataTab[4][1])
		desText = desText .. tempDes
	end

	if self._pageDataTab[4][2] and self._pageDataTab[4][2] ~= "" then
		local tempDes = string.gsub(desText3, "{$arenaRank}", self._pageDataTab[4][2])
		desText = desText .. tempDes
	end

	if self._pageDataTab[4][3] and self._pageDataTab[4][3] ~= "" then
		local tempDes = string.gsub(desText4, "{$arenaWins}", self._pageDataTab[4][3])
		desText = desText .. tempDes
	end

	if self._pageDataTab[4][4] and self._pageDataTab[4][4] ~= "" then
		local tempDes = string.gsub(desText5, "{$championshipWins}", self._pageDataTab[4][4])
		desText = desText .. tempDes
	end

	desText = desText .. desText6
	return desText		
end

function GrowthWayModel:getPageData5()
	local desText = ""
	local desText1 = lang("growthwaypage_5_1")
	local desText2 = lang("growthwaypage_5_2")
	local desText3 = lang("growthwaypage_5_3")
	local desText4 = lang("growthwaypage_5_4")
	desText = desText .. desText1
	if self._pageDataTab[5][1] and self._pageDataTab[5][1] ~= "" then
		local tempDes = string.gsub(desText2, "{$fristRName}", self._pageDataTab[5][1])
		desText = desText .. tempDes
	end
	if self._pageDataTab[5][2] and self._pageDataTab[5][2] ~= "" then
		local tempDes1 = string.gsub(desText3, "{$year}", self._pageDataTab[5][2])
		local tempDes2 = string.gsub(tempDes1, "{$month}", self._pageDataTab[5][3])
		local tempDes3 = string.gsub(tempDes2, "{$day}", self._pageDataTab[5][4])
		local tempDes4 = string.gsub(tempDes3, "{$fristJoinGuildName}", self._pageDataTab[5][5])
		desText = desText .. tempDes4
	end
	if self._pageDataTab[5][6] and self._pageDataTab[5][6] ~= "" then
		local tempDes1 = string.gsub(desText4, "{$year}", self._pageDataTab[5][6])
		local tempDes2 = string.gsub(tempDes1, "{$month}", self._pageDataTab[5][7])
		local tempDes3 = string.gsub(tempDes2, "{$day}", self._pageDataTab[5][8])
		local tempDes4 = string.gsub(tempDes3, "{$frist15LvTeamId}", self._pageDataTab[5][9])
		desText = desText .. tempDes4
	end

	return desText		
end

function GrowthWayModel:getPageData6()
	local desText = ""
	local desText1 = lang("growthwaypage_6_1")
	local desText2 = lang("growthwaypage_6_2")
	local desText3 = lang("growthwaypage_6_3")
	local desText4 = lang("growthwaypage_6_4")

	if self._pageDataTab[6][1] and self._pageDataTab[6][3] >= 5 then
		local tempDes1 = string.gsub(desText1, "{$chapter}", self._pageDataTab[6][1])
		local tempDes2 = string.gsub(tempDes1, "{$underCityId}", self._pageDataTab[6][2])
		local tempDes3 = string.gsub(tempDes2, "{$underCityCount}", self._pageDataTab[6][3])
		desText = desText .. tempDes3
	end

	if self._pageDataTab[6][4] and self._pageDataTab[6][6] >= 5 then
		local tempDes1 = string.gsub(desText2, "{$layer}", self._pageDataTab[6][4])
		local tempDes2 = string.gsub(tempDes1, "{$cloudCityId}", self._pageDataTab[6][5])
		local tempDes3 = string.gsub(tempDes2, "{$cloudCityCount}", self._pageDataTab[6][6])
		desText = desText .. tempDes3
	end

	if self._pageDataTab[6][7] and self._pageDataTab[6][8] >= 5 then
		local tempDes1 = string.gsub(desText3, "{$planeId}", self._pageDataTab[6][7])
		local tempDes2 = string.gsub(tempDes1, "{$planeCount}", self._pageDataTab[6][8])
		desText = desText .. tempDes2
	end
	desText  = desText .. desText4

	return desText		
end

function GrowthWayModel:getPageData7()
	local desText = lang("growthwaypage_7_1")
	return desText		
end

function GrowthWayModel:getShareData()
	local userInfo = self._modelMgr:getModel("UserModel"):getData()
	local name = userInfo.name
    if name == "" then
        name = self._modelMgr:getModel("UserModel"):getUID()
    end
    local desText = ""
	local desText1 = lang("growthwaypage_8_1")
	local tempDes1 = string.gsub(desText1, "{$vRoleName}", name)
	local tempDes2 = string.gsub(tempDes1, "{$logindays}", self._data.loginDays)
	local tempDes3 = string.gsub(tempDes2, "{$heroCount}", self._data.heroCount )
	local tempDes4 = string.gsub(tempDes3, "{$teamCount}", self._data.teamCount)
	local tempDes5 = string.gsub(tempDes4, "{$arenaRank}", self._data.arenaRank or 5)

	desText = desText .. tempDes5

	return desText		
end

function GrowthWayModel:isHaveRedPoint()
	return self._awardStatus
end

function GrowthWayModel:setAwardStatus(state)
	self._awardStatus = state
end

function GrowthWayModel:getAwardStatus()
	return self._awardStatus
end

function GrowthWayModel:setAwardData(data)
	if data == nil then return end
    -- data 为 0 或 1 (0代表未领取 1代表领取)
    self._awardStatus = tonumber(data) == 1 and true or false
end

return GrowthWayModel