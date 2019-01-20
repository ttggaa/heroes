--[[
    @FileName   StarChartsView.lua
    @Authors    zhangtao
    @Date       2018-03-07 10:50:37
    @Email      <zhangtao@playcrad.com>
    @Description   星图
--]]

local StarChartsView = class("StarChartsView",BaseView)
StarChartsBody = require "game.view.starCharts.StarChartsBody"
local DEBUGFLAG = false

require "game.view.starCharts.StarChartConst"

local desKeys = {
    [StarChartConst.HeroAdd] = {"ability_hero_camp","ability_hero_type"},
    [StarChartConst.TeamAdd] = {"ability_team_camp","ability_team_type","ability_team_posclass","ability_team_movetype","ability_team_sort"},
    [StarChartConst.SysteamAdd] = {},
    [StarChartConst.SpecialAdd] = {"heroMastery"}
}

local addValue = {
    [StarChartConst.HeroAdd] = {["key"] = "ability_hero",["keyType"] = "ability_hero_type"},
    [StarChartConst.TeamAdd] = {["key"] = "ability_team_num",["keyType"] = "ability_team_sort"},
    [StarChartConst.SysteamAdd] = {["key"] = "proceeds_num",["keyType"] = nil},
    [StarChartConst.SpecialAdd] = {["key"] = nil,["keyType"] = nil}
}
function StarChartsView:ctor(params)
    self.super.ctor(self)
    self._mapLayer = nil
    self._parent = params.container
    self._heroId = params.heroId
    self._heroData = params.heroData
    self.starId = nil    --星图id
    self._starBodyId = 0
    self._starChartsModel = self._modelMgr:getModel("StarChartsModel")
    self._heroModel = self._modelMgr:getModel("HeroModel")
    self._starChartsModel:setStarInfoByHeroId(self._heroId)
    self._starChartIsMake = 0  --是否构成
    self.starInfo = self._starChartsModel:getStarInfo()
    self:setStarId() 
    self.labelTable = {[1]={},[2]={}}     --动态label表  1代表英雄上场生效  2代表全局生效
    self.heroAbilityTypeTable = {}        --英雄属性加成配表  
    self.teamAbilityTypeTable = {}        --兵团属性加成配表
    self.proceedAbilityTypeTable = {}     --收益加成配表
    self.specialAbilityTypeTable = {}     --特殊加成配表
    self.skillNodeTable = {}
    self.heroMasteryTable = {}            --专精node表
    self.checkBoxSelect = 0
    self.movingNum = 0                  
    self.centerId = tab.starCharts[self.starId]["centrality"]

end

--英雄星图id
function StarChartsView:setStarId()
    for k , v in pairs(tab.starCharts) do
        if tonumber(self._heroId) == tonumber(v.hero) then
            self.starId = v.id
            return
        end
    end
    -- self.starId = 1
    self._starChartsModel:getBodyIdTable(self.starId)
end


-- 初始化UI后会调用, 有需要请覆盖
function StarChartsView:onInit()
    print("=========onInit=======")
    -- dump(self._heroData)
    if self._mapLayer == nil then
        self._mapLayer = require("game.view.starCharts.StarChartsViewMap").new(function()
            
        end,self,self.starId)
        self:addChild(self._mapLayer,-1)
        -- UIUtils:reloadLuaFile("game.view.starCharts.StarChartsViewMap")
    else
        -- 两个view间切换会无法走onTop,所以手动走
        self._mapLayer:onTop()
    end

    self.attributeKey = {110,113,116,119}

    self:setListenReflashWithParam(true)
    self:listenReflash("StarChartsModel", self.updateUI)
    self.allBodySkillTable = self._starChartsModel:getAllBodySkillLevelValue()   --英雄法术等级加成
    self.allBodyQualityTable = self._starChartsModel:getAllBodyQualitValue()     --英雄属性加成
    --UI面板
    self.panel1 = self:getUI("Panel1")
    self.panel2 = self:getUI("Panel2")
    self.panel3 = self:getUI("Panel3")
    self.panel4 = self:getUI("Panel4")
    self.panel5 = self:getUI("Panel5")
    self.panel6 = self:getUI("Panel6")
    self.panel7 = self:getUI("Panel7")
    self.composeimg = self:getUI("composeimg")
    self.zhanlilayer = self:getUI("BgPanel.Heroimg.zhanlilayer")
    self.ImageBottom = self:getUI("ImageBottom")
    --培养面板
    self.propertyimg = self.panel7:getChildByFullName("propertyimg")
    self.checkBox1 = self.panel7:getChildByFullName("CheckBox1")
    self.checkBox2 = self.panel7:getChildByFullName("CheckBox2")
    self.rightPanel1 = self.panel7:getChildByFullName("rightPanel1")
    self.rightPanel2 = self.panel7:getChildByFullName("rightPanel2")
    self.iconlayer1 = self.panel7:getChildByFullName("iconlayer1")
    self.icon1num = self.panel7:getChildByFullName("icon1num")
    self.iconlayer2 = self.panel7:getChildByFullName("iconlayer2")
    self.icon2num = self.panel7:getChildByFullName("icon2num")
    self.iconlayer3 = self.panel7:getChildByFullName("iconlayer3")
    self.icon3num = self.panel7:getChildByFullName("icon3num")
    self.iconlayerNode = self:getUI("Panel7.rightPanel1.iconlayer3")

    self.cancelBtn = self:getUI("Panel7.rightPanel2.cancelBtn")
    self.acceptBtn = self:getUI("Panel7.rightPanel2.acceptBtn")
    --headImageBg
    self.headImageBg = self:getUI("BgPanel.Heroimg")
    -- 英雄属性node
    local attackNumx = self:getUI("Panel3.ScrollView1.autolist.GlobalPanel.attacknum")
    local defenseNum = self:getUI("Panel3.ScrollView1.autolist.GlobalPanel.defensenum")
    local witNum = self:getUI("Panel3.ScrollView1.autolist.GlobalPanel.witnum")
    local knowledgeNum = self:getUI("Panel3.ScrollView1.autolist.GlobalPanel.knowledgenum")
    self.qualityTable = 
    {
        [StarChartConst.QualityType110] = attackNumx,
        [StarChartConst.QualityType113] = defenseNum,
        [StarChartConst.QualityType116] = witNum,
        [StarChartConst.QualityType119] = knowledgeNum
    }
    --初始化Panel4(普通、奖励、特殊星体的面板)
    self._starName4 = self:getUI("Panel4.starname")
    self._starnum4 = self:getUI("Panel4.starnum")
    self._Panel14 = self:getUI("Panel4.Panel1")
    self._bottomPanel4 = self:getUI("Panel4.bottomPanel")
    self._activeBtn4 = self:getUI("Panel4.bottomPanel.activebtn")
    self:registerClickEvent(self._activeBtn4, function()
        -- UIUtils:reloadLuaFile("elemental.ElementalView")
       self:activeBtnClick()
    end)
    self._goldBg4 = self:getUI("Panel4.bottomPanel.goldBg")
    self._itemicon4 = self:getUI("Panel4.bottomPanel.itemicon")
    self._goldNum4 = self:getUI("Panel4.bottomPanel.GoldNum")
    self._soulStartext = self:getUI("Panel4.bottomPanel.Soulstartext")
    self._soulStarnum = self:getUI("Panel4.bottomPanel.Soulstarnum")
    self._soulStarimg = self:getUI("Panel4.bottomPanel.Soulstarimg")
    self._activedImg4 = self:getUI("Panel4.activedImg")
    self._starUnlockImg4 = self:getUI("Panel4.starUnlockImg")
    self._unlockPanel4 = self:getUI("Panel4.unlockPanel")
    self._unlockshowLab4 = self:getUI("Panel4.unlockPanel.showLab")
    self._unlockImg4 = self:getUI("Panel4.unlockPanel.unlockImg")
    self._getedImg = self:getUI("Panel4.Panel1.Panel3.geted")
    self._rewardPanel4 = self:getUI("Panel4.Panel1.Panel3.rewardPanel")

    --星图构成Panel6
    self._bg6 = self:getUI("Panel6.bg")
    self._title6 = self:getUI("Panel6.bg.title")
    self._iconawardBg6 = self:getUI("Panel6.bg.iconbg")
    self._herodesc6 = self:getUI("Panel6.bg.herodesc")
    self._heroatt16 = self:getUI("Panel6.bg.heroatt1")
    self._heroatt26 = self:getUI("Panel6.bg.heroatt2")
    self._activetext6 = self:getUI("Panel6.activetext")
    self._activenum6 = self:getUI("Panel6.activenum")
    self._costPanel6 = self:getUI("Panel6.costPanel")
    self._costimg16 = self:getUI("Panel6.costPanel.costimg1")
    self._costnum16 = self:getUI("Panel6.costPanel.costnum1")
    self._costimg26 = self:getUI("Panel6.costPanel.costimg2")
    self._costnum26 = self:getUI("Panel6.costPanel.costnum2")
    self._starmakeBtn6 = self:getUI("Panel6.starmakeBtn")
    self._starCompleteimg6 = self:getUI("Panel6.starCompleteimg")
    self:registerClickEvent(self._starmakeBtn6, function()
       self:starMakeBtnClick()
    end)


    --分支按钮
    self._branchBtn = self:getUI("starbranchBtn")
    self:registerClickEvent(self._branchBtn, function()
        local branchTouchCallBack = function(catenaId)
            self.movingNum = self.movingNum + 1
            -- self._mapLayer:deleateBodyAni()
            ScheduleMgr:delayCall(500, self, function()
                self.movingNum = self.movingNum - 1
                if self.movingNum == 0 then
                    local catenaIds = tab.starChartsCatena[catenaId]["stars"]
                    for k , id in pairs(catenaIds) do
                        self._mapLayer:bodyAddAni1(id)
                    end
                end
            end)
        end
        self._viewMgr:showHintView("starCharts.StarChartsrBranchDialog",
            {container = self,starId = self.starId,bodyId = self._starBodyId,autoCloseTip = false,callback = branchTouchCallBack})
    end)

    --添加按钮
    self._addBtn = self:getUI("Panel2.addBtn")
    self:registerClickEvent(self._addBtn, function()
        self._viewMgr:showDialog("starCharts.StarChartsResonanceDialog",{container = self,heroData = self._heroData,starId = self.starId},true)
        -- self:testAni()
    end)
    --重置按钮
    self._resetBtn = self:getUI("Panel1.resetBtn")
    self:registerClickEvent(self._resetBtn, function()
        self._viewMgr:showDialog("starCharts.StarChartsResetDialog",{container = self,heroId = self._heroId},true)
    end)
    --详情按钮
    self._knowbtn = self:getUI("Panel3.ScrollView1.autolist.GlobalPanel.knowbtn")
    self:registerClickEvent(self._knowbtn, function()
        self._viewMgr:showHintView("starCharts.StarChartsKnowDialog",{container = self, showType = StarChartConst.DetailsType1,starId = self.starId,autoCloseTip = false,btn = self._knowbtn})
       -- self:createHeroMasteryNode() 
        -- self._viewMgr:showDialog("starCharts.StarChartsKnowDialog",{container = self,showType = 1},true)
    end)
    --专精描述详情按钮
    self._starSoulKnowbtn = self:getUI("Panel3.ScrollView1.autolist.zjPanel.knowbtn")
    self:registerClickEvent(self._starSoulKnowbtn, function()
        self._viewMgr:showHintView("starCharts.StarChartsKnowDialog",{container = self, showType = StarChartConst.DetailsType3,starId = self.starId,autoCloseTip = false,btn = self._starSoulKnowbtn})
    end)
    --突破按钮
    self.breakBtn = self:getUI("Panel7.rightPanel1.breakBtn")
    self:registerClickEvent(self.breakBtn, function()
        self:getCheckBoxSelected()
        if self.checkBoxSelect == 0 then
            self._viewMgr:showTip("请选择突破资源")
        else
            self:breakBtnClick()

        end
    end)

    --取消突破按钮
    self:registerClickEvent(self.cancelBtn, function()
        self:acceptBtnClick(2)
    end)
    --接受突破按钮
     self:registerClickEvent(self.acceptBtn, function()
        self:acceptBtnClick(1)
    end)   
    --复选框1
    self.checkBox1:addEventListener(function (_, state)
        print("state==============", state)
        if not self.checkBox1:isSelected() then
            self.checkBox1:setSelected(true)
            return
        end
        if state == 0 then
            self.checkBox2:setSelected(false)
            -- self.checkBoxSelect = 1
            -- self.checkBox2:unSelectedEvent()
        else
        
        end
    end)
    --复选框2
    self.checkBox2:addEventListener(function (_, state)
        print("state==============", state)
        if not self.checkBox2:isSelected() then
            self.checkBox2:setSelected(true)
            return
        end
        if state == 0 then
            self.checkBox1:setSelected(false)
            -- self.checkBoxSelect = 2
            -- self.checkBox1:unSelectedEvent()
        else
            
        end
    end)

    --星图构成详情
    self.KnowBtn = self:getUI("Panel7.KnowBtn")
    self:registerClickEvent(self.KnowBtn, function()
        self._viewMgr:showHintView("starCharts.StarChartsKnowDialog",{container = self,showType = StarChartConst.DetailsType2,starId = self.starId,autoCloseTip = false,btn = self.KnowBtn})
    end)
    --规则描述按钮
    self.ruleBtn = self:getUI("kwbtn")
    self:registerClickEvent(self.ruleBtn, function()
        self._viewMgr:showDialog("global.GlobalRuleDescView",{desc = lang("starCharts_Rule")},true)
    end)
    --功能方法
    self:setHeroBgImage()
    self:setHeroFightValue()
    self:initCommonPanel()
    self:setSoulNum(false)
    self:setActiviteNum(false)
    self:updateIsMake()
    self:loadSkillNode()
    self:upDataQuality()
    -- self:switchUIByType(StarChartConst.CenterType,0)

    self:mapToCenterPos(self.centerId,false,nil,200)
    self:firstEnterFlag()
    self:addCanActivityAni()
