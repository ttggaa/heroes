--[[
    Filename:    AcBtnEventUtils.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2019-1-9 10:45
    Description: 
--]]

local AcBtnEventUtils = {}

local viewMgr = ViewManager:getInstance()
local modelMgr = ModelManager:getInstance()

function AcBtnEventUtils.goView1() 
    viewMgr:showView("intance.IntanceView", {superiorType = 1}) 
end

function AcBtnEventUtils.goView2() 
    viewMgr:showView("vip.VipView", {viewType = 0}) 
end

function AcBtnEventUtils.goView3()
    if not SystemUtils:enableElite() then
        viewMgr:showTip(lang("TIP_JINGYING_1"))
        return 
    end
    viewMgr:showView("intance.IntanceEliteView", {superiorType = 1}) 
end

function AcBtnEventUtils.goView4() 
    if not SystemUtils:enableDwarvenTreasury() then
        viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    viewMgr:showView("pve.AiRenMuWuView") 
end

function AcBtnEventUtils.goView5() 
    if not SystemUtils:enableCrypt() then
        viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    viewMgr:showView("pve.ZombieView") 
end

function AcBtnEventUtils.goView6() 
    if not SystemUtils:enableBoss() then
        viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    viewMgr:showView("pve.DragonView") 
end

function AcBtnEventUtils.goView7() 
    viewMgr:showView("team.TeamListView") 
end

function AcBtnEventUtils.goView8() 
    viewMgr:showView("flashcard.FlashCardView") 
end

function AcBtnEventUtils.goView9() 
    if not SystemUtils:enableArena() then
        viewMgr:showTip(lang("TIP_Arena"))
        return 
    end
    viewMgr:showView("arena.ArenaView") 
end

function AcBtnEventUtils.goView10() 
    if not SystemUtils:enableCrusade() then
        viewMgr:showTip(lang("TIP_Crusade"))
        return 
    end
    viewMgr:showView("crusade.CrusadeView") 
end

function AcBtnEventUtils.goView11() 
    DialogUtils.showBuyRes({goalType = "gold"}) 
end

function AcBtnEventUtils.goView12() 
    DialogUtils.showBuyRes({goalType = "physcal"}) 
end

function AcBtnEventUtils.goView13()
    viewMgr:showView("shop.ShopView",{idx = 6})
end

function AcBtnEventUtils.goView14() 
    DialogUtils.showBuyRes({goalType = "gem"}) 
end

function AcBtnEventUtils.goView15() 
    DialogUtils.showBuyRes({goalType = "gem"})
end

function AcBtnEventUtils.goView16() 
    if modelMgr:getModel("ActivityCarnivalModel"):carnivalIsOpen() then
        viewMgr:showDialog("activity.ActivityCarnival", {}, true)
    else
        viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
    end
end

function AcBtnEventUtils.goView17() 
    local showday, _ = modelMgr:getModel("ActivitySevenDaysModel"):getShowDayAndState()
    if SystemUtils:enableSevenDay() and showday > 0  then
        viewMgr:showDialog("activity.ActivitySevenDaysView", {})
    else
        viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
    end
end

function AcBtnEventUtils.goView18() 
    if not SystemUtils:enableGuild() then
        viewMgr:showTip(lang("TIP_Guild"))
        return 
    end
    local userData = modelMgr:getModel("UserModel"):getData()
    if not userData.guildId or userData.guildId == 0 then
        viewMgr:showView("guild.join.GuildInView")
    else
        viewMgr:showView("guild.GuildView")
    end
end

function AcBtnEventUtils.goView19() 
    if not SystemUtils:enableTreasure() then
        viewMgr:showTip(lang("TIP_Treasure"))
        return 
    end

    viewMgr:showView("treasure.TreasureShopView")
end

function AcBtnEventUtils.goView20() 
    if not SystemUtils:enableTeam() then
        viewMgr:showTip(lang("TIP_TEAM"))
        return 
    end

    viewMgr:showView("team.TeamListView")
