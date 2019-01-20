--[[
    Filename:    UserServer.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2015-04-28 12:11:52
    Description: File description
--]]

local UserServer = class("UserServer", BaseServer)
function UserServer:ctor(data)
    UserServer.super.ctor(self, data)

end

function UserServer:_init()
    self._userModel = self._modelMgr:getModel("UserModel")
    self._playerTodayModel = self._modelMgr:getModel("PlayerTodayModel")
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._formationModel = self._modelMgr:getModel("FormationModel")
    self._heroModel = self._modelMgr:getModel("HeroModel")
    self._treasureModel = self._modelMgr:getModel("TreasureModel")
    self._vipModel = self._modelMgr:getModel("VipModel")
    self._pgtModel = self._modelMgr:getModel("PrivilegesModel")
    -- self._signModel = self._modelMgr:getModel("SignModel")
    self._sevenDaysModel = self._modelMgr:getModel("ActivitySevenDaysModel")
    self._talentModel = self._modelMgr:getModel("TalentModel")
    self._cloudCityModel = self._modelMgr:getModel("CloudCityModel")
    self._arrowModel = self._modelMgr:getModel("ArrowModel")
    self._leagueModel = self._modelMgr:getModel("LeagueModel")
    self._celebrationModel = self._modelMgr:getModel("CelebrationModel")
    self._tFormationModel = self._modelMgr:getModel("TformationModel")
    self._crusadeModel = self._modelMgr:getModel("CrusadeModel")
    self._awakingModel = self._modelMgr:getModel("AwakingModel")
    self._weaponsModel = self._modelMgr:getModel("WeaponsModel")
    self._defenseModel = self._modelMgr:getModel("DefenseModel")
    self._spellBooksModel = self._modelMgr:getModel("SpellBooksModel")
    self._recallModel = self._modelMgr:getModel("FriendRecallModel")
    self._lotteryModel = self._modelMgr:getModel("AcLotteryModel")
    self._dailySiegeModel = self._modelMgr:getModel("DailySiegeModel")
    self._skillTalentModel = self._modelMgr:getModel("SkillTalentModel")
    self._backupModel = self._modelMgr:getModel("BackupModel")
end

-- 登录获取用户数据
-- 完整数据结构查看地址：http://172.16.100.90:8080/demo/schema.php
--[[
'_id'            => core_Schema::STR,  // 角色ID
"_it"            => core_Schema::NUM, // 初始化时间init time
"_lt"            => core_Schema::NUM, // login time,上次登录时间
'_at'            => core_Schema::NUM, // active time,上次活跃时间
'uid'            => core_Schema::NUM, // 玩家ID
'name'           => core_Schema::STR, // 玩家名
'avatar'         => core_Schema::NUM, // 玩家头像/形象ID
'lvl'            => core_Schema::NUM, // 玩家等级
'exp'            => core_Schema::NUM, // 玩家经验
'prestigeLvl'    => core_Schema::NUM, // 声望等级
'prestigeExp'    => core_Schema::NUM, // 声望经验
'vipLvl'         => core_Schema::NUM, // VIP等级
'lockGem'        => core_Schema::NUM, // 冻结钻石
'payGem'         => core_Schema::NUM, // 钻石数量（充值）
'gem'            => core_Schema::NUM, // 钻石数量（非充值）
'payGemTotal'    => core_Schema::NUM, // 累计钻石数量（充值）
'gemTotal'       => core_Schema::NUM, // 累计钻石数量（非充值)
'gold'           => core_Schema::NUM, // 金子（游戏币）
'physcal'        => core_Schema::NUM, // 体力值
'physcalLimit'   => core_Schema::NUM, // 体力值上限
'upPhyTime'      => core_Schema::NUM, // 上次体力更新时间
'drawTeamLastTime' => core_Schema::NUM, //上次免费抽取方阵时间
'formationTeamNum'=> core_Schema::NUM, //阵型上阵怪兽数量
'dayInfo'       => 'DayInfo', //每日重置
'teams'            => 'Teams',            //Team
'formations'      => 'Formations',//阵型
'items'      => 'Items',//背包
'story'    =>'Story',//剧情副本
]]--

