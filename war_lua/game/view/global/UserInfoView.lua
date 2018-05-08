--[[
    Filename:    UserInfoView.lua
    Author:      <libolong@playcrab.com>
    Datetime:    2015-04-29 15:21:54
    Description: File description
--]]
local tab = tab
local UserInfoView = class("UserInfoView", BaseView)
--[[
传入参数  类型
offset    ccp   偏移
hideHead  bool  是否隐藏间隔条
hideNavi  bool  隐藏资源(金币。。等)条
hideBtn   bool  隐藏关闭按钮
types     table 可选任意三个{"Gold","Gem","Physcal","Texp","Val"}
--]]
function UserInfoView:ctor()
    UserInfoView.super.ctor(self)
end
local iconMap = IconUtils.resImgMap
-- {
--     Gold = "globalImageUI_gold1.png",
--     Gem = "globalImageUI_diamond.png",
--     Physcal = "globalImageUI4_power.png",
--     Currency = "globalImage_jingjibi.png",
--     Crusading = "golbalIamgeUI5_yuanzhengbi.png",
--     Texp = "globalImageUI_texp.png",
-- }
local firstInit = true
local beginPhysic = 0
local beginGuilPower = 0
local loginPhysic = 0
local loginGPTime = 0
local loginUpPhyTime = 0
function UserInfoView:onInit()
    self._bg = self:getUI("bg")
    self._bar = self:getUI("bg.bar")
    self._closeBtn = self:getUI("closeBtn")
    self._closeBtn2 = self:getUI("closeBtn2")
    self._titleBg = self:getUI("titleBg")
    -- local titleBgImg = self:getUI("titleBg.titleBgImg")
    -- titleBgImg:setZOrder(-1)
    -- 
    self._lineImg = self:getUI("bg.bar.lineImg")
    self._lineImg:setVisible(false)
    self._titleImg = self:getUI("titleBg.title_img")
    self._titleImg:setVisible(false)
    self._titleTxt = self:getUI("titleBg.title_Txt")
    self._titleTxt:setFontName(UIUtils.ttfName_Title)
    self._titleTxt:setFontSize(28)
    self._titleTxt:setSkewX(10)

    self._closeBtn.pressLongTime = 0x0030
    self:registerTouchEvent(self._closeBtn, nil, nil, function ()
        if type(self._callback) == "function" then
            self._callback()
            self._callback = nil
        end
        if OS_IS_WINDOWS then
            ---[[ 关闭界面后重载 lua file by guojun 16.8.3
            local reloadFileName = self._viewMgr._viewLayer:getChildren()[#self._viewMgr._viewLayer:getChildren()].view:getClassName()
            UIUtils:reloadLuaFile(reloadFileName)
            --]]
        end
        self._viewMgr:closeCurView()
    end, nil, function () self._viewMgr:showNotificationDialog(uft8) end)
    self:registerClickEvent(self._closeBtn2, function ()
        if type(self._callback) == "function" then
            self._callback()
            self._callback = nil
        end
        if OS_IS_WINDOWS then
            ---[[ 关闭界面后重载 lua file by guojun 16.8.3
            local reloadFileName = self._viewMgr._viewLayer:getChildren()[#self._viewMgr._viewLayer:getChildren()].view:getClassName()
            UIUtils:reloadLuaFile(reloadFileName)
            --]]
        end
        self._viewMgr:closeCurView()    
    end)
    -- 特做的进度条
    self._progBg2 = self:getUI("bg.bar.board2.progBg")
    self._progBg2:setVisible(false)
    self._progBg3 = self:getUI("bg.bar.board3.progBg")
    self._progBg3:setVisible(false)
    -- 数组管理
    -- 显示数值的label
    self._buyLabels = {}
    for i=1,4 do
        local label = self:getUI("bg.bar.board" .. i .. ".lab")
        label:setFontName(UIUtils.ttfName)
        table.insert(self._buyLabels,label)
    end
    self._icons = {}
    for i=1,4 do
        local icon = self:getUI("bg.bar.board" .. i .. ".icon")
        table.insert(self._icons,icon)
    end
    -- 显示资源label衬底
    self._boards = {}
    for i=1,4 do
        table.insert(self._boards,self:getUI("bg.bar.board" .. i))
    end
     --添加特效
    -- local mc1Paly = 0
    local mc2Play = 0
    self._mc1 = mcMgr:createViewMC("jinbiguang_mainviewcoin", true, false,function (_, sender)
         math.randomseed(tostring(os.time()):reverse():sub(1, 6))
        mc2Play = math.floor(math.random()*10)%2       
        sender:stop()
        if math.floor(mc2Play) == 0 then
            self._mc2:gotoAndPlay(0)
        else
            self._mc3:gotoAndPlay(0)
        end  
    end)
    self._mc1:setName("anim1")
    self._mc1:setPosition(self._icons[2]:getContentSize().width/2+2.5, self._icons[2]:getContentSize().height/2+2.5)
    self._icons[2]:addChild(self._mc1, 1)    

    self._mc2 = mcMgr:createViewMC("zuanshiguang_mainviewcoin", true, false,function (_, sender)
        math.randomseed(tostring(os.time()):reverse():sub(1, 6))
        mc2Play = math.floor(math.random()*10)%2       
        sender:stop()
        if math.floor(mc2Play) == 0 then
            self._mc1:gotoAndPlay(0)
        else
            self._mc3:gotoAndPlay(0)
        end         
    end)
    self._mc2:setScale(0.95)
    self._mc2:setName("anim2")
    self._mc2:stop()
    self._mc2:setPosition(self._icons[3]:getContentSize().width/2, self._icons[3]:getContentSize().height/2+0.5)
    self._icons[3]:addChild(self._mc2, 1)

    self._mc3 = mcMgr:createViewMC("tiliguang_mainviewcoin", true, false,function (_, sender)
        math.randomseed(tostring(os.time()):reverse():sub(1, 6))
        mc2Play = math.floor(math.random()*10)%2      
        sender:stop()
        if math.floor(mc2Play) == 0 then
            self._mc1:gotoAndPlay(0)
        else
            self._mc2:gotoAndPlay(0)
        end  
    end)
    self._mc3:setName("anim3")
    self._mc3:stop()
    self._mc3:setPosition(self._icons[1]:getContentSize().width/2-1, self._icons[1]:getContentSize().height/2-1.5)
    self._icons[1]:addChild(self._mc3, 1)

    -- self._head = self:getUI("head")
    -- 根据model初始化数值
    self.btnTypes = {"Physcal","Gold","Gem"}
    self._preValues = {}
    -- self:updatePreValues()
    local physcalAdd = tab:Setting("G_PHYSCAL_ADD").value*60
    local guildPowerAdd = tab:Setting("G_GUILDPOWER_ADD").value*60
    local userModel = self._modelMgr:getModel("UserModel")
    local privileges = self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_7) or 0
    local privilegeBuff = 0
    if privileges then
        privilegeBuff = privileges or 0
    end
    local maxPhyNum = (tab:Setting("G_INITIAL_PHYSCAL_MAX").value or 0)+privilegeBuff
    local maxGuildNum = self:isBigPrivilege() or 0
    self:listenReflash("UserModel", self.reflashUserInfo)
    self:listenReflash("ArenaModel", self.reflashUserInfo)
    self:listenReflash("AdventureModel", self.reflashUserInfo)
    self.btnEvents = {}
    local btnNames = {
        "bg.bar.board1.btn",
        "bg.bar.board2.btn",
        "bg.bar.board3.btn",
        "bg.bar.board4.btn",
    }
    self._buyBtns = {}
    for i,name in ipairs(btnNames) do
        local btn = self:getUI(name)
        table.insert(self._buyBtns,btn)
        self:registerClickEventByName(name, function ()
            self.btnEvents[i](self)
        end)

    end

    loginPhysic = userModel:getData().physcal or 0
    beginPhysic = userModel:getData().physcal or 0
    beginGuilPower = userModel:getData().guildPower or 0 
    loginGPTime = userModel:getData().upGPTime or 0
    loginUpPhyTime = userModel:getData().upPhyTime or 0 
    self._board1 = self:getUI("bg.bar.board1")
    self._board2 = self:getUI("bg.bar.board2")
    self._board3 = self:getUI("bg.bar.board3")
    self._physicalTip = self:getUI("bg.physicalTip")
    self._guildPowerTip = self:getUI("bg.guildPowerTip")
    -- self._guildPowerTip:setPositionX(-(MAX_SCREEN_WIDTH-960)/2)
    local guildDes2 = self._guildPowerTip:getChildByFullName("des2")
    guildDes2:setString(lang("GUILDMAPTIPS_5") or "玩家每前进一格消耗10点行动力，当行动力为0时不可继续移动")
    self._mapHurtTip = self:getUI("bg.mapHurtTip")
    -- self._mapHurtTip:setPositionX(46-(MAX_SCREEN_WIDTH-960)/2)
    local mapHurtDes2 = self._mapHurtTip:getChildByFullName("des2")
    mapHurtDes2:setString(lang("GUILDMAPTIPS_2"))
    
    self:regGuildPowerTip()
    self:regMapHurtTip()
    self:regPythicTip()
    -- 更新体力
    local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local upGPTime = self._modelMgr:getModel("UserModel"):getData().upGPTime
    local function upDatePhyscal()
        local privileges = self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_7) or 0
        local privilegeBuff = 0
        if privileges then
            privilegeBuff = privileges or 0
        end
        local maxPhyNum = (tab:Setting("G_INITIAL_PHYSCAL_MAX").value or 0)+privilegeBuff
        local physcal = self._modelMgr:getModel("UserModel"):getData().physcal or 0
        local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
        if physcal < maxPhyNum then  
            local upPhyTime = self._modelMgr:getModel("UserModel"):getData().upPhyTime or self._modelMgr:getModel("UserModel"):getCurServerTime()
            if nowTime >= upPhyTime+physcalAdd then 
                local deltPhy = math.floor((nowTime-upPhyTime)/physcalAdd)
                local num  = (beginPhysic or 0)+deltPhy
                upPhyTime = nowTime-(nowTime-upPhyTime)%physcalAdd --nowTime--nowTime%physcalAdd
                self._modelMgr:getModel("UserModel"):updateUserData({physcal = math.min(self._modelMgr:getModel("UserModel"):getData().physcal+deltPhy,maxPhyNum),upPhyTime=upPhyTime+physcalAdd})
            end
        end

        local upGPTime = self._modelMgr:getModel("UserModel"):getData().upGPTime
        local maxGuildNum = self:isBigPrivilege() or 0
        local guildPower = self._modelMgr:getModel("UserModel"):getData().guildPower

        if guildPower and guildPower < maxGuildNum then  
            local upGPTime = self._modelMgr:getModel("UserModel"):getData().upGPTime or self._modelMgr:getModel("UserModel"):getCurServerTime()
            local guildAdd = tab:Setting("G_GUILDPOWER_ADD").value*60
            if upGPTime and nowTime >= upGPTime+guildAdd then 
                local deltGuild = math.floor((nowTime-upGPTime)/guildAdd)
                upGPTime = nowTime-(nowTime-upGPTime)%guildAdd

                self._modelMgr:getModel("UserModel"):updateUserData({guildPower = math.min(self._modelMgr:getModel("UserModel"):getData().guildPower+deltGuild,maxGuildNum),upGPTime=upGPTime+guildAdd})
            elseif upGPTime and nowTime <= upGPTime then
                local deltGuild = math.floor((upGPTime-nowTime)/guildAdd)
                upGPTime = nowTime+(upGPTime-nowTime)%guildAdd - guildAdd
                self._modelMgr:getModel("UserModel"):updateUserData({guildPower = math.min(self._modelMgr:getModel("UserModel"):getData().guildPower,maxGuildNum),upGPTime=upGPTime})
            end
        end
        -- if upGPTime then
        --     local maxGuildNum = self:isBigPrivilege() or 0
        --     local guildPower = self._modelMgr:getModel("UserModel"):getData().guildPower
        --     if guildPower and guildPower < maxGuildNum then
        --         if upGPTime < nowTime then
        --             local guildAdd = tab:Setting("G_GUILDPOWER_ADD").value*60
        --             local deltGuild = math.ceil((nowTime-upGPTime)/guildPowerAdd)
        --             local toAddGuild = guildPower+deltGuild
        --             if toAddGuild > 200 and guildPower < maxGuildNum then
        --                 toAddGuid = 200
        --             end
        --             upGPTime = nowTime+deltGuild*guildAdd
        --             self._modelMgr:getModel("UserModel"):updateUserData({guildPower = toAddGuid,upGPTime=upGPTime})
        --         end
        --     end
        -- end
    end

    upDatePhyscal( )
    self._upDateFunc = function( )
        upDatePhyscal( )
    end
    self._phySchedule = ScheduleMgr:regSchedule(3000,self,function ( )
        upDatePhyscal()
    end)


    -- 为调整 按钮位置 初始化 默认位置
    if not self._initResPoses then
        self._initResPoses = {
            [1] = {
                self._icons[1]:getPositionX(),
                self._boards[1]:getPositionX(),
                self._buyBtns[1]:getPositionX(),
                self._buyLabels[1]:getPositionX(),
            },
            [2] = {
                self._icons[2]:getPositionX(),
                self._boards[2]:getPositionX(),
                self._buyBtns[2]:getPositionX(),
                self._buyLabels[2]:getPositionX(),
                
                self._icons[2]:getPositionY(),
                self._boards[2]:getPositionY(),
                self._buyBtns[2]:getPositionY(),
                self._buyLabels[2]:getPositionY(),
            },
            [3] = {
                self._icons[3]:getPositionX(),
                self._boards[3]:getPositionX(),
                self._buyBtns[3]:getPositionX(),
                self._buyLabels[3]:getPositionX(),

                self._icons[3]:getPositionY(),
                self._boards[3]:getPositionY(),
                self._buyBtns[3]:getPositionY(),
                self._buyLabels[3]:getPositionY(),
            },
            [4] = {
                self._icons[4]:getPositionX(),
                self._boards[4]:getPositionX(),
                self._buyBtns[4]:getPositionX(),
                self._buyLabels[4]:getPositionX()
            },

        }
    end 
