--[[
    Filename:    TeamUpStarNode.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2015-12-18 10:16:04
    Description: File description
--]]

local TeamUpStarNode = class("TeamUpStarNode", BaseLayer)

-- local moveFeiGuang = {
--     [1] = {posX = 0, posY = 0, angle = 0},
--     [2] = {posX = 10.3, posY = 24.5, angle = -65.5},
--     [3] = {posX = 18.65, posY = 28.14, angle = -62.2},
--     [4] = {posX = 22.94, posY = 35, angle = -59.1},
--     [5] = {posX = 30, posY = 47, angle = -56},
--     [6] = {posX = 38, posY = 55, angle = -53}          
-- }

-- local moveFeiGuang = {
--     [1] = {posX = -560, posY = 60, angle = 0},
--     [2] = {posX = -550.3, posY = 84.5, angle = -65.5},
--     [3] = {posX = -342.65, posY = 88.14, angle = -62.2},
--     [4] = {posX = -538.94, posY = 95, angle = -59.1},
--     [5] = {posX = -530, posY = 107, angle = -56},
--     [6] = {posX = -522, posY = 115, angle = -53}          
-- }

function TeamUpStarNode:ctor(param)
    TeamUpStarNode.super.ctor(self)
    self._smallStar = {}
    -- self._bigStar = {}
    self._bigStarPos = param.starPos or {}
    self._starTip = param.starTip
    -- print("param.callback=======",param.callback)
    self._setBigStarCallBack = param.callback or nil 
    self._fightCallback = param.fightCallback
    self._clickSign = true
    self._disValue = {}
    self._biaojiSmallStar = 0
end

function TeamUpStarNode:onInit()
    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._Panel_35 = self:getUI("bg.Panel_35")
    for i=1,10 do
        self._smallStar[i] = self._Panel_35:getChildByFullName("smallStar" .. i)
    end

    self._upStar = self:getUI("bg.upStar")
    self._oneUpStar = self:getUI("bg.oneUpStar")
    self._maxStar = self:getUI("bg.gaoji")
    local mc1 = mcMgr:createViewMC("jihuoqianneng_teamqianneng", true, false)
    mc1:setPosition(self._maxStar:getContentSize().width/2, self._maxStar:getContentSize().height/2)
    self._maxStar:addChild(mc1, 1)

    -- 激活潜能
    self:registerClickEvent(self._maxStar, function()
        self:activationPotential()
    end)

    self._seniorNum = 1
    for i=1,3 do
        local hstar = self:getUI("bg1.panel.hstar" .. i)
        self:registerTouchEvent(hstar, nil, nil, function()
            self:updateSelectHStar(false)
            self._seniorNum = i 
            self:updateSelectHStar(true)
            self:updateConsumeHStar()
            if self._starTip then
                self._starTip:setVisible(false)
            end
        end, function()
            if self._starTip then
                self._starTip:setVisible(false)
            end
        end, function()
            self:updateStarTip(i)
        end)
        -- local selectHstar = self:getUI("bg1.panel.hstar" .. i .. ".selectHstar")
        local selectHstar = mcMgr:createViewMC("xuanzhong_teamqianneng", true, false)
        selectHstar:setPosition(40, 40)
        hstar:addChild(selectHstar, 20)
        selectHstar:setName("selectHstar")
        selectHstar:setVisible(false)
        local levelLab = self:getUI("bg1.panel.hstar" .. i .. ".levelLab")
        levelLab:setVisible(false)
        -- levelLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        local nameLab = self:getUI("bg1.panel.hstar" .. i .. ".nameLab")
        nameLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        -- nameLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

        local potentialAttrTab = tab:PotentialAttr(i)
        nameLab:setString(lang(potentialAttrTab.name))
    end
    self:updateSelectHStar(true)
    -- self._maxStar:setFontName(UIUtils.ttfName)
    -- self._maxStar:setColor(cc.c3b(127, 85, 40))
    -- self._maxStar:setFontSize(28)

    self._addHun = self:getUI("bg.hunBg.addHun")
    self._addHun1 = self:getUI("bg1.hunBg.addHun")

    -- local starBg = ccui.ImageView:create()
    -- starBg:setName("starBg")
    -- -- starBg:loadTexture("asset/bg/race_bg_1.png")
    -- starBg:setAnchorPoint(cc.p(0,0))
    -- starBg:setPosition(cc.p(0,-6))
    -- self:addChild(starBg, -1)

    self._isNeedShowBigStar = true
    -- self:reflashUI()

    -- self:listenReflash("ItemModel", self.reflashItemUI)
    -- self:listenReflash("ItemModel", self.reflashItemData)


    -- for i=2,10 do
    --     self:setLiuGuang(i) 
    -- end
    -- self:setLiuGuang(10)  
    self:animBtn()
end

function TeamUpStarNode:updateSelectHStar(peg)
    local selectHstar = self:getUI("bg1.panel.hstar" .. self._seniorNum .. ".selectHstar")
    selectHstar:setVisible(peg)
end

function TeamUpStarNode:updateConsumeHStar()
    local hunNum = self:getUI("bg1.needBg.hunNum")
    local goldNum = self:getUI("bg1.needBg.goldNum")
    local needBg = self:getUI("bg1.needBg")
    local maxStar = self:getUI("bg1.maxStar")
    local upPotentBtn = self:getUI("bg1.upPotentBtn")

    local potentLevel = 1
    if self._teamData.pl and self._teamData.pl[tostring(self._seniorNum)] then
        potentLevel = self._teamData.pl[tostring(self._seniorNum)] + 1
    end
    local starMax = false
    if potentLevel > TeamUtils.hPotentialStar then
        starMax = true
        potentLevel = TeamUtils.hPotentialStar
    end
    local potentialTab = tab:Potential(potentLevel)
    hunNum:setString(potentialTab.goodsNum)
    goldNum:setString(potentialTab.gold)

    if starMax == true then
        needBg:setVisible(false)
        maxStar:setVisible(true)
        upPotentBtn:setVisible(false)
        return
    end
    needBg:setVisible(true)
    maxStar:setVisible(false)
    upPotentBtn:setVisible(true)

    local sysTeamData = tab:Team(self._teamData.teamId)
    local sameSouls, sameSoulCount = self._itemModel:getItemsById(sysTeamData.goods)
    if sameSoulCount >= potentialTab.goodsNum then
        hunNum:setColor(UIUtils.colorTable.ccUIUnLockColor)
    else
        hunNum:setColor(UIUtils.colorTable.ccUIBaseColor6)
    end

    local userGold = self._modelMgr:getModel("UserModel"):getData().gold
    if userGold >= potentialTab.gold then
        goldNum:setColor(UIUtils.colorTable.ccUIUnLockColor)
    else
        goldNum:setColor(UIUtils.colorTable.ccUIBaseColor6)
    end