function UserServer:onLogin(result, error)
    if error ~= 0 then
        print("登录失败")
        return
    end
    self._serverMgr:setToken(result["token"])
    self._serverMgr:setRequestId(result["initRequestId"])
    self:callback(result)
end

function UserServer:onLogined(result, error)
    if error ~= 0 then
        return
    end

    local tencentData = {}
    if result and result.constList then
        tencentData.qqVip = result.constList.qqVip
        tencentData.tequan = result.constList.tequan
        self._modelMgr:getModel("TencentPrivilegeModel"):setData(tencentData)
    end
    self:callback(result)
end

function UserServer:onInit(result, error)
    if error ~= 0 then
        return
    end

    local tencentData = {}
    if result and result.constList then
        tencentData.qqVip = result.constList.qqVip
        tencentData.tequan = result.constList.tequan
        self._modelMgr:getModel("TencentPrivilegeModel"):setData(tencentData)
    end
    self:callback(result)
end

-- 完整数据结构查看地址：http://172.16.100.90:8080/demo/schema.php
function UserServer:onGetPlayerAction(result, error)
    self:_init()
    -- dump(result, "UserServer:onGetPlayerAction", 10)
    
    -- 勿删，方便查看用户id
    print("用户ID",result._id)
    local data

    data = result["dayInfo"]

    result["dayInfo"] = nil
    self._playerTodayModel:setData(data)
    self._playerTodayModel:setDrawAward(result["drawAward"])
    self._playerTodayModel:updateBubble(result["bubble"])

    data = result["items"]
    if data ~= nil then 
        result["items"] = nil
        self._itemModel:setData(data)
    end

    data = result["formations"]
    result["formations"] = nil
    self._formationModel:setFormationData(data)


    local storyData  = result["story"]
    result["story"] = nil

    -- 英雄法术书数据
    data = result["spellBooks"]
    --if data then 
        self._spellBooksModel:setData(data or {})
        result["spellBooks"] = nil
    --end
    
    data = result["heros"]
    result["heros"] = nil
    self._heroModel:setData(data)
    
    -- data = result["sign"]
    -- result["sign"] = nil
    -- self._signModel:setData(data)

    data = result["privileges"]
    if data ~= nil then
        result["privileges"] = nil
        self._pgtModel:setData(data)
    end

    data = result["treasures"]
    if data ~= nil then
        result["treasures"] = nil
        self._treasureModel:setData(data)
    end

    data = result["arrow"]
    if data ~= nil then
        result["arrow"] = nil
        self._arrowModel:updateData(data)
    end

    data = result["friendAct"]
    if data ~= nil then
        result["friendAct"] = nil
        self._recallModel:setFriendActData(data)
    end

    data = result["crusade"]
    if data ~= nil then
        result["crusade"] = nil
        self._crusadeModel:setCurLastCrusade(data)
    end

    data = result["vip"]
    result["vip"] = nil
    self._vipModel:setData(data)

    data = result["activity"]
    result["activity"] = nil

    if not self._ativityModel then
        self._ativityModel = self._modelMgr:getModel("ActivityModel")
    end

    if data.acSpecial then
        self._ativityModel:setActivitySpecialData(data.acSpecial)
    end

    if data.acTask then
        self._ativityModel:setActivityTaskData(data.acTask)
    end

    data = result["acShowList"]
    result["acShowList"] = nil
    self._ativityModel:setActivityShowList(data)

    -- 单笔充值数据
    data = result["sRcg"]
    if data then
        result["sRcg"] = nil
        self._ativityModel:setSingleRechargeData(data)
    end

    -- 英雄交锋数据
    data = result["acHeroDuel"]
    if data then
        result["acHeroDuel"] = nil
        self._ativityModel:setAcHeroDuelData(data)
    end

    -- 1元购数据
    data = result["acRmb"]
    if data then
        result["acRmb"] = nil
        self._ativityModel:setAcRmbData(data)
    end

    -- 动态单笔充值
    data = result["intelligentRecharge"]
    if data then
        result["intelligentRecharge"] = nil
        self._ativityModel:setIntRechargeData(data)
    end

    -- 时间市场
    data = result["offLine"]
    if data then
        result["offLine"] = nil
        self._ativityModel:setRetrieveData(data)
    end

    -- VIP 周礼包
    data = result["vipWeeklyGift"]
    if data then
        dump(data,"lishunan1234",10)
        result["vipWeeklyGift"] = nil
        self._ativityModel:setVipWeeklyGifts(data)
    end

    -- 整点狂欢数据
    data = result["lottery"]
    if data then
        -- dump(data,"lottery_user",10)
        self._lotteryModel:updateData(data)
        result["lottery"] = nil
    end

    -- 宝物技能编组
    data = result["tformations"]
    if data then
        result["tformations"] = nil
        self._tFormationModel:setData(data)
    end

    data = result["talent"]
    result["talent"] = nil
    self._talentModel:setData(data)

    if result["award"] ~= nil then
        -- 7日登录
        local sevenDaysModel = self._modelMgr:getModel("ActivitySevenDaysModel")
        sevenDaysModel:updateData(result["award"]["login"], result["award"]["loginFinish"])
        result["award"]["login"] = nil 
        result["award"]["loginFinish"] = nil

        sevenDaysModel:updateLoginExt(result["award"]["loginExt"])
        result["award"]["loginExt"] = nil 
        
        -- 等级回馈
        local levelFBModel = self._modelMgr:getModel("ActivityLevelFeedBackModel")
        levelFBModel:updateData(result["award"]["levels"], result["award"]["levelsFinish"])
        result["award"]["levels"] = nil 
        result["award"]["levelsFinish"] = nil


        -- 半月登录
        -- local halfMonthModel = self._modelMgr:getModel("ActivityHalfMonthModel")
        -- halfMonthModel:updateData(result["award"]["login2"], result["award"]["loginFinish2"])
        -- result["award"]["login2"] = nil 
        -- result["award"]["loginFinish2"] = nil
    end

    -- 觉醒任务
    data = result["awaking"]
    if data then 
        self._awakingModel:setAwakingTaskData(data)
        result["awaking"] = nil
    end

    -- 攻城
    data = result["weaponInfo"]
    if data then 
        self._weaponsModel:setData(data)
        result["weaponInfo"] = nil
    end

    -- 防守
    data = result["defenseInfo"]
    if data then 
        self._defenseModel:setData(data)
        result["defenseInfo"] = nil
    end

    --法术祈愿数据
    data = result["drawAward"] 
    if data then
        self._spellBooksModel:setDrawData(data)
        result["drawAward"] = nil
    end

    --法术天赋
    data = result["spTalent"]
    if data then
        self._skillTalentModel:setData(data)
        result["spTalent"] = nil
    else
        self._skillTalentModel:setData({})
    end

    self._userModel:setData(result)

    data = result["runes"]
    if data ~= nil then 
        result["runes"] = nil
        self._teamModel:setHolyData(data)
    end

    -- 怪兽必须在items,formations,user后进行处理，涉及到处理数据
    data = result["teams"]
    if data ~= nil then 
        result["teams"] = nil
        self._teamModel:setData(data)
    end

    -- 副本数据要放在用户数据处理后面，需要等级判断，即使nil也要传入做初始化,请勿更改
    local intanceModel = self._modelMgr:getModel("IntanceModel")
    local intanceEliteModel = self._modelMgr:getModel("IntanceEliteModel")
    intanceModel:setData(storyData)
    intanceEliteModel:setData(storyData)

    self._ativityModel:evaluateActivityData()
    if result["award"] ~= nil then
        -- 嘉年华
        local carnivalModel = self._modelMgr:getModel("ActivityCarnivalModel")
        -- dump(result["award"]["sevenAim"])
        carnivalModel:updateCarnivalData(result["award"]["sevenAim"])
        result["award"]["sevenAim"] = nil 
    end

    -- 公测庆典活动数据处理
    if result["celebrity"] ~= nil then
        self._celebrationModel:updateData(result["celebrity"])
        result["celebrity"] = nil
    end

    -- 幸运抽奖=
    if result["runeLottery"] ~= nil then
        local runeLotteryModel = self._modelMgr:getModel("RuneLotteryModel")
        runeLotteryModel:setData(result["runeLottery"])
        result["runeLottery"] = nil
    end

    if result["comingGuildAc"] ~= nil then
        local AcUltimateModel = self._modelMgr:getModel("AcUltimateModel")
        AcUltimateModel:setData(result["comingGuildAc"])
        result["comingGuildAc"] = nil
    end
    
    if result["gadgets"] ~= nil then
        self._modelMgr:getModel("MainViewModel"):setGadgetData(result["gadgets"])
    end

    -- 新手引导
    GuideUtils.guideIndex = result["guide"]
    -- 补救引导，自动修正
    local newIndex = GuideUtils.autoAdjust(GuideUtils.guideIndex, result["lvl"])
    if newIndex then
        GuideUtils.guideIndex = newIndex
        GuideUtils.guideChange = newIndex
        if OS_IS_WINDOWS then 
            self._viewMgr:showTip("等级"..result["lvl"].."，新手引导自动修正引导到"..newIndex.."步")
        end
    end

    -- 后援
    if result["backups"] ~= nil then
        self._backupModel:setBackupData(result["backups"])
    end

    -- 成长之路奖励状态
    if result["roadOfGrowthStatus"] ~= nil then
       self._modelMgr:getModel("GrowthWayModel"):setAwardData(result["roadOfGrowthStatus"]) 
    end

    --兵团战阵
    if result["battleArray"] ~= nil then
        self._modelMgr:getModel("BattleArrayModel"):setBattleArrayData(result["battleArray"])
    end

    -- 上传错误信息
    ApiUtils.playcrab_upload_lua_error()
    ApiUtils.playcrab_monitor_login()

    self:callback()