end
--首次进入标记
function StarChartsView:firstEnterFlag()
    local firstEnter = SystemUtils.loadAccountLocalData("STARCHARTS_IS_FIRSEENTER")
    if firstEnter == nil then
        SystemUtils.saveAccountLocalData("STARCHARTS_IS_FIRSEENTER", "1")
    end
end
--
function StarChartsView:addCanActivityAni()
    local activityIds = self._starChartsModel:getCanActivityBodyList(self.starId)
    for _ , id in pairs(activityIds) do
        self._mapLayer:addCompletedAni(id)
    end
end

function StarChartsView:testAni()
    -- local mc2 = mcMgr:createViewMC("gongxihuode_huodetitleanim", false,true)
    -- mc2:setPosition(500,500)
    -- self:addChild(mc2, 100)
    -- -- mc2:getChildren()[1]:getChildren()[1]:setVisible(false)
    -- mc2:getChildren()[1]:getChildren()[1]:setSpriteFrame("starCharts_starchainactive.png")
    -- -- mc2:getChildren()[1]:getChildren()[2]:setSpriteFrame("starCharts_starchainactive.png")
    -- -- mc2:getChildren()[1]:getChildren()[3]:setSpriteFrame("starCharts_starchainactive.png")
    -- dump(mc2:getChildren(),"ani node",10)

end

--以某点为屏幕中心
function StarChartsView:mapToCenterPos(bodyId,anim,callBack,offsetX,offsetY)
    local offsetX = offsetX or 0
    local offsetY = offsetY or 0
    local posIndex = tab.starChartsStars[bodyId]["position"]
    local posTable = tab.starPosition[posIndex]["position"]
    self._mapLayer:screenToPos(posTable[1] + offsetX,posTable[2] + offsetY,anim,callBack,false,nil,0.3)
end

--英雄图片
function StarChartsView:setHeroBgImage()
    local heroBgImagePath = tab.hero[self._heroId]["herobg"]..".jpg"
    local bgNode = cc.Sprite:create("asset/uiother/hero/"..heroBgImagePath)
    bgNode:setScale(1.2)
    bgNode:setFlipX(true)
    local mask = cc.Sprite:createWithSpriteFrameName("starCharts_headCover.png")
    local clipNode = cc.ClippingNode:create()
    local bgSize = self.headImageBg:getContentSize()
    clipNode:setPosition(bgSize.width/2,bgSize.height/2)
    clipNode:setStencil(mask)
    clipNode:setAlphaThreshold(0.5)
    clipNode:addChild(bgNode)
    self.headImageBg:addChild(clipNode)
    --星图名称
    local heroName = lang(tab.hero[self._heroId]["heroname"])
    self:getUI("BgPanel.starchartsname"):setString(heroName.."星图")
end

--设置英雄战斗力
function StarChartsView:setHeroFightValue()
    self._zhandouliText = ccui.TextBMFont:create("0", UIUtils.bmfName_zhandouli_little)
    self._zhandouliText:setAnchorPoint(cc.p(1,0.5))
    self._zhandouliText:setPosition(116,45)
    self._zhandouliText:setString("a")
    self._zhandouliText:setScale(0.5)
    self.zhanlilayer:addChild(self._zhandouliText, 20)

    self._zhandouliLabel = ccui.TextBMFont:create("0", UIUtils.bmfName_zhandouli_little)
    self._zhandouliLabel:setName("zhandouliBmp")
    self._zhandouliLabel:setAnchorPoint(cc.p(1,0.5))
    self._zhandouliLabel:setPosition(116,20)
    self._zhandouliLabel:setString((self._heroData.score or 0))
    self._zhandouliLabel:setScale(0.5)
    self.zhanlilayer:addChild(self._zhandouliLabel, 20)
end

--是否构成
function StarChartsView:updateIsMake()
    if self.starInfo == nil or self.starInfo["cf"] == nil then
        self._starChartIsMake = 0
    else
        self._starChartIsMake = self.starInfo["cf"]
    end
    print("=======self._starChartIsMake========"..self._starChartIsMake)
    self.panel1:setVisible(self._starChartIsMake == 0 and true or false)
    self.panel2:setVisible(self._starChartIsMake == 0 and true or false)
    self.composeimg:setVisible(self._starChartIsMake == 1 and true or false)
    self.ImageBottom:setVisible(self._starChartIsMake == 0 and true or false)
    self:setResetBtnStatus()
    --中心星体动画
    self._mapLayer:addCenterBodyAni(self.centerId,self._starChartIsMake)
    if tonumber(self._starChartIsMake) == 1 then
        --构成后默认选中中心星体
        self._mapLayer:defaultSelect(self.centerId)
    end
    --显示为已完成图片
    self:checkStarIsCompleted()
end
--更新重置按钮状态
function StarChartsView:setResetBtnStatus()
    if self._starChartIsMake == 1 then
         self._resetBtn:setVisible(false)
    else
        if not self._starChartsModel:checkStarListOrNull() then 
            self._resetBtn:setVisible(false)
        else
            self._resetBtn:setVisible(true)
        end
    end
end

--设置激活数量
function StarChartsView:setActiviteNum(isUpdate)
    local openNum = self:getUI("Panel1.openNum")
    local bodyNum = #self._starChartsModel:getBodyIdTable(self.starId)

    local starNum = self._starChartsModel:getStarActivedNum()
    openNum:setString(starNum .."/"..bodyNum)
    if isUpdate then
        self:runValueChangeAnim(openNum,nil)
    end
end
--设置星魂数量
function StarChartsView:setSoulNum(isUpdate)
    local ptentialNum = self:getUI("Panel2.ptentialNum")
    if isUpdate then
        self:runValueChangeAnim(ptentialNum,nil)
    end
    if self.starInfo == nil or self.starInfo["ss"] == nil then
        ptentialNum:setString(0)
    else
        ptentialNum:setString(self.starInfo["ss"])
    end
end
--英雄技能
function StarChartsView:loadSkillNode()
    local skillTable = self._heroData.spell
    for index,skillId in pairs(skillTable) do
        local skillTemp = skillId
        local isReplaced, skillReplacedId = self._heroModel:isSpellReplaced(tonumber(self._heroId), skillId)
        if isReplaced then
            skillId = skillReplacedId
        end
        self.skillNodeTable[skillId] = {}
        local node1 = self:getUI("Panel3.ScrollView1.autolist.heroPanel.skillimg"..index)
        local node2 = self:getUI("Panel3.ScrollView1.autolist.heroPanel.skilllevelnum"..index) 
        self.skillNodeTable[skillId].node1 = node1
        self.skillNodeTable[skillId].node2 = node2
    end
    self:initSkillNode()
    self:upDataSkillLevel()
end

--初始化技能
function StarChartsView:initSkillNode()
    self._attributeValues = BattleUtils.getHeroAttributes(clone(self._heroData))
    for k , skillId in pairs(self._heroData.spell) do
        
        local skillTemp = skillId
        local isReplaced, skillReplacedId = self._heroModel:isSpellReplaced(tonumber(self._heroId), skillId)
        if isReplaced then
            skillId = skillReplacedId
        end
        print("=====skillId========"..skillId)
        local bgNode = self.skillNodeTable[skillId].node1

        local skillData = tab:PlayerSkillEffect(skillId)
        -- local iconBg = self._skillIcon[i]:getChildByFullName("skill_icon_bg")
        local skillIcon = bgNode.skillIcon
        self:registerTouchEvent(bgNode, 
            function(x, y)
                bgNode:runAction(cc.EaseIn:create(cc.ScaleTo:create(0.05, 0.45), 2))
                self:onIconPressOn(bgNode, clone(self._heroData), 2, skillData.id, skillTemp)
            end,
            function(x, y) 
            end,
            function(x, y)
                -- self:endClock() 
                bgNode:runAction(cc.Sequence:create(
                    cc.ScaleTo:create(0.02 + 0.03, 0.5 * (1.00 + 0.05)), 
                    cc.ScaleTo:create(0.02 + 0.03, 0.5 * (1.00 - 0.05)),
                    cc.ScaleTo:create(0.02 + 0.03, 0.5)
                ))
            end,
            function(x, y)
                bgNode:runAction(cc.Sequence:create(
                    cc.ScaleTo:create(0.02 + 0.03, 0.5 * (1.00 + 0.05)), 
                    cc.ScaleTo:create(0.02 + 0.03, 0.5 * (1.00 - 0.05)),
                    cc.ScaleTo:create(0.02 + 0.03, 0.5)
                ))
            end
        )
        if skillIcon == nil then
            skillIcon = ccui.ImageView:create(IconUtils.iconPath .. (skillData.art or skillData.icon) .. ".png", 1)
            skillIcon:setScale(0.9)
            skillIcon:setPosition(bgNode:getContentSize().width / 2, bgNode:getContentSize().height / 2)
            
            bgNode:addChild(skillIcon,-1)
        else
            skillIcon:loadTexture(IconUtils.iconPath .. (skillData.art or skillData.icon) .. ".png", 1)
        end
        bgNode:setSwallowTouches(false)
    end
