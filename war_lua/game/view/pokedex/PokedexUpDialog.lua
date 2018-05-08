--[[
    Filename:    PokedexUpDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-01-21 14:49:19
    Description: File description
--]]

local PokedexUpDialog = class("PokedexUpDialog", BasePopView)

function PokedexUpDialog:ctor(params)
    PokedexUpDialog.super.ctor(self)
    self._selectPokedex = params.pokedexType
end

function PokedexUpDialog:onInit()
    self:registerClickEventByName("bg.closeBtn", function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("pokedex.PokedexUpDialog")
        end
        self:close()
    end)
    -- local burst = self:getUI("bg.layer.burst")

    local title = self:getUI("bg.layer.titleBg.title")
    UIUtils:setTitleFormat(title, 1)
    -- title:setFontName(UIUtils.ttfName)
    -- -- title:setColor(cc.c3b(250, 242, 192))
    -- -- title:enable2Color(1, cc.c4b(255, 195, 20, 255))
    -- -- title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
    -- title:setFontSize(30)

    self._tujianIcon = self:getUI("bg.layer.panel1")
    -- local name = self._tujianIcon:getChildByFullName("titleBg.name")
    -- name:setColor(cc.c3b(255,255,255))
    -- name:setFontSize(24)
    -- name:enableOutline(cc.c4b(60, 30, 10, 255), 2)
    self._oldValue = self._tujianIcon:getChildByFullName("old.oldValue")
    self._newName = self._tujianIcon:getChildByFullName("new.newName")
    self._oldName = self._tujianIcon:getChildByFullName("old.oldName")
    self._oldQuality = self._tujianIcon:getChildByFullName("old.quality")

    self._newLabel = self._tujianIcon:getChildByFullName("new.newLabel")
    self._newValue = self._tujianIcon:getChildByFullName("new.newValue")


    -- self._oldName:setFontName(UIUtils.ttfName)
    self._oldName:setColor(UIUtils.colorTable.ccUIBaseColor1)
    self._oldName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    -- self._newName:setFontName(UIUtils.ttfName)
    self._newName:setColor(UIUtils.colorTable.ccUIBaseColor1)
    self._newName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._itemBg = self:getUI("bg.layer.panel2.itemBg")
    self._itemNum = self:getUI("bg.layer.panel2.shuziBg.itemNum")

    self._goldValue = self:getUI("bg.layer.panel2.goldValue")
    self._burst = self:getUI("bg.layer.panel2.burst")
    self._tujianIcon = self:getUI("bg.tujianIcon")

    self._maxLab = self:getUI("bg.layer.panel2.maxLab")
    self._maxLab:setVisible(false)
    -- self._layer = self:getUI("bg.layer")
    self._panel3 = self:getUI("bg.layer.panel3")
    self._panel2 = self:getUI("bg.layer.panel2")
    self._panel1 = self:getUI("bg.layer.panel1")

    local maxLab = self:getUI("bg.layer.panel3.maxLab")
    -- maxLab:setFontName(UIUtils.ttfName)

    local title = self:getUI("bg.layer.panel3.titleBg.title")
    -- title:setFontName(UIUtils.ttfName)
    title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    -- title:setString(lang(tab:Tujian(self._selectPokedex).name) .. "图鉴")

    self:listenReflash("UserModel", self.reflashData)
    self:reflashData()
end

