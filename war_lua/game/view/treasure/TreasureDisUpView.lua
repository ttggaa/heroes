--
-- Author: <ligen@playcrab.com>
-- Date: 2016-07-21 22:31:14
--

--[[加入升星 layer ,
-- 通过设置层级, 升星layer可以使用通用标头、宝物列表等UI和数据
-- ]]
local volumeChange = {25,16,9,4,1}
local maxDisStage = table.nums(tab.devDisTreasure) + 1

local TreasureDisUpView = class("TreasureDisUpView", BasePopView)
function TreasureDisUpView:ctor()
    self.super.ctor(self)

    self._tModel = self._modelMgr:getModel("TreasureModel")

    self._disIconList = { };
end

-- function TreasureDisUpView:getAsyncRes()
--     return
--     {
--         { "asset/ui/treasure2.plist", "asset/ui/treasure2.png" }
--     }
-- end

-- 初始化UI后会调用, 有需要请覆盖
function TreasureDisUpView:onInit()
    self._materialNode = self:getUI("bg.layer.materialNode")
    self._materialNode:setVisible(false)
    self._materialPanel = self:getUI("bg.layer.materialPanel")

    self._title = self:getUI("bg.layer.headBg.title")
    self._title:setFontName(UIUtils.ttfName)
    UIUtils:setTitleFormat(self._title,1)

    self._name = self:getUI("bg.layer.name")
    -- UIUtils:setTitleFormat(self._name,1)
    self._nameBg = self:getUI("bg.layer.nameBg")
    self._attTitle = self:getUI("bg.layer.basicInfo.attTitle")
    UIUtils:setTitleFormat(self._attTitle,3)

    self._disListView = self:getUI("bg.layer.listBg.disListView")
    self._disListView:setBounceEnabled(true)
    self._selectFrame = cc.Sprite:createWithSpriteFrameName("globalImageUI4_selectFrame.png")
    self._selectFrame:setScale(107 / self._selectFrame:getContentSize().width)
    self._selectFrame:setAnchorPoint(0, 0)
    self._selectFrame:setPosition(6, 4)
    self._selectFrame:retain()

    self._des1 = self:getUI("bg.layer.infoBg.titleBg1.titleLab")
    self._des1:setFontName(UIUtils.ttfName)
    -- self._des1:setString("进阶提升")
    -- UIUtils:setTitleFormat(self._des1,2)
    self._des2 = self:getUI("bg.layer.infoBg.titleBg2.titleLab")
    -- self._des2:setFontName(UIUtils.ttfName)
    -- self._des2:setString("进阶材料")
    -- UIUtils:setTitleFormat(self._des2,2)
    UIUtils:adjustTitle(self:getUI("bg.layer.infoBg.titleBg1"))
    UIUtils:adjustTitle(self:getUI("bg.layer.infoBg.titleBg2"))
    UIUtils:adjustTitle(self:getUI("bg.layer.basicInfo.titleBg"))

    self._attPanel = self:getUI("bg.layer.attPanel")
    self._attPanel:setVisible(false)

    self._basicInfo = self:getUI("bg.layer.basicInfo")
    local baseTitleLab = self:getUI("bg.layer.basicInfo.titleBg.titleLab")
    baseTitleLab:setString("宝物属性")
    self._infoBg = self:getUI("bg.layer.infoBg")

    self._iconMaxStage = self:getUI("bg.layer.iconMaxStage")
    self._affectPanel = self:getUI("bg.layer.infoBg.affectPanel")

    self._curTreasureData = { }

    self:registerClickEventByName("bg.layer.closeBtn", function()
        if self._upStarLayer then
            self._upStarLayer:removeFromParent()
            self._upStarLayer = nil
            UIUtils:reloadLuaFile("treasure.TreasureUpStarLayer")
        end
        self:close()
        UIUtils:reloadLuaFile("treasure.TreasureDisUpView")
    end )
    self._upBtn = self:getUI("bg.layer.upBtn")
    self._upBtn:setCapInsets(cc.rect(100,70,1,1))
    self._upBtn:setContentSize(cc.size(200,70))
    self:registerClickEventByName("bg.layer.upBtn", function()
        if self._curTreasureData.upType == "dis" and self._curTreasureData.stage == maxDisStage then
            self._viewMgr:showTip("已满阶")
            return
        end
        if not self._abundent then
            self._viewMgr:showTip(lang("TIPS_ARTIFACT_01") or "材料不足")
            return
        end
        self:lock(-1)
        if self._curTreasureData.upType == "dis" then
            self._serverMgr:sendMsg("TreasureServer", "promoteDisTreasure", { disId = self._curTreasureData.id, comId = self._curTreasureData.cid }, true, { }, function(result)
                
                self._curTreasureData.stage = self._curTreasureData.stage + 1
                --播放进阶动画放到下一帧
                ScheduleMgr:nextFrameCall(self, function()audioMgr:playSound("Artifact")
                    self._viewMgr:showDialog("treasure.TreasureUpStageSuccessView",
                    { id = self._curTreasureData.id, stage = self._curTreasureData.stage, callBack = handler(self, self.fightValueCallBack) }, true,false,nil,true)
                    self:unlock()
                end)
                self:reflashUI(self._curTreasureData)
            end )
        end
    end )
    self:listenReflash("TreasureModel", self.reflashUI)
    self:listenReflash("ItemModel", self.reflashUI)

    -- 加到这个界面上一个新的layer
    self._layer = self:getUI("bg.layer")
    self._upStarLayer = self:createLayer("treasure.TreasureUpStarLayer",{parent = self._layer})
    self._upStarLayer:setVisible(false)
    self._upStarLayer:setAnchorPoint(0,0)
    self._upStarLayer:setPosition(0,0)
    self._layer:addChild(self._upStarLayer,99)
    self:initTab()

    -- 如果没开启页签，调整弹窗居中
    local isOpen,isShow,des = SystemUtils:enableTreasureStar()
    local _,isPreDay = self:isInOpenTime()
    local sTimeData = tab.sTimeOpen[103]
    local level = self._modelMgr:getModel("UserModel"):getPlayerLevel()
    isShow = level >= sTimeData.noticelv and isPreDay
    if not isShow then
        local parameter = self._layer:getLayoutParameter()
        parameter:setMargin({left=45,top=45,right=0,bottom=0})
        self._layer:setLayoutParameter(parameter)
    end
    