end
--技能图标点下tips
function StarChartsView:onIconPressOn(node, heroData, iconType, iconId, iconIdTemp)
    if not heroData then return end
    local spTalent = self._modelMgr:getModel("SkillTalentModel"):getTalentDataInFormat()
    if iconType == 1 then
        self:showHintView("global.GlobalTipView",{tipType = 2, node = node, id = heroData.special,heroData = clone(heroData), posCenter = true, spTalent = spTalent})
    else
        local index = 1
        local inSpell = false
        for k,v in pairs(heroData.spell) do
            if v == iconIdTemp then   --用转换之前的skillId比较，因为后端给的是这样
                index = k 
                inSpell = true
                break
            end
        end
        local skillLevel = nil
        local sklevel = 1
        local isSlotMastery = false
        if not inSpell then
            skillLevel = heroData.slot and heroData.slot.sLvl
            sklevel = heroData.slot and heroData.slot.s
            local heroDataC = clone(heroData)
            local sid = heroDataC.slot and heroDataC.slot.sid and tonumber(heroDataC.slot.sid)
            isSlotMastery = tab.heroMastery[tonumber(sid) or 0]
            if sid and sid ~= 0 then
                local bookId = tonumber(sid)
                local bookInfo = self._modelMgr:getModel("SpellBooksModel"):getData()[tostring(bookId)]
                -- 刻印被动技能根据法术书变id
                if isSlotMastery and bookInfo then
                    if tonumber(bookInfo.l) > 1 then
                        iconId = tonumber(iconId .. (bookInfo.l-1))
                    end
                end
                if bookInfo then
                    heroDataC.skillex = {heroDataC.slot.sid, heroDataC.slot.s, bookInfo.l}
                end
            end
            local attributeValues = BattleUtils.getHeroAttributes(heroDataC)
            for k,v in pairs(attributeValues.skills) do
                local sid1 = v[1]
                if iconId == sid1 then
                    sklevel = v[2] or 1
                    skillLevel = not isSlotMastery and v[3] or v[2] or 1
                    break
                end
            end
        else
            skillLevel = self._attributeValues.skills and 
                         self._attributeValues.skills[index] and
                         self._attributeValues.skills[index][2] or nil
        end
        self:showHintView("global.GlobalTipView",{
            tipType = 2, node = node, id = iconId, heroData = not isSlotMastery and clone(heroData) or nil,
            skillLevel = skillLevel, sklevel = sklevel, posCenter = true, spTalent = spTalent})
    end
end
---设置星体法术加成等级
function StarChartsView:upDataSkillLevel()
    local activitySkillTable = self._starChartsModel:getActivitedBodySkillLevelValue()
    for skillId,skillNode in pairs(self.skillNodeTable) do
        local activityNum = 0
        if activitySkillTable ~= nil and activitySkillTable[skillId] ~= nil then
            activityNum = activitySkillTable[skillId].num
        end
        local totalNum = 0
        if self.allBodySkillTable ~= nil and self.allBodySkillTable[skillId] ~= nil then
            totalNum = self.allBodySkillTable[skillId].num
        end
        skillNode.node2:setString("+"..activityNum.."/"..totalNum)
    end
end

-- 英雄属性更新
function StarChartsView:upDataQuality()
    local activityQualityTable = self._starChartsModel:getActivitedBodyQualitValue()
    local activityTable,totalTable = self:getBranchAttr()
    local completeAttr = self:getCompleteAttr()
    local qHab = self._modelMgr:getModel("UserModel"):getHeroStarHAb() or {}
    -- print("======upDataQuality========")
    -- dump(activityQualityTable)
    for qType,qNode in pairs(self.qualityTable) do
        local activityNum = 0
        local braActivityNum = activityTable[qType] or 0
        local braTotalNum = totalTable[qType] or 0
        if activityQualityTable ~= nil and activityQualityTable[qType] ~= nil then
            activityNum = activityQualityTable[qType].value
        end
        local totalNum = 0
        if self.allBodyQualityTable ~= nil and self.allBodyQualityTable[qType] ~= nil then
            totalNum = self.allBodyQualityTable[qType].value
        end
        activityNum = activityNum + braActivityNum
        totalNum = totalNum + braTotalNum
        --构成属性
        local completeValue = completeAttr[qType] or 0
        totalNum = totalNum + completeValue
        if self._starChartIsMake == 1 then
            activityNum = activityNum + completeValue
        end
        -- --突破属性
        -- local qHabValue = qHab[qType] or 0
        -- activityNum = activityNum + qHabValue
        -- local maxValue = tab.starCharts[self.starId]["train_max"]
        -- local index = StarChartConst.typeByValue[tonumber(qType)]
        -- totalNum = totalNum + maxValue[index]

        qNode:setString("+"..(activityNum).."/"..(totalNum ))
    end
end
--分支属性
function StarChartsView:getBranchAttr()
    local activityTable = {}
    local totalTable = {}
    local starChartsCatenaTab = tab.starChartsCatena
    local branchIds = tab.starCharts[self.starId]["catena_id"]
    for k ,id in pairs(branchIds) do
        local activityNum ,totalNum = self._starChartsModel:getBodyIdsByCatenaId(id)
        local isComplete = activityNum == totalNum or false
        local quality_type = starChartsCatenaTab[id]["quality_type"]
        local quality = starChartsCatenaTab[id]["quality"]
        if totalTable[quality_type] ~= nil then
            totalTable[quality_type] = totalTable[quality_type] + quality
        else
            totalTable[quality_type] = quality
        end
        if isComplete then
            if activityTable[quality_type] ~= nil then
                activityTable[quality_type] = activityTable[quality_type] + quality
            else
                activityTable[quality_type] = quality
            end
        end
    end
    return activityTable,totalTable
end
--星图构成属性
function StarChartsView:getCompleteAttr()
    local completeTable = {}
    local starInfo = tab.starCharts[self.starId]
    local aid = tonumber(starInfo.quality_type1) or 0
    local value = tonumber(starInfo.quality1) or 0
    completeTable[aid] = completeTable[aid] or 0
    completeTable[aid] = completeTable[aid] + value
    aid = tonumber(starInfo.quality_type2) or 0
    value = tonumber(starInfo.quality2) or 0
    completeTable[aid] = completeTable[aid] or 0
    completeTable[aid] = completeTable[aid] + value
    return completeTable
end


--[[
点击星体切换UI
1：普通
2：奖励
3：属性未知
4：中心（星图构成）
-- ]]
function StarChartsView:switchUIByType(typeValue,bodyId)
    if typeValue == StarChartConst.CommonType then
        if self.panel3:isVisible() == true then return end
    end
    self._starType = typeValue 
    self._starBodyId = bodyId or 0 --已经点击的星体ID

    -- self._starChartIsMake = 0   --临时

    print("======self._starBodyId======="..self._starBodyId)
    self:getUI("BgPanel.starchartsname"):setVisible(true)
    self.panel3:setVisible(typeValue == StarChartConst.CommonType and true or false)

    self.panel4:setVisible((typeValue == StarChartConst.NormalType or 
                            typeValue == StarChartConst.AwardType  or
                            typeValue == StarChartConst.UnKnownType  ) and true or false)

    if typeValue == StarChartConst.CenterType then
        if StarChartConst.NOTOPEN then
            self.panel6:setVisible(true)
            self.panel7:setVisible(false)
        else
            self.panel6:setVisible(self._starChartIsMake == 0 and true or false)
            self.panel7:setVisible(self._starChartIsMake == 1 and true or false)
        end

    else
        self.panel6:setVisible(false)
        self.panel7:setVisible(false)
    end
    if self._starBodyId ~= 0 then
        self:initStarPanel(typeValue)
        if DEBUGFLAG then
            self._viewMgr:showTip("选中的星体id = "..self._starBodyId)
        end
    end
end


function StarChartsView:setNavigation()    
    self._viewMgr:showNavigation("global.UserInfoView",{types = {"","Gold","Gem"},title = "trainingView_title.png",titleTxt = "星  图"})
end


--初始化通用面板 begin
function StarChartsView:initCommonPanel()
    self._scrollView = self:getUI("Panel3.ScrollView1")
    self._scrollView:setBounceEnabled(true)
    self._listWiget = self:getUI("Panel3.ScrollView1.autolist")

    self:initLabelNodeTable()
    self:setAutoListNode()

end
--初始化星体所对应的面板 begin
function StarChartsView:initStarPanel(typeValue)
    self:updateStarActived() 
    --self._Panel14:setVisible((StarChartConst.NormalType == typeValue) or (StarChartConst.UnKnownType == typeValue))
    --self._Panel24:setVisible(StarChartConst.AwardType == typeValue) 
    
    if typeValue == StarChartConst.CenterType then
        if StarChartConst.NOTOPEN then
            self:initStarCenterType()
        else
            if self._starChartIsMake == 1 then
                self:initCulturePanel()
            else
                self:initStarCenterType()
            end
        end    
    else
        self:updateCatenaName()
        self:initstarNormalType(typeValue)
    end

end
--更新星体是否已激活
function StarChartsView:updateStarActived()
    if self._heroData.star < 4 then
        self._starUnlockImg4:setVisible(true)
        self._bottomPanel4:setVisible(false)
        self._activedImg4:setVisible(false)
        self._unlockPanel4:setVisible(false)
    else
        self._starUnlockImg4:setVisible(false)

        if self._starChartsModel:checkOrLock(self._starBodyId) then
            self._activedImg4:setVisible(true)
            self._bottomPanel4:setVisible(false)
            self._unlockPanel4:setVisible(false)
        else
            local isActive,activeNum = self._starChartsModel:checkActiveState(self._starBodyId)
            if isActive == false then
                self._unlockPanel4:setVisible(true)
                self._activedImg4:setVisible(false)
                self._bottomPanel4:setVisible(false)
            else
                self._unlockPanel4:setVisible(false)
                self._activedImg4:setVisible(false)
                self._bottomPanel4:setVisible(true)
            end
            
        end
    end

    --显示已获得的图片
    if self._starChartsModel:orGetAward(self._starBodyId) then
        self._getedImg:setVisible(true)
    else
        self._getedImg:setVisible(false)
    end
    
end

--更新分支名字及数量
function StarChartsView:updateCatenaName()
    local catenaId,activityNum,totalCatenaNum = self._starChartsModel:getCatenaNum(self.starId,self._starBodyId)
    local catenaName = lang(tab.starChartsCatena[catenaId]["name"])
    self._starName4:setString(catenaName)
    self._starnum4:setString(activityNum .. "/" .. totalCatenaNum)

    UIUtils:center2Widget(self._starName4,self._starnum4,157,4)
