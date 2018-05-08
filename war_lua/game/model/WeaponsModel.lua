--[[
    Filename:    WeaponsModel.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-09-04 16:58:27
    Description: File description
--]]

--[[
weaponInfo{
    weapons{
        (type) {   -- 器械类型
            'lv'   -- 等级
            'sp1'  -- 插槽1配件
            'sp2'  -- 插槽2配件
            'sp3'  -- 插槽3配件
            'sp4'  -- 插槽4配件
            'ss1'  -- 技能1解锁状态
            'ss2'  -- 技能2解锁状态
            'sl1'  -- 技能1等级
            'sl2'  -- 技能2等级
            'unlockIds'=>'AutoFieldsNum', -- 解锁ID列表
        }
    }
    props{ -- 配件列表
        (propIdx){ --  索引
            'lv'  -- 等级
            'id'  -- 配件ID
        }
    }
}
--]]

local WeaponsModel = class("WeaponsModel", BaseModel)

function WeaponsModel:ctor()
    WeaponsModel.super.ctor(self)
    self._weaponsType = {}
    self._weapons = {}
    self._weaponsMap = {}
    self._props = {}
    self._useProps = {}
    self._newPropsData = {}
end

function WeaponsModel:getData()
    return self._data
end
 
-- 子类覆盖此方法来存储数据
function WeaponsModel:setData(data)
    dump(data, "6666666========", 10)
    self._data = data
    -- self._checkTipData = {}
    -- -- 匹配数据
    if data.weapons then
        local backData, unlockWeapons = self:processData(data.weapons)
        self._weaponsType = backData
        self._weapons = unlockWeapons
        self:getWeaponsPropsData()
    end

    if data.props then
        -- self._props = data.props
        local backData, propsData = self:processPropsData(data.props)
        self._props = backData
        self._newPropsData = propsData or {}
    end
    self:checkTips()
    self:reflashData()

    -- -- 监听布阵数据变化更改排序
    -- self:listenReflash("FormationModel", self.refreshDataOrder)
    -- -- 监听物品数据变化更改提示状态
    -- self:listenReflash("ItemModel", self.updateTeamTips)
    self:listenReflash("UserModel", self.checkTips)
end

function WeaponsModel:updateWeaponsInfo(data)
    if data.weapons then
        self:updateWeaponsData(data.weapons)
        data.weapons = nil 
    end
    if data.props then
        self:updatePropsData(data.props)
        data.props = nil 
    end
    self:checkTips()
    self:reflashData()
end

-- 更新器械数据
function WeaponsModel:updateWeaponsData(data)
    local unlockWeapons = self._weapons
    local weaponsMap = self._weaponsMap
    local upProps = false
    for k,v in pairs(data) do
        local indexId = tonumber(k)
        local _weaponData = self._weaponsType[indexId]
        for k1,v1 in pairs(v) do
            if k1 == "unlockIds" then
                local unlockIds = _weaponData.unlockIds
                if not unlockIds then
                    unlockIds = {}
                    _weaponData.unlockIds = unlockIds
                end
                for wkey,wvalue in pairs(v1) do
                    local indexKeyId = tonumber(wkey)
                    weaponsMap[indexKeyId] = indexId
                    unlockWeapons[indexKeyId] = wvalue
                    unlockIds[indexKeyId] = wvalue
                end
            else
                _weaponData[k1] = v1
                if k1 == "sp1" or k1 == "sp2" or k1 == "sp3" or k1 == "sp4" then
                    upProps = true
                end
            end
        end
    end

    self._weaponsMap = weaponsMap

    if upProps == true then
        self:getWeaponsPropsData()
    end
end

-- 更新配件数据
function WeaponsModel:updatePropsData(data)
    local backData = self._props
    local propsData = self._newPropsData or {}
    for k,v in pairs(data) do
        local indexId = tonumber(k)
        local _propsData = backData[indexId]
        if _propsData then
            for pkey,pvalue in pairs(v) do
                _propsData[pkey] = pvalue
            end
        else
            local propsId = v.id 
            local propsTab = tab:SiegeEquip(propsId)
            v.quality = propsTab.quality 
            v.order = propsTab.order 
            v.jackType = propsTab.type  
            v.maxLevel = propsTab.lvlimit
            v.showequip = propsTab.showequip
            v.key = indexId
            backData[indexId] = v
            table.insert(propsData, v)
        end
    end
