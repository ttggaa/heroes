--
-- Author: <ligen@playcrab.com>
-- Date: 2016-07-20 20:49:51
--
local maxComStage = table.nums(tab.devComTreasure) + 1
-- 引用别的文件的 解析
local GlobalTipView = require("game.view.global.GlobalTipView")
local TreasureComUpView = class("TreasureComUpView", BasePopView)
local skillTp = {"主动技能","兵团被动","自动技能","开场技能","自动技能","英雄被动",}

function TreasureComUpView:ctor()
    self.super.ctor(self)
    self._tModel = self._modelMgr:getModel("TreasureModel")

    self._skillTabMap = {
        tab.heroMastery,
        tab.playerSkillEffect,
        tab.skillPassive,
        tab.skillCharacter,
        tab.skillAttackEffect,
        tab.skill,
    }
end

-- 初始化UI后会调用, 有需要请覆盖
function TreasureComUpView:onInit()
    self._comTreasureUp = self:getUI("bg.layer.comTreasureUp")
    self._materialNode = self:getUI("bg.layer.materialNode")
    self._materialNode:setVisible(false)
    self._materialPanel = self:getUI("bg.layer.materialPanel")
    self._propertyNode = self:getUI("bg.layer.propertyNode")
    self._treasureNode = self:getUI("bg.layer.treasureNode")

    self._infoBg = self:getUI("bg.layer.infoBg")
    self._infoScrollView = self:getUI("bg.layer.infoBg.infoScrollView")

    self._title = self:getUI("bg.layer.headBg.title")
    self._title:setFontName(UIUtils.ttfName)
    UIUtils:setTitleFormat(self._title,1)
    self._type = self:getUI("bg.layer.comTreasureUp.left.type")

    self._treasureName = self._treasureNode:getChildByFullName("treasureNameCN")
    self._treasureName:setString("")
    -- self._zhandouliLabel = self._treasureNode:getChildByFullName("zhandouliBmpLab")
    -- self._zhandouliLabel:setFntFile(UIUtils.bmfName_zhandouli)

    self._comStage = self._treasureNode:getChildByFullName("comstage")
    self._comStage:setFontName(UIUtils.ttfName)
    self._comStage:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._comStage:setString("")

    self._des1 = self:getUI("bg.layer.des1")
    self._des1:setFontName(UIUtils.ttfName)
    self._des1:setString("进阶材料")
    self._des2 = self:getUI("bg.layer.des2")
    self._des2:setFontName(UIUtils.ttfName)
    self._des2:setString("组合进阶")

    self._attPanel = self:getUI("bg.layer.attPanel")
    self._attPanel:setVisible(false)

    self._iconMaxStage = self:getUI("bg.layer.iconMaxStage")

    self._curTreasureData = { }
    self:registerClickEventByName("bg.layer.closeBtn", function()
        self:close()
        UIUtils:reloadLuaFile("treasure.TreasureComUpView")
    end )


    self._upBtn = self:getUI("bg.layer.upBtn")
    self:registerClickEventByName("bg.layer.upBtn", function()
        if self._curTreasureData.upType == "com" and self._curTreasureData.stage == maxComStage then
            self._viewMgr:showTip("已满阶")
            return
        end
        if not self._abundent then
            self._viewMgr:showTip(lang("TIPS_ARTIFACT_01") or "材料不足")
            return
        end
        self:lock(-1)
        if self._curTreasureData.upType == "com" then
            local comInfo = self._modelMgr:getModel("TreasureModel"):getComTreasureById(tostring(self._curTreasureData.id))
            for k, v in pairs(comInfo.treasureDev) do
                if v.s < comInfo.stage + 1 then
                    self._viewMgr:showTip(lang("TIPS_ARTIFACT_02") or "散件宝物等级不足")
                    self:unlock()
                    return
                end
            end
            local curTreasureData = clone(self._modelMgr:getModel("TreasureModel"):getComTreasureById(tostring(self._curTreasureData.id)))
            self._serverMgr:sendMsg("TreasureServer", "promoteComTreasure", { comId = self._curTreasureData.id }, true, { }, function(result)
                self._curTreasureData.stage = self._curTreasureData.stage + 1
        
                --组合宝物悬浮窗  播放进阶动画放到下一帧
                ScheduleMgr:nextFrameCall(self, function()
                    audioMgr:playSound("Artifact")
                    self._viewMgr:showDialog("treasure.TreasureUpStageComView",
                    { treasureData = curTreasureData, id = self._curTreasureData.id, stage = self._curTreasureData.stage, callBack = handler(self, self.fightValueCallBack) }, true,false,nil,true)

                    self:unlock()
                end)                
                self:reflashUI(self._curTreasureData)

            end )
        end
    end )

    self:listenReflash("TreasureModel", self.reflashUI)
    self:listenReflash("ItemModel", self.reflashUI)
