--[[
    Filename:    PokedexDetailView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2015-09-28 11:42:02
    Description: File description
--]]

local PokedexDetailView = class("PokedexDetailView", BaseView)

function PokedexDetailView:ctor(params)
    PokedexDetailView.super.ctor(self)
    self._selectPokedex = params.pokedexType or 1
end

function PokedexDetailView:onInit()
    -- local bg1 = self:getUI("bg1")
    -- bg1:loadTexture("asset/bg/bg_003.jpg")
    -- local rgb = tab:Tujian(self._selectPokedex).rgb
    -- bg1:setColor(cc.c3b(rgb[1], rgb[2], rgb[3]))
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._pingfenshuaxin = false

-- Brightness
-- Contrast
-- Saturation
-- Hue
    local closeBtn = self:getUI("closeBtn")
    closeBtn:setVisible(false)
    self:registerClickEvent(closeBtn, function()
        self:close()
    end)
    local guize = self:getUI("zongfenBg.guize")
    guize:setAnchorPoint(0.5, 0.5)
    guize:setScaleAnim(true)
    self:registerClickEvent(guize, function()
        self._viewMgr:showDialog("pokedex.PokedexShowDialog")
    end)

    self._zhandouli = self:getUI("rewardBg.zhandouli")
    -- self._zhandouli:setColor(cc.c3b(240,240,0))
    -- self._zhandouli:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._zhandouli:setFntFile(UIUtils.bmfName_zhandouli_little) 
    -- self._zhandouli:setScale(0.8)
    -- self._pokedexIcon = self:getUI("rewardBg.titleIcon")
    -- self._pokedexIcon:loadTexture("tj_name_" .. tab:Tujian(self._selectPokedex).art .. ".png", 1)
    self._reward = self:getUI("rewardBg.reward")
    self._reward:setColor(UIUtils.colorTable.ccUIBasePromptColor)
    self._reward:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._rewardValue = self:getUI("rewardBg.rewardValue")
    self._rewardValue:setColor(cc.c3b(118,238,0))
    self._rewardValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)


    self._reward1 = self:getUI("rewardBg.reward1")
    self._reward1:setColor(UIUtils.colorTable.ccUIBasePromptColor)
    self._reward1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._rewardValue1 = self:getUI("rewardBg.rewardValue1")
    self._rewardValue1:setColor(cc.c3b(118,238,0))
    self._rewardValue1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    -- self._title = self:getUI("rewardBg.title")
    -- self._title:enableOutline(cc.c4b(85,14,0,255), 2)
    -- self._title:setFontName(UIUtils.ttfName)qqqh2

    self._upGrade = self:getUI("rewardBg.pokeEffectBg")
    self:registerClickEvent(self._upGrade, function()
        -- print("图鉴突破")
        self._viewMgr:showDialog("pokedex.PokedexUpDialog", {pokedexType = self._selectPokedex or 1})
    end)
    self:setAnim(0,3)
    self._pokedexLevel = self:getUI("rewardBg.pokeEffectBg.pokedex_level")
    self._pokedexLevel:setColor(UIUtils.colorTable.ccUIBasePromptColor)
    -- self._pokedexLevel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._pokeEffect = self:getUI("rewardBg.pokeEffectBg.pokeEffect")
    self._pokeEffect:setColor(cc.c3b(255,193,57))
    -- self._pokeEffect:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._zongfen = self:getUI("zongfenBg.zongfen")
    -- self._zongfen:setFontName(UIUtils.ttfName)
    self._zongfen:setColor(cc.c3b(255, 255, 255))
    -- self._zongfen:enable2Color(1, cc.c4b(255, 226, 147, 255))
    -- self._zongfen:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._zongfen:setFontSize(26)

    local des1 = self:getUI("bg.des1")
    des1:setColor(UIUtils.colorTable.ccUIBasePromptColor)
    -- des1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    des1:setString(lang("TUJIAN_SHOW_1"))
    local des2 = self:getUI("bg.des2")
    des2:setColor(UIUtils.colorTable.ccUIBasePromptColor)
    -- des2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    des2:setString(lang("TUJIAN_SHOW_2"))

    local quickadd = self:getUI("bg.quickadd")    
    quickadd:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnColor4, 1)
    quickadd:setTitleFontSize(20)
    quickadd:setTitleColor(cc.c4b(255, 255, 255, 255)) 
    quickadd:setTitleFontName(UIUtils.ttfName)
    -- quickadd:setTitleFontSize(20)
    self:registerClickEvent(quickadd, function()
        self:quickAdd()
    end)

    self._showTeam = {}    
    for i=1,5 do
        self._showTeam[i] = self:getUI("bg.showTeam" .. i)
        -- self._showTeam[i]:setAnchorPoint(cc.p(0.5,0.5))
        self._showTeam[i].pokedex = self._showTeam[i]:getChildByFullName("pokedex")
        self._showTeam[i].suo = self._showTeam[i]:getChildByFullName("suo")
        self._showTeam[i].suo:setScale(0.8)
        self._showTeam[i].addTeam = self._showTeam[i]:getChildByFullName("addTeam")
        self._showTeam[i].addYellow = self._showTeam[i]:getChildByFullName("add_yellow")
        self._showTeam[i].addTeam:setVisible(false)
        self._showTeam[i].addYellow:setVisible(false)
        local fade1 = cc.FadeOut:create(0.8)
        local fade2 = cc.FadeIn:create(0.8)
        local seq = cc.Sequence:create(fade1,fade2)
        local rep = cc.RepeatForever:create(seq)
        self._showTeam[i].addTeam:runAction(rep)

        self._showTeam[i].pingfen = self._showTeam[i]:getChildByFullName("pingfenBg.pingfen")
        self._showTeam[i].pingfenBg = self._showTeam[i]:getChildByFullName("pingfenBg")
        self._showTeam[i].pingjia = self._showTeam[i]:getChildByFullName("pingfenBg.pingjia")
        self._showTeam[i].gem = self._showTeam[i]:getChildByFullName("gem")        
        local scaleNum1 = math.floor((36/self._showTeam[i].gem:getContentSize().width)*100)
        self._showTeam[i].gem:setScale(scaleNum1/100)
        self._showTeam[i].genValue = self._showTeam[i]:getChildByFullName("genValue")
        self._showTeam[i].des = self._showTeam[i]:getChildByFullName("des")
        self._showTeam[i].gem:setPositionY(self._showTeam[i].gem:getPositionY() + 6)
        -- self._showTeam[i].yuan = self:getUI("bg.stage.show" .. i)
        -- self._showTeam[i].tiao = self:getUI("bg.stage.showTiao" .. i)
    end
    self._isNeedupdate = true
    self:onModelReflash()
    self:listenReflash("PokedexModel", self.onModelReflash)
    self:listenReflash("UserModel", self.onModelReflash)