end

function WeaponsModel:handelUnsetProps(inData)
    local tempData = {}
    for k,v in pairs(inData) do
        if string.find(k, ".") ~= nil then
            local temp = string.split(k, "%.")
            if #temp >= 3 then
                table.insert(tempData,tonumber(temp[3]))
            end
        end
    end
    return tempData
end

-- 分解配件
function WeaponsModel:removeProps(inProps)
    if not inProps then
        return
    end
    local backData = self._props
    local propsData = self._newPropsData or {}
    for k,v in pairs(inProps) do
        backData[v] = nil
        local tempIndex = 0
        for k1,v1 in pairs(propsData) do
            if v1.key == tonumber(v) then 
                tempIndex = k1
                break
            end
        end
        if tempIndex > 0 then
            table.remove(propsData, tempIndex)
        end
    end
    self:reflashData()
end


-- 获取所有器械上的装备
function WeaponsModel:getWeaponsPropsData()
    self._useProps = {}
    for k,v in pairs(self._weaponsType) do
        for i=1,4 do
            local propsPos = v["sp" .. i]
            if propsPos ~= 0 then
                self._useProps[propsPos] = k
            end
        end
    end
end

-- 处理器械数据
function WeaponsModel:processData(data)
    local backData = {}
    local unlockWeapons = {}
    local weaponsMap = self._weaponsMap
    -- local siegeTypeTab = tab.siegeWeaponType
    for k,v in pairs(data) do
        local indexId = tonumber(k)
        backData[indexId] = v
        backData[indexId].weaponType = indexId
        -- v.equipType = siegeTypeTab[indexId].equipType
        -- v.weaponId = siegeTypeTab[indexId].weaponId
        if v.unlockIds then
            local unlockIds = {}
            for wkey,wvalue in pairs(v.unlockIds) do
                local indexKeyId = tonumber(wkey)
                weaponsMap[indexKeyId] = indexId
                unlockWeapons[indexKeyId] = wvalue
                unlockIds[indexKeyId] = wvalue
            end
            v.unlockIds = unlockIds
        end
    end
    self._weaponsMap = weaponsMap
    return backData, unlockWeapons
end

-- 初始化所有器械
function WeaponsModel:initWeapons()
    local sysWeapons = {}
    local weaponsTab = tab.siegeWeapon
    local unlockWeapons = self:getWeaponsData()
    for k,v in pairs(weaponsTab) do
        if not unlockWeapons[v.id] then
            sysWeapons[v.id] = 0
        end
    end
    self._sysWeapons = sysWeapons
end

-- 处理配件数据
function WeaponsModel:processPropsData(data)
    local backData = {}
    local propsData = {}

    for k,v in pairs(data) do
        local indexId = tonumber(k)
        local propsId = v.id 
        local propsTab = tab:SiegeEquip(propsId)
        v.quality = propsTab.quality 
        v.order = propsTab.order 
        v.jackType = propsTab.type  
        v.maxLevel = propsTab.lvlimit
        v.showequip = propsTab.showequip
        v.key = indexId 
        backData[indexId] = v
    end
    for k,v in pairs(data) do
        local indexId = tonumber(k)
        if backData[indexId] then
            table.insert(propsData, backData[indexId])
        end
    end
    return backData, propsData
end

function WeaponsModel:getWeaponsAllData()
    return self._weaponsType
end

-- 根据类型获取器械升级数据
function WeaponsModel:getWeaponsDataByType(weaponType)
    return self._weaponsType[weaponType]
end

-- 根据id获取当前器械类型
function WeaponsModel:getWeaponsTypeDataById(weaponId)
    local weaponType = self._weaponsMap[weaponId]
    print("weaponType========", weaponType)
    return self._weaponsType[weaponType]
end

-- 获取未获得器械id
function WeaponsModel:getAllWeaponsData()
    self:initWeapons()
    return self._sysWeapons