end


local comMcs = TreasureConst.comMcs or {
    [10] = "huanyingshengong_treasurehuanyingshengong",
    -- "huanyingshengong",
    [11] = "shenshengxueping_treasureshenshengxueping",
    -- "longping",

    [22] = "fashizhijie_treasurefashizhijie",
    -- "fashizhijie",
    [21] = "moliyuanquan_treasuremoliyuanquan",
    -- "moliyuanquan",

    [30] = "zuzhoukaijia_treasurezuzhoukaijia",
    -- "zuzhoukaijia",
    [31] = "yemanzhifu_treasurezhifu",
    -- "leidianjian",
    [32] = "guiwangdoupeng_treasureguiwangdoupeng",
    -- "guiwangdoupeng",

    [40] = "shenglongkaijia_treasureshenglongkaijia",
    -- "shenglongkaijia",
    [41] = "jian_treasureicon",
    [42] = "taitanshenjian_treasuretaitanshenjian",
    [45] = "jinmoqiu_jinmoqiu",
}
local comMcOffsetY =
{
    [10] = 0,
    [11] = - 20,

    [22] = 0,
    [21] = 0,

    [30] = 0,
    [31] = 45,
    [33] = 0,
    [32] = 0,

    [40] = 0,
    [41] = 30,
    [42] = 30,
    [43] = 30,
    [23] = 0,
    [12] = 20,
    [44] = 20,
    [45] = 20,
    [46] = 20,
}