end

function UserServer:onBuyPhyscal( result, error )
    if error ~= 0 then 
        print("error ....",error)
        return
    end
    self:_init()
    self._playerTodayModel:updateDayInfo(result.d.dayInfo)
    self._userModel:updateUserData(result.d)
    self:callback(result)
end

function UserServer:onBuyTexp( result, error )
    if error ~= 0 then 
        print("error ....",error)
        return
    end
    dump(result,"result",10)
    self:_init()
    self._playerTodayModel:updateDayInfo(result.d.dayInfo)
    self._userModel:updateUserData(result.d)
    self:callback(result)
end

function UserServer:onBuyArrow( result, error )
    if error ~= 0 then 
        print("error ....",error)
        return
    end

    self:_init()
    self._playerTodayModel:updateDayInfo(result.d.dayInfo)
    self._userModel:updateUserData(result.d)
    self:callback(result)
end

function UserServer:onBuyGold( result, error )
    if error ~= 0 then 
        print("error ....",error)
        return
    end
    self:_init()
    self._playerTodayModel:updateDayInfo(result.d.dayInfo)
    self._userModel:updateUserData(result.d)
    self:callback(result)
end

function UserServer:onBuyGuildPower( result, error )
    if error ~= 0 then 
        print("error ....",error)
        return
    end
    self:_init()
    self._playerTodayModel:updateDayInfo(result.d.dayInfo)
    self._userModel:updateUserData(result.d)
    self:callback(result)
