--[[
    Filename:    HeroMasteryRefreshView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2015-07-13 14:45:16
    Description: File description
--]]


local FormationIconView = require("game.view.formation.FormationIconView")

local HeroMasteryRefreshView = class("HeroMasteryRefreshView", BasePopView)

HeroMasteryRefreshView.kCurrentMasteryIconTag = 1000
HeroMasteryRefreshView.kNewestMasteryIconTag = 1001

HeroMasteryRefreshView.kHeroLocked = "mastery_locked_hero.png"
HeroMasteryRefreshView.kHeroUnlocked = "mastery_unlocked_hero.png"
HeroMasteryRefreshView.kHeroLockDisabled = "mastery_lock_disabled_hero.png"

function HeroMasteryRefreshView:ctor(params)
    HeroMasteryRefreshView.super.ctor(self)
    self._container = params.container
    self._heroData = params.data
    self._userModel = self._modelMgr:getModel("UserModel")
    self._vipModel = self._modelMgr:getModel("VipModel")
    self._privilegesModel = self._modelMgr:getModel("PrivilegesModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")
end

function HeroMasteryRefreshView:disableTextEffect(element)
    if element == nil then
        element = self._widget
    end
    local desc = element:getDescription()
    if desc == "Label" then
        element:disableEffect()
        element:setFontName(UIUtils.ttfName)
    end
    local count = #element:getChildren()
    for i = 1, count do
        self:disableTextEffect(element:getChildren()[i])
    end
end

