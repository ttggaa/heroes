--
-- Author: <wangguojun@playcrab.com>
-- Date: 2018-01-25 16:23:01
--
local maxComStage = table.nums(tab.devComTreasure) + 1
local GlobalTipView = require("game.view.global.GlobalTipView")
local TreasureDetailDialog = class("TreasureDetailDialog",BasePopView)
function TreasureDetailDialog:ctor()
    self.super.ctor(self)
    self._skillTabMap = {
        tab.heroMastery,
        tab.playerSkillEffect,
        tab.skillPassive,
        tab.skillCharacter,
        tab.skillAttackEffect,
        tab.skill,
    }
    self._Atts = {}
end

function TreasureDetailDialog:getAsyncRes()
    return
    {
        { "asset/ui/treasure.plist", "asset/ui/treasure.png" },
        -- { "asset/ui/treasure1.plist", "asset/ui/treasure1.png" },
        -- { "asset/ui/treasure2.plist", "asset/ui/treasure2.png" },
        -- { "asset/ui/treasure3.plist", "asset/ui/treasure3.png" },
        -- { "asset/ui/treasure4.plist", "asset/ui/treasure4.png" },
        -- { "asset/ui/treasureActiveBg1.plist", "asset/ui/treasureActiveBg1.png" },
        -- { "asset/ui/treasureActiveBg2.plist", "asset/ui/treasureActiveBg2.png" },
        -- {"asset/ui/treasure-HD.plist", "asset/ui/treasure-HD.png"},
        -- 用背包的标题底板
        -- { "asset/ui/bag.plist", "asset/ui/bag.png" },
    }
end

-- 初始化UI后会调用, 有需要请覆盖
function TreasureDetailDialog:onInit()
	self:registerClickEventByName("bg.closeBtn", function()
		self.dontRemoveRes = true
        self:close()
        UIUtils:reloadLuaFile("treasure.TreasureDetailDialog")
    end )
	self._comTreasureUp = self:getUI("bg.comTreasureUp")
	self._attrPanel = self:getUI("bg.attrPanel")
	self._infoScrollView = self:getUI("bg.infoScrollView")
	self._title = self:getUI("bg.headBg.title")
    self._title:setFontName(UIUtils.ttfName)
    UIUtils:setTitleFormat(self._title,1)
end

-- 第一次进入调用, 有需要请覆盖
function TreasureDetailDialog:onShow()

end

-- 接收自定义消息
function TreasureDetailDialog:reflashUI(data)
	self._curComData = tab:ComTreasure(data.id)
	self:createComTreasureIcon(data.id, data.stage)
	self._curComInfo = data.comInfo or self._modelMgr:getModel("TreasureModel"):getComTreasureById(tostring(self._curComData.id)) 
	self:reflashAttrPanel( data.id, data.stage )
end

function TreasureDetailDialog:createComTreasureIcon(id, stage, up)
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
    rightArrow:setVisible(false)
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
    nLevel:setVisible(false)
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

    local typeTag = left:getChildByFullName("type")
    typeTag:setString(lang("BAOWUADDTAG_"..self._curComData.addtag))

    local desScrollView = self._comTreasureUp:getChildByFullName("scrollView")
    desScrollView:removeAllChildren()
    local minHeight = desScrollView:getContentSize().height
    local skillDes = self:generateDes(stage)
    local rtx = RichTextFactory:create("[color = 8a5c1d,fontsize=16]" .. skillDes ..  "[-]", desScrollView:getContentSize().width - 10, 0) -- ,fontsize=18
    rtx:formatText()
    rtx:setName("rtx")
    local innerH = rtx:getRealSize().height
    rtx:setPosition(rtx:getRealSize().width / 2 + 5, innerH / 2)
    if innerH < minHeight then
        rtx:setPosition(rtx:getRealSize().width / 2 + 5, minHeight - innerH + innerH / 2)
        innerH = minHeight
    end
    desScrollView:setInnerContainerSize(cc.size(desScrollView:getContentSize().width, innerH))
    desScrollView:addChild(rtx)
    UIUtils:alignRichText(rtx, { hAlign = "left",vAlign="bottom" })

    return icon
end

-- 计算阶数的des
function TreasureDetailDialog:generateDes( stage )
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
    -- 
    GlobalTipView._des = nil
    return skillDes
end

