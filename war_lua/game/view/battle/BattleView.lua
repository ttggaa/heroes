--[[
    Filename:    BattleView.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2015-04-30 13:31:23
    Description: File description
--]]

local BattleView = class("BattleView", BaseView)
local tc = cc.Director:getInstance():getTextureCache()
local _BattleUtils = BattleUtils
--[[
    zzid1 主线副本
    zzid2 地下城副本
    zzid3 云中城
    zzid4 竞技场
    zzid5 冠军对决
    zzid6 元素位面
    zzid7 攻城战(进攻)
    zzid8 攻城战(防守)
    zzid9 联盟密境
]]--

local settingKey = {"fuben", "arena", "airen", "zombie", "fuben", 
                    "dulong", "xnlong", "sjlong", "crusade", "guildpve", 
                    "guildpvp", "biography", "league", "mf", "cloudcity",
                    "cloudcity", "gvg", "gvg", "training", "adventure",
                    "heroduel", "gboss1", "gboss2", "gboss3", "godwar",
                    "elemental1", "elemental2", "elemental3", "elemental4", "elemental5",
                    "siegeatk", "siegedef", "siegeatk", "siegedef", "serverarena",
                    "serverarenafuben","climbtower","guildfam","crossGodwar","woodpile_1",
                    "woodpile_2", "gloryarena", "", "wordboss", "legin"}

-- 投降没有提示的战斗类型
local BM_SURRENDER_NO_TIP_MAP =
{
    [_BattleUtils.BATTLE_TYPE_BOSS_DuLong] = true,
    [_BattleUtils.BATTLE_TYPE_BOSS_XnLong] = true,
    [_BattleUtils.BATTLE_TYPE_BOSS_SjLong] = true,
    [_BattleUtils.BATTLE_TYPE_Crusade] = true,
    [_BattleUtils.BATTLE_TYPE_AiRenMuWu] = true, 
    [_BattleUtils.BATTLE_TYPE_Zombie] = true, 
    [_BattleUtils.BATTLE_TYPE_CloudCity] = true,
    [_BattleUtils.BATTLE_TYPE_CCSiege] = true,
    [_BattleUtils.BATTLE_TYPE_GuildPVE] = true,
    [_BattleUtils.BATTLE_TYPE_GuildPVP] = true,
    [_BattleUtils.BATTLE_TYPE_Training] = true,
    [_BattleUtils.BATTLE_TYPE_Biography] = true,    
    [_BattleUtils.BATTLE_TYPE_Adventure] = true, 
    [_BattleUtils.BATTLE_TYPE_HeroDuel] = true,
    [_BattleUtils.BATTLE_TYPE_GBOSS_1] = true,
    [_BattleUtils.BATTLE_TYPE_GBOSS_2] = true,
    [_BattleUtils.BATTLE_TYPE_GBOSS_3] = true,
    [_BattleUtils.BATTLE_TYPE_GodWar] = true,
    [_BattleUtils.BATTLE_TYPE_Elemental_1] = true,
    [_BattleUtils.BATTLE_TYPE_Elemental_2] = true,
    [_BattleUtils.BATTLE_TYPE_Elemental_3] = true,
    [_BattleUtils.BATTLE_TYPE_Elemental_4] = true,
    [_BattleUtils.BATTLE_TYPE_Elemental_5] = true,
    [_BattleUtils.BATTLE_TYPE_Siege_Atk] = true,
    [_BattleUtils.BATTLE_TYPE_Siege_Def] = true,
    [_BattleUtils.BATTLE_TYPE_Siege_Atk_WE] = true,
    [_BattleUtils.BATTLE_TYPE_Siege_Def_WE] = true,
    [_BattleUtils.BATTLE_TYPE_GuildFAM] = true,
    [_BattleUtils.BATTLE_TYPE_CrossGodWar] = true,
    [_BattleUtils.BATTLE_TYPE_WoodPile_1] = true,
    [_BattleUtils.BATTLE_TYPE_WoodPile_2] = true,
    [_BattleUtils.BATTLE_TYPE_Legion] = true,


}
-- 有战报的战斗类型
local BM_SURRENDER_HAS_REPORT_MAP =
{
    [_BattleUtils.BATTLE_TYPE_Fuben] = true,
    [_BattleUtils.BATTLE_TYPE_ServerArenaFuben] = true,
    [_BattleUtils.BATTLE_TYPE_Siege] = true,
    [_BattleUtils.BATTLE_TYPE_Arena] = true,
    [_BattleUtils.BATTLE_TYPE_ServerArena] = true,
    [_BattleUtils.BATTLE_TYPE_League] = true,
    [_BattleUtils.BATTLE_TYPE_CloudCity] = true,
    [_BattleUtils.BATTLE_TYPE_CCSiege] = true,
    [_BattleUtils.BATTLE_TYPE_HeroDuel] = true,
    [_BattleUtils.BATTLE_TYPE_GodWar] = true,
    [_BattleUtils.BATTLE_TYPE_ClimbTower] = true,
    [_BattleUtils.BATTLE_TYPE_CrossGodWar] = true,
    [_BattleUtils.BATTLE_TYPE_GloryArena] = true,
}
-- 没有输的战斗类型
local BM_SURRENDER_NO_LOSE_MAP =
{
    [_BattleUtils.BATTLE_TYPE_AiRenMuWu] = true,
    [_BattleUtils.BATTLE_TYPE_Zombie] = true,
    [_BattleUtils.BATTLE_TYPE_BOSS_DuLong] = true,
    [_BattleUtils.BATTLE_TYPE_BOSS_XnLong] = true,
    [_BattleUtils.BATTLE_TYPE_BOSS_SjLong] = true,
    [_BattleUtils.BATTLE_TYPE_Siege_Atk] = true,
    [_BattleUtils.BATTLE_TYPE_Siege_Def] = true,
    [_BattleUtils.BATTLE_TYPE_Siege_Atk_WE] = true,
    [_BattleUtils.BATTLE_TYPE_Siege_Def_WE] = true,
    [_BattleUtils.BATTLE_TYPE_Siege_Def_WE] = true,
    [_BattleUtils.BATTLE_TYPE_WoodPile_1] = true,
    [_BattleUtils.BATTLE_TYPE_WoodPile_2] = true,
    [_BattleUtils.BATTLE_TYPE_WORDBOSS] = true,
}
local BM_viewTabs = 
{
    [_BattleUtils.BATTLE_TYPE_Fuben] = "battle.BattleResultCommon",
    [_BattleUtils.BATTLE_TYPE_Arena] = "battle.BattleResultArena",
    [_BattleUtils.BATTLE_TYPE_AiRenMuWu] = "battle.BattleResultAiren",
    [_BattleUtils.BATTLE_TYPE_Zombie] = "battle.BattleResultAiren",
    [_BattleUtils.BATTLE_TYPE_Siege] = "battle.BattleResultCommon",
    [_BattleUtils.BATTLE_TYPE_BOSS_DuLong] = "battle.BattleResultBossDuLong",
    [_BattleUtils.BATTLE_TYPE_BOSS_XnLong] = "battle.BattleResultBossDuLong",
    [_BattleUtils.BATTLE_TYPE_BOSS_SjLong] = "battle.BattleResultBossDuLong",
    [_BattleUtils.BATTLE_TYPE_Crusade] = "battle.BattleResultCrusade",
    [_BattleUtils.BATTLE_TYPE_Guide] = "",
    [_BattleUtils.BATTLE_TYPE_GuildPVE] = "battle.BattleResultGuildMap",
    [_BattleUtils.BATTLE_TYPE_GuildPVP] = "battle.BattleResultGuildMap",
    [_BattleUtils.BATTLE_TYPE_Biography] = "battle.BattleResultBiography",
    [_BattleUtils.BATTLE_TYPE_League] = "battle.BattleResultLeague",
    [_BattleUtils.BATTLE_TYPE_CloudCity] = "battle.BattleResultCloudCity",
    [_BattleUtils.BATTLE_TYPE_CCSiege] = "battle.BattleResultCloudCity",
    [_BattleUtils.BATTLE_TYPE_GVG] = "battle.BattleResultCommon",
    [_BattleUtils.BATTLE_TYPE_GVGSiege] = "battle.BattleResultCommon",
    [_BattleUtils.BATTLE_TYPE_Training] = "battle.BattleResultTraining",
    [_BattleUtils.BATTLE_TYPE_Adventure] = "battle.BattleResultCommon",
    [_BattleUtils.BATTLE_TYPE_HeroDuel] = "battle.BattleResultHeroDuel",
    [_BattleUtils.BATTLE_TYPE_GBOSS_1] = "battle.BattleResultGuildMap",
    [_BattleUtils.BATTLE_TYPE_GBOSS_2] = "battle.BattleResultGuildMap",
    [_BattleUtils.BATTLE_TYPE_GBOSS_3] = "battle.BattleResultGuildMap",
    [_BattleUtils.BATTLE_TYPE_GodWar] = "battle.BattleResultGodWar",
    [_BattleUtils.BATTLE_TYPE_Elemental_1] = "battle.BattleResultElement",
    [_BattleUtils.BATTLE_TYPE_Elemental_2] = "battle.BattleResultElement",
    [_BattleUtils.BATTLE_TYPE_Elemental_3] = "battle.BattleResultElement",
    [_BattleUtils.BATTLE_TYPE_Elemental_4] = "battle.BattleResultElement",
    [_BattleUtils.BATTLE_TYPE_Elemental_5] = "battle.BattleResultElement",
    [_BattleUtils.BATTLE_TYPE_Siege_Atk] = "battle.BattleResultSiegeDailyAtk",
    [_BattleUtils.BATTLE_TYPE_Siege_Def] = "battle.BattleResultSiegeDailyDfc",
    [_BattleUtils.BATTLE_TYPE_Siege_Atk_WE] = "battle.BattleResultSiegeAtk",
    [_BattleUtils.BATTLE_TYPE_Siege_Def_WE] = "battle.BattleResultSiegeDef",
    [_BattleUtils.BATTLE_TYPE_ServerArena] = "battle.BattleResultCrossPK",
    [_BattleUtils.BATTLE_TYPE_ServerArenaFuben] = "battle.BattleResultCommon",
    [_BattleUtils.BATTLE_TYPE_ClimbTower] = "battle.BattleResultCommon",
    [_BattleUtils.BATTLE_TYPE_GuildFAM] = "battle.BattleResultCrusade",--BattleResultGuildMap",
    [_BattleUtils.BATTLE_TYPE_CrossGodWar] = "battle.BattleResultCrossGodWar",
    [_BattleUtils.BATTLE_TYPE_WoodPile_1] = "battle.BattleResultStake",
    [_BattleUtils.BATTLE_TYPE_WoodPile_2] = "battle.BattleResultStake",
    [_BattleUtils.BATTLE_TYPE_GloryArena] = "battle.BattleResultGloryArena",
    [_BattleUtils.BATTLE_TYPE_WORDBOSS] = "battle.BattleResultWorldBoss",
    [_BattleUtils.BATTLE_TYPE_Legion] = "battle.BattleResultLegions"
}