-- 接收自定义消息
function TreasureComUpView:reflashUI(data)
    -- if true then return end
    if data and not data.id then data = nil end
    self._curTreasureData = data or self._curTreasureData
    if not data then data = self._curTreasureData end
    local upType = self._curTreasureData.upType or "dis"
    if upType == "com" then
        self._curComData = tab:ComTreasure(data.id)
        self._type:setString(lang("BAOWUADDTAG_" .. (self._curComData.addtag or 1))) 
        --skillTp[self._curComData.addattr[1][1]])

        self._title:setString("组合进阶")
        self._comTreasureUp:setVisible(true)

        self._propertyNode:removeAllChildren()

        ScheduleMgr:nextFrameCall(self,function(  )
            self:createComTreasureIcon(data.id, data.stage)
            if self._treasureNode:getChildByName("mc") ~= nil then
                self._treasureNode:removeChildByName("mc")
            end
            -- dump(mcNameArr)
            ScheduleMgr:delayCall(50, self, function( )
                if not self._treasureNode then return end
                local mc = mcMgr:createViewMC(comMcs[self._curTreasureData.id], true, false)
                mc:setName("mc")
                mc:setPlaySpeed(0.25)
                mc:setPosition(122, 107 + comMcOffsetY[self._curTreasureData.id])
                self._treasureNode:addChild(mc)
            end)
        end)

        self._curComInfo = self._tModel:getComTreasureById(tostring(data.id))
        if self._curComInfo then
            -- self._zhandouliLabel:setString("a" ..(self._curComInfo.disScore or 0) +(self._curComInfo.comScore or 0))
        else
            -- self._zhandouliLabel:setString("a" .. 0)
        end

        -- self._treasureName:loadTexture(self._curComData.name .. "_treasure.png", 1)
        self:updateComStage()

        UIUtils:createTreasureNameLab(self._curTreasureData.id,data.stage,nil,self._treasureName)
        if data.stage < maxComStage then
            -- local afterAtts = self:createComTreasureIcon(data.id,data.stage+1,true)
            -- after:addChild(afterAtts)
            local devComT = tab:DevComTreasure(data.stage)
            local materials = devComT["special" .. self._curComData.quality]

            self:generateMatirals(materials)
        else
            self._iconMaxStage:setVisible(true)
            self._iconMaxStage:setPosition(570,103)
            self._upBtn:setVisible(false)
            self._materialPanel:removeAllChildren()
            return
        end
    end


    local canUp = true
    if not self._abundent then
        canUp = false
    end

    local canClick = true
    if self._curTreasureData.upType == "com" then
        local comInfo = self._modelMgr:getModel("TreasureModel"):getComTreasureById(tostring(self._curTreasureData.id))
        for k, v in pairs(comInfo.treasureDev) do
            if v.s < comInfo.stage + 1 then
                canUp = false
                canClick = false
            end
        end
    end

    local desRtx = self._materialPanel:getChildByName("desRtx")
    if desRtx then
        desRtx:removeFromParent()
    end
    if canClick then
        -- self._upBtn:setPosition(650,100)
    else
        desRtx = RichTextFactory:create("[color = 3c2a1e,fontSize = 18]需要:所有宝物+" .. self._curTreasureData.stage + 1 .. "[-]", 250, 40)
        desRtx:formatText()
        desRtx:setVerticalSpace(7)
        desRtx:setName("desRtx")
        desRtx:setPosition(240, 90)
        self._materialPanel:addChild(desRtx)
        UIUtils:alignRichText(desRtx,{hAlign = "right"})
        -- self._upBtn:setPosition(650,90)
    end

    self._upBtn:removeAllChildren()
    if canUp then
        local mc1 = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true, false)
        mc1:setName("anim")
        -- mc1:setScale(1.3,1.3)
        mc1:setPosition(70, 26)
        self._upBtn:addChild(mc1, 1)
    end
    UIUtils:setGray(self._upBtn, not canUp)


end

