--[[
    Filename:    TeamGradeNode.lua
    Author:      qiaohuan@playcrab.com 
    Datetime:    2015-12-11 10:52:44
    Description: File description
--]]
local TeamGradeNode = class("TeamGradeNode", BaseLayer)

local volumeChar = {"输出", "防御", "突击", "远程", "魔法"}

function TeamGradeNode:ctor(param)
    TeamGradeNode.super.ctor(self)
    self._tipId = {}
    self._tipValue = {}
    self._tip = {}
    self._tipBg = {}
    self._animValue = {}
    self._fightCallback = param.fightCallback
    self._attr = param.attr   
    self._tipattrs = {}
    -- self._aminBg = param.inView
end

function TeamGradeNode:onInit()
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._entryBgimg =  self:getUI("bg.tip")
    self._tipLab =  self:getUI("bg.tipLab")
    self._valueLab = self:getUI("bg.valueLab")

    self._entryBgimg:setVisible(false)
    self._tipLab:setVisible(false)
    self._valueLab:setVisible(false)

    -- local haveExpLab = self:getUI("bg.scrollView.infoNode.haveExpLab")
    -- local levelTipLab = self:getUI("bg.scrollView.infoNode.levelTipLab")
    -- local expTipLab = self:getUI("bg.scrollView.infoNode.expTipLab")

    self._bottom = self:getUI("bg.bottom")
    local mc1 = mcMgr:createViewMC("youjiantou_teamnatureanim", true, false)
    mc1:setPosition(cc.p(self._bottom:getContentSize().width*0.5, self._bottom:getContentSize().height*0.5))
    self._bottom:addChild(mc1)

    self._scrollView = self:getUI("bg.scrollView")
    self._scrollView:setBounceEnabled(true)
    self._scrollView:addEventListener(function(sender, eventType)
        if eventType == 6 or eventType == 1 then
            -- print ("5eventType============", eventType)
            self._bottom:setVisible(false)
        else
            -- print ("6eventType============", eventType)
            self._bottom:setVisible(true)
        end
    end)
    self._infoNode = self:getUI("bg.scrollView.infoNode")

    local title = self._infoNode:getChildByFullName("titleBg1.title")
    UIUtils:setTitleFormat(title, 3, 1)

    title = self._infoNode:getChildByFullName("titleBg2.title")
    UIUtils:setTitleFormat(title, 3, 1)
    
    -- local bg = self:getUI("bg")
    self._attrLabel = {}
    local maxHeight = self._attr:getContentSize().height
    local attrScroll = self._attr:getChildByFullName("scrollview")
    self._attr.scroll = attrScroll
    maxHeight = 26 * 20
    attrScroll:jumpToTop()
    attrScroll:setInnerContainerSize(cc.size(self._attr:getContentSize().width,maxHeight))
    for i=1,20 do
        local str = lang("SHOW_ATTR_NAME_" .. i)
        self._attrLabel[i] = cc.Label:createWithTTF(str, UIUtils.ttfName, 20)
        posY = maxHeight - 26 * i -- *(i-1)
        self._attrLabel[i]:setAnchorPoint(cc.p(0,0))
        self._attrLabel[i]:setPosition(cc.p(20,posY)) 
        self._attrLabel[i]:setColor(UIUtils.colorTable.ccUIBasePromptColor)
        attrScroll:addChild(self._attrLabel[i])
    end
    local closeAttr = self._attr:getChildByFullName("closeAttr")
    self:registerClickEvent(closeAttr, function()
        -- self:close()
        self._attr:setVisible(false)
    end)

    local updateTeamBtn = self:getUI("bg.scrollView.infoNode.updateTeamBtn")
    local upFiveTeamBtn = self:getUI("bg.scrollView.infoNode.upFiveTeamBtn")

    self:registerClickEvent(updateTeamBtn, function()
        if self._callUpGradeOne then
            self._callUpGradeOne(1)
        end
    end)
    self:registerClickEvent(upFiveTeamBtn, function()
        if self._callUpGradeOne then
            self._callUpGradeOne(5)
        end
    end)

    self:registerClickEventByName("bg.scrollView.infoNode.tanchushuxing",function( )
        -- dump(self._tipattrs)
        self:showHintView("global.GlobalTipView",
        {   
            tipType = 10,
            attrs = self._tipattrs,
            posCenter = true,
        })
    end)
    self._scrollTop = true
    
end

function TeamGradeNode:reflashUI(data,inView)

    -- print("TeamGradeNode:reflashUI(data,inView) ==========================")
    -- local teamImgBg = self:getUI("bg.scrollView.infoNode.tip1.valueLab")
    -- TeamUtils:setDataAnim(teamImgBg, {oldData = 120, newData = 123})
    self._aminBg = inView
    -- if table.nums(self._tip) == 0 or table.nums(self._tipBg) == 0 then
    --     -- print("创建")
    --     self:createTipNode()
    -- end
    -- self:setTipHide()

    if table.nums(self._tip) == 0 then
        -- print("创建")
        self:createTipNode()
    end
    self:setTipHide()

    self._teamData = data
    local sysTeam = tab:Team(self._teamData.teamId)

    local baseInfoLevelLab = self._infoNode:getChildByFullName("levelLab")
    baseInfoLevelLab:disableEffect()
    baseInfoLevelLab:setString("Lv." .. self._teamData.level)
    -- baseInfoLevelLab:setColor(cc.c3b(255,255,255))
    -- baseInfoLevelLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)

    local userData = self._modelMgr:getModel("UserModel"):getData()


    local haveExpValue = self._infoNode:getChildByFullName("haveExpValue")
    -- haveExpValue:setColor(cc.c3b(255,255,255))
    -- haveExpValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
    -- local tempLevel = self._teamData.level
    -- haveExpValue:setString(tab:TeamLevel(tempLevel).exp)
    -- haveExpValue:setString(userData.texp) -- 经验池的经验
    local tempTab = tab:Team(self._teamData.teamId).race
    haveExpValue:setString(lang(tab:Race(tempTab[1]).name))

