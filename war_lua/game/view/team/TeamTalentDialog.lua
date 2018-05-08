--[[
    Filename:    TeamTalentDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-04-05 10:08:07
    Description: File description
--]]

-- 兵团天赋
local TeamTalentDialog = class("TeamTalentDialog", BasePopView)

function TeamTalentDialog:ctor(data)
    TeamTalentDialog.super.ctor(self)
    if not data then
        data = {}
    end
    self._teamId = data.teamId or 104
end

function TeamTalentDialog:onInit()
    self:registerClickEventByName("bg.closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("team.TeamTalentDialog")
        end
        if self._state ~= 0 then
            local flag = false
            for i=1,10 do
                if self._selectTrainTimes[i] == 1 then
                    flag = true
                    break
                end
            end
            if flag == true then
                self._viewMgr:showDialog("global.GlobalSelectDialog",
                    {desc = lang("TIP_TIANFU_QUXIAO"),
                    alignNum = 1,
                    -- button1 = "确定",
                    -- button2 = "取消", 
                    callback1 = function ()
                        self:close()
                    end,
                    callback2 = function()

                    end},true)   
            else
                self:close() 
            end
        else
            self:close()
        end
    end)  

    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")

    self._trainType = 1
    self._state = 0
    self:resetTrain()
    local title1 = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title1, 1, 1)


    local bg = self:getUI("bg")
    bg:setVisible(true)
    local closeTip = self:getUI("closeTip")
    local tip = self:getUI("tip")
    local maxTip = self:getUI("maxTip")
    closeTip:setVisible(false)
    tip:setVisible(false)
    maxTip:setVisible(false)
    self:registerClickEvent(closeTip, function()
        closeTip:setVisible(false)
        tip:setVisible(false)
        maxTip:setVisible(false)
    end)

    local image_frame = self:getUI("bg.leftPanel.image_frame")
    self._teamScore = cc.LabelBMFont:create("1", UIUtils.bmfName_zhandouli)
    self._teamScore:setAnchorPoint(cc.p(0,0.5))
    self._teamScore:setPosition(cc.p(186, 181))
    self._teamScore:setScale(0.5)
    image_frame:addChild(self._teamScore, 10)


    -- local btnPanel2 = self:getUI("bg.btnPanel2")
    -- self._oteamScore = cc.LabelBMFont:create("", UIUtils.bmfName_zhandouli)
    -- self._oteamScore:setAnchorPoint(cc.p(1,0.5))
    -- self._oteamScore:setPosition(cc.p(130, 90))
    -- self._oteamScore:setScale(0.5)
    -- btnPanel2:addChild(self._oteamScore, 10)

    self._oScoreLab = self:getUI("bg.btnPanel2.Label_26")
    self._upArrow = self:getUI("bg.btnPanel2.upArrow")
    local btnPanel2 = self:getUI("bg.btnPanel2")
    self._nteamScore = cc.LabelBMFont:create("", UIUtils.bmfName_zhandouli)
    self._nteamScore:setAnchorPoint(cc.p(0,0.5))
    self._nteamScore:setPosition(cc.p(125, 103))
    self._nteamScore:setScale(0.5)
    btnPanel2:addChild(self._nteamScore, 10)

    local wenziLab = self:getUI("bg.leftPanel.image_frame.wenziLab")
    wenziLab:setLocalZOrder(10)

    self._addfight = cc.LabelBMFont:create("111", UIUtils.bmfName_zhandouli)
    self._addfight:setAnchorPoint(cc.p(0,0.5))
    self._addfight:setPosition(cc.p(186, 181))
    self._addfight:setScale(0.5)
    self._addfight:setOpacity(0)
    image_frame:addChild(self._addfight, 10)

    local level = self:getUI("bg.leftPanel.skillPanel.level")
    level:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    -- local image_frame = self:getUI("bg.leftPanel.image_frame")
    -- self._ttScore = cc.LabelBMFont:create("1", UIUtils.bmfName_zhandouli)
    -- self._ttScore:setAnchorPoint(cc.p(0,0.5))
    -- self._ttScore:setPosition(cc.p(175, -6))
    -- self._ttScore:setScale(0.8)
    -- image_frame:addChild(self._ttScore, 1)

    local wenziLab = self:getUI("bg.leftPanel.image_frame.wenziLab")
    wenziLab:setColor(cc.c3b(255, 236, 67))
    wenziLab:enable2Color(1, cc.c4b(255, 183, 25, 255))
    wenziLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._selectPanel = self:getUI("bg.selectPanel")
    self._selectPanel:setVisible(false)
    self._leftPanel = self:getUI("bg.leftPanel")
    self._leftPanel:setVisible(true)

    local teamName = self:getUI("bg.leftPanel.image_frame.teamName")

    self._teamData = self._teamModel:getTeamAndIndexById(self._teamId)
    dump(self._teamData)
    self._systeam = tab:Team(self._teamId)

    self:updateClickBtn()

    self:listenReflash("ItemModel", self.updateCost)
    self:listenReflash("UserModel", self.updateCost)
    self:listenReflash("TeamModel", self.reflashUI)
    self:updateSelect(1)
    self:updateTeamAmin()
    self:updateBtnPanel()
    self:updateTalentPanel()
