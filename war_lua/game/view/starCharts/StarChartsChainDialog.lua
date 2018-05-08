--[[
    @FileName   StarChartsChainDialog.lua
    @Authors    cuiyake
    @Date       2018-03-27 20:21:25
    @Email      <cuiyake@playcrad.com>
    @Description   星链激活UI
--]]

local StarChartsChainDialog = class("StarChartsChainDialog",BasePopView)
function StarChartsChainDialog:ctor(params)
    self.super.ctor(self)
    self._parent = params.container
    self._showtype = params.showtype
    self._starId = params.starId
    self._catenaId = params.catenaId
    self._callBack = params.callback or nil
    self._itemTable = {}
end

-- 初始化UI后会调用, 有需要请覆盖
function StarChartsChainDialog:onInit()
    --关闭按钮
    self:registerClickEventByName("Panel1", function ()
        ScheduleMgr:nextFrameCall(self, function()
            if self._callBack ~= nil then
                self._callBack(self._showtype)
            end
            self:close()
            UIUtils:reloadLuaFile("starCharts.StarChartsChainDialog")
        end)
    end)
    self._bg = self:getUI("Panel1")
    self._bg1 = self:getUI("Panel1.bg")
    self._Panel1 = self:getUI("Panel1.Panel1") --星链激活
    self._Panel2 = self:getUI("Panel1.Panel2") --构成效果
    self._effectbg = self:getUI("Panel1.effectbg")
    self._effectdesc = self:getUI("Panel1.effectdesc")
    self._touchLab = self:getUI("Panel1.touchLab")
    self._leftbg = self:getUI("leftbg")
    self._rightbg = self:getUI("rightbg")
    self._leftbg:setVisible(false)
    self._rightbg:setVisible(false)

    self._containerNode = {self._Panel1,self._effectbg,self._effectdesc,self._touchLab}

    self._Panel1:setVisible(self._showtype == StarChartConst.SatrChainType)
    self._Panel2:setVisible(self._showtype == StarChartConst.SatrCompletedType)
    if self._showtype ==  StarChartConst.SatrChainType then
        self:starChainActived()
    else
        self:starCompleted()
    end
    self._bg:setTouchEnabled(false)
end
function StarChartsChainDialog:showLeftRightbg()
    self._leftbg:setVisible(true)
    self._rightbg:setVisible(true)

    local moveOffset = {25,25}
    local leftPosx,leftPosy = self._leftbg:getPositionX(),self._leftbg:getPositionY()
    local rightPosx,rightPosy = self._rightbg:getPositionX(),self._rightbg:getPositionY()
    self._leftbg:setPosition(leftPosx-moveOffset[1], leftPosy-moveOffset[2])
    self._leftbg:runAction(cc.MoveTo:create(0.1,cc.p(leftPosx, leftPosy)))
    self._rightbg:setPosition(rightPosx - moveOffset[1], rightPosy-moveOffset[2])
    self._rightbg:runAction(cc.MoveTo:create(0.1,cc.p(rightPosx, rightPosy)))
end

function StarChartsChainDialog:animBegin(callback)
    local addTime = 0.08
    local checkOpacity = nil
    checkOpacity = function(child)
        for k,v in pairs(child) do
            -- v:setCascadeOpacityEnabled(true)
            v:setOpacity(0)
            if v:getChildrenCount() > 0 then
                checkOpacity(v:getChildren())
            end
        end
    end 
    
    checkOpacity(self._containerNode)

    self:addPopViewTitleAnim(self._bg, "xinglianjihuo_xingtutaitou", self._bg:getContentSize().width/2, 475)
    local showTime = 0.2
    ScheduleMgr:delayCall(700, self, function( )
        if callback and self._bg1 then
            callback()
            self._bg1:runAction(cc.FadeIn:create(0.2))
            local children1 = self._containerNode
            local showChild = nil
            showChild = function(child)
                for k,v in pairs(child) do
                    showTime = showTime + addTime
                    v:runAction(cc.Sequence:create(cc.DelayTime:create(showTime),cc.FadeIn:create(0.2)))
                    if v:getChildrenCount() > 0 then
                        showChild(v:getChildren())
                    end
                end
            end 
            showChild(children1)
        end
    end)
    ScheduleMgr:delayCall(2000, self, function( )
        self._bg:setTouchEnabled(true) 
    end)
   
end


-- 第一次进入调用, 有需要请覆盖
function StarChartsChainDialog:onShow()

end

-- 接收自定义消息
function StarChartsChainDialog:reflashUI(data)

end

