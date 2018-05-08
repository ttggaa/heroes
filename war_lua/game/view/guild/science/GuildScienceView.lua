--[[
    Filename:    GuildScienceView.lua
    Author:      <qiaohuan@GuildScienceView.com>
    Datetime:    2016-05-04 10:41:13
    Description: File description
--]]

-- 联盟捐献选择
local GuildScienceView = class("GuildScienceView", BaseView, require("game.view.guild.GuildBaseView"))

local imageType = {1,3,4,2}

function GuildScienceView:ctor(data)
    GuildScienceView.super.ctor(self)
    self.initAnimType = 3
end

function GuildScienceView:onInit()
    self._modelMgr:getModel("GuildModel"):setQuitAlliance(false)
    self:listenReflash("UserModel", self.reflashQuitAlliance)

    self._userModel = self._modelMgr:getModel("UserModel")
    self._guildModel = self._modelMgr:getModel("GuildModel")
    self._playerTodayModel = self._modelMgr:getModel("PlayerTodayModel")

    self._todayExp = self:getUI("bg.titleBg.todayExp")
    self._todayExpalready = self:getUI("bg.titleBg.todayExpalready")
    self._expBar = self:getUI("bg.titleBg.expBg.expBar")
    self._expBg = self:getUI("bg.titleBg.expBg")

    self._guildExp = self:getUI("bg.leftPanel.lvlBarBg.iconBg")
    self._guildLevel = self:getUI("bg.leftPanel.allianceLvl")
    self._guildName = self:getUI("bg.leftPanel.allianceName")
    self._timesValue = self:getUI("bg.leftPanel.timesValue")

    -- tip
    local lvlBarBg = self:getUI("bg.leftPanel.lvlBarBg")
    local closeTip = self:getUI("closeTip")
    local tip = self:getUI("bg.tip")
    local tip1 = self:getUI("bg.tip1")
    local tip2 = self:getUI("bg.tip2")
    local tipsBtn = self:getUI("bg.leftPanel.tipBtn")
    closeTip:setVisible(false)
    tip:setVisible(false)
    tip1:setVisible(false)
    tip2:setVisible(false)

    self:registerClickEvent(tipsBtn, function()
        self:showGuildTip()
        closeTip:setVisible(true)
    end)

    self:registerClickEvent(self._timesValue, function ()
        if not self._testLogCount then
            self._testLogCount = 0
        end
        if self._testLogCount >= 10 then
            self._testLogCount = 0
            local data,tem,cur = self._userModel:getRoleAlliance(true)
            local last = tostring(data.lastTime) or "-1"
            local dtimes = tostring(data.dTimes) or "-1"
            local tem_ = tostring(tem) or "-1"
            local cur_ = tostring(cur) or "-1"
            self._viewMgr:showTip("lastTime:" .. last .. "dtimes:" .. dtimes .. "tem:" .. tem_ .. "cur_:" .. cur_)
        end
        self._testLogCount = self._testLogCount + 1
    end)

    self:registerClickEvent(closeTip, function()
        closeTip:setVisible(false)
        tip:setVisible(false)
        tip1:setVisible(false)
        tip2:setVisible(false)
    end)

    local expLab = self:getUI("bg.tip.allianceExpBg.expLab")
    expLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    for i=1,3 do
        local reward = self:getUI("bg.titleBg.award" .. i)
        local award = self:getUI("bg.titleBg.award" .. i .. ".award")
        -- award:setVisible(false)
        -- local rewardMc = mcMgr:createViewMC("guang_boxlight", true)
        -- rewardMc:setPlaySpeed(1, true)
        -- reward:addChild(rewardMc, 100)
        -- rewardMc:setPosition(cc.p(reward:getContentSize().width*0.5, reward:getContentSize().height*0.5))
        -- rewardMc:setName("rewardMc")
        local rewardMc = mcMgr:createViewMC("baoxiang" .. i .. "_baoxiang", true, false)
        rewardMc:setVisible(false)
        reward:addChild(rewardMc, 100)
        rewardMc:setPosition(cc.p(reward:getContentSize().width*0.5-3, reward:getContentSize().height*0.5+5))
        rewardMc:setName("rewardMc")

        local baoxiangguang = mcMgr:createViewMC("baoxiangguang1_baoxiang", true, false)
        baoxiangguang:setVisible(false)
        reward:addChild(baoxiangguang, 100)
        baoxiangguang:setPosition(cc.p(reward:getContentSize().width*0.5-3, reward:getContentSize().height*0.5+5))
        baoxiangguang:setName("baoxiangguang")
    end

    self._detailCell = self:getUI("detailCell")
    self._detailCell:setVisible(false)
    for i=1,4 do
        local scienceIcon = self._detailCell:getChildByFullName("scienceNum" .. i )
        scienceIcon:setAnchorPoint(0.5,0.5)
        scienceIcon:setPosition(scienceIcon:getPositionX()+40,scienceIcon:getPositionY()+42.5)
        scienceIcon:setScaleAnim(true)
    end
    self._technology = tab.technologyBase
    self:listenReflash("GuildModel", self.reflashUI)

    self:addTableView()

    self._playAnimBg = self:getUI("bg.bg")
    self._playAnimBgOffX = 0
    self._playAnimBgOffY = -24

    local bg = self:getUI("bg.tableViewBg")
    self.upMc = mcMgr:createViewMC("youjiantou_teamnatureanim", true, false)
    self.upMc:setPosition(cc.p(bg:getContentSize().width-40, 300))
    self.upMc:setRotation(-90)
    bg:addChild(self.upMc,20)
    self.upMc:setVisible(false)

    self.bottomMc = mcMgr:createViewMC("youjiantou_teamnatureanim", true, false)
    self.bottomMc:setPosition(cc.p(bg:getContentSize().width-35, 40))
    self.bottomMc:setRotation(90)
    bg:addChild(self.bottomMc,20)
    self.bottomMc:setVisible(false)
