--
-- Author: huachangmiao@playcrab.com
-- Date: 2016-10-12 11:07:34
--

local DevelopDialog = class("DevelopDialog", BasePopView)

function DevelopDialog:ctor(data)
    DevelopDialog.super.ctor(self)

    self._devList = 
    {
        -- 名称, function
        {"FPS开关", 
        function () 
            GameStatic.showDEBUGInfo = not GameStatic.showDEBUGInfo
            cc.Director:getInstance():setDisplayStats(GameStatic.showDEBUGInfo)
            self._viewMgr:showDebugInfo(GameStatic.showDEBUGInfo)   
        end},
        {"mc测试", 
        function () 
            if self._text:getString() == "" then self._viewMgr:showTip("没填参数") return end
            local mc = mcMgr:createViewMC(self._text:getString(), false, true)
            mc:setPosition(cc.p(MAX_SCREEN_WIDTH*0.5,MAX_SCREEN_HEIGHT*0.5))
            self:addChild(mc)
        end},
        {"分享", 
        function () 
            self._viewMgr:showDialog("share.ShareBaseView", {moduleName = "ShareCloudModule", stage = 2})
        end},
        {"航海", 
        function () 
            self._viewMgr:showView("MF.MFView")
        end},
        {"兵团技巧", 
        function () 
            -- if self._text:getString() == "" then self._viewMgr:showTip("没填参数") return end
            -- 

            -- self._viewMgr:showDialog("global.DialogUserLevelUp")
            -- self._viewMgr:showDialog("guild.dialog.GuildTipBindDialog")
            -- self._viewMgr:showDialog("pokedex.PokedexShowDialog")
            -- self._viewMgr:showDialog("backflow.BackflowView")
            -- local teamId = self._modelMgr:getModel("TeamModel"):getTeamMaxFightScore()
            -- print("teamId========", teamId)

            -- self._modelMgr:getModel("SignModel"):isSignInTip()

            -- local param = {teamId = 106} 
            -- self._viewMgr:showDialog("team.TeamAwakenOpenTaskDialog", param)
            -- self._viewMgr:showDialog("godwar.GodWarChampionDialog", {})
            
            UIUtils:reloadLuaFile("team.TeamHolyView")
            self._viewMgr:showView("team.TeamHolyView", {})
        end},
        {"spine", 
        function () 
            -- spineMgr:createSpine("xinshouyindao", function (spine)
            --     -- spine:setVisible(false)
            --     spine.endCallback = function ()
            --         spine:setAnimation(0, "pingdan", true)
            --     end 
            --     local anim = "pingdan"
            --     spine:setAnimation(0, anim, true)
            --     spine:setPosition(400, 300)
            --     self:addChild(spine)
            -- end)
            spineMgr:createSpine("baitian-shijiu", function (spine)
                -- spine:setVisible(false)
                spine.endCallback = function ()
                    spine:setAnimation(0, "shijiu", true)
                end 
                spine:setSkin("huanghun")
                local anim = "shijiu"
                spine:setAnimation(0, anim, true)
                spine:setPosition(400, 300)
                self:addChild(spine)
            end)
        end},
        {"公告测试", 
        function () 
            local f = io.open("./script/test/gonggao.txt", 'r')
            local str = f:read("*all")
            -- print(json.encode(str))
            self._viewMgr:showDialog("login.LoginNoticeView",{data = str}, true)
        end},
        {"剧情动画", 
        function () 
            self._viewMgr:showDialog("intance.IntancePlotReviewView", {})
            -- self._viewMgr:showDialog("intance.IntanceStoryInfoView", {title = "哈哈", story = "mainstorybeginInfo_1", test = 1})            
--                 self._viewMgr:showView("intance.IntanceMcPlotView", {plotId = 2, callback = function()
--                     self._viewMgr:popView()
--                 end})
        end},    
        {"英雄Solo", 
        function () 
            if self._text:getString() == "" then self._viewMgr:showTip("没填参数") return end
            local mask = ccui.Layout:create()
            mask:setBackGroundColorOpacity(255)
            mask:setBackGroundColorType(1)
            mask:setBackGroundColor(cc.c3b(0,0,0))
            mask:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
            mask:setOpacity(180)
            self:addChild(mask)

            local solo = HeroSoloPlayer.new()
            solo:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5 - 100)
            self:addChild(solo)
            solo:init(
            {
                -- 左边信息
                info1 =
                {
                    heroID = 60102,
                    HP_begin = 8,
                    HP_end = 6,
                    name = "我是大哥",
                    HP_color = 1, -- 1红2蓝3绿
                },
                -- 右边信息
                info2 =
                {
                    heroID = 60303,
                    HP_begin = 5,
                    HP_end = 0,
                    name = "我是二哥",
                    HP_color = 2,
                },
                -- heroSoloGroup表ID
                groupID = tonumber(self._text:getString()),
                -- 表里定义的进攻是左还是右
                atkCamp = 1,
                -- 胜利者 1 or 2 / 0 是平局
                winCamp = 1,
            })
        end},
        {"GVG", 
        function () 
            local textStr = self._text:getString()
            if textStr == "" then self._viewMgr:showTip("参数 1地图，2备战，3布阵，4领奖, 5清除") return end
            if tonumber(textStr) == 1 then
                self._viewMgr:showView("citybattle.CityBattleView")
            elseif tonumber(textStr) == 2 then
                self._viewMgr:showDialog("citybattle.CityBattleReadlyFightDialog")
            elseif tonumber(textStr) == 3 then
                self._viewMgr:showDialog("citybattle.CityBFChangeDialog")
            elseif tonumber(textStr) == 4 then
                self._viewMgr:showDialog("citybattle.CityBattleAwardDialog")
            elseif tonumber(textStr) == 5 then
                SystemUtils.saveAccountLocalData("CITYBATTLE_READY_TIME",nil)
                SystemUtils.saveAccountLocalData("CITYBATTLE_BATTLE_TIME",nil)
                SystemUtils.saveAccountLocalData("CITYBATTLE_BATTLE_RESULT1",nil)
                SystemUtils.saveAccountLocalData("CITYBATTLE_BATTLE_RESULT2",nil)
                SystemUtils.saveAccountLocalData("CITYBATTLE_OPEN",nil)
                SystemUtils.saveAccountLocalData("CITYBATTLE_OPEN_MC_TIME",nil)
                SystemUtils.saveAccountLocalData("CITYBATTLE_NUM_TIME",nil)
                SystemUtils.saveAccountLocalData("CITYBATTLE_NUM_READY_TIME",nil)
                SystemUtils.saveAccountLocalData("CITYBATTLE_PRI_TIME", nil)
            end 
        end},
        {"guoj..", 
        function () 
            -- if not i then 
            --     i = 1
            -- end
            self._viewMgr:showView("purgatory.PurgatoryView")
            -- self._viewMgr:showDialog("league.LeagueOpenFlyView", {target = self}, true)
            -- DialogUtils.showTeam({teamId=402})--(100)*math.floor(i/7+1)+i%7+1}) -- 402})--
            -- i = i+1
            -- DialogUtils.showCard({itemId=3104,changeNum=10})
             -- self._viewMgr:showDialog("league.LeagueUpStageView",{zone=2})
             -- DialogUtils.showGiftGet({
             --    gifts = {{"tool",3001,15,txPlus = {is_qq_vip=100}}},
             --    title = lang("FINISHSTAGETITLE"),
             --    })-- vipPlus = 1.5
            -- UIUtils:reloadLuaFile("hero.HeroUnlockView")
            -- local heroUnlockLayer = self._viewMgr:createLayer("hero.HeroUnlockView", {heroId = 60103, callBack = function()end})
            -- self:addChild(heroUnlockLayer,999)
        end},  
        {"公测庆典", 
        function () 

            self._viewMgr:showDialog("activity.celebration.AcCelebrationView",{},true)
        end},
        {"RS", 
        function () 
            ServerManager:getInstance():RS_initSocket(
            {
                url = "ws://192.168.4.111:9190/websocket",
                checkKey = "mDfhdksljhfja&(r4qr",
                mtime = 345,
                rid = "rid",
                roomId = "roomId",
                platform = "platform",
            },
            function ()
                -- 连接成功回调
                print("rs init success")
            end,
            function (data)
                -- 正常回调
                dump(data)

            end,
            function (data)
                print("rs error")
                dump(data)
                -- 连接失败&重大错误回调
            end)
        end},    
        
        {"RS请求", 
        function () 
            ServerManager:getInstance():RS_sendMsg("aaa", "bbb", {})
        end},
        {"RS断", 
        function () 
            ServerManager:getInstance():RS_clear()
        end},
        {"活动甘特图", 
        function () 
            self._viewMgr:showView("dev.TestActivityTimeList")
        end},
        {"GVG后端", 
        function () 
            local textStr = self._text:getString()
            self._serverMgr:sendMsg("CityBattleServer", "getCitybattleSoketData", {}, true, {}, function (result, error)
                if error ~= 0 then 
                    self._viewMgr:showTip("连接服务器失败")
                    return 
                end
                self._userModel = self._modelMgr:getModel("UserModel")
                local params = {}
                params.rid = self._userModel:getData()._id
                params.name = self._userModel:getData().name
                params.test = textStr
                ServerManager:getInstance():RS_sendMsg("PlayerProcessor", "test", params or {})           
                -- self._onBeforeAddCallback(1)
                -- self:setVisible(false)
            end)  
        end},
        {"联盟地图", 
        function () 
            self._viewMgr:showView("guild.map.GuildMapView")
        end},
        {"元素位面", 
        function () 
            self._viewMgr:showView("elemental.ElementalView")
        end},
        {"联盟佣兵", 
        function () 
            self._viewMgr:showView("guild.mercenary.GuildMercenaryView")
        end},
        {"法术抽取", 
        function () 
            self._viewMgr:showView("skillCard.SkillCardTakeView")
        end},
        {"秘境动画", 
        function () 
            self._viewMgr:showDialog("guild.map.GuildMapFindFamEffectDialog")
        end},
        {"ad调位置", 
        function () 
            self._viewMgr:showDialog("activity.AdvertisementView", {isAdjust = true}, true)
        end},
        {"攻城战日常", 
        function () 
            self._viewMgr:showDialog("siegeDaily.SiegeDailySelectView")
        end},
        {"攻城战抽卡", 
        function () 
            self._viewMgr:showView("siege.SigeCardView")
        end},
        {"攻城战剧情动画", 
        function () 
            self._viewMgr:showView("siege.SiegeMcPlotView", {plotId = 1, callback = function()
                self._viewMgr:popView()
            end})
        end},
        {"调试对话", 
        function () 
            local param = self._text:getString()
            if param == "" then self._viewMgr:showTip("没填参数") return end
            -- talkId, hideList, callback, notClose, noJump
            local talkIdx = tonumber(param)
            if talkIdx == 0 then
                local guideStoryConfig = require "game.config.guide.GuideStoryConfig"
                local nextStoryFuc 
                nextStoryFuc = function  ( talkIdx )
                    self._viewMgr:enableTalking(talkIdx,{},function( )
                        local index,newStory = next(guideStoryConfig,talkIdx)
                        if newStory then
                            self._text:setString(index or 0)
                            nextStoryFuc(index)
                        end
                    end,false,true)
                end
                nextStoryFuc(next(guideStoryConfig))
            else
                self._viewMgr:enableTalking(talkIdx,{},nil,false,true)
            end
        end},
        {"国王联赛", 
        function () 
            local state = self._modelMgr:getModel("CrossModel"):getOpenState()
            local sTime = self._modelMgr:getModel("CrossModel"):getOpenTime()
            dump(sTime)
            local state = self._modelMgr:getModel("CrossModel"):getOpenActionState()
            print("state==============", state)
            if state == 1 then
                self._viewMgr:showTip(lang("cp_tips_openday"))
            elseif state == 2 then
                self._viewMgr:showTip(lang("cp_tips_openlv"))
            elseif state == 3 then
                self._viewMgr:showTip(lang("cp_tips_openlv"))
            elseif state == 4 then
                UIUtils:reloadLuaFile("cross.CrossMainView")
                self._viewMgr:showView("cross.CrossMainView", {})
            elseif state == 5 then
                self._viewMgr:showTip(lang("cp_tips_maintain"))
            elseif state == 0 then
                self._viewMgr:showTip(lang("cp_tips_maintain"))
            end

        end},
        {"", 
        function () 
            
        end},
        {"", 
        function () 
            
        end},
        {"线上信息", 
        function () 
            package.loaded["game.view.dev.TestOnlineInfo"] = nil
            self._viewMgr:showView("dev.TestOnlineInfo")   
        end},
        {"战斗场景", 
        function () 
            package.loaded["game.view.dev.TestBattleScene"] = nil
            self._viewMgr:showView("dev.TestBattleScene")     
        end},
        {"photoshop", 
        function () 
            package.loaded["game.view.dev.TestSpriteEffectView"] = nil
            self._viewMgr:showView("dev.TestSpriteEffectView")
        end},
        {"movieClip", 
        function () 
            package.loaded["game.view.dev.TestMovieClip"] = nil
            self._viewMgr:showView("dev.TestMovieClip")
            
        end},
        {"role骨骼动画", 
        function () 
            package.loaded["game.view.dev.TestRoleMovieClip"] = nil
            self._viewMgr:showView("dev.TestRoleMovieClip")
        end},
        {"role序列帧", 
        function () 
            package.loaded["game.view.dev.TestRoleSpriteFrameAnim"] = nil
            self._viewMgr:showView("dev.TestRoleSpriteFrameAnim")
        end},


        -- 一系列战斗
        {"副本战斗检查", 
        function ()
            BattleUtils.DEBUG_FAST_BATTLE = 1
            tab:initTab_Sync()
            local key = {}
            for k, v in pairs(tab.mainStage) do
                BattleUtils.PVE_INTANCE_ID = tonumber(k)
                print("副本ID", BattleUtils.PVE_INTANCE_ID, "==============================")
                BattleUtils.battleDemo_Fuben()
            end
            BattleUtils.DEBUG_FAST_BATTLE = 0
        end},
        {"云中城战斗检查", 
        function () 
            BattleUtils.DEBUG_FAST_BATTLE = 1
            tab:initTab_Sync()
            local key = {}
            for k, v in pairs(tab.towerFight) do
                BattleUtils.PVE_CCT_ID = tonumber(k)
                print("云中城ID", BattleUtils.PVE_CCT_ID, "==============================")
                BattleUtils.battleDemo_CloudCity()
            end
            BattleUtils.DEBUG_FAST_BATTLE = 0
        end},
        {"矮人战斗", 
        function () 
            -- BattleUtils.battleDemo_Arena()
            BattleUtils.battleDemo_ServerArena()
        end},
        {"僵尸战斗", 
        function () 
            BattleUtils.battleDemo_Zombie()
        end},
        {"攻城战&", 
        function () 
            if self._text:getString() == "" then self._viewMgr:showTip("没填参数") return end
            BattleUtils.PVE_INTANCE_SIEGE_ID = tonumber(self._text:getString())
            BattleUtils.battleDemo_Siege()
        end},
        {"毒龙战斗", 
        function () 
            BattleUtils.battleDemo_BOSS_DuLong()
        end},
        {"水晶龙战斗", 
        function () 
            BattleUtils.battleDemo_BOSS_SjLong()
        end},
        {"仙女龙战斗", 
        function () 
            BattleUtils.battleDemo_BOSS_XnLong()
        end},
        {"元素战斗&", 
        function () 
            if self._text:getString() == "" then self._viewMgr:showTip("没填参数") return end
            local str = self._text:getString()
            local list = string.split(str, "_")
            BattleUtils.battleDemo_Elemental(tonumber(list[1]), tonumber(list[2]))
        end},
        {"攻城战（进攻）", 
        function () 
            if self._text:getString() == "" then self._viewMgr:showTip("没填参数") return end
            local str = self._text:getString()
            BattleUtils.battleDemo_Siege_Def_WE(tonumber(str))
        end},
        {"远征战斗", 
        function () 
			package.loaded["game.view.dev.TestBattleCrusade"] = nil
			self._viewMgr:showView("dev.TestBattleCrusade")
        end},
        {"训练所战斗", 
        function () 
            if self._text:getString() == "" then self._viewMgr:showTip("没填参数") return end
            BattleUtils.PVE_TRAINING_ID = tonumber(self._text:getString())
            BattleUtils.battleDemo_Training()
        end},
    }