-- 处理三种标签 
    -- local Image_196 = self._infoNode:getChildByFullName("Image_196")
    -- for i=1,3 do
    --     local iconLab = Image_196:getChildByFullName("iconBg" .. i)
    --     local imgStr, tipType
    --     local tempTab = tab:Team(self._teamData.teamId).race
    --     if i == 1 then
    --         imgStr = tab:Race(tempTab[1]).art .. ".png"
    --         tipType = 5
    --     elseif i == 2 then
    --         imgStr = tab:Race(tempTab[2]).art .. ".png"
    --         tipType = 6
    --     else 
    --         imgStr = tab:Team(self._teamData.teamId).classlabel .. ".png"
    --         tipType = 7
    --     end
    --     TeamUtils.showTeamLabelTip(iconLab, tipType, self._teamData.teamId)
    --     iconLab:loadTexture(IconUtils.iconPath .. imgStr)
    -- end

-- 处理标签显示
    -- local Image_196 = self._infoNode:getChildByFullName("Image_196")
    -- for i=1,2 do
    --     local iconLab = self._infoNode:getChildByFullName("teamlabelBg" .. i .. ".name")
    --     iconLab:setFontName(UIUtils.ttfName)
    --     local imgStr, tipType
    --     local tempTab = tab:Team(self._teamData.teamId).race
    --     if i == 1 then
    --         imgStr = lang(tab:Race(tempTab[1]).name)
    --         tipType = 5
    --         iconLab:setColor(cc.c3b(255,242,58))
    --         iconLab:enableOutline(cc.c4b(98,44,0,255), 2)
    --     elseif i == 2 then
    --         imgStr = lang(tab:Race(tempTab[2]).name)
    --         tipType = 6
    --         iconLab:setColor(cc.c3b(14,254,245))
    --         iconLab:enableOutline(cc.c4b(98,44,0,255), 2)
    --     -- else 
    --     --     imgStr = tab:Team(self._teamData.teamId).classlabel .. ".png"
    --     --     tipType = 7
    --     end
    --     TeamUtils.showTeamLabelTip(self._infoNode:getChildByFullName("teamlabelBg" .. i), tipType, self._teamData.teamId)
    --     iconLab:setString(imgStr)
    --     -- iconLab:loadTexture(IconUtils.iconPath .. imgStr)
    -- end


    -- local expLab = self._infoNode:getChildByFullName("expLab")
    -- expLab:disableEffect()
    -- expLab:setString(self._teamData.exp .. "/" .. teamMaxExp.exp)

   
    local teamMaxExp = tab:TeamLevel(self._teamData.level)
--经验条
    local exp = self._infoNode:getChildByFullName("expBg.exp")
    -- exp:setColor(cc.c3b(255,255,255))
    exp:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    exp:setString(self._teamData.exp .. "/" .. teamMaxExp.exp)
    -- exp:setString("升级还需" .. teamMaxExp.exp-self._teamData.exp .. "经验")

    local expBar = self._infoNode:getChildByFullName("expBg.expBar")
    str = (self._teamData.exp / teamMaxExp.exp)
    if str > 1 then
        str = 1
    end
    if str < 0 then
        str = 0
    end
    expBar:setScaleX(str)
    -- expBar:setPercent(str)

--升级
    local updateTeamBtn = self._infoNode:getChildByFullName("updateTeamBtn")
    local upFiveTeamBtn = self._infoNode:getChildByFullName("upFiveTeamBtn")
    if self._teamData.level < userData.lvl then 
        if userData.texp > 0 then
            self._callUpGradeOne = function(level)
                local param = {teamId = self._teamData.teamId,level = level}
                self:upgradeTeam(param)
            end

        else
            self._callUpGradeOne = function()
                DialogUtils.showLackRes( {goalType = "texp"})
            end
        end
    else
        if self._teamData.level == userData.lvl then 
            self._callUpGradeOne = function()
                self._viewMgr:showTip(lang("TIPS_BINGTUAN_08"))
            end
        end
    end

    local itemModel = self._modelMgr:getModel("ItemModel")
    --怪兽等级小于玩家等级不能进行升级

            -- self:registerClickEvent(updateTeamBtn, function ()
            --     -- self._viewMgr:showDialog("team.TeamGradeDialog",{teamData = self._teamData},true)  
            --     -- if self._teamData.level >= userData.lvl  then 
            --     --     self._viewMgr:showTip("怪兽已达最高等级")
            --     -- end
            -- end) 

        -- if self._teamData.level < userData.lvl then 
        --     self:registerClickEvent(updateTeamBtn, function ()
        --         if userData.texp >= teamMaxExp.exp then
        --             -- self:upgradeTeam()
        --             self._viewMgr:showDialog("team.TeamGradeDialog",{teamData = self._teamData},true)   
        --         else
        --             self._viewMgr:showTip("经验池经验不足")
        --         end
                
        --     end)      
        -- else
        --     self:registerClickEvent(updateTeamBtn, function ()
        --         if self._teamData.level >= userData.lvl  then 
        --             self._viewMgr:showTip("怪兽已达最高等级")
        --         end
        --     end)          
        -- end

    -- self:updateAttribute()
    local sysTeam = tab:Team(self._teamData.teamId)

    local flag = 1
    for k,v in pairs(sysTeam.equip) do
        if tonumber(self._teamData["es" .. k]) <= self._teamData.stage then
            flag = 0
        end
    end