function TreasureComUpView:createComTreasureIcon(id, stage, up)
    local desBg = self._comTreasureUp:getChildByFullName("desBg")
    desBg:removeAllChildren()

    -- self:generateAtts(id, stage, self._propertyNode, -462, 0, maxComStage)
    ScheduleMgr:nextFrameCall(self,function( )
        if not self.generateExAtts then return end 
        self:generateExAtts(id, math.min(stage,maxComStage), self._infoScrollView, 0, 0, maxComStage)
    end)

    local x, y = 0, 0
    local offsetx, offsety = -40, 30
    local lineHeight = 20
    local height, width = -5, 10
    x = width + offsetx

    -- local comName = ccui.Text:create()
    -- comName:setFontName(UIUtils.ttfName)
    -- comName:setFontSize(22)
    -- comName:setAnchorPoint(cc.p(0.5,0.5))
    -- comName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    -- comName:setString(lang(self._curComData.name) .. " +" .. stage)
    -- comName:setColor(UIUtils.colorTable["ccColorQuality" .. (self._curComData.quality or 2)])
    -- comName:setPosition(cc.p(50, 100))
    -- treasureNode:addChild(comName)


    local skillId = self._curComData.addattr[1][2]
    local skillD = { }
    for k, v in pairs(self._skillTabMap) do
        if v[skillId] and(v[skillId].art or v[skillId].icon) then
            skillD = clone(v[skillId])
            break
        end
    end

    local left = self._comTreasureUp:getChildByFullName("left")

    local rightArrow = self._comTreasureUp:getChildByFullName("rightArrow")
    rightArrow:setPosition(258,107)
    rightArrow:setScale(0.8)
    rightArrow:setVisible(true)
    local nameBg = self._comTreasureUp:getChildByFullName("nameBg")
    nameBg:setContentSize(cc.size(280,34))

    local lName = left:getChildByFullName("name")
    UIUtils:setTitleFormat(lName,3)
    lName:setString(lang(skillD.name) .. " Lv.".. stage)

    local lLevel = left:getChildByFullName("level")
    lLevel:setColor(UIUtils.colorTable.ccUIBaseColor9)
    lLevel:setString("Lv." .. stage)

    local nLevel = left:getChildByFullName("levelNext")
    -- nLevel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    nLevel:setPositionX(272)
    -- UIUtils:setTitleFormat(nLevel,3)
    nLevel:setVisible(true)
    -- nLevel:setColor(cc.c3b(0, 255, 30))
    if stage < maxComStage then
        nLevel:setString("Lv." .. stage + 1)
    else
        nLevel:setString("MAX")
    end


    -- 技能icon..
    local bgNode = ccui.Widget:create()
    bgNode:setContentSize({width=90, height=90})
    bgNode:setAnchorPoint(0, 0)
    bgNode:setPosition(-5, 10)
    local fu = cc.FileUtils:getInstance()
    local skillIcon = ccui.ImageView:create()
    local sfc = cc.SpriteFrameCache:getInstance()
    local art = skillD.art or skillD.icon
    if sfc:getSpriteFrameByName(art .. ".jpg") then
        skillIcon:loadTexture("" .. art .. ".jpg", 1)
    else
        skillIcon:loadTexture("" .. art .. ".png", 1)
    end
    skillIcon:ignoreContentAdaptWithSize(false)
    skillIcon:setContentSize({width=90, height=90})
    skillIcon:setAnchorPoint(0, 0)
    skillIcon:setPosition(0, 10)
    bgNode:addChild(skillIcon)
    local frame = ccui.ImageView:create()
    frame:loadTexture("hero_skill_bg3_forma.png", 1)
    frame:setContentSize(cc.size(100, 100))
    frame:ignoreContentAdaptWithSize(false)
    frame:setPosition(-7, 7)

    frame:setAnchorPoint(cc.p(0, 0))
    bgNode:addChild(frame, 1)

    local iconBg = ccui.ImageView:create()
    iconBg:loadTexture("globalImageUI4_heroBg2.png", 1)
    iconBg:setContentSize({width=80, height=80})
    iconBg:ignoreContentAdaptWithSize(false)
    iconBg:setPosition(-5, 10)
    iconBg:setScale(90 / iconBg:getContentSize().width)
    iconBg:setAnchorPoint(0, 0)
    bgNode:addChild(iconBg, -1)
    bgNode:setScale(0.8)

    desBg:addChild(bgNode)


    -- if desBg.scrollView then
    --     desBg.scrollView:removeFromParentAndCleanup()
    -- end
    local scrollView = ccui.ScrollView:create()
    scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    scrollView:setContentSize(cc.size(300,54))
    scrollView:setAnchorPoint(0,0)
    scrollView:setPosition(85,-10)
    scrollView:setBounceEnabled(true)
    desBg.scrollView = scrollView
    desBg:addChild(scrollView,99)

    local sWidth = scrollView:getContentSize().width
    local sHeight = scrollView:getContentSize().height

    local skillDes
    -- skillDes = GlobalTipView._des 825528
    skillDes = self:generateDes(stage)
    local rtx = RichTextFactory:create("[color = 8a5c1d,fontsize=16]" .. skillDes ..  "[-]", 290, 54) -- ,fontsize=18
    -- rtx:setVerticalSpace(-4)
    -- rtx:ignoreContentAdaptWithSize(true)
    -- rtx:setPixelNewline(true)
    rtx:formatText()
    rtx:setName("rtx")
    local rtRealHeight = rtx:getRealSize().height

    rtx:setPosition(sWidth/2 - 5, rtRealHeight / 2)
    scrollView:addChild(rtx)
    scrollView:getInnerContainer():setContentSize(cc.size(sWidth,rtRealHeight))
    scrollView:getInnerContainer():setPositionY(sHeight  - rtRealHeight)
    scrollView:setTouchEnabled(rtRealHeight > sHeight)
    -- UIUtils:alignRichText(rtx, { hAlign = "left",vAlign="bottom" })



    -- if up then
    -- 	iconName:setString(lang(tab:DisTreasure(id).name) .. " +1")
    -- 	iconName:setColor(cc.c4b(255, 209, 38, 255))
    -- 	iconName:enableOutline(cc.c4b(54,0,4,255),1.5)
    -- else
    -- 	iconName:setString(lang(tab:DisTreasure(id).name))
    -- 	iconName:setColor(cc.c4b(255, 255, 255, 255))
    -- 	iconName:enableOutline(cc.c4b(0,0,4,255),1.5)
    -- end


    return icon
