--[[
    Filename:    HeroCardView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2015-08-04 10:20:51
    Description: File description
--]]

local HeroCardView = class("HeroCardView", function()
    return cc.Sprite:create()
end)

HeroCardView.kSelectedZorder = 1000
HeroCardView.kActionIntervalTime = 0.35

function HeroCardView:ctor(container, hero)
    -- dump(hero, "HeroCardView:ctor",5)
    self._container = container
    self._hero = hero
    self._radian = 0
    self._oldZorder = 0
    self._isGray = false
    self._isSelected = false
    self._cardImage = nil
    self._selectedAction = nil
    self._deSelectedAction = nil

    self:onInit()
end

function HeroCardView:onInit()

    local cardImgaeFileName = self._hero.herobg
    if self._hero.skin then
        local skinTableData = tab:HeroSkin(tonumber(self._hero.skin))
        cardImgaeFileName = skinTableData and skinTableData.herobg or cardImgaeFileName
    end

    self._cardImage = cc.Sprite:create("asset/uiother/hero/"..cardImgaeFileName .. ".jpg")

    local size = self._cardImage:getContentSize()
    self._cardImage:setPosition(size.width / 1.1, size.height / 2)
    self:addChild(self._cardImage, 5)
    
    self:setAnchorPoint(0.5, 0.5)
    self:setContentSize(size)

    local imgName = (self._hero and self._hero.slot) and "image_card_bg_selected_heroSlot.png" or "image_card_bg_normal_hero.png"
    self._imageBgNormal = cc.Sprite:createWithSpriteFrameName(imgName)
    self._imageBgNormal:setPosition(size.width / 5 - 15, size.height / 2)
    self._cardImage:addChild(self._imageBgNormal, 10)

    --[[
    self._imageBgSelected = cc.Sprite:createWithSpriteFrameName("image_card_bg_selected_hero.png")
    self._imageBgSelected:setVisible(false)
    --self._imageBgSelected:setPosition(size.width / 1.45, size.height / 2)
    self._imageBgSelected:setPosition(self._imageBgNormal:getContentSize().width / 1.45, self._imageBgNormal:getContentSize().height / 2 + 3)
    self._imageBgNormal:addChild(self._imageBgSelected, 4)
    ]]

    self._imageBgSelected = cc.Sprite:createWithSpriteFrameName("image_card_bg_selected_hero.png")
    self._imageBgSelected:setVisible(false)
    --self._imageBgSelected:setPosition(size.width / 1.45, size.height / 2)
    self._imageBgSelected:setPosition(size.width / 2 - 10, size.height / 2 - 10)
    self._cardImage:addChild(self._imageBgSelected, 15)

    self._imageBgSelectedSlot = mcMgr:createViewMC("keyinxuanzhong_keyinxuanzhong", true, false) --cc.Sprite:createWithSpriteFrameName("image_card_bg_selected_hero.png")
    self._imageBgSelectedSlot:setVisible(false)
    self._imageBgSelectedSlot:setScale(0.82)
    --self._imageBgSelectedSlot:setPosition(size.width / 1.45, size.height / 2)
    self._imageBgSelectedSlot:setPosition(size.width / 2+5, size.height / 2-3)
    self._cardImage:addChild(self._imageBgSelectedSlot, 15)

    --[[
    self._imageBgSelected = mcMgr:createViewMC("xuanzhong_kejiesuo", true, false)
    self._imageBgSelected:setVisible(false)
    --self._imageBgSelected:setPosition(size.width / 1.45, size.height / 2)
    self._imageBgSelected:setPosition(size.width / 2, size.height / 2 - 1)
    self._cardImage:addChild(self._imageBgSelected, 4)
    ]]

    --[[
    -- version 3.0
    self._imageBgLoaded = cc.Sprite:createWithSpriteFrameName("image_card_bg_loaded.png")
    self._imageBgLoaded:setVisible(self._hero.id == self._container._container:getCurrentLoadedHeroId())
    self._imageBgLoaded:setPosition(size.width / 2, size.height / 2)
    self._cardImage:addChild(self._imageBgLoaded, 10)
    ]]
    --[[
    self._imageChain = cc.Sprite:createWithSpriteFrameName("hero_chain_tag.png")
    --self._imageChain:setRotation(-5)
    self._imageChain:setPosition(size.width / 1.5, size.height / 4)
    self._imageChain:setVisible(false)
    self._cardImage:addChild(self._imageChain, 10)
    ]]
    --星图动画a4
    self._heroStarMC = mcMgr:createViewMC("xingtu_xingtu3", true, false)
    self._heroStarMC:setPosition(size.width / 2, size.height / 2)
    self._cardImage:addChild(self._heroStarMC)
    self._heroStarMC:setVisible(false)


    self._heroUnlockMC1 = mcMgr:createViewMC("kejiasuo1_kejiesuo", true, false)
    self._heroUnlockMC1:setPosition(size.width / 4 + 45, size.height / 2 - 5)
    self._cardImage:addChild(self._heroUnlockMC1)

    self._heroUnlcokMask = cc.Sprite:createWithSpriteFrameName("unlock_mask_hero.png")
    self._heroUnlockMC2 = cc.ClippingNode:create()
    self._heroUnlockMC2:setStencil(self._heroUnlcokMask)
    self._heroUnlockMC2:setAlphaThreshold(0.05)
    self._heroUnlockMC2:setPosition(size.width / 4 + 45, size.height / 2 - 5)
    local heroUnlockMC2 = mcMgr:createViewMC("kejiesuo2_kejiesuo", true, false)
    heroUnlockMC2:setScale(0.8)
    self._heroUnlockMC2:addChild(heroUnlockMC2)
    self._cardImage:addChild(self._heroUnlockMC2, 5)
    --[[
    local imageHeroRaceTag = cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. "h_prof_" .. self._hero.prof ..".png")
    imageHeroRaceTag:setPosition(self._imageBgNormal:getContentSize().width / 1.1, self._imageBgNormal:getContentSize().height / 1.2)
    self._imageBgNormal:addChild(imageHeroRaceTag, 5)
    ]]
    --[[
    self._imageStarBg = cc.Sprite:createWithSpriteFrameName("star_bg_hero.png")
    self._imageStarBg:setRotation(90)
    self._imageStarBg:setPosition(self._imageBgNormal:getContentSize().width / 1.2, self._imageBgNormal:getContentSize().height / 3.2)
    self._imageBgNormal:addChild(self._imageStarBg, 5)
    ]]
    -- version 6.0
    --[[
    self._imageStarBg = cc.Sprite:createWithSpriteFrameName("upgrade_material_bg_hero.png")
    self._imageStarBg:setName("hero_star_bg")
    self._imageStarBg:setPosition(size.width / 1.18, size.height / 3.2)
    self._imageStar = {}
    for i = 1, 4 do
        self._imageStar[i] = cc.Sprite:createWithSpriteFrameName("globalImageUI6_heroStar.png")
        self._imageStar[i]:setPosition(self._imageStarBg:getContentSize().width / 4 + 18 * (i - 1), self._imageStarBg:getContentSize().height / 2)
        self._imageStarBg:addChild(self._imageStar[i], 10)
    end
    self._cardImage:addChild(self._imageStarBg, 10)

    self._starMC = mcMgr:createViewMC("kongxingshan_herostaranim", true)
    self._starMC:setPlaySpeed(1, true)
    self._starMC:setPosition(self._imageStar[2]:getPosition())
    self._starMC:setVisible(false)
    self._imageStarBg:addChild(self._starMC, 20)
    ]]

    --[[
    -- version 6.0
    self._imageMaterialBg = cc.Sprite:createWithSpriteFrameName("upgrade_material_bg_hero.png")
    self._imageMaterialBg:setName("hero_upgrade_material_bg")
    self._imageMaterialBg:setPosition(size.width / 1.18, size.height / 3.2)
    self._imageMaterialBg:setVisible(false)
    self._cardImage:addChild(self._imageMaterialBg, 10)

    self._imageMaterial = cc.Sprite:createWithSpriteFrameName("globalImageUI_herosplice1.png")
    self._imageMaterial:setPosition(20, self._imageMaterialBg:getContentSize().height / 2)
    self._imageMaterialBg:addChild(self._imageMaterial, 5)

    
    self._unlockcost = ccui.Text:create(desc, UIUtils.ttfName, 18)
    self._unlockcost:setContentSize(cc.size(100, 50))
    self._unlockcost:setColor(cc.c3b(118, 238, 0))
    self._unlockcost:setPosition(self._imageMaterialBg:getContentSize().width / 1.8, self._imageMaterialBg:getContentSize().height / 2)
    self._imageMaterialBg:addChild(self._unlockcost, 5)
    ]]

    --[[
    -- version 3.0
    self._stars = {}
    for i = 1, self._hero.star do
        self._stars[i] = cc.Sprite:createWithSpriteFrameName("globalImageUI4_star1.png")
        self._stars[i]:setPosition(cc.p(355 + 20 * i, 23))
        self._imageBgNormal:addChild(self._stars[i], 5)
    end
    ]]
    --[[
    -- version 3.0
    local imageDiamond = cc.Sprite:createWithSpriteFrameName("hero_diamond_tag.png")
    --imageDiamond:setPosition(self._cardImage:getContentSize().width / 1.08, self._cardImage:getContentSize().height / 1.15)
    imageDiamond:setPosition(self._imageBgNormal:getContentSize().width / 1.08, self._imageBgNormal:getContentSize().height / 1.15)
    self._imageBgNormal:addChild(imageDiamond, 10)
    ]]
    --[[
    self._labelName = cc.Label:createWithTTF(tostring(lang(self._hero.heroname)), UIUtils.ttfName, 20)
    self._labelName:setPosition(cc.p(350, 106))
    self:addChild(self._labelName, 20)
    ]]

    self._imageStarRed = cc.Sprite:createWithSpriteFrameName("globalImageUI_bag_keyihecheng.png")
    self._imageStarRed:setPosition(size.width, size.height)
    self._imageStarRed:setVisible(false)
    self._cardImage:addChild(self._imageStarRed, 20)

    --self:initGrayProgram()
    self:setUnlock(self._hero.unlock)

    self:updateUI()

    self._selectedAction = cc.EaseOut:create(cc.MoveBy:create(self.kActionIntervalTime, cc.p(32.0, 0.0)), 2)
    self._deSelectedAction = self._selectedAction:reverse()

    if self._selectedAction then
        self._selectedAction:retain()
    end

    if self._deSelectedAction then
        self._deSelectedAction:retain()
    end

    self:registerScriptHandler(function(state)
        if state == "exit" then
            self:stopAllActions()
            self:markGray(false)
            --self._grayProgram:release()
            if self._selectedAction then
                self._selectedAction:release()
                self._selectedAction = nil
            end

            if self._deSelectedAction then
                self._deSelectedAction:release()
                self._deSelectedAction = nil
            end
        end 
    end)

    --[[
    local easeOutMoveAction = cc.EaseOut:create(cc.MoveBy:create(self.kActionIntervalTime, cc.p(32.0, 0.0)), 2)
    local easeOutMoveActionReverse = easeOutMoveAction:reverse()
    self._selectedAction = cc.Spawn:create(easeOutMoveAction,
        cc.Sequence:create(
        cc.DelayTime:create(self.kActionIntervalTime / 1.5),
            cc.CallFunc:create(function()
                self:setLocalZOrder(self.kSelectedZorder)
            end)))
    self._deSelectedAction = cc.Spawn:create(easeOutMoveActionReverse, 
        cc.Sequence:create(
        cc.DelayTime:create(self.kActionIntervalTime / 1.5),
            cc.CallFunc:create(function()
                self:setLocalZOrder(self:getOldZorder())
            end)))

    if self._selectedAction then
        self._selectedAction:retain()
    end

    if self._deSelectedAction then
        self._deSelectedAction:retain()
    end

    self:registerScriptHandler(function(state)
        if state == "exit" then
            self:stopAllActions()
            self:markGray(false)
            self._grayProgram:release()
            if self._selectedAction then
                self._selectedAction:release()
                self._selectedAction = nil
            end

            if self._deSelectedAction then
                self._deSelectedAction:release()
                self._deSelectedAction = nil
            end
        end 
    end)
    ]]