function AppExit()
    APP_EXIT = true
    local scene = cc.Director:getInstance():getRunningScene()
    if scene then scene:setPosition(-10000, -10000) end
    if OS_IS_IOS then
        cc.Director:getInstance():endToLua()
        os.exit()
    else
        cc.Director:getInstance():endToLua()
    end
end

for i = 1, 10 do
    _G["AppExit"..i] = function ()
        APP_EXIT = true
        local scene = cc.Director:getInstance():getRunningScene()
        if scene then scene:setPosition(-10000, -10000) end
        if OS_IS_IOS then
            cc.Director:getInstance():endToLua()
            os.exit()
        else
            cc.Director:getInstance():endToLua()
        end
    end
end

function BattleView:ctor(data)
    BattleView.super.ctor(self)
    if APP_EXIT then
        return
    end
    self.noSound = true
    local hudType = SystemUtils.loadAccountLocalData("HUD_TYPE")
    if hudType == nil then hudType = 1 end
    BattleUtils.HUD_TYPE = hudType

    -- self._mirrorTable = {}
    -- for k, v in pairs(_G) do
    --     self._mirrorTable[k] = v
    -- end
    self._battleInfo = data.battleInfo

    -- 当前配置和代码的战斗版本号
    -- self._battleVer = tab:BattleVer(1)["ver"]
    -- self._reportVer = self._battleInfo.playerInfo.ver

    -- if self._battleInfo.isReport or self._battleInfo.isShare then
    --     -- 提示战报过期
    --     if self._battleVer ~= self._reportVer then
    --         self._viewMgr:showTip(lang("REPLAY_COMPARE"))
    --     end
    -- end

    -- 计算战斗中需要的资源
    local ret, p1, p2, p3, p4 = trycall("BattleUtils.getBattleRes", BattleUtils.getBattleRes, self._battleInfo)
    if not ret then
        self._getBattleResFailed = true
        return
    end

    self._loadingList, self._teamId, self._race, self._checkValue = p1, p2, p3, p4
    self._noLoading = data.noLoading
    self._nounloadRes = data.nounloadRes
    self._dontCheck = data.dontCheck
    if self._dontCheck then
        self._checkValue = nil
    end
    if self._battleInfo.battleId == nil then 
        self._battleInfo.battleId = ""
    end

    self._dontInit = BattleUtils.dontInitTab
    BattleUtils.dontInitTab = nil
    self.noSound = true
    require "game.view.battle.logic.BattleConst"
    BC.fastBattle = self._battleInfo.fastBattle
    if BattleUtils.onceFastBattle then
        BattleUtils.onceFastBattle = nil
        BC.fastBattle = true
    end
    -- self._battleInfo.reverse         战斗是否颠倒方向，逻辑不变，显示和操作左右反转
    -- self._battleInfo.siegeReverse    攻城战是否颠倒方向，细分为逻辑颠倒和显示颠倒，显示颠倒受reverse影响
    BC.reset(self._battleInfo.playerInfo.lv, self._battleInfo.enemyInfo.lv, self._battleInfo.reverse, self._battleInfo.siegeReverse)

    -- 设备引导前两关，强制显示英雄头像
    if type(self._battleInfo.battleId) == "number" and (self._battleInfo.battleId == 7100101 or self._battleInfo.battleId == 7100102) then
        BC.forceHeroSkillAnimId = 514
    end

    if BattleUtils.unLockSkillIndex == 0 then
        self._autoSpeed2 = true
    end

    self._popViewCount = 0
    self._playerTodayModel = self._modelMgr:getModel("PlayerTodayModel")
    self._globalModel = self._modelMgr:getModel("GlobalModel")

    -- 如果小惊喜资格还在, 就设置小惊喜
    if not (self._battleInfo.isReport or self._battleInfo.isShare) then
        local data = self._playerTodayModel:getData()
        if data.day24 == nil or data.day24 == 0 then
            BattleUtils.surpriseList = self._globalModel:getSurpriseList()
            if BattleUtils.surpriseList then
                BattleUtils.surpriseOpen = true
            else
                BattleUtils.surpriseOpen = false
            end
        else
            BattleUtils.surpriseOpen = false
        end
    else
        BattleUtils.surpriseOpen = false
    end
    self._viewMgr:pauseGlobalDialog()
    self._viewMgr:disableIndulge()
end

function BattleView:getAsyncRes()
    if APP_EXIT then
        return {}
    end
    if self._battleInfo.isShare then
        return 
        {   
            {"asset/ui/battle.plist", "asset/ui/battle.png"},
            {"asset/ui/battle-HD.plist", "asset/ui/battle-HD.png"},
            {"asset/ui/battle2.plist", "asset/ui/battle2.png"},
            {"asset/ui/battle3.plist", "asset/ui/battle3.png"},
            {"asset/ui/battle4.plist", "asset/ui/battle4.png"},
        }
    else
        return 
        {   
            {"asset/ui/battle.plist", "asset/ui/battle.png"},
            {"asset/ui/battle-HD.plist", "asset/ui/battle-HD.png"},
            {"asset/ui/battle2.plist", "asset/ui/battle2.png"},
            {"asset/ui/battle4.plist", "asset/ui/battle4.png"},
        }
    end
end

function BattleView:destroy()
    if self._screenToUpdateId then
        ScheduleMgr:unregSchedule(self._screenToUpdateId)
    end
    BattleUtils.inBattle = false
    setMultipleTouchDisabled()
    ViewManager:getInstance()._rootLayer:stopAllActions()
    ViewManager:getInstance()._rootLayer:setScale(1.0)
    cc.Director:getInstance():setAnimationInterval(GameStatic.normalAnimInterval)
    self._skills = {}
    if self._battleScene then
        self._battleScene:clear()
        delete(self._battleScene)
    end
    self._battleScene = nil
    if _G.BC then
        delete(_G.BC.DelayCall)
        _G.BC.DelayCall = nil
        delete(_G.BC.Ran)
        _G.BC.Ran = nil
        delete(_G.BC.Ran2)
        _G.BC.Ran2 = nil
        _G.BC = nil
    end

    BattleUtils.surpriseOpen = false

    BattleUtils.clearBattleRequire()

    BattleUtils.playExitBattleMusic(self._battleInfo.mode, self._battleInfo.subType, self._battleInfo.isElite)
    cc.Director:getInstance():setProjection(cc.DIRECTOR_PROJECTION2_D)
    self._viewMgr:resumeGlobalDialog()
    BattleView.super.destroy(self, true)
end

function BattleView:onInit()
    BattleUtils.inBattle = true
    self._widget:setVisible(false)
end

-- 战斗出错的强制退出
function BattleView:errorClose()
    local t = {
        [BattleUtils.BATTLE_TYPE_Fuben]             = 1,
        [BattleUtils.BATTLE_TYPE_ServerArenaFuben]  = 1,
        [BattleUtils.BATTLE_TYPE_ClimbTower]        = 1,
    }
    if self._battleInfo then
        pcall(function ()
            if (self._battleInfo.mode and t[self._battleInfo.mode])
              or (self._battleInfo.subType and t[self._battleInfo.subType]) 
              and not self._battleInfo.isElite then
                self._battleInfo.resultcallback(nil, nil, true) 
            end 
        end)
    end
    BattleView.super.close(self, true)
end

function BattleView:onAdd()
    if APP_EXIT then
        return
    end
    if self._getBattleResFailed then
        local dialog = self._viewMgr:showDialog("global.GlobalOkDialog", {desc = "战场遭到墓园势力入侵，暂时不能进入", button = "确定", 
        callback = function ()
            self:errorClose()
        end}, true)
        showGlobalErrorCode(dialog:getUI("bg"), 6665001)
        return
    end
    if not self._noLoading then
        if BattleUtils.loadingTeamId then
            self._teamId = BattleUtils.loadingTeamId
            BattleUtils.loadingTeamId = nil
        end
        self._loadingView = self:createLayer("global.LoadingView", {
            type = self._battleInfo.mode, 
            subtype = self._battleInfo.subType, 
            teamId = self._teamId,
            race = self._race,
            dontInit = self._dontInit,
            checkValue = self._checkValue,
            battleId = self._battleInfo.battleId,
            isPass = self._battleInfo.isPass,
        })
        self:getLayerNode():addChild(self._loadingView)
    end
    ScheduleMgr:delayCall(200, self, function()
        if self.init then
            self:init()
        end
    end)
end

function BattleView:onTop()
    if self._battleScene then
        self._battleScene:onTop()
    end
end

function BattleView:onHide()
    if self._battleScene then
        self._battleScene:onHide()
    end
end

