--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-08-03 22:00:28
--
local TformationModel = class("TformationModel", BaseModel)

function TformationModel:ctor()
    TformationModel.super.ctor(self)
    self._data = {}
    self._skillTabMap = {
        tab.heroMastery,
        tab.playerSkillEffect,
        tab.skillPassive,
        tab.skillCharacter,
        tab.skillAttackEffect,
        tab.skill,
    }
    self._skill2ComMap = {}
    self._com2SkillMap = {}
end

function TformationModel:setData(data)
    self._data = data
    self:processData()
    dump(self._data,"tformationModel...setData")
    self:reflashData()
end

function TformationModel:processData( )
	local tempData = {}
	for k,v in pairs(self._data) do
		tempData[tonumber(k)] = v 
	end
	self._data = tempData
end

function TformationModel:getData()
    return self._data
end

function TformationModel:getTFormDataById(formId)
    return self._data[formId]
end

function TformationModel:updateData( inData )
	if not inData then return end
	dump(inData,"in Data ....")
	dump(self._data,"self.data...")
	for k,v in pairs(inData) do
		k = tonumber(k)
		if self._data[k] then
			if type(v) == "table" then
				for k1,v1 in pairs(v) do
					self._data[k][k1] = v1
				end
			else
				self._data[k] = v
			end
		else 
			self._data[k] = v
		end
	end
	dump(self._data,"self.data..after..")
	self:processData()
    self:reflashData()
end

-- 对外接口
function TformationModel:comId2skillId( comId )
	local skillId  =  self._skill2ComMap[comId] and self._skill2ComMap[comId].skillId 
	if not skillId then
		local treasureD = tab.comTreasure[comId]
		skillId = treasureD.addattr[1][2]
	    for k, v in pairs(self._skillTabMap) do
	        if v[skillId] and(v[skillId].art or v[skillId].icon) then
	            skillD = clone(v[skillId])
	            break
	        end
	    end
		self._skill2ComMap[comId]   = {skillId = skillId,skillD = skillD}
	end
    self._com2SkillMap[skillId] = comId
	local skillD = self._skill2ComMap[comId] and self._skill2ComMap[comId].skillD 
    return skillId,skillD
end

return TformationModel