end

function HeroCardView:updateStar(unlock)
    --[[
    local ok = self._hero.star < 4
    if self._hero.star < 4 then
        local cost = {}
        if 0 == self._hero.star then
            cost = {[1] = self._hero.unlockcost}
        else
            cost = self._hero.starcost[self._hero.star]
        end
        for k, v in pairs(cost) do
            local have, consume = 0, v[3]
            if "tool" == v[1] then
                local _, toolNum = ModelManager:getInstance():getModel("ItemModel"):getItemsById(v[2])
                have = toolNum
            elseif "gold" == v[1] then
                have = ModelManager:getInstance():getModel("UserModel"):getData().gold
            elseif "gem" == v[1] then
                have = ModelManager:getInstance():getModel("UserModel"):getData().freeGem
            end
            if have < consume then
                ok = false
                break
            end
        end
    end
    ]]
    local heroModel = ModelManager:getInstance():getModel("HeroModel")
    local ok = heroModel:isHeroRedTagShowByIdAndType(self._hero.id, heroModel.kTagTypeSkill) or 
               heroModel:isHeroRedTagShowByIdAndType(self._hero.id, heroModel.kTagTypeUpgrade)or 
               heroModel:haveHeroStarRed(self._hero.id)
    -- local ok = heroModel:haveHeroStarRed(self._hero.id)
    self._imageStarRed:setVisible(SystemUtils:enableHeroOpen() and unlock and ok)

    self._heroStarMC:setVisible(heroModel:isCompleted(self._hero.id))
    --[[
    -- version 6.0
    self._starMC:setVisible(false)
    local ok = false
    if self._hero.star < 4 then
        for k, v in pairs(self._hero.starcost[self._hero.star]) do
            local have, consume = 0, v[3]
            if "tool" == v[1] then
                local _, toolNum = ModelManager:getInstance():getModel("ItemModel"):getItemsById(v[2])
                have = toolNum
            elseif "gold" == v[1] then
                have = ModelManager:getInstance():getModel("UserModel"):getData().gold
            elseif "gem" == v[1] then
                have = ModelManager:getInstance():getModel("UserModel"):getData().freeGem
            end
            if have >= consume then
                ok = true
                break
            end
        end
    end

    for i = 1, 4 do
        self._imageStar[i]:setVisible(unlock and i <= self._hero.star)
        if i == self._hero.star + 1 then
            self._starMC:setPosition(self._imageStar[i]:getPosition())
            self._starMC:setVisible(ok)
        end
    end
    ]]
