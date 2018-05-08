--[[
    Filename:    GuildView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-04-18 21:33:07
    Description: File description
--]]

-- 联盟主场景
local GuildView = class("GuildView", BaseView, require("game.view.guild.GuildBaseView"))

function GuildView:ctor(data)
    GuildView.super.ctor(self)

    self._gemBubbleIndex = nil
    self._redBubbleIndex = nil
    self._activeRun = false
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("guild.GuildView")
            self:onExit()
        elseif eventType == "enter" then 
            self:onEnter()
        end
    end)
    

    self._userModel = self._modelMgr:getModel("UserModel")
end

function GuildView:onInit()
    self._modelMgr:getModel("GuildModel"):setQuitAlliance(false)
    -- self:listenReflash("UserModel", self.reflashQuitAlliance)
    self:listenReflash("GuildModel", self.hadNewBtnInfo)
    self:listenReflash("GuildMapModel", self.hadNewBtnInfo)
    self:listenReflash("ArrowModel", self.hadNewBtnInfo)
    self:listenReflash("PlayerTodayModel", self.hadNewBtnInfo)

    self._guildMapModel = self._modelMgr:getModel("GuildMapModel")

    local guildImageLeft = self:getUI("imageBg.guildImageLeft")
    local guildImageright = self:getUI("imageBg.guildImageright")
    guildImageLeft:loadTexture("asset/bg/bg_guildLeft.jpg")
    guildImageright:loadTexture("asset/bg/bg_guildRight.jpg")


    --去掉坐标的适配 
    -- guildImage:setPosition(cc.p(MAX_SCREEN_WIDTH*0.5+(1136-MAX_SCREEN_WIDTH), MAX_SCREEN_HEIGHT*0.5+(640-MAX_SCREEN_HEIGHT)*0.5))
    -- local bg = self:getUI("bg")
    -- for k,v in pairs(bg:getChildren()) do
    --     v:setPositionX(v:getPositionX()+(1136-MAX_SCREEN_WIDTH)*0.5)
    -- end

    -- if MAX_SCREEN_WIDTH < 1136 then
    --     -- guildImage:setPosition(cc.p(MAX_SCREEN_WIDTH*0.5+(1136-MAX_SCREEN_WIDTH), MAX_SCREEN_HEIGHT*0.5))
    --     guildImage:setPosition(cc.p(MAX_SCREEN_WIDTH*0.5+176, MAX_SCREEN_HEIGHT*0.5))
    --     local bg = self:getUI("bg")
    --     for k,v in pairs(bg:getChildren()) do
    --         v:setPositionX(v:getPositionX()+88)
    --         -- v:setPositionX(v:getPositionX()+(MAX_SCREEN_WIDTH-1136)*0.5)
    --     end
    -- end
    -- guildImage:setVisible(true)

    self:setAnim(2)
    -- self:setAnim(1)
    local zhanbao = self:getUI("bg.zhanbao")
    self._zhanbaoAnim = mcMgr:createViewMC("lianmengzhanbao_lianmengtansuochuansongmen", true, false)
    self._zhanbaoAnim:setPosition(cc.p(zhanbao:getContentSize().width*0.5, zhanbao:getContentSize().height*0.5))
    self._zhanbaoAnim:gotoAndStop(1)
    zhanbao:setLocalZOrder(-1000)
    zhanbao:addChild(self._zhanbaoAnim)
    self:registerClickEvent(zhanbao, function()
        self._viewMgr:showDialog("guild.map.GuildMapLogDialog", {}, true)
        self._modelMgr:getModel("GuildMapModel"):getData()
        local guildMapData = self._modelMgr:getModel("GuildMapModel")
        guildMapData:updateReportState(0)
    end)

    -- local manage = self:getUI("bg.manage")
    -- local science = self:getUI("bg.science")
    -- science:setVisible(false)

    local closeBtn = self:getUI("closeBtn")
    self:registerClickEvent(closeBtn, function()
        self:close()
    end)

    -- local gonggao = self:getUI("bg.gonggao")
    -- self:registerClickEvent(gonggao, function()
    --     self._viewMgr:showDialog("guild.dialog.GuildChangeADDialog")
    -- end)

    -- local everygift = self:getUI("bg.everygift")
    -- self:registerClickEvent(everygift, function()
    --     local dayinfo = self._modelMgr:getModel("PlayerTodayModel"):getData()
    --     if dayinfo["day47"] == 1 then
    --         self._viewMgr:showTip("您已领取过今日礼包，请明天再来")
    --         return
    --     end
    --     self._viewMgr:showDialog("guild.dialog.GuildTipGiftDialog")
    -- end)

    ---pad 分辨率适配每日礼包文字
    -- local dayGift = self:getUI("bg.btnName11")
    -- if dayGift then
    --     if MAX_SCREEN_WIDTH < 1136 then
    --        dayGift:setPositionX(dayGift:getPositionX()+(MAX_SCREEN_WIDTH-960)/2-40)
    --     end
    -- end

    for i=1,GuildConst.BUTTON_INPUT do
        local btnName = self:getUI("bg.btnName" .. i)
        -- btnName:setLocalZOrder(-1000)
        if i == 6 or i==12 then
            btnName:setLocalZOrder(10000)
        end
    end

    for i=1,6 do
        local image = self:getUI("bg.image" .. i)
        if image then
            image:setLocalZOrder(-1*image:getPositionY())
        end
    end

    local npc = {1,6,7,9,10}
    for _,index in pairs (npc) do 
        local image = self:getUI("bg.image" .. index)
        image:setLocalZOrder(-1000)
    end

    local taozi1 = self:getUI("bg.taizi_left")
    local taozi2 = self:getUI("bg.taizi_right")
    taozi1:setLocalZOrder(-999)
    taozi2:setLocalZOrder(-999)

    self._stopSpAction = false

    self._tabEventTarget = {}
    for i=1,GuildConst.BUTTON_INPUT do
        local btn = self:getUI("bg.btn" .. i)
        btn:setZOrder(5000)
        self:registerClickEvent(btn, function(sender)self:tabButtonClick(sender,i) end)
         table.insert(self._tabEventTarget, btn)
    end

    --by wangyan 聊天
    self._chatNode = require("game.view.global.GlobalChatNode").new("guild")
    self._chatNode:setAnchorPoint(0, 0.5)
    
    self:addChild(self._chatNode, 100)
    local label = cc.Label:createWithTTF("聊天", UIUtils.ttfName, 14)
    label:setColor(cc.c3b(255, 255, 255))
    label:enableOutline(cc.c4b(60, 30, 10, 255), 2)
    label:setPosition(26, 10)
    label:setName("31555")
    self._chatNode:addChild(label, 9999)

    local chatListen = function(self, param)
        if self._chatNode ~= nil and self._chatNode.showChatUnread ~= nil then
            self._chatNode:showChatUnread(param)
        end
    end
    self:setListenReflashWithParam(true)
    self:listenReflash("ChatModel", chatListen)
    self:listenReflash("PlayerTodayModel", chatListen)

    -- btn1:setTitleColor(cc.c3b(255, 255, 255))
    -- btn1:getTitleRenderer():enable2Color(1, cc.c4b(230, 230, 230, 255))
    -- btn1:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 255), 2) 
    -- btn1:setTitleFontSize(46)

    -- 初始化建筑名称
    for i=1,GuildConst.BUTTON_INPUT do
        local title = self:getUI("bg.btnName" .. i .. ".title")
        if title then
            title:setFontSize(20)
            title:setFontName(UIUtils.ttfName)
            title:setColor(UIUtils.colorTable.ccBuildNameColor)
            title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        end
    end
    
    self._viewNames = {
            {"guild.manager.GuildManageView"},      -- 大厅
            {"guild.rank.GuildRankView"}, -- 排行榜 {"guild.dialog.GuildChangeADDialog"},    -- 公告板
            {"guild.science.GuildScienceView"},     -- 科技
            {"shop.ShopView"},    -- 商店
            {},    -- 联盟战
            {"guild.map.GuildMapView"},    -- 大地图
            {},    -- BOSS战 
            {"guild.backup.GuildBackupView"},    -- 增援 
            {"guild.redgift.GuildRedView"}, -- {"guild.redgift.GuildRedView"},    -- 红包 
            {"activity.arrow.ArrowView"}, -- {"guild.redgift.GuildRedView"},    -- 射箭
            {"guild.dialog.GuildChangeADDialog"},
            {"guild.mercenary.GuildMercenaryView"} -- 联盟佣兵
        }
    self:showZuanShiQiPao()
    self._redBubble = self:getUI("bg.red_qipao")
    self:checkRedBubble()

    self._newPos = self._modelMgr:getModel("GuildModel"):getPlayPos()
    if self._redBubbleIndex or self._gemBubbleIndex then
        self._newPos = self._gemBubbleIndex or self._redBubbleIndex
    end

    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("guild.GuildView")
            self:onExit()
        elseif eventType == "enter" then 
            self:onEnter()
        end
    end)

    self:setMemberMove()


    --------------------泉水特效----------------------
    local quanshui = self:getUI("bg.Image_56")
    local mc1 = mcMgr:createViewMC("dabenyingpenquan_chuansongmen", true, false)
    mc1:setPosition(cc.p(quanshui:getContentSize().width*0.5, quanshui:getContentSize().height*0.5-68))
    quanshui:addChild(mc1)
    quanshui:setScaleX(1136/1022)
    quanshui:setScaleY(776/698)
    --------------------------------------------------

    local chuansongmen = self:getUI("bg.chuansongmen")
    chuansongmen:setScaleX(1136/1022)
    chuansongmen:setScaleY(776/698)

    self:showRoleAnima()
    
    if GameStatic.appleExamine == true then
        local Redtitle = self:getUI("bg.btnName9")
        if Redtitle then
            Redtitle:setVisible(false)
        end

        local redbtn = self:getUI("bg.btn9")
        if redbtn then
            redbtn:setVisible(false)
        end
    end

