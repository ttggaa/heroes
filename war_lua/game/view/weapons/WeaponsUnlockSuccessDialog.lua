--[[
    Filename:    WeaponsUnlockSuccessDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-10-10 11:49:51
    Description: File description
--]]

local WeaponsUnlockSuccessDialog = class("WeaponsUnlockSuccessDialog", BasePopView)

function WeaponsUnlockSuccessDialog:ctor(params)
    WeaponsUnlockSuccessDialog.super.ctor(self)
    self._isShowLimitInfo = params.isShowLimitInfo
    self._callback = params.callback
end

function WeaponsUnlockSuccessDialog:onInit()
    local bg1 = self:getUI("bg.layer.bg1")
    bg1:setContentSize(cc.size(1136,320))

    local bg = self:getUI("bg")
 
    local closeBtn = self:getUI("closeBtn")
    self:registerClickEvent(closeBtn, function()
        if self._callback and type(self._callback) == "function" then
            self._callback()
        end
        self:close()
        UIUtils:reloadLuaFile("weapons.WeaponsUnlockSuccessDialog")
    end)

    self._anim = {}
    for i=1,7 do
        if i == 1 then
            self._anim[i] = self:getUI("bg.layer.oldIcon")
        elseif i == 2 then
            self._anim[i] = self:getUI("bg.layer.jiantou")
        elseif i == 3 then
            self._anim[i] = self:getUI("bg.layer.newIcon")
        elseif i == 4 then
            self._anim[i] = self:getUI("bg.layer.fight")
        else -- if i == 5 then
            self._anim[i] = self:getUI("bg.layer.attrLab" .. (i - 5))
        end
        if self._anim[i] then
            self._anim[i]:setVisible(false)
        end
    end

    -- self._newSkillOpen = 0
    self._tishi = self:getUI("bg.layer.tishi")
    self._bg = self:getUI("bg")
    self._layer = self:getUI("bg.layer")
    self._bgImg = self:getUI("bg.layer.bg1")
   
    -- self._viewMgr:lock()
end

