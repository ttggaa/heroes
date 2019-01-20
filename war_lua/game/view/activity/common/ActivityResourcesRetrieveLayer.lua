--[[
    Filename:    ActivityResourcesRetrieveLayer.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2017-06-14 20:06:29
    Description: File description
--]]

local ActivityResourcesRetrieveLayer = class("ActivityResourcesRetrieveLayer", 
    require("game.view.activity.common.ActivityCommonLayer"))

function ActivityResourcesRetrieveLayer:ctor()
    ActivityResourcesRetrieveLayer.super.ctor(self)
    self._activityModel = self._modelMgr:getModel("ActivityModel")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("asset/ui/acRetrieve.plist", "asset/ui/acRetrieve.png")
    self._userModel = self._modelMgr:getModel("UserModel")
end

function ActivityResourcesRetrieveLayer:onDestroy()
    ActivityResourcesRetrieveLayer.super.onDestroy(self)
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("asset/ui/acRetrieve.plist")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("asset/ui/acRetrieve.png")
end

function ActivityResourcesRetrieveLayer:getAsyncRes()
    return {
    {"asset/ui/acRetrieve.plist","asset/ui/acRetrieve.png"}
}
end

function ActivityResourcesRetrieveLayer:onAdd()
    cc.SpriteFrameCache:getInstance():addSpriteFrames("asset/ui/acRetrieve.plist", "asset/ui/acRetrieve.png")
end

function ActivityResourcesRetrieveLayer:onTop()
    
end

function ActivityResourcesRetrieveLayer:onInit()
    self:refreshUI()
end

function ActivityResourcesRetrieveLayer:refreshUI()
    
    self:refreshGold()
    self:refreshTeamExp()
    self:refreshExp()

end

function ActivityResourcesRetrieveLayer:refreshGold()
    --黄金
    local data = self._activityModel:getRetrieveData()
    dump(data)
    local res1 = self:getUI("bg.bottomBg.res1")
    local totalGold = math.max(0,data.gGold) + math.max(0,data.gGold2)
    if data.gGold2 <= 0 then
        totalGold = 0
    end
    res1:getChildByFullName("num"):setString(totalGold)
    local canBack1 = res1:getChildByFullName("canBack")
    canBack1:setVisible(false)
    local collecting1 = res1:getChildByFullName("collecting")
    collecting1:setVisible(false)
    local collecting = res1:getChildByFullName("collecting1")
    collecting:setVisible(false)
    -- if res1:getChildByName("shalou") then
    --     res1:removeChildByName("shalou")
    -- end
    if data.gGold ~= 0 or data.gGold2 ~= 0 then
        canBack1:setVisible(true)
        local numFree = canBack1:getChildByFullName("numFree")
        local numGem = canBack1:getChildByFullName("numGem")
        local haveGet1 = canBack1:getChildByFullName("haveGet1")
        haveGet1:setVisible(false)
        local haveGet2 = canBack1:getChildByFullName("haveGet2")
        haveGet2:setVisible(false)
        local freeGet = canBack1:getChildByFullName("freeGet")
        freeGet:setVisible(false)
        local gemGet = canBack1:getChildByFullName("gemGet")
        gemGet:setVisible(false)
        numFree:setString(self:getUnit(data.gGold))
        local per2 = canBack1:getChildByFullName("per2")
        if data.gGold > 0 and data.gGold2 > 0 then
            freeGet:setVisible(true)
            numGem:setString(self:getUnit(data.gGold2 + data.gGold))
            self:registerClickEvent(freeGet,function()
                self:onGet("gold","free")
            end)
            if per2 then
                per2:setString("(100%)")
            end
        elseif data.gGold < 0 then
            haveGet1:setVisible(true)
            numGem:setString(self:getUnit(data.gGold2))
            if per2 then
                per2:setString("(50%)")
            end
        else
            numGem:setString(self:getUnit(data.gGold2))
            if per2 then
                per2:setString("(50%)")
            end
        end
        if data.gGold2 > 0 then
            gemGet:setVisible(true)
            local cost = data.goldCost
            if cost < 10 then
                gemGet:setTitleText(" " .. cost .. "找回")
            elseif cost >=10 and cost <= 99 then
                gemGet:setTitleText("  " .. cost .. "找回")
            elseif cost >=100 and cost <= 999 then
                gemGet:setTitleText("  " .. cost .. "找回")
            else
                gemGet:setTitleText("  " .. cost .. "找回")
            end
            self:registerClickEvent(gemGet,function()
                self:onGet("gold","gem",cost)
            end)
        else
            haveGet2:setVisible(true)
        end
    else
        collecting:setString("请再接再厉哦！")
        collecting1:setVisible(true)
        collecting:setVisible(true)
        -- local mc2 = mcMgr:createViewMC("shalou_mfhanghaifengweitexiao", true, false)
        -- mc2:setName("shalou")
        -- mc2:setScale(1.2)
        -- mc2:setPosition(40, 90)
        -- res1:addChild(mc2)
    end
