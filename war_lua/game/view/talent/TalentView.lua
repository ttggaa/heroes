--[[
    Filename:    TalentView.lua
    Author:      <liushuai@playcrab.com> 
    Datetime:    2016-04-20 15:54:19
    Description: File description
--]]
local TalentView = class("TalentView", BaseView)

TalentView.kViewTypeSkillInformation    = 1
TalentView.kViewTypeBasicInformation    = 2
TalentView.kViewTypeUpgradeInformation  = 3

TalentView.kHeroSkillInformationTag     = 1000
TalentView.kHeroBasicInformationTag     = 2000
TalentView.kHeroUpgradeInformationTag   = 3000

TalentView.kNormalZOrder                = 500
TalentView.kLessNormalZOrder            = TalentView.kNormalZOrder - 1
TalentView.kAboveNormalZOrder           = TalentView.kNormalZOrder + 1
TalentView.kHighestZOrder               = TalentView.kAboveNormalZOrder + 1

function TalentView:ctor(params)
    TalentView.super.ctor(self)
    self._talentModel = self._modelMgr:getModel("TalentModel")
    self._userModel = self._modelMgr:getModel("UserModel")

    if params and params.openTab then   --外部指定显示页签
        self._viewType = params.openTab
    end
    self.initAnimType = 1 
    self._isUpdateAnim = false --是否显示左侧进度条   
end

function TalentView:onInit()
    self:addAnimBg()

    self:getUI("bg.bgl"):loadTexture("asset/bg/bg_magic.png")
    self:getUI("bg.bgr"):loadTexture("asset/bg/bg_magic.png")
    self:getUI("bg.bgR1"):loadTexture("asset/bg/bg_magic_rDec-LL.png")

    self._buttons = {}
    for i=1, 7 do
        self._buttons[i] = {}
        self._buttons[i]._btn = self:getUI("bg.btn_" .. i)
        self._buttons[i]._btn:enableOutline(cc.c4b(73,48,29,255), 1)

        self:registerClickEvent(self._buttons[i]._btn, function ()
            local talentData = self._talentData[i]
            if not talentData or 0 == talentData.s then
                local limitLv = tab.magicSeries[talentData.id].lvlimit
                self._viewMgr:showTip(limitLv .. lang("magicResetTip_7"))
                return
            end
            self:switchViewType(i)
        end)
    end

    self._layers = {}
    for i=1, 7 do
        self._layers[i] = {}
        self._layers[i]._layer = nil
        self._layers[i]._dirty = true
        self._layers[i]._talentMC = nil
        self._layers[i]._talentLastColOpenNum = 0
    end
    self._layers[1]._layer = self:getUI("bg.layer_magic_guild")
    local labelSkillName = self._layers[1]._layer:getChildByFullName("label_skill_name")
    labelSkillName:setFontName(UIUtils.ttfName)
    local labelSkillLevel = self._layers[1]._layer:getChildByFullName("label_skill_level")
    labelSkillLevel:setFontName(UIUtils.ttfName)
    labelSkillLevel:getVirtualRenderer():setAdditionalKerning(2)

    self:registerClickEventByName("bg.btn_return", function(sender)
        self:close()
        UIUtils:reloadLuaFile("talent.TalentView")
        UIUtils:reloadLuaFile("talent.TalentDetailsView")
        UIUtils:reloadLuaFile("talent.TalentResetView")
    end)
end

function TalentView:initTalentData()
    local result = {}
    local talentData = self._talentModel:getData()
    local talentKindTableData = tab.magicSeries
    local talentTotalTableData = tab.magicTalent
    -- dump(talentData, "talentData", 10)

    for k, v in pairs(talentData) do 
        local magicData = tab.magicSeries[tonumber(k)]
        if type(v) == "table" and magicData then
            local btn = self:getUI("bg.btn_"..magicData["show"])
            btn:setTitleText(lang(magicData["sign"]))
        end
    end

    local findTalentKindTableData = function(kindId)
        for k, v in pairs(talentKindTableData) do
            if tonumber(k) == tonumber(kindId) then
                return true, v
            end
        end
        return false
    end

    local findTalentTotalTableData = function(talentId)
        for k, v in pairs(talentTotalTableData) do
            if tonumber(k) == tonumber(talentId) then
                return true, v
            end
        end
        return false
    end

    for k, v in pairs(talentData) do 
        local f, d = findTalentKindTableData(k)
        if f then
            local t = clone(d)
            t.cs = v.cs
            t.l = v.l
            t.s = v.s
            t.cl = {}
            t.parentList = {}
            for k0, v0 in ipairs(t.smallTalent) do
                t.cl[tonumber(k0)] = {}
                for k1, v1 in ipairs(v0) do
                    local talentId = v1
                    local f0, d0 = findTalentTotalTableData(talentId)
                    if f0 then
                        local t0 = clone(d0)
                        table.merge(t0, v.cl[tostring(talentId)])
                        table.insert(t.cl[tonumber(k0)], t0)
                    end
                end
            end

            for k0, v0 in ipairs(t.bigTalent) do
                t.parentList[tonumber(k0)] = {}
                for k1, v1 in ipairs(v0) do
                    local talentId = v1
                    local f0, d0 = findTalentTotalTableData(talentId)
                    if f0 then
                        local t0 = clone(d0)
                        table.merge(t0, v.cl[tostring(talentId)])
                        table.insert(t.parentList[tonumber(k0)], t0)
                    end
                end
            end

            table.insert(result, t)
        end
    end

    table.sort(result, function(a, b)
        return a.show < b.show
    end)

    -- dump(result, "result", 10)
    return result
end

function TalentView:refreshUI()
    self._talentData = self:initTalentData()
    for i=1, 7 do
        self._layers[i]._dirty = true
    end
    local lastIndex = self._talentModel:getShowChannel()
    self:switchViewType(self._viewType or lastIndex, true)