end

-- 销毁时关闭定时器
function UserInfoView:onDestroy( )
    if self._phySchedule then
        ScheduleMgr:unregSchedule(self._phySchedule)
        self._phySchedule = nil
    end
    if self._lastTimeSch then
        ScheduleMgr:unregSchedule(self._lastTimeSch)
        self._lastTimeSch = nil
    end
    -- self.super.onDestroy(self)
    UserInfoView.super.onDestroy(self)

end

-- 注册tip事件
function UserInfoView:regGuildPowerTip( )
    local guildPowerAdd = tab:Setting("G_GUILDPOWER_ADD").value*60
    self:registerTouchEvent(self._board3, function( )
        if self.btnTypes then
            if string.lower(self.btnTypes[3]) == "guildpower" then
                self._board2:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function( )
                    self._guildPowerTip:setVisible(true)

                    local nextTime = self._guildPowerTip:getChildByFullName("nextTime")
                    local upGPTime = self._modelMgr:getModel("UserModel"):getData().upGPTime or 0
                    local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
                    local maxGuildNum = self:isBigPrivilege() or 0
                    local guildAdd = tab:Setting("G_GUILDPOWER_ADD").value*60 or 0
                    local deltGuild =  math.floor((nowTime-upGPTime)/guildPowerAdd)
                    local num = math.min(maxGuildNum,(beginGuilPower or 0)+deltGuild)

                    local nowNum = self._modelMgr:getModel("UserModel"):getData().guildPower or 0
                    if not self._lastTimeSch and maxGuildNum - nowNum > 0 then
                        self._lastTimeSch = ScheduleMgr:regSchedule(1000,self,function ( )
                            local upGPTime = self._modelMgr:getModel("UserModel"):getData().upGPTime or self._modelMgr:getModel("UserModel"):getCurServerTime()
                            local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
                            local lastTime = guildAdd - (nowTime-upGPTime)%guildAdd
                            nextTime:setString(string.format("%02d:%02d:%02d",math.floor(lastTime/3600),math.floor(lastTime/60%60),lastTime%60))
                        end)
                        local lastTime = guildAdd - (nowTime-upGPTime)%guildAdd
                        nextTime:setString(string.format("%02d:%02d:%02d",math.floor(lastTime/3600),math.floor(lastTime/60%60),lastTime%60))
                    else
                        nextTime:setString("00:00:00")
                    end
                end)))
            end
        end
    end, nil, function( )
        self._board2:stopAllActions()
        self._guildPowerTip:setVisible(false)
        if self._lastTimeSch then
            ScheduleMgr:unregSchedule(self._lastTimeSch)
            self._lastTimeSch = nil
        end
    end, function( )
        self._board2:stopAllActions()
        self._guildPowerTip:setVisible(false)
        if self._lastTimeSch then
            ScheduleMgr:unregSchedule(self._lastTimeSch)
            self._lastTimeSch = nil
        end
    end)