function PokedexUpDialog:reflashData()

    local pokedexData = self._modelMgr:getModel("PokedexModel"):getDataById(self._selectPokedex)
    self._pokedexLevel = pokedexData.level or 0
    self._pokedexNextLevel = self._pokedexLevel + 1

     -- TeamUtils:getPokedexStage(self._pokedexLevel)
    -- 旧数据
    local stage = tab:Tujianshengji(self._pokedexLevel)["stage"]
    local str = lang(tab:Tujian(self._selectPokedex).name) .. "图鉴" 
    if stage[2] ~= 0 then
        str = lang(tab:Tujian(self._selectPokedex).name) .. "图鉴 +" .. stage[2]
    end
    self._oldName:setString(str)
    self._oldName:setColor(UIUtils.colorTable["ccUIBaseColor" .. stage[1]])

    self._oldQuality:loadTexture("pokeImage_pquality" .. stage[1] .. ".png", 1)

    local titleLab = self:getUI("bg.layer.infoBg.titleLab")
    titleLab:setString(str)
    UIUtils:adjustTitle(self:getUI("bg.layer.infoBg"))

    local art = "tj_" .. tab:Tujian(self._selectPokedex).art .. ".png"
    if tab:Tujian(self._selectPokedex).art == 7 then
        art = "tj_4.png"
    elseif tab:Tujian(self._selectPokedex).art == 4 then
        art = "tj_7.png"
    end
    self._tujianIcon:loadTexture(art, 1)
    local oldValue = tab:Tujianshengji(self._pokedexLevel).effect
    self._oldValue:setString("总评分 + " .. oldValue .. "%")
    -- self._oldValue:setPositionX(self._oldLabel:getContentSize().width + self._oldLabel:getPositionX())

    local pokedexMax = true
    -- print("==========================",self._pokedexNextLevel, table.nums(tab:Tujian(self._selectPokedex).levelUpLimit))
    if self._pokedexNextLevel <= table.nums(tab:Tujian(self._selectPokedex).levelUpLimit) - 1 then
    -- if tab:Tujianshengji(self._pokedexNextLevel) ~= nil then
        pokedexMax = false

        -- 新数据
        local stage = tab:Tujianshengji(self._pokedexNextLevel)["stage"]
        local str = lang(tab:Tujian(self._selectPokedex).name) .. "图鉴" 
        if stage[2] ~= 0 then
            str = lang(tab:Tujian(self._selectPokedex).name) .. "图鉴 +" .. stage[2]
        end
        self._newName:setString(str)
        self._newName:setColor(UIUtils.colorTable["ccUIBaseColor" .. stage[1]])

        
        local newValue = tab:Tujianshengji(self._pokedexNextLevel).effect
        self._newValue:setString(" + " .. newValue .. "%")
        self._newValue:setPositionX(self._newLabel:getContentSize().width + self._newLabel:getPositionX() + 2)

        local userData = self._modelMgr:getModel("UserModel"):getData()

        local itemId = tab:Tujian(self._selectPokedex).itemId
        local systemItem = tab:Tool(itemId)
        local needItemNum = tab:Tujianshengji(self._pokedexNextLevel).itemNum
        local itemModel = self._modelMgr:getModel("ItemModel")
        local tempItems, tempItemCount = itemModel:getItemsById(itemId)
        if tempItemCount >= needItemNum then
            -- print("==========================",self._itemNum)
            self._itemNum:disableEffect()
            self._itemNum:setColor(UIUtils.colorTable.ccUIBaseColor9)
        else
            self._itemNum:setColor(UIUtils.colorTable.ccUIBaseColor6)
        end
        self._itemNum:setString(tempItemCount .. "/" .. needItemNum)
        if self._itemIcon then
            self._itemIcon:removeFromParent()
        end
        local suo = 0
        if tempItemCount < needItemNum then
            suo = 2
        end
        self._itemIcon = IconUtils:createItemIconById({itemId = itemId,num = -1,suo = suo,itemData = systemItem,eventStyle = 3,clickCallback = function( )
            local toolD = tab:Tool( itemId )
            local approach = toolD["approach"]
            -- if approach then
                self._viewMgr:showDialog("bag.DialogAccessTo", {goodsId = itemId, needItemNum = needItemNum}, true)
            -- else
            --     self._viewMgr:showTip("没有配获取路径")
            -- end
        end})
        self._itemIcon:setScale(self._itemBg:getContentSize().width/self._itemIcon:getContentSize().width)
        self._itemIcon:setPosition(cc.p(0,0))

        self._itemBg:addChild(self._itemIcon)

        local goldNum = tab:Tujianshengji(self._pokedexNextLevel).goldNum
        if userData.gold >= goldNum then
            self._goldValue:disableEffect()
            self._goldValue:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
            -- self._goldValue:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        else
            self._goldValue:setColor(UIUtils.colorTable.ccUIBaseColor6)
            self._goldValue:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        end
        self._goldValue:setString(goldNum)

        -- print("=======level ", self._pokedexNextLevel, tab:Tujian(self._selectPokedex).levelUpLimit[self._pokedexNextLevel])
        if self._pokedexNextLevel >= table.nums(tab:Tujian(self._selectPokedex).levelUpLimit) - 1 then
            self._pokedexNextLevel = table.nums(tab:Tujian(self._selectPokedex).levelUpLimit) - 1
        end
        if userData.lvl < tab:Tujian(self._selectPokedex).levelUpLimit[self._pokedexNextLevel + 1] then
            local goldIcon = self:getUI("bg.layer.panel2.gold")
            goldIcon:setVisible(false)
            self._goldValue:setVisible(false)
            local tishi = self:getUI("bg.layer.panel2.tishi")
            tishi:setVisible(true)
            tishi:setString(tab:Tujian(self._selectPokedex).levelUpLimit[self._pokedexNextLevel + 1] .. "级可突破")
            self:registerClickEvent(self._burst, function()
                self._viewMgr:showTip("玩家等级不足")
            end)
        elseif tempItemCount < needItemNum then
            self:registerClickEvent(self._burst, function()
                self._viewMgr:showTip("图鉴符文数量不足")
            end)
        elseif userData.gold < goldNum then
            self:registerClickEvent(self._burst, function()
                -- self._viewMgr:showTip("金币不足")
                DialogUtils.showLackRes({goalType = "gold"})
            end)
        else -- if tempItemCount >= needItemNum then
            self:registerClickEvent(self._burst, function()
                -- print("突破")
                -- self:setAnim()
                self:upPokedexLevel()
            end)
        end
        self._panel1:setVisible(true)
        self._panel2:setVisible(true)
        self._panel3:setVisible(false)
        -- self._maxLayer:setVisible(false)
        -- self._layer:setVisible(true)
    else
        -- self._maxLayer:setVisible(true)
        self._panel1:setVisible(false)
        self._panel2:setVisible(false)
        self._panel3:setVisible(true)
        local levelLab = self:getUI("bg.layer.panel3.levelLab")
        levelLab:setString(str)

        local quality = self:getUI("bg.layer.panel3.quality")
        quality:loadTexture("pokeImage_pquality" .. stage[1] .. ".png", 1)

        local title = self:getUI("bg.layer.panel3.titleBg.title")
        title:setString(str)
        title:setColor(UIUtils.colorTable["ccUIBaseColor" .. stage[1]])

        local shuxing = self:getUI("bg.layer.panel3.shuxing")
        local newValue = tab:Tujianshengji(self._pokedexLevel).effect
        shuxing:setString("总评分   + " .. newValue .. "%")
        -- self._maxName:setString(self._pokedexLevel .. "级图鉴")
        -- self._maxValue:setString("+" .. oldValue .. "%")

        -- self._newName:setString("Max级图鉴")
        -- local newValue = tab:Tujianshengji(self._pokedexLevel).effect
        -- self._newValue:setString("+" .. newValue .. "%")

    end