end

function DevelopDialog:onInit()
    local closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(closeBtn, function ()
        self:close()
        UIUtils:reloadLuaFile("dev.DevelopDialog")
    end)
    self._bg = self:getUI("bg")
    local filename
    local x, y = 115, 400
    for i = 1, #self._devList do
        if math.fmod(i, 2) == 1 then
            filename = "globalButtonUI13_2_1.png"
        else
            filename = "globalButtonUI13_1_1.png" 
        end
        
        local btn = ccui.Button:create(filename, filename, filename, 1)
        self._bg:addChild(btn)
        btn:setScale(0.9)
        btn:setPosition(x, y)
        btn:setTitleFontSize(22)
        btn:setTitleFontName(UIUtils.ttfName)
        btn:enableOutline(cc.c4b(0, 0, 0, 255), 1)  
        x = x + 130
        if x > 780 then
            x = 115
            y = y - 50
        end
        btn:setTitleText(self._devList[i][1])
        self:registerClickEvent(btn, function ()
            self._devList[i][2]()
        end)
    end

    self._labelarea = self:getUI("bg.labelarea")

    self._text = self:getUI("bg.text")
    self._text:setPlaceHolder("请输入参数")
    self._text:setPlaceHolderColor(cc.c4b(180, 180, 180, 255))
    self._text:setString("")
    self._text:setTouchEnabled(false)

    self:registerClickEvent(self._labelarea, function ()  
        self._text:attachWithIME()
    end)   
end

function DevelopDialog:onDestroy()
    package.loaded["game.view.dev.DevelopDialog"] = nil
    DevelopDialog.super.onDestroy(self)
end

return DevelopDialog