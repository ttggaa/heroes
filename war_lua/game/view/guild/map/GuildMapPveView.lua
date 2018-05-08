--[[
    Filename:    GuildMapPveView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-06-25 16:59:30
    Description: File description
--]]


local GuildMapPveView = class("GuildMapPveView", BasePopView, require("game.view.guild.map.GuildMapCommonBattle"))

function GuildMapPveView:ctor(data)
    GuildMapPveView.super.ctor(self)

    self._userId = self._modelMgr:getModel("UserModel"):getData()._id
    self._guildMapModel = self._modelMgr:getModel("GuildMapModel")

    self._eventType = data.eventType
    self._callback = data.callback
    self._targetId = data.targetId
    self._eleId = data.eleId
    self._eleTypeName = data.typeName
    self._isRemote = data.isRemote
end



function GuildMapPveView:onInit()


    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("guild.map.GuildMapPveView")
        elseif eventType == "enter" then 
        end
    end)  

    local labTip = self:getUI("bg.tipLab1")
    labTip:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    
    local labTip = self:getUI("bg.tipLab")
    labTip:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        
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
        self:closeInit()
        return
    end

    if mapList[self._targetId][self._eleTypeName] == nil then
        self._viewMgr:showTip("当前点已被占领")
        self:closeInit()
        return
    end
    self._mapInfomation = mapList[self._targetId][self._eleTypeName]
    if self._mapInfomation.formation == nil then
        self._viewMgr:showTip("当前点已被占领")
        self:closeInit()
        return
    end

    self._sysGuildMapThing = tab:GuildMapThing(self._eleId)

    local titleLab = self:getUI("bg.titleBg.titleLab")
    UIUtils:setTitleFormat(titleLab, 1)
    -- titleLab:setFontName(UIUtils.ttfName)
    -- titleLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
    titleLab:setString(lang(self._sysGuildMapThing.name))
    
    local subTitleLab = self:getUI("bg.infoBg.titleLab")
    local titleLab = self:getUI("bg.titleBg.titleLab")
    UIUtils:setTitleFormat(titleLab, 1)
    if subTitleLab == nil then 
        titleLab:setString(lang(self._sysGuildMapThing.name))
    else
        subTitleLab:setString(lang(self._sysGuildMapThing.name))
        UIUtils:adjustTitle(self:getUI("bg.infoBg"))
        print("self._sysGuildMapThing.qiangdu=====", self._sysGuildMapThing.qiangdu)
        subTitleLab:setColor(UIUtils.colorTable.ccUIBasePromptColor)
        if self._sysGuildMapThing.qiangdu == 3 then 
            -- subTitleLab:setColor(UIUtils.colorTable.ccColorQuality2)
            -- subTitleLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
            local stateImg1 = self:getUI("bg.infoBg.stateImg1")
            stateImg1:setVisible(false)
        elseif self._sysGuildMapThing.qiangdu == 2 then
            -- subTitleLab:setColor(UIUtils.colorTable.ccColorQuality6)
            local stateImg2 = self:getUI("bg.infoBg.stateImg2")
            stateImg2:setVisible(false)            
        else
            subTitleLab:setColor(cc.c3b(78,50,13))
        end
        
    end

    local descBg = self:getUI("bg.descBg")
    if descBg ~= nil and self._sysGuildMapThing.des ~= nil then 
        local GuildMapUtils = require "game.view.guild.map.GuildMapUtils"
        local userLvl = self._modelMgr:getModel("UserModel"):getData().lvl
        local serverLvl = self._guildMapModel:getData().servLv
        local str = GuildMapUtils:handleDesc(lang(self._sysGuildMapThing.des), userLvl, serverLvl)

        if string.find(str, "color=") == nil then
            str = "[color=000000]"..str.."[-]"
        end          
        print("str============", str)
        local rtx = RichTextFactory:create(str,descBg:getContentSize().width - 20,descBg:getContentSize().height)
        rtx:formatText()
        rtx:setVerticalSpace(3)
        rtx:setAnchorPoint(cc.p(0,0.5))
        rtx:setPosition(-rtx:getInnerSize().width/2,descBg:getContentSize().height/2)
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
    local rewardNode = self:getUI("bg.rewardBg.rewardNode")
    local GuildMapUtils = require "game.view.guild.map.GuildMapUtils"
    local backNode = GuildMapUtils:showItems(reward, 0.7)
    backNode:setPosition(rewardNode:getContentSize().width/2  , rewardNode:getContentSize().height/2)
    rewardNode:addChild(backNode)
    
    self._enemyMapHurt = mapList[self._targetId][self._eleTypeName].npcHp
    self._myselfMapHurt = self._modelMgr:getModel("UserModel"):getData().roleGuild.mapHurt

    local mapHurtLab = self:getUI("bg.mapHurtLab")
    mapHurtLab:setString(mapList[self._targetId][self._eleTypeName].npcHp .. "/" .. self._sysGuildMapThing.npcHp)
    mapHurtLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
    mapHurtLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    local mapHurtProg = self:getUI("bg.mapHurtProg")
    mapHurtProg:setPercent(mapList[self._targetId][self._eleTypeName].npcHp / self._sysGuildMapThing.npcHp * 100)


    local sysTeam = tab:Team(self._mapInfomation.formation["team1"])
    local teamImg = cc.Sprite:create("asset/uiother/steam/" .. sysTeam.steam .. ".png")
    teamImg:setPosition(infoBg:getContentSize().width/2, 50)
    teamImg:setScale(sysTeam.guildmap / 100)
    teamImg:setAnchorPoint(0.5, 0)
    infoBg:addChild(teamImg)

    local enterBtn = self:getUI("bg.enterBtn")
    self:registerClickEvent(enterBtn, function ()
        self:pveBefore()
    end)

    if self._isRemote == true then 
        enterBtn:setVisible(false)
        cancelBtn:setVisible(false)
        close1Btn:setVisible(true)
    else
        enterBtn:setVisible(true)
        cancelBtn:setVisible(true)
        close1Btn:setVisible(false)
    end    
end




function GuildMapPveView:pveAfterFinish()

end


function GuildMapPveView:onDestroy()
    self:onDestroy1()
    GuildMapPveView.super.onDestroy(self)
end


return GuildMapPveView