function HeroMasteryRefreshView:onInit()
    print("HeroMasteryRefreshView:onInit")
    --[[
    self._bg = self:getUI("bg")
    self._layer = self:getUI("bg.layer")
    self._scrollView = self:getUI("bg.layer.scrollview")
    self._scrollView._container = self
    self._labelTitle = self:getUI("bg.layer.label_title")
    self._labelTitle:setString(self._viewTitle)

    self._layerTag = self:getUI("bg.layer.layer_tag")
    self._layerTag:setVisible(self._showTag)

    -- description
    self._description = {}
    self._description._layer = self:getUI("bg.layer.layer_description")
    ]]
    self:disableTextEffect()
    local title = self:getUI("bg.layer_recommand.layer_recommand_bg.label_current")
    title:setFontName(UIUtils.ttfName)
    title:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    title = self:getUI("bg.layer.label_current")
    title:setFontName(UIUtils.ttfName)
    title:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    title = self:getUI("bg.layer.layer_current_bg.label_current")
    title:setFontName(UIUtils.ttfName)
    title:enableOutline(cc.c4b(93, 93, 93, 255), 2)
    title = self:getUI("bg.layer.layer_newest_bg.label_newest")
    title:setFontName(UIUtils.ttfName)
    title:enableOutline(cc.c4b(93, 93, 93, 255), 2)
    title = self:getUI("bg.layer.layer_newest_no_refresh.label_newest")
    title:setFontName(UIUtils.ttfName)
    title:enableOutline(cc.c4b(93, 93, 93, 255), 2)
    self._bg = self:getUI("bg")
    --self._masteryData = self:initMasteryData()
    self._is_refresh_btn_clicked = false
    --self._layer = self:getUI("bg.layer") -- remove the recommand button like a lighting
    self._currentMastery = {}
    for i=1, 4 do
        self._currentMastery[i] = {}
        self._currentMastery[i]._value = self._heroData["m" .. i]
        self._currentMastery[i]._lock = self._heroData["masteryLock" .. i]
        self._currentMastery[i]._image = self:getUI(string.format("bg.layer.layer_current_bg.layer_icon_%d", i))
        self._currentMastery[i]._image.tipRotation = 90
        self._currentMastery[i]._masteryMC = mcMgr:createViewMC("tihuan_heromasteryrefresh", false, false)
        self._currentMastery[i]._masteryMC:setVisible(false)
        self._currentMastery[i]._masteryMC:setPosition(cc.p(self._currentMastery[i]._image:getContentSize().width * 1.6, self._currentMastery[i]._image:getContentSize().height / 2))
        self._currentMastery[i]._image:addChild(self._currentMastery[i]._masteryMC, 100)
        self._currentMastery[i]._labelMasteryName = self:getUI(string.format("bg.layer.layer_current_bg.layer_icon_%d.label_mastery", i))
        self._currentMastery[i]._labelMasteryLevel = self:getUI(string.format("bg.layer.layer_current_bg.layer_icon_%d.label_mastery_level", i))
        self._currentMastery[i]._image_bg_normal = self:getUI(string.format("bg.layer.layer_current_bg.image_bg_%d_normal", i))
        self._currentMastery[i]._image_bg_gray = self:getUI(string.format("bg.layer.layer_current_bg.image_bg_%d_gray", i))
        self._currentMastery[i]._imageLock = self:getUI(string.format("bg.layer.layer_current_bg.layer_icon_%d.image_lock", i))
        --self:updateLockImage(i)
        self:registerClickEvent(self._currentMastery[i]._imageLock, function()
           self:onLockButtonClicked(i)
        end)
    end
    
    self._is_no_refresh = true
    self._newestMasteryLayer = self:getUI("bg.layer.layer_newest_bg")
    self._newestMasteryLayer:setVisible(not self._is_no_refresh)
    self._newestMasteryNoRefreshLayer = self:getUI("bg.layer.layer_newest_no_refresh")
    self._newestMasteryNoRefreshLayer:setVisible(self._is_no_refresh)

    self._newestMastery = {}
    for i=1, 4 do
        self._newestMastery[i] = {}
        self._newestMastery[i]._value = self._currentMastery[i]._value
        self._newestMastery[i]._lock = self._currentMastery[i]._lock
        self._newestMastery[i]._image = self:getUI(string.format("bg.layer.layer_newest_bg.layer_icon_%d", i))
        self._newestMastery[i]._image.tipRotation= 90
        self._newestMastery[i]._masteryMC = mcMgr:createViewMC("shuaxin_heromasteryrefresh", false, false)
        self._newestMastery[i]._masteryMC:setVisible(false)
        self._newestMastery[i]._masteryMC:setPosition(cc.p(self._newestMastery[i]._image:getContentSize().width * 1.2, self._newestMastery[i]._image:getContentSize().height / 2))
        self._newestMastery[i]._image:addChild(self._newestMastery[i]._masteryMC, 100)
        self._newestMastery[i]._labelMasteryName = self:getUI(string.format("bg.layer.layer_newest_bg.layer_icon_%d.label_mastery", i))
        self._newestMastery[i]._labelMasteryLevel = self:getUI(string.format("bg.layer.layer_newest_bg.layer_icon_%d.label_mastery_level", i))
        self._newestMastery[i]._image_bg_normal = self:getUI(string.format("bg.layer.layer_newest_bg.image_bg_%d_normal", i))
        self._newestMastery[i]._image_bg_gray = self:getUI(string.format("bg.layer.layer_newest_bg.image_bg_%d_gray", i))
        self._newestMastery[i]._image_recommand = self:getUI(string.format("bg.layer.layer_newest_bg.layer_icon_%d.image_recommand", i))
        --[[
        self._newestMastery[i]._imageIncrease = self:getUI(string.format("bg.layer.layer_newest_bg.layer_icon_%d.image_increase", i))
        self._newestMastery[i]._imageDecrease = self:getUI(string.format("bg.layer.layer_newest_bg.layer_icon_%d.image_decrease", i))
        self._newestMastery[i]._imageEqual = self:getUI(string.format("bg.layer.layer_newest_bg.layer_icon_%d.image_equal", i))
        ]]
        --[[
        self._newestMastery[i]._imageLock = self:getUI(string.format("bg.layer.layer_newest_bg.layer_icon_%d.image_lock", i))
        self._newestMastery[i]._imageLock:setVisible(self._newestMastery[i]._lock)
        self._newestMastery[i]._imageLockBg = self:getUI(string.format("bg.layer.layer_newest_bg.label_newest_mastery_%d.image_lock_bg", i))
        self:registerClickEvent(self._newestMastery[i]._imageLock, function()
            self:onLockButtonClicked(i)
        end)
        ]]
    end

    self._recommandMastery = {}
    -- remove the recommand button like a lighting
    --[[
    self._recommandMastery._layer = self:getUI("bg.layer_recommand")
    self._recommandMastery._btn_recommand = self:getUI("bg.layer.btn_recommand")
    self._recommandMastery._image_recommand_frame = self:getUI("bg.layer.btn_recommand.image_frame")
    self:registerClickEvent(self._recommandMastery._btn_recommand, function()
        self._recommandMastery._layer:setVisible(not self._recommandMastery._layer:isVisible())
        self._recommandMastery._image_recommand_frame:setVisible(not self._recommandMastery._image_recommand_frame:isVisible())
        self._layer:setPositionX(self._recommandMastery._layer:isVisible() and 410 or 245)
    end)
    ]]
    for i=1, 4 do
        self._recommandMastery[i] = {}
        self._recommandMastery[i]._image = self:getUI(string.format("bg.layer_recommand.layer_recommand_bg.layer_icon_%d", i))
        self._recommandMastery[i]._name = self:getUI(string.format("bg.layer_recommand.layer_recommand_bg.layer_icon_%d.label_mastery", i))
        self._recommandMastery[i]._level = self:getUI(string.format("bg.layer_recommand.layer_recommand_bg.layer_icon_%d.label_mastery_level", i))
    end

    local playerDayInfoData = self._modelMgr:getModel("PlayerTodayModel"):getData()
    self._image_privileges_icon = self:getUI("bg.layer.btn_refresh.image_privileges_icon")
    self._label_free_times = self:getUI("bg.layer.btn_refresh.image_privileges_icon.label_free_times")
    self._label_free_times:enableOutline(cc.c4b(93, 93, 93, 255), 2)
    self._label_free_times_value = self:getUI("bg.layer.btn_refresh.image_privileges_icon.label_free_times.label_free_times_value")
    self._label_free_times_value:enableOutline(cc.c4b(93, 93, 93, 255), 2)

    local freeTimes = self._privilegesModel:getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_12) - playerDayInfoData.day4
    self._image_privileges_icon:setVisible(freeTimes > 0)
    self._label_free_times_value:setString(freeTimes)

    local _, scrollNum = self._itemModel:getItemsById(3015)
    self._imageConsumeScroll = self:getUI("bg.layer.btn_refresh.image_consume_scroll")
    self._imageConsumeScroll:setVisible(freeTimes <= 0 and scrollNum > 0)
    self._labelConsumeScrollValue = self:getUI("bg.layer.btn_refresh.image_consume_scroll.label_consume_value")
    self._labelConsumeScrollValue:enableOutline(cc.c4b(93, 93, 93, 255), 2)
    self._labelConsumeScrollValue:setString(scrollNum)

    self._refreshConsume = tab:Setting("G_MASTERY_REFRESH").value
    self._imageConsume = self:getUI("bg.layer.btn_refresh.image_consume")
    self._imageConsume:setVisible(freeTimes <= 0 and scrollNum <= 0)
    self._labelConsumeValue = self:getUI("bg.layer.btn_refresh.image_consume.label_consume_value")
    self._labelConsumeValue:enableOutline(cc.c4b(93, 93, 93, 255), 2)
    self._labelConsumeValue:setString(self._refreshConsume[self:getLockedCount() + 1])

    self._imageConsumeBg = self:getUI("bg.layer.image_consume_bg")
    self._imageConsumeBg:setVisible(freeTimes <= 0)

    self._btn_refresh = self:getUI("bg.layer.btn_refresh")
    self._btn_change = self:getUI("bg.layer.btn_change")
    self._btn_cancel = self:getUI("bg.layer.btn_cancel")

    --self:initGrayProgram()
    self:visableLockImage()

    self:registerClickEventByName("bg.layer.btn_return", function ()
        self._bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.15, 0.00), cc.DelayTime:create(0.05), cc.CallFunc:create(function ()
            self._container:onRefreshViewClose()
            self._is_no_refresh = not self._is_refresh_btn_clicked
            self:setVisible(false)
        end)))
    end)

    self:registerClickEvent(self._btn_refresh, function()
        self:onButtonRefreshClicked()
    end)

    self:registerClickEvent(self._btn_change, function()
        self:onButtonChangeClicked()
    end)

    self:registerClickEvent(self._btn_cancel, function()
        self:onButtonCancelClicked()
    end)

    self:registerClickEventByName("bg.layer_recommand.btn_all_mastery", function ()
        self._viewMgr:showDialog("hero.HeroAllMasteryView", { heroData = self._heroData }, true)
    end)
    
    -- 代码加载jpg图片 add by vv
    local image_bg1 = self:getUI('bg.layer_recommand.image_bg')
    image_bg1:loadTexture("asset/bg/mastery_refresh_bg2_hero.jpg")

    local image_bg2 = self:getUI('bg.layer.image_bg')
    image_bg2:loadTexture("asset/bg/mastery_refresh_bg1_hero.jpg")

    self:updateUI()
