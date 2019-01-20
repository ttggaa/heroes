--[[
 	@FileName 	ParagonModel.lua
	@Authors 	yuxiaojing
	@Date    	2018-09-21 17:21:15
	@Email    	<yuxiaojing@playcrab.com>
	@Description   描述
--]]

--[[

	{"pTalents":
		{
			"1001":{"lv":1},
			"2001":{"lv":1},
			"3001":{"lv":1},
			"4101":{"lv":1},
			"4201":{"lv":1},
			"4301":{"lv":1}
		}
	}

--]]

local ParagonModel = class("ParagonModel", BaseModel)

function ParagonModel:ctor(  )
	ParagonModel.super.ctor(self)

	self._itemModel = self._modelMgr:getModel("ItemModel")
	self._userModel = self._modelMgr:getModel("UserModel")

	self._data = {}
end

function ParagonModel:setData(inData)
	self._data = inData
end

function ParagonModel:getData(  )
	return clone(self._data)
end

function ParagonModel:updateData(inData)
	local function updateSubData(inSubData, inUpData)
        if type(inSubData) == "table" then
            for k,v in pairs(inUpData) do
                local backData = updateSubData(inSubData[k], v)
                inSubData[k] = backData
            end
            return inSubData
        else 
            return inUpData
        end
    end

    for k,v in pairs(inData) do
        local backData = updateSubData(self._data[k], v)
        self._data[k] = backData
    end
end

function ParagonModel:getParagonTalentData( talentId )
	local pData = self:getData()
	return pData[tostring(talentId)] or {}
end

function ParagonModel:checkWarReadinessRedPoint()
	local curTalent = self._userModel:getData().pTalentPoint or 0
	local isCanUp = self:checkIsCanUpdate()
	if curTalent >= tab.setting["PARAGON_TALENT_RED_POINT"].value and isCanUp then
		return true
	end
	return false
end

function ParagonModel:checkIsCanUpdate()
	local sysTree = tab.paragonTalentTree
	local sysTalent = tab.paragonTalent
	for k,v in pairs(sysTree) do
		for m,n in ipairs(v["talent"]) do
			for p,q in ipairs(n) do
				local curData = self._data[tostring(q)]
				local maxLv = #(sysTalent[tonumber(q)]["costTalentPoint"])
				if curData and curData["lv"] < maxLv then
					return true
				end
			end
		end
	end

	return false
end

return ParagonModel