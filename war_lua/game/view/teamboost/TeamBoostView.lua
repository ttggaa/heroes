--[[
    Filename:    TeamBoostView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-10-24 15:35:13
    Description: File description
--]]

local TeamBoostView = class("TeamBoostView", BaseView)
-- local TEAMBOOST_HIGHMAX = 8
function TeamBoostView:ctor(data)
    TeamBoostView.super.ctor(self)
    -- self._teamId = tonumber(data.teamId)
    if not data then
        data = {}
    end
    self._teamId = data.teamId 
    self._callback = data.callback
end

function TeamBoostView:onInit()
    self._selectTeamIndex = 0
    self:addAnimBg()

    local closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(closeBtn, function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("teamboost.TeamBoostView")
        end
        if self._callback then
            self._callback()
        end
        self:close()
    end)

    local btn_rule = self:getUI("bg.layer.btn_rule")
    self:registerClickEvent(btn_rule, function()
        self._viewMgr:showDialog("teamboost.TeamBoostDescDialog")
    end)

    self._teamboost = self:getUI("bg.layer.image_frame.teamboostBtn.txt")
    self._teamboost:setColor(UIUtils.colorTable.ccUIMenuBtnColor1)
    -- self._teamboost:enable2Color(1, UIUtils.colorTable.ccUIMenuBtnColor2)
    self._teamboost:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._teamboost:setFontSize(44)
    self._teamboostBtn = self:getUI("bg.layer.image_frame.teamboostBtn")
    self._image_frame = self:getUI("bg.layer.image_frame")

    self._lab3 = self:getUI("bg.layer.lab3")

    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    -- self._teamData = self._teamModel:getData()

    local bgl = self:getUI("bg.bgl")
    local bgr = self:getUI("bg.bgr")
    bgl:loadTexture("asset/bg/bg_magic.png")
    bgr:loadTexture("asset/bg/bg_magic.png")

    local txt = self:getUI("bg.layer.btn_rule.txt")
    txt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._btnPanel1 = self:getUI("bg.layer.btnPanel1")
    self._maxPanel = self:getUI("bg.layer.maxPanel")
    self._btnPanel = self:getUI("bg.layer.btnPanel")

    self._label40 = self:getUI("bg.layer.Label_40")
    self._times = self:getUI("bg.layer.times")
    self._daojishi = self:getUI("bg.layer.daojishi")
    self._daojishi:setVisible(false)

    self._timeTip = self:getUI("bg.layer.timeTip")
    self._timeTip:setVisible(false)

    self._natureTip = self:getUI("bg.layer.natureTip")
    self._natureTip:setVisible(false)
    local closeTip = self:getUI("bg.layer.natureTip.closePanel")
    self:registerClickEvent(closeTip, function()
        self._natureTip:setVisible(false)
    end)

    -- 提示点击动画
    local itemPanel = self:getUI("bg.layer.itemPanel")
    self._btn1Anim = mcMgr:createViewMC("tishikuang_teamyangcheng", true, false)
    self._btn1Anim:setPosition(itemPanel:getContentSize().width*0.5,itemPanel:getContentSize().height*0.5)
    self._btn1Anim:setScaleX(1.03)
    itemPanel:addChild(self._btn1Anim, 100)

    local trainBtn = self:getUI("bg.layer.btnPanel.trainBtn")
    self:registerClickEvent(trainBtn, function()
        self:upTeamBoostLevel(1)
        print("普通培养")
    end)

    local expertTrainBtn = self:getUI("bg.layer.btnPanel.expertTrainBtn")
    self:registerClickEvent(expertTrainBtn, function()
        self:upTeamBoostLevel(2)
        print("高级培养")
    end)

    -- tips
    self._tips = self:getUI("bg.layer.tipLayer")
    self._tips:setVisible(false)
    local techniquePanel = self:getUI("bg.layer.techniquePanel")
    self:registerClickEvent(techniquePanel, function()
        self:setTips()
        self._tips:setVisible(true)
    end)

    local closeTip = self:getUI("bg.layer.tipLayer.closePanel")
    self:registerClickEvent(closeTip, function()
        self._tips:setVisible(false)
    end)

    self._buyTimes = self:getUI("bg.layer.buyTimes")
    self:registerClickEvent(self._buyTimes, function()
        local playerData = self._modelMgr:getModel("PlayerTodayModel"):getData()
        local viplvl = self._modelMgr:getModel("VipModel"):getData().level 
        local userData = self._modelMgr:getModel("UserModel"):getData() 
        local maxTimes = tab:Vip(viplvl).buyTechNum
        if (maxTimes - playerData["day42"]) <= 0 then
            -- DialogUtils.showLackRes()
            self._buyTipDesTable = {des1 = lang("MF_VIP1")}
            self._viewMgr:showDialog("global.GlobalResTipDialog",self._buyTipDesTable or {},true)
            return
        end
        local buyT = tab:ReflashCost(playerData["day42"]+1).buyTechNum
        -- if userData.gem < buyT then
        --     local param = {callback1 = function()
        --         self._viewMgr:showView("vip.VipView", {viewType = 0})
        --     end}
        --     DialogUtils.showNeedCharge(param)
        --     return
        -- end

        local tnum = self._teamModel:getBoostTimesNum()
        if tnum >= tab:Setting("G_TECHNIQUE_NUM_MAX").value then
            self._viewMgr:showTip("培养次数接近上限，请先去培养")
            return
        end

        local str = "购买" .. tab:Setting("G_BUY_TECH_NUM").value .. "次培养次数(今日还可购买" .. (maxTimes - playerData["day42"]) .. "次培养次数)"
        local param = {goods = str,costNum = buyT, costType = "gem",callback1 = function()
            self:buyTBNum(buyT)
        end}
        DialogUtils.showBuyDialog(param)

        -- print("购买次数", buyT, playerData["day42"], maxTimes)
    end)

    local tip = self:getUI("bg.layer.tip")
    tip:setVisible(false)
    self:registerClickEvent(tip, function()
        print("打开Tip")
    end)

    -- local teamModel = self._modelMgr:getModel("TeamModel")
    local image_frame = self:getUI("bg.layer.image_frame")
    self._teamScore = cc.LabelBMFont:create("1", UIUtils.bmfName_zhandouli)
    self._teamScore:setAnchorPoint(cc.p(0,0.5))
    self._teamScore:setPosition(cc.p(10, 166))
    self._teamScore:setScale(0.7)
    image_frame:addChild(self._teamScore, 1)

    self._addfight = cc.LabelBMFont:create("111", UIUtils.bmfName_zhandouli)
    self._addfight:setAnchorPoint(cc.p(0,0.5))
    self._addfight:setPosition(cc.p(99, 166))
    self._addfight:setScale(0.7)
    self._addfight:setOpacity(0)
    image_frame:addChild(self._addfight, 1)
    
    -- 切换兵团
    local aminBg = self:getUI("bg.layer.image_frame.teamBg.aminBg")
    self:registerClickEvent(aminBg, function()
        self:replaceTeam()
    end)

    local replaceBtn = self:getUI("bg.layer.image_frame.replaceBtn")
    self:registerClickEvent(replaceBtn, function()
        self:replaceTeam()

    end)

    -- 界面设置
    for i=1,4 do
        local itemBg = self:getUI("bg.layer.itemPanel.itemBg" .. i)
        itemBg:setAnchorPoint(0.5,0.5)
        itemBg:setScaleAnim(true)
        itemBg:setPosition(itemBg:getPositionX()+36,itemBg:getPositionY()+36)
        local selectItem1 = mcMgr:createViewMC("xuanzhong_teamyangcheng", true, false,function( _,sender )
        end)
        selectItem1:setName("selectItem1")
        selectItem1:setPosition(itemBg:getContentSize().width*0.5, itemBg:getContentSize().height*0.5)
        itemBg:addChild(selectItem1, 1000)

        local techniqueValue = self:getUI("bg.layer.techniquePanel.techniqueBg" .. i .. ".techniqueValue")
        techniqueValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

        -- local maxLab = self:getUI("bg.layer.techniquePanel.techniqueBg" .. i .. ".techniqueBarBg.maxLab")
        -- maxLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    end

    local teamName = self:getUI("bg.layer.image_frame.teamName")
    -- teamName:setFontName(UIUtils.ttfName)
    teamName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    local needGoldNum = self:getUI("bg.layer.btnPanel.needGoldNum")
    needGoldNum:setString(tab:Setting("G_TECHNIQUE_COMMON").value[1][3])
    local needGemNum = self:getUI("bg.layer.btnPanel.needGemNum")
    needGemNum:setString(tab:Setting("G_TECHNIQUE_SENIER").value[1][3])

    
    -- local tempTeamData = teamModel:getData()
    -- local tempTeamData = teamModel:getAllTeamData()
    if not self._teamId then
        self._teamId = self._teamModel:getBoostTeamId() -- tempTeamData[1].teamId 
    end
    self:checkStage()
    self:reflashUI()
    self:updateSelectItem(0)
    self:scrollToNext()
    self:listenReflash("UserModel", self.updateBoostTimes)
    self:listenReflash("ItemModel", self.updateRightPanel)
