--[[
    Filename:    HeroModel.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2015-07-20 11:28:23
    Description: File description
--]]

--[[
    ********数据瘦身记录********
    mastery     => m
    spellLvl    => sl
    spellLvlExp => se
]]--

local HeroModel = class("HeroModel", BaseModel)

HeroModel.kTagTypeSkill = 1
HeroModel.kTagTypeMastery = 2
HeroModel.kTagTypeSpecialty = 3
HeroModel.kTagTypeUpgrade = 4
HeroModel.kTagTypeEnd = 4

function HeroModel:ctor()
    HeroModel.super.ctor(self)
    self._data = {}
    -- 英雄传记数据
    self._heroBio = {}
    self._placeSkillID = {}
    self._modelMgr = ModelManager:getInstance()
    self._userModel = self._modelMgr:getModel("UserModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._playerTodayModel = self._modelMgr:getModel("PlayerTodayModel")
    self._privilegesModel = self._modelMgr:getModel("PrivilegesModel")

    self:registerTimer(5, 0, 0, specialize(self.setOutOfDate, self))
    -- self:cacheBaseSkillID()
    -- 添加全局监听 英雄传记
    self:listenGlobalResponse(specialize(self.onChangeBiography, self))
end


-- 技能替换后id和技能最原始id映射
function HeroModel:cacheBaseSkillID()
    if tab.heroMastery and table.nums(self._placeSkillID) == 0 then
        local Tabdata = tab.heroMastery
        local result = {}
        for _,data in pairs (Tabdata) do 
            if data.skreplace and type(data.skreplace) == "table" then
                for _,s in pairs (data.skreplace) do 
                    result[s[2]] = s[1]
                end
            end
        end
        self._placeSkillID = result
    end
end

function HeroModel:getPlaceSkillIds()
    if self._placeSkillID and table.nums(self._placeSkillID) == 0 then
        self:cacheBaseSkillID()
    end
    return self._placeSkillID
end

function HeroModel:setData(data)
    self._data = data
    -- 注入ID
    if self._data then
        for k, v in pairs(self._data) do
            v["id"] = tonumber(k)
            self:updateCheck(v)
            self:initSlotSkillex(v)
            -- 初始化英雄传记
            self:initHeroBiography(k,v)
        end
    end
    -- dump(self._data, "HeroModel:setData", 20)
    self:reflashData()
end

function HeroModel:reflashAllSlotSkillex( )
    if self._data then
        for k, v in pairs(self._data) do
            self:initSlotSkillex(v)
        end
    end
end

function HeroModel:initSlotSkillex( heroData )
     -- 处理法术插槽
    if heroData.slot 
        and heroData.slot.sid 
        and tonumber(heroData.slot.sid) ~= 0 
    then
        local spellBooksModelD = ModelManager:getInstance():getModel("SpellBooksModel"):getData()
        local bookInfo = spellBooksModelD and spellBooksModelD[tostring(heroData.slot.sid)]
        if bookInfo and tonumber(bookInfo.l) then
            heroData.skillex = {heroData.slot.sid, heroData.slot.s, bookInfo.l}
        elseif heroData.slot.sLvl then
            heroData.skillex = {heroData.slot.sid, heroData.slot.s, heroData.slot.sLvl}
        else
            heroData.skillex = nil
        end
    else
        heroData.skillex = nil
    end
end

function HeroModel:updateCheck(heroData)
    if not heroData.star then return end
    heroData.heroCheck = BattleUtils.checkHeroData(heroData)
end

function HeroModel:getData()
    return self._data
end

function HeroModel:checkData()
    for k, v in pairs(self._data) do
        if v.heroCheck ~= BattleUtils.checkHeroData(v) then
            return v
        end
    end
end

function HeroModel:setOutOfDate()
    self:reflashData()
end

function HeroModel:saveMastery(heroData, index, callback)
    local context = {heroId = heroData.id,  index = index--[[args = {masterys = {}}]]}
    --[[
    for i=1, 4 do
        context.args.masterys["m" .. i] = self._heroData["m" .. i]
    end
    ]]
    local formationModel = self._modelMgr:getModel("FormationModel")
    self._serverMgr:sendMsg("HeroServer", "saveMastery", context, true, {}, function(success, result)
        if not success then return end

        if not (result and result["d"] and result["d"]["heros"] and result["d"]["heros"][tostring(heroData.id)]) then return end

        local newHeroData = result["d"]["heros"][tostring(heroData.id)]

        for i=1, 4 do
            if newHeroData["m" .. i] then
                self._data[tostring(heroData.id)]["m" .. i] = newHeroData["m" .. i]
            end
        end

        if result["d"].formations then
            formationModel:updateAllFormationData(result["d"].formations)
        end

        result["d"].formations = nil

        if result["d"].heros then
            self:updateHeroData(result["d"])
        end

        -- table.merge(heroData, newHeroData)
        self:mergeHeroData(heroData, newHeroData)
            
        result["d"].heros = nil

        self._userModel:updateUserData(result["d"])

        if callback and type(callback) == "function" then
            callback(success)
        end 
    end)
end

function HeroModel:saveLocks(heroData)
    --dump(heroData, "saveLocks")
    local locks = ""
    local isLock = false
    for i=1, 4 do
        if heroData["masteryLock" .. i] then
            isLock = true
            locks = locks .. i .. ","
        end 
    end
    if isLock then
        self._data[tostring(heroData.id)].locks = string.sub(locks, 1, -2)
    end
end

function HeroModel:unlockHero(hero)
    --dump(hero, "unlockHero")
    for k, v in pairs(hero) do
        if not self._data[k] then 
            self._data[k] = v
            self._data[k]["id"] = tonumber(k)
        end
    end

    self:updateHeroData({heros = hero})
    --dump(self._data, "unlockHero")
end

function HeroModel:updateHeroData(heroData)
    if heroData.heros then
        local m = nil
        m = function(a, b)
            for k, v in pairs(b) do
                if type(a[k]) == "table" and type(v) == "table" then
                    m(a[k], v)
                else
                    a[k] = v
                end
            end
        end
        m(self._data, heroData.heros)

        for k, v in pairs(heroData.heros) do
            self:initSlotSkillex(self._data[tostring(k)])
            self:updateCheck(self._data[tostring(k)])
        end
        --dump(self._data, "updateHeroData")
        self:reflashData()
    end
end

function HeroModel:hasHeroCanUnlock()

    local heroData = self:getData()
    local heroTableData = clone(tab.hero)

    local findHeroData = function(key)
        for k, v in pairs(heroData) do
            if tonumber(k) == tonumber(key) then
                return true
            end
        end
        return false
    end

    local isHeroCanUnlock = function(heroData)
        local _, have = self._itemModel:getItemsById(heroData.unlockcost[2])
        local consume = heroData.unlockcost[3]
        return have >= consume
    end

    for k, v in pairs(heroTableData) do
        repeat
            if 0 == v.visible then break end
            if not findHeroData(k) and isHeroCanUnlock(v) then
                return true
            end
        until true
    end

    return false
end

function HeroModel:checkHero(heroId)
    local heroData = self:getData()
    for k, v in pairs(heroData) do
        if tonumber(k) == tonumber(heroId) then
            return true
        end
    end
    return false
end

function HeroModel:getHeroData(heroId)
    local heroData = self:getData()
    for k, v in pairs(heroData) do
        if tonumber(k) == tonumber(heroId) then
            return v
        end
    end
end

function HeroModel:getHeroCount()
    local count = 0
    local heroData = self:getData()
    if not heroData then return count end
    for k, v in pairs(heroData) do
        count = count + 1
    end
    return count
end

function HeroModel:getTopScoreHero()
    local heroData = self:getData()
    if not heroData then return 60102 end
    local topScore = 0
    local topSocreHeroId
    for k, v in pairs(heroData) do
        if heroData.score > topScore then
            topScore = heroData.score
            topSocreHeroId = tonumber(k)
        end
    end
    return topSocreHeroId
end

function HeroModel:isHeroCanUpgrade(heroId)
    local heroData = self:getHeroData(tonumber(heroId))
    if not heroData then return false end
    local star = self:getHeroData(tonumber(heroId)).star
    local heroTableData = tab:Hero(tonumber(heroId))
    if star >= 4 then return false end
    local cost = {}
    if 0 == star then
        cost = {[1] = heroTableData.unlockcost}
    else
        cost = heroTableData.starcost[star]
    end
    for k, v in pairs(cost) do
        local have, consume = 0, v[3]
        if "tool" == v[1] then
            local _, toolNum = self._modelMgr:getModel("ItemModel"):getItemsById(v[2])
            have = toolNum
        elseif "gold" == v[1] then
            have = self._modelMgr:getModel("UserModel"):getData().gold
        elseif "gem" == v[1] then
            have = self._modelMgr:getModel("UserModel"):getData().freeGem
        end
        if consume > have then
            return false
        end
    end
    return true
end

function HeroModel:isHeroRedTagShowByType(tagType)

    if not SystemUtils:enableHeroOpen() then return false end
    
    local found = true
    local formationModel = self._modelMgr:getModel("FormationModel")
    if HeroModel.kTagTypeSkill == tagType then
        local heroId = formationModel:getFormationDataByType(formationModel.kFormationTypeCommon).heroId
        local heroData = self:getHeroData(heroId)
        if heroData then
            local skillMaxLevel = tab:Setting("G_HERO_MAX_SKILL_LEVEL").value
            for i=1, 4 do
                repeat
                    found = true
                    local skillLevel = heroData["sl" .. i]
                    if skillLevel >= skillMaxLevel then break end
                    local skcost = 4 == i and tab:PlayerSkillExp(skillLevel).skcost2 or tab:PlayerSkillExp(skillLevel).skcost
                    for k, v in pairs(skcost) do
                        local have, consume = 0, v[3]
                        if "tool" == v[1] then
                            local _, toolNum = self._modelMgr:getModel("ItemModel"):getItemsById(v[2])
                            have = toolNum
                        elseif "gold" == v[1] then
                            have = self._modelMgr:getModel("UserModel"):getData().gold
                        elseif "gem" == v[1] then
                            have = self._modelMgr:getModel("UserModel"):getData().freeGem
                        end
                        if consume > have then
                            found = false
                            break
                        end
                    end

                    local levelLimited = tab:PlayerSkillExp(math.min(skillMaxLevel-1,skillLevel)).lvlim[i]
                    local userLevel = self._userModel:getPlayerLevel()
                    if levelLimited > userLevel then
                        found = false
                    end 
                until true
                if found then break end
            end
        end
    elseif HeroModel.kTagTypeMastery == tagType then
        found = false
    elseif HeroModel.kTagTypeSpecialty == tagType then
        found = false
    else
        for k, v in pairs(self._data) do
            repeat
                found = true
                local star = self:getHeroData(tonumber(k)).star
                local heroTableData = tab:Hero(tonumber(k))
                if star >= 4 then found = false break end
                local cost = {}
                if 0 == star then
                    cost = {[1] = heroTableData.unlockcost}
                else
                    cost = heroTableData.starcost[star]
                end
                for k, v in pairs(cost) do
                    local have, consume = 0, v[3]
                    if "tool" == v[1] then
                        local _, toolNum = self._modelMgr:getModel("ItemModel"):getItemsById(v[2])
                        have = toolNum
                    elseif "gold" == v[1] then
                        have = self._modelMgr:getModel("UserModel"):getData().gold
                    elseif "gem" == v[1] then
                        have = self._modelMgr:getModel("UserModel"):getData().freeGem
                    end
                    if consume > have then
                        found = false
                        break
                    end
                end
            until true
            if found then break end
        end
    end

    return found
end

function HeroModel:isHeroRedTagShowByIdAndType(heroId, tagType)
    if not SystemUtils:enableHeroOpen() then return false end
    if not self:checkHero(heroId) then return false end
    local found = true
    local formationModel = self._modelMgr:getModel("FormationModel")
    local pveHeroId = formationModel:getFormationDataByType(formationModel.kFormationTypeCommon).heroId
    if HeroModel.kTagTypeSkill == tagType then
        if pveHeroId ~= heroId then return false end
        local heroData = self:getHeroData(pveHeroId)
        local skillMaxLevel = tab:Setting("G_HERO_MAX_SKILL_LEVEL").value
        for i=1, 4 do
            repeat
                found = true
                local skillLevel = heroData["sl" .. i]
                if skillLevel >= skillMaxLevel then break end
                local skcost = 4 == i and tab:PlayerSkillExp(skillLevel).skcost2 or tab:PlayerSkillExp(skillLevel).skcost
                for k, v in pairs(skcost) do
                    local have, consume = 0, v[3]
                    if "tool" == v[1] then
                        local _, toolNum = self._modelMgr:getModel("ItemModel"):getItemsById(v[2])
                        have = toolNum
                    elseif "gold" == v[1] then
                        have = self._modelMgr:getModel("UserModel"):getData().gold
                    elseif "gem" == v[1] then
                        have = self._modelMgr:getModel("UserModel"):getData().freeGem
                    end
                    if consume > have then
                        found = false
                        break
                    end
                end

                local levelLimited = tab:PlayerSkillExp(math.min(skillMaxLevel-1,skillLevel)).lvlim[i]
                local userLevel = self._userModel:getPlayerLevel()
                if levelLimited > userLevel then
                    found = false
                end 
            until true
            if found then break end
        end
        -- 加可以判断
        local canOpenSlot,_,openLvl = SystemUtils:enableSkillBook()
        local star = heroData.star or 1
        local needStar = tab.setting["SKILLBOOK_LV"] and tab.setting["SKILLBOOK_LV"].value
        local isStarOk = star >= needStar

        if canOpenSlot and isStarOk then
            if not heroData.slot 
                or not heroData.slot.sid 
                or tonumber(heroData.slot.sid) == 0 
            then
                -- 多增加能否开孔判断
                local isAbounce = false
                local needUnlock = not heroData.slot
                if needUnlock then
                    local heroD = tab.hero[tonumber(heroData.id)]
                    local unlockD = heroD.scrollUnlock and heroD.scrollUnlock[1]
                    local cost = unlockD and unlockD[3]
                    local costType = unlockD and unlockD[1]
                    local costId = unlockD and unlockD[2]
                    local _,haveNum = self._modelMgr:getModel("ItemModel"):getItemsById(costId)
                    if costType ~= "tool" then
                        costId = IconUtils.iconIdMap[costType] or costId
                        haveNum = self._modelMgr:getModel("UserModel"):getData()[costType] or 0
                    end
                    haveNum = haveNum or 0
                    isAbounce = haveNum >= cost
                else
                    local isMatch=function( sid )
                        local spellFilterMap = {}
                        local heroD = tab.hero[tonumber(heroData.id)]
                        local spells = heroD.spell 
                        for k,v in pairs(spells) do
                            spellFilterMap[v] = true
                        end
                        local skillData = tab.skillBookBase[tonumber(sid)]
                        if not heroData.slot or not skillData then return false end
                        local tp = heroData.slot.tp or 0
                        local na = heroData.slot.na or 0
                        local isEquiped = false
                        if (tp == 5 or tp == skillData.type) and  
                           (na == 5 or na == skillData.nature)
                           and not spellFilterMap[tonumber(sid)]
                        then
                            return true
                        end
                        return false
                    end
                    local spellBooksInfo = self._modelMgr:getModel("SpellBooksModel"):getData() or {}
                    for k,v in pairs(spellBooksInfo) do
                        local isMatch = isMatch(k)
                        if isMatch and (not(v.b) or tonumber(v.b) == 0) then
                            isAbounce = true
                            break
                        end
                    end
                end
                found = isAbounce 
            end 
        end
            
    elseif HeroModel.kTagTypeMastery == tagType then
        if pveHeroId ~= heroId or not SystemUtils:enableHeroMastery() then return false end
        --found = (self._privilegesModel:getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_12) - self._playerTodayModel:getData().day4) > 0
        found = 0 == self._playerTodayModel:getData().day4
    elseif HeroModel.kTagTypeSpecialty == tagType then
        found = false
    else
        local star = self:getHeroData(tonumber(heroId)).star
        if star then
            local heroTableData = tab:Hero(tonumber(heroId))
            if star >= 4 then found = false return false end
            local cost = {}
            if 0 == star then
                cost = {[1] = heroTableData.unlockcost}
            else
                cost = heroTableData.starcost[star]
            end
            for k, v in pairs(cost) do
                local have, consume = 0, v[3]
                if "tool" == v[1] then
                    local _, toolNum = self._modelMgr:getModel("ItemModel"):getItemsById(v[2])
                    have = toolNum
                elseif "gold" == v[1] then
                    have = self._modelMgr:getModel("UserModel"):getData().gold
                elseif "gem" == v[1] then
                    have = self._modelMgr:getModel("UserModel"):getData().freeGem
                end
                if consume > have then
                    found = false
                end
            end
        end
    end

    return found
