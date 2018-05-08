--[[
    Filename:    GuildServer.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-04-20 16:14:55
    Description: File description
--]]

local GuildServer = class("GuildServer", BaseServer)

function GuildServer:ctor(data)
    GuildServer.super.ctor(self)
    self._guildModel = self._modelMgr:getModel("GuildModel")
end

-- 请求数据

-- 根据Id获取数据
function GuildServer:onGetGameGuildBaseInfo(result, error)
    if error ~= 0 then 
        return
    end
    -- if result["d"] then
    --     -- local userModel = self._modelMgr:getModel("UserModel")
    --     -- userModel:updateUserData(result["d"])
    --     self:updateUserData(result)
    --     -- result["d"] = nil
    -- end
    self:callback(result)
end

-- 快速加入
function GuildServer:onJoinGuildQuickly(result, error)
    if error ~= 0 then 
        return
    end
    if result["d"] then
        self:updateUserData(result)
    end
    self._modelMgr:getModel("GuildModel"):setCheckRedStatus(true)
    self:callback(result)
end

-- 加入 & 申请
function GuildServer:onApplyJoin(result, error)
    if error ~= 0 then 
        return
    end
    -- dump(result, "result ==============")
    if result["d"] then
        self:updateUserData(result)
    end

    self._modelMgr:getModel("GuildModel"):setCheckRedStatus(true)
    self:callback(result)
end

-- 取消申请
function GuildServer:onCancelApplyJoin(result, error)
    if error ~= 0 then 
        return
    end
    -- dump(result)
    -- self:handAboutServerData(result)
    self:callback(result)
end

-- 创建
function GuildServer:onCreateGuild(result, error)
    if error ~= 0 then 
        return
    end
    -- dump(result)
    if result["d"] then
        -- local userModel = self._modelMgr:getModel("UserModel")
        -- userModel:updateUserData(result["d"])
        self:updateUserData(result)
        result["d"] = nil
    end
    -- self:handAboutServerData(result)
    self._modelMgr:getModel("GuildModel"):setCheckRedStatus(true)
    self:callback(result)
end

-- 查找
function GuildServer:onSelectGuild(result, error)
    if error ~= 0 then 
        return
    end
    -- dump(result)
    -- self:handAboutServerData(result)
    self:callback(result)
end

-- 加入列表
function GuildServer:onGetApplyGuildList(result, error)
    if error ~= 0 then 
        return
    end
    
    -- dump(result)
    self:callback(result)
end

-- 获取工会基本信息
function GuildServer:onGetGameGuildInfo(result, error)
    if error ~= 0 then 
        return
    end
    if result["techs"] then
        local tempTechs = {techs = result["techs"]}
        self._modelMgr:getModel("GuildModel"):setGuildScience(tempTechs)
        result["techs"] = nil 
    end
    if result["bubble"] then
        self._modelMgr:getModel("GuildModel"):setBubbleData(result["bubble"])
        result["bubble"] = nil 
    end
    if result["arrow"] then
        dump(result["arrow"], "arrow==")
        local arrowModel = self._modelMgr:getModel("ArrowModel")
        if arrowModel:getIsFirstLoad() == false then
            arrowModel:updateData(result["arrow"])
            arrowModel:setIsFristLoad(true)
        end
        result["arrow"] = nil
    end
    self._modelMgr:getModel("GuildModel"):setAllianceList(result)
    self:callback(result)
end

-- 修改联盟名称
function GuildServer:onChangeGuildName(result, error)
    if error ~= 0 then 
        return
    end
    -- dump(result,"restult ===================")
    self:updateUserData(result)
    self:callback(result)
end

-- 退出联盟
function GuildServer:onQuitGuild(result, error)
    if error ~= 0 then 
        return
    end
    self._modelMgr:getModel("ChatModel"):quitGuild()  --by wangyan
    self._modelMgr:getModel("GuildModel"):clearAllianceOpenAction()
    if result["d"] then
        -- local userModel = self._modelMgr:getModel("UserModel")
        -- userModel:updateUserData(result["d"])
        self:updateUserData(result)
        result["d"] = nil
    end
    -- dump(result)
    self:callback(result)
end

-- 踢出
function GuildServer:onKickMember(result, error)
    if error ~= 0 then 
        return
    end
    -- dump(result)
    self:callback(result)
end

-- 任命
function GuildServer:onPositionAppoint(result, error)
    if error ~= 0 then 
        return
    end
    -- dump(result)
    self:updateUserData(result)
    self:callback(result)
end

-- 公告
function GuildServer:onAddGuildNotice(result, error)
    if error ~= 0 then 
        return
    end
    -- dump(result)
    self:callback(result)
end

-- 宣言
function GuildServer:onAddGuildDeclare(result, error)
    if error ~= 0 then 
        return
    end
    -- dump(result)
    self:callback(result)
end

-- 修改头像
function GuildServer:onChangeAvatar(result, error)
    if error ~= 0 then 
        return 
    end
    -- dump(result)
    self:callback(result)
end

-- 排行榜
function GuildServer:onGetGuildListRank(result, error)
    if error ~= 0 then 
        return
    end
    -- dump(result)
    self:callback(result)