end

function TeamUpStarNode:animBtn()
    local mc1 = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true, false)
    mc1:setName("anim")
    mc1:setPosition(self._upStar:getContentSize().width/2, self._upStar:getContentSize().height/2)
    self._upStar:addChild(mc1, 1)
    mc1:setVisible(false)

    local mc1 = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true, false)
    mc1:setName("anim")
    mc1:setPosition(self._oneUpStar:getContentSize().width/2, self._oneUpStar:getContentSize().height/2)
    self._oneUpStar:addChild(mc1, 1)
    mc1:setVisible(false)
end

function TeamUpStarNode:reflashUI(data)
    dump(data)
    self._clickSign = false
    self._teamData = data.teamData or {}
    self:updatePrimaryStar()

    -- 里属性
    if self._teamData.avn == 1 then
        local bg1 = self:getUI("bg1")
        bg1:setVisible(true)
        local bg = self:getUI("bg")
        bg:setVisible(false)
        self:updateConsumeHStar()
        self:updateSeniorStar()
    else
        local bg1 = self:getUI("bg1")
        local bg = self:getUI("bg")
        bg:setVisible(true)
        bg1:setVisible(false)
    end
end

function TeamUpStarNode:updateSeniorStar()
    local itemModel = self._modelMgr:getModel("ItemModel")
    local sysTeam = tab:Team(self._teamData.teamId) or 3201
    local sameSouls, sameSoulCount = itemModel:getItemsById(sysTeam.goods)

    local hunNum = self:getUI("bg1.hunBg.hunNum")
    hunNum:setColor(UIUtils.colorTable.ccUIBaseColor1)
    hunNum:setString(sameSoulCount)

    local teamModel = self._modelMgr:getModel("TeamModel")
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local smallStar1 = teamModel:getSmallStar(self._teamData)
    local tempSmallStar = (self._teamData.smallStar - (self._teamData.star - 1) * 10)

    -- 根据阵营设置星位置以及背景图
    local race = tab:Race(sysTeam["race"][1])

    local starBg = self:getChildByName("starBg")
    if starBg then
        starBg:setVisible(false)
    end

    local raceBg = self:getUI("bg1.panel.raceBg")
    raceBg:loadTexture("teamImageUI_race_" .. race.pic .. ".png", 1)

    for i=1,3 do
        local nameLab = self:getUI("bg1.panel.hstar" .. i .. ".nameLab")
        local potentLevel = 0
        if self._teamData.pl and self._teamData.pl[tostring(i)] then
            potentLevel = self._teamData.pl[tostring(i)]
        end
        -- levelLab:setString(potentLevel)
        local potentialAttrTab = tab:PotentialAttr(i)
        local str = lang(potentialAttrTab.name) .. " Lv." .. potentLevel
        nameLab:setString(str)
    end

    -- local potentLevel = 1
    -- if self._teamData.pl and self._teamData.pl[tostring(self._seniorNum)] then
    --     potentLevel = self._teamData.pl[tostring(self._seniorNum)]
    -- end
    -- local potentialTab = tab:Potential(potentLevel)

    -- if userData.gold < potentialTab.gold then
    --     self:registerClickEvent(upPotentBtn, function()
    --         DialogUtils.showLackRes()
    --     end)
    -- elseif (potentialTab.goodsNum or 100) > sameSoulCount then
    --     self:registerClickEvent(upPotentBtn, function()
    --         self._viewMgr:showTip(lang("TIPS_BINGTUAN_09"))
    --     end)
    -- else
    --     self:registerClickEvent(upPotentBtn, function()
    --         self:upPotential(self._seniorNum)
    --     end)
    -- end

    local upPotentBtn = self:getUI("bg1.upPotentBtn")
    self:registerClickEvent(upPotentBtn, function()
        local potentLevel = 1
        if self._teamData.pl and self._teamData.pl[tostring(self._seniorNum)] then
            potentLevel = self._teamData.pl[tostring(self._seniorNum)] + 1
        end
        if potentLevel > TeamUtils.hPotentialStar then
            potentLevel = TeamUtils.hPotentialStar
            self._viewMgr:showTip("已达当前最大等级")
            return
        end
        local potentialTab = tab:Potential(potentLevel)
        if userData.gold < potentialTab.gold then
            DialogUtils.showLackRes()
        elseif (potentialTab.goodsNum or 100) > sameSoulCount then
            self._viewMgr:showTip(lang("TIPS_BINGTUAN_09"))
        else
            self:upPotential(self._seniorNum)
        end
    end)
end

function TeamUpStarNode:updatePrimaryStar()
    local itemModel = self._modelMgr:getModel("ItemModel")
    local teamId = self._teamData.teamId or 3201
    local sysTeam = tab:Team(teamId)
    local sameSouls, sameSoulCount = itemModel:getItemsById(sysTeam.goods)
    -- local sameSouls, sameSoulCount = itemModel:getItemsById(sysTeam.goods)
    local hunNum = self:getUI("bg.hunBg.hunNum")
    hunNum:setColor(UIUtils.colorTable.ccUIBaseColor1)
    -- hunNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
    hunNum:setString(sameSoulCount)

    local teamModel = self._modelMgr:getModel("TeamModel")
    
    local smallStar1 = teamModel:getSmallStar(self._teamData)
    local tempSmallStar = (self._teamData.smallStar - (self._teamData.star - 1) * 10)