end

function TeamBoostView:checkStage()
    local tempTD = self._teamModel:getTeamAndIndexById(self._teamId)
    if tempTD.stage < 6 then
        local tempsData = self._teamModel:getBoostTeamData(self._teamId)
        if table.nums(self._teamModel:getBoostTeamData(self._teamId)) > 0 then
            self._teamId = tempsData[1].teamId
        end
    end
end

function TeamBoostView:updateTeamBoost()
    local highAttrLock = tab:Setting("G_TECHNIQUE_UNLOCK").value
    local teamboost = self._teamModel:getTeamBoostData(self._curSelectTeam)
    local tbStage = TeamUtils:getTeamBoostName(teamboost)
    self._teamboost:setString(lang("TECHINIQUELEVEL_" .. teamboost))
    self._teamboostBtn:loadTexture("globalImageUI_teamboost" .. tbStage[1] .. ".png", 1)
    self._image_frame:loadTexture("teamboost_teambg" .. tbStage[1] .. ".jpg", 1)
    if teamboost < 10 then
        self._lab3:setString("解锁下一奥义需: 所有技巧等级≥" .. highAttrLock[teamboost])
        self._lab3:setVisible(true)
    else
        self._lab3:setVisible(false)
    end
end


function TeamBoostView:replaceTeam()
    if table.nums(self._teamModel:getBoostTeamData(self._teamId)) == 0 then
        local param = {indexId = 1}
        self._viewMgr:showDialog("global.GlobalPromptDialog", param)
        -- self._viewMgr:showTip(lang("TIPS_TECHINIQUE_3"))
        return
    end
    self._viewMgr:showDialog("teamboost.TeamBoostSelectDialog",{teamId = self._teamId, callback = function(teamId)
        self._boostItemId = 0
        self._selectTeamIndex = 0
        self:updateSelectItem(0)
        self._btn1Anim:setVisible(true)
        self._oldGradeNature = nil
        self._teamId = teamId
        self._teamModel:setBoostTeamId(self._teamId)
        self:reflashUI()
        self:scrollToNext()

        -- 切换怪兽特效
        -- local teamBg = self:getUI("bg.layer.image_frame.teamBg.teamBg")
        local aminBg = self:getUI("bg.layer.image_frame.teamBg.aminBg")
        local teamShowMc = mcMgr:createViewMC("redianshanzhen1_leaguerediantexiao", false, true,function( _,sender )
        end,RGBA8888)
        teamShowMc:setPosition(aminBg:getContentSize().width*0.5,10)
        -- teamShowMc:setScale(1.5)
        aminBg:addChild(teamShowMc, 1000)
    end})
end

function TeamBoostView:reflashUI()
    self._maxPanel:setVisible(false)
    self._curSelectTeam = self._teamModel:getTeamAndIndexById(self._teamId)
    self._systeam = tab:Team(self._teamId)

    self._teamScore:setString("a" .. self._curSelectTeam.score)

    -- dump(self._curSelectTeam)
    self._gradeNature = self:setGradeNatureValue()

    self:updateRightPanel()
    self:updateTeamAmin()
    self:updateBoostLevel()
    self:updateTeamBoost()
end

function TeamBoostView:setTips()
    local technique = self._systeam.technique
    for i=1,4 do
        local techniqueTab = tab:Technique(technique[i])
        local labtxt = self:getUI("bg.layer.tipLayer.labtxt" .. i)
        local labValue = self:getUI("bg.layer.tipLayer.labValue" .. i)
        labtxt:setString(lang(techniqueTab.lang))
        local nowValue = 0
        if self._curSelectTeam.tb and self._curSelectTeam.tb[tostring(technique[i])] then
            nowValue = self._curSelectTeam.tb[tostring(technique[i])]
        end
        local str = "+" .. nowValue*techniqueTab.rate .. "%"
        if technique[i] == 5 or technique[i] == 6 then
            str = "+" .. nowValue*techniqueTab.rate
        end
        labValue:setString(str)
    end
