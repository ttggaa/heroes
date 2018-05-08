--
-- Author: huachangmiao@playcrab.com
-- Date: 2016-07-26 19:08:57
--
local GlobalModel = class("GlobalModel", BaseModel)

function GlobalModel:ctor()
    GlobalModel.super.ctor(self)
    self._data = {}

end

function GlobalModel:setData(data)
	if data == nil then 
		return
	end
    self._data = data

    self._surpriseList = {}
    local surpriseStr = self._data["surpriseList"]
    for i = 1, #surpriseStr do
    	self._surpriseList[i] = tonumber(string.sub(surpriseStr, i, i))
    end
end

function GlobalModel:getSurpriseList()
	return self._surpriseList
end

return GlobalModel