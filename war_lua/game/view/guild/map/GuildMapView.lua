--[[
    Filename:    GuildMapView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-06-04 14:53:42
    Description: File description
--]]

local GuildMapView = class("GuildMapView", BaseView, require("game.view.guild.GuildBaseView"))

function GuildMapView:ctor(data)
    GuildMapView.super.ctor(self)
    self._guildMapModel = self._modelMgr:getModel("GuildMapModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    if data and data.toGridKey then
        self._famPos = string.split(data.toGridKey, ",")
    end
--  self.fixMaxWidth = ADOPT_IPHONEX and 1136 or nil
end

function GuildMapView:onInit()
    -- local guildMap = tab["guildMap"]
    -- dump(guildMap)
    self:listenReflash("UserModel", self.reflashQuitAlliance)
    print("test==============================================")
    self._tidySetting = {}

    self._lockTaskView = false

    self._isPreview = false

    self._isHaveGoBack = false

    self:setOpenQuickDispatch()
    
    self._taskBtns = {}
    for i=1,3 do
        local taskBtn = self:getUI("task"..i)
        self._taskBtns[i] = taskBtn
    end
    
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            self:hideMapNotice()
            if OS_IS_WINDOWS then
                SystemUtils.saveAccountLocalData("GUILD_MAP_GUANGBO_TIME", self._guildMapModel:getNoticeLastTime())
            end
            ScheduleMgr:cleanMyselfDelayCall(self)
            mcMgr:clear()
            -- UIUtils:reloadLuaFile("GuildMapModel", "game.model.")
            -- UIUtils:reloadLuaFile("GuildMapServer", "game.server.")

            UIUtils:reloadLuaFile("guild.map.GuildMapAQView")
            UIUtils:reloadLuaFile("guild.map.GuildMapAQRuleView")
            UIUtils:reloadLuaFile("guild.map.GuildMapAQRankView")
            UIUtils:reloadLuaFile("guild.map.GuildMapView")
            UIUtils:reloadLuaFile("guild.map.GuildMapSecondEventView")
            UIUtils:reloadLuaFile("guild.map.GuildMapEventView")
            UIUtils:reloadLuaFile("guild.map.GuildMapPvpView")
            UIUtils:reloadLuaFile("guild.map.GuildMapEffect")
            UIUtils:reloadLuaFile("guild.map.MapLayer")
            UIUtils:reloadLuaFile("guild.map.GuildMapAQRankView")
            UIUtils:reloadLuaFile("guild.GuildConst")
            UIUtils:reloadLuaFile("guild.map.GuildMapUtils")
            
        elseif eventType == "enter" then 
        end
    end)

    local cldaBtn = self:getUI("cldaBtn")
    cldaBtn:setVisible(false)
    local cldaTitle = self:getUI("cldaBtn.title")
    cldaTitle:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self:registerClickEvent(cldaBtn, function ()
        self._viewMgr:showDialog("guild.map.GuildMapCalendarView", {}, true)
        end)

    local datiBtn = self:getUI("datiBtn")
    local datiTitle = self:getUI("datiBtn.title")
    datiTitle:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local datitTitleBg = self:getUI("datiBtn.titleBg")
    datitTitleBg:setVisible(false)
    local datiTime = self:getUI("datiBtn.time")
    datiTime:setString("")
    self:registerClickEvent(datiBtn, function ()
        local curShowTime = self._guildMapModel:getAQAcTime()
        local curTime = self._userModel:getCurServerTime()
        if curShowTime == nil or #curShowTime < 3 or curTime >= curShowTime[3] or curTime < curShowTime[1] then
            self._viewMgr:showTip("活动已结束")
            return
        end
        
        self._viewMgr:showDialog("guild.map.GuildMapAQRankView", {}, true)
        end)
		
	local treasureBtn = self:getUI("treasure.treasureBtn")
    local treasureTitle = self:getUI("treasure.treasureBtn.title")
    treasureTitle:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	self:registerClickEvent(treasureBtn, function()
		if OS_IS_WINDOWS then
			UIUtils:reloadLuaFile("guild.map.GuildMapTreasureDialog")
		end
		self._viewMgr:showDialog("guild.map.GuildMapTreasureDialog")
	end)

    local backTownBtn = self:getUI("Panel.backTownBtn")
    local backTownBg = self:getUI("Panel.backTownName")
    local backTownLab = self:getUI("Panel.backTownName.nameLab")
    backTownLab:setFontName(UIUtils.ttfName)
    backTownLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)

    local previewBg1 = self:getUI("Panel.previewName1")
    local previewBg2 = self:getUI("Panel.previewName2")
    local markBtn = self:getUI("markBtn")
    local unMarkBtn = self:getUI("unMarkBtn")
    local unMarkTip = self:getUI("unMarkBtn.tip")

    local nameLab = self:getUI("Panel.previewName1.nameLab")
    nameLab:setFontName(UIUtils.ttfName)
    nameLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)

    local nameLab = self:getUI("Panel.previewName2.nameLab")
    nameLab:setFontName(UIUtils.ttfName)
    nameLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)

    self:registerClickEvent(backTownBtn, function ()
        self._viewMgr:showDialog("global.GlobalSelectDialog",
        {
            desc = lang("GUILDMAPTIPS_1"),
            button1 = "确定" ,
            button2 = "取消", 
            callback1 = function ()
                self._mapLayer:backCity()
            end,
            callback2 = function()
            end
        }, true)        
        
    end)

    local previewBtn1 = self:getUI("Panel.previewBtn1")
    previewBtn1:setVisible(false)
    local previewBtn2 = self:getUI("Panel.previewBtn2")
    previewBtn2:setVisible(true)
    self:registerClickEvent(previewBtn1, function ()   --地上
        self._isCanTri = true
        print("previewBtn1===========================")
        backTownBg:setVisible(true)
        backTownBtn:setVisible(true)
        previewBtn1:setVisible(false)
        previewBg1:setVisible(false)
        previewBtn2:setVisible(true)
        previewBg2:setVisible(true)
        markBtn:setVisible(false)
        unMarkBtn:setVisible(false)
        -- cldaBtn:setVisible(true)
        datiBtn:setVisible(false)
		treasureBtn:setVisible(false)

        local winWid = self._widget:getContentSize().width
        for i=1,3 do
            local taskBtn = self:getUI("task"..i):setVisible(false)
            taskBtn:setPositionX(winWid - 200)
        end
        local guildId = self._modelMgr:getModel("UserModel"):getData().guildId
        local selfPoint = self._guildMapModel:getData().selfPoint        
        self._guildMapModel:clear()
        if selfPoint ~= nil then
            backTownBg:setVisible(false)
            backTownBtn:setVisible(false)
            self._isPreview = true
            self:preViewMap(guildId)
        else
            self:refreshTagBtn()
            self:refreshAQBtn()
            backTownBg:setVisible(true)
            backTownBtn:setVisible(true)
            self._isPreview = false
            self:getMapInfo()
        end
    end)

    self:registerClickEvent(previewBtn2, function ()   --地下
        self._isCanTri = true
        print("previewBtn2======================")
        backTownBg:setVisible(false)
        backTownBtn:setVisible(false)
        markBtn:setVisible(false)
        unMarkBtn:setVisible(false)
        previewBg1:setVisible(true)
        previewBtn1:setVisible(true)
        previewBg2:setVisible(false)
        previewBtn2:setVisible(false)
        cldaBtn:setVisible(false)
        datiBtn:setVisible(false)
		treasureBtn:setVisible(false)
        local selfPoint = self._guildMapModel:getData().selfPoint

        self._guildMapModel:clear()

        if selfPoint ~= nil then 
            backTownBg:setVisible(false)
            backTownBtn:setVisible(false)
            self._isPreview = true
            self:preViewMap("center")
        else
            backTownBg:setVisible(true)
            backTownBtn:setVisible(true)
            self._isPreview = false
            self:getMapInfo()
        end
    end)

    local isGuildMgr = self._userModel:getData()["roleGuild"]["pos"] == 1
    self:registerClickEvent(markBtn, function ()
        if self._mapLayer ~= nil then 
            self._mapLayer:activeBattleTip()
        end        
        if isGuildMgr == true then  --联盟长
            markBtn:setVisible(false)
            unMarkBtn:setVisible(true)
            unMarkTip:setVisible(true)
            unMarkBtn:setPositionY(5)
            self._mapLayer:setTagTouchState(true)
            --标记
            self:refreshWidgetVisible(0)
            self._mapLayer:initEnableTag()

        else
            local mapMark = self._modelMgr:getModel("GuildMapModel"):getData().mapMark
            if not mapMark or next(mapMark) == nil then
                self._viewMgr:showTip(lang("GUILDMAPSIGN_TIPS_2"))
                return
            else
                if mapMark[1] and mapMark[1]["pos"] then
                    local spPos = string.split(mapMark[1]["pos"], ",")
                    self._mapLayer:screenToGrid(tonumber(spPos[1]), tonumber(spPos[2]))
                end
            end
        end
    end)

    self:registerClickEvent(unMarkBtn, function ()
        local tagState = self._mapLayer:getTagTouchState()
        if tagState == true then   --选择状态中
            self._mapLayer:removeEnableTag()
            self._mapLayer:setTagTouchState(false)
            self:refreshWidgetVisible(1)
            self:refreshTagBtn()
            self:reflashPushMapTask()
        else
            --取消tag
            local guildMapData = self._modelMgr:getModel("GuildMapModel"):getData()
            local tagData = guildMapData["mapMark"]
            if tagData and tagData[1] and tagData[1]["pos"] then
                self._serverMgr:sendMsg("GuildMapServer", "cancelMapMark", {tagPoint = tagData[1]["pos"]}, true, {}, function (result)
                    self._guildMapModel:removeTagsData()
                    self._mapLayer:createTagElement()
                    self:refreshTagBtn()
                    end)
            end            
        end
    end)

    self:setListenReflashWithParam(true)
    self:listenReflash("GuildMapModel", self.listenModel) 
    self:listenReflash("FormationModel", function()  --英雄形象更新 wangyan
            if self._mapLayer ~= nil then
                self._mapLayer:updateMySelfHeroMc()
            end
            self:reflashFormationRedTip()
        end)