end

function GuildScienceView:updateTip()
    local name = self:getUI("bg.tip.name")
    local level = self:getUI("bg.tip.level")
    local todayExpValue = self:getUI("bg.tip.todayExpValue")
    local allianceExpBar = self:getUI("bg.tip.allianceExpBg.allianceExpBar")
    local expLab = self:getUI("bg.tip.allianceExpBg.expLab")

    local guildScience = self._guildModel:getGuildScience()
    local scienceBase = self._guildModel:getGuildScienceBase()

    local allianceD = self._guildModel:getAllianceDetail()

    -- dump(allianceD, "allianceD-=======")
    -- dump(scienceBase, "scienceBase-=======")
    -- dump(guildScience, "guildScience-=======")

    local guildLevelTab = tab:GuildLevel(scienceBase.level)

    name:setString(allianceD.name)
    level:setString("Lv. " .. scienceBase.level)
    todayExpValue:setString(scienceBase.todayExp .. "/" .. guildLevelTab.limit)
    local expMax = guildLevelTab.exp
    local scienceExp = scienceBase.exp

    local sceStr = scienceBase.exp .. "/" .. guildLevelTab.exp
    local nextLevel = scienceBase.level + 1
    if expMax == 999999 then
        sceStr = "Max"
        expMax = 1
        scienceExp = 2
        nextLevel = scienceBase.level
    end
    
    expLab:setString(sceStr)
    local expValue = scienceExp/expMax * 100
    allianceExpBar:setPercent(expValue)

    local iconBg = self:getUI("bg.tip.iconBg")
    local avatarIcon = iconBg:getChildByName("avatarIcon")
    local param = {flags = allianceD.avatar1 or 101, logo = allianceD.avatar2 or 201}

    if not avatarIcon then
        avatarIcon = IconUtils:createGuildLogoIconById(param)
        avatarIcon:setName("avatarIcon")
        avatarIcon:setScale(0.95)
        avatarIcon:setPosition(-3, 0)
        iconBg:addChild(avatarIcon,2)
    else
        IconUtils:updateGuildLogoIconByView(avatarIcon, param)
    end

    local name = self:getUI("bg.tip.baoxiangTip1.name")
    local des = self:getUI("bg.tip.baoxiangTip1.des")
    local itemBg = self:getUI("bg.tip.baoxiangTip1.itemBg")
    
    local itemId = guildLevelTab.gift
    local itemData = tab:Tool(itemId)
    local itemIcon = IconUtils:createItemIconById({itemId = itemId, itemData = itemData, effect = false})
    itemIcon:setSwallowTouches(true)
    itemIcon:setAnchorPoint(cc.p(0,0))
    itemIcon:setVisible(true)
    itemBg:addChild(itemIcon)
    local itemNormalScale = 80/itemIcon:getContentSize().width
    itemIcon:setScale(itemNormalScale)

    if itemData.name then
        name:setString(lang(itemData.name))
    end
    if itemData.color then
        name:setColor(UIUtils.colorTable["ccUIBaseColor" .. itemData.color])
    end
    des:setString(lang(itemData.des))


    local name = self:getUI("bg.tip.baoxiangTip2.name")
    local des = self:getUI("bg.tip.baoxiangTip2.des")
    local itemBg = self:getUI("bg.tip.baoxiangTip2.itemBg")
    local guildLevelTab = tab:GuildLevel(nextLevel)
    
    local itemId = guildLevelTab.gift
    local itemData = tab:Tool(itemId)
    local itemIcon = IconUtils:createItemIconById({itemId = itemId, itemData = itemData, effect = false})
    itemIcon:setSwallowTouches(true)
    itemIcon:setAnchorPoint(cc.p(0,0))
    itemIcon:setVisible(true)
    itemBg:addChild(itemIcon)
    local itemNormalScale = 80/itemIcon:getContentSize().width
    itemIcon:setScale(itemNormalScale)

    if itemData.name then
        name:setString(lang(itemData.name))
    end
    if itemData.color then
        name:setColor(UIUtils.colorTable["ccUIBaseColor" .. itemData.color])
    end
    des:setString(lang(itemData.des))