end

-- 日志
function GuildServer:onGetGuildEvent(result, error)
    if error ~= 0 then 
        return
    end
    -- dump(result)
    self._modelMgr:getModel("GuildModel"):setLogData(result)
    result = nil
    self:callback(result)
end

-- 限制
function GuildServer:onSetJoinGuildCondition(result, error)
    if error ~= 0 then 
        return
    end
    -- 更新联盟限制信息
    -- self._modelMgr:getModel("GuildModel"):updateLimit(result)
    -- dump(result)
    self:callback(result)
end

-- 审批列表
function GuildServer:onGetApplyUserList(result, error)
    if error ~= 0 then 
        return
    end
    -- dump(result)
    self:callback(result)
end

-- 审批
function GuildServer:onApproval(result, error)
    if error ~= 0 then 
        return
    end
    -- dump(result)
    self:callback(result)
end

-- 科技
function GuildServer:onGetTechInfo(result, error)
    if error ~= 0 then 
        return
    end
    self._modelMgr:getModel("GuildModel"):setGuildScience(result)
    self:callback(result)
end

function GuildServer:onTechDonate(result, error)
    if error ~= 0 then 
        return
    end
    -- dump(result)
    if result and result["d"] and result["d"].backFlow then
        self._modelMgr:getModel("BackflowModel"):updateReturnBlessData(result["d"].backFlow)
        result["d"].backFlow = nil
    end
    self:updateUserData(result)
    result["d"] = nil
    -- dump(result,"==============================")
    self._modelMgr:getModel("GuildModel"):updateScience(result)
    self:callback(result)
end

function GuildServer:onGetDailyAward(result, error)
    if error ~= 0 then 
        return
    end
    -- dump(result)
    if result["d"]["items"] ~= nil then
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(result["d"]["items"], true)
        result["d"]["items"] = nil 
    end
    self:updateUserData(result)
    self:callback(result)
end

-- 领取联盟每日礼包
function GuildServer:onGetGuildDailyGift(result, error)
    if error ~= 0 then 
        return
    end
    -- dump(result)
    self:handAboutServerData(result)
    self:callback(result)
end


-- 推送数据
-- 玩家申请列表推送
-- function GuildServer:onNewMail( result, error)
--     if error ~= 0 then 
--         return
--     end
--     print("****************")
--     dump(result)
--     print("查看内容")
-- end

-- 联盟事件推送
function GuildServer:onUpdateGuildEvent(result, error)
    if error ~= 0 then 
        return
    end
    if result["guildLog"] then   --聊天联盟推送
        local str = self._modelMgr:getModel("GuildModel"):getRichTextString(result["guildLog"])
        local chatModel = self._modelMgr:getModel("ChatModel")
        local guildId = self._modelMgr:getModel("UserModel"):getData().guildId 
        if result["guildLog"]["type"] == 3 or result["guildLog"]["type"] == 4 or 
            result["guildLog"]["type"] == 5 or result["guildLog"]["type"] == 6 or guildId == nil or guildId <= 0 then
            return
        end
        local _, _, sendData = chatModel:paramHandle("log", {infoType = "GUILD_LOG_" .. result["guildLog"]["type"], info = str})
        if sendData ~= nil then
            chatModel:pushData(sendData)
        end
    end
end

-- 联盟科技升级推送
function GuildServer:onUpdateTechLevel(result, error)
    if error ~= 0 then 
        return
    end
    -- gameGuild
    print("联盟科技升级推送****************")
    -- dump(result, "result ===========", 10)
    self._modelMgr:getModel("GuildModel"):updateScience({gameGuild = result})
    -- self._modelMgr:getModel("ChatModel"):pushSysDataByManual("GUILD_SCIENCE_UPDATAE", "科技名")
    -- print("****************")
    -- dump(result)
    -- print("查看内容")
end

-- 被踢玩家推送
function GuildServer:onKicked( result, error)
    if error ~= 0 then 
        return
    end
    self._modelMgr:getModel("ChatModel"):quitGuild()   --by wangyan
    self._modelMgr:getModel("GuildMapModel"):clear()
    self._modelMgr:getModel("GuildModel"):clearAllianceOpenAction()
    self:updateUserData(result)
    print("被踢玩家推送")
end

-- 加入玩家推送
function GuildServer:onJoined(result, error)
    if error ~= 0 then 
        return
    end
    print("**加入玩家推送**************")
    -- 更新元素庆典好友数据 hgf
    if result["d"] and result["d"]["celebrity"] then
        local celebrationModel = self._modelMgr:getModel("CelebrationModel")
        celebrationModel:updateData(result["d"]["celebrity"])
        result["d"]["celebrity"] = nil
    end

    self._viewMgr:showTip(string.gsub(lang("TIP_CREATE_GUILD_NAME_3"), "%b{}", result["d"]["guildName"]))
    -- self._modelMgr:getModel("ChatModel"):pushSysDataByManual("GUILD_JOIN", "玩家名")
    -- self._viewMgr:showTip(lang("TIP_CREATE_GUILD_NAME_3"))
    self:updateUserData(result)
    self._modelMgr:getModel("ChatModel"):setApplyRecord()   --清空聊天申请记录  wangyan
    self._modelMgr:getModel("ChatModel"):setPriApplyRecord()   --清空私聊聊天申请记录  wangyan
    print("加入玩家推送")