-- 设置位置
    self:saveData(sysTeam)
    local tipcount = self:getTipCountNum()

    -- 计算总高度
    local rHeight = self._infoNode:getContentSize().height
    rHeight = rHeight + ((self._tipLab:getContentSize().height + 6) * tipcount) + 20

    local property = self:getUI("bg.scrollView.infoNode.titleBg2.gantanhao")
    property:setScaleAnim(true)
    self:registerClickEvent(property, function()
        self._attr:setVisible(true)
        -- self._viewMgr:showDialog("team.TeamGradeAttrDialog")
        -- print("我是感叹号")
    end)

    -- local inTipBg = self._scrollView:getChildByName("inTipBg")
    -- local property -- = inTipBg:getChildByName("property")
    -- if inTipBg then
    --     property = inTipBg:getChildByName("property")
    --     inTipBg:setContentSize(cc.size(300, ((self._tipLab:getContentSize().height + 6) * tipcount + 10)))
    --     property:setPosition(cc.p(296,((self._tipLab:getContentSize().height + 6) * tipcount + 6)))
    --     inTipBg:setCapInsets(cc.rect(25, 25, 1, 1))
    -- else
    --     inTipBg = cc.Scale9Sprite:createWithSpriteFrameName("globalPanelUI6_paperInnerBg2.png")
    --     inTipBg:setContentSize(cc.size(300, ((self._tipLab:getContentSize().height + 6) * tipcount + 10)))
    --     inTipBg:setAnchorPoint(cc.p(0, 0))
    --     inTipBg:setName("inTipBg")
    --     inTipBg:setCapInsets(cc.rect(25, 25, 1, 1))
        
    --     self._scrollView:addChild(inTipBg)

    --     property = ccui.ImageView:create()
    --     property:setName("property")
    --     property:loadTexture("globalImage_info.png", 1)
    --     property:setAnchorPoint(cc.p(1,1))
    --     property:setPosition(cc.p(296,((self._tipLab:getContentSize().height + 6) * tipcount + 6)))
    --     inTipBg:addChild(property)
    --     self:registerClickEvent(property, function()
    --         self._attr:setVisible(true)
    --         -- self._viewMgr:showDialog("team.TeamGradeAttrDialog")
    --         print("我是新界面")
    --     end)
    -- end

    -- inTipBg:setPosition(cc.p(5, 5))

    -- self._maxHeight = rHeight

    local scrollViewWidth = self._scrollView:getContentSize().width
    self._scrollView:setInnerContainerSize(cc.size(scrollViewWidth,rHeight))

    local height = (self._tipLab:getContentSize().height + 6) * tipcount + 23
    self._infoNode:setPositionY(height)
    self:getTipCount(tipcount)

    if self._scrollTop == true then
        self._scrollView:jumpToTop() --(0.01,false)
        self._bottom:setVisible(true)
    else
        self._scrollTop = true
    end

    -- self:setPianyi()
end

function TeamGradeNode:showItem(inTipLab, inValueLab, inBg, isShowBg, inTip, inValue, inHeight)
    -- 闪避值
    -- inBg, isShowBg, 
    local str = lang(inTip)
    -- print(str)
    inTipLab:setString(str .. ":")
    inTipLab:setVisible(true)
    -- inTipLab:setPosition(cc.p(-10,5 + (self._tipLab:getContentSize().height + 6) * inHeight))
    inTipLab:setPositionY(5 + (self._tipLab:getContentSize().height + 5) * inHeight + 10)

    inValueLab:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
    inValueLab:setString(inValue)
    inValueLab:setVisible(true)
    -- self._tip[i].valueLab:setPosition(cc.p(self._tip[i].tipLab:getPositionX()+self._tip[i].tipLab:getContentSize().width, 0))
    inValueLab:setPosition(inTipLab:getPositionX()+inTipLab:getContentSize().width + 5, inTipLab:getPositionY()) 
    -- print("=========", inTip, isShowBg)
    if isShowBg == true then 
        -- print(inHeight,"执行")
        inBg:setVisible(false)
        inBg:setPosition(cc.p(inBg:getPositionX(), inValueLab:getPositionY()))
    end
end

-- 设置高级属性显示
function TeamGradeNode:getTipCount(tipBgcount)
    local tipCount = 0
    local tipBg = 15
    local isShowBg = false
    local tempConst = 0
    if tipBgcount and math.fmod(tipBgcount, 2) == 0 then
        tempConst = 1
    end
    for i,v in ipairs(self._tipValue) do
    -- for i=table.nums(self._tipValue),1,-1 do
        if math.fmod(tipCount, 2) == tempConst then
            isShowBg = true
            tipBg = tipBg + 1       
        end
        -- print("isShowBg=============", tipCount, isShowBg, table.nums(self._tipValue))
        if i == 13 then
            if v ~= 200 then
                local temp  = self._tipValue[i] .. "%"
                tipCount = tipCount + 1               
                self:showItem(self._tip[i].tipLab, self._tip[i].valueLab, self._tip[i].entryBgimg, isShowBg, self._tipId[i] , temp, tipCount)
            end
        elseif i > 13 then
            if i == 15 or i == 16 then
                if tonumber(v) ~= 0 then
                    local temp = self._tipValue[i]
                    tipCount = tipCount + 1
                    self:showItem(self._tip[i].tipLab, self._tip[i].valueLab, self._tip[i].entryBgimg, isShowBg, self._tipId[i] , temp, tipCount)  
                end
            else
                local temp = self._tipValue[i]
                tipCount = tipCount + 1
                -- self:showItem(self._tip[i].tipLab, self._tip[i].valueLab, self._tipBg[tipBg].entryBgimg, isShowBg, self._tipId[i] , temp, tipCount)
                self:showItem(self._tip[i].tipLab, self._tip[i].valueLab, self._tip[i].entryBgimg, isShowBg, self._tipId[i] , temp, tipCount)
            end
        else
            if tonumber(v) ~= 0 then
                local temp 
                if i == 10 or i == 3 or i == 4 then
                    temp = self._tipValue[i]
                elseif (i > 2 and i <= 13) then            
                    temp = self._tipValue[i] .. "%"
                else
                    temp = self._tipValue[i]
                end
                tipCount = tipCount + 1
                self:showItem(self._tip[i].tipLab, self._tip[i].valueLab, self._tip[i].entryBgimg, isShowBg, self._tipId[i] , temp, tipCount)
            end
        end
        isShowBg = false
    end
    return tipCount

end

-- 获取显示几个属性
function TeamGradeNode:getTipCountNum()
    local tipCount = 0
    for i,v in ipairs(self._tipValue) do
        if i == 13 then
            if v ~= 200 then
                tipCount = tipCount + 1               
            end
        elseif i > 13 then
            if i == 15 or i == 16 then
                if tonumber(v) ~= 0 then
                    tipCount = tipCount + 1
                end 
            else
                tipCount = tipCount + 1
            end  
        else
            if tonumber(v) ~= 0 then
                tipCount = tipCount + 1
            end
        end
    end

    return tipCount
