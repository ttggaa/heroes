--[[
    Filename:    GuildMapListen.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2017-06-18 13:43:04
    Description: File description
--]]

local CityBattleWorldLayer = require("game.view.citybattle.CityBattleWorldLayer")



function CityBattleWorldLayer:listenModelShowBattleTip(inData)
    self:handleListenModelShowBattleTip(inData)
end



--[[
--! @function handleListenModelShowBattleTip
--! @desc 更新城池信息
--! @param 
--! @return 
--]]
function CityBattleWorldLayer:handleListenModelShowBattleTip(otherEvent)
    if self._lockBattleTip ==  true then 
        return
    end
    -- 派遣时临时锁住1秒通知，因为要播放派遣动画，防止锁屏出现
    if self._lockBattleTipTime ~= nil and self._lockBattleTipTime > os.time() then return end

    local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime() 
    local limitTime = SystemUtils.loadAccountLocalData("CITYBATTLE_TIP_TIME_LIMIT")
    if limitTime ~= nil and limitTime > curTime then 
        return
    end
    local formationInfo = otherEvent[1]
    
    local tip = lang("CITYBATTLE_TIP_05")
    local sysCityBattle = tab:CityBattle(tonumber(formationInfo.cid))
    if sysCityBattle == nil then return end
    local cityData = self._cityBattleModel:getData()
    local cityInfos = cityData.c.c
    -- local mineSec = self._cityBattleModel:getMineSec()
    if cityInfos[formationInfo.cid].b == tostring(self._sec) then return end
    local cutLine = 1

    local cityTab = tab:CityBattle(tonumber(formationInfo.cid))
    if cityTab ~= nil then 
        cutLine = cityTab.atknum
    end
    if formationInfo.fid == nil then print("==================================formationInfo.fid =================nil=======") end
    if cityData["f"][formationInfo.fid] == nil or cityData["f"][formationInfo.fid].i > cutLine or cityData["f"][formationInfo.fid].i == -1 then return end
    self._lockBattleTip = true

    tip, count = string.gsub(tip, "{$city}", lang(sysCityBattle.name))
    self._viewMgr:showDialog("citybattle.CityBattleBattleEnterDialog",
        {desc = tip,
        button1 = "确定", 
        button2 = "取消" ,
        callback1 = function ()
            self._lockBattleTip = false
            self:resetSelectedCityState()
            self:screenToCity(formationInfo.cid, function()
                self._viewMgr:showView("citybattle.CityBattleFightView", {cityId = formationInfo.cid})
            end)
        end,
        callback2 = function(inSelected)
            self._lockBattleTip = false
            if inSelected == true then 
                local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime() 
                local limitTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 23:59:59"))
                SystemUtils.saveAccountLocalData("CITYBATTLE_TIP_TIME_LIMIT", limitTime)
            end
        end})
end


function CityBattleWorldLayer:listenModelUFormation_CUR(inData)
    self:handleListenModelUFormation_CUR(inData)
end



--[[
--! @function handleListenModelUpdateFormation
--! @desc 更新城池信息
--! @param 
--! @return 
--]]
function CityBattleWorldLayer:handleListenModelUFormation_CUR(otherEvent)
    self._parentView:reflashFormationInfo()
end



function CityBattleWorldLayer:listenModelDMiniIcon_CUR(inData)
    self:handleListenModelDMiniIcon_CUR(inData)
end

--[[
--! @function handleListenModelDMiniIcon_CUR
--! @desc 删除已经被迁走的mini图标
--! @param 
--! @return 
--]]
function CityBattleWorldLayer:handleListenModelDMiniIcon_CUR(otherEvent)
    for k,v in pairs(otherEvent) do
        local formation = self._formationModel:getFormationDataByType(tonumber(k))
        if formation ~= nil and formation["heroId"] ~= nil then
            self:removeCityMiniHeroIcon(v, formation["heroId"])
        end
    end
end