end

function GuildScienceView:showGuildTip()
    local tip1 = self:getUI("bg.tip")
    local tip2 = self:getUI("bg.tip2")
    local scienceBase = self._guildModel:getGuildScienceBase()
    local guildLevelTab = tab:GuildLevel(scienceBase.level)
    local expMax = guildLevelTab.exp
    if expMax == 999999 then
        self:updateTip2()
        tip2:setVisible(true)
        tip1:setVisible(false)
    else
        self:updateTip()
        tip2:setVisible(false)
        tip1:setVisible(true)
    end
end

function GuildScienceView:updateTip2()
    local name = self:getUI("bg.tip2.name")
    local level = self:getUI("bg.tip2.level")
    local todayExpValue = self:getUI("bg.tip2.todayExpValue")
    local allianceExpBar = self:getUI("bg.tip2.allianceExpBg.allianceExpBar")
    local expLab = self:getUI("bg.tip2.allianceExpBg.expLab")

    local guildScience = self._guildModel:getGuildScience()
    local scienceBase = self._guildModel:getGuildScienceBase()
    local allianceD = self._guildModel:getAllianceDetail()

    local guildLevelTab = tab:GuildLevel(scienceBase.level)

    name:setString(allianceD.name)
    level:setString("Lv. " .. scienceBase.level)
    todayExpValue:setString(scienceBase.todayExp .. "/" .. guildLevelTab.limit)
    local expMax = guildLevelTab.exp
    local scienceExp = scienceBase.exp

    local sceStr = scienceBase.exp .. "/" .. guildLevelTab.exp
    local nextLevel = scienceBase.level + 1
    if expMax == 999999 then
        sceStr = "Max"
        expMax = 1
        scienceExp = 2
        nextLevel = scienceBase.level
    end
    
    expLab:setString(sceStr)
    expLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local expValue = scienceExp/expMax * 100
    allianceExpBar:setPercent(expValue)

    local iconBg = self:getUI("bg.tip2.iconBg")
    local avatarIcon = iconBg:getChildByName("avatarIcon")
    local param = {flags = allianceD.avatar1 or 101, logo = allianceD.avatar2 or 201}

    if not avatarIcon then
        avatarIcon = IconUtils:createGuildLogoIconById(param)
        avatarIcon:setName("avatarIcon")
        avatarIcon:setScale(0.95)
        avatarIcon:setPosition(-3, 0)
        iconBg:addChild(avatarIcon,2)
    else
        IconUtils:updateGuildLogoIconByView(avatarIcon, param)
    end

    local name = self:getUI("bg.tip2.baoxiangTip1.name")
    local des = self:getUI("bg.tip2.baoxiangTip1.des")
    local itemBg = self:getUI("bg.tip2.baoxiangTip1.itemBg")
    
    local itemId = guildLevelTab.gift
    local itemData = tab:Tool(itemId)
    local itemIcon = IconUtils:createItemIconById({itemId = itemId, itemData = itemData, effect = false})
    itemIcon:setSwallowTouches(true)
    itemIcon:setAnchorPoint(cc.p(0,0))
    itemIcon:setVisible(true)
    itemBg:addChild(itemIcon)
    local itemNormalScale = 80/itemIcon:getContentSize().width
    itemIcon:setScale(itemNormalScale)

    if itemData.name then
        name:setString(lang(itemData.name))
    end
    if itemData.color then
        name:setColor(UIUtils.colorTable["ccUIBaseColor" .. itemData.color])
    end
    des:setString(lang(itemData.des))
end