end

function HeroMasteryRefreshView:getBg()
    return self._bg
end

--[[
function HeroMasteryRefreshView:initMasteryData()
    local result = {}
    local data = clone(tab.heroMastery)

    for _, v in pairs(data) do
        repeat
            if not v.masterylv then break end
            if not result[v.masterylv] then result[v.masterylv] = {} end
            table.insert(result[v.masterylv], v)
        until true
    end

    dump(result, "initMasteryData")
end
]]
--[[
function HeroMasteryRefreshView:initGrayProgram()
    local grayvsh = "attribute vec4 a_position;\n" ..
    "attribute vec2 a_texCoord;\n" ..
    "attribute vec4 a_color;\n" ..
    "varying vec4 v_fragmentColor;\n" ..
    "varying vec2 v_texCoord;\n" ..
    "void main()\n" ..
    "{\n" ..
        "gl_Position = CC_PMatrix * a_position;\n" ..
        "v_fragmentColor = a_color;\n" ..
        "v_texCoord = a_texCoord;\n" .. 
    "}"
    local grayfsh = "varying vec4 v_fragmentColor;\n" ..  
    "varying vec2 v_texCoord;\n" ..
    "void main()\n" ..
    "{\n" ..
        "vec4 v_orColor = v_fragmentColor * texture2D(CC_Texture0, v_texCoord);\n" ..
        "float gray = dot(v_orColor.rgb, vec3(0.299, 0.587, 0.114));\n" ..
        "gl_FragColor = vec4(gray, gray, gray, v_orColor.a);\n" ..
    "}"
    self._grayProgram = cc.GLProgram:createWithByteArrays(grayvsh, grayfsh)
    self._grayProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION)
    self._grayProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR)
    self._grayProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORDS)
    self._grayProgram:link()
    self._grayProgram:updateUniforms()
    self._grayProgram:retain()