-- 根据阵营设置星位置以及背景图
    local race = tab:Race(sysTeam["race"][1])

    -- local starBg = self._Panel_35:getChildByName("starBg")
    -- if not starBg then
    --     starBg = ccui.ImageView:create()
    --     starBg:setName("starBg")
    --     self._Panel_35:addChild(starBg, -1)
    -- end
    local starBg = self:getChildByName("starBg")
    if not starBg then
        starBg = ccui.ImageView:create()
        starBg:setName("starBg")
        starBg:setAnchorPoint(cc.p(0.5,0.5))
        starBg:setPosition(cc.p(184,218))
        self:addChild(starBg, -1)
    end
    starBg:setVisible(true)
    starBg:loadTexture("asset/uiother/race/race_" .. race.pic .. ".png")
    -- starBg:loadTexture("asset/uiother/race/race_bg_" .. race.pic .. ".jpg")
    -- starBg:setPosition(cc.p(race.positon[1],race.positon[2]))

    for i=1,10 do
        local posX = race.star[i][1]
        local posY = race.star[i][2]
        self._smallStar[i]:setPosition(cc.p(posX,posY))
    end

    if smallStar1 == 11 then 
        self._upStar:setTitleText("升星")
        self._upStar:setPositionX(180)
        self._oneUpStar:setVisible(false)
        self:getUI("bg.Label_24"):setVisible(false)
        self:getUI("bg.Image_129_0"):setVisible(false)
        self:getUI("bg.splice_img"):setVisible(false)
    else
        self._upStar:setPositionX(100)
        self._upStar:setTitleText("激活")
        self._oneUpStar:setVisible(true)
        self._oneUpStar:setPositionX(250)
        self:getUI("bg.Label_24"):setVisible(true)
        self:getUI("bg.Image_129_0"):setVisible(true)
        self:getUI("bg.splice_img"):setVisible(true)
    end
    
    self._checkShanShuo = false
    local touchBtn = self._upStar:isTouchEnabled()

    if self._teamData.star >= 6 then
        -- print("按钮不可见")
        self._maxStar:setVisible(true)
        self._upStar:setVisible(false)
        self._oneUpStar:setVisible(false)
        self:getUI("bg.Label_24"):setVisible(false)
        self:getUI("bg.Image_129_0"):setVisible(false)
        self:getUI("bg.splice_img"):setVisible(false)
        self:registerClickEvent(self._upStar, function()
            self._viewMgr:showTip(lang("TIPS_BINGTUAN_12"))
        end)
        self:registerClickEvent(self._oneUpStar, function()
            self._viewMgr:showTip(lang("TIPS_BINGTUAN_12"))
        end)
        
    else
        self._maxStar:setVisible(false)
        self._upStar:setVisible(true)
        self._oneUpStar:setVisible(true)
        if sameSoulCount >= tab:Star(self._teamData.star).cost then
            self._checkShanShuo = true
        end
    end

    if self._isNeedShowBigStar == true then
        self:setBigStar(self._teamData.star)
    else
        self._isNeedShowBigStar = true
    end

    if self._teamData.star == 6 then
        for i=1,10 do
            self:setSmallStar(i, 3)
        end
    else
        for i=1,10 do
            if i < smallStar1 then
                self:setSmallStar(i, 3)
            elseif i == smallStar1 then
                self:setSmallStar(i, 2)
            elseif i > smallStar1 then
                self:setSmallStar(i, 1)
            end
        end
    end
    local anim = self._upStar:getChildByName("anim")
    local anim1 = self._oneUpStar:getChildByName("anim")
    if smallStar1 > 10 then
        -- self:setBigStar(self._teamData.star)
        self._oneUpStar:setVisible(false)
        anim:setVisible(true)
        self:registerClickEvent(self._upStar, function()
            -- self:setUpMaxStar1()
            self:upgradeMaxStar()
        end)            
    else
        -- self._viewMgr:showTip("点亮所有节点兵团可升星")
        if (tab:Star(self._teamData.star).cost or 100) <= sameSoulCount then
            anim:setVisible(true)
            anim1:setVisible(true)
            self:registerClickEvent(self._upStar, function()
                self:upgradeStar(smallStar1)
            end)   
            self:registerClickEvent(self._oneUpStar, function()
                self:oneupgradeStar(smallStar1, 1)
            end)    
        else
            anim:setVisible(false)
            anim1:setVisible(false)
            self:registerClickEvent(self._upStar, function()
                self._viewMgr:showTip(lang("TIPS_BINGTUAN_09"))
            end)    
            self:registerClickEvent(self._oneUpStar, function()
                self._viewMgr:showTip(lang("TIPS_BINGTUAN_09"))
            end)    
        end
    end
    print("=touchBtn======", touchBtn)
    self._upStar:setTouchEnabled(touchBtn)
    self:registerClickEvent(self._addHun, function()
        self._viewMgr:showDialog("bag.DialogAccessTo", {goodsId = sysTeam.goods}, true)
    end)
    self:registerClickEvent(self._addHun1, function()
        self._viewMgr:showDialog("bag.DialogAccessTo", {goodsId = sysTeam.goods}, true)
    end)
end

-- 星星连接线
function TeamUpStarNode:updateLianjiexian(index, posX, posY, pos2)
    local bg = self:getUI("bg.Panel_35")
    local liuguang = bg:getChildByFullName("liuguang" .. index)
    if not liuguang then
        liuguang = mcMgr:createViewMC("shengxinglianjiexian_teamshengxinglianjiexian", true, false)
        liuguang:setName("liuguang" .. index)
        liuguang:setCascadeOpacityEnabled(true, true)
        -- liuguang:setPosition(cc.p(100,100))
        -- 60
        -- liuguang:setScale(2,1)
        liuguang:setOpacity(60)
        -- liuguang:setRotation(-20)
        bg:addChild(liuguang)
    end
    -- print(index, posX, posY, pos2.x, pos2.y)
    local dis = math.sqrt((pos2.x-posX)*(pos2.x-posX)+(pos2.y-posY)*(pos2.y-posY))
    local angle = -1 * math.deg(math.asin((pos2.y - posY) / dis))  -- math.deg(math.atan((posX-pos2.x)/(posY-pos2.y))) 
    if pos2.x-posX < 0 then
        angle = -1*angle - 180
    end

    liuguang:setPosition(cc.p(posX, posY))
    liuguang:setScale(dis/60,1)
    liuguang:setOpacity(60)
    liuguang:setRotation(angle)
    -- print ("==index========", index, dis, dis/60, angle)

end