end

function GuildView:showRoleAnima()
    local aniName = {"shensheshou","lianmengzongguan","caiwuguan","lianmengkeji","lianmengshangren"}
    local btnName = {"btn10","btn1","btn9","btn3","btn4"}
    local pos = {cc.p(18,-76),cc.p(4,-60),cc.p(10,-40),cc.p(8,-30),cc.p(10,-60)}
    local hideImage = {"image7","image1","image6","image9","image10"}

    for i=1,5 do 
        local btn = self:getUI("bg."..btnName[i])
        local mc1 = mcMgr:createViewMC(aniName[i].."_lianmengxiaoren", true, false)
        mc1:setPosition(cc.p(btn:getPositionX()+pos[i].x,btn:getPositionY()+pos[i].y))
        self:getUI("bg"):addChild(mc1,-1000)

        local image = self:getUI("bg."..hideImage[i])
        if image then
            image:setVisible(false)
        end

        if GameStatic.appleExamine == true and i == 3 then
            mc1:setVisible(false)
        end
    end

end

function GuildView:checkRedBubble()
    if GameStatic.appleExamine == true then
        self._redBubble:setVisible(false)
        return
    end
    local isShowBubble = self._modelMgr:getModel("GuildRedModel"):isShowHalfRed()
    if isShowBubble then
        self._redBubble:setVisible(true)
        local richBg = self._redBubble:getChildByFullName("richPanel")
        if not richBg:getChildByName("richChild") then
            local richText = RichTextFactory:create(lang("GUILD_RED_REWARD"), richBg:getContentSize().width, richBg:getContentSize().height)
            richText:formatText()
            richText:setPositionY(richBg:getContentSize().height/2-2)
            richText:setPositionX(richBg:getContentSize().width/2+6)
            richText:setName("richChild")
            richBg:addChild(richText,11)
            local scale = 1
            local seq = cc.Sequence:create(cc.ScaleTo:create(2, scale+scale*0.1), cc.ScaleTo:create(2, scale))
            self._redBubble:runAction(cc.RepeatForever:create(seq))
        end
        self._redBubbleIndex = 9
    else
        self._redBubbleIndex = nil
        self._redBubble:setVisible(false)
    end

end

function GuildView:showZuanShiQiPao()

    self._modelMgr:getModel("MainViewModel"):checkTipsQipao24()
    local gemQipao = self._modelMgr:getModel("GuildModel"):getGemQipao() 
    local zuanshi = self:getUI("bg.zuanshi")
    local richBg = self:getUI("bg.zuanshi.richPanel")
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local role_pos = userData.roleGuild.pos

    if GameStatic.appleExamine == true then
        zuanshi:setVisible(false)
        return
    end

    if gemQipao == true then
        if not richBg:getChildByName("richChild") then
            local richStr = role_pos == 1 and lang("GUILD_QQ_REWARD") or lang("GUILD_QQ1_REWARD")
            local label1 = RichTextFactory:create(richStr, richBg:getContentSize().width, richBg:getContentSize().height)
            label1:formatText()
            label1:setPositionY(richBg:getContentSize().height/2-2)
            label1:setPositionX(richBg:getContentSize().width/2+6)
            label1:setName("richChild")
            richBg:addChild(label1,11)
            zuanshi:setVisible(true)
            local scale = 1
            local seq = cc.Sequence:create(cc.ScaleTo:create(2, scale+scale*0.1), cc.ScaleTo:create(2, scale))
            zuanshi:runAction(cc.RepeatForever:create(seq))
        end
        self._gemBubbleIndex = 1
    else
        self._gemBubbleIndex = nil
        zuanshi:setVisible(false)
    end

    
end

function GuildView:onShow()
    if self._chatNode and self._chatNode.showChatUnread then
        self._chatNode:showChatUnread("priUnread")
    end
end

function GuildView:setAnim(flag)
    if flag == 1 then -- 传送门开启
        local chuansongmen = self:getUI("bg.chuansongmen")
        local mc1 = mcMgr:createViewMC("die_chuansongmen", false, true)
        mc1:setPosition(cc.p(chuansongmen:getContentSize().width*0.5-36, chuansongmen:getContentSize().height*0.5+40))
        chuansongmen:addChild(mc1)
    elseif flag == 2 then -- 传送门
        local chuansongmen = self:getUI("bg.chuansongmen")
        local mc1 = mcMgr:createViewMC("stop_chuansongmen", true, false)
        mc1:setPosition(cc.p(chuansongmen:getContentSize().width*0.5-38, chuansongmen:getContentSize().height*0.5+20))
        chuansongmen:setLocalZOrder(-500)
        mc1:setScaleX(0.9)
        chuansongmen:addChild(mc1)
    end
end

-- 每日首次进入联盟
function GuildView:showFirstAD()
    local flag = self._modelMgr:getModel("GuildModel"):getGuildADFristShow()
    local guildAnimLvl = self._modelMgr:getModel("GuildModel"):getAllianceOpenActionLevel()
    if flag == true and guildAnimLvl == 1 then
        self._viewMgr:showView("guild.manager.GuildManageView")
        -- self._viewMgr:showDialog("guild.dialog.GuildChangeADDialog")
    end