end

-- function PokedexDetailView:addSaoguang()
--     local mc1 = mcMgr:createViewMC("hengbanliudong_itemeffectcollection", true, false)
--     -- mc1:setPosition(self._detailCell[index]["effect" .. i]:getContentSize().width/2 ,self._detailCell[index]["effect" .. i]:getContentSize().height/2)
--     local clipNode = cc.ClippingNode:create()
--     clipNode:setInverted(false)
--     local mask = cc.Sprite:create("asset/bg/commonWin_bg.png")
--     mask:setAnchorPoint(cc.p(0,0.5))
--     -- mask:setScale(1.25)
--     -- mask:setPosition(cc.p(0,MAX_SCREEN_HEIGHT*0.5))
--     -- mc1:setPosition(35,35)
--     clipNode:setStencil(mask)
--     clipNode:setAlphaThreshold(0.1)
--     clipNode:addChild(mc1)
--     clipNode:setName("clipNode")
--     clipNode:setAnchorPoint(cc.p(0,0.5))
--     clipNode:setScale(1.25)
--     clipNode:setPosition(cc.p(0,MAX_SCREEN_HEIGHT*0.5))
--     -- clipNode:setRotation(-0.1)
--     bg:addChild(clipNode,2)
-- end

function PokedexDetailView:onModelReflash()
    -- self:setShowTeam()
    if self._isNeedupdate then 
        self:setShowTeam()
        self:reflashUI()
    end
end

function PokedexDetailView:reflashUI()

    local pokedexModel = self._modelMgr:getModel("PokedexModel")
    local pokedexPos = pokedexModel:getDataById(self._selectPokedex)
    dump(pokedexPos)

    -- self._title:setString(lang("TUJIANLABEL_" .. self._selectPokedex))
    self._reward:setString("所有" .. lang("TUJIANTITLE_" .. tab:Tujian(self._selectPokedex).art) .. "攻击")
    local str = 0.006 * pokedexPos.score
    self._rewardValue:setString("+" .. TeamUtils.getNatureNums(str) .. "%")
    self._rewardValue:setPositionX(self._reward:getPositionX() + self._reward:getContentSize().width + 5)
    
    self._reward1:setString("生命")
    self._rewardValue1:setString("+" .. TeamUtils.getNatureNums(str) .. "%")
    self._reward1:setPositionX(self._rewardValue:getPositionX() + self._rewardValue:getContentSize().width + 25)
    self._rewardValue1:setPositionX(self._reward1:getPositionX() + self._reward1:getContentSize().width + 5)


    self._zhandouli:setString("a+" .. math.ceil(pokedexPos.fight))
    self._zhandouli:setScale(0.6)
    -- if true then
    if self._pingfenshuaxin == true then
        local zongfenBg = self:getUI("zongfenBg")

        local mask = cc.Sprite:create()
        mask:setSpriteFrame("pokeImage_bg6.png")
        mask:setAnchorPoint(cc.p(0.5,0.5))
        mask:setPosition(cc.p(0, 0))

        local mc1 = mcMgr:createViewMC("tujianpingfenbianhua_pokedextujianpingfenbianhua", false, true)
        -- mc1:setPosition(cc.p(mc1:getContentSize().width*0.5,mc1:getContentSize().height*0.5))
        mc1:setPosition(cc.p(-1*mask:getContentSize().width*0.5,10))
        -- zongfenBg:addChild(mc1)

        local clipNode = cc.ClippingNode:create()
        clipNode:setInverted(false)

        clipNode:setStencil(mask)
        clipNode:setAlphaThreshold(0.1)
        clipNode:addChild(mc1)
        clipNode:setName("clipNode")
        clipNode:setAnchorPoint(cc.p(0.5,0.5))
        clipNode:setPosition(cc.p(zongfenBg:getContentSize().width*0.5,zongfenBg:getContentSize().height*0.5+13))
        clipNode:setRotation(-0.1)
        zongfenBg:addChild(clipNode,2)
    end
    self._zongfen:setString(lang("TUJIANLABEL_" .. tab:Tujian(self._selectPokedex).art) .. "总评分:" .. math.ceil(pokedexPos.score))
    local pokedexTab = tab:Tujianshengji(pokedexPos.level)
    local str = lang(tab:Tujian(self._selectPokedex).name) .. "图鉴" 
    if pokedexTab["stage"][2] ~= 0 then
        str = lang(tab:Tujian(self._selectPokedex).name) .. "图鉴 +" .. pokedexTab["stage"][2]
    end
    self._pokedexLevel:setString(str)
    self._pokedexLevel:setColor(UIUtils.colorTable["ccUIBaseColor" .. pokedexTab["stage"][1]])
    self._pokeEffect:setString("总评分+" .. pokedexTab["effect"] .. "%")
    self:setAnim(0,3)