end

-- 获取已解锁器械
function WeaponsModel:getWeaponsData()
    return self._weapons
end

-- 获取器械技能是否需要动画
function WeaponsModel:getWeaponsSkillLock()
    return self._weaponSkillLock or {0, 0}
end

function WeaponsModel:setWeaponsSkillLock(skillNum)
    self._weaponSkillLock = skillNum
end

function WeaponsModel:getWeaponsDataF()
    local result = {}
    for k, v in pairs(self._weapons) do
        repeat
            local data = clone(self:getWeaponsTypeDataById(tonumber(k)))
            if not data or 4 == data.weaponType then break end
            data.score = tonumber(v)
            data.weaponId = tonumber(k)
            table.insert(result, data)
        until true
    end
    return result
end

function WeaponsModel:getWeaponsDataD()
    local result = {}
    for k, v in pairs(self._weapons) do
        repeat
            local data = clone(self:getWeaponsTypeDataById(tonumber(k)))
            if not data or 4 ~= data.weaponType then break end
            data.score = tonumber(v)
            data.weaponId = tonumber(k)
            table.insert(result, data)
        until true
    end
    return result
end

-- 获取所有器械配件数据
function WeaponsModel:getPropsData()
    return self._props
end

function WeaponsModel:getNewPropsData()
    return self._newPropsData or {}
end

-- 获取所有使用中的配件id
function WeaponsModel:getUsePropsIdData()
    return self._useProps
end


function WeaponsModel:getPropsDataByKey(propsKey)
    return self._props[propsKey]
end

-- 根据传入类型获取需要的配件
-- 传入类型是table
function WeaponsModel:getPropsDataByType(inTable)
    if not inTable then
        inTable = {1,2,3,4,5,6,7,8}
    end
    local backData = {}
    for k,v in pairs(self._props) do
        local ttype = v.jackType
        if table.indexof(inTable, ttype) ~= false then
            table.insert(backData, v)
        end
    end
    return backData
end

-- 根据传入类型获取没有装备的配件
function WeaponsModel:getPropsNoInsertByType(inTable)
    if not inTable then
        inTable = {1,2,3,4,5,6,7,8}
    end
    local propsData = self._props
    local propsUseData = self._useProps
    local backData = {}
    for k,v in pairs(propsData) do
        if not propsUseData[k] then
            local ttype = v.jackType
            if table.indexof(inTable, ttype) ~= false then
                table.insert(backData, v)
            end
        end
    end
    return backData
end



-- 可分解配件排序
function WeaponsModel:getCanBreakProps()
    local propsData = self._props
    local propsUseData = self._useProps
    local backData = {}
    for k,v in pairs(propsData) do
        if not self._useProps[k] then
            table.insert(backData, v)
        end
    end
    local sortFunc = function(a, b)
        local akey = a.key 
        local bkey = b.key 
        local aquality = a.quality
        local bquality = b.quality
        local aorder = a.order
        local border = b.order
        local ascore = a.score
        local bscore = b.score
        if aquality ~= bquality then
            return aquality < bquality
        elseif aorder and border and aorder ~= border then
            return aorder < border
        elseif ascore and bscore and ascore ~= bscore then
            return ascore > bscore
        elseif akey ~= bkey then
            return akey < bkey
        end
    end
    table.sort(backData, sortFunc)
    return backData
end


-- 替换配件排序
function WeaponsModel:getCanReplaceProps(propsData, propKey, weaponType)
    local propsUseData = self._useProps
    local backData = {}
    for k,v in pairs(propsData) do
        if propsUseData[v.key] then
            v.onEquit = 1
        else
            v.onEquit = 0
        end
        local proper = 0
        if v.showequip and v.showequip[weaponType] then
            proper = v.showequip[weaponType]
        end
        v.proper = proper
        if v.key ~= propKey then
            table.insert(backData, v)
        end
    end
    local sortFunc = function(a, b)
        local akey = a.key 
        local bkey = b.key 
        local aquality = a.quality
        local bquality = b.quality
        local aproper = a.proper
        local bproper = b.proper
        local aorder = a.order
        local border = b.order
        local ascore = a.score
        local bscore = b.score
        local aonEquit = a.onEquit
        local bonEquit = b.onEquit
        if aonEquit ~= bonEquit then
            return aonEquit < bonEquit
        elseif aproper ~= bproper then
            return aproper > bproper
        elseif aquality ~= bquality then
            return aquality > bquality
        elseif ascore and bscore and ascore ~= bscore then
            return ascore > bscore
        elseif aorder and border and aorder ~= border then
            return aorder < border
        elseif akey ~= bkey then
            return akey < bkey
        end
    end
    table.sort(backData, sortFunc)
    return backData