end

function UserInfoView:regMapHurtTip( )
    self:registerTouchEvent(self._board2, function( )
        if self.btnTypes then
            if string.lower(self.btnTypes[2]) == "maphurt" then
                self._board2:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function( )
                    self._mapHurtTip:setVisible(true)
                end)))
            end
        end
    end, nil, function( )
        self._board2:stopAllActions()
        self._mapHurtTip:setVisible(false)
        if self._lastTimeSch then
            ScheduleMgr:unregSchedule(self._lastTimeSch)
            self._lastTimeSch = nil
        end
    end, function( )
        self._board2:stopAllActions()
        self._mapHurtTip:setVisible(false)
        if self._lastTimeSch then
            ScheduleMgr:unregSchedule(self._lastTimeSch)
            self._lastTimeSch = nil
        end
    end)
end

function UserInfoView:regPythicTip( )
    local physcalAdd = tab:Setting("G_PHYSCAL_ADD").value*60
    self:registerTouchEvent(self._board1, function( )
        if self.btnTypes then
            if string.lower(self.btnTypes[1]) == "physcal" then
                self._board1:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function( )
                    self._physicalTip:setVisible(true)
                    local nextTime = self._physicalTip:getChildByFullName("nextTime")
                    local fullTime = self._physicalTip:getChildByFullName("fullTime")
                    local buyNum = self._physicalTip:getChildByFullName("buyNum")

                    self:genEnergyDes() -- 调用计算函数
                    buyNum:setString((self.buyEnergyNum-self._buyEnergySum) .."/".. self.buyEnergyNum )
                    local privileges = self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_7) or 0
                    local privilegeBuff = 0
                    if privileges then
                        privilegeBuff = privileges or 0
                    end
                    local maxPhyNum = (tab:Setting("G_INITIAL_PHYSCAL_MAX").value or 0)+privilegeBuff
                    local nowNum = self._modelMgr:getModel("UserModel"):getData().physcal or 0
                    if not self._lastTimeSch and maxPhyNum - nowNum > 0 then
                        local updatePhyTime = function ( )
                            local upPhyTime = self._modelMgr:getModel("UserModel"):getData().upPhyTime or self._modelMgr:getModel("UserModel"):getCurServerTime()
                            local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
                            local lastTime = physcalAdd - (nowTime-upPhyTime)%physcalAdd
                            nextTime:setString(string.format("%02d:%02d:%02d",math.floor(lastTime/3600),math.floor(lastTime/60%60),lastTime%60))
                            local lastFull = (maxPhyNum-self._modelMgr:getModel("UserModel"):getData().physcal)*physcalAdd+lastTime
                            fullTime:setString(string.format("%02d:%02d:%02d",math.floor(lastFull/3600),math.floor(lastFull/60%60),lastFull%60))
                        end
                        self._lastTimeSch = ScheduleMgr:regSchedule(1000,self,function( )
                            updatePhyTime()
                        end)
                        updatePhyTime()
                    else
                        nextTime:setString("00:00:00")
                        fullTime:setString("00:00:00")
                    end
                end)))
            end
        end
    end, nil, function( )
        self._board1:stopAllActions()
        self._physicalTip:setVisible(false)
        if self._lastTimeSch then
            ScheduleMgr:unregSchedule(self._lastTimeSch)
            self._lastTimeSch = nil
        end
    end, function( )
        self._board1:stopAllActions()
        self._physicalTip:setVisible(false)
        if self._lastTimeSch then
            ScheduleMgr:unregSchedule(self._lastTimeSch)
            self._lastTimeSch = nil
        end
    end)