end

function TeamTalentDialog:reflashUI(inData)
    if not inData then
        inData = {}
    end

    -- self._teamScore:setString("a" .. self._teamData.score)

    local image_frame = self:getUI("bg.leftPanel.image_frame")
    local wenziLab = self:getUI("bg.leftPanel.image_frame.wenziLab")
    local tScore = self._teamData.tScore or 0
    self._teamScore:setString(tScore)
    self._oteamScore = tScore
    -- self._oteamScore:setString(tScore)
    local posX = image_frame:getContentSize().width - wenziLab:getContentSize().width - self._teamScore:getContentSize().width*self._teamScore:getScaleX()
    posX = posX*0.5
    wenziLab:setPositionX(posX)
    posX = posX + wenziLab:getContentSize().width
    self._teamScore:setPositionX(posX)

    self:updateClassSkillIcon()
end

function TeamTalentDialog:resetTrain()
    self._selectTrainTimes = {}
    for i=1,10 do
        self._selectTrainTimes[i] = 0
    end
end

function TeamTalentDialog:updateClickBtn()
    self._check1 = self:getUI("bg.btnPanel1.checktype1")
    self._check2 = self:getUI("bg.btnPanel1.checktype2")
    self._check3 = self:getUI("bg.btnPanel1.checktype3")
    self._check1:addEventListener(function()
        self:updateSelect(1)
    end)
    self._check2:addEventListener(function()
        self:updateSelect(2)
    end)
    self._check3:addEventListener(function()
        self:updateSelect(3)
    end)

    -- 培养
    local trainOneBtn = self:getUI("bg.btnPanel1.trainOneBtn")
    self:registerClickEvent(trainOneBtn, function()
        -- self._viewMgr:showDialog("team.TeamTalentUpgradeDialog", {teamData = self._teamData})
        self:upTrainTalent(1)
    end)

    local trainTenBtn = self:getUI("bg.btnPanel1.trainTenBtn")
    self:registerClickEvent(trainTenBtn, function()
        self:upTrainTalent(10)
    end)

    local saveBtn = self:getUI("bg.btnPanel2.saveBtn")
    saveBtn:setTitleText("保留")
    self:registerClickEvent(saveBtn, function()
        self:saveTalent()
    end)

    local cancelBtn = self:getUI("bg.btnPanel2.cancelBtn")
    cancelBtn:setTitleText("放弃")
    self:registerClickEvent(cancelBtn, function()
        self:cancelSelectBtn()
    end)

    for i=1,10 do
        local select1 = self:getUI("bg.selectPanel.select" .. i)
        self:registerClickEvent(select1, function()
            self:selectTrainNatrue(i, true)
        end)
        local check = self:getUI("bg.selectPanel.select" .. i .. ".check")
        check:addEventListener(function()
            self:selectTrainNatrue(i)
        end)
    end
end

function TeamTalentDialog:cancelSelectBtn()
    local flag = false
    for i=1,10 do
        if self._selectTrainTimes[i] == 1 then
            flag = true
            break
        end
    end
    if flag == true then
        self._viewMgr:showDialog("global.GlobalSelectDialog",
            {desc = lang("TIP_TIANFU_QUXIAO"),
            alignNum = 1,
            -- button1 = "确定",
            -- button2 = "取消", 
            callback1 = function ()
                self._state = 0
                self:updateBtnPanel()
                self:updateTalentPanel()
                self:resetTrain()
            end,
            callback2 = function()

            end},true)    
    else
        self._state = 0
        self:updateBtnPanel()
        self:updateTalentPanel()
        self:resetTrain()
    end
end


function TeamTalentDialog:selectTrainNatrue(indexId, isCheck)
    local check = self:getUI("bg.selectPanel.select" .. indexId .. ".check")
    local flag = check:isSelected()
    if isCheck == true then
        flag = not flag
    end
    local select1 = self:getUI("bg.selectPanel.select" .. indexId)
    self:updateSelectCell(select1, flag, indexId)
    self:showTrainExp()
end



function TeamTalentDialog:progressTalent(data)
    if not data then
        return
    end
    dump(data, "data==========", 2)
    local talentTab = self._systeam.talent
    local xishu = TeamUtils.TalentXishu 
    for i=1,10 do
        local select1 = self:getUI("bg.selectPanel.select" .. i)
        local selectImg = select1:getChildByFullName("select")
        selectImg:setVisible(false)
        local flag = false
        local tempData = data[tostring(i)]
        if not tempData then
            return
        end
        local tuijianValue = 0
        for j=1,4 do
            local nature = select1:getChildByFullName("nature" .. j)
            local talentAttr = talentTab[j][1]
            local talentType = talentTab[j][2]
            local value = tempData[tostring(talentAttr)]
            if nature then
                nature:setString(value)
                if value > 0 then
                    nature:setColor(UIUtils.colorTable.ccUIBaseColor9)
                elseif value < 0 then
                    nature:setColor(UIUtils.colorTable.ccUIBaseColor6)
                else
                    nature:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
                    nature:setString("--")
                end
            end
            
            tuijianValue = tuijianValue + xishu[talentType]*value
        end
        if tuijianValue > 0 then
            flag = true
        end
        print("tuijianValue=====", tuijianValue, flag)

        local times = select1:getChildByFullName("times")
        if times then
            times:setString("第" .. i .. "次")
        end
        self:updateSelectCell(select1, flag, i)

        local tuijian = select1:getChildByFullName("tuijian")
        if tuijian then
            if flag == true then
                tuijian:setVisible(true)
            else
                tuijian:setVisible(false)
            end
        end
    end