end

-- 红点提示
function GuildView:hadNewBtnInfo()
    local userModel = self._modelMgr:getModel("UserModel")
    local userData = userModel:getData()
    local guildModel = self._modelMgr:getModel("GuildModel")
    local dayinfo = self._modelMgr:getModel("PlayerTodayModel"):getData()
    -- dump(userData.guildBackup, "guildBackup ===", 10)
    -- dump(userData, "userModel ===", 2)

    -- 等级开屏判断，名字隐藏处理【先判断等级开启，再判断红点】
    for i=1,table.nums(self._viewNames) do
        local btnName = self:getUI("bg.btnName" .. i)
        local configData = tab:GuildRoad(i)
        if not configData then return end
        local limit = configData.limit
        local level = self._modelMgr:getModel("GuildModel"):getAllianceDetail().level
        -- local level = userModel:getData().guildLevel

        if btnName then
            if level < limit then 
                btnName:setVisible(false)
            else
                btnName:setVisible(true)
            end
        end
    end

    local noticeMap = {
        -- 大厅
        {iconName = "bg.btnName1",detectFuc = function()
            local flag = false
            if self._modelMgr:getModel("UserModel"):getData()["roleGuild"]["pos"] ~= 3 then
                if userData.guildApply ~= 0 then
                    flag = true
                end
            end
            return flag 
        end},
        -- 科技
        {iconName = "bg.btnName3",detectFuc = function()
            local flag = false
            local userGuildData = self._modelMgr:getModel("UserModel"):getRoleAlliance()
            local times = guildModel:getDonateTimes()
            if userGuildData.dTimes < times then
                flag = true
            end

            if flag == false then
                local scienceBase = guildModel:getAllianceDetail()
                for i=1,3 do
                    if dayinfo["day" .. (17+i)] == 0 then
                        local sciRewardTab = tab:GuildContriReward(i)
                        if scienceBase.todayExp and scienceBase.todayExp >= sciRewardTab.condition then
                            return true
                        end
                    end
                end
            end
            return flag -- self._modelMgr:getModel("GuildModel"):haveNoticeScience()
        end},
        -- 大地图
        {iconName = "bg.btnName6", qipao = true, _x = -50, _y = 30, detectFuc = function()
            local flag = self._modelMgr:getModel("GuildMapModel"):checkGuildMapRedpoint()
            return flag 
        end},
        -- 增援
        {iconName = "bg.btnName8",detectFuc = function()
            local flag = false
            local guildBackup = userData.guildBackup
            local temptime = userModel:getCurServerTime()
            if guildBackup and guildBackup.askCD then
                if guildBackup.askCD - temptime <= 0 then
                    flag = true
                end
            elseif guildBackup.askCD == nil then
                flag = true
            end
            return flag 
        end},
        -- 红包
        {iconName = "bg.btnName9",detectFuc = function()
            local flag = false
            local bubble = guildModel:getBubbleData()
            -- if self._modelMgr:getModel("GuildRedModel"):isRedTipButtle() == false then
            --     flag = true
            -- end
            if bubble["1"] == 1 then
                flag = true
            end
            return flag 
        end},
        -- 射箭
        {iconName = "bg.btnName10",detectFuc = function()
            local flag = self._modelMgr:getModel("ArrowModel"):checkIsCDRedpoint()
            return flag 
        end},
        -- 每日礼包
        {iconName = "bg.btnName11",detectFuc = function()
            local flag = true
            local dayinfo = self._modelMgr:getModel("PlayerTodayModel"):getData()
            if dayinfo["day47"] == 1 then
                flag = false
            end
            return flag 
        end},
        --雇佣兵红点
        {iconName = "bg.btnName12",detectFuc = function()
            local flag = self._modelMgr:getModel("GuildModel"):checkMercenaryRed()
            return flag 
        end},

    }

    -- 红点处理
    for k,v in pairs(noticeMap) do
        local hint = false
        if v.detectFuc then
            hint = v.detectFuc()
        end
        if v.qipao then
            self:setHintQipao(v.iconName, hint, v._x, v._y)
        else
            self:setHintTip(v.iconName, hint)
        end
    end

    local reportState = self._guildMapModel:getReportState()
    if reportState == 1 then
        self._zhanbaoAnim:gotoAndPlay(1)
    else
        self._zhanbaoAnim:gotoAndStop(1)
    end

    if GameStatic.appleExamine == true then
        local Redtitle = self:getUI("bg.btnName9")
        if Redtitle then
            Redtitle:setVisible(false)
        end
    end
end

function GuildView:setHintTip(btnName, hint)
    local btnName = self:getUI(btnName)
    if not btnName then
        return
    end
    if btnName then
        btnNameTip = btnName:getChildByName("btnNameTip")
        if btnNameTip then
            btnNameTip:setVisible(hint)
        else
            btnNameTip = cc.Sprite:createWithSpriteFrameName("globalImageUI_bag_keyihecheng.png")
            btnNameTip:setName("btnNameTip")
            btnNameTip:setAnchorPoint(cc.p(0,0))
            btnNameTip:setScale(0.7)
            btnNameTip:setPosition(cc.p(btnName:getContentSize().width - 10, btnName:getContentSize().height*0.5 - 3))
            btnName:addChild(btnNameTip, 10)
            btnNameTip:setVisible(hint)
        end
    end
end

function GuildView:setHintQipao(btnName, hint, _x, _y)
    local btnName = self:getUI(btnName)
    if not btnName then
        return
    end
    if btnName then
        btnNameTip = btnName:getChildByName("btnNameTip")
        if btnNameTip then
            btnNameTip:setVisible(hint)
        else
            btnNameTip = cc.Sprite:createWithSpriteFrameName("qipao_max.png")
            btnNameTip:setName("btnNameTip")
            btnNameTip:setAnchorPoint(cc.p(0,0))
            btnNameTip:setPosition(_x, _y)
            btnName:addChild(btnNameTip, 10)
            btnNameTip:setVisible(hint)
            local scale = 1
            local seq = cc.Sequence:create(cc.ScaleTo:create(1, scale+scale*0.2), cc.ScaleTo:create(1, scale))
            btnNameTip:runAction(cc.RepeatForever:create(seq))
        end
    end
end

