--[[
    Filename:    PokedexView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2015-09-28 11:42:02
    Description: File description
--]]

local PokedexView = class("PokedexView", BaseView)
local pokedexMax = 15
function PokedexView:ctor(params)
    PokedexView.super.ctor(self)
    self._pokedex = {}
    self._isClick = false
    self._isScroll = false
end

function PokedexView:onInit()

    local closeBtn = self:getUI("closeBtn")
    closeBtn:setVisible(false)
    self:registerClickEvent(closeBtn, function()
        self:close()
    end)
    
    self._pokedexModel = self._modelMgr:getModel("PokedexModel")
    self._modelMgr:getModel("PokedexModel"):processData()
    self._tempTableOffsetX = -99999999
    self._tempTableOffsetX1 = self._tempTableOffsetX
    self._offsetxAnim = false
    self._pokedexSelect = 1
    local title = self:getUI("bg.title")
    -- local zongBg = self:getUI("bg.zongBg")

    -- local bg = self:getUI("bg")
    -- self._zongFight = cc.LabelBMFont:create("1", UIUtils.bmfName_team_fight)
    -- self._zongFight:setName("self._zongFight")
    -- self._zongFight:setAnchorPoint(cc.p(0.5,0.5))
    -- self._zongFight:setPosition(cc.p(480, 554))
    -- bg:addChild(self._zongFight, 1)
    -- self._zongFight:setVisible(false)

    self._scrollView = cc.ScrollView:create() 
    self._scrollView:setViewSize(cc.size(1136, 640))
    self._scrollView:setDirection(0) --设置滚动方向
    self._scrollView:setBounceable(true)
    -- self._scrollView:setAnchorPoint(cc.p(0.5,0.5))
    self._scrollView:setDelegate()
    self._scrollView:registerScriptHandler(function() return self:scrollViewDidScroll() end ,cc.SCROLLVIEW_SCRIPT_SCROLL)

    local bg = self:getUI("bg")
    if MAX_SCREEN_HEIGHT > 640 then
        self._scrollView:setAnchorPoint(cc.p(0,0))
    else
        self._scrollView:setAnchorPoint(cc.p(0,0.5))
    end
    self._scrollView:setPosition(cc.p((1136-MAX_SCREEN_WIDTH)*0.5,0))
    self._scrollView:setScale((MAX_SCREEN_WIDTH/1136) > 1.15 and 1.15 or (MAX_SCREEN_WIDTH/1136))
    bg:addChild(self._scrollView, 1)

    self._right = self:getUI("right")
    self._right:setLocalZOrder(2)
    local mc1 = mcMgr:createViewMC("tujianyoujiantou_teamnatureanim", true, false)
    mc1:setPosition(cc.p(self._right:getContentSize().width*0.5, self._right:getContentSize().height*0.5))
    self._right:addChild(mc1) 

    self._left = self:getUI("left")
    self._left:setLocalZOrder(2)
    local mc2 = mcMgr:createViewMC("tujianzuojiantou_teamnatureanim", true, false)
    mc2:setPosition(cc.p(self._left:getContentSize().width*0.5, self._left:getContentSize().height*0.5))
    self._left:addChild(mc2)


    -- self._scrollView:setVisible(false)
    self._pokedex = {}
    -- self._contentX = 480    

    local tempX = -90 -- MAX_SCREEN_WIDTH*0.5 - 200 -- 260 -- 330 -- 476
    local tmaxWidth = 90+220*pokedexMax
    self._scrollView:setContentSize(cc.size(tmaxWidth, 640))
    -- self._scrollView:setContentSize(cc.size(3160, 640))
    -- local tempX = 260 -- 330 -- 476
    for i=1,pokedexMax do
        -- local str = "tj_" .. i .. ".png"
        self._pokedex[i] = require("game.view.pokedex.PokedexCardNode").new() 
        self._pokedex[i]:setName("poke" .. i)
        self._pokedex[i]:reflashUI({indexId = i})
        -- self._pokedex[i]:
        self._pokedex[i]:setAnchorPoint(cc.p(0.5,0.5))
        self._pokedex[i]:setPosition(cc.p(tempX + 220*i, MAX_SCREEN_HEIGHT*0.5+20))
        self._scrollView:addChild(self._pokedex[i])
        -- testCell:setZOrder(self._pokedex[i]:getPositionX())
    end
    -- local childs = self._scrollView:getContainer():getChildren()
    -- for k,v in pairs(childs) do
    --     print(k,v)
    --     v:setName(str)
    -- end

    local teamModel = self._modelMgr:getModel("TeamModel")
    teamModel:refreshDataOrder()
    teamModel:initGetSysTeams()
    -- self:reflashUI(data)

    self._updateId = ScheduleMgr:regSchedule(1, self, function()
        self:update()
    end)
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            self:onExit()
        end
    end)
    local click = self:getUI("bg.click")

    local downX
    self._clickFlag = false

    self:setPokedexFormation()
    self:listenReflash("PokedexModel", self.setPokedex)