end

function TeamTalentDialog:updateSelectCell(inView, flag, indexId)
    local selectBg = inView:getChildByFullName("selectBg")
    local check = inView:getChildByFullName("check")
    if flag == true then
        self._selectTrainTimes[indexId] = 1
        if selectBg then
            selectBg:setVisible(true)
        end
        if check then
            check:setSelected(true)
        end
    else
        self._selectTrainTimes[indexId] = 0
        if selectBg then
            selectBg:setVisible(false)
        end
        if check then
            check:setSelected(false)
        end
    end
end

-- 选择培养方式
function TeamTalentDialog:updateSelect(_type)
    if _type == 1 then
        self._check1:setSelected(true)
        self._check2:setSelected(false)
        self._check3:setSelected(false)
    elseif _type == 2 then
        self._check1:setSelected(false)
        self._check2:setSelected(true)
        self._check3:setSelected(false)
    elseif _type == 3 then
        self._check1:setSelected(false)
        self._check2:setSelected(false)
        self._check3:setSelected(false)
    end
    self._trainType = _type
    self:updateCost()
end

-- 更新消耗
function TeamTalentDialog:updateCost()
    local itemId = self._systeam.talentTool 
    local tempItems, tempItemCount = self._itemModel:getItemsById(itemId)
    local costNum = tab:Setting("G_TEAM_TALENT_COST").value 
    local needItemNum = costNum[self._trainType]
    local costNum = self:getUI("bg.btnPanel1.costBg1.costNum")
    costNum:setString(tempItemCount .. "/" .. needItemNum)

    if needItemNum > tempItemCount then
        costNum:setColor(UIUtils.colorTable.ccUIBaseColor6)
    else
        costNum:setColor(UIUtils.colorTable.ccUIBaseColor9)
    end

    local costBg1 = self:getUI("bg.btnPanel1.costBg1")
    local costBg2 = self:getUI("bg.btnPanel1.costBg2")
    if self._trainType == 1 then
        costBg1:setVisible(true)
        costBg2:setVisible(false)
    else
        costBg1:setVisible(true)
        costBg2:setVisible(true)

        local costNum = tab:Setting("G_TEAM_TALENT_COST_TOOL").value 
        local itemData = costNum[self._trainType]
        local needItemNum = itemData[3]
        if itemData[1] == "gem" then
            local costNum = self:getUI("bg.btnPanel1.costBg2.costNum")
            local tempItemCount = self._modelMgr:getModel("UserModel"):getData().gem
            costNum:setString(tempItemCount .. "/" .. needItemNum)

            local costImg = self:getUI("bg.btnPanel1.costBg2.costImg")
            costImg:loadTexture("globalImageUI_littleDiamond.png", 1)
            costImg:setScale(1)

            if needItemNum > tempItemCount then
                costNum:setColor(UIUtils.colorTable.ccUIBaseColor6)
            else
                costNum:setColor(UIUtils.colorTable.ccUIBaseColor9)
            end
        else

        end
    end
end

-- 天赋培养
function TeamTalentDialog:upTrainTalent(_type)
    local itemId = self._systeam.talentTool 
    local costNum = tab:Setting("G_TEAM_TALENT_COST").value 
    local _, tempItemCount = self._itemModel:getItemsById(itemId)
    local trainType = self._trainType or 1
    local needItemNum = costNum[trainType]*_type
    print("==========", needItemNum)
    if self:isTrainTalentMax() == true then
        self._viewMgr:showTip(lang("TIP_TIANFU_YIMAN"))
        return
    end
    if not tempItemCount then
        tempItemCount = 0
    end

    local costData = tab:Setting("G_TEAM_TALENT_COST_TOOL").value 
    local itemData = costData[trainType]
    local oneGemNum = itemData[3] or 0
    local needGemNum = oneGemNum*_type 
    local userData = self._userModel:getData()
    local gemNum = userData.gem or 0
    if tempItemCount < needItemNum then
        local userLvl = userData.lvl or 1
        if userLvl < 41 then
            self._viewMgr:showTip(lang("TIP_TIANFU_BUZU"))
        else
            local param = {indexId = 10}
            print("itemId=========", itemId)
            self._viewMgr:showDialog("global.GlobalPromptDialog", param)
        end
    elseif needGemNum > gemNum then
        local param = {callback1 = function()
            self._viewMgr:showView("vip.VipView", {viewType = 0})
        end}
        DialogUtils.showNeedCharge(param)
    else
        local param = {teamId = self._teamData.teamId, type = trainType, num = _type}
        self:trainTalent(param)
    end
end