-- 设置大星个数
function TeamUpStarNode:setBigStar(bigStarNum)
    -- print("&&&&&&&&&&&&&",#self._bigStar,bigStarNum)
    if self._isNeedShowBigStar == false then
        bigStarNum = bigStarNum - 1
        self._isNeedShowBigStar = true
    end
    -- if #self._bigStar >= bigStarNum then
    --     for i=1,6 do
    --         if i<=bigStarNum then
    --             self._bigStar[i]:setVisible(true)
    --             -- self._bigStar[i]:loadTexture("star_4.png", 1)
    --         else
    --             self._bigStar[i]:setVisible(false)
    --             -- self._bigStar[i]:loadTexture("star1.png", 1)
    --         end
    --     end
    -- end
    
end

-- 三种升星状态
function TeamUpStarNode:upStarStage(smallStarId,stage)
    -- local setLiuGuang = function(flag)
    --     local bg = self:getUI("bg.Panel_35")
    --     -- pubuClip:setPosition(200,130)
    --     if self._smallStar[smallStarId].liuguang then
    --         self._smallStar[smallStarId].liuguang:setVisible(true)
    --     else
    --         local liuguangClip = cc.ClippingNode:create()
    --         local liuguangMask = cc.Sprite:createWithSpriteFrameName("teamImageUI_img7.png")
    --         local mc = mcMgr:createViewMC("aocaoliuguang_qianghua", true, false, function (_, sender)

    --         end)
    --         liuguangClip:addChild(mc)
    --         liuguangClip:setInverted(false)
    --         liuguangClip:setStencil(liuguangMask)
    --         liuguangClip:setAlphaThreshold(0.05)
    --         liuguangClip:setAnchorPoint(cc.p(0.5,1))
    --         self._smallStar[smallStarId].liuguang = liuguangClip
    --         self._smallStar[smallStarId].liuguang:setScaleX(liuPos[smallStarId].scaleX)
    --         self._smallStar[smallStarId].liuguang:setRotation(liuPos[smallStarId].angle)
    --         self._smallStar[smallStarId].liuguang:setPosition(cc.p(liuPos[smallStarId].posX,liuPos[smallStarId].posY))
    --         bg:addChild(self._smallStar[smallStarId].liuguang,1)
    --     end
    --     -- 遮罩移动
    --     if flag == true then
    --         local liuguangMask = self._smallStar[smallStarId].liuguang:getStencil()
    --         liuguangMask:setPositionX(-80)
    --         local moveZhezhao = cc.MoveBy:create(0.2,cc.p(80,0))
    --         liuguangMask:runAction(moveZhezhao)
    --     end
    -- end
    local setBaozha = function(startype)
        local panel = self:getUI("bg.Panel_35")
        local sysTeam = tab:Team(self._teamData.teamId) or 3201
        local race = tab:Race(sysTeam["race"][1])
        local posX = race.star[smallStarId][1]
        local posY = race.star[smallStarId][2]
        local shengxingAnim = "bingtuanshengxing1_qianghua"
        if startype == 5 or startype == 10 then
            shengxingAnim = "bingtuanshengxing2_qianghua"
        end
        local mc2 = mcMgr:createViewMC(shengxingAnim, false, true, function (_, sender)

        end)
        mc2:setPosition(cc.p(posX,posY))
        -- mc2:setPlaySpeed(2)
        -- self._smallStar[smallStarId]:setZOrder(100)
        panel:addChild(mc2,100) 
    end

    local setOneBaozha = function(startype)
        local panel = self:getUI("bg.Panel_35")
        local sysTeam = tab:Team(self._teamData.teamId) or 3201
        local race = tab:Race(sysTeam["race"][1])
        local posX = race.star[smallStarId][1]
        local posY = race.star[smallStarId][2]
        local shengxingAnim = "xiaoshi_qianghua"
        if startype == 5 or startype == 10 then
            shengxingAnim = "xiaoshi_qianghua"
        end
        local mc2 = mcMgr:createViewMC(shengxingAnim, false, true, function (_, sender)

        end)
        mc2:setPosition(cc.p(posX,posY))
        -- mc2:setPlaySpeed(2)
        -- self._smallStar[smallStarId]:setZOrder(100)
        panel:addChild(mc2,100) 
    end

    -- local mc1 -- 流光
    -- local mc2 -- 烟花爆炸
    -- local mc3 -- 星星光效
    -- local mc4
    if self._smallStar[smallStarId] then
        self._smallStar[smallStarId].clickStar = self._smallStar[smallStarId]:getChildByFullName("Image_109")
        self._smallStar[smallStarId].haveStar = self._smallStar[smallStarId]:getChildByFullName("Image_24")

        if stage == 1 then
            if self._smallStar[smallStarId].smallStarAnim then
                self._smallStar[smallStarId].smallStarAnim:setVisible(false)
            end
            if self._smallStar[smallStarId].upSmallStarHint then
                self._smallStar[smallStarId].upSmallStarHint:setVisible(false)
            end
            -- if self._smallStar[smallStarId].liuguang then
            --     self._smallStar[smallStarId].liuguang:setVisible(false)
            -- end
        elseif stage == 2 then  -- 闪烁
            -- print("consumeLab ===================================")
            if self._smallStar[smallStarId].upSmallStarHint then
                self._smallStar[smallStarId].upSmallStarHint:setVisible(true)
                if self._smallStar[smallStarId].smallStarAnim then
                    self._smallStar[smallStarId].smallStarAnim:setVisible(false)
                end
            else
                self._smallStar[smallStarId].upSmallStarHint = mcMgr:createViewMC("kejihuotishi_qianghua", true, false)
                self._smallStar[smallStarId].upSmallStarHint:setName("anim1")
                self._smallStar[smallStarId].upSmallStarHint:setPosition(cc.p(21,23))
                self._smallStar[smallStarId]:addChild(self._smallStar[smallStarId].upSmallStarHint,4)
            end
        elseif stage == 3 then -- 星动画 
            if self._smallStar[smallStarId].smallStarAnim then
                self._smallStar[smallStarId].smallStarAnim:setVisible(true)
                if self._smallStar[smallStarId].upSmallStarHint then
                    self._smallStar[smallStarId].upSmallStarHint:setVisible(false)
                end
            else
                self._smallStar[smallStarId].smallStarAnim = mcMgr:createViewMC("xingguangxiao_qianghua", true, false)
                self._smallStar[smallStarId].smallStarAnim:setName("anim3")
                self._smallStar[smallStarId].smallStarAnim:setPosition(cc.p(13,13))
                self._smallStar[smallStarId].haveStar:addChild(self._smallStar[smallStarId].smallStarAnim,4)
            end
            -- if smallStarId > 1 then
            --     if self._smallStar[smallStarId].liuguang then
            --         self._smallStar[smallStarId].liuguang:setVisible(true)
            --     else
            --         -- setLiuGuang(false)
            --     end
            -- end
        elseif stage == 4 then -- 激活动画  
            local execute3 = cc.CallFunc:create(function()
                self:upStarStage(self._biaojiSmallStar,3)
                if self._biaojiSmallStar ~= 0 then
                    if self._smallStar[self._biaojiSmallStar].haveStar.setVisible then
                        self._smallStar[self._biaojiSmallStar].haveStar:setVisible(true)
                    end
                end
                self._upStar:setTouchEnabled(true)
                self._biaojiSmallStar = 0
            end)

            if smallStarId == 1 then
                setBaozha(smallStarId)
                -- self:upgradeStar()
                local seq = cc.Sequence:create(cc.DelayTime:create(0.8) ,execute3)
                self:runAction(seq)
            else
                -- local execute1 = cc.CallFunc:create(function()
                --     setLiuGuang(true)
                -- end)
                local execute2 = cc.CallFunc:create(function()
                    setBaozha(smallStarId)
                    -- self:upgradeStar()
                end)

                local seq = cc.Sequence:create(execute2, cc.DelayTime:create(0.5) ,execute3)
                self:runAction(seq)
            end

        elseif stage == 5 then -- 激活动画  
            setOneBaozha(smallStarId)
        end
    end
end

-- --按钮动画
-- function TeamSkillUpdateView:animBegin()

--     local updateBtn = self:getUI("bg.Panel_10.updateBtn")
    -- local mc1 = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true, false, function (_, sender)
    --     sender:gotoAndPlay(80)
    -- end)