--星链激活
function StarChartsChainDialog:starChainActived()
    local  namebg = self._Panel1:getChildByFullName("namebg")
    local  name = namebg:getChildByFullName("name")
    local  numLayer = namebg:getChildByFullName("numlayer")
    local  activeDesc = self._Panel1:getChildByFullName("activedesc")
    local  attbg = self._Panel1:getChildByFullName("attbg")
    local  desc = attbg:getChildByFullName("desc")
    local  num = attbg:getChildByFullName("num")

    local catenaTable = tab.starChartsCatena[self._catenaId]["stars"]
    local branchNum = ccui.TextBMFont:create(#catenaTable .. "/" .. #catenaTable, "asset/fnt/font_starCharts.fnt")
    branchNum:setAnchorPoint(0,0)
    branchNum:setPosition(0,0)
    branchNum:setScale(0.8)
    numLayer:addChild(branchNum)
    local catenaImg = tab.starChartsCatena[self._catenaId]["image"]
    name:loadTexture(catenaImg .. ".png",1)

    local catenaName = lang(tab.starChartsCatena[self._catenaId]["name"])
    activeDesc:setString("恭喜你激活【" .. catenaName .."】的全部星团")
    UIUtils:center2Widget(name,numLayer,222,5)

    local quality_type = tab.starChartsCatena[self._catenaId]["quality_type"]
    local quality = tab.starChartsCatena[self._catenaId]["quality"]
    desc:setString(lang("SHOW_ATTR_" .. quality_type) .. ":")
    num:setString("+" .. quality)
    UIUtils:center2Widget(desc,num,216,5)
    
    self._effectbg:loadTexture("starCharts_starchaineffect.png",1)
    local heromasteryid = tab.starChartsCatena[self._catenaId]["heromasteryid"]
    local langdesc = tab.heroMastery[heromasteryid]["des"]
    self._effectdesc:setString(lang(langdesc))

    local bg1Height = 200
    local maxHeight = self._bg1:getContentSize().height + 12
    self._bg1:setOpacity(0)
    self:animBegin(function()
        self._bg1:setOpacity(255)
        local sizeSchedule
        local step = 0.5
        local stepConst = 30
        -- self._bg:setPositionY(self._bg:getPositionY()+self._bg:)
        local sizeSchedule
        sizeSchedule = ScheduleMgr:regSchedule(1,self,function( )
            stepConst = stepConst-step
            if stepConst < 1 then 
                stepConst = 1
            end
            bg1Height = bg1Height+stepConst
            if bg1Height < maxHeight then
                self._bg1:setContentSize(cc.size(self._bg1:getContentSize().width,bg1Height))
            else
                self._bg1:setContentSize(cc.size(self._bg1:getContentSize().width,maxHeight))
                self._bg1:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05,1,1.05),cc.ScaleTo:create(0.1,1,1)))
                ScheduleMgr:unregSchedule(sizeSchedule)
                self:showLeftRightbg()
            end
        end)
        
    end)


end