function BattleView:init()
    local timeBg1 = self:getUI("uiLayer.topLayer.timeBg1")
    timeBg1:getVirtualRenderer():getSprite():getTexture():setAliasTexParameters()

    self._speedBtn = self:getUI("uiLayer.bottomLayer2.speedBtn")
    self._speedBtn.speed = self:getUI("uiLayer.bottomLayer2.speedBtn.speed")
    self:initTextForm(self:getUI("uiLayer.bottomLayer2.speedBtn.label"))
    self._speedBtn.lock = self:getUI("uiLayer.bottomLayer2.speedBtn.lock")
    self._pauseBtn = self:getUI("uiLayer.bottomLayer2.pauseBtn")
    self._pauseBtn.lock = self:getUI("uiLayer.bottomLayer2.pauseBtn.lock")
    self._pauseBtn.label = self:getUI("uiLayer.bottomLayer2.pauseBtn.label")
    self:initTextForm(self._pauseBtn.label)
    self._autoBtn = self:getUI("uiLayer.bottomLayer2.autoBtn")
    self._autoBtn.lock = self:getUI("uiLayer.bottomLayer2.autoBtn.lock")
    self._autoBtn.label = self:getUI("uiLayer.bottomLayer2.autoBtn.label")
    self:initTextForm(self._autoBtn.label)

    self._surrenderBtn = self:getUI("uiLayer.bottomLayer2.surrenderBtn")
    self:initTextForm(self:getUI("uiLayer.bottomLayer2.surrenderBtn.label"))

    self._surrenderBtn:setVisible(false)

    self._chatBtn = self:getUI("uiLayer.bottomLayer2.chatBtn")
    self._chatBtn.circle = self:getUI("uiLayer.bottomLayer2.chatCircle")
    self._chatBtn.btn1 = self:getUI("uiLayer.bottomLayer2.chatCircle.btn1")
    self._chatBtn.btn2 = self:getUI("uiLayer.bottomLayer2.chatCircle.btn2")
    self._chatBtn.btn3 = self:getUI("uiLayer.bottomLayer2.chatCircle.btn3")
    self._chatBtn.btn4 = self:getUI("uiLayer.bottomLayer2.chatCircle.btn4")
    self._chatBtn.circle:setScale(0)
    for i = 1, 4 do
        self._chatBtn["btn"..i].idx = i
    end
    self._chatBtn:setVisible(false)

    if SystemUtils["enableBattleAuto"] then
        local enable = SystemUtils["enableBattleAuto"]()
        self._autoBtn:setVisible(enable)
    end
    self._speedBtn.lock:setVisible(false)
    self._pauseBtn.lock:setVisible(false)
    self._autoBtn.lock:setVisible(false)
    self._autoFight = self:getUI("uiLayer.topLayer.autoFight")
    self._autoFight:setVisible(false)

    self._skipBtn = self:getUI("uiLayer.bottomLayer2.skipBtn")
    self._skipBtn:setVisible(USESRDATA)
    self:initTextForm(self:getUI("uiLayer.bottomLayer2.skipBtn.label"))

    self._autoTip = self:getUI("uiLayer.bottomLayer2.tip")
    local tip = cc.Label:createWithTTF("点击开启自动战斗", UIUtils.ttfName, 20)
    tip:setPosition(93, 31)
    tip:setColor(UIUtils.colorTable.ccUIBasePromptColor)
    self._autoTip:addChild(tip)
    self._autoTip:setVisible(false)

    self._hudTip = self:getUI("uiLayer.bottomLayer2.tip2")
    local tip = cc.Label:createWithTTF("切换血条显示模式", UIUtils.ttfName, 20)
    tip:setPosition(93, 31)
    tip:setColor(UIUtils.colorTable.ccUIBasePromptColor)
    self._hudTip:addChild(tip)
    self._hudTip:setVisible(false)

    self:getUI("uiLayer.bottomLayer2.autoBtn.label"):enableOutline(cc.c4b(59, 31, 9, 255), 2)
    self:getUI("uiLayer.bottomLayer2.skipBtn.label"):enableOutline(cc.c4b(59, 31, 9, 255), 2)

    self._allMana = self:getUI("uiLayer.bottomLayer.allMpBg.allMp")
    self._allMana:setString("0")
    self._allMana.tip = self:getUI("uiLayer.bottomLayer.allMpBg.tip")

    local timeLabel = self:getUI("uiLayer.topLayer.timeLabel")
    timeLabel:setColor(cc.c3b(255, 255, 255))
    timeLabel:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    local countLabel = self:getUI("uiLayer.topLayer.countLabel")
    countLabel:setFontSize(22)
    countLabel:enableOutline(cc.c4b(0, 0, 0, 255), 1)

    self:registerClickEvent(self._speedBtn, specialize(self.onSpeedBtnClicked, self))
    self:registerClickEvent(self._pauseBtn, specialize(self.onPauseBtnClicked, self))
    self:registerClickEvent(self._autoBtn, specialize(self.onAutoBtnClicked, self))
    self:registerClickEvent(self._skipBtn, specialize(self.onSkipBtnClicked, self))
    self:registerClickEvent(self._surrenderBtn, specialize(self.onSurrenderBtnClicked, self))
    self:registerClickEvent(self._chatBtn, specialize(self.onChatBtnClicked, self))

    self:registerClickEvent(self._chatBtn.btn1, specialize(self.onChatBtnClicked, self))
    self:registerClickEvent(self._chatBtn.btn2, specialize(self.onChatBtnClicked, self))
    self:registerClickEvent(self._chatBtn.btn3, specialize(self.onChatBtnClicked, self))
    self:registerClickEvent(self._chatBtn.btn4, specialize(self.onChatBtnClicked, self))

    self._scene = self:getUI("scene")

    local BattleScene = require("game.view.battle.display.BattleScene")
    self._battleScene = BattleScene.new(self._battleInfo)
    
    self:addChild(self._battleScene:getView(), -1)

    -- 把View中的一些显示控件传给战斗场景
    self._battleScene:setControlUI(
    {
        self._speedBtn, self._pauseBtn, self._autoBtn, self._skipBtn, self._surrenderBtn, self._chatBtn, 
    })
    self._battleScene:setView(self)

    self._isPause = false
    self._battleSpeed = 1
    self._battleScene:setBattleSpeed(self._battleSpeed)

    self._battleScene:setManaLabel(self._allMana)

    -- 玩家技能伤害显示
    self._playerCountBg1 = self:getUI("uiLayer.playerCountBg1")
    self._playerCountBg1:setCascadeOpacityEnabled(true)
    self._playerCountBg1:setOpacity(0)
    self._playerCountBg1:setTouchEnabled(false)
    local node = cc.Node:create()
    node:setCascadeOpacityEnabled(true)
    node:setPosition(235, 32)
    self._playerCountBg1.node = node
    self._playerCountBg1:addChild(node)
    local label = cc.Label:createWithBMFont(UIUtils.bmfName_red, "")
    -- label:setAnchorPoint(0.5, 0.5)
    label:setAdditionalKerning(-5)
    label:setString("")
    self._playerCountBg1.label = label
    node:addChild(label)
    local bright = cc.Label:createWithBMFont(UIUtils.bmfName_red, "")
    bright:setBrightness(255)
    bright:setAdditionalKerning(-5)
    -- bright:setAnchorPoint(0.5, 0.5)
    bright:setString("")
    self._playerCountBg1.bright = bright
    node:addChild(bright)
    self._playerCountBg1.pic = self:getUI("uiLayer.playerCountBg1.pic")
    self._playerCountBg1.kuang = self:getUI("uiLayer.playerCountBg1.kuang")
    self._playerCountBg1.icon = self:getUI("uiLayer.playerCountBg1.icon")
    self._playerCountBg1.icon:setScale(0.9)

    -- 怪兽技能提示
    local tempSoldierBg = self:getUI("uiLayer.soldierSkillBg")
    self._soldierBgs = {}
    local soldierBg
    for i = 1, 4 do
        soldierBg = tempSoldierBg:clone()
        soldierBg:setScale(0.66)
        soldierBg:setTouchEnabled(false)
        soldierBg:setVisible(false)
        soldierBg:setCascadeOpacityEnabled(true)
        tempSoldierBg:getParent():addChild(soldierBg)
        self._soldierBgs[i] = soldierBg
        local icon1, icon2
        for k = 1, 2 do
            soldierBg["bg"..k] = soldierBg:getChildByFullName("bg"..k)
            soldierBg["bg"..k]:setCascadeOpacityEnabled(true)
            icon1 = soldierBg["bg"..k]:getChildByFullName("icon1")
            icon2 = soldierBg["bg"..k]:getChildByFullName("icon2")
            icon1:setScale(0.8)
            icon2:setScale(0.8)
            icon1:setLocalZOrder(-1)
            icon2:setLocalZOrder(-1)
            soldierBg["bg"..k].icon1 = icon1
            soldierBg["bg"..k].icon2 = icon2
        end

        soldierBg.index = 0
    end
    for i = 1, 4 do
        if i == 4 then
            self._soldierBgs[i].next = self._soldierBgs[1]
        else
            self._soldierBgs[i].next = self._soldierBgs[i + 1]
        end
    end
    self._curSoldierSkillBg = self._soldierBgs[1]
    tempSoldierBg:removeFromParent()
    self._battleScene:setSoldierSkillBg(self._curSoldierSkillBg, self._soldierBgs)


    self._battleScene:setCallBack(function (event, data)
        if event == "onBattleBegin" then
            self:onBattleBegin(data)
        elseif event == "onBattleEnd" then
            self:onBattleEnd(data)
        end
    end)
    ScheduleMgr:delayCall(1, self, function()
        self._battleScene:setPlayerCount(self._playerCountBg1)
        if not self._noLoading then
            if BC.fastBattle then
                BATTLE_PROC = true
                self._loadingList = {}
            end
            local res = self._loadingView:loadStart(self._loadingList, function () 
                self:loadingDone()
            end)
            -- 战前检查
            if not res and GameStatic.checkZuoBi_battleBegin then
                local dialog = self._viewMgr:showDialog("global.GlobalOkDialog", {desc = "数据异常", button = "确定", 
                callback = function ()
                    self:errorClose()
                end}, true)
                showGlobalErrorCode(dialog:getUI("bg"), 6665010)
            end
        else
            self:loadingDone()
        end
    end)
end

function BattleView:initTextForm(titleTxt)
    if not titleTxt then return end 
    -- titleTxt:setColor(cc.c3b(250,242,192))
    -- titleTxt:enable2Color(1, cc.c3b(255, 195, 17))
    titleTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
end