end

-- 更新金币钻石和次数
function TeamBoostView:updateBoostTimes()
    local userdata = self._userModel:getData()
    local currentTime = self._userModel:getCurServerTime()

    local maxTimes = tab:Setting("G_TECHNIQUE_NUM_MAX").value
    local timeAdd = tab:Setting("G_TECHNIQUE_NUM_ADD").value

    -- if not userdata["upTbTime"] then
    --     userdata["upTbTime"] = 0
    -- end
    -- if not userdata["tbNum"] then
    --     userdata["tbNum"] = maxTimes
    -- end
    local tempTimesNum, nextTimes = self._teamModel:getBoostTimes()
    local tempTime = userdata["upTbTime"] + timeAdd*60

    self._buyTimes:setVisible(false)
    if (userdata["tbNum"]+tempTimesNum) <= 0 then
        self._buyTimes:setVisible(true)
    end
    print("=timesNum=", tempTimesNum, userdata["tbNum"])
    if (userdata["tbNum"]+tempTimesNum) >= maxTimes then
        self._times:setString(maxTimes .. "/" .. maxTimes)
        self._daojishi:setVisible(false)
        self._label40:setPositionX(517)
        self._times:setPositionX(self._label40:getContentSize().width + self._label40:getPositionX() + 3)
        self._buyTimes:setPositionX(self._times:getContentSize().width + self._times:getPositionX() + 23)
        return
    end
    self._label40:setPositionX(433)
    self._times:setPositionX(self._label40:getContentSize().width + self._label40:getPositionX() + 3)
    self._times:setString((userdata["tbNum"]+tempTimesNum) .. "/" .. maxTimes)
    self._buyTimes:setPositionX(self._times:getContentSize().width + self._times:getPositionX() + 23)
    self._daojishi:setVisible(true)
    
    if userdata["tbNum"] <= maxTimes then
        self._daojishi:stopAllActions()
        local tempT = nextTimes - currentTime
        if self._daojishi:isVisible() == true then
            local tempValue = tempT
            local minute = math.floor(tempValue/60)
            tempValue = tempValue - minute*60
            local second = math.fmod(tempValue, 60)
            local showTime = string.format("%.2d:%.2d", minute, second)
            self._daojishi:setString(" (下次恢复:" .. showTime .. ")")
        end
        local seq = cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            tempT = tempT - 1
            local tempValue = tempT
            local minute = math.floor(tempValue/60)
            tempValue = tempValue - minute*60
            local second = math.fmod(tempValue, 60)
            local showTime = string.format("%.2d:%.2d", minute, second)
            self._daojishi:setString(" (下次恢复:" .. showTime .. ")")
            if tempT <= 0 then
                self._daojishi:stopAllActions()
                self:updateBoostTimes()
            end
        end))
        self._daojishi:runAction(cc.RepeatForever:create(seq))
    end
end


-- 更新等级 和高级属性
function TeamBoostView:updateBoostLevel()
    local highAttr = self._systeam.highAttr
    local techniqiueshow = self._systeam.techniqiueshow

    local highAttrLock = tab:Setting("G_TECHNIQUE_UNLOCK").value
    local boostlevel = self:getTeamBoostLevel()
    for i=1,9 do
        local expertBg = self:getUI("bg.layer.expertPanel.expertBg" .. i)
        local expertLab = self:getUI("bg.layer.expertPanel.expertBg" .. i .. ".expertLab")
        -- local expertValue = self:getUI("bg.layer.expertPanel.expertBg" .. i .. ".expertValue")
        local expertIcon = self:getUI("bg.layer.expertPanel.expertBg" .. i .. ".expertIcon")
        -- local expertLimit = self:getUI("bg.layer.expertPanel.expertBg" .. i .. ".expertLimit")

        -- expertLab:setString(lang("ATTR_" .. highAttr[i][1]))
        expertLab:setString(lang("TECHINIQUESHOW_" .. techniqiueshow[i]))

        local str = "+" .. highAttr[i][2] .. "%"
        if highAttr[i][1] == 3 or highAttr[i][1] == 6 then
            str = "+" .. highAttr[i][2]
        end
        -- expertValue:setString(str)
        expertIcon:loadTexture("teamboost_img6.png", 1)

        if self:getTeamBoostLock(i) then
            expertLab:setColor(UIUtils.colorTable.ccUIBasePromptColor)
            expertIcon:setScale(1)
            expertIcon:setSaturation(0)
            if self:isTeamBoostLock(i) then
            -- if true then
                local indexId = i
                local param = {old = indexId, new = indexId+1, techniqiueshow = techniqiueshow[i], callback = function()
                    local mc3 = mcMgr:createViewMC("shuxingjihuoshuaguang_lianmengjihuo", false, true)
                    mc3:setPosition(0, expertBg:getContentSize().height*0.5)
                    expertBg:addChild(mc3, 100)

                    local mc3 = mcMgr:createViewMC("bingtuanqianghua_qianghua", false, true)
                    mc3:setPosition(self._teamboostBtn:getContentSize().width*0.5-12, self._teamboostBtn:getContentSize().height*0.5-10)
                    self._teamboostBtn:addChild(mc3, 100)
                end}
                self:scrollToNext()
                self._viewMgr:showDialog("teamboost.TeamBoostUpgradeDialog", param)
                print("动画动画动画动画动画")
            end
        else
            expertLab:setColor(UIUtils.colorTable.ccUIUnLockColor)
            -- expertValue:setColor(UIUtils.colorTable.ccUIUnLockColor)
            -- expertLimit:setColor(UIUtils.colorTable.ccUIUnLockColor)
            -- expertLimit:setString("(每项等级≥" .. highAttrLock[i] .. ")")
            -- expertLimit:setVisible(true)
            expertIcon:loadTexture("teamboost_img7.png", 1)
            expertIcon:setScale(1)
            expertIcon:setSaturation(-100)
        end

        local downY
            local posX, posY
            registerTouchEvent(
                expertBg,
                function (_, _, y)
                    downY = y
                    clickFlag = false
                    expertBg:setBrightness(40)
                end, 
                function (_, _, y)
                    if downY and math.abs(downY - y) > 5 then
                        clickFlag = true
                    end
                end, 
                function ()
                    if clickFlag == false then 
                        self:setBoostNatureTip(i)
                    end
                    expertBg:setBrightness(0)
                end,
                function ()
                    expertBg:setBrightness(0)
                end)
            expertBg:setSwallowTouches(false)

    end

    local lab2 = self:getUI("bg.layer.image_frame.lab2")
    lab2:setString("Lv. " .. boostlevel)
    
