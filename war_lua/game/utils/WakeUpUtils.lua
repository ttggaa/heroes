--[[
    Filename:    WakeUpUtils.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2017-04-25 16:01:06
    Description: File description
--]]

local WakeUpUtils = {}

local cacheExtInfo 

local openBattleView 
--[[
--! @function wakeUpCallback
--! @desc 登陆与sdk拉起回调
--! @paraminParam  参数协定:t=xx,d=xx   string
--! @return
--]]
function WakeUpUtils.wakeUpCallback(inParam)
    -- 防止未登录激活wakeup
    local userModel = ModelManager:getInstance():getModel("UserModel")
    if userModel:getData() == nil or userModel:getData().lvl == nil then 
        cacheExtInfo = inParam
        return 
    end
    if inParam == nil  then return end
    local tempList = string.split(inParam, ",")
    local infoList = {}
    for k,v in pairs(tempList) do
        local tempKeyValue = string.split(v, "=")
        if #tempKeyValue == 2 then 
            infoList[tempKeyValue[1]] = tempKeyValue[2]
        end
    end
    local infoType = infoList["t"]
    if infoType == nil then return end
    if WakeUpUtils["handleWakeUp" .. infoType] ~= nil then 
        WakeUpUtils["handleWakeUp" .. infoType](infoList)
    end
end


function WakeUpUtils.checkCacheExtInfo()
    print("checkCacheExtInfo=========================")

    if cacheExtInfo ~= nil then 
        WakeUpUtils.wakeUpCallback(cacheExtInfo)
        cacheExtInfo = nil
    end
end

function WakeUpUtils.setCacheExtInfo(inParam)
    cacheExtInfo = string.urldecode(inParam)
end


function WakeUpUtils.handleWakeUp1(inParam)
    if openBattleView == true then 
        return
    end
    --【战报分享】点击链接战报有重复弹的现象
    openBattleView = true
    local userModel = ModelManager:getInstance():getModel("UserModel")
    if userModel:getData() == nil or userModel:getData().lvl == nil or userModel:getData().lvl <= 5 then
        return
    end

    ViewManager:getInstance():showGlobalDialog("wakeup.WakeUpBattleView", { result = inParam}, nil, nil, false)
end

--[[
    联盟BOSS邀请
]]
function WakeUpUtils.handleWakeUp2(inParam)
    if openBattleView == true then 
        return
    end
    openBattleView = true
    local inviteGuildid = tonumber(inParam.gid)
    local userModel = ModelManager:getInstance():getModel("UserModel")
    local userGuildid
    local userData = userModel:getData()
    if userData == nil or userData.lvl == nil then
        return
    end
    userGuildid = userData.guildId and tonumber(userData.guildId) or 0
    local isSameGuild = inviteGuildid == userGuildid
    local level = tonumber(userData.lvl)
    local isLevelEnough = level >= 26
    local isSucess = (pcall(function ()
        local view_manager = ViewManager:getInstance()
        local tips = lang("GUILDBOSS_INVITE_TIP1")
        view_manager:showGlobalDialog("global.GlobalSelectDialog",
                    {desc = tips,
                    alignNum = 1,
                    callback1 = function ()
                        openBattleView = nil
                        if not isSameGuild then
                            view_manager:showTip(lang("GUILDBOSS_INVITE_TIP2"))
                            return
                        end
                        if not isLevelEnough then
                            view_manager:showTip(lang("GUILDBOSS_INVITE_TIP3"))
                            return
                        end
                        view_manager:showView("guild.map.GuildMapView",{},true)
                    end,
                    callback2 = function()
                        openBattleView = nil
                    end},true)
    end))
    if not isSucess then
        openBattleView = nil
    end
    
end


--[[
    联盟秘境邀请
]]
function WakeUpUtils.handleWakeUp3(inParam)
    if openBattleView == true then 
        return
    end
    openBattleView = true
    local inviteGuildid = tonumber(inParam.gid)
    local userModel = ModelManager:getInstance():getModel("UserModel")
    local userGuildid
    local userData = userModel:getData()
    if userData == nil or userData.lvl == nil then
        return
    end
    userGuildid = userData.guildId and tonumber(userData.guildId) or 0
    local isSameGuild = inviteGuildid == userGuildid
    local level = tonumber(userData.lvl)
    local isLevelEnough = level >= 26--设置等级限制
    local isSucess = (pcall(function ()
        local view_manager = ViewManager:getInstance()
		local server_manager = ServerManager:getInstance()
		local model_manager = ModelManager:getInstance()
        local tips = lang("GUILD_FAM_TIPS_24")
        view_manager:showGlobalDialog("global.GlobalSelectDialog",
                    {desc = tips,
                    alignNum = 1,
                    callback1 = function ()
                        openBattleView = nil
                        if not isSameGuild then
                            view_manager:showTip(lang("GUILDBOSS_INVITE_TIP2"))
                            return
                        end
                        if not isLevelEnough then
                            view_manager:showTip(lang("GUILDBOSS_INVITE_TIP3"))
                            return
                        end
						local gridKey = inParam.inGridX..","..inParam.inGridY
						server_manager:sendMsg("GuildMapServer", "getSecretLandStatus", {tagPoint = gridKey}, true, {}, function(result, errorCode)
							if errorCode and errorCode~=0 then
								if errorCode == 3047 then
									self._viewMgr:showTip(lang("GUILD_FAM_TIPS_23"))
								end
								return
							end
							local isLoad = view_manager:isViewLoad("guild.map.GuildMapView")
							if result.status==1 then
								if isLoad then
									model_manager:getModel("GuildMapModel"):noticeScreenToFam(gridKey)
								else
									view_manager:showView("guild.map.GuildMapView",{toGridKey = gridKey})
								end
								model_manager:getModel("GuildMapFamModel"):setInviteKey(0)
							elseif result.status==2 then
								view_manager:showTip(lang("GUILD_FAM_TIPS_28"))
							elseif result.status==3 then
								self._viewMgr:showTip(lang("GUILD_FAM_TIPS_29"))
							else
								view_manager:showTip(lang("GUILD_FAM_TIPS_15"))
							end
						end)
						
                    end,
                    callback2 = function()
                        openBattleView = nil
                    end},true)
    end))
    if not isSucess then
        openBattleView = nil
    end
    
end

function WakeUpUtils.setOpenBattleView(inOpenBattleView)
    openBattleView = inOpenBattleView
end

function WakeUpUtils.dtor()
    cacheExtInfo = nil
end
return WakeUpUtils