function GuildView:tabButtonClick(sender, indexId)
    printf("GuildView:tabButtonClick indexId == %d,name = %s",indexId,sender:getName())
    local guildId = self._modelMgr:getModel("UserModel"):getData().guildId
    if not guildId or guildId == 0 then
        self._viewMgr:showTip("你已被踢出联盟！")
        self._viewMgr:returnMain()
        return
    end

    local callback = function(indexId,isStopMove)
        local indexId = indexId
        if isStopMove ~= 1 then
            indexId = self._newPos
        end

        local limit = tab:GuildRoad(indexId).limit
        local level = self._modelMgr:getModel("GuildModel"):getAllianceDetail().level
        -- local level = self._modelMgr:getModel("UserModel"):getData().guildLevel
        -- dump(self._modelMgr:getModel("GuildModel"):getAllianceDetail(),"+++++++++")
        -- print("level < limit=====",level)
        -- level = 0
        if level < limit then
            self._viewMgr:showTip(lang(tab:GuildRoad(indexId).tip))
            return
        end

        if self._viewNames[indexId] and self._viewNames[indexId][1] then
            print("callback =========",self._viewNames[indexId][1])
            if indexId == 2 then
                self._viewMgr:showView("guild.rank.GuildRankView", {rankType = 7}, true)
            elseif indexId == 4 then
                self._viewMgr:showView("shop.ShopView",{idx = 5})
            elseif indexId == 9 then
                ---[[
                local guildRedModel = self._modelMgr:getModel("GuildRedModel")
                local isRed = guildRedModel:isRedChaoshi()
                if isRed == true then
                    self._viewMgr:showView(self._viewNames[indexId][1])
                else
                    self._viewMgr:showTip("第二天5点可进入该功能")
                end
                --]]
                -- self._viewMgr:showView(self._viewNames[indexId][1])
            elseif indexId == 11 then
                -- self._viewMgr:showDialog("guild.dialog.GuildChangeADDialog")
                local dayinfo = self._modelMgr:getModel("PlayerTodayModel"):getData()
                if dayinfo["day47"] == 1 then
                    self._viewMgr:showTip("您已领取过今日礼包，请明天再来")
                    return
                end
                self._viewMgr:showDialog("guild.dialog.GuildTipGiftDialog")
            elseif indexId == 12 then
                local userLevel = self._modelMgr:getModel("UserModel"):getData().lvl
                local limitLevel = tab:SystemOpen("Lansquenet")[1]
                if tonumber(userLevel) < tonumber(limitLevel) then
                    self._viewMgr:showTip(lang("OPEN_LANSQUENET_TIP2"))
                    return
                end
                self._viewMgr:showView(self._viewNames[indexId][1])
            else
                self._viewMgr:showView(self._viewNames[indexId][1])
            end
        end
    end

    local limit = tab:GuildRoad(indexId).limit
    local level = self._modelMgr:getModel("GuildModel"):getAllianceDetail().level

    print(limit)
    print(level)
    if level < limit then
        self._viewMgr:showTip(lang(tab:GuildRoad(indexId).tip))
        return
    end

    if self._newPos == indexId then
        callback(indexId)
        return
    end

    -- if not self._viewNames[indexId] and self._viewNames[indexId][1] == nil then
    --     return 
    -- end

    if self._stopSpAction == true and self._mcBg then
        self._mcBg:stopAllActions()
    end
    
    local pos = tab:GuildRoad(self._newPos)["b" .. indexId]
    if not pos then 
        callback(indexId,1)
        return 
    end
    self._activeRun = true
    self:setPoint(self._indexId, pos, indexId, callback)
    self._modelMgr:getModel("GuildModel"):setPlayPos(indexId)
    self._newPos = indexId
    callback(indexId)
end


-- 瞎小人移动
function GuildView:setMemberMove()
    
    local callfunc = cc.CallFunc:create(function()
        if table.nums(self._members) < 2 then
            return
        end
        local rand = GRandom(7)
        if rand == 5 or rand == 7 then 
            rand = 1 
        end
        local play = GRandom(table.nums(self._members)) -- self._members[i].rand
        print("play == self._indexId ", play , self._indexId)
        if play == self._indexId then
            return
        end

        local limit = tab:GuildRoad(rand).limit
        local level = self._modelMgr:getModel("GuildModel"):getAllianceDetail().level
        if level < limit then
            -- self._viewMgr:showTip(lang(tab:GuildRoad(rand).tip))
            return
        end

        local pos = tab:GuildRoad(self._members[play].rand)["b" .. rand]
        self._members[play].rand = rand
        -- print("play =============", play, self._members[play].rand)

        self:setPoint(play, pos, rand)
    end)
    
    local repeat1 = cc.Repeat:create(cc.Sequence:create(cc.DelayTime:create(10),callfunc), 6)
    local repeat2 = cc.Repeat:create(cc.Sequence:create(cc.DelayTime:create(20),callfunc), 9)
    local repeat3 = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(40),callfunc))
    self:runAction(cc.Sequence:create(repeat1, repeat2, repeat3))

end

function GuildView:setPoint(index, pos, rand, callback)
    local tempMove = {}
    if pos == nil then
        print("表有问题，找xbw",index, self._members[index].rand)
        return
    end
    for i,v in ipairs(pos) do
        local point = tab:GuildPoint(v[1]) -- cc.p(v[1],v[2])
        local last
        local begin

        if v[2] == 2 then
            begin = table.nums(point.point) - 1
            last = 1
            if i == 1 then
                begin = table.nums(point.point)
            end
            for j=begin,last,-1 do
                local vv = point.point[j]
                vv[3] = v[2]
                table.insert(tempMove, vv)
            end
        elseif v[2] == 1 then
            last = table.nums(point.point)
            begin = 2
            if i == 1 then
                begin = 1
            end
            for j=begin,last do
                local vv = point.point[j]
                vv[3] = v[2]
                table.insert(tempMove, vv)
            end
        end
    end
    self:setMove(index, tempMove, rand, callback)

    -- loadstring(response.patch)()
    -- cc.Sequence:create(arrayOfActions)
end

function GuildView:setMove(index, point, rand, callback)
    
    callback = nil
    local movePoint = {}
    local pos1 = 0
    local xishuX = 1136/1136
    local xishuY = 640/640
    -- local tempX = (1136-MAX_SCREEN_WIDTH)*0.5 -- 1022*0.5 - MAX_SCREEN_WIDTH*0.5
    local tempX = 0 --适配pad,去掉偏移修正
    local tempY = 0 -- 576*0.5 - MAX_SCREEN_HEIGHT*0.5 -- + 32
    -- if MAX_SCREEN_WIDTH < 1136 then
    --     tempX = tempX + 88
    -- end
    -- if MAX_SCREEN_HEIGHT < 576 then
    --     tempY = 576*0.5 - MAX_SCREEN_HEIGHT*0.5
    -- end
    -- print("xishuX =====", xishuX, xishuY, tempX, tempY)
    -- xishu = 1
    -- for i,v in ipairs(point) do
    local time = 0
    for i=1,table.nums(point) do
        if i > 1 then
            pos1 = i
            local x = point[i][1]*xishuX + tempX -- + GRandom(40)
            local y = point[i][2]*xishuY + tempY -- + GRandom(40)
            if i == table.nums(point) then
                -- print("point========", point[i][1], point[i][2])
                x = point[i][1]*xishuX + tempX -- + GRandom(10)
                y = point[i][2]*xishuY + tempY -- + GRandom(10)
                -- print("x =========", x, y)
            end
            time = time+0.3
            local move = cc.MoveTo:create(0.3,cc.p(x,y))
            local rotaion = cc.RotateBy:create(0,0)
            local callFunc = cc.CallFunc:create(function()
                local lastPointX = point[i - 1][1]*xishuX + tempX
                local pointX = point[i][1]*xishuX + tempX
                if self._mcs[index].sp then
                    if lastPointX > pointX then
                        self._mcs[index].sp:setScaleX(-0.3)
                    else
                        self._mcs[index].sp:setScaleX(0.3)
                    end
                end

                -- local lastPointX = point[i - 1][2]*xishuY -- + tempY
                -- local pointX = point[i][2]*xishuY -- + tempY
                if self._mcs[index] then
                    self._mcs[index]:setLocalZOrder(-1*self._mcs[index]:getPositionY())
                end
            end)
            table.insert(movePoint, callFunc)
            table.insert(movePoint, move)
        end
    end
    local callFunc1 = cc.CallFunc:create(function()
        if callback then
            self._viewMgr:lock(-1)
        end
        -- self._viewMgr:lock(-1)
        self._stopSpAction = true
        self._mcs[index]:setVisible(true)
        if self._mcs[index].sp then
            -- self._mcs[index].sp:setScale(0.3)
            self._mcs[index].sp:changeMotion("run")
        end
        -- self._mcs[index].sp:play() 
    end)
    local callFunc2 = cc.CallFunc:create(function()
        -- self._viewMgr:unlock()
        self._stopSpAction = false
        if callback then
            self._viewMgr:unlock()
            callback(index)
        end
        if self._mcs[index] then
            if self._mcs[index].sp then
                self._mcs[index].sp:changeMotion("stop")
                self._mcs[index].sp:setScaleX(0.3)
            end
            self._mcs[index]:setLocalZOrder(-1 * self._mcs[index]:getPositionY())
        end
        print("index============", rand)
        if rand == 6 then
            -- local mc1 = mcMgr:createViewMC("die_lianmengtansuochuansongmen", true, false)
            -- mc1:setPosition(cc.p(0, 77))
            -- self._mcBg:addChild(mc1)
            local currTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
            local weekday = TimeUtils.date("%w", currTime)
            local flag = false
            if tonumber(weekday) == 1 then
                local minTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(currTime,"%Y-%m-%d 03:00:00"))
                local maxTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(currTime,"%Y-%m-%d 05:00:00"))
                if currTime >= minTime and currTime <= maxTime then
                    flag = true
                end
            end
            if flag == false then
                self:setAnim(1)
                self._mcs[index]:setVisible(false)
            end
            
            print('进入大地图特效')
        end
        -- self._mcs[index].sp:play()
        -- if self._updateId then
        --     ScheduleMgr:unregSchedule(self._updateId)
        --     self._updateId = nil
        -- end
    end)

    table.insert(movePoint,1, callFunc1)
    table.insert(movePoint, callFunc2)

    -- if self._members[play].rand == 5 then
    --     local callFunc3 = cc.CallFunc:create(function()
    --         print(···)
    --     end)
    --     table.insert(movePoint, callFunc3)
    -- end

    if not self._mcs[index] then
        self._viewMgr:showTip("数据出现问题，请联系管理员")
        return
    end
    self._mcs[index]:runAction(cc.Sequence:create(movePoint))


    -- print("index>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"..rand)
    
    if self._activeRun == true then
        self._activeRun = false
        if rand then
            local location = tab:GuildRoad(rand).location
            if location then
                self:viewMove(time,location)
            end
        end
    end