--     mc1:setName("anim1")
--     mc1:setPosition(77, 30)
--     updateBtn:addChild(mc1, 1)
--     mc1:setVisible(false)
-- end

function TeamUpStarNode:setUpMaxStar1()
    self._viewMgr:lock(-1)
    local bg = self:getUI("bg.Panel_35")
    local callback1 = cc.CallFunc:create(function()
        if self._teamData.star == 6 then
            return
        end
        for i=1,10 do
            local mc2 = mcMgr:createViewMC("xiaoshi_qianghua", false, true)
            self:setSmallStar(i,1)
            mc2:setPosition(cc.p(21,23))
            self._smallStar[i]:addChild(mc2,10)
        end
    end)

    local callback3 = cc.CallFunc:create(function()
        local panel = self:getUI("bg.Panel_35")
        local sysTeam = tab:Team(self._teamData.teamId) or 3201
        local race = tab:Race(sysTeam["race"][1])
        for i=1,10 do
            local mc3 = mcMgr:createViewMC("juxing1_qianghua", false, false)
            local posX = race.star[i][1]
            local posY = race.star[i][2]
            mc3:setPosition(cc.p(posX, posY))
            panel:addChild(mc3,5)
            local posX1 = 185
            local posY1 = 115
            mc3:runAction(cc.Sequence:create(cc.MoveTo:create(0.5, cc.p(posX1, posY1)),cc.DelayTime:create(0.05),cc.RemoveSelf:create(true)))
        end
    end)

    local callback2 = cc.CallFunc:create(function()
        local tpx, tpy = 180, 113
        local tlength = 0
        local tempmcBg = ccui.ImageView:create() -- cc.Sprite:createWithSpriteFrameName("activityPanel_bg1.png")
        tempmcBg:loadTexture("globalImageUI6_meiyoutu.png", 1)
        tempmcBg:setPosition(tpx,tpy)
        bg:addChild(tempmcBg, 2)

        local mc3 = mcMgr:createViewMC("xingxingtou_qianghua", true, false)
        mc3:setCascadeOpacityEnabled(true)
        local pos2 = bg:convertToNodeSpace(cc.p(self._bigStarPos[self._teamData.star].posX, self._bigStarPos[self._teamData.star].posY)) 

        local angle = math.deg(math.atan((math.abs(pos2.y-tpy))/(math.abs(pos2.x-tpx))))
        tempmcBg:addChild(mc3, 20)

        local yiba = mcMgr:createViewMC("xingxingwei_qianghua", true, false)
        yiba:setAnchorPoint(cc.p(0.5, 0))
        yiba:setRotation(angle)
        yiba:setCascadeOpacityEnabled(true)
        yiba:setScaleX(0)
        tempmcBg:addChild(yiba, -1)
        local yibaSeq = cc.Sequence:create(cc.DelayTime:create(0.2), cc.ScaleTo:create(0.15, 1, 1), cc.FadeOut:create(0.3))
        yiba:runAction(yibaSeq)
        
        local dis = cc.pGetDistance(cc.p(pos2.x, pos2.y),cc.p(tpx, tpy))
        local pos3 = {}
        pos3.y = pos2.y-tpy-(tlength*(pos2.y-tpy))/dis
        pos3.x = pos2.x-tpx-(tlength*(pos2.x-tpx))/dis
        -- local dis1 = math.sqrt(pos3.x*pos3.x + pos3.y*pos3.y)
        -- print ("dis ====================", dis, dis1)
         -- cc.p(0,0)) -- cc.p(pos3.x,pos3.y)) -- cc.p(165 - pos2.x, pos2.y - 103))
        -- local moveSp = cc.MoveBy:create(0.5, cc.p(moveFeiGuang[self._teamData.star].posX, moveFeiGuang[self._teamData.star].posY)) -- cc.p(0,0)) -- cc.p(pos3.x,pos3.y)) -- cc.p(165 - pos2.x, pos2.y - 103))
        local callback3 = cc.CallFunc:create(function()
            local teamModel = self._modelMgr:getModel("TeamModel")
            local backTeamData,tempTeamIndex = teamModel:getTeamAndIndexById(self._teamData.teamId)
            teamModel:setBigStar(false)
            self._setBigStarCallBack(backTeamData.star)

            local mc4 = mcMgr:createViewMC("xiaoshi_qianghua", false, true, function (_, sender)
                -- local teamModel = self._modelMgr:getModel("TeamModel")
                -- local backTeamData,tempTeamIndex = teamModel:getTeamAndIndexById(self._teamData.teamId)
            end)
            mc4:setPosition(cc.p(pos2.x,pos2.y))
            bg:addChild(mc4)

            self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function()
                -- teamModel:setBigStar(false)
                -- self._setBigStarCallBack(backTeamData.star)
                local tempTeamData = {}
                tempTeamData.old = self._oldTeamData
                tempTeamData.new = backTeamData
                local teamUpStarSuccessView = self._viewMgr:showDialog("team.TeamUpStarSuccessView",tempTeamData,true) 
                self._oldTeamData = nil
                self._viewMgr:unlock()
            end)))
        end)
        
        local rota1 = cc.ScaleTo:create(0.1, 2)
        local spawn2 = cc.Spawn:create(cc.ScaleTo:create(0.1, 1), cc.RotateBy:create(0.1, 80))
        local rota2 = cc.RotateBy:create(0.2, 66)
        local seq1 = cc.Sequence:create(rota1,spawn2,rota2,cc.FadeTo:create(0.2, 0))
        mc3:runAction(seq1)

        local moveSp = cc.MoveBy:create(0.2, cc.p(pos3.x, pos3.y))
        local seq = cc.Sequence:create(cc.DelayTime:create(0.2),moveSp,callback3, cc.DelayTime:create(0.4), cc.RemoveSelf:create(true))
        tempmcBg:runAction(seq)
    end)

    local seq = cc.Sequence:create(callback1,callback3,cc.DelayTime:create(0.55), callback2)
    self:runAction(seq)
    
end


