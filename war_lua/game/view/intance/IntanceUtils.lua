--[[
    Filename:    IntanceUtils.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-01-22 10:24:20
    Description: File description
--]]

IntanceUtils = {}

--[[
--! @function handleWideReward
--! @desc 处理奖励信息
--！@param inReward 服务端返回奖励内容
--！@param inSysReward 配置表奖励内容
--! @return 
--]]
function IntanceUtils:handleWideReward(inReward, inSysReward)
    local tmpRewards = {}
    -- 根据服务器返回数据进行重组
    for k,v in pairs(inReward) do
        local tmpReward = {}

        if next(v) then
            tmpReward.items = {}
            -- 组合数据
            for k3,v3 in pairs(v) do
                local item = {}
                item.goodsId = v3.typeId
                item.num = v3.num
                table.insert(tmpReward.items, item)
            end

        end
        
        tmpReward.texp = 0
        tmpReward.exp = 0 
        tmpReward.gold = 0
        tmpReward.expCoin = 0
        local otherReward  = inSysReward[k]
        for k1,v1 in pairs(otherReward) do
            if v1["type"] == "texp" then 
                -- 怪兽经验
                tmpReward.texp = v1["num"]
            elseif v1["type"] == "exp" then 
                -- 玩家经验
                tmpReward.exp = v1["num"]
            elseif v1["type"] == "expCoin" then
                --经验转化的经验货币
                tmpReward.expCoin = v1["num"]
            else
                -- 金币
                tmpReward.gold = v1["num"]
                tmpReward.goldTxPlus = v1["txPlus"]
            end  
        end
 
        table.insert(tmpRewards, tmpReward)
    end
    return tmpRewards
end


--[[
--! @function initFormationData
--! @desc 初始化敌方布阵
--！@param enemyData 英雄与兵团信息
--! @return enemyFormation 整合后布阵信息
--]]
function IntanceUtils:initFormationData(enemyData)
    local enemyFormation = {}
    local score = 0
    for i=1,8 do
        if enemyData["m" .. i] == nil and 
           enemyData["m" .. i] ~= 0 then 
            break
        end
        enemyFormation["team" .. i] = enemyData["m" .. i][1]
        enemyFormation["g" .. i] = enemyData["m" .. i][2]
        -- dump(tab.npc[enemyData["m" .. i][1]])
        local npc = tab:Npc(enemyData["m" .. i][1])
        score = score + npc.score
    end
    for i=1,6 do
        if enemyData["skill" .. i] == nil then 
            break
        end
        enemyFormation["skillId" .. i] = enemyData["skill" .. i]
    end
    enemyFormation.type = 1
    score = score + tab.npcHero[enemyData.hero].score
    enemyFormation.score = score
    enemyFormation.heroId = enemyData.hero
    if enemyData["siegeid"] then
        enemyFormation.siegeid = true
    end
    return enemyFormation
end

--[[
--! @function updateDropNode
--! @desc 更新奖励提示信息
--！@param dropNode 奖励bg node
--! @param sysStage 系统关卡信息
--! @param isFirst 是否是首次
--]]
function IntanceUtils:updateDropNode(dropNode, sysStage, isFirst, spaceX, inScale)
    dropNode:removeAllChildren()
    local maxShowNum = 3
    if sysStage["firstReward"] ~= nil and isFirst then 
        maxShowNum = 2
    end
    print("maxShowNum====", maxShowNum)
    local offsetX = 0
    if spaceX == nil then 
        spaceX = 10
    end
    if inScale == nil then 
        inScale = 0.8
    end
    -- 这里用x是因为dropItem 可能出现空着录入的情况
    local x = 0
    local xPoint = 0
    local dropIcon
    for i=0, 4 do
        if sysStage["dropItem" .. i] ~= nil then 
            x = x + 1 
            local sysItem = tab:Tool(sysStage["dropItem" .. i])
            dropIcon = IconUtils:createItemIconById({itemId = sysStage["dropItem" .. i],itemData = sysItem})
            dropNode:addChild(dropIcon)
            dropIcon:setScale(inScale)
            dropIcon:setAnchorPoint(cc.p(0 ,0.5))
            dropIcon:setName("dropIcon" .. i)
            dropIcon:setVisible(true)
            
            dropIcon:setPosition(xPoint, dropNode:getContentSize().height * 0.5 )

            xPoint = spaceX + xPoint + dropIcon:getContentSize().width * dropIcon:getScale()
            if x == maxShowNum then 
                break
            end
            
        end
    end
    if maxShowNum == 2 then 
        x = x + 1
        local iconId = 0
        if sysStage["firstReward"][1] == "tool" then
            iconId = sysStage["firstReward"][2]
        else
            iconId = IconUtils.iconIdMap[sysStage["firstReward"][1]]
        end
        local rewardIcon = IconUtils:createItemIconById({itemId = iconId,itemData = tab:Tool(iconId),num = sysStage["firstReward"][3]})
        rewardIcon:setScale(inScale)
        rewardIcon:setAnchorPoint(cc.p(0, 0.5))
        rewardIcon:setPosition(xPoint,  dropNode:getContentSize().height * 0.5)
        dropNode:addChild(rewardIcon)

        local mc1 = mcMgr:createViewMC("wupinguang_itemeffectcollection", true)
        mc1:setPosition(rewardIcon:getContentSize().width * 0.5 ,rewardIcon:getContentSize().height * 0.5)

        rewardIcon:addChild(mc1,9)

        local tempIcon = cc.Sprite:createWithSpriteFrameName("globalImageUI6_connerTag_r.png")
        tempIcon:setAnchorPoint(cc.p(1, 1))
        tempIcon:setPosition(rewardIcon:getContentSize().width, rewardIcon:getContentSize().height)
        rewardIcon:addChild(tempIcon, 8)

        local tempLab = cc.Label:createWithTTF("首次", UIUtils.ttfName, 22)
        tempLab:setRotation(41)
        tempLab:setPosition(cc.p(45, 37))
        tempLab:enableOutline(cc.c4b(146, 19, 5, 255), 1)
        tempIcon:addChild(tempLab)

    end