end

-- 保存数据
function TeamGradeNode:saveData(sysTeam)
    local tempEquips = {}
    for i=1,4 do
        local tempEquip = {}
        local equipLevel = self._teamData["el" .. i]
        local equipStage = self._teamData["es" .. i]
        tempEquip.stage = equipStage
        tempEquip.level = equipLevel
        table.insert(tempEquips, tempEquip)
    end

    local backData, backSpeed, atkSpeed = BattleUtils.getTeamBaseAttr(self._teamData, tempEquips, self._modelMgr:getModel("PokedexModel"):getScore())
    
    -- 获取宝物属性
    local attr = self._teamModel:getTeamTreasure(self._teamData.volume)
    local treasureAttr = self._teamModel:getTeamTreasureAttrData(self._teamData.teamId)

    -- 获取英雄属性
    local heroAttr = self._teamModel:getTeamHeroAttrByTeamId(self._teamData.teamId)
    -- dump(heroAttr)
    -- 基础数据
    local backData1, backSpeed1, atkSpeed1 = BattleUtils.getTeamBaseAttr(self._teamData, tempEquips)

    local backData2, backSpeed2, atkSpeed2 = BattleUtils.getTeamBaseAttr(self._teamData, tempEquips)

    local boostData = self:getTeamBoostData(self._teamData.tb, sysTeam)

    local talentData = self:getTeamTalentData(self._teamData.tt, sysTeam)

    local holyData,holyAddAttr = self._modelMgr:getModel("TeamModel"):getStoneAttr(self._teamData.rune)

    local holySuitData = self:calcRuneSuitData(self._teamData.rune)


    -- boostData.atkAttr = 0
    -- boostData.hpAttr = 0
    -- boostData.lvStage = 0
    -- boostData.atkBase = 1
    -- boostData.hpBase = 1
    -- boostData.atkAttrValue = 0
    -- boostData.hpAttrValue = 0
    -- dump(tab.team[self._teamData.teamId])
    -- dump(boostData, "boostData===") -- 不算宝物
    -- dump(backData, "backData===") -- 不算宝物
    -- dump(attr, "attr========", 10)

    for i=BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
        backData[i] = backData[i] + heroAttr[i] + holyData[i] + holyAddAttr[i]
    end

    for i=BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
        backData1[i] = backData1[i] + holyData[i] + holyAddAttr[i]
    end

    --增加圣徽精通 攻击 防御 额外属性
    local holyAtk,holyDef = self:getHolyExtPorp(self._teamData.rune)
    backData[66] = backData[66] + holyAtk
    backData[67] = backData[67] + holyDef
    
    for i=1,2 do
        if i == 1 then
            local value = BattleUtils.getTeamAttackAttr(backData1, true) -- 无图鉴数据
            local value1 = BattleUtils.getTeamAttackAttr(backData, true) -- 总数据
            -- local value2 = math.ceil(boostData.atkBase * (100+boostData.atkAttr) / 100 + boostData.atkAttrValue)
            local value2 = backData1[1] * (talentData.atkAttr / 100) + talentData.atkAttrValue
            -- local  value3 = value1 * (100 + holyData[64]) / 100           -- 总数据（包含圣辉加成）
            local holyValue =  value1 *((holyData[64]*(100+0.3* holyData[64])/(100+holyData[64]))*0.01)        -- 圣辉全局攻击加成
            local herovalue = backData1[1] * (heroAttr[2] / 100) + heroAttr[3]
            local d = holySuitData[2] and holyAddAttr[2] + holySuitData[2] or holyAddAttr[2]
            local holyValue2 = math.ceil(backData1[1] *d/100)
            self._tipattrs["atkbase"] = value - value2 - holyValue2
            self._tipattrs["atkpokedex"] = value1 - value - herovalue
            self._tipattrs["atkteamboost"] = math.ceil(value2)
            self._tipattrs["atkhero"] = math.ceil(herovalue)
            self._tipattrs["atkholy"] = math.ceil(holyValue) + holyValue2
        elseif i == 2 then
            local value = BattleUtils.getTeamHpAttr(backData1, true)
            local value1 = BattleUtils.getTeamHpAttr(backData, true)
            -- local value2 = math.ceil(talentData.hpBase * (100+talentData.hpAttr) / 100 + talentData.hpAttrValue)
            local value2 = backData1[4] * (talentData.hpAttr / 100) + talentData.hpAttrValue
            local  value3 = value1 * (100 + holyData[65]) / 100           
            local herovalue = backData1[4] * (heroAttr[5] / 100) + heroAttr[6]
            local holyValue =  value1 *((holyData[65]*(100+0.3* holyData[65])/(100+holyData[65]))*0.01)
            local d = holySuitData[5] and holyAddAttr[5] + holySuitData[5] or holyAddAttr[5]
            local holyValue2 = math.ceil(backData1[4] * d/100)
            self._tipattrs["hpbase"] = value - value2 - holyValue2
            self._tipattrs["hppokedex"] = value1 - value - herovalue
            self._tipattrs["hpteamboost"] = math.ceil(value2)
            self._tipattrs["hphero"] = math.ceil(herovalue)
            self._tipattrs["hpholy"] = math.ceil(holyValue) + holyValue2
        end
    end
    for i=BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
        backData[i] = backData[i] + treasureAttr[i]
    end
    dump(backData,"jichushuxing2")
    -- 暂时只加2和5属性
    backData[2] = backData[2] + attr[2]
    backData[3] = backData[3] + attr[3]
    backData[5] = backData[5] + attr[5]
    backData[6] = backData[6] + attr[6]

    -- self._tipattrs["atkbase"]
    -- self._tipattrs["atkpokedex"]
    -- self._tipattrs["atktreasure"]
    -- self._tipattrs["atkteamboost"]
    -- self._tipattrs["atkholy"]
    -- self._tipattrs["hp"]
    -- self._tipattrs["hpbase"]
    -- self._tipattrs["hppokedex"]
    -- self._tipattrs["hptreasure"]
    -- self._tipattrs["hpholy"]

    atkSpeed = backSpeed * (1 + 0.01 * backData[14])

    self._baseNature = {}
    local aLvl = self._teamData.aLvl or 0
    if aLvl >= 6 then
        aLvl = 6
    end
    for i=1,6 do
        local str1 = "tip" .. i .. ".valueLab"--"bg.scrollView.infoNode.tip" .. i .. ".valueLab" --"tip" .. i .. ".valueLab"
        local valueLabNum = self._infoNode:getChildByFullName(str1)--self:getUI(str) --self._infoNode:getChildByFullName(str)
        str1 = "tip" .. i .. ".addValue"
        local addValueNum = self._infoNode:getChildByFullName(str1)
        str1 = "tip" .. i .. ".addValue1"
        local addValue1 = self._infoNode:getChildByFullName(str1)
        str1 = "tip" .. i .. ".addValue2"
        local addValue2 = self._infoNode:getChildByFullName(str1)
        local value = 0
        local addValue = 0
        if i == 1 then
            value = BattleUtils.getTeamAttackAttr(backData, true)
            local holyValue =  value *((holyData[64]*(100+0.3* holyData[64])/(100+holyData[64]))*0.01)
            value = value + holyValue
            self._tipattrs["atk"] = value
            value = TeamUtils.getNatureNums(value)
            addValue = sysTeam.atkadd[self._teamData.star]
            self._baseNature[i] = sysTeam.atkadd[self._teamData.star]
            -- addValue = addValue --string.format("%.2f", addValue)
            if aLvl and aLvl ~= 0 then
                addValue = addValue + sysTeam.atktalent[aLvl]
            end
        elseif i == 2 then
            value = BattleUtils.getTeamHpAttr(backData, true)
            local holyValue =  value *(( holyData[65]*(100+0.3* holyData[65])/(100+holyData[65]))*0.01)
            value = value + holyValue
            self._tipattrs["hp"] = value
            value = TeamUtils.getNatureNums(value)
            addValue = sysTeam.hpadd[self._teamData.star]
            self._baseNature[i] = sysTeam.hpadd[self._teamData.star]
            if aLvl and aLvl ~= 0 then
                addValue = addValue + sysTeam.hptalent[aLvl]
            end
        elseif i == 3 then
            value = backData[7]*(0.01*backData[35]+1)
            value = TeamUtils.getNatureNums(value)
            addValue = sysTeam.defadd[self._teamData.star]
            self._baseNature[i] = sysTeam.defadd[self._teamData.star]
        elseif i == 4 then
        -- 破防
            -- value = backData[8]
            -- addValue = sysTeam.penadd[self._teamData.star]
        -- 攻速
            -- value = math.ceil(atkSpeed * 100) / 100  --backData[8]
            value = TeamUtils.getNatureNums(atkSpeed)
            -- print("=============", value)
            addValue = 0
        elseif i == 5 then
            value = (6 - tab:Team(self._teamData.teamId).volume) * (6 - tab:Team(self._teamData.teamId).volume) --backData[8]
            addValue = 0 --sysTeam.penadd[self._teamData.star]
        elseif i == 6 then
            value = lang("TEAM_DINGWEI_"..tab:Team(self._teamData.teamId).carddes)
            addValue = 0
        end
        addValue = TeamUtils.getNatureNums(addValue) --math.ceil(addValue * 10) / 10
        -- 
        if value then
            self._animValue[i] = value
            -- print ("===========", value)
            valueLabNum:setString(value)
            -- valueLabNum:enableOutline(UIUtils.colorTable.ccUIB8aseOutlineColor,2)
            -- valueLabNum:setPositionX(valueLabNum:getPositionX()-2)
        end
        -- 弹出Tip
        if i == 1 then
            local tatktreasure = math.ceil(self._tipattrs["atk"] - self._tipattrs["atkbase"] - self._tipattrs["atkpokedex"] - self._tipattrs["atkteamboost"] - self._tipattrs["atkhero"] - self._tipattrs["atkholy"])
            if tatktreasure < 0 then
                tatktreasure = 0
            end
            self._tipattrs["atktreasure"] = tatktreasure
        elseif i == 2 then
            thptreasure = math.ceil(self._tipattrs["hp"] - self._tipattrs["hpbase"] - self._tipattrs["hppokedex"] - self._tipattrs["hpteamboost"] - self._tipattrs["hphero"] - self._tipattrs["hpholy"])
            if thptreasure < 0 then
                thptreasure = 0
            end
            self._tipattrs["hptreasure"] = thptreasure
        end
        if tonumber(addValue) ~= 0 then
            addValueNum:setString("+" .. addValue)
            -- addValueNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            addValueNum:setVisible(true)
            addValue2:setPositionX(valueLabNum:getPositionX()+valueLabNum:getContentSize().width + 8)
            addValueNum:setPositionX(addValue2:getPositionX()+addValue2:getContentSize().width + 5)
            addValue1:setPositionX(addValueNum:getPositionX()+addValueNum:getContentSize().width + 10)
            
        else
            addValueNum:setVisible(false)
            addValue1:setVisible(false)
            addValue2:setVisible(false)
        end

    end

    -- dump(self._tipValue)

    local function handleShowNum(inFirNum ,inSecNum)
        local showNum = ""
        if inFirNum > 0 then 
            showNum = inFirNum -- .. "%" 
        end

        if inSecNum > 0 then
            if string.len(showNum) > 0 then 
                showNum = showNum .. "+"
            end
            showNum = showNum .. inSecNum
        end
        if string.len(showNum) <= 0 then 
            showNum = "0"
        end
        return showNum
    end
    local speed = (sysTeam.speedmove + tonumber(backData[31]))
    if speed > 999 then 
        speed = 999
    elseif speed < 0 then
        speed = "0"
    end