end

function TreasureDisUpView:onTop( )
    if self._upStarLayer then
        self._upStarLayer:onTop()
    end
end

function TreasureDisUpView:onHide()
    if self._upStarLayer then
        self._upStarLayer:onHide()
    end
end

-- 新增页签
function TreasureDisUpView:initTab( )
    local tabConfig = {"tab_upStage","tab_upStar"}
    self._tab = {}
    for i=1,2 do
        local tab = self:getUI("bg.layer." .. tabConfig[i])
        table.insert(self._tab,tab)
        UIUtils:setTabChangeAnimEnable(tab,-30,handler(self, self.touchTab),i)
    end
    self:touchTab(1)
    self:detectUpStarOpen()
end

function TreasureDisUpView:detectUpStarOpen( )
    local isOpen,isShow,des = SystemUtils:enableTreasureStar()
    local sTimeData = tab.sTimeOpen[103]
    local level = self._modelMgr:getModel("UserModel"):getPlayerLevel()
    local _,isPreDay = self:isInOpenTime()
    isShow = level >= sTimeData.noticelv and isPreDay
    self._tab[2]:setVisible(isShow) 
    self._tab[1]:setVisible(isShow)
    UIUtils:setGray(self._tab[2],not isOpen and isShow)
    return isOpen 
end

