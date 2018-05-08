--[[
    Filename:    CommentModel.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-01-16 19:47:20
    Description: File description
--]]


local CommentModel = class("CommentModel", BaseModel)

function CommentModel:ctor()
    CommentModel.super.ctor(self)
    self._userModel = self._modelMgr:getModel("UserModel")
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._teamComment = {}
    self._teamCommentDetail = {}

    self._typeList = {}
    self._typeDetailList = {}
end

function CommentModel:getData()
    return self._data
end

function CommentModel:setData(data)
    self._data = data
end

function CommentModel:setTeamData(data)
    self._teamComment = {}
    local cList = data["cList"]
    local hList = data["hList"]
    self:progressData(hList, cList)
    self._teamCommentDetail = data
 end

 function CommentModel:setTypeData(data)
    self._typeList[data.type] = {}

    local cList = data["cList"]
    local hList = data["hList"]
    if not hList then
        hList = {}
    end
    if not cList then
        cList = {}
    end
    for i=1,table.nums(hList) do
        local indexId = i
        self._typeList[data.type][indexId] = hList[i]
    end
    local num = table.nums(hList)
    for i=1,table.nums(cList) do
        local indexId = i+num
        self._typeList[data.type][indexId] = cList[i]
    end
    self._typeDetailList[data.type] = data
 end

function CommentModel:getDetailDataByType(type)
    return self._typeDetailList[type]
end

function CommentModel:getDataByType(type)
    return self._typeList[type]
end

function CommentModel:progressData(hList, cList)
    if not hList then
        hList = {}
    end
    if not cList then
        cList = {}
    end
    
    for i=1,table.nums(hList) do
        local indexId = i
        self._teamComment[indexId] = hList[i]
    end
    for i=1,table.nums(cList) do
        local indexId = i+table.nums(hList)
        self._teamComment[indexId] = cList[i]
    end

    -- -- 数据处理备用
    -- local hListT = {}
    -- local hCount = 1
    -- for k,v in pairs(hList) do
    --     hListT[tonumber(k)] = v
    -- end
    -- for k,v in pairs(hListT) do
    --     self._teamComment[hCount] = v
    --     hCount = hCount + 1
    -- end
    -- local cListT = {}
    -- local cCount = table.nums(hListT)+1
    -- for k,v in pairs(cList) do
    --     cListT[tonumber(k)] = v
    -- end
    -- for k,v in pairs(cListT) do
    --     self._teamComment[cCount] = v
    --     cCount = cCount + 1
    -- end
end

function CommentModel:getTeamDetailData()
    return self._teamCommentDetail
end

function CommentModel:getTeamData()
    return self._teamComment
end

return CommentModel