end

-- 购买金币回调
function UserInfoView:buyGold( callback )
    -- local str,canbuy,canBuyNum = self:genGoldDes()
    
    if not SystemUtils:enableUser_buyGold() then
        local systemOpenTip = tab.systemOpen["User_buyGold"][3]
        if not systemOpenTip then
            self._viewMgr:showTip(tab.systemOpen["User_buyGold"][1] .. "级开启")
        else
            self._viewMgr:showTip(lang(systemOpenTip))
        end
        -- self._viewMgr:showTip(lang("TIP_DIANJINSHOU"))
        return 
    end
    if self:isCanBuyRes("gold") then
        -- self._viewMgr:showDialog("global.GlobalBuyResDialog",{goalType = "gold",closeCallback = callback},true)
        self._viewMgr:showDialog("global.GlobalTradeDialog",{goalType = "gold",tabIdx = 1,closeCallback = callback})
    end
end

-- 购买钻石回调
function UserInfoView:buyGem( )
    self._viewMgr:showView("vip.VipView", {viewType = 0})
end

-- 购买大富翁骰子回调
function UserInfoView:buyDice( callback )
    -- self._viewMgr:showView("task.TaskView", {viewType = 2,superiorType = 3})
    -- self._viewMgr:showDialog("activity.adventure.AdventureTaskView", {})
    self._viewMgr:showDialog("global.GlobalBuyResDialog",{goalType = "dice",closeCallback = callback},true)
     -- kSuperiorTypeAdventure
end

-- 购买体力回调
function UserInfoView:buyPhyscal( callback )
    if self:isCanBuyRes("physcal") then 
        self._viewMgr:showDialog("global.GlobalBuyResDialog",{goalType = "physcal",closeCallback = callback},true)
    end
end

-- 巢穴回调
function UserInfoView:buynests1( )
    local param = {indexId = 3}
    self._viewMgr:showDialog("global.GlobalPromptDialog", param)
end

function UserInfoView:buynests2( )
    local param = {indexId = 4}
    self._viewMgr:showDialog("global.GlobalPromptDialog", param)
end

function UserInfoView:buynests3( )
    local param = {indexId = 5}
    self._viewMgr:showDialog("global.GlobalPromptDialog", param)
end

-- 购买竞技币回调
-- function UserInfoView:buyVal( )
    
-- end

-- 购买怪兽经验回调
function UserInfoView:buyTexp( callback )
    if self:isCanBuyRes("texp") then 
        -- self._viewMgr:showDialog("global.GlobalBuyResDialog",{goalType = "texp",closeCallback = callback},true)
        self._viewMgr:showDialog("global.GlobalTradeDialog",{goalType = "texp",tabIdx = 2,closeCallback = callback})
    end
end

-- 购买幸运币（抽卡用）回调
function UserInfoView:buyLuckyCoin( callback,param )
    param = param or {}
    param.closeCallback = param.callback 
    self._viewMgr:showDialog("global.DialogBuyLucyCoin",param)
end

-- 购买法术卷轴回调
function UserInfoView:buyMagicNum( callback )
    if self:isCanBuyRes("texp") then 
        -- self._viewMgr:showDialog("global.GlobalBuyResDialog",{goalType = "texp",closeCallback = callback},true)
        self._viewMgr:showDialog("global.GlobalTradeDialog",{goalType = "magicNum",tabIdx = 3,closeCallback = callback})
    end
end

-- 购买进阶石回调
function UserInfoView:buyTreasureNum( callback )
    if self:isCanBuyRes("texp") then 
        -- self._viewMgr:showDialog("global.GlobalBuyResDialog",{goalType = "texp",closeCallback = callback},true)
        self._viewMgr:showDialog("global.GlobalTradeDialog",{goalType = "treasureNum",tabIdx = 4,closeCallback = callback})
    end
end


-- 购买箭
function UserInfoView:buyArrow( callback )
    if self:isCanBuyRes("arrowNum","buyArrow") then 
        self._viewMgr:showDialog("global.GlobalBuyResDialog",{goalType = "arrowNum",closeCallback = callback},true)
    end
end


-- 购买器械经验
function UserInfoView:buySiegeWeaponExp( callback )
    local param = {indexId = 16}
    self._viewMgr:showDialog("global.GlobalPromptDialog", param)
end