end
--初始化普通星体和特殊星体属性
function StarChartsView:initstarNormalType(typeValue)
    local panel1 = self:getUI("Panel4.Panel1.Panel1")
    local panel2 = self:getUI("Panel4.Panel1.Panel2")
    local panel3 = self:getUI("Panel4.Panel1.Panel3")

    local attText1 = self:getUI("Panel4.Panel1.Panel1.attText1")
    
    local attText2 = self:getUI("Panel4.Panel1.Panel1.attText2")
    local attNum2 = self:getUI("Panel4.Panel1.Panel1.attNum2")
    local iconimg = self:getUI("Panel4.Panel1.Panel1.iconimg")
    iconimg:loadTexture(StarChartConst.showsort[tab.starChartsStars[self._starBodyId]["show_sort"]],1)
  
    --初始化奖励星体属性
    if typeValue ==  StarChartConst.AwardType then
        panel3:setVisible(true)
        local rewardDesc = self:getUI("Panel4.Panel1.Panel3.rewardNum")

        local rewardTable = tab.starChartsStars[self._starBodyId]["award"][1]
        local rewardType = rewardTable[1]
        local rewardId = rewardTable[2]
        local rewardNum = rewardTable[3]
        
        if self._rewardPanel4.itemIcon ~= nil then
           self._rewardPanel4.itemIcon:removeFromParent()
           self._rewardPanel4.itemIcon = nil
        end
        local  itemIcon = self:createIcon(rewardTable)
        if itemIcon ~= nil then
            local scale = 0.35
            if rewardType == "team" or rewardType == "hero" then
                scale = 0.23
            elseif rewardType == "avatarFrame" then
                scale = 0.2
            end
            itemIcon:setScale(scale)
            self._rewardPanel4:addChild(itemIcon)
            self._rewardPanel4.itemIcon = itemIcon
        end

        rewardDesc:setString("x" .. rewardNum)

    else
        panel3:setVisible(false)
    end
    --初始化特殊星体属性
    if typeValue ==  StarChartConst.UnKnownType then
        local isActive,activeNum = self._starChartsModel:checkActiveState(self._starBodyId)
        panel1:setVisible(isActive)
        panel2:setVisible(not isActive)
        if isActive == false then
            local specialDesc = self:getUI("Panel4.Panel1.Panel2.specialDesc")
            local unlockNum = tab.starChartsStars[self._starBodyId]["unlock_num"]
            local descText = "激活相邻" .. activeNum .. "/" .. unlockNum .. "星体才能查看该星体"
            specialDesc:setString(descText)
            self._unlockshowLab4:setVisible(false)
            self._unlockImg4:setPositionY(80)  
        end
    else
        panel1:setVisible(true)
        panel2:setVisible(false)
        self._unlockshowLab4:setVisible(true)
        self._unlockImg4:setPositionY(97)
    end

    --非特殊星体也会有多个激活数量
    local _,activeStarNum = self._starChartsModel:checkActiveState(self._starBodyId)
    local unlockStarNum = tab.starChartsStars[self._starBodyId]["unlock_num"]
    if unlockStarNum > 1 then
        self._unlockshowLab4:setString("激活" .. activeStarNum .. "/" .. unlockStarNum .. "个相邻星体后解锁")
    else
        self._unlockshowLab4:setString("激活相邻星体后解锁")    
    end

    --初始化星体独有属性
    --local abilitySort = tab.starChartsStars[self._starBodyId]["ability_sort"]
    --local ability_showtype = tab.starChartsStars[self._starBodyId]["ability_showtype"]
   
    attText1:setString(lang(tab.starChartsStars[self._starBodyId]["des"]))

    local qualitytype2 = tab.starChartsStars[self._starBodyId]["quality_type"] 
    local qualityvalue2 = tab.starChartsStars[self._starBodyId]["quality"] 
    attText2:setString(StarChartConst.qualityType[qualitytype2])
    attNum2:setString("+".. qualityvalue2)
    self:adjustWidgetDistance(attText2,{attNum2},1)
    
    self._soulStarimg:setVisible(false)
    self._soulStarnum:setVisible(false)
    self._itemicon4:setVisible(false)
    self._goldNum4:setVisible(false)

    local costNodeTable = {
    [1] = {["iconNode"] = {self._soulStarimg,{110,85}},["num"] = {self._soulStarnum,{129,82}}},
    [2] = {["iconNode"] = {self._itemicon4,{170,85}},["num"] = {self._goldNum4,{189,82}}}
    }
    local costTable = {}
    local cost1 = tab.starChartsStars[self._starBodyId]["cost1"]
    local cost2 = tab.starChartsStars[self._starBodyId]["cost2"]
    if cost1 ~= nil then
        local  tTable = {"soulStar",0,cost1}
        table.insert(costTable,tTable)
    end
    if cost2 ~= nil then
        for i,v in pairs(cost2) do
            table.insert(costTable,v)
        end
    end
    
    for i,cTable in pairs(costTable) do
        local iconRes,iconScale = self:getIconImg(cTable)
        if iconRes and iconRes ~= "" then
            costNodeTable[i]["iconNode"][1]:loadTexture(iconRes,1)
            costNodeTable[i]["iconNode"][1]:setScale(iconScale)
        end
        costNodeTable[i]["num"][1]:setString(cTable[3])
        costNodeTable[i]["iconNode"][1]:setPositionX(costNodeTable[i]["iconNode"][2][1])
        costNodeTable[i]["num"][1]:setPositionX(costNodeTable[i]["num"][2][1])
        costNodeTable[i]["iconNode"][1]:setVisible(true)
        costNodeTable[i]["num"][1]:setVisible(true)
    end

    if #costTable == 1 then
        costNodeTable[1]["iconNode"][1]:setPositionX(140)
        costNodeTable[1]["num"][1]:setPositionX(159)
    end
    
    self:setActivebtnStatus()
end
function StarChartsView:createIcon(iconTable)
        local itemIcon = nil
        local itemType = iconTable[1]
        local itemId = iconTable[2]
        local itemNum = iconTable[3]
        local eventStyle = 1 --{itemId = itemId, num = num,eventStyle = 0} 
        if itemType == "hero" then
            local heroData = clone(tab:Hero(itemId))
            itemIcon = IconUtils:createHeroIconById({sysHeroData = heroData})
            --itemIcon:getChildByName("starBg"):setVisible(false)
            for i=1,6 do
                if itemIcon:getChildByName("star" .. i) then
                    itemIcon:getChildByName("star" .. i):setPositionY(itemIcon:getChildByName("star" .. i):getPositionY() + 5)
                end
            end

            registerClickEvent(itemIcon, function()
                local NewFormationIconView = require "game.view.formation.NewFormationIconView"
                self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = itemId}, true)
            end)
        elseif itemType == "team" then
            local teamTeam = clone(tab:Team(itemId))
            itemIcon = IconUtils:createSysTeamIconById({sysTeamData = teamTeam,isJin=true})
           
        elseif itemType == "avatarFrame" then
            local frameData = tab:AvatarFrame(itemId)
            param = {itemId = itemId, itemData = frameData}
            itemIcon = IconUtils:createHeadFrameIconById(param)
        elseif itemType == "siegeProp" then
            local propsTab = tab:SiegeEquip(itemId)
            local param = {itemId = itemId, level = 1, itemData = propsTab, quality = propsTab.quality, iconImg = propsTab.art, eventStyle = 1}
            itemIcon = IconUtils:createWeaponsBagItemIcon(param)
        else
            if itemType ~= "tool" then
                itemId = IconUtils.iconIdMap[itemType]
            end
            itemIcon = IconUtils:createItemIconById({itemId = itemId, num = itemNum,eventStyle = eventStyle})
            itemIcon.iconColor.numLab:setVisible(false)
        end
        return itemIcon
end

function StarChartsView:getIconImg(iconTable)
    local itemType = iconTable[1]
    local itemId = iconTable[2]
    local itemNum = iconTable[3]
    local iconPath = nil
    local iconScale = 1
    if itemType == "hero" then
        local heroData = clone(tab:Hero(itemId))
        local herohead
        if heroData.skin then
            local heroSkinD = tab.heroSkin[heroData.skin]
            herohead = heroSkinD["herohead"] or heroData.herohead
        else
            herohead = heroData.herohead
        end
        iconPath = IconUtils.iconPath .. herohead .. ".jpg"

    elseif itemType == "team" then
        local teamTeam = clone(tab:Team(itemId))
        local filename = IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTeam, "art1") .. ".jpg"
        local sfc = cc.SpriteFrameCache:getInstance()
        if not sfc:getSpriteFrameByName(filename) then
            filename = IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTeam, "art1") .. ".png"
        end
        iconPath = filename

    elseif itemType == "avatarFrame" then
        local frameData = tab:AvatarFrame(itemId)
        local frameImg = (frameData.art or frameData.icon or "globalImageUI4_itemBg3" )
        local filename = frameImg .. ".png"
        local sfc = cc.SpriteFrameCache:getInstance()
        if not sfc:getSpriteFrameByName(filename) then
            filename = frameImg .. ".jpg"
        end
        iconPath = filename
    elseif itemType == "siegeProp" then
        local propsTab = tab:SiegeEquip(itemId)
        iconPath = propsTab.art..".png"
    else
        if itemType ~= "tool" then
            local iconRes = IconUtils.resImgMap[itemType]
            if iconRes and iconRes ~= "" then
                iconPath = iconRes
            end
            iconScale = 0.6
        else
            local num_itemid = tonumber(itemId)
            local toolD = tab.tool[num_itemid] 
            if toolD then
                if toolD.art then
                    local filename = IconUtils.iconPath .. toolD.art .. ".png"
                    local sfc = cc.SpriteFrameCache:getInstance()
                    if not sfc:getSpriteFrameByName(filename) then
                        filename = IconUtils.iconPath .. toolD.art .. ".jpg"
                    end
                    iconPath = filename
                end
            end
            iconScale = 0.35
        end
        
    end


    return iconPath , iconScale
end

--设置激活按钮状态
function StarChartsView:setActivebtnStatus()
    local canActivite = self._starChartsModel:checkActiveState(self._starBodyId)
    UIUtils:setGray(self._activeBtn4,not canActivite)
end
--培养面板
--('顶点数组' , '顶点个数' , '填充颜色' , '轮廓粗细' , '轮廓颜色')
--[[
    posArr:顶点数组
    fillColor:填充颜色
    borderWidth:轮廓粗细
    color:轮廓颜色
]]
function StarChartsView:initCulturePanel()
    --默认勾选第一个
    self.checkBox1:setSelected(true)
    self.checkBox2:setSelected(false)

    self:getUI("BgPanel.starchartsname"):setVisible(false)
    
    --四维图
    --最外面的四边形
    if self.propertyimg.maxNode == nil then
        local maxNode = cc.DrawNode:create()
        maxNode:setAnchorPoint(0.5,0.5)
        
        self.propertyimg:addChild(maxNode,1)
        self.propertyimg.maxNode = maxNode
        local color = cc.c4f(0.0, 0.0, 0.0, 1.0)
        local fillColor = cc.c4f(97/255, 83/255, 79/255, 0.6)

        local maxValue = tab:Setting("train_max").value    --1攻击 2防御 3智力 4知识 
        -- 智力 攻击  知识  防御
        local pPolygonPtArr = self:getNodePosArr(maxValue[3],maxValue[1],maxValue[2],maxValue[4])
        maxNode:drawPolygon(pPolygonPtArr, table.nums(pPolygonPtArr), fillColor, 0, color)
        --星体最大
        local color = cc.c4f(0.0, 0.0, 0.0, 1.0)
        local fillColor = cc.c4f(62/255, 51/255, 48/255, 0.6)
        local attributeValue = tab.starCharts[self.starId]["train_max"]
        local pPolygonPtArr = self:getNodePosArr(attributeValue[3],attributeValue[1],attributeValue[4],attributeValue[2])
        maxNode:drawPolygon(pPolygonPtArr, table.nums(pPolygonPtArr), fillColor, 0, color)
        self:createCurAttributeNode()
        --横线
        local contentSise = self.propertyimg:getContentSize()
        maxNode:drawSegment(ccp(contentSise.width/2 - 60, contentSise.height/2), ccp(contentSise.width/2+60 - 1, contentSise.height/2), 0.5, cc.c4f(82/255, 60/255, 48/255, 0.8))
        maxNode:drawSegment(ccp(contentSise.width/2, contentSise.height/2+60 - 1), ccp(contentSise.width/2, contentSise.height/2-60), 0.5, cc.c4f(82/255, 60/255, 48/255, 0.8))
    end

    --灌注消耗资源
    local createItemIcon = function(itemNode1,itemNode2,itemTable)
        -- dump(itemTable)
        local itemType = itemTable[1]
        local itemId = itemTable[2]
        local itemNum = itemTable[3]
        local eventStyle = 1
        if itemType ~= "tool" then
            itemId = IconUtils.iconIdMap[itemType]
        end
        if itemNode1.itemIcon ~= nil then
            itemNode1.itemIcon:removeFromParent()
            itemNode1.itemIcon = nil
        end
        local itemIcon = IconUtils:createItemIconById({itemId = itemId, num = itemNum,eventStyle = eventStyle})
        itemIcon.iconColor.numLab:setVisible(false)
        itemIcon:setScale(0.35)
        itemNode1.itemIcon = itemIcon
        itemNode1:addChild(itemIcon)
        itemNode2:setString(itemNum)
    end
    --初级消耗
    local itemTable = tab.starCharts[self.starId]["cost1"][1]
    createItemIcon(self.iconlayer1,self.icon1num,itemTable)
    --高级消耗
    local itemTable1 = tab.starCharts[self.starId]["cost2"][1]
    createItemIcon(self.iconlayer2,self.icon2num,itemTable1)
    local itemTable2 = tab.starCharts[self.starId]["cost2"][2]
    createItemIcon(self.iconlayer3,self.icon3num,itemTable2)

    self:setAttributePanelStatus()
    self:upDateAttributeValue()
    self:upDateAddAttributeValue()
    self:hasHeroPieceNum()