end

function HeroCardView:updateUnlockStatus(unlock)
    local consume = self._hero.unlockcost[3]
    local _, have = ModelManager:getInstance():getModel("ItemModel"):getItemsById(self._hero.unlockcost[2])
    if SystemUtils:enableHeroOpen() and not unlock and have >= consume then
        self._heroUnlockMC1:setVisible(true)
        self._heroUnlockMC2:setVisible(true)
    else
        self._heroUnlockMC1:setVisible(false)
        self._heroUnlockMC2:setVisible(false)
    end
end

function HeroCardView:updateUI()
    self:updateStar(self._hero.unlock) -- version 6.0
    self:updateUnlockStatus(self._hero.unlock) -- version 6.0
    local cardImgaeFileName = self._hero.herobg
    if self._hero.skin then
        local skinTableData = tab:HeroSkin(tonumber(self._hero.skin))
        cardImgaeFileName = skinTableData and skinTableData.herobg or cardImgaeFileName
    end

    self._cardImage:setTexture("asset/uiother/hero/"..cardImgaeFileName .. ".jpg")
    --[[
    local consume = self._hero.unlockcost[3]
    local _, have = ModelManager:getInstance():getModel("ItemModel"):getItemsById(self._hero.unlockcost[2])
    if have < consume then
        self._unlockcost:setColor(cc.c3b(255, 0, 0))
    end
    self._unlockcost:setString(string.format("%d/%d", have, consume))
    ]]