end

function ActivityResourcesRetrieveLayer:refreshTeamExp()
    --兵团经验
    local data = self._activityModel:getRetrieveData()
    local res2 = self:getUI("bg.bottomBg.res2")
    local totalTeamExp = math.max(0,data.gtExp) + math.max(0,data.gtExp2)
    if data.gtExp2 <= 0 then
        totalTeamExp = 0
    end
    res2:getChildByFullName("num"):setString(totalTeamExp)
    local canBack1 = res2:getChildByFullName("canBack")
    canBack1:setVisible(false)
    local collecting1 = res2:getChildByFullName("collecting")
    collecting1:setVisible(false)
    local collecting = res2:getChildByFullName("collecting1")
    collecting:setVisible(false)
    -- if res2:getChildByName("shalou") then
    --     res2:removeChildByName("shalou")
    -- end
    if data.gtExp ~= 0 or data.gtExp2 ~= 0 then
        canBack1:setVisible(true)
        local numFree = canBack1:getChildByFullName("numFree")
        local numGem = canBack1:getChildByFullName("numGem")
        local haveGet1 = canBack1:getChildByFullName("haveGet1")
        haveGet1:setVisible(false)
        local haveGet2 = canBack1:getChildByFullName("haveGet2")
        haveGet2:setVisible(false)
        local freeGet = canBack1:getChildByFullName("freeGet")
        freeGet:setVisible(false)
        local gemGet = canBack1:getChildByFullName("gemGet")
        gemGet:setVisible(false)
        numFree:setString(self:getUnit(data.gtExp))
        local per2 = canBack1:getChildByFullName("per2")
        if data.gtExp > 0 and data.gtExp2 > 0 then
            freeGet:setVisible(true)
            numGem:setString(self:getUnit(data.gtExp2 + data.gtExp))
            self:registerClickEvent(freeGet,function()
                self:onGet("teamExp","free")
            end)
            if per2 then
                per2:setString("(100%)")
            end
        elseif data.gtExp < 0 then
            haveGet1:setVisible(true)
            numGem:setString(self:getUnit(data.gtExp2))
            if per2 then
                per2:setString("(50%)")
            end
        else
            numGem:setString(self:getUnit(data.gtExp2))
            if per2 then
                per2:setString("(50%)")
            end
        end
        if data.gtExp2 > 0 then
            gemGet:setVisible(true)
            local cost = data.tExpCost
            if cost < 10 then
                gemGet:setTitleText(" " .. cost .. "找回")
            elseif cost >=10 and cost <= 99 then
                gemGet:setTitleText("  " .. cost .. "找回")
            elseif cost >=100 and cost <= 999 then
                gemGet:setTitleText("  " .. cost .. "找回")
            else
                gemGet:setTitleText("  " .. cost .. "找回")
            end
            -- gemGet:setTitleText("   " .. cost .. "找回")
            self:registerClickEvent(gemGet,function()
                self:onGet("teamExp","gem",cost)
            end)
        else
            haveGet2:setVisible(true)
        end
    else
        collecting:setString("请再接再厉哦！")
        collecting1:setVisible(true)
        collecting:setVisible(true)
        -- local mc2 = mcMgr:createViewMC("shalou_mfhanghaifengweitexiao", true, false)
        -- mc2:setName("shalou")
        -- mc2:setScale(1.2)
        -- mc2:setPosition(40, 90)
        -- res2:addChild(mc2)
    end