--     for i=1,11 do
--         local str = "SHOW_ATTR_" .. (12-i)
--         self._tipId[i] = str 
--     end
-- -- BattleUtils.dumpBaseAttr(backData)
--     self._tipValue[1] = speed -- 移动速度17
--     self._tipValue[2] = handleShowNum(backData[25], backData[24])-- 反伤9
--     self._tipValue[3] = handleShowNum(backData[23], backData[22])-- 吸血8
--     self._tipValue[4] = backData[55] -- 法术免伤13% 
--     self._tipValue[5] = backData[21] -- 兵团免伤12% 
--     self._tipValue[6] = backData[20] -- 兵团伤害11% 
--     self._tipValue[7] = handleShowNum(backData[19], backData[18])-- 被治疗值7
--     self._tipValue[8] = handleShowNum(backData[17], backData[16])-- 治疗值6
--     self._tipValue[9] = (200 + backData[10]) -- 暴伤值3
--     self._tipValue[10] = backData[12]-- 闪避值4 -- 常态
--     self._tipValue[11] = backData[9]-- 暴击值2 -- 常态

    local maxNatureNum = 18
    for i=1,(maxNatureNum-1) do
        local str = "SHOW_ATTR_" .. (maxNatureNum-i)
        self._tipId[i] = str 
    end