end

function UserServer:onBuyMagicNum( result, error )
    if error ~= 0 then 
        print("error ....",error)
        return
    end
    self:_init()
    self._playerTodayModel:updateDayInfo(result.d.dayInfo)
    if result and result.d and result.d.items then
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(result["d"]["items"], true)
        result["d"]["items"] = nil
    end
    self._userModel:updateUserData(result.d)
    self:callback(result)
end

function UserServer:onBuyTreasureNum( result, error )
    if error ~= 0 then 
        print("error ....",error)
        return
    end
    self:_init()
    self._playerTodayModel:updateDayInfo(result.d.dayInfo)
    if result and result.d and result.d.items then
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(result["d"]["items"], true)
        result["d"]["items"] = nil
    end
    self._userModel:updateUserData(result.d)
    self:callback(result)
end

function UserServer:onBuyLuckyCoin( result, error )
    if error ~= 0 then 
        print("error ....",error)
        return
    end
    self:_init()
    self._userModel:updateUserData(result.d)
    self:callback(result)
end

function UserServer:onBubble( result, error )
    self:_init()
    dump(result,"uid".. self._modelMgr:getModel("UserModel"):getUID(),10)
    self._playerTodayModel:updateBubble(result.bubble)
end

function UserServer:onSetName(result,errorCode)
    if errorCode ~= 0 then 
        if errorCode == 117 then
            self._viewMgr:showTip(lang("INFORMATION_NAME_ERROR_02"))
        elseif errorCode == 107 then
            self._viewMgr:showTip("只能为中文、英文、数字")
        elseif errorCode == 114 then 
            self._viewMgr:showTip(lang("INFORMATION_NAME_ERROR_03"))
        end
        return
    end
    -- dump(result)
    if result.d then
        self:_init()
        self._userModel:updateUserData(result.d)
    end
    self:callback(result)