end

function HeroModel:isHeroRedTagShow()

    if not SystemUtils:enableHeroOpen() then return false end

    for tagType = HeroModel.kTagTypeSkill, HeroModel.kTagTypeEnd do
        if self:isHeroRedTagShowByType(tagType) then
            return true
        end
    end

    if self:hasHeroCanUnlock() then
        return true
    end

    -- 英雄传记有红点提示
    if self:isheroIconHaveNotice() then
        return true
    end

    if self:isHeroIconRedBySkin() then
        return true 
    end


    return self:getAllHeroStarRed()
end

function HeroModel:getHeroSpellReplace(heroId)
    if not self:checkHero(heroId) then 
        return {} 
    end
    local result = {}
    local t = {}
    local heroData = self:getHeroData(heroId)
    local heroTableData = tab:Hero(heroId)
    local star = heroData.star
    local special = heroTableData.special
    if not self._specialTableData then
        self._specialTableData = clone(tab.heroMastery)
        for k, v in pairs(self._specialTableData) do
            if 1 ~= v.class then
                self._specialTableData[k] = nil
            end
        end
    end

    local specialTableData = {}
    for k, v in pairs(self._specialTableData) do
        if special == v.baseid then
            table.insert(specialTableData, v)
        end
    end

    table.sort(specialTableData, function(a, b)
        return a.masterylv < b.masterylv
    end)

    for k, v in ipairs(specialTableData) do
        if special == v.baseid then
            if star >= v.masterylv and v.skreplace then
                for _, v0 in ipairs(v.skreplace) do
                    t[#t + 1] = v0
                end
            end
        end
    end

    local t1 = clone(t)
    t = {}
    for i=1, #t1 do
        repeat
            if t1[i][3] then break end
            local id = 0
            for j=i, #t1 do
                repeat
                    if t1[j][3] then break end
                    if t1[j][1] == t1[i][1] then
                        t1[j][3] = true
                        id = t1[j][2]
                    end
                until true
            end
            if 0 ~= id then
                t[#t + 1] = { [1] = t1[i][1], [2] = id }
            end
        until true
    end

    local checkHeroSpecialtyEffect = function(t, k)
        for _, v in pairs(t) do
            if v[1] == k[1] and v[2] == k[2] then
                return true
            end
        end

        return false
    end

    for i = 1, #t do
        if not checkHeroSpecialtyEffect(result, t[i]) then
            result[#result + 1] = t[i]
        end
    end

    return result
end

-- 提供给拍排行榜查看他人技能tips
-- 算法同 getHeroSpellReplace  HGF 17.10.09
function HeroModel:getHeroSpellReplaceByData(heroId,heroD)
    
    local result = {}
    local t = {}
    local heroData = heroD--self:getHeroData(heroId)
    local heroTableData = tab:Hero(heroId)
    local star = heroData.star
    local special = heroTableData.special
    if not self._specialTableData then
        self._specialTableData = clone(tab.heroMastery)
        for k, v in pairs(self._specialTableData) do
            if 1 ~= v.class then
                self._specialTableData[k] = nil
            end
        end
    end

    local specialTableData = {}
    for k, v in pairs(self._specialTableData) do
        if special == v.baseid then
            table.insert(specialTableData, v)
        end
    end

    table.sort(specialTableData, function(a, b)
        return a.masterylv < b.masterylv
    end)

    for k, v in ipairs(specialTableData) do
        if special == v.baseid then
            if star >= v.masterylv and v.skreplace then
                for _, v0 in ipairs(v.skreplace) do
                    t[#t + 1] = v0
                end
            end
        end
    end

    local t1 = clone(t)
    t = {}
    for i=1, #t1 do
        repeat
            if t1[i][3] then break end
            local id = 0
            for j=i, #t1 do
                repeat
                    if t1[j][3] then break end
                    if t1[j][1] == t1[i][1] then
                        t1[j][3] = true
                        id = t1[j][2]
                    end
                until true
            end
            if 0 ~= id then
                t[#t + 1] = { [1] = t1[i][1], [2] = id }
            end
        until true
    end

    local checkHeroSpecialtyEffect = function(t, k)
        for _, v in pairs(t) do
            if v[1] == k[1] and v[2] == k[2] then
                return true
            end
        end

        return false
    end

    for i = 1, #t do
        if not checkHeroSpecialtyEffect(result, t[i]) then
            result[#result + 1] = t[i]
        end
    end

    return result
end


function HeroModel:isSpellReplaced(heroId, spellId)
    local starReplaceId = self:isSpellReplacedByStar(heroId, spellId)
    if starReplaceId then
        return true,starReplaceId
    end
    local currentHeroSpecialEffect = self:getHeroSpellReplace(heroId)
    for _, v in ipairs(currentHeroSpecialEffect) do
        if spellId == v[1] then
            return true, v[2]
        end
    end 
    return false
end

--星图专精替换技能
function HeroModel:isSpellReplacedByStar(heroId, spellId)
    local hStar = self._userModel:getData()["hStar"]
    if hStar == nil or next(hStar) == nil then
        return nil
    end
    local starTable = tab.starCharts
    local starCatenaTable = tab.starChartsCatena
    local heroMasteryTable = tab.heroMastery
    local starInfo = nil
    for _ , v in pairs(starTable) do
        if tonumber(heroId) == tonumber(v.hero) then
            starInfo = v
        end
    end

    --判断分支是否被激活
    local catennaOrlock = function (id)
        for catenId,catenNum in pairs(hStar.scmap or {}) do
            if tonumber(id) == tonumber(catenId) and tonumber(catenNum) ~= 0 then
                return true
            end
        end
        return false
    end

    local getReplaceId = function(masteryId)
        local skreplace = heroMasteryTable[masteryId]["skreplace"]
        if skreplace and next(skreplace) then
            for _ , data in pairs(skreplace) do
                if tonumber(spellId) == tonumber(data[1]) then
                    return data[2]
                end
            end
        end
        return nil
    end

    if starInfo then
        --星链激活专精id
        for _ , id in pairs(starInfo["catena_id"]) do
            if catennaOrlock(id) then
                local masteryId = starCatenaTable[id]["heromasteryid"]
                if masteryId and getReplaceId(masteryId) then
                    return getReplaceId(masteryId)
                end
            end
        end
        --星图构成专精
        for hId , count in pairs(hStar.smap or {}) do
            if tonumber(hId) == tonumber(heroId) and tonumber(count) ~= 0 then
                local masteryId = starInfo["heromasteryid"]
                if masteryId and getReplaceId(masteryId) then
                    return getReplaceId(masteryId)
                end
            end
        end
    end
    return nil
end

-- 提供给拍排行榜查看他人技能tips
-- 仿写 isSpellReplaced  HGF 17.10.09
function HeroModel:isSpellReplacedByData(heroId, spellId,heroD)
    local currentHeroSpecialEffect = self:getHeroSpellReplaceByData(heroId,heroD)
    for _, v in ipairs(currentHeroSpecialEffect) do
        if spellId == v[1] then
            return true, v[2]
        end
    end 
    return false
end


function HeroModel:getHeroGrade(heroId)
    if not self:checkHero(heroId) then return 0 end
    local heroData = self:getHeroData(heroId)
    local masteryLv = 0
    -- dump(heroData, "============="..heroId)
    for i=1, 4 do
        local masteryData = tab:HeroMastery(heroData["m" .. i])
        masteryLv = masteryLv + masteryData.masterylv
    end
    local userLevel = self._userModel:getPlayerLevel()
    local skillLevel = 0
    local skillMaxLevel = 0
    for i=1, 4 do
        if i <= 3 then
            skillLevel = skillLevel + heroData["sl" .. i]
        else
            skillMaxLevel = heroData["sl" .. i]
        end
    end
    local score = ((heroData.star * 3.6 + masteryLv * 1.35 + 3.6) * userLevel + (skillLevel + skillMaxLevel * 2) * 8) * 1.3 + 500
    return math.floor(score+0.99)
end

function HeroModel:isHeroLoaded(heroId)
    heroId = tonumber(heroId)
    if not self:checkHero(heroId) then
        return false
    end

    local formationModel = self._modelMgr:getModel("FormationModel")
    local formationData = formationModel:getFormationDataByType(formationModel.kFormationTypeCommon)
    if not formationData.heroId then return false end
    return heroId == tonumber(formationData.heroId)
end


---- 英雄传记
-- 初始化英雄传记
function HeroModel:initHeroBiography(hId,data)
    
    -- dump(data,"biography==>")  
    -- 服务器返回的key 是string
    local sBioData = data.biogra
    if sBioData then
        local heroId = tonumber(hId)
        self._heroBio[heroId] = sBioData  
    end
    --[[
    for i=1,5 do
        local bioData = self._heroBio[heroId]
        bioData[i] = {}
        if sBioData and sBioData[tostring(i)] then
            bioData[i].num = sBioData[tostring(i)]
            -- 如果没有完成所有传记 计算总的完成进度
            -- 已完成状态是时间戳  
            if i ~= 1 and bioData[1].num ~= -1 and bioData[i].num > 100000000 then 
                bioData[1].num = bioData[1].num + 1
            end
            -- print("=============1321313===============",k,v)
            if -1 == bioData[i].num then
                -- 需要红点提示
                bioData[i].isRedNotice = true
            else                
                bioData[i].isRedNotice = false
            end

        else
            bioData[i].num = 0
            bioData[i].isRedNotice = false
        end               
    end    
    ]]
end

-- 解锁英雄 初始化新英雄传记
function HeroModel:unLockHeroBiography(hero)
    for k, v in pairs(hero) do
        self:updateHeroBiography(k,v)        
    end
end

-- 获取某个英雄的所有传记
function HeroModel:getBiographyDataByHeroId(heroId)
    -- dump(self._heroBio[tonumber(heroId)],"===>")
    return self._heroBio[tonumber(heroId)] or {}
end

function HeroModel:updateHeroBiography(hId,data)   
    local heroId = tonumber(hId)
    local sBioData = data.biogra or {}
    -- dump(self._heroBio,"self._heroBio",5)

    if not self._heroBio[heroId] then
        self:initHeroBiography(heroId,data) 
    else
        local bioData = self._heroBio[heroId]
        for k,v in pairs(sBioData) do
            -- 某条传记数据
            if bioData[k] then
                for kk,vv in pairs(v) do
                    if kk == "conds" then
                        for kkk,vvv in pairs(vv) do
                            bioData[k]["conds"][kkk] = vvv
                        end
                    else
                        bioData[k][kk] = vv
                    end
                end
            else
                bioData[k] = v
            end

        end
    end
    -- local bioData = self._heroBio[heroId]
    -- if sBioData then
    --     for k,v in pairs(sBioData) do
    --         bioData[tonumber(k)].num = tonumber(v)
    --         -- 如果没有完成所有传记 计算总的完成进度
    --         if tonumber(k) ~= 1 and bioData[1].num ~= -1 and bioData[tonumber(k)].num > 100000000 then 
    --             bioData[1].num = bioData[1].num + 1
    --         end
    --         if -1 == tonumber(v) then
    --             -- 需要红点提示
    --             bioData[tonumber(k)].isRedNotice = true
    --         else                
    --             bioData[tonumber(k)].isRedNotice = false
    --         end
    --     end
    -- end

end
-- 更新传记数据
function HeroModel:updateBioData(heros)
    if not heros then return end
    -- dump(heros,"==>",5)
    for k,v in pairs(heros) do
        self:updateHeroBiography(k,v)
    end

end

--更新某个传记的红点信息
function HeroModel:setBioRedNotice(heroId,idx,isNotice)   
    local heroBioData = self._heroBio[heroId]
    if heroBioData and heroBioData[idx] then
        heroBioData[idx].isRedNotice = isNotice
    end

end

-- 传记红点  主界面英雄icon是否显示红点
function HeroModel:isheroIconHaveNotice( )
    if not SystemUtils:enableHeroBio() then return false end
    local haveNotice = false
    local heroBio = self._heroBio or {}
    for k,v in pairs(heroBio) do
        if haveNotice then
            break
        end
        local heroData = tab:Hero(tonumber(k))
        if heroData and heroData.heroBioID then
            haveNotice = self:isHaveNoticeByheroId(k)
        end
        -- for i,value in pairs(v) do
        --     if value.isRedNotice then
        --         if i ~= 1 and (value.num > 0 or -1 == value.num) then
        --             -- 解锁某个传记 并且没有被点击过
        --             haveNotice = not SystemUtils.loadAccountLocalData("BIOGRAPHY_RED_" .. heroId .. "0" .. i)
        --         end
        --         break
        --     end
        -- end
    end    
    return haveNotice
end

-- 根据英雄id判断传记按钮是否显示红点
function HeroModel:isHaveNoticeByheroId(heroId)
    local haveNotice = false
    local bioData = self._heroBio[heroId] or {}
    for k,v in pairs(bioData) do
        if haveNotice then 
            break
        end

        -- 宝箱是否有可以领取
        local isHaveBox = v.pTime and v.pTime > 10000000 and (not v.box or v.box == 0) 
        haveNotice = isHaveBox 

        -- 可以挑战并且传记没被点击过
        if not haveNotice then
            if v.pTime and v.pTime == 1 then
                haveNotice = not SystemUtils.loadAccountLocalData("BIOGRAPHY_RED_" .. k)
            end
        end
       
    end
    return haveNotice
end

-- 更新传记 carry数据
function HeroModel:onChangeBiography(data)
    if not data._carry_ then return end
    -- dump(data._carry_,"carry==>",20)
    if data._carry_.heroBio then
        for k,v in pairs(data._carry_.heroBio) do
            if not v.biogra then 
                break 
            end
            self:updateHeroBiography(k,v)
        end
        self:setCurrBioTipsData(data._carry_.heroBio)
        -- dump(self._currBioTip,"self._currBioTip===>",5)
        if self._currBioTip and table.nums(self._currBioTip) > 0 then 
            self._viewMgr:biographyChangeTip()
        end
    end
end

-- 设置当前传记tips展示数据
function HeroModel:setCurrBioTipsData(bioData)
    self._currBioTip = {}
    local bioIdArr = self:getCurrBioIdByHeroId(bioData)
    -- dump(bioIdArr,"bioIdArr==>",5)
    -- dump(bioData,"bioData==>",5)
    for k,v in pairs(bioData) do
        if not v.biogra then
            break
        end
        for i,bio in pairs(bioIdArr) do            
            local hId = bio.hId or 0
            if tonumber(k) == tonumber(hId) then
                local currBioId = bio.bioId or 0            
                for kk,vv in pairs(v.biogra) do
                    -- 通关前置关卡条件不需要提示 "1"
                    if tonumber(currBioId) == tonumber(kk) and vv["conds"] and vv["conds"]["2"] then
                        if not self._currBioTip[tonumber(k)] then 
                            self._currBioTip[tonumber(k)] = {}
                        end
                        self._currBioTip[tonumber(k)][kk] = vv
                        break
                    end
                end  
            end          
        end
    end

end

function HeroModel:getCurrBioTipsData()
    return self._currBioTip or {}
end

-- 获取当前正在进行的传记id
function HeroModel:getCurrBioIdByHeroId(bioData)
    local bioIdArr = {}
    local heroBio
    for k,v in pairs(bioData) do
        heroBio = self:getBiographyDataByHeroId(k)
        for kk,vv in pairs(heroBio) do
            -- dump(vv,"vvvvvvvv",5)
            if  (not vv.pTime or vv.pTime < 2) 
                and 
                (vv.conds and vv.conds["1"] and vv.conds["1"]["finish"] and vv.conds["1"]["finish"] == 1)
            then
                local bioArr = {}
                bioArr.bioId = tonumber(kk)
                bioArr.hId = tonumber(k)
                table.insert(bioIdArr, bioArr)
                -- break
            end
        end        
    end

    return bioIdArr
end

-- 根据英雄id获取英雄有没有解锁传记获得皮肤
function HeroModel:isBioUnlockByHeroId(heroId)
    local heroBio = self:getBiographyDataByHeroId(heroId)
    local isUnlock = false
    local i = 0
    for k,v in pairs(heroBio) do
        if v and v.pTime and v.pTime > 10000000 then
            i = i + 1
        end
    end
    if i == 5 then
        isUnlock = true
    end
    return isUnlock
end

-- 根据英雄id更新皮肤信息
function HeroModel:updateHeroSkin(heroData)
    if not heroData then return end 

    for k,v in pairs(heroData) do
        if self._data[tostring(k)] and v.skin then
            self._data[tostring(k)].skin = v.skin 
        end
    end
end

-- 皮肤红点  主界面英雄icon是否显示红点
function HeroModel:isHeroIconRedBySkin( )
    local haveNotice = false
    if not self._data then return end
    for k,v in pairs(self._data) do
        if haveNotice then 
            break
        end
        haveNotice = self:isSkinHaveNoticeById(k)
    end 
    return haveNotice
end
-- 根据英雄ID获取皮肤红点
-- 规则：有新皮肤未被点击则显示红点
function HeroModel:isSkinHaveNoticeById(heroId)
   
    local serverSkin = self._userModel:getSkinDataById(heroId)
    local isNeedRed = false

    local redInfo = {}
    local jsonStr = SystemUtils.loadAccountLocalData("HEROSKIN_REDNOTICE_CLICKDATA" .. heroId)
    if jsonStr and jsonStr ~= "" and jsonStr ~= "null" then            
        redInfo = json.decode(jsonStr)
    else            
        redInfo = {}
    end
    
    -- 数量不一样则说明有皮肤未被点击
    if table.nums(serverSkin) ~= table.nums(redInfo) then
        isNeedRed = true
    end

    return isNeedRed
end

-- 根据皮肤ID判断皮肤是否获得
function HeroModel:isHaveSkinBySkinId(skinId)
    local isHaveSkin = false 
    if not skinId then return isHaveSkin end

    local skinidStr = tostring(skinId)
    if not skinidStr then return isHaveSkin end 
    
    local heroId = string.sub(skinidStr,2 ,string.len(skinidStr) - 2)
    local serverSkin = self._userModel:getSkinDataById(heroId)
    if serverSkin and serverSkin[tostring(skinId)] then 
        isHaveSkin = true 
    end
    return isHaveSkin 
end

-- 根据配表索引获取皮肤特效名称
function HeroModel:getSkinMcNameByIndex(idx)
    if not self._skinMcName then 
        self._skinMcName = {
            [1] = "weideninapifutexiao_weideninapifu",
            [2] = "guowangganenjiepifutexiao_guowangganenjie",
        }
    end
    if not idx then return nil end 
    return self._skinMcName[tonumber(idx)]
end

-- 通过星级来获得 英雄收集 增加的属性 by guojun 2017.2.2
function HeroModel:caculateHeroCollectAttr( )
    local attrs = {atk=0,def=0,int=0,ack=0}
    -- dump(self._data)
    for k,v in pairs(self._data) do
        local heroD = tab.hero[tonumber(k)]
        for attName,v1 in pairs(attrs) do
            if heroD[attName] then
                local base = heroD[attName][1]
                local up   = heroD[attName][2]
                attrs[attName] = attrs[attName] + base + (v.star-1)*up
            end
        end
    end
    return attrs
end

-- 通过玩家身上的 uMastery 来计算全局属性
function HeroModel:caculateHeroMasteryAttr( )
    local uMastery = self._modelMgr:getModel("UserModel"):getData().uMastery 
    local attrs = {atk=0,def=0,int=0,ack=0}
    local changeMap = {[110] = "atk",[113] = "def", [116]="int",[119] = "ack"}
    if uMastery then
        for id,lvl in pairs(uMastery) do
            -- print(id,lvl)
            local masteryD = tab.heroMastery[tonumber(id)]
            if masteryD then
                local morale    = masteryD.morale
                -- dump(morale)
                if morale and morale[1] then
                    local attType   = morale[1][1]
                    local attNum    = morale[1][2]*(tonumber(lvl) or 0)
                    local changeType = changeMap[tonumber(attType)]
                    if changeType then
                        attrs[changeType] = attrs[changeType]+attNum
                    end
                end
            end
        end
    end
    return attrs
end

-- 获取英雄皮肤属性
function HeroModel:getHeroSkinAttr(hSkin)
    local attrs = {atk=0,def=0,int=0,ack=0}
    local changeMap = {[101] = "atk",[102] = "def", [103]="int",[104] = "ack"}
    local skinData = hSkin or self._userModel:getUserSkinData()
    local skinTb = tab.heroSkin
    for k,v in pairs(skinData) do
        for kk,vv in pairs(v) do
            local tempData = skinTb[tonumber(kk)]
            if tempData and tempData.addAttr then
                for key,value in pairs(tempData.addAttr) do                    
                    local changeType = changeMap[tonumber(value[1])]
                    if changeType then
                        attrs[changeType] = attrs[changeType]+tonumber(value[2])
                    end
                end
            end
        end
    end
    return attrs
end

-- 仿写 npc英雄的 isSpellReplaced 方法
function HeroModel:isNpcSpellReplaced( heroData,heroId,spellId )
    if not heroData then return false,spellId end
    local result = {}
    local t = {}
    local heroTableData = tab:Hero(heroId)
    -- print(heroId,"heroId",type(heroId))
    if not heroTableData then return false,spellId end
    local star = heroData.star
    local special = heroTableData.special
    if not self._specialTableData then
        self._specialTableData = clone(tab.heroMastery)
        for k, v in pairs(self._specialTableData) do
            if 1 ~= v.class then
                self._specialTableData[k] = nil
            end
        end
    end

    local specialTableData = {}
    for k, v in pairs(self._specialTableData) do
        if special == v.baseid then
            table.insert(specialTableData, v)
        end
    end

    table.sort(specialTableData, function(a, b)
        return a.masterylv < b.masterylv
    end)

    for k, v in ipairs(specialTableData) do
        if special == v.baseid then
            if star >= v.masterylv and v.skreplace then
                for _, v0 in ipairs(v.skreplace) do
                    t[#t + 1] = v0
                end
            end
        end
    end

    local t1 = clone(t)
    t = {}
    for i=1, #t1 do
        repeat
            if t1[i][3] then break end
            local id = 0
            for j=i, #t1 do
                repeat
                    if t1[j][3] then break end
                    if t1[j][1] == t1[i][1] then
                        t1[j][3] = true
                        id = t1[j][2]
                    end
                until true
            end
            if 0 ~= id then
                t[#t + 1] = { [1] = t1[i][1], [2] = id }
            end
        until true
    end

    local checkHeroSpecialtyEffect = function(t, k)
        for _, v in pairs(t) do
            if v[1] == k[1] and v[2] == k[2] then
                return true
            end
        end

        return false
    end

    for i = 1, #t do
        if not checkHeroSpecialtyEffect(result, t[i]) then
            result[#result + 1] = t[i]
        end
    end

    local currentHeroSpecialEffect = result
    for _, v in ipairs(currentHeroSpecialEffect) do
        if spellId == v[1] then
            return true, v[2]
        end
    end 
    return false
 end 

-- 获取英雄的星级
 function HeroModel:getHeroStar( heroId )
    local data = self:getHeroData(tonumber(heroId))
    if data then
        star = data.star
    else
        star = 0
    end
    return star
 end

 local mergeB2AData
mergeB2AData = function( ta,tb )
    if not ta or not next(ta) then 
        ta = tb  
        return tb
    end
    if not tb then return ta end 
    for k,v in pairs(tb) do
        if type(v) ~= "table" then 
            ta[k] = v
        else
            ta[k] = mergeB2AData(ta[k],v)
        end
    end
    return ta
end

function HeroModel:mergeHeroData( ta,tb )
    mergeB2AData(ta,tb)
end

-- 判断法术刻印  slotType 传入特定的孔类型
function HeroModel:isHaveUnlockSlot( num,slotNature )
    num = num or 0
    local slotNum = 0
    local isOpen = SystemUtils:enableSkillBook()
    if not isOpen then return false,0 end
    -- local needStar = tab.setting["SKILLBOOK_LV"] and tab.setting["SKILLBOOK_LV"].value or 4
    for k,v in pairs(self._data) do
        if v.slot then
            if not slotNature then
                slotNum = slotNum + 1
            elseif v.slot.na and v.slot.na == slotNature then
                slotNum = slotNum + 1
            end
        end  
    end
    return slotNum >= num,slotNum
end

--获取英雄战力
function HeroModel:getHeroScore(heroId)
    local heroData = self:getData()
    for k, v in pairs(heroData) do
        if tonumber(k) == tonumber(heroId) then
            return v["score"]
        end
    end
    return 0
end

--星图数据
function HeroModel:getStarInfo(heroId)
    if heroId == nil then return nil end
    local heroData = self:getHeroData(heroId)
    if not heroData or heroData["sc"] == nil then return nil end
    return heroData["sc"]
end

--删除英雄星图突破加成属性
function HeroModel:handelUnsetStarItems(inData)
    local tempData = {}
    local index = 1
    for k,v in pairs(inData) do
        tempData[index] = {}
        if string.find(k, ".") ~= nil then
            local temp = string.split(k, "%.")
            if #temp >= 2 then
                tempData[index]["heroId"] = temp[2]
            end
            if #temp >= 3 then
                tempData[index]["key1"] = temp[3]
            end
            if #temp >= 4 then
                tempData[index]["key2"] = temp[4]
            end
            index = index + 1
        end
    end
    dump(tempData)
    return tempData
end

function HeroModel:delItems(inItems)
    for k , v in pairs(self._data) do
        if tonumber(k) == tonumber(inItems["heroId"]) then
            if v[inItems["key1"]] ~= nil and v[inItems["key1"]][inItems["key2"]] ~= nil then
                v[inItems["key1"]][inItems["key2"]] = nil
            end
        end
    end
end


--星图是否开启
function HeroModel:starOrOpen(heroId)
    local starTable = tab.starCharts
    for _ , v in pairs(starTable) do
        if tonumber(heroId) == tonumber(v.hero) then
            return true
        end
    end
    return false
end

--英雄星图红点判断
function HeroModel:haveHeroStarRed(heroId)
    local firstEnter = SystemUtils.loadAccountLocalData("STARCHARTS_IS_FIRSEENTER")   --第一次进入
    if firstEnter then return false end
    local heroData = self:getHeroData(heroId)
    if not heroData then return false end                    --是否解锁
    local openLevel = tab:SystemOpen("starCharts")[1]
    local userLv = self._modelMgr:getModel("UserModel"):getData().lvl     --开启等级判断
    if userLv < openLevel then return false end
    if not self:starOrOpen(heroId) then return false end 
    return true
end
--获取所有英雄红点显示的条件
function HeroModel:getAllHeroStarRed()
    local firstEnter = SystemUtils.loadAccountLocalData("STARCHARTS_IS_FIRSEENTER")   --第一次进入
    if firstEnter then return false end
    local openLevel = tab:SystemOpen("starCharts")[1]
    local userLv = self._modelMgr:getModel("UserModel"):getData().lvl     --开启等级判断
    if userLv < openLevel then return false end
    for id , v in pairs(self._data) do                                 
        if self:starOrOpen(tonumber(id)) then
            return true 
        end 
    end
    return false
end

--英雄星图是否构成
function HeroModel:isCompleted(heroId)
    local scInfo = self:getStarInfo(heroId)
    if scInfo and scInfo["cf"] then
        if tonumber(scInfo["cf"]) == 1 then
            return true
        end
    end
    return false
end

return HeroModel