end


function PokedexDetailView:setShowTeam()

    local pokedexModel = self._modelMgr:getModel("PokedexModel")
    local pokedexPos = pokedexModel:getDataById(self._selectPokedex)
    if not pokedexPos then
        local userData = self._modelMgr:getModel("UserModel"):getData()
        self._viewMgr:onLuaError(serialize({userId = userData._id, pokedexId = self._selectPokedex, msg = "pokedexData is empty"}))
        return
    end

    local teamModel = self._teamModel
    local tjData = tab:Tujian(self._selectPokedex)
    local userlevel = self._modelMgr:getModel("UserModel"):getData().lvl
    local viplevel = self._modelMgr:getModel("VipModel"):getData().level


    for i=1,5 do
        local openCondition = tjData.openCondition[i]
        if userlevel >= openCondition[1] or viplevel >= openCondition[2] then
            if pokedexPos.posList[tostring(i)] then  -- 解锁
                if  pokedexPos.posList[tostring(i)] ~= 0 then -- 展示
                    local teamData = teamModel:getTeamAndIndexById(pokedexPos.posList[tostring(i)])
                    self:setPokedexStage(i,teamData,4)
                else
                    self:setPokedexStage(i,teamData,3)
                end
            else
                self:setPokedexStage(i,teamData,2)
            end
        else
            self:setPokedexStage(i,teamData,1)
        end
    end
end

function PokedexDetailView:setPokedexStage(index,teamData,stage)
    -- if stage == 3 then
    --     ScheduleMgr:delayCall(500, self, function()
    --         self:setPokedexStage1(index,teamData,stage)
    --     end)
    -- else
        self:setPokedexStage1(index,teamData,stage)
    -- end
        local pokedexModel = self._modelMgr:getModel("PokedexModel")
        local pokedexPos = pokedexModel:getDataById(self._selectPokedex)
        local tempTeam = self._teamModel:getClassTeam(tab:Tujian(self._selectPokedex).art)
        local tempFlag = 0
        if pokedexPos.posList[tostring(index)] == 0 then
            for k,v in pairs(tempTeam) do
                local flag,pokedexKey = pokedexModel:getPokedexShangzhen(v.teamId)
                -- print("flag,pokedexKey ===", flag,pokedexKey, self._selectPokedex)
                if flag == false then
                    tempFlag = 1
                    break
                else
                    if tonumber(pokedexKey) ~= self._selectPokedex then
                        tempFlag = -1
                    end
                end
            end
        else
            tempFlag = 0
        end

        if tempFlag == 0 then
            self._showTeam[index].addTeam:setVisible(false)
            self._showTeam[index].addYellow:setVisible(false)
        elseif tempFlag == -1 then           
            self._showTeam[index].addTeam:setVisible(false)
            self._showTeam[index].addYellow:setVisible(true)
        elseif tempFlag == 1 then
            self._showTeam[index].addTeam:setVisible(true)
            self._showTeam[index].addYellow:setVisible(false)
        end
        -- self._showTeam[index].addTeam:setVisible(true)
        -- self._showTeam[index].addYellow:setVisible(false)
end

-- function TeamView:update(dt)
--     local offset = self._tableView:getContentOffset()
--     if self._tempTableOffset == offset then 
--         return 
--     end
--     local childs = self._tableView:getContainer():getChildren()
--     if #childs <= 0 then 
--         return
--     end
--     -- 110 是cell 高度 ，320 是table 高度/2
--     self._tempTableOffset = offset
--     for k,v in pairs(childs) do
--         local x,y = v:getPosition()
--         x = 1.4 * math.sqrt(math.abs(math.pow(120,2) - 0.1* math.pow((y + 110/2 - offset.y * -1   - 320),2))) - 105
--         v:setPosition(x, y)
--     end
-- end