--@type_ 1 等级最大 2 等级上限
function GuildScienceView:updateTip1(data, indexId,type_, percent)
    -- dump(data)
    local name = self:getUI("bg.tip1.name")
    local richTextBg = self:getUI("bg.tip1.richTextBg")
    local technologIcon = self:getUI("bg.tip1.scaturP.technologIcon")
    local level = self:getUI("bg.tip1.scaturP.level")
    local scaturP = self:getUI("bg.tip1.scaturP")
    local maxLevel = self:getUI("bg.tip1.tipBg.Image_64")
    local limitLevel = self:getUI("bg.tip1.limit_level")
    local realLevel
    if type_ == 1 then
        maxLevel:setVisible(true)
        limitLevel:setVisible(false)
        realLevel = data.levelmax
    else
        maxLevel:setVisible(false)
        limitLevel:setVisible(true)
        realLevel = data.curLevel
    end

    name:setString(lang(data.name))
    level:setString(realLevel)
    level:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    technologIcon:loadTexture("allianceScicene_icon" .. data.id .. ".png", 1)

    -- local technologyBar = scaturP:getChildByName("technologyBar")
    -- if not technologyBar then
    --     local sp = cc.Sprite:createWithSpriteFrameName("allianceScicene_progressBar" .. indexId .. ".png")  
    --     sp:setPosition(scaturP:getContentSize().width*0.5-2, scaturP:getContentSize().height*0.5)
    --     sp:setName("technologyBar")  
    --     sp:setRotation(180)
    --     scaturP:addChild(sp, 5)
    -- else
    --     technologyBar:setSpriteFrame("allianceScicene_progressBar" .. indexId .. ".png")
    -- end
    local _percent = type_ == 2 and percent or 100
    local technologyBar = scaturP:getChildByName("technologyBar")
    local imageNum = imageType[indexId] or 1
    if not technologyBar then
        local sp = cc.Sprite:createWithSpriteFrameName("allianceScicene_progressBar" .. imageNum .. ".png")  
        technologyBar = cc.ProgressTimer:create(sp)
        technologyBar:setName("technologyBar")   
        technologyBar:setPosition(scaturP:getContentSize().width*0.5-1, scaturP:getContentSize().height*0.5)
        technologyBar:setPercentage(_percent)
        technologyBar:setRotation(180)
        scaturP:addChild(technologyBar, 5)
    else
        local sp1 = cc.Sprite:createWithSpriteFrameName("allianceScicene_progressBar" .. imageNum .. ".png")  
        technologyBar:setSprite(sp1)
        technologyBar:setPercentage(0)
        technologyBar:setPercentage(_percent)
    end

    local richTextStr = self:split(lang(data.show), realLevel)
    -- print("data.show : "..data.show)
    -- print("richTextStr : "..richTextStr)
    richTextStr = string.gsub(richTextStr, "3c2a1e", "ffeea0")
    if type_ == 2 then
        richTextStr = richTextStr .. "[][-][color=fae6c8,fontsize=20](提升联盟等级可以提高科技上限)[-]"
    end
    self:createRichText(richTextBg, richTextStr)
end

function GuildScienceView:split(str,reps)
    local des = string.gsub(str,"%b{}",function( lvStr )
        local str = string.gsub(lvStr,"%$level",reps)
        return loadstring("return " .. string.gsub(str, "[{}]", ""))()
    end)
    return des 
end

function GuildScienceView:createRichText(inview, str)
    if not inview then
        return
    end 
    local richText = inview:getChildByName("richText")
    if richText ~= nil then
        richText:removeFromParent()
    end
    if string.find(str, "color=") == nil then
        str = "[color=865c30]"..str.."[-]"
    end   
    richText = RichTextFactory:create(str, inview:getContentSize().width, inview:getContentSize().height)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(inview:getContentSize().width*0.5, inview:getContentSize().height*0.8 - richText:getInnerSize().height*0.5)
    richText:setName("richText")
    inview:addChild(richText)
end

-- function GuildScienceView:getScienceMinEXP()
--     local guildScience = self._guildModel:getGuildScience()
--     local minExpId = 1
--     local minExp = 10000
--     for k,v in pairs(tab.technologyChild) do
--         if not guildScience[tostring(k)] then
--             guildScience[tostring(k)] = {}
--             guildScience[tostring(k)].exp = 0
--             guildScience[tostring(k)].lvl = 1
--         end
--         local tempExp = guildScience[tostring(k)].exp
--         local templvl = guildScience[tostring(k)].lvl
--         templvl = templvl + 1
--         if (v["levelexp"][tonumber(templvl)] - tempExp) < minExp then
--             minExp = (v["levelexp"][templvl] - tempExp)
--             minExpId = k
--         end
--     end
--     -- print("minExpId========", minExpId, minExp)
--     return minExpId
-- end