end

-- 图鉴升级
function PokedexUpDialog:upPokedexLevel()
    -- print("==============",os.clock())
    self._oldFight = TeamUtils:updateFightNum()
    self._serverMgr:sendMsg("PokedexServer", "upPokedexLevel", {pokedexId = self._selectPokedex}, true, {}, function (result)
        -- print("==============111",os.clock())
        return self:upPokedexLevelFinish()
    end, function(errorId)
        if tonumber(errorId) == 1210 then
            self._viewMgr:showTip("已达到最高等级")
        end
    end)
end

function PokedexUpDialog:upPokedexLevelFinish()
    -- print("elvel=====", self._pokedexLevel, self._pokedexNextLevel)
    local param = {old = self._pokedexLevel, new = self._pokedexNextLevel, selectPokedex = self._selectPokedex, callback = function()
        local fightBg = self:getUI("bg")
        TeamUtils:setFightAnim(fightBg, {oldFight = self._oldFight, newFight = TeamUtils:updateFightNum(), x = fightBg:getContentSize().width*0.5-80, y = fightBg:getContentSize().height - 100})
    end}
    self._viewMgr:showDialog("pokedex.PokedexUpgradeDialog", param)
    -- self._viewMgr:showTip("升级成功")
    -- local bg = self:getUI("bg")
    -- TeamUtils:setFightAnim(teamImgBg, {oldFight = self._oldFight, newFight = tempTeamData.score, x = teamImgBg:getContentSize().width*0.5, y = teamImgBg:getContentSize().height - 70})

    

    self:reflashData()
end

return PokedexUpDialog