end

function GuildView:getForcePos()
    --根据气泡,强制修改玩家所在功能位置点
    local isShowBubble = self._modelMgr:getModel("GuildRedModel"):isShowHalfRed()
    self._modelMgr:getModel("MainViewModel"):checkTipsQipao24()
    local gemQipao = self._modelMgr:getModel("GuildModel"):getGemQipao() 
    return gemQipao and 1 or isShowBubble and 9
end


function GuildView:createSp()
    local mapBg = self:getUI("bg")
    local xishuX = 1136/1136
    local xishuY = 640/640
    -- local tempX = (1136-MAX_SCREEN_WIDTH)*0.5 -- 1022*0.5 - MAX_SCREEN_WIDTH*0.5
    local tempX = 0 --适配pad,去掉偏移修正
    local tempY = 0 -- 576*0.5 - MAX_SCREEN_HEIGHT*0.5 + 32
    -- if MAX_SCREEN_WIDTH < 1136 then
    --     tempX = tempX + 88
    -- end
    local pos
    local nowHeroD = 1
    local location
    self._mcs = {}
    local last = table.nums(self._members)

    for i = 1, last do
        local forcePos
        local isSelf
        if self._members[i]["memberId"] == self._modelMgr:getModel("UserModel"):getData()._id then
            nowHeroD = i
            forcePos = self:getForcePos()
            isSelf = true
        end
        if i == 1 then
            dump(self._members[i], "==============",10)
        end
        local heroD = tab:Hero(self._members[i]["heroId"])
        local skin = self._members[i]["hSkin"]
        local skinModel
        if skin then
            skinModel = tab:HeroSkin(skin).heroart
        end

        self._mcs[i] = ccui.Widget:create()
        self._mcs[i]:setContentSize(cc.size(10,10))
        local rand = GRandom(7)
        if rand == 5 or rand == 7 then
            rand = 1
        end
        self._members[i].rand = rand


        local limit = tab:GuildRoad(self._members[i].rand).limit
        local level = self._modelMgr:getModel("GuildModel"):getAllianceDetail().level
        if level < limit then
            -- self._viewMgr:showTip(lang(tab:GuildRoad(rand).tip))
            self._members[i].rand = 1
        end

        if forcePos and forcePos ~= false then
            pos = tab:GuildRoad(forcePos).position
        else
            pos = tab:GuildRoad(self._members[i].rand).position
        end
        self._mcs[i]:setPosition(cc.p(pos[1]*xishuX + tempX + GRandom(5), pos[2]*xishuY + tempY + GRandom(5)))
        mapBg:addChild(self._mcs[i])

        local str = (self._members[i].name or "没名字") -- .. " V" .. self._members[i].vipLvl
        self._mcs[i].lab = cc.Label:createWithTTF(str, UIUtils.ttfName, 16)
        self._mcs[i].lab:setAnchorPoint(cc.p(0.5,0.5))
        self._mcs[i].lab:enableOutline(cc.c4b(0,0,0,255), 1)
        self._mcs[i].lab:setPosition(cc.p(0,-20)) 
        self._mcs[i]:addChild(self._mcs[i].lab, 10)
        
        local str = "V" .. self._members[i].vipLvl
        self._mcs[i].vipLab = cc.Label:createWithTTF(str, UIUtils.ttfName, 16)
        self._mcs[i].vipLab:enableOutline(cc.c4b(0,0,0,255), 1)
        self._mcs[i].vipLab:setPosition(cc.p(self._mcs[i].lab:getContentSize().width*0.5 + 15,-20))
        self._mcs[i]:addChild(self._mcs[i].vipLab, 10)

        local tipbg = cc.Scale9Sprite:createWithSpriteFrameName("allianceScicene_playerNameBg.png")
        tipbg:setAnchorPoint(cc.p(0.5,0.5))
        tipbg:setContentSize(self._mcs[i].lab:getContentSize().width + 50, 25)
        tipbg:setOpacity(80)
        tipbg:setPosition(cc.p(self._mcs[i].lab:getContentSize().width*0.5-30, -20))
        self._mcs[i]:addChild(tipbg, -1)

        self._mcs[i]:setLocalZOrder(-1*self._mcs[i]:getPositionY())
        if self._members[i].rand == 6 and not isSelf then
            self._mcs[i]:setVisible(false)
        end
        -- 隐藏vip　by guojun
        local isHideVip = UIUtils:isHideVip(self._members[i].hideVip,"guild")
        if self._members[i].vipLvl == 0 or isHideVip then
            self._mcs[i].vipLab:setVisible(false)
            self._mcs[i].lab:setPositionX(self._mcs[i].lab:getPositionX()+10)
        elseif self._members[i].vipLvl < 5 then
            self._mcs[i].vipLab:setColor(cc.c3b(0,198,255))
        elseif self._members[i].vipLvl >= 5 and self._members[i].vipLvl < 10 then
            self._mcs[i].vipLab:setColor(cc.c3b(245,120,250))
        elseif self._members[i].vipLvl >= 10 then
            self._mcs[i].vipLab:runAction(cc.RepeatForever:create(cc.Sequence:create(
                    cc.TintTo:create(0.75, cc.c3b(255, 255, 120)),
                    cc.TintTo:create(0.75, cc.c3b(120, 255, 120)),
                    cc.TintTo:create(0.75, cc.c3b(120, 255, 255)),
                    cc.TintTo:create(0.75, cc.c3b(120, 120, 255)),
                    cc.TintTo:create(0.75, cc.c3b(255, 120, 255)),
                    cc.TintTo:create(0.75, cc.c3b(255, 120, 120))
                )))
        end

        -- self:registerClickEvent(self._mcs[i], function()
        --     print("===GuildPlayerDialog===========")
        --     self._viewMgr:showDialog("guild.GuildPlayerDialog", {detailData = self._members[i], dataType = 1}, true)
        -- end)
        local skin_name = skinModel or heroD.heroart
        HeroAnim.new(self._mcs[i], skin_name, {"stop", "run"}, function (mc)
            -- mc:setPosition(100 + i * 10, 320)
            mc:stop()
            mc:setScale(0.3)
            mc:changeMotion("stop")
            self._mcs[i].sp = mc
        end, false, nil, nil, false)
    end
    self._index = 1 
    self._updateId = ScheduleMgr:regSchedule(1, self, function(self, dt)
        local count = 0
        if not self._mcs or #self._mcs == 0 then return end
        while count < 5 do
            if self._mcs[self._index].sp then
                self._mcs[self._index].sp:autoUpdate()
            end
            self._index = self._index + 1
            if self._index > last then self._index = 1 end
            count = count + 1
        end
    end)
    print("nowHeroD ===========", nowHeroD)
    self._mcBg = self._mcs[nowHeroD]
    if not self._mcBg then
        nowHeroD = 1
        self._mcBg = self._mcs[1]
    end
    pos = tab:GuildRoad(self._newPos).position
    location = tab:GuildRoad(self._newPos).location

    if not self._mcBg then
        -- self._viewMgr:showTip("数据出现问题，请联系管理员")
        return
    end
    self._mcBg:setPosition(cc.p(pos[1]*xishuX + tempX,pos[2]*xishuY))
    -- self._mcBg:setZOrder(2)
    self._sp = self._mcs[nowHeroD].sp
    self._indexId = nowHeroD
    -- 
    local mc1 = mcMgr:createViewMC("jiantou_crusademap", true, false)
    mc1:setPosition(cc.p(6, 120))
    self._mcBg:addChild(mc1)
    -- self._mcBg:setVisible(true)
    -- self:showFirstAD()
    -- self._sp:changeMotion(1)
    -- self:checkRandRed()

    --初始化上下屏
    local moveY
    if location == 1 then
        moveY = -math.max(0,(776-MAX_SCREEN_HEIGHT)/2)
    elseif location == 2 then
        moveY= 0
    else
       moveY = math.max(0,(776-MAX_SCREEN_HEIGHT)/2)
    end
    self:setPositionY(moveY)
    if self._chatNode then
        -- self._chatNode:setPositionY(0)
        self._chatNode:setPosition(ADOPT_IPHONEX and 125 or 0, MAX_SCREEN_HEIGHT * 0.5-moveY)
    end