end

function TalentView:onShow()
    if self._talentModel:isNeedRequest() then
        self:doRequestData()
    else
        self:refreshUI()
    end
end

function TalentView:onTop()
    if self._talentModel:isNeedRequest() then
        self:doRequestData()
    else
        self:refreshUI()
    end
end

function TalentView:onModelReflash()
    if self._talentModel:isNeedRequest() then
        self:doRequestData()
    else
        self:refreshUI()
    end
end

function TalentView:doRequestData()
    self._serverMgr:sendMsg("TalentServer", "getTalentInfo", {}, true, {}, function(success)
        self:refreshUI()
    end)
end

function TalentView:switchViewType(viewType, force)
    self._talentModel:setShowChannel(viewType)
    if self._viewType == viewType and not force then return end
    self._viewType = viewType
    --btn
    local isDataError = false
    for i=1, 7 do
        local talentData = self._talentData[i]
        if self._talentData[i] == nil then
            isDataError = true
        end
        local btn = self._buttons[i]._btn
        btn:setBright(i ~= self._viewType)
        btn:setSaturation((not talentData or 0 == talentData.s) and -100 or 0)
        btn:setTitleColor(i ~= self._viewType and UIUtils.colorTable.ccUIMagicTab2 or UIUtils.colorTable.ccUIMagicTab1)
    end

    if isDataError == true then
        for k=1,7 do
            self._buttons[k]._btn:setEnabled(false)
            self._buttons[k]._btn:setSaturation(-100)
            self._buttons[k]._btn:setBright(false)
        end
        return
    end

    local img = {"water", "fire", "wind", "soil", "yuansu", "hundun", "zuzhou"}
    local toterm = self:getUI("bg.layer_magic_guild.toterm")
    toterm:loadTexture("magic_totem_".. img[viewType] ..".png", 1)

    --layer
    for i=1, 7 do
        local layer = self._layers[i]._layer
        if i == self._viewType then
            if not layer then
                self._layers[i]._layer = self._layers[1]._layer:clone()

                local labelSkillName = self._layers[i]._layer:getChildByFullName("label_skill_name")
                labelSkillName:setFontName(UIUtils.ttfName)

                local labelSkillLevel = self._layers[i]._layer:getChildByFullName("label_skill_level")
                labelSkillLevel:setFontName(UIUtils.ttfName)
                labelSkillLevel:getVirtualRenderer():setAdditionalKerning(2)

                self._layers[1]._layer:getParent():addChild(self._layers[i]._layer)
            end
            layer = self._layers[i]._layer
            layer:setVisible(true)
            self:updateLayer()
        else
            if layer then
                layer:setVisible(false)
            end
        end
    end
end

--获取升级文本提示
function TalentView:getDescription(talentData)
    local varibleNameToValue = {
        ["$level"] = self._userModel:getData().lvl,
        ["$attr1value"] = talentData.attr1value and (0 == talentData.l and talentData.attr1value[1] or talentData.attr1value[talentData.l]) or 0,
        ["$attr2value"] = talentData.attr2value and (0 == talentData.l and talentData.attr2value[1] or talentData.attr2value[talentData.l]) or 0
    }
    local description = lang(talentData.des)
    description = string.gsub(description, "%b{}", function(substring)
        local result = string.format("%.1f", loadstring("return " .. string.gsub(string.gsub(substring, "%$%w+", function(variableName)
            return tostring(varibleNameToValue[variableName])
        end), "[{}]", ""))())
        if '0' == string.sub(result, -1) then
            result = checkint(result)
        end
        return result
    end)
    return description
end

--获取当前layer数据
function TalentView:getTalentKindData(talentKindId)
    for k, v in ipairs(self._talentData) do
        if v.id == talentKindId then
            return true, v
        end
    end
    return false
end

--获取当前layer大小天赋数据
function TalentView:getTalentChildData(talentKindId, talentId)
    local found, talentKindData = self:getTalentKindData(talentKindId)
    if found then
        for k, v in ipairs(talentKindData.cl) do
            for k0, v0 in ipairs(v) do
                if v0.id == talentId then
                    return true, v0
                end
            end
        end

        for k, v in ipairs(talentKindData.parentList) do
            for k0, v0 in ipairs(v) do
                if v0.id == talentId then
                    return true, v0
                end
            end
        end
    end
    return false
end