end

function TreasureComUpView:generateMatirals(data)
    self._materialPanel:removeAllChildren()
    self._abundent = true
    local num = table.nums(data)
    local itemSize = 95
    local x, y = 0, 0
    local offsetx, offsety = 10, 20
    -- -itemSize*num*0.5+20+self._materialPanel:getContentSize().width/2
    for i, material in ipairs(data) do
        local item = self._materialNode:clone()
        item:setVisible(true)
        local itemId = material[2]
        local _, hadNum = self._modelMgr:getModel("ItemModel"):getItemsById(itemId)
        local needNum = item:getChildByFullName("needNum")
        local icon
        if hadNum < self._tModel:getCurrentNum(material[2],material[3]) then
            needNum:setColor(UIUtils.colorTable["ccUIBaseColor6"])
            -- needNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            self._abundent = false
            local itemRedFlag = self._modelMgr:getModel("ItemModel"):approatchIsOpen(itemId)
            local suo = itemRedFlag and 2 or nil
            icon = IconUtils:createItemIconById( {
                itemId = itemId,
                eventStyle = 3,
                suo = suo,
                clickCallback = function()
                    if itemId == 41001 then
                        DialogUtils.showBuyRes({goalType="treasureNum"})
                    else
                        DialogUtils.showItemApproach(itemId)
                    end
                end
            } )
        else
            icon = IconUtils:createItemIconById( { 
                itemId = itemId ,
                eventStyle = 3,
                clickCallback = function()
                    if itemId == 41001 then
                        DialogUtils.showBuyRes({goalType="treasureNum"})
                    else
                        DialogUtils.showItemApproach(itemId)
                    end
                end
            })
            needNum:setColor(UIUtils.colorTable["ccUIBaseColor9"])
            -- needNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        end
        icon:setScale(80 / icon:getContentSize().width)
        icon:setPositionX(-3)
        item:addChild(icon)
        local toolD = tab:Tool(itemId)
        local color = 1
        if toolD then
            color = toolD.color or 1
        end
        needNum:setString(ItemUtils.formatItemCount(hadNum or 0) .. "/" .. self._tModel:getCurrentNum(material[2],material[3]))
        x = itemSize *(i - 1)
        -- if num == 1 then 
        --     x = x+itemSize/2+20
        -- end
        item:setPosition(cc.p(x + offsetx, y + offsety))
        self._materialPanel:addChild(item)
    end
end