function TreasureDisUpView:touchTab( idx )
    if idx == 2 then -- 升星50级开
        if not self:detectUpStarOpen() then
            local level = self._modelMgr:getModel("UserModel"):getPlayerLevel()
            local sTimeData = tab.sTimeOpen[103]
            local isTimeOpen = self:isInOpenTime()
            if not isTimeOpen then
                local sTimeData = tab.sTimeOpen[103]
                local des = lang(sTimeData.systemTimeOpenTip)
                des = string.gsub(des,"%b{}",function( catchStr )
                    local str = catchStr
                    str = str.gsub(str,"{","")  
                    str = str.gsub(str,"}","")
                    local _,_,nowDaySec = self:isInOpenTime() -- self._modelMgr:getModel("UserModel"):getOpenServerTime()
                    -- local nowDaySec = self._modelMgr:getModel("UserModel"):getOpenServerTime()
                    local openDay = math.ceil(nowDaySec/86400)
                    print("nowDaySec",nowDaySec,nowDaySec/86400,openDay)
                    openDay = sTimeData.opentime - openDay

                    str = str.gsub(str,"$serveropen",openDay)  
                    str = loadstring("return " .. str)
                    local _,result = trycall("count",str) 
                    return result or catchStr
                end)
                self._viewMgr:showTip(des or "")
            elseif level < sTimeData.level then
                self._viewMgr:showTip(lang(sTimeData.systemOpenTip))
            end
    
            UIUtils:tabTouchAnimOut(self._tab[2])
            return 
        end
    end
    for i,v in ipairs(self._tab) do
        if i ~= idx then
            self:setTabStatus(v,false)
            if self._preBtn then
                UIUtils:tabChangeAnim(self._preBtn,nil,true)
            end
        end
    end
    local selectTab = self._tab[idx]
    self._preBtn = selectTab 
    UIUtils:tabChangeAnim(selectTab,function( )
        self:setTabStatus(selectTab,true)
    end)
    self._upStarLayer:setVisible(idx == 2)
    if idx == 2 then
        self._upStarLayer:reflashUI(self._curTreasureData)
        self._title:setString("宝物升星")
    else
        self._title:setString("宝物进阶")
    end
    self:updateDisIcons()
end

function TreasureDisUpView:isInOpenTime( )
    local tabId = 103
    local serverBeginTime = ModelManager:getInstance():getModel("UserModel"):getData().sec_open_time
    if serverBeginTime then
        local sec_time = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(serverBeginTime,"%Y-%m-%d 05:00:00"))
        if serverBeginTime < sec_time then   --过零点判断
            serverBeginTime = sec_time - 86400
        end
    end
    local serverHour = tonumber(TimeUtils.date("%H",serverBeginTime)) or 0
    local nowTime = ModelManager:getInstance():getModel("UserModel"):getCurServerTime()
    local openDay = tab:STimeOpen(tabId).opentime-1
    local openTimeNotice = tab:STimeOpen(tabId).openhour
    local openHour = string.format("%02d:00:00",openTimeNotice)
    local openTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(serverBeginTime + openDay*86400,"%Y-%m-%d " .. openHour))
    local leftTime = openTime - nowTime
    local isOpen = leftTime <= 0
    -- 显示页签时间
    local noticeTime = tab:STimeOpen(tabId).notice-1
    local showTabTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(serverBeginTime + noticeTime*86400,"%Y-%m-%d " .. openHour))
    local showLeftTime = showTabTime - nowTime
    local isPreDay = showLeftTime <= 0

    return isOpen,isPreDay,leftTime
end

function TreasureDisUpView:setTabStatus( tabBtn,isSelect )
    if isSelect then
        tabBtn:loadTextureNormal("globalBtnUI4_page1_p.png",1)
        local text = tabBtn:getTitleRenderer()
        tabBtn:setTitleColor(UIUtils.colorTable.ccUITabColor1)
        text:disableEffect()
    else
        tabBtn:loadTextureNormal("globalBtnUI4_page1_n.png",1)
        local text = tabBtn:getTitleRenderer()
        tabBtn:setTitleColor(UIUtils.colorTable.ccUITabColor2)
        text:disableEffect()
    end
    tabBtn:setEnabled(not isSelect)
end
-- 页签处理 end

