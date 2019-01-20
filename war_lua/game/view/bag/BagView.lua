--[[
    Filename:    BagView.lua
    Author:      <libolong@playcrab.com>
    Datetime:    2015-05-27 11:20:25
    Description: File description
--]]

local BagView = class("BagView", BaseView)

function BagView:ctor()
    BagView.super.ctor(self)
    self.initAnimType = 3
end

function BagView:getAsyncRes()
    return 
    {
        {"asset/ui/bag.plist", "asset/ui/bag.png"}
    }
end

function BagView:getBgName()
    return "bg_007.jpg"
end

function BagView:onInit()
    -- 通用动态背景
    self:addAnimBg()
    -- if true then return end
    self._bagItem = nil
    self._selectedItem = nil
    self._itemIdx = 0

    local itemName = self:getUI("bg.layer.itemInfo"):getChildByFullName("itemName")
    if OS_IS_WINDOWS then
        itemName:setPositionY(itemName:getPositionY() + itemName:getContentSize().height * 0.5)
        itemName:setAnchorPoint(0.5, 1)
    end

    -- 增加点击动画
    UIUtils:setTabChangeAnimEnable(self:getUI("bg.layer.tab_all"),140,handler(self, self.tabButtonClick))
    UIUtils:setTabChangeAnimEnable(self:getUI("bg.layer.tab_team"),140,handler(self, self.tabButtonClick))
    UIUtils:setTabChangeAnimEnable(self:getUI("bg.layer.tab_hero"),140,handler(self, self.tabButtonClick))
    UIUtils:setTabChangeAnimEnable(self:getUI("bg.layer.tab_tool"),140,handler(self, self.tabButtonClick))
    UIUtils:setTabChangeAnimEnable(self:getUI("bg.layer.tab_consumables"),140,handler(self, self.tabButtonClick))
    UIUtils:setTabChangeAnimEnable(self:getUI("bg.layer.tab_treasure"),140,handler(self, self.tabButtonClick))

    self._tabEventTarget = {}
    table.insert(self._tabEventTarget, self:getUI("bg.layer.tab_all"))
    table.insert(self._tabEventTarget, self:getUI("bg.layer.tab_team"))
    table.insert(self._tabEventTarget, self:getUI("bg.layer.tab_hero"))
    table.insert(self._tabEventTarget, self:getUI("bg.layer.tab_tool"))
    table.insert(self._tabEventTarget, self:getUI("bg.layer.tab_consumables"))
    table.insert(self._tabEventTarget, self:getUI("bg.layer.tab_treasure"))
    self._animBtns = self._tabEventTarget
    self._playAnimBg = self:getUI("bg.layer.bg1")
    self._playAnimBgOffX = 46
    self._playAnimBgOffY = -28
    local itemAll = self._modelMgr:getModel("ItemModel"):getData()
    print("itemAll and next(itemAll)",itemAll and next(itemAll),"...",itemAll ,"----", next(itemAll))
    if not itemAll  or not next(itemAll) then
        self._notPlayAnimLogo = true
    end

    self._tabPosX = 140
    for k,button in pairs(self._tabEventTarget) do
        button:setTitleFontName(UIUtils.ttfName)
        -- button:setTitleFontSize(32)
        button:setPositionX(self._tabPosX)
        button:setZOrder(-10)
        button:setAnchorPoint(1,0.5)
    end
    self:reorderTabs()

    self._nameBg = self:getUI("bg.layer.itemInfo.nameBg")
    self._scrollView = self:getUI("bg.layer.scrollView")
    -- self._scrollView:setClippingType(1)
    -- self._scrollItem = self:getUI("bg.layer.scrollItem")
    self._infoNode = self:getUI("bg.layer.infoNode")
    self._bg2 = self:getUI("bg.layer.itemInfo.bg2")
    self._noneDes = self:getUI("bg.layer.noneDes")
    -- 精灵动画
    -- spineMgr:createSpine("xinshouyindao", function (spine)
    --     -- spine:setVisible(false)
    --     spine.endCallback = function ()
    --         spine:setAnimation(0, "pingdan", true)
    --     end 
    --     local anim = "pingdan"
    --     spine:setAnimation(0, anim, true)
    --     spine:setPosition(-100, 50)
    --     spine:setScale(0.8)
    --     self._noneDes:addChild(spine,10)
    -- end)
    -- UIUtils:addBlankPrompt( self._noneDes,{x=-100,y=50,des=lang("TIPS_BEIBAO_02")} )
    self._noneDesImg = self:getUI("bg.layer.noneDes.img")
    -- self._noneDesImg:setVisible(false)
    self._noneDesDes = self:getUI("bg.layer.noneDes.des")
    -- self._noneDesDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._noneDesDes:setString(lang("TIPS_BEIBAO_02"))
    -- self._noneIcon = self:getUI("bg.layer.noneDes.noneIcon")
    -- self._noneIcon:setPositionX(-self._noneDes:getContentSize().width/2)
    local itemModel = self._modelMgr:getModel("ItemModel")
    self._itemsData = itemModel:getData()
    self._tableData = itemModel:getData()
    self:addTableView()

    -- self:refreshTabData("tab_all")

    -- local info = self:createLayer("bag.BagItemInfoView")
    -- self._infoNode:addChild(info)
    -- info:setVisible(false)
    -- self._bagInfo = info
    self._bagInfo = self:getUI("bg.layer.itemInfo")
    self._itemInfoBg = self:getUI("bg.layer.itemInfo.itemInfoBg")
    -- self._itemInfoBg:loadTexture("asset/bg/baginfo_bg.jpg")

    self:listenReflash("ItemModel", function( )
        self:onModelReflash()
        self._itemIdx = 0
        local tableOffset = self._tableOffset
        self._tableView:reloadData()
        if tableOffset then
            local maxOffsetY = 420-math.ceil(#self._tableData/4)*102
            maxOffsetY = math.min(0,maxOffsetY)
            tableOffset.y = math.max(maxOffsetY,tableOffset.y)
            self._tableView:setContentOffset(tableOffset)
        end
        if self._tabName then
            self:refreshTabData(self._tabName)
        end
    end)

    self._selectedItemIcon = nil
    self._selFrame = self:getUI("bg.layer.selFrame")
    self._selFrame:setPosition(-13,-11)
    self._selFrame:setContentSize(cc.size(90,90))
    self._selFrame:setAnchorPoint(0,0)
    self._selFrame:setVisible(false)
    self._selFrame:setOpacity(0)

    -- mc1:setVisible(false)
    self._tabEventTarget[1]._appearSelect = true
    self:tabButtonClick(self._tabEventTarget[1],true)
    local isHas ,param = itemModel:isHaveAutoUseMaterial()
    if isHas then
        ScheduleMgr:delayCall(500, self, function( ) 
            local mc1 = mcMgr:createViewMC("beibaobaoxiangkaiqi_beibaobaoxiangkaiqi", false, true ,function()
                self:unlock()
                self._maskLayer:removeFromParent()
                self._maskLayer = nil
                self._serverMgr:sendMsg("ItemServer", "useItems", param or {}, true, {}, function(result)
                    self._viewMgr:showDialog("bag.BagAutoUseDialog",{gifts = result.reward})
                end)
            end)
            if mc1 then
                self._maskLayer = ccui.Layout:create()
                self._maskLayer:setBackGroundColorOpacity(255)
                self._maskLayer:setBackGroundColorType(1)
                self._maskLayer:setBackGroundColor(cc.c3b(0,0,0))
                self._maskLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
                self._maskLayer:setOpacity(210)
                self:addChild(self._maskLayer, 999999)

                self:lock(-1)
                mc1:setName("openBox")
                mc1:setPosition(MAX_SCREEN_WIDTH/2, MAX_SCREEN_HEIGHT/2)
                -- mc1:setScale(0.95)
                self._maskLayer:addChild(mc1)
            end
        end)
    else
        print(" 7777777777 ")
    end


end

function BagView:onBeforeAdd( callback )
    if callback then 
        callback()
    end
    self:reorderTabs()
end

function BagView:reorderTabs( )
    if not self._tabPoses then
        self._tabPoses = {}
        for k,tab in pairs(self._tabEventTarget) do
            local pos = cc.p(tab:getPosition())
            table.insert(self._tabPoses,pos)
        end
        table.sort(self._tabPoses,function ( a,b )
            return a.y > b.y
        end)
    end
    self._enabledTabs = {}
    table.insert(self._enabledTabs,self._tabEventTarget[1])
    local tabIds = {1,4,2,9,3}
    for i,v in ipairs(tabIds) do
        local items = self._modelMgr:getModel("ItemModel"):getItemsByTabId(v)
        -- if v == 4 then
        --     dump(items)
        -- end
        local text = self._tabEventTarget[i+1]:getTitleRenderer()
        -- text:setPositionX(65)
        if #items > 0 then
            table.insert(self._enabledTabs,self._tabEventTarget[i+1])
            -- self._tabEventTarget[i+1]:setBright(true)
            -- self._tabEventTarget[i+1]:setEnabled(true)
            -- self:tabButtonState(self._tabEventTarget[i+1], false,false)
            self._tabEventTarget[i+1]:setVisible(true)
            -- self._tabEventTarget[i+1]:setPosition(self._tabPoses[#self._enabledTabs])
            -- self._tabEventTarget[i+1]:loadTextureNormal("globalBtnUI4_page1_n.png",1)
            -- self._tabEventTarget[i+1]:loadTexturePressed("globalBtnUI4_page1_n.png",1)
            UIUtils:setGray(self._tabEventTarget[i+1],false)
            UIUtils:setTabChangeAnimEnable(self._tabEventTarget[i+1],140,handler(self, self.tabButtonClick))
        else

            -- self._tabEventTarget[i+1]:setVisible(false)
            -- self._tabEventTarget[i+1]:setBright(false)
            -- self._tabEventTarget[i+1]:loadTextureNormal("globalBtnUI4_page1_n.png",1)
            -- self._tabEventTarget[i+1]:loadTexturePressed("globalBtnUI4_page1_n.png",1)
            UIUtils:setGray(self._tabEventTarget[i+1],true)
            self._tabEventTarget[i+1]:setEnabled(true)
            local text = self._tabEventTarget[i+1]:getTitleRenderer()
            text:disableEffect()
            self._tabEventTarget[i+1]:setTitleColor(UIUtils.colorTable.ccUITabColor1)
            -- text:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
            self:tabButtonState(self._tabEventTarget[i+1], false,true)
            self:registerClickEvent(self._tabEventTarget[i+1],function ( )
                self._viewMgr:showTip(lang("TIPS_BEIBAO_03"))
            end)
        end
        -- 宝物页签做隐藏
        -- if self._tabEventTarget[i+1]:getName() == "tab_treasure" then
        --     local isOpen = SystemUtils["enableTreasure"]()
        --     if not isOpen then
        --         self._tabEventTarget[i+1]:setVisible(false)
        --     end
        -- end
    end

end

function BagView:onModelReflash()
    if self._selectedItem ~= nil
    and self._bagInfo ~= nil then 
        local itemModel = self._modelMgr:getModel("ItemModel")
        local item,icount = itemModel:getItemsById(self._selectedItem.goodsId)
        if icount <= 0 then
            --self._tableOffset = nil
            -- [[5.0需求使用完物品默认下一个 
            local allCount = #self._tableData
            local curItemIdx = self._itemIdx
            local nextCellId = 0
            local nextItemIdx = 0
            print(self._itemIdx,"-----------  count ----------",allCount,"-====",self._cellIdx)
            if curItemIdx <= 4 then
                self._tableOffset = nil
            end
            if curItemIdx >= allCount then
                self._tableOffset = nil
            else
                nextCellId = math.floor((curItemIdx-1)/4)
                nextItemIdx = (curItemIdx-1)%4
            end
            --]]
            -- local mc1 = mcMgr:createViewMC("wupinxiaoshi_bagselect", false, true)
            -- mc1:setName("anim")
            -- mc1:setPosition(50, 50)
            -- mc1:setScale(0.95)
            ScheduleMgr:delayCall(1, self, function( ) 
            -- mc1:addCallbackAtFrame(8,function( )
                if self.refreshTabData then
                    local curData = self:refreshTabData(self._tabName)
                    -- sender:removeFromParent()
                    self:refreshBagInfo(curData[curItemIdx] or curData[1])
                    if curData ~= nil then
                        local curData = self:refreshTabData(self._tabName)
                        if self._tableView:cellAtIndex(nextCellId) and
                           self._tableView:cellAtIndex(nextCellId):getChildByFullName("cellItem" .. nextItemIdx) 
                        then
                            local item = self._tableView:cellAtIndex(nextCellId):getChildByFullName("cellItem" .. nextItemIdx) 
                            local iData  = curData[curItemIdx] or curData[1]
                            self:touchItemEnd(iData,item)
                        elseif self._tableView:cellAtIndex(0) then
                            local item = self._tableView:cellAtIndex(0):getChildByFullName("cellItem0")
                            local iData  = curData[1]
                            self:touchItemEnd(iData,item)
                        end
                    end 
                    self:reorderTabs()
                end
                -- mc1:removeFromParent()
            -- end)
            end)
            -- if self._selectedItemIcon and mc1 then
            --     self._selectedItemIcon:addChild(mc1, 1) 
            -- end
        else
            self:setBagInfoNodesVisible(false)
            self:refreshBagInfo(item[1])
            if self._tableView:cellAtIndex(0) and not tolua.isnull(self._tableView:cellAtIndex(0)) then
                local item = self._tableView:cellAtIndex(0):getChildByFullName(self._selectedItem._itemName or "cellItem0")
                local iData  = self._selectedItem
                self:touchItemEnd(iData,item)
            end
        end
    end
end

--[[
--! @function tabButtonClick
--! @desc 选项卡按钮点击事件处理
--! @param sender table 操作对象
--! @return 
--]]
function BagView:tabButtonClick(sender,noAudio)
    self._tableOffset = nil
    if sender == nil then 
        return 
    end
    if not noAudio then 
        audioMgr:playSound("Tab")
    end
    self:setBagInfoNodesVisible(false)
    for k,v in pairs(self._enabledTabs) do
        if v ~= sender then 
            local text = v:getTitleRenderer()
            v:setTitleColor(UIUtils.colorTable.ccUITabColor1)
            text:disableEffect()
            -- text:setPositionX(85)
            v:setScaleAnim(false)
            v:stopAllActions()
            v:setScale(1)
            if v:getChildByName("changeBtnStatusAnim") then 
                v:getChildByName("changeBtnStatusAnim"):removeFromParent()
            end
            v:setZOrder(-10)
            self:tabButtonState(v, false)
        end
    end
    if self._preBtn then
        UIUtils:tabChangeAnim(self._preBtn,nil,true)
    end
    
    -- text:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    -- 按钮动画
    self._preBtn = sender
    sender:stopAllActions()
    sender:setZOrder(99)
    UIUtils:tabChangeAnim(sender,function( )
        local text = sender:getTitleRenderer()
        text:disableEffect()
        -- text:setPositionX(85)
        sender:setTitleColor(UIUtils.colorTable.ccUITabColor2)
        self:tabButtonState(sender, true)
    end)
    local data = self:refreshTabData(sender:getName())
    self:refreshBagInfo(data[1])
    local item = self._tableView:cellAtIndex(0):getChildByFullName("cellItem0")
    local iData  = data[1]
    self:touchItemEnd(iData,item)

end

-- 按钮按下动画
function BagView:tabTouchAnimBegin(sender)
    sender:runAction(cc.MoveTo:create(0.1,cc.p(self._tabPosX-5,sender:getPositionY())))
end

-- 按钮按下动画
function BagView:tabTouchAnimOut(sender)
    sender:runAction(cc.MoveTo:create(0.1,cc.p(self._tabPosX,sender:getPositionY())))
end
--[[
--! @function refreshTabData
--! @desc 更新tab界面
--! @param name 字符串 tab名称
--! @return 
--]]
function BagView:refreshTabData(name)
    local data = {}
    local itemModel = self._modelMgr:getModel("ItemModel")

    if name == "tab_all" then
        data = itemModel:getData()
    elseif name == "tab_team" then
        data = itemModel:getTeamSouls()
    elseif name == "tab_hero" then
        data = itemModel:getHeroSouls()
    elseif name == "tab_tool" then
        data = itemModel:getMaterials()
    elseif name == "tab_consumables" then
        data = itemModel:getConsumables()
    elseif name == "tab_treasure" then
        data = itemModel:getTreasures()
    end
    self._tabName = name
    self:reflashUI(data)
    return data
end

--[[
--! @function tabButtonState
--! @desc 按钮状态切换
--! @param sender table 操作对象
--! @param isSelected bool 是否选中状态
--! @return 
--]]
function BagView:tabButtonState(sender, isSelected,isDisabled)
    -- local tabtxt01 = sender:getChildByFullName("tabtxt_01")
    -- local tabtxt02 = sender:getChildByFullName("tabtxt_02")
    -- local tabtxt03 = sender:getChildByFullName("tabtxt_03")

    sender:setBright(not isSelected)
    sender:setEnabled(not isSelected)
    -- sender:setZOrder(isSelect and 99 or -1)
    -- tabtxt01:setVisible(isSelected)
    -- tabtxt02:setVisible(not isSelected)
    -- tabtxt03:setVisible(false)
    -- if isDisabled and tabtxt03 then
        -- tabtxt03:setVisible(false)
        -- tabtxt01:setVisible(false)
        -- tabtxt02:setVisible(false)
    -- end
    
end


--[[
--! @function touchItemEnd
--! @desc 点击道具结束
--! @return 
--]]
function BagView:touchItemEnd(info,item)
    -- dump(self._selectedItem)
    if not info or not item or tolua.isnull(item) then
        return 
    end
    self._selectedItem = info
    local lastIcon 
    local scaleNum = (93/item:getContentSize().width)
    -- runAction
    if not tolua.isnull(self._selectedItemIcon) then
        lastIcon = self._selectedItemIcon:getParent()  
        -- scaleNum = lastIcon:getScale()      
        self._selectedItemIcon:removeFromParent()
    end
    self._selectedItemIcon = self._selFrame:clone()
    self._selectedItemIcon:setName("select")
    local mc1 = mcMgr:createViewMC("xuanzhong_itemeffectcollection", true, false)
    if mc1 then
        mc1:setName("anim")
        mc1:setPosition(60, 57)
        mc1:setScale(0.95)
        self._selectedItemIcon:addChild(mc1, 1)
        self._selectedItemIcon:setOpacity(0)
    end
    self._selectedItemIcon:setVisible(true)
    -- item:setScale(5)
    -- item:setColor(cc.c4b(255, 0, 0, 255))
    item:addChild(self._selectedItemIcon,7)
    
    -- if item._itemName then
        self._selectedItem._itemName = item._itemName or self._selectedItem._itemName
    -- end    
    self._inScrolling = false
    -- 如果重复点击同一个图标 不刷新界面
    if self._itemIdx == item._indexNum then return end 
    self._itemIdx = item._indexNum or 1
    self._cellIdx = item._cellIdx
    print("cellIdx...",self._cellIdx)
    self:refreshBagInfo(info)
    -- 如果是可使用物品，设置model里是否通知过状态
    if item and item._isCanUse then 
        if not self._modelMgr:getModel("ItemModel"):isItemHadNoticed( info.goodsId ) then
            self._modelMgr:getModel("ItemModel"):setItemNoticed( info.goodsId )
        end
    end
    -- 如果上一个是可使用物品，重新设置红点
    if lastIcon and lastIcon._isCanUse then 
        local tip = lastIcon:getChildByFullName("iconColor") and lastIcon:getChildByFullName("iconColor"):getChildByFullName("tip")
        if tip then 
            tip:setVisible(false)
        end
    --     lastIcon:stopAllActions()
    --     lastIcon:setScale(scaleNum)
    --     local repeatAction = cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(1,scaleNum - 0.05), cc.ScaleTo:create(1,scaleNum)))
    --     lastIcon:runAction(repeatAction)
    end

end

--[[
--! @function refreshBagInfo
--! @desc 点击刷新道具信息
--! @param info table 道具信息
--! @return 
--]]
function BagView:refreshBagInfo(data)
    -- if self._bagInfo == nil then
    --     local info = self:creat("bag.BagItemInfoView")
    --     self._infoNode:addChild(info)
    --     self._bagInfo = info
    -- end
    
    if data == nil then 
        self:setBagInfoNodesVisible(false)
        if not tolua.isnull(self._selectedItemIcon) then
            self._selectedItemIcon:removeFromParent()
        end
        self._infoNode:setVisible(false)
        self._bg2:setVisible(false)
        self._noneDes:setVisible(true)
        -- if not self._noneDes:getChildByName("jingling") then
        --     UIUtils:addBlankPrompt( self._noneDes,{x=-100,y=50,des=lang("TIPS_BEIBAO_02")} )
        -- end
        self._none = true
        -- self:reorderTabs()
        local curData = self:refreshTabData(self._tabName)
        if next(curData) == nil and self._tabName ~= "tab_all" then
            self._tableView:reloadData()
            self:tabButtonClick(self._tabEventTarget[1],true)
            local curData = self:refreshTabData(self._tabName)
            local item = self._tableView:cellAtIndex(0):getChildByFullName("cellItem0")
            item._itemName = "cellItem0"
            local iData  = curData[1]
            self:touchItemEnd(iData,item)
        end
        return
    else
        self._infoNode:setVisible(true)
        self._bg2:setVisible(true)
        self._noneDes:setVisible(false)
        self._none = false
    end
    self:setBagInfoNodesVisible(true)
    local bagInfo = self._bagInfo
    -- self._bagInfo:reflashUI(info)
    -- 移除bagiteminfo
    local itemName = bagInfo:getChildByFullName("itemName")
    itemName:setFontName(UIUtils.ttfName)
    -- itemName:setColor(UIUtils.colorTable.ccUIBaseColor2)
    -- itemName:setColor(UIUtils.colorTable["ccUIBaseColor" .. tab.tool[data.goodsId].color])
    -- itemName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    -- UIUtils:setTitleFormat(itemName,3)

    -- local itemCount = bagInfo:getChildByFullName("itemCount")
    -- itemCount:setColor(UIUtils.colorTable.ccUIBaseColor1)
    -- itemCount:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    -- local itemCountDes = bagInfo:getChildByFullName("itemCountDes")

    local itemDesc = bagInfo:getChildByFullName("itemDesc")
    -- local itemDescLabel = itemDesc:getVirtualRenderer()
    -- itemDescLabel:setMaxLineWidth(280)
    -- itemDescLabel:setLineHeight(25)
    itemDesc:setLineBreakWithoutSpace(true)

    local itemIcon = bagInfo:getChildByFullName("iconNode")
    local flexoBtn = bagInfo:getChildByFullName("flexoBtn")
-------------------------------------------
    local toolD = tab.tool[data.goodsId]
    local name = lang(toolD["name"])
    local num = data["num"]
    local desc = lang(toolD["des"])
    if toolD.tabId == 1 --[[兵团碎片]] then
        local teamId = tonumber(string.sub(tostring(data.goodsId),2,string.len(tostring(data.goodsId))))
        local hadTeam = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(teamId)
        if hadTeam and lang(toolD.des .. "_1") then
            desc = lang(toolD.des .. "_1")
        end
    end

    local numTail = ""
    if toolD.typeId == 6 then
        local heroId = tonumber(string.sub(tostring(data.goodsId),2,string.len(tostring(data.goodsId))))
        heroD = tab.hero[heroId]
        local heroData = self._modelMgr:getModel("HeroModel"):getHeroData(heroId)
        if heroData then
            desc = lang(toolD["adddes"]) or desc
            desc = string.gsub(desc,"%b{}",function( )
                if heroD.starcost and heroD.starcost[heroData.star] and heroD.starcost[heroData.star][1] and heroD.starcost[heroData.star][1][3] then
                    numTail =  "/" .. heroD.starcost[heroData.star][1][3]
                    return heroD.starcost[heroData.star][1][3]
                else
                    if heroD.starcost[heroData.star] then
                        numTail = "/" .. heroD.unlockcost[3]
                    end
                    return heroD.unlockcost[3]
                end
            end)
        else  -- 没有英雄及零星
            numTail = "/" .. heroD.unlockcost[3]
        end
    end
    if toolD.speciallDes then
        local level = toolD.speciallDes
        local userlvl = self._modelMgr:getModel("UserModel"):getData().lvl
        if level > userlvl then
            desc = lang(toolD.des .. "_1")
        end
    end

    if OS_IS_WINDOWS then
        itemName:setString(name .. "\n[" .. toolD.id .. "]")
    else
        itemName:setString(name)
    end
    local bgWidth = itemName:getContentSize().width
    bgWidth =  bgWidth + 100 -- or 210
    local bgColor = ItemUtils.findResIconColor(data.goodsId,num) --tab.tool[data.goodsId].color
    self._nameBg:loadTexture("globalImageUI12_tquality".. bgColor  ..".png",1)
    -- self._nameBg:setContentSize(math.min(bgWidth,250),self._nameBg:getContentSize().height)
    -- if toolD.color then
    --     itemName:setColor(UIUtils.colorTable["ccColorQuality" .. toolD.color])
    -- end
    -- itemName:disableEffect()
    -- itemCount:setString("".. ItemUtils.formatItemCount(num) .. numTail)
    -- itemCount:setFontSize(18)
    -- itemCount:disableEffect()
    -- itemCountDes:disableEffect()
    -- itemCountDes:setPositionX(itemCount:getPositionX()+itemCount:getContentSize().width)
    -- itemIcon:loadTexture(iconId,1)
    itemDesc:setString(desc)
    itemDesc:disableEffect()
    itemDesc:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    -- iconUtils 创建新的icon
    itemIcon:removeAllChildren()
    local icon = IconUtils:createItemIconById({itemId = data.goodsId,itemData = toolD,num=num,eventStyle = 0,effect = true})
    -- icon:setContentSize(cc.size(94, 94))
    icon:setPosition(2,4)
    -- icon:setScale(96/icon:getContentSize().width)
    itemIcon:addChild(icon)

    -- [[ 等级限制逻辑 by guojun 2017.1.14
    local limitTipDes
    if toolD.openLevel then
        local userlvl = self._modelMgr:getModel("UserModel"):getData().lvl
        if userlvl < toolD.openLevel then
            limitTipDes = lang("TOOL_COMMON_LV")
            limitTipDes = string.gsub(limitTipDes,"{$openLevel}",toolD.openLevel)
        end
    end
    --]]

    -- [[  随机红包使用限制，
        if toolD.typeId == 11 then
            local userData = self._modelMgr:getModel("UserModel"):getData()
            local roleGuild = userData.roleGuild
            if not roleGuild then --没有有联盟
                limitTipDes = "请先加入联盟"
            end
        end
    -- ]]

    local butType = tonumber(toolD["butType"])
    -- 默认显示
    flexoBtn:setTitleText("使用")
    local vipLimitFuc = function()
        local goodsId = data["goodsId"]
        print("==========goodsId=======",goodsId)
        if tab:ToolGift(goodsId) then
            local openVipLv = tab:ToolGift(goodsId)["openVipLv"]
            local vip = self._modelMgr:getModel("VipModel"):getData().level
            if openVipLv then
                if tonumber(openVipLv) > tonumber(vip) then
                    self._viewMgr:showTip("VIP等级不足,无法打开礼包")
                    return true
                end
            end
        end
        return false
    end

    if butType == 0 or butType == 5 then-- 获取途径
        flexoBtn:setTitleText("来源")
        self:registerClickEvent(flexoBtn, function ()
            -- local approach = toolD["approach"]
            -- if approach then
            -- else
            --     self._viewMgr:showTip("没有配获取路径")
            -- end
            -- self._viewMgr:showDialog("bag.DialogAccessTo", data, true)
             DialogUtils.showItemApproach(data.goodsId)
        end)
    elseif num == 1 then
        self:registerClickEvent(flexoBtn, function ()            
            if limitTipDes then
                self._viewMgr:showTip(limitTipDes)
                return 
            end
            if vipLimitFuc() then
                return 
            end
            self:useOneItem(data)
        end)    
    elseif butType == 1 then -- 批量使用 从1
        self:registerClickEvent(flexoBtn, function ()
            if limitTipDes then
                self._viewMgr:showTip(limitTipDes)
                return 
            end
            if vipLimitFuc() then
                return 
            end
            self._viewMgr:showDialog("bag.DialogBatchUse",{data=data,useThreshold = "one"},true)
        end)   
    elseif butType == 2 or butType == 3 then -- 批量使用 从上限
        self:registerClickEvent(flexoBtn, function ()
            if limitTipDes then
                self._viewMgr:showTip(limitTipDes)
                return 
            end
            if vipLimitFuc() then
                return 
            end
            self._viewMgr:showDialog("bag.DialogBatchUse",{data=data,useThreshold = "max"},true)
        end)
    -- elseif butType == 3 then -- 使用
    --     self:registerClickEvent(flexoBtn, function ()
    --         self._viewMgr:showDialog("bag.DialogBatchUse",data,true)
    --     end)
    end
end

function BagView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{title = "globalTitleUI_bag.png",titleTxt = "背包"})
end