end

-- 联盟数据变化推送
function GuildServer:onChangeUserInfo(result, error)
    if error ~= 0 then 
        return
    end
    print("****************")
    -- 
    if result["d"]["guildLevel"] then
        self._modelMgr:getModel("GuildModel"):updateAllianceLevel(result["d"]["guildLevel"])
    end
    self:updateUserData(result)
    print("联盟数据变化推送")
end

-- 联盟有人申请
function GuildServer:onUpdateGuildApply(result, error)
    if error ~= 0 then 
        return
    end
    local userModel = self._modelMgr:getModel("UserModel")
    userModel:getData().guildApply = result["guildApply"]
    print("联盟有人申请推送", userModel:getData().guildApply)
end

-- 处理用户身上的数据
function GuildServer:updateUserData(result)
    -- dump(result)
    -- print(debug.traceback())
    if result == nil then 
        return 
    end
    if result.d and result.d.dayInfo then
        self._modelMgr:getModel("PlayerTodayModel"):updateDayInfo(result.d.dayInfo)
    end
    local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(result["d"])

    -- self._modelMgr:getModel("GuildModel"):saveBubbleModify()

    -- -- dump(self._guildModel:getAllianceDetail())
    -- -- userModel:updateGuildLevel(self._guildModel:getAllianceDetail().level)

    -- print("·===updateUserData=======··", self._guildModel:getAllianceDetail().level)
    -- userModel:getData().guildLevel = self._guildModel:getAllianceDetail().level
end

-- function GuildServer:handAboutServerData(result)
--     if result == nil then 
--         return 
--     end
--     local userModel = self._modelMgr:getModel("UserModel")
--     userModel:updateUserData(result["d"])
-- end

-- 航海数据
function GuildServer:onGetMFList(result, error)
    if error ~= 0 then 
        return
    end
    self:callback(result)
end

function GuildServer:onGetBindGuildInfo(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result, error)
end

function GuildServer:onBindGuild(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result, error)
end

function GuildServer:onUnBindGuild(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result, error)
end

-- 发送邮件
function GuildServer:onSendGuildMails(result, error)
    if error ~= 0 then 
        return
    end
    if result["d"] then
        self._guildModel:updateMailData(result["d"])
    end
    
    self:callback(result, error)
end

function GuildServer:handAboutServerData(result)
    if result == nil or result["d"] == nil then 
        return 
    end
   -- 物品数据处理要优先于怪兽
    if result["d"]["items"] ~= nil then
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(result["d"]["items"], true)
        result["d"]["items"] = nil 
    end

    if result["unset"] ~= nil then 
        local itemModel = self._modelMgr:getModel("ItemModel")
        local removeItems = itemModel:handelUnsetItems(result["unset"])
        itemModel:delItems(removeItems, true)
    end

    if result.d and result.d.dayInfo then
        self._modelMgr:getModel("PlayerTodayModel"):updateDayInfo(result.d.dayInfo)
    end

    local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(result["d"])
end
--获取本人设置的雇佣兵列表
function GuildServer:onGetMyMercenaryList(result, error)
    if error ~= 0 then 
        return
    end
    self._guildModel:setGuildMercenary(result["userMercenaryList"])
    self:callback(result["userMercenaryList"],error)
end
--设置佣兵
function GuildServer:onSetMercenary(result,error)
    if error ~= 0 then 
        return
    end
    self._guildModel:setGuildMercenary(result["userMercenaryList"])
    self:callback(result,error)
end

-- 领取雇佣兵奖励
function GuildServer:onGetMercenaryReward(result, error)
    if error ~= 0 then 
        return
    end
    self._guildModel:setGuildMercenary(result["userMercenaryList"])
    if result["d"] then
        self:updateUserData(result)
    end
    self:callback(result,error)
end
--撤回佣兵
function GuildServer:onRetractMercenary(result, error)
    if error ~= 0 then 
        return
    end
    self._guildModel:setGuildMercenary(result["userMercenaryList"])
    self:callback(result,error)
end
-- 获取全部的雇佣兵列表
function GuildServer:onGetAllMercenary(result, error)
    if error ~= 0 then 
        return
    end
    self._guildModel:setGuildMercenaryAllList(result)
    self:callback(result,error)
end
function GuildServer:onGetMercenaryList(result, error)
    if error ~= 0 then 
        if error == 2703 then  --特殊处理
            self:callback(result,error)
        end
        return
    else
        self._guildModel:setGuildMercenaryList(result)
        self:callback(result,error)
    end
end

--获取工会上次邀请参战时间
function GuildServer:onGetLastInviteTime(result, error)
    if error ~= 0 then 
        return
    end
    self:callback(result,error)
end

--设置工会上次邀请参战的时间
function GuildServer:onSetLastInviteTime(result, error)
    if error ~= 0 then 
        return
    end
    self:callback(result,error)
end

return GuildServer