--[[
    Filename:    HeroServer.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2015-07-20 11:45:23
    Description: File description
--]]

local HeroServer = class("HeroServer", BaseServer)

function HeroServer:ctor()
    HeroServer.super.ctor(self)
    self._heroModel = self._modelMgr:getModel("HeroModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._activityModel = self._modelMgr:getModel("ActivityModel")
    self._spellBooksModel = self._modelMgr:getModel("SpellBooksModel")
end

function HeroServer:onGetHero(result, error)
    --dump(result, "HeroServer:onGetFormation")
    self._heroModel:setData(result["heros"])
    self:callback(0 == tonumber(error))
end

function HeroServer:onRefreshMastery(result, error)
    --dump(result, "HeroServer:onRefreshMastery")
    if result and result["d"] then
        self:callback(result)
        self._activityModel:pushUserEvent()
    end
end

function HeroServer:updateHeroGlobalAttributes(result, isReplaceMastery)
    if not (result and result["d"]) then return end
    if result["d"].hAb then
        self._userModel:updateGlobalAttributes(result["d"].hAb)
        result["d"].hAb = nil
    end

    if result["d"].uMastery then
        self._userModel:updateuMastery(result["d"].uMastery, isReplaceMastery)
        result["d"].uMastery = nil
    end
end

function HeroServer:onSaveMastery(result, error)
    dump(result, "HeroServer:onSaveMastery", 5)
    self:updateHeroGlobalAttributes(result, true)
    self:callback(0 == tonumber(error), result)
end

function HeroServer:onSetWarHero(result, error)
    self:callback(0 == tonumber(error))
end

function HeroServer:onUnlockHero(result, error)
    -- dump(result, "onUnlockHero")
    if 0 == tonumber(error) then

        self:updateHeroGlobalAttributes(result)

        if result["d"] and result["d"]["heros"] then
            self:callback(result)     

            -- 新英雄传记数据初始化
            self._heroModel:unLockHeroBiography(result["d"]["heros"])
        end

        -- 处理英雄皮肤数据
        if result["d"] and result["d"]["hSkin"] then
            self._userModel:updateSkinData(result["d"]["hSkin"])
            result["d"]["hSkin"] = nil
        end
        
        self._userModel:updateUserData(result["d"])
    end
end

function HeroServer:onHeroSkillUpgrade(result, error)
    --[[
        [LUA-print] - "onHeroSkillUpgrade" = {
        [LUA-print] -     "d" = {
        [LUA-print] -         "_id"   = "dev_9"
        [LUA-print] -         "gold"  = 849200
        [LUA-print] -         "heros" = {
        [LUA-print] -             "60001" = {
        [LUA-print] -                 "sl1"    = 7
        [LUA-print] -                 "se1" = 7016
        [LUA-print] -             }
        [LUA-print] -         }
        [LUA-print] -     }
        [LUA-print] -     "rate" = 2
        [LUA-print] -     "s"    = "OK"
        [LUA-print] - }
    ]]
    --dump(result, "onHeroSkillUpgrade", 5)
    if 0 == tonumber(error) then
        if result["d"] and result["d"]["heros"]  then
            self._heroModel:updateHeroData(result["d"])
            self:callback(result, 0 == tonumber(error))
        end
    end
end

function HeroServer:onUpgradeStar(result, error)
    --[[
        [LUA-print] -     "d" = {
        [LUA-print] -         "_id"   = "dev_9"
        [LUA-print] -         "heros" = {
        [LUA-print] -             "60102" = {
        [LUA-print] -                 "star" = 3
        [LUA-print] -             }
        [LUA-print] -         }
        [LUA-print] -         "items" = {
        [LUA-print] -             "360102" = {
        [LUA-print] -                 "num" = 900
        [LUA-print] -             }
        [LUA-print] -         }
        [LUA-print] -     }
        [LUA-print] -     "s" = "OK"
        [LUA-print] - }
    ]]
    -- dump(result, "onUpgradeStar", 5)
    if 0 == tonumber(error) then
        if result["d"] then
            self:updateHeroGlobalAttributes(result)
            if result["d"]["heros"] then
                self._heroModel:updateHeroData(result["d"])
                self:callback(result, 0 == tonumber(error))
            end
            if result["d"]["globalSpecial"] then
                self._userModel:setGlobalMasterys(result["d"]["globalSpecial"])
            end
        end
    end