-- 是否培养满级
function TeamTalentDialog:isTrainTalentMax()
    local talentTab = self._systeam.talent
    local ttalent = self._teamData.tt
    local teamQualityTab = tab:TeamQuality(self._teamData.stage)
    local flag = true

    for i=1,4 do
        local talentAttr = talentTab[i][1]
        local talentType = talentTab[i][2]
        if ttalent then
            local talentValue = ttalent[tostring(talentAttr)]
            local expMaxValue = teamQualityTab["teamTalent_" .. talentType]
            if talentValue and tonumber(talentValue) ~= tonumber(expMaxValue) then
                flag = false
                break
            end
        else
            flag = false
            break
        end
    end
    return flag
end

-- 更新面板状态 
function TeamTalentDialog:updateBtnPanel()
    local btnPanel1 = self:getUI("bg.btnPanel1")
    local btnPanel2 = self:getUI("bg.btnPanel2")
    local leftPanel = self:getUI("bg.leftPanel")
    local selectPanel = self:getUI("bg.selectPanel")
    local tishi = self:getUI("bg.tishi")
    if self._state == 0 then
        leftPanel:setVisible(true)
        btnPanel1:setVisible(true)
        btnPanel2:setVisible(false)
        tishi:setVisible(false)
        selectPanel:setVisible(false)
    elseif self._state == 1 then -- 培养一次
        leftPanel:setVisible(true)
        btnPanel1:setVisible(false)
        btnPanel2:setVisible(true)
        tishi:setVisible(true)
        selectPanel:setVisible(false)
    elseif self._state == 10 then -- 培养10次
        leftPanel:setVisible(false)
        btnPanel1:setVisible(false)
        btnPanel2:setVisible(true)
        tishi:setVisible(true)
        selectPanel:setVisible(true)
    end
end

-- 展示tips 
function TeamTalentDialog:showTip()
    local talentSkill = tab:Setting("G_TEAM_TALENTSKILL").value
    dump(talentSkill)

    local skillPanel = self:getUI("bg.leftPanel.skillPanel")
    local level,_ = self._teamModel:getSkillLevelAndScore(self._teamData)

    local tip = self:getUI("tip")
    local maxTip = self:getUI("maxTip")
    if level >= TeamUtils.teamMaxTalentLevel then
        level = TeamUtils.teamMaxTalentLevel
        maxTip:setVisible(true)
        tip:setVisible(false)
    else
        tip:setVisible(true)
        maxTip:setVisible(false)
    end

    local cs = self._systeam.cs
    local skillType = cs[1]
    local skillId = cs[2]
    local sysSkill = SkillUtils:getTeamSkillByType(skillId, skillType)
    local skillBg = self:getUI("tip.iconBg")
    local skillIcon = skillBg:getChildByName("skillIcon")
    if skillIcon ~= nil then 
        IconUtils:updateTeamSkillIconByView(skillIcon, {teamSkill = sysSkill ,isGray = isGray ,eventStyle = 0, teamData = self._teamData, level = tempLevel})
    else
        skillIcon = IconUtils:createTeamSkillIconById({teamSkill = sysSkill, eventStyle = 0, teamData = self._teamData, level = 0})
        skillIcon:setName("skillIcon")
        skillIcon:setPosition(-10, -8)
        skillBg:addChild(skillIcon)
    end

    local name = self:getUI("tip.name")
    name:setString(lang(sysSkill.name))

    local levelLab = self:getUI("tip.level")
    levelLab:setString("Lv." .. level)

    local richtextBg = self:getUI("tip.baoxiangTip1.desBg")
    local desc = SkillUtils:handleSkillDesc1(lang(sysSkill.des), self._teamData, level, 0)
    desc = string.gsub(desc, "562600", "fae6c8")
    local richText = richtextBg:getChildByName("richText")
    if richText then
        richText:removeFromParent()
    end
    richText = RichTextFactory:create(desc, richtextBg:getContentSize().width, richtextBg:getContentSize().height)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(richtextBg:getContentSize().width*0.5, richtextBg:getContentSize().height - richText:getInnerSize().height*0.5)
    richText:setName("richText")
    richtextBg:addChild(richText)

    local tishiDes = self:getUI("tip.baoxiangTip2.tishiDes")
    local nextlv = level + 1
    if nextlv >= TeamUtils.teamMaxTalentLevel then
        nextlv = TeamUtils.teamMaxTalentLevel
    end
    local str = "天赋战力达到" .. talentSkill[nextlv]
    tishiDes:setString(str)

    local richtextBg = self:getUI("tip.baoxiangTip2.desBg")
    local desc = SkillUtils:handleSkillDesc1(lang(sysSkill.des), self._teamData, level, 1)
    desc = string.gsub(desc, "562600", "fae6c8")
    local richText = richtextBg:getChildByName("richText")
    if richText then
        richText:removeFromParent()
    end
    richText = RichTextFactory:create(desc, richtextBg:getContentSize().width, richtextBg:getContentSize().height)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(richtextBg:getContentSize().width*0.5, richtextBg:getContentSize().height - richText:getInnerSize().height*0.5)
    richText:setName("richText")
    richtextBg:addChild(richText)


    local skillBg = self:getUI("maxTip.iconBg")
    local skillIcon = skillBg:getChildByName("skillIcon")
    if skillIcon ~= nil then 
        IconUtils:updateTeamSkillIconByView(skillIcon, {teamSkill = sysSkill ,isGray = isGray ,eventStyle = 0, teamData = self._teamData, level = tempLevel})
    else
        skillIcon = IconUtils:createTeamSkillIconById({teamSkill = sysSkill, eventStyle = 0, teamData = self._teamData, level = 0})
        skillIcon:setName("skillIcon")
        skillIcon:setPosition(-10, -8)
        skillBg:addChild(skillIcon)
    end

    local name = self:getUI("maxTip.name")
    name:setString(lang(sysSkill.name))

    local levelLab = self:getUI("maxTip.level")
    levelLab:setString("Lv." .. level)

    local richtextBg = self:getUI("maxTip.baoxiangTip1.desBg")
    local desc = SkillUtils:handleSkillDesc1(lang(sysSkill.des), self._teamData, level, 0)
    desc = string.gsub(desc, "562600", "fae6c8")
    local richText = richtextBg:getChildByName("richText")
    if richText then
        richText:removeFromParent()
    end
    richText = RichTextFactory:create(desc, richtextBg:getContentSize().width, richtextBg:getContentSize().height)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(richtextBg:getContentSize().width*0.5, richtextBg:getContentSize().height - richText:getInnerSize().height*0.5)
    richText:setName("richText")
    richtextBg:addChild(richText)

    local closeTip = self:getUI("closeTip")
    closeTip:setVisible(true)