--左侧进度条特效
function TalentView:progressBarEffect(layer, talentData)
    if self._isUpdateAnim and self._isUpdateAnim == true and
     self._isLvMax and self._isLvMax == 0 and  --等级
     self._curStarLevel and self._curStarLevel < talentData.l then   --点详情可升级
        self._isUpdateAnim = false
        local clickObj
        local mark = string.split(self._clickMark, "_")
        mark[2] = tonumber(mark[2])
        mark[3] = tonumber(mark[3])
        if mark[1] == "big" then
            clickObj = layer:getChildByFullName(string.format("big_skill_icon_%d_%d", mark[2], mark[3]))
        else
            clickObj = layer:getChildByFullName(string.format("skill_icon_%d_%d", mark[2], mark[3]))
        end

        --point1
        point1 = {}
        point1.x = clickObj:getContentSize().width*0.5
        point1.y = clickObj:getContentSize().height*0.5

        --point2
        local curStar = layer:getChildByFullName("label_skill_bar_bg.star" .. talentData.l)
        local point2 = curStar:convertToWorldSpace(cc.p(0, 0)) 
        point2 = clickObj:convertToNodeSpace(point2)
        point2.x = point2.x + curStar:getContentSize().width/2 - 15
        point2.y = point2.y + curStar:getContentSize().height/2 

        --angle
        local midPoint = MathUtils.midpoint(point1, point2)  
        local angle = 360 - MathUtils.angleAtan2(point1, point2) - 90

        --widget
        local pointDis = MathUtils.pointDistance(point1, point2)
        local moveX = (point2.x - point1.x) * 100 / pointDis
        local moveY = (point2.y - point1.y) * 100 / pointDis
        local wiget = ccui.Layout:create()
        wiget:setPosition(point1.x + moveX, point1.y + moveY)
        wiget:setRotation(angle)
        clickObj:addChild(wiget)

        --feixing1 xingxing
        local feixing1 = mcMgr:createViewMC("feixing1_mofahanghui", true)
        wiget:addChild(feixing1)

        --feixing2
        local wiget1 = ccui.Layout:create()
        wiget1:setScaleX(1.5)
        wiget:addChild(wiget1)
        local feixing2 = mcMgr:createViewMC("feixing2_mofahanghui", true)
        wiget1:addChild(feixing2)

        wiget:runAction(cc.Sequence:create(
            cc.MoveTo:create(0.4, cc.p(point2.x, point2.y)),
            cc.DelayTime:create(0.1),
            cc.CallFunc:create(function()
                wiget:removeAllChildren()
                wiget:removeFromParent(true)
                wiget = nil

                -- curStar:loadTexture("magicguild_update1.png", 1)
                -- local endAinm = mcMgr:createViewMC("fashubaodou_mofahanghuishengji", false, true)
                -- endAinm:setPosition(curStar:getContentSize().width/2, curStar:getContentSize().height/2)
                -- curStar:addChild(endAinm)

                local proBar = layer:getChildByFullName("label_skill_bar_bg.proBar")
                proBar.percent = math.max((talentData.l - 1) * 10, 0)
                local perTo = talentData.l * 10
                proBar:runAction(cc.RepeatForever:create(cc.Sequence:create(
                    cc.CallFunc:create(function()
                        if (proBar.percent or 0) >= perTo then
                            proBar:stopAllActions()
                            return
                        end
                        local curPercent = (proBar.percent or 0) + 0.5
                        proBar:setPercent(curPercent)
                        proBar.percent = curPercent
                        end),
                    cc.DelayTime:create(0.01)
                    )))
                local proNum = layer:getChildByFullName("label_skill_bar_bg.proNum")
                proNum:setString(talentData.l .. "/10")
                proNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)                
                end)
            ))

    else
        -- for i=1,10 do
        --     -- local star = layer:getChildByFullName("label_skill_bar_bg.star" .. i)
        --     -- if i <= talentData.l then
        --     --     star:loadTexture("magicguild_update1.png", 1)
        --     -- else
        --     --     star:loadTexture("magicguild_update2.png", 1)
        --     -- end
        -- end

        local proBar = layer:getChildByFullName("label_skill_bar_bg.proBar")
        proBar:setPercent(talentData.l * 10)
        
        local proNum = layer:getChildByFullName("label_skill_bar_bg.proNum")
        proNum:setString(talentData.l .. "/10")
        proNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    end
    self._curStarLevel = talentData.l
end

--右侧流动条特效
function TalentView:talentLineEffect(layer)
    for i=1, 3 do
        for j=2, 3 do
            local talentLine = layer:getChildByFullName(string.format("image_line_%d_%d", i, j))
            if talentLine.barMc ~= nil then
                talentLine.barMc:removeFromParent(true)
                talentLine.barMc = nil
            end
            local unlockLineMC = mcMgr:createViewMC("liudongtiao1_mofahanghui", true)
            unlockLineMC:setPosition(talentLine:getPositionX(), talentLine:getPositionY())
            talentLine:getParent():addChild(unlockLineMC, 1)

            talentLine.barMc = unlockLineMC
            unlockLineMC:setVisible(false)
            --变色
            self:setAnimColorByType(unlockLineMC)
        end
    end

    for k=1, 3 do
        local talentLine = layer:getChildByFullName(string.format("big_image_line_1_1_%d", k))
        if talentLine.barMc ~= nil then
            talentLine.barMc:removeFromParent(true)
            talentLine.barMc = nil
        end
        local layout = ccui.Layout:create()
        talentLine:getParent():addChild(layout, 1)
        talentLine.barMc = layout
        layout:setVisible(false)

        local mcName, disX, disY = "", 0, 0
        if k == 1 then
            mcName = "liudongtiao3_mofahanghui"
            disX, disY = -21, 20
        elseif k == 2 then
            disX, disY = 0, 0
            mcName = "liudongtiao1_mofahanghui"
        elseif k == 3 then
            mcName = "liudongtiao3_mofahanghui"
            layout:setScaleX(-1)
            disX, disY = 21, 20
        end

        layout:setPosition(talentLine:getPositionX() + disX, talentLine:getPositionY() + disY)
        local unlockLineMC = mcMgr:createViewMC(mcName, true)
        unlockLineMC:setPosition(cc.p(0,0))
        layout:addChild(unlockLineMC)
        --变色
        self:setAnimColorByType(unlockLineMC)
    end 
end

