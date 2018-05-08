--[[
    Filename:    GuildMapUtils.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-06-27 11:10:00
    Description: File description
--]]

local GuildMapUtils = {}

function GuildMapUtils:initBattleData(enemyD)
    --  合成敌人数据
    local enemyInfo = {team = {}, hero = {
                                            id = 100003, 
                                            level = 1, 
                                            slevel = {0, 0, 0, 0, 0},
                                            star = 1,
                                            mastery = {}, 
                                            score = 0,
                                            }, 
                        pokedex = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
                        globalMasterys = {}, 
                        treasure = nil,
                        talent = nil}
    for k=1,4 do
        enemyInfo.hero["sl" .. k] = 1
    end                    
    enemyInfo.pokedex = enemyD.pokedex
    if not enemyD.pokedex or #enemyD.pokedex == 0 then
        enemyInfo.pokedex = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}          
    end
    
    local team 
    enemyInfo.team = {}

    local formation = enemyD.formation
    local heroScore = 0
    local totalScore = 0
    for i=1,8 do
        local teamId = formation["team" .. i]
        local g = formation["g" .. i]
        if teamId ~= nil then
            local tid = tonumber(teamId)
            if tid ~= 0  then 
                local sysTeam = tab.team[tid]
                local score = 0
                if enemyD.scoreList ~= nil and enemyD.scoreList["s" .. i] ~= nil then 
                    score = tonumber(enemyD.scoreList["s" .. i])
                end
                team = {
                    id = tid,
                    pos = tonumber(g),
                    level = enemyD.lvl,
                    star = 1,
                    stage = 1,
                    equip = {
                        {stage = 1,level=1},
                        {stage = 1,level=1},
                        {stage = 1,level=1},
                        {stage = 1,level=1},
                    },
                    skill = {0,0,0,0},
                    score = score,
                }
                for k=1,4 do
                    team["sl" .. k] = 1
                    team["es" .. k] = 1
                    team["el" .. k] = 1
                end
                -- 第一个兵团战斗力*3  做为英雄战斗力
                if i == 1 then 
                    heroScore = score * 3
                end
                totalScore = totalScore + score
                table.insert(enemyInfo.team, team)
            end
        end
    end
    enemyInfo.hero.id = formation.heroId
    enemyInfo.hero.score = heroScore
    enemyInfo.score = totalScore + heroScore
    return enemyInfo
end


function GuildMapUtils:showItems(inItems, inScale, inHideNum, inEffect, inEventStyle, inIsDouble)
    if inItems == nil  then 
        return cc.Node:create()
    end
    if inScale == nil then 
        inScale  = 0.8
    end
    local tips1 = {}
    local index = 1
    for k,v in pairs(inItems) do
        local itemType = v[1]
        local itemId = v[2]
        local itemNum = v[3]
        if itemType ~= "tool" then
            itemId = IconUtils.iconIdMap[itemType]
        end
        local itemData = tab:Tool(itemId)
        local itemIcon = IconUtils:createItemIconById({itemId = itemId, num = itemNum, itemData = itemData, effect = inEffect, eventStyle = inEventStyle})       
        itemIcon:setScale(inScale)
        tips1[k] = itemIcon
        if inHideNum == 1 then
            local iconColor = itemIcon:getChildByFullName("iconColor")
            local numLab = itemIcon:getChildByFullName("numLab") or iconColor:getChildByFullName("numLab")
            if numLab ~= nil then numLab:setVisible(false) end
        end
        if inIsDouble == true then 

            local iconColor = itemIcon:getChildByFullName("iconColor") 
            if iconColor == nil then 
                iconColor = itemIcon:getChildByFullName("itemIcon")
            end
            local doubleTip = cc.Sprite:createWithSpriteFrameName("globalImageUI6_connerTag_r.png")
            doubleTip:setAnchorPoint(1, 1)
            doubleTip:setPosition(itemIcon:getContentSize().width, itemIcon:getContentSize().height)
            iconColor:addChild(doubleTip, 100)
            local doubleText = cc.Label:createWithTTF("双倍", UIUtils.ttfName, 22)
            doubleText:setRotation(41)
            doubleText:setPosition(cc.p(45, 37))
            doubleText:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
            doubleTip:addChild(doubleText)
        end
    end

    local nodeTip1 = UIUtils:createHorizontalNode(tips1, nil, false, 10)
    nodeTip1:setAnchorPoint(cc.p(0.5, 0.5))
    return nodeTip1
end



--[[
--! @function handleSkillDesc
--! @desc  处理技能描述
--! @param inDesc string 技能描述
--! @param inLevel int 技能等级
--! @param inUlevel int 技能等级升级到的目标等级
--! @return result string 替换后的描述（如果替换条件不满足，可能返回原描述)
--]]
function GuildMapUtils:handleDesc(inDesc, inUserLvl, inServerLvl)
    -- print("inUlevel==",inUlevel,inDesc)
    if inUserLvl == nil then 
        inUserLvl = 0
    end
    if inServerLvl == nil then 
        inServerLvl = 0
    end
    local tempDesc = string.gsub(inDesc, "{[^}]+}",function(inSubStr)

        local result,count = string.gsub(inSubStr, "$userlevel", inUserLvl)
        local uresult = ""
        local flag = 0
        local count1 = 0
        uresult,count = string.gsub(result, "$serverlevel", inServerLvl)
        if count > 0 then 
            result = uresult
        end

        result = string.gsub(result, "{", "")
        result = string.gsub(result, "}", "")

        if string.len(result) > 0 then 
            local a = "return " .. result
            result = loadstring(a)()        
        end
        return result
    end)

    return tempDesc
end

function GuildMapUtils.dtor()
    GuildMapUtils = nil
end 

return GuildMapUtils