end

function TeamTalentDialog:updateClassSkillIcon()
    local cs = self._systeam.cs
    local skillType = cs[1]
    local skillId = cs[2]
    local sysSkill = SkillUtils:getTeamSkillByType(skillId, skillType)
    local skillBg = self:getUI("bg.leftPanel.skillPanel.skillBg")
    local skillIcon = skillBg:getChildByName("skillIcon")
    if skillIcon ~= nil then 
        IconUtils:updateTeamSkillIconByView(skillIcon, {teamSkill = sysSkill ,isGray = isGray ,eventStyle = 0, teamData = self._teamData, level = tempLevel})
    else
        skillIcon = IconUtils:createTeamSkillIconById({teamSkill = sysSkill, eventStyle = 0, teamData = self._teamData, level = 0})
        skillIcon:setName("skillIcon")
        skillIcon:setPosition(-15, -12)
        skillIcon:setScale(0.9)
        skillBg:addChild(skillIcon)
    end

    self:registerClickEvent(skillIcon, function()
        self:showTip()
    end)

    local level,_ = self._teamModel:getSkillLevelAndScore(self._teamData)
    if level >= TeamUtils.teamMaxTalentLevel then
        level = TeamUtils.teamMaxTalentLevel
    end
    local levelLab = self:getUI("bg.leftPanel.skillPanel.level")
    levelLab:setString("Lv." .. level)

    local name = self:getUI("bg.leftPanel.skillPanel.name")
    name:setString(lang(sysSkill.name))

    local level,_ = self._teamModel:getSkillLevelAndScore(self._teamData)

    local richtextBg = self:getUI("bg.leftPanel.skillPanel.richtextBg")
    local desc = SkillUtils:handleSkillDesc1(lang(sysSkill.des), self._teamData, level, 0)
    local richText = richtextBg:getChildByName("richText")
    if richText then
        richText:removeFromParent()
    end
    richText = RichTextFactory:create(desc, richtextBg:getContentSize().width, richtextBg:getContentSize().height)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(richtextBg:getContentSize().width*0.5, richtextBg:getContentSize().height - richText:getInnerSize().height*0.5)
    richText:setName("richText")
    richtextBg:addChild(richText)

    -- self._viewMgr:showDialog("team.TeamTalentUpgradeDialog", {teamData = self._teamData})
end