function BattleView:onBattleBegin(data)
    local mode = self._battleInfo.mode
    local maxSpeed = BC.BATTLE_MAX_SPEED
    if maxSpeed > 2 then
        maxSpeed = 2
    end
    local modeT = {
        [BattleUtils.BATTLE_TYPE_Arena]         = 1,
        [BattleUtils.BATTLE_TYPE_ServerArena]   = 1,
        [BattleUtils.BATTLE_TYPE_GuildPVP]      = 1,
        [BattleUtils.BATTLE_TYPE_GVG]           = 1,
        [BattleUtils.BATTLE_TYPE_GVGSiege]      = 1,
        [BattleUtils.BATTLE_TYPE_HeroDuel]      = 1,
        [BattleUtils.BATTLE_TYPE_GodWar]        = 1,
        [BattleUtils.BATTLE_TYPE_CrossGodWar]   = 1,
        [BattleUtils.BATTLE_TYPE_GloryArena]   = 1,
    }
    if mode and modeT[mode] then
        -- 竞技场和联盟探索PVP和GVG 强制自动战斗
        local speed = SystemUtils.loadAccountLocalData(settingKey[mode] .. "Speed")
        if speed == nil then speed = maxSpeed end
        if speed > maxSpeed then speed = maxSpeed end
        if speed then
            self._battleSpeed = speed
            if not self._forcePause then
                self._battleScene:setBattleSpeed(self._battleSpeed)
            end
            if speed > 1 then
                self._speedBtn:loadTextureNormal("speedBtn_battleSelected.png", 1)
                self._speedBtn:loadTexturePressed("speedBtn_battleSelected.png", 1)
            end
            self._speedBtn.speed:loadTexture("speed"..self._battleSpeed.."_battle.png", 1)
        end     
        self._battleScene:setSkillAuto(true)
        self._autoFight:setVisible(true)

        -- windows 好友切磋，手动战斗
        if OS_IS_WINDOWS then
            if (mode == BattleUtils.BATTLE_TYPE_Arena or mode == BattleUtils.BATTLE_TYPE_ServerArena) 
                and self._battleInfo.isFriend then
                    self._battleScene:setSkillAuto(false)
                    self._autoFight:setVisible(false)
            end
        end

    elseif self._battleInfo.isReport then
        -- 禁止点自动战斗, 通过技能序列参数来复盘
        self._battleScene:setSkillAuto(false)
        self._battleScene:lockSkill()
        self._battleSpeed = 2
        if not self._forcePause then
            self._battleScene:setBattleSpeed(self._battleSpeed)
        end
        self._speedBtn:loadTextureNormal("speedBtn_battleSelected.png", 1)
        self._speedBtn:loadTexturePressed("speedBtn_battleSelected.png", 1)
        self._speedBtn.speed:loadTexture("speed"..self._battleSpeed.."_battle.png", 1)
    elseif BattleUtils.unLockSkillIndex == nil and mode ~= BattleUtils.BATTLE_TYPE_Guide then
        if mode == BattleUtils.BATTLE_TYPE_Siege then
            local t = {[BattleUtils.BATTLE_TYPE_Fuben] = 1, [BattleUtils.BATTLE_TYPE_Crusade] = 1, [BattleUtils.BATTLE_TYPE_Biography] = 1}
            if self._battleInfo.subType and t[self._battleInfo.subType] then
                mode = self._battleInfo.subType
            end 
        end
        -- 保存上一次的设置
        local speed = SystemUtils.loadAccountLocalData(settingKey[mode] .. "Speed")
        if self._autoSpeed2 then speed = 2 end
        if speed == nil then speed = maxSpeed end
        if speed > maxSpeed then speed = maxSpeed end
        if speed then
            self._battleSpeed = speed
            if not self._forcePause then
                self._battleScene:setBattleSpeed(self._battleSpeed)
            end
            if speed > 1 then
                self._speedBtn:loadTextureNormal("speedBtn_battleSelected.png", 1)
                self._speedBtn:loadTexturePressed("speedBtn_battleSelected.png", 1)
            end
            self._speedBtn.speed:loadTexture("speed"..self._battleSpeed.."_battle.png", 1)
        end
        if mode == BattleUtils.BATTLE_TYPE_League then
            self._speedBtn:setTouchEnabled(false)
        end
        local auto = SystemUtils.loadAccountLocalData(settingKey[mode] .. "Auto")
        if mode == BattleUtils.BATTLE_TYPE_WoodPile_1 or mode == BattleUtils.BATTLE_TYPE_WoodPile_2 then
            -- 木桩默认自动战斗不强制
            auto = true
        end
        if auto then
            self._autoBtn:loadTextureNormal("autoBtn_battleSelected.png", 1)
            self._battleScene:setSkillAuto(true)
            self._autoFight:setVisible(true)
        end 
    elseif mode == BattleUtils.BATTLE_TYPE_Guide then
        self._battleSpeed = 2
        self._battleScene:setBattleSpeed(self._battleSpeed)
    end

    local t = {
        [BattleUtils.BATTLE_TYPE_Fuben]             = 1,
        [BattleUtils.BATTLE_TYPE_ServerArenaFuben]  = 1,
        [BattleUtils.BATTLE_TYPE_ClimbTower]        = 1,
    }
    if (mode and t[mode]) or (self._battleInfo.subType and t[self._battleInfo.subType]) then
        if not self._battleInfo.isReport then
            local level = BC.PLAYER_LEVEL[1]
            if self._autoFight:isVisible() == false then
                if level == 8 then
                    self._autoTip:setVisible(true)
                end
            end
            if level >= 5 and level <= 6 then
                local hudTip = SystemUtils.loadAccountLocalData("hudTip")
                if hudTip == nil then
                    SystemUtils.saveAccountLocalData("hudTip", 1)
                    self._hudTip:setVisible(true)
                end
            end
        end
    end
    ApiUtils.gsdkStart({zone_id = tostring(GameStatic.sec), tag = tostring(self._battleInfo.mode), room_ip = GameStatic.ipAddress})
end

function BattleView:onBattleEnd(data)
    local BattleUtils = BattleUtils
    -- 记录
    local mode = self._battleInfo.mode
    local modeT = {
        [BattleUtils.BATTLE_TYPE_Arena]         = 1,
        [BattleUtils.BATTLE_TYPE_ServerArena]   = 1,
        [BattleUtils.BATTLE_TYPE_GuildPVP]      = 1,
        [BattleUtils.BATTLE_TYPE_GVG]           = 1,
        [BattleUtils.BATTLE_TYPE_GVGSiege]      = 1,
        [BattleUtils.BATTLE_TYPE_HeroDuel]      = 1,
        [BattleUtils.BATTLE_TYPE_GodWar]        = 1,
        [BattleUtils.BATTLE_TYPE_CrossGodWar]   = 1,
        [BattleUtils.BATTLE_TYPE_GloryArena]    = 1,
    }
    if mode and modeT[mode] then
        SystemUtils.saveAccountLocalData(settingKey[mode] .. "Speed", self._battleSpeed)
    elseif self._battleInfo.isReport then
        -- do nothing
    elseif mode ~= BattleUtils.BATTLE_TYPE_Guide then
        if mode == BattleUtils.BATTLE_TYPE_Siege then
            local t = {[BattleUtils.BATTLE_TYPE_Fuben] = 1, [BattleUtils.BATTLE_TYPE_Crusade] = 1, [BattleUtils.BATTLE_TYPE_Biography] = 1}
            if self._battleInfo.subType and t[self._battleInfo.subType] then
                mode = self._battleInfo.subType
            end 
        end
        SystemUtils.saveAccountLocalData(settingKey[mode] .. "Speed", self._battleSpeed)
        SystemUtils.saveAccountLocalData(settingKey[mode] .. "Auto", self._autoFight:isVisible())
    end

    self._battleSpeed = 1
    self._battleScene:setBattleSpeed(self._battleSpeed)
    self._speedBtn.speed:loadTexture("speed"..self._battleSpeed.."_battle.png", 1)
    self._speedBtn:loadTextureNormal("speedBtn_battle.png", 1)
    self._speedBtn:loadTexturePressed("speedBtn_battle.png", 1)

    self._pauseBtn:setColor(cc.c3b(255, 255, 255))
    self._autoBtn:setColor(cc.c3b(255, 255, 255))
    if not self._autoBtn.lock:isVisible() then
        self._autoBtn:loadTextureNormal("autoBtn_battle.png",1)
    end
    self._autoFight:setVisible(false)

    self:enableSkillIcon()

    local delayTime = 100
    if self._surrenderView then
        self._surrenderView:close(true)
        self._surrenderView = nil
    end

    self:lock(-1)
    ScheduleMgr:delayCall(delayTime, self, function()
        self:unlock()
        local resultFunc = function ()
            -- 结果回调
            -- dump(data)
            self._battleInfo.resultcallback(data, 
            function (result, rewards)
                -- dump(result)
                -- failed 来自服务器 data.zuobi 来自前端检查
                if result then
                    if result.failed or (data.zuobi and GameStatic.checkZuoBi_battleBegin) then
                        if result.failed then
                            if BattleUtils.BattleString and GameStatic.upload_fupan_failed then
                                pcall(function ()
                                    local res = ""
                                    if result.__code then
                                        res = res .. "::code-" .. tostring(result.__code)
                                    end
                                    if result.__error then
                                        res = res .. "::error-" .. tostring(result.__error)
                                    end
                                    if result.extract then
                                        res = res .. "::extract-" .. cjson.encode(result.extract)
                                    end
                                    local strhp = ""
                                    if data.hp and data.hpex then
                                        strhp = "::"..cjson.encode(data.hp) .. "_" .. cjson.encode(data.hpex)
                                    end
                                    if result.__error or result.extract == nil then
                                        ApiUtils.playcrab_lua_error("fubenshibai", "mode:" .. self._battleInfo.mode .. " r1:" .. self._battleInfo.r1 .. res)
                                    else
                                        ApiUtils.playcrab_lua_error("fupanshibai_1", BattleUtils.BattleString .. "::"..data.skillList .. res .. strhp)
                                    end
                                end)
                            end
                        end
                        print(result.failed, data.zuobi, result.__error, result.__code)
                        if self._viewMgr then
                            local str
                            if data.zuobi then
                                str = "数据异常，相关数据已经上报数据中心，如校验后发现作弊行为，将会导致帐号被封停"
                            else
                                str = "数据异常"
                            end
                            
                            local dialog = self._viewMgr:showDialog("global.GlobalOkDialog", {desc = str, button = "确定", 
                            callback = function ()
                                if self._battleInfo and self._battleInfo.endcallback then
                                    self._battleInfo.endcallback()
                                end
                                self:errorClose()
                            end}, true)
                            showGlobalErrorCode(dialog:getUI("bg"), 6665009, serialize({zuobi = data.zuobi, failed = result.failed, error = result.__error, code = result.__code}))
                        end
                        return
                    end
                end
                BattleUtils.BattleString = nil
                if result and result.win ~= nil then
                    data.win = result.win
                end
                if self._battleScene then
                    self._battleScene:over()
                end
                -- 增加针对不同场景结算界面可定制
                local mode = self._battleInfo.resultMode or self._battleInfo.mode
                local viewName = BM_viewTabs[mode]
                -- 好友切磋使用默认分支
                if (mode == BattleUtils.BATTLE_TYPE_Arena)
                    and self._battleInfo.isFriend then
                        viewName = "battle.BattleResultCommon"
                        rewards = {}
                end
                if viewName == nil then
                    viewName = "battle.BattleResultCommon"
                end
                -- 积分联赛多一个平局
                -- if mode == BattleUtils.BATTLE_TYPE_League and result.isTimeUp then
                --     viewName = "battle.BattleResultLeague2"
                -- end

                local showResultViewFunc = function (viewname)
                    local battleinfo = {data = clone(data), result = result, rewards = rewards, battleType = mode, battleInfo = self._battleInfo, callback = function (_type, _callback)
                        print("battleinfo callback ====")
                        -- 结束回调
                        self:close(true, _type, _callback)
                    end,
                    replayCallback = function ()
                        self:replay()
                    end, isBranch = self._battleInfo.isBranch}
                    battleinfo.data.reverse = BC.reverse
                    battleinfo.result.reverse = BC.reverse
                    if BC.reverse then
                        local left = battleinfo.result.leftData
                        local right = battleinfo.result.rightData
                        battleinfo.result.leftData = right
                        battleinfo.result.rightData = left
                    end
                    if _G._autoBattleSchedule then
                        --这个时候表示自动战斗脚本检测，所以直接使用通用的结算界面，避免出错
                        viewname = "battle.BattleResultStakeWin"
                    end
                    self._resultView = self._viewMgr:showDialog(viewname, battleinfo, true, true, nil, true)
                    self._viewMgr:enableIndulge()
                end

                if mode == BattleUtils.BATTLE_TYPE_Guide then
                    -- 等黑屏
                    self._viewMgr:doGuideBattleOver2()
                elseif ((mode == BattleUtils.BATTLE_TYPE_Fuben and self._battleInfo.isBranch) or
                        BM_SURRENDER_NO_TIP_MAP[mode]) and data.isSurrender then
                    if data.isErrorExit then
                        ViewManager:getInstance():showTip("挑战时间已过期")
                        ScheduleMgr:delayCall(500, self, function()
                            self:close(true)
                        end)
                    else
                        ScheduleMgr:delayCall(100, self, function()
                            self:close(true)
                        end)
                    end
                    
                elseif (BM_SURRENDER_HAS_REPORT_MAP[mode] and self._battleInfo.isReport)
                        or mode == BattleUtils.BATTLE_TYPE_GVG or mode == BattleUtils.BATTLE_TYPE_GVGSiege then
                    if self._battleInfo.isShare then
                        -- 战报分享结算界面
                        local battleinfo = {data = clone(data), result = result, rewards = rewards, 
                            battleType = mode, battleInfo = self._battleInfo, callback = function (_type, _callback)
                            -- 结束回调
                            self:close(true, _type, _callback)
                        end,
                        replayCallback = function ()
                            self:replay()
                        end}
                        self._resultView = self._viewMgr:showDialog("battle.BattleResultShare", battleinfo, true, true, nil, true)
                        self._viewMgr:enableIndulge()
                    else
                        ScheduleMgr:delayCall(500, self, function()
                            self:close(true)
                        end)
                    end
                -- elseif mode == BattleUtils.BATTLE_TYPE_Arena and self._battleInfo.isFriend then
                --     -- 好友切磋 沿用支线
                else
                    local win = data.win
                    if self._battleInfo.reverse or (mode == BattleUtils.BATTLE_TYPE_CrossGodWar and self._battleInfo.enemyInfo.isMySelf) then
                        win = not win
                    end
                    if win then
                        if _BattleUtils.BATTLE_TYPE_GloryArena ~= mode then
                            viewName = viewName .. "Win"
                        end
                        showResultViewFunc(viewName)
                    else
                        local saturation = 0
                        self:lock(-1)
                        self._updateId = ScheduleMgr:regSchedule(1, self, function(self, dt)
                            saturation = saturation - 3
                            self._widget:setSaturation(saturation)
                            if self._battleScene then
                                self._battleScene:getView():setSaturation(saturation)
                            end
                            if saturation <= -100 then
                                self:unlock()
                                ScheduleMgr:unregSchedule(self._updateId)
                                if _BattleUtils.BATTLE_TYPE_GloryArena ~= mode then
                                    if BM_SURRENDER_NO_LOSE_MAP[mode] or (mode == BattleUtils.BATTLE_TYPE_League and result.isTimeUp) then
                                        viewName = viewName .. "Win"
                                    else
                                        viewName = viewName .. "Lose"
                                    end
                                end
                                showResultViewFunc(viewName)
                            end
                        end)
                    end
                end
            end, nil)
        end
        -- 每日小惊喜 发完请求在回调
        local supriseFunction = function ()
            if BattleUtils.surpriseSuccess then
                local surpriseList = BattleUtils.surpriseList
                local value = surpriseList[1] * 1000 + surpriseList[2] * 100  + surpriseList[3] * 10 + surpriseList[4]
                self._serverMgr:sendMsg("BattleServer", "getSurprise", {surpriseList = value}, true, {}, function(result, success)
                    BattleUtils.surpriseSuccess = false
                    BattleUtils.surpriseOpen = false
                    resultFunc()
                end)
            else
                resultFunc()
            end
        end
        -- 结束对话, 赢了才有
        if data.win and self._battleInfo.endTalkId then
            self._viewMgr:enableTalking(self._battleInfo.endTalkId, {}, supriseFunction)
        else
            supriseFunction()
        end
    end)  
    ApiUtils.gsdkEnd({})
