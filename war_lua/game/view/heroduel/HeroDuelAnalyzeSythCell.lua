--[[
    Filename:    HeroDuelAnalyzeSythCell.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2017-02-08 19:01:19
    Description: File description
--]]


local HeroDuelAnalyzeSythCell = class("HeroDuelAnalyzeSythCell", cc.TableViewCell)

function HeroDuelAnalyzeSythCell:ctor()

end

function HeroDuelAnalyzeSythCell:onInit()

end


function HeroDuelAnalyzeSythCell:reflashUI(inData, inFirstData)
    if math.mod(self:getIdx(), 2) == 0 then
        if self._bg == nil then 
            self._bg = cc.Scale9Sprite:createWithSpriteFrameName("globalPanelUI6_floatBg2.png")
            self._bg:setCapInsets(cc.rect(10, 10, 1, 1))
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
        self._teamIcon:setPosition(cc.p(15, 35))
        self._teamIcon:setAnchorPoint(cc.p(0, 0.5))
        self:addChild(self._teamIcon, 10)
    else
        IconUtils:updateTeamIconByView(self._teamIcon, param)
    end

    if self._progBar == nil  then 
        local progBarBg = cc.Scale9Sprite:createWithSpriteFrameName("img_dataBarBg_heroDuel.png")
        progBarBg:setContentSize(105, 20)
        progBarBg:setAnchorPoint(0, 0.5)
        progBarBg:setPosition(95, 25)

        self._progBar = cc.Scale9Sprite:createWithSpriteFrameName("img_dataBBarBg_heroDuel.png")
        self._progBar:setCapInsets(cc.rect(5, 0, 1, 1))
        self._progBar:setContentSize(105, 20)
        self._progBar:setAnchorPoint(0, 0)
        self._progBar:setPosition(0, 0)
        progBarBg:addChild(self._progBar)
        self:addChild(progBarBg, 9)
    end

    if self._labNum == nil then
        self._labNum = cc.Label:createWithTTF(inData.mvp .. "次", UIUtils.ttfName, 20)
        self._labNum:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
        self._labNum:setPosition(147.5, 45)
        self._labNum:setAnchorPoint(0.5, 0.5)
        self:addChild(self._labNum)
    end
    self._labNum:setString(inData.mvp .. "次")

    if self._progBar1 == nil  then 
        local progBarBg = cc.Scale9Sprite:createWithSpriteFrameName("img_dataBarBg_heroDuel.png")
        progBarBg:setContentSize(105, 20)
        progBarBg:setAnchorPoint(0, 0.5)
        progBarBg:setPosition(225, 25)

        self._progBar1 = cc.Scale9Sprite:createWithSpriteFrameName("img_dataGBarBg_heroDuel.png")
        self._progBar1:setCapInsets(cc.rect(5, 0, 1, 1))
        self._progBar1:setContentSize(105, 20)
        self._progBar1:setAnchorPoint(0, 0)
        self._progBar1:setPosition(0, 0)
        progBarBg:addChild(self._progBar1)
        self:addChild(progBarBg, 9)
    end

    if self._labNum1 == nil then
        self._labNum1 = cc.Label:createWithTTF(inData.show .. "次", UIUtils.ttfName, 20)
        self._labNum1:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
        self._labNum1:setPosition(277.5, 45)
        self._labNum1:setAnchorPoint(0.5, 0.5)
        self:addChild(self._labNum1)
    end
    self._labNum1:setString(inData.show .. "次")



    if self._progBar2 == nil  then 
        local progBarBg = cc.Scale9Sprite:createWithSpriteFrameName("img_dataBarBg_heroDuel.png")
        progBarBg:setContentSize(105, 20)
        progBarBg:setAnchorPoint(0, 0.5)
        progBarBg:setPosition(350, 25)

        self._progBar2 = cc.Scale9Sprite:createWithSpriteFrameName("img_dataHBarBg_heroDuel.png")
        self._progBar2:setCapInsets(cc.rect(5, 0, 1, 1))
        self._progBar2:setContentSize(105, 20)
        self._progBar2:setAnchorPoint(0, 0)
        self._progBar2:setPosition(0, 0)
        progBarBg:addChild(self._progBar2)
        self:addChild(progBarBg, 9)
    end

    if self._labNum2 == nil then
        self._labNum2 = cc.Label:createWithTTF(inData.ban .. "次", UIUtils.ttfName, 20)
        self._labNum2:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
        self._labNum2:setPosition(402.5, 45)
        self._labNum2:setAnchorPoint(0.5, 0.5)
        self:addChild(self._labNum2)
    end
    self._labNum2:setString(inData.ban .. "次")

    local parentNum = 0
    local parentNum1 = 0
    local parentNum2 = 0

    if inFirstData.mvp ~= 0 then 
        parentNum = inData.mvp / inFirstData.mvp
    end
    
    if inFirstData.show ~= 0 then 
        parentNum1 = inData.show / inFirstData.show
    end

    if inFirstData.ban ~= 0 then 
        parentNum2 = inData.ban / inFirstData.ban
    end    


    self._progBar:setContentSize(parentNum * 105, 20)
    self._progBar1:setContentSize(parentNum1 * 105, 20)
    self._progBar2:setContentSize(parentNum2 * 105, 20)

    self._progBar:setVisible(true)
    self._progBar1:setVisible(true)
    self._progBar2:setVisible(true)
    
    if (parentNum * 100) < 1 then 
        self._progBar:setVisible(false)
    end

    if (parentNum1 * 100) < 1 then 
        self._progBar1:setVisible(false)
    end   

    if (parentNum2 * 100) < 1 then 
        self._progBar2:setVisible(false)
    end     
end

return HeroDuelAnalyzeSythCell