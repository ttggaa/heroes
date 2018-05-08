--[[
    Filename:    PokedexUpgradeDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-11-09 22:16:32
    Description: File description
--]]


local PokedexUpgradeDialog = class("PokedexUpgradeDialog", BasePopView)

function PokedexUpgradeDialog:ctor(param)
    PokedexUpgradeDialog.super.ctor(self)
    self._callback = param.callback
    -- self._detailCell = {}
end

function PokedexUpgradeDialog:onInit()

    -- local bgLayer = ccui.Layout:create()
    -- bgLayer:setBackGroundColorOpacity(180)
    -- bgLayer:setBackGroundColorType(1)
    -- bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
    -- bgLayer:setTouchEnabled(true)
    -- bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    -- bg:getParent():addChild(bgLayer, -1)
    local closeBtn = self:getUI("closeBtn")
    self:registerClickEvent(closeBtn, function()        
        self._callback()
        self:close()
        UIUtils:reloadLuaFile("pokedex.PokedexUpgradeDialog")
    end)

    self._name = self:getUI("bg.layer.newIcon.name")
    -- self._name:setFontName(UIUtils.ttfName)
    self._name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._name:setFontSize(24)

    -- local oldName = self:getUI("bg.layer.attrImg.oldName")
    -- oldName:setFontName(UIUtils.ttfName)
    -- oldName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    -- oldName:setFontSize(30)

    -- local newName = self:getUI("bg.layer.attrImg.newName")
    -- newName:setFontName(UIUtils.ttfName)
    -- newName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    -- newName:setFontSize(30)

    self._viewMgr:lock(-1)
    -- self._newSkillOpen = 0
    self._tishi = self:getUI("bg.layer.tishi")
    self._bg = self:getUI("bg")

    self._layer = self:getUI("bg.layer")
    self._bgImg = self:getUI("bg.bg3")
    -- self._closeBtn = self:getUI("closeBtn")
    -- local mcMgr = MovieClipManager:getInstance()
end


function PokedexUpgradeDialog:reflashUI(inData)
    -- dump(inData,"inData")
    local oldPokedexLevel = inData.old
    local newPokedexLevel = inData.new
    local selectPokedex = inData.selectPokedex

    -- 新数据
    local pokedexTab = tab:Tujianshengji(newPokedexLevel)
    local stage = pokedexTab["stage"]
    local str = lang(tab:Tujian(selectPokedex).name) .. "图鉴" 
    if stage[2] ~= 0 then
        str = lang(tab:Tujian(selectPokedex).name) .. "图鉴 +" .. stage[2]
    end    

    local newIcon = self:getUI("bg.layer.newIcon")
    newIcon:loadTexture("pokeImage_pquality" .. stage[1] .. ".png", 1)

    local newName = self:getUI("bg.layer.newIcon.name")
    newName:setString(str)
    newName:setColor(UIUtils.colorTable["ccUIBaseColor" .. stage[1]])

    local newName = self:getUI("bg.layer.attrImg.newName")
    newName:setString("总评分+" .. pokedexTab.effect .. "%")


    -- 旧数据
    local pokedexTab = tab:Tujianshengji(oldPokedexLevel)


    local oldName = self:getUI("bg.layer.attrImg.oldName")
    oldName:setString("总评分+" .. pokedexTab.effect .. "%")

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
                self._viewMgr:unlock() 
            end
        end)
    end)
end

function PokedexUpgradeDialog:animBegin(callback)
    -- 播放获得音效
    audioMgr:playSound("ItemGain_1")
    self:addPopViewTitleAnim(self._bg, "tupochenggong_huodetitleanim", 568, 480)

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

function PokedexUpgradeDialog:getMaskOpacity()
    return 230
end

return PokedexUpgradeDialog