-- 设置图鉴4个状态
-- 1 未开启
-- 2 未解锁
-- 3 已解锁 & 无展示怪兽
-- 4 已解锁 & 有展示怪兽
function PokedexDetailView:setPokedexStage1(index,teamData,stage)
    local tjData = tab:Tujian(self._selectPokedex)
    local openCondition = tjData.openCondition[index]
    local showTeam = self._showTeam[index] 
    if stage == 1 then
        print("==========未开启")
        showTeam.suo:setVisible(true)
        -- showTeam.addTeam:setVisible(false)
        -- showTeam.addYellow:setVisible(false)
        -- showTeam.des:setVisible(false)
        showTeam.pokedex:loadTexture("pokeImage_bg1.png", 1)
        -- showTeam.pokedex:setVisible(false)
        -- showTeam.pokedex:setSaturation(-100)
        -- showTeam.pokedex:setOpacity(183)
        showTeam.genValue:setVisible(true)
        showTeam.genValue:setString("V" .. openCondition[2] .. "或" .. openCondition[1] .. "级可解锁")
        -- showTeam.genValue:setFontName(UIUtils.ttfName)
        showTeam.genValue:setColor(UIUtils.colorTable.ccUIBasePromptColor)
        -- showTeam.genValue:enableOutline(cc.c4b(47,28,0,255), 2)
        showTeam.genValue:setPositionX((showTeam:getContentSize().width - showTeam.genValue:getContentSize().width)*0.5 - 3)
        showTeam.gem:setVisible(false)
        showTeam.pingfen:setVisible(false)
        showTeam.pingfenBg:setVisible(false)
        showTeam.pingjia:setVisible(false)

        -- showTeam.yuan:loadTexture("pokeImage_img1.png", 1)
        -- showTeam.tiao:setVisible(false)
        -- if showTeam.mc1 then
        --     showTeam.mc1:setVisible(false)
        -- end

    elseif stage == 2 then
        print("==========未解锁")
        showTeam.pokedex:loadTexture("pokeImage_bg1.png", 1)
        showTeam.suo:setVisible(true)
        -- showTeam.des:setVisible(true)
        -- showTeam.addTeam:setVisible(false)
        -- showTeam.addYellow:setVisible(false)
        showTeam.pingfen:setVisible(false)
        showTeam.pingfenBg:setVisible(false)
        showTeam.pingjia:setVisible(false)
        -- showTeam.pokedex:setSaturation(-100)
        -- showTeam.pingfen:setFontName(UIUtils.ttfName)
        -- showTeam.pingfen:setColor(cc.c3b(255,235,191))
        -- showTeam.pingfen:enableOutline(cc.c4b(85,14,0,255), 1)
        showTeam.genValue:setColor(cc.c3b(240,230,200))
        -- showTeam.genValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        showTeam.gem:setVisible(true)
        showTeam.genValue:setVisible(true)

        -- showTeam.yuan:loadTexture("pokeImage_img1.png", 1)
        -- showTeam.tiao:setVisible(false)
        -- if showTeam.mc1 then
        --     showTeam.mc1:setVisible(false)
        -- end

        local costNum = tab:Tujian(self._selectPokedex).openCost[index]
        -- showTeam.des:setString("需要")
        showTeam.genValue:setString(costNum .. "解锁")
        local tempX = (showTeam:getContentSize().width - showTeam.genValue:getContentSize().width - showTeam.gem:getContentSize().width)*0.5
        -- showTeam.des:setPositionX(tempX)
        -- tempX = tempX + showTeam.des:getContentSize().width
        showTeam.gem:setPositionX(tempX)
        tempX = tempX + showTeam.gem:getContentSize().width*showTeam.gem:getScale()
        showTeam.genValue:setPositionX(tempX)
        
        -- showTeam.pingfen:setString("需要")
        -- local tempX = showTeam.pingfen:getContentSize().width + showTeam.gem:getContentSize().width*showTeam.gem:getScale() + showTeam.genValue:getContentSize().width
        -- tempX = (showTeam:getContentSize().width - tempX)/2
        -- showTeam.pingfen:setPositionX(tempX)
        -- tempX = tempX + showTeam.pingfen:getContentSize().width
        -- showTeam.gem:setPositionX(tempX)
        -- tempX = tempX + showTeam.gem:getContentSize().width*showTeam.gem:getScale()
        -- showTeam.genValue:setPositionX(tempX)

        local userData = self._modelMgr:getModel("UserModel"):getData()
        -- print("======================", userData.gem , costNum)
        if userData.gem < costNum then
            self:registerClickEvent(showTeam.pokedex, function()
                local param = {callback1 = function()
                    self._viewMgr:showView("vip.VipView", {viewType = 0})
                end}
                DialogUtils.showNeedCharge(param)
            end)
        else
            self:registerClickEvent(showTeam.pokedex, function()
                local userData = self._modelMgr:getModel("UserModel"):getData()
                if userData.gem < costNum then
                    local param = {callback1 = function()
                        self._viewMgr:showView("vip.VipView", {viewType = 0})
                    end}
                    DialogUtils.showNeedCharge(param)
                    return
                end
                -- self:setAnim(index, 2)
                local param = {goods = "解锁？",costNum = costNum, costType = "gem",callback1 = function()
                    -- 向服务器请求数据
                    -- self:setAnim(index, 2)
                    -- local callfunc = cc.CallFunc:create(function()
                        self._isNeedupdate = false
                        self._serverMgr:sendMsg("PokedexServer", "activePokedexPos", {pokedexId = self._selectPokedex, positionId = index}, true, {}, function (result)
                            -- ScheduleMgr:delayCall(2000, self, function()
                            showTeam.suo:setVisible(false)
                            self:setAnim(index, 2)
                                -- end)
                        end)
                    -- end)
                    -- local seq = CCSequence:create(cc.DelayTime:create(0.5),callfunc)
                    -- self:runAction(seq)
                end}
                DialogUtils.showBuyDialog(param)
            end)
        end

    elseif stage == 3 then
        print("==========已解锁 & 无展示怪兽")
        showTeam.pokedex:loadTexture("pokeImage_bg0.png", 1)
        showTeam.suo:setVisible(false)
        -- showTeam.pokedex:setSaturation(0)
        -- showTeam.addTeam:setVisible(false)
        -- showTeam.addYellow:setVisible(false)
        showTeam.pokedex:setVisible(true)
        showTeam.gem:setVisible(false)
        showTeam.genValue:setVisible(false)
        showTeam.pingfen:setVisible(true)
        showTeam.pingfenBg:setVisible(true)
        showTeam.pingjia:setVisible(false)
        -- showTeam.yuan:loadTexture("pokeImage_img1.png", 1)
        -- showTeam.tiao:setVisible(false)
        -- if showTeam.mc1 then
        --     showTeam.mc1:setVisible(false)
        -- end

        if showTeam.card then
            showTeam.card:setVisible(false)
        else
            local sysTeam = tab:Team(102)
            local param = {teamD = sysTeam, level = 1, star = 1, teamData = teamData}
            showTeam.card = CardUtils:createTeamCard(param)
            showTeam.card:setScale(0.56)
            showTeam.card:setPosition(showTeam:getContentSize().width * 0.5 - 5, showTeam:getContentSize().height * 0.5 - 2)
            showTeam:addChild(showTeam.card)
            showTeam.card:setVisible(false)
        end

        showTeam.pingfen:setString("评分:0")

        -- showTeam.pingfen:setFontName(UIUtils.ttfName)
        -- showTeam.pingfen:setColor(cc.c3b(255, 225, 24))
        -- showTeam.pingfen:enable2Color(1, cc.c4b(255, 226, 147, 255))
        -- showTeam.pingfen:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        showTeam.pingfen:setFontSize(20)
        showTeam.pingfen:setPositionX((showTeam.pingfenBg:getContentSize().width)*0.5-showTeam.pingfen:getContentSize().width*0.5)
        self:registerClickEvent(showTeam.pokedex, function()
            self._oldFight = TeamUtils:updateFightNum()
            self._viewMgr:showDialog("pokedex.PokedexSelectTeam", {pokedexType = self._selectPokedex, posId = index, callback = function()
                self:putCardAnim(index)
                local fightBg = self:getUI("bg")
                TeamUtils:setFightAnim(fightBg, {oldFight = self._oldFight, newFight = TeamUtils:updateFightNum(), x = fightBg:getContentSize().width*0.5-100, y = fightBg:getContentSize().height - 200})
            end})
            -- self._viewMgr:showDialog("pokedex.PokedexSelectTeam", {pokedexType = self._selectPokedex, posId = index, pokDV = self})
        end)

    elseif stage == 4 then
        print("==========已解锁 & 有展示怪兽")
        showTeam.suo:setVisible(false)
        showTeam.gem:setVisible(false)
        showTeam.genValue:setVisible(false)
        -- showTeam.addTeam:setVisible(false)
        -- showTeam.addYellow:setVisible(false)
        showTeam.pokedex:setVisible(false)
        showTeam.pokedex:setSaturation(0)
        -- showTeam.yuan:loadTexture("pokeImage_img2.png", 1)
        -- showTeam.tiao:setVisible(true)
        -- self:setAnim(index, 1)
        if showTeam.card then
            showTeam.card:setVisible(true)
        end

        local pingfenScore = self._teamModel:getTeamAddPingScore(teamData) 
        local pingjia = self._teamModel:getTeamPingjia(pingfenScore)
        local str = "评分:" .. pingfenScore
        showTeam.pingfen:setString(str)
        showTeam.pingjia:loadTexture("globalImgUI_pingjia" .. pingjia .. ".png", 1)
        showTeam.pingfenBg:setVisible(true)
        showTeam.pingjia:setVisible(true)
        -- showTeam.pingfen:setFontName(UIUtils.ttfName)
        -- showTeam.pingfen:setColor(cc.c3b(255, 225, 24))
        -- showTeam.pingfen:enable2Color(1, cc.c4b(255, 226, 147, 255))
        -- showTeam.pingfen:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        showTeam.pingfen:setFontSize(20)
        local pingfenPosx = (showTeam.pingfenBg:getContentSize().width)*0.5-3-showTeam.pingfen:getContentSize().width*0.5-showTeam.pingjia:getContentSize().width*0.5*showTeam.pingjia:getScaleX()
        showTeam.pingfen:setPositionX(pingfenPosx)
        showTeam.pingjia:setPositionX(pingfenPosx+showTeam.pingfen:getContentSize().width+6)
        -- showTeam.pingfen:setPositionX((showTeam:getContentSize().width)*0.5)
        local sysTeam = tab:Team(teamData.teamId)
        local param = {teamD = sysTeam, level = teamData.level, star = teamData.star, teamData = teamData}
        if showTeam.card then
            CardUtils:updateTeamCard(showTeam.card, param)
        else
            showTeam.card = CardUtils:createTeamCard(param)
            showTeam.card:setScale(0.56)
            showTeam.card:setPosition(showTeam:getContentSize().width * 0.5 - 5, showTeam:getContentSize().height * 0.5 - 2)
            showTeam:addChild(showTeam.card)
        end
        self:registerClickEvent(showTeam, function()
            -- self:putCardAnim(index)
            self._oldFight = TeamUtils:updateFightNum()
            self._viewMgr:showDialog("pokedex.PokedexSelectTeam", {pokedexType = self._selectPokedex, posId = index, callback = function()
                self:putCardAnim(index)
                local fightBg = self:getUI("bg")
                TeamUtils:setFightAnim(fightBg, {oldFight = self._oldFight, newFight = TeamUtils:updateFightNum(), x = fightBg:getContentSize().width*0.5-100, y = fightBg:getContentSize().height - 200})
            end})
            -- self._viewMgr:showDialog("pokedex.PokedexSelectTeam", {pokedexType = self._selectPokedex, posId = index, pokDV = self})
        end)
    end