function GuildScienceView:reflashUI()
    if self._inDonateDialog then
        return
    end
    -- self._tuijianId = self:getScienceMinEXP() or 1
    self._tuijianId = self._guildModel:getScienceMinEXP() or 1
    self._tableView:reloadData()

    self:updateData()

    -- -- 进度条
    -- local bg = self:getUI("bg")
    -- local sp = cc.Sprite:createWithSpriteFrameName("globalImageUI5_yilingqu.png")      
    -- local progress = cc.ProgressTimer:create(sp)
    -- progress:setPosition(cc.p(500,200))
    -- progress:setPercentage(12)
    -- progress:setRotation(180)
    -- progress:setZOrder(1)
    -- bg:addChild(progress)
end

function GuildScienceView:updateData()
    local guildScience = self._guildModel:getGuildScience()
    local scienceBase = self._guildModel:getGuildScienceBase()
    local allianceD = self._guildModel:getAllianceDetail()

    -- dump(allianceD, "allianceD-=======")
    -- dump(scienceBase, "scienceBase-=======",10)
    -- dump(guildScience, "guildScience-=======")
 
    local dayinfo = self._playerTodayModel:getData()

    local boxExp = {1500,3000,5000}
    for i=1,3 do
        local reward = self:getUI("bg.titleBg.award" .. i)
        local rewardMc = reward:getChildByName("rewardMc")
        local baoxiangguang = reward:getChildByName("baoxiangguang")
        if rewardMc then
            rewardMc:setVisible(false)
        end
        if baoxiangguang then
            baoxiangguang:setVisible(false)
        end

        local award = self:getUI("bg.titleBg.award" .. i .. ".award")
        if award then
            award:setVisible(true)
        end
        if dayinfo["day" .. (17+i)] == 1 then
            award:loadTexture("box_" .. i .. "_p.png", 1)
            self:registerClickEvent(reward, function()
            end)
        else
            award:loadTexture("box_" .. i .. "_n.png", 1)
            -- self:registerClickEvent(award, function()
            --     print("lingqu ===", i)
            --     local reward = self:getUI("bg.titleBg.reward" .. i)
            --     local sciRewardTab = tab:GuildContriReward(i)
            --     if scienceBase.todayExp >= sciRewardTab.condition then
            --         self:getDailyAward(i)
            --     else
            --         local param = clone(sciRewardTab.reward)
            --         param.viewType = 1
            --         DialogUtils.showGiftGet(param)
            --     end
            -- end)
            local sciRewardTab = tab:GuildContriReward(i)
            if scienceBase.todayExp >= sciRewardTab.condition then
                self:registerClickEvent(reward, function()
                    self:getDailyAward(i)
                end)
                if rewardMc then
                    rewardMc:setVisible(true)
                    award:setVisible(false)
                    rewardMc:play() --setVisible(true)
                end
                if baoxiangguang then
                    baoxiangguang:setVisible(true)
                end
            else
                self:registerClickEvent(reward, function()
                    local param = clone(sciRewardTab.reward)
                    param.viewType = 2
                    param.des = "今日联盟经验达到" .. boxExp[i] .. "可领取"
                    DialogUtils.showGiftGet(param)
                end)
            end
            -- reward:addChild(reward.rewardMc)
        end
    end

    local guildLevelTab = tab:GuildLevel(scienceBase.level)
    local expMax = guildLevelTab.exp
    local scienceExp = scienceBase.exp
    if expMax == 999999 then
        expMax = 1
        scienceExp = 2
    end
    local barValue = 4 + scienceExp / expMax * 90

    -- 进度条
    local lvlBarBg = self:getUI("bg.leftPanel.lvlBarBg")
    if not self._lvlBar then
        -- local lvlBarBg = self:getUI("bg.leftPanel.lvlBarBg")
        local sp = cc.Sprite:createWithSpriteFrameName("allianceScicene_img21.png")      
        self._lvlBar = cc.ProgressTimer:create(sp)
        self._lvlBar:setPosition(lvlBarBg:getContentSize().width*0.5, lvlBarBg:getContentSize().height*0.5)
        self._lvlBar:setPercentage(0)
        self._lvlBar:setRotation(180)
        lvlBarBg:addChild(self._lvlBar, 5)
    end
    self._lvlBar:setPercentage(barValue)

    -- qizi
    local avatarIcon = lvlBarBg:getChildByName("avatarIcon")
    local param = {flags = allianceD.avatar1 or 101, logo = allianceD.avatar2 or 201}
    if not avatarIcon then
        avatarIcon = IconUtils:createGuildLogoIconById(param)
        avatarIcon:setName("avatarIcon")
        avatarIcon:setPosition(cc.p(12, 23))

        local mask = cc.Sprite:create()
        mask:setSpriteFrame("globalImage_IconMaskCircle.png")
        mask:setScale(0.98)
        mask:setAnchorPoint(cc.p(0,0))
        mask:setPosition(cc.p(18, 38))

        local clipNode = cc.ClippingNode:create()
        clipNode:setInverted(false)
        clipNode:setStencil(mask)
        clipNode:setAlphaThreshold(0.1)
        clipNode:addChild(avatarIcon)
        clipNode:setName("clipNode")
        lvlBarBg:addChild(clipNode,2)
    else
        IconUtils:updateGuildLogoIconByView(avatarIcon, param)
    end

    self._guildLevel:setString(scienceBase.level)
    self._guildName:setString(allianceD.name)

    -- 次数
    local userGuildData = self._userModel:getRoleAlliance()
    local times = self._guildModel:getDonateTimes()
    if (times - userGuildData.dTimes) < 0 then
        self._timesValue:setString(0 .. "/" .. times)
    else
        self._timesValue:setString((times - userGuildData.dTimes) .. "/" .. times)
    end

    -- 今日经验
    self._todayExp:setString("/" .. guildLevelTab.limit)
    self._todayExpalready:setString(scienceBase.todayExp)
    self._todayExp:setPositionX(self._todayExpalready:getPositionX()+self._todayExpalready:getContentSize().width)
    print("sci============", scienceBase.todayExp, guildLevelTab.limit)
    local expBarValue = scienceBase.todayExp/guildLevelTab.limit*100
    -- local expBarValue = 1500/guildLevelTab.limit*100
    self._expBar:setPercent(expBarValue)

    local totalWidth = self._expBg:getContentSize().width
    local level = {1500,3000,5000}
    for i=1,3 do
        local award = self:getUI("bg.titleBg.award" .. i)
        -- local posX = tab:GuildContriReward(i)["condition"]*838/guildLevelTab.limit - 98   修改为均等分
        local posX = totalWidth*level[i]/guildLevelTab.limit-100
        award:setPositionX(posX)
        -- awardLab:setString(tab:GuildContriReward(i)["condition"])
    end
