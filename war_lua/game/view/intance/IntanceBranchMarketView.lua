--[[
    Filename:    IntanceBranchMarketView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2017-04-17 21:13:36
    Description: File description
--]]


local IntanceBranchMarketView = class("IntanceBranchMarketView", BasePopView)


function IntanceBranchMarketView:ctor()
    IntanceBranchMarketView.super.ctor(self)
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("intance.IntanceBranchMarketView")
        elseif eventType == "enter" then 
        end
    end)
end

function IntanceBranchMarketView:reflashUI(inData)
    self._touchTime = socket.gettime()
    self._data = inData
    local branchId = inData.branchId
    local stageId = inData.stageId

    local titleLab = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(titleLab, 1)
    
    self:registerClickEventByName("bg.closeBtn", function()
        self:close()
    end)

    local sysBranchStage = tab:BranchStage(branchId)

    local infoBg = self:getUI("bg.infoBg")
    local teamPic = cc.Sprite:create("asset/uiother/intance/" .. sysBranchStage.tipPic .. '.png')
    teamPic:setAnchorPoint(0.5, 0)
    teamPic:setScale(sysBranchStage.zoom / 100)
    teamPic:setPosition(infoBg:getContentSize().width * 0.5, 20)
    infoBg:addChild(teamPic)

    local intanceModel = self._modelMgr:getModel("IntanceModel")
    local branchInfo = intanceModel:getStageInfo(stageId).branchInfo
    local branchSells = {}
    local branchData = branchInfo[tostring(branchId)]
    if branchData ~= nil and string.len(branchData) > 0 then 
        local tempBranchSells =  string.split(branchData, ",")
        for k,v in pairs(tempBranchSells) do
            branchSells[tostring(v)] = 1
        end
    end
    local goodsBg = self:getUI("bg.goodsBg")
    for k,v in pairs(sysBranchStage.shop) do
        local item = goodsBg:getChildByName("item" .. k)
        local soldOut = item:getChildByName("soldOut")

        item:setSwallowTouches(false)
        item:setName("item".. k )
        local sysBranchShop = tab:BranchShop(v)
        
        local num = sysBranchShop.item[3]
        local itemId
        if IconUtils.iconIdMap[sysBranchShop.item[1]] then
            itemId = IconUtils.iconIdMap[sysBranchShop.item[1]]
        else
            itemId = sysBranchShop.item[2]
        end

        local toolD = tab:Tool(itemId)
        --加图标
        local itemIcon = item:getChildByFullName("itemIcon")
        itemIcon:setSwallowTouches(false)
        itemIcon:removeAllChildren()

        local icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = num,eventStyle = 0})
        icon:setScale(0.8)
        icon:setAnchorPoint(0.5, 0.5)
        icon:setPosition(itemIcon:getContentSize().width * 0.5, itemIcon:getContentSize().height * 0.5)
        itemIcon:addChild(icon)

        -- local 

        -- 设置名称
        local itemName = item:getChildByFullName("itemName")
        itemName:setString(lang(toolD.name) or "没有名字")
        itemName:setFontName(UIUtils.ttfName)
        -- print("==================UIUtils.colorTable.ccUIBaseColor .. toolD.color====",toolD.color)
        -- itemName:setColor(UIUtils.colorTable["ccUIBaseColor" .. toolD.color])
        -- itemName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
        local costData = {}
        costData.costType = sysBranchShop.cost[1]
        costData.itemId = itemId
        costData.shopBuyType = "intance"
        costData.num = num
        local haveNum = 0
        local costNum = 0
        local player = self._modelMgr:getModel("UserModel"):getData()
        if type(costData.costType) == "table" then
            haveNum = player[(costData.costType[1] or costData.costType["type"])]
            costNum = costData.costType[3] or costData.costType["num"]
            costData.costType = (costData.costType[1] or costData.costType["type"])
            costData.costNum = costNum
        else
            haveNum = player[costData.costType]
            costNum = costData.costNum
        end

        -- 花费
        local priceLab = item:getChildByFullName("priceLab")
        priceLab:setString(ItemUtils.formatItemCount(costNum) or "")
        priceLab:setColor(UIUtils.colorTable.ccUIBaseTextColor1)

        -- priceBmpLab:setPositionX((item:getContentSize().width-priceBmpLab:getContentSize().width)/2)
        -- 购买类型
        local buyIcon = item:getChildByFullName("diamondImg")
        buyIcon:loadTexture(IconUtils.resImgMap[costData.costType],1)
        local scaleNum = math.floor((32/buyIcon:getContentSize().width)*100)
        buyIcon:setScale(scaleNum/100)
        -- buyIcon:setScale(1)

        local iconW = buyIcon:getContentSize().width*scaleNum/100
        local labelW = priceLab:getContentSize().width
        local itemW = item:getContentSize().width - 5
        buyIcon:setPositionX(itemW/2-labelW/2-3)
        priceLab:setPositionX(itemW/2+iconW/2-labelW/2-3)


        local priceLab = item:getChildByFullName("priceLab")
        priceLab:setString(ItemUtils.formatItemCount(costNum) or "")
        print('haveNum=============', haveNum, costNum)
        if haveNum < costNum then
            priceLab:setColor(UIUtils.colorTable.ccUIBaseColor6)
        else
            priceLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        end
        costData.intanceCallback = function()
            self:getMainBranchReward(stageId, branchId, v)
        end

        if branchSells[tostring(v)] ~= nil then
            soldOut:setVisible(true)
            item:setTouchEnabled(false)
            soldOut:setColor(cc.c4b(255, 255, 255,255))
            local children = item:getChildren()
            for k,v in pairs(children) do
                v:setBrightness(-50)
            end
            soldOut:setBrightness(0)
        else
            item:setScaleAnim(false)
            self:registerClickEvent(item, function()
                if socket.gettime() - self._touchTime  <= 0.5 then return end
                self._touchTime = socket.gettime()
                self._viewMgr:showDialog("shop.DialogShopBuy", costData, true)
            end)            
            soldOut:setVisible(false)
        end        
                    
    end
end


--[[
--! @function getMainBranchReward
--! @desc 关卡奖励支线
--! @param inStageId  关卡id
--! @param inBranchId  支线id
--! @param inGoodsId  商品id
--]]
function IntanceBranchMarketView:getMainBranchReward(inStageId, inBranchId, inGoodsId)
    local param = {mid = inStageId, bid = inBranchId, ext = inGoodsId}
    self._serverMgr:sendMsg("StageServer", "getMainBranchReward", param, true, {}, function (result)
        if result == nil or result["d"] == nil then 
            return 
        end
        self:reflashUI(self._data)
        ViewManager:getInstance():showTip(lang("STORE_SYSTEM_BUY") or "购买成功！") 
    end)  
end
return IntanceBranchMarketView