end


function GuildView:checkRandRed()
    local status = self._modelMgr:getModel("GuildModel"):getCheckRedStatus()
    if status == true then
        local consumeItem = self._modelMgr:getModel("ItemModel"):getConsumables()
        local idList = {}
        for _,data in pairs (consumeItem) do 
            local configData = tab.tool[data.goodsId]
            if configData.typeId == 11 then
                table.insert(idList,data.goodsId)
            end
        end
        if #idList >0 then
            self._viewMgr:showDialog("guild.dialog.GuildDropRedDialog",idList,true)
        end
    end

    -- self:viewMove()
end

function GuildView:viewMove(time,location)

    local moveY = 0
    if location == 1 then
        moveY = -math.max(0,(776-MAX_SCREEN_HEIGHT)/2)
    elseif location == 2 then
        moveY= 0
    else
       moveY = math.max(0,(776-MAX_SCREEN_HEIGHT)/2)
    end

    if self._curMoveType == location  then
        return
    end
    self._curMoveType = location
    self:stopAllActions()
    self:runAction(cc.MoveTo:create(time, cc.p(0, moveY)))

    if self._chatNode then
        self._chatNode:runAction(cc.MoveTo:create(time,cc.p(ADOPT_IPHONEX and 100 or 0,MAX_SCREEN_HEIGHT * 0.5-moveY)))
    end
end


-- function GuildView:setRoleMove(x,y,rad,isOrder)
--     self._sp:setRotation(rad)

--     self._sp:runAction(cc.MoveTo:create(5, cc.p(x, y)))
-- end

function GuildView:reflashUI()
    self._members = self._modelMgr:getModel("GuildModel"):getRunAllianceList()
    self:createSp()
    self:hadNewBtnInfo()
end

-- function GuildView:setNavigation()
--      self._viewMgr:showNavigation("global.UserInfoView",{hideHead = true})
-- end

function GuildView:getAsyncRes()
    return {
    -- {"asset/ui/alliance.plist", "asset/ui/alliance.png"},
    {"asset/ui/alliance3.plist", "asset/ui/alliance3.png"},
    {"asset/ui/alliance2.plist", "asset/ui/alliance2.png"},
    {"asset/ui/alliance1.plist", "asset/ui/alliance1.png"},
}
end

-- function GuildView:getBgName()
--     return "bg_008.jpg"
-- end

function GuildView:setNoticeBar()
    self._viewMgr:hideNotice(true)
end

function GuildView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{hideInfo = true, hideHead = true})
end

function GuildView:onBeforeAdd(callback, errorCallback)
    -- self._members = self._modelMgr:getModel("GuildModel"):getRunAllianceList()
    -- if table.nums(self._members) == 0 then
    local guildModel = self._modelMgr:getModel("GuildModel")
    if guildModel:isEmpty() then
        self._onBeforeAddCallback = function(inType)
            if inType == 1 then 
                callback()
            else
                errorCallback()
            end
        end
        self:getGuildInfo()
    else
        self:reflashUI()
        callback()
    end
end

function GuildView:getGuildInfo()
    print("===getGameGuildInfo=============================")
    self._serverMgr:sendMsg("GuildServer", "getGameGuildInfo", {}, true, {}, function (result)
        if self.getGuildInfoFinish then
            self:getGuildInfoFinish(result)
        end
    end)

end

function GuildView:onExit()
    if self._updateId then
        ScheduleMgr:unregSchedule(self._updateId)
        self._updateId = nil
    end
end

function GuildView:onEnter()

end

function GuildView:getGuildInfoFinish(result)
    -- dump(result)
    if result == nil then
        self._onBeforeAddCallback(2)
        return 
    end
    self._onBeforeAddCallback(1)
    self:reflashUI()
    self:isOpenAnim()
end

-- function GuildView:getMaxGuildLevel()
--     local flag = false
--     local userData = self._modelMgr:getModel("UserModel"):getData()
--     local guildLvl = userData.guildLevel
--     print("guildLevel=====", guildLvl)
--     if guildLvl == 2 or guildLvl == 3 or guildLvl == 4 then
--         local guildMaxLevel = SystemUtils.loadAccountLocalData("GUILD_LEVELMAX") or 1
--         print("=guildMaxLevel======", guildMaxLevel)
--         if guildLvl > tonumber(guildMaxLevel) then
--             -- SystemUtils.saveAccountLocalData("GUILD_LEVELMAX", guildLvl)
--             flag = true
--         end
--     end
--     SystemUtils.saveAccountLocalData("GUILD_LEVELMAX", 1)
--     return flag
-- end

-- 切换动画完毕时候调用, 界面动画在这里, 发请求最好也在这里
function BaseView:onAnimEnd()

end

-- 第一次进入界面会调用, 有需要请覆盖
function BaseView:onShow()

