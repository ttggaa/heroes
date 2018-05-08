--
-- Author: <ligen@playcrab.com>
-- Date: 2017-07-19 17:52:37
--
local CityBattleFightResultView = class("CityBattleFightResultView",BasePopView)
function CityBattleFightResultView:ctor(param)
    CityBattleFightResultView.super.ctor(self)

    self._data = param.data

    self._killData = {
        {num = 3, picName = "citybattle_view_img82"},
        {num = 4, picName = "citybattle_view_img83"},
        {num = 5, picName = "citybattle_view_img84"},
        {num = 10, picName = "citybattle_killTen_img"},
        {num = 20, picName = "citybattle_killTwenty_img"},
        {num = 30, picName = "citybattle_killThirty_img"},
        {num = 50, picName = "citybattle_killFifty_img"},
    }
end

function CityBattleFightResultView:getMaskOpacity()
    return 0
end
-- 初始化UI后会调用, 有需要请覆盖
function CityBattleFightResultView:onInit()
    self:runAction(cc.Sequence:create(
        cc.DelayTime:create(3),
        cc.CallFunc:create(function()
            self:close()
            UIUtils:reloadLuaFile("citybattle.CityBattleFightResultView")
        end
    )))

    local nameLabel1 = self:getUI("bg.bg1.nameLabel1")
    nameLabel1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    local nameLabel2 = self:getUI("bg.bg1.nameLabel2")
    nameLabel2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    local label = self:getUI("bg.bg1.label")
    label:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    local headData = nil
    if self._data.win then
        nameLabel1:setString(self._data.atk.name == "" and "中立守卫"  or self._data.atk.name)
        nameLabel2:setString(self._data.def.name == "" and "中立守卫"  or self._data.def.name)
        headData = tab:HeroSkin(tonumber(self._data.atk.skin)) or tab:Hero(tonumber(self._data.atk.heroId))
    else
        nameLabel1:setString(self._data.def.name == "" and "中立守卫"  or self._data.def.name)
        nameLabel2:setString(self._data.atk.name == "" and "中立守卫"  or self._data.atk.name)
        headData = tab:HeroSkin(tonumber(self._data.def.skin)) or tab:Hero(tonumber(self._data.def.heroId))
    end

    local killNumImg = self:getUI("bg.bg1.killNumImg")
    for i = #self._killData, 1, -1 do
        if self._data.killCount >= self._killData[i].num then
            killNumImg:loadTexture(self._killData[i].picName .. ".png", 1)
            break
        end
    end

    local offsetX = (nameLabel1:getContentSize().width - nameLabel2:getContentSize().width) * 0.5
    nameLabel1:setPositionX(nameLabel1:getPositionX() + offsetX)
    nameLabel2:setPositionX(nameLabel2:getPositionX() + offsetX)
    label:setPositionX(label:getPositionX() + offsetX)

    self._mc = mcMgr:createViewMC("shengli_shengli", false, false)
    self._mc:gotoAndStop(0)
    self._mc:setPosition(206, 228)
    self:getUI("bg.bg1"):addChild(self._mc)

    local clipNode = cc.ClippingNode:create()
    clipNode:setPosition(0,-9)
    local mask = cc.Sprite:createWithSpriteFrameName("citybattle_view_btn2.png")
    mask:setPosition(0, 0)
    mask:setScale(1.1)
--    clipNode:setInverted(true)
    clipNode:setStencil(mask)
    clipNode:setAlphaThreshold(0.1)
    self._mc:getChildren()[2]:getChildren()[1]:addChild(clipNode, -1)

    local headIcon = cc.Sprite:createWithSpriteFrameName(headData.herohead .. ".jpg")
    headIcon:setPosition(-5,-5)
    clipNode:addChild(headIcon)
end


function CityBattleFightResultView:onShow()
    self._mc:gotoAndPlay(0)
end
return CityBattleFightResultView