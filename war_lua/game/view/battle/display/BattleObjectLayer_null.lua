--[[
    Filename:    BattleObjectLayer_null.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-11-24 16:09:10
    Description: File description
--]]

local BattleObjectLayer = class("BattleObjectLayer")

function BattleObjectLayer:ctor() end
function BattleObjectLayer.dtor() end

function BattleObjectLayer:createObj() end
function BattleObjectLayer:getMotionFrame() end
function BattleObjectLayer:clear() end
function BattleObjectLayer:setDirect() end
function BattleObjectLayer:setPos() end
function BattleObjectLayer:setAltitude() end
function BattleObjectLayer:setZ() end
function BattleObjectLayer:Zfront() end
function BattleObjectLayer:Zback() end
function BattleObjectLayer:setMotion() end
function BattleObjectLayer:setVisible() end
function BattleObjectLayer:setShadowVisible() end
function BattleObjectLayer:getSize() end
function BattleObjectLayer:rap() end
function BattleObjectLayer:HPLabelMove() end
function BattleObjectLayer:rangeAttack() end
function BattleObjectLayer:rangeAttackPt() end
function BattleObjectLayer:rangeHit() end
function BattleObjectLayer:runEffect() end
function BattleObjectLayer:runEffectStop() end
function BattleObjectLayer:pause() end
function BattleObjectLayer:resume() end
function BattleObjectLayer:bodyDisappear() end
function BattleObjectLayer:update() end
function BattleObjectLayer:onSpeedChange() end
function BattleObjectLayer:showHP() end
function BattleObjectLayer:showSkillName() end
function BattleObjectLayer:getView() end
function BattleObjectLayer:setScale() end
function BattleObjectLayer:cancelColor() end
function BattleObjectLayer:setSaturation() end
function BattleObjectLayer:setColor() end
function BattleObjectLayer:battleEnd() end
function BattleObjectLayer:onHUDTypeChange() end

function BattleObjectLayer:playEffect_skill1() end
function BattleObjectLayer:playEffect_skill2() end
function BattleObjectLayer:playEffect_skill3() end
function BattleObjectLayer:playEffect_skill4() end
function BattleObjectLayer:playEffect_fly() end
function BattleObjectLayer:playEffect_hit1() end
function BattleObjectLayer:playEffect_hit2() end
function BattleObjectLayer:playEffect_hit2_pt() end
function BattleObjectLayer:playEffect_hit2_pt2() end
function BattleObjectLayer:playEffect_buff() end
function BattleObjectLayer:playEffect_die() end
function BattleObjectLayer:playEffect_dieFadeOut() end
function BattleObjectLayer:playEffect_totem() end
function BattleObjectLayer:playEffect_totemDisappear() end
function BattleObjectLayer:playEffect_totem2() end
function BattleObjectLayer:playEffect_totemDisappear2() end
function BattleObjectLayer:playEffect_spell() end
function BattleObjectLayer:setEffectScale() end
function BattleObjectLayer:stopEffect() end
function BattleObjectLayer:getSoldierSp() end
function BattleObjectLayer:setCampBrightness() end
function BattleObjectLayer:setSelectTeam() end
function BattleObjectLayer:stopTipEffect() end
function BattleObjectLayer:changeRes() end
function BattleObjectLayer:hitFly() end

function BattleObjectLayer:windFly() end
function BattleObjectLayer:cancelWindFly() end

function BattleObjectLayer:playCommonBuff() end
function BattleObjectLayer:addTeamHalo() end
function BattleObjectLayer:hideSkillArea() end
function BattleObjectLayer:beforeClear() end
function BattleObjectLayer:destroy() end

-- function BattleObjectLayer:() end
-- function BattleObjectLayer:() end
-- function BattleObjectLayer:() end
-- function BattleObjectLayer:() end
-- function BattleObjectLayer:() end
-- function BattleObjectLayer:() end

return BattleObjectLayer