--inType：nil流动条特效 / 2圆圈特效
function TalentView:setAnimColorByType(inMc, inType)
    local animColor = {}
    
    if inType ~= nil then
        --2常态特效
        animColor = {
            [1] = {brightness = -12, contrast = 10, saturation = 12, hue = 100},    --水
            [2] = {brightness = 3, contrast = -38, saturation = 85, hue = -149},    --火
            [3] = {brightness = 11, contrast = 17, saturation = 45, hue = 87},      --气
            [4] = {brightness = 0, contrast = 0, saturation = 0, hue = -155},       --土
            [5] = {brightness = 50, contrast = 1, saturation = 29, hue = 71},       --元素
            [6] = {brightness = -30, contrast = 8, saturation = -10, hue = 102},   --混沌
            [7] = {brightness = -20 , contrast = 15 , saturation = 10 , hue = -50},   --混沌
        }

    else
        --nil流动条特效
        animColor = {
            [1] = {brightness = -12, contrast = 10, saturation = 12, hue = 100},    --水
            [2] = {brightness = 28, contrast = 6, saturation = 94, hue = -175},     --火
            [3] = {brightness = -11, contrast = 4, saturation = 82, hue = 110},     --气
            [4] = {brightness = -36, contrast = 6, saturation = -37, hue = -166},   --土
            [5] = {brightness = 0, contrast = 0, saturation = 31, hue = 62},        --元素
            [6] = {brightness = -30, contrast = 8, saturation = -10, hue = 102},   --混沌
            [7] = {brightness = -20 , contrast = 15 , saturation = 10 , hue = -50},   --混沌
        }
    end

    if self._viewType ~= 1 then
        local colorData = animColor[self._viewType]
        inMc:setHue(colorData["hue"])
        inMc:setBrightness(colorData["brightness"])
        inMc:setContrast(colorData["contrast"])
        inMc:setSaturation(colorData["saturation"])
    end
end

--左侧UI
function TalentView:updateLeftLayer(layer, talentData, dirty)
    local image = layer:getChildByFullName("image_frame")
    image:loadTexture(talentData.res .. ".jpg", 1)

    --法术名
    self._labelSkillName = layer:getChildByFullName("label_skill_name")  
    self._labelSkillName:setFontName(UIUtils.ttfName)
    -- self._labelSkillName:enableOutline(cc.c4b(60, 30, 10), 1)
    self._labelSkillName:setString(lang(talentData.name))

    --等级
    self._labelSkillLevel = layer:getChildByFullName("label_skill_level")  
    self._labelSkillLevel:setPositionX(isMaxLevel and 265 or 211)
    self._labelSkillLevel:setString("Lv."..talentData.l)

    --进度条
    self:progressBarEffect(layer, talentData)

    --描述
    self._skillDes = layer:getChildByFullName("layer_skill_des")
    local richTextDes = self._skillDes:getChildByName("descRichText")
    if richTextDes then
        richTextDes:removeFromParentAndCleanup()
    end
    richTextDes = RichTextFactory:create(lang("magicSeries_tips"), 300, 70)
    richTextDes:formatText()
    richTextDes:enablePrinter(true)
    richTextDes:setPosition(richTextDes:getContentSize().width/2, self._skillDes:getContentSize().height/2)
    richTextDes:setName("descRichText")
    self._skillDes:addChild(richTextDes)

    --当前等级 显示/隐藏
    self._layerConsumeInfo = layer:getChildByFullName("layer_cur_info")  
    self._layerEffectInfo = layer:getChildByFullName("layer_next_info")    
    self._imageHighestLevel = layer:getChildByFullName("image_highest_level")
    if talentData.l == 0 then   --0级
        self._layerConsumeInfo:setVisible(false)
        self._layerEffectInfo:setVisible(true)
        self._imageHighestLevel:setVisible(false)
        self._layerEffectInfo:setPosition(cc.p(41, 120))

    elseif talentData.l >= talentData.maxLevel then --满级
        self._layerConsumeInfo:setVisible(true)
        self._layerEffectInfo:setVisible(false)
        self._imageHighestLevel:setVisible(true)
    else
        self._layerConsumeInfo:setVisible(true)
        self._layerEffectInfo:setVisible(true)
        self._imageHighestLevel:setVisible(false)
        self._layerEffectInfo:setPosition(cc.p(41, 80))
    end

    --当前等级文本
    local desc = "[color=af7631]" .. self:getDescription(talentData) .. "[-]"   
    self._curlabel = layer:getChildByFullName("layer_cur_info.layer_cur_des")
    local richTextCur = self._curlabel:getChildByName("descRichText")
    if richTextCur then
        richTextCur:removeFromParentAndCleanup()
    end
    richTextCur = RichTextFactory:create(desc, 300, 70)
    richTextCur:formatText()
    richTextCur:enablePrinter(true)
    richTextCur:setPosition(richTextCur:getContentSize().width/2, self._curlabel:getContentSize().height/2)
    richTextCur:setName("descRichText")
    self._curlabel:addChild(richTextCur)

    --下一等级文本
    local nextTalentData = clone(talentData)
    nextTalentData.l = nextTalentData.l + 1
    local desc = "[color=af7631]" .. self:getDescription(nextTalentData) .. "[-]"
    self._nextlabel = layer:getChildByFullName("layer_next_info.layer_next_des")  
    local richTextNext = self._nextlabel:getChildByName("descRichText")
    if richTextNext then
        richTextNext:removeFromParentAndCleanup()
    end
    richTextNext = RichTextFactory:create(desc, 300, 70)
    richTextNext:formatText()
    richTextNext:enablePrinter(true)
    richTextNext:setPosition(richTextNext:getContentSize().width/2, self._nextlabel:getContentSize().height/2)
    richTextNext:setName("descRichText")
    self._nextlabel:addChild(richTextNext)
end