end

-- 器械属性
function WeaponsModel:getWeaponsAttr(weaponsId, weaponType)
    -- local weaponsId = 1
    local attr = {}
    for i=1,6 do
        attr[i] = 0
    end
    local weaponsData = self._weaponsType[weaponType] -- self._weaponsModel:getWeaponsDataByType(weaponsType)
    if not weaponsData then
        return attr
    end
    local weaponsLevel = weaponsData.lv
    local weaponsTab = tab:SiegeWeapon(weaponsId)
    local intproperty = weaponsTab.intproperty
    for i=1,table.nums(intproperty) do
        local oneproperty = intproperty[i]
        local ptype = oneproperty[1]
        local pbaseattr = oneproperty[2]
        local pgrow = oneproperty[3]
        attr[ptype] = attr[ptype] + pgrow*(weaponsLevel-1) + pbaseattr
    end

    return attr 
end 

-- 配件属性
function WeaponsModel:getPropsAttr(propsId)
    local attr = {}
    for i=1,6 do
        attr[i] = 0
    end
    local weaponData = self._props -- self._weaponsModel:getPropsData()
    local propsData = weaponData[propsId]
    if not propsData then
        return attr
    end
    local propsId = propsData.id 
    local propsLevel = propsData.lv 
    local propsTab = tab:SiegeEquip(propsId)
    local intproperty = propsTab.intproperty
    for i=1,table.nums(intproperty) do
        local oneproperty = intproperty[i]
        local ptype = oneproperty[1]
        local pbaseattr = oneproperty[2]
        local pgrow = oneproperty[3]
        attr[ptype] = attr[ptype] + pgrow*(propsLevel-1) + pbaseattr
    end

    local equipLimitLv = tab:Setting("SIEGE_EQUIP_LV").value
    for i=1,6 do
        local percent = propsTab["percent" .. i]
        if percent then
            local ptype = percent[1] + 3
            local pvalue = percent[2]
            if propsLevel >= equipLimitLv[i] then
                attr[ptype] = attr[ptype] + pvalue
            end
        end
    end
    return attr
end 

-- 属性总值
function WeaponsModel:getAttrValue(attr)
    local attrValue = {}
    for i=1,3 do
        attrValue[i] = 0
    end
    if not attr then
        return 
    end

    local attrValue = {}
    for i=1,3 do
        local value = attr[i]*(1+attr[3+i]*0.01)
        attrValue[i] = math.floor(value*10)/10
    end
    return attrValue
end 

-- 功能总开关
function WeaponsModel:getActionOpen()
    return true 
end 

-- 四种状态
-- 0，无此功能
-- 1，事件未结束，等级未到
-- 2，事件结束，等级未到
-- 3，事件未结束，等级已到
-- 4，事件结束，等级已到
function WeaponsModel:getWeaponState()
    local open = self:getActionOpen()
    if open == false then
        return 0
    end
    local seigeStatus = self._modelMgr:getModel("SiegeModel"):getData().status
    local eventState = 0
    if seigeStatus == 7 then -- 判断攻城战养成是否开启
        eventState = 1
    end

    -- local userData = self._modelMgr:getModel("UserModel"):getData()
    -- local userLvl = userData.lvl
    local isOpen,toBeOpen,isLevel = SystemUtils["enableWeapon"]()
    local lvState = 0
    if isOpen == true then
        lvState = 1
    end

    local state = 1
    if eventState == 0 and lvState == 0 then
        state = 1
    elseif eventState == 1 and lvState == 0 then
        state = 2
    elseif eventState == 0 and lvState == 1 then
        state = 3
    elseif eventState == 1 and lvState == 1 then
        state = 4
    end
    return state 