end

-- 更新等级 和高级属性
function TeamBoostView:setBoostNatureTip(index)
    local indexId = index
    local highAttr = self._systeam.highAttr
    local techniqiueshow = self._systeam.techniqiueshow
    local highAttrLock = tab:Setting("G_TECHNIQUE_UNLOCK").value
    local boostlevel = self:getTeamBoostLevel()

    local titleName = self:getUI("bg.layer.natureTip.titleName")
    local expertLab = self:getUI("bg.layer.natureTip.expertLab")
    local expertIcon = self:getUI("bg.layer.natureTip.expertIcon")
    local expertLimit = self:getUI("bg.layer.natureTip.expertLimit")
    local expertValue = self:getUI("bg.layer.natureTip.expertValue")

    titleName:setString(lang("TECHINIQUESHOW_" .. techniqiueshow[indexId]))
    expertLab:setString(lang("ATTR_" .. highAttr[indexId][1]))
    local str = "+" .. highAttr[indexId][2] .. "%"
    if highAttr[indexId][1] == 3 or highAttr[indexId][1] == 6 then
        str = "+" .. highAttr[indexId][2]
    end
    expertValue:setString(str)
    expertIcon:loadTexture("teamboost_nature" .. highAttr[indexId][1] .. ".png", 1)

    if self:getTeamBoostLock(indexId) then
    -- if i == 1 then
        -- expertValue:setColor(UIUtils.colorTable.ccUIBasePromptColor)
        -- expertIcon:loadTexture("teamboost_nature1.png", 1)
        expertIcon:setScale(1)
        expertIcon:setSaturation(0)
        expertLimit:setVisible(false)
    else
        -- expertValue:setColor(UIUtils.colorTable.ccUIUnLockColor)
        -- expertLimit:setColor(UIUtils.colorTable.ccUIUnLockColor)
        expertLimit:setString("解锁条件: 所有技巧等级≥" .. highAttrLock[indexId])
        expertLimit:setVisible(true)
        -- expertIcon:loadTexture("teamboost_img7.png", 1)
        -- expertIcon:setScale(0.8)
        -- expertIcon:setSaturation(-100)
    end
    self._natureTip:setVisible(true)
end

-- 获取等级
function TeamBoostView:getTeamBoostLevel()
    local level = 0
    local boostD = self._curSelectTeam.tb
    if boostD and table.nums(boostD) > 0 then
        for k,v in pairs(boostD) do
            level = level + v
        end
    end
    return level
end

-- 判断加锁
function TeamBoostView:getTeamBoostLock(index)
    local flag = true -- false
    local boostD = self._curSelectTeam.tb
    local highAttrLock = tab:Setting("G_TECHNIQUE_UNLOCK").value
    if boostD and table.nums(boostD) > 0 then
        for k,v in pairs(boostD) do
            if v < highAttrLock[index] then
                flag = false
                break
            end
        end
        if flag == true and table.nums(boostD) < 4  then
            flag = false
        end
    else
        flag = false
    end

    return flag
end

-- 解锁动画
function TeamBoostView:isTeamBoostLock(index)
    local flag = false
    if self._gradeNature and self._oldGradeNature then
        if self._gradeNature[index] ~= self._oldGradeNature[index] then
            flag = true
        end
    end
    return flag
end


-- 更新右侧数据
function TeamBoostView:updateRightPanel()
    local technique = self._systeam.technique

    for i=1,4 do
        local techniqueTab = tab:Technique(technique[i])

        local itemBg = self:getUI("bg.layer.itemPanel.itemBg" .. i)
        local techniqueLab = self:getUI("bg.layer.techniquePanel.techniqueBg" .. i .. ".techniqueLab")
        local techniqueIcon = self:getUI("bg.layer.techniquePanel.techniqueBg" .. i .. ".techniqueIcon")
        local techniqueValue = self:getUI("bg.layer.techniquePanel.techniqueBg" .. i .. ".techniqueValue")
        local techniqueBar = self:getUI("bg.layer.techniquePanel.techniqueBg" .. i .. ".techniqueBarBg.techniqueBar")
        local lvlLab = self:getUI("bg.layer.techniquePanel.techniqueBg" .. i .. ".techniqueBarBg.lvlLab")
        -- local maxLab = self:getUI("bg.layer.techniquePanel.techniqueBg" .. i .. ".techniqueBarBg.maxLab")


        local itemIcon = itemBg:getChildByName("itemIcon")

        local itemModel = self._modelMgr:getModel("ItemModel")
        local _, itemNum = itemModel:getItemsById(techniqueTab.itemId)
        local param = {itemId = techniqueTab.itemId, eventStyle = 0, num = itemNum}
        if itemIcon then
            IconUtils:updateItemIconByView(itemIcon, param)
        else
            itemIcon = IconUtils:createItemIconById(param)
            itemIcon:setName("itemIcon")
            itemIcon:setScale(0.7)
            itemIcon:setPosition(cc.p(0,0))
            itemBg:addChild(itemIcon)
        end

        self:registerClickEvent(itemBg, function()
            print("高级培养", techniqueTab.itemId)
            self._boostItemId = techniqueTab.itemId
            self:updateSelectItem(i)
        end)

        techniqueIcon:loadTexture("teamboost_icon" .. technique[i] .. ".png", 1)
        techniqueLab:setString(lang(techniqueTab.name))
        if i ~= self._selectTeamIndex then
            techniqueValue:setString("+" .. techniqueTab.add[1] .. "~" .. techniqueTab.add[2])
        end

        -- dump(self._curSelectTeam)

        local nowValue = 0
        local maxValue = tab:TeamQuality(self._curSelectTeam.stage).techniqueLevel
        if self._curSelectTeam.tb and self._curSelectTeam.tb[tostring(technique[i])] then
            nowValue = self._curSelectTeam.tb[tostring(technique[i])]
        end
        if not maxValue then
            maxValue = tab:Setting("G_TECHNIQUE_NUM_MAX").value
        end
        local strPercent = math.floor(nowValue/maxValue*100)

        techniqueBar:setPercent(strPercent)
        lvlLab:setString("Lv. " .. nowValue .. "/" .. maxValue)
        if nowValue == maxValue then
            -- maxLab:setVisible(true)
            lvlLab:setColor(UIUtils.colorTable.ccUIBaseColor2)
            
            if self._selectTeamIndex == i then
                self._maxPanel:setVisible(true)
                self._btnPanel:setVisible(false)
            end
        else
            -- lvlLab:disableEffect()
            lvlLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
            -- maxLab:setVisible(false)
        end
        lvlLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    end

    self:updateBoostTimes()