--构成成功
function StarChartsChainDialog:starCompleted()
    local  iconLayer = self._Panel2:getChildByFullName("iconLayer")
    local  desc1 = self._Panel2:getChildByFullName("attbg1.desc")
    local  num1 = self._Panel2:getChildByFullName("attbg1.num")
    local  desc2 = self._Panel2:getChildByFullName("attbg2.desc")
    local  num2 = self._Panel2:getChildByFullName("attbg2.num")

    self._containerNode2 = {self._Panel2:getChildByFullName("attbg1"),self._Panel2:getChildByFullName("attbg2"),self._effectbg,self._effectdesc,self._touchLab}

    iconLayer:removeAllChildren()
    local awardNode = cc.Node:create()
    local awardTable = tab.starCharts[self._starId]["award"]

    local totalWidth = 0
    for i,iconTable in ipairs(awardTable) do
        local itemIcon = nil
        local itemType = iconTable[1]
        local itemId = iconTable[2]
        local itemNum = iconTable[3]
        local eventStyle = 1 --{itemId = itemId, num = num,eventStyle = 0} 
        if itemType == "hero" then
            local heroData = clone(tab:Hero(itemId))
            itemIcon = IconUtils:createHeroIconById({sysHeroData = heroData})
            --itemIcon:getChildByName("starBg"):setVisible(false)
            for i=1,6 do
                if itemIcon:getChildByName("star" .. i) then
                    itemIcon:getChildByName("star" .. i):setPositionY(itemIcon:getChildByName("star" .. i):getPositionY() + 5)
                end
            end

            registerClickEvent(itemIcon, function()
                local NewFormationIconView = require "game.view.formation.NewFormationIconView"
                self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = itemId}, true)
            end)
        elseif itemType == "team" then
            local teamTeam = clone(tab:Team(itemId))
            itemIcon = IconUtils:createSysTeamIconById({sysTeamData = teamTeam,isJin=true})
           
        elseif itemType == "avatarFrame" then
            local frameData = tab:AvatarFrame(itemId)
            param = {itemId = itemId, itemData = frameData}
            itemIcon = IconUtils:createHeadFrameIconById(param)
        elseif itemType == "siegeProp" then
            local propsTab = tab:SiegeEquip(itemId)
            local param = {itemId = itemId, level = 1, itemData = propsTab, quality = propsTab.quality, iconImg = propsTab.art, eventStyle = 1}
            itemIcon = IconUtils:createWeaponsBagItemIcon(param)
        else
            if itemType ~= "tool" then
                itemId = IconUtils.iconIdMap[itemType]
            end
            itemIcon = IconUtils:createItemIconById({itemId = itemId, num = itemNum,eventStyle = eventStyle})
        end
        local scale = 0.71
        if itemType == "team" or itemType == "hero" then
            scale = 0.61
        elseif itemType == "avatarFrame" then
            scale = 0.58
        end
        itemIcon:setScale(scale)
        itemIcon:setAnchorPoint(0.5,0.5)
        itemIcon:setPositionX(itemIcon:getContentSize().width * (i - 1) )
        awardNode:addChild(itemIcon)
        totalWidth = itemIcon:getContentSize().width / 2 * (i - 1)

        itemIcon:setVisible(false)
        table.insert(self._itemTable,itemIcon)
        
    end
    awardNode:setPosition(iconLayer:getContentSize().width / 2 - totalWidth, iconLayer:getContentSize().height / 2)
    iconLayer:addChild(awardNode)

    self._effectbg:loadTexture("starCharts_starMakeeffect.png",1)
    local langdesc = tab.heroMastery[tab.starCharts[self._starId]["heromasteryid"]]["des"]
    self._effectdesc:setString(lang(langdesc))
    
    local quality_type1 = tab.starCharts[self._starId]["quality_type1"]
    local quality1 = tab.starCharts[self._starId]["quality1"]
    local quality_type2 = tab.starCharts[self._starId]["quality_type2"]
    local quality2 = tab.starCharts[self._starId]["quality2"]

    desc1:setString(lang("SHOW_ATTR_" .. quality_type1) .. ":")
    num1:setString("+" .. quality1)
    desc2:setString(lang("SHOW_ATTR_" .. quality_type2) .. ":")
    num2:setString("+" .. quality2)

    UIUtils:center2Widget(desc1,num1,216,5)
    UIUtils:center2Widget(desc2,num2,216,5)

    local bg1Height = 200
    local maxHeight = self._bg1:getContentSize().height + 12
    self._bg1:setOpacity(0)
    self:animBegin2(function()
        self._bg1:setOpacity(255)
        local sizeSchedule
        local step = 0.5
        local stepConst = 30
        -- self._bg:setPositionY(self._bg:getPositionY()+self._bg:)
        local sizeSchedule
        sizeSchedule = ScheduleMgr:regSchedule(1,self,function( )
            stepConst = stepConst-step
            if stepConst < 1 then 
                stepConst = 1
            end
            bg1Height = bg1Height+stepConst
            if bg1Height < maxHeight then
                self._bg1:setContentSize(cc.size(self._bg1:getContentSize().width,bg1Height))
            else
                self._bg1:setContentSize(cc.size(self._bg1:getContentSize().width,maxHeight))
                self._bg1:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05,1,1.05),cc.ScaleTo:create(0.1,1,1)))
                ScheduleMgr:unregSchedule(sizeSchedule)
                self:showLeftRightbg()
            end
        end)
        
    end)
end

function StarChartsChainDialog:animBegin2(callback)
    local checkOpacity = nil
    checkOpacity = function(child)
        for k,v in pairs(child) do
            -- v:setCascadeOpacityEnabled(true)
            v:setOpacity(0)
            if v:getChildrenCount() > 0 then
                checkOpacity(v:getChildren())
            end
        end
    end 
    
    checkOpacity(self._containerNode2)

    self:addPopViewTitleAnim(self._bg, "gouchengchenggong_xingtutaitou", self._bg:getContentSize().width/2, 475)
    ScheduleMgr:delayCall(700, self, function( )
        if callback and self._bg1 then
            callback()
            local addTime = 0.2
            for i,v in pairs(self._itemTable) do
                addTime = addTime + 0.1
                v:runAction(cc.Sequence:create(cc.DelayTime:create(addTime),cc.Show:create()))
            end
            self._bg1:runAction(cc.FadeIn:create(0.2))

        end
    end)

    ScheduleMgr:delayCall(810, self, function( )
            local children1 = self._containerNode2
            local showChild = nil
            local showTime = 0.2
            showChild = function(child)
                for k,v in pairs(child) do
                    showTime = showTime + 0.1
                    v:runAction(cc.Sequence:create(cc.DelayTime:create(showTime),cc.FadeIn:create(0.2)))
                    if v:getChildrenCount() > 0 then
                        showChild(v:getChildren())
                    end
                end
            end 
            showChild(children1)
    end)

    ScheduleMgr:delayCall(2000, self, function( )
        self._bg:setTouchEnabled(true) 
    end)
end

return StarChartsChainDialog

