--[[
    Filename:    DirectShopDialog.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2017-04-14 17:22:54
    Description: File description
--]]



local DirectShopDialog = class("DirectShopDialog",BasePopView)


DirectShopDialog.TITLE_TEXT = {
    "购买后可获得全部道具",
    "购买后有一定几率获得",
    "购买后有一定几率获得",
    "购买后任选一个获得",
    "",
    "购买后一周内每天获得"
}

function DirectShopDialog:ctor(param)
    DirectShopDialog.super.ctor(self)
    self._param = param
    -- dump(self._param)
end

-- 第一次被加到父节点时候调用
function DirectShopDialog:onAdd()

end

local costImg = {
    [1] = "globalImageUI_diamond.png",
    [4] = "globalImageUI_luckyCoin.png",
}
-- 初始化UI后会调用, 有需要请覆盖
function DirectShopDialog:onInit()

    local giftID = self._param.giftID
    local num    = self._param.num
    local itemName = self._param.name
    local des = self._param.des
    local ios_pid = self._param.ios_pid
    local discount1 = self._param.discount1
    local discount2 = self._param.discount2

    local discountToCn = {
        "一折","二折","三折",
        "四折","五折","六折",
        "七折","八折","九折",
    }

    local giftConfigData = tab:ToolGift(giftID)
    self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
        UIUtils:reloadLuaFile("shop.DirectShopDialog")
    end)

    --title
    local titleType = giftConfigData.type
    local titleLbl = self:getUI("bg.Tips")
    local titleStr = self.TITLE_TEXT[titleType] or "无配置类型"..titleType
    titleLbl:setString(titleStr)

    local zuanshiBtn,rmbBtn,zuanshiBtnBoth,rmbBtnBoth
    zuanshiBtn = self:getUI("bg.zuanshiBtn")
    zuanshiBtn:setVisible(false)
    local zuanshiBtn_dis = zuanshiBtn:getChildByFullName("discount_image")
    zuanshiBtn_dis:setVisible(false)
    rmbBtn = self:getUI("bg.rmbBtn")
    rmbBtn:setVisible(false)
    local rmbBtn_dis = rmbBtn:getChildByFullName("discount_image")
    rmbBtn_dis:setVisible(false)

    zuanshiBtnBoth = self:getUI("bg.zuanshiBtnBoth")
    zuanshiBtnBoth:setVisible(false)
    local zuanshiBtnBoth_dis = zuanshiBtnBoth:getChildByFullName("discount_image")
    zuanshiBtn_dis:setVisible(false)
    rmbBtnBoth = self:getUI("bg.rmbBtnBoth")
    local rmbBtnBoth_dis = rmbBtnBoth:getChildByFullName("discount_image")
    rmbBtnBoth_dis:setVisible(false)
    rmbBtnBoth:setVisible(false)
    
    local gemPrice = self._param.gemPrice
    local rmbPrice = self._param.rmbPrice
    local currency = self._param.currency
    local id = self._param.id
    local leftTimes = self._param.leftTimes
    local confirm = self._param.confirm
    if currency == 1 or currency == 4 then
        local Image_61 = self:getUI("bg.zuanshiBtn.Image_61")
        Image_61:loadTexture(costImg[currency],1)
        zuanshiBtn:setVisible(true)
        zuanshiBtn:setTitleText("   "..gemPrice)
        if discount1 and discount1 ~= -1 then
            zuanshiBtn_dis:setVisible(true)
            zuanshiBtn_dis:getChildByFullName("discount"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor)
            if discountToCn[discount1/100] then
                zuanshiBtn_dis:getChildByFullName("discount"):setString(discountToCn[discount1/100])
            else
                zuanshiBtn_dis:getChildByFullName("discount"):setString(discount1/100 .. "折")
            end
            
        end
        self:registerClickEvent(zuanshiBtn, function( )
            printf("钻石购买")
            local param = {}
            param.buyType = currency
            param.price = gemPrice
            param.id = id
            param.left = leftTimes
            param.confirm = confirm
            param.name = itemName
            param.des = des or ""
            param.num = num or 1
            self:onBuyItem(param)
            -- self:onBuyItem(1,gemPrice,id,leftTimes,confirm)
        end)
    elseif currency == 2 then
        rmbBtn:setVisible(true)     
        rmbBtn:setTitleText("¥ "..rmbPrice)
        if discount2 and discount2 ~= -1 then
            rmbBtn_dis:setVisible(true)
            rmbBtn_dis:getChildByFullName("discount"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor)
            if discountToCn[discount2/100] then
                rmbBtn_dis:getChildByFullName("discount"):setString(discountToCn[discount2/100])
            else
                rmbBtn_dis:getChildByFullName("discount"):setString(discount2/100 .. "折")
            end
        end
        self:registerClickEvent(rmbBtn, function( )
            printf("RMB 购买")
            local param = {}
            param.buyType = 2
            param.price = rmbPrice
            param.id = id
            param.left = leftTimes
            param.confirm = confirm
            param.name = itemName
            param.des = des or ""
            param.num = num or 1
            param.ios_pid = ios_pid
            self:onBuyItem(param)
            -- self:onBuyItem(2,rmbPrice,id,leftTimes,confirm)
        end)  
    else
        zuanshiBtnBoth:setVisible(true)
        rmbBtnBoth:setVisible(true)
        zuanshiBtnBoth:setTitleText("   "..gemPrice)
        if rmbPrice then   --by wangyan
            rmbBtnBoth:setTitleText("¥ "..rmbPrice)
        end
        
        if discount1 and discount1 ~= -1 then
            zuanshiBtnBoth_dis:setVisible(true)
            zuanshiBtnBoth_dis:getChildByFullName("discount"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor)
            if discountToCn[discount1/100] then
                zuanshiBtnBoth_dis:getChildByFullName("discount"):setString(discountToCn[discount1/100])
            else
                zuanshiBtnBoth_dis:getChildByFullName("discount"):setString(discount1/100 .. "折")
            end
        end
        if discount2 and discount2 ~= -1 then
            rmbBtnBoth_dis:setVisible(true)
            rmbBtnBoth_dis:getChildByFullName("discount"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor)
            if discountToCn[discount2/100] then
                rmbBtnBoth_dis:getChildByFullName("discount"):setString(discountToCn[discount2/100])
            else
                rmbBtnBoth_dis:getChildByFullName("discount"):setString(discount2/100 .. "折")
            end
            
        end
        self:registerClickEvent(zuanshiBtnBoth, function( )
            printf("钻石购买")
            local param = {}
            param.buyType = 1
            param.price = gemPrice
            param.id = id
            param.left = leftTimes
            param.confirm = confirm
            param.name = itemName
            param.des = des or ""
            param.num = num or 1
            self:onBuyItem(param)
            -- self:onBuyItem(1,gemPrice,id,leftTimes,confirm)
        end)
        self:registerClickEvent(rmbBtnBoth, function( )
            printf("RMB 购买")
            local param = {}
            param.buyType = 2
            param.price = rmbPrice
            param.id = id
            param.left = leftTimes
            param.confirm = confirm
            param.name = itemName
            param.des = des or ""
            param.num = num or 1
            param.ios_pid = ios_pid
            self:onBuyItem(param)
            -- self:onBuyItem(2,rmbPrice,id,leftTimes,confirm)
        end)
    end

    if leftTimes <= 0 then
        zuanshiBtn:setVisible(false)
        rmbBtn:setVisible(false)
        zuanshiBtnBoth:setVisible(false)
        rmbBtnBoth:setVisible(false)
    end


    self:listenReflash("DirectShopModel", self.onShopDataChange)

    self:setTableData(giftConfigData)
    self:addTableView()