-- BattleUtils.dumpBaseAttr(backData)
    
    self._tipValue[1] = TeamUtils.getNatureNums(backData[34]+sysTeam.attackarea) -- backData[34]-- 攻击距离-- 常态
    self._tipValue[2] = TeamUtils.getNatureNums(speed) -- speed -- 移动速度17
    self._tipValue[3] = TeamUtils.getNatureNums(backData[67]) -- backData[9]-- 圣辉攻击 
    self._tipValue[4] = TeamUtils.getNatureNums(backData[66]) -- backData[9]-- 圣辉防御 
    self._tipValue[5] = TeamUtils.getNatureNums(handleShowNum(backData[25], backData[24])) -- handleShowNum(backData[25], backData[24])-- 反伤9
    self._tipValue[6] = TeamUtils.getNatureNums(handleShowNum(backData[23], backData[22])) -- handleShowNum(backData[23], backData[22])-- 吸血8
    self._tipValue[7] = TeamUtils.getNatureNums(backData[55]) -- backData[55] -- 法术免伤13% 
    self._tipValue[8] = TeamUtils.getNatureNums(backData[21]) -- backData[21] -- 兵团免伤12% 
    self._tipValue[9] = TeamUtils.getNatureNums(backData[20]) -- backData[20] -- 兵团伤害11% 
    self._tipValue[10] = TeamUtils.getNatureNums(backData[15])
    self._tipValue[11] = TeamUtils.getNatureNums(handleShowNum(backData[19], backData[18])) -- handleShowNum(backData[19], backData[18])-- 被治疗值7
    self._tipValue[12] = TeamUtils.getNatureNums(handleShowNum(backData[17], backData[16])) -- handleShowNum(backData[17], backData[16])-- 治疗值6
    self._tipValue[13] = TeamUtils.getNatureNums((200 + backData[10])) -- (200 + backData[10]) -- 暴伤值3
    self._tipValue[14] = TeamUtils.getNatureNums(backData[12]) -- backData[12]-- 闪避值4 -- 常态
    self._tipValue[15] = TeamUtils.getNatureNums(backData[13]) -- backData[13]-- 命中
    self._tipValue[16] = TeamUtils.getNatureNums(backData[11]) --                韧性
    self._tipValue[17] = TeamUtils.getNatureNums(backData[9]) -- backData[9]-- 暴击值2 -- 常态

    if self._tipValue[1] >= 2000 then
        self._tipValue[1] = "无视距离"
    end
    if self._tipValue[15] >= 5000 then
        self._tipValue[15] = "必定命中"
    end
end

function TeamGradeNode:calcRuneSuitData(rune)

    local runes = {}
    local baseAttr = {}
    if not rune then
        return baseAttr
    end
    local suit = rune["suit"]
    if suit then
        local t = {"2", "6"}  -- "4" 在兵团技能初始化那里加

        for i=1,#t do
            local effComsStr = suit[t[i]]
            if effComsStr then
                local effComs = string.split(effComsStr,",")
                for j=1,#effComs do
                    local runeId = tonumber(effComs[j])
                    local buffData = tab.rune[runeId]["effect"..t[i]]
                    for m=1, #buffData do
                        -- 判断是否存在
                        if not runes[runeId] then
                             runes[runeId] = {}
                        end

                        if not runes[runeId][buffData[m][1]] then
                            runes[runeId][buffData[m][1]] = buffData[m][2]
                        else
                            runes[runeId][buffData[m][1]] = runes[runeId][buffData[m][1]] + buffData[m][2]
                        end 
                    end
                end
            end 
        end
    end
    for runeId, value in pairs(runes) do
        for attr,v in pairs(value) do
            local a = tonumber(attr)
            baseAttr[a] = v
        end
    end
    return baseAttr
end

--计算圣徽精通额外属性
function TeamGradeNode:getHolyExtPorp(rune)
    local atk = 0
    local def = 0
    local lv = 0
    if rune then
        for i=1,6 do
            local key = rune[tostring(i)]
            if key and key ~= 0 then
                local stoneData = self._teamModel:getHolyDataByKey(key)
                lv = lv + stoneData.lv-1
            end
        end
    end
    local tempLv = 0
    for i,tabData in ipairs(tab.runeCastingMastery) do
        if lv < tabData.level then
            tempLv = i - 1
            break
        end
        tempLv = i
    end
    local rData = tab.runeCastingMastery[tempLv]
    if rData then
        atk = rData.castingMastery[1][2]
        def = rData.castingMastery[2][2]
    end
    return atk,def
end

-- 计算天赋属性
function TeamGradeNode:getTeamTalentData(teamTalent, teamD)
    local talentData = {}
    talentData.atkAttr = 0
    talentData.hpAttr = 0
    talentData.atkBase = 1
    talentData.hpBase = 1
    talentData.atkAttrValue = 0
    talentData.hpAttrValue = 0
    if teamTalent then
        local talentTab = teamD.talent
        for i=1,4 do
            local attr = talentTab[i][1]
            local value = tonumber(teamTalent[tostring(attr)]) or 0
            print("attr============", attr, value)
            if attr == 2 then
                talentData.atkAttr = value
            elseif attr == 3 then
                talentData.atkAttrValue = value
            elseif attr == 5 then
                talentData.hpAttr = value
            elseif attr == 6 then
                talentData.hpAttrValue = value
            end
        end
    end
    return talentData