end


function PokedexDetailView:setAnim(index, animType)
    if animType == 1 then
        if not self._showTeam[index].mc1 then
            self._showTeam[index].mc1 = mcMgr:createViewMC("guang_pokedex", true, false)
            self._showTeam[index].mc1:setPosition(cc.p(25,25))
            self._showTeam[index].yuan:addChild(self._showTeam[index].mc1)
        end
        self._showTeam[index].mc1:setVisible(true)
    elseif animType == 2 then -- 解锁光
        self._viewMgr:lock(-1)    
        local mc2 = mcMgr:createViewMC("jiesuoguang_pokedex", false, true, function(_, sender)
            self._viewMgr:unlock()
        end)
        mc2:setScale(0.8)
        mc2:addCallbackAtFrame(12, function()
            self._isNeedupdate = true
            self:setPokedexStage(index,nil,3)
        end)
        mc2:setPosition(cc.p(self._showTeam[index]:getContentSize().width/2 - 5, self._showTeam[index]:getContentSize().height/2 + 35))
        self._showTeam[index]:addChild(mc2, 5)
        -- self:setPokedexStage(index,nil,3)
    elseif animType == 3 then
        local anim1 = self._upGrade:getChildByName("anim1")
        if not anim1 then
            local mc1 = mcMgr:createViewMC("anniuguang_pokedex", true, false)
            mc1:setPosition(cc.p(0,0))
            local clipNode = cc.ClippingNode:create()
            local mask = cc.Sprite:createWithSpriteFrameName("pokeImage_zhezhao.png")
            mask:setAnchorPoint(cc.p(0,0.5))
            clipNode:setStencil(mask)
            clipNode:setAlphaThreshold(0.1)
            clipNode:addChild(mc1)
            clipNode:setName("anim1")
            clipNode:setAnchorPoint(cc.p(0,0.5))
            clipNode:setPosition(cc.p(26,40))
            anim1 = clipNode
            self._upGrade:addChild(anim1)
        end
        local pokedexData = self._modelMgr:getModel("PokedexModel"):getDataById(self._selectPokedex)
        local userData = self._modelMgr:getModel("UserModel"):getData()

        local tpokedexLevel = pokedexData.level or 1
        local pokedexNextLevel = pokedexData.level + 1
        -- print("===========", pokedexNextLevel, tab:Tujianshengji(table.nums(tab.tujianshengji) - 1))
        if pokedexNextLevel > tab:Tujianshengji(table.nums(tab.tujianshengji) - 1).id  then
            pokedexNextLevel = pokedexData.level 
        end
        local needItemNum = tab:Tujianshengji(pokedexNextLevel).itemNum
        local itemModel = self._modelMgr:getModel("ItemModel")
        local itemId = tab:Tujian(self._selectPokedex).itemId
        local tempItems, tempItemCount = itemModel:getItemsById(itemId)
        if pokedexNextLevel >= table.nums(tab:Tujian(self._selectPokedex).levelUpLimit) - 1 then
            pokedexNextLevel = table.nums(tab:Tujian(self._selectPokedex).levelUpLimit) - 1
        end
        local hongdian = self:getUI("rewardBg.pokeEffectBg.hongdian")
        if tpokedexLevel < (table.nums(tab:Tujian(self._selectPokedex).levelUpLimit)-1) and userData.lvl >= tab:Tujian(self._selectPokedex).levelUpLimit[pokedexNextLevel + 1] and tempItemCount >= needItemNum then
            anim1:setVisible(true)
            hongdian:setVisible(true)
        else 
            anim1:setVisible(false)
            hongdian:setVisible(false)
        end
    end