end

-- 点击物品事件状态
function TeamBoostView:updateSelectItem(index)
    -- print("=================", self._boostItemId)
    self._selectTeamIndex = index
    if (self._boostItemId and self._boostItemId ~= 0) then
        self._btnPanel1:setVisible(false)
        self._btnPanel:setVisible(true)
        self._btn1Anim:setVisible(false)
    else
        self._btn1Anim:setVisible(true)
        self._btnPanel1:setVisible(true)
        self._btnPanel:setVisible(false)
    end

    local maxValue = tab:TeamQuality(self._curSelectTeam.stage).techniqueLevel
    local technique = self._systeam.technique
    for i=1,4 do
        local itemBg = self:getUI("bg.layer.itemPanel.itemBg" .. i)
        local selectItem = itemBg:getChildByName("selectItem1")
        local techniqueValue = self:getUI("bg.layer.techniquePanel.techniqueBg" .. i .. ".techniqueValue")
        techniqueValue:setColor(cc.c3b(250, 146, 26))
        if i == index then
            selectItem:setVisible(true)
            techniqueValue:setVisible(true)

            local techniqueTab = tab:Technique(technique[i])
            local techniqueValue = self:getUI("bg.layer.techniquePanel.techniqueBg" .. i .. ".techniqueValue")
            techniqueValue:setString("+" .. techniqueTab.add[1] .. "~" .. techniqueTab.add[2])

            local nowValue = 0
            if self._curSelectTeam.tb and self._curSelectTeam.tb[tostring(technique[i])] then
                nowValue = self._curSelectTeam.tb[tostring(technique[i])]
            end
            if not maxValue then
                maxValue = tab:Setting("G_TECHNIQUE_NUM_MAX").value
            end
            if nowValue == maxValue then
               self._maxPanel:setVisible(true)
               self._btnPanel:setVisible(false)
               techniqueValue:setVisible(false)
            else
                self._maxPanel:setVisible(false)
                self._btnPanel:setVisible(true)
            end
        else
            selectItem:setVisible(false)
            techniqueValue:setVisible(false)
        end
    end
end

-- 进行培养
function TeamBoostView:upTeamBoostLevel(upType)
    if self._boostItemId then
        local itemModel = self._modelMgr:getModel("ItemModel")
        local userData = self._modelMgr:getModel("UserModel"):getData()
        local _, tempItemCount = itemModel:getItemsById(self._boostItemId)

        -- local tempItems, itemNum = itemModel:getItemsById(self._boostItemId)
        if tempItemCount < 1 then
            print("打开获取物品界面")
            local toolD = tab:Tool(self._boostItemId)
            local approach = toolD["approach"]
            self._viewMgr:showDialog("bag.DialogAccessTo", {goodsId = self._boostItemId}, true)
            return
        end
        
        if upType == 2 then
            if userData.gem < tab:Setting("G_TECHNIQUE_SENIER").value[1][3] then
                local param = {callback1 = function()
                    self._viewMgr:showView("vip.VipView", {viewType = 0})
                end}
                DialogUtils.showNeedCharge(param)
                return
            end

            -- vip 判断
            -- local playerData = self._modelMgr:getModel("PlayerTodayModel"):getData()
            -- local viplvl = self._modelMgr:getModel("VipModel"):getData().level 
            -- local maxTimes = tab:Vip(viplvl).technique
            -- if (maxTimes - playerData["day34"]) <= 0 then
            --     self._viewMgr:showTip("高级培养次数用完")
            --     return
            -- end
        else
            if userData.gold < tab:Setting("G_TECHNIQUE_COMMON").value[1][3] then
                DialogUtils.showLackRes()
                return
            end
        end
        if table.nums(self._teamModel:getBoostTeamData(self._teamId)) == 0 then
            local param = {indexId = 1}
            self._viewMgr:showDialog("global.GlobalPromptDialog", param)
            return
        end
        local tempTimesNum, nextTimes = self._teamModel:getBoostTimes()
        if (userData["tbNum"]+tempTimesNum) <= 0 then
            -- self._viewMgr:showTip("培养次数不足")
            local viplvl = self._modelMgr:getModel("VipModel"):getData().level 
            local maxTimes = tab:Vip(viplvl).buyTechNum
            local playerData = self._modelMgr:getModel("PlayerTodayModel"):getData()
            local buyT = tab:ReflashCost(playerData["day42"]+1).buyTechNum

            if (maxTimes - playerData["day42"]) <= 0 then
                self._buyTipDesTable = {des1 = lang("MF_VIP1")}
                self._viewMgr:showDialog("global.GlobalResTipDialog",self._buyTipDesTable or {},true)
                return
            end
            local str = "购买" .. tab:Setting("G_BUY_TECH_NUM").value .. "次培养次数(今日还可购买" .. (maxTimes - playerData["day42"]) .. "次培养次数)"
            local param = {goods = str,costNum = buyT, costType = "gem",callback1 = function()
                self:buyTBNum(buyT)
            end}
            DialogUtils.showBuyDialog(param)
            return
        end
        if tempItemCount > 0 then
            local param = {tId = self._teamId, upType = upType, itemId = self._boostItemId}
            self._oldTeamData = clone(self._curSelectTeam)
            self._oldGradeNature = clone(self._gradeNature)
            self._oldFight = TeamUtils:updateFightNum()
            self._serverMgr:sendMsg("TeamBoostServer", "upTeamBoostLevel", param, true, {}, function (result)
                -- self:autoUpgradeStageEquipFinish(result)
                -- dump(result, "++", 10)
                -- self:upTeamBoostLevelFinish(result)
                self._viewMgr:lock(-1)
                self._gradeNature = self:setGradeNatureValue()
                local teamImgBg = self:getUI("bg.layer")
                TeamUtils:setFightAnim(teamImgBg, {oldFight = self._oldFight, newFight = TeamUtils:updateFightNum(), x = teamImgBg:getContentSize().width*0.5-100, y = teamImgBg:getContentSize().height - 80})

                self:reflashUI()
                self:setAnim()

                local tempTeam,_ = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(self._oldTeamData.teamId)
                self:setFightAnim({newFight = tempTeam.score, oldFight = self._oldTeamData.score})
                -- local boostValue = self._curSelectTeam["tb"][tostring(1)] - self._oldTeamData["tb"][tostring(1)]
                -- print("boostValue=====", boostValue)
                
            end, function(errorId)
                if tonumber(errorId) == 3906 then
                    self._viewMgr:showTip("技巧已达最大等级")
                elseif tonumber(errorId) == 3907 then
                    self._viewMgr:showTip("培养次数不足")
                elseif tonumber(errorId) == 3903 then
                    self._viewMgr:showTip(lang("TIPS_TECHINIQUE_2"))
                end
            end)
        -- else
        --     self._viewMgr:showTip(lang("TIPS_TECHINIQUE_1"))
        end
    else
        self._viewMgr:showTip("请选择物品")
    end