end


-- 计算技巧属性
function TeamGradeNode:getTeamBoostData(teamBoost, teamD)
    local boostData = {}
    boostData.atkAttr = 0
    boostData.hpAttr = 0
    boostData.atkBase = 1
    boostData.hpBase = 1
    -- boostData.lvStage = 0
    boostData.atkAttrValue = 0
    boostData.hpAttrValue = 0
    -- if teamBoost then
    --     local techniqueD, lvStage
    --     local minLvStage = 9
    --     local setingTab = tab:Setting("G_TECHNIQUE_UNLOCK").value
    --     for k, v in pairs(teamBoost) do
    --         techniqueD = tab.technique[tonumber(k)]
    --         if tonumber(k) == 1 then
    --             boostData.atkAttr = v * techniqueD["rate"]
    --         elseif tonumber(k) == 2 then
    --             boostData.hpAttr = v * techniqueD["rate"]
    --         end

    --         lvStage = 0
    --         for i=9,1,-1 do
    --             if v >= setingTab[i] then
    --                 lvStage = i
    --                 break
    --             end
    --         end
    --         if lvStage < minLvStage then
    --             minLvStage = lvStage
    --         end
    --     end
    --     boostData.lvStage = minLvStage
    --     if minLvStage > 0 then
    --         local highAttr = teamD["highAttr"]
    --         local attr, value
    --         for i = 1, minLvStage do
    --             attr, value = highAttr[i][1], highAttr[i][2]
    --             -- baseAttr[attr] = baseAttr[attr] + value
    --             if attr == 2 then
    --                 boostData.atkAttr = boostData.atkAttr + value
    --             elseif attr == 3 then
    --                 boostData.atkAttrValue = boostData.atkAttrValue + value
    --             elseif attr == 5 then
    --                 boostData.hpAttr = boostData.hpAttr + value
    --             elseif attr == 6 then
    --                 boostData.hpAttrValue = boostData.hpAttrValue + value
    --             end
    --         end
    --     end
    -- end

    return boostData
end

-- 创建高级属性条
function TeamGradeNode:createTipNode()
    if table.nums(self._tip) == 0 then
        for i=1,18 do
            self._tip[i] = {}
            self._tip[i].tipLab = self._tipLab:clone()
            self._scrollView:addChild(self._tip[i].tipLab)
            self._tip[i].tipLab:setAnchorPoint(0, 0.5)
            self._tip[i].tipLab:setPosition(45, 0)
            self._tip[i].tipLab:disableEffect() 

            self._tip[i].valueLab = self._valueLab:clone()
            self._scrollView:addChild(self._tip[i].valueLab)
            self._tip[i].valueLab:setAnchorPoint(0, 0.5)
            self._tip[i].valueLab:disableEffect() 
            -- self._tip[i].valueLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
            self._tip[i].valueLab:setPosition(cc.p(self._tip[i].tipLab:getPositionX()+self._tip[i].tipLab:getContentSize().width, 0))

            self._tip[i].entryBgimg = self._entryBgimg:clone()
            self._scrollView:addChild(self._tip[i].entryBgimg)
            self._tip[i].entryBgimg:setAnchorPoint(cc.p(0, 0.5))
            self._tip[i].entryBgimg:setPosition(cc.p(self._tip[i].entryBgimg:getPositionX()-8, 0))
        end
    end --self._tip[i].tipLab:getPositionX() + nameLab:getContentSize().width + 20
end

-- 为0 隐藏
function TeamGradeNode:setTipHide()
    if table.nums(self._tip) > 0 then
        for i=1,18 do
            self._tip[i].entryBgimg:setVisible(false)
            self._tip[i].tipLab:setVisible(false)
            self._tip[i].valueLab:setVisible(false)
        end
    end

    -- if table.nums(self._tipBg) > 0 then
    --     for i=1,9 do
    --         self._tipBg[i].entryBgimg:setVisible(false)
    --     end
    -- end
end

--[[
--! @function upgradeTeam
--! @desc 升级怪兽
--! @param 
--! @return 
--]]
function TeamGradeNode:upgradeTeam(param)
    self._oldAnimValue = clone(self._animValue)
    self._oldTeamData = clone(self._teamData)
    -- dump(self._oldTeamData)
    self._oldFight = TeamUtils:updateFightNum()
    self._serverMgr:sendMsg("TeamServer", "upgradeTeam", param, true, {}, function(result)
        self._scrollTop = false
        self:upgradeTeamFinish(result)
    end)
end