end

--[[
--! @function checkPreSection
--! @desc 检查是否满足条件前往下一章
--！@param inCurSectionId 检查章
--! @param inNextSection 下一章
--]]
function IntanceUtils:checkPreSection(inCurSectionId, inNextSection)
    local modelMgr = ModelManager:getInstance()
    local intanceModel = modelMgr:getModel("IntanceModel")

    if inNextSection == nil then
        return 1
    end

    local curSysSection = tab:MainSection(inCurSectionId)

    local curSysMainStage = tab:MainStage(curSysSection.includeStage[#curSysSection.includeStage])
    local stageInfo = intanceModel:getStageInfo(curSysMainStage.id)
    if stageInfo.star == 0 then
        return 2
    end

    local endSection = tab:Setting("G_FINISH_SECTION_STORY").value
    if endSection == inCurSectionId then
        return 4
    end

    local userInfo = modelMgr:getModel("UserModel"):getData()
    if inNextSection.level > userInfo.lvl then 
        return 3, inNextSection.level
    end

    return 0
end

function IntanceUtils:convertSectionToImgNum(num, imgName)
    local nodeContent = cc.Sprite:create()
    local strNum = tostring(num)
    local x = 0
    local height = 0
    local tempImgWidth = 0
    local tempImg = cc.Sprite:createWithSpriteFrameName("world_num_di.png")
    tempImg:setAnchorPoint(0, 0.5)
    tempImg:setPosition(x, tempImg:getContentSize().height/2)
    nodeContent:addChild(tempImg, 1)
    x = x + tempImg:getContentSize().width/2 - 5

    for i=1,string.len(strNum) do
        local tempSigNum = string.sub(strNum, i , i)
        local tempImgNum = cc.Sprite:createWithSpriteFrameName(imgName .. tempSigNum .. ".png")
        tempImgNum:setAnchorPoint(0, 0.5)

        tempImgNum:setPosition(x, tempImgNum:getContentSize().height/2)
        x = x + tempImgNum:getContentSize().width/2 - 7

        height = tempImgNum:getContentSize().height
        tempImgWidth = tempImgNum:getContentSize().width
        nodeContent:addChild(tempImgNum, 1)
    end
    x = x - tempImgWidth/2 + 25
    local tempImg = cc.Sprite:createWithSpriteFrameName("world_num_zhang.png")
    tempImg:setAnchorPoint(0, 0.5)
    tempImg:setPosition(x, height/2)
    nodeContent:addChild(tempImg, 1)
    x = x + tempImg:getContentSize().width

    nodeContent:setContentSize(x, height)

    -- local layer4 = cc.LayerColor:create(cc.c4b(0, 0, 0, 255))
    -- layer4:setContentSize(x, height)
    -- layer4:setPosition(0, 0)
    -- nodeContent:addChild(layer4)

    nodeContent:setCascadeOpacityEnabled(true, true)
    return nodeContent    
end

function IntanceUtils:convertToImgNum(num, imgName, suffix)
    local nodeContent = cc.Sprite:create()
    local strNum = tostring(num)
    local x = 0
    local height = 0
    local tempImgWidth = 0
    for i=1,string.len(strNum) do
        local tempSigNum = string.sub(strNum, i , i)
        local tempImgNum = cc.Sprite:createWithSpriteFrameName(imgName .. tempSigNum .. ".png")
        tempImgNum:setAnchorPoint(0, 0.5)
        tempImgNum:setPosition(x, tempImgNum:getContentSize().height/2)
        x = x + tempImgNum:getContentSize().width/2 - 7

        height = tempImgNum:getContentSize().height
        tempImgWidth = tempImgNum:getContentSize().width
        nodeContent:addChild(tempImgNum, 1)
    end
    if suffix then
        x = x - tempImgWidth/2 + 5
        local tempImg = cc.Sprite:createWithSpriteFrameName(suffix)
        tempImg:setAnchorPoint(0, 0.5)
        tempImg:setPosition(x, height/2)
        nodeContent:addChild(tempImg, 1)
        x = x + tempImg:getContentSize().width - 10
    end


    nodeContent:setContentSize(x, height)

    -- local layer4 = cc.LayerColor:create(cc.c4b(0, 0, 0, 255))
    -- layer4:setContentSize(x, height)
    -- layer4:setPosition(0, 0)
    -- nodeContent:addChild(layer4)
    -- layer4:setVisible(false)

    nodeContent:setCascadeOpacityEnabled(true, true)
    return nodeContent
end