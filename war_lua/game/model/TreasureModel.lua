--[[
    Filename:    TreasureModel.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2016-01-27 15:05:43
    Description: File description
--]]

local TreasureModel = class("TreasureModel", BaseModel)
local maxComStage
local maxDisStage
function TreasureModel:ctor()
    TreasureModel.super.ctor(self)
    self._data = {}
    self._checkValue = BattleUtils.checkTreasureData(self._data)

end

function TreasureModel:setData(data)
    self._data = data or {}
    self:recountCheck()
    self:reflashData()
end

function TreasureModel:getData()
    return self._data
end

-- 验证数据用
function TreasureModel:recountCheck()
    self._checkValue = BattleUtils.checkTreasureData(self._data)
end

function TreasureModel:getCheckValue()
    return self._checkValue
end

function TreasureModel:checkData()
    if self._checkValue ~= BattleUtils.checkTreasureData(self._data) then
        return self._data
    end
end

function TreasureModel:getTreasureScore( )
    if not self._data then return end
    local comScore = 0
    local disScore = 0
    for k,v in pairs(self._data) do
        if type(v) == "table" then
            comScore = comScore + (v.comScore or 0)
            disScore = disScore + (v.disScore or 0)
        end
    end
    return (comScore or 0) + (disScore or 0),comScore,disScore
end


-- 自己计算散件战斗力 2017.4.22
function TreasureModel:caculateDisTreasureScore( disId,isPreStar,inStage )
    -- 服务端数据
    local disInfo  = self:getTreasureById(disId)
    local stage = inStage or (disInfo and disInfo.s or 0)
    local bigStar = disInfo and disInfo.bs or 0
    local smallStar = disInfo and disInfo.ss or 0
    local starScale = disInfo and disInfo.b or 0
    -- local star = disInfo and disInfo.bs
    -- 静态表数据
    local disData = tab.disTreasure[disId]
    local fightNumTab = disData.fightNum

    -- 升星表
    local starIdx = bigStar*8+smallStar+math.floor(starScale/100)
    if isPreStar then
        starIdx = starIdx-1
    end
    local upStarData = tab.comTreasureStar[starIdx]
    -- 升星额外属性
    local starAttr = 0
    if upStarData then
        starAttr = upStarData.powerprosum*0.01
    end
    -- 基数  ：战斗力计算为 属性得到的系数乘基数
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local level = userData.lvl or userData.level
    local heroPower = tab:HeroPower(tonumber(level) or 1)
    local baowuScoreBase = heroPower.baowu

    -- 计算额外加成  系数
    local unlockData = disData.unlockaddattr
    local exAttr = 0
    for i,v1 in ipairs(unlockData) do
        if stage >= v1 then
            exAttr = exAttr+fightNumTab[3]
        end
    end
    
    local score = baowuScoreBase*(fightNumTab[1]+fightNumTab[2]*(stage-1)+exAttr)*(1+starAttr)
    print("dis score id=",disId,"score = ",score,string.format("%d",score))
    score = math.ceil(score) --string.format("%d",score)

    return score
end

-- 获得散件宝物修正后的战斗数值
function TreasureModel:getCorrectDisScore( disId,isPreStar )
    if self:isLastDisInCom(disId) then
        return self:getComLastDisScore( disId ,nil,isPreStar)
    else
        return self:caculateDisTreasureScore( disId ,isPreStar)
    end
end

-- 获得组合宝物最后一个宝物的战斗力 用于处理偏差
function TreasureModel:getComLastDisScore( disId,comId,isPreStar )
    -- 最后一个散件做数值矫正 偏差值为 1~6 
    comId = comId or self:getComIdByDisId(disId) -- 传入comId减少计算次数
    local comData = tab.comTreasure[tonumber(comId)]
    local comInfo = self:getTreasureById(comId)
    local lastScore = 0
    if comInfo and comInfo.treasureDev then
        local disScoreSum = 0
        for k,v in pairs(comInfo.treasureDev) do
            if tonumber(k) ~= tonumber(disId) and v.s > 0 then
                disScoreSum = disScoreSum + self:caculateDisTreasureScore(tonumber(k),isPreStar)
            end
        end
        lastScore = comInfo.disScore - disScoreSum
    end

    return lastScore
