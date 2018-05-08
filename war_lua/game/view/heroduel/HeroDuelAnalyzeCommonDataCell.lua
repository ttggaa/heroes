--[[
    Filename:    HeroDuelAnalyzeCommonDataCell.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2017-02-08 19:00:55
    Description: File description
--]]


local HeroDuelAnalyzeCommonDataCell = class("HeroDuelAnalyzeCommonDataCell", cc.TableViewCell)

function HeroDuelAnalyzeCommonDataCell:ctor()

end

function HeroDuelAnalyzeCommonDataCell:onInit()

end


function HeroDuelAnalyzeCommonDataCell:reflashUI(inData, inFirstData, inType)
    print("idx================================", self:getIdx(), math.mod(self:getIdx(), 2))

    if math.mod(self:getIdx(), 2) == 0 then
        if self._bg == nil then 
            self._bg = cc.Scale9Sprite:createWithSpriteFrameName("globalPanelUI_headbg.png")
            self._bg:setCapInsets(cc.rect(8, 7, 1, 1))
            self._bg:setContentSize(470, 70)
            self._bg:setAnchorPoint(0, 0)
            self:addChild(self._bg)
            self._bg:setOpacity(30)
        end
        self._bg:setVisible(true)
    else
        if self._bg ~= nil then
            self._bg:setVisible(false)
        end
    end

    if self:getIdx() == 1 then
        if self._no1 == nil then
            self._no1 = cc.Sprite:createWithSpriteFrameName("img_heroDuel_no1.png")
            self._no1:setAnchorPoint(0, 0.5)
            self._no1:setPosition(10, 35)
            self._no1:setScale(0.8)
            self:addChild(self._no1)
        end
        self._no1:setVisible(true)

        if self._otherNo ~= nil then 
            self._otherNo:setVisible(false)
        end
    else
        if self._otherNo == nil then
            self._otherNo = cc.Label:createWithTTF("No." .. self:getIdx(), UIUtils.ttfName, 20)
            self._otherNo:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
            self._otherNo:setPosition(20, 35)
            self._otherNo:setAnchorPoint(0, 0.5)
            self:addChild(self._otherNo)
        end
        self._otherNo:setVisible(true)
        self._otherNo:setString("No." .. self:getIdx())
        if self._no1 ~= nil then
            self._no1:setVisible(false)
        end
    end

    local sysTeam = tab:Team(inData.id)
    local heroDuelTab = tab:HeroDuel(ModelManager:getInstance():getModel("HeroDuelModel"):getWeekNum())
    local quality = ModelManager:getInstance():getModel("TeamModel"):getTeamQualityByStage(heroDuelTab.teamquality)

    local ast = nil
    local aLv = nil
    if ModelManager:getInstance():getModel("HeroDuelModel"):isTeamJx(inData.id) then
        ast = 3
        aLvl = tab:HeroDuejx(inData.id).aLvl
    end

    local inTeamData = {
        teamId=teamId,
        level=nil,
        star=heroDuelTab.teamstar,
        ast = ast,
        aLvl = aLvl
    }
    local param = {teamData = inTeamData, 
        sysTeamData = sysTeam,
        quality = quality[1], 
        quaAddition = 0,  
        eventStyle = 0,
    }
    if self._teamIcon == nil then
        self._teamIcon = IconUtils:createTeamIconById(param)
        self._teamIcon:setName("teamIcon")
        self._teamIcon:setScale(0.5)
        self._teamIcon:setPosition(cc.p(80, 35))
        self._teamIcon:setAnchorPoint(cc.p(0, 0.5))
        self:addChild(self._teamIcon, 10)
    else
        IconUtils:updateTeamIconByView(self._teamIcon, param)
    end

    if self._progBar == nil  then 
        local progBarBg = cc.Scale9Sprite:createWithSpriteFrameName("img_dataBarBg_heroDuel.png")
        progBarBg:setContentSize(325, 20)
        progBarBg:setAnchorPoint(0, 0)
        progBarBg:setPosition(130, 36)

        self._progBar = cc.Scale9Sprite:createWithSpriteFrameName("img_dataBBarBg_heroDuel.png")
        self._progBar:setCapInsets(cc.rect(5, 0, 1, 1))
        self._progBar:setContentSize(325, 20)
        self._progBar:setAnchorPoint(0, 0)
        self._progBar:setPosition(0, 0)
        progBarBg:addChild(self._progBar)
        self:addChild(progBarBg, 9)

        self._progBarNum = cc.Label:createWithTTF("0", UIUtils.ttfName, 16)
        self._progBarNum:setColor(UIUtils.colorTable.ccUIBaseColor1)
        self._progBarNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        self._progBarNum:setPosition(5, -1)
        self._progBarNum:setAnchorPoint(0, 0)
        progBarBg:addChild(self._progBarNum, 10)

    end


    self._progBar:setContentSize(162.5, 20)
    

    if self._progBar1 == nil  then 
        local progBarBg = cc.Scale9Sprite:createWithSpriteFrameName("img_dataBarBg_heroDuel.png")
        progBarBg:setContentSize(325, 20)
        progBarBg:setAnchorPoint(0, 1)
        progBarBg:setPosition(130, 34)

        self._progBar1 = cc.Scale9Sprite:createWithSpriteFrameName("img_dataGBarBg_heroDuel.png")
        self._progBar1:setCapInsets(cc.rect(5, 0, 1, 1))
        self._progBar1:setContentSize(325, 20)
        self._progBar1:setAnchorPoint(0, 0)
        self._progBar1:setPosition(0, 0)
        progBarBg:addChild(self._progBar1)
        self:addChild(progBarBg, 9)


        self._progBarNum1 = cc.Label:createWithTTF("0", UIUtils.ttfName, 16)
        self._progBarNum1:setColor(UIUtils.colorTable.ccUIBaseColor1)
        self._progBarNum1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        self._progBarNum1:setPosition(5,  -1)
        self._progBarNum1:setAnchorPoint(0, 0)
        progBarBg:addChild(self._progBarNum1, 10)
    end
    print("inData====",inData.show)
    local parentNum = 0
    local parentNum1 = 0
    if inType == "tab_out" then
        if inFirstData.damage ~= 0 then
            parentNum = inData.damage / inFirstData.damage
        end
        if inFirstData.damageRate ~= 0 then
            parentNum1 = inData.damageRate / inFirstData.damageRate
        end

        if inData.damage > 100000000 then
            self._progBarNum:setString(string.format("%.3f", inData.damage / 100000000) .. "亿")
        elseif inData.damage > 100000 then
            self._progBarNum:setString(string.format("%.2f", inData.damage / 10000) .. "万")
        else
            self._progBarNum:setString(inData.damage)
        end

        if inData.damageRate > 100000000 then
            self._progBarNum1:setString(string.format("%.3f", inData.damageRate / 100000000) .. "亿")
        elseif inData.damageRate > 100000 then
            self._progBarNum1:setString(string.format("%.2f", inData.damageRate / 10000) .. "万")
        else
            self._progBarNum1:setString(inData.damageRate)
        end
    elseif inType == "tab_def" then
        if inFirstData.hurt ~= 0  then 
            parentNum = inData.hurt / inFirstData.hurt
        end
        if inFirstData.hurtRate ~= 0 then 
            parentNum1 = inData.hurtRate / inFirstData.hurtRate
        end

        if inData.hurt > 100000000 then
            self._progBarNum:setString(string.format("%.3f", inData.hurt / 100000000) .. "亿")
        elseif inData.hurt > 100000 then
            self._progBarNum:setString(string.format("%.2f", inData.hurt / 10000) .. "万")
        else
            self._progBarNum:setString(inData.hurt)
        end

        if inData.hurtRate > 100000000 then
            self._progBarNum1:setString(string.format("%.3f", inData.hurtRate / 100000000) .. "亿")
        elseif inData.hurtRate > 100000 then
            self._progBarNum1:setString(string.format("%.2f", inData.hurtRate / 10000) .. "万")
        else
            self._progBarNum1:setString(inData.hurtRate)
        end

    elseif inType == "tab_treat" then
        if inFirstData.heal ~= 0  then 
            parentNum = inData.heal / inFirstData.heal
        end
        if inFirstData.healRate ~= 0 then
            parentNum1 = inData.healRate / inFirstData.healRate
        end

        if inData.heal > 100000000 then
            self._progBarNum:setString(string.format("%.3f", inData.heal / 100000000) .. "亿")
        elseif inData.heal > 100000 then
            self._progBarNum:setString(string.format("%.2f", inData.heal / 10000) .. "万")
        else
            self._progBarNum:setString(inData.heal)
        end

        if inData.healRate > 100000000 then
            self._progBarNum1:setString(string.format("%.3f", inData.healRate / 100000000) .. "亿")
        elseif inData.healRate > 100000 then
            self._progBarNum1:setString(string.format("%.2f", inData.healRate / 10000) .. "万")
        else
            self._progBarNum1:setString(inData.healRate)
        end
    end

    self._progBar:setContentSize(parentNum * 325, 20)
    self._progBar1:setContentSize(parentNum1 * 325, 20)

    self._progBar:setVisible(true)
    self._progBar1:setVisible(true)

    if (parentNum * 100) < 1 then 
        self._progBar:setVisible(false)
    end

    if (parentNum1 * 100) < 1 then 
        self._progBar1:setVisible(false)
    end
end

return HeroDuelAnalyzeCommonDataCell