--[[
stage：三种状态
1，没有升星
2，正在升星
3，升星完成
--]]
function TeamUpStarNode:setSmallStar(smallStarId,stage)
    if self._smallStar[smallStarId] then
        self._smallStar[smallStarId]:setLocalZOrder(1)
        -- self._smallStar[smallStarId].noStar = self._smallStar[smallStarId]:getChildByFullName("Image_364")
        self._smallStar[smallStarId].clickStar = self._smallStar[smallStarId]:getChildByFullName("Image_109")
        self._smallStar[smallStarId].haveStar = self._smallStar[smallStarId]:getChildByFullName("Image_24")
        -- self._smallStar[smallStarId].clickStar = self._smallStar[smallStarId]:getChildByFullName("Button_237")
        -- self._smallStar[smallStarId].haveStar = self._smallStar[smallStarId]:getChildByFullName("Image_26")
        if stage == 1 then
            -- self._smallStar[smallStarId].noStar:setVisible(false)            
            self._smallStar[smallStarId].clickStar:setVisible(false)            
            self._smallStar[smallStarId].haveStar:setVisible(false)
            self:upStarStage(smallStarId,1)
            -- self:registerClickEvent(self._smallStar[smallStarId], function()

            -- end)
        elseif stage == 2 then
            self._smallStar[smallStarId]:setLocalZOrder(10)
            -- self._smallStar[smallStarId].noStar:setVisible(false)            
            self._smallStar[smallStarId].clickStar:setVisible(true) 
            -- self._smallStar[smallStarId].clickStar:setBright(false)            
            self._smallStar[smallStarId].haveStar:setVisible(false)
            self:upStarStage(smallStarId,1)

            local consumeLab = self:getUI("bg.Label_24")
            str = tab:Star(self._teamData.star).cost
            consumeLab:setString(str)
            local img = self:getUI("bg.Image_129_0")
            if self._checkShanShuo == true then
                self:upStarStage(smallStarId,2)
                self._checkShanShuo = false
                consumeLab:setColor(UIUtils.colorTable.ccUITabColor2)
            else
                consumeLab:setColor(UIUtils.colorTable.ccUIBaseColor6)
            end
            
            local tempLab = self._smallStar[smallStarId].clickStar:getChildByFullName("Label_28")            
            -- tempLab:setFontName(UIUtils.ttfName)
            
            local tempData = tab:Team(self._teamData.teamId).smallstaradd[(self._teamData.smallStar + 1)]
            local str = lang("ATTR_" .. tempData[1]) or "攻击"
            tempLab:setString(str)
            local tempValue = self._smallStar[smallStarId].clickStar:getChildByFullName("Label_29")
            tempValue:setColor(UIUtils.colorTable.ccColorQuality2)
            tempValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            str = "+" .. TeamUtils.getNatureNums(tempData[2] or 100) -- string.format("+%.1f", tempData[2] or "100") -- "+" .. tempData[2] or "100"
            -- if tempData[1] == 4 then
            --     str = string.format("+%d", tempData[2] or "100")
            -- end
            -- tempLab:disableEffect()
            -- tempValue:disableEffect()
            tempLab:setFontSize(20)
            tempLab:setColor(cc.c3b(182,180,176))
            tempLab:enableOutline(cc.c4b(108,48,0,255), 1)

            tempValue:setString(str)            
            tempValue:setFontSize(20)
            tempValue:setColor(cc.c3b(182,180,176))
            tempValue:enableOutline(cc.c4b(108,48,0,255), 1)
            -- tempLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
            -- tempLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

            -- self._smallStar[smallStarId].clickStar:loadTexture("teamImageUI_bg19.png", 1)
            local tempPosX = (self._smallStar[smallStarId].clickStar:getContentSize().width - tempLab:getContentSize().width - tempValue:getContentSize().width)/2
            tempLab:setPositionX(tempPosX)
            tempValue:setPositionX(tempLab:getPositionX()+tempLab:getContentSize().width)

            local itemModel = self._modelMgr:getModel("ItemModel")
            local sysTeam = tab:Team(self._teamData.teamId) or 3201
            local sameSouls, sameSoulCount = itemModel:getItemsById(sysTeam.goods)
            -- print(tab:Star(self._teamData.star).cost,sameSoulCount)
            -- self:registerClickEvent(self._smallStar[smallStarId], function()
            --     if tab:Star(self._teamData.star).cost <= sameSoulCount then
            --         self:upStarStage(smallStarId,4)
            --         self:upgradeStar(smallStarId)
            --     else
            --         self._viewMgr:showTip(lang("TIPS_BINGTUAN_09"))
            --     end
            -- end)

        elseif stage == 3 then
            -- self._smallStar[smallStarId].noStar:setVisible(false)            
            self._smallStar[smallStarId].clickStar:setVisible(true) 
            -- self._smallStar[smallStarId].clickStar:setBright(true)           
            
            self:upStarStage(smallStarId,1)
            if self._biaojiSmallStar and self._biaojiSmallStar == smallStarId then
                -- self:upStarStage(smallStarId,3)
            else
                self:upStarStage(smallStarId,3)
                self._smallStar[smallStarId].haveStar:setVisible(true)
            end
            
            -- self:registerClickEvent(self._smallStar[smallStarId], function()

            -- end)
            -- self._smallStar[smallStarId].clickStar:loadTexture("teamImageUI_bg18.png", 1)
            local tempLab = self._smallStar[smallStarId].clickStar:getChildByFullName("Label_28")
            tempLab:disableEffect()
            local tempId 
            if self._teamData.star == 6 then
                tempId = (smallStarId + (self._teamData.star - 2) * 10)
            else
                tempId = (smallStarId + (self._teamData.star - 1) * 10)
            end
            local tempData = tab:Team(self._teamData.teamId).smallstaradd[tempId]
            -- print(tempData,"&&&&&&&&&&", self._teamData.teamId,(smallStarId + (self._teamData.star - 1) * 10))
            local str = lang("ATTR_" .. tempData[1]) or "攻击力"
            tempLab:setString(str)
            local tempValue = self._smallStar[smallStarId].clickStar:getChildByFullName("Label_29")
            str = "+" .. TeamUtils.getNatureNums(tempData[2] or 100) --string.format("+%.1f", tempData[2] or "100") -- "+" .. tempData[2] or "100"
            -- if tempData[1] == 4 then
            --     str = string.format("+%d", tempData[2] or "100")
            -- end
            tempValue:setString(str)
            if smallStarId == 5 or smallStarId == 10 then
                tempLab:setColor(cc.c3b(254,229,178))
                tempLab:enableOutline(cc.c4b(108,48,0,255), 1)
                tempLab:setFontSize(20)
            else
                tempLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
                tempLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
                tempLab:setFontSize(20)
            end
            tempValue:setColor(UIUtils.colorTable.ccColorQuality2)
            tempValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            tempValue:setFontSize(20)
            local tempPosX = (self._smallStar[smallStarId].clickStar:getContentSize().width - tempLab:getContentSize().width - tempValue:getContentSize().width)/2
            tempLab:setPositionX(tempPosX)
            tempValue:setPositionX(tempLab:getPositionX()+tempLab:getContentSize().width)

            -- str = "[color=fee5b2]" .. str .. tempData[2] .. "[-]" --  "消耗:" .. tab:Star(self._teamData.star).cost .. "魂石"
            -- if self._smallStar[smallStarId].richLab ~= nil then
            --     self._smallStar[smallStarId].richLab:removeFromParent()
            -- end
            -- self._smallStar[smallStarId].richLab = RichTextFactory:create(str, 100, 25)
            -- self._smallStar[smallStarId].richLab:setAnchorPoint(cc.p(0.2,0))     
            -- self._smallStar[smallStarId].clickStar:addChild(self._smallStar[smallStarId].richLab,7)
            -- -- local tempPos = (self._smallStar[smallStarId].clickStar:getContentSize().width - self._richText:getContentSize().width)/2
            -- self._smallStar[smallStarId].richLab:setPosition(0,3)

            --给richtext添加描边
            -- local tips1 = {}
            -- tips1[1] = cc.Label:createWithTTF("生命 ", UIUtils.ttfName, 20)
            -- tips1[1]:setColor(UIUtils.colorTable.ccColor1)
            -- tips1[2] = cc.Label:createWithTTF("11", UIUtils.ttfName, 20)
            -- tips1[2]:setColor(UIUtils.colorTable.ccColor1)

            -- local nodeTip1 = UIUtils:createHorizontalNode(tips1)
            -- nodeTip1:setAnchorPoint(cc.p(0.5, 0.5))
            -- nodeTip1:setPosition(rewardBg:getContentSize().width/2,rewardBg:getContentSize().height/2)
            -- rewardBg:addChild(nodeTip1)

        end

    end