end

-- 物品框特效
function TeamBoostView:setAnim()
-- 物品移动
    if self._selectTeamIndex == 0 then
        return
    end
    local itemBg = self:getUI("bg.layer.itemPanel.itemBg" .. self._selectTeamIndex)

    local inView = itemBg:getChildByName("itemIcon")
    if not inView then
        return
    end

    local bg = self:getUI("bg.layer")  
    local mc3 = inView:clone()
    
    mc3:setTouchEnabled(false)
    mc3:setAnchorPoint(cc.p(0.5, 0.5))
    mc3:setScale(0.5)
    mc3:setCascadeOpacityEnabled(true)
    bg:addChild(mc3, 10)
    -- local itemCount = mc3:getChildByFullName("itemCount")
    -- if itemCount then
    --     itemCount:removeFromParent()
    -- end

    local techniqueBarBg = self:getUI("bg.layer.techniquePanel.techniqueBg" .. self._selectTeamIndex .. ".techniqueBarBg")
    local techniqueBarBgWorldPoint = techniqueBarBg:convertToWorldSpace(cc.p(65, 11))
    local mcPos = bg:convertToNodeSpace(cc.p(techniqueBarBgWorldPoint.x,techniqueBarBgWorldPoint.y))

    local itemWorldPoint = inView:convertToWorldSpace(cc.p(50, 50))
    local pos1 = bg:convertToNodeSpace(cc.p(itemWorldPoint.x,itemWorldPoint.y))
    mc3:setPosition(cc.p(pos1.x,pos1.y))

    local moveSp = cc.MoveTo:create(0.35, cc.p(mcPos.x,mcPos.y)) 
    local scaleSp = cc.ScaleTo:create(0.35, 0.16) 
    local callFunc = cc.CallFunc:create(function()
        local techniqueValue = self:getUI("bg.layer.techniquePanel.techniqueBg" .. self._selectTeamIndex .. ".techniqueValue")
        
        local techniqueBg = self:getUI("bg.layer.techniquePanel.techniqueBg" .. self._selectTeamIndex)

        local techniqueValue1 = cc.Label:createWithTTF("", UIUtils.ttfName, 20)
        techniqueValue1:setAnchorPoint(cc.p(0, 0.5))
        techniqueValue1:setPosition(cc.p(techniqueValue:getPositionX(), techniqueValue:getPositionY()))
        techniqueValue1:setString(techniqueValue:getString())
        techniqueValue1:setColor(techniqueValue:getColor())
        techniqueValue1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        techniqueBg:addChild(techniqueValue1, -1)

        self:setTechniqueValue()
        techniqueValue1:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.1),
            cc.CallFunc:create(function()
                techniqueValue:setColor(cc.c3b(0, 255, 30))
                techniqueValue:setOpacity(0)
                -- self:setTechniqueValue()
            end),
            cc.Spawn:create(cc.MoveBy:create(0.18, cc.p(20, 0)), cc.FadeOut:create(0.3)),
            -- cc.Spawn:create(cc.MoveBy:create(0.1, cc.p(5, 0))), -- , cc.FadeOut:create(0.1)),
            cc.CallFunc:create(function()
                -- self:setTechniqueValue()
            end),
            -- cc.DelayTime:create(3),
            cc.RemoveSelf:create(true)
            ))

        -- techniqueValue:setVisible(false)
        local seq = cc.Sequence:create(cc.MoveBy:create(0, cc.p(-20, 0)) ,cc.DelayTime:create(0.08),cc.Spawn:create(cc.MoveBy:create(0.1, cc.p(20, 0)), cc.FadeIn:create(0.1)))
        techniqueValue:runAction(seq)
        -- self:setTechniqueValue()
    end)

    local callFunc1 = cc.CallFunc:create(function()
        local mc2 = mcMgr:createViewMC("jindutiaoshanguang_teamyangcheng", false, true)
        mc2:setPosition(techniqueBarBg:getContentSize().width*0.5,techniqueBarBg:getContentSize().height*0.5)
        techniqueBarBg:addChild(mc2, 100)
        self._viewMgr:unlock()
    end)

    local seq = cc.Sequence:create(callFunc, cc.Spawn:create(scaleSp, moveSp, cc.FadeTo:create(0.35, 100)), callFunc1, cc.RemoveSelf:create(true))
    mc3:runAction(seq) 
end

-- 培养之后数值处理
function TeamBoostView:setTechniqueValue()
    for i=1,4 do
        local techniqueValue = self:getUI("bg.layer.techniquePanel.techniqueBg" .. i .. ".techniqueValue")
        if techniqueValue:isVisible() then
            techniqueValue:setColor(cc.c3b(0, 255, 30))
            local tempvalue = 0
            if self._oldTeamData["tb"] and self._oldTeamData["tb"][tostring(self._systeam.technique[i])] then
                tempvalue = self._oldTeamData["tb"][tostring(self._systeam.technique[i])]
            end
            value = self._curSelectTeam["tb"][tostring(self._systeam.technique[i])] - tempvalue
            techniqueValue:setString("+" .. value)
        end
    end
end

-- 高级属性处理
function TeamBoostView:setGradeNatureValue()
    local tempNature = {}
    local highNum = 0
    local highAttr = self._systeam.highAttr
    local highAttrLock = tab:Setting("G_TECHNIQUE_UNLOCK").value
    for i=1,9 do
        local highTempNum = self:getTeamBoostLock(i)
        tempNature[i] = highTempNum
        if highTempNum == true then
            highNum = highNum + 1
        end
    end
    self._hightAttrNum = highNum
    return tempNature
end