end

function AcBtnEventUtils.goView21() 
    if not SystemUtils:enableHero() then
        viewMgr:showTip(lang("TIP_HERO"))
        return 
    end

    viewMgr:showView("hero.HeroView")
end

--[[
function AcBtnEventUtils.goView22() 
    if not SystemUtils:enableMF() then
        viewMgr:showTip(lang("TIP_MF"))
        return 
    end

    viewMgr:showView("MF.MFView")
end

function AcBtnEventUtils.goView23() 
    if not SystemUtils:enableCloudCity() then
        viewMgr:showTip(lang("TIP_TOWER"))
        return 
    end

    viewMgr:showView("cloudcity.CloudCityView")
end

function AcBtnEventUtils.goView24()
    local isOpen,openDes = LeagueUtils:isLeagueOpen()
    if not isOpen then
        viewMgr:showTip(openDes)
        return
    end
    viewMgr:showView("league.LeagueView")
end
]]

function AcBtnEventUtils.goView25()
    if not SystemUtils:enablePokedex() then
        viewMgr:showTip(lang("TIP_Pokedex"))
        return 
    end

    viewMgr:showView("pokedex.PokedexView")
end

function AcBtnEventUtils.goView26()
    if not SystemUtils:enableTeam() then
        viewMgr:showTip(lang("TIP_TEAM"))
        return 
    end

    DialogUtils.showBuyRes({goalType = "texp"})
end

--[[
function AcBtnEventUtils.goView27()
    viewMgr:showDialog("tencentprivilege.TencentPrivilegeView")
end
]]

function AcBtnEventUtils.goView28()
    local isOpen,openDes = LeagueUtils:isLeagueOpen()
    if isOpen then
        viewMgr:showView("league.LeagueView")
    else
        viewMgr:showTip(openDes)
    end
end

function AcBtnEventUtils.goView29()
    if not SystemUtils:enableTreasure() then
        viewMgr:showTip(lang("TIP_Treasure"))
        return 
    end

    viewMgr:showView("treasure.TreasureView")
end

function AcBtnEventUtils.goView30()
    if not SystemUtils:enableNests() then
        viewMgr:showTip(lang("TIP_Nests"))
        return 
    end

    viewMgr:showView("nests.NestsView")
end

function AcBtnEventUtils.goView31()
    local userInfo = modelMgr:getModel("UserModel"):getData()  
    local _,_,level = SystemUtils:enableTraining()
    if userInfo.lvl < level then
        viewMgr:showTip("请先将等级提升到"..level.."级")
    else
        viewMgr:showView("training.TrainingView")
    end
end

function AcBtnEventUtils.goView32()
    local weaponsModel = modelMgr:getModel("WeaponsModel")
    local state = weaponsModel:getWeaponState()
    if state == 1 then
        viewMgr:showTip(lang("TIP_Weapon"))
    elseif state == 2 then
        viewMgr:showTip(lang("TIP_Weapon2"))
    elseif state == 3 then
        viewMgr:showTip(lang("TIP_Weapon3"))
    elseif state == 4 then
        local tdata = weaponsModel:getWeaponsDataByType(1)
        if tdata then
            viewMgr:showView("weapons.WeaponsView", {})
        else
            self._serverMgr:sendMsg("WeaponServer", "getWeaponInfo", {}, true, {}, function(result)
                viewMgr:showView("weapons.WeaponsView", {})
            end)
        end
    end
end

--[[
function AcBtnEventUtils.goView31()
    if not SystemUtils:enableElement() then
        viewMgr:showTip(lang("TIP_elementalPlane"))
        return 
    end

    viewMgr:showView("elemental.ElementalView")
end
]]

function AcBtnEventUtils.dtor()
    viewMgr = nil
    modelMgr = nil
end

return AcBtnEventUtils