-- 接收自定义消息
function TreasureDisUpView:reflashUI(data)
    if data and not data.id then data = nil end
    self._curTreasureData = data or self._curTreasureData
    if not data then data = self._curTreasureData end
    if self._upStarLayer:isVisible() then
        self._upStarLayer:reflashUI(data)
        self._title:setString("宝物升星")
        -- return
    else
        self._title:setString("宝物进阶")
    end
    local upType = self._curTreasureData.upType or "dis"
    if upType == "dis" then
        -- self._title:setString("宝物进阶")

        

        self._curDisData = tab:DisTreasure(data.id)

        self:updateDisIcons(self._disDataList);

        local disNode = self:getUI("bg.layer.treasureNode")
        disNode:removeAllChildren()
        local icon = self:createDisTreasureIcon(data.id, data.stage)
        icon:setScale(0.8)
        disNode:addChild(icon, 99)

        if data.stage < maxDisStage then
            local materials = { }
            local devDisT = tab:DevDisTreasure(data.stage)
            local material = { "tool", data.id, devDisT.treasureNum }
            table.insert(materials, material)
            -- for i=1,5 do
            material = devDisT["mater" .. self._curDisData.quality]
            table.insert(materials, material)
            -- end
            self:generateMatirals(materials)
            self._iconMaxStage:setVisible(false)
            self._upBtn:setVisible(true)
        else
            self._iconMaxStage:setVisible(true)
            self._upBtn:setVisible(false)
            self._materialPanel:removeAllChildren()
        end
    end

    local canUp = true
    if self._curTreasureData.upType == "dis" and self._curTreasureData.stage == maxDisStage then
        canUp = false
    end
    if not self._abundent then
        canUp = false
    end

    self._upBtn:removeAllChildren()
    if canUp then
        local mc1 = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true, false)
        mc1:setName("anim")
        mc1:setScale(1.5,1.15)
        mc1:setPosition(100, 35)
        self._upBtn:addChild(mc1, 1)
    end
    UIUtils:setGray(self._upBtn, not canUp)
end