end

function HeroMasteryRefreshView:_setProgram(node, program)
    if node and program then 
        node:setGLProgram(program) 
    end

    local children = node:getChildren()
    if children and table.getn(children) > 0 then
        for _, v in pairs(children) do
            self:_setProgram(v, program)
        end
    end 
end

function HeroMasteryRefreshView:_setGray(node)
    self._isGray = true
    self:_setProgram(node, self._grayProgram)
end

function HeroMasteryRefreshView:_removeGray(node)
    self._isGray = false
    self:_setProgram(node, cc.ShaderCache:getInstance():getProgram("ShaderPositionTextureColor_noMVP"))
end

function HeroMasteryRefreshView:markGray(node, gray)
    if self._isGray == gray then return end
    if gray then
        self:_setGray(node)
    else
        self:_removeGray(node)
    end
end
]]
function HeroMasteryRefreshView:getLockedCount()
    local lockedCount = 0
    for i=1, 4 do
        if self._currentMastery[i]._lock then
            lockedCount = lockedCount + 1
        end
    end
    return lockedCount
end

function HeroMasteryRefreshView:updateLockImage(index)
    local lock = self._currentMastery[index]._lock
    if self._is_refresh_btn_clicked then
        self._currentMastery[index]._imageLock:loadTexture(self.kHeroLockDisabled, 1)
    elseif lock then
        self._currentMastery[index]._imageLock:loadTexture(self.kHeroLocked, 1)
    else
        self._currentMastery[index]._imageLock:loadTexture(self.kHeroUnlocked, 1)
    end
    
end