end

function HeroServer:onConvertSoul(result, error)
    self:callback(result, 0 == tonumber(error))
end

-- 皮肤换肤协议
function HeroServer:onSetSkin(result,error)
    if error ~= 0 then return end
    
    local heroData = result["d"] and result["d"]["heros"] or nil
    self._heroModel:updateHeroSkin(heroData)
    self:callback(result, 0 == tonumber(error))

end

--[[
    法术书抽取接口
    @param num 抽取次数
]]
function HeroServer:onDrawSpeelBook(result,error)
    -- dump(result,"HeroServer:onDrawSpeelBook",10)
    if error ~= 0 then 
        self:callback(nil) 
        return 
    end
    if result["d"] then
        self._itemModel:updateItems(result["d"]["items"])
        result["d"]["items"] = nil

        self._userModel:updateUserData(result["d"])
        if result.d.dayInfo then
            self._playerDayModel:updateDayInfo(result.d.dayInfo)
        end
        local drawAward = result["d"]["drawAward"]
        if drawAward then
            self._spellBooksModel:setDrawData(drawAward)
        end
    end
    if result["unset"] ~= nil then 
        local removeItems = self._itemModel:handelUnsetItems(result["unset"])
        self._itemModel:delItems(removeItems, true)
    end
    self:callback(result)
end

-- 英雄法术书
function HeroServer:onInitHeroSlot( result,error )
    if error ~= 0 then return end
    self:handleSpellBookData(result)
end

function HeroServer:onCombineSpellBook( result,error )
    if error ~= 0 then return end
    self:handleSpellBookData(result)
end

function HeroServer:onUpLevelSpellBook( result,error )
    if error ~= 0 then return end
    self:handleSpellBookData(result)
end

function HeroServer:onRefreshHeroSlot( result,error )
    if error ~= 0 then return end
    self:handleSpellBookData(result)
end

function HeroServer:onSaveHeroSlot( result,error )
    if error ~= 0 then return end
    self:handleSpellBookData(result)
end

function HeroServer:onEquipSpellBook( result,error )
    if error ~= 0 then return end
    self:handleSpellBookData(result)
end

function HeroServer:onTakeSpellBook( result,error )
    if error ~= 0 then return end
    self:handleSpellBookData(result)
end

function HeroServer:onResolveSpellBookPiece( result,error )
    if error ~= 0 then return end
    self:handleSpellBookData(result,true)
    self:callback(result)
end

function HeroServer:onUpLevelHeroSlot( result,error )
    if error ~= 0 then return end
    self:handleSpellBookData(result)
end

function HeroServer:handleSpellBookData( result,singleCallback )
    if not result then return end
    local spellBooksData = result and result["d"] and result["d"]["spellBooks"]
    if spellBooksData then
        self._spellBooksModel:updateData(spellBooksData)
        result["d"]["spellBooks"] = nil
    end
    
    self:updateHeroGlobalAttributes(result)
    local heroData = result and result["d"] and result["d"]["heros"]
    if heroData then
        self._heroModel:updateHeroData(heroData)
    end
    -- hero界面在回调里处理数据
    if not singleCallback then
        self:callback(result, 0 == tonumber(error))
    end
    if heroData then result["d"]["heros"] = nil end

    -- 处理道具
    local itemModel = self._modelMgr:getModel("ItemModel")
    if result["d"] and result["d"]["items"] then
        itemModel:updateItems(result["d"]["items"], true)
        result["d"]["items"] = nil
    end
    if result["unset"] ~= nil then 
        local removeItems = itemModel:handelUnsetItems(result["unset"])
        itemModel:delItems(removeItems, true)
    end
    local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(result and result["d"])
end
return HeroServer