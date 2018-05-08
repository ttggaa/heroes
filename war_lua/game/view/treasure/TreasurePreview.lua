--
-- Author: <ligen@playcrab.com>
-- Date: 2016-07-23 11:33:04
--
local GlobalTipView = require("game.view.global.GlobalTipView")
local TreasurePreview = class("TreasurePreview", BasePopView)
local maxComStage = table.nums(tab.devComTreasure) + 1
function TreasurePreview:ctor()
    self.super.ctor(self)

    self._comTreasureData = nil

    self._Atts = { }

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
function TreasurePreview:onInit()

    self:registerClickEventByName("bg.layer.closeBtn", function()
        self:close()
    end )

    self._title = self:getUI("bg.layer.headBg.title")
--    self._title:setColor(cc.c3b(250, 242, 192))
--    self._title:enable2Color(1, cc.c4b(255, 195, 20, 255))
--    self._title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
    self._title:setFontName(UIUtils.ttfName)
    self._title:setString("宝物预览")

    self._stageNum = self:getUI("bg.layer.treasureNode.stageNum")
    self._stageNum:setFontName(UIUtils.ttfName)
    self._stageNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

--    self._nameAndStage = self:getUI("bg.layer.treasureNode.nameAndStage")
--    self._nameAndStage:setColor(cc.c3b(0, 255, 30))
--    self._nameAndStage:setFontName(UIUtils.ttfName)
--    self._nameAndStage:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)

    self._leftBtn = self:getUI("bg.layer.treasureNode.leftBtn")
    self:registerClickEvent(self._leftBtn, function()
        self:updateStage(self._stage - 1)
    end )

    self._rightBtn = self:getUI("bg.layer.treasureNode.rightBtn")
    self._rightBtn:setVisible(false)
    self:registerClickEvent(self._rightBtn, function()
        self:updateStage(self._stage + 1)
    end )


    self._infoBg = self:getUI("bg.layer.infoBg")

    self._des1 = self:getUI("bg.layer.infoBg.titleBg1.des1")
    self._des1:setFontName(UIUtils.ttfName)
    self._des1:setString("属性加成")

    self._des2 = self:getUI("bg.layer.infoBg.titleBg2.des2")
    self._des2:setFontName(UIUtils.ttfName)
    self._des2:setString("宝物技能")

    self._attPanel = self:getUI("bg.layer.attPanel")

    self._treasureNode = self:getUI("bg.layer.treasureNode")

    self._lLevel = self:getUI("bg.layer.level")
    self._lName = self:getUI("bg.layer.name")
end

-- 阶段变化
function TreasurePreview:updateStage(stage)
    if stage <= 1 then
        self._leftBtn:setVisible(false)
    else
        self._leftBtn:setVisible(true)
    end
    
    
    if stage >= maxComStage then
        self._rightBtn:setVisible(false)
    else
        self._rightBtn:setVisible(true)
    end


    self:reflashUI({cid = self._comTreasureData.id, stage = stage})
end

local comMcs = {
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
}
local comMcOffsetY =
{
    [10] = 0,
    [11] = - 20,

    [22] = 0,
    [21] = 0,

    [30] = 0,
    [31] = 45,
    [32] = 0,

    [40] = 0,
    [41] = 30,
}

-- 接收自定义消息
function TreasurePreview:reflashUI(data)
    self._comTreasureData = tab:ComTreasure(data.cid)

    self._stage = 0;
    if data.stage == nil then
        self._stage = 12;
    else
        self._stage = data.stage;
    end

    if self._treasureNode:getChildByName("mc") == nil then
        local mc = mcMgr:createViewMC(comMcs[self._comTreasureData.id], true, false)
        mc:setName("mc")
        mc:setPlaySpeed(0.25)
        mc:setPosition(130, 200 + comMcOffsetY[self._comTreasureData.id])
        self._treasureNode:addChild(mc)
    end

    local skillId = self._comTreasureData.addattr[1][2]
    local skillD = { }
    for k, v in pairs(self._skillTabMap) do
        if v[skillId] and(v[skillId].art or v[skillId].icon) then
            skillD = clone(v[skillId])
            break
        end
    end

    self._lName:setString(lang(skillD.name))
--    self._lName:setColor(UIUtils.colorTable["ccColorQuality" ..(self._comTreasureData.quality or 2)])
    self._lName:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    self._lLevel:setString("Lv." .. self._stage)
    self._lLevel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