function BagView:reflashUI(data)
    self._tableData = data
    local tableOffset = self._tableOffset
    self._tableView:reloadData()
    if tableOffset then
        local maxOffsetY = 420-math.ceil(#self._tableData/4)*102
        maxOffsetY = math.min(0,maxOffsetY)
        tableOffset.y = math.max(maxOffsetY,tableOffset.y)
        self._tableView:setContentOffset(tableOffset)
    end
end

--[[
用tableview实现
--]]
function BagView:addTableView( )
    self._tableNode = self:getUI("bg.layer.itemInfo.tableNode")
    local tableView = cc.TableView:create(cc.size(420, 420))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setAnchorPoint(0,0)
    tableView:setPosition(0 ,8)
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    self._tableNode:addChild(tableView,999)
    tableView:registerScriptHandler(function( view ) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(function( view ) return self:scrollViewDidZoom(view) end ,cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(function ( table,cell ) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(function( table,index ) return self:cellSizeForTable(table,index) end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function ( table,index ) return self:tableCellAtIndex(table,index) end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function ( table ) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()
    UIUtils:ccScrollViewAddScrollBar(tableView, cc.c3b(169, 124, 75), cc.c3b(64, 32, 12), -12, 6)
    self._tableView = tableView
    self._inScrolling = false
end

function BagView:scrollViewDidScroll(view)
    self._inScrolling = view:isDragging()
    -- if self._inScrolling then
        self._tableOffset = view:getContentOffset()
    -- end
    UIUtils:ccScrollViewUpdateScrollBar(view)
end

function BagView:scrollViewDidZoom(view)
end

function BagView:tableCellTouched(table,cell)
end

function BagView:cellSizeForTable(table,idx) 
    return 102,428
end

function BagView:tableCellAtIndex(table, idx)
    local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
    end
    -- cell:removeAllChildren()
    local row = idx*4
    for i=0,3 do
        local item = cell:getChildByName("cellItem".. i)
        local isNewCreateItem = true
        if i+row+1>#self._tableData then
            if item then
                item:removeFromParent()
            end
            item = self:createGrid()
            item._isGrid = true
        else
            if item and item._isGrid then
                item:removeFromParent()
                item = nil
            end
            if not item then
                item = self:createItem(self._tableData[i+row+1])
            else
                isNewCreateItem = false
                item = self:createItem(self._tableData[i+row+1],item)
            end
            item._indexNum = i+row+1
            item._isGrid = false
        end
        -- item:setScale(0.95)
        if self._none then
            item:setVisible(false)
        end
        item:setPosition(i*100+55,52)
        item:setName("cellItem".. i)
        item._itemName = "cellItem".. i
        item._cellIdx = idx
        if isNewCreateItem then
            cell:addChild(item)
        end
        if self._selectedItem and self._tableData[i+row+1] and self._selectedItem.goodsId == self._tableData[i+row+1].goodsId then
            if not item:getChildByFullName("select") then
                self._selectedItemIcon = self._selFrame:clone()
                self._selectedItemIcon:setName("select")
                local mc1 = mcMgr:createViewMC("xuanzhong_itemeffectcollection", true, false)
                if mc1 then
                    mc1:setName("anim")
                    mc1:setPosition(62, 56)
                    mc1:setScale(0.95)
                    self._selectedItemIcon:addChild(mc1, 1)
                    self._selectedItemIcon:setOpacity(0)
                end
                self._selectedItemIcon:setVisible(true)
                item:addChild(self._selectedItemIcon,7)
            else
                item:getChildByFullName("select"):setVisible(true)
            end
        else
            if item:getChildByFullName("select") then
                item:getChildByFullName("select"):removeFromParent()
            end
        end
    end 
    return cell
end

function BagView:numberOfCellsInTableView(table)
   local itemRow = math.ceil(#self._tableData/4)
    if itemRow < 4 then
        itemRow = 4
    end
    return itemRow
end

function BagView:createGrid( )
    local bagGrid = ccui.Widget:create()
    bagGrid:setContentSize(cc.size(98,98))
    bagGrid:setAnchorPoint(0.5,0.5)
    local bagGridFrame = ccui.ImageView:create()
    bagGridFrame:loadTexture("globalImageUI4_squality1.png", 1)
    bagGridFrame:setName("bagGridFrame")
    bagGridFrame:setContentSize(cc.size(107, 107))
    bagGridFrame:setAnchorPoint(0,0)
    bagGridFrame:setPosition(3,3)
    bagGrid:addChild(bagGridFrame,1)
    local bagGridBg = ccui.ImageView:create()
    bagGridBg:loadTexture("globalImageUI4_itemBg1.png", 1)
    bagGridBg:setName("bagGridBg")
    bagGridBg:ignoreContentAdaptWithSize(false)
    bagGridBg:setContentSize(cc.size(85, 85))
    bagGridBg:setAnchorPoint(0.5,0.5)
    -- bagGridBg
    bagGridBg:setPosition(47,47)
    bagGrid:addChild(bagGridBg,-1)
    -- 缩放
    bagGrid:setScale(1.02)
    return bagGrid
end

-- 创建物品格子
-- 参数 data     道具信息 
-- 参数 dirtItem 旧的格子
function BagView:createItem(data,dirtItem)
    local item
    local function itemCallback( )
        if not self._inScrolling then
            self:touchItemEnd(data,item)
        else
            self._inScrolling = false
        end
    end

    local toolD = tab.tool[data.goodsId]
    if not dirtItem then
        item = IconUtils:createItemIconById({itemId = data.goodsId,num = data.num,itemData = toolD,effect = true,eventStyle = 3,clickCallback = itemCallback})-- self._scrollItem:clone()
    else
        item = dirtItem
        item:stopAllActions()
        IconUtils:updateItemIconByView(item,{itemId = data.goodsId,num = data.num,itemData = toolD,effect = true,eventStyle = 3,clickCallback = itemCallback})
    end
    -- item:setContentSize(cc.size(98, 98))
    item:setScale(93/item:getContentSize().width)   -- 暂时处理
    item:setVisible(true)
    item:setSwallowTouches(false)
    -- local tmpTip = item:getChildByName("tip")
    -- if tmpTip then
    --     tmpTip:removeFromParent()
    -- end
    local team = self._modelMgr:getModel("TeamModel")
    local idata,icount = team:getTeamAndIndexById(toolD.teamId)
    --能否拼合
    if icount <= 0 and data.typeId == ItemUtils.ITEM_KIND_TEAMSOUL and toolD.teamId then
        local teamD = tab.team[toolD.teamId]
        local starlevel = teamD["starlevel"]
        local starD = tab.star[starlevel]
        local combReq = tonumber(starD["sum"])

        -- if data.num >= combReq then
        --     local tip = ccui.ImageView:create()
        --     tip:loadTexture("globalImageUI_bag_keyihecheng.png", 1)
        --     tip:setPosition(cc.p(86,86))
        --     tip:setName("tip")
        --     item:addChild(tip,16)
        -- end
    end
    local teamToUp
    local isExpBottle = (tonumber(data.goodsId) == 30201 or tonumber(data.goodsId) == 30202 or tonumber(data.goodsId) == 30203 )
    if toolD.pres and toolD.pres == 2 and isExpBottle then
        teamToUp = self._modelMgr:getModel("UserModel"):getData().texp < 50000
    end
    local tip = item:getChildByFullName("tip")
    local hadNoticed = self._modelMgr:getModel("ItemModel"):isItemHadNoticed(data.goodsId)
    if ((toolD.pres and toolD.pres == 1) or teamToUp) and not hadNoticed then
        if not tip then            
            -- local mc = mcMgr:createViewMC("wupinkeshiyongxingxing_itemeffectcollection", true,false)
            -- mc:setPosition(54,54)
            -- mc:setName("tip")
            tip = ccui.ImageView:create()
            tip:loadTexture("globalImageUI_bag_keyihecheng.png", 1)
            tip:setPosition(85,85)--node:getContentSize().width,node:getContentSize().height))
            tip:setName("tip")
            tip:setScale(0.8)
            item:addChild(tip,99)            
        else
            tip:setVisible(true)
        end
        item._isCanUse = true
        -- item:stopAllActions()
        -- local scaleNum = item:getScale()
        -- local repeatAction = cc.RepeatForever:create(cc.Sequence:create( cc.ScaleTo:create(1,scaleNum - 0.05), cc.ScaleTo:create(1,scaleNum)))
        -- item:runAction(repeatAction)
    else
        if tip then
            tip:setVisible(false)
        end
    end
    item:setAnchorPoint(0.5,0.5)
    if isExpBottle and not teamToUp then
        if item:getChildByFullName("iconColor"):getChildByName("tip") then
            item:getChildByFullName("iconColor"):getChildByName("tip"):setVisible(false)
        end
    end
    return item
end

function BagView:useOneItem(data)
    if data["num"] <= 0 then 
        return 
    end
    self._itemData = data
    local giftData = tab.toolGift[self._itemData.goodsId] or tab.equipmentBox[self._itemData.goodsId]
    if giftData then
        local needLvl = giftData.openLv or giftData.openLevel
        if needLvl then
            local userLevel = self._modelMgr:getModel("UserModel"):getData().lvl 
            if needLvl > userLevel then
                self._viewMgr:showTip("等级" .. needLvl .."可使用")
                return 
            end
        end
    end
    -- [[体力超3000不让用体力药水 by guojun 2016.8.23 
    local physicalBottles = {
        [30211] = 30211,
        [30212] = 30212,
        [30213] = 30213,
    }
    if physicalBottles[self._itemData.goodsId] then
        local physcal = self._modelMgr:getModel("UserModel"):getData().physcal 
        if physcal >= 3000 then
            self._viewMgr:showTip(lang("TIPS_BEIBAO_04"))
            return 
        end
    end
    --]]
    local param = {goodsId = self._itemData.goodsId, goodsNum = 1,extraParams=nil}
    local toolD = tab:Tool(self._itemData.goodsId)
    
    -- [[ 新增逻辑 N选一 
    local isNselectOne = giftData and giftData["type"] == 4
    if isNselectOne then
        local showGift = {}
        if giftData.giftContain then 
            showGift = clone(giftData.giftContain)
            for k,v in pairs(showGift) do
                if v[4] then
                    v[4] = nil
                end
            end
        end
        self._viewMgr:showDialog("global.GlobalSelectAwardDialog", {gift = showGift,callback = function(selectedIndex)
            param.extraParams = json.encode({cId = selectedIndex})
            self:sendUseItemMsg(param)
        end})
    elseif toolD.typeId == 11 then
        local idList = {}
        table.insert(idList,self._itemData.goodsId)
        self:userRandRed(idList)
    else
        self:sendUseItemMsg(param)
    end
    --]]
end

function BagView:userRandRed(idList)
    self._viewMgr:showDialog("guild.dialog.GuildDropRedDialog",idList,true)
end

-- 抽离出 发送使用物品接口
function BagView:sendUseItemMsg( param )
    local preHave = {}
    for k,v in pairs(self._modelMgr:getModel("UserModel"):getData()) do
        if type(v) == "number" then
            preHave[k] = v 
        end
    end
    self._serverMgr:sendMsg("ItemServer", "useItem", param or {}, true, {}, function(result) 
        -- self:upgradeBag(result)
        -- dump(result)

        if result.reward then
            local giftData = tab:ToolGift(param.goodsId) or {}
            local gifts = giftData.giftContain            
            -- 头像框 
            if giftData.type == 5 then
                local notChange = false
                for k,v in pairs(result.reward) do
                    if v[1] == "avatarFrame" or v["type"] == "avatarFrame" 
                        or v[1] == "avatar" or v["type"] == "avatar" then
                        notChange = true
                    end
                end
                if notChange and table.nums(result.reward) == 1 then
                    DialogUtils.showAvatarFrameGet( {gifts = gifts}) 
                else
                    DialogUtils.showGiftGet( {gifts = result.reward,notPop=true})
                end    
            else
				if giftData.openType and giftData.openType==1 then
					DialogUtils.showGiftGet( {gifts = result.reward} )
				else
					DialogUtils.showGiftGet( {gifts = result.reward,notPop=true})
				end            
            end
            -- self._viewMgr:showTip("使用礼包成功")
        elseif tab.toolGift[param.goodsId] then
            local giftData = tab:ToolGift(param.goodsId) or {}
            local gifts = giftData.giftContain
            -- 头像框 
            if giftData.type == 5 then
                DialogUtils.showAvatarFrameGet( {gifts = gifts})   
            else
                DialogUtils.showGiftGet( {gifts = gifts,notPop=true})                
            end
            -- self._viewMgr:showTip("使用礼包成功")
        else
            -- self._viewMgr:showTip("使用成功")
            local goodsData = tab:Tool(param.goodsId)
            if goodsData and goodsData.typeId == 102 then
                DialogUtils.showSkinGetDialog( {skinId = tonumber("2" .. param.goodsId)})
            elseif goodsData and goodsData.typeId == 105 then
                local skinId = string.sub(tostring(param.goodsId), 2, 20)
                DialogUtils.showTeamSkinGetDialog({skinId = tonumber(skinId)})
            else
                local items = {}
                local uniqueTab = {}
                if (result.d["payGem"] and not uniqueTab["payGem"]) or (result.d["freeGem"] and not uniqueTab["freeGem"])  then
                    result.d["payGem"] = nil
                    if result.d["payGem"] then
                        uniqueTab["payGem"] = true 
                    end
                    if result.d["freeGem"] then
                        uniqueTab["freeGem"] = true 
                    end
                    result.d["freeGem"] = nil
                    local item = {"gem",0}
                    table.insert(item,self._modelMgr:getModel("UserModel"):getData().gem-preHave["gem"])
                    table.insert(items,item)
                elseif IconUtils.iconIdMap[k] and not uniqueTab[IconUtils.iconIdMap[k]] then
                    local item = {"tool",IconUtils.iconIdMap[k]}
                    table.insert(item,v-preHave[k])
                    table.insert(items,item)
                    uniqueTab[IconUtils.iconIdMap[k]] = true
                end
                if #items > 0 then
                    DialogUtils.showGiftGet( {gifts = items,notPop=true})
                end
            end
        end
    end)
end

-- 设置 bagInfo上的显示 用于替换setVisible方法
function BagView:setBagInfoNodesVisible( isClear )
    local children = self._bagInfo:getChildren()
    for i,v in ipairs(children) do
        v:setVisible(isClear)
    end
    -- 放在循环外单独设置，提高缓存命中率
    local decoratePanel = self._bagInfo:getChildByName("decoratePanel")
    if decoratePanel then 
        decoratePanel:setVisible(true)
    end
end

-- 用通用背包界面来调弹出动画
-- 按钮动画实现
function BagView:tabChangeAnim( btn,callback,isReverse )
    btn:setEnabled(false)
    local clippNode = btn:getChildByName("changeBtnStatusAnim")
    if clippNode then
        clippNode:removeFromParent()
    end
    clippNode = cc.ClippingNode:create()
    clippNode:setContentSize(btn:getContentSize())
    clippNode:setName("changeBtnStatusAnim")
    

    -- reverse 
    local maskPos = -100
    local dir = 1
    local cloneImgName = "globalBtnUI4_page1_p.png"
    local color = UIUtils.colorTable.ccUITabColor2
    if isReverse then
        maskPos = 0
        dir = -1
        btn:setEnabled(true)
        color = UIUtils.colorTable.ccUITabColor1
    end
    local btnClone = btn:clone()
    btnClone:loadTextureNormal(cloneImgName,1)
    local text = btnClone:getTitleRenderer()
    btnClone:setTitleColor(UIUtils.colorTable.ccUITabColor2)
    btnClone:setScale(1)
    btnClone:setAnchorPoint(0,0)
    btnClone:setPosition(-10,0)
    clippNode:addChild(btnClone)
    
    local mask = cc.Sprite:createWithSpriteFrameName("globalPanelUI7_zhezhao.png")
    mask:setContentSize(btn:getContentSize())
    if isReverse then
        mask:setContentSize(btnClone:getContentSize())
    end
    mask:setAnchorPoint(0,0)
    mask:setPosition(maskPos,0)
    clippNode:setStencil(mask)
    clippNode:setAlphaThreshold(0.05)

    clippNode:runAction(cc.Sequence:create(
        cc.MoveBy:create(0.15,cc.p(100*dir,0)),
        cc.CallFunc:create(function( )
            if callback then 
                callback()
            end
            if btn then
                btn:setPositionX(140)
            end
            clippNode:removeFromParent()
        end)
    ))
    btnClone:runAction(cc.MoveBy:create(0.15,cc.p(-100*dir+10,0)))
    btn:addChild(clippNode,99)
end

return BagView