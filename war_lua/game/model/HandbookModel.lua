--
-- Author: <ligen@playcrab.com>
-- Date: 2017-04-13 10:47:29
--
local HandbookModel = class("HandbookModel", BaseModel)
function HandbookModel:ctor()
    HandbookModel.super.ctor(self) 

    self._data = {}

    self._gpTab = nil

    self._userModel = self._modelMgr:getModel("UserModel")

    self:listenGlobalResponse(specialize(self.onCarry, self))
end

function HandbookModel:getHasCeche()
    if not self._hasCeche then
        self._hasCeche = true
        return false
    end
    return true
end

function HandbookModel:setData(data)
    if type(data) ~= "table" then
        dump("此处需传入table")
        return
    end

    self._hasCeche = true
    self._data = data
end

function HandbookModel:getData()
    return self._data
end

-- 更新数据
function HandbookModel:updateData(data)
--    for k, v in pairs(data) do
--        self._data[k].status = v
--    end
    if data and type(data) == "table" then
        local function mergeDataFun(newData, oldData)
            for k, v in pairs(newData) do
                if oldData[k] == nil then
                    oldData[k] = v
                elseif type(v) == "table" then
                    mergeDataFun(v, oldData[k])
                else
                    oldData[k] = v
                end
            end
        end
        mergeDataFun(data, self._data)
    end

    self:reflashData()
--    self:hasRedPoint()
end


-- 保存已浏览过的状态
function HandbookModel:setCheckData(id)
    id = tostring(id)
    if self._checkData == nil then
        self._checkData = SystemUtils.loadAccountLocalData("handbookCheck") or {}
    end

    local hasCheck = false
    for i = 1, #self._checkData do
        if self._checkData[i] == id then
            hasCheck = true
        end
    end

    if not hasCheck then
        table.insert(self._checkData, id) 
        SystemUtils.saveAccountLocalData("handbookCheck", json.encode(self._checkData))
    end

--    self:hasRedPoint()
end

function HandbookModel:getCheckData()
    if self._checkData == nil then
        local jsonData = SystemUtils.loadAccountLocalData("handbookCheck")
        if jsonData then
            self._checkData = json.decode(jsonData)
        else
            self._checkData = {}
        end
    end
    return self._checkData
end

-- 判断入口是否显示红点
function HandbookModel:hasRedPoint()
    if self._gpTab == nil then
        self._gpTab = {}
        for k, v in pairs(tab.gameplayOpen) do
            table.insert(self._gpTab, v)
        end

        table.sort(self._gpTab, function(a,b)
            return a.tabRank < b.tabRank
        end)
    end


    local gpTabLen = #self._gpTab
    local userLv = self._userModel:getPlayerLevel()

    local userlevelTab = tab:UserLevel(userLv)
    local systemnotice = userlevelTab.systemnotice

    self._newOpenLv = 0
    if systemnotice ~= nil then
        for i = 1, #self._gpTab do
            if self._gpTab[i].system then
                if SystemUtils["enable" .. self._gpTab[i].system]() and userLv >= self._gpTab[i].requiresLevel then   
                    if self._data[tostring(self._gpTab[i].id)] and self._data[tostring(self._gpTab[i].id)].status == 1 then
--                    self:reflashData("hasRed")
                        return "hasRed"
                    end
                end
            end
            
        end
    else
        for i = 1, #self._gpTab do
            if userLv >= self._gpTab[i].requiresLevel then   
                self._newOpenLv = math.max(self._newOpenLv, self._gpTab[i].requiresLevel)

                if self._data[tostring(self._gpTab[i].id)] and self._data[tostring(self._gpTab[i].id)].status == 1 then
--                    self:reflashData("hasRed")
                    return "hasRed"
                end
            end
        end

        for i = 1, #self._gpTab do
            if self._gpTab[i].requiresLevel == self._newOpenLv and not self:_hasChecked(tostring(self._gpTab[i].id)) then
--                self:reflashData("hasNew")
                return "hasNew"
            end
        end
    end

--    self:reflashData("noRed")
    return "noRed"
end

-- 判断是否浏览过
function HandbookModel:_hasChecked(id)
    id = tostring(id)
    local hasCheck = false
    local checkData = self:getCheckData()
    for i = 1, #checkData do
        if self._checkData[i] == id then
            hasCheck = true
        end
    end
    return hasCheck
end

-- 返回carry数据
function HandbookModel:onCarry(data)
    if data == nil or data._carry_ == nil then return end
--    print("==================================")
--    dump(data._carry_)
--    print("==================================")

    if data._carry_.handbook then
        self:updateData(data._carry_.handbook)
    end
end

return HandbookModel