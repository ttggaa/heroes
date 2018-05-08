--[[
    Filename:    TeamBoostUpgradeDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-02-07 16:08:20
    Description: File description
--]]


local TeamBoostUpgradeDialog = class("TeamBoostUpgradeDialog", BasePopView)

function TeamBoostUpgradeDialog:ctor(param)
    TeamBoostUpgradeDialog.super.ctor(self)
    -- self._callback = param.callback
    -- self._detailCell = {}
    self._callback = param.callback
end

function TeamBoostUpgradeDialog:onInit()

    local closeBtn = self:getUI("closeBtn")
    registerClickEvent(closeBtn, function()        
        print("=======registerClickEvent---------===")
        self._callback()
        UIUtils:reloadLuaFile("teamboost.TeamBoostUpgradeDialog")
        self:close()
    end)

    -- self._fight = self:getUI("bg.layer.fight")
    -- self._fight:setVisible(false)

    -- self._oldFight = self:getUI("bg.layer.fight.oldFight")
    -- self._oldFight:setFntFile(UIUtils.bmfName_zhandouli)

    -- self._newFight = self:getUI("bg.layer.fight.newFight")
    -- self._newFight:setFntFile(UIUtils.bmfName_zhandouli)

    -- local oldName = self:getUI("bg.layer.oldIcon.name")
    local oldName = self:getUI("bg.layer.attrImg.oldName")
    oldName:setFontName(UIUtils.ttfName_Title)
    oldName:setColor(cc.c3b(254, 251, 150))
    oldName:enable2Color(1, cc.c4b(208, 153, 62, 255))
    oldName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 3)
    oldName:setFontSize(30)
    -- local newName = self:getUI("bg.layer.newIcon.name")
    local newName = self:getUI("bg.layer.attrImg.newName")
    newName:setFontName(UIUtils.ttfName_Title)
    newName:setColor(cc.c3b(254, 251, 150))
    newName:enable2Color(1, cc.c4b(208, 153, 62, 255))
    newName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 3)
    newName:setFontSize(30)

    self._attrLab1 = self:getUI("bg.layer.attrLab1")
    self._attrLab1:setVisible(false)

    self._attrImg = self:getUI("bg.layer.attrImg")
    self._attrImg:setVisible(false)

    self._jiantou = self:getUI("bg.layer.jiantou")
    self._jiantou:setVisible(false)

    self._oldIcon = self:getUI("bg.layer.oldIcon")
    self._oldIcon:setVisible(false)
    self._newIcon = self:getUI("bg.layer.newIcon")
    self._newIcon:setVisible(false)
    self._tipLab = self:getUI("bg.layer.attrLab1.tipLab")

    self._viewMgr:lock(-1)
    self._tishi = self:getUI("bg.layer.tishi")
    self._tishi:setVisible(false)
    self._bg = self:getUI("bg")
    self._bgImg = self:getUI("bg.bg3")
    self._layer = self:getUI("bg.layer")
end

function TeamBoostUpgradeDialog:reflashUI(inData)
    dump(inData,"inData")
    local oldData = inData.old
    local newData = inData.new
    -- local oldFightLab = inData.oldFight
    -- local newFightLab = inData.newFight
    local techniqiueshow = inData.techniqiueshow

    local oldStage = TeamUtils:getTeamBoostName(oldData)
    local newStage = TeamUtils:getTeamBoostName(newData)

    -- print("============", oldData, newData)
    self._oldIcon = self:getUI("bg.layer.oldIcon")
    self._oldIcon:loadTexture("globalImageUI_teamboost" .. oldStage[1] .. ".png", 1)

    self._newIcon = self:getUI("bg.layer.newIcon")
    self._newIcon:loadTexture("globalImageUI_teamboost" .. newStage[1] .. ".png", 1)

    -- self._oldFight:setString(oldFightLab)
    -- self._newFight:setString(newFightLab)

    -- local oldName = self:getUI("bg.layer.oldIcon.name")
    local oldName = self:getUI("bg.layer.attrImg.oldName")
    oldName:setString(lang("TECHINIQUELEVEL_" .. oldData))
    
    -- local newName = self:getUI("bg.layer.newIcon.name")
    local newName = self:getUI("bg.layer.attrImg.newName")
    newName:setString(lang("TECHINIQUELEVEL_" .. newData))

    local desc = lang("TECHINIQUESHOW_" .. techniqiueshow) 
    self._tipLab:setString(desc)

    local sizeSchedule
    local step = 0.5
    local stepConst = 30
    local bg1Height = 150
    self.bgWidth = self._bgImg:getContentSize().width    
    local maxHeight = self._bgImg:getContentSize().height
    self._bgImg:setOpacity(0)
    self._layer:setVisible(false)    
    self._bgImg:setPositionX(self._layer:getContentSize().width*0.5)
    self._bgImg:setContentSize(cc.size(self.bgWidth,bg1Height))  
    self:animBegin(function( )
        self._bgImg:setOpacity(255)  
        sizeSchedule = ScheduleMgr:regSchedule(1,self,function( )
            stepConst = stepConst-step
            if stepConst < 1 then 
                stepConst = 1
            end
            bg1Height = bg1Height+stepConst
            if bg1Height < maxHeight then
                self._bgImg:setContentSize(cc.size(self.bgWidth,bg1Height))                   
            else
                self._layer:setVisible(true)
                self._bgImg:setContentSize(cc.size(self.bgWidth,maxHeight))
                ScheduleMgr:unregSchedule(sizeSchedule)
                self:addDecorateCorner()
                self:nextAnimFunc() 
                -- self._viewMgr:unlock()          
            end
        end)
    end)