end

function PokedexView:setPokedexFormation()
    local pFormation = self._pokedexModel:getPFormation()
    self._userModel = self._modelMgr:getModel("UserModel")
    local userData = self._userModel:getData()
    local pfId = userData.pfId or 1
    local pfLab = self:getUI("organizeBg.pfBtn.pfLab")
    local pName = pFormation[tostring(pfId)]
    if (not pName) or pName == "" then
        pName = "图鉴编组" .. pfId
    end
    pfLab:setString(pName)

    local callback = function()
        self:setPokedexFormation()
    end

    local pfBtn = self:getUI("organizeBg.pfBtn")
    self:registerClickEvent(pfBtn, function()
        local pFormation = self._pokedexModel:getPFormation()
        self._modelMgr:getModel("FormationModel"):showFormationEditView({data = pFormation, isOnly = "pokedex", callback = callback})
    end)
    local changeName = self:getUI("organizeBg.changeName")
    self:registerClickEvent(changeName, function()
        UIUtils:reloadLuaFile("pokedex.PokedexCNameDialog")
        self._viewMgr:showDialog("pokedex.PokedexCNameDialog", {callback = callback})
    end)
    local addPokedexForm = self:getUI("organizeBg.addPokedexForm")
    self:registerClickEvent(addPokedexForm, function()
        self:sendUnlockMsg()
    end)
end


function PokedexView:sendUnlockMsg()
    -- 添加编组
    local pFormation = self._pokedexModel:getPFormation()
    local slotMaxNum = table.nums(tab.tujianjiesuo)
    local formNum
    for i=1,slotMaxNum do
        if not pFormation[tostring(i)] then
            formNum = i
            break
        end
    end

    print("formNum=========", formNum)
    if not formNum or formNum > slotMaxNum then
        self._viewMgr:showTip("编组已满")
        return 
    end
    local cost = tab:Tujianjiesuo(formNum).expend
    local costNum = cost[3]
    local gem = self._modelMgr:getModel("UserModel"):getData().gem 
    if gem < costNum then
        DialogUtils.showNeedCharge({desc = "钻石不足，是否前去充值",callback1=function( )
            -- print("充值去！")
            local viewMgr = ViewManager:getInstance()
            viewMgr:showView("vip.VipView", {viewType = 0})
        end})
        return
    end
    local descStr =  "[color=462800,fontsize=24]是否使用[pic=globalImageUI_littleDiamond.png][-][color=3d1f00,fontsize=24]" .. (costNum or 0) 
                    .. "[-][-]" .. "[color=462800,fontsize=24]".. "解锁图鉴编组" .. formNum .."[-]"
    self._viewMgr:showSelectDialog( descStr, "", function( )
            self._serverMgr:sendMsg("PokedexServer", "openPFormation", {}, true, { }, function(result)
                self:reflashUI()
            end)
        end, 
    "", nil)
end

function PokedexView:onExit()
    if self._updateId then
        ScheduleMgr:unregSchedule(self._updateId)
        self._updateId = nil
    end
end

function PokedexView:update()
    local offset = self._scrollView:getContentOffset() --getContentOffset()
    if self._tempTableOffsetX == offset.x then 
        if self._isScroll == false and not self._scrollView:isDragging() then
            self:scrollViewScroll()
        end
        return 
    end
    local childs = self._scrollView:getContainer():getChildren()
    if #childs <= 0 then 
        return
    end
    -- 110 是cell 高度 ，320 是table 高度/2
    -- local sca = 0
    self._tempTableOffsetX = offset.x
    local tempRank = {}
    local tempX, posIndex
    for k,v in pairs(childs) do
        local x,y = v:getPosition()
        local worldX = v:convertToWorldSpaceAR(cc.p(0,0)).x 
        if tonumber(k) == 1 then
            self._offsetX = worldX
        end
        
        local sca = 1/(1+0.0000008*(math.sqrt(math.pow((worldX-MAX_SCREEN_WIDTH*0.5),4))))
        -- print("sca ========",k, x, worldX, sca, sca*100)
        
        -- if v:getName() == self._scaleSelf then
        --     -- print("======", tonumber(k), self._scaleSelf, v:getName())
        --     sca = 0.9
        -- end
        v:setScale(sca)
        -- v:setZOrder(math.ceil(sca*100))
        -- v:setPositionX(sca)
    end

end