end

function BattleView:onShowDialogError()
    ScheduleMgr:nextFrameCall(self, function()
        if self._resultView then
            local mask = ccui.Layout:create()
            mask:setBackGroundColorOpacity(255)
            mask:setBackGroundColorType(1)
            mask:setBackGroundColor(cc.c3b(255,0,0))
            mask:setContentSize(MAX_SCREEN_WIDTH + 200, MAX_SCREEN_HEIGHT)
            mask:setTouchEnabled(true)
            mask:setOpacity(0)
            self._resultView:addChild(mask, 999999)   
            self:registerClickEvent(mask, function ()
                self:close(true)
            end)
        else
            ScheduleMgr:delayCall(500, self, function()
                self:close(true)
            end)
        end
    end)
end

local color_black = cc.c4b(0, 0, 0, 255)
function BattleView:loadingDone()
    if self._restart then return end
    -- 初始化场景

    local ret = trycall("battleScene.initScene", self._battleScene.initScene, self._battleScene)
    if not ret then
        -- 战斗update报错
        local dialog = self._viewMgr:showDialog("global.GlobalOkDialog", {desc = "战场遭到据点势力入侵，指挥官下令撤离", button = "确定", 
        callback = function ()
            self:errorClose()
        end}, true)
        showGlobalErrorCode(dialog:getUI("bg"), 6665002)
        return
    end
    
    local iconlock = (BattleUtils.BATTLE_TYPE_Arena == self._battleInfo.mode 
        or BattleUtils.BATTLE_TYPE_ServerArena == self._battleInfo.mode 
        or BattleUtils.BATTLE_TYPE_GuildPVP == self._battleInfo.mode
        or BattleUtils.BATTLE_TYPE_GodWar == self._battleInfo.mode
        or BattleUtils.BATTLE_TYPE_CrossGodWar == self._battleInfo.mode)
    -- 上面的技能按钮被移至屏幕外,新按钮创建
    local skillIcon = self:getUI("uiLayer.bottomLayer.skill_new")
    local panel = skillIcon:getParent()
    panel:setCascadeOpacityEnabled(true, true)
    local skills = self._battleScene:getSkills()
    
    local count = #skills
    self._skillIcons = {}
    
    local scount = 0
    for i = count, 1, -1 do
        if skills[i][3] then
            scount = scount + 1
        end
    end
    local icon_inv
    local icon_begin
    if scount <= 5 then
        icon_inv = BattleUtils.SKILL_ICON_INV_X_ORI
        icon_begin = BattleUtils.SKILL_ICON_BEGIN_X_ORI
    else
        icon_inv = BattleUtils.SKILL_ICON_INV_X
        icon_begin = BattleUtils.SKILL_ICON_BEGIN_X
    end
    local beginX = icon_begin
    for i = count, 1, -1 do
        if skills[i][3] then
            local sicon = skillIcon:clone()
            sicon:setCascadeOpacityEnabled(true, true)
            self._skillIcons[i] = sicon
            local skill = sicon:getChildByName("skill")
            skill:setPosition(50, 40)
            skill:setAnchorPoint(0.5, 0.5)
            sicon.skill = skill
            sicon.icon = skill:getChildByName("icon")
            sicon:setName("icon_"..i) 
            local cdLabel = cc.Label:createWithTTF("0", UIUtils.ttfName, 34)
            cdLabel:setPosition(49, 47)
            cdLabel:enableOutline(cc.c4b(0, 0, 0, 255), 1)
            skill:addChild(cdLabel, 100)
            sicon.cdLabel = cdLabel

            sicon.light = skill:getChildByName("light") 
            -- sicon.icon:setScale(0.73) 
            sicon.label = sicon:getChildByName("mpLabel")
            sicon.label:enableOutline(cc.c4b(0, 0, 0, 255), 1)
            sicon.mask = skill:getChildByName("mask")
            sicon.count = skill:getChildByName("count")
            if skills[i][4] >= 0 then
                sicon.count:setVisible(true)
            end
            local lock = sicon:getChildByName("lock")
            lock:setBrightness(40)
            lock:setVisible(iconlock) 
            lock:setLocalZOrder(999)
            sicon.lock = lock
            if iconlock then
                sicon:setBrightness(-60)
            end

            local skillcd = skill:getChildByName("skillCD")

            local cdsp = cc.Sprite:createWithSpriteFrameName("skillCdMask_battle.png")
            local cd = cc.ProgressTimer:create(cdsp)
            cd:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
            cd:setReverseProgress(true)
            cd:setPosition(40, 40)
            skillcd:addChild(cd)
            sicon.cd = cd

            sicon:setPosition(beginX, 32)
            sicon.touchEnabled = true

            if i < 5 then
                beginX = beginX - icon_inv
            end
            -- 这边需要支持点击和拖动两种操作方式

            sicon.pressLongTime = 0.2
            self:registerTouchEvent(sicon, 
            function ()
                sicon.__touchDown = true
                if self._guideLockSkill then
                    self._viewMgr:showTip("当前无法释放法术")
                    return
                end
                if sicon.outOfCount then
                    if sicon.maxCount < 5 then
                        self._viewMgr:showTip(lang("SKILLBOOK_TIPS117"))
                    else
                        self._viewMgr:showTip(lang("SKILLBOOK_TIPS118"))
                    end
                    return
                end
                -- down
                if not sicon.touchEnabled then return end
                if GuideUtils.isGuideRunning then return end
                if GuideBattleHelpUtils.LOCK then return end
                if sicon.___lock then return end
                -- down
                sicon.__pressLong = false
                sicon.___lock = true
                sicon.__down = true
                if not sicon.skill.open then
                    sicon.skill:stopAllActions()
                    sicon.skill:runAction(cc.ScaleTo:create(0.15, 0.85))
                end
            end, 
            function (_, x, y)
                -- move
                if self._guideLockSkill then return end
                if not sicon.touchEnabled then return end
                if GuideUtils.isGuideRunning then return end
                -- if GuideBattleHelpUtils.LOCK then return end
                if not sicon.___lock then return end
                -- move
                local pt = sicon:convertToWorldSpace(cc.p(0, 0))
                local w = sicon:getContentSize().width
                local h = sicon:getContentSize().height

                if sicon.__move then
                    if self:isInSkillCancelArea(x, y) then
                        self:setSkillCancelAreaType(2)
                    else
                        self:setSkillCancelAreaType(1)
                    end
                    self._battleScene:onPlayerSkillMove(x, y)
                    return
                end
                if not sicon.__down then return end
                if x < pt.x or y < pt.y or x > pt.x + w or y > pt.y + h then
                    sicon.__down = false
                    sicon.__move = true
                    -- sicon:setBrightness(0)
                    if not self._battleScene:isPlayerSkillSelect(i) then
                        self._battleScene:onPlayerSkill(i)
                    end
                    self:disableSkillIcon(i)
                    self._battleScene:onPlayerSkillMoveBegin(i, x, y)
                end
            end, 
            function (_, x, y)
                -- up 点击按钮弹起，再次点击其他区域释放
                sicon.__touchDown = false
                if sicon.outOfCount and sicon.__pressLong then
                    self:hideSkillIconTip()
                end
                if self._guideLockSkill then return end
                if not sicon.touchEnabled then 
                    if not sicon.__disable then
                        self._viewMgr:showTip("法术自动释放中")
                    end
                    return 
                end
                if GuideUtils.isGuideRunning then
                    self._battleScene:onPlayerSkill(i)
                    sicon.___lock = false
                    return
                end
                if not sicon.___lock then return end
                sicon.___lock = false
                -- if GuideBattleHelpUtils.LOCK then return end
                -- up
                if sicon.__move then
                    sicon.__move = false
                    self._battleScene:onPlayerSkillMoveEnd(i)
                    self._battleScene:playerSkillUp_xy(x, y)

                    return
                end
                if not sicon.__down then return end
                sicon.__down = false
                -- sicon:setBrightness(0)
                if not sicon.__pressLong then
                    self._battleScene:onPlayerSkill(i)
                    self:disableSkillIcon(i)
                else
                    sicon.skill:stopAllActions()
                    sicon.skill:runAction(cc.ScaleTo:create(0.05, 1))
                    -- self._battleScene:onPlayerSkill(i)
                    -- self._battleScene:onPlayerSkill(i)
                    self:hideSkillIconTip()
                end
            end,
            function (_, x, y)
                -- out  拖到外部释放
                sicon.__touchDown = false
                if sicon.outOfCount and sicon.__pressLong then
                    self:hideSkillIconTip()
                end
                if self._guideLockSkill then return end
                if not sicon.touchEnabled then return end
                if not sicon.___lock then return end
                sicon.___lock = false
                if GuideUtils.isGuideRunning then return end
                -- if GuideBattleHelpUtils.LOCK then return end
                -- out
                if sicon.__move then
                    if not self:isInSkillCancelArea(x, y) then
                        self._battleScene:onPlayerSkillMoveEnd(i)
                        self._battleScene:playerSkillUp_xy(x, y)
                    else
                        self._battleScene:onPlayerSkill(i)
                        self._battleScene:onPlayerSkillMoveEnd(i)
                        self:enableSkillIcon()
                    end

                    sicon.__move = false
                    return
                end
                sicon.__down = false
                sicon:setBrightness(0)
            end,
            function ()
                if self._guideLockSkill then return end
                if not sicon.touchEnabled then return end
                if GuideUtils.isGuideRunning then return end
                if GuideBattleHelpUtils.LOCK then return end
                -- 长按
                sicon.__pressLong = true
                self:showSkillIconTip(i)
            end)
            sicon:setVisible(true) 
            panel:addChild(sicon)

            self._battleScene:addSkillIcon(sicon, i)
        end
    end
    self._battleScene:updateSkillLock()
    if count > 4 then
        for i = 5, count do
            if skills[i][3] then
                self._skillIcons[i]:setPositionX(beginX)
                beginX = beginX - icon_inv
            end
        end
    end
    self:getUI("uiLayer.bottomLayer.allMpBg"):setPosition(beginX + 56, 26)
    local skillbg = self:getUI("uiLayer.bottomLayer.skillbg")
    skillbg:setContentSize(960 - beginX + 16 + 60, 59)
    skillbg:setAnchorPoint(1, 0)
    skillbg:setPositionX(960 + 60)

    local skillBg = self:getUI("uiLayer.skillBg")
    skillIcon:setVisible(false)

    self._battleScene:setAllMpBg(self:getUI("uiLayer.bottomLayer.allMpBg"))

    cc.Director:getInstance():setProjection(cc.DIRECTOR_PROJECTION3_D)
    self._widget:setVisible(true)
    self._battleScene:getView():setVisible(true)
    if self._loadingView then
        self._loadingView:removeFromParent()
    end
    self._battleScene:play()
    BattleUtils.playBattleMusic(self._battleInfo.mode, self._battleInfo.isElite)