-- 更新进度条数据
function TeamTalentDialog:updateTalentPanel()
    local talentTab = self._systeam.talent
    dump(talentTab)
    local teamQualityTab = tab:TeamQuality(self._teamData.stage)
    dump(teamQualityTab)
    local ttalent = self._teamData.tt
    for i=1,4 do
        local nameLab = self:getUI("bg.selectPanel.name" .. i)
        local talentBg = self:getUI("bg.talentPanel.talentBg" .. i)
        local talentLab = self:getUI("bg.talentPanel.talentBg" .. i .. ".talentLab")
        local talentValue1 = self:getUI("bg.talentPanel.talentBg" .. i .. ".talentValue1")
        local talentValue2 = self:getUI("bg.talentPanel.talentBg" .. i .. ".talentValue2")
        local talentBar1 = self:getUI("bg.talentPanel.talentBg" .. i .. ".talentBarBg.talentBar1")
        talentBar1:setVisible(false)
        local talentBar1 = self:getUI("bg.talentPanel.talentBg" .. i .. ".talentBarBg.bar1")
        local talentBar2 = self:getUI("bg.talentPanel.talentBg" .. i .. ".talentBarBg.talentBar2")
        local talentBar3 = self:getUI("bg.talentPanel.talentBg" .. i .. ".talentBarBg.talentBar3")
        talentBar2:setVisible(false)
        talentBar3:setVisible(false)
        local talentAttr = talentTab[i][1]
        local talentType = talentTab[i][2]
        local nameValue = lang("ATTR_" .. talentAttr)
        talentLab:setString(nameValue)
        nameLab:setString(nameValue)
        if utf8.len(nameValue) > 2 then
            nameLab:setFontSize(18)
        else
            nameLab:setFontSize(20)
        end
        local expMaxValue = teamQualityTab["teamTalent_" .. talentType]
        local expValue = 0
        if ttalent and ttalent[tostring(talentAttr)] then
            expValue = ttalent[tostring(talentAttr)]
        end
        local value1 = expValue
        local value2 = "/" ..  expMaxValue
        if talentType ~= 3 then
            value1 = expValue .. "%"
            value2 = value2 .. "%"
        end
        talentValue1:setString(value1)
        talentValue2:setString(value2)
        talentValue2:disableEffect()
        talentValue2:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

        local bar1Value = expValue/expMaxValue*100
        local barValue = expValue/expMaxValue
        talentBar1:setScaleX(barValue)
        -- talentBar1:setPercent(bar1Value)
        talentBar2:setPercent(bar1Value)
        talentBar3:setPercent(bar1Value)
    end
end

-- 更新军团展示怪兽
function TeamTalentDialog:updateTeamAmin()
    local backQuality = self._teamModel:getTeamQualityByStage(self._teamData.stage)
    local teamName = self:getUI("bg.leftPanel.image_frame.teamName")
    teamName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    if backQuality[2] > 0 then
        teamName:setString(lang(self._systeam.name) .. "+" .. backQuality[2])
    else
        teamName:setString(lang(self._systeam.name))
    end
    teamName:setColor(UIUtils.colorTable["ccColorQuality" .. backQuality[1]])

    local classLabelIcon = self:getUI("bg.leftPanel.image_frame.teamclassImg")
    classLabelIcon:loadTexture(IconUtils.iconPath .. tab:Team(self._teamData.teamId).classlabel .. ".png", 1)
    local image_frame = self:getUI("bg.leftPanel.image_frame")
    local posX = image_frame:getContentSize().width - classLabelIcon:getContentSize().width*classLabelIcon:getScaleX() - teamName:getContentSize().width
    posX = posX*0.5
    classLabelIcon:setPositionX(posX)
    posX = posX + classLabelIcon:getContentSize().width*classLabelIcon:getScaleX()
    teamName:setPositionX(posX)

    local aminBg = self:getUI("bg.leftPanel.image_frame.teamBg.aminBg")
    local backBgNode = aminBg:getChildByName("backBgNode")
    local pos = self._systeam.xiaoren
    local teamBg = self:getUI("bg.leftPanel.image_frame.teamBg.teamBg")
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

    local costImg = self:getUI("bg.btnPanel1.costBg1.costImg")
    local itemId = self._systeam.talentTool 
    local toolTab = tab:Tool(itemId)
    costImg:loadTexture(toolTab.art .. ".png", 1)
end


-- 天赋培养
function TeamTalentDialog:trainTalent(param)
    if not param then
        return
    end
    self._state = param.num
    -- self._viewMgr:lock(-1)
    self._serverMgr:sendMsg("TeamServer", "trainTalent", param, true, {}, function (result)
        dump(result, 'resutl======', 3)
        self:trainTalentFinish(result)
    end)
end

function TeamTalentDialog:trainTalentFinish(result)
    if result["d"] == nil then 
        return 
    end
    self._cTalent = result["cTalent"]
    if self._state == 10 then
        self:progressTalent(result["cTalent"])
    end
    
    self:updateBtnPanel()
    self:showTrainExp()
    self:updateCost()
    self._modelMgr:getModel("ActivityModel"):pushUserEvent()
    -- self._viewMgr:unlock()
end


function TeamTalentDialog:getTeamTalentSelectData()
    local selectData = {}
    print("self._state=======", self._state)
    for k,v in pairs(self._cTalent["1"]) do
        selectData[k] = 0
    end
    if self._state == 10 then
        for k,v in pairs(self._cTalent) do
            if self._selectTrainTimes[tonumber(k)] == 1 then
                for kk,vv in pairs(v) do
                    selectData[kk] = (selectData[kk]*100 + vv*100)/100
                end
            end
        end
    else
        selectData = self._cTalent["1"]
    end
    return selectData
end