--    self._nameAndStage:setString(self._comTreasureData.backname .. "+" .. self._stage)

    self._stageNum:setString(lang(self._comTreasureData.name) .. "+" .. self._stage)
    self._stageNum:setColor(UIUtils.colorTable["ccColorQuality" ..(self._comTreasureData.quality or 2)])

    local skillDes
    local tipDataD = GlobalTipView["getDataDForTipType2"](GlobalTipView,
    { tipType = 2, node = self._infoBg, id = skillD.id, skillType = self._comTreasureData.addattr[1][1], skillLevel = math.min(self._stage, maxComStage) })
    skillDes = GlobalTipView._des
    skillDes = string.gsub(skillDes, "fontsize=17", "fontsize=18")
    skillDes = string.gsub(skillDes, "fontsize=18", "fontsize=18")
    skillDes = string.gsub(skillDes, "fontsize=20", "fontsize=18")
    skillDes = string.gsub(skillDes, "fontsize=24", "fontsize=18")
    skillDes = string.gsub(skillDes, "outlinecolor=3c1e0a00", "outlinecolor=3c1e0a00,outlinesize=1")
    skillDes = string.gsub(skillDes, "outlinecolor=3c1e0aff", "outlinecolor=3c1e0aff,outlinesize=1")

    if self._infoBg:getChildByName("rtx") ~= nil then
        self._infoBg:removeChildByName("rtx")
    end
    local rtx = RichTextFactory:create("[color=3d1f00,fontsize=20]" .. skillDes .. "[-]", 280, 80)
    rtx:formatText()
    rtx:setName("rtx")
    rtx:setVerticalSpace(7)
    rtx:setPosition(cc.p(188,  133 - rtx:getInnerSize().height / 2))
    self._infoBg:addChild(rtx, 99)
    UIUtils:alignRichText(rtx, { hAlign = "left" })

    GlobalTipView._des = nil

    self._attPanel:removeAllChildren()
    local atts = self:generateAtts(self._comTreasureData.id)
    local height = self._attPanel:getContentSize().height
    local lineHeight = 30
    local x, y = 0, 0
    local offsetx, offsety = 20, -20
    local lineCol = 0
    local lineNum = 0
    for i, att in ipairs(atts) do
        local desName = ccui.Text:create()
        desName:setAnchorPoint(cc.p(0, 0.5))
        desName:setFontSize(22)
        desName:setFontName(UIUtils.ttfName)
        desName:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        local attName = lang("ARTIFACTDES_PRO_" .. att.attId)
        if not attName then
            attName = lang("ATTR_" .. att.attId)
        end
        if attName then
            attName = string.gsub(attName, "　", "")
            attName = string.gsub(attName, " ", "") .. "+"
        end
        desName:setString(attName)
        if tonumber(att.attId) < 10 then
            lineNum = lineNum + 1
            lineCol = 0
        else
            if lineCol == 2 then
                lineCol = 0
                lineNum = lineNum + 1
            end
        end
        x = lineCol * 145 + offsetx
        y = height - lineNum * lineHeight + offsety
        lineCol = lineCol + 1
        -- if i <= 4 then
        -- 	x = (i-1)%2*115+offsetx
        -- 	y = height- math.floor((i-1)/2)*lineHeight+offsety
        -- else
        -- 	x = 0+offsetx
        -- 	y = height-lineHeight*(i-3)+offsety
        -- end
        desName:setPosition(cc.p(x, y))
        local attNum = ccui.Text:create()
        attNum:setFontSize(22)
        attNum:setFontName(UIUtils.ttfName)
        attNum:setAnchorPoint(cc.p(0, 0.5))
        local tail = ""
        if att.attId == 2 or att.attId == 5 then
            tail = "%"
        end

        if tonumber(att.attNum) then
            attNum:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
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
        attNum:setPosition(cc.p(x + desName:getContentSize().width + 10, y))
        self._attPanel:addChild(attNum)
        self._attPanel:addChild(desName)
    end
end

function TreasurePreview:generateAtts(id)
    -- if not self._Atts[id] then
    local Atts = { }
    for k, property in pairs(self._comTreasureData["property"]) do
        if not Atts[property[1]] then
            Atts[property[1]] = { }
        end
        Atts[property[1]].attId = property[1]
        Atts[property[1]].attNum =(self._stage > 0) and(property[2] + math.max(self._stage - 1, 0) * property[3]) or "--"
    end

    local form = self._comTreasureData.form
    for k, v in pairs(form) do
        local disTreasure = tab:DisTreasure(v)
        for k, property in pairs(disTreasure["property"]) do
                local attId = property[1]
                if not Atts[attId] then
                    Atts[attId] = { }
                end

                Atts[attId].attId = attId
                local preAttNum = tonumber(Atts[attId].attNum) or 0
                local curAttNum = 0
                curAttNum = property[2] + math.max(self._stage - 1, 0) * property[3]
                Atts[attId].attNum = preAttNum + curAttNum
                -- (tonumber(Atts[attId].attNum) or (self._curComInfo and self._curComInfo.treasureDev and tonumber(self._curComInfo.treasureDev[tostring(v)]) > 0))
                -- and ((tonumber(Atts[attId].attNum) or 0)+property[2]+math.max(disStage-1,0)*property[3]) or "--"
        end
    end

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

function TreasurePreview:getNumberInChinese(lNum)
    local tab1 = { "零", "一", "二", "三", "四", "五", "六", "七", "八", "九" }
    local tab2 = { "", "十", "百", "千", "万" }

    lNum = tostring(lNum)
    local cText = "";
    for i = 1, string.len(lNum) do
        local cNum = string.sub(lNum, i, i)
        cText = cText .. tab1[tonumber(cNum + 1)]
    end

    local fText = cText;
    local kChineseLen = 3;
    local n = 0;
    for j = string.len(cText), 1, - kChineseLen do
        n = n + 1;
        fText = string.sub(fText, 1, j) .. tab2[n] .. string.sub(fText, j + kChineseLen - 2);
    end

    fText = string.gsub(fText, "一十", "十");
    fText = string.gsub(fText, "零", "");
    return fText
end
return TreasurePreview