end

-- 上阵卡牌效果
function PokedexDetailView:putCardAnim(index)
    self._pingfenshuaxin = true
    -- self._showTeam[index]:setOpacity(0)
    -- local spawn = cc.Spawn:create(cc.FadeIn:create(0.5), )
    -- self._showTeam[index].pokedex:setScale(2)
    local seq = cc.Sequence:create(cc.DelayTime:create(0.1),cc.ScaleTo:create(0, 1), cc.ScaleTo:create(0.07, 0.56), cc.ScaleTo:create(0.05, 0.55), cc.ScaleTo:create(0, 0.56), cc.CallFunc:create(function()
        -- local mc2 = mcMgr:createViewMC("fangzhiguang_pokedex", true, false, function(_, sender)
        local mc2 = mcMgr:createViewMC("kaiqi_pokedex", false, true, function(_, sender)
            -- local mc1 = mcMgr:createViewMC("saoguang_pokedex", false, true)
            -- mc1:setPosition(cc.p(self._showTeam[index]:getContentSize().width/2, self._showTeam[index]:getContentSize().height/2 + 8))
            -- self._showTeam[index]:addChild(mc1)
        end)
        mc2:setPosition(cc.p(self._showTeam[index]:getContentSize().width/2, self._showTeam[index]:getContentSize().height/2 + 8))
        self._showTeam[index]:addChild(mc2, -1)

        -- local fightBg = self:getUI("bg")
        -- TeamUtils:setFightAnim(fightBg, {oldFight = self._oldFight, newFight = TeamUtils:updateFightNum(), x = fightBg:getContentSize().width*0.5, y = fightBg:getContentSize().height - 200})

    end))
    if self._showTeam[index].card then
        self._showTeam[index].card:runAction(seq)
    end
    -- self._showTeam[index].card:runAction(seq)

end

-- function PokedexDetailView:getBgName()
--     return "bg_003.jpg"
-- end

function PokedexDetailView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{hideInfo = true, hideHead = true})
end