--    self:reflashFormationRedTip()

    --by wangyan 聊天
    local chatNode = require("game.view.global.GlobalChatNode").new("guild")
    local treasureBtn = self:getUI("treasure.treasureBtn")
    chatNode:setAnchorPoint(0, 0.5)
    local distance = 0
    if ADOPT_XIAOMIM2 then
        distance = 72
    elseif not ADOPT_XIAOMIM2 and ADOPT_IPHONEX then
        distance = 125
    end
    treasureBtn:setPositionX(distance - 10)
    chatNode:setPosition(distance, MAX_SCREEN_HEIGHT * 0.5)
    self:addChild(chatNode, 100)
    local label = cc.Label:createWithTTF("聊天", UIUtils.ttfName, 14)
    label:setColor(cc.c3b(255, 255, 255))
    label:enableOutline(cc.c4b(60, 30, 10, 255), 2)
    label:setPosition(26, 10)
    label:setName("31555")
    chatNode:addChild(label, 9999)
    self._chatNode = chatNode

    local treasureStateLab = self:getUI("treasure.treasureBtn.stateLab")
    treasureStateLab:enableOutline(cc.c4b(31, 60, 63, 255), 1)
    
    --联盟秘境
    self._famProgress = self:getUI("famLayer.progressBg.progress")
    self._exploreValueLabel = self:getUI("famLayer.progressBg.exploreValue")
    self._exploreValueLabel:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self._stateLabel = self:getUI("famLayer.stateBg.stateLabel")
    self._stateLabel:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self._famBtn = self:getUI("famLayer.famImage")
    self:registerClickEvent(self._famBtn, function()
        self:screenToFamGridKey()
    end)
    self:setFamData()
    self:listenReflash("PlayerTodayModel", self.handleModelListen)
    
    self:setListenReflashWithParam(true)
    self:listenReflash("ChatModel", self.chatListenFunc)
    self:listenReflash("PlayerTodayModel", self.chatListenFunc)
    
    --新年使者的buff图标
    self:onInitNewYear()
end

function GuildMapView:handleModelListen(inParam)
    self:chatListenFunc(inParam)
    self:setFamData()
end

function GuildMapView:chatListenFunc(inParam)
    if self._chatNode and self._chatNode.showChatUnread ~= nil then
        self._chatNode:showChatUnread(inParam)
    end
end

function GuildMapView:onTop()
    if self._mapLayer ~= nil then 
        self._mapLayer:unLockTouch()
    end
    print("GuildMapView:onTop()====================")
    self:activeBattleTip()
    --ontop走马灯 
    self:showMapNotice()
    if self._tidySetting.isCenter then
        self._viewMgr:enableScreenWidthBar()
    end
end

function GuildMapView:activeBattleTip()
    ScheduleMgr:delayCall(0, self, function()
        if self._mapLayer ~= nil then 
            self._mapLayer:activeBattleTip()
        end
    end)
end



function GuildMapView:onAdd()

end

function GuildMapView:enterBattle()
    self:hideMapNotice()
end

function GuildMapView:onDoGuide(config)
    if config.view ~= nil and config.view == "guildmap" and config.moveto ~= nil then
        if self._mapLayer ~= nil then 
            self._mapLayer:screenToGrid(config.moveto.a, config.moveto.b, true)
        end
    end
end

function GuildMapView:onHide()
    if self._mapLayer ~= nil then 
        self._mapLayer:lockTouch()
    end
    
    if self._mapLayer ~= nil then 
        self._mapLayer:stopBattleTip()
    end
    
    self._viewMgr:disableScreenWidthBar()
end