function PokedexView:scrollViewScroll()
    -- print("==========", view:getContentSize().width)
    if self._tempTableOffsetX == self._tempTableOffsetX1 or self._clickFlag == true then 
        self._scheduleSelector = false
        return 
    end
    self._tempTableOffsetX1 = self._tempTableOffsetX
    local childs = self._scrollView:getContainer():getChildren()
    if #childs <= 0 then 
        return
    end
    self._scrollView:stopScroll()
    -- 110 是cell 高度 ，320 是table 高度/2
    -- local tempRank = {}
    local posValue = 3000
    local posIndex, posOffset

    for k,v in pairs(childs) do
        -- local x,y = v:getPosition()
        local worldX = v:convertToWorldSpaceAR(cc.p(0,0)).x 
        -- local _x = self._pokedex[tonumber(k)]
        -- print("worldX ===", posValue, math.abs(worldX - MAX_SCREEN_WIDTH*0.5))
        if posValue >= math.abs(worldX - MAX_SCREEN_WIDTH*0.5) then
            posValue = math.abs(worldX - MAX_SCREEN_WIDTH*0.5)
            posOffset = worldX - MAX_SCREEN_WIDTH*0.5
            posIndex = tonumber(k)
        end
    end

    -- print("=====", self._scrollView:getContentOffset().x, posOffset, posIndex)
    if posIndex > pokedexMax - 2 then
        posOffset = -80
    elseif posIndex < 3  then
        posOffset = 80
    end
    if posOffset > 0 and posOffset < 1 then
        posOffset = 0
    end

    if self._offsetxAnim == false then
        self._scrollView:setContentOffset(cc.p(self._scrollView:getContentOffset().x - posOffset,0), false)
        self._offsetxAnim = true
        return
    end
    local scrollInner = self._scrollView:getContainer()
    local toffsetX = self._scrollView:getContentOffset().x - posOffset
    local move = cc.MoveTo:create(0.01, cc.p(toffsetX, 0))
    scrollInner:stopAllActions()
    scrollInner:runAction(move)
end


-- 判断是否滑动到结束
function PokedexView:scrollViewDidScroll()
    self._isClick = true

    local view = self._scrollView
    -- self._inScrolling = view:isDragging()
    local tempPos = view:getContentSize().width + view:getContainer():getPositionX()
    -- print("==============",self._offsetX, tempPos, view:getContainer():getPositionX(), view:getContentSize().width)
    if math.floor(self._offsetX+0.5) >= 128 then
        self._right:setVisible(true)
        self._left:setVisible(false)
    elseif math.floor(self._offsetX+0.5) <= -1192 then
        self._right:setVisible(false)
        self._left:setVisible(true)
    else
        self._right:setVisible(true)
        self._left:setVisible(true)
    end
end


function PokedexView:setPokedex()
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local pokedexData = self._modelMgr:getModel("PokedexModel"):getData()
    for i=1,pokedexMax do
        local level = tab:Tujian(i).level
        -- print((userData.lvl) , level)
        if tonumber(userData.lvl) >= level then
            -- print("self._pokedex[i]", i, self._pokedex[i], pokedexData[tostring(i)].fight)
            self._pokedex[i]:updateCell({type = 1, fight = math.ceil(pokedexData[tostring(i)].fight), pokedexData = pokedexData[tostring(i)]})

            if i <= table.nums(pokedexData) then
                if pokedexData[tostring(i)].onPokedex == true or pokedexData[tostring(i)].onUpgrade == true then
                    self._pokedex[i]:setTip(true)
                else
                    self._pokedex[i]:setTip(false)
                end
            else
                self._pokedex[i]:setTip(false)
            end
            self:registerClickEvent(self._pokedex[i], function()
                -- print("进入图鉴")
                self._viewMgr:showView("pokedex.PokedexDetailView", {pokedexType = i})
            end)
            local downX
            registerTouchEvent(
                self._pokedex[i],
                function (_, x, y)
                    self._isClick = false
                end, 
                function (_, x, y)
                    self._isScroll = true
                end, 
                function (_, x, y)
                    if self._isClick == false then
                        self._viewMgr:showView("pokedex.PokedexDetailView", {pokedexType = i})
                        self._isClick = false
                    end
                    self._isScroll = false
                end,
                function ()
                    self._isClick = false
                    self._isScroll = false
                end)
            -- self:registerClickEvent(self._pokedex[i], function()
            --     self._viewMgr:showView("pokedex.PokedexDetailView", {pokedexType = i})
            -- end)

        else
            self._pokedex[i]:updateCell({type = 2, level = level, pokedexData = pokedexData[tostring(i)]})

            registerTouchEvent(
                self._pokedex[i],
                function (_, x, y)
                    self._isClick = false
                end, 
                function (_, x, y)
                end, 
                function (_, x, y)
                    if self._isClick == false then
                        self._viewMgr:showTip("玩家" .. level .. "级开启")
                        self._isClick = false
                    end
                end,
                function ()
                    self._isClick = false
                end)
            self._pokedex[i]:setTip(false)
        end
        self._pokedex[i]:setSwallowTouches(false)
        -- self._pokedex[i].pokedex:loadTexture("tj_" .. tab:Tujian(i).art .. ".png", 1) 
        -- self._pokedex[i].title:setString(lang(tab:Tujian(i).name))
        -- local level = tab:Tujian(i).level
        -- if tonumber(userData.lvl) >= level then
        --     self:setPokedexStage(i,1)
        -- else
        --     self._pokedex[i].off:setString(level .. "级开启")
        --     self:setPokedexStage(i,2)
        -- end
        -- local str = pokedexModel:getPokedexSumScore(i) * tab:Tujian(i).effect
        -- if i <= table.nums(pokedexData) then
        --     self._pokedex[i].fight:setString("a+" .. math.ceil(pokedexData[tostring(i)].fight))
        --     -- self._pokedex[i].onPokedex:setVisible(pokedexData[tostring(i)].onPokedex)
        -- else
        --     -- self._pokedex[i].onPokedex:setVisible(false)
        -- end

        -- self._pokedex[i].onPokedex:setPositionX(self._pokedex[i].title:getPositionX()+self._pokedex[i].title:getContentSize().width/2)

        -- self._pokedex[i].onPokedex

        -- local posX = (self._pokedex[i]:getContentSize().width - (self._pokedex[i].fight:getContentSize().width * self._pokedex[i].fight:getScale()))/2
        -- self._pokedex[i].zhanli:setPositionX(posX)
        -- self._pokedex[i].fight:setPositionX(posX - 12)
        -- self._pokedex[i].fight:setPositionX(posX + self._pokedex[i].zhanli:getContentSize().width - 12)
    end