-- 购买配件经验
function UserInfoView:buySiegePropExp( callback )
    local param = {indexId = 17}
    self._viewMgr:showDialog("global.GlobalPromptDialog", param)
end

--获取圣徽货币
function UserInfoView:buyRuneCoin( callback )
	local param = {indexId = 18}
	self._viewMgr:showDialog("global.GlobalPromptDialog", param)
end


-- 检测是否可以买 vip = 0 及 当前vip时次数为0 
function UserInfoView:isCanBuyRes( goalType,vipBuyType )
    -- 去掉vip 次数为0 弹提升vip的板子
    -- local vip = self._modelMgr:getModel("VipModel"):getData().level
    -- local buyType = vipBuyType or ("buy" .. string.upper(string.sub(goalType,1,1)) .. string.sub(goalType,2,string.len(goalType)))
    -- if tab:Vip(vip)[buyType] < 1 then 
    --         local goalName = lang(tab:Tool(IconUtils.iconIdMap[goalType]).name)
    --         self._viewMgr:showDialog("global.GlobalResTipDialog",{des1 = "今日购买".. goalName .."次数已用完，提升VIP可增加购买次数"},true)
    --     return false
    -- end
    return true
end

-- 购买大地图行动力回调
function UserInfoView:buyGuildPower( callback )
    if self:isCanBuyRes("guildPower") then 
        -- 行动力超过一千不让买
        local limitNum = tab.setting["G_GUILD_POWER_LIMIT"] and tab.setting["G_GUILD_POWER_LIMIT"].value
        if limitNum and (self._modelMgr:getModel("UserModel"):getData().guildPower or 0) > limitNum then
            self._viewMgr:showTip("行动力接近上限，请先进行联盟探索")
            return
        end
        local canBuyNum = tab.vip[#tab.vip-1]["buyGuildPower"]
        local buyGuildPowerSum = self._modelMgr:getModel("PlayerTodayModel"):getData().day23 or 0
        if canBuyNum <= buyGuildPowerSum then
            self._viewMgr:showTip("今日购买次数已达上限")
            return 
        end
        self._viewMgr:showDialog("global.GlobalBuyResDialog",{goalType = "guildPower",closeCallback = callback},true)
    end
end

function UserInfoView:genGemDes()
    -- body
end

function UserInfoView:genEnergyDes()
    -- if not self.energyAdd then
    self.energyAdd = tab:Setting("G_PHYSCAL_BUY_ADD").value
    local vip = self._modelMgr:getModel("VipModel"):getData().level
    -- dump(self._modelMgr:getModel("VipModel"):getData())
    self.buyEnergyNum = tonumber(tab:Vip(vip).buyPhyscal) -- tab:Setting("G_INITIAL_BUY_PHYSCAL_NUM").value
    -- end
    if self._buyEnergySum >= self.buyEnergyNum then
        return "今日购买次数已满,请明日再来",false
    end
    local buySum = self._buyEnergySum+1
    local reflashCostT = tab["reflashCost"]
    if buySum > #reflashCostT then buySum = #reflashCostT end
    self.energyCostGem = tab:ReflashCost(buySum).buyPhysical or 0
    local desString = "花费".. self.energyCostGem .."钻石购买".. self.energyAdd .. "体力,是否继续？今日已购买".. self._buyEnergySum .."/".. self.buyEnergyNum .."次(提高vip可增加购买体力次数）"
    return desString,true
end

-- 额外更新 延迟更新时先单独更新色子 不影响之后色子更新
function UserInfoView:reflashDiceOnly( preNum,afterNum )
    for i,v in ipairs(self.btnTypes) do
        local costType = string.lower(string.sub(v,1,1)) .. string.sub(v,2,string.len(v)) -- 预防驼峰命名的变量不直接用lower！！
        if costType == "dice" then 
            local num = after or self._modelMgr:getModel("AdventureModel"):getHadDiceNum()
            -- 判断变化
            local preNum = preNum or self:getPreResNum(costType) -- self._preValues[costType]
            local detectNum = num
            if preNum and preNum ~= detectNum then
                self:runValueChangeAnim(self._buyLabels[i],i,function( index )
                    num = ItemUtils.formatItemCount(num)
                    self._buyLabels[index]:setString(num)
                end)
            else
                num = ItemUtils.formatItemCount(num)
                self._buyLabels[i]:setString(num)
            end
            break
        end
    end
    self:updatePreValues()
end 

-- 封装取资源数目的接口
function UserInfoView:getResNum( costType )
    local player = self._modelMgr:getModel("UserModel"):getData()
    local num = player[costType] or (player.roleGuild and player.roleGuild[costType]) 
    if num == nil then
        if tonumber(costType) then
            if tab.tool[tonumber(costType)] then 
                _,num = self._modelMgr:getModel("ItemModel"):getItemsById(tonumber(costType))
            end
        end
    end
    if costType == "dice" then
        num = self._modelMgr:getModel("AdventureModel"):getHadDiceNum()
    end
    return num or 0
end

function UserInfoView:getPreResNum( costType )
    local player = self._modelMgr:getModel("UserModel"):getData()
    local num = self._preValues[costType] or (self._preValues.roleGuild and self._preValues.roleGuild[costType])
    if num == nil or num == 0 then
        num = self:getResNum(costType)
        self._preValues[costType] = num
    end
    return num or 0
end

function UserInfoView:reflashUserInfo( ignoreDelay )
    local player = self._modelMgr:getModel("UserModel"):getData()
    if table.nums(player) == 0 then
        return 
    end

    -- 延迟刷新
    if self._delayReflash and not ignoreDelay then
        return 
    end
    
    for i,v in ipairs(self.btnTypes) do
        local costType = string.lower(string.sub(v,1,1)) .. string.sub(v,2,string.len(v)) -- 预防驼峰命名的变量不直接用lower！！
        local num = self:getResNum(costType) --player[costType] or (player.roleGuild and player.roleGuild[costType]) or 0
        if costType == "dice" then
            num = self._modelMgr:getModel("AdventureModel"):getHadDiceNum()
        end
        local greenTxt = self._boards[i]:getChildByFullName("greenTxt")  
        local greenNum      
        -- self._buyLabels[i]:enableOutline(cc.c4b(65,65,65,255),2)
        if costType == "physcal" then
            if not greenTxt then 
                greenTxt = ccui.Text:create()
                greenTxt:setFontName(UIUtils.ttfName)
                greenTxt:setFontSize(22)--self._buyLabels[i]:getFontSize())
                greenTxt:setFontName(UIUtils.ttfName)
                -- greenTxt:setAnchorPoint(cc.p(0,0.5))
                greenTxt:setColor(cc.c4b(0, 255, 0, 255))
                greenTxt:setPositionY(18)
                greenTxt:setName("greenTxt")
                -- greenTxt:setPosition(cc.p(0,self._buyLabels[i]:getContentSize().height*0.5))
                -- greenTxt:enableOutline(cc.c4b(65,65,65,255),2, 0)
                self._boards[i]:addChild(greenTxt)
                if not self._physicalPos then
                    self._physicalPosX = self._buyLabels[i]:getPositionX()
                end
                UIUtils:center2Widget(greenTxt,self._buyLabels[i],65)
            end
            greenNum = num
            local preValue = self:getPreResNum(costType) -- self._preValues[costType] or (self._preValues.roleGuild and self._preValues.roleGuild[costType]) or greenNum
            self:formatPhysicalNum(greenTxt,preValue or 0,i)
        else
            if greenTxt then
                greenTxt:setVisible(false)
                if #self.btnTypes ~= 4 and self.btnTypes[3] ~= "MapHurt" then
                    self._buyLabels[i]:setPositionX(self._physicalPosX)
                end
            end
        end
        -- 判断变化
        local preNum = self:getPreResNum(costType) -- self._preValues[costType] or (self._preValues.roleGuild and self._preValues.roleGuild[costType])
        num = self:getResNum(costType) -- player[costType] or (player.roleGuild and player.roleGuild[costType]) or 0
        if costType == "dice" then
            num = self._modelMgr:getModel("AdventureModel"):getHadDiceNum()
        end
        local detectNum = num
        if greenTxt and greenTxt:isVisible() then
            detectNum = greenNum --tonumber(greenTxt:getString())
        end
        if preNum and preNum ~= detectNum then
            if (costType == "guildPower" or costType == "mapHurt") and preNum > detectNum then
                self._buyLabels[i].changeColor = cc.c3b(255, 23, 23) 
            else
                self._buyLabels[i].changeColor = nil
            end 
            -- 体力最大3000点，超过2800，每次增加都弹tip 
            if preNum < detectNum and detectNum > 2800 and costType == "physcal" then
                self._viewMgr:showTip("你的体力即将达到上限，快去扫荡副本吧！")
            end
            self:runValueChangeAnim(self._buyLabels[i],i,function( index )
                -- upvalue 索引到的costType 会因为多次引用被修改 所以需要重拿
                local costType = string.lower(string.sub(self.btnTypes[index],1,1)) .. string.sub(self.btnTypes[index],2,string.len(self.btnTypes[index]))
                local num = self:getResNum(costType) -- player[costType] or (player.roleGuild and player.roleGuild[costType]) or 0
                if costType == "dice" then
                    num = self._modelMgr:getModel("AdventureModel"):getHadDiceNum()
                end
                if costType == "physcal" then
                    self:formatPhysicalNum(greenTxt,greenNum,i)
                else
                    local orignNum = num -- 原生数据用于计算进度条
                    num = ItemUtils.formatItemCount(num)
                    if costType == "guildPower" then
                        -- 刷新进度条
                        self:refreshProgressBar(costType,orignNum,self:isBigPrivilege())
                        num = num .. "/" .. self:isBigPrivilege() 
                    elseif costType == "mapHurt" then
                        -- 刷新进度条
                        self:refreshProgressBar(costType,orignNum,100)
                        num = num .. "/100"
                    end
                    self._buyLabels[i]:setString(num)
                end
            end)
        elseif costType == "physcal" then
            self:formatPhysicalNum(greenTxt,greenNum,i)
        else
            local orignNum = num -- 原生数据用于计算进度条
            num = ItemUtils.formatItemCount(num)
            if costType == "guildPower" then
                -- 刷新进度条
                self:refreshProgressBar(costType,orignNum,self:isBigPrivilege())
                num = num .. "/" .. self:isBigPrivilege() 
            elseif costType == "mapHurt" then
                -- 刷新进度条
                self:refreshProgressBar(costType,orignNum,100)
                num = num .. "/100"
            end
            self._buyLabels[i]:setString(num)
        end
    end

    local todayModel = self._modelMgr:getModel("PlayerTodayModel")

    self._buyEnergySum = todayModel:getData().day2 
    self._buyGoldSum = todayModel:getData().day3

    -- 变化的数值标签加动画

    self:updatePreValues()