end

function HeroCardView:getId()
    return self._hero.id
end

function HeroCardView:setRadian(radian)
    self._radian = radian
end

function HeroCardView:getRadian()
    return self._radian
end

function HeroCardView:setOldZorder(zorder)
    self._oldZorder = zorder
end

function HeroCardView:getOldZorder()
    return self._oldZorder
end

function HeroCardView:initGrayProgram()
    if true then return end
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

function HeroCardView:_setProgram(node, program)
    if node:getName() == "hero_upgrade_material_bg" or node:getName() == "hero_star_bg" then return end
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

function HeroCardView:_setGray(node)
    self._isGray = true
    --self:_setProgram(node, self._grayProgram)
    self:setSaturation(-100)
end

function HeroCardView:_removeGray(node)
    self._isGray = false
    --self:_setProgram(node, cc.ShaderCache:getInstance():getProgram("ShaderPositionTextureColor_noMVP"))
    self:setSaturation(0)
end

function HeroCardView:markGray(gray)
    if self._isGray == gray then return end
    if gray then
        self:_setGray(self._cardImage)
    elseif self._hero.unlock then
        self:_removeGray(self._cardImage)
    end
end

function HeroCardView:setUnlock(unlock)
    --self._imageChain:setVisible(not unlock)
    --self._imageMaterialBg:setVisible(not unlock) -- version 6.0
    --self._imageStarBg:setVisible(unlock) -- version 6.0

    self:updateStar(unlock) -- version 6.0
    self:updateUnlockStatus(unlock) -- version 6.0

    if not unlock then
        self:_setGray(self._cardImage)
    else
        self:_removeGray(self._cardImage)
    end
