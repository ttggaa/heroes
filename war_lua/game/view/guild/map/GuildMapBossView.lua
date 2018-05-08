--[[
    Filename:    GuildMapBossView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-06-25 16:59:30
    Description: File description
--]]


local GuildMapBossView = class("GuildMapBossView", BasePopView, require("game.view.guild.map.GuildMapCommonBattle"))

function GuildMapBossView:ctor(data)
    GuildMapBossView.super.ctor(self)

    self._userModel = self._modelMgr:getModel("UserModel")
    self._userId = self._userModel:getData()._id
    self._guildMapModel = self._modelMgr:getModel("GuildMapModel")

    self._eventType = data.eventType
    self._callback = data.callback
    self._targetId = data.targetId
    self._eleId = data.eleId
    self._eleTypeName = data.typeName
    self._isRemote = data.isRemote

    self._isBossBattle = true
end



function GuildMapBossView:onInit()

    local labTip = self:getUI("bg.labTip")
    labTip:setColor(UIUtils.colorTable.ccUIBaseColor1)
    
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("guild.map.GuildMapBossView")
            if OS_IS_WINDOWS then
                package.loaded["game.view.guild.map.GuildMapCommonBattle"] = nil
            end
        elseif eventType == "enter" then 
        end
    end)  
    self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
    end)

    local cancelBtn = self:getUI("bg.cancelBtn")
    self:registerClickEvent(cancelBtn, function ()
        self:close()
    end)

    local close1Btn = self:getUI("bg.close1Btn")
    self:registerClickEvent(close1Btn, function ()
        self:close()
    end)

    local mapList = self._guildMapModel:getData().mapList

    local infoBg = self:getUI("bg.infoBg")
    if mapList[self._targetId] == nil then 
        self._viewMgr:showTip("当前点已被占领")
        return
    end

    if mapList[self._targetId][self._eleTypeName] == nil then
        self._viewMgr:showTip("当前点已被占领")
        return
    end

    local thisEle = mapList[self._targetId][self._eleTypeName]

    self._sysGuildMapThing = tab:GuildMapThing(self._eleId)

    if self._sysGuildMapThing.bossback == 1 then
        self._pveBattleFunction = BattleUtils.enterBattleView_GBOSS_1
    elseif self._sysGuildMapThing.bossback == 2 then
        self._pveBattleFunction = BattleUtils.enterBattleView_GBOSS_2
    else
        self._pveBattleFunction = BattleUtils.enterBattleView_GBOSS_3
    end

    local titleLab = self:getUI("bg.titleBg.titleLab")
    UIUtils:setTitleFormat(titleLab, 2)
    titleLab:setString(lang(self._sysGuildMapThing.name))

    local labTip = self:getUI("bg.labTip")
    labTip:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    for i=1,3 do
        local labTip = self:getUI("bg.rankNode.tipLab" .. i)
        labTip:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    end

    local battleList = thisEle.ah or {}
    local sortFunc = function(a, b) 
        if a.h > b.h then
            return true
        end
        if a.h == b.h then 
            if a.t > b.t then 
                return true
            end
        end
    end
    table.sort(battleList, sortFunc)

    local sumUserCount = 0
    for i=1, 5 do
        local listCell = self:getUI("bg.rankNode.listCell" .. i)
        local battleInfo = battleList[i]
        if battleInfo == nil then
            listCell:setVisible(false)
        else
            sumUserCount = sumUserCount + 1
            local rankLab = listCell:getChildByName("rankLab")
            rankLab:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)

            local nameLab = listCell:getChildByName("nameLab")
            nameLab:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
            nameLab:setString(battleInfo.name)

            local hurtLab = listCell:getChildByName("hurtLab")
            hurtLab:setColor(UIUtils.colorTable.ccUIBaseColor2)
            hurtLab:setString(battleInfo.h)
            hurtLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        end
    end

    local nothingImg = self:getUI("bg.rankNode.nothingImg")
    local rankTipLab1 = self:getUI("bg.rankNode.tipLab1")
    local rankTipLab2 = self:getUI("bg.rankNode.tipLab2")
    local rankTmpImg = self:getUI("bg.rankNode.tmpImg")
    
    if sumUserCount <= 0 then 

        local nothingTipLab = self:getUI("bg.rankNode.nothingImg.tipLab")
        nothingTipLab:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
        nothingImg:setVisible(true)
        rankTipLab1:setVisible(false)
        rankTipLab2:setVisible(false)
        rankTmpImg:setVisible(false)
    else
        nothingImg:setVisible(false)
        rankTipLab1:setVisible(true)
        rankTipLab2:setVisible(true)
        rankTmpImg:setVisible(true)
    end


    local labTip = self:getUI("bg.rewardNode.tipLab")
    labTip:setColor(UIUtils.colorTable.ccUIBaseTextColor2)    

    local sceneBg = self:getUI("bg.sceneBg")
    sceneBg:loadTexture("guildMapImg_sceneBg" .. self._sysGuildMapThing.bossback .. ".png", 1)
    
    local descBg = self:getUI("bg.descBg")
    if descBg ~= nil and self._sysGuildMapThing.des ~= nil then 
        local GuildMapUtils = require "game.view.guild.map.GuildMapUtils"
        local userLvl = self._modelMgr:getModel("UserModel"):getData().lvl
        local serverLvl = self._guildMapModel:getData().servLv
        local str = GuildMapUtils:handleDesc(lang(self._sysGuildMapThing.des), userLvl, serverLvl)

        if string.find(str, "color=") == nil then
            str = "[color=000000]"..str.."[-]"
        end          
        local rtx = RichTextFactory:create(str,descBg:getContentSize().width,descBg:getContentSize().height, true)
        rtx:formatText()
        rtx:setVerticalSpace(3)
        rtx:setAnchorPoint(cc.p(0,0.5))
        rtx:setPosition(-rtx:getInnerSize().width/2,descBg:getContentSize().height/2)
        descBg:setContentSize(40 + rtx:getInnerSize().width, descBg:getContentSize().height)
        descBg:addChild(rtx)
    end

    
    local beginX, inv = 135, 74
    local npcAward = self._sysGuildMapThing["npcAward1"]
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local reward = {}
    for i,v in ipairs(npcAward) do
        if v ~= nil  and userData.lvl >= v[1] and userData.lvl <= v[2] then 
            for p,q in pairs(v[3]) do
                reward[#reward + 1] = q
            end
        end
    end

    self._bossLvl = mapList[self._targetId][self._eleTypeName].lvl
    self._bossHp = mapList[self._targetId][self._eleTypeName].npcHp
    local rewardNode = self:getUI("bg.rewardNode")
    local GuildMapUtils = require "game.view.guild.map.GuildMapUtils"
    local backNode = GuildMapUtils:showItems(reward, 1, 1)
    backNode:setScale(0.6)
    backNode:setAnchorPoint(0.5, 0.5)
    backNode:setPosition(rewardNode:getContentSize().width * 0.5 , rewardNode:getContentSize().height/2 - 20)
    rewardNode:addChild(backNode)
    
    self._enemyMapHurt = mapList[self._targetId][self._eleTypeName].npcHp
    self._myselfMapHurt = self._modelMgr:getModel("UserModel"):getData().roleGuild.mapHurt

    local mapHurtLab = self:getUI("bg.mapHurtLab")
    local curHp = mapList[self._targetId][self._eleTypeName].npcHp
    mapHurtLab:setString(curHp)
    mapHurtLab:setColor(UIUtils.colorTable.ccUIBaseColor5)

    local tipLab = self:getUI("bg.tipLab")
    tipLab:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    local totalHp = self._sysGuildMapThing.npcHp
    tipLab:setString("/" .. totalHp)
    tipLab:setPositionX(mapHurtLab:getPositionX() + mapHurtLab:getContentSize().width)

    local mapHurtProg = self:getUI("bg.mapHurtProg")
    local percent = curHp * 100 / totalHp
    mapHurtProg:setPercent(percent)
    self._curPercent = percent
    

    -- local sysTeam = tab:Team(self._mapInfomation.formation["team1"])
    local teamImg = cc.Sprite:create("asset/uiother/steam/" .. self._sysGuildMapThing.art .. ".png")
    teamImg:setPosition(infoBg:getContentSize().width/2, 0)
    teamImg:setScale(0.6)
    teamImg:setAnchorPoint(0.5, 0)
    infoBg:addChild(teamImg)

    local enterBtn = self:getUI("bg.enterBtn")
    self:registerClickEvent(enterBtn, function ()
        self:pveBefore()
    end)

    local inviteBtn = self:getUI("bg.inviteBtn")
    self:registerClickEvent(inviteBtn, function ()
        self:inviteBattle()
    end)

    if self._isRemote == true then 
        enterBtn:setVisible(false)
        inviteBtn:setVisible(false)
        cancelBtn:setVisible(false)
        close1Btn:setVisible(true)
    else
        enterBtn:setVisible(true)
        inviteBtn:setVisible(true)
        cancelBtn:setVisible(true)
        close1Btn:setVisible(false)
    end    
end

--邀请参战
function GuildMapBossView:inviteBattle()
     --是否在联盟平台群中
    local isInQun = false
    local bindGroup = self._modelMgr:getModel("GuildModel"):getAllianceDetail().bindGroup or {}
    if bindGroup.hadJoin == 1 then
        isInQun = true
    end
    if not isInQun then
        self._viewMgr:showTip(lang("GUILDBOSS_INVITE_TIP4"))
        return
    end
    self._serverMgr:sendMsg("GuildServer", "getLastInviteTime", {}, true, {}, function (result)
        if result == nil then 
            return
        end
        local lastTime = result.time or 0
        local curentTime = self._userModel:getCurServerTime()
        if curentTime >= lastTime + 3600 then
            print("aaaa")
            self:sendToPlatform()
        else
            print("aaaab")
            local _viewMgr = self._viewMgr or ViewManager:getInstance()
            _viewMgr:showTip(lang("GUILDBOSS_INVITE_TIP5"))
        end
    end)
end

function GuildMapBossView:sendToPlatform()
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local guildID = userData.guildId
    -- desTxt = string.gsub(desTxt,"{$name1}",userData["name"] or "")
    -- desTxt = string.gsub(desTxt,"{$name2}",enemyName)
    local title = lang("GUILDBOSS_INVITE_TITLE")
    local desTxt = lang("GUILDBOSS_INVITE_CONTENT")
    desTxt = string.gsub(desTxt,"{$num}",self._curPercent or 50)

    local param = {}
    param.message_ext = "t=2,gid=".. guildID ..","
    -- param.message_ext = "t=2,gid=".. guildID ..",s=".. GameStatic.sec ..",bt=1,l=".. self._shareMyName ..",r=".. self._shareEnemyName ..""
    param.scene = 2
    param.title = title
    param.desc  = desTxt
    param.media_tag = sdkMgr.SHARE_TAG.MSG_INVITE
    sdkMgr:sendToPlatform(param, function(code, data) 
        if code == sdkMgr.SDK_STATE.SDK_SHARE_SUCCESS then --分享成功，加cd
            local _serverMgr = self._serverMgr or ServerManager:getInstance()
            _serverMgr:sendMsg("GuildServer", "setLastInviteTime", {}, false, {}, function(result)
            
            end)
        end
        sdkMgr:unregisterCallbackByEventType("TYPE_SHARE")
    end)
end


return GuildMapBossView