end

function UserInfoView:refreshProgressBar( goalType,num,baseNum )
    local board 
    if goalType == "mapHurt" then
        board = self._board2
    elseif goalType == "guildPower" then
        board = self._board3
    end
    if board then
        board:setCascadeOpacityEnabled(false)
        board:setOpacity(0)
        board:getChildByFullName("progBg"):setVisible(true)
        local progress = board:getChildByFullName("progBg.progBar")
        progress:setPercent(tonumber(num)/baseNum*100)
    end
end

function UserInfoView:reflashUI(data)
    if data then
        self._callback = data.callback 
    end
    if data and data.offset then
        self._bar:setPosition(data.offset[1], data.offset[2])
    else
        self._bar:setPosition(0, -6)
    end

    if data and data.hideHead then
        -- self._titleImg:setVisible(false)
        self._titleTxt:setVisible(false)
        self._titleBg:setVisible(false)        
    else
        -- self._titleImg:setVisible(true)
        self._titleTxt:setVisible(true)
        self._titleBg:setVisible(true)
    end
    self._lineImg:setVisible(data.showLine)
    -- self._titleImg:setVisible(false)    
    -- if data and data.title ~= nil then
        -- self._titleImg:setVisible(true)
        -- self._titleImg:loadTexture(data.title,1)
    -- end
    -- 右上角程序字标题    
    self._titleTxt:setVisible(false)
    if data and data.titleTxt then
        self._titleTxt:setVisible(true)
        self._titleTxt:setString(data.titleTxt)
    end

    if data and data.forceTitleImage then
        self._titleImg:setVisible(true)
        self._titleImg:loadTexture(data.forceTitleImage,1)
    else
        self._titleImg:setVisible(false)
    end

    -- SigeCardView 需求加入底图木板  lishunan
    if data and data.longBg then
        if not self._longBg then
            self._longBg = cc.Sprite:createWithSpriteFrameName(data.longBg)
            self._longBg:setAnchorPoint(0,0.5)
            local height = self._longBg:getContentSize().height
            self._longBg:setScaleX(MAX_SCREEN_WIDTH/1022)
            self._longBg:setPosition(0,MAX_SCREEN_HEIGHT-height*0.5)
            self:addChild(self._longBg,-1)
        end
    else
        if not tolua.isnull(self._longBg) then
            self._longBg:removeFromParent()
            self._longBg = nil
        end
    end

    if data and data.hideInfo then
        self._bg:setVisible(false)
    else
        self._bg:setVisible(true)
    end

    if data and data.hideBtn then
        self._closeBtn:setVisible(false)
        self._closeBtn2:setVisible(false)
        self._titleBg:setVisible(false)
    else
        self._closeBtn:setVisible(true)
        -- self._titleBg:setVisible(true)
        if  data and data.hideHead then
            self._closeBtn:setVisible(false)
            self._closeBtn2:setVisible(true)
        else
            self._closeBtn:setVisible(true)
            self._closeBtn2:setVisible(false)
        end
    end

    if data then -- 延迟刷新
        self._delayReflash = data.delayReflash
    end
    if data and data.types then
        self.btnTypes = data.types        
        
    else
        self.btnTypes = {"Physcal","Gold","Gem"}        
    end

    -- 默认不显示进度条
    self._progBg2:setVisible(false)
    self._progBg3:setVisible(false)
    self._board2:setOpacity(255)
    self._board3:setOpacity(255)

    self.btnEvents = {}
    local btnUIGroup = {
        {"board1.icon","board1","board1.lab","board1.btn"},
        {"board2.icon","board2","board2.lab","board2.btn"},
        {"board3.icon","board3","board3.lab","board3.btn"},
        {"board4.icon","board4","board4.lab","board4.btn"}
    }
    for i,v in ipairs(self.btnTypes) do
        if v == "" then
            for k,v1 in pairs(btnUIGroup[i]) do
                self:getUI("bg.bar." .. v1):setVisible(false)
            end
        else
            for k,v1 in pairs(btnUIGroup[i]) do
                self:getUI("bg.bar." .. v1):setVisible(true)
            end
        end
        local funcName = "buy" .. v 
        local resImg = string.lower(string.sub(v,1,1)) .. string.sub(v,2,string.len(v))
        if self[funcName] then
            table.insert(self.btnEvents,self[funcName])
            self._buyBtns[i]:setVisible(true)
            self._icons[i]:loadTexture(iconMap[resImg],1)
            self._icons[i]:setScale(1)
            -- self._icons[i]:setScale(52/self._icons[i]:getContentSize().width)
        else
            if iconMap[resImg] then
                self._icons[i]:loadTexture(iconMap[resImg],1)
                -- self._icons[i]:setScale(52/self._icons[i]:getContentSize().width)
                self._icons[i]:setScale(1)
            elseif tab.tool[tonumber(resImg) or 0] then
                local toolD = tab.tool[tonumber(resImg) or 0]
                local filename = IconUtils.iconPath .. toolD.art .. ".png"
                local sfc = cc.SpriteFrameCache:getInstance()
                if not sfc:getSpriteFrameByName(filename) then
                    filename = IconUtils.iconPath .. toolD.art .. ".jpg"
                end
                self._icons[i]:loadTexture(filename,1)
                -- self._icons[i]:setContentSize({width=46,height=46})
                self._icons[i]:setScale(46/self._icons[i]:getContentSize().width)
            end
            table.insert(self.btnEvents,function( )end)
            self._buyBtns[i]:setVisible(false)
        end
        if data and data[string.lower(v) .. "HeartBeat"] then
            self:heartBeatAnim(v)
        else
            self:clearBeatAnim(v)
        end
    end

    self._mc1:setVisible(data.isAnim and true or false)  --是否播放特效
    self._mc2:setVisible(data.isAnim and true or false)
    self._mc3:setVisible(data.isAnim and true or false) 


    self:reflashUserInfo()
    -- 调整位置 适配三个和四个资源
    self:resetIconPos()