end

function BattleView:disableSkillIcon(index)
    if self._skillIcons == nil then return end
    self:hideSkillIconTip()
    local skillIcon = self:getUI("uiLayer.bottomLayer.skill_new")
    local panel = skillIcon:getParent()
    panel:setOpacity(120)
    for i = 1, 7 do
        local sicon = self._skillIcons[i]
        if sicon then  
            sicon:setEnabled(false)
            if index == i then
                sicon:setCascadeOpacityEnabled(false, false)     
                -- sicon.bg:setOpacity(50)
            else
                sicon:setCascadeOpacityEnabled(true, true)     
                sicon:setOpacity(100)
                sicon.cd:setOpacity(50)
            end
        end
    end

    if self.cancelAreaBg == nil then
        local bgnode = cc.Node:create()
        self:addChild(bgnode, 9999)

        local bg = cc.Sprite:createWithSpriteFrameName("skill_cancel_bg_battle.png")
        bg:setAnchorPoint(0.5, 1)
        bg:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT)
        bg:setScale(2)
        bgnode:addChild(bg)
        bgnode.bg = bg

        local label = cc.Label:createWithTTF("拖动至区域取消法术选择", UIUtils.ttfName, 20)
        label:enableOutline(cc.c4b(0, 0, 0, 255), 2)
        label:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT - 140)
        bgnode:addChild(label)

        local jiantou1 = cc.Sprite:createWithSpriteFrameName("skill_tip_jiantou_battle.png")
        jiantou1:setPosition(MAX_SCREEN_WIDTH * 0.5 - 135, MAX_SCREEN_HEIGHT - 140)
        bgnode:addChild(jiantou1)

        local jiantou2 = cc.Sprite:createWithSpriteFrameName("skill_tip_jiantou_battle.png")
        jiantou2:setPosition(MAX_SCREEN_WIDTH * 0.5 + 135, MAX_SCREEN_HEIGHT - 140)
        bgnode:addChild(jiantou2)

        bgnode.jiantou1 = jiantou1
        bgnode.jiantou2 = jiantou2
        self.cancelAreaBg = bgnode
    end
    self.cancelAreaBg:stopAllActions()
    self.cancelAreaBg:setPosition(0, 170)
    self.cancelAreaBg.jiantou1:stopAllActions()
    self.cancelAreaBg.jiantou2:stopAllActions()
    self.cancelAreaBg.jiantou1:setPosition(MAX_SCREEN_WIDTH * 0.5 - 135, MAX_SCREEN_HEIGHT - 140)
    self.cancelAreaBg.jiantou2:setPosition(MAX_SCREEN_WIDTH * 0.5 + 135, MAX_SCREEN_HEIGHT - 140)

    self.cancelAreaBg:runAction(cc.EaseOut:create(cc.MoveTo:create(0.1, cc.p(0, 30)), 2))
    self.cancelAreaBg.jiantou1:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(0, 5)), cc.MoveBy:create(0.5, cc.p(0, -5)))))
    self.cancelAreaBg.jiantou2:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(0, 5)), cc.MoveBy:create(0.5, cc.p(0, -5)))))
    self:setSkillCancelAreaType(1)
end

function BattleView:lockSkillIcon()
    if self._skillIcons == nil then return end
    for i = 1, 7 do
        local sicon = self._skillIcons[i]
        if sicon and not sicon.__move and not sicon.__down and not sicon.__touchDown then  
            sicon:setTouchEnabled(false)
        end
    end
end

function BattleView:unlockSkillIcon()
    if self._skillIcons == nil then return end
    for i = 1, 7 do
        local sicon = self._skillIcons[i]
        if sicon then  
            sicon:setTouchEnabled(true)
        end
    end
end

-- 用于技能卡住时候的解锁
function BattleView:resetSkillIcon()
    if self._skillIcons == nil then return end
    for i = 1, 7 do
        local sicon = self._skillIcons[i]
        if sicon then  
            sicon.__move = false
            sicon.__down = false
            sicon.___lock = false
        end
    end
end

function BattleView:enableSkillIcon()
    if self._skillIcons == nil then return end
    local skillIcon = self:getUI("uiLayer.bottomLayer.skill_new")
    local panel = skillIcon:getParent()
    panel:setOpacity(255)
    for i = 1, 7 do
        local sicon = self._skillIcons[i]
        if sicon then  
            sicon:setEnabled(true)
            sicon:setOpacity(255)
            sicon.cd:setOpacity(255)
        end
    end
    if self.cancelAreaBg then
        self.cancelAreaBg:stopAllActions()
        self.cancelAreaBg:runAction(cc.EaseIn:create(cc.MoveTo:create(0.1, cc.p(0, 170)), 2))
        self.cancelAreaBg.jiantou1:stopAllActions()
        self.cancelAreaBg.jiantou2:stopAllActions()
    end