function HeroMasteryRefreshView:updateLockRelative(index)
    self:updateLockImage(index)
    local lock = self._currentMastery[index]._lock
    local color = cc.c3b(255, 255, 255)
    if lock then
        color = cc.c3b(160, 151, 151)
    end
    self._currentMastery[index]._labelMasteryName:setColor(color)
    self._currentMastery[index]._image_bg_normal:setVisible(not lock)
    self._currentMastery[index]._image_bg_gray:setVisible(lock)
    self._newestMastery[index]._labelMasteryName:setColor(color)
    self._newestMastery[index]._image_bg_normal:setVisible(not lock)
    self._newestMastery[index]._image_bg_gray:setVisible(lock)

    local dataCurrent = tab:HeroMastery(self._currentMastery[index]._value)
    local currentLv = dataCurrent.masterylv
    local color = nil
    local outlineColor = nil
    local levelName = nil
    if lock then
        color = cc.c3b(160, 151, 151)
        if 1 == currentLv then
            levelName = "初级"
            --outlineColor = cc.c4b(0, 78, 0, 255)
        elseif 2 == currentLv then
            levelName = "中级"
            --outlineColor = cc.c4b(0, 44, 118, 255)
        elseif 3 == currentLv then
            levelName = "高级"
            --outlineColor = cc.c4b(71, 0, 140, 255)
        end
    else
        if 1 == currentLv then
            color = cc.c3b(118, 238, 0)
            outlineColor = cc.c4b(0, 78, 0, 255)
            levelName = "初级"
        elseif 2 == currentLv then
            color = cc.c3b(72, 210, 255)
            outlineColor = cc.c4b(0, 44, 118, 255)
            levelName = "中级"
        elseif 3 == currentLv then
            color = cc.c3b(239, 109, 254)
            outlineColor = cc.c4b(71, 0, 140, 255)
            levelName = "高级"
        end
    end
    if levelName then
        self._currentMastery[index]._labelMasteryLevel:setString(levelName)    
    end
    self._currentMastery[index]._labelMasteryLevel:setColor(color)
    if outlineColor then
        self._currentMastery[index]._labelMasteryLevel:enableOutline(outlineColor, 2)
    else
        self._currentMastery[index]._labelMasteryLevel:disableEffect()
    end
    local dataNewest = tab:HeroMastery(self._newestMastery[index]._value)
    local newestLv = dataNewest.masterylv
    if newestLv ~= currentLv then
        local color = nil
        local outlineColor = nil
        local levelName = nil
        if lock then
            color = cc.c3b(160, 151, 151)
            if 1 == newestLv then
                levelName = "初级"
                --outlineColor = cc.c4b(0, 78, 0, 255)
            elseif 2 == newestLv then
                levelName = "中级"
                --outlineColor = cc.c4b(0, 44, 118, 255)
            elseif 3 == newestLv then
                levelName = "高级"
                --outlineColor = cc.c4b(71, 0, 140, 255)
            end
        else
            if 1 == newestLv then
                color = cc.c3b(118, 238, 0)
                outlineColor = cc.c4b(0, 78, 0, 255)
                levelName = "初级"
            elseif 2 == newestLv then
                color = cc.c3b(72, 210, 255)
                outlineColor = cc.c4b(0, 44, 118, 255)
                levelName = "中级"
            elseif 3 == newestLv then
                color = cc.c3b(239, 109, 254)
                outlineColor = cc.c4b(71, 0, 140, 255)
                levelName = "高级"
            end
        end
        self._newestMastery[index]._labelMasteryLevel:setColor(color)
        if outlineColor then
            self._newestMastery[index]._labelMasteryLevel:enableOutline(outlineColor, 2)
        else
            self._newestMastery[index]._labelMasteryLevel:disableEffect()
        end
        if levelName then
            self._newestMastery[index]._labelMasteryLevel:setString(levelName)    
        end
    else
        self._newestMastery[index]._labelMasteryLevel:setColor(color)
        if outlineColor then
            self._newestMastery[index]._labelMasteryLevel:enableOutline(outlineColor, 2)
        else
            self._newestMastery[index]._labelMasteryLevel:disableEffect()
        end
        if levelName then
            self._newestMastery[index]._labelMasteryLevel:setString(levelName)    
        end
    end

    local icon = self._currentMastery[index]._image:getChildByTag(self.kCurrentMasteryIconTag)
    if icon then
        --self:markGray(icon, lock)
        icon:setSaturation(lock and -100 or 0)
    end

    local icon = self._newestMastery[index]._image:getChildByTag(self.kNewestMasteryIconTag)
    if icon then
        --self:markGray(icon, lock)
        icon:setSaturation(lock and -100 or 0)
    end
end

function HeroMasteryRefreshView:visableLockImage()
    local lockedCount = self:getLockedCount()
    if lockedCount >= 3 then
        for i = 1, 4 do
            if not self._currentMastery[i]._lock then
                self._currentMastery[i]._imageLock:setVisible(false)
            end
        end
    else
        for i = 1, 4 do
            self._currentMastery[i]._imageLock:setVisible(true)
        end
    end
end

function HeroMasteryRefreshView:onLockButtonClicked(index)
    if self._is_refresh_btn_clicked then return end

    if not self._currentMastery[index]._lock then
        local vipLevel = self._vipModel:getData().level
        if self:getLockedCount() >= tab.vip[vipLevel].refreshLock then
            self._viewMgr:showTip(lang("TiPS_VIP_MASTERY_" .. (tab.vip[vipLevel].refreshLock + 1)))
            return
        end
    end
    
    self._currentMastery[index]._lock = not self._currentMastery[index]._lock
    self._newestMastery[index]._lock = self._currentMastery[index]._lock
    self._heroData["masteryLock" .. index] = self._currentMastery[index]._lock

    local lockedCount = self:getLockedCount()
    self:visableLockImage()
    local consume = self._refreshConsume[lockedCount + 1]
    local totalGem = self._userModel:getData().freeGem + self._userModel:getData().payGem
    if totalGem < consume then
        self._labelConsumeValue:setColor(cc.c3b(255, 0, 0))
        self._labelConsumeValue:enableOutline(cc.c4b(81, 19, 0, 255), 2)
    else
        self._labelConsumeValue:setColor(cc.c3b(255, 255, 255))
        self._labelConsumeValue:enableOutline(cc.c4b(93, 93, 93, 255), 2)
    end
    self._labelConsumeValue:setString(self._refreshConsume[lockedCount + 1])

    self:updateLockRelative(index)
end