function TeamGradeNode:upgradeTeamFinish(inResult)
    if inResult["d"] == nil then 
        return 
    end
    local fightBg = self:getUI("bg")
    TeamUtils:setFightAnim(fightBg, {oldFight = self._oldFight, newFight = TeamUtils:updateFightNum(), x = -200, y = fightBg:getContentSize().height - 110})

    audioMgr:playSound("crLvUp")
    local tempTeam,_ = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(self._teamData.teamId)
    self._teamData = tempTeam
    local upTeamLevel = self._teamData.level - self._oldTeamData.level
    local userTexp = self._modelMgr:getModel("UserModel"):getData().texp
    local expNum = 0 --tab:TeamLevel(self._oldTeamData.level).exp - self._oldTeamData.exp
    local tempParent = 0
    local percent = 0
    for i=self._oldTeamData.level,self._teamData.level do
        if i == self._oldTeamData.level and self._oldTeamData.exp ~= 0 then
            expNum = expNum + tab:TeamLevel(i).exp - self._oldTeamData.exp
            tempParent = tempParent + 100 -- (self._oldTeamData.exp / tab:TeamLevel(i).exp) * 100
        elseif i == self._teamData.level and self._teamData.exp ~= 0 and i ~= 1 then
            expNum = expNum + self._teamData.exp 
            percent = (self._teamData.exp / tab:TeamLevel(self._teamData.level).exp) * 100
            tempParent = tempParent + percent
        elseif i == self._teamData.level and self._teamData.exp == 0 then
            expNum = expNum
            tempParent = tempParent
        else
            expNum = expNum + tab:TeamLevel(i).exp
            tempParent = tempParent + 100
        end
    end
    if self._oldTeamData.level == self._teamData.level then
        expNum = self._teamData.exp - self._oldTeamData.exp
    end
    if expNum <= 0 then
        expNum = self._teamData.exp - self._oldTeamData.exp 
    end

    local expBar = self._infoNode:getChildByFullName("expBg.expBar")


    local tempExp = (self._oldTeamData.exp / tab:TeamLevel(self._oldTeamData.level).exp) * 100
    -- local percent = (self._teamData.exp / tab:TeamLevel(self._teamData.level).exp) * 100
    -- tempParent = tempParent + percent
    -- print("==tempParent============", tempParent)
    local addExp = 5
    if tempParent > 100 then
        addExp = 10
    end
    expBar:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
        if tempExp < tempParent then
            local str = math.fmod(tempExp, 100)
            if str + 10 >= 100 then
                str = 100
            end
            local percent = str*0.01
            if percent > 1 then
                percent = 1
            end
            if percent < 0 then
                percent = 0
            end
            expBar:setScaleX(percent)
            -- expBar:setPercent(str)
        else
            percent = (self._teamData.exp / tab:TeamLevel(self._teamData.level).exp)
            if percent > 1 then
                percent = 1
            end
            if percent < 0 then
                percent = 0
            end
            expBar:setScaleX(percent)

            expBar:stopAllActions()
        end
        tempExp = tempExp + addExp
    end), cc.DelayTime:create(0.001))))
    
    self:teamSheng()
    -- expBar:runAction(cc.RepeatForever(cc.Sequence:create(cc.CallFunc:create(function()
    --         tempExp = tempExp + 1
    --         if tempExp == 100 then
    --             expBar:stopAllActions()
    --             return
    --         end
    --         expBar:setPercent(tempExp)
    --     end), cc.DelayTime:create(0.1))))
    
    
    -- self:teamPiaoNature(expNum)
    self:setAnim()
    self._fightCallback({newFight = tempTeam.score, oldFight = self._oldTeamData.score})
    -- self._viewMgr:showTip("升级成功")
    
    -- local teamModel = self._modelMgr:getModel("TeamModel")
    -- self:reflashUI({teamData = teamModel:getTeamAndIndexById(self._teamData.teamId)})
end

function TeamGradeNode:setPianyi()
    self._scrollView:scrollToTop(0.01,false) --scrollToTop(0, true)
    -- self._scrollView:getContainer()
    -- setContainer(pContainer)
    -- self._tableView:setContentOffset(cc.p(0 , -(selectedIndex - 1)*90))
end


function TeamGradeNode:setAnim()
    -- print("设置动画")
    local sysTeam = tab:Team(self._teamData.teamId)
    self:saveData(sysTeam)
    -- local aminBg = self:getUI("bg.rightBg.aminBg")
    local mc2 = mcMgr:createViewMC("shengjirenwu_teamupgrade-HD", false, true, function (_, sender) end, RGBA8888)
    mc2:setPosition(290,self._aminBg:getContentSize().height/2)
    self._aminBg:addChild(mc2)

    local teamImgBg = self:getUI("bg.scrollView.infoNode.tip1.valueLab")
    TeamUtils:setDataAnim(teamImgBg, {oldData = self._oldAnimValue[1], newData = self._animValue[1], tempColor = UIUtils.colorTable.ccUIBaseTextColor2})
    teamImgBg = self:getUI("bg.scrollView.infoNode.tip2.valueLab")
    TeamUtils:setDataAnim(teamImgBg, {oldData = self._oldAnimValue[2], newData = self._animValue[2], tempColor = UIUtils.colorTable.ccUIBaseTextColor2})
    teamImgBg = self:getUI("bg.scrollView.infoNode.tip3.valueLab")
    TeamUtils:setDataAnim(teamImgBg, {oldData = self._oldAnimValue[3], newData = self._animValue[3], tempColor = UIUtils.colorTable.ccUIBaseTextColor2})
end

function TeamGradeNode:teamSheng()
    local str = "升级成功"
    local expBar = self._infoNode:getChildByFullName("expBg")

    local expBarLab = cc.Sprite:create() 
    expBarLab:setSpriteFrame("teamImageUI_img27.png")
    expBarLab:setPosition(cc.p(expBar:getContentSize().width - 30, 5))
    expBarLab:setOpacity(0)
    expBar:addChild(expBarLab,10)
    local movenature = cc.MoveBy:create(0.3, cc.p(0,25))
    local fadenature = cc.FadeIn:create(0.3)
    local spawnnature = cc.Spawn:create(movenature,fadenature)
    local seq = cc.Sequence:create(cc.DelayTime:create(0.25),spawnnature,cc.Spawn:create(cc.MoveBy:create(0.5, cc.p(0,5)),cc.FadeOut:create(0.5)))
    local callFunc = cc.CallFunc:create(function()
        expBarLab:removeFromParent()
    end)
    expBarLab:runAction(cc.Sequence:create(seq,callFunc))
end

--[[
--! @function teamPiaoNature
--! @desc 点击道具飘字
--! @param param 飘字列表
--! @param count 飘字 
--! @return 
--]]
function TeamGradeNode:teamPiaoNature(str)
    local str = str
    local natureLab = cc.Label:createWithTTF("-" .. str, UIUtils.ttfName, 30)
    -- natureLab:setName("natureLabLab")
    natureLab:setColor(cc.c3b(118,238,0))
    natureLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
    local userTexpView = self._viewMgr:getNavigation("global.UserInfoView"):getUI("bg.bar.energyLab") 
    natureLab:setPosition(cc.p(userTexpView:getContentSize().width/2,0))
    userTexpView:addChild(natureLab,10)
    local movenature = cc.MoveBy:create(0.3, cc.p(0,-35))
    local fadenature = cc.FadeOut:create(0.8)
    local spawnnature = cc.Spawn:create(movenature,fadenature)
    local callFunc = cc.CallFunc:create(function()
        natureLab:removeFromParent()
    end)
    local seqnature = cc.Sequence:create(spawnnature,callFunc)
    natureLab:runAction(seqnature)
end

return TeamGradeNode