function CityBattleWorldLayer:listenModelUFormation(inData)
    -- local otherEvent = self._cityBattleModel:getEvents()["UFormation"]
    self:handleListenModelUFormation(inData)
    -- self._cityBattleModel:getEvents()["UFormation"] = nil
end


-- function CityBattleWorldLayer:listenModelUFormation()
--     local otherEvent = self._cityBattleModel:getEvents()["UFormation"]
--     self:handleListenModelUFormation(otherEvent)
--     self._cityBattleModel:getEvents()["UFormation"] = nil
-- end

--[[
--! @function handleListenModelUpdateFormation
--! @desc 更新城池信息
--! @param 
--! @return 
--]]
function CityBattleWorldLayer:handleListenModelUFormation(otherEvent)


    if otherEvent == nil or otherEvent["f"] == nil then return end
    local cityData = self._cityBattleModel:getData()
    for k,v in pairs(otherEvent["f"]) do
        local fIndex = self._formationWithIndex[tonumber(k)]
        -- handleJavaCallback10004 的时候可能出现cid为nil，因为被打走了
        local formation = self._formationModel:getFormationDataByType(tonumber(k))
        if (cityData["f"][k] == nil or cityData["f"][k]["i"] == -1) then
            if v["cid"] ~= nil then 
                self:removeCityMiniHeroIcon(v["cid"], formation["heroId"])
            end
        else
            self:updateCityMiniHeroIconState(cityData["f"][k]["cid"], formation["heroId"])
        end
        self:updateDialFormation(self._selectedCityId, tonumber(fIndex))
    end
    
    self._parentView:reflashFormationInfo()
end


function CityBattleWorldLayer:listenModelUCityInfo(inData)
    self:handleListenModelUCityInfo(inData)
end


--[[
--! @function handleListenModelUCityInfo
--! @desc 更新城池信息
--! @param 
--! @return 
--]]
function CityBattleWorldLayer:handleListenModelUCityInfo(otherEvent)
    local cityData = self._cityBattleModel:getData()
    local cityInfos = cityData.c.c
    local fmInfos = cityData.f
    local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime() 
    local changeMaster = 0

    local changeNearCity = {}

    local updateNearCityFormation = {}
    local isRevert = GameStatic.revertGvg_rebuild
    for k,v in pairs(otherEvent) do
        self:updateDialPanelInfo(tonumber(k))
        local sysCityBattleMap = tab.cityBattleMap[tonumber(k)]
        self:updateAreaState(sysCityBattleMap, cityInfos)
        local sysCityBattle = tab.cityBattle[tonumber(k)]
        -- 更新周边城池状态
        for k1,v1 in pairs(sysCityBattle.nearby) do
            local sysCityBattleMap1 = tab.cityBattleMap[tonumber(v1)]
            self:updateAreaState(sysCityBattleMap1, cityInfos)
        end
        -- 废墟恢复中
        local cityInfo = cityInfos[tostring(k)]

        if cityInfo.t ~= nil and 
            cityInfo.t > curTime then
            table.insert(self._cityFallTips, k)
            for k1,v1 in pairs(sysCityBattle.nearby) do
                local newarCityInfo = cityInfos[tostring(v1)]
                if tostring(newarCityInfo.b) == tostring(self._sec) then
                    changeNearCity[v1] = 1
                end
            end
            for k1,v1 in pairs(fmInfos) do
                if isRevert and v1.cid ==  tostring(k) then 
                    changeMaster = 1 
                end
                if changeNearCity[v1.cid] ~= nil then 
                    updateNearCityFormation[k1] = v1.cid
                end
            end
        end
    end

    if next(updateNearCityFormation) ~= nil then 
        for k,v in pairs(updateNearCityFormation) do
            local fIndex = self._formationWithIndex[tonumber(k)]
            self:updateDialFormation(v, tonumber(fIndex))
        end
    end
    
    if #self._cityFallTips > 0 then 
        self:activeFallTipShow()
    end
    -- self._parentView:reflashServerNum()
    if changeMaster == 1 then 
        self:getPlayerFormation()
    end
end