function HeroMasteryRefreshView:onButtonRefreshClicked()

    local lockedCount = self:getLockedCount()
    local consume = self._refreshConsume[lockedCount + 1]
    local totalGem = self._userModel:getData().freeGem + self._userModel:getData().payGem
    local freeTimes = self._modelMgr:getModel("PlayerTodayModel"):getData().day4
    local _, scrollNum = self._itemModel:getItemsById(3015)
    if freeTimes >= self._privilegesModel:getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_12) and scrollNum <= 0 and consume > totalGem then
        DialogUtils.showNeedCharge({callback1=function( )
            local viewMgr = ViewManager:getInstance()
            viewMgr:showView("vip.VipView", {viewType = 0})
        end})
        return 
    end

    self._btn_refresh:setEnabled(false)
    self._btn_refresh:setBright(false)

    local context = {heroId = self._heroData.id, args = {locks = {}}}
    for i=1, 4 do
        if self._currentMastery[i]._lock then
            context.args.locks[#context.args.locks+1] = i
        else
            self._newestMastery[i]._masteryMC:setVisible(true)
            self._newestMastery[i]._masteryMC:addEndCallback(function()
                self._newestMastery[i]._masteryMC:stop()
                self._newestMastery[i]._masteryMC:setVisible(false)
            end)
            self._newestMastery[i]._masteryMC:gotoAndPlay(0)
        end
    end

    if self._is_no_refresh then
        self._is_no_refresh = false
        self._newestMasteryLayer:setVisible(not self._is_no_refresh)
        self._newestMasteryNoRefreshLayer:setVisible(self._is_no_refresh)
    end

    context["args"] = json.encode(context["args"])
    ScheduleMgr:delayCall(400, self, function()
        self._serverMgr:sendMsg("HeroServer", "refreshMastery", context, true, {}, function(result) 
            dump(result, "refresh data",10)
            self:updateButtonStatus(true)

            self._btn_refresh:setEnabled(true)
            self._btn_refresh:setBright(true)

            for i=1, 4 do
                if not self._currentMastery[i]._lock then
                    self._newestMastery[i]._value = result["d"]["heros"][tostring(self._heroData.id)]["new" .. i]
                end
            end

            result["d"]["heros"] = nil

            if result["unset"] ~= nil then 
                local removeItems = self._itemModel:handelUnsetItems(result["unset"])
                self._itemModel:delItems(removeItems, true)
            end
            
            if result["d"].items then
                self._itemModel:updateItems(result["d"].items)
                result["d"].items = nil
            end

            self._modelMgr:getModel("UserModel"):updateUserData(result["d"])
            self._modelMgr:getModel("HeroModel"):saveLocks(self._heroData)
            if result.d and result.d.dayInfo and result.d.dayInfo.day4 then
                self._modelMgr:getModel("PlayerTodayModel"):setDayInfo(4, result.d.dayInfo.day4)
            end
            -- self._modelMgr:getModel("PlayerTodayModel"):setDayInfo(4, self._modelMgr:getModel("PlayerTodayModel"):getData().day4 + 1)
            self:updateUI()
        end)
    end)
end

function HeroMasteryRefreshView:onButtonChangeClicked()
    self._btn_change:setEnabled(false)
    self._btn_change:setBright(false)
    self._btn_cancel:setEnabled(false)
    self._btn_cancel:setBright(false)
    print("onButtonChangeClicked")
    for i=1, 4 do
        if not self._heroData["masteryLock" .. i] then
            self._currentMastery[i]._value = self._newestMastery[i]._value
            self._heroData["m" .. i] = self._currentMastery[i]._value
            self._currentMastery[i]._masteryMC:setVisible(true)
            self._currentMastery[i]._masteryMC:addEndCallback(function()
                self._currentMastery[i]._masteryMC:stop()
                self._currentMastery[i]._masteryMC:setVisible(false)
            end)
            self._currentMastery[i]._masteryMC:gotoAndPlay(0)
        end
    end

    self._modelMgr:getModel("HeroModel"):saveMastery(self._heroData, function(success)
        self:updateButtonStatus(false)
        self._btn_change:setEnabled(true)
        self._btn_change:setBright(true)
        self._btn_cancel:setEnabled(true)
        self._btn_cancel:setBright(true)
        self:updateUI()
    end)
end

function HeroMasteryRefreshView:onButtonCancelClicked()
    self:updateButtonStatus(false)
    print("onButtonCancelClicked")
    for i=1, 4 do
        self._newestMastery[i]._value = self._currentMastery[i]._value
    end
    self:updateUI()
end

function HeroMasteryRefreshView:onIconPressOn(node, iconType, iconId)
    print("onIconPressOn")
    iconType = node.getIconType and node:getIconType() or iconType
    iconId = node.getIconId and node:getIconId() or iconId
    if not (iconType and iconId) then return end
    print("iconType, iconId", iconType, iconId)
    if iconType == FormationIconView.kIconTypeHeroSpecialty or iconType == FormationIconView.kIconTypeHeroMastery then
        self:showHintView("global.GlobalTipView",{tipType = 2, node = node, id = iconId, rotation = 90, des = BattleUtils.getDescription(iconType, iconId, self._attributeValues)})
    end
end

function HeroMasteryRefreshView:onIconPressOff()
    print("onIconPressOff")
    self:closeHintView()
end

function HeroMasteryRefreshView:onReshow()
    self._newestMasteryLayer:setVisible(not self._is_no_refresh)
    self._newestMasteryNoRefreshLayer:setVisible(self._is_no_refresh)
end

function HeroMasteryRefreshView:updateUI()
    self._attributeValues = BattleUtils.getHeroAttributes(self._heroData)
    local recommandMasteryData = self._heroData.recmastery
    for i=1, 4 do
        -- current mastery
        local dataCurrent = tab:HeroMastery(self._currentMastery[i]._value)
        local icon = self._currentMastery[i]._image:getChildByTag(self.kCurrentMasteryIconTag)
        if not icon then
            icon = FormationIconView.new({ iconType = FormationIconView.kIconTypeHeroMastery, iconId = dataCurrent.id, container = { _container = self } })
            icon:setPosition(self._currentMastery[i]._image:getContentSize().width / 2, self._currentMastery[i]._image:getContentSize().height / 2)
            icon:setTag(self.kCurrentMasteryIconTag)
            self._currentMastery[i]._image:addChild(icon)
        end 
        icon = self._currentMastery[i]._image:getChildByTag(self.kCurrentMasteryIconTag)
        icon:setIconType(FormationIconView.kIconTypeHeroMastery)
        icon:setIconId(dataCurrent.id)
        icon:updateIconInformation()

        self._currentMastery[i]._labelMasteryName:setString(lang(dataCurrent.name))

        --[[
        -- version 3.0
        local color = cc.c3b(255, 255, 255)
        if self._currentMastery[i]._lock then
            color = cc.c3b(128, 128, 128)
        end
        --self._masteryUI[i]._level:setString("初中高级")
        self._currentMastery[i]._labelMasteryName:setColor(color)
        self._currentMastery[i]._labelMasteryName:setString(lang(dataCurrent.name))
        self._currentMastery[i]._image_bg_normal:setVisible(not self._currentMastery[i]._lock)
        self._currentMastery[i]._image_bg_gray:setVisible(self._currentMastery[i]._lock)
        ]]
        
        -- newest mastery
        local dataNewest = tab:HeroMastery(self._newestMastery[i]._value)
        --[[ -- version 3.0
        local isIncrease = self._newestMastery[i]._value ~= self._currentMastery[i]._value and dataNewest.masterylv > dataCurrent.masterylv
        local isDecrease = self._newestMastery[i]._value ~= self._currentMastery[i]._value and dataNewest.masterylv < dataCurrent.masterylv
        local isEqual = self._newestMastery[i]._value ~= self._currentMastery[i]._value and dataNewest.masterylv == dataCurrent.masterylv
        ]]
        local icon = self._newestMastery[i]._image:getChildByTag(self.kNewestMasteryIconTag)
        if not icon then
            icon = FormationIconView.new({ iconType = FormationIconView.kIconTypeHeroMastery, iconId = dataNewest.id, container = { _container = self } })
            icon:setPosition(self._newestMastery[i]._image:getContentSize().width / 2, self._newestMastery[i]._image:getContentSize().height / 2)
            icon:setTag(self.kNewestMasteryIconTag)
            self._newestMastery[i]._image:addChild(icon)
        end 
        icon = self._newestMastery[i]._image:getChildByTag(self.kNewestMasteryIconTag)
        icon:setIconType(FormationIconView.kIconTypeHeroMastery)
        icon:setIconId(dataNewest.id)
        icon:updateIconInformation()

        self:updateLockRelative(i)

        self._newestMastery[i]._labelMasteryName:setString(lang(dataNewest.name))

        local isRecommand = function(masteryId)
            for i = 1, #recommandMasteryData do
                if recommandMasteryData[i] == masteryId then
                    return true
                end
            end
            return false
        end

        self._newestMastery[i]._image_recommand:setVisible(recommandMasteryData and isRecommand(dataNewest.id))

        --[[ -- version 3.0
        local color = cc.c3b(255, 255, 255)
        if self._currentMastery[i]._lock then
            color = cc.c3b(128, 128, 128)
        elseif isIncrease then
            color = cc.c3b(90, 170, 0)
        elseif isDecrease then
            color = cc.c3b(255, 0, 0)
        end 
        --self._masteryUI[i]._level:setString("初中高级")
        self._newestMastery[i]._labelMasteryName:setColor(color)
        self._newestMastery[i]._labelMasteryName:setString(lang(dataNewest.name))
        self._newestMastery[i]._image_bg_normal:setVisible(not self._currentMastery[i]._lock)
        self._newestMastery[i]._image_bg_gray:setVisible(self._currentMastery[i]._lock)
        ]]
        --[[
        self._newestMastery[i]._imageIncrease:setVisible(isIncrease)
        self._newestMastery[i]._imageDecrease:setVisible(isDecrease)
        self._newestMastery[i]._imageEqual:setVisible(isEqual)
        ]]
    end

    if recommandMasteryData then
        for i = 1, 4 do
            local dataMastery = tab:HeroMastery(recommandMasteryData[i])
            local masteryLv = dataMastery.masterylv
            local icon = self._recommandMastery[i]._image:getChildByTag(self.kCurrentMasteryIconTag)
            if not icon then
                icon = FormationIconView.new({ iconType = FormationIconView.kIconTypeHeroMastery, iconId = dataMastery.id, container = { _container = self } })
                icon:setPosition(self._recommandMastery[i]._image:getContentSize().width / 2, self._recommandMastery[i]._image:getContentSize().height / 2)
                icon:setTag(self.kCurrentMasteryIconTag)
                self._recommandMastery[i]._image:addChild(icon)
            end 
            icon = self._recommandMastery[i]._image:getChildByTag(self.kCurrentMasteryIconTag)
            icon:setIconType(FormationIconView.kIconTypeHeroMastery)
            icon:setIconId(dataMastery.id)
            icon:updateIconInformation()
            self._recommandMastery[i]._name:setString(lang(dataMastery.name))
            local color = nil
            local outlineColor = nil
            local levelName = nil
            if 1 == masteryLv then
                color = cc.c3b(118, 238, 0)
                outlineColor = cc.c4b(0, 78, 0, 255)
                levelName = "初级"
            elseif 2 == masteryLv then
                color = cc.c3b(72, 210, 255)
                outlineColor = cc.c4b(0, 44, 118, 255)
                levelName = "中级"
            elseif 3 == masteryLv then
                color = cc.c3b(239, 109, 254)
                outlineColor = cc.c4b(71, 0, 140, 255)
                levelName = "高级"
            end
            if levelName then
                self._recommandMastery[i]._level:setString(levelName)    
            end
            self._recommandMastery[i]._level:setColor(color)
            if outlineColor then
                self._recommandMastery[i]._level:enableOutline(outlineColor, 2)
            else
                self._recommandMastery[i]._level:disableEffect()
            end
        end
    end

    local playerDayInfoData = self._modelMgr:getModel("PlayerTodayModel"):getData()
    local freeTimes = self._privilegesModel:getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_12) - playerDayInfoData.day4
    self._image_privileges_icon:setVisible(freeTimes > 0)
    self._label_free_times_value:setString(freeTimes)
    local _, scrollNum = self._itemModel:getItemsById(3015)
    self._imageConsumeScroll:setVisible(freeTimes <= 0 and scrollNum > 0)
    self._labelConsumeScrollValue:setString(scrollNum)
    self._imageConsume:setVisible(freeTimes <= 0 and scrollNum <= 0)
    local consume = self._refreshConsume[self:getLockedCount() + 1]
    local totalGem = self._userModel:getData().freeGem + self._userModel:getData().payGem
    if totalGem < consume then
        self._labelConsumeValue:setColor(cc.c3b(255, 0, 0))
        self._labelConsumeValue:enableOutline(cc.c4b(81, 19, 0, 255), 2)
    else
        self._labelConsumeValue:setColor(cc.c3b(255, 255, 255))
        self._labelConsumeValue:enableOutline(cc.c4b(93, 93, 93, 255), 2)
    end
    self._labelConsumeValue:setString(consume)
    self._imageConsumeBg:setVisible(not self._is_refresh_btn_clicked and freeTimes <= 0)
end

function HeroMasteryRefreshView:updateButtonStatus(isRefresh)
    self._is_refresh_btn_clicked = isRefresh
    --[[
    for i=1, 4 do
        self._currentMastery[i]._imageLockBg:setVisible(not isRefresh)
        self._newestMastery[i]._imageLockBg:setVisible(not isRefresh)
    end
    ]]
    for i=1, 4 do
        self:updateLockImage(i) 
    end

    self._btn_refresh:setVisible(not isRefresh)
    self._imageConsumeBg:setVisible(not isRefresh)
    self._btn_change:setVisible(isRefresh)
    self._btn_cancel:setVisible(isRefresh)
end

function HeroMasteryRefreshView:updateDescription()

end

function HeroMasteryRefreshView:close()
    self._container:onRefreshViewClose()
    HeroMasteryRefreshView.super.close(self)
end

return HeroMasteryRefreshView