function GuildMapView:showBufferNode()
    local userData = self._modelMgr:getModel("UserModel"):getData()
        if (userData.roleGuild == nil or userData.roleGuild.mapbuff == nil or table.nums(userData.roleGuild.mapbuff) <=0)  then 
            self._viewMgr:showTip("您当前没有加成")
            return
        end
        -- dump(userData.roleGuild.mapbuff)
        local bgLayer = ccui.Layout:create()
        bgLayer:setBackGroundColorOpacity(0)
        bgLayer:setBackGroundColorType(1)
        bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
        bgLayer:setTouchEnabled(true)
        bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
        self._widget:addChild(bgLayer, 100)
        bgLayer:setName("bgLayer")

        registerClickEvent(bgLayer, function()
            local bufferBg = self:getUI("bufferBg")    --buff显示图
            bufferBg:setVisible(false)
            bgLayer:removeFromParent()
        end)

        --普通buff
        local bufferBg = self:getUI("bufferBg")
        local sysBuffPic = tab.crusadeBuffPic
        for i=1,5 do
            local bufferIcon = self:getUI("bufferBg.smallIcon" .. i)
            bufferIcon:setVisible(false)

            if bufferBg:getChildByName("richText" .. i) ~= nil then 
                bufferBg:getChildByName("richText" .. i):removeFromParent()
            end
        end

        local buffOrderKeys = table.keys(userData.roleGuild.mapbuff)
        local sortFunc = function(a, b) return tonumber(b) > tonumber(a) end
        table.sort(buffOrderKeys, sortFunc)
        for k,v in pairs(buffOrderKeys) do
            local buff = userData.roleGuild.mapbuff[v]
            local bufferIcon = self:getUI("bufferBg.smallIcon" .. k) 
            bufferIcon:loadTexture("guildMapImg_buffer" .. v..".png", 1)
            bufferIcon:setVisible(true)
            bufferIcon:setScale(0.35)
            local desc = lang("CRUSADE_BUFFS_" .. v)   --text
            local result,count = string.gsub(desc, "$num", buff)
            if count > 0 then
                desc = result
            end
            local richText = RichTextFactory:create(desc, 160 , 0)
            richText:formatText()
            richText:setPosition(88 + richText:getContentSize().width/2, bufferIcon:getPositionY())
            richText:setName("richText" .. k)
            bufferBg:addChild(richText)
        end
        -- bufferBg:setContentSize(cc.size(220, 194 + (math.max(#buffOrderKeys - 2, 0))*35 + 15 ))
        bufferBg:setVisible(true)
end

function GuildMapView:listenModel(inType)
    print("inType==============================================", inType)
    if inType == nil then
        return
    end

    if self["reflash" .. inType] then
        self["reflash" .. inType](self)
    else
        if self._mapLayer ~= nil then 
            if self._mapLayer["listenModel" .. inType] == nil then
                print("GuildMapView: Not found listenModel" .. inType)
                return
            end
            self._mapLayer["listenModel" .. inType](self._mapLayer)
            -- print("inType--------------------------------------------------", inType)
            -- dump(self._guildMapModel:getEvents())
        end
    end
end

function GuildMapView:reflashPushMapMark()
    if self._mapLayer and self._mapLayer.createTagElement then
        self._mapLayer:createTagElement()
        self:refreshTagBtn()
    end
end

-- 显示广播
function GuildMapView:showMapNotice()
    local name = "guild.map.GuildMapNoticeView"
    local view = require("game.view." .. name).new()
    view:setClassName(name)
    self._viewMgr:showCustomNotice(view)
    if self._noticeView == nil then
        view:initUI(name)
        self._noticeView = view
        view:reflashUI()
    else
        if self._noticeView.reflashUI then
            self._noticeView:reflashUI()
        end
    end
end

function GuildMapView:reflashGlobalNotice()
    if self._noticeView and self._noticeView.reflashUI then
        self._noticeView:reflashUI()
    end
end

function GuildMapView:hideMapNotice()
    self._viewMgr:removeCustomNotice()
    if self._noticeView then
        self._noticeView = nil
    end
end

function GuildMapView:reflashUpdateReport()
    local guildMapData = self._modelMgr:getModel("GuildMapModel"):getData()
    local reportBtn = self:getUI("Panel_29.extendBar.bg.map_report_btn")
    if reportBtn ~= nil then
        local redPoint = reportBtn:getChildByName("redPoint")
        if redPoint == nil then 
            redPoint = cc.Sprite:createWithSpriteFrameName("globalImageUI_bag_keyihecheng.png")
            redPoint:setPosition(reportBtn:getContentSize().width - 10, reportBtn:getContentSize().height - 10)
            redPoint:setName("redPoint")
            reportBtn:addChild(redPoint)
        end
        if guildMapData.havetips == 1 then
            redPoint:setVisible(true)
        else
            redPoint:setVisible(false)
        end
    end
end

function GuildMapView:reflashUpdateRuleOpen()
    local ruleBtn = self:getUI("Panel_29.extendBar.bg.map_desc_btn")
    if ruleBtn ~= nil then
        local redPoint = ruleBtn:getChildByName("redPoint")
        if redPoint == nil then 
            redPoint = cc.Sprite:createWithSpriteFrameName("globalImageUI_bag_keyihecheng.png")
            redPoint:setPosition(ruleBtn:getContentSize().width - 10, ruleBtn:getContentSize().height - 10)
            redPoint:setName("redPoint")
            ruleBtn:addChild(redPoint)
        end
        if self._guildMapModel:getRuleOpenState() == false then
            redPoint:setVisible(true)
        else
            redPoint:setVisible(false)
        end
    end
end

function GuildMapView:onBeforeAdd(callback, errorCallback)
    local upTime = self._guildMapModel:getData().upTime
    self._serverMgr:sendMsg("GuildMapServer", "getMapInfo", {upTime = upTime}, true, {}, function(result, errorCode)
        if errorCode ~= 0 then 
            if errorCode == GuildConst.GUILD_MAP_RESULT_CODE.GUILD_MAP_RENEW then 
                self._viewMgr:showTip(lang("GUILD_MAP_RESULT_CODE_TIP_" .. errorCode))
            else
                self._viewMgr:showTip("联盟地图开启失败")
            end
            errorCallback()
            self._viewMgr:unlock(51)
            return
        end
        self:refreshUIUnify()
        callback()
        --跑马灯
        self:showMapNotice()
    end)
end

function GuildMapView:initMap()
    -- self._mapLayer = require("game.view.guild.map.GuildMapLayer").new(self)
    -- self:addChild(self._mapLayer, 100)
end

function GuildMapView:reflashView()
    self._viewMgr:lock(1)
    if self._mapLayer ~= nil then 
        self._mapLayer:removeFromParent()
        self._mapLayer = nil
    end
    local mapId = self._guildMapModel:getData().version
    if mapId == nil or type(mapId) == "boolean" then 
        ScheduleMgr:delayCall(0, self, function()
            self._viewMgr:unlock()
            self:close()
            ViewManager:getInstance():showTip("数据不匹配，请联系管理员")
        end)
        return        
        -- mapId = "2016,1"
    end
    local currentGuildId = self._guildMapModel:getData().currentGuildId
    local isCenter = false
    if currentGuildId == "center" then 
        isCenter = true
    end

    local sysGuildMapSetting = tab:GuildMapSetting(mapId)  
    self._tidySetting = {}
    self._tidySetting.name = sysGuildMapSetting.guildname
    -- 安全区
    self._tidySetting.safeArea = sysGuildMapSetting.G_GUILD_MAP_SAFE_AREA
    self._tidySetting.centerSafeArea = sysGuildMapSetting.G_GUILD_MAP_CENTERMAP_SAFE

    local preViewPanel = self:getUI("Panel")
    local previewBtn2 = self:getUI("Panel.previewBtn2")
    local previewBtn1 = self:getUI("Panel.previewBtn1")
    local previewBg1 = self:getUI("Panel.previewName1")
    local previewBg2 = self:getUI("Panel.previewName2")
    local markBtn = self:getUI("markBtn")
    local unMarkBtn = self:getUI("unMarkBtn")
    local unMarkTip = self:getUI("unMarkBtn.tip") 
    local cldaBtn = self:getUI("cldaBtn")
    local datiBtn = self:getUI("datiBtn")
	local treasureBtn = self:getUI("treasure.treasureBtn")

    local param = {}
    if not isCenter then
        print("isCenter===============================")
        self._tidySetting.mapTable = sysGuildMapSetting.default
        self._tidySetting.decorate = sysGuildMapSetting.decorate
        self._tidySetting.bgImg = sysGuildMapSetting.guildPic
        self._tidySetting.miniImg = sysGuildMapSetting.guildSmallPic
        self._tidySetting.cloudImg = sysGuildMapSetting.guildCloudPic
        self._tidySetting.param = sysGuildMapSetting.guildSetting
        self._tidySetting.decoratePlist = sysGuildMapSetting.guildDecoratePlist

        self._tidySetting.isCenter = false

        previewBg1:setVisible(false)
        previewBtn1:setVisible(false)   
        
        previewBg2:setVisible(true)
        previewBtn2:setVisible(true)

        -- cldaBtn:setVisible(true)

        --标记 
        self:refreshTagBtn()
        --答题
        self:refreshAQBtn()
		--藏宝图
		self:reflashUpdateTreasure()

        param.extendInfo = {
            {
                "map_statis_btn",    
                "guildMapBtn_qingbao.png",       
                lang("GUILD_MAP_BUTTON_7"),        
                function()
                    self._viewMgr:showDialog("guild.map.GuildMapStatisView", {}, true)
                end
            },
            {
                "map_equip_btn",    
                "guildMapBtn_equip.png",       
                lang("GUILD_MAP_BUTTON_5"),        
                function()
                    self._viewMgr:showDialog("guild.map.GuildMapEquipView", {}, true)
                end
            },
            {
                "map_mini_btn",    
                "guildMapBtn_miniMap.png",       
                lang("GUILD_MAP_BUTTON_4"),        
                function() 
                    if self._tidySetting.miniImg == nil then 
                        self._viewMgr:showTip("无小地图")
                        return
                    end
                    self._viewMgr:showDialog("guild.map.GuildMiniMapView", {mapImg = self._tidySetting.miniImg,mapTable= self._tidySetting.mapTable}, true)
                end
            },  
            {
                "map_report_btn",    
                "guildMapBtn_battleReport.png",       
                lang("GUILD_MAP_BUTTON_3"),        
                function()
                    self._viewMgr:showDialog("guild.map.GuildMapLogDialog", {}, true)
                    self._modelMgr:getModel("GuildMapModel"):getData()
                    local guildMapData = self._modelMgr:getModel("GuildMapModel")
                    guildMapData:updateReportState(0)
                end
            }, 
            {
                "map_desc_btn",         
                "guildMapBtn_desc.png",        
                lang("GUILD_MAP_BUTTON_2"),         
                function()
                    self._viewMgr:showDialog("guild.map.GuildMapDescNode", {}, true) 
                    local guildMapData = self._modelMgr:getModel("GuildMapModel") 
                    guildMapData:updateRuleOpenState(true)                  
                end
            },            
            {
                "map_formation_btn",    
                "guildMapBtn_formation.png",       
                lang("GUILD_MAP_BUTTON_1"),        
                function()
                    self._formationModel = self._modelMgr:getModel("FormationModel")
                    self._viewMgr:showView("formation.NewFormationView", {
                        formationType = self._formationModel.kFormationTypeGuildDef,
                    })
                end
            }
        }
		self._centerTime = nil
		self._limitViewShow= false
		if self._updateId then
			ScheduleMgr:unregSchedule(self._updateId)
			self._updateId = nil
		end
    else
        print("11111111111111isCenter===============================")
        self._tidySetting.mapTable = sysGuildMapSetting.center
        self._tidySetting.decorate = sysGuildMapSetting.centerDecorate
        self._tidySetting.bgImg = sysGuildMapSetting.centerPic
        -- self._tidySetting.miniImg = sysGuildMapSetting.guildSmallPic_2
        -- self._tidySetting.cloudImg = sysGuildMapSetting.guildCloudPic
        self._tidySetting.decoratePlist = sysGuildMapSetting.centerDecoratePlist
        self._tidySetting.param = sysGuildMapSetting.centerSetting
        self._tidySetting.isCenter = true

        previewBg1:setVisible(true)
        previewBtn1:setVisible(true)   
        
        previewBg2:setVisible(false)
        previewBtn2:setVisible(false) 

        markBtn:setVisible(false) 
        unMarkBtn:setVisible(false) 
        unMarkTip:setVisible(false)
        -- cldaBtn:setVisible(false)
        datiBtn:setVisible(false) 
		treasureBtn:setVisible(false)
        
        param.extendInfo = {
            {
                "map_report_btn",    
                "guildMapBtn_battleReport.png",       
                lang("GUILD_MAP_BUTTON_3"),        
                function()
                    self._viewMgr:showDialog("guild.map.GuildMapLogDialog", {}, true)
                    self._modelMgr:getModel("GuildMapModel"):getData()
                    local guildMapData = self._modelMgr:getModel("GuildMapModel")
                    guildMapData:updateReportState(0)
                end
            }, 
            {
                "map_rank_btn",         
                "guildMapBtn_rank.png",        
                lang("GUILD_MAP_BUTTON_6"),         
                function()
                    self:showRankView()
                end
            },
			{
                "map_desc_btn",         
                "guildMapBtn_desc.png",        
                lang("GUILD_MAP_BUTTON_2"),         
                function()
					self._viewMgr:showDialog("global.GlobalRuleDescView", {desc = lang("DUNGEON_RULE")}, true)
                end
            },
            {
                "map_formation_btn",    
                "guildMapBtn_formation.png",       
                lang("GUILD_MAP_BUTTON_1"),        
                function()
                    self._formationModel = self._modelMgr:getModel("FormationModel")
                    self._viewMgr:showView("formation.NewFormationView", {
                        formationType = self._formationModel.kFormationTypeGuildDef,
                    })
                end
            }
		}
		self._centerTime = self._userModel:getCurServerTime()
		self._limitViewShow = false
		self._updateId = ScheduleMgr:regSchedule(1000, self, function(self, dt)
			self:updateCenter20(dt)
		end)
    end
    --[[if self._widget then
        if ADOPT_IPHONEX and not self.isPopView and not self.dontAdoptIphoneX then
            if self.fixMaxWidth then
                self._widget:setContentSize((MAX_SCREEN_WIDTH > self.fixMaxWidth) and self.fixMaxWidth or MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
            else
                self._widget:setContentSize(MAX_SCREEN_WIDTH - 120, MAX_SCREEN_HEIGHT)
            end
        end
    end--]]
    if ADOPT_XIAOMIM2 then ADOPT_IPHONEX = true end
    if ADOPT_IPHONEX then
        if isCenter then
            self._viewMgr:enableScreenWidthBar()
            self._widget:setContentSize(1136, MAX_SCREEN_HEIGHT)
        else
            self._viewMgr:disableScreenWidthBar()
            self._widget:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
        end
    end

    -- 指定按钮宽度
    param.btnWidth = 82
    -- 预留宽度
    param.reserveWidth = 70
    -- 初始化状态1伸展，0收缩
    param.initState = (self._barState~=nil and self._barState) or 1
    -- 初始化风格，按照按钮宽度
    param.style = 1

    -- 文本内容大小
    param.fontSize = 18

    -- 图标偏移量
    param.iconOffset = {0, 0}

    -- name偏移量
    param.nameOffset = {0, 10}

    param.barHeight = 95

    param.redTipCallback = function(inBtnName, inBtnNode)

    end
    param.motionCallback = function(inState)
    -- inState 1展开，0收缩
        if self._barState == math.abs(inState-1) then
            return
        end
        for i,v in ipairs(self._taskBtns) do
            local fatherWidth = MAX_SCREEN_WIDTH
            local width = v:getContentSize().width
            v:stopAllActions()
            local anim
            if inState==0 then
                anim = cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(fatherWidth-width, v:getPositionY())), cc.CallFunc:create(function()
--                  print("posX"..i.." = "..v:getPositionX())
                end))
            else
                anim = cc.MoveTo:create(0.3, cc.p(fatherWidth, v:getPositionY()))
            end
            v:runAction(anim)
        end
        self._barState = math.abs(inState-1)
    end
    -- 横向方向1左侧，2右侧
    param.horizontal = 1
    if self._extendBar ~= nil then self._extendBar:removeFromParent(true) end

    self._extendBar = require("game.view.global.GlobalExtendBarNode").new(param)
    local quickBg = self:getUI("Panel_29")
    quickBg:addChild(self._extendBar)
    self._extendBar:setAnchorPoint(0, 0.5)
    self._extendBar:setPosition(-35, quickBg:getContentSize().height * 0.5)

    local extendBtn = self:getUI("Panel_29.extendBar.bg.extend")
    extendBtn:setPositionX(extendBtn:getPositionX()-8)
    extendBtn:setVisible(true)

    self._mapLayer = require("game.view.guild.map.GuildMapLayer").new({parent = self, setting = self._tidySetting})

    self:addChild(self._mapLayer, -1)
    self._viewMgr:unlock()

    local guildId = self._modelMgr:getModel("UserModel"):getData().guildId

    local guildList = self._guildMapModel:getData().guildList
    if guildList ~= nil then
        if tostring(currentGuildId) ~= "center" and guildList[tostring(currentGuildId)] == nil then 
            ScheduleMgr:delayCall(0, self, function()
                self._viewMgr:unlock()
                self:close()
                ViewManager:getInstance():showTip("联盟ID与联盟列表数据不匹配，请联系管理员")
            end)
            return
        end
        local guildNameBg = self:getUI("title.guildNameBg")
        local nameLab = self:getUI("title.guildNameBg.nameLab")
        nameLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        nameLab:setFontName(UIUtils.ttfName)

        local tipLab = self:getUI("title.guildNameBg.tipLab")
        tipLab:setFontName(UIUtils.ttfName)
        tipLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
        tipLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

        ------判断都有哪些引导或弹出  by wangyan

        local guildData = self._guildMapModel:getData()

        --自家联盟引导1
        local triggerPoint = require "game.config.guide.TriggerConfig"
        local isGuide12 = not self._userModel:hasTrigger(triggerPoint["action"][tostring(12)])
        --敌方联盟引导2
        local isGuide14 = not self._userModel:hasTrigger(triggerPoint["action"][tostring(14)])
        --地图重置3
        local isResetPop = false
        if guildData.weekReset == 1 and guildData.isFirst == 0 then
            isResetPop = true
        end
        --小精灵引导4
        local isSpGuide = false
        local isHasShow = SystemUtils.loadAccountLocalData("GUILD_MAP_IS_XIANZHI_TALK1_SHOW")
        local taskType = GuildConst.TASK_TYPE.GUILD_MAP_ST_FIND_XUEZHE
        local taskState = self._guildMapModel:getTaskStateByStatis(taskType)
        if isHasShow ~= 1 and tostring(currentGuildId) == tostring(guildData.speGid) and taskState == 1  then
            isSpGuide = true
        end
        local killedNotice = guildData.killedNotice
        --被打回城提示5
        local isKillPop = false
        if killedNotice ~= nil and next(killedNotice) ~= nil then
            isKillPop = true
        end 
        --活动答题拍脸图 
        local isSphinxAd = true
        if isGuide12 or isGuide14 or isResetPop or isSpGuide or isKillPop then
            isSphinxAd = false
        end
        ---------------------------------

        if tostring(currentGuildId) == "center" then
            -- 第一次进入地下城
            if self._isCanTri == false then
                GuideUtils.checkTriggerByType("action", "13")
            end
            
            nameLab:setString("地下城")
            nameLab:setColor(UIUtils.colorTable.ccUIBaseColor3)
            self._lockTaskView = true
         else
            self._isCanTri = false
            if tostring(currentGuildId) == tostring(guildId) then
                -- 第一次进入联盟地图
                GuideUtils.checkTriggerByType("action", "12")
                nameLab:setColor(UIUtils.colorTable.ccUIBaseColor2)
            else

                -- 第一次进有小精灵的公会
                if isSpGuide == true then
                    ViewManager:getInstance():enableTalking(41, {}, function()
                        SystemUtils.saveAccountLocalData("GUILD_MAP_IS_XIANZHI_TALK1_SHOW", 1)
                        --移动屏幕
                        local spPos = guildData["spTaskData"]["sp2"]["pos"]
                        local spPos = string.split(spPos, ",")
                        if spPos then
                            self._mapLayer:screenToGridAndDelayBack(tonumber(spPos[1]), tonumber(spPos[2]))
                        end
                        end)
                        
                else
                    -- 第一次进入敌方地图
                    GuideUtils.checkTriggerByType("action", "14")
                end
                
                nameLab:setColor(UIUtils.colorTable.ccUIBaseColor6)
            end
            nameLab:setString(guildList[tostring(currentGuildId)].name)
            self._lockTaskView = false 

            --重置地图弹板
            if isResetPop then
                SystemUtils.saveAccountLocalData("GUILD_MAP_IS_XIANZHI_TALK1_SHOW", 0) 
                SystemUtils.saveAccountLocalData("GUILD_MAP_IS_AQ_AD_SHOWED", 0)
                self._guildMapModel:getData().weekReset = nil
                ScheduleMgr:delayCall(0, self, function()
                    self._viewMgr:showDialog("guild.map.GuildMapResetTipView", true)
                end)
            end
        end
        tipLab:setPosition(nameLab:getPositionX() + nameLab:getContentSize().width, tipLab:getPositionY())
        guildNameBg:setContentSize(cc.size(nameLab:getContentSize().width + tipLab:getContentSize().width, guildNameBg:getContentSize().height ))
        guildNameBg:setPositionX(guildNameBg:getParent():getContentSize().width * 0.5 - guildNameBg:getContentSize().width * 0.5)      
        
        --被打回城提示
        if isKillPop then 
            self._guildMapModel:getData().killedNotice = nil
            ScheduleMgr:delayCall(0, self, function()
                self._viewMgr:showDialog("guild.map.GuildMapInfoTipView", {showType = 3, otherData = killedNotice}, true)
            end)
        end

        --答题活动 开启广告
        if isSphinxAd then
            local aqTime = self._guildMapModel:getAQAcTime()
            local curTime = self._userModel:getCurServerTime()
            if not (aqTime == nil or #aqTime < 3 or curTime >= aqTime[2] or curTime < aqTime[1]) then
                local isShowed = SystemUtils.loadAccountLocalData("GUILD_MAP_IS_AQ_AD_SHOWED")
                if isShowed == nil or isShowed ~= 1 then
                    ScheduleMgr:delayCall(0, self, function()
                        self._viewMgr:showDialog("guild.GuildAdView", {adList = {"sifenkesiAQ_l"}, inType = 1,  callback = function()
                        SystemUtils.saveAccountLocalData("GUILD_MAP_IS_AQ_AD_SHOWED", 1) 
                        end}, true)
                    end)
                end
            end
        end        
            

    end
    
    local mapData = self._modelMgr:getModel("GuildMapModel"):getData()
    local myGuildId = self._modelMgr:getModel("UserModel"):getData().guildId
    if self._famPos then
        local mapData = self._modelMgr:getModel("GuildMapModel"):getData()
        local myGuildId = self._modelMgr:getModel("UserModel"):getData().guildId
        if tonumber(myGuildId)~=tonumber(mapData.currentGuildId) then
            self._viewMgr:showGlobalDialog("global.GlobalSelectDialog",
            {
                desc = lang("GUILD_FAM_TIPS_27"),--"[color=8a5c1d,fontsize=24]您当前没有在自己的联盟领地内，若进入秘境，您会自动[-][color=c44904,fontsize=24]回城[-][color=8a5c1d,fontsize=24]，是否现在进入秘境？[-]",
                button1 = "确定" ,
                button2 = "取消", 
                callback1 = function ()
                    self._mapLayer:backCity()
                end,
                callback2 = function()
                    self._famPos = nil
                end
            }, true)
        else
            self._mapLayer:screenToGrid(tonumber(self._famPos[1]), tonumber(self._famPos[2]), true, function()
                self._mapLayer:touchRemoteGridEvent(self._famPos[1], self._famPos[2])
                self._famPos = nil
            end)
        end
    end
end


function GuildMapView:reflashPushMapTask()
    -- print('reflashPushMapTask===============================')
    local winWid = self._widget:getContentSize().width
    for i=1,3 do
        local taskBtn = self:getUI("task"..i):setVisible(false)
--        taskBtn:setPositionX(winWid - 200)
    end
    -- print("self._lockTaskView==================", self._lockTaskView)
    if self._lockTaskView then
        return
    end
    for i=1,3 do
        local taskBtn = self:getUI("task"..i):setVisible(false)
--        taskBtn:setPositionX(winWid - 200)
        taskBtn.isCanGet = false

        local boxImg = taskBtn:getChildByName("boxImg")
        boxImg:stopAllActions()
        boxImg:setScale(0.85)
        boxImg:setRotation(0)
        boxImg:setPosition(21, taskBtn:getContentSize().height/2)
        boxImg:setLocalZOrder(1)
        
        if taskBtn:getChildByName("diguang") ~= nil then
            taskBtn:getChildByName("diguang"):removeFromParent(true)
        end

        local taskDes = taskBtn:getChildByName("taskDes")
        taskDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

        local Label_54 = taskBtn:getChildByName("Label_54")
        Label_54:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

        local curPer = taskBtn:getChildByName("curPer")
        curPer:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    end

    local guildMapData = self._modelMgr:getModel("GuildMapModel"):getData()
    if not guildMapData["mapTask"] or next(guildMapData["mapTask"]) == nil then
        return
    end
    
    local sysGuildMapTask = tab.guildMapTask
    local guildMapTask = self._guildMapModel:sortTaskByOrder()
    local userModelData = self._userModel:getData()
    -- dump(guildMapTask, "mapTask2")
    -- dump(guildMapData["mapTask"], "mapTask")
    -- dump(userModelData["mapStatis"], "task1")

    local num = 0
    for i,v in ipairs(guildMapTask) do
        repeat
            if v.info ~= 0 then
                break
            end    
            num = num + 1
            local taskBtn = self:getUI("task"..num)
            taskBtn:setVisible(true)
            taskBtn.taskID = v.id 
            self:registerClickEvent(taskBtn, function()
                    self:onTaskBtnClickHandle(taskBtn)
                end)
            --taskDes
            local taskDes = taskBtn:getChildByName("taskDes")
            taskDes:setString(lang(sysGuildMapTask[v.id].name))

            --curPer
            local statis = tostring(sysGuildMapTask[v.id].condition)
            local curPer = taskBtn:getChildByName("curPer")
            local cur = 0
            if userModelData["mapStatis"] ~= nil and userModelData["mapStatis"][statis] ~= nil then 
                cur = userModelData["mapStatis"][statis]
            end
            
            local max = sysGuildMapTask[v.id].conditionNum
            curPer:setString(math.min(cur, max).."/"..max)
            if cur >= max then
                curPer:setColor(UIUtils.colorTable.ccUIBaseColor2)
            else
                curPer:setColor(UIUtils.colorTable.ccUIBaseColor1)
            end

            --标记
            local mark = taskBtn:getChildByName("mark")
            local markType = sysGuildMapTask[v.id]["type"]
            if markType then
                mark:loadTexture("guildMapImg_taskT".. markType ..".png", 1)
            else
                mark:setVisible(false)
            end

            --anim
            if cur >= max then
                taskBtn.isCanGet = true

                local boxImg = taskBtn:getChildByName("boxImg")
                local diguang = taskBtn:getChildByName("diguang")   --旋转光
                
                if not diguang then
                    local mc1 = mcMgr:createViewMC("renwulingquguang_lianmengjihuo", true, false) 
                    mc1:setPosition(boxImg:getPosition())
                    mc1:setName("diguang")
                    taskBtn:addChild(mc1)
                end

                local action1 = cc.RotateTo:create(0.08, 15)  
                local action2 = cc.RotateTo:create(0.08, 0)  
                boxImg:runAction(cc.RepeatForever:create(cc.Sequence:create(action1, action2, action1, action2, cc.DelayTime:create(0.5))))
            end

            --字动画
            if guildMapData["markTaskStatis"] then
                for i,v in ipairs(guildMapData["markTaskStatis"]) do
                    if v[statis] ~= nil then
                        local preColor = curPer:getColor()
                        curPer:setColor(cc.c3b(0, 255, 0))
                        curPer:runAction(cc.Sequence:create(
                            cc.ScaleTo:create(0.3,1.2),
                            cc.ScaleTo:create(0.2,1),
                            cc.CallFunc:create(function()
                                curPer:setColor(preColor)
                            end)))
                        table.remove(guildMapData["markTaskStatis"], i)
                        break
                    end
                end
            end
            if i == #guildMapTask then
                guildMapData["markTaskStatis"] = {}
            end
            
            --任务激活动画
            if guildMapData["markTask"] and guildMapData["markTask"] == v.id then
                --任务激活特效
                if tonumber(statis) == GuildConst.TASK_TYPE.GUILD_MAP_ST_FIND_XUEZHE or
                 tonumber(statis) == GuildConst.TASK_TYPE.GUILD_MAP_ST_FIND_BOX then
                    local jihuoAim = mcMgr:createViewMC("shuaxinguangxiao_shuaxinguangxiao", false, true)
                    jihuoAim:setPosition(taskBtn:getContentSize().width*0.5, taskBtn:getContentSize().height*0.5)
                    jihuoAim:setScaleX(-1)
                    taskBtn:addChild(jihuoAim, 10)

                    local prePosX, prePosY = taskBtn:getPositionX(), taskBtn:getPositionY()
                    taskBtn:runAction(cc.Sequence:create(
                        cc.MoveTo:create(0.05, cc.p(prePosX + 100, prePosY)),
                        cc.MoveTo:create(0.15, cc.p(prePosX, prePosY)),
                        cc.CallFunc:create(function()
                            guildMapData["markTask"] = nil
                            end)
                        ))
                end
            end            

        until true
    end
end

function GuildMapView:onTaskBtnClickHandle(taskBtn)
    local sysGuildMapTask = tab.guildMapTask
    if taskBtn.isCanGet and taskBtn.isCanGet == true then
        self._serverMgr:sendMsg("GuildMapServer", "getMapTaskReward", {taskId = tonumber(taskBtn.taskID)}, true, {}, 
            function(result)
                DialogUtils.showGiftGet({
                    gifts = result.reward,
                    callback = function()
                        self:reflashPushMapTask()
                    end
                    })
            end,
            function()
                self._viewMgr:showTip("暂时不能领取任务")
            end)
    else
        local eleId = self._mapLayer._gridElements[inGridKey]
        self:showDialog("guild.map.GuildMapBoxDesNode", {taskId = tonumber(taskBtn.taskID), eleId = eleId}, true)
    end
end

function GuildMapView:applicationDidEnterBackground()
    self._modelMgr:getModel("GuildMapModel"):lockPush()
    self._isHaveGoBack = true
    if self._viewMgr:getCurViewName() ~= self:getClassName() then return end
    local popViews  = self:getPopViews()
    if popViews ~= nil and next(popViews) ~= nil then 
        for k,v in pairs(popViews) do
            if v ~= nil and v.setVisible ~= nil and v:getClassName() ~= "global.NetWorkDialog" then
				if v:getClassName() == "chat.ChatView" or v:getClassName()=="guild.map.GuildMapTagView" then
					if v.detachKeyBoard then
						v:detachKeyBoard()
					end
				end
                v:setVisible(false)
            end
        end
    end
end


function GuildMapView:applicationWillEnterForeground()
    self._enterForeground = 1
    if self._viewMgr:getCurViewName() ~= self:getClassName() then return end
    self:getMapInfo()
	if self._widgetVisibleState and self._widgetVisibleState==0 then
		self:refreshWidgetVisible(1)
	end
end


function GuildMapView:preViewMap(inGuild)
    self._modelMgr:getModel("GuildMapModel"):lockPush()
    self._serverMgr:sendMsg("GuildMapServer", "preViewMap", {tagGid = inGuild}, true, {}, function(result, errorCode)
        
        if errorCode == GuildConst.GUILD_MAP_RESULT_CODE.GUILD_MAP_RENEW then 
            self._viewMgr:showTip(lang("GUILD_MAP_RESULT_CODE_TIP_" .. errorCode))
            self:close()
            return
        end
        if result.code == GuildConst.GUILD_MAP_RESULT_CODE.GUILD_MAP_NOT_UP then 
            return
        end
        self:refreshUIUnify()
    end)
end

function GuildMapView:checkMapUpdate()
    if self._isHaveGoBack == true then 
        self:getMapInfo()
        self._isHaveGoBack = false
        return true
    end
    return false
end

function GuildMapView:getMapInfo()
    local upTime = self._guildMapModel:getData().upTime
    self._serverMgr:sendMsg("GuildMapServer", "getMapInfo", {upTime = upTime}, true, {}, function(result, errorCode)
        if errorCode == GuildConst.GUILD_MAP_RESULT_CODE.GUILD_MAP_RENEW then 
            self._viewMgr:showTip(lang("GUILD_MAP_RESULT_CODE_TIP_" .. errorCode))
            self:close()
            return
        end
        if result.code == GuildConst.GUILD_MAP_RESULT_CODE.GUILD_MAP_NOT_UP then 
            self._viewMgr:lock(-1)
            local popViews  = self:getPopViews()
            if popViews ~= nil and next(popViews) ~= nil then 
                for k,v in pairs(popViews) do
                    if v ~= nil and v.setVisible ~= nil then
                        v:setVisible(true)
                    end
                end
            end
            self._viewMgr:unlock()
            return
        end
        self._viewMgr:lock(-1)
        local popViews  = self:getPopViews()
        if popViews ~= nil and next(popViews) ~= nil then 
            for k,v in pairs(popViews) do
                if v ~= nil and v.close ~= nil and v:getClassName() ~= "global.NetWorkDialog" then
                    v:close(true)
                end
            end
        end
        self._viewMgr:unlock()

        self:refreshUIUnify()
    end)
end

--第一次进入界面 统一刷新
function GuildMapView:refreshUIUnify()
    self:reflashView()
    self:reflashPushMapTask()
    self:reflashUpdateReport()
    self:reflashUpdateRuleOpen()
    self:reflashFormationRedTip()
end

function GuildMapView:reflashFormationRedTip()
    local formationModel = self._modelMgr:getModel("FormationModel")

    local isFullTeam = formationModel:isFormationTeamFullByType(formationModel.kFormationTypeGuildDef)
    local isNotFullWeapons = formationModel:isHaveWeaponCanLoaded(formationModel.kFormationTypeGuildDef)

    local formatioBtn = self:getUI("Panel_29.extendBar.bg.map_formation_btn")
    
    if formatioBtn ~= nil then
        local redPoint = formatioBtn:getChildByName("redPoint")
        if redPoint == nil then 
            redPoint = cc.Sprite:createWithSpriteFrameName("globalImageUI_bag_keyihecheng.png")
            redPoint:setPosition(formatioBtn:getContentSize().width - 10, formatioBtn:getContentSize().height - 10)
            redPoint:setName("redPoint")
            formatioBtn:addChild(redPoint)
        end
        if not isFullTeam or isNotFullWeapons then
            redPoint:setVisible(true) 
        else
            redPoint:setVisible(false) 
        end
    end
end

function GuildMapView:refreshWidgetVisible(inState, hideUnMark)--添加hideUmMark参数，针对新年使者的传送功能。避免联盟长标记之后，传送状态时没隐藏取消标记button   --lannan
    local isShow = inState == 1 and true or false
    local count = #self._widget:getChildren()
    for i = 1, count do
        local obj = self._widget:getChildren()[i]
        if isShow == true then
            if (hideUnMark or obj:getName() ~= "unMarkBtn") and obj.isShow == 1 then 
                obj:setVisible(true)
                obj.isShow = nil
            end
            
        else
            if hideUnMark or obj:getName() ~= "unMarkBtn" then 
                obj.isShow = obj:isVisible() and 1 or 0
                obj:setVisible(false)
            end
        end
        
    end
    local navigation = self._viewMgr:getNavigation("global.UserInfoView")
    navigation:setVisible(isShow)
    self._chatNode:setVisible(isShow)
	self._widgetVisibleState = inState
end

function GuildMapView:refreshTagBtn()
    local markBtn = self:getUI("markBtn")
    local unMarkBtn = self:getUI("unMarkBtn")
    local unMarkTip = self:getUI("unMarkBtn.tip")
    local markImg = markBtn:getChildByName("markImg")
    local title = markBtn:getChildByName("title")

    local isMarking = self._guildMapModel:getMarkingState()
    local isGuildMgr = self._userModel:getData()["roleGuild"]["pos"] == 1
    
    markBtn:setVisible(false)
    unMarkBtn:setVisible(false)
    unMarkTip:setVisible(false)

    local guildId = self._modelMgr:getModel("UserModel"):getData().guildId
    local currentGuildId = self._guildMapModel:getData().currentGuildId
    if tostring(guildId) ~= tostring(currentGuildId) then
        return
    end

    local selfPoint = self._guildMapModel:getData().selfPoint 
    if selfPoint == nil then
        return
    end

    if isGuildMgr == true then  --联盟长
        if isMarking == true then
            unMarkBtn:setVisible(true)
            unMarkBtn:setPositionY(191)
        else
            markBtn:setVisible(true)
            markImg:loadTexture("guildMapBtn_mark1.png", 1)
            title:setString("标记")
        end
    else
        markBtn:setVisible(true)
        markImg:loadTexture("guildMapBtn_markCheck.png", 1)
        title:setString("查找标记")
    end
end

function GuildMapView:refreshAQBtn()
    local datiBtn = self:getUI("datiBtn")
    datiBtn:setVisible(false)

    local aqTime = self._guildMapModel:getAQAcTime()
    local curTime = self._userModel:getCurServerTime()
    if aqTime == nil or #aqTime < 3 or curTime >= aqTime[3] or curTime < aqTime[1] then
        return
    end

    local userModel = self._modelMgr:getModel("UserModel")
    local curTime = userModel:getCurServerTime()
    if curTime >= aqTime[1] and curTime < aqTime[3] then
        datiBtn:setVisible(true)
        local titleBg = datiBtn:getChildByName("titleBg")
        titleBg:setVisible(true)

        local timeDes = datiBtn:getChildByName("time")
        if aqTime[2] - curTime <= 0 then
            timeDes:setString("活动已结束")
        else
            local repeatAction = cc.RepeatForever:create(cc.Sequence:create(
                cc.CallFunc:create(function()
                    local curTime = userModel:getCurServerTime()
                    local timeDis = aqTime[2] - curTime
                    if timeDis <= 0 then
                        timeDes:setString("活动已结束")
                        timeDes:stopAllActions()
                    else
                        local timeStr = TimeUtils.getTimeString(timeDis)
                        timeDes:setString("倒计时" .. timeStr)
                    end
                end),
                cc.DelayTime:create(1)))
            timeDes:runAction(repeatAction)
        end

    end
end

function GuildMapView:reflashUpdateTreasure()--藏宝图
	local treasureBtn = self:getUI("treasure.treasureBtn")
    local guildId = self._modelMgr:getModel("UserModel"):getData().guildId
    local currentGuildId = self._guildMapModel:getData().currentGuildId
    if tostring(guildId) ~= tostring(currentGuildId) then
        treasureBtn:setVisible(false)
        return
    end
    treasureBtn:setVisible(not self._isPreview)
	local treasureStateLab = self:getUI("treasure.treasureBtn.stateLab")
	treasureStateLab:setVisible(self._guildMapModel:getTreasureState())
	if self._mapLayer then
		self._mapLayer:updateHeroTreasure()
	end
    if self._guildMapModel:getTreasureState() then
        UIUtils.addRedPoint(treasureBtn, false)
    else
        local items = self._modelMgr:getModel("ItemModel"):getItemsByType(ItemUtils.ITEM_TYPE_GUILD_MAP_TREASURE)
        if not items or table.nums(items) == 0 then
            UIUtils.addRedPoint(treasureBtn, false)
        else
            UIUtils.addRedPoint(treasureBtn, true)
        end
    end
    local treasureDebug = treasureBtn:getChildByName("treasureDebug")
    if OS_IS_WINDOWS then
        local treasureData = self._guildMapModel:getTreasureData()
        if self._guildMapModel:getTreasureState() then
            if treasureDebug then
                treasureDebug:setVisible(true)
                treasureDebug:setString(treasureData.point)
            else
                treasureDebug = cc.Label:createWithTTF("", UIUtils.ttfName, 16)
                treasureDebug:setName("treasureDebug")
                treasureDebug:setString(treasureData.point)
                treasureDebug:setColor(cc.c4b(0, 255, 0, 255))
                treasureDebug:enableOutline(cc.c4b(0, 0, 0, 255), 1)
                treasureDebug:setPosition(treasureStateLab:getPosition() + treasureStateLab:getContentSize().width, -25)
                treasureBtn:addChild(treasureDebug)
            end
        elseif treasureDebug then
            treasureDebug:setVisible(false)
        end
    elseif treasureDebug then
        treasureDebug:setVisible(false)
    end
end

function GuildMapView:setFamData()
    local exploreValue = self._modelMgr:getModel("PlayerTodayModel"):getDayInfo(72)
    local haveActivited = self._modelMgr:getModel("PlayerTodayModel"):getDayInfo(73)
    local famRatio = tab:Setting("FAMEXPLORATION").value
    if exploreValue then
        print("exploreValue = "..exploreValue)
    else
        error("not exploreValue")
    end
    if haveActivited then
        print("haveActivited = "..haveActivited)
    else
        error("not haveActivited")
    end
    if famRatio then
        print("famRatio[1] = "..famRatio[1])
        print("famRatio[2] = "..famRatio[2])
    else
        error("not famRatio")
    end
    local percent = exploreValue/famRatio[1]*famRatio[2]*100
    --判断当前秘境状态
    print("percent = "..percent)
    local percentText = lang("GUILD_FAM_TIPS_1")
    percentText = string.gsub(percentText, "$pro", percent)
    self._famBtn:setTouchEnabled(false)
    if haveActivited==1 then
        self._famProgress:setPercent(0)
        self._exploreValueLabel:setString(lang("GUILD_FAM_TIPS_20"))
        local famShowTime = self._userModel:getFamCreateTime()
        local famType = self._userModel:getFamType()
        local lifeTime = tab.famAppear[famType].time
        local nowTime = self._userModel:getCurServerTime()
        local time = nowTime - (famShowTime+lifeTime)
        print("")
        if nowTime>=famShowTime+lifeTime then
            percentText = lang("GUILD_FAM_TIPS_3")
        else
            percentText = lang("GUILD_FAM_TIPS_2")
            self._stateLabel:runAction(cc.Sequence:create(cc.DelayTime:create(lifeTime-(nowTime-famShowTime)),cc.CallFunc:create(function()
                if self._stateLabel then
                    self._stateLabel:setString(lang("GUILD_FAM_TIPS_3"))
                end
            end)))
            self._famBtn:setTouchEnabled(true)
        end
    else
        self._famProgress:setPercent(percent)
        self._exploreValueLabel:setString(string.format("%s/%s", exploreValue, tonumber(tab:Setting("FAMEXPLORATIONNUMMAX").value)))
    end
    self._stateLabel:setString(percentText)
end

function GuildMapView:reflashFindFam()
    self._viewMgr:showDialog("guild.map.GuildMapFindFamEffectDialog")
end

function GuildMapView:reflashToInviteFamGrid()
    if self._mapLayer then
        local mapData = self._modelMgr:getModel("GuildMapModel"):getData()
        local myGuildId = self._modelMgr:getModel("UserModel"):getData().guildId
        if tonumber(myGuildId)~=tonumber(mapData.currentGuildId) then
            self._viewMgr:showGlobalDialog("global.GlobalSelectDialog",
            {
                desc = lang("GUILD_FAM_TIPS_27"),
                button1 = "确定" ,
                button2 = "取消", 
                callback1 = function ()
                    self._mapLayer:backCity()
                    local gridKey = self._guildMapModel:getEvents()["ToInviteFamGrid"]
                    self._famPos = string.split(gridKey, ",")
                    self._guildMapModel:getEvents()["ToInviteFamGrid"] = nil
                end,
                callback2 = function()
                    self._guildMapModel:getEvents()["ToInviteFamGrid"] = nil
                end
            }, true)
        else
            local gridKey = self._guildMapModel:getEvents()["ToInviteFamGrid"]
            local pos = string.split(gridKey, ",")
            self._mapLayer:screenToGrid(tonumber(pos[1]), tonumber(pos[2]), true, function()
                self._mapLayer:touchRemoteGridEvent(pos[1], pos[2])
                self._guildMapModel:getEvents()["ToInviteFamGrid"] = nil
            end)
        end
    end
end

function GuildMapView:screenToFamGridKey()
    local famGridKey = self._guildMapModel:getFamGridKeyByRoleId(self._userModel:getRID())
    if famGridKey then
        local pos = string.split(famGridKey, ",")
        self._mapLayer:screenToGrid(tonumber(pos[1]), tonumber(pos[2]), true)
    else
        self._viewMgr:showTip("暂时无秘境")
    end
end

--初始化新年使者
function GuildMapView:onInitNewYear()
    self._buffNode = {}
    for i=1, 2 do
        self._buffNode[i] = {
            image = self:getUI("title.buffImg"..i),
            nameLab = self:getUI("title.buffImg"..i..".buffLab"),
            timeLab = self:getUI("title.buffImg"..i..".timeLab")
        }
        self._buffNode[i].image:setVisible(false)
    end
    self:reflashUpdateYearBuff()
end

--新年使者buff更新
function GuildMapView:reflashUpdateYearBuff()
    for i=1, 2 do
        self._buffNode[i].image:setVisible(false)
        self._buffNode[i].image:stopAllActions()
    end
    local yearBuff = self._guildMapModel:getYearBuffData()
    local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local count = 1
    for i,v in pairs(yearBuff) do
        if v.end_time>nowTime then
            local buffNode = self._buffNode[count]
            buffNode.nameLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            buffNode.timeLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            buffNode.nameLab:setString(tonumber(i)==3002 and "日行千里" or "战争鼓舞")
            local repeatAction = cc.RepeatForever:create(
                cc.Sequence:create(cc.CallFunc:create(function()
                    local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
                    buffNode.image:setVisible(v.end_time-curTime>0)
                    if v.end_time-curTime>0 then
                        buffNode.timeLab:setString(TimeUtils.getTimeStringMS(v.end_time-curTime))
                    else
                        self._guildMapModel:resetYearBuffDataById(i)
                        self:reflashUpdateOfficerState()
                        buffNode.image:stopAllActions()
                    end
                end),
                cc.DelayTime:create(1)))
            buffNode.image:runAction(repeatAction)
            buffNode.image:setVisible(true)
            count = count + 1
        end
    end
    self:reflashUpdateOfficerState()
end

--初始化军需官
function GuildMapView:reflashUpdateOfficerState()
    local officerHeadBtn = self:getUI("title.officerHeadBtn")
    local officerPanel = self:getUI("officerPanel")
    officerPanel:setVisible(false)
    local targetGuildId = self._guildMapModel:getOfficerTargetGuildId()
    local officerState
    local commanderData = self._guildMapModel:getCommanderData()
    local maxInterval = tab:Setting("OFFICER_REWARD_TOTAL").value*60
    if targetGuildId and targetGuildId~=0 then
        officerState = 1--已经领取NPC1任务，还未找NPC2
    elseif commanderData and commanderData.rtime and commanderData.actime and  tonumber(commanderData.rtime)-tonumber(commanderData.actime)<maxInterval then--此处需要完善
        officerState = 2--已经在NPC2处选择了奖励类型
    end
    officerHeadBtn:setVisible(officerState~=nil)--没有状态时证明没找过NPC1
--  officerPanel:setVisible(officerState~=nil)
    local yearBuff = self._guildMapModel:getYearBuffData() or {}
    if table.nums(yearBuff)>0 then
        officerHeadBtn:setPositionX(115)
    else
        officerHeadBtn:setPositionX(36)
    end
    officerPanel:setSwallowTouches(false)
    self:registerClickEvent(officerHeadBtn, function()
        local officerTipReward = officerPanel:getChildByName("officerTipReward")
        officerTipReward:setVisible(officerState==2)
        local officerTipText = officerPanel:getChildByName("officerTipText")
        officerTipText:setVisible(officerState==1)
        if officerState==1 then
            local richText = RichTextFactory:create(lang("GUILD_MILITARY_TIP_1"), 200)
            richText:setPixelNewline(true)
            richText:formatText()
            richText:setVerticalSpace(3)
            richText:setAnchorPoint(cc.p(0.5, 0.5))
            richText:setName("richText")
            local sizeWidth = richText:getRealSize().width+30
            local sizeHeight = richText:getInnerSize().height+30
            if sizeHeight<officerTipText:getContentSize().height then
                sizeHeight = officerTipText:getContentSize().height
            end
            officerTipText:setContentSize(sizeWidth, sizeHeight)
            richText:setPosition(cc.p(sizeWidth/2, sizeHeight/2))
            officerTipText:addChild(richText)
            
            
            local posx = officerHeadBtn:getParent():convertToWorldSpace(cc.p(officerHeadBtn:getPosition())).x+officerHeadBtn:getContentSize().width/2 +officerTipText:getContentSize().width/2
            local posy = officerHeadBtn:getParent():convertToWorldSpace(cc.p(officerHeadBtn:getPosition())).y-officerTipText:getContentSize().height/2
            officerTipText:setPosition(cc.p(posx, posy))
        else
            local posx = officerHeadBtn:getParent():convertToWorldSpace(cc.p(officerHeadBtn:getPosition())).x+officerHeadBtn:getContentSize().width/2 +officerTipReward:getContentSize().width/2
            local posy = officerHeadBtn:getParent():convertToWorldSpace(cc.p(officerHeadBtn:getPosition())).y-officerTipReward:getContentSize().height/2
            officerTipReward:setPosition(cc.p(posx, posy))
            self:onInitOfficerRewardTip()
        end
        self:registerTouchEvent(officerPanel, function()
            officerPanel:setVisible(false)
        end, function()
            officerPanel:setVisible(false)
        end, function()
            officerPanel:setVisible(false)
        end, function()
            officerPanel:setVisible(false)
        end, function()
            
        end)
        officerPanel:setVisible(true)
    end)
end

function GuildMapView:onInitOfficerRewardTip()
    local commanderData = self._guildMapModel:getCommanderData()
    
    local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local interval = tab:Setting("OFFICER_REWARD_INTERVAL").value*60
    
    local maxTimeInterval = tab:Setting("OFFICER_REWARD_TOTAL").value*60
    local intervalTimeStr = TimeUtils.getStringTimeForInt(maxTimeInterval)
    
    local timeLab = self:getUI("officerPanel.officerTipReward.timeLab")
    local titleLab = self:getUI("officerPanel.officerTipReward.titleLab")
    
    local canGet = false
    local getTimes = math.floor((commanderData.rtime-commanderData.actime)/interval)
    local maxCanGetTimes = maxTimeInterval/interval
    local nowTimes = math.floor((nowTime-commanderData.actime)/interval)
    nowTimes = nowTimes>maxCanGetTimes and maxCanGetTimes or nowTimes
    
    local rewardPanel = self:getUI("officerPanel.officerTipReward.rewardPanel")
    
    local rewardCountLab = self:getUI("officerPanel.officerTipReward.rewardCountLab")
    local rewardCountLab2 = self:getUI("officerPanel.officerTipReward.rewardCountLab2")
    rewardCountLab:setString(nowTimes)
    rewardCountLab2:setPositionX(rewardCountLab:getPositionX()+rewardCountLab:getContentSize().width+1)
    
    
    timeLab:stopAllActions()
    local repeatAction =cc.RepeatForever:create(
        cc.Sequence:create(cc.CallFunc:create(function()
            local nowTimeStamp = self._modelMgr:getModel("UserModel"):getCurServerTime()
            local nowInterval = nowTimeStamp - tonumber(commanderData.actime)
            local nowIntervalStr = TimeUtils.getStringTimeForInt(nowInterval)
            
            if nowTimes<maxCanGetTimes then--当到了下一个奖励激活的时候，更新界面。
                local nextTimeStamp = tonumber(commanderData.actime) + (nowTimes+1)*interval
                if nowTimeStamp>nextTimeStamp then
                    nowTimes = nowTimes + 1
                    rewardCountLab:setString(nowTimes)
                    rewardCountLab2:setPositionX(rewardCountLab:getPositionX()+rewardCountLab:getContentSize().width+1)
                    local node = rewardPanel:getChildByName("node"..nowTimes)
                    node:setSaturation(0)
                    node:setEnabled(true)
                    if rewardPanel:getChildByName("collectionLab"..nowTimes) then
                        rewardPanel:getChildByName("collectionLab"..nowTimes):removeFromParent()
                    end
                end
            end
            if nowInterval>=maxTimeInterval then
                titleLab:setString("奖励收集完成")
                timeLab:setString(intervalTimeStr.."/"..intervalTimeStr)
                timeLab:stopAllActions()
            else
                titleLab:setString("收集奖励中")
                timeLab:setString(nowIntervalStr.."/"..intervalTimeStr)
            end
        end),
        cc.DelayTime:create(1)))
    timeLab:runAction(repeatAction)
    
    rewardPanel:removeAllChildren()
    local rewards = tonumber(commanderData.type)~=3 and commanderData.rewards or commanderData.mapEquips
    
    local posX = 0
    for i,v in ipairs(rewards) do
        if table.nums(v)~=1 then
            error(string.format("Wrong number of officer reward, expect 1, get %d!!!@lizhiyuan", table.nums(v)))
        end
        local rewardData = v[1]
        local node
        if tonumber(commanderData.type)~=3 then
            local itemId = rewardData[2]
            if rewardData[1] ~= "tool" then
                itemId = IconUtils.iconIdMap[rewardData[1]]
            end
            node = IconUtils:createItemIconById({itemId = itemId, num = rewardData[3], eventStyle = 4})
        else
            node = IconUtils:createGuildMapEquipment({equipId = rewardData[1], num = rewardData[2]})
        end
        node:setAnchorPoint(0.5, 0.5)
        node:setScale(0.5)
        node:setName("node"..i)
        local row = math.ceil(i/4)
        local posY = rewardPanel:getContentSize().height - (row-0.5)*node:getContentSize().height*0.5 - (row-1)*3
        local index = i%4==0 and 4 or i%4
        if index==1 then
            posX = 0
        end
        posX = rewardPanel:getContentSize().width*((index*2-1)/8)
        node:setPosition(posX, posY)
        rewardPanel:addChild(node)
        node:setSaturation(0)
        node:setEnabled(true)
        if i>nowTimes then
            node:setSaturation(-100)
            node:setEnabled(false)
            local collectionLab = ccui.Text:create()
            collectionLab:setString("收集中")
            collectionLab:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
            collectionLab:setFontName(UIUtils.ttfName)
            collectionLab:setFontSize(22)
            collectionLab:setScale(0.5)
            collectionLab:setName("collectionLab"..i)
            collectionLab:enableOutline(UIUtils.colorTable.titleOutLineColor, 1)
            collectionLab:setAnchorPoint(0.5, 0)
            collectionLab:setPosition(node:getPositionX(), node:getPositionY()-node:getContentSize().height*0.5/2+3)
            rewardPanel:addChild(collectionLab)
        elseif i<=getTimes then
            node:setEnabled(false)
            local hasGetImg = ccui.ImageView:create()
            hasGetImg:loadTexture("globalImageUI_activity_getItBlue.png", 1)
            hasGetImg:setPosition(cc.p(node:getContentSize().width/2, node:getContentSize().height/2))
            node:addChild(hasGetImg, 10)
        end
    end
end

function GuildMapView:updateCenter20(dTime)--地下城20分钟强制退出，防挂机
	local nowTime = self._userModel:getCurServerTime()
	local limitTime = tab:Setting("CROSSGUILD_MAXSTAY_TIME").value*60
	if self._centerTime and nowTime-self._centerTime>=limitTime and self._viewMgr:getCurViewName()=="guild.map.GuildMapView" and not self._limitViewShow then
		self._limitViewShow = true
		self._viewMgr:showDialog("global.NetWorkDialog", {msg = lang("DUNGEON_KICKOUT"), callback = function()
			ViewManager:getInstance():returnMain()
		end})
		if self._updateId then
			ScheduleMgr:unregSchedule(self._updateId)
			self._updateId = nil
		end
	end
end

function GuildMapView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{types= {"", "MapHurt", "GuildPower"},offset = {-50,0}, hideBtn = false,hideHead = true, callback = function()
        if self._isPreview == true then 
            self._guildMapModel:clear()
        end
        self._serverMgr:sendMsg("GuildMapServer", "quitMapRoom", {}, true, {}, function(result, errorCode)
            return
        end)
        -- self:close()
    end}, nil, (ADOPT_IPHONEX or ADOPT_XIAOMIM2) and 1136 or nil)
end


function GuildMapView:onReconnect()
    if self._enterForeground == 1 then 
        self._enterForeground = 0
        return
    end
    self:getMapInfo()
end

function GuildMapView:showRankView()
    -- self._serverMgr:sendMsg("GuildMapServer", "getRankList", {upTime = upTime}, true, {}, function(result, errorCode)
    --     if result == nil then return end
        self._viewMgr:showDialog("guild.map.GuildMapRankView", {}, true)
    -- end)    
end

function GuildMapView:getAsyncRes()
    return {
            {"asset/ui/guildMap.plist", "asset/ui/guildMap.png"},
            {"asset/ui/guildMap1.plist", "asset/ui/guildMap1.png"},
            {"asset/ui/guildMap2.plist", "asset/ui/guildMap2.png"},
            {"asset/ui/guildMapIcon.plist", "asset/ui/guildMapIcon.png"},
            {"asset/ui/guildMapbuild.plist", "asset/ui/guildMapbuild.png"},
            {"asset/ui/guildMapbuild1.plist", "asset/ui/guildMapbuild1.png"},
            {"asset/ui/alliance2.plist", "asset/ui/alliance2.png"},
            {"asset/ui/guildMapIcon1.plist", "asset/ui/guildMapIcon1.png"},
        }
end

function GuildMapView:onDestroy()
	if self._updateId then
		ScheduleMgr:unregSchedule(self._updateId)
		self._updateId = nil
	end
    self._viewMgr:disableScreenWidthBar()
    GuildMapView.super.onDestroy(self)
end

function GuildMapView:setNoticeBar()
    self._viewMgr:hideNotice(true)
end

return GuildMapView