end

function DirectShopDialog:setTableData(giftConfigData)
    self._curData = giftConfigData.giftContain
    -- local function sortFun(item1,item2)
    --     if item1.order ~= item2.order then
    --         return item1.order < item2.order
    --     end
    -- end
    -- table.sort( self._curData, sortFun )
end

--[[
用tableview实现
--]]
function DirectShopDialog:addTableView()
    local tableViewBg = self:getUI("bg.tableBg")
    self.cellListItem = self:getUI("cellList")
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height))
    self._tableView:setDelegate()
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:registerScriptHandler(function( view ) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._tableView:registerScriptHandler(function( view ) return self:scrollViewDidZoom(view) end ,cc.SCROLLVIEW_SCRIPT_ZOOM)
    self._tableView:registerScriptHandler(function(table, cell) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:setBounceable(true)
    tableViewBg:addChild(self._tableView)
    self._tableView:reloadData()
end

function DirectShopDialog:scrollViewDidScroll(view)
    
end

function DirectShopDialog:scrollViewDidZoom(view)
end

function DirectShopDialog:tableCellTouched(table,cell)
end

function DirectShopDialog:numberOfCellsInTableView(view)
    return #self._curData
end

function DirectShopDialog:cellSizeForTable(table,idx)
    return 70,346
end

function DirectShopDialog:tableCellAtIndex(table,idx)
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
    else
        cell:removeAllChildren()
    end

    local item = self:createItem(idx+1)
    item:setPosition(cc.p(0,0))
    cell:addChild(item)
    return cell
end

function DirectShopDialog:createItem(index)
    local data = self._curData[index]
    local item = self.cellListItem:clone()
    item:setVisible(true)
    item:setAnchorPoint(cc.p(0,0))

    local itemID
    local itemData 
    local isAva
    if data[1] == "tool" then
        itemID = data[2]
        itemData = tab:Tool(itemID)
    elseif data[1] == "avatarFrame" then
        itemID = data[2]
        itemData = tab:AvatarFrame(data[2])
        isAva = true
    elseif data[1] == "team" then
        itemID = data[2]
        itemData = tab:Team(itemID)
    elseif data[1] == "hero" then
        itemID = data[2]
        itemData = tab:Hero(itemID)
    else
        itemID = IconUtils.iconIdMap[data[1]]
        itemData = tab:Tool(itemID)
    end

    -- dump(data)
    -- local itemData = tab:Tool(itemID)
    if not itemData then
        print("itemID",itemID,"type",data[1])
    end

    local itemCount = data[3]
    local type_ = data[1]

    local nameLbl = item:getChildByFullName("name")
    nameLbl:setString(lang(itemData.name))
    -- local color = ItemUtils.findResIconColor(itemID,itemCount)
    -- nameLbl:setColor(UIUtils.colorTable["ccUIBaseColor" .. color])

    local countLbl = item:getChildByFullName("Label_65")
    countLbl:setString("x"..itemCount)
    countLbl:setPositionX(nameLbl:getContentSize().width+nameLbl:getPositionX())
    -- countLbl:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local icon
    local iconBg = item:getChildByFullName("iconBg")
    iconBg:setTouchEnabled(false)
    if isAva == true then
        icon = IconUtils:createHeadFrameIconById({itemId = itemID, itemData = itemData})
        icon:setScale(0.52)
    else
        if type_ == "team" then
            icon = IconUtils:createSysTeamIconById({sysTeamData = itemData,isGray = false,isJin = true})
            icon:setScale(0.54)
        elseif type_ == "hero" then
            icon = IconUtils:createHeroIconById({sysHeroData = itemData})
            icon:setScale(0.54)
            iconBg:setTouchEnabled(true)
            registerClickEvent(iconBg, function()
                local NewFormationIconView = require "game.view.formation.NewFormationIconView"
                self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = data[2]}, true)
            end)
            iconBg:setSwallowTouches(false)
        else
            icon = IconUtils:createItemIconById({itemId = itemID,itemData = itemData,eventStyle = 2})
            icon:setScale(0.60)
        end
    end
    -- icon:setContentSize(100, 60)
    
    icon:setAnchorPoint(0.5,0.5)
    icon:setPosition(iconBg:getContentSize().width/2,iconBg:getContentSize().height/2)
    iconBg:addChild(icon)

    return item