end

function UserInfoView:getBuyImgByType( buyType )
    for i,v in ipairs(self.btnTypes) do
        if v == tostring(buyType) then
            return self:getUI("bg.bar.board" .. i .. ".icon")
        end
    end
end

-- 做引导使用 图片心跳动画
function UserInfoView:heartBeatAnim( btnType )
    local icon = self:getBuyImgByType(btnType)
    if not icon then return end
    if icon:getChildByName("beatImg") then
        icon:getChildByName("beatImg"):removeFromParent()
    end
    local beatImg = icon:clone()
    beatImg:setName("beatImg")
    beatImg:setPosition(cc.p(icon:getContentSize().width/2,icon:getContentSize().height/2))
    icon:addChild(beatImg)
    local seq = cc.Sequence:create(cc.ScaleTo:create(0.2,1.2),cc.FadeOut:create(0.4),
        cc.FadeIn:create(0),cc.ScaleTo:create(0,1),cc.DelayTime:create(0.2))
    beatImg:runAction(cc.RepeatForever:create(seq))
end

function UserInfoView:clearBeatAnim( btnType )
    local icon = self:getBuyImgByType(btnType)
    if not icon then return end
    if icon:getChildByName("beatImg") then
        icon:getChildByName("beatImg"):removeFromParent()
    end
end

function UserInfoView:clearAllBeatAnim( )
    for k,v in pairs(self.btnTypes) do
        self:clearBeatAnim(v)
    end
end

-- 记录变化前的数据 需及时更新
function UserInfoView:updatePreValues( )
    local userData = self._modelMgr:getModel("UserModel"):getData()
    for k,v in pairs(self._preValues) do
        self._preValues[k] = userData[k]
    end
    for k,v in pairs(self.btnTypes) do
        self._preValues[string.lower(string.sub(v,1,1)) .. string.sub(v,2,string.len(v))] = self:getResNum(string.lower(string.sub(v,1,1)) .. string.sub(v,2,string.len(v)))
    end
end