end

function BattleView:showSkillIconTip(index)
    local skillIcon = self:getUI("uiLayer.bottomLayer.skill_new")
    local panel = skillIcon:getParent()
    local sicon = self._skillIcons[index]

    local bgimage = cc.Scale9Sprite:createWithSpriteFrameName("globalPanelUI5_tipBg.png")
    bgimage:setCapInsets(cc.rect(35, 35, 1, 1))
    bgimage:setAnchorPoint(0.5, 0)
    
    local width = panel:getContentSize().width
    local x, y = sicon:getPositionX() + 50, sicon:getPositionY() + 100
    if x + 225 > width - 10 then
        x = width - 225 - 10
    end

    local str, name = BC.logic:getSkillDesc(index)
    local str = "[color=fae6c8, fontsize=20]" .. str .. "[-]"
    local richText = RichTextFactory:create(str, 410, 0)
    richText:formatText()
    richText:setAnchorPoint(cc.p(0.5, 0))
    richText:setPosition(225, 10)
    bgimage:setContentSize(450, richText:getInnerSize().height + 54)
    bgimage:addChild(richText)
    bgimage:setPosition(x, y)

    local nameLabel = cc.Label:createWithTTF(name, UIUtils.ttfName, 24)
    nameLabel:setAnchorPoint(0, 1)
    nameLabel:setPosition(20, bgimage:getContentSize().height - 12)
    nameLabel:setColor(cc.c3b(250, 230, 200))
    bgimage:addChild(nameLabel)

    self._skillTip = bgimage
    panel:addChild(bgimage)
end

function BattleView:hideSkillIconTip()
    if self._skillTip then
        self._skillTip:removeFromParent()
        self._skillTip = nil
    end
end

-- 1是黑色, 2是红色
function BattleView:setSkillCancelAreaType(_type)
    if self.cancelAreaBg == nil then return end
    if self.cancelAreaBg.type == _type then return end
    if _type == 1 then
        self.cancelAreaBg.bg:setCM(1, 1, 1, 1, 0, 0, 0, 0)
    else
        self.cancelAreaBg.bg:setCM(0.5, 0.5, 0.5, 1, 255, 0, 0, 0)
    end
    self.cancelAreaBg.type = _type
end

function BattleView:isInSkillCancelArea(x, y)
    local maxHeight = MAX_SCREEN_HEIGHT - 100
    return y > maxHeight
end

function BattleView:onSpeedBtnClicked()
    if self._battleScene:isSkillAreaShow() then return end
    if not self._battleScene:isEnableSpeed() then 
        self._viewMgr:showTip(lang("XINSHOUZHANDOU_99"))
        return 
    end
    if BC.BATTLE_MAX_SPEED == 1 then
        self._viewMgr:showTip(lang("TIP_BATTLE_ACCELERATE"))
        return   
    end
    local max_speed = BC.BATTLE_MAX_SPEED
    if BATTLE_DEBUG_MAX_SPEED then
        max_speed = 10
    end
    self._battleSpeed = self._battleSpeed + 1
    if self._battleSpeed > max_speed then
        self._battleSpeed = 1
        self._speedBtn:loadTextureNormal("speedBtn_battle.png",1)
        self._speedBtn:loadTexturePressed("speedBtn_battle.png",1)
    else
        self._speedBtn:loadTextureNormal("speedBtn_battleSelected.png",1)
        self._speedBtn:loadTexturePressed("speedBtn_battleSelected.png",1)
    end
    if not self._isPause then
        --[[
             1 改变动画的播放速度
             2 修改速度,从而修改logic.battleTime
        ]]
        self._battleScene:setBattleSpeed(self._battleSpeed)
    end
    self._speedBtn.speed:loadTexture("speed"..self._battleSpeed.."_battle.png", 1)
    if self._battleSpeed > 4 then
        self._speedBtn.speed:setVisible(false)
        if self._speedBtn.node then
            self._speedBtn.node:removeAllChildren()
        else
            self._speedBtn.node = cc.Node:create()
            self._speedBtn.node:setPosition(29, 29)
            self._speedBtn:addChild(self._speedBtn.node)
        end
        local node = self._speedBtn.node
        if self._battleSpeed == 5 then
            local sp1 = cc.Sprite:createWithSpriteFrameName("speed3_battle.png")
            local sp2 = cc.Sprite:createWithSpriteFrameName("speed2_battle.png")
            sp1:setPositionX(-14)
            sp2:setPositionX(14)
            node:addChild(sp1)
            node:addChild(sp2)
            node:setScaleX(0.85)
        elseif self._battleSpeed == 6 then
            local sp1 = cc.Sprite:createWithSpriteFrameName("speed3_battle.png")
            local sp2 = cc.Sprite:createWithSpriteFrameName("speed3_battle.png")
            sp1:setPositionX(-16)
            sp2:setPositionX(17)
            node:addChild(sp1)
            node:addChild(sp2)
            node:setScaleX(0.75)
        elseif self._battleSpeed == 7 then
            local sp1 = cc.Sprite:createWithSpriteFrameName("speed4_battle.png")
            local sp2 = cc.Sprite:createWithSpriteFrameName("speed3_battle.png")
            sp1:setPositionX(-18)
            sp2:setPositionX(18)
            node:addChild(sp1)
            node:addChild(sp2)
            node:setScaleX(0.7)
        elseif self._battleSpeed == 8 then
            local sp1 = cc.Sprite:createWithSpriteFrameName("speed4_battle.png")
            local sp2 = cc.Sprite:createWithSpriteFrameName("speed4_battle.png")
            sp1:setPositionX(-20)
            sp2:setPositionX(20)
            node:addChild(sp1)
            node:addChild(sp2)
            node:setScaleX(0.6)
        elseif self._battleSpeed == 9 then
            local sp1 = cc.Sprite:createWithSpriteFrameName("speed4_battle.png")
            local sp2 = cc.Sprite:createWithSpriteFrameName("speed3_battle.png")
            local sp3 = cc.Sprite:createWithSpriteFrameName("speed2_battle.png")
            sp1:setPositionX(-29)
            sp2:setPositionX(8)
            sp3:setPositionX(35)
            node:addChild(sp1)
            node:addChild(sp2)
            node:addChild(sp3)
            node:setScaleX(0.5)
        else
            local sp1 = cc.Sprite:createWithSpriteFrameName("speed4_battle.png")
            local sp2 = cc.Sprite:createWithSpriteFrameName("speed4_battle.png")
            local sp3 = cc.Sprite:createWithSpriteFrameName("speed2_battle.png")
            sp1:setPositionX(-30)
            sp2:setPositionX(10)
            sp3:setPositionX(41)
            node:addChild(sp1)
            node:addChild(sp2)
            node:addChild(sp3)
            node:setScaleX(0.5)
        end
    else
        self._speedBtn.speed:setVisible(true)
        if self._speedBtn.node then
            self._speedBtn.node:removeFromParent()
            self._speedBtn.node = nil
        end
    end
end

function BattleView:onPauseBtnClicked()
    if self._battleScene:isSkillAreaShow() then return end
    if not self._battleScene:isEnablePause() then 
        self._viewMgr:showTip(lang("XINSHOUZHANDOU_99"))
        return 
    end
    self._isPause = not self._isPause
    if self._isPause then
        audioMgr:pauseAll()
        -- self._battleScene:setBattleSpeed(0)
        self._pauseBtn:loadTextureNormal("pauseBtn_battleSelected.png",1)
        collectgarbage("collect")

        local str = ""
        local mode = self._battleInfo.resultMode  or self._battleInfo.mode
        local physical = self._battleInfo.physical
        local showStarDes = false
        local modeT = {
            [BattleUtils.BATTLE_TYPE_BOSS_DuLong]       = 1,
            [BattleUtils.BATTLE_TYPE_BOSS_XnLong]       = 1,
            [BattleUtils.BATTLE_TYPE_BOSS_SjLong]       = 1,
            [BattleUtils.BATTLE_TYPE_Siege_Atk]         = 1,
            [BattleUtils.BATTLE_TYPE_Siege_Def]         = 1,
            [BattleUtils.BATTLE_TYPE_Siege_Atk_WE]      = 1,
            [BattleUtils.BATTLE_TYPE_Siege_Def_WE]      = 1,
            [BattleUtils.BATTLE_TYPE_GBOSS_1]           = 1,
            [BattleUtils.BATTLE_TYPE_GBOSS_2]           = 1,
            [BattleUtils.BATTLE_TYPE_GBOSS_3]           = 1,
            [BattleUtils.BATTLE_TYPE_AiRenMuWu]         = 1,
            [BattleUtils.BATTLE_TYPE_Zombie]            = 1,
            [BattleUtils.BATTLE_TYPE_CloudCity]         = 1,
            [BattleUtils.BATTLE_TYPE_Legion]            = 1,
        }
        if mode and modeT[mode] then
            str = lang("TIPS_QUIT_PVE")
        elseif mode == BattleUtils.BATTLE_TYPE_Arena or mode == BattleUtils.BATTLE_TYPE_ServerArena  then
            if not self._battleInfo.isReport then
                str = lang("TIPS_QUIT_PVP")
            end
        elseif mode == BattleUtils.BATTLE_TYPE_Fuben then
            showStarDes = true
            if self._battleInfo.isBranch then
                str = 1
            else
                str = lang("TIPS_QUIT_CAMPAIGN")
            end
        elseif mode == BattleUtils.BATTLE_TYPE_Crusade then
            str = lang("TIPS_QUIT_CRUSADE")
        elseif mode == BattleUtils.BATTLE_TYPE_Siege then 
            if self._battleInfo.subType == BattleUtils.BATTLE_TYPE_Fuben then
                showStarDes = true
                str = lang("TIPS_QUIT_CAMPAIGN")
            elseif self._battleInfo.subType == BattleUtils.BATTLE_TYPE_Crusade then
                str = lang("TIPS_QUIT_CRUSADE")
            end
        end
        local oldHudType = BattleUtils.HUD_TYPE
        self._viewMgr:showDialog("battle.BattlePauseView", {mode = mode, showStarDes = showStarDes, isReport = self._battleInfo.isReport, callback = function (index)
            if index == 1 then
                self:onPauseBtnClicked()
            elseif index == 2 then
                self:onPauseBtnClicked()
                self._battleScene:surrender()
            end
            if oldHudType ~= BattleUtils.HUD_TYPE then
                self._battleScene:onHUDTypeChange()
            end
        end, quitTip = str})

        self._hudTip:setVisible(false)
    else
        self._battleScene:reflashAudio()
        -- self._battleScene:setBattleSpeed(self._battleSpeed)
        self._pauseBtn:loadTextureNormal("pauseBtn_battle.png",1)
    end