-- 更新军团展示怪兽
function TeamBoostView:updateTeamAmin()
    local backQuality = self._teamModel:getTeamQualityByStage(self._curSelectTeam.stage)
    local teamName = self:getUI("bg.layer.image_frame.teamName")
    if backQuality[2] > 0 then
        teamName:setString(lang(self._systeam.name) .. "+" .. backQuality[2])
    else
        teamName:setString(lang(self._systeam.name))
    end
    teamName:setColor(UIUtils.colorTable["ccColorQuality" .. backQuality[1]])

    local aminBg = self:getUI("bg.layer.image_frame.teamBg.aminBg")
    local backBgNode = aminBg:getChildByName("backBgNode")
    local pos = self._systeam.xiaoren
    local teamBg = self:getUI("bg.layer.image_frame.teamBg.teamBg")
    if teamBg then
        if self._systeam["race"][1] > 106 then
            teamBg:loadTexture("asset/uiother/dizuo/teamBgDizuo101.png", 0)
        else
            teamBg:loadTexture("asset/uiother/dizuo/teamBgDizuo" .. self._systeam["race"][1] .. ".png", 0)
        end
    end
    if backBgNode then
        backBgNode:setTexture("asset/uiother/steam/"..self._systeam.steam..".png")
    else
        backBgNode = cc.Sprite:create("asset/uiother/steam/"..self._systeam.steam..".png")
        backBgNode:setAnchorPoint(cc.p(0.5, 0))
        backBgNode:setScale(0.5)
        backBgNode:setName("backBgNode")
        aminBg:addChild(backBgNode)
    end
    backBgNode:setPosition(cc.p(aminBg:getContentSize().width/2+pos[1], pos[2]-10))
end

function TeamBoostView:getAsyncRes()
    return 
        {
            {"asset/ui/magic.plist", "asset/ui/magic.png"},
        }
end

function TeamBoostView:getBgName()
    return "bg_007.jpg"
end

-- function TeamBoostView:setNavigation()
--     self._viewMgr:showNavigation("global.UserInfoView",{types = {"Gold","Gem","Texp"},title = "globalTitleUI_team.png"})
-- end

function TeamBoostView:setNoticeBar()
    self._viewMgr:hideNotice(true)
end

function TeamBoostView:setFightAnim(inTable)
    local fightLabel = self._teamScore
    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function()
        audioMgr:playSound("PowerCount")
    end)))
    local addfight = self._addfight

    fightLabel:stopAllActions()
    addfight:setString("+" .. (inTable.newFight - inTable.oldFight))
    local tempGunlun, tempFight 
    tempGunlun = inTable.newFight - inTable.oldFight
    tempFight = inTable.oldFight

    addfight:setPositionX(fightLabel:getContentSize().width*fightLabel:getScaleX() + fightLabel:getPositionX())
    local fightNum = tempGunlun / 20
    local numsch = 1
    local sequence = cc.Sequence:create(
        cc.ScaleTo:create(0.05, 0.8),
        cc.Repeat:create(cc.Sequence:create(cc.DelayTime:create(0.05),cc.CallFunc:create(function()
            fightLabel:setString("a" .. (tempFight + math.ceil(fightNum * numsch)))
            numsch = numsch + 1
        end)), 20),
        cc.CallFunc:create(function()
            fightLabel:setString("a" .. inTable.newFight)
            addfight:setPositionX(fightLabel:getContentSize().width*fightLabel:getScaleX() + fightLabel:getPositionX())
            addfight:runAction(cc.Sequence:create(
                cc.FadeIn:create(0.2),
                cc.FadeTo:create(0.3, 80),
                -- cc.FadeOut:create(0.3),
                cc.FadeIn:create(0.2),
                cc.FadeOut:create(0.3)
                )
            )
        end),
        cc.ScaleTo:create(0.05, 0.7)
        )
    fightLabel:runAction(sequence)
end

function TeamBoostView:buyTBNum(buyT)
    local userData = self._modelMgr:getModel("UserModel"):getData() 
    if userData.gem < buyT then
        local param = {callback1 = function()
            self._viewMgr:showView("vip.VipView", {viewType = 0})
        end}
        DialogUtils.showNeedCharge(param)
        return
    end

    self._serverMgr:sendMsg("TeamBoostServer", "buyTBNum", {}, true, {}, function (result)
        
    end, function(errorId)
        if tonumber(errorId) == 3906 then
            self._viewMgr:showTip("技巧已达最大等级")
        elseif tonumber(errorId) == 3907 then
            self._viewMgr:showTip("培养次数不足")
        elseif tonumber(errorId) == 203 then
            self._viewMgr:showTip("钻石数量不足")
        end
    end)
end

function TeamBoostView:scrollToNext(flag)
    local scrollView = self:getUI("bg.layer.expertPanel")
    local innerScroll = scrollView:getInnerContainer()

    local selectedIndex = self._hightAttrNum + 1
    local posY = -41*(9-selectedIndex)

    posY = posY + 22
    if posY < -219 then
        posY = -219
    elseif posY > 0 then
        posY = 0
    end
    print("self=======", self._hightAttrNum, posY)
    innerScroll:runAction(cc.MoveTo:create(0.2, cc.p(0, posY)))
    if flag == true then
        innerScroll:stopAllActions()
        innerScroll:setPositionY(posY)
    end
end

-- -- 更新等级 和高级属性
-- function TeamBoostView:updateBoostLevel()
--     local highAttr = self._systeam.highAttr
--     local highAttrLock = tab:Setting("G_TECHNIQUE_UNLOCK").value
--     local boostlevel = self:getTeamBoostLevel()
--     for i=1,9 do
--         local expertBg = self:getUI("bg.layer.expertPanel.expertBg" .. i)
--         local expertLab = self:getUI("bg.layer.expertPanel.expertBg" .. i .. ".expertLab")
--         local expertValue = self:getUI("bg.layer.expertPanel.expertBg" .. i .. ".expertValue")
--         local expertIcon = self:getUI("bg.layer.expertPanel.expertBg" .. i .. ".expertIcon")
--         local expertLimit = self:getUI("bg.layer.expertPanel.expertBg" .. i .. ".expertLimit")

--         expertLab:setString(lang("ATTR_" .. highAttr[i][1]))
--         local str = "+" .. highAttr[i][2] .. "%"
--         if highAttr[i][1] == 3 or highAttr[i][1] == 6 then
--             str = "+" .. highAttr[i][2]
--         end
--         expertValue:setString(str)
--         expertIcon:loadTexture("teamboost_nature" .. highAttr[i][1] .. ".png", 1)

