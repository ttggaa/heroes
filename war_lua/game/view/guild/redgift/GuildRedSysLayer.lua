--[[
    Filename:    GuildRedSysLayer.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-06-06 19:54:11
    Description: File description
--]]

-- 系统红包

local GuildRedSysLayer = class("GuildRedSysLayer", BaseLayer)

function GuildRedSysLayer:ctor()
    GuildRedSysLayer.super.ctor(self)
end

function GuildRedSysLayer:onInit()
    local ruleBtn = self:getUI("bg.ruleBtn")
    self:registerClickEvent(ruleBtn, function()
        self._viewMgr:showDialog("guild.redgift.GuildRedDescDialog", {wordType = "SYSTEM"})
        -- self._viewMgr:showTip("我是规则，你要听我的")
    end)
    for i=1,3 do
        local redGift = self:getUI("bg.redGift" .. i)
        if redGift then
            redGift:setVisible(false)
        end
    end

    -- self:showLightAnim(false) 
    -- self:getGuildRed()


end

function GuildRedSysLayer:reflashUI(forceRefresh)

    print("GuildRedSysLayer:reflashUI")
    local sysRedData = self._modelMgr:getModel("GuildRedModel"):getSysData()
    if table.nums(sysRedData) ~= 0 and not forceRefresh then
        self:updateRed()
    else
        self:getGuildRed()
    end
    self._modelMgr:getModel("GuildRedModel"):updateRedTipButtle()
end

function GuildRedSysLayer:checkIsMax()
    local maxLevel = table.nums(tab.guildLevel)
    local goldMax,gemMax,treasureMax
    for i=maxLevel,1,-1 do 
        local data = tab:GuildLevel(i).technology
        if goldMax and gemMax and treasureMax then
            break
        end
        if data then
            for k,v in pairs (data) do 
                if v[1] == 7 then
                    goldMax = i
                elseif v[1] == 8 then
                    gemMax =i
                elseif v[1] == 9 then
                    treasureMax = i
                end
            end
        end
    end
    return {goldMax,gemMax,treasureMax}
end

function GuildRedSysLayer:updateRed()
    print("=updateRed=========")
    local sysRedData = self._modelMgr:getModel("GuildRedModel"):getSysData()
    dump(sysRedData, "sysRedData",10)

    local curentGuildLv = self._modelMgr:getModel("GuildModel"):getAllianceDetail().level
    local classType 
    local maxTable = self:checkIsMax()
    dump(maxTable)
    for i=1,3 do
        local redGift = self:getUI("bg.redGift" .. i)
        redGift:setVisible(true)
        local redData = sysRedData[i]
        local redTabData = tab:GuildRed(redData.id)
        local allNum = redGift:getChildByFullName("allNum")
        if allNum then
            allNum:setString(redTabData["reward"][3])
        end
        local haveNum = redGift:getChildByFullName("haveNum")
        if haveNum then
            haveNum:setString((redTabData["people"] - redData.rob) .. "/" .. redTabData["people"])
        end
        local desName = redGift:getChildByFullName("desName")
        if desName then
            desName:setString(redData.best)
            if redData.best == "" then
                desName:setString("无")
            end
        end

        -- dump(tab.guildLevel)

        local upStatus = redGift:getChildByFullName("canUp")
        if upStatus then
            if maxTable[i] and curentGuildLv < maxTable[i] then
                upStatus:setVisible(true)
                self:registerClickEvent(upStatus, function()
                    self._viewMgr:showTip(lang("TIP_GUILD_RED_2"))
                end)
                local x =math.max(164,allNum:getPositionX()+allNum:getContentSize().width)
                upStatus:setPositionX(x)
            else
                upStatus:setVisible(false)
            end
        end

        -- local gift = redGift:getChildByFullName("gift")        

        -- if gift then
        --     if redData.robRed == 1 then
        --         gift:loadTexture("allicance_redziyuan4.png", 1)
        --         classType = 4
        --     elseif redData.robRed == 2 then
        --         gift:loadTexture("allicance_redziyuan5.png", 1)
        --         classType = 5
        --     else
        --         gift:loadTexture("allicance_redziyuan" .. i .. ".png", 1)
        --         classType = i
        --     end
        -- end

        print("redData.robRed"..redData.robRed)
        if redData.robRed == 1 then
            classType = 4
        elseif redData.robRed == 2 then
            classType = 5
        else
            classType = i
        end
        self:addRedGiftEffect(redGift, classType,i)

        self:registerClickEvent(redGift, function()
            self:robGuildRed(redData)
        end)
    end
end

function GuildRedSysLayer:setGetStatus(panel,index)
    local getImage = cc.Sprite:createWithSpriteFrameName("status_get.png")  --遮罩
    local width,height = panel:getContentSize().width,panel:getContentSize().height
    getImage:setPosition(cc.p(width/2+panel:getPositionX(), height/2+panel:getPositionY())) 
    panel:getParent():addChild(getImage)
    getImage:setLocalZOrder(20)
    getImage:setName("Status_get_"..index)

end