end

function UserServer:onGetEmptyInfo(result, error)
    print("onGetEmptyInfo")
    self:callback(result)
end

function UserServer:onPushStatis(result, error)
    if error ~= 0 then 
        return
    end
    -- dump(result)
    if result ~= nil and 
        result["d"] ~= nil and  
        result["d"]["statis"] ~= nil then
        self:_init()
        self._userModel:updateUserData(result["d"])
        self._sevenDaysModel:reflashMainView()
    end
end

function UserServer:onPushTopPayChange(result)
    -- dump(result)
    if result ~= nil and 
        result["d"] ~= nil then
        self:_init()
        self._userModel:updateUserData(result["d"])
    end
end


function UserServer:onGetTargetUser(result, error)
    print("getTargetUser=======",error, result)
    if error ~= 0 then
        return
    end
    self:callback(result)
end

function UserServer:onGetTargetUserBattleInfo(result, error)
    -- print("onGetTargetUserBattleInfo=======",error, result)
    if error ~= 0 then
        return
    end
    self:callback(result)
end

function UserServer:onShare(result, error)
    if error ~= 0 then
        return
    end
    if result and result["d"] then
        self:_init()
        self._userModel:updateUserData(result["d"])
    end    
    self:callback(result)
end


-- 保存宣言
function UserServer:onSvaeDeclaration( result, errorCode )
    if errorCode ~= 0 then 
        if errorCode == 117 then
            self._viewMgr:showTip(lang("INFORMATION_NAME_ERROR_02"))
        end
        return
    end
    self:callback(result)
end

function UserServer:onSimulationLogin(result, error)
    if 0 ~= tonumber(error) then
        print("UserServer:onSimulationLogin error", error)
        ViewManager:getInstance():onLuaError("UserServer:onSimulationLogin error:" .. error)
        return
    end
    if result and result["d"] and  result["d"]["constList"] ~= nil then
        ModelManager:getInstance():getModel("UserModel"):handleConstList(result["d"]["constList"])
    end
    if result and result["d"] then
        self:callback(result["d"])
    end
