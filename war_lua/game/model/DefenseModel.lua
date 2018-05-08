--[[
    Filename:    DefenseModel.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-09-09 17:45:56
    Description: File description
--]]

-- defenseInfo{
--     'mlv' => core_Schema::NUM, // 主城等级
--     'wlv' => core_Schema::NUM, // 城防等级
--     'rlv' => core_Schema::NUM, // 护城河等级
--     'cIds' => 'AutoFieldsNum', // 解锁城池ID列表
--     'curId' => core_Schema::NUM, // 当前城池ID
--     'teamId1'=> core_Schema::NUM, // 箭塔1兵团
--     'teamId2'=> core_Schema::NUM, // 箭塔2兵团
-- }

local DefenseModel = class("DefenseModel", BaseModel)

function DefenseModel:ctor()
    DefenseModel.super.ctor(self)
end

function DefenseModel:getData()
    return self._data
end
 
-- 子类覆盖此方法来存储数据
function DefenseModel:setData(data)
    dump(data, "6666666========", 10)
    self._data = data
    self:reflashData()

end

function DefenseModel:updateDefenseData(data)
    dump(data, "6666666========", 10)
    for k,v in pairs(data) do
        self._data[k] = v
    end
end

return DefenseModel