end

function GuildScienceView:getDailyAward(index)
    self._serverMgr:sendMsg("GuildServer", "getDailyAward", {id = index}, true, {}, function (result)
        DialogUtils.showGiftGet(result["rewards"])
        self:updateData()
    end)
end

--[[
用tableview实现
--]]
function GuildScienceView:addTableView()
    local tableViewBg = self:getUI("bg.tableViewBg")
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height))
    self._tableView:setDelegate()
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:registerScriptHandler(function(table, cell) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:registerScriptHandler(function(view) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._tableView:setBounceable(true)
    -- if self._tableView.setDragSlideable ~= nil then 
    --     self._tableView:setDragSlideable(true)
    -- end
    -- self._tableView:reloadData()
    tableViewBg:addChild(self._tableView)
end


-- 触摸时调用
function GuildScienceView:tableCellTouched(table,cell)
    -- self._viewMgr:showDialog("guild.GuildScienceDetailDialog", {detailData = nil})
    -- print("==========================", cell:getIdx())
end

-- cell的尺寸大小
function GuildScienceView:cellSizeForTable(table,idx) 
    local width = 632 
    local height = 126
    return height, width
end

function GuildScienceView:scrollViewDidScroll(view)
    self._inScrolling = view:isDragging()
    if self._inScrolling then
        self.upMc:setVisible(false)
        self.bottomMc:setVisible(false)
    else
        self._offsetY = view:getContentOffset().y
        if self._offsetY >= 0 then
            self.upMc:setVisible(true)
            self.bottomMc:setVisible(false)
        elseif self._offsetY <= view:minContainerOffset().y then
            self.bottomMc:setVisible(true)
            self.upMc:setVisible(false)
        else
            self.upMc:setVisible(true)
            self.bottomMc:setVisible(true)
        end
    end
    -- if self._offsetY
    -- print("self._offsetY",self._offsetY)
    -- local minY = view:
    -- if self._offsetY <= 

end

-- 创建在某个位置的cell
function GuildScienceView:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local param = self._technology[idx+1]
    local indexId = idx + 1
    if nil == cell then
        cell = cc.TableViewCell:new()
        local detailCell = self._detailCell:clone() 
        detailCell:setVisible(true)
        detailCell:setAnchorPoint(cc.p(0,0))
        detailCell:setPosition(cc.p(-2,0))
        detailCell:setName("detailCell")
        cell:addChild(detailCell)
        for i=1,4 do
            local tlevel = detailCell:getChildByFullName("scienceNum" .. i .. ".scaturP.level")
            tlevel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        end
    end

    local detailCell = cell:getChildByName("detailCell")
    if detailCell then
        self:updateCell(detailCell, param, indexId)
        detailCell:setSwallowTouches(false)
    end

    return cell
end

-- 返回cell的数量
function GuildScienceView:numberOfCellsInTableView(table)
    return #self._technology --table.nums(self._membersData)
end

function GuildScienceView:updateCell(inView, data, indexId)
    if not inView then
        return
    end
    local guildScience = self._guildModel:getGuildScience()

    -- 是否解锁
    local level = self._guildModel:getGuildScienceBase().level or 1
    local openLvl = inView:getChildByFullName("openLvl")
    openLvl:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor)
    local isOpen = false
    local guild_level = level
    if level >= data.limit then
        isOpen = true
        if openLvl then
            openLvl:setVisible(false)
        end
    else
        if openLvl then
            openLvl:setVisible(true)
            openLvl:setString("需联盟Lv." .. data.limit)
        end
    end
    -- dump(data.include)
    for i=1,4 do
        local donateBtn = inView:getChildByName("scienceNum" .. i)
        local lock = inView:getChildByFullName("scienceNum" .. i .. ".lock")
        local scaturP = inView:getChildByFullName("scienceNum" .. i .. ".scaturP")
        local tlevel = inView:getChildByFullName("scienceNum" .. i .. ".scaturP.level")
        local tmaxLevel = inView:getChildByFullName("scienceNum" .. i .. ".maxLevel")
        local ticon = inView:getChildByFullName("scienceNum" .. i .. ".scaturP.technologIcon")
        local tname = inView:getChildByFullName("scienceNum" .. i .. ".scienceName")
        local tuijian = inView:getChildByFullName("scienceNum" .. i .. ".tuijian")
        local limit_level = inView:getChildByFullName("scienceNum" .. i .. ".limit_level")



        if tuijian then
            tuijian:setVisible(false)
        end

        if limit_level then
            limit_level:setVisible(false)
        end

        if i <= table.nums(data.include) then
            -- local indexId = i
            local technology = tab:TechnologyChild(data.include[i])

            if tname then
                tname:setString(lang(technology.name))
                tname:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
            end
            
            if ticon then
                ticon:loadTexture("allianceScicene_icon" .. data.include[i] .. ".png", 1)
            end

            local level,exp
            if not guildScience[tostring(data.include[i])] then
                level = 1
                exp = 0
            else
                level = guildScience[tostring(data.include[i])].lvl + 1
                exp = guildScience[tostring(data.include[i])].exp
            end

            --是否达到联盟等级限制
            local BaseId = tab:TechnologyBase(indexId)["include"][i]
            local limit_guild_level = tab:TechnologyChild(tonumber(BaseId))["limit"][guild_level]
            -- limit_guild_level = 20

            if tlevel then
                tlevel:setString(level-1)
            end
            local barValue = 4
            if level > table.nums(technology.levelexp) then
                barValue = 100
            else
                barValue = 4 + (exp/technology.levelexp[level])*90
            end

            local technologyBar = scaturP:getChildByName("technologyBar")
            local imageNum = imageType[indexId] or 1
            if not technologyBar then
                local sp = cc.Sprite:createWithSpriteFrameName("allianceScicene_progressBar" .. imageNum .. ".png")  
                technologyBar = cc.ProgressTimer:create(sp)
                technologyBar:setName("technologyBar")   
                technologyBar:setPosition(scaturP:getContentSize().width*0.5-2, scaturP:getContentSize().height*0.5)
                technologyBar:setPercentage(0)
                technologyBar:setRotation(180)
                scaturP:addChild(technologyBar, 5)
            else
                local sp1 = cc.Sprite:createWithSpriteFrameName("allianceScicene_progressBar" .. imageNum .. ".png")  
                technologyBar:setSprite(sp1)
                technologyBar:setPercentage(0)
                technologyBar:setPercentage(barValue)
            end

            if tmaxLevel then
                tmaxLevel:setVisible(false)
            end

            local param = clone(technology)
            param.callback = function()
                self._inDonateDialog = false
                local tempOffset = self._tableView:getContentOffset()
                self:reflashUI()
                self._tableView:setContentOffset(tempOffset)
            end
            param.baseIndex = indexId

            param.childIndex = i

            donateBtn:setScaleAnim(true)
            self:registerClickEvent(donateBtn, function()
                print("lll=======捐献")
                self._inDonateDialog = true
                self._viewMgr:showDialog("guild.science.GuildScienceDonateDialog", param, true)
            end)
            if level > technology["levelmax"] then
                if tmaxLevel then
                    tmaxLevel:setVisible(true)
                end
                barValue = 100
                self:registerClickEvent(donateBtn, function()
                    -- self._viewMgr:showTip("科技已满级")
                    local closeTip = self:getUI("closeTip")
                    local tip1 = self:getUI("bg.tip1")

                    self:updateTip1(technology, indexId,1)
                    closeTip:setVisible(true)
                    tip1:setVisible(true)
                end)
            end
            technologyBar:setPercentage(barValue)
            local realValue = barValue

            -- print("tuijian_ID_____"..self._tuijianId.."______"..data.include[i])
            if self._tuijianId == data.include[i] then
                if tuijian then
                    tuijian:setVisible(true)
                end
            end
            donateBtn:setVisible(true)

            -- print("level"..level.."limit_guild_level"..limit_guild_level.."max"..technology["levelmax"])
            if level > limit_guild_level and level <= technology["levelmax"] then
                tuijian:setVisible(false)
                tmaxLevel:setVisible(false)
                limit_level:setVisible(true)
                -- tlevel:setColor(UIUtils.colorTable.ccUIBaseColor6)

                -- 上限时显示上限tips
                self:registerClickEvent(donateBtn, function()
                    local closeTip = self:getUI("closeTip")
                    local tip1 = self:getUI("bg.tip1")
                    technology.curLevel = level-1
                    self:updateTip1(technology, indexId,2, realValue)
                    closeTip:setVisible(true)
                    tip1:setVisible(true)
                end)
            end
        else
            donateBtn:setVisible(false)
        end

        if isOpen == false then
            if lock then
                lock:setVisible(true)
            end
            if scaturP then
                scaturP:setSaturation(-100)
            end
            if tlevel then
                tlevel:setVisible(false)
            end
            if tname then
                tname:setColor(UIUtils.colorTable.ccUIBaseColor8)
            end
            if limit_level then
                limit_level:setVisible(false)
            end

            self:registerClickEvent(donateBtn, function()
                self._viewMgr:showTip("联盟" .. data.limit .. "级解锁")
            end)
        else
            if scaturP then
                scaturP:setSaturation(0)
            end
            if lock then
                lock:setVisible(false)
            end
            if tlevel then
                tlevel:setVisible(true)
            end
            if tname then
                tname:setColor(UIUtils.colorTable.ccUIBaseColor1)
            end
        end
    end

    local cellBg = inView:getChildByFullName("cellBg")
    if cellBg then
        cellBg:loadTexture("allianceScicene_titleBg" .. indexId .. ".png", 1)
    end

    local tiao = inView:getChildByFullName("tiao")
    if tiao then
        tiao:loadTexture("allianceScicene_titletiao" .. indexId .. ".png", 1)
        tiao:setContentSize(cc.size(118*(table.nums(data.include)-1), 4))
    end
end

function GuildScienceView:onBeforeAdd(callback, errorCallback)
    self._onBeforeAddCallback = function(inType)
        if inType == 1 then 
            callback()
        else
            errorCallback()
        end
    end
    self:getTechInfo()
end

function GuildScienceView:getTechInfo()
    self._serverMgr:sendMsg("GuildServer", "getTechInfo", {}, true, {}, function (result)
        self:getTechInfoFinish(result)
    end)
end

function GuildScienceView:getTechInfoFinish(result)
    -- dump(result,"result ===================")
    if result == nil then
        self._onBeforeAddCallback(2)
        return 
    end
    self._onBeforeAddCallback(1)
    self:reflashUI()
end

function GuildScienceView:getAsyncRes()
    return {
            {"asset/ui/alliance.plist", "asset/ui/alliance.png"},
            {"asset/ui/alliance1.plist", "asset/ui/alliance1.png"},
            {"asset/ui/alliance2.plist", "asset/ui/alliance2.png"}
}
end

function GuildScienceView:getBgName()
    return "bg_001.jpg"
end

function GuildScienceView:setNoticeBar()
    self._viewMgr:hideNotice(true)
end

function GuildScienceView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{types = {"GuildCoin","Gold","Gem"},title = "allianceScicene_img2.png",titleTxt = "联盟科技"})
end

return GuildScienceView