end 

function WeaponsModel:openWeapon()
    local flag = false
    if self:getWeaponState() == 4 then
        local weaponOpen = SystemUtils.loadAccountLocalData("Weapon_Open")
        if not weaponOpen then
            flag = true
        end
    end
    return flag
end 

function WeaponsModel:setWeapon()
    local weaponOpen = SystemUtils.loadAccountLocalData("Weapon_Open")
    if not weaponOpen then
        SystemUtils.saveAccountLocalData("Weapon_Open", "1004")
    end
end 

-- 检查气泡
function WeaponsModel:checkMainViewTips()
    local flag = false
    local weaponTypeData = self:getWeaponsAllData() or {}
    for k,v in pairs(weaponTypeData) do
        if v.onInsert == true and v.unlockIds then
            flag = true
        end
    end
    -- for k,v in pairs(weaponTypeData) do
    --     local sp = v["sp" .. k]
    --     if sp == 0 then
    --         local equipType = tab.siegeWeaponType[tonumber(k)].equipType
    --         for i=1,4 do
    --             local skillTab = equipType[i]
    --             local propsData = self:getPropsNoInsertByType(skillTab)
    --             if table.nums(propsData) ~= 0 then
    --                 flag = true
    --                 break
    --             end
    --         end
    --         if flag == true then
    --             break
    --         end
    --     end
    -- end
    return flag
end

-- 检查红点
function WeaponsModel:checkTips()
    local weaponTypeData = self:getWeaponsAllData() or {}
    for k,v in pairs(weaponTypeData) do
        local onGrade, onInsert, onReplace = self:checkUpGrade(k, v)
        v.onGrade = onGrade
        v.onInsert = onInsert
        v.onReplace = onReplace
    end
end

function WeaponsModel:checkUpGrade(k, v)
    local onGrade = false
    local onInsert = false
    local onReplace = 0
    local level = v["lv"]
    local exp = v["exp"] or 0
    local wpType = tonumber(k)
    local weaponTypeTab = tab.siegeWeaponType[wpType]
    local weaponExpTab = tab:SiegeWeaponExp(level)
    if weaponExpTab then
        local userData = self._modelMgr:getModel("UserModel"):getData()
        local userLvl = userData.lvl or 1
        local maxLvl = userLvl - tab:Setting("SIEGE_WEAPON_LV").value
        local siegeWeaponExp = userData.siegeWeaponExp or 0
        siegeWeaponExp = siegeWeaponExp + exp
        local costExp = weaponExpTab.cost1
        if level < maxLvl then
            if siegeWeaponExp >= costExp then
                onGrade = true
            end
        end
    end

    local equipType = weaponTypeTab.equipType
    for i=1,4 do
        local sp = v["sp" .. i]
        local skillTab = equipType[i]
        local propsData = self:getPropsNoInsertByType(skillTab)
        if sp == 0 and onInsert == false then
            if table.nums(propsData) ~= 0 then
                onInsert = true
            end
        end

        if sp ~= 0 and onReplace == 0 then
            local tpropData1 = self:getPropsDataByKey(sp)
            if table.nums(propsData) ~= 0 then
                local tpropData2 = self:getRecommendProps(propsData, wpType)[1]
                local score1 = tpropData1.score
                local score2 = tpropData2.score
                local quality1 = tpropData1.quality
                local quality2 = tpropData2.quality
                local proper1 = tpropData1.showequip[wpType]
                local proper2 = tpropData2.showequip[wpType]
                if proper1 < proper2 then
                    onReplace = i
                elseif proper1 == proper2 then
                    if score1 < score2 then
                        onReplace = i
                    end
                end
            end
        end

        if onInsert == true and onReplace ~= 0 then
            break
        end
    end

    print("WeaponsModelonGrade===", onGrade, onInsert, onReplace)
    return onGrade, onInsert, onReplace
end