function TreasureComUpView:generateAtts(id, stage, node, offsetx, offsety, stageMax)
    local preAtts = self._modelMgr:getModel("TreasureModel"):getTreasureAtts(id, stage)
    local afterAtts = self._modelMgr:getModel("TreasureModel"):getTreasureAtts(id, stage + 1)
    local panelW, panelH = self._attPanel:getContentSize().width, self._attPanel:getContentSize().height + 5
    self._panelH = panelH
    local x, y = node:getContentSize().width + 2 + panelW / 2, node:getContentSize().height / 2 + panelH *((#preAtts - 1) / 2)
    local offsetx, offsety = offsetx or 0, offsety or 0
    local idx = 1
    self._panels = { }
    -- for k, v in pairs(preAtts) do
    --     local attPanel = self._attPanel:clone()
    --     attPanel:setAnchorPoint(cc.p(0.5, 0.5))
    --     attPanel:setVisible(true)
    --     if idx % 2 == 1 then
    --         attPanel:setOpacity(0)
    --     end
    --     attPanel:setPosition(cc.p(x + offsetx, y + offsety -(idx - 1) * panelH))
    --     node:addChild(attPanel, 99)
    --     table.insert(self._panels, attPanel)

    --     local attLeft = attPanel:getChildByFullName("attLeft")
    --     attLeft:setColor(UIUtils.colorTable.ccUIBaseTextColor2)


    --     local attRight = attPanel:getChildByFullName("attRight")
    --     attRight:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    --     local att2 = attPanel:getChildByFullName("att2")
    --     att2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    --     local name = lang("ARTIFACTDES_PRO_" .. v.attId)
    --     if not name then
    --         name = lang("ATTR_" .. v.attId)
    --     end
    --     if name then
    --         name = string.gsub(name, "　", "")
    --         name = string.gsub(name, " ", "")
    --     end
    --     local tail = ""
    --     if tonumber(v.attId) == 2 or tonumber(v.attId) == 5 then
    --         tail = "%"
    --     end
    --     attLeft:setString(name .. " +" .. v.attNum .. tail)
    --     if stage < stageMax then
    --         att2:setString(" +" .. afterAtts[k]["attNum"] .. tail)
    --         attRight:setString(name)
    --     else
    --         attRight:setString("已满阶")
    --         attRight:setColor(cc.c3b(0, 255, 30))
    --         att2:setString("")
    --         att2:setColor(cc.c3b(255, 255, 255))
    --     end
    --     att2:setPositionX(attRight:getPositionX() + attRight:getContentSize().width)
    --     idx = idx + 1
    -- end
end

local volumeChange = {25,16,9,4,1}
-- 2017.1.7 新逻辑
-- 不同阶数下 额外加成
function TreasureComUpView:generateExAtts( id, stage, node, offsetx, offsety )
    local disData = tab.comTreasure[id]
    local unlockData = disData.unlockaddattr
    local addAttrsData = disData.addattr
    local nextBuffId 
    for i,v in ipairs(unlockData) do
        if unlockData[i] > stage and not nextBuffId then
            nextBuffId = unlockData[i]
        end 
    end
    if not nextBuffId then nextBuffId = maxComStage end
    if not self._addAttrItems then
        self._addAttrItems = {}
    end
    local scrollHeight = 0
    -- 创建额外加成显示
    for i=2,#unlockData do
        -- if unlockData[i] > nextBuffId then break end
        local item = self._addAttrItems[i]
        if not item then
            item = ccui.Layout:create()
            -- item:setBackGroundColorOpacity(255)
            -- item:setBackGroundColorType(1)
            -- item:setBackGroundColor(cc.c4b(207, 192, 175, 40))
            item:setBackGroundImage("globalPanelUI11_0419DayGoodsCellBg.png", 1)
            item:setBackGroundImageCapInsets(cc.rect(8,11,1,1))
            item:setBackGroundImageScale9Enabled(true)
            item:setOpacity(255*((i+1)%2))
            item:setContentSize(378, 32)
            item:setAnchorPoint(0,0)
            item:setPosition(offsetx,offsety-i*32)
            node:addChild(item)
            self._addAttrItems[i] = item

            -- local flag = ccui.ImageView:create()
            -- flag:loadTexture("flag3_treasure.png",1)
            -- flag:setPosition(0,3)
            -- flag:setAnchorPoint(0,0)
            -- item:addChild(flag)

            -- local stageLab = ccui.Text:create()
            -- stageLab:setFontSize(20)
            -- stageLab:setFontName(UIUtils.ttfName)
            -- -- stageLab:enableShadow(UIUtils.colorTable.ccUIBaseShadowColor, cc.size(0, -2))
            -- stageLab:setColor(cc.c3b(70, 40, 0))
            -- stageLab:setPosition(2,16)
            -- stageLab:setAnchorPoint(0,0.5)
            -- stageLab:setString("Lv." .. unlockData[i])
            -- item:addChild(stageLab)
        end 

        local stageUpImg = item:getChildByName("upStage")
        if not stageUpImg then
            stageUpImg = ccui.ImageView:create()
            stageUpImg:loadTexture("comAttr_null_treasure.png",1)
            stageUpImg:setPosition(7,16)
            stageUpImg:setAnchorPoint(0,0.5)
            stageUpImg:setName("upStage")
            -- stageUpImg:setScale(0.8)
            item:addChild(stageUpImg)
        end
        node:reorderChild(item,12)
        if stage >= unlockData[i] then
            stageUpImg:loadTexture("comAttr_full_treasure.png",1)
        end

        local attr = addAttrsData[1][1]
        local addValue = addAttrsData[1][2]



        local des = lang("HEROMASTERYDES_" .. addValue .. math.max(i-1,1))
        local desEx = ""
        desEx = lang("HEROMASTERYDESEX_" .. addValue .. math.max(i-1,1))
        if des == "" then
            des   = lang("PLAYERSKILLDES2_" .. addValue .. math.max(i-1,1))
            desEx = lang("PLAYERSKILLDESEX_" .. addValue .. math.max(i-1,1))
        end
        -- print("des",des)
        -- print("desEx",desEx,"lll",addValue,i)
        if desEx ~= "" then
            local button = item:getChildByName("infoBtn")
            if not button then
                button = ccui.Button:create("globalImage_info.png", "globalImage_info.png", "", 1)
                button:setAnchorPoint(0.5, 0.5)
                button:setName("button")
                button:setPosition(360, 16)
                button:ignoreContentAdaptWithSize(false)
                button:setTitleText("")
                button:setScale(0.65)
                -- button:setSwallowTouches(false)
                button:setName("infoBtn")
                -- self:L10N_Text(button)
                item:addChild(button)
            end
            self:registerClickEvent(button,function() 
                self._viewMgr:showHintView("global.GlobalTipView",{
                    node = button,
                    tipType = 16,
                    des = "[color=ffffff]" .. desEx .. "[-]",
                    posCenter = true,
                })
            end)
        end
        if i == 1 then
            des = self:generateDes(1)
        end
        local color = cc.c3b(100, 100, 100)
        local colorH = "[color=646464]"
        local isOutline = false
        local isNotAffect = false -- 判断是不是没有开启
        if stage < unlockData[i] then
            des = "[color=646464]" .. des .. "[-]" -- "Lv." .. unlockData[i] .. " " ..
            isNotAffect = true
        elseif stage <= unlockData[i]  then
            isOutline = true
            color = cc.c3b(250, 146, 26)
            des = "[color=c44904]Lv." .. unlockData[i] .. "　" .. des .. "[-]"
        else
            color = cc.c3b(70, 40, 0)
            des =  "[color=462800]Lv." .. unlockData[i] .. "　" .. des .. "[-]" -- 
        end

        if item:getChildByName("rtx") then
            item:getChildByName("rtx"):removeFromParent()
        end
        --]]
        --[[
        local desLab = ccui.Text:create()
        desLab:setFontSize(19)
        desLab:setFontName(UIUtils.ttfName)
        -- desLab:enableShadow(UIUtils.colorTable.ccUIBaseShadowColor, cc.size(0, -2))
        desLab:setPosition(35,16)
        desLab:setAnchorPoint(0,0.5)
        desLab:setName("rtx")
        desLab:getVirtualRenderer():setMaxLineWidth(315)
        desLab:setString(des)
        print("desLab:getWidth",desLab:getContentSize().width)
        item:addChild(desLab)
        desLab:setColor(color)
        if isOutline then
            desLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        else
            desLab:disableEffect()
        end
        --]]
        -- 加开启条件
        if isNotAffect then
            -- local desLabW = desLab:getContentSize().width
            -- if desLabW < 300 then
            --     des = des .. "\n"
            -- end
            des = des .. "[color=646464]　(Lv." .. unlockData[i] .."可获得)[-]"
            -- desLab:setString(des)
        end
        -- [[ 换用普通label创建
        des = "[color=ffffff]" .. des .. "[-]"
        local rtx = RichTextFactory:create(des or "",315,item:getContentSize().height)
        rtx:formatText()
        -- rtx:setVerticalSpace(5)
        -- rtx:setAnchorPoint(cc.p(0,0))
        local w = rtx:getInnerSize().width
        local h = rtx:getInnerSize().height
        rtx:setPosition(cc.p(w/2+35,item:getContentSize().height/2))
        UIUtils:alignRichText(rtx,{vAlign = "center",hAlign = "left"})
        rtx:setName("rtx")
        item:addChild(rtx)
        local desLab = rtx
        local h = h --desLab:getContentSize().height
        if h <= 32 then 
            h = 32
        else
            h = math.ceil(h/32)*32
        end 
        -- if h > 32 then
        item:setContentSize(cc.size(375,h))
        -- end
        local children = item:getChildren()
        for _,child in pairs(children) do
            local name 
            if child.getName and child:getName() then 
                name = child:getName()
            end
            if name == "rtx" then
                child:setPositionY(math.max(16,h/2))
            end
            if name ~= "rtx" then
                if h > 32  then
                    child:setPositionY(43)
                else
                    child:setPositionY(math.max(16,h/2))
                end
            end
        end
        scrollHeight = scrollHeight+math.max(h,32)
    end
    node:setInnerContainerSize(cc.size(375,scrollHeight))
    local addHeight = scrollHeight
    addHeight = math.max(175,addHeight)
    -- print(scrollHeight,"scrollHeight")
    -- dump(self._addAttrItems)
    for k,item in pairs(self._addAttrItems) do
        local itemH = item:getContentSize().height
        item:setPositionY(addHeight-itemH)
        -- print("height...",addHeight-itemH)
        addHeight = addHeight - itemH
    end
end

-- 更新宝物阶段
function TreasureComUpView:updateComStage()
    self._comStage:setString("")
    local stage = self._curComInfo and self._curComInfo.stage or 0
    if stage > 0 then
        self._comStage:setString("+" .. stage)
        self._comStage:setColor(UIUtils.colorTable["ccColorQuality" .. self._curComData.quality])
        self._comStage:setPositionX(self._treasureName:getPositionX() + 83)
    end
end

-- 计算阶数的des
function TreasureComUpView:generateDes( stage )
    local skillDes
    local skillId = self._curComData.addattr[1][2]
    local skillD = { }
    for k, v in pairs(self._skillTabMap) do
        if v[skillId] and(v[skillId].art or v[skillId].icon) then
            skillD = clone(v[skillId])
            break
        end
    end
    local tipDataD = GlobalTipView["getDataDForTipType2"](GlobalTipView,
    { tipType = 2, node = desBg, id = skillD.id,comId = self._curComData.id, skillType = self._curComData.addattr[1][1], skillLevel = math.min(stage, maxComStage) })
    skillDes = GlobalTipView._des
    skillDes = string.gsub(skillDes, "fontsize=16", "fontsize=16")
    skillDes = string.gsub(skillDes, "fontsize=17", "fontsize=16")
    skillDes = string.gsub(skillDes, "fontsize=18", "fontsize=16")
    skillDes = string.gsub(skillDes, "fontsize=20", "fontsize=16")
    skillDes = string.gsub(skillDes, "fontsize=24", "fontsize=16")
    -- skillDes = string.gsub(skillDes, "color=3d1f00", "color=fae0bc")
    -- skillDes = string.gsub(skillDes, "outlinecolor=3c1e0a00", "")
    -- skillDes = string.gsub(skillDes, "outlinecolor=3c1e0aff", "")
    
    -- skillDes = string.gsub(skillDes, "%%", "")
-- skillDes = string.gsub(skillDes, "color=1ca216", "color=ffffff")
    -- 
    GlobalTipView._des = nil
    return skillDes
end

function TreasureComUpView:fightValueCallBack(oldValue, newValue)
    local layer = self:getUI("bg.layer")
    if layer then
        local x = layer:getContentSize().width * 0.5-100
        local y = layer:getContentSize().height - 70
        TeamUtils:setFightAnim(layer, {
            oldFight = oldValue,
            newFight = newValue,
            x = x,
            y = y
        } )
    end
end
return TreasureComUpView