end

-- 成为topView会调用, 有需要请覆盖
function GuildView:onTop()
    if self._mcBg then
        self._mcBg:setVisible(true)
        self._mcBg:setLocalZOrder(-1*self._mcBg:getPositionY())
    end
   
    self:hadNewBtnInfo()
    self:isOpenAnim()

    self:showZuanShiQiPao()
    self:checkRedBubble()
    -- self._mcs[i]:setLocalZOrder(-1*self._mcs[i]:getPositionY())
end


function GuildView:isOpenAnim()
    -- self._modelMgr:getModel("GuildModel"):saveAllianceOpenAction(4)
    -- local guildAnimLvl = self._modelMgr:getModel("GuildModel"):getAllianceOpenActionLevel()
    -- print("guildAnimLvl==============", guildAnimLvl)
    -- if guildAnimLvl and guildAnimLvl ~= 1 then
    --     -- self._viewMgr:showDialog("guild.dialog.GuildLevelUpDialog")
    --     -- self:bofangdonghua(guildAnimLvl)
    --     -- self:actionOpen(guildAnimLvl)
    --     local callback = function()
    --         self:actionOpen(guildAnimLvl)
    --     end
    --     local userData = self._modelMgr:getModel("UserModel"):getData()
    --     local guildLvl = userData.guildLevel
    --     local param = {oldLevel = guildLvl-1, newLevel = guildLvl, callback = callback}
    --     self._viewMgr:showDialog("guild.dialog.GuildLevelUpDialog", param)
    -- end

    local guildModel = self._modelMgr:getModel("GuildModel")
    local userModel = self._modelMgr:getModel("UserModel")

    local function levelUpCheck()
        guildModel:resetBubbleData()
        local isUp,level = guildModel:checkIsLevelUp()
        if isUp == true then
            local callback = function()
                self:actionOpen(level)
            end
            local guildLvl = userModel:getData().guildLevel
            local param = {oldLevel = guildLvl-1, newLevel = guildLvl, callback = callback}
            self._viewMgr:showDialog("guild.dialog.GuildLevelUpDialog", param)
        else
            self:checkUserLevelUpFun()
        end
        guildModel:saveBubbleModify()
    end

    --进联盟首次弹广告  wangyan
    local adList = guildModel:checkIsAdShow()
    if adList and #adList > 0 then
        self._viewMgr:showDialog("guild.GuildAdView", {adList = adList, callback = function()
            levelUpCheck()
            end}, true)

        local currTime = userModel:getCurServerTime()
        local revertTime = TimeUtils.formatTimeToFiveOclock(currTime)
        SystemUtils.saveAccountLocalData("GUILD_IS_SHOWED_AD", revertTime)
    else
        levelUpCheck()
    end
       
    -- self:bofangdonghua(2)
    -- self:actionOpen(2)


    -- local bubble = self._modelMgr:getModel("PlayerTodayModel"):getBubble()
    -- local guildMaxLevel = bubble["b3"] or 1
    -- if self._guildMaxLevel ~= 1 then
    --     guildMaxLevel = self._guildMaxLevel -- 如果开启联盟升级以后
    -- end
    -- if guildLvl > tonumber(guildMaxLevel) then
    --     flag = true
    -- end
end