-- 数值变化动画
function UserInfoView:runValueChangeAnim( label,index,endFunc )
    if not label then return end
    if not label:getActionByTag(101) then
        local preColor = label:getColor()
        label.userInfoView_endFunc = endFunc
        if not label.changeColor then
            label:setColor(cc.c3b(0, 255, 0))
        else
            label:setColor(label.changeColor)
        end
        local seq = cc.Sequence:create(cc.ScaleTo:create(0.1,1.2),cc.ScaleTo:create(0.3,1),cc.CallFunc:create(function( )
            label:setColor(preColor)
            if type(label.userInfoView_endFunc) == "function" then
                label.userInfoView_endFunc(index)
            end
        end))
        seq:setTag(101)
        label:runAction(seq)
    else
        label.userInfoView_endFunc = endFunc
    end
end

-- 格式化 体力
function UserInfoView:formatPhysicalNum( greenTxt,greenNum,labelPos,isGuildPower )
    -- 这一行做预防，放置传入的为空
    greenTxt,greenNum,labelPos = greenTxt or "",greenNum or self._modelMgr:getModel("UserModel"):getData().physcal or 0,labelPos or cc.p(0,0)
    
    local privileges = self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_7) or 0
    local privilegeBuff = 0
    if privileges then
        privilegeBuff = privileges or 0
    end 
    local maxNum = ((tab:Setting("G_INITIAL_PHYSCAL_MAX").value or 0)+privilegeBuff)

    greenTxt:setString(greenNum)
    local width = greenTxt:getContentSize().width
    greenTxt:setPositionX(-width)
    self._greenPos = self._physicalPosX+width/2
    if greenNum >= maxNum then
        -- self._buyLabels[labelPos]:setPositionX(self._greenPos)
        greenTxt:setVisible(true)
        self._buyLabels[labelPos]:setString("/" .. maxNum)
        UIUtils:center2Widget(greenTxt,self._buyLabels[labelPos],65)
    else
        greenTxt:setVisible(false)
        self._buyLabels[labelPos]:setPositionX(self._physicalPosX)
        self._buyLabels[labelPos]:setString( greenNum .. "/" .. maxNum)
    end
end

-- 重算资源条各图标的位置
function UserInfoView:resetIconPos( )
    -- 如果 资源条 显示4个 缩减相互之间的距离
    -- 四个弃用
    local i = 4
    self._icons[i]:setVisible(false)
    self._boards[i]:setVisible(false)
    self._buyBtns[i]:setVisible(false)
    self._buyLabels[i]:setVisible(false)
    if true then return end
    if #self.btnTypes == 4 then
        for i=1,4 do
            local offsetX = -25 - (i-1)*25
            if i == 1 then offsetX = -20 end

            if i == 4 and self.btnTypes[3] == "MapHurt" then
                offsetX = - 150
            end
            self._icons[i]:setPositionX(self._initResPoses[i][1]+offsetX)
            self._boards[i]:setPositionX(self._initResPoses[i][2]+offsetX)
            self._buyBtns[i]:setPositionX(self._initResPoses[i][3]+offsetX)
            self._buyLabels[i]:setPositionX(self._initResPoses[i][4]+offsetX)
            if i == 3 and self.btnTypes[3] == "MapHurt" then       -- 损伤值换行
                self._icons[i]:setPosition(self._initResPoses[2][1]-150,self._initResPoses[2][1+4])
                self._boards[i]:setPosition(self._initResPoses[2][2]-150,self._initResPoses[2][2+4])
                self._buyBtns[i]:setPosition(self._initResPoses[2][3]-150,self._initResPoses[2][3+4])
                self._buyLabels[i]:setPosition(self._initResPoses[2][4]-150,self._initResPoses[2][4+4])
                self._buyLabels[i]:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
            end
        end
    else                       -- 默认按三个重设位置
        for i=1,4 do
            self._icons[i]:setPositionX(self._initResPoses[i][1])
            self._boards[i]:setPositionX(self._initResPoses[i][2])
            self._buyBtns[i]:setPositionX(self._initResPoses[i][3])
            if i~=3 then
                self._buyLabels[i]:setPositionX(self._initResPoses[i][4])
                if self.btnTypes[3] == "MapHurt" then
                    self._buyLabels[i]:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
                else
                    self._buyLabels[i]:disableEffect()
                end
            else
                if self.btnTypes[3] == "MapHurt" then       -- 损伤值换行
                    self._icons[i]:setPosition(self._initResPoses[2][1]-50,self._initResPoses[2][1+4])
                    self._boards[i]:setPosition(self._initResPoses[2][2]-50,self._initResPoses[2][2+4])
                    self._buyBtns[i]:setPosition(self._initResPoses[2][3]-50,self._initResPoses[2][3+4])
                    self._buyLabels[i]:setPosition(self._initResPoses[2][4]-50,self._initResPoses[2][4+4])
                    self._buyLabels[i]:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
                else
                    self._icons[i]:setPosition(self._initResPoses[3][1],self._initResPoses[3][1+4])
                    self._boards[i]:setPosition(self._initResPoses[3][2],self._initResPoses[3][2+4])
                    self._buyBtns[i]:setPosition(self._initResPoses[3][3],self._initResPoses[3][3+4])
                    self._buyLabels[i]:setPositionY(self._initResPoses[3][4+4])
                    self._buyLabels[i]:disableEffect()
                end
            end
            if i == 4 then
                self._icons[i]:setVisible(false)
                self._boards[i]:setVisible(false)
                self._buyBtns[i]:setVisible(false)
                self._buyLabels[i]:setVisible(false)
            end
        end
    end
end

--
function UserInfoView:applicationWillEnterForeground(second)
    self._upDateFunc()
end

function UserInfoView:isBigPrivilege()
    local guildPower = tab:Setting("G_INITIAL_GUILDPOWER_MAX").value or 0
    local guildPowerBuff1 = self._modelMgr:getModel("PrivilegesModel"):getPeerageEffect(PrivilegeUtils.peerage_ID.AlliancePower1)
    local guildPowerBuff = self._modelMgr:getModel("PrivilegesModel"):getPeerageEffect(PrivilegeUtils.peerage_ID.AlliancePowerMax)
    guildPower = guildPower + guildPowerBuff + guildPowerBuff1
    return guildPower
end

function UserInfoView:getIconsArr()
    return self._icons or {}
end
return UserInfoView