end

function HeroCardView:runSelectedAction(isSelected)
    if isSelected then
        self:runAction(self._selectedAction)
        ScheduleMgr:delayCall(self.kActionIntervalTime / 1.5 * 1000, self, function()
            if not (self.setLocalZOrder and self.kSelectedZorder) then return end
             self:setLocalZOrder(self.kSelectedZorder)
        end)
    else
        self:runAction(self._deSelectedAction)
        ScheduleMgr:delayCall(self.kActionIntervalTime / 1.5 * 1000, self, function()
            if not (self.setLocalZOrder and self.getOldZorder) then return end
            self:setLocalZOrder(self:getOldZorder())
        end)
    end
end

function HeroCardView:setSelected(isSelected, noAction,isHaveSlot)
    self._isSelected = isSelected
    self._imageBgSelected:setVisible(isSelected and not isHaveSlot)
    self._imageBgSelectedSlot:setVisible(isSelected and not not isHaveSlot)
    self:setScale(self._isSelected and 1.2 or 1.0)
    if noAction then
        self:setLocalZOrder(self:getOldZorder())
        return
    end
    self:runSelectedAction(isSelected)
end
-- 更新选中卡牌的选中框 hgf  & 刻印常态框
function HeroCardView:updateSelectImage(isHaveSlot)
    self._imageBgSelected:setVisible(not isHaveSlot)
    self._imageBgSelectedSlot:setVisible(not not isHaveSlot)
    local imgName = isHaveSlot and "image_card_bg_selected_heroSlot.png" or "image_card_bg_normal_hero.png"
    self._imageBgNormal:setSpriteFrame(imgName)
end

function HeroCardView:getSelected()
    return self._isSelected
end

function HeroCardView:setLoaded(isloaded)
    self._imageBgLoaded:setVisible(isloaded)
end

return HeroCardView