end


-- 升小星
function TeamUpStarNode:oneupgradeStar(smallStarId)
    print("===============", smallStarId, inBatch)
    self._oldTeamData = copyTab(self._teamData)
    local param = {teamId = self._teamData.teamId, batch = 1}
    self._viewMgr:lock(-1)
    self._oldFight = TeamUtils:updateFightNum()
    self._serverMgr:sendMsg("TeamServer", "upgradeStar", param, true, {}, function (result)
        -- print("升级小星星",smallStarId)
        -- self._viewMgr:showTip("升星成功")
        self:oneupgradeStarFinish(result)
    end)
end

function TeamUpStarNode:oneupgradeStarFinish(result)
    if result["d"] == nil then 
        return 
    end
    local tempTeam,_ = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(self._teamData.teamId)
    local begStarNum = math.fmod(self._oldTeamData.smallStar, 10) + 1 
    local endStarNum = math.fmod(tempTeam.smallStar, 10) 
    if endStarNum == 0 then
        endStarNum = 10
    end
    if endStarNum == 10 then
        -- print("达到10个小星  ==============")
        GuideUtils.checkTriggerByType("action", "5")
    end
    for i=begStarNum,endStarNum do
        self:upStarStage(i, 5)
    end
    self._fightCallback({newFight = tempTeam.score, oldFight = self._oldTeamData.score})

    local fightBg = self:getUI("bg")
    TeamUtils:setFightAnim(fightBg, {oldFight = self._oldFight, newFight = TeamUtils:updateFightNum(), x = -200, y = fightBg:getContentSize().height - 110})

    -- local teamModel = self._modelMgr:getModel("TeamModel")

    -- local tempTeamData,tempTeamIndex = teamModel:getTeamAndIndexById(self._teamData.teamId)
    -- self:reflashUI({teamData = tempTeamData, equipId = self._curSelectIndex})
    -- self:reflashUI(tempTeamData)
    audioMgr:playSound("Advance")
    self._viewMgr:unlock()
end

-- 升小星
function TeamUpStarNode:upgradeStar(smallStarId)
    self._oldTeamData = copyTab(self._teamData)
    local param = {teamId = self._teamData.teamId}
    if smallStarId == 10 then
        -- print("达到10个小星  ==============")
        GuideUtils.checkTriggerByType("action", "5")
    end
    self._viewMgr:lock(-1)
    self._oldFight = TeamUtils:updateFightNum()
    self._serverMgr:sendMsg("TeamServer", "upgradeStar", param, true, {}, function (result)
        -- print("升级小星星",smallStarId)
        self._biaojiSmallStar = smallStarId
        self._upStar:setTouchEnabled(false)
        self:upStarStage(smallStarId,4)
        -- self._viewMgr:showTip("升星成功")
        self:upgradeStarFinish(result)
    end)
end

function TeamUpStarNode:upgradeStarFinish(result)
    if result["d"] == nil then 
        return 
    end
    local tempTeam,_ = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(self._teamData.teamId)
    self._fightCallback({newFight = tempTeam.score, oldFight = self._oldTeamData.score})

    local fightBg = self:getUI("bg")
    TeamUtils:setFightAnim(fightBg, {oldFight = self._oldFight, newFight = TeamUtils:updateFightNum(), x = -200, y = fightBg:getContentSize().height - 110})

    -- local teamModel = self._modelMgr:getModel("TeamModel")

    -- local tempTeamData,tempTeamIndex = teamModel:getTeamAndIndexById(self._teamData.teamId)
    -- self:reflashUI({teamData = tempTeamData, equipId = self._curSelectIndex})
    -- self:reflashUI(tempTeamData)
    audioMgr:playSound("Advance")
    self._viewMgr:unlock()
end

-- 升大星
function TeamUpStarNode:upgradeMaxStar()
    self._modelMgr:getModel("TeamModel"):setBigStar(true)
    self._oldTeamData = copyTab(self._teamData)
    local param = {teamId = self._teamData.teamId}
    self._oldFight = TeamUtils:updateFightNum()
    self._serverMgr:sendMsg("TeamServer", "upgradeMaxStar", param, true, {}, function (result)
        self:upgradeMaxStarFinish(result)
    end)
end

function TeamUpStarNode:upgradeMaxStarFinish(result)
    if result["d"] == nil then 
        return 
    end
    local fightBg = self:getUI("bg")
    TeamUtils:setFightAnim(fightBg, {oldFight = self._oldFight, newFight = TeamUtils:updateFightNum(), x = -200, y = fightBg:getContentSize().height - 110})

    local tempTeam,_ = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(self._teamData.teamId)
    self._fightCallback({newFight = tempTeam.score, oldFight = self._oldTeamData.score})
    self._isNeedShowBigStar = false
    self:setUpMaxStar1()
    -- self:setUpMaxStar()
    audioMgr:playSound("StarUp")
    -- self._viewMgr:showTip("升星成功")

    -- local tempTeamData = {}
    -- local teamModel = self._modelMgr:getModel("TeamModel")
    -- local backTeamData,tempTeamIndex = teamModel:getTeamAndIndexById(self._teamData.teamId)
    -- tempTeamData.old = self._oldTeamData
    -- tempTeamData.new = backTeamData
    -- local teamUpStarSuccessView = self._viewMgr:showDialog("team.TeamUpStarSuccessView",tempTeamData,true) 
    -- self._oldTeamData = nil
    -- self._viewMgr:unlock()