end

function BattleView:initBattleGuide()
    self._isInitBattleGuide = true
end

function BattleView:onquiteBtnClicked()
    self._battleScene:guideSurrender()
end

-- 新手引导专用锁定技能， 永远提示CD没到
function BattleView:onLockSkill()
    self._guideLockSkill = true
end

function BattleView:onUnlockSkill()
    self._guideLockSkill = false
end

function BattleView:onSengLvEff(callback)
    local mc = mcMgr:createViewMC("zhandousenglv_senglveff", false, true, callback)
    mc:setPosition(MAX_SCREEN_WIDTH*0.5,MAX_SCREEN_HEIGHT*0.5)
    self:addChild(mc, 9999999)
end

function BattleView:onAutoBtnClicked()
    if self._battleScene:isSkillAreaShow() then return end
    if not self._battleScene:isEnableAuto() then 
        self._viewMgr:showTip(lang("XINSHOUZHANDOU_99"))
        return 
    end
    if not self._autoFight:isVisible() then
        self._autoBtn:loadTextureNormal("autoBtn_battleSelected.png",1)
        self._battleScene:setSkillAuto(true)
        self._autoFight:setVisible(true)
        self._autoTip:setVisible(false)
    else
        self._autoBtn:loadTextureNormal("autoBtn_battle.png",1)
        self._autoFight:setVisible(false)
        self._battleScene:setSkillAuto(false)
    end
end

function BattleView:screenToPos(x, y, anim, callback)
    self._battleScene:battleBeginAnimCancel()
    local _anim = anim
    local _x = x
    local _y = y
    self._screenToUpdateId = ScheduleMgr:regSchedule(1, self, function(self, dt)
        local pt1x, pt1y = self._battleScene:getScenePosition()
        self._battleScene:screenToPos(_x, _y, _anim)
        local pt2x, pt2y = self._battleScene:getScenePosition()
        local dx = math.abs(pt1x - pt2x)
        local dy = math.abs(pt1y - pt2y)
        if dx < 1 and dy < 1 then
            if callback then callback() end
            if self._screenToUpdateId then
                ScheduleMgr:unregSchedule(self._screenToUpdateId)
            end
        end
    end)
end

function BattleView:onSkipBtnClicked()
    if self._battleScene:isSkillAreaShow() then return end
    if not self._battleScene:isEnableSkip() then 
        self._viewMgr:showTip(lang("XINSHOUZHANDOU_99"))
        return 
    end
    self._skipBtn:setTouchEnabled(false)
    self._battleScene:doJump()
end

function BattleView:onSurrenderBtnClicked()
    if self._battleScene:isSkillAreaShow() then return end
    local mode = self._battleInfo.mode
    self._surrenderView = self._viewMgr:showDialog("battle.BattleSurrenderView", {callback = function (index)
        if index == 1 then
            self._surrenderView = nil
        elseif index == 2 then
            self._surrenderView = nil
            self._battleScene:surrender()
        end
    end, mode = mode})
end

function BattleView:onChatBtnClicked(btn)
    if self._battleScene:isSkillAreaShow() then return end
    local circle = self._chatBtn.circle
    if btn.idx then
        self._battleScene:onChat(1, lang("CALL_BATTLE_0"..btn.idx.."_0"..GRandom(3)))
        circle.extend = false
        circle:stopAllActions()
        circle:runAction(cc.ScaleTo:create(0.1, 0))
    else
        -- [[高亮
        local btnClone = btn:clone()
        btnClone:setTitleText("")
        btnClone:setPurityColor(255, 255, 255)
        btnClone:setVisible(false)
        btnClone:setPosition(btnClone:getContentSize().width/2,btnClone:getContentSize().height/2)
        btn:addChild(btnClone)
        btnClone:setTouchEnabled(false)
        btnClone:setOpacity(200)
        btnClone:runAction(cc.Sequence:create(
            -- cc.DelayTime:create(.01),
            cc.CallFunc:create(function( )
                btnClone:setVisible(true)
            end),
            cc.ScaleTo:create(0.01,1.1),
            cc.Spawn:create(
                cc.FadeOut:create(.05),
                cc.ScaleTo:create(0.05,1.12)
            ),
            cc.RemoveSelf:create(true)
        ))
        --]]

        circle:stopAllActions()
        if circle.extend then
            circle:runAction(cc.ScaleTo:create(0.1, 0))
        else
            circle:runAction(cc.ScaleTo:create(0.1, 1))
        end
        circle.extend = not circle.extend
    end
end

-- 托管
function BattleView:onTuoGuan(tuoguan)
    if self._tuoguanMc ~= nil then return end
    self._tuoguanMc = mcMgr:createViewMC("tuoguan_tuoguan", true, false)
    self._tuoguanMc:setPosition(880, 30)
    self:getUI("uiLayer.topLayer"):addChild(self._tuoguanMc)
end

function BattleView:close(noAnim, _type, _callback)
    self._battleScene:beforeClear()
    ScheduleMgr:nextFrameCall(self, function()
        if not self._battleInfo then
            return
        end
        local callback = self._battleInfo.endcallback
        BattleView.super.close(self, noAnim)
        callback(_type)
        if _callback then
            _callback()
        end
    end)
end

-- 重播
function BattleView:replay()
    if self._resultView then
        self._resultView:close(true)
    end
    self._viewMgr:disableIndulge()
    self._widget:setSaturation(0)
    self._battleScene:getView():setSaturation(0)
    BC.reset(self._battleInfo.playerInfo.lv, self._battleInfo.enemyInfo.lv, self._battleInfo.reverse, self._battleInfo.siegeReverse)
    BattleUtils.playBattleMusic(self._battleInfo.mode, self._battleInfo.isElite)
    self._battleScene:replay()
end

function BattleView:getReleaseDelay()
    return -1
end

function BattleView:isReleaseAllOnShow()
    if self._nounloadRes then
        return false
    else
        return true
    end
end

function BattleView:isReleaseTextureOnShow()
    if self._nounloadRes then
        return false
    else
        return true
    end
end

function BattleView:isReleaseAllOnPop()
    return true
end

function BattleView:isAsyncRes()
    return false
end

function BattleView:setNoticeBar()
    self._viewMgr:hideNotice(true)
end


function BattleView:setGiftMoneyTip()
    self._viewMgr:hideGiftMoneyTip()
end

function BattleView:onRestart()
    self._restart = true
    ScheduleMgr:cleanMyselfDelayCall(self)
    ScheduleMgr:cleanMyselfTicker(self)
    if self._battleScene then
        self._battleScene:setBattleSpeed(0)
        ScheduleMgr:cleanMyselfDelayCall(self._battleScene)
        ScheduleMgr:cleanMyselfTicker(self._battleScene)
    end
    if BC then
        ScheduleMgr:cleanMyselfDelayCall(BC.logic)
        ScheduleMgr:cleanMyselfTicker(BC.logic)
    end
    cc.Director:getInstance():getActionManager():removeAllActions()
end

function BattleView:showDialog(name, data, forceShow, Async, callback, noPop)
    -- 重写此方法, 不是结算界面就暂停游戏
    if string.find(name, "battle.BattleResult")
     or string.find(name, "battle.BattleCountView") 
     or string.find(name, "battle.BattleSurrenderView") 
     or self._popViewCount == nil then
        return BattleView.super.showDialog(self, name, data, forceShow, Async, callback, noPop)
    else
        if self._popViewCount == 0 then
            if self._battleScene then self._battleScene:setBattleSpeed(0) end
            self._forcePause = true
        end
        self._popViewCount = self._popViewCount + 1
        local popview = BattleView.super.showDialog(self, name, data, forceShow, Async, callback, noPop)
        popview:setCloseCallback(function ()
            self._popViewCount = self._popViewCount - 1
            if self._popViewCount == 0 then
                self._forcePause = false
                if self._battleScene then self._battleScene:setBattleSpeed(self._battleSpeed) end
            end
        end)
        return popview
    end
end

function BattleView:applicationDidEnterBackground()
    if self._battleScene then
        self._battleScene:applicationDidEnterBackground()
    end
end

function BattleView:applicationWillEnterForeground(second)
    if self._battleScene then
        self._battleScene:applicationWillEnterForeground(second)
    end
end

-- 从后台且回来, 检查一下战场数据是否有异常 
function BattleView:applicationDidBecomeActive()
    if self._battleScene then
        if GameStatic.checkZuoBi_1 then
            -- 下一帧 主线程去检查
            ScheduleMgr:delayCall(0, self, function()
                if not self._battleScene then return end
                print("检查战中属性")
                local res = self._battleScene:checkData()
                if res ~= nil then
                    BC.zuobi = 3
                    if OS_IS_WINDOWS then
                        if ViewManager then ViewManager:getInstance():onLuaError("战中属性被修改: "..serialize(res)) end
                    else
                        if ViewManager then ViewManager:getInstance():showTip("数据异常.04") end
                        ApiUtils.playcrab_lua_error("attr_xiugai", serialize(res))
                        if GameStatic.kickZuoBi_1 then
                            do _G["AppExit"..math.random(10)]() if not APP_EXIT then ServerManager = nil ModelManager = nil end return end
                        end
                    end   
                end
            end)
        end
        if GameStatic.checkZuoBi_4 then
            -- 下一帧 主线程去检查
            ScheduleMgr:delayCall(0, self, function()
                if not self._battleScene then return end
                print("检查战中时间")
                local res = self._battleScene:checkTime()
                if res ~= nil then
                    BC.zuobi = 4
                    if OS_IS_WINDOWS then
                        if ViewManager then ViewManager:getInstance():onLuaError("战中时间被修改: "..serialize(res)) end
                    else
                        if ViewManager then ViewManager:getInstance():showTip("数据异常.05") end
                        ApiUtils.playcrab_lua_error("time_xiugai", serialize(res))
                        if GameStatic.kickZuoBi_4 then
                            do _G["AppExit"..math.random(10)]() if not APP_EXIT then ServerManager = nil ModelManager = nil end return end
                        end
                    end   
                end
            end)
        end
    end
end

function BattleView.dtor()
    _BattleUtils = nil
    BattleView = nil
    color_black = nil
    settingKey = nil
    tc = nil
end

return BattleView