end

-- 是否为组合最后一个id
function TreasureModel:isLastDisInCom( disId )
    -- 最后一个散件做数值矫正 偏差值为 1~6 
    local comId = self:getComIdByDisId(disId)
    local comData = tab.comTreasure[tonumber(comId)]
    local comInfo = self:getTreasureById(comId)
    local form = comData.form 
    local lastId = 0
    if comInfo and comInfo.treasureDev then
        for k,v in pairs(comInfo.treasureDev) do
            if lastId < tonumber(k) and v.s > 0 then 
                lastId = tonumber(k)
            end
        end
    else
        lastId = form[#form]
    end
    print("lastId ..is ",lastId)

    return disId == lastId
end

function TreasureModel:getComTreasureById( id )

    return self._data[tostring(id)]
end

function TreasureModel:getComIdByDisId( disId )
    disId = tostring(disId or 0)
    if not self._dis2Com then self._dis2Com = {} end
    if not self._dis2Com[disId] then 
        for k,v in pairs(self._data) do
            if v.treasureDev and v.treasureDev[disId] then
                self._dis2Com[disId] = k
            end
        end
    end
    return self._dis2Com[disId]
end

function TreasureModel:isTreasureActived( comId )
    if not comId then return false end
    return self._data[tostring(comId)] and self._data[tostring(comId)].stage > 0 or false
end

function TreasureModel:getTreasureById( id )
    id = tostring(id) or 0
    if self._data[id] then
        return self._data[id]
    end
    for k,v in pairs(self._data) do
        if v.treasureDev and v.treasureDev[id] and v.treasureDev[id].s > 0 then
            return v.treasureDev[id]
        end
    end
    return nil
end

function TreasureModel:isHaveTreasure( treasureId,stage )
    local treasureInfo = self:getTreasureById(treasureId)
    local tStage = treasureInfo and (treasureInfo.stage or treasureInfo.s or 0) or 0 
    return tStage >= stage,tStage
end

local updateTData 
updateTData = function ( tData,inData,key )
    if type(inData) ~= type(tData) then
        print("数据结构错误！")
        return
    elseif type(inData) == "table" then
        for k,v in pairs(inData) do
            updateTData(tData,v,key)
        end
    else
        tData[key] = inData 
    end

end

function TreasureModel:upDateTreasure( inData )
    for k,v in pairs(inData) do
        if not self._data[k] then
            self._data[k] = v
        else
            for k1,v1 in pairs(v) do
                if k1 == "treasureDev" then
                    for k2,v2 in pairs(v1) do
                        if not self._data[k]["treasureDev"][k2] then
                            self._data[k]["treasureDev"][k2] = v2
                        else
                            table.merge(self._data[k]["treasureDev"][k2] ,v2)
                        end
                    end
                else
                    self._data[k][k1] = v1
                end
            end
        end
    end
    self:recountCheck()
    self:reflashData()
end

function TreasureModel:wearOnDisTreasure( inData )
    for k,v in pairs(inData) do
        if not self._data[k] then
            self._data[k] = v
        else
            self._data[k]["disScore"] = v.disScore
            for k1,v1 in pairs(v.treasureDev) do
                self._data[k]["treasureDev"][k1] = v1
            end
        end
    end
    self:recountCheck()
    self:reflashData()
end

function TreasureModel:promoteTreasure( inData )
    for k,v in pairs(inData) do
        if not self._data[k] then
            self._data[k] = v
        else
            self._data[k]["disScore"] = v.disScore
            self._data[k]["comScore"] = v.comScore
            for k1,v1 in pairs(v.treasureDev) do
                self._data[k]["treasureDev"][k1] = v1
            end
        end
    end
    self:recountCheck()
    self:reflashData()
end

function TreasureModel:activeComTreasure( inData )
    for k,v in pairs(inData) do
        if not self._data[k] then
            self._data[k] = v
        else
            for k1,v1 in pairs(v) do
                self._data[k][k1] = v1
            end
        end
    end
    self:recountCheck()
    self:reflashData()
end

function TreasureModel:isComTreasureCanDo( comId )
    local doInfo = {}
    local comInfo = self:getComTreasureById(tostring(comId))
    local comD = tab:ComTreasure(tonumber(comId))
    if not comD then return false end
    if comInfo then 
        local dev = comInfo.treasureDev
        local minDisStage
        for disId,disInfo in pairs(dev) do
            local disStage = disInfo.s
            if not minDisStage then
                minDisStage = disStage
            else
                minDisStage = math.min(minDisStage,disStage)
            end
            if disStage >= 1 then
                local canUp = true
                if not maxDisStage then maxDisStage = table.nums(tab.devDisTreasure)+1 end
                local devDisT = disStage < maxDisStage and tab:DevDisTreasure(tonumber(disStage)) or nil
                if devDisT then
                    local materials = devDisT["mater" .. tab:DisTreasure(tonumber(disId)).quality]
                    -- for _,material in pairs(materials) do
                        local _,haveNum = self._modelMgr:getModel("ItemModel"):getItemsById(materials[2])
                        if haveNum < self:getCurrentNum(materials[2],materials[3]) then
                            canUp = false
                        end
                    -- end
                    local _,haveNum = self._modelMgr:getModel("ItemModel"):getItemsById(tonumber(disId))
                    if haveNum < devDisT.treasureNum then
                        canUp = false
                    end

                    if canUp then --and (comInfo.stage+1) > disStage then
                        doInfo.canUpDis = true
                        -- return "canUpDis"
                    end
                end
            else
                local _,hadNum = self._modelMgr:getModel("ItemModel"):getItemsById(tonumber(disId))
                if hadNum >= 1 then
                    doInfo.canFixed = true
                    -- return "canFixed"
                end
            end
        end
        if comInfo.stage > 0 then
            local canUp = true
            if not maxComStage then maxComStage = table.nums(tab.devComTreasure)+1 end
            local devComT = comInfo.stage < maxComStage and tab:DevComTreasure(comInfo.stage) or nil
            if devComT then 
                local materials = devComT["special" .. comD.quality]
                for _,material in pairs(materials) do
                    local _,haveNum = self._modelMgr:getModel("ItemModel"):getItemsById(material[2])
                    if haveNum < self:getCurrentNum(material[2],material[3]) 
                       --[[判断不计算铸造水晶--]]
                       and material[2] ~= 41002  
                    then
                        canUp = false
                        break
                    end
                end
                if canUp and comInfo.stage < minDisStage then
                    doInfo.canUpCom = true
                    -- return "canUpCom"
                end
            end
        else
            local hadFixed = 0
            local disTNum = table.nums(comD.form)
            for k,v in pairs(comInfo.treasureDev) do
                if v.s >= 1 then
                    hadFixed = hadFixed+1
                end
            end
            if not (hadFixed == 0 or hadFixed ~= disTNum) then
                doInfo.canActive = true
                -- return "canActive"
            end
        end
    else
        local hadFixed = 0
        local disTNum = table.nums(comD.form)
        for k,v in pairs(comD.form) do
            local _,hadNum = self._modelMgr:getModel("ItemModel"):getItemsById(v)
            if hadNum >= 1 then
                doInfo.canFixed = true
                -- return "canFixed"
            end
        end
    end
    if table.nums(doInfo) == 0 then
        return false
    else
        return doInfo
    end
end
function TreasureModel:havePromoteTreasure( )
    local isOpen = SystemUtils["enableTreasure"]()
    if not isOpen then return false end
    -- for comId,comInfo in pairs(self._data) do
        for comId,v in pairs(tab.comTreasure) do
            -- print(k,v)
            if self:isComTreasureCanDo(comId) then
                return true
            end
        end
    -- end
    return false
end

-- 是否可以升星
function TreasureModel:isCanUpStar( disId,num )
    num = num or 1
    local disInfo = self:getTreasureById(disId)
    local toolD = tab.tool[tonumber(disId)]
    local color = toolD.color
    local isEnough = true
    local starfrag = self._modelMgr:getModel("UserModel"):getData().starfrag or 0
    local cost = self:getUpStarConsume(disId)
    if starfrag < cost*num then
        isEnough = false
    end

    local isFull = self:isFullStar(disId)
    
    return not isFull and isEnough,isFull,isEnough
end

-- 散件是否升满
function TreasureModel:isFullStar( disId )
    local disInfo = self:getTreasureById(disId)
    local isFull = true
    if disInfo then
        local smallStar = disInfo.ss or 0
        local bigStar = disInfo.bs or 0
        local percrent = disInfo.b or 0
        if bigStar < 4 or (bigStar == 4 and (smallStar < 7 or (smallStar == 7 and percrent <100) )) then
            isFull = false
        end
    else 
        isFull = false
    end
    return isFull
end

-- 散件当前升星消耗
function TreasureModel:getUpStarConsume( disId )
    local disInfo = self:getTreasureById(disId)
    local smallStar = disInfo and disInfo.ss or 0
    local bigStar = disInfo and disInfo.bs or 0
    local toolD = tab.tool[tonumber(disId)]
    print("disId...",disId)
    local color = toolD.color 
    local curIdx = bigStar*8 + smallStar +1
    local comStarD = tab.comTreasureStar[curIdx]
    local cost = 99999999999 -- 不可用
    if comStarD then
        local costTab = comStarD["cost" .. color]
        if costTab then
            cost = costTab[1][3]
        end
    else
        comStarD = tab.comTreasureStar[#tab.comTreasureStar]
        local costTab = comStarD["cost" .. color]
        if costTab then
            cost = costTab[1][3]
        end
    end
    return cost
end

function TreasureModel:getDisTreasureStar( disId )
    local disInfo = self:getTreasureById(disId)
    local isFull = true
    if disInfo then
        local smallStar = disInfo.ss or 0
        local bigStar = disInfo.bs or 0
        local percrent = disInfo.b or 0
        return bigStar + math.floor((smallStar+percrent/100)/8)
    end
    return 0
end

-- 升星加成的属性
function TreasureModel:caculateStarAttr( disId,treasureInfo )
    local disInfo = treasureInfo or self:getTreasureById(disId)
    local bs = disInfo and disInfo.bs or 0
    local ss = disInfo and disInfo.ss or 0
    local b = disInfo and disInfo.b or 0
    local idx = bs*8+ss + math.floor(b/100)
    local upStarData = tab.comTreasureStar[idx]
    local starAttr = upStarData and upStarData.attrprosum or 0
    -- 百分数变小数
    starAttr = starAttr*0.01
    return starAttr
end

-- 升星前后的属性
function TreasureModel:caculateStarPreAftAttrs( disId )
    local preAtts = {att=0,attAdd=0}
    local curAtts = {att=0,attAdd=0}
    local disInfo = self:getTreasureById(disId)
    local bs = disInfo and disInfo.bs or 0
    local ss = disInfo and disInfo.ss or 0
    local b = disInfo and disInfo.b or 0
    local idx = bs*8+ss + math.floor(b/100)
    local upStarData = tab.comTreasureStar[idx]
    local nextIdx = math.min(idx+1,#tab.comTreasureStar)
    local upStarNextData = tab.comTreasureStar[nextIdx]
    if upStarData then
        curAtts.att = upStarData.attrprosum or 0
        curAtts.attAdd = upStarNextData and ((upStarNextData.attrprosum or 0) - curAtts.att ) or 0
    end
    local preIdx = idx - 1
    local upStarBeforeData = tab.comTreasureStar[preIdx]
    if upStarBeforeData then
        preAtts.att = upStarBeforeData.attrprosum or 0
        preAtts.attAdd = upStarData and ((upStarData.attrprosum or 0) - preAtts.att ) or 0
    end
    return preAtts,curAtts
end

-- 新增参数addDisStarBuff 加升星属性
function TreasureModel:getTreasureAtts( id,stage,addDisStarBuff )
    local Atts = {}
    local stage = stage or 0
    local treasure = tab:DisTreasure(tonumber(id)) or tab:ComTreasure(tonumber(id))
    if not treasure then return end
    if treasure["property"] then
        for k,property in pairs(treasure["property"]) do
            if not Atts[property[1]] then
                Atts[property[1]] = {}
            end
            Atts[property[1]].attId = property[1] 
            Atts[property[1]].attNum = property[2]+math.max(stage-1,0)*property[3]
        end
    end
    -- 加升星属性
    local starBuff = 1
    if addDisStarBuff and tab:DisTreasure(tonumber(id)) then
       starBuff = 1+self:caculateStarAttr(id)
       print("starBUffff----------------------",starBuff)
    end
    local tempAtts = {}
    for k,v in pairs(Atts) do
        print("v. attId ,attNum",v.attId,v.attNum)
        v.attNum = string.format("%.1f",v.attNum * starBuff)
        print(v.attNum)
        table.insert(tempAtts,v)
    end
    if #tempAtts > 1 then
        table.sort(tempAtts,function ( a,b )
            return a.attId > b.attId
        end)
    end
    return tempAtts
end

-- 统计组合宝物 对单位方阵兵团 攻击和生命加成的统计
function TreasureModel:getVolumeBuffMap( id )
    local comData = tab.comTreasure[id]
    if not comData then return {} end
    -- buffs 二维数组
        -- volume 1 4 9 16
            -- 3 攻击 6 生命
    local buffs = {}
    local form  = comData.form 
    local comInfo = self:getTreasureById(id)
    for k,v in pairs(form) do
        local stage = 1
        if comInfo and comInfo.treasureDev and comInfo.treasureDev[tostring(v)] then
            stage = comInfo.treasureDev[tostring(v)].s or 1
        end 
        local disData = tab.disTreasure[tonumber(v)]
        local unlockData = disData.unlockaddattr
        local limit = 0
        for i,v1 in ipairs(unlockData) do
            if stage < v1 then
                break
            end
            limit = i
        end
        print("limit,",limit)
        local addAttrData = disData.addattr 
        for i,v1 in ipairs(addAttrData) do
            if i > limit then break end
            local volume = v1[1]
            local attr   = v1[2]
            local value  = v1[3]
            if not buffs[volume]       then buffs[volume] = {}       end
            if not buffs[volume][attr] then buffs[volume][attr] = 0 end
            buffs[volume][attr] = buffs[volume][attr] + value
            -- print(i,limit,"model lll",volume,attr, value,"---",buffs[volume][attr])
        end
    end
    -- dump(buffs)
    return buffs
end

-- 只统计单个 散件 宝物当前激活的属性
function TreasureModel:getDisVolumeBuffMap( disId )
    -- buffs 二维数组
        -- volume 1 4 9 16
            -- 3 攻击 6 生命
    local buffs = {}
    local stage = 1
    local disInfo = self:getTreasureById(disId)
    -- dump(disInfo)
    if disInfo then
        stage = disInfo and disInfo.s or 1 --comInfo.treasureDev[tostring(disId)]
    end 
    local disData = tab.disTreasure[tonumber(disId)]
    local unlockData = disData.unlockaddattr
    local limit = 0
    for i,v1 in ipairs(unlockData) do
        if stage < v1 then
            break
        end
        limit = i
    end
    print("limit,",limit)
    local addAttrData = disData.addattr 
    for i,v1 in ipairs(addAttrData) do
        if i > limit then break end
        local volume = v1[1]
        local attr   = v1[2]
        local value  = v1[3]
        if not buffs[volume]       then buffs[volume] = {}       end
        if not buffs[volume][attr] then buffs[volume][attr] = 0 end
        buffs[volume][attr] = buffs[volume][attr] + value
        -- print(i,limit,"model lll",volume,attr, value,"---",buffs[volume][attr])
    end
    return buffs
end

-- 给分享用的 给出战斗力最高的宝物 
function TreasureModel:getHightScoreTreasure( comId )
    if comId and self._data and self._data[tostring(comId)] then
        return self._data[tostring(comId)]
    end
    local highScore = 0
    local hightId
    for k,v in pairs(self._data) do
        if v and v.stage > 0 then 
            local score = (v.comScore or 0)+(v.disScore or 0)
            if score > highScore then
                highScore = score
                hightId = tonumber(k) 
            end
        end
    end
    return hightId
end

-- 获取当下需要的进阶材料数量（可能活动打折） 2016.11.2
-- @param id 道具ID
-- @param count 原本所需数量
function TreasureModel:getCurrentNum(id, count)
    local activityModel = self._modelMgr:getModel("ActivityModel")
    if tostring(id) == "41001" then
        return count * (1 + activityModel:getAbilityEffect(activityModel.PrivilegIDs.PrivilegID_25))
    else
        return count
    end
end

-- 宝物占星，计算剩余次数
function TreasureModel:countLeftNum( )
    local vip = self._modelMgr:getModel("VipModel"):getData().level
    local recordNum = self._modelMgr:getModel("PlayerTodayModel"):getData().day10
    local leftCount = tab:Vip(vip).buyTreasure - recordNum
    local _,haveNum = self._modelMgr:getModel("ItemModel"):getItemsById(41003)
    leftCount = leftCount--+ haveNum

    -- 累计抽取次数 
    local totalCount = self._modelMgr:getModel("PlayerTodayModel"):getDrawAward().tDrawNum or 0
    print("totalCount------------------------------------",totalCount,20-totalCount%20)
    return leftCount,haveNum,20-totalCount%20,100-totalCount%100
end

-- 判断本地存没存分解字段
function TreasureModel:isFenjieOpened( )
    local isOpen,_,openLevel = SystemUtils["enableTreasureFenjie"]()
    if isOpen and not self._fenjieBtnIsOpen then
        self._fenjieBtnIsOpen = SystemUtils.loadAccountLocalData("fenjieBtnIsOpen") or false
    end
    print("self._fenjieBtnIsOpen",self._fenjieBtnIsOpen)
    return self._fenjieBtnIsOpen
end

-- 给签到全勤宝物 提供接口 ，根据散件id 传回 对应组合宝物id , 资源名
function TreasureModel:getComInfoByDisId( disId )
    local comTreasure = tab.comTreasure
    local comId = nil
    local comData = nil
    for k,v in pairs(comTreasure) do
        if comId then break end
        local form = v.form 
        if form then
            for i,formId in ipairs(form) do
                if disId == formId then
                    comId = v.id
                    comData = v 
                    break
                end 
            end
        end
    end
    if comId and comData then 
        return comId,"pic_artifact_".. comId ..".png",lang(comData.name)
    end
end

-- 判断是否开升星引导
function TreasureModel:isUpStarGuide( )
    local trigger35 = self._modelMgr:getModel("UserModel"):hasTrigger("35")
    if not trigger35 and SystemUtils:enableTreasureStar() then
        return true
    end
end

-- 统计宝物技能中加法伤
function TreasureModel:caculateMagicHurtBySkill( )
    local hurt = 0
    for comId,comInfo in pairs(self._data) do
        local comData = tab.comTreasure[tonumber(comId)]
        if comData then
            local stage = comInfo.stage
            local curSKillId = comData.addattr[1][2]
            if stage > 1 then
                local unlockData = comData.unlockaddattr
                for i,skillLv in ipairs(unlockData) do
                    if stage >= skillLv then
                        curSKillId = comData.addattr[i][2]
                    else
                        break
                    end
                end
            end
            local skillD = tab.heroMastery[curSkillId]
            if  skillD 
                and skillD.morale 
                and skillD.morale[1] 
                and skillD.morale[1][1] == 131 
            then
                local base = skillD.morale[1][2] or 0
                local step = skillD.morale[1][3] or 0
                hurt = hurt + base + step*(stage-1)
            end
        end
    end
    return hurt
end

-- 获得转化后的技能id
function TreasureModel:getTransferSkillId( comId )
    if not comId then return end 
    local comInfo = self:getTreasureById(comId)
    local comD = tab.comTreasure[comId]
    if comD then 
        local stage = comInfo and comInfo.stage or 1
        local addattr = comD.addattr
        local unlockData = comD.unlockaddattr
        local transId = addattr[1][2]
        
        for i,v in ipairs(unlockData) do
            if stage >= v then
                transId = addattr[i][2]
            else
                break
            end
        end
        return transId
    end
end

return TreasureModel