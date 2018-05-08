--[[
    Filename:    ChallengeModel.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-07-14 17:59:30
    Description: File description
--]]

local ChallengeModel = class("ChallengeModel", BaseModel)

function ChallengeModel:ctor()
    ChallengeModel.super.ctor(self)
end

function ChallengeModel:getData()
    return self._data
end
 
-- 子类覆盖此方法来存储数据
function ChallengeModel:setData(data)

end


function ChallengeModel:updateData(inChallengesData)
    if inChallengesData ~= nil and 
        inChallengesData["challStages"] ~= nil then
        for k,v in pairs(inChallengesData["challStages"]) do
            local tmpChallenge = {}
            tmpChallenge.id = k
            tmpChallenge.expireTime = v.expireTime
            tmpChallenge.conditionId = v.conditionId
            table.insert(self._data, tmpChallenge)
        end
    end
    self:reflashData()
end
return ChallengeModel