end

function DirectShopDialog:onShopDataChange()
    -- self:close()
end

function DirectShopDialog:buySuccess(result)
    -- dump(result)
    local buyID = result.buyId
    local cashId
    if GameStatic.appleExamine == true then
        cashId = tab:Specialshopauditing(buyID).goodsid
    else
        cashId = tab:Specialshop(buyID).goodsid
    end

    local cashData = tab:CashGoodsLib(cashId)
    local rewardData = cashData.reward
    -- local giftId = rewardData[2]
    local giftType = cashData.type
    local reward = {}
    if result.reward then
        for _,data in pairs (result.reward) do 
            if data[4] and data[4] == 1 then
                table.insert(reward,{type = data[1],typeId = data[2],num = data[3],isChange = 1})
            else
                table.insert(reward,{type = data[1],typeId = data[2],num = data[3]})
            end
        end
    end
    -- if result._rewards then
    --     if rewardData[1] == "hero" then
    --         for id,data in pairs (result._rewards) do 
    --             local type_ = "tool"
    --             if tab:Hero(tonumber(id)) then
    --                 type_ = "hero"
    --             end
    --             table.insert(reward,{type = type_,typeId = id,num = data.num})
    --         end
    --     else
    --         table.insert(reward,{type = rewardData[1],typeId = rewardData[2],num = rewardData[3]})
    --     end
    -- else
    --     table.insert(reward,{type = rewardData[1],typeId = rewardData[2],num = rewardData[3]})
    -- end
    -- table.insert(reward,{type = rewardData[1],typeId = rewardData[2],num = rewardData[3]})
    if giftType ~= 2 then --非周卡类型
        DialogUtils.showGiftGet( {
            hide = self,
            gifts = reward,
            title = "恭喜获得",
            notPop=true,
            callback = function()
        end})
    else --周卡类型获得面板
        
        self._viewMgr:showDialog("shop.WeekRewardDialog",{id = rewardData[2]},true)
    end
    reward = nil
    result.reward = nil