end

-- 激活潜能
function TeamUpStarNode:activationPotential()
    self._oldTeamData = copyTab(self._teamData)
    local param = {teamId = self._teamData.teamId}
    self._viewMgr:lock(-1)
    self._oldFight = TeamUtils:updateFightNum()
    self._serverMgr:sendMsg("TeamServer", "activationPotential", param, true, {}, function (result)
        self:activationPotentialFinish(result)
    end)
end

function TeamUpStarNode:activationPotentialFinish(result)
    if result["d"] == nil then 
        return 
    end
    local tempTeam,_ = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(self._teamData.teamId)
    self._fightCallback({newFight = tempTeam.score, oldFight = self._oldTeamData.score})

    local fightBg = self:getUI("bg1")
    TeamUtils:setFightAnim(fightBg, {oldFight = self._oldFight, newFight = TeamUtils:updateFightNum(), x = -200, y = fightBg:getContentSize().height - 110})

    self._viewMgr:unlock()
    self._viewMgr:showDialog("team.TeamStarShowDialog", {teamId = self._teamData.teamId})
end

-- 升级潜能
function TeamUpStarNode:upPotential(potentialId)
    self._oldTeamData = copyTab(self._teamData)
    local param = {teamId = self._teamData.teamId, potentialId = potentialId}
    self._viewMgr:lock(-1)
    self._oldFight = TeamUtils:updateFightNum()
    self._serverMgr:sendMsg("TeamServer", "upPotential", param, true, {}, function (result)
        self:upPotentialFinish(result)
    end)
end

function TeamUpStarNode:upPotentialFinish(result)
    if result["d"] == nil then 
        return 
    end
    local tempTeam,_ = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(self._teamData.teamId)
    self._fightCallback({newFight = tempTeam.score, oldFight = self._oldTeamData.score})

    local fightBg = self:getUI("bg1")
    TeamUtils:setFightAnim(fightBg, {oldFight = self._oldFight, newFight = TeamUtils:updateFightNum(), x = -200, y = fightBg:getContentSize().height - 110})

    local hstar = self:getUI("bg1.panel.hstar" .. self._seniorNum)
    local mc1 = mcMgr:createViewMC("shengji_teamqianneng", false, true)
    mc1:setPosition(hstar:getContentSize().width*0.5, hstar:getContentSize().height*0.5)
    hstar:addChild(mc1, 100)

    local icon = self:getUI("bg1.panel.hstar" .. self._seniorNum .. ".icon")

    local callFunc1 = cc.CallFunc:create(function()
        icon:setBrightness(255)
    end)
    local callFunc2 = cc.CallFunc:create(function()
        icon:setBrightness(0)
    end)
    local seq = cc.Sequence:create(cc.DelayTime:create(0.4), callFunc1, cc.DelayTime:create(0.1), callFunc2)
    icon:runAction(seq)

    self:teamPiaoNature1()
    self._viewMgr:unlock()
end

function TeamUpStarNode.dtor()
    -- moveFeiGuang = nil
end


function TeamUpStarNode:teamPiaoNature1()
    local hstar = self:getUI("bg1.panel.hstar" .. self._seniorNum)
    local potentialAttrTab = tab:PotentialAttr(self._seniorNum)
    local attr = potentialAttrTab.attr
    local param = {}
    for i=1,2 do
        local data = attr[i][2]
        if i == 1 then
            param[i] = lang("ATTR_" .. attr[i][1]) .. "+" .. data .. "%"
        else
            param[i] = lang("ATTR_" .. attr[i][1]) .. "+" .. data .. "%"
        end
    end

    for i=1,2 do
        local natureLab = hstar:getChildByName("natureLab" .. i)
        if natureLab then
            natureLab:stopAllActions()
            natureLab:removeFromParent()
        end
        natureLab = cc.Label:createWithTTF(param[i], UIUtils.ttfName, 24)
        natureLab:setName("natureLab" .. i)
        natureLab:setColor(UIUtils.colorTable.ccColorQuality2)
        natureLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        natureLab:setPosition(cc.p(hstar:getContentSize().width*0.5, hstar:getContentSize().height*0.5-35*i - 15))
        natureLab:setOpacity(0)
        hstar:addChild(natureLab,100)

        local seqnature = cc.Sequence:create(cc.ScaleTo:create(0, 0.2), cc.DelayTime:create(0.2+0.1*i), 
            cc.Spawn:create(cc.ScaleTo:create(0.2, 1),cc.FadeIn:create(0.2),cc.MoveBy:create(0.2, cc.p(0,38))), 
            cc.MoveBy:create(0.38, cc.p(0,17)),
            cc.Spawn:create(cc.MoveBy:create(0.4, cc.p(0,10)),cc.FadeOut:create(0.7)),
            cc.RemoveSelf:create(true))
        natureLab:runAction(seqnature)
    end
end

function TeamUpStarNode:updateStarTip(_type)
    if not self._starTip then
        return
    end
    self._starTip:setVisible(true)
    local icon = self._starTip:getChildByFullName("icon")
    local frame = self._starTip:getChildByFullName("icon.frame")
    local name = self._starTip:getChildByFullName("name")
    local level = self._starTip:getChildByFullName("level")
    local tipDes = self._starTip:getChildByFullName("tipDes")

    local potentialAttrTab = tab:PotentialAttr(_type)

    local potentLevel = 0
    if self._teamData.pl and self._teamData.pl[tostring(_type)] then
        potentLevel = self._teamData.pl[tostring(_type)]
    end
    level:setString("Lv." .. potentLevel)

    icon:loadTexture(TeamUtils.hStarImg[_type], 1)
    frame:loadTexture(TeamUtils.frameStarImg[_type], 1)
    -- icon:loadTexture("teamImageUI_img" .. 47 + _type .. ".png", 1)
    name:setString(lang(potentialAttrTab.name))
    tipDes:setString(lang(potentialAttrTab.des))

    local attr = potentialAttrTab.attr
    for i=1,2 do
        local nature = self._starTip:getChildByFullName("nature" .. i)
        local natureValue = self._starTip:getChildByFullName("natureValue" .. i)
        nature:setString(lang("ATTR_" .. attr[i][1]))
        natureValue:setString("+" .. attr[i][2]*potentLevel  .. "%")
        natureValue:setPositionX(nature:getPositionX() + nature:getContentSize().width + 10)
    end
end
return TeamUpStarNode