function TalentView:createRightLayer(layer, talentData)
    --星星点击  wangyan
    -- local rest_star = layer:getChildByFullName("layer_rest_star")
    -- self:registerClickEvent(rest_star, function(sender)
    --     DialogUtils.showItemApproach(39989)
    --     -- if not SystemUtils:enableElite() then
    --     --     self._viewMgr:showTip(lang("TIP_JINGYING_1"))
    --     --     return 
    --     -- end
    --     -- self._viewMgr:showView("intance.IntanceEliteView")
    -- end)
    local rest_star_getBtn = layer:getChildByFullName("notUse.getBtn")
    if rest_star_getBtn then
        self:registerClickEvent(rest_star_getBtn, function(sender)
            DialogUtils.showItemApproach(39989)
        end)
    end

    --重置
    local btnReset = layer:getChildByFullName("btn_reset")
    btnReset:getChildByName("Label_29"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self:registerClickEvent(btnReset, function(sender)
        self:onResetTalentButtonClicked()
    end)
    local css = 0   --by wangyan
    for k,v in pairs(self._talentData) do
        if v.cs then
            css = css + v.cs
        end
    end
    if css == 0 then
        btnReset:setVisible(false)
    else
        btnReset:setVisible(true)
    end

    --规则
    local btnRule = layer:getChildByFullName("btn_rule")
    -- btnRule:getChildByName("Label_29"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self:registerClickEvent(btnRule, function(sender)
        self:onRuleTalentButtonClicked()
    end)
end

---------------------------------------------updateLayer---------------------------------------------
function TalentView:updateLayer()
    local curChannel = self._viewType  --记录当前切页类型，防止切换页签值变化
    local layer = self._layers[curChannel]._layer
    local dirty = self._layers[curChannel]._dirty
    local talentData = self._talentData[curChannel]

    --剩余星数
    local starNum = layer:getChildByFullName("notUse.num")
    starNum:setString(self._userModel:getData().starNum)
    starNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    --已投入星数
    local costStarNum = layer:getChildByFullName("hasUse.num")
    costStarNum:setString(talentData.cs)
    costStarNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    if not (layer and dirty and talentData) then print("update layer return") return end  --dirty用来判断是否刷新小天赋界面

    local isOpen = talentData.l >= 1
    local isMaxLevel = talentData.l >= talentData.maxLevel
    self._layers[curChannel]._dirty = false

    self:updateLeftLayer(layer, talentData)  --左侧UI
    self:createRightLayer(layer, talentData)  --右侧部分UI

    --右侧流动条
    self:talentLineEffect(layer)

    --特效重置  wangyan
    for i=1, #talentData.cl do
        for j=1, #talentData.cl[i] do
            local btnIcon = layer:getChildByFullName(string.format("skill_icon_%d_%d.skill_icon", i, j))            
            if btnIcon:getParent():getChildByName("changtaiAnim") then
                btnIcon:getParent():getChildByName("changtaiAnim"):removeFromParent(true)
            end
        end
    end

    for i=1, #talentData.parentList do
        for j=1, #talentData.parentList[i] do
            local btnIcon = layer:getChildByFullName(string.format("big_skill_icon_%d_%d.skill_icon", i, j))
            if btnIcon:getParent():getChildByName("changtaiAnim") then
                btnIcon:getParent():getChildByName("changtaiAnim"):removeFromParent(true)
            end
        end
    end

    --右侧小天赋
    local colOpenNum = 0
    for i=1, #talentData.cl do
        local isColOpen = true
        for j=1, #talentData.cl[i] do           
            local talentChildData = talentData.cl[i][j]
            local locked = 0 == talentChildData.s
            local firstUnlock = not locked and 1 ~= SystemUtils.loadAccountLocalData("TALENT_UNLOCK_" .. curChannel .. "_" .. i .. "_" .. j)
            --icon
            local talent = layer:getChildByFullName(string.format("skill_icon_%d_%d", i, j))
            talent:setScaleAnim(true)
            talent:setSaturation((locked or firstUnlock) and -100 or 0)
            self:registerClickEvent(talent, function(sender)
                self._clickMark = "small_"..i.."_"..j
                self._isLvMax = talentData.l >= talentData.maxLevel and 1 or 0
                self._talentDetailsDialog = self._viewMgr:showDialog("talent.TalentDetailsView", {container = self, talentKindData = talentData, talentData = talentChildData, lastLv = talentChildData.l}, true)
            end)

            --lock
            local talentLocked = layer:getChildByFullName(string.format("skill_icon_%d_%d.image_locked", i, j))
            talentLocked:setVisible(locked or firstUnlock)

            --line
            local talentLine = nil
            if 1 ~= j then
                talentLine = layer:getChildByFullName(string.format("image_line_%d_%d", i, j))
                talentLine:setVisible(not (locked or firstUnlock))
                talentLine.barMc:setVisible(not (locked or firstUnlock))
            end

            --img
            local talentIcon = layer:getChildByFullName(string.format("skill_icon_%d_%d.skill_icon", i, j))
            talentIcon:setScale(0.85)
            talentIcon:loadTexture(talentChildData.icon .. ".png", 1)

            --imgBg
            local talentIconBg = layer:getChildByFullName(string.format("skill_icon_%d_%d.skill_icon_bg", i, j))
            talentIconBg:setScale(0.85)

            --num进度
            local iamgeValueBg = layer:getChildByFullName(string.format("skill_icon_%d_%d.image_value_bg", i, j))
            iamgeValueBg:setVisible(not locked)
            local labelValue = layer:getChildByFullName(string.format("skill_icon_%d_%d.image_value_bg.label_value", i, j))  
            labelValue:setString(string.format("%d/%d", talentChildData.l, talentChildData.maxLevel))

            if talentChildData.l >= talentChildData.maxLevel then
                --满级文本变绿色
                labelValue:setColor(cc.c3b(121, 249, 0))   --UIUtils.colorTable.ccUIBaseColor2
                labelValue:disableEffect()
                --满级常态动画
                local btnIcon = layer:getChildByFullName(string.format("skill_icon_%d_%d.skill_icon", i, j))
                if btnIcon:getParent():getChildByName("changtaiAnim") then
                    btnIcon:getParent():getChildByName("changtaiAnim"):removeFromParent(true)
                end
                local anim = mcMgr:createViewMC("shengjichantai_mofahanghui", true)   
                anim:setName("changtaiAnim")
                anim:setPosition(btnIcon:getContentSize().width * 0.5, btnIcon:getContentSize().height * 0.5)
                btnIcon:getParent():addChild(anim, 10)
                self:setAnimColorByType(anim, 2)
            else
                labelValue:setColor(UIUtils.colorTable.ccUIBaseColor1)
                labelValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            end

            --升级绿色箭头动画
            local imageUpgrade = layer:getChildByFullName(string.format("skill_icon_%d_%d.image_upgrade", i, j))
            imageUpgrade:stopAllActions()
            imageUpgrade:setPosition(67, 12)
            imageUpgrade:setVisible(false)
            if not firstUnlock and not locked and talentChildData.l < talentChildData.maxLevel then
                local have, cost = self._userModel:getData().starNum, talentChildData.cost[talentChildData.l + 1]
                if have >= cost then
                    imageUpgrade:setVisible(true)
                    local moveUp = cc.MoveTo:create(0.5, cc.p(67, 15))
                    local moveDown = cc.MoveTo:create(0.5, cc.p(67, 10))
                    imageUpgrade:runAction(cc.RepeatForever:create(cc.Sequence:create(moveUp, moveDown)))
                else
                    imageUpgrade:setVisible(false)
                end
            end

            --天赋解锁动画
            isColOpen = talentChildData.l >= talentChildData.maxLevel
            if firstUnlock then
                self:lock()
                local curI, curJ = i, j --防止切页签self._viewType变化，本地记录的状态错误
                ScheduleMgr:delayCall(500, self, function()
                    if not talentLocked then return end
                    talentLocked:runAction(cc.Sequence:create(cc.FadeOut:create(0.3), cc.CallFunc:create(function()
                        if not (talent and talentLocked) then return end
                        talent:setSaturation(0)
                        talentLocked:setVisible(false)
                    end)))

                    --流动条动画
                    if 1 ~= curJ then
                        if talentLine then
                            talentLine:setVisible(true)
                            talentLine.barMc:setVisible(true)
                        end
                    end
                    local unlockMC = mcMgr:createViewMC("tianfujiesuo_mofahanghui", false, true)
                    unlockMC:addCallbackAtFrame(20, function()
                        if not locked and talentChildData.l < talentChildData.maxLevel then
                            local have, cost = self._userModel:getData().starNum, talentChildData.cost[talentChildData.l + 1]
                            if have >= cost then
                                imageUpgrade:setVisible(true)
                                local moveUp = cc.MoveTo:create(0.5, cc.p(67, 17))
                                local moveDown = cc.MoveTo:create(0.5, cc.p(67, 12))
                                imageUpgrade:runAction(cc.RepeatForever:create(cc.Sequence:create(moveUp, moveDown)))
                            else
                                imageUpgrade:setVisible(false)
                            end
                        end
                        SystemUtils.saveAccountLocalData("TALENT_UNLOCK_" .. curChannel .. "_" .. curI .. "_" .. curJ, 1)
                    end)
                    unlockMC:setPosition(talent:getPosition())
                    talent:getParent():addChild(unlockMC, 100)
                    self:unlock()
                end)
            end
        end
        if isColOpen then
            colOpenNum = colOpenNum + 1
        end
    end

    --最后一个icon  
    if not self._layers[curChannel]._talentMC then
        local imageIconBg = layer:getChildByFullName("big_skill_icon_1_1.image_icon_bg")
        local mask = cc.Sprite:createWithSpriteFrameName("image_icon_clipImg.png")
        mask:setScale(1.1)
        local clipNode = cc.ClippingNode:create()
        clipNode:setInverted(false) 
        clipNode:setStencil(mask)
        clipNode:setAlphaThreshold(0.05)
        clipNode:setPosition(imageIconBg:getPosition())
        self._layers[curChannel]._talentMC = mcMgr:createViewMC("zuihoutianfu_mofahanghui", true)
        self._layers[curChannel]._talentMC:setPosition(cc.p(0, 50))
        self._layers[curChannel]._talentMC:setVisible(false)
        self._layers[curChannel]._talentMC:setScaleY(1.13)
        clipNode:addChild(self._layers[curChannel]._talentMC, 20)
        clipNode:setPosition(40, 42)
        imageIconBg:getParent():addChild(clipNode)

        self:setAnimColorByType(self._layers[curChannel]._talentMC)
    end

    if self._layers[curChannel]._talentMC and colOpenNum ~= self._layers[curChannel]._talentLastColOpenNum then
        self._layers[curChannel]._talentMC:setVisible(colOpenNum > 0)
        self._layers[curChannel]._talentMC:runAction(cc.MoveTo:create(0.1, cc.p(0, colOpenNum * 109/3 - 41)))
        self._layers[curChannel]._talentMC:addEndCallback(function()
            self._layers[curChannel]._talentMC:gotoAndPlay(22)
        end)
        
        self._layers[curChannel]._talentLastColOpenNum = colOpenNum
    end

    for i=1, #talentData.parentList do
        for j=1, #talentData.parentList[i] do
            local talentParentData = talentData.parentList[i][j]
            local locked = 0 == talentParentData.s
            local firstUnlock = not locked and 1 ~= SystemUtils.loadAccountLocalData("BIG_TALENT_UNLOCK_" .. curChannel .. "_" .. i .. "_" .. j)
            --icon
            local talent = layer:getChildByFullName(string.format("big_skill_icon_%d_%d", i, j))
            talent:getChildByFullName("skill_icon"):setSaturation((locked or firstUnlock) and -100 or 0)
            talent:getChildByFullName("skill_icon_bg"):setSaturation((locked or firstUnlock) and -100 or 0)
            talent:getChildByFullName("image_value_bg"):setSaturation((locked or firstUnlock) and -100 or 0)
            talent:getChildByFullName("image_locked"):setSaturation((locked or firstUnlock) and -100 or 0)
            talent:getChildByFullName("image_upgrade"):setSaturation((locked or firstUnlock) and -100 or 0)
            -- talent:setSaturation((locked or firstUnlock) and -100 or 0)
            talent:setScaleAnim(true)
            self:registerClickEvent(talent, function(sender)
                self._clickMark = "big_"..i.."_"..j
                self._isLvMax = talentData.l >= talentData.maxLevel and 1 or 0
                self._talentDetailsDialog = self._viewMgr:showDialog("talent.TalentDetailsView", {container = self, talentKindData = talentData, talentData = talentParentData, lastLv = talentParentData.l, isBig = true}, true)
            end)

            --lock
            local talentLocked = layer:getChildByFullName(string.format("big_skill_icon_%d_%d.image_locked", i, j))
            talentLocked:setVisible(locked or firstUnlock)

            --clip外圈
            local clipImg1 = layer:getChildByFullName(string.format("big_skill_icon_%d_%d.Image_52", i, j))
            clipImg1:setScale(1.11)
            clipImg1:setPosition(40, 40)

            --line
            local talentLine = {}
            for k=1, 3 do
                local talentChildData = talentData.cl[k][3]
                talentLine[k] = layer:getChildByFullName(string.format("big_image_line_%d_%d_%d", i, j, k))
                if talentChildData.l >= talentChildData.maxLevel then
                    talentLine[k]:setVisible(true)
                    talentLine[k].barMc:setVisible(true)
                else
                    talentLine[k]:setVisible(false)
                    talentLine[k].barMc:setVisible(false)
                end
                -- talentLine[k] = layer:getChildByFullName(string.format("big_image_line_%d_%d_%d", i, j, k))
                -- talentLine[k].barMc:setVisible(not (locked or firstUnlock))
            end
            
            --iconImg
            local talentIcon = layer:getChildByFullName(string.format("big_skill_icon_%d_%d.skill_icon", i, j))
            talentIcon:setScale(0.85)
            talentIcon:loadTexture(talentParentData.icon .. ".png", 1)

            --imgBg
            local talentIconBg = layer:getChildByFullName(string.format("big_skill_icon_%d_%d.skill_icon_bg", i, j))
            talentIconBg:setScale(0.85)

            --进度
            local iamgeValueBg = layer:getChildByFullName(string.format("big_skill_icon_%d_%d.image_value_bg", i, j))
            iamgeValueBg:setVisible(not locked)
            local labelValue = layer:getChildByFullName(string.format("big_skill_icon_%d_%d.image_value_bg.label_value", i, j))
            labelValue:setString(string.format("%d/%d", talentParentData.l, talentParentData.maxLevel))
            labelValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor)

            if talentParentData.l >= talentParentData.maxLevel then
                labelValue:setColor(cc.c3b(121, 249, 0))   --满级绿色
                labelValue:disableEffect()
                local btnIcon = layer:getChildByFullName(string.format("big_skill_icon_%d_%d.skill_icon", i, j))
                if btnIcon:getParent():getChildByName("changtaiAnim") then
                    btnIcon:getParent():getChildByName("changtaiAnim"):removeFromParent(true)
                end
                local anim = mcMgr:createViewMC("shengjichantai_mofahanghui", true)   --满级常态动画
                anim:setPosition(btnIcon:getContentSize().width * 0.5, btnIcon:getContentSize().height * 0.5 + 3)
                anim:setName("changtaiAnim")
                anim:setScale(0.9)
                btnIcon:getParent():addChild(anim, 10)
                self:setAnimColorByType(anim, 2)
            else
                labelValue:setColor(UIUtils.colorTable.ccUIBaseColor1)
                labelValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            end

            --升级箭头
            local imageUpgrade = layer:getChildByFullName(string.format("big_skill_icon_%d_%d.image_upgrade", i, j))
            imageUpgrade:stopAllActions()
            imageUpgrade:setPosition(67, 12)
            imageUpgrade:setVisible(false)
            if not firstUnlock and not locked and talentParentData.l < talentParentData.maxLevel then
                local have, cost = self._userModel:getData().starNum, talentParentData.cost[talentParentData.l + 1]
                if have >= cost then
                    imageUpgrade:setVisible(true)
                    local moveUp = cc.MoveTo:create(0.5, cc.p(67, 17))
                    local moveDown = cc.MoveTo:create(0.5, cc.p(67, 12))
                    imageUpgrade:runAction(cc.RepeatForever:create(cc.Sequence:create(moveUp, moveDown)))
                else
                    imageUpgrade:setVisible(false)
                end
            end

            --第一次解锁
            if firstUnlock then
                self:lock()
                local curI, curJ = i, j
                ScheduleMgr:delayCall(500, self, function()
                    if not talentLocked then return end
                    talentLocked:runAction(cc.Sequence:create(cc.FadeOut:create(0.3), cc.CallFunc:create(function()
                        if not (talent and talentLocked) then return end
                        talent:getChildByFullName("skill_icon"):setSaturation(0)
                        talent:getChildByFullName("skill_icon_bg"):setSaturation(0)
                        talent:getChildByFullName("image_value_bg"):setSaturation(0)
                        talent:getChildByFullName("image_locked"):setSaturation(0)
                        talent:getChildByFullName("image_upgrade"):setSaturation(0)
                        talentLocked:setVisible(false)
                    end)))

                    --流动条动画
                    if talentLine[1] then
                        talentLine[1]:setVisible(true)
                        talentLine[1].barMc:setVisible(true)
                    end
                    if talentLine[2] then
                        talentLine[2]:setVisible(true)
                        talentLine[2].barMc:setVisible(true)
                    end
                    if talentLine[3] then
                        talentLine[3]:setVisible(true)
                        talentLine[3].barMc:setVisible(true)
                    end

                    --解锁动画
                    local unlockMC = mcMgr:createViewMC("tianfujiesuo_mofahanghui", false, true)
                    unlockMC:addCallbackAtFrame(20, function()
                        if not locked and talentParentData.l < talentParentData.maxLevel then
                            local have, cost = self._userModel:getData().starNum, talentParentData.cost[talentParentData.l + 1]
                            if have >= cost then
                                imageUpgrade:setVisible(true)
                                local moveUp = cc.MoveTo:create(0.5, cc.p(67, 17))
                                local moveDown = cc.MoveTo:create(0.5, cc.p(67, 12))
                                imageUpgrade:runAction(cc.RepeatForever:create(cc.Sequence:create(moveUp, moveDown)))
                            else
                                imageUpgrade:setVisible(false)
                            end
                        end
                        SystemUtils.saveAccountLocalData("BIG_TALENT_UNLOCK_" .. curChannel .. "_" .. curI .. "_" .. curJ, 1)
                    end)
                    unlockMC:setPosition(cc.p(talent:getPositionX(), talent:getPositionY()))
                    talent:getParent():addChild(unlockMC, 100)

                    self:unlock()
                end)
            end
        end
    end
end

--详情界面 升级按钮点击回调
function TalentView:onUpTalentChildLvButtonClicked(talentKindData, talentData)
    local context = {kind = talentKindData.id, tid = talentData.id}
    self._oldFight = TeamUtils:updateFightNum()
    self._serverMgr:sendMsg("TalentServer", "upTalentChildLv", context, true, {}, function(result, success)
        if not success then 
            self._viewMgr:showTip("升级失败")
            return 
        end

        self._viewMgr:showTip(lang("magicResetTip_3"))
        self._talentData = self:initTalentData()
        if self._talentDetailsDialog then
            --by wangyan
            local posX, posY = self._talentDetailsDialog:getContentSize().width/2 - 100, 450 
            TeamUtils:setFightAnim(self._talentDetailsDialog, {oldFight = self._oldFight, newFight = TeamUtils:updateFightNum(), x = posX, y = posY})

            local found1, tKindData = self:getTalentKindData(talentKindData.id)
            local found2, tChildData = self:getTalentChildData(talentKindData.id, talentData.id)
            if found1 and found2 then
                self._talentDetailsDialog:setContext({talentKindData = tKindData, talentData = tChildData})
                self._talentDetailsDialog:updateUI()
            end
        end
        self:updateLayer()
    end)
end

--重置
function TalentView:resetLocalData(isSingle)
    local talentData = self._talentData[self._viewType]

    local function resetLocal(index)  --单页重置
        for i=1, #talentData.cl do
            for j=1, #talentData.cl[i] do
                SystemUtils.saveAccountLocalData("TALENT_UNLOCK_" .. index .. "_" .. i .. "_" .. j, 0)
            end
        end
    end

    local function resetLocalP(index) 
        for i=1, #talentData.parentList do
            for j=1, #talentData.parentList[i] do
                SystemUtils.saveAccountLocalData("BIG_TALENT_UNLOCK_" .. index .. "_" .. i .. "_" .. j, 0)
            end
        end
    end

    if isSingle then
        resetLocal(self._viewType)
        resetLocalP(self._viewType)
    else
        for k=1,7 do   --页签数
            resetLocal(k)
        end
        for k=1,7 do
            resetLocalP(k)
        end
    end
end

-- 重置按钮点击事件
function TalentView:onResetTalentButtonClicked()
    local totalGem = self._userModel:getData().freeGem + self._userModel:getData().payGem
    local talentData = self._talentData[self._viewType]

    local function resetCallback1()   --all
        local consume = tab:Setting("G_TALENT_RESET_CONSUME").value
        if consume > totalGem then
            DialogUtils.showNeedCharge({callback1=function( )
                local viewMgr = ViewManager:getInstance()
                viewMgr:showView("vip.VipView", {viewType = 0})
            end})
            return 
        end

        self._serverMgr:sendMsg("TalentServer", "resetTalent", {}, true, {}, function(success, result)
            if not success then 
                self._viewMgr:showTip("重置失败")
                return 
            end

            self._viewMgr:showTip(lang("magicResetTip_2"))
            self:resetLocalData()

            self:refreshUI()
        end)

    end

    local function resetCallback2()
        local consume = tab:Setting("G_TALENT_RESET_CONSUME_2").value
        if consume > totalGem then
            DialogUtils.showNeedCharge({callback1=function( )
                local viewMgr = ViewManager:getInstance()
                viewMgr:showView("vip.VipView", {viewType = 0})
            end})
            return 
        end

        self._serverMgr:sendMsg("TalentServer", "resetTanlentSingle", {kind = talentData["id"]}, true, {}, function(success, result)
            if not success then 
                self._viewMgr:showTip("重置失败")
                return 
            end

            self._viewMgr:showTip(lang("magicResetTip_2"))
            self:resetLocalData(true)
            self:refreshUI()
        end)
    end

    self._viewMgr:showDialog("talent.TalentResetView", {callback1 = resetCallback1, callback2 = resetCallback2}, true)
end

-- 规则按钮点击事件
function TalentView:onRuleTalentButtonClicked()
    self._viewMgr:showDialog("global.GlobalRuleDescView",{desc = lang("magicSeries_rule")},true)
end

--详情界面关闭 刷新回调
function TalentView:onTalentDetailsViewClose(isLevelUp)
    self._talentDetailsDialog = nil
    self._isUpdateAnim = isLevelUp
    self:refreshUI()
end

function TalentView:getAsyncRes()
    return 
    {
        {"asset/ui/magic.plist", "asset/ui/magic.png"},
        {"asset/ui/magic1.plist", "asset/ui/magic1.png"},
    }
end

function TalentView:getBgName(  )
    return "bg_007.jpg"
end

return TalentView