function TeamTalentDialog:showTrainExp()
    local selectData = self:getTeamTalentSelectData()
    dump(selectData, "selectDat===")
    dump(self._selectTrainTimes, "selectDat===")
    local nFight = 0
    local sTalentTab = tab:Setting("G_TEAM_TALENT_SCORE").value

    local talentTab = self._systeam.talent
    local teamQualityTab = tab:TeamQuality(self._teamData.stage)
    local ttalent = self._teamData.tt
    for i=1,4 do
        local talentBg = self:getUI("bg.talentPanel.talentBg" .. i)
        local talentLab = talentBg:getChildByFullName("talentLab")
        local talentValue1 = talentBg:getChildByFullName("talentValue1")
        local talentValue2 = talentBg:getChildByFullName("talentValue2")

        local talentBar1 = self:getUI("bg.talentPanel.talentBg" .. i .. ".talentBarBg.talentBar1")
        talentBar1:setVisible(false)
        local talentBar1 = self:getUI("bg.talentPanel.talentBg" .. i .. ".talentBarBg.bar1")
        local talentBar2 = self:getUI("bg.talentPanel.talentBg" .. i .. ".talentBarBg.talentBar2")
        local talentBar3 = self:getUI("bg.talentPanel.talentBg" .. i .. ".talentBarBg.talentBar3")

        local talentAttr = talentTab[i][1]
        local talentType = talentTab[i][2]
                    
        local tempValue = selectData[tostring(talentAttr)]

        local expMaxValue = teamQualityTab["teamTalent_" .. talentType]
        local expValue = 0
        if ttalent and ttalent[tostring(talentAttr)] then
            expValue = tonumber(ttalent[tostring(talentAttr)])
        end
        local addMax = expMaxValue - expValue
        if tempValue and tempValue > addMax then
            tempValue = addMax
        end

        local nowValue = expValue + tempValue
        local tempValueStr = tempValue
        if (tempValue + expValue) < 0 then
            tempValue = 0
        end
        local bar1Value = expValue/expMaxValue*100
        local bar2Value = nowValue/expMaxValue*100
        local barValue1 = expValue/expMaxValue
        local barValue2 = nowValue/expMaxValue

        talentBar2:setPercent(bar1Value)
        talentBar3:setPercent(bar2Value)
        if tempValue and tempValue > 0 then
            talentValue2:disableEffect()
            talentValue2:setColor(UIUtils.colorTable.ccUIBaseColor9)
            -- talentValue2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            if talentType ~= 3 then
                tempValueStr = string.format("+%." .. talentType .. "f", tempValue)
            else
                tempValueStr = string.format("+%d", tempValue)
            end
            talentBar1:setScaleX(barValue1)
            -- talentBar1:setPercent(bar1Value)
            talentBar2:setVisible(false)
            talentBar3:setVisible(true)
        elseif tempValue and tempValue < 0 then
            talentValue2:disableEffect()
            talentValue2:setColor(UIUtils.colorTable.ccUIBaseColor6)
            -- talentValue2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            if talentType ~= 3 then
                tempValueStr = string.format("%." .. talentType .. "f", tempValue)
            else
                tempValueStr = string.format("%d", tempValue)
            end
            talentBar1:setScaleX(barValue2)
            -- talentBar1:setPercent(bar2Value)
            talentBar2:setVisible(true)
            talentBar3:setVisible(false)
        else
            talentValue2:disableEffect()
            talentValue2:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
            tempValueStr = "+0"
            if barValue2 < 0 then
                barValue2 = 0
            end
            talentBar1:setScaleX(barValue2)
            -- talentBar1:setPercent(bar2Value)
            talentBar2:setVisible(false)
            talentBar3:setVisible(false)
        end

        local value1 = expValue
        local value2 = tempValueStr
        nFight = nFight + (value1+value2)*sTalentTab[talentType]
        if talentType ~= 3 then
            value1 = expValue .. "%"
            value2 = value2 .. "%"
        end

        talentValue1:setString(value1)
        talentValue2:setString(value2)
    end
    local nFight = math.ceil(nFight)
    self._nteamScore:setString(nFight)
    local str = nFight - self._oteamScore
    if str > 0 then
        self._upArrow:loadTexture("arenaReport_jiantou2.png", 1)
        self._oScoreLab:setColor(UIUtils.colorTable.ccUIBaseColor9)
    elseif str < 0 then
        self._upArrow:loadTexture("arenaReport_jiantou1.png", 1)
        self._oScoreLab:setColor(UIUtils.colorTable.ccUIBaseColor6)
    end
    self._oScoreLab:setString(str)
end

-- 获取选择的属性
function TeamTalentDialog:getSelectTrain()
    local selectTrain = {}
    local flag = false
    if self._state == 10 then
        for i=1,10 do
            local check = self:getUI("bg.selectPanel.select" .. i .. ".check")
            if check:isSelected() == true then
                flag = true
                table.insert(selectTrain, i)
            end
        end
    else
        flag = true
        table.insert(selectTrain, 1)
    end
    return selectTrain, flag
end

-- 保存天赋
function TeamTalentDialog:saveTalent()
    local tempData, flag = self:getSelectTrain()
    if flag == false then
        self._state = 0
        self:updateBtnPanel()
        self:updateTalentPanel()
        self:resetTrain()
        return
    end
    local param = {teamId = self._teamData.teamId, tId = json.encode(tempData)}
    self._oldTeamData = copyTab(self._teamData)
    -- self._viewMgr:lock(-1)
    self._oldFight = TeamUtils:updateFightNum()
    self._serverMgr:sendMsg("TeamServer", "saveTalent", param, true, {}, function (result)
        self:saveTalentFinish(result)
    end)
end