function PokedexDetailView:setNoticeBar()
    self._viewMgr:hideNotice(true)
end


-- 快速添加
function PokedexDetailView:quickAdd()
    local pokedexModel = self._modelMgr:getModel("PokedexModel")
    local pokedexPos = pokedexModel:getDataById(self._selectPokedex)
    dump(pokedexPos.posList)
    -- 可添加位置
    local addPokedexData = {}
    -- for i=1,table.nums(pokedexPos.posList) do
    --     if pokedexPos.posList[tostring(i)] == 0 then
    --         table.insert(addPokedexData, i)
    --     end
    -- end

    for i=1,5 do
        if pokedexPos.posList[tostring(i)] == 0 then
            table.insert(addPokedexData, i)
        end
    end

    for k,v in pairs(pokedexPos.posList) do
        if pokedexPos.posList[tostring(i)] == 0 then
            table.insert(addPokedexData, k)
        end
    end


    -- 可添加兵团
    local addTeamData = self:getAddTeam()
    if table.nums(addPokedexData) == 0 then
        self._viewMgr:showTip("暂无可添加位置")
        return
    elseif table.nums(addTeamData) == 0 then
        self._viewMgr:showTip("暂无可添加兵团")
        return
    end

    if table.nums(addPokedexData) < table.nums(addTeamData) then
        self._pokedexAddNum = table.nums(addPokedexData)
    else
        self._pokedexAddNum = table.nums(addTeamData)
    end

    -- dump(addTeamData, "addTeamData=========")
    -- dump(addPokedexData, "addTeamData=========")
    self:putAllTeam(addTeamData, addPokedexData)
end

function PokedexDetailView:putAllTeam(addTeamData, addPokedexData)
    if self._pokedexAddNum == 0 then
        return
    end

    local putList = {}
    for i=1,self._pokedexAddNum do
        local tempTeam = {addPokedexData[i], addTeamData[i].teamId}
        table.insert(putList, tempTeam)
        -- tempTeam[1] = 
    end
    dump(putList)
    -- local param = {pokedexId = self._selectPokedex, positionId = addPokedexData[self._add], teamId = addTeamData[self._add]["teamId"]}
    -- local param = {pokedexId = self._selectPokedex, putList = {{tonumber(self._posId),v.teamId}}}
    local param = {pokedexId = self._selectPokedex, putList = putList}
    self:putTeamOnPokedexPos(param)
end

function PokedexDetailView:getAddTeam()
    local addTeamData = {}
    local pokedexModel = self._modelMgr:getModel("PokedexModel")
    local tempTeamData = self._modelMgr:getModel("TeamModel"):getClassTeam(tab:Tujian(self._selectPokedex).art)

    for k,v in pairs(tempTeamData) do
        local score = self._modelMgr:getModel("TeamModel"):getTeamAddPingScore(v)
        v.pokedexScore = score
    end
    self:processData(tempTeamData) 
    
    for k,v in ipairs(tempTeamData) do
        local flag,pokedexKey = pokedexModel:getPokedexShangzhen(v.teamId)
        if flag == false then
            table.insert(addTeamData, v)
        end
    end
    return addTeamData
end

function PokedexDetailView:processData(tempData)
    if table.nums(tempData) <= 1 then
        return
    end
    local sortFunc = function(a, b) 
        local acheck = a.pokedexScore
        local bcheck = b.pokedexScore
        if acheck == nil then
            return
        end
        if bcheck == nil then
            return
        end
        if acheck > bcheck then
            return true
        end
    end
    table.sort(tempData, sortFunc)
end

-- 怪兽上阵
function PokedexDetailView:putTeamOnPokedexPos(param)
    self._viewMgr:lock(-1)
    self._oldFight = TeamUtils:updateFightNum()
    self._serverMgr:sendMsg("PokedexServer", "putTeamOnPokedexPos", param, true, {}, function (result)
        for k,v in pairs(param.putList) do
            self:putCardAnim(v[1])
        end
        local fightBg = self:getUI("bg")
        TeamUtils:setFightAnim(fightBg, {oldFight = self._oldFight, newFight = TeamUtils:updateFightNum(), x = fightBg:getContentSize().width*0.5-100, y = fightBg:getContentSize().height - 200})

        audioMgr:playSound("PlaceDex")
        self._viewMgr:unlock()
    end)
end