-- 更新左侧宝物列表
function TreasureDisUpView:updateDisIcons(disList)
    self._disDataList = { };
    for k, v in pairs(tab.comTreasure) do
        if v.id == self._curTreasureData.cid then
            for i = 1, #v.form do
                local disData = { };
                disData.disId = v.form[i];
                local disInfo = self._tModel:getTreasureById(tostring(v.form[i]))
                disData.devNum = disInfo and disInfo.s;
                table.insert(self._disDataList, disData)
            end
        end
    end
    disList = self._disDataList
    local iconList = self._disListView:getChildren()
    local curIdx = 1
    for i = 1, #disList do
        local disData = disList[i];

        if iconList[i] == nil then 
            local disLayout = ccui.Layout:create()
            disLayout:setAnchorPoint(cc.p(1, 1))
            disLayout:setContentSize(cc.size(120, 106))
            self._disListView:addChild(disLayout);
            table.insert(iconList, disLayout);
        else
            table.remove(self._disIconList, i)
            iconList[i]:getChildByName("disIcon"):removeFromParent(true)
        end

        local disIcon = IconUtils:createItemIconById(
        { itemId = disData.disId, eventStyle = 0, stage = (disData.devNum and disData.devNum > 0 and disData.devNum), effect = true, showStar = true })
        disIcon:setScale(89 / disIcon:getContentSize().width)
        disIcon:setName("disIcon")
        disIcon:setPosition(15,12)
        iconList[i]:addChild(disIcon)

        self:registerClickEvent(disIcon,function(...)
            self:refreshDisTreasure(...)
        end)
        table.insert(self._disIconList, i, disIcon);


        if disData.disId == self._curDisData.id then
            if self._selectFrame:getParent() ~= nil then
                self._selectFrame:removeFromParent()
            end
            iconList[i]:addChild(self._selectFrame)
            curIdx = i
        end

        local canUp = true
        local devDisT = nil
        if disData.devNum ~= nil and disData.devNum < maxDisStage then
            devDisT = tab:DevDisTreasure(disData.devNum)
        end
        if devDisT then
            local materials = devDisT["mater" .. tab:DisTreasure(disData.disId).quality]
            -- for _,material in pairs(materials) do
            local _, haveNum = self._modelMgr:getModel("ItemModel"):getItemsById(materials[2])
            if haveNum < self._tModel:getCurrentNum(materials[2],materials[3]) then
                canUp = false
            end
            -- end
            local _, haveNum = self._modelMgr:getModel("ItemModel"):getItemsById(disData.disId)
            if haveNum < devDisT.treasureNum then
                canUp = false
            end
        else
            canUp = false
        end
        if canUp and not self._upStarLayer:isVisible() then
            if iconList[i]:getChildByName("arrowUp") == nil then
                local arrowUp = cc.Sprite:createWithSpriteFrameName("globalImageUI5_upArrow.png")
                arrowUp:setPosition(iconList[i]:getContentSize().width - 33, 33)
                arrowUp:stopAllActions()
                arrowUp:setName("arrowUp")
                iconList[i]:addChild(arrowUp, 110)
                local moveUp = cc.MoveBy:create(0.5, cc.p(0, 3))
                local moveDown = cc.MoveBy:create(0.5, cc.p(0, -3))
                local seq = cc.Sequence:create(moveUp, moveDown)
                local repeateMove = cc.RepeatForever:create(seq)
                arrowUp:runAction(repeateMove)
            end
        elseif (not canUp or self._upStarLayer:isVisible()) and iconList[i]:getChildByName("arrowUp") ~= nil then
            iconList[i]:removeChildByName("arrowUp")
        end


        if disData.devNum == nil or disData.devNum == 0 then
            iconList[i]:getChildByName("disIcon"):setSaturation(-180)
        end
    end
    self._disListView:setInnerContainerSize(cc.size(90, #iconList * 106))
    if curIdx > 2 then
        -- self._disListView:scrollToTop(0.01,true)
        self._disListView:scrollToBottom(0.1,false)
    end


end

function TreasureDisUpView:refreshDisTreasure(sender)
    local index = 0;
    for i = 1, #self._disIconList do
        if sender == self._disIconList[i] then
            index = i;
            break;
        end
    end
    local curDisData = self._disDataList[index];

    if curDisData.devNum == nil or curDisData.devNum == 0 then
        self._viewMgr:showTip(lang("TIPS_ARTIFACT_07"))
    else
        self:reflashUI( { upType = "dis", id = curDisData.disId, cid = self._curTreasureData.cid, stage = curDisData.devNum })
    end

end

-- 生成散件属性列
function TreasureDisUpView:createDisTreasureIcon(id, stage, up)
    local icon = IconUtils:createItemIconById( { itemId = id, eventStyle = 0 , showStar = true})
    icon:setScale(0.8)
    self:generateAtts(id, stage, self._basicInfo, -5, -2, maxDisStage)

    self._name:setString(lang(tab:DisTreasure(id).name) .. "+" .. stage)
    local color = tab:DisTreasure(id).quality or 2
    self._nameBg:loadTexture("globalImageUI12_tquality".. color  ..".png",1)
    self:generateExAtts(id, stage, self._infoBg, 25, 350)
    return icon
end

-- 刷新兵团板子
function TreasureDisUpView:reflashAffectPanel( volume )
    local  des   = self._affectPanel:getChildByName("des")
    -- des:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    local volumeLab = self._affectPanel:getChildByName("volume")
    volumeLab:setString(volumeChange[volume])
    local volumeImg = self._affectPanel:getChildByName("volumeImg")
    volumeImg:loadTexture("v".. volume .."_battle_treasure.png",1)     
end

-- 进阶素材
function TreasureDisUpView:generateMatirals(data)
    self._materialPanel:removeAllChildren()
    self._abundent = true
    local num = table.nums(data)
    local itemSize = 113
    local x, y = 0, 0
    local offsetx, offsety = 3, 25
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
                -- showStar = true,
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
                -- showStar = true,
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
        icon:setScale(85 / icon:getContentSize().width)
        item:addChild(icon)
        local toolD = tab:Tool(itemId)
        local color = 1
        if toolD then
            color = toolD.color or 1
        end
        needNum:setString(ItemUtils.formatItemCount(hadNum or 0) .. "/" .. self._tModel:getCurrentNum(material[2],material[3]))
        x = itemSize *(i - 1)
        item:setPosition(x + offsetx, y + offsety)
        self._materialPanel:addChild(item)
    end
end

-- 属性值成长
function TreasureDisUpView:generateAtts(id, stage, node, offsetx, offsety, stageMax)
    local preAtts = self._tModel:getTreasureAtts(id, math.max(stage,1),true)
    local afterAtts = self._tModel:getTreasureAtts(id, math.min(stage+1,maxDisStage),true)
    local panelW, panelH = self._attPanel:getContentSize().width/2, self._attPanel:getContentSize().height
    self._panelH = panelH
    local x, y = node:getContentSize().width/2 --[[+ 2 + panelW / 2--]], node:getContentSize().height - panelH-20
    local offsetx, offsety = offsetx or 0, offsety or 0
    local idx = 1
    self._panels = { }
    -- 不反复创建删除节点，做缓存
    if not self._panelCache then
        self._panelCache = {}
    else
        for k,v in pairs(self._panelCache) do
            v:setVisible(false)
        end
    end
    for k, v in pairs(preAtts) do
        local attPanel = self._panelCache[k]
        if not attPanel then
            attPanel = self._attPanel:clone()
            attPanel:setAnchorPoint(cc.p(0.5, 0.5))
            node:addChild(attPanel, 99)
            table.insert(self._panels, attPanel)
            self._panelCache[k] = attPanel
        else
            attPanel:setVisible(true)
        end
        attPanel:setVisible(true)
        if idx % 2 == 1 then
            attPanel:setOpacity(0)
        end
        attPanel:setPosition(x + offsetx, y + offsety -(idx - 1) * panelH)

        local attLeft = attPanel:getChildByFullName("attLeft")
        -- attLeft:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        local attRight = attPanel:getChildByFullName("attRight")
        -- attRight:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        local att2 = attPanel:getChildByFullName("att2")
        att2:setColor(UIUtils.colorTable.ccUIBaseColor9)
        -- att2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

        local name = lang("ARTIFACTDES_PRO_" .. v.attId)
        if not name then
            name = lang("ATTR_" .. v.attId)
        end
        if name then
            name = string.gsub(name, "　", "")
            name = string.gsub(name, " ", "")
        end
        local tail = " "
        if tonumber(v.attId) == 2 or tonumber(v.attId) == 5 or tonumber(v.attId) == 131 then
            tail = "% "
        end
        
        local leftAttStr = v.attNum == math.floor(v.attNum) and tostring(v.attNum) or string.format("%.1f", v.attNum)
        attLeft:setString( leftAttStr .. tail)
        attRight:setString(name )
        if stage < stageMax then
            local rightAttStr = afterAtts[k]["attNum"] == math.floor(afterAtts[k]["attNum"]) and tostring(afterAtts[k]["attNum"]) or string.format("%.1f", afterAtts[k]["attNum"])
            -- local addValue = rightAttStr-leftAttStr
            -- if addValue == 0 then
            --     att2:setString("")
            -- else
                att2:setString("" .. (rightAttStr) .. tail .. "")
            -- end
        else
            -- attRight:setString("已满阶")
            att2:setString("已满阶")
            -- att2:setColor(cc.c3b(255, 255, 255))
            -- att2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        end
        -- att2:setPositionX(attRight:getPositionX() + attRight:getContentSize().width)
        idx = idx + 1
    end
end

-- 2017.1.7 新逻辑
-- 不同阶数下 额外加成
function TreasureDisUpView:generateExAtts( id, stage, node, offsetx, offsety, stageMax )
    self._buffs = self._modelMgr:getModel("TreasureModel"):getDisVolumeBuffMap(id)
    local disData = tab.disTreasure[id]
    local unlockData = disData.unlockaddattr
    local addAttrsData = disData.addattr
    local nextBuffId 
    local fromIdx = 1
    local endIdx  = 1 

    for i,v in ipairs(unlockData) do
        endIdx = i
        if unlockData[i] > stage and not nextBuffId then
            nextBuffId = unlockData[i]
            break
        end 
        fromIdx = i
    end
    if not self._addAttrItems then
        self._addAttrItems = {}
    else
        for k,v in pairs(self._addAttrItems) do
            v:removeFromParent()
        end
        self._addAttrItems = {}
    end
    self:reflashAffectPanel(addAttrsData[fromIdx][1])
    -- 创建额外加成显示
    local rtxTotalHeight = 0
    for i=fromIdx,endIdx do
        local item = self._addAttrItems[i]
        if not item then
            item = ccui.Layout:create()
            item:setBackGroundColorOpacity(0)
            item:setBackGroundColorType(1)
            item:setBackGroundColor(cc.c4b(216, 194, 156, 255))
            -- item:setOpacity(255*(i%2))
            item:setContentSize(290, 30)
            item:setAnchorPoint(0,1)

            node:addChild(item)
            self._addAttrItems[i] = item
        end 

        local addAttrData = addAttrsData[i]
        local volume = addAttrData[1]

        local attr = addAttrData[2]
        local addValue = addAttrData[3]
        local attrDes = lang("ATTR_" .. attr) .. "+" .. addValue 

        local rtxNeedHeight = 0
        local rtxBlank = 10
        local rtxBoardHeight = 50
        if i == fromIdx and (fromIdx ~= endIdx or stage >= unlockData[#unlockData]) then
            local buff = self._buffs[volume]
            local attr3 = buff[3] -- and buff[3] or 0
            local attr6 = buff[6] -- and buff[6] or 0
            attrDes = ""
            if attr3 then
                rtxNeedHeight = rtxNeedHeight+30
                attrDes = attrDes .. "[color=7a5237]" ..  lang("ATTR_3") .. ":[-][color=1ca216]+" .. attr3 .. "[-]"
            end
            if attr6 then
                if attrDes ~= "" then attrDes = attrDes .. "[][-]" end -- 加换行
                rtxNeedHeight = rtxNeedHeight+30
                attrDes = attrDes .. "[color=7a5237]" ..  lang("ATTR_6") .. ":[-][color=1ca216]+" .. attr6 .. "[-]"
            else
                rtxNeedHeight = rtxNeedHeight+30
                if attrDes ~= "" then attrDes = attrDes .. "[][-][]　[-]" end
            end
            -- 
        else
            attrDes = lang("ATTR_" .. attr) .. "+" .. addValue .. " ( 进阶到+" .. unlockData[i] .. "解锁 )"
        end
        -- volume = volumeChange[volume]
        local des -- volume .. "单位兵团" ..
        print(stage, stage == maxDisStage)
        if i == fromIdx and (fromIdx ~= endIdx or stage >= unlockData[#unlockData])then
            des = "[color=fa921a,outlinecolor=3c1e0aff,outlinesize=1]" ..  attrDes .. "[-]"
        elseif stage <= unlockData[i] then
            des = "[color=646464]" ..  attrDes .. "[-]"
        else
            des = "[color=462800]" ..  attrDes .. "[-]"
        end

        if item:getChildByName("rtx") then
            item:getChildByName("rtx"):removeFromParent()
        end
        item:setContentSize(cc.size(290, rtxBoardHeight))
        if (fromIdx ~= endIdx or stage >= unlockData[#unlockData]) then
            item:setPosition(offsetx,offsety-rtxTotalHeight)
        else
            item:setPosition(offsetx,offsety-rtxBoardHeight)
        end
        rtxTotalHeight = rtxTotalHeight + rtxBoardHeight+rtxBlank
        local rtx = RichTextFactory:create(des or "",item:getContentSize().width,rtxNeedHeight)
        rtx:setVerticalSpace(5)
        rtx:formatText()
        -- rtx:setAnchorPoint(cc.p(0,0))
        local w = rtx:getInnerSize().width
        local h = rtx:getInnerSize().height
        rtx:setPosition(w/2,rtxBoardHeight-h/2+2)
        UIUtils:alignRichText(rtx,{vAlign = "bottom",hAlign = "left"})
        rtx:setName("rtx")
        item:addChild(rtx)
    end
end

function TreasureDisUpView:fightValueCallBack(oldValue, newValue)
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
return TreasureDisUpView