--红包闪光特效  wangyan
function GuildRedSysLayer:addRedGiftEffect(redGift, classType,index)
    if redGift:getChildByName("redGiftAnim") then
        redGift:getChildByName("redGiftAnim"):removeFromParent(true)
    end

    local status_get = redGift:getParent():getChildByName("Status_get_"..index)
    if status_get then
        status_get:removeFromParent(true)
    end

    if classType == 4 then
        redGift:setBrightness(-40)
        redGift:setContrast(-40)

        local gift = redGift:getChildByFullName("gift")
        if gift then
            gift:setBrightness(40)
            gift:setContrast(40)
        end
        self:setGetStatus(redGift,index)
        return
    else
        redGift:setBrightness(0)
        redGift:setContrast(0)

        local gift = redGift:getChildByFullName("gift")
        if gift then
            gift:setBrightness(0)
            gift:setContrast(0)
        end
    end

    local anim = mcMgr:createViewMC("hongbaokelingqu_keling", true)
    anim:setPosition(redGift:getContentSize().width/2, redGift:getContentSize().height/2)

    local clipNode = cc.ClippingNode:create()   
    clipNode:setInverted(false)   

    local mask = cc.Sprite:createWithSpriteFrameName("guil_red_zuanshi.png")  --遮罩
    mask:setPosition(cc.p(redGift:getContentSize().width/2, redGift:getContentSize().height/2-4))   
    mask:setAnchorPoint(0.5, 0.5)
    clipNode:setStencil(mask)  
    clipNode:setAlphaThreshold(0.1)
    clipNode:addChild(anim)  
    clipNode:setAnchorPoint(cc.p(0, 0))
    clipNode:setPosition(0, 0)
    clipNode:setName("redGiftAnim")
    redGift:addChild(clipNode, 2)
end

-- function GuildRedSysLayer:receiveRed(redData)
--     -- local param = {}
--     -- if index == 1 then
--     --     print("黄金红包")
--     -- elseif index == 2 then
--     --     print("钻石红包")
--     -- elseif index == 3 then
--     --     print("宝物红包")
--     -- end
--     local param = {redId = redData.redId}
--     self:robGuildRed(param)
-- end

-- 抢红包
function GuildRedSysLayer:robGuildRed(redData)
    if redData.robRed == 0 then
        self._serverMgr:sendMsg("GuildRedServer", "robGuildRed", {redId = redData.redId}, true, {}, function (result)
            -- redData.robRed = 1
            self:robGuildRedFinish(result)
        end, function(errorId)
            if tonumber(errorId) == 2803 then
                self._viewMgr:showTip("你已经抢过该红包了")
            elseif tonumber(errorId) == 2803 then
                self._viewMgr:showTip("该红包已被抢光")
            elseif tonumber(errorId) == 2802 then
                self._viewMgr:showTip("每日21点红包刷新")
            end
        end)
    else
        self._serverMgr:sendMsg("GuildRedServer", "getGuildRedRobRank", {redId = redData.redId}, true, {}, function (result)
            if result == nil then 
                return 
            end
            local redRank = self:checkData(result,redData.best)
            self:robProcessData(redRank, redData)

            self._viewMgr:showDialog("guild.redgift.GuildRedRobRankDialog", {redData = redData, redRank = redRank, redType = 1})
        end)
    end
end 

function GuildRedSysLayer:checkData(result,best)
    print("best",best)
    if #result <= 1 or not best or best == "" then
        return result
    end
    local data = result[1]
    local findIndex
    for i=2,#result do 
        if result[i].name == best then
            findIndex = i
        end
    end
    if findIndex then
        result[1] = result[findIndex]
        result[findIndex] = data
    end
    dump(result,"resultresultresultresultresult",10)
    return result
end

function GuildRedSysLayer:robProcessData(data, redData)
    for i,v in ipairs(data) do
        v.rank = i 
        v.gemValue = v.score
        if redData["best"] == v["name"] then
            v.rank = 0
        end
    end
    if table.nums(data) <= 1 then
        return
    end
    local sortFunc = function(a, b) 
        local acheck = a.score
        local bcheck = b.score
        if acheck == nil then
            return
        end
        if bcheck == nil then
            return
        end
        if acheck ~= bcheck then
            return acheck > bcheck
        end
    end

    table.sort(data, sortFunc)
    -- return tempData
end

function GuildRedSysLayer:robGuildRedFinish(result)
    if result == nil then 
        return 
    end

    self._viewMgr:lock(-1)

    self._viewMgr:showDialog("guild.redgift.GuildEffectLayer", {data = result, callback = function()
        self._viewMgr:unlock()
        DialogUtils.showGiftGet({gifts = result["reward"]})
        self:reflashUI()
        end}, true)

    self._modelMgr:getModel("GuildRedModel"):updateRedTipButtle()

end

-- 获取红包数据
function GuildRedSysLayer:getGuildRed()
    print("=getGuildRed=====getGuildRed========")
    self._serverMgr:sendMsg("GuildRedServer", "getGuildRed", {}, true, {}, function (result)
        self:getGuildRedFinish(result)
    end)
end 

function GuildRedSysLayer:getGuildRedFinish(result)
    if result == nil then 
        return 
    end
    -- dump(result, "result==============")
    self:reflashUI()
end

return GuildRedSysLayer