end

function TeamBoostUpgradeDialog:nextAnimFunc()
    -- audioMgr:playSound("adTitle")
    local bgW,bgH = self._bg:getContentSize().width,self._bg:getContentSize().height
  
    ScheduleMgr:delayCall(500, self, function()
        if not self._oldIcon then return end
        self._oldIcon:setVisible(true)
        self._oldIcon:runAction(cc.Sequence:create(cc.MoveBy:create(0, cc.p(60, 0)),cc.MoveBy:create(0.15, cc.p(-60, 0)))) -- ,cc.JumpBy:create(0.15, cc.p(-60, 0),10,1)))

        if not self._newIcon then return end
        self._newIcon:setVisible(true)
        self._newIcon:runAction(cc.Sequence:create(cc.MoveBy:create(0, cc.p(-60, 0)),cc.MoveBy:create(0.15, cc.p(60, 0)))) -- ,cc.JumpBy:create(0.15, cc.p(60, 0),10,1)))
    end)

    ScheduleMgr:delayCall(600, self, function()
        if not self._jiantou then return end
        self._jiantou:setVisible(true)
    end)

    -- ScheduleMgr:delayCall(700, self, function()
    --     if not self._fight then return end
    --     self._fight:setVisible(true)

    --     local mcShua = mcMgr:createViewMC("shuxingshuguang_itemeffectcollection", true, false, function (_, sender)
    --         sender:removeFromParent()
    --     end,RGBA8888)
    --     mcShua:setPosition(cc.p(self._fight:getContentSize().width*0.5-80, 14))
    --     audioMgr:playSound("adTag")
    --     self._fight:addChild(mcShua)
    -- end)

    ScheduleMgr:delayCall(700, self, function()
        if not self._attrImg then return end
        self._attrImg:setVisible(true)
        -- attrImg:runAction(cc.JumpBy:create(0.2,cc.p(0,0),10,1))
        local mcShua = mcMgr:createViewMC("shuxingshuguang_itemeffectcollection", true, false, function (_, sender)
            sender:removeFromParent()
        end,RGBA8888)
        mcShua:setPosition(cc.p(self._attrImg:getContentSize().width*0.5-80, 14))
        audioMgr:playSound("adTag")
        self._attrImg:addChild(mcShua)
    end)

    ScheduleMgr:delayCall(1100, self, function()
        if not self._attrLab1 then return end
        self._attrLab1:setVisible(false)
        local callFunc = cc.CallFunc:create(function()
            self._attrLab1:setVisible(true)
        end)
        local specialTxt = self:getUI("bg.layer.attrLab1.specialTxt")
        -- specialTxt:runAction(cc.Sequence:create(cc.ScaleTo:create(0, 2), cc.ScaleTo:create(0.2, 1))) 
        specialTxt:runAction(cc.Sequence:create(cc.MoveBy:create(0.01, cc.p(-400, 0)),cc.MoveBy:create(0.3, cc.p(400, 0)))) -- ,cc.JumpBy:create(0.3, cc.p(400, 0),10,1)))
        local tipLab = self:getUI("bg.layer.attrLab1.tipLab")
        tipLab:runAction(cc.Sequence:create(cc.MoveBy:create(0.01, cc.p(400, 0)), callFunc, cc.MoveBy:create(0.3, cc.p(-400, 0)))) --,cc.JumpBy:create(0.3, cc.p(-400, 0),10,1)))
    end)
    ScheduleMgr:delayCall(1600, self, function()
        if not self._tishi then return end
        self._tishi:setVisible(true)
        self._viewMgr:unlock()
    end)

end

function TeamBoostUpgradeDialog:animBegin(callback)
    -- 播放获得音效
    audioMgr:playSound("ItemGain_1")

    self._bg = self:getUI("bg")
    self:addPopViewTitleAnim(self._bg, "xueweitisheng_huodetitleanim", 568, 480)

    ScheduleMgr:delayCall(450, self, function( )
        if self._bg then
            --震屏
            -- UIUtils:shakeWindow(self._bg)
            -- ScheduleMgr:delayCall(200, self, function( )
            if callback and self._bg then
                callback()
            end
            -- end)
        end
    end)
   
end

function TeamBoostUpgradeDialog:getMaskOpacity()
    return 230
end

return TeamBoostUpgradeDialog