function TeamTalentDialog:saveTalentFinish(result)
    if result["d"] == nil then 
        return 
    end

    local tempData, flag = self:getSelectTrain()
    local selectData = self:getTeamTalentSelectData()
    self:teamPiaoNature1(selectData)

    local fightBg = self:getUI("bg")
    TeamUtils:setFightAnim(fightBg, {oldFight = self._oldFight, newFight = TeamUtils:updateFightNum(), x = 350, y = fightBg:getContentSize().height - 110})
    self._state = 0
    self:updateBtnPanel()
    self:updateTalentPanel()
    self:resetTrain()

    self._teamData = self._teamModel:getTeamAndIndexById(self._teamId)
    self:isUpgradeSkill()
    self._viewMgr:unlock()
end

function TeamTalentDialog:isUpgradeSkill()
    local oldlevel,_ = self._teamModel:getSkillLevelAndScore(self._oldTeamData)
    local level,_ = self._teamModel:getSkillLevelAndScore(self._teamData)
    print("level=========", level, oldlevel)
    if not self._teamData.tmScore then
        self._teamData.tmScore = 0
    end
    if not self._oldTeamData.tmScore then
        self._oldTeamData.tmScore = 0
    end
    if level > oldlevel then
        if self._teamData.tmScore > self._oldTeamData.tmScore then
            local tempLevel = {oldlevel, level}
            self._viewMgr:showDialog("team.TeamTalentUpgradeDialog", {skillLvl = tempLevel, teamData = self._teamData})
        end
    end
end

function TeamTalentDialog:teamPiaoNature1(inData)
    local runeIcon = self:getUI("bg.leftPanel.image_frame.teamBg.aminBg")
    local mc1 = mcMgr:createViewMC("tianfushengji_teamqianneng", false, true)
    mc1:setPosition(runeIcon:getContentSize().width*0.5, runeIcon:getContentSize().height*0.5)
    runeIcon:addChild(mc1)

    local mc1 = mcMgr:createViewMC("tianfushengji1_teamqianneng", false, true)
    mc1:setPosition(runeIcon:getContentSize().width*0.5, 0)
    runeIcon:addChild(mc1, -1)
    local ttalent = self._oldTeamData.tt
    local teamQualityTab = tab:TeamQuality(self._teamData.stage)
    local talentTab = self._systeam.talent
    for i=1,4 do
        local talentAttr = talentTab[i][1]
        local talentType = talentTab[i][2]
        local data = inData[tostring(talentAttr)]
        data = math.floor(data*100)/100
        local expMaxValue = teamQualityTab["teamTalent_" .. talentType]
        local expValue = 0
        if ttalent and ttalent[tostring(talentAttr)] then
            expValue = tonumber(ttalent[tostring(talentAttr)])
        end
        local addMax = expMaxValue - expValue
        if data and data > addMax then
            data = addMax
        end

        if (data + expValue) < 0 then
            data = 0
        end
        local dataStr = string.format("%.2f", data)
        local piaostr = lang("ATTR_" .. talentAttr) .. dataStr
        local talentBarBg = self:getUI("bg.talentPanel.talentBg" .. i .. ".talentBarBg")
        if data >= 0 then
            piaostr = lang("ATTR_" .. talentAttr) .. "+" .. dataStr
            local jindutiaozhang = mcMgr:createViewMC("jindutiaozhang_teamqianneng", false, true)
            jindutiaozhang:setPosition(talentBarBg:getContentSize().width/2, talentBarBg:getContentSize().height/2)
            talentBarBg:addChild(jindutiaozhang, 10)
        else
            local jindutiaojian = mcMgr:createViewMC("jindutiaojian_teamqianneng", false, true)
            jindutiaojian:setPosition(talentBarBg:getContentSize().width/2, talentBarBg:getContentSize().height/2)
            talentBarBg:addChild(jindutiaojian, 10)
        end

        local natureLab = runeIcon:getChildByName("natureLab" .. i)
        if natureLab then
            natureLab:stopAllActions()
            natureLab:removeFromParent()
        end
        natureLab = cc.Label:createWithTTF(piaostr, UIUtils.ttfName, 24)
        natureLab:setName("natureLab" .. i)
        natureLab:setColor(UIUtils.colorTable.ccUIBaseColor6)
        if data > 0 then
            natureLab:setColor(UIUtils.colorTable.ccUIBaseColor9)
        end
        natureLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        natureLab:setPosition(cc.p(runeIcon:getContentSize().width*0.5, runeIcon:getContentSize().height*0.5-30*i + 15))
        natureLab:setOpacity(0)
        runeIcon:addChild(natureLab,100)

        local seqnature = cc.Sequence:create(cc.ScaleTo:create(0, 0.2), cc.DelayTime:create(0.1*i), 
            cc.Spawn:create(cc.ScaleTo:create(0.2, 1),cc.FadeIn:create(0.2),cc.MoveBy:create(0.2, cc.p(0,38))), 
            cc.MoveBy:create(0.38, cc.p(0,17)),
            cc.Spawn:create(cc.MoveBy:create(0.4, cc.p(0,10)),cc.FadeOut:create(0.7)),
            cc.RemoveSelf:create(true))
        natureLab:runAction(seqnature)
    end
end


return TeamTalentDialog