-- 加的属性
function TreasureDetailDialog:reflashAttrPanel( id, stage)
    id = self._curComData.id 
    if self._curComInfo and self._curComInfo.stage then
        stage = self._curComInfo.stage
    end
    -- print("id,stage",id,stage)
    local atts    = self:generateAtts(id)
    self._attrPanel:removeAllChildren()
    -- self._attrPanel:setContentSize(cc.size(285,#atts/2*40))
    local height  = self._attrPanel:getContentSize().height
    local lineHeight = 25
    local x, y = 0, 1
    local offsetx, offsety = 0, -25
    local lineCol = 0
    local lineNum = 0
    local linesInfo = {}
    for i, att in ipairs(atts) do
        local desName = ccui.Text:create()
        desName:setAnchorPoint(cc.p(0, 0.5))
        desName:setFontSize(20)
        desName:setFontName(UIUtils.ttfName)
        desName:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
        local attName = lang("ARTIFACTDES_PRO_" .. att.attId)
        if not attName then
            attName = lang("ATTR_" .. att.attId)
        end
        if attName then
            attName = string.gsub(attName, "　", "")
            attName = string.gsub(attName, " ", "")
        end
        desName:setString(attName)
        x = ((i-1)%2) * 180 + offsetx
        y = height - math.floor((i-1)/2) * lineHeight + offsety
        lineCol = lineCol + 1

        desName:setPosition(cc.p(x, y))
        local attNum = ccui.Text:create()
        attNum:setFontSize(20)
        attNum:setFontName(UIUtils.ttfName)
        attNum:setAnchorPoint(cc.p(0, 0.5))
        local tail = ""
        if att.attId == 2 or att.attId == 5 or att.attId == 131 then
            tail = "%"
        end
        if self._curComInfo and tonumber(att.attNum) then
            attNum:setColor(UIUtils.colorTable.ccUIBaseColor9)
            local value =(att.attNum or 0)
            if value < 1 then
                value = tonumber(string.format("%.2f", value))
            elseif value < 100 then
                value = tonumber(string.format("%.1f", value))
            else
                value = math.ceil(value)
            end
            attNum:setString(value .. tail)
        else
            attNum:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
            attNum:disableEffect()
            attNum:setString("--")
        end
        attNum:setPosition(cc.p(x + desName:getContentSize().width + 2, y))
        self._attrPanel:addChild(attNum)
        self._attrPanel:addChild(desName)

        -- 计算偏移
        local lineNum = math.floor((i-1)/2)+1
        if not linesInfo[lineNum] then
            linesInfo[lineNum] = {}
            linesInfo[lineNum].beginX = desName:getPositionX()
            linesInfo[lineNum].endX = attNum:getPositionX()+attNum:getContentSize().width
            linesInfo[lineNum].width = linesInfo[lineNum].endX - linesInfo[lineNum].beginX
        else
            linesInfo[lineNum].endX = attNum:getPositionX()+attNum:getContentSize().width
            linesInfo[lineNum].width = linesInfo[lineNum].endX - linesInfo[lineNum].beginX
        end
    end
    local lineWidthMax = 0
    for k,v in pairs(linesInfo) do
        if v.width > lineWidthMax then
            lineWidthMax = v.width
        end
    end
    -- local offsetx = (self._attrPanel:getContentSize().width-lineWidthMax)/2
    -- local children = self._attrPanel:getChildren()
    -- for k,v in pairs(children) do
    --     v:setPosition(v:getPositionX()+offsetx,v:getPositionY())
    -- end
    self._attrPanel:setVisible(true)
end

function TreasureDetailDialog:generateAtts(id)
    -- if not self._Atts[id] then
    local Atts = { }
    local stage = 0
    local form = self._curComData.form
    local disStages = { }
    -- if self._curComInfo then
    disStages = self._curComInfo and self._curComInfo.treasureDev or { }
    for k, v in pairs(form) do
        local disTreasure = tab:DisTreasure(v)
        for k, property in pairs(disTreasure["property"]) do
            if (disStages[tostring(v)] and disStages[tostring(v)].s > 0) or self._propertyNone then
                local attId = property[1]
                if not Atts[attId] then
                    Atts[attId] = { }
                end
                local disStage = disStages[tostring(v)] and disStages[tostring(v)].s or 0
                Atts[attId].attId = attId
                local preAttNum = tonumber(Atts[attId].attNum) or 0
                local curAttNum = 0
                if self._curComInfo and self._curComInfo.treasureDev
                    and self._curComInfo.treasureDev[tostring(v)].s > 0 then
                    curAttNum = property[2] + math.max(disStage - 1, 0) * property[3]
                    -- 加升星加成
                    local starBuff = 1 + self._modelMgr:getModel("TreasureModel"):caculateStarAttr(v,disStages[tostring(v)])
                    curAttNum = curAttNum * starBuff
                end
                Atts[attId].attNum = preAttNum + curAttNum
            end
        end
    end
    -- end
    self._Atts[id] = { }
    for k, v in pairs(Atts) do
        if v.attNum == 0 then
            v.attNum = "--"
        end
        table.insert(self._Atts[id], v)
    end
    if #self._Atts[id] > 1 then
        table.sort(self._Atts[id], function(a, b)
            return a.attId > b.attId
        end )
    end
    -- end
    return self._Atts[id]
end

local volumeChange = {25,16,9,4,1}
-- 2017.1.7 新逻辑
-- 不同阶数下 额外加成
function TreasureDetailDialog:generateExAtts( id, stage, node, offsetx, offsety )
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
        -- print("desEx",desEx,"lll",addValue)
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
    for k,item in pairs(self._addAttrItems) do
        local itemH = item:getContentSize().height
        item:setPositionY(addHeight-itemH)
        addHeight = addHeight - itemH
    end
end

return TreasureDetailDialog