function WeaponsUnlockSuccessDialog:nextAnimFunc()
    -- audioMgr:playSound("adTitle")
    local bgW,bgH = self._bg:getContentSize().width,self._bg:getContentSize().height
    self._bgW,self._bgH = bgW,bgH
  
    local userlvl = self._modelMgr:getModel("UserModel"):getData().lvl 

    local animTimes = 7
    -- if userlvl < 40 then
    --     animTimes = 9
    -- end
    for i=1,animTimes do
        local des = self._anim[i]
        -- print("========", des:getName())
        ScheduleMgr:delayCall(i*120, self, function( )
            des:setVisible(true)
            des:runAction(cc.JumpBy:create(0.1,cc.p(0,0),10,1))--cc.Sequence:create(,cc.CallFunc:create(function ( )
                if i < 4 then
                    audioMgr:playSound("adIcon")
                end
                if i >= 4 and i <= 9 then
                    local mcShua = mcMgr:createViewMC("shuxingshuguang_itemeffectcollection", true, false, function (_, sender)
                        sender:removeFromParent()
                    end,RGBA8888)
                    mcShua:setPosition(cc.p(des:getContentSize().width*0.5-80, 12))
                    mcShua:setScaleY(0.8)
                    audioMgr:playSound("adTag")
                    -- mcShua:setPlaySpeed(0.2)
                    des:addChild(mcShua)
                end
                if i == animTimes then
                    self._tishi:setVisible(true)
                    self._viewMgr:unlock()
                end
        end)
    end
end

function WeaponsUnlockSuccessDialog:reflashUI(inData)
    local weaponId = inData.weaponId or 11
    local weaponType = inData.weaponType or 1

    -- local teamModel = self._modelMgr:getModel("TeamModel")
    local weaponsTab = tab:SiegeWeapon(weaponId)
    local weaponTypeTab = tab:SiegeWeaponType(weaponType)

    local weaponIcon = self:getUI("bg.layer.weaponIcon")
    local fileName = "asset/uiother/weapon/Weapon_" .. weaponId .. ".png"
    weaponIcon:loadTexture(fileName, 0)
    local mc1bg = mcMgr:createViewMC("huodedaojudiguang_commonlight", true, false, function (_, sender)
        sender:gotoAndPlay(0)
    end,RGBA8888)
    mc1bg:setPosition(weaponIcon:getContentSize().width*0.5, weaponIcon:getContentSize().height*0.5)
    mc1bg:setPlaySpeed(1)
    -- mc1bg:setScale(1.5)
    weaponIcon:addChild(mc1bg, -1)


    local wName = self:getUI("bg.layer.wName")
    wName:setColor(cc.c3b(253,235,160))
    wName:enable2Color(1, cc.c4b(241, 171, 51, 255))
    wName:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    wName:setFontSize(32)
    wName:setString(lang(weaponsTab.name))

    local attrTipLab = self:getUI("bg.layer.shuxingBg.infoBg1.attrTipLab")
    attrTipLab:setString(lang(weaponTypeTab.name))

    local richtextBg = self:getUI("bg.layer.shuxingBg.infoBg2")
    local desc = lang(weaponsTab.des)
    if string.find(desc, "color=") == nil then
        desc = "[color=aaa082]"..desc.."[-]"
    end   
    richText = RichTextFactory:create(desc, richtextBg:getContentSize().width, richtextBg:getContentSize().height)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(richtextBg:getContentSize().width*0.5, richtextBg:getContentSize().height - richText:getInnerSize().height*0.5)
    richText:setName("richText")
    richtextBg:addChild(richText)

    local infoBg3 = self:getUI("bg.layer.shuxingBg.infoBg3")
    -- local skillBg = self:getUI("bg.rightSubBg.panel.skillBg")
    local wSkill = weaponsTab.skill
    local indexId = 1
    local _skill = wSkill[indexId]
    local skillEffect = tab:SiegeSkillDes(_skill)
    -- print("_skill==========", _skill)
    local param = {sysSkill = skillEffect}
    local skillIcon = infoBg3:getChildByFullName("skillIcon" .. indexId)
    if not skillIcon then
        skillIcon = IconUtils:createWeaponsSkillIcon(param)
        skillIcon:setName("skillIcon" .. indexId)
        skillIcon:setScale(0.7)
        skillIcon:setPosition(-10, -10)
        infoBg3:addChild(skillIcon)
    else
        IconUtils:updateWeaponsSkillIcon(skillIcon, param)
    end

    local skillName = self:getUI("bg.layer.shuxingBg.infoBg3.skillName")
    skillName:setString(lang(skillEffect.name))

    local richtextBg = self:getUI("bg.layer.shuxingBg.infoBg3.richtextBg")
    local desc = lang(skillEffect.showdec)
    if string.find(desc, "color=") == nil then
        desc = "[color=aaa082]"..desc.."[-]"
    end   
    richText = RichTextFactory:create(desc, richtextBg:getContentSize().width, richtextBg:getContentSize().height)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(richtextBg:getContentSize().width*0.5, richtextBg:getContentSize().height - richText:getInnerSize().height*0.5)
    richText:setName("richText")
    richtextBg:addChild(richText)

    local sizeSchedule
    local step = 0.5
    local stepConst = 30
    local bg1Height = 150 
    self.bgWidth = 1136   
    
    local maxHeight = 320 --self._bgImg:getContentSize().height
    print(self._bgImg:getContentSize().height,"=======self._bgImg:getContentSize().height=========maxHeight========",maxHeight)
    self._bgImg:setOpacity(0)
    self._layer:setVisible(false)
    self._bgImg:setPositionX(self._layer:getContentSize().width*0.5)
    self._bgImg:setContentSize(cc.size(self.bgWidth,bg1Height))  
    self:animBegin(function( )
        self._bgImg:setOpacity(255)
        self._layer:setVisible(true) 
        sizeSchedule = ScheduleMgr:regSchedule(1,self,function( )
            stepConst = stepConst-step
            if stepConst < 1 then 
                stepConst = 1
            end
            bg1Height = bg1Height+stepConst
            if bg1Height < maxHeight then
                self._bgImg:setContentSize(cc.size(self.bgWidth,bg1Height))                   
            else
                self._bgImg:setContentSize(cc.size(self.bgWidth,maxHeight))
                ScheduleMgr:unregSchedule(sizeSchedule)
                self:addDecorateCorner() 
                -- self:nextAnimFunc()            
            end
        end)
    end)
end

function WeaponsUnlockSuccessDialog:animBegin(callback)
    -- 播放获得音效
    audioMgr:playSound("ItemGain_1")
    --升星成功
    -- self:addPopViewTitleAnim(self._bg, "juexingtisheng_juexingchenggong", 560, 465)
    local mcName = "jiesuochenggong_jiesuochenggong"
    if self._isShowLimitInfo then
        mcName = "xianshishiyong_jiesuochenggong"
    end
    self:addPopViewTitleAnim(self._bg, mcName, 568, 450)

    ScheduleMgr:delayCall(400, self, function( )
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


-- 弹出悬浮窗（如：获得物品）title动画
function WeaponsUnlockSuccessDialog:addPopViewTitleAnim(view,mcName,x,y)
    local mcStar = mcMgr:createViewMC( mcName, false, false, function (_, sender)

    end,RGBA8888)

    local children = mcStar:getChildren()
    for k,v in pairs(children) do
        if k == 2 then
            local _children = v:getChildren()
            for kk,vv in pairs(_children) do
                -- vv:setSpriteFrame("TeamAwakenImageUI_img24.png")
            end
        end
    end
    mcStar:addCallbackAtFrame(84, function()
        mcStar:gotoAndPlay(35)
    end)
    mcStar:setPosition(x,y+35)
    view:addChild(mcStar,99)

    mcStar:addCallbackAtFrame(6,function( )
        local mc = mcMgr:createViewMC("caidai_huodetitleanim", false, false, function (_, sender)
        --sender:gotoAndPlay(80)
        end,RGBA8888)
        -- mc:setPlaySpeed(1)
        mc:setPosition(cc.p(x,y))
        view:addChild(mc,100)
                 
        local mc1bg = mcMgr:createViewMC("huodedaojudiguang_commonlight", true, false, function (_, sender)
            sender:gotoAndPlay(0)
        end,RGBA8888)
        mc1bg:setPlaySpeed(1)
        mc1bg:setScale(1.5)

        local clipNode2 = cc.ClippingNode:create()
        clipNode2:setPosition(x,y+45)
        local mask = cc.Sprite:createWithSpriteFrameName("globalImage_IconMaskHalfCircle.png")
        mask:setScale(2.5)
        mask:setPosition(0,147)
        clipNode2:setStencil(mask)
        clipNode2:setAlphaThreshold(0.5)
        mc1bg:setPositionY(-10)
        clipNode2:addChild(mc1bg)
        view:addChild(clipNode2,-1)
        UIUtils:shakeWindow(view)
    end) 
end

function WeaponsUnlockSuccessDialog:getMaskOpacity()
    return 230
end

return WeaponsUnlockSuccessDialog