function PokedexDetailView:setFightAnim(inTable)
    if (inTable.newFight - inTable.oldFight) <= 0 then
        return
    end
    local fightLabel = self:getUI("rewardBg.zhandouli")
    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function()
        audioMgr:playSound("PowerCount")
    end)))
    -- local addfight = self:getUI("nameBg.addFight")
    -- addfight:setVisible(true)
    -- addfight:setColor(cc.c3b(118,238,0))
    -- addfight:enableOutline(cc.c4b(60,30,10, 255), 1)
    fightLabel:stopAllActions()
    -- addfight:setString("+" .. (inTable.newFight - inTable.oldFight))
    local tempGunlun, tempFight 
    -- if (inTable.newFight - inTable.oldFight) < 10 then
    --     tempFight = math.floor(inTable.newFight * 0.01) * 100
    --     tempGunlun = inTable.newFight - tempFight
    -- elseif (inTable.newFight - inTable.oldFight) < 100 then
    --     tempFight = math.floor(inTable.newFight * 0.001) * 1000
    --     tempGunlun = inTable.newFight - tempFight
    -- else
    --     tempFight = 0
    --     tempGunlun = inTable.newFight - tempFight
    -- end
    tempGunlun = inTable.newFight - inTable.oldFight
    tempFight = inTable.oldFight
    local fightNum = tempGunlun / 20
    local numsch = 1
    local sequence = cc.Sequence:create(
        cc.ScaleTo:create(0.05, 1.1),
        cc.Repeat:create(cc.Sequence:create(cc.DelayTime:create(0.05),cc.CallFunc:create(function()
            fightLabel:setString("a" .. (tempFight + math.ceil(fightNum * numsch)))
            numsch = numsch + 1
        end)), 20),
        cc.CallFunc:create(function()
            fightLabel:setString("a" .. inTable.newFight)
            -- addfight:setPositionX(fightLabel:getPositionX() + fightLabel:getContentSize().width + 8)
            -- addfight:runAction(cc.Sequence:create(
            --     cc.FadeIn:create(0.2),
            --     cc.FadeTo:create(0.3, 80),
            --     -- cc.FadeOut:create(0.3),
            --     cc.FadeIn:create(0.2),
            --     cc.FadeOut:create(0.3)
            --     )
            -- )
        end),
        cc.ScaleTo:create(0.05, 1)
        )
    fightLabel:runAction(sequence)
end


-- -- 快速添加
-- function PokedexDetailView:quickAdd()
--     local pokedexModel = self._modelMgr:getModel("PokedexModel")
--     local pokedexPos = pokedexModel:getDataById(self._selectPokedex)
--     local addPokedexData = {}
--     for i=1,table.nums(pokedexPos.posList) do
--         if pokedexPos.posList[tostring(i)] == 0 then
--             table.insert(addPokedexData, i)
--         end
--     end

--     local addTeamData = self:getAddTeam()
--     if table.nums(addPokedexData) == 0 then
--         self._viewMgr:showTip("暂无可添加位置")
--         return
--     elseif table.nums(addTeamData) == 0 then
--         self._viewMgr:showTip("暂无可添加兵团")
--         return
--     end

--     if table.nums(addPokedexData) < table.nums(addTeamData) then
--         self._pokedexAddNum = table.nums(addPokedexData)
--     else
--         self._pokedexAddNum = table.nums(addTeamData)
--     end

--     -- dump(addTeamData, "addTeamData=========")
--     -- dump(addPokedexData, "addTeamData=========")
--     self._add = 1
--     self:putAllTeam(addTeamData, addPokedexData, self._add)
-- end

-- function PokedexDetailView:putAllTeam(addTeamData, addPokedexData, testNum)
--     if self._pokedexAddNum == 0 then
--         return
--     end
--     print(addTeamData, addPokedexData, testNum)
--     -- local param = {pokedexId = self._selectPokedex, positionId = addPokedexData[self._add], teamId = addTeamData[self._add]["teamId"]}
--     local param = {pokedexId = self._selectPokedex, putList = {{tonumber(self._posId),v.teamId}}}
--     self:putTeamOnPokedexPos(addTeamData, addPokedexData, param, callback)
--     -- local test = function(param)
--     --     self._pokedexAddNum = self._pokedexAddNum - 1
--     --     self:putTeamOnPokedexPos(addTeamData, addPokedexData, param, callback)
--     -- end 
-- end

-- function PokedexDetailView:getAddTeam()
--     local addTeamData = {}
--     local pokedexModel = self._modelMgr:getModel("PokedexModel")
--     local tempTeamData = self._modelMgr:getModel("TeamModel"):getClassTeam(tab:Tujian(self._selectPokedex).art)
--     self:processData(tempTeamData) 
--     for k,v in pairs(tempTeamData) do
--         local flag,pokedexKey = pokedexModel:getPokedexShangzhen(v.teamId)
--         if flag == false then
--             table.insert(addTeamData, v)
--         end
--     end
--     return addTeamData
-- end

-- function PokedexDetailView:processData(tempData)
--     if table.nums(tempData) <= 1 then
--         return
--     end
--     local sortFunc = function(a, b) 
--         local acheck = a.star
--         local bcheck = b.star
--         if acheck == nil then
--             return
--         end
--         if bcheck == nil then
--             return
--         end
--         if acheck > bcheck then
--             return true
--         end
--     end
--     table.sort(tempData, sortFunc)
-- end

-- -- 怪兽上阵
-- function PokedexDetailView:putTeamOnPokedexPos(addTeamData, addPokedexData, param)
--     -- print("HHHHHHHHHHHHHHHHHHHHHH", self._add, self._pokedexAddNum)
--     self._viewMgr:lock(-1)
--     self._serverMgr:sendMsg("PokedexServer", "putTeamOnPokedexPos", param, true, {}, function (result)
--         self:putCardAnim(param.positionId)
--         self._add = self._add + 1
--         self._pokedexAddNum = self._pokedexAddNum - 1
--         audioMgr:playSound("PlaceDex")
--         self:putAllTeam(addTeamData, addPokedexData, self._add)
--         self._viewMgr:unlock()
--     end)
-- end

function PokedexDetailView:getReleaseDelay()
    return 0
end

function PokedexDetailView:getBgName()
    return "bg_003.jpg"
end


return PokedexDetailView