--[[
    检测玩家升级触发得功能开启,可能会是多个功能同事
]]
function GuildView:checkUserLevelUpFun()

    self._openFunList = {}
    local playerLevel = self._userModel:getData().lvl
    ----60级雇佣兵
    local limitLevel = tab:SystemOpen("Lansquenet")[1]
    if limitLevel <= playerLevel then
        local flag = SystemUtils.loadAccountLocalData("GUILD_OPEN_LANSQUENET")
        if not flag then
            local param = {
                btn = "bg.btn12",
                name = "LANSQUENET_NAME",
                system = "Lansquenet"
            }
            self._openFunList[#self._openFunList+1] = param 
        end
    end

    ------------------------------------------------------------
    local function BeginAnima()
        local data = self._openFunList[self._openAnimaIndex]
        if data then
            self._viewMgr:lock(-1)
            local btn = self:getUI(data.btn)
            if btn then
                local btnPos = btn:convertToWorldSpace(cc.p(btn:getContentSize().width*0.5, btn:getContentSize().height*0.5))
                local rect1 = cc.rect(MAX_SCREEN_WIDTH*0.2, 0, MAX_SCREEN_WIDTH*(1-0.4), MAX_SCREEN_HEIGHT)
                local flag = cc.rectContainsPoint(rect1, cc.p(btnPos.x, btnPos.y))
                local times = 0
                local seq = cc.Sequence:create(cc.DelayTime:create(times + 0.2),cc.CallFunc:create(function()
                    SystemUtils.saveAccountLocalData("GUILD_OPEN_"..string.upper(data.system), 1)
                    self:setActionOpen(data.system, true, data,function()
                        self._openAnimaIndex = self._openAnimaIndex + 1
                        BeginAnima()
                    end)
                end))
                self:runAction(seq)
            end
        else
            self._viewMgr:unlock()
        end
    end

    if #self._openFunList > 0 then
        self._openAnimaIndex = 1
        BeginAnima()
    end
end

-- 动画开启
function GuildView:actionOpen(level)
    -- local noticeType = 1
    -- local userData = self._modelMgr:getModel("UserModel"):getData()
    -- local guildLvl = userData.guildLevel or 1
    -- if level ~= guildLvl then
    --     --todo
    -- end
    local guildLvTab = tab:GuildLevel(level)
    if not guildLvTab.open then
        self:checkUserLevelUpFun()
        return
    end

    if guildLvTab.open == 1 then
        self._viewMgr:lock(-1)
        local btntitle = guildLvTab.btn
        -- print ("==btntitle=====", btntitle)
        local btn = self:getUI(btntitle)
        if btn then
            local btnPos = btn:convertToWorldSpace(cc.p(btn:getContentSize().width*0.5, btn:getContentSize().height*0.5))
            local rect1 = cc.rect(MAX_SCREEN_WIDTH*0.2, 0, MAX_SCREEN_WIDTH*(1-0.4), MAX_SCREEN_HEIGHT)
            local flag = cc.rectContainsPoint(rect1, cc.p(btnPos.x, btnPos.y))
            local times = 0

            local seq = cc.Sequence:create(cc.DelayTime:create(times + 0.2),cc.CallFunc:create(function()
                self:setActionOpen(level, true, guildLvTab,function()
                    self:checkUserLevelUpFun()
                end)
            end))
            self:runAction(seq)
        else
            self:checkUserLevelUpFun()
            self._viewMgr:unlock()
        end
    end
end

-- 设置新功能开启动画
function GuildView:setActionOpen(systemopen, breakBg, systemDes, endBack)
    -- local systemDes = tab:SystemDes(systemopen)
    print("执行动画=== ")
    local btntitle = systemDes.btn

    local bgNode = self:getLayerNode()
    local bgLayer 
    if breakBg then
        bgLayer = ccui.Layout:create()
        bgLayer:setName("bgLayer")
        bgLayer:setBackGroundColorOpacity(180)
        bgLayer:setBackGroundColorType(1)
        bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
        bgLayer:setTouchEnabled(true)
        bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
        bgNode:addChild(bgLayer, 1)
    else
        bgLayer = ccui.Layout:create()
        bgLayer:setName("bgLayer")
        bgLayer:setBackGroundColorOpacity(0)
        bgLayer:setBackGroundColorType(1)
        bgLayer:setTouchEnabled(true)
        bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
        bgLayer:setOpacity(150)
        bgNode:addChild(bgLayer, 3)
        -- local bgLayer = bgNode
    end

    local mc = mcMgr:createViewMC("diguang_lianmengjihuo", false, true, function (_, sender)

    end, RGBA8888)  
    mc:setScale(2)       
    mc:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
    bgNode:addChild(mc, 2)

    local mc1 = mcMgr:createViewMC("guangqiu_lianmengjihuo", false, true, function (_, sender) 

    end, RGBA8888)  
    mc1:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
    bgNode:addChild(mc1,5)

    local icon = cc.Sprite:createWithSpriteFrameName("allianceScicene_openNameBg.png")
    icon:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
    bgNode:addChild(icon, 2)
    icon:setScale(0)

    local label = cc.Label:createWithTTF("解锁", UIUtils.ttfName, 24)
    label:setAnchorPoint(0, 0)
    label:setColor(cc.c3b(250, 230, 200))
    label:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    label:setPosition(100, 28)
    -- label:setPosition(MAX_SCREEN_WIDTH * 0.5 - 50, MAX_SCREEN_HEIGHT * 0.5)
    icon:addChild(label, 3)
    label:setScale(2.0)
    label:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3, 1.0), cc.DelayTime:create(1.5), cc.ScaleTo:create(0.2, 0), cc.FadeOut:create(0.1), cc.CallFunc:create(function()
        label:removeFromParent()
    end)))

    local noticeName = cc.Label:createWithTTF(lang(systemDes.name), UIUtils.ttfName_Title, 30)
    noticeName:setAnchorPoint(0, 0)
    noticeName:setColor(cc.c3b(255,254,216))
    noticeName:enable2Color(1, cc.c4b(255, 253, 123, 255))
    noticeName:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    noticeName:setPosition(label:getPositionX()+label:getContentSize().width+5, 30)
    -- noticeName:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
    icon:addChild(noticeName, 2)
    noticeName:setOpacity(0)
    noticeName:runAction(cc.Sequence:create(cc.FadeIn:create(0.1), cc.DelayTime:create(1.5), cc.FadeOut:create(0.2)))
    
    dump(systemDes, "systemDes ===")
    print("·systemopen====··", systemopen)
    local btn = self:getUI(btntitle)

    local scale = btn:getScale()
    local bgNodePos = btn:convertToWorldSpace(cc.p(0, 0)) 
    local iconPos = icon:convertToWorldSpace(cc.p(0, 0))

    -- local posX = bgNodePos.x - iconPos.x + btn:getContentSize().width*0.5*btn:getScaleX() + systemDes.position[1] -- 165 --systemDes.position[1]
    -- local posY = bgNodePos.y - iconPos.y + btn:getContentSize().height*0.5*btn:getScaleY() + systemDes.position[2] -- 99 --systemDes.position[2]
    -- local speed = cc.pGetDistance(cc.p(bgNodePos.x, bgNodePos.y),cc.p(iconPos.x,iconPos.y))/1000
    -- if tonumber(systemDes.id) == 1 then
    --     posX = posX - 25
    -- end
    if not systemDes.position then
        systemDes.position = {0,0}
    end

    local posX = bgNodePos.x - iconPos.x + btn:getContentSize().width*0.5*btn:getScaleX() + systemDes.position[1] -- 165 --systemDes.position[1]
    local posY = bgNodePos.y - iconPos.y + btn:getContentSize().height*0.5*btn:getScaleY() + systemDes.position[2] -- 99 --systemDes.position[2]
    local disicon = math.sqrt(posX*posX+posY*posY)
    local speed = disicon/1000
    
    local angle = math.deg(math.atan(posX/posY)) -- + 180
    if 0 <= posX and 0 <= posY then
        angle = angle + 180
    elseif  0 >= posX and 0 <= posY then
        angle = angle + 180
    elseif  0 >= posX and 0 >= posY then
        angle = angle 
    elseif  0 <= posX and 0 >= posY then
        angle = angle 
    end

    icon:runAction(cc.Sequence:create(
        cc.ScaleTo:create(0.3, 1.2), 
        cc.ScaleTo:create(0.05, 1.0), 
        cc.DelayTime:create(1.2), 
        -- cc.FadeOut:create(0.3),
        cc.ScaleBy:create(0.3, 0.01),
        cc.CallFunc:create(function()
            local mc2 = mcMgr:createViewMC("guangqiu_lianmengjihuo", true, false, nil, RGBA8888) 
            mc2:setName("mc2")
            mc2:setScale(100) 
            mc2:setRotation(angle)
            icon:addChild(mc2)
        end),
        cc.DelayTime:create(0.2), 
        cc.CallFunc:create(function()
            noticeName:removeFromParent()
            audioMgr:playSound("Unlock")
        end),        
        cc.Spawn:create(
            -- cc.ScaleBy:create(speed, 0.2), 
            cc.MoveBy:create(speed, cc.p(posX, posY)),
            cc.FadeOut:create(speed+0.2)),
        cc.CallFunc:create(function()
            local mc2 = icon:getChildByFullName("mc2")
            if mc2 then
                mc2:removeFromParent()
            end
            local mc1 = mcMgr:createViewMC("fankui_lianmengjihuo", false, true, nil, RGBA8888)  
            mc1:setScale(100)
            icon:addChild(mc1,-1)
            
            btn:stopAllActions()
            if string.find(btntitle, "bg.mid") ~= nil then
                btn:runAction(cc.Sequence:create(
                    cc.CallFunc:create(function()
                        btn:setOpacity(100)
                    end),
                    cc.DelayTime:create(0.3), 
                    cc.CallFunc:create(function()
                        btn:setOpacity(0)
                    end)
                     ))
            else
                btn:setOpacity(255)
                btn:runAction(cc.Sequence:create(
                    cc.CallFunc:create(function()
                        btn:setScale(scale+0.1)
                        btn:setOpacity(255)
                        btn:setBrightness(40)
                    end),
                    cc.DelayTime:create(0.3), 
                    cc.CallFunc:create(function()
                        btn:setBrightness(0)
                        btn:setScale(scale)
                    end)
                     ))
            end
        end),
        cc.DelayTime:create(1), 
        -- cc.MoveTo:create(speed, cc.p(95, MAX_SCREEN_HEIGHT - 37)), 
        cc.CallFunc:create(function ()
            bgLayer:removeFromParent()
            self._viewMgr:unlock()
            self._modelMgr:getModel("GuildModel"):clearAllianceOpenAction()
            self._modelMgr:getModel("GuildModel"):saveBubbleModify()
            -- self._viewMgr:doNewoverGuide()
            print("动画播放结束======================================")
            -- self:setQipao()
            -- local mainViewModel = self._modelMgr:getModel("MainViewModel")
            -- self:removeQipao(mainViewModel:getTipsQipao())
            if endBack then endBack() end
        end), 
        cc.RemoveSelf:create(true)))
end

function GuildView:setBubbleModify(level)
    -- local userData = self._modelMgr:getModel("UserModel"):getData()
    -- local guildLvl = userData.guildLevel
    -- local param = {num = 3, val = guildLvl}
    local param = {num = 3, val = level}
    ServerManager:getInstance():sendMsg("UserServer", "bubbleModify", param, true, {}, function (result)
        print("开启动画======", level)
        -- self._viewMgr:showTip("开启动画======")
    end)
end


-- function GuildView:reflashQuitAlliance()
--     local guildId = self._modelMgr:getModel("UserModel"):getData().guildId
--     if guildId and guildId == 0 then
--         self._viewMgr:returnMain()
--     end
-- end


return GuildView