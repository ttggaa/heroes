

local DirectShopModel = class("DirectShopModel", BaseModel)
local tabMaxCount = 5

function DirectShopModel:ctor()
    DirectShopModel.super.ctor(self)
    self._data = {}
    self._dirty = true
    self._clickTab = {}
    self._redInfo = nil
    self._rmbResult = nil
    self._initCacheData = nil
    self._haveInit = nil   --是否已经初始化红点
    self._openDay = nil

    -- self:setListenReflashWithParam(true)
    -- self:listenReflash("VipModel", self.onModelEvent)
    self._userModel = self._modelMgr:getModel("UserModel")
    self._vipModel  = self._modelMgr:getModel("VipModel")
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._treaSureModel = self._modelMgr:getModel("TreasureModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._heroModel = self._modelMgr:getModel("HeroModel")

    self:listenReflash("TeamModel" , self.onGetTeam)
end

function DirectShopModel:onLevelUp()
    if self._initCacheData and table.nums(self._initCacheData) > 0 then
        self._data = {}
        self:updateShop(self._initCacheData)
        self:updateRedInfo()
        self:reflashData("TeamChanged")
    end
end

function DirectShopModel:getOpenDay()
    return self._openDay
end

function DirectShopModel:setOpenDay(day)
    if day then
        self._openDay = day
    end
end

function DirectShopModel:onGetTeam()
    -- if self._initCacheData and table.nums(self._initCacheData) > 0 then
    --     self._data = {}
    --     self:updateShop(self._initCacheData)
    --     self:updateRedInfo()
    --     self:reflashData()
    -- end
    self:reflashData("TeamChanged")
end

function DirectShopModel:setData(data)
    -- dump(data)
    self._data = {}
    if data and table.nums(data) > 0 then
        self._initCacheData = clone(data) 
    	self:updateShop(data)
        self:reflashData()
    else
        self._data = {}
        self._initCacheData = nil
    end
    self:setServerDataStatus(false)
end


function DirectShopModel:getData()
    return self._data
end

function DirectShopModel:isServerDataDirty()
    return self._dirty
end

--缓存点击的页签
function DirectShopModel:cickTab(index)
    if not self._redInfo then self._redInfo = {} end
    if table.find(self._clickTab,index) == nil then
        table.insert(self._clickTab,index)
        if self._redInfo[index] == true then
            self._redInfo[index] = false
            self:reflashData()
        end
    end
end

--缓存红点数据
function DirectShopModel:setDirectShopRedInfo(data)
    -- dump(data)
    self._redInfo = data
    self:reflashData()
end

function DirectShopModel:getDirectShopRedInfo()

    -- dump(self._redInfo,"getDirectShopRedInfo",10)
    return self._redInfo or {}
end


--获取
function DirectShopModel:getTopTabIndex()

    -- dump(self._redInfo,"getTopTabIndex",10)
    if not self._redInfo then self._redInfo = {} end
    local i = 1
    for k,v in pairs (self._redInfo) do
        if v == true then
            return i
        end
        i = i + 1
    end
    return 1
end

function DirectShopModel:getCickTab()
    return self._clickTab or {}
end

function DirectShopModel:setServerDataStatus(status)
    self._dirty = status
end

function DirectShopModel:cleanRedStatus()
    self._haveInit = nil
end


function DirectShopModel:checkRedInfo()
    if self._haveInit == true then
        return
    end
    print("DirectShopModel:checkRedInfo")
    self._haveInit = true
    self._clickTab = {}

    ---有新增id的情况
    local function seachModelData(modelData,id)
        for k,v in pairs (modelData) do 
            if v.id == id then
                return true
            end
        end
        return false
    end

    local redData = SystemUtils.loadAccountLocalData("DIRECTSHOP")
    local shopData = self:getData()

    -- dump(shopData,"checkRedInfo",10)
    local redInfo = {}
    if redData == nil then --第一次登陆客户端
       local saveData = {}
       for tabIndex,tabData in pairs (shopData) do 
            if not saveData[tabIndex] then 
                saveData[tabIndex] = {}
                redInfo[tabIndex] = true 
            end
            if not saveData[tabIndex].id then saveData[tabIndex].id = {} end
            for k,v in pairs (tabData) do 
                table.insert(saveData[tabIndex].id,v.id)
            end
       end
       local totalData = {}
       -- totalData.time = os.date()
       -- table.sort(saveData)
       totalData.data = saveData
       SystemUtils.saveAccountLocalData("DIRECTSHOP",cjson.encode(totalData))
    else
        redData = cjson.decode(redData)
        local dataInfo = redData.data
        -- local time = redData.time
        for tabIndex,tabData in pairs (shopData) do 
            if not dataInfo[tabIndex] then --新的商品类型
                dataInfo[tabIndex] = {}
                -- dataInfo[tabIndex].haveNew = true
                redInfo[tabIndex] = true
                if not dataInfo[tabIndex].id then dataInfo[tabIndex].id = {} end
                for k,v in pairs (tabData) do 
                    table.insert(dataInfo[tabIndex].id,v.id)
                end
            else
                local localData = dataInfo[tabIndex]
                --删除过期的id
                for i=table.nums(localData.id),1,-1 do 
                    if seachModelData(tabData,localData.id[i]) == false then
                        table.remove(localData.id,i)
                    end
                end
                --添加新增id
                for k,v in pairs (tabData) do 
                    if table.find(localData.id,v.id) == nil then
                        table.insert(localData.id,v.id)
                        -- localData.haveNew = true
                        redInfo[tabIndex] = true
                        -- if tabIndex == 1 and k <= 4 then
                        --     redInfo[tabIndex] = true
                        -- elseif tabIndex ~= 1 then
                        --     redInfo[tabIndex] = true
                        -- end
                    end
                end
            end
            SystemUtils.saveAccountLocalData("DIRECTSHOP",cjson.encode(redData))
       end
    end

    dump(redInfo,"------------",10)
    for i=1,tabMaxCount do 
        if (not redInfo[i] or redInfo[i] == false) and self._data[i] and table.nums(self._data[i]) >0 then --此类商品没有新增，需要去检查是否有可购买的商品
           redInfo[i] = self:checkIsHaveSomethingCanBuy(i)
        end
    end
    dump(redInfo,"setDirectShopRedInfo",10)
    self:setDirectShopRedInfo(redInfo)
end


function DirectShopModel:resetClickTab(index)
    if index then
        local tabIndex = tonumber(index) 
        if tabIndex then
            for k,v in pairs (self._clickTab) do 
                if v == tabIndex then
                    table.remove(self._clickTab,k)
                    break
                end
            end
        end
    end
end

function DirectShopModel:updateRedInfo()
    -- self._clickTab = {}

    ---有新增id的情况
    local function seachModelData(modelData,id)
        for k,v in pairs (modelData) do 
            if v.id == id then
                return true
            end
        end
        return false
    end

    local redData = SystemUtils.loadAccountLocalData("DIRECTSHOP")
    local shopData = self:getData()
    local redInfo = self._redInfo or {}
    if redData == nil then --第一次登陆客户端
       local saveData = {}
       for tabIndex,tabData in pairs (shopData) do 
            if not saveData[tabIndex] then 
                saveData[tabIndex] = {}
                redInfo[tabIndex] = true 
                self:resetClickTab(tabIndex)
            end
            if not saveData[tabIndex].id then saveData[tabIndex].id = {} end
            for k,v in pairs (tabData) do 
                table.insert(saveData[tabIndex].id,v.id)
            end
       end
       local totalData = {}
       -- totalData.time = os.date()
       -- table.sort(saveData)
       totalData.data = saveData
       SystemUtils.saveAccountLocalData("DIRECTSHOP",cjson.encode(totalData))
    else
        redData = cjson.decode(redData)
        local dataInfo = redData.data
        -- local time = redData.time
        for tabIndex,tabData in pairs (shopData) do 
            if not dataInfo[tabIndex] then --新的商品类型
                dataInfo[tabIndex] = {}
                -- dataInfo[tabIndex].haveNew = true
                redInfo[tabIndex] = true
                self:resetClickTab(tabIndex)
                if not dataInfo[tabIndex].id then dataInfo[tabIndex].id = {} end
                for k,v in pairs (tabData) do 
                    table.insert(dataInfo[tabIndex].id,v.id)
                end
            else
                local localData = dataInfo[tabIndex]
                --删除过期的id
                for i=table.nums(localData.id),1,-1 do 
                    if seachModelData(tabData,localData.id[i]) == false then
                        table.remove(localData.id,i)
                    end
                end
                --添加新增id
                for k,v in pairs (tabData) do 
                    if table.find(localData.id,v.id) == nil then
                        table.insert(localData.id,v.id)
                        -- localData.haveNew = true
                        redInfo[tabIndex] = true
                        self:resetClickTab(tabIndex)
                        -- if tabIndex == 1 and k <= 4 then
                        --     redInfo[tabIndex] = true
                        -- elseif tabIndex ~= 1 then
                        --     redInfo[tabIndex] = true
                        -- end
                    end
                end
            end
            SystemUtils.saveAccountLocalData("DIRECTSHOP",cjson.encode(redData))
       end
    end
    dump(redInfo,"redInfo====",10)
    self:setDirectShopRedInfo(redInfo)
end


function DirectShopModel:checkIsHaveSomethingCanBuy(type_)
    -- dump(self._data)
    local itemList = self._data[type_]
    if not itemList then return false end
    for index,itemData in pairs (itemList) do 
        if type_ == 1 and index > 4 then
            return false
        end
        if itemData.buyTimes > 0 then
            if itemData.currency == 2 or itemData.currency == 3 then
                print("checkIsHaveSomethingCanBuy",type_,1111)
                return true
            else
                local player = self._modelMgr:getModel("UserModel"):getData()
                local gemHaveCount = player.gem
                if itemData.gemprice <= gemHaveCount then
                    print("checkIsHaveSomethingCanBuy",type_,2222)
                    return true
                end
            end
        end
    end
    return false
end


function DirectShopModel:getLeftTime(cellData,endTime)

    -- printf("cur == %d, entime == %d",os.time(),endTime)
    local time_ = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local leftTime = 0
    if cellData.timetype == 1 then--开服时间
        -- leftTime = endtime - 
        leftTime = math.max(0,endTime - time_)
    elseif cellData.timetype == 2 then --创角时间
        leftTime = math.max(0,endTime - time_)
    elseif cellData.timetype == 3 then --自然时间
        leftTime = math.max(0,endTime - time_)
    end
    return leftTime
end

function DirectShopModel:updateShop( inData )

    local _userModel = self._userModel:getData()
    local userLevel = _userModel.lvl
    local userVip = self._vipModel:getData().level
    local teamModelData = self._teamModel:getData()
    -- dump(inData.zhigou,"updateShop",10)
    --商品分类
    for tabId,shopData in pairs (inData.zhigou) do 
        -- dump(shopData)
        printf("tabId == %d",tabId)
        local configData
        if GameStatic.appleExamine == true then
            configData = tab:Specialshopauditing(tonumber(tabId))
        else
            configData = tab:Specialshop(tonumber(tabId))
        end
        if configData then
            local needVip = configData.vip
            local needLevel = configData.level
            local leftTime_ = shopData.endTime
            local teamNeedId = configData.team or -1
            local treasureNeedId = configData.treasure
            local conditionCustom = configData.invisible
            local conditionType = conditionCustom and conditionCustom[1]
            local conditionId1  = conditionCustom and conditionCustom[2]
            local conditionId2  = conditionCustom and conditionCustom[3]

            configData.buyTimes = shopData.buyTimes
            configData.leftTime = leftTime_

            if userLevel >= needLevel and userVip >= needVip and leftTime_ > 0 then
                for _,_tab in pairs (configData.tab) do 
                    if not self._data[_tab] then self._data[_tab] = {} end
                    configData.expireTime = shopData.expireTime or 0
                    if teamNeedId and teamNeedId ~= -1 then
                        for _,data in pairs (teamModelData) do 
                            if data.teamId == teamNeedId then
                                table.insert(self._data[_tab],configData)
                                break
                            end
                        end
                    elseif treasureNeedId then
                        if self._treaSureModel:isTreasureActived(treasureNeedId) then
                            table.insert(self._data[_tab],configData)
                        end
                    elseif conditionType == 1 then -- 有特定皮肤,则特定的皮肤商品不显示
                        local isOk = true
                        if conditionId1 then --道具id
                            local _,count = self._itemModel:getItemsById(conditionId1)
                            if count ~= 0 then
                                isOk = false
                            end
                        end
                        if isOk then
                            if conditionId2 then
                                if self._heroModel:isHaveSkinBySkinId(conditionId2) then
                                    isOk = false
                                end
                            end
                        end
                        if isOk then
                            table.insert(self._data[_tab],configData)
                        end
                    else
                        table.insert(self._data[_tab],configData)
                    end
                end
            end
        else
            printf("直购商品表 >>>>>>>> %d <<<<<<<<<<<<<<<<<<<<未找到,请联系刘弘睿",tonumber(tabId))
        end
    end

    local function sortFun(item1,item2)
        if item1.order ~= item2.order then
            return item1.order < item2.order
        end
    end
    for _,tableData in pairs (self._data) do 
        table.sort( tableData, sortFun )
    end
    self:orderItemByCount()
    self:reflashData()
end

function DirectShopModel:orderItemByCount()
    for tabIndex,data in pairs (self._data) do 
        local sell_out = {}
        for i=table.nums(data),1,-1 do 
            local itemData = data[i]
            if itemData.reset == 4 and itemData.buyTimes <=0 then
                table.insert(sell_out,data[i])
                table.remove(data,i)
            end
        end
        for _,_data in pairs (sell_out) do 
            table.insert(data,_data)
        end
    end
end

--缓存人民币购买后的服务器数据
function DirectShopModel:setRmbResult(result)
    self._rmbResult = result
end

function DirectShopModel:getRmbResult()
    return self._rmbResult
end

function DirectShopModel:setOneCashResult(result)
    self._oneCashResult = result
    self:reflashData()
end

function DirectShopModel:getOneCashReslut()
    return self._oneCashResult
end

function DirectShopModel:clearRmbResult()
    self._rmbResult = nil
end

function DirectShopModel:clearOneCashResult()
    self._oneCashResult = nil
end

function DirectShopModel:updateShopGoodsAfterBuy(inData)
    -- dump(inData)
    local buyData =inData.zhigou.weekCards or inData.zhigou
    for id,data in pairs (buyData) do 
        local typeTable
        if GameStatic.appleExamine == true then
            typeTable = tab:Specialshopauditing(tonumber(id)).tab
        else
            typeTable = tab:Specialshop(tonumber(id)).tab
        end
        for _,type_ in pairs (typeTable) do 
            for itemId,itemData in pairs (self._data[type_]) do 
                if itemData.id == tonumber(id) then 
                    itemData.buyTimes = data.buyTimes
                    itemData.expireTime = data.expireTime or 0
                    self:refreshCashData(itemData.id,data)
                    break
                end
            end
        end
    end
    self:orderItemByCount()
    self:reflashData()
end

function DirectShopModel:refreshCashData(directId,realData)
    if self._initCacheData and table.nums(self._initCacheData) > 0 then
        if self._initCacheData.zhigou and self._initCacheData.zhigou.weekCards and table.nums(self._initCacheData.zhigou.weekCards) > 0 then
            for id,data in pairs (self._initCacheData.zhigou.weekCards) do 
                if tonumber(id) == directId then
                    data.buyTimes = realData.buyTimes
                    data.expireTime = realData.expireTime or 0
                    break
                end
            end
        else
            for id,data in pairs (self._initCacheData.zhigou) do 
                if tonumber(id) == directId then
                    data.buyTimes = realData.buyTimes
                    data.expireTime = realData.expireTime or 0
                    break
                end
            end
        end
    end
end


return DirectShopModel