end

function DirectShopDialog:isTimeOut(endTime)
    local time_ = self._modelMgr:getModel("UserModel"):getCurServerTime()
    return time_ >= endTime
end

--@ costType 1钻石购买 2 RMB购买 
function DirectShopDialog:onBuyItem(param)
    local costType = param.buyType
    local price = param.price
    local itemID = param.id
    local leftBuyTimes = param.left
    local confirm = param.confirm
    local name = param.name
    local des = param.des
    local num = param.num
    local ios_pid = param.ios_pid
    local needCount = tab:Setting("G_SPECIALSHOP_CONVENIENT").value
    local batchData = self._param.batchData

    --剩余次数判定
    if leftBuyTimes <= 0 then
        self._viewMgr:showTip("购买次数不足！")
        return
    end

    if self:isTimeOut(self._param.endTime) then
        self._viewMgr:showTip("商品已过期")
        return
    end

    local function goBuy()
        if costType == 1 then
            printf("price == %d",price)
            local player = self._modelMgr:getModel("UserModel"):getData()
            local gemHaveCount = player.gem
            if price > gemHaveCount then
                DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function( )
                    self._viewMgr:showView("vip.VipView", {viewType = 0})
                end})
                return
            end

            --批量购买判断
            if leftBuyTimes > needCount then
                --满足批量购买
                self._viewMgr:showDialog("shop.DirectBatchBuyDialog",{data = batchData,callBack = function (result)
                    self:close()
                    self:buySuccess(result)
                end},true)
                return
            end

            self._serverMgr:sendMsg("ShopServer", "buyShopItem", {id = itemID,["type"] = "zhigou"}, true, {}, function(result)
                audioMgr:playSound("consume")
                -- self._viewMgr:showTip("购买成功！")
                self:close()
                self:buySuccess(result)
            end)
        elseif costType == 4 then
            printf("price == %d",price)
            local player = self._modelMgr:getModel("UserModel"):getData()
            local haveCount = player.luckyCoin
            if price > haveCount then
                -- DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function( )
                --     local viewMgr = ViewManager:getInstance()
                --     viewMgr:showView("vip.VipView", {viewType = 0})
                -- end})
                DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_LUCKYCOIN"),button1 = "前往",title = "幸运币不足",callback1=function( )
                    DialogUtils.showBuyRes({goalType = "luckyCoin",inputNum = price - haveCount })
                end})
                return
            end

            --批量购买判断
            if leftBuyTimes > needCount then
                --满足批量购买
                self._viewMgr:showDialog("shop.DirectBatchBuyDialog",{data = self._curentBuyData,callBack = function (result)
                    self:close()
                    self:buySuccess(result)
                end},true)
                return
            end
            self._serverMgr:sendMsg("ShopServer", "buyShopItem", {id = itemID,["type"] = "zhigou"}, true, {}, function(result)
                audioMgr:playSound("consume")
                self:close()
                self:buySuccess(result)
            end)
        else 
            local param1 = {}
            param1.ftype = 2
            param1.gname = des
            param1.gdes = des
            if OS_IS_IOS then
                param1.product_id = "com.tencent.yxwdzzjy."..ios_pid
            end
            param1.ext = json.encode({id = itemID, num = 1})
            price = tonumber(price)*10
            local param2 = "com.tencent.yxwdzzjy.".. ios_pid .."*".. price .."*"..1
            -- self._modelMgr:getModel("PaymentModel"):chargeDirect(param1,param2)
            self:rmbReCharge(param1,param2)
        end
    end
    if confirm >= 1 and costType == 1 then --有二次确认
        local costType_
        if costType == 1 then
            costType_ = "gem"
        else
            costType_ = "rmb"
        end
        DialogUtils.showBuyDialog({
            costNum = price,
            costType = costType_,
            goods = "购买此道具？",
            callback1 = function()
                goBuy()
            end
        })
        return
    end
    goBuy()
end

function DirectShopDialog:rmbReCharge(param1,param2)
    local tag = SystemUtils.loadAccountLocalData("DIRECT_NO_WARING")
    if tag and tag == 1 then
        self._modelMgr:getModel("PaymentModel"):chargeDirect(param1,param2)
    else
        self._viewMgr:showDialog("shop.DirectChargeSureDialog",{callback = function ()
            self._modelMgr:getModel("PaymentModel"):chargeDirect(param1,param2)
        end})
    end
end


return DirectShopDialog