-- 推荐替换配件排序
function WeaponsModel:getRecommendProps(propsData, weaponType)
    local backData = {}
    for k,v in pairs(propsData) do
        local proper = 0
        if v.showequip and v.showequip[weaponType] then
            proper = v.showequip[weaponType]
        end
        v.proper = proper
        table.insert(backData, v)
    end
    local sortFunc = function(a, b)
        local akey = a.key 
        local bkey = b.key 
        local aproper = a.proper
        local bproper = b.proper
        local aquality = a.quality
        local bquality = b.quality
        local ascore = a.score
        local bscore = b.score
        if aproper ~= bproper then
            return aproper > bproper
        elseif aquality ~= bquality then
            return aquality > bquality
        elseif ascore and bscore and ascore ~= bscore then
            return ascore > bscore
        elseif akey ~= bkey then
            return akey < bkey
        end
    end
    table.sort(backData, sortFunc)
    return backData
end

function WeaponsModel:getWeaponAllScore()
    local weaponDataType = self:getWeaponsAllData() or {}
    local score = 0
    for k,v in pairs(weaponDataType) do
        local unlockIds = v.unlockIds or {}
        for k1,v1 in pairs(unlockIds) do
            score = score + v1
        end
        for i=1,4 do
            local _sp = v["sp" .. i]
            if _sp ~= 0 then
                local propData = self:getPropsDataByKey(_sp)
                if propData and propData.score then
                    local tScore = propData.score
                    score = score + tScore
                end
            end
        end
    end
    return score
end

function WeaponsModel:getWeaponScore(weaponId, weaponType)
    local tScore = 0
    local weaponData = self:getWeaponsData()
    if weaponData[weaponId] then
        tScore = weaponData[weaponId]
        local weaponTypeData = self:getWeaponsDataByType(weaponType)
        local propsData = self:getPropsData()
        for i=1,4 do
            local sp = weaponTypeData["sp" .. i]
            if sp ~= 0 then
                if propsData[sp] and propsData[sp].score then
                    tScore = tScore + propsData[sp].score
                end
            end
        end
    end

    return tScore
end 

function WeaponsModel:getAttrData(weaponId, weaponType)
    local attr = {}
    for i=1,6 do
        attr[i] = 0
    end
    local wattrData = self:getWeaponsAttr(weaponId, weaponType)
    for key=1,6 do
        attr[key] = attr[key] + wattrData[key]
    end
    local weaponTypeData = self:getWeaponsDataByType(weaponType)
    for i=1,4 do
        local propKey = weaponTypeData["sp" .. i]
        if propKey ~= 0 then
            local attrData = self:getPropsAttr(propKey)
            for key=1,6 do
                attr[key] = attr[key] + attrData[key]
            end
        end
    end
    return attr
end

-- guofang 12.13 嘉年华用
function WeaponsModel:getWeaponTypeLevel(weaponType)
    local weaponLevel = 0
    if not weaponType then
        weaponType = 1
    end
    local weaponTypeData = self:getWeaponsDataByType(weaponType)
    if weaponTypeData and weaponTypeData.lv then
        weaponLevel = weaponTypeData.lv
    end
    return weaponLevel
end

function WeaponsModel:getPropNumByStage(propStage)
    local propsData = {}
    if not weaponType then
        weaponType = 1
    end
    local propsNum = 0
    local propsData = self:getUsePropsIdData()
    for k,v in pairs(propsData) do
        local pdata = self:getPropsDataByKey(k)
        if pdata and pdata.quality and pdata.quality >= propStage then
            propsNum = propsNum + 1
        end
    end
    return propsNum
end

-- guofang 专用 判断器械解锁
function WeaponsModel:getWeaponLockById(weaponId)
    local flag = false
    if not weaponId then
        return flag
    end
    local weaponData = self:getWeaponsData()
    if weaponData[weaponId] then
        flag = true
    end
    return flag
end

-----------------------------------------------------

-- 是否达到背包容量
function WeaponsModel:isFinishMaxcapacity()
    local data = self:getNewPropsData()
    local max = tab:Setting("WEAPON_LIMIT").value
    if #data < max then
        return false
    end 
    return true
end

return WeaponsModel