end


function PokedexView:setPokedexStage(index,typeId)
    if typeId == 1 then
        self._pokedex[index].pokedex:setSaturation(0)
        -- self._pokedex[index].zhanli:setVisible(true)
        self._pokedex[index].fight:setVisible(true)
        self:registerClickEvent(self._pokedex[index], function()
            -- print("进入图鉴")
            self._viewMgr:showView("pokedex.PokedexDetailView", {pokedexType = index})
        end)
    elseif typeId == 2 then
        self._pokedex[index].pokedex:setSaturation(-100)
        self._pokedex[index].off:setVisible(true)
        -- self._pokedex[index].zhanli:setVisible(false)
        self._pokedex[index].fight:setVisible(false)
    end
end


function PokedexView:onBeforeAdd(callback, errorCallback)
    local pokedexModel = self._modelMgr:getModel("PokedexModel")
    local pokedexData = pokedexModel:getData()
    local tempNum = 0
    local flag = false
    local userlvl = self._modelMgr:getModel("UserModel"):getData().lvl
    for i=1,pokedexMax do
        if tab:Tujian(i).level <= userlvl then
            tempNum = tempNum + 1
        end
    end
    if tempNum > table.nums(pokedexData) or pokedexModel:isEmpty() then
        flag = true
    end
    if flag then
        self._onBeforeAddCallback = function(inType)
            if inType == 1 then 
                callback()
            else
                errorCallback()
            end
        end
        self:getPokedexInfo()
    else
        self:setPokedex()
        callback()
    end

end

function PokedexView:getPokedexInfo()
    self._serverMgr:sendMsg("PokedexServer", "getPokedexInfo", {}, true, {}, function (result)
        self:getPokedexInfoFinish(result)
    end)
end

function PokedexView:getPokedexInfoFinish(result)
    if result == nil then
        self._onBeforeAddCallback(2)
        return 
    end
    self._onBeforeAddCallback(1)
    self:setPokedex()
end

function PokedexView:getAsyncRes()
    return  
        { 
            {"asset/ui/pokedex2.plist", "asset/ui/pokedex2.png"},
            {"asset/ui/pokedex1.plist", "asset/ui/pokedex1.png"},
            {"asset/ui/pokedex.plist", "asset/ui/pokedex.png"},
        }
end

function PokedexView:getBgName()
    return "bg_003.jpg"
end

-- function PokedexView:setNavigation()
--     self._viewMgr:showNavigation("global.UserInfoView",{title = "globalTitleUI_tujian.png"})
-- end

function PokedexView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{hideHead=true,hideInfo=true})
end

function PokedexView:setNoticeBar()
    self._viewMgr:hideNotice(true)
end

function PokedexView:onDoGuide(config)
    if config.showTuJianDialog  ~= nil then
        self._viewMgr:showDialog("pokedex.PokedexShowDialog")
    end
end

return PokedexView