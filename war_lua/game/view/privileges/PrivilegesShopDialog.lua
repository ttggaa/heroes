--[[
    Filename:    PrivilegesShopDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-06-29 16:42:39
    Description: File description
--]]


local PrivilegesShopDialog = class("PrivilegesShopDialog", BasePopView)

function PrivilegesShopDialog:ctor(param)
    PrivilegesShopDialog.super.ctor(self)
    if not param then
        param = {}
    end
    self._callback = param.callback
end


function PrivilegesShopDialog:onInit()
    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 1)

    self._inFirst = false

    self._widget:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    if MAX_SCREEN_WIDTH > 1136 then
        self._privilegeWidth = 1136
        self._widget:setContentSize(MAX_SCREEN_WIDTH-120, MAX_SCREEN_HEIGHT)
    end

    self:registerClickEventByName("closeBtn", function ()
        UIUtils:reloadLuaFile("privileges.PrivilegesShopDialog")
        if self._callback then
            self._callback()
        end
        self:close()
    end)

    self._privilegeModel = self._modelMgr:getModel("PrivilegesModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")

    self._buffCell = self:getUI("buffCell")
    self._buffCell:setVisible(false)

    self._itemNum = self:getUI("board.lab")

    self._up = self:getUI("bg.right")
    local mc1 = mcMgr:createViewMC("zuojiantou_teamnatureanim", true, false)
    mc1:setPosition(cc.p(self._up:getContentSize().width*0.5, self._up:getContentSize().height*0.5))
    self._up:addChild(mc1)

    self._down = self:getUI("bg.left")
    local mc2 = mcMgr:createViewMC("zuojiantou_teamnatureanim", true, false)
    mc2:setPosition(cc.p(self._down:getContentSize().width*0.5, self._down:getContentSize().height*0.5))
    self._down:addChild(mc2)


    local desBg = self:getUI("bg.desBg")
    desBg:setCascadeOpacityEnabled(true)
    desBg:setOpacity(0)
    local timeBg = self:getUI("bg.timeBg")
    timeBg:setCascadeOpacityEnabled(true)
    timeBg:setOpacity(0)
    local tishi = self:getUI("bg.awardvalue_0_1")
    tishi:setOpacity(0)

    self._shopData = self._privilegeModel:getShopTableData()
    self._peerageData = {}
    self:addTableView()
    self:realTimeData()
    self._firstAnim = false
    self._tableView:reloadData()

    self._viewMgr:lock(-1)

    self:listenReflash("PrivilegesModel", self.updateUI)
end

function PrivilegesShopDialog:updateUI()
    ScheduleMgr:delayCall(2000, self, function()
        if not self._peerageData then return end
        self:reflashUI()
        self._viewMgr:unlock()
    end)
end

function PrivilegesShopDialog:reflashUI()
    -- local pData = self._privilegeModel:getData()
    -- dump(pData, "ddd=====", 5)
    self:updateItemNum()
    -- self._shopData = self._privilegeModel:getShopTableData()
    -- self._tableView:reloadData()
    dump(self._shopData)
end