--         if self:getTeamBoostLock(i) then
--         -- if i == 1 then
--             expertBg:setOpacity(255)
--             expertLab:setColor(UIUtils.colorTable.ccUIBasePromptColor)
--             expertValue:setColor(UIUtils.colorTable.ccUIBasePromptColor)
--             -- expertIcon:loadTexture("teamboost_nature1.png", 1)
--             expertIcon:setScale(1)
--             expertIcon:setSaturation(0)
--             expertLimit:setVisible(false)
--             -- print("isTeamBoostLock···", self:isTeamBoostLock(i))
--             if self:isTeamBoostLock(i) then
--             -- if true then
--                 -- print("动画动画动画动画动画")
--                 -- self:scrollToNext(true)
--                 local bg = self:getUI("bg")
--                 local expProgWorldPoint = expertIcon:convertToWorldSpace(cc.p(21, 22))
--                 local mcPos = bg:convertToNodeSpace(cc.p(expProgWorldPoint.x,expProgWorldPoint.y))

--                 expertBg:setOpacity(65)
--                 expertLab:setColor(UIUtils.colorTable.ccUIUnLockColor)
--                 expertValue:setColor(UIUtils.colorTable.ccUIUnLockColor)
--                 expertLimit:setColor(UIUtils.colorTable.ccUIUnLockColor)
--                 expertLimit:setString("(每项等级≥" .. highAttrLock[i] .. ")")
--                 expertLimit:setVisible(true)
--                 expertIcon:loadTexture("globalImageUI5_treasureLock.png", 1)
--                 expertIcon:setScale(0.8)
--                 expertIcon:setSaturation(-100)

--                 local posX = bg:getContentSize().width*0.5
--                 local posY = bg:getContentSize().height*0.5+80

--                 local callFunc1 = cc.CallFunc:create(function()
--                     local mc2 = mcMgr:createViewMC("jihuoxinshuxing_lianmengjihuo", false, true, function (_, sender)
--                     end)
--                     mc2:setPosition(posX, posY)
--                     bg:addChild(mc2, 100)

--                     expProgWorldPoint = expertIcon:convertToWorldSpace(cc.p(21, 22))
--                     mcPos = bg:convertToNodeSpace(cc.p(expProgWorldPoint.x,expProgWorldPoint.y))
--                 end)
--                 local callFunc2 = cc.CallFunc:create(function()
--                     local mc3 = mcMgr:createViewMC("jihuoshuxingguang_lianmengjihuo", false, true)
--                     mc3:setPosition(posX, posY)
--                     bg:addChild(mc3, 100)
--                 end)
--                 local callFunc3 = cc.CallFunc:create(function()
--                     local mcMove = mcMgr:createViewMC("feixingxian_lianmengjihuo", false, true)
--                     mcMove:setPosition(posX, posY)
--                     mcMove:setName("mcMove")
--                     bg:addChild(mcMove, 100)

--                     local pos3 = {}
--                     local angle = math.deg(math.atan((posX - mcPos.x)/(posY - mcPos.y))) 
--                     pos3.x = math.sin(math.rad(math.abs(angle))) * 300
--                     pos3.y = math.sin(math.rad(90-math.abs(angle))) * 300
--                     angle = 90 + angle 
--                     mcMove:setRotation(angle)

--                     local tempX = mcPos.x+pos3.x
--                     local tempY = mcPos.y+pos3.y
--                     print("========", tempX, tempY)
--                     local move1 = cc.MoveTo:create(0.5, cc.p(tempX, tempY))
--                     mcMove:runAction(move1)
--                 end)
--                 local callFunc4 = cc.CallFunc:create(function()
--                     -- local mc3 = mcMgr:createViewMC("jihuoshuxingguang_lianmengjihuo", false, true)
--                     -- mc3:setPosition(posX, posY)
--                     -- bg:addChild(mc3, 100)
--                     -- expertIcon:setPurityColor(255, 255, 255)
--                     expertIcon:loadTexture("teamboost_nature" .. highAttr[i][1] .. ".png", 1)
--                     expertIcon:setScale(1)
--                     expertIcon:setSaturation(0)
--                 end)
--                 local callFunc5 = cc.CallFunc:create(function()
--                     -- expertIcon:loadTexture("teamboost_nature" .. highAttr[i][1] .. ".png", 1)
--                     expertLimit:setVisible(false)
--                     expertBg:setOpacity(255)
--                     expertLab:setColor(UIUtils.colorTable.ccUIBasePromptColor)
--                     expertValue:setColor(UIUtils.colorTable.ccUIBasePromptColor)

--                     local mc3 = mcMgr:createViewMC("shuxingjihuoshuaguang_lianmengjihuo", false, true)
--                     mc3:setPosition(0, expertBg:getContentSize().height*0.5)
--                     expertBg:addChild(mc3, 100)
--                 end)

--                 local callFunc0 = cc.CallFunc:create(function()
--                     self:scrollToNext()
--                 end)
--                 local seq = cc.Sequence:create(callFunc0, cc.DelayTime:create(0.8), callFunc1, 
--                     cc.DelayTime:create(1.5), callFunc2, 
--                     cc.DelayTime:create(0.2), callFunc3, 
--                     cc.DelayTime:create(0.6), callFunc4,
--                     -- cc.DelayTime:create(0.6), cc.RotateTo:create(0.02, 50), cc.RotateTo:create(0.02, -50), cc.RotateTo:create(0.01, 0), callFunc4,
--                     cc.ScaleTo:create(0.3, 2), cc.ScaleTo:create(0.2, 0.8), cc.ScaleTo:create(0.05, 1), callFunc5)

--                 expertIcon:runAction(seq)
--                 -- local mc2 = mcMgr:createViewMC("shuaxinguangxiao_shuaxinguangxiao", false, true)
--                 -- mc2:setPosition(expertBg:getContentSize().width*0.5,expertBg:getContentSize().height*0.5)
--                 -- expertBg:addChild(mc2, 100)
--             end
--         else
--             expertBg:setOpacity(65)
--             expertLab:setColor(UIUtils.colorTable.ccUIUnLockColor)
--             expertValue:setColor(UIUtils.colorTable.ccUIUnLockColor)
--             expertLimit:setColor(UIUtils.colorTable.ccUIUnLockColor)
--             expertLimit:setString("(每项等级≥" .. highAttrLock[i] .. ")")
--             expertLimit:setVisible(true)
--             expertIcon:loadTexture("globalImageUI5_treasureLock.png", 1)
--             expertIcon:setScale(0.8)
--             expertIcon:setSaturation(-100)
--         end
--     end

--     local lab2 = self:getUI("bg.layer.image_frame.lab2")
--     lab2:setString("Lv. " .. boostlevel)
-- end

return TeamBoostView