end

function UserServer:onBubbleModify(result, error)
    -- if error ~= 0 then
    --     return
    -- end
    self:_init()
    self._playerTodayModel:updateBubble1(result["d"]["bubble"])
    self:callback(result)
end

function UserServer:onGetIOSCommentAward(result, error)
    if error ~= 0 then
        return
    end
    self._modelMgr:getModel("UserModel"):updateUserData(result["d"])
    self._modelMgr:getModel("ItemModel"):updateItems(result.d.items)
    self:callback(result)
end

function UserServer:onShareActivity(result, error)
    if error ~= 0 then
        return
    end
    -- dump(result, "onShareActivity")

    if result["d"] then
        self._modelMgr:getModel("ActivityModel"):updateSpecialData(result["d"]["activity"])
        self._modelMgr:getModel("UserModel"):updateUserData(result["d"])
        self._modelMgr:getModel("ItemModel"):updateItems(result.d.items)
    end
    self:callback(result)
end

function UserServer:onSubscribe_setlist(result, error)
    if error ~= 0 then
        return
    end
    self:callback(result)
end

function UserServer:onGetVipGiftMail(result, error)
    if error ~= 0 then
        return
    end
    self:callback(result)
end

function UserServer:onSombra(result, error)
    print("onSombra")
    GLOBAL_VALUES.onSombra = true
end


-- 主界面心悦特权红点推送
function UserServer:onPushUserRedDots(result, error)
    if error ~= 0 then
        return
    end
    if result and result["d"] then 
        local mainViewModel = self._modelMgr:getModel("MainViewModel")
        mainViewModel:updateRedDotsData(result.d)
    end 
    self:callback(result)

end

-- 主界面 心悦特权点击
--[[
    -- type 1：心悦特权
]]
function UserServer:onViewRedDots(result, error)
    if error ~= 0 then
        return
    end
    -- dump(result,"result==>",5)    
    if result and result["d"] then 
        local mainViewModel = self._modelMgr:getModel("MainViewModel")
        mainViewModel:updateRedDotsData(result.d)
    end 
    self:callback(result)
end

-- 联盟地图任务统计 wangyan
function UserServer:onPushMapStatis(result, error) 
    -- dump(result, "UserServer====pushMapTask", 10)
    if error ~= 0 then
        return
    end
   
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:pushMapTask(result)
end

-- 元素分享领奖
function UserServer:onShareWithNoCondition(result, error)
    if error ~= 0 then
        return
    end
    -- dump(result,"result==>",10)
    if result["d"] then
        self._modelMgr:getModel("UserModel"):updateExtraData(result["d"])
        self._modelMgr:getModel("ItemModel"):updateItems(result["d"]["items"])
        if result["d"].teams then
            self._modelMgr:getModel("TeamModel"):updateTeamData(result["d"].teams)
            result["d"].teams = nil
        end
    end

    self:callback(result)
end

-- 贵宾特权周奖励
function UserServer:onGetWeeklyVipGiftMail(result, error)
    if error ~= 0 then
        return
    end
    dump(result,"result==>",10)
    if result["d"] then
        self._modelMgr:getModel("UserModel"):updateExtraData(result["d"])
    end
    self:callback(result)
end

--同步玩家联盟id
function UserServer:onGetUserGuildId(result, error)
    if error ~= 0 then
        return
    end
    if result then
        if result["guildId"] ~= nil then
            self._modelMgr:getModel("UserModel"):getData()["guildId"] = result["guildId"]
        end
    end
    self:callback(result)
end

--换安装包奖励
function UserServer:onReplacePackage(result, error)
    if error ~= 0 then
        return
    end
    if result["d"] then
        self._modelMgr:getModel("UserModel"):updateExtraData(result["d"])
    end
    self:callback(result)
end

return UserServer