--[[
用tableview实现
--]]
function PrivilegesShopDialog:addTableView()
    local tableViewBg = self:getUI("bg.tableViewBg")
    local width = 230*4+15
    self._tableView = cc.TableView:create(cc.size(width, tableViewBg:getContentSize().height-10))
    self._tableView:setDelegate()
    self._tableView:setDirection(0)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(-10, 0)
    self._tableView:registerScriptHandler(function(view) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:setBounceable(true)
    -- if self._tableView.setDragSlideable ~= nil then 
    --     self._tableView:setDragSlideable(true)
    -- end
    tableViewBg:addChild(self._tableView)
end


-- 判断是否滑动到结束
function PrivilegesShopDialog:scrollViewDidScroll(view)
    self._inScrolling = view:isDragging()
    local tempPos = view:getContentSize().width + view:getContainer():getPositionX()
    -- print("==============",tempPos, view:getContainer():getPositionX(), view:getContentSize().width)
    -- down left
    -- up   right
    if view:getContainer():getPositionX() == 0 then
        if view:getContentSize().width < 960 then
            self._up:setVisible(false)
            self._down:setVisible(false)
        else
            self._up:setVisible(true)
            self._down:setVisible(false)
        end
    elseif tempPos <= 960 then
        if view:getContentSize().width < 960 then
            self._up:setVisible(false)
            self._down:setVisible(false)
        else
            self._up:setVisible(false)
            self._down:setVisible(true)
        end
    elseif tempPos == 1036 then
        if view:getContentSize().width < 960 then
            self._up:setVisible(false)
            self._down:setVisible(false)
        else
            self._up:setVisible(false)
            self._down:setVisible(true)
        end
    elseif view:getContentSize().width > 960 then
        self._up:setVisible(true)
        self._down:setVisible(true)
    end
end

-- 触摸时调用
function PrivilegesShopDialog:tableCellTouched(table,cell)
end

-- cell的尺寸大小
function PrivilegesShopDialog:cellSizeForTable(table,idx) 
    local width = 230 
    local height = 431
    return height, width
end

-- 创建在某个位置的cell
function PrivilegesShopDialog:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local indexId = idx+1
    local param = self._shopData[indexId]
    if nil == cell then
        cell = cc.TableViewCell:new()
        cell:setName(indexId)
        cell.indexId = indexId
        local buffCell = self._buffCell:clone() 
        buffCell:setVisible(true)
        buffCell:setScale(0.9)
        buffCell:setAnchorPoint(cc.p(0,0))
        buffCell:setPosition(cc.p(1,100))
        buffCell:setName("buffCell")
        cell:addChild(buffCell)

        local shopBuy = buffCell:getChildByFullName("shopBuy")
        shopBuy:getTitleRenderer():enableOutline(cc.c4b(70,40,0,255), 1)
        -- -- local upgrade = buffCell:getChildByFullName("upgrade")
        -- UIUtils:setButtonFormat(shopBuy, 3)

        -- -- titleBg:setOpacity(150)
        local tname = buffCell:getChildByFullName("tname")
        tname:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

        -- local natureName = buffCell:getChildByFullName("cellBg.natureName")
        -- local natureValue = buffCell:getChildByFullName("cellBg.natureValue")
        -- natureName:enableOutline(cc.c4b(70, 40, 0, 255), 1)
        -- natureValue:enableOutline(cc.c4b(70, 40, 0, 255), 1)
        local iconBg = buffCell:getChildByFullName("iconBg")
        local title = mcMgr:createViewMC("fuweuqiguang2_kaiqi", true, false)
        title:setPosition(iconBg:getContentSize().width*0.5, iconBg:getContentSize().height*0.5+10)
        -- title:setVisible(false)
        title:setCascadeOpacityEnabled(true)
        title:setOpacity(150)
        iconBg:addChild(title, -1)

        self:updateCell(buffCell, param, indexId)
        if self._inFirst == false then
            buffCell:setVisible(false)
        end
        buffCell:setSwallowTouches(false)
        print("chuangjian=================")
    else
        self._firstAnim = true
        local buffCell = cell:getChildByName("buffCell")
        print("shuaxin=================")
        if buffCell then
            self:updateCell(buffCell, param, indexId)
            buffCell:setSwallowTouches(false)
        end
    end

    return cell
end

-- 返回cell的数量
function PrivilegesShopDialog:numberOfCellsInTableView(table)
    return #self._shopData -- #self._peerageData
end

function PrivilegesShopDialog:updateCell(inView, param, indexId)
    print("inView========", indexId, inView:isVisible())
    local buffNum = tonumber(param)
    local buffTab = tab:PeerShop(buffNum)

    local sysBuf = buffTab.buff
    local itemNameBg = inView:getChildByName("itemNameBg")
    local str = lang(buffTab.des)
    str = self:tsplit(str,sysBuf[2])
    local result, count = string.gsub(str, "$num", sysBuf[2])
    if count > 0 then 
        str = result
    end
    
    local richText = itemNameBg.richText
    if richText then
        richText:removeFromParent()
    end
    richText = RichTextFactory:create(str, 160, 40)
    richText:setName("richText")
    richText:formatText()
    richText:setPosition(itemNameBg:getContentSize().width/2 + (itemNameBg:getContentSize().width - richText:getRealSize().width)/2+3, itemNameBg:getContentSize().height/2)
    itemNameBg:addChild(richText)
    itemNameBg.richText = richText

    local cellBg = inView:getChildByFullName("cellBg")
    if cellBg then
        if math.fmod(indexId, 2) == 0 then
            cellBg:loadTexture("privilegeImageUI_img103.png", 1)
        else
            cellBg:loadTexture("privilegeImageUI_img102.png", 1)
        end
    end

    local tname = inView:getChildByFullName("tname")
    if tname then
        tname:setString(lang(buffTab.name))
    end

    local iconBg = inView:getChildByFullName("iconBg")
    if iconBg then
        iconBg:setVisible(true)
        local buffIcon = iconBg:getChildByName("buffIcon")
        local param = {image = buffTab.icon .. ".png", quality = 5, scale = 0.90, bigpeer = true}
        if buffIcon then
            IconUtils:updatePeerageIconByView(buffIcon, param)
            buffIcon:setSwallowTouches(false)
        else
            local buffIcon = IconUtils:createPeerageIconById(param)
            buffIcon:setPosition(-10,-5)
            buffIcon:setName("buffIcon")
            iconBg:addChild(buffIcon)
            buffIcon:setSwallowTouches(false)
        end
    end

    local natureLab = iconBg:getChildByName("natureLab")
    if natureLab then
        -- natureLab:stopAllActions()
        natureLab:removeFromParent()
    end

    local shopBuy = inView:getChildByFullName("shopBuy")
    local alreadyBuy = inView:getChildByFullName("alreadyBuy")
    local effect = self._privilegeModel:getBuffShopById(param)
    if effect == true then
        if alreadyBuy then
            alreadyBuy:setVisible(true)
            alreadyBuy:setScale(1)
            alreadyBuy:setOpacity(255)
        end
        if shopBuy then
            shopBuy:setVisible(false)
        end
    else
        if alreadyBuy then
            alreadyBuy:setVisible(false)
        end
        if shopBuy then
            shopBuy:setVisible(true)
            shopBuy:setTitleText("    " .. buffTab.cost[3])
            self:registerClickEvent(shopBuy, function()
                local tempItems, tempItemCount = self._itemModel:getItemsById(tab:Setting("G_PRIVILEGES_LVUP_ITEMID").value)
                if tempItemCount >= buffTab.cost[3] then
                    self:buyBuff(indexId, inView, str, indexId)
                else
                    self._viewMgr:showTip("特权点数不足")
                end
            end)
        end
    end
end

function PrivilegesShopDialog:updateItemNum()
    local tempItems, tempItemCount = self._itemModel:getItemsById(tab:Setting("G_PRIVILEGES_LVUP_ITEMID").value)
    self._itemNum:setString(tempItemCount)
end

function PrivilegesShopDialog:buyBuff(buffId, inView, str, indexId)
    local param = {bid = buffId}
    self._serverMgr:sendMsg("PrivilegesServer", "buyBuff", param, true, {}, function (result)
        -- self._viewMgr:showTip(lang("PRIVILEGEDES_TIP2"))
        -- self._viewMgr:lock(-1)
        self._shopData = self._privilegeModel:getShopTableData()
        local param = self._shopData[indexId]
        self:updateCell(inView, param, indexId)
        self:teamPiaoNature(inView, str)
        self:buttonAnim(inView)
        self:updateItemNum()
    end)
end


function PrivilegesShopDialog:buttonAnim(inView)
    local shopBuy = inView:getChildByFullName("shopBuy")
    local alreadyBuy = inView:getChildByFullName("alreadyBuy")
    shopBuy:setVisible(false)
    alreadyBuy:setVisible(true)
    alreadyBuy:setOpacity(0)
    local callFunc = cc.CallFunc:create(function()
        self._viewMgr:unlock()
    end)

    local scale1 = cc.ScaleTo:create(0.2, 1)
    local spawn = cc.Spawn:create(cc.FadeIn:create(0.2), scale1)
    local ease = cc.EaseSineIn:create(spawn)
    local seqnature = cc.Sequence:create(cc.ScaleTo:create(0, 5), ease, cc.DelayTime:create(2), callFunc)
    alreadyBuy:runAction(seqnature)
end

function PrivilegesShopDialog:teamPiaoNature(inView, str)
    local runeIcon = inView:getChildByFullName("iconBg")

    local mc2 = mcMgr:createViewMC("jinengjiesuo_qianghua", false, true)
    mc2:setScale(1.2)
    mc2:setPosition(runeIcon:getContentSize().width*0.5, runeIcon:getContentSize().height*0.5)
    runeIcon:addChild(mc2, 111)


    local data = string.gsub(str, "%b[]", "")

    local natureLab = runeIcon:getChildByName("natureLab")
    if natureLab then
        natureLab:stopAllActions()
        natureLab:removeFromParent()
    end

    natureLab = cc.Label:createWithTTF(data, UIUtils.ttfName, 24)
    natureLab:setName("natureLab")
    natureLab:setColor(UIUtils.colorTable.ccColorQuality2)
    natureLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    natureLab:setPosition(cc.p(runeIcon:getContentSize().width*0.5+3, runeIcon:getContentSize().height*0.5 - 35))
    natureLab:setOpacity(0)
    runeIcon:addChild(natureLab,100)

    local seqnature = cc.Sequence:create(cc.ScaleTo:create(0, 0.2), cc.DelayTime:create(0.2+0.1), 
        cc.Spawn:create(cc.ScaleTo:create(0.2, 1),cc.FadeIn:create(0.2),cc.MoveBy:create(0.2, cc.p(0,38))), 
        cc.MoveBy:create(0.38, cc.p(0,17)),
        cc.Spawn:create(cc.MoveBy:create(0.4, cc.p(0,10)),cc.FadeOut:create(0.7)),
        cc.RemoveSelf:create(true))
    natureLab:runAction(seqnature)
end

function PrivilegesShopDialog:realTimeData()
    local timerLab = self:getUI("bg.timeBg.timerLab")
    local curServerTime = self._userModel:getCurServerTime()
    local tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
    local callFunc = cc.CallFunc:create(function()
    local curServerTime = self._userModel:getCurServerTime()
        local realTime = math.abs(curServerTime - tempTime)
        -- print("curServerTime > tempTime======0", curServerTime, tempTime)
        if curServerTime > tempTime then
            realTime = curServerTime - tempTime - 86400
        else
            realTime = tempTime - curServerTime
        end
        realTime = math.abs(realTime)
        local thour = math.floor(realTime/3600)
        local tTime = realTime - thour*3600
        local tmin = math.floor(tTime/60)
        local tTime = tTime - tmin*60
        local tsec = math.fmod(tTime, 60)
        local timerStr = string.format("%.2d:%.2d:%.2d", thour, tmin, tsec)
        timerLab:setString(timerStr)
    end)
    local seq = cc.Sequence:create(callFunc, cc.DelayTime:create(1))
    timerLab:runAction(cc.RepeatForever:create(seq))
end

function PrivilegesShopDialog:onPopEnd()
    local titleBg = self:getUI("bg.titleBg")
    local title = mcMgr:createViewMC("guowangshangdiantaitou_privilegesshopkaiqi", false, false)
    title:addCallbackAtFrame(7, function()
        local desBg = self:getUI("bg.desBg")
        desBg:runAction(cc.FadeIn:create(0.5))
    end)
    title:addCallbackAtFrame(5, function()
        local childs = self._tableView:getContainer():getChildren()
        for k,v in pairs(childs) do
            if v then
                v:setVisible(false)
            end
            local indexId = v.indexId or 1
            local buffCell = v:getChildByFullName("buffCell")
            if buffCell then
                buffCell:setVisible(false)
            end
            self:cellAnim(v, indexId)
        end
    end)
    title:addCallbackAtFrame(10, function()
        local timeBg = self:getUI("bg.timeBg")
        timeBg:runAction(cc.FadeIn:create(0.5))
    end)
    title:addCallbackAtFrame(13, function()
        local tishi = self:getUI("bg.awardvalue_0_1")
        tishi:runAction(cc.FadeIn:create(0.5))
    end)
    title:addCallbackAtFrame(20, function()
        -- self._viewMgr:unlock()
        self._inFirst = true
    end)
    title:setPosition(titleBg:getContentSize().width*0.5, titleBg:getContentSize().height*0.5-10)
    title:setName("mc2")
    titleBg:addChild(title, 1)

end

function PrivilegesShopDialog:tsplit(str,reps)
    local des = string.gsub(str,"%b{}",function( lvStr )
        local str = string.gsub(lvStr,"%$num",reps)
        return loadstring("return " .. string.gsub(str, "[{}]", ""))()
    end)
    return des 
end

function PrivilegesShopDialog:cellAnim(inView, indexId)
    local move1 = cc.MoveBy:create(0, cc.p(0, -180))
    local move2 = cc.MoveBy:create(0.1, cc.p(0, 200))
    local move3 = cc.MoveBy:create(0.1, cc.p(0, -20))

    local callFunc2 = cc.CallFunc:create(function()
        inView:setVisible(true)
        local buffCell = inView:getChildByFullName("buffCell")
        if buffCell then
            buffCell:setVisible(true)
        end
    end)
    local callFunc3 = cc.CallFunc:create(function()
        self._viewMgr:unlock()
    end)
    local seq = cc.Sequence:create(move1, cc.DelayTime:create(0.05*indexId), callFunc2, move2, move3)
    if indexId == 4 then
        seq = cc.Sequence:create(move1, cc.DelayTime:create(0.05*indexId), callFunc2, move2, move3, cc.DelayTime:create(0.05), callFunc3)
    end
    inView:runAction(seq)
end

return PrivilegesShopDialog