end

function ActivityResourcesRetrieveLayer:refreshExp()
    --经验
    local data = self._activityModel:getRetrieveData()
    local res3 = self:getUI("bg.bottomBg.res3")
    local totalExp = math.max(0,data.gExp) + math.max(0,data.gExp2)
    if data.gExp2 <= 0 then
        totalExp = 0
    end
    res3:getChildByFullName("num"):setString(totalExp)
    local canBack1 = res3:getChildByFullName("canBack")
    canBack1:setVisible(false)
    local collecting1 = res3:getChildByFullName("collecting")
    collecting1:setVisible(false)
    local collecting = res3:getChildByFullName("collecting1")
    collecting:setVisible(false)
    local per2 = canBack1:getChildByFullName("per2")
    -- if res3:getChildByName("shalou") then
    --     res3:removeChildByName("shalou")
    -- end
    if data.gExp ~= 0 or data.gExp2 ~= 0 then
        canBack1:setVisible(true)
        local numFree = canBack1:getChildByFullName("numFree")
        local numGem = canBack1:getChildByFullName("numGem")
        local haveGet1 = canBack1:getChildByFullName("haveGet1")
        haveGet1:setVisible(false)
        local haveGet2 = canBack1:getChildByFullName("haveGet2")
        haveGet2:setVisible(false)
        local freeGet = canBack1:getChildByFullName("freeGet")
        freeGet:setVisible(false)
        local gemGet = canBack1:getChildByFullName("gemGet")
        gemGet:setVisible(false)
        numFree:setString(self:getUnit(data.gExp))
        if data.gExp > 0 and data.gExp2 > 0 then
            freeGet:setVisible(true)
            numGem:setString(self:getUnit(data.gExp2 + data.gExp))
            self:registerClickEvent(freeGet,function()
                self:onGet("Exp","free")
            end)
            if per2 then
                per2:setString("(100%)")
            end
        elseif data.gExp < 0 then 
            haveGet1:setVisible(true)
            numGem:setString(self:getUnit(data.gExp2))
            if per2 then
                per2:setString("(50%)")
            end
        else
            numGem:setString(self:getUnit(data.gExp2))
            if per2 then
                per2:setString("(50%)")
            end
        end
        if data.gExp2 > 0 then
            gemGet:setVisible(true)
            local cost = data.expCost
            if cost < 10 then
                gemGet:setTitleText(" " .. cost .. "找回")
            elseif cost >=10 and cost <= 99 then
                gemGet:setTitleText("  " .. cost .. "找回")
            elseif cost >=100 and cost <= 999 then
                gemGet:setTitleText("  " .. cost .. "找回")
            else
                gemGet:setTitleText("  " .. cost .. "找回")
            end
            -- gemGet:setTitleText("   " .. cost .. "找回")
            self:registerClickEvent(gemGet,function()
                self:onGet("Exp","gem",cost)
            end)
        else
            haveGet2:setVisible(true)
        end
    else
        collecting:setString("请再接再厉哦！")
        collecting1:setVisible(true)
        collecting:setVisible(true)
        -- local mc2 = mcMgr:createViewMC("shalou_mfhanghaifengweitexiao", true, false)
        -- mc2:setName("shalou")
        -- mc2:setScale(1.2)
        -- mc2:setPosition(40, 90)
        -- res3:addChild(mc2)
    end
end