end
--设置突破面板状态
function StarChartsView:setAttributePanelStatus()
    if self.starInfo["tcps"] == nil or self.starInfo["tcps"]["1"] == nil then
        self:setCheckBoxEnable(true)
        self.rightPanel1:setVisible(true)
        self.rightPanel2:setVisible(false)
    else
        self:setCheckBoxEnable(false)
        self.rightPanel1:setVisible(false)
        self.rightPanel2:setVisible(true)
    end
end

function StarChartsView:hasHeroPieceNum()
    -- self.iconlayerNode = self:getUI("Panel7.rightPanel1.iconlayer3")
    local _, itemNum = self._modelMgr:getModel("ItemModel"):getItemsById(self._heroData.soul)
    if self.iconlayerNode.itemicon ~= nil then
        self.iconlayerNode.itemicon:removeFromParent()
        self.iconlayerNode.itemicon = nil
    end
    local itemIcon = IconUtils:createItemIconById({itemId = self._heroData.soul, num = -1, eventStyle = 0})
    self.iconlayerNode:setScale(0.35)
    self.iconlayerNode.itemicon = itemIcon
    self.iconlayerNode:addChild(itemIcon)

    local icon3num = self:getUI("Panel7.rightPanel1.icon3num")
    icon3num:setString(itemNum)
end

--当前属性四维图
function StarChartsView:createCurAttributeNode()
    --当前属性
    if self.propertyimg.curNode then
         self.propertyimg.curNode:removeFromParentAndCleanup(true)
         self.propertyimg.curNode = nil
    end
    if self.starInfo["cp"] == nil then
        return
    end
    local curNode = cc.DrawNode:create()
    curNode:setAnchorPoint(0.5,0.5)
    self.propertyimg:addChild(curNode,3)
    self.propertyimg.curNode = curNode
    local color = cc.c4f(0.0, 0.0, 0.0, 1.0)
    local fillColor = cc.c4f(232/255, 96/255, 64/255, 0.6)
    local cpValue = self.starInfo["cp"]
    local pPolygonPtArr = self:getNodePosArr(cpValue[tostring(self.attributeKey[3])],cpValue[tostring(self.attributeKey[1])],cpValue[tostring(self.attributeKey[4])],cpValue[tostring(self.attributeKey[2])],-1,0)
    curNode:drawPolygon(pPolygonPtArr, table.nums(pPolygonPtArr), fillColor, 0, color)
end
--更新培养当前属性值
function StarChartsView:upDateAttributeValue()
    -- dump(self.starInfo)
    for k , v in pairs(self.attributeKey) do
        local curNode = self:getUI("Panel7.prooertybg.curAtt"..v)
        if self.starInfo["cp"] == nil then
            curNode:setString(0)
        else
            local value = self.starInfo["cp"][tostring(v)]
            print("========value========"..value)
            curNode:setString(value)
        end
    end
end
--更新培养当前增加属性值
function StarChartsView:upDateAddAttributeValue()
    for k , v in pairs(self.attributeKey) do
        local addNode = self:getUI("Panel7.prooertybg.addAtt"..v)
        local addImage = self:getUI("Panel7.prooertybg.changeImg"..v)
        if self.starInfo["tcps"] == nil or self.starInfo["tcps"]["1"] == nil then
            addNode:setString("")
            addImage:setVisible(false)
        else
            local value = self.starInfo["tcps"]["1"][tostring(v)]
            print("========value========"..value)
            if tonumber(value) == 0 then
                addNode:setString("")
                addImage:setVisible(false)
            else
                addImage:setVisible(true)
                if tonumber(value) > 0 then
                    addNode:setString("+"..value)
                    addNode:setColor(UIUtils.colorTable.ccColorQuality2)
                    addImage:loadTexture("arenaReport_jiantou2.png",1)
                else
                    addNode:setColor(UIUtils.colorTable.ccColorQuality6)
                    addImage:loadTexture("arenaReport_jiantou1.png",1)
                end
            end
        end
    end
end

--选中的复选框类型
function StarChartsView:getCheckBoxSelected()
    self.checkBoxSelect = 0
    if self.checkBox1:isSelected() then
        self.checkBoxSelect = 1
    end
    if self.checkBox2:isSelected() then
        self.checkBoxSelect = 2
    end
end
--设置复选框状态
function StarChartsView:setCheckBoxEnable(flag)
    self.checkBox1:setEnabled(flag)
    UIUtils:setGray(self.checkBox1,not flag)
    self.checkBox2:setEnabled(flag)
    UIUtils:setGray(self.checkBox2,not flag)
end
--[[
    leftLength:智力属性
    topLength:攻击属性
    rightLength:知识属性
    bottomLength:防御属性
]]
function StarChartsView:getNodePosArr(leftLength,topLength,rightLength,bottomLength,distX,distY)
    local contentSise = self.propertyimg:getContentSize()
    local maxBorder = 60
    local maxValue = tab:Setting("train_max").value
    local pPolygonPtArr = {}
    local disX,disY = distX or 0, distY or 0

    local leftPos = cc.p(-(leftLength/maxValue[3])*maxBorder + contentSise.width/2+disX,contentSise.height/2+disY)
    local topPos = cc.p(contentSise.width/2+disX,(topLength/maxValue[1])*maxBorder + contentSise.height/2+disY)
    local rightPos = cc.p((rightLength/maxValue[2])*maxBorder + contentSise.width/2+disX,contentSise.height/2+disY)
    local bottomPos = cc.p(contentSise.width/2+disX,-(bottomLength/maxValue[4])*maxBorder + contentSise.height/2+disY)
    table.insert(pPolygonPtArr,leftPos)
    table.insert(pPolygonPtArr,topPos)
    table.insert(pPolygonPtArr,rightPos)
    table.insert(pPolygonPtArr,bottomPos)
    return pPolygonPtArr
end

--突破响应事件
function StarChartsView:breakBtnClick()
    local itemTable = tab.starCharts[self.starId]["cost2"]
    local  gemNum = 0
    if itemTable ~= nil and itemTable[1] == "gem" then
        for i,dTable in pairs(itemTable) do
            if dTable[1] == "gem" then
                gemNum = gemNum + dTable[3]
            end
        end
        if self:checkCondition(gemNum) == false then
            return
        end
    end
    
    self._serverMgr:sendMsg("StarChartsServer", "prime", {heroId = self._heroId, ptype = self.checkBoxSelect}, true, {}, function(result, success) 
        --print(result)
        dump(result)

        self:upDateAttributeValue()
        self:upDateAddAttributeValue()

        self:setCheckBoxEnable(false)
        self.rightPanel1:setVisible(false)
        self.rightPanel2:setVisible(true)
    end)
end

---突破确认事件
--flag  1确认  2取消
function StarChartsView:acceptBtnClick(flag)
    self._serverMgr:sendMsg("StarChartsServer", "primeSure", {heroId = self._heroId, sure = flag}, true, {}, function(result, success) 
        --print(result)
        dump(result)

    end)
end

--初始化星图构成UI
function StarChartsView:initStarCenterType()
    if self._iconawardBg6.awardNode ~= nil then
        self._iconawardBg6.awardNode:removeFromParent()
        self._iconawardBg6.awardNode = nil
    end

    local awardNode = cc.Node:create()
    local awardTable = tab.starCharts[self.starId]["award"]

    local totalWidth = 0
    for i,iconTable in ipairs(awardTable) do
        local itemIcon = nil
        local itemType = iconTable[1]
        local itemId = iconTable[2]
        local itemNum = iconTable[3]
        local eventStyle = 1 --{itemId = itemId, num = num,eventStyle = 0} 
        if itemType == "hero" then
            local heroData = clone(tab:Hero(itemId))
            itemIcon = IconUtils:createHeroIconById({sysHeroData = heroData})
            --itemIcon:getChildByName("starBg"):setVisible(false)
            for i=1,6 do
                if itemIcon:getChildByName("star" .. i) then
                    itemIcon:getChildByName("star" .. i):setPositionY(itemIcon:getChildByName("star" .. i):getPositionY() + 5)
                end
            end

            registerClickEvent(itemIcon, function()
                local NewFormationIconView = require "game.view.formation.NewFormationIconView"
                self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = itemId}, true)
            end)
        elseif itemType == "team" then
            local teamTeam = clone(tab:Team(itemId))
            itemIcon = IconUtils:createSysTeamIconById({sysTeamData = teamTeam,isJin=true})
           
        elseif itemType == "avatarFrame" then
            local frameData = tab:AvatarFrame(itemId)
            param = {itemId = itemId, itemData = frameData}
            itemIcon = IconUtils:createHeadFrameIconById(param)
        elseif itemType == "siegeProp" then
            local propsTab = tab:SiegeEquip(itemId)
            local param = {itemId = itemId, level = 1, itemData = propsTab, quality = propsTab.quality, iconImg = propsTab.art, eventStyle = 1}
            itemIcon = IconUtils:createWeaponsBagItemIcon(param)
        else
            if itemType ~= "tool" then
                itemId = IconUtils.iconIdMap[itemType]
            end
            itemIcon = IconUtils:createItemIconById({itemId = itemId, num = itemNum,eventStyle = eventStyle})
        end
        local scale = 0.71
        if itemType == "team" or itemType == "hero" then
            scale = 0.61
        elseif itemType == "avatarFrame" then
            scale = 0.58
        end
        itemIcon:setScale(scale)
        itemIcon:setAnchorPoint(0.5,0.5)
        itemIcon:setPositionX(itemIcon:getContentSize().width * (i - 1) )
        awardNode:addChild(itemIcon)
        totalWidth = itemIcon:getContentSize().width / 2 * (i - 1)
    end
    awardNode:setPosition(self._iconawardBg6:getContentSize().width / 2 - totalWidth, self._iconawardBg6:getContentSize().height / 2)
    self._iconawardBg6.awardNode = awardNode
    self._iconawardBg6:addChild(awardNode)

    local langdesc = tab.heroMastery[tab.starCharts[self.starId]["heromasteryid"]]["des"]
    self._herodesc6:setString(lang(langdesc))
    
    local quality_type1 = tab.starCharts[self.starId]["quality_type1"]
    local quality1 = tab.starCharts[self.starId]["quality1"]
    local quality_type2 = tab.starCharts[self.starId]["quality_type2"]
    local quality2 = tab.starCharts[self.starId]["quality2"]
    local att1 = lang("SHOW_ATTR_" .. quality_type1) .. ":+" .. quality1
    local att2 = lang("SHOW_ATTR_" .. quality_type2) .. ":+" .. quality2
    self._heroatt16:setString(att1)
    self._heroatt26:setString(att2)


    local bodyNum = #self._starChartsModel:getBodyIdTable(self.starId)
    if not self._starChartsModel:checkStarListOrNull() then
        self._activenum6:setString("0".."/"..bodyNum)
    else
        self._activenum6:setString(self._starChartsModel:getStarActivedNum() .."/"..bodyNum)
    end

    self._costimg16:setVisible(false)
    self._costnum16:setVisible(false)
    self._costimg26:setVisible(false)
    self._costnum26:setVisible(false)
    local costNodeTable = {
    [1] = {["iconNode"] = {self._costimg16,{68,21}},["num"] = {self._costnum16,{86,19}}},
    [2] = {["iconNode"] = {self._costimg26,{136,21}},["num"] = {self._costnum26,{154,19}}}
    }
    local costTable = {}
    local chartsCost1 = tab.starCharts[self.starId]["charts_cost1"]
    local chartsCost2 = tab.starCharts[self.starId]["charts_cost2"]
    if chartsCost1 ~= nil then
        local  tTable = {"soulStar",0,chartsCost1}
        table.insert(costTable,tTable)
    end
    if chartsCost2 ~= nil then
        for i,v in pairs(chartsCost2) do
            table.insert(costTable,v)
        end
    end

    for i,cTable in pairs(costTable) do
        local iconRes,iconScale = self:getIconImg(cTable)
        if iconRes and iconRes ~= "" then
            costNodeTable[i]["iconNode"][1]:loadTexture(iconRes,1)
            costNodeTable[i]["iconNode"][1]:setScale(iconScale)
        end
        costNodeTable[i]["num"][1]:setString(cTable[3])
        costNodeTable[i]["iconNode"][1]:setPositionX(costNodeTable[i]["iconNode"][2][1])
        costNodeTable[i]["num"][1]:setPositionX(costNodeTable[i]["num"][2][1])
        costNodeTable[i]["iconNode"][1]:setVisible(true)
        costNodeTable[i]["num"][1]:setVisible(true)
    end

    if #costTable == 1 then
        costNodeTable[1]["iconNode"][1]:setPositionX(105)
        costNodeTable[1]["num"][1]:setPositionX(121)
    end

    self:checkStarIsCompleted()
