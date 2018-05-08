--[[
    Filename:    GuildRedSenderLayer.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-06-06 19:54:55
    Description: File description
--]]

-- 玩家发红包

local GuildRedSenderLayer = class("GuildRedSenderLayer", BaseLayer)

function GuildRedSenderLayer:ctor()
    GuildRedSenderLayer.super.ctor(self)
end

function GuildRedSenderLayer:onInit()
    -- self:showLightAnim(false)
    local title = self:getUI("bg.titleBg.title")
    -- UIUtils:setTitleFormat(title, 1)

    self._tishi = self:getUI("bg.tishi")

    local ruleBtn = self:getUI("bg.ruleBtn")
    self:registerClickEvent(ruleBtn, function()
        self._viewMgr:showDialog("guild.redgift.GuildRedDescDialog", {wordType = "GIVE"})
    end)

    local redRankBtn = self:getUI("bg.redRankBtn")
    self:registerClickEvent(redRankBtn, function()
        self._viewMgr:showDialog("guild.redgift.GuildRedRankDialog", {redType = 1})
        -- self._viewMgr:showTip("排行榜未开封")
    end)
    for i=1,3 do
        local redGift = self:getUI("bg.redGift" .. i)

        local tuijian = redGift:getChildByFullName("effetPanel")
        tuijian:setVisible(false)
        tuijian:setContentSize(tuijian:getContentSize().width-10,tuijian:getContentSize().height)
        local text = tuijian:getChildByFullName("Label_61")
        text:enableOutline(cc.c4b(60,30,10,255), 1)

        self:registerClickEvent(redGift, function()
            self._viewMgr:showDialog("guild.redgift.GuildRedSenderDialog", {sendType = i, callback = function(redId)
                self._modelMgr:getModel("GuildRedModel"):setUpdateRobList(false)
                self:sendUserRed(redId)
            end})
        end)
    end
    self:initSugessAnima()

end

function GuildRedSenderLayer:initSugessAnima()

    if self._sugestAnim then
        self._sugestAnim:removeFromParent(true)
        self._sugestAnim = nil
    end
    if self._activePanel then
        self._activePanel:setVisible(false)
    end
    local type_ = self._modelMgr:getModel("GuildRedModel"):isShowHalfRed()
    if type_ then
        for i=1,type_ do 
            local gift = self:getUI("bg.redGift"..i)
            local panel = gift:getChildByFullName("effetPanel")
            panel:setVisible(true)
            local labelTip = panel:getChildByFullName("Label_61")
            if i == type_ then
                self._sugestAnim = mcMgr:createViewMC("tuijianfafang_alliancerobred", true)
                self._sugestAnim:setPosition(panel:getContentSize().width/2-10,panel:getContentSize().height/2)
                panel:addChild(self._sugestAnim,20)
                self._activePanel = panel
                labelTip:setString("半价(推荐)")
            else
                labelTip:setString("半价")
            end
        end
    end
end

function GuildRedSenderLayer:reflashUI()
    local times = self._modelMgr:getModel("GuildModel"):getRedSendTimes()
    local todayTimes = self._modelMgr:getModel("PlayerTodayModel"):getData()
    -- dump(todayTimes, 'todayTimes ================')
    if todayTimes["day16"] then
        local tempTimes = (times - todayTimes["day16"])
        if (times - todayTimes["day16"]) < 0 then
            tempTimes = 0
        end
        self._tishi:setString("今日剩余可发红包数量: " .. tempTimes .. "/" .. times)
    else
        self._tishi:setString("今日剩余可发红包数量: " .. times .. "/" .. times)
    end
end

-- 玩家发送红包
function GuildRedSenderLayer:sendUserRed(redId)
    self._serverMgr:sendMsg("GuildRedServer", "sendUserRed", {id = redId}, true, {}, function (result)
        dump(result, "resul玩家发送红包t==============")
        local type_ = self._modelMgr:getModel("GuildRedModel"):isShowHalfRed()
        print("-------------------------------------")
        print(type_)
        if not type_ then
            if self._sugestAnim then
                self._sugestAnim:removeFromParent(true)
                self._sugestAnim = nil
            end
            for i=1,3 do 
                local gift = self:getUI("bg.redGift"..i)
                local panel = gift:getChildByFullName("effetPanel")
                panel:setVisible(false)
            end
        end
        self:sendUserRedFinish(result)
    end, function(errorId)
        if tonumber(errorId) == 2809 then
            self._viewMgr:showTip("您今天发红包次数已用光")
        end
    end)
end 

function GuildRedSenderLayer:sendUserRedFinish(result)
    if result == nil then 
        return 
    end
    -- dump(result)
    DialogUtils.showGiftGet({
        gifts = result["reward"],
        callback = function()
            -- self:showLightAnim(true)
        end})
    self:reflashUI()
end


return GuildRedSenderLayer