function ActivityResourcesRetrieveLayer:onGet(reType,getType,costGem)
    --钻石判断
    if costGem then
        local player = self._modelMgr:getModel("UserModel"):getData()
        local gemHaveCount = player.gem
        if costGem > gemHaveCount then
            DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function()
                self._viewMgr:showView("vip.VipView", {viewType = 0})
            end})
            return
        end
    end


    if reType == "gold" then
        if getType == "free" then
            print("免费领黄金")
            self:getUserGold(0)
        else
            print("钻石领黄金")
            self:getUserGold(1)
        end
    elseif reType == "teamExp" then
        if getType == "free" then
            print("免费领兵团经验")
            self:getUserTexp(0)
        else
            print("钻石领兵团经验")
            self:getUserTexp(1)
        end
    elseif reType == "Exp" then
        if getType == "free" then
            print("免费领经验")
            self:getUserExp(0)
        else
            print("钻石领经验")
            self:getUserExp(1)
        end
    end
end

function ActivityResourcesRetrieveLayer:getUserGold(type_)
    self._serverMgr:sendMsg("OffLineServer", "receiveUserGold", {type = type_}, true, {}, function(result)
        if not result then return end
        dump(result)
        DialogUtils.showGiftGet({
            hide = self,
            gifts = result.reward,
            title = "恭喜获得",
            callback = function()
                
        end})
        if result.d and result.d.offLine then
            self._activityModel:updateRetrieveData(result.d.offLine)
            result.d.offLine = nil
        end
        self:refreshUI()
    end)
end

function ActivityResourcesRetrieveLayer:getUserExp(type_)
    local _userModel = self._userModel
    local _viewMgr = self._viewMgr
    self._serverMgr:sendMsg("OffLineServer", "receiveUserExp", {type = type_}, true, {}, function(result)
        if not result then return end
        -- dump(result,"aaa",10)
        DialogUtils.showGiftGet({
            hide = self,
            gifts = result.reward,
            title = "恭喜获得",
            callback = function()
                local data = result.d
                if data and data.lvl then
                    local lastLvl = _userModel:getLastLvl()
                    local lastPhysical = _userModel:getLastPhysical()
                    local userLevel = _userModel:getData().lvl
                    local userphysic = _userModel:getData().physcal
                    _viewMgr:checkLevelUpReturnMain(data.lvl)
                    _viewMgr:showDialog("global.DialogUserLevelUp", { preLevel = lastLvl, level = data.lvl, prePhysic = lastPhysical, physic = userphysic }, true, nil, nil, false)
                elseif data and data.plvl then
                    local lastPLvl = _userModel:getLastPLvl()
                    local lastPTalentPoint = _userModel:getLastPTalentPoint()
                    local plvl = _userModel:getData().plvl or 1
                    local pTalentPoint = _userModel:getData().pTalentPoint or lastPTalentPoint
                    ViewManager:getInstance():showDialog("global.DialogUserParagonLevelUp", {oldPlvl = lastPLvl, plvl = plvl, pTalentPoint = (pTalentPoint - lastPTalentPoint)}, true, nil, nil, false)
                end 
        end})
        if result.d and result.d.offLine then
            self._activityModel:updateRetrieveData(result.d.offLine)
            result.d.offLine = nil
        end
        self:refreshUI()
    end)
end

function ActivityResourcesRetrieveLayer:getUserTexp(type_)
    self._serverMgr:sendMsg("OffLineServer", "receiveUserTexp", {type = type_}, true, {}, function(result)
        if not result then return end
        dump(result)
        DialogUtils.showGiftGet({
            hide = self,
            gifts = result.reward,
            title = "恭喜获得",
            callback = function()
                
        end})
        if result.d and result.d.offLine then
            self._activityModel:updateRetrieveData(result.d.offLine)
            result.d.offLine = nil
        end
        self:refreshUI()
    end)
end

function ActivityResourcesRetrieveLayer:getUnit(num)
    local num = math.abs(num)
    if num < 10000 then
        return num
    else
        local a,b = math.modf(num/10000)
        b = math.floor(b*10)
        local result = (a+b/10) .. "万"
        return result
        -- return string.format("%.1f万",num/10000)
    end
end

function ActivityResourcesRetrieveLayer:getCostbyCount(count)
    return 200
end


function ActivityResourcesRetrieveLayer:showRewardDialog()
    local params = clone(self._activityReward)
    DialogUtils.showGiftGet({gifts = params})
end

return ActivityResourcesRetrieveLayer