end
function StarChartsView:checkStarIsCompleted()
     if self._starChartIsMake == 0 then
        local canComplete = 0
        if self._starChartsModel:getStarActivedNum() == #self._starChartsModel:getBodyIdTable(self.starId) then
             canComplete = 1
        end
        if canComplete == 1 then
            self._activetext6:setVisible(false)
            self._activenum6:setVisible(false)
            self._costPanel6:setVisible(true)
        else
            self._activetext6:setVisible(true)
            self._activenum6:setVisible(true)
            self._costPanel6:setVisible(false)
        end
        self._starCompleteimg6:setVisible(false)
        UIUtils:setGray(self._starmakeBtn6,canComplete == 0 and true or false)
    else
        UIUtils:setGray(self._starmakeBtn6,true)
        self._starmakeBtn6:setVisible(false)
        self._activetext6:setVisible(false)
        self._activenum6:setVisible(false)
        self._costPanel6:setVisible(false)
        self._starCompleteimg6:setVisible(true)
    end
end

function StarChartsView:checkCondition(costNum)
    local cost = self._modelMgr:getModel("UserModel"):getData()["gem"] 
    if tonumber(costNum) and costNum > cost then
        DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function( )
            local viewMgr = ViewManager:getInstance()
            viewMgr:showView("vip.VipView", {viewType = 0})
            end})
        return false 
    end
    return true
end

--激活星体事件
function StarChartsView:activeBtnClick()
    local canActivite = self._starChartsModel:checkActiveState(self._starBodyId)
    if canActivite == false then
        self._viewMgr:showTip("未满足解锁条件,请查看配表")
        return
    end
    if tab.starChartsStars[self._starBodyId]["cost2"] ~= nil then
        local itemTable = tab.starChartsStars[self._starBodyId]["cost2"][1]
        local itemNum = itemTable[3]
        if itemTable[1] == "gem" then
            if self:checkCondition(itemNum) == false then
                return
            end
        end
    end
   
    self._serverMgr:sendMsg("StarChartsServer", "activation", {heroId = self._heroId, starId = self._starBodyId}, true, {}, function(result, success) 
        local showOtherUI = function()
            local catenaId,activityNum,totalCatenaNum = self._starChartsModel:getCatenaNum(self.starId,self._starBodyId)
            if tonumber(activityNum) ==  tonumber(totalCatenaNum) then
                self._viewMgr:showDialog("starCharts.StarChartsChainDialog",{container = self,showtype = StarChartConst.SatrChainType,starId = self.starId,catenaId = catenaId,callback = function()
                    -- if not self:abilityUpTeam() then
                    --     self:fightUpAni()
                    -- end 
                    self:abilityUpTeam()
                end},true) 
            else
                self:abilityUpTeam()
            end

        end
        if result["reward"] ~= nil then
            DialogUtils.showGiftGet( {gifts = result["reward"],callback = showOtherUI})
        else
            showOtherUI()
        end 

    end)
end

function StarChartsView:abilityUpTeam()
    local ability_showtype = tab.starChartsStars[self._starBodyId]["ability_showtype"]
    if ability_showtype == StarChartConst.TeamAdd then
        local teamType = tab.starChartsStars[self._starBodyId]["ability_team_type"]
        local teamSort = tab.starChartsStars[self._starBodyId]["ability_team_sort"]
        local teamNum = tab.starChartsStars[self._starBodyId]["ability_team_num"]

        local isPrecent = false
        local attrTab = tab.attClient[teamSort]
        if attrTab and attrTab.attType == 1 then
            isPrecent = true
        end
        if teamType ~= 0 and not isPrecent then
            self._viewMgr:showDialog("starCharts.StarChartsrUpTeamDialog",{volume=teamType,buffId=teamSort,buffValue=teamNum,callback = function( )
                    --更新战力
                    self:fightUpAni()
            end})
            return true            
        end
    end
    self:fightUpAni()
    return false
end
function StarChartsView:checkSoulNum(costSoulNum)
    if self.starInfo == nil or self.starInfo["ss"] == nil then
        return false
    end
    local soulNum = self.starInfo["ss"]
    if tonumber(costSoulNum) and costSoulNum > soulNum then
        return false 
    end
    return true
end

--星图构成Button
function StarChartsView:starMakeBtnClick()
    if tab.starCharts[self.starId]["charts_cost2"] ~= nil then
        local itemTable = tab.starCharts[self.starId]["charts_cost2"][1]
        local itemNum = itemTable[3]
        if itemTable[1] == "gem" then
            if self:checkCondition(itemNum) == false then
                return
            end
        end
    end
    

    if self._starChartsModel:getStarActivedNum() < #self._starChartsModel:getBodyIdTable(self.starId) then
        self._viewMgr:showTip(lang("TIP_starCharts11"))
        return
    end

    local soulstarcost1 = tab.starCharts[self.starId]["charts_cost1"]
    if self:checkSoulNum(tonumber(soulstarcost1)) == false then
        self._viewMgr:showTip(lang("TIP_starCharts3"))
        return
    end

    DialogUtils.showShowSelect({desc = lang("TIP_starCharts8"),callback1=function( )
            self._serverMgr:sendMsg("StarChartsServer", "compose", {heroId = self._heroId}, true, {}, function(result, success) 
                dump(result)
                local function touchCallBack(selectType)
                    if StarChartConst.NOTOPEN then

                    else
                        if selectType == StarChartConst.SatrCompletedType then
                            self:switchUIByType(StarChartConst.CenterType,self._starBodyId)
                        elseif selectType == StarChartConst.SatrChainType then

                        end
                    end
                    self:fightUpAni()
                end 
                self._viewMgr:showDialog("starCharts.StarChartsChainDialog",{container = self,showtype = StarChartConst.SatrCompletedType,starId = self.starId , callback = touchCallBack},true) 
            
            end)
    end})

    
end

--初始化星体所对应的面板 end

function StarChartsView:initLabelNodeTable()
    local desNode = self:getUI("Panel3.ScrollView1.autolist.spelltext")
    local valueNode = self:getUI("Panel3.ScrollView1.autolist.spellnum")
    -- desNode:setAnchorPoint(0,0.5)
    self.labelTable = {[1]={},[2]={}}
    -- if self.starInfo == nil then return end

    local starInfo = self._starChartsModel:getBodyIdTable(self.starId)
    if not next(starInfo) then print("不包含任何星体") return end
    table.sort(starInfo,function(a,b)return (tonumber(a) >  tonumber(b)) end)  
    -- dump(starInfo)
    for _, bodyId in pairs(starInfo) do
        local abilitySort = tab.starChartsStars[bodyId]["ability_sort"]
        local ability_showtype = tab.starChartsStars[bodyId]["ability_showtype"]
        if ability_showtype == StarChartConst.HeroAdd then
            table.insert(self.heroAbilityTypeTable,bodyId)
            self.labelTable[abilitySort][StarChartConst.HeroAdd] = {}
        elseif ability_showtype == StarChartConst.TeamAdd then
            table.insert(self.teamAbilityTypeTable,bodyId)
            self.labelTable[abilitySort][StarChartConst.TeamAdd] = {}
        elseif ability_showtype == StarChartConst.SysteamAdd then
            table.insert(self.proceedAbilityTypeTable,bodyId)
            self.labelTable[abilitySort][StarChartConst.SysteamAdd] = {}
        elseif ability_showtype == StarChartConst.SpecialAdd then
            table.insert(self.specialAbilityTypeTable,bodyId)
            self.labelTable[abilitySort][StarChartConst.SpecialAdd] = {}
        end
    end

    --英雄加成属性
    for _,index in pairs(self.heroAbilityTypeTable) do
        local abilitySort = tab.starChartsStars[index]["ability_sort"]      --加成能力生效类型 1英雄上场生效 2全局生效
        local abilityValue = tab.starChartsStars[index]["ability_hero"] or 0      --加成值
        local ability_hero_type = tab.starChartsStars[index]["ability_hero_type"] or 0   --加成类型
        local isPercent = self:checkAbilityIsPercent(index)                                                   --是否显示百分比   
        local key,typeValue = self:getTypeAndKey(index)
        if key ~= nil then
            local isLock = self._starChartsModel:checkOrLock(index)
            local acvitityNum = 0
            if isLock then acvitityNum = abilityValue end
            if self.labelTable[abilitySort][StarChartConst.HeroAdd][key] == nil then
                self.labelTable[abilitySort][StarChartConst.HeroAdd][key] = {}
                self.labelTable[abilitySort][StarChartConst.HeroAdd][key].id = index
                self.labelTable[abilitySort][StarChartConst.HeroAdd][key].node1 =  desNode:clone()
                self.labelTable[abilitySort][StarChartConst.HeroAdd][key].node2 =  valueNode:clone()
                self.labelTable[abilitySort][StarChartConst.HeroAdd][key].value =  abilityValue
                self.labelTable[abilitySort][StarChartConst.HeroAdd][key].acvitityNum =  acvitityNum
                self.labelTable[abilitySort][StarChartConst.HeroAdd][key].isPercent = isPercent
                local desValue = self:getAddAttributeDes(typeValue,key)
                self.labelTable[abilitySort][StarChartConst.HeroAdd][key].desValue =  desValue

            else
                self.labelTable[abilitySort][StarChartConst.HeroAdd][key].value = self.labelTable[abilitySort][StarChartConst.HeroAdd][key].value + abilityValue
                self.labelTable[abilitySort][StarChartConst.HeroAdd][key].acvitityNum = self.labelTable[abilitySort][StarChartConst.HeroAdd][key].acvitityNum + acvitityNum
            end
        end
    end
    --兵团加成属性
    for _,index in pairs(self.teamAbilityTypeTable) do
        local abilitySort = tab.starChartsStars[index]["ability_sort"]            --加成能力生效类型 1英雄上场生效 2全局生效
        local abilityTeamNum = tab.starChartsStars[index]["ability_team_num"] or 0       -- 生效加成值
        local isPercent = self:checkAbilityIsPercent(index)
        local key,typeValue = self:getTypeAndKey(index)
        if key ~= nil then
            local isLock = self._starChartsModel:checkOrLock(index)
            local acvitityNum = 0
            if isLock then acvitityNum = abilityTeamNum end
            if self.labelTable[abilitySort][StarChartConst.TeamAdd][key] == nil then
                self.labelTable[abilitySort][StarChartConst.TeamAdd][key] = {}
                self.labelTable[abilitySort][StarChartConst.TeamAdd][key].id = index
                self.labelTable[abilitySort][StarChartConst.TeamAdd][key].node1 =  desNode:clone()
                self.labelTable[abilitySort][StarChartConst.TeamAdd][key].node2 =  valueNode:clone()
                self.labelTable[abilitySort][StarChartConst.TeamAdd][key].value =  abilityTeamNum
                self.labelTable[abilitySort][StarChartConst.TeamAdd][key].acvitityNum =  acvitityNum
                self.labelTable[abilitySort][StarChartConst.TeamAdd][key].isPercent = isPercent
                local desValue = self:getAddAttributeDes(typeValue,key)
                self.labelTable[abilitySort][StarChartConst.TeamAdd][key].desValue =  desValue
            else
                self.labelTable[abilitySort][StarChartConst.TeamAdd][key].value = self.labelTable[abilitySort][StarChartConst.TeamAdd][key].value + abilityTeamNum
                self.labelTable[abilitySort][StarChartConst.TeamAdd][key].acvitityNum = self.labelTable[abilitySort][StarChartConst.TeamAdd][key].acvitityNum + acvitityNum
            end
        end
    end
    --加成属性
    for _,index in pairs(self.proceedAbilityTypeTable) do
        local abilitySort = tab.starChartsStars[index]["ability_sort"]            --加成能力生效类型 1英雄上场生效 2全局生效
        local isPercent = self:checkAbilityIsPercent(index)
        local key,typeValue = self:getTypeAndKey(index)
        if key ~= nil then
            local isLock = self._starChartsModel:checkOrLock(index)
            local acvitityNum = 0
            if isLock then acvitityNum = 0 end
            if key ~= -1 then
                if self.labelTable[abilitySort][StarChartConst.SysteamAdd][key] == nil then
                    self.labelTable[abilitySort][StarChartConst.SysteamAdd][key] = {}
                    self.labelTable[abilitySort][StarChartConst.HeroAdd][key].id = index
                    self.labelTable[abilitySort][StarChartConst.SysteamAdd][key].node1 =  desNode:clone()
                    self.labelTable[abilitySort][StarChartConst.SysteamAdd][key].node2 =  valueNode:clone()
                    self.labelTable[abilitySort][StarChartConst.SysteamAdd][key].value =  0
                    self.labelTable[abilitySort][StarChartConst.SysteamAdd][key].acvitityNum =  0
                    self.labelTable[abilitySort][StarChartConst.SysteamAdd][key].isPercent = isPercent
                    local desValue = self:getAddAttributeDes(typeValue,key)
                    self.labelTable[abilitySort][StarChartConst.SysteamAdd][key].desValue =  desValue
                else
                    self.labelTable[abilitySort][StarChartConst.SysteamAdd][key].value = self.labelTable[abilitySort][StarChartConst.SysteamAdd][key].value + 0
                    self.labelTable[abilitySort][StarChartConst.SysteamAdd][key].acvitityNum = self.labelTable[abilitySort][StarChartConst.SysteamAdd][key].acvitityNum + 0
                end
            end
        end
    end
    --专精(只显示专精描述)
    for _,index in pairs(self.specialAbilityTypeTable) do
        local abilitySort = tab.starChartsStars[index]["ability_sort"]            --加成能力生效类型 1英雄上场生效 2全局生效
        -- local isPercent = self:checkAbilityIsPercent(index)
        local key,typeValue = self:getTypeAndKey(index)
        if key ~= nil then
            if key ~= -1 then
                if self.labelTable[abilitySort][StarChartConst.SpecialAdd][key] == nil then
                    self.labelTable[abilitySort][StarChartConst.SpecialAdd][key] = {}
                    self.labelTable[abilitySort][StarChartConst.HeroAdd][key].id = index
                    self.labelTable[abilitySort][StarChartConst.SpecialAdd][key].node1 =  desNode:clone()
                    self.labelTable[abilitySort][StarChartConst.SpecialAdd][key].node2 =  nil
                    self.labelTable[abilitySort][StarChartConst.SpecialAdd][key].onlyShowDes = true
                    local desValue = self:getAddAttributeDes(typeValue,key)
                    self.labelTable[abilitySort][StarChartConst.SpecialAdd][key].desValue =  desValue
                end
            end
        end
    end
    dump(self.labelTable)
end


function StarChartsView:setAutoListNode()
    local scrollContentSize = self._scrollView:getContentSize()
    local globalPanel = self:getUI("Panel3.ScrollView1.autolist.GlobalPanel")
    local heroPanel = self:getUI("Panel3.ScrollView1.autolist.heroPanel")
    local zjPanel = self:getUI("Panel3.ScrollView1.autolist.zjPanel")
    local totalHeight = self:createHeroMasteryNode(0)
    zjPanel:setPositionY(totalHeight)
    totalHeight = totalHeight + zjPanel:getContentSize().height

    local abilityHeroHeight = self:abilityNodeHeight(StarChartConst.AbilityHeroSort,totalHeight)
    totalHeight = totalHeight + abilityHeroHeight
    --英雄面板
    heroPanel:setPositionY(totalHeight)
    totalHeight = totalHeight + heroPanel:getContentSize().height
    print("=========totalHeight========"..totalHeight)
    local allAbilityNodeheight = self:abilityNodeHeight(StarChartConst.AbilityAllSort,totalHeight)
    print("=========allAbilityNodeheight========"..allAbilityNodeheight)
    totalHeight = totalHeight + allAbilityNodeheight
    print("=========totalHeight========"..totalHeight)
    --全局面板
    globalPanel:setPositionY(totalHeight)
    self._listWiget:setContentSize(scrollContentSize.width,totalHeight)
    local maxHeight = scrollContentSize.height
    if totalHeight + globalPanel:getContentSize().height > scrollContentSize.height then
        maxHeight = totalHeight + globalPanel:getContentSize().height
        self._listWiget:setPositionY(0)
    else
        self._listWiget:setPositionY(maxHeight - totalHeight - globalPanel:getContentSize().height)
    end
    self._scrollView:setInnerContainerSize(cc.size(scrollContentSize.width, totalHeight + globalPanel:getContentSize().height))
end



--创建英雄生效的node
function StarChartsView:abilityNodeHeight(typeValue,beginDistance)
    local typeLabelTable = self.labelTable[typeValue]
    local listNode = ccui.Widget:create()
    listNode:setAnchorPoint(0,0)
    local totalHeight = 0
    
    local orderByKeyFun = function(tableData)
        local keyTable = {}
        local tempOrderTable = {}
        for k , v in pairs(tableData) do
            table.insert(keyTable,k)
        end
        table.sort(keyTable,function(a,b)return (tonumber(a) >  tonumber(b)) end)
        for k , v in pairs(keyTable) do
            table.insert(tempOrderTable,tableData[v])
        end
        return tempOrderTable
    end

    local resetTableFun = function(tableData)
        local starTab = tab.starChartsStars
        local newTable = {}
        local i = 1
        for k , info in pairs(tableData) do
            local bodyId = info.id
            local orderValue = tonumber(starTab[bodyId]["desc_order"])*10000
            if newTable[orderValue] then
                orderValue = orderValue + i
            end
            newTable[orderValue] = info
            i = i + 1
        end
        return newTable
    end

    if typeLabelTable ~= {} then
        local orderTab = orderByKeyFun(typeLabelTable)
        local index = 1
        for k , data in pairs(orderTab) do
            local resetTable = resetTableFun(data)
            local realTable = orderByKeyFun(resetTable)
            for _, v in pairs(realTable) do               
                v.node1:setPositionY(beginDistance + (index -1)*StarChartConst.Distance+15)
                v.node1:setVisible(true)
                listNode:addChild(v.node1)
                if v.onlyShowDes then                               --特殊属性（专精只显示描述）
                    v.node1:setString(v.desValue)
                else
                    v.node1:setString(v.desValue ..":")
                    v.node2:setPositionY(beginDistance + (index -1)*StarChartConst.Distance+15)
                    v.node2:setVisible(true)
                    if v.isPercent then
                        if v.acvitityNum == 0 then
                            v.node2:setString(v.acvitityNum .."/"..v.value .."%")
                        else
                            v.node2:setString(v.acvitityNum .."%".."/"..v.value .."%")
                        end
                    else
                        v.node2:setString(v.acvitityNum.."/"..v.value)
                    end

                    local colorValue = tonumber(v.acvitityNum) == tonumber(v.value) and cc.c3b(28,162,22) or cc.c3b(100, 82, 82)
                    v.node1:setColor(colorValue)
                    v.node2:setColor(colorValue)

                    listNode:addChild(v.node2)
                    self:adjustWidgetDistance(v.node1,{v.node2})
                end

                index = index + 1
            end
        end
        self._listWiget:setContentSize(cc.size(315,(index -1)*StarChartConst.Distance+15))
        self._listWiget:addChild(listNode)
        totalHeight = (index - 1)*StarChartConst.Distance
    end
    return totalHeight
end

--创建专精UI
function StarChartsView:createHeroMasteryNode(beginDistance)
    local catenaIds = tab.starCharts[self.starId]["catena_id"]
    local starChartsCatenaTab = tab.starChartsCatena
    local masteryIdTable = {}
    for k , v in pairs(catenaIds) do
        local temptable = {}
        temptable["id"] = starChartsCatenaTab[v]["heromasteryid"]
        temptable["order"] = starChartsCatenaTab[v]["desc_order"]
        table.insert(masteryIdTable,temptable)
    end
    --构成加专精
    local masteryId = tab.starCharts[self.starId]["heromasteryid"]
    if masteryId then
        local temptable = {}
        temptable["id"] = masteryId
        temptable["order"] = 100
        table.insert(masteryIdTable,temptable)
    end
    table.sort(masteryIdTable,function(a,b)return (tonumber(a.order) >  tonumber(b.order)) end)

    local totalHeight = 0
    local heroMasteryTab = tab.heroMastery
    local i = 0
    for k , v in pairs(masteryIdTable) do
        local name = lang(heroMasteryTab[v["id"]]["name"])
        local des = lang(heroMasteryTab[v["id"]]["des"])
        local tLabel = {text = name ..":"..des,fontsize = 20,color = cc.c3b(100, 82, 82),width = 300,anchorPoint = ccp(0, 0)}
        local node = UIUtils:createMultiLineLabel(tLabel)
        self._listWiget:addChild(node)
        self.heroMasteryTable[v["id"]] = {}
        self.heroMasteryTable[v["id"]].node = node
        node:setPositionX(10)
        node:setPositionY(beginDistance + totalHeight)
        totalHeight = totalHeight + node:getContentSize().height + 15
        i = i + 1
    end
    self._listWiget:setContentSize(cc.size(315,totalHeight))
    self:upMasteryNode()
    return totalHeight
end



--更新星体属性值
function StarChartsView:updateAbilityValue(bodyId)
    local ability_showtype = tab.starChartsStars[bodyId]["ability_showtype"]
    local abilitySort = tab.starChartsStars[bodyId]["ability_sort"]      --加成能力生效类型 1英雄上场生效 2全局生效
    local abilityValue = 0
    if ability_showtype == StarChartConst.HeroAdd then
        abilityValue = tab.starChartsStars[bodyId]["ability_hero"] or 0     --加成值
    elseif ability_showtype == StarChartConst.TeamAdd then
        abilityValue = tab.starChartsStars[bodyId]["ability_team_num"] or 0       -- 生效加成值
    elseif ability_showtype == StarChartConst.SysteamAdd then
        abilityValue = tab.starChartsStars[bodyId]["proceeds_type"] or -1    --收益增加涉及系统
    elseif ability_showtype == StarChartConst.SpecialAdd then   
        return
    end
    local key,typeValue = self:getTypeAndKey(bodyId)
    if key == nil then return end
    if self.labelTable[abilitySort][ability_showtype][key] ~= nil then
        local labelTab = self.labelTable[abilitySort][ability_showtype][key]
        labelTab.acvitityNum = labelTab.acvitityNum + abilityValue
        local acvitityNum = labelTab.acvitityNum
        local value = labelTab.value
        
        if labelTab.acvitityNum == value then
            labelTab.node1:setColor(cc.c3b(28,162,22))
            labelTab.node2:setColor(cc.c3b(28,162,22))
        end

        if labelTab.isPercent then
            if acvitityNum == 0 then
                labelTab.node2:setString(labelTab.acvitityNum .."/"..labelTab.value .."%")
            else
                labelTab.node2:setString(labelTab.acvitityNum .."%".."/"..labelTab.value .."%")
            end
        else
            labelTab.node2:setString(acvitityNum.."/"..value)
        end
    end
end
--更新专精node
function StarChartsView:upMasteryNode()
    if self.starInfo == nil or self.starInfo["scIds"] == nil or not next(self.starInfo["scIds"]) then
        return
    end
    local starChartsCatenaTab = tab.starChartsCatena
    for id , v in pairs(self.starInfo["scIds"]) do
        local heromasteryId = starChartsCatenaTab[tonumber(id)]["heromasteryid"]
        if heromasteryId then
            if self.heroMasteryTable[heromasteryId] then
                self.heroMasteryTable[heromasteryId].node:setColor(cc.c3b(28,162,22))
            end
        end
    end
    if self.starInfo["cf"] == 1 then
        local heromasteryId = tab.starCharts[self.starId]["heromasteryid"]
        if heromasteryId then
            if self.heroMasteryTable[heromasteryId] then
                self.heroMasteryTable[heromasteryId].node:setColor(cc.c3b(28,162,22))
            end
        end
    end
end

--根据英雄id获取属性类型和key
function StarChartsView:getTypeAndKey(bodyId)
    local starChartsTable = tab.starChartsStars
    local ability_showtype = starChartsTable[bodyId]["ability_showtype"]
    local abilitySort = starChartsTable[bodyId]["ability_sort"]      --加成能力生效类型 1英雄上场生效 2全局生效
    local ability_system = starChartsTable[bodyId]["ability_system"]  --加成能力生效系统

    local tempKey,realKey = nil,nil
    local keyTable = {}
    if desKeys[ability_showtype] == nil or not next(desKeys[ability_showtype]) then return nil end
    for k , v in pairs(desKeys[ability_showtype]) do
        local keyValue = starChartsTable[bodyId][v] or -1
        table.insert(keyTable,keyValue)
    end
    local effectiveKey = false
    for index , key in pairs(keyTable) do
        if not effectiveKey and key ~= -1 then effectiveKey = true end
        if index == 1 then
            tempKey = key
        else
            tempKey = tempKey .. "#" .. key
        end
    end

    if effectiveKey == false then
        return nil
    else
        realKey = ability_system .. "#" ..tempKey
    end

    return realKey,ability_showtype
end

--获取属性描述
function StarChartsView:getAddAttributeDes(typeValue,ids) 
    if typeValue == nil or not next(desKeys[typeValue]) or nil then return "" end
    local abilityValue = nil
    local desString = ""
    local idList = string.split(ids, "#")
    if typeValue == StarChartConst.SpecialAdd then            --特殊类型特殊处理
        if idList[2] == -1 then
            return ""
        else
            print("======idList[2]====="..idList[2])
            return lang(tab.heroMastery[tonumber(idList[2])]["des"])          --从专精表获取描述
        end
    end

    -- dump(idList)
    local tempStr = ""
    local systemValue = idList[1]    --加成能力生效系统
    for k , v in pairs(desKeys[typeValue]) do
        if idList[k + 1] ~= nil and tonumber(idList[k + 1]) ~= 0 then
            local desKey = v .. idList[k+1]
            tempStr = tempStr .. lang(desKey)
        end
    end
    if tonumber(systemValue) ~= 0 then
        desString = lang("ability_system"..systemValue)..tempStr
    else
        desString = tempStr
    end
    return desString
end
--获取星体属性加成值
function StarChartsView:getAbilityValue(bodyId)
    local starChartsTable = tab.starChartsStars
    local ability_showtype = starChartsTable[bodyId]["ability_showtype"]
    if ability_showtype == StarChartConst.SpecialAdd then            --特殊类型特殊处理(专精没有加成值显示)
        return ""
    end
    local key = addValue[ability_showtype]["key"]
    local abilityValue = 0
    if key ~= nil then
        abilityValue = starChartsTable[bodyId][key] or 0
    end
    local isPercent = self:checkAbilityIsPercent(bodyId)
    if isPercent and abilityValue ~= 0 then
        return abilityValue .. "%"
    end
    return abilityValue
    
end

--英雄属性是否百分比显示
function StarChartsView:checkAbilityIsPercent(bodyId)
    local ability_showtype = tab.starChartsStars[bodyId]["ability_showtype"]
    local keyType = addValue[ability_showtype]["keyType"]
    if keyType == nil then return false end
    local abilityType = tab.starChartsStars[bodyId][keyType]
    local attrTab = tab.attClient[abilityType]
    if attrTab and attrTab.attType == 1 then
        return true
    end
    return false
end

--重置星体属性值
function StarChartsView:resetBodyAbilityValue()
    for _ , typeData in pairs(self.labelTable) do
        for _ , abilityData in pairs(typeData) do
            for key,bodyNode in pairs(abilityData) do
                bodyNode.acvitityNum = 0
                bodyNode.node1:setColor(cc.c3b(100, 82, 82))
                bodyNode.node2:setColor(cc.c3b(100, 82, 82))
                if bodyNode.isPercent then
                    bodyNode.node2:setString("0" .."/"..bodyNode.value .."%")
                else
                    bodyNode.node2:setString("0".."/"..bodyNode.value)
                end
            end
        end
    end
    for k , v  in pairs(self.heroMasteryTable) do
        v.node:setColor(cc.c3b(100, 82, 82))
    end
end


---重置调用
function StarChartsView:resetCallBack()
    --切换成通用面板
    self:switchUIByType(StarChartConst.CommonType,0)
    --英雄技能等级重置
    self:upDataSkillLevel()
    --英雄属性重置
    self:upDataQuality()
    --所有星体加成属性重置
    self:resetBodyAbilityValue()
    --星体状态重置
    self._mapLayer:resetAllBodyState()
    --将中心星体移动到屏幕中心
    local centerId = tab.starCharts[self.starId]["centrality"]
    self:mapToCenterPos(centerId,false,nil,200)
    --重置激活数量及星魂数量
    self:setActiviteNum(true)
    self:setSoulNum()
    --更新重置按钮状态
    self:setResetBtnStatus()
    --重置成功弹tips
    self._viewMgr:showTip(lang("TIP_starCharts10"))
    --可激活星体动画
    self:addCanActivityAni()
end

function StarChartsView:reflashUI()
    -- body
end

function StarChartsView:onTop()
    
end
-- 第一次进入调用, 有需要请覆盖
function StarChartsView:onShow()

end

-- 被其他View盖住会调用, 有需要请覆盖
function StarChartsView:onHide()

end

function StarChartsView:onDestroy()
    UIUtils:reloadLuaFile("starCharts.StarChartsView")
end



--更新UI
function StarChartsView:updateUI(upTypeName)
    self.starInfo = self._starChartsModel:getStarInfo()
    print("========self.starInfo=========")
    dump(self.starInfo)
    if upTypeName == "convert" then           --星魂转换
        self:setSoulNum(true)
    elseif upTypeName == "activation" then    --星体激活
        self:setActiviteNum(true)
        self:setSoulNum(true)
        self._mapLayer:updateBodyNode(self._starBodyId)
        self:updateAbilityValue(self._starBodyId)

        self:updateStarActived() 
        --英雄技能等级重置
        self:upDataSkillLevel()
        --英雄属性重置
        self:upDataQuality()
        --更新分支数量
        self:updateCatenaName()
        --更新重置按钮状态
        self:setResetBtnStatus()
        --更新专精
        self:upMasteryNode()

    elseif upTypeName == "reset" then    --星体重置
        self:resetCallBack()
    elseif upTypeName == "prime" then   --灌注
        
    elseif upTypeName == "primeSure" then   --灌注确认和取消
        self:upDateAttributeValue()
        self:upDateAddAttributeValue()
        self:setCheckBoxEnable(true)
        self.rightPanel1:setVisible(true)
        self.rightPanel2:setVisible(false)
        self:createCurAttributeNode()
        self:hasHeroPieceNum()
    end
    if upTypeName == "compose" then    --星体构成
        self:updateIsMake()
        --更新专精
        self:upMasteryNode()
        --更新英雄属性
        self:upDataQuality()
    end
    if upTypeName ~= "activation" and upTypeName ~= "compose" then
        --更新战力
        self:fightUpAni()
    end
    
end



function StarChartsView:fightUpAni()
    local beforeFightNum = self._heroData.score or 0
    local afterFightNum = self._heroModel:getHeroScore(self._heroId)
    self._zhandouliLabel:setString((afterFightNum or 0))
    self._heroData.score = afterFightNum
    if tonumber(afterFightNum) > tonumber(beforeFightNum) then
        TeamUtils:setFightAnim(self, {oldFight = beforeFightNum, 
            newFight = afterFightNum, x = MAX_SCREEN_WIDTH/2, y = MAX_SCREEN_HEIGHT-200})
    end
end
 
-- 调整控件间距
function StarChartsView:adjustWidgetDistance(beginNode,nodeTable,distance)
    local distance = distance or 0
    local tempPosX = 0
    local anchorPointX = beginNode:getAnchorPoint().x
    local beginNodeConSize = beginNode:getContentSize()
    local beginPosX = beginNode:getPositionX()
    tempPosX = (1 - anchorPointX)*beginNodeConSize.width + beginPosX
    for k , node in pairs(nodeTable) do
        local nAnchorPointX = node:getAnchorPoint().x
        local nConSize = node:getContentSize()
        node:setPositionX(tempPosX + nAnchorPointX*nConSize.width + distance)
        tempPosX = tempPosX + (1 - nAnchorPointX)*nConSize.width + distance
    end
end

-- 数值变化动画
function StarChartsView:runValueChangeAnim( label,endFunc )
    if not label then return end
    if not label:getActionByTag(101) then
        local preColor = label:getColor()
        label.endFunc = endFunc
        if not label.changeColor then
            label:setColor(cc.c3b(0, 255, 0))
        else
            label:setColor(label.changeColor)
        end
        local seq = cc.Sequence:create(cc.ScaleTo:create(0.1,1.2),cc.ScaleTo:create(0.3,1),cc.CallFunc:create(function( )
            label:setColor(preColor)
            if type(label.endFunc) == "function" then
                label.endFunc()
            end
        end))
        seq:setTag(101)
        label:runAction(seq)
    else
        label.endFunc = endFunc
    end
end


function StarChartsView:getAsyncRes()
    return 
    {
        {"asset/ui/starCharts.plist", "asset/ui/starCharts.png"},
        {"asset/ui/treasure.plist", "asset/ui/treasure.png"},
    }
end
return StarChartsView