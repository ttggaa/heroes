--[[
    Filename:    SkillUtils.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-06-15 10:29:46
    Description: File description
--]]

local SkillUtils = {}

SkillUtils.SKILL_TYPE_SKILL = 1
SkillUtils.SKILL_TYPE_PASSIVE = 2
SkillUtils.SKILL_TYPE_CHARACTER = 3
SkillUtils.SKILL_TYPE_ATTACKEFFECT = 4


local modelMgr = ModelManager:getInstance()
function SkillUtils:handleSkillDesc1(inDesc, inTeamData, inLevel, inUlevel)
    local backData, backSpeed = BattleUtils.getTeamBaseAttr1(inTeamData, modelMgr:getModel("PokedexModel"):getScore(), modelMgr:getModel("BattleArrayModel"):getData(), modelMgr:getModel("ParagonModel"):getData())
    local volume = inTeamData.volume 
    local attr = modelMgr:getModel("TeamModel"):getTeamTreasure(volume) 
    if not inTeamData["exp"] and volume then
        local volume = (6-volume)*(6-volume)
        attr = modelMgr:getModel("TeamModel"):getTeamTreasure(volume) 
    end
    for i = 1, #backData do
        backData[i] = backData[i] + attr[i]
    end
    local attack = BattleUtils.getTeamAttackAttr(backData)
    return self:handleSkillDesc(inDesc, inLevel, attack, inUlevel, inTeamData.level)
end

function SkillUtils:handleStageTeamSkillDesc1(inDesc, inTeamData, inLevel, inUlevel)
    local attack = inTeamData["attr1"][1] + inLevel * inTeamData["attr1"][2]
    return self:handleSkillDesc(inDesc, inLevel, attack, inUlevel, inTeamData.level)
end

--[[
--! @function handleSkillDesc
--! @desc  处理技能描述
--! @param inDesc string 技能描述
--! @param inLevel int 技能等级
--! @param inUlevel int 技能等级升级到的目标等级
--! @return result string 替换后的描述（如果替换条件不满足，可能返回原描述)
--]]
function SkillUtils:handleSkillDesc(inDesc, inLevel, inAttack, inUlevel, inTeamLevel)
    -- print("inUlevel==",inUlevel,inDesc)
    if inUlevel == nil then 
        inUlevel = 0
    end
    if inAttack == nil then 
        inAttack = 0
    end
    if inTeamLevel == nil then 
        inTeamLevel = 0 
    end
    local tempDesc = string.gsub(inDesc, "{[^}]+}",function(inSubStr)

        local result,count = string.gsub(inSubStr, "$level", inLevel)
        local uresult = ""
        local flag = 0
        local count1 = 0
        uresult,count = string.gsub(result, "$ulevel", inUlevel)
        if count > 0 then 
            result = uresult
        end
        uresult,count1 = string.gsub(result, "$atk", inAttack)
        if count1 > 0 then 
            result = uresult
        end

        uresult,count1 = string.gsub(result, "$teamlevel", inTeamLevel)
        if count1 > 0 then 
            result = uresult
        end


        result = string.gsub(result, "{", "")
        result = string.gsub(result, "}", "")
        

        if string.len(result) > 0 then 
            local a = "return " .. result
            result = TeamUtils.getNatureNums(loadstring(a)())
        end
        -- if flag == 1 then 
        --     if inUlevel > 0 and count > 0 then 
        --         result = "(+" .. result .. ")"
        --     else
        --         return ""
        --     end
        -- end
        return result
    end)

    return tempDesc
end

--[[
--! @function getTeamSkillByType
--! @desc  根据类型获取怪兽系统技能数据
--! @param skillId int 技能id
--! @param skillType int 技能类型
--! @return sysSkill object 系统技能
--]]
function SkillUtils:getTeamSkillByType(skillId, skillType)
    local sysSkill 
    if skillType == SkillUtils.SKILL_TYPE_SKILL then 
        sysSkill = tab:Skill(skillId)
    elseif skillType == SkillUtils.SKILL_TYPE_PASSIVE then 
        sysSkill = tab:SkillPassive(skillId)
    elseif skillType == SkillUtils.SKILL_TYPE_CHARACTER then 
        sysSkill = tab:SkillCharacter(skillId)
    elseif skillType == SkillUtils.SKILL_TYPE_ATTACKEFFECT then 
        sysSkill = tab:SkillAttackEffect(skillId)
    end
    return sysSkill
end

function SkillUtils.dtor()
    modelMgr = nil
    SkillUtils = nil
end

return SkillUtils