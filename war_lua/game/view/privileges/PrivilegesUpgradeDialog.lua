--[[
    Filename:    PrivilegesUpgradeDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-03-11 16:38:51
    Description: File description
--]]

local PrivilegesUpgradeDialog = class("PrivilegesUpgradeDialog", BasePopView)

function PrivilegesUpgradeDialog:ctor(param)
    PrivilegesUpgradeDialog.super.ctor(self)
    self._callback = param.callback
    -- self._detailCell = {}
end

-- function PrivilegesUpgradeDialog:onInit()
--     local title = self:getUI("bg.layer.layer.titleBg.layer.title")

--     -- self._burst = self:getUI("bg.layer.layer.burst")

--     self._newPrivilege = self:getUI("bg.layer.layer.newPrivilege")
--     self._newPrivilegeDes = self:getUI("bg.layer.layer.newPrivilegeDes")
--     self._dayTask = self:getUI("bg.layer.layer.dayTask")
--     self._dayTaskDes = self:getUI("bg.layer.layer.dayTaskDes")

--     local peerage = self:getUI("closeBtn")
--     self:registerClickEvent(peerage, function()
--         self:close()
--     end)
-- end 

-- function PrivilegesUpgradeDialog:reflashUI(inData)
--     local oldIcon = self:getUI("bg.layer.layer.Panel_5.old.oldIcon")
--     local oldName = self:getUI("bg.layer.layer.Panel_5.old.oldName")

--     local newIcon = self:getUI("bg.layer.layer.Panel_5.new.newIcon")
--     local newName = self:getUI("bg.layer.layer.Panel_5.new.newName")

--     -- self._newPrivilege:
--     -- self:registerClickEvent(self._burst, function()
--     --     print("解锁下一爵位")
--     -- end)
-- end
function PrivilegesUpgradeDialog:onInit()
    local bg = self:getUI("bg")
    -- local bgLayer = ccui.Layout:create()
    -- bgLayer:setBackGroundColorOpacity(180)
    -- bgLayer:setBackGroundColorType(1)
    -- bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
    -- bgLayer:setTouchEnabled(true)
    -- bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    -- bg:getParent():addChild(bgLayer, -1)
    local closeBtn = self:getUI("closeBtn")
    registerClickEvent(closeBtn, function()        
        print("=======registerClickEvent---------===")
        self._callback()
        self:close()
        UIUtils:reloadLuaFile("privileges.PrivilegesUpgradeDialog")
    end)

    -- local oldName = self:getUI("bg.layer.oldIcon.name")
    local oldName = self:getUI("bg.layer.attrImg.oldName")
    oldName:setFontName(UIUtils.ttfName)
    oldName:setColor(cc.c3b(255, 249, 181))
    oldName:enable2Color(1, cc.c4b(233, 160, 0, 255))
    oldName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 3)
    oldName:setFontSize(30)
    -- local newName = self:getUI("bg.layer.newIcon.name")
    local newName = self:getUI("bg.layer.attrImg.newName")
    newName:setFontName(UIUtils.ttfName)
    newName:setColor(cc.c3b(255, 249, 181))
    newName:enable2Color(1, cc.c4b(233, 160, 0, 255))
    newName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 3)
    newName:setFontSize(30)

    -- self._anim = {}
    -- for i=1,5 do
    --     if i == 1 then
    --         self._anim[i] = self:getUI("bg.layer.oldIcon")
    --     elseif i == 2 then
    --         self._anim[i] = self:getUI("bg.layer.jiantou")
    --     elseif i == 3 then
    --         self._anim[i] = self:getUI("bg.layer.newIcon")
    --     elseif i == 4 then
    --         self._anim[i] = self:getUI("bg.layer.attrLab1")
    --     elseif i == 5 then
    --         self._anim[i] = self:getUI("bg.layer.attrLab2")
    --     end
    --     if self._anim[i] then
    --         -- self._anim[i]:setVisible(false)
    --     end
    -- end

    -- self._newSkillOpen = 0
    self._viewMgr:lock(-1)
    self._tishi = self:getUI("bg.layer.tishi")
    self._bg = self:getUI("bg")
    self._bgImg = self:getUI("bg.bg3")
    self._layer = self:getUI("bg.layer")
    -- self._closeBtn = self:getUI("closeBtn")
    -- local mcMgr = MovieClipManager:getInstance()
end

function PrivilegesUpgradeDialog:reflashUI(inData)
    dump(inData,"inData")
    local oldPrivilegesData = inData.old
    local newPrivilegesData = inData.new

    -- local oldIcon = self:getUI("bg.layer.oldIcon")
    -- oldIcon:loadTexture("" .. tab:Peerage(inData.old).res .. ".png", 1)
    local newIcon = self:getUI("bg.layer.newIcon")
    newIcon:loadTexture("" .. tab:Peerage(inData.new).res .. ".png", 1)

    -- local oldName = self:getUI("bg.layer.oldIcon.name")
    local oldName = self:getUI("bg.layer.attrImg.oldName")
    if oldPrivilegesData == 0 then
        oldName:setString("新手")
    else
        oldName:setString(lang(tab:Peerage(inData.old).name))
    end
    
    -- local newName = self:getUI("bg.layer.newIcon.name")
    local newName = self:getUI("bg.layer.attrImg.newName")
    newName:setString(lang(tab:Peerage(inData.new).name))

    local attrLab1 = self:getUI("bg.layer.attrLab1")
    local desc = lang(tab:Peerage(inData.new).des) -- "[color=cc8945]副本中获得的玩家经验提高555%副本中获得的玩家经验提高555%副本中获得中获得的玩家经验提高555%[-]" -- SkillUtils:handleSkillDesc1(lang(sysSkill.des1), self._teamData, 1)
    local attrStr1 = RichTextFactory:create(desc, attrLab1:getContentSize().width, attrLab1:getContentSize().height)
    attrStr1:formatText()
    attrStr1:setName("attrStr1")
    attrStr1:enablePrinter(true)
    attrStr1:setPosition(attrLab1:getContentSize().width/2, attrLab1:getContentSize().height - attrStr1:getInnerSize().height/2)
    attrLab1:addChild(attrStr1)

    local attrLab2 = self:getUI("bg.layer.attrLab2")
    local desc = lang(tab:Peerage(inData.new).taskDes) -- "[color=cc8945]副本中获得的玩家经验提高555%副本中获得的玩家经验提高555%副本中获得中获得的玩家经验提高555%[-]" -- SkillUtils:handleSkillDesc1(lang(sysSkill.des1), self._teamData, 1)
    local attrStr2 = RichTextFactory:create(desc, attrLab2:getContentSize().width, attrLab2:getContentSize().height)
    attrStr2:formatText()
    attrStr2:setName("attrStr2")
    attrStr2:enablePrinter(true)
    attrStr2:setPosition(attrLab2:getContentSize().width/2, attrLab2:getContentSize().height - attrStr2:getInnerSize().height/2)
    attrLab2:addChild(attrStr2)
    

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
                -- nextAnimFunc()   
                self._viewMgr:unlock()          
            end
        end)
    end)
end

function PrivilegesUpgradeDialog:animBegin(callback)
    -- 播放获得音效
    audioMgr:playSound("ItemGain_1")

    self._bg = self:getUI("bg")
    self:addPopViewTitleAnim(self._bg, "jinshengchenggong_huodetitleanim", 568, 480)

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

function PrivilegesUpgradeDialog:getMaskOpacity()
    return 230
end

return PrivilegesUpgradeDialog