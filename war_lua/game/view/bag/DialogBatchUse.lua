--[[
    Filename:    DialogBatchUse.lua
    Author:      <libolong@playcrab.com>
    Datetime:    2015-06-15 11:54:59
    Description: File description
--]]

local DialogBatchUse = class("DialogBatchUse", BasePopView)

function DialogBatchUse:ctor()
    DialogBatchUse.super.ctor(self)
    
end

function DialogBatchUse:onInit()
    -- self._scrollItem = self:getUI("bg.scrollItem")

    self._closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(self._closeBtn, function ()
        self:close()
        UIUtils:reloadLuaFile("bag.DialogBatchUse")
    end)
    
    self._okBtn = self:getUI("bg.okBtn")
    self:registerClickEvent(self._okBtn, function ()
        self:useItem()
    end)


    self._title = self:getUI("bg.headBg.title")
    -- self._title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._title:setFontName(UIUtils.ttfName)
    UIUtils:setTitleFormat(self._title,1)
    self._itemBg = self:getUI("bg.titlePanel.itemBg")
    self._itemNode = self:getUI("bg.titlePanel.itemNode")
    self._itemName = self:getUI("bg.titlePanel.itemName")
    -- self._itemName:enableOutline(cc.c4b(60,30,10,255),1)
    UIUtils:setTitleFormat(self._itemName,2)
    self._itemNum = self:getUI("bg.titlePanel.itemNum")
    -- self._itemNum:enableOutline(cc.c4b(60,30,10,255),2)
    self._itemCountDes = self:getUI("bg.titlePanel.itemCountDes")
    
    self._useTxtNum = self:getUI("bg.detailPanel.useNum")
    -- self._useTxtNum:enableOutline(cc.c4b(60,30,10,255),2)

    self._detailPanel = self:getUI("bg.detailPanel")
    self._desPanel = self:getUI("bg.desPanel")
    self._desPanel:setVisible(false)
    self._bg1 = self:getUI("bg.bg1")
    self._greenPro = self:getUI("bg.detailPanel.greenPro")

    self._canGetValue = self:getUI("bg.desPanel.canGetValue")
    -- self._canGetValue:enableOutline(cc.c4b(60,30,10,255),2)
    self._totalValue = self:getUI("bg.desPanel.totalValue")
    -- self._totalValue:enableOutline(cc.c4b(60,30,10,255),2)

    self._des1 = self:getUI("bg.titlePanel.des1")

    self._inputNum = 1

    -- self._leftNum = self:getUI("bg.leftNum_img.leftNum")
    -- self._haveNum = self:getUI("bg.haveNum_img.haveNum")
    self._slider = self:getUI("bg.detailPanel.sliderBar")
    self._slider:setCascadeOpacityEnabled(false)
    self._slider:getVirtualRenderer():setOpacity(0)
    self._slider:addEventListener(function(sender, eventType)
        local event = {}
        if eventType == 0 then
            event.name = "ON_PERCENTAGE_CHANGED"            
            self:sliderValueChange()
        end
        event.target = sender
        -- callback(event)
    end)
    -- self._useCountInput:addEventListener(function(sender, eventType)
    --     if eventType == 0 then
    --         -- event.name = "ATTACH_WITH_IME"
    --     elseif eventType == 1 then
    --        --  event.name = "DETACH_WITH_IME"
    --     elseif eventType == 2 then
    --         -- event.name = "INSERT_TEXT"
    --         local text = tonumber(sender:getString())
    --         print("text..",text)
    --         if not text or text < 0 then
    --             self._viewMgr:showTip("输入格式错误！")
    --             self._inputNum = 1
    --             sender:setString(1)
    --         elseif text <= self._maxNum then
    --             self._inputNum = text
    --         else
    --             self._viewMgr:showTip("输入超过上限！")
    --             self._inputNum = self._maxNum
    --             sender:setString(self._maxNum)
    --         end
    --     elseif eventType == 3 then
    --         -- event.name = "DELETE_BACKWARD"
    --         local text = tonumber(sender:getString())
    --         if not text or text < 0 then
    --             self._viewMgr:showTip("输入格式错误！")
    --             self._inputNum = 1
    --             sender:setString(1)
    --         elseif text > 0 then
    --             self._inputNum = text
    --         end
    --     end
    --     self:refreshBtnStatus()
    -- end)
    self._addBtn = self:getUI("bg.detailPanel.addBtn")
    self:registerClickEvent(self._addBtn, function ()
        if self._inputNum < self._maxNum then
            self._inputNum = self._inputNum + 1
            -- self._leftNum:setString(tonumber(self._useNum) - tonumber(self._inputNum))
            -- self._haveNum:setString(self._inputNum)
            local num = self._inputNum/self._maxNum*100
            self:setSliderPercent(self._inputNum/self._maxNum*100)
        elseif self._inputNum > boxMaxD.value then
            self._viewMgr:showTip(lang("TIPS_BEIBAO_01"))
        else
            self._viewMgr:showTip("已达使用上限！")
        end
        self:refreshBtnStatus()
    end)

    self._subBtn = self:getUI("bg.detailPanel.subBtn")
    self:registerClickEvent(self._subBtn, function ()
        if self._inputNum > 1 then
            self._inputNum = self._inputNum - 1
            self:setSliderPercent(self._inputNum/self._maxNum*100)
            -- self._itemNum:setString(self._maxNum + self._inputNum)
        end
        self:refreshBtnStatus()
    end)

    self._addTenBtn = self:getUI("bg.detailPanel.addTenBtn")
    self:registerClickEvent(self._addTenBtn, function ()
        self._inputNum = self._maxNum
        -- self._useCountInput:setString(self._inputNum)

        self:setSliderPercent(self._inputNum/self._maxNum*100)

        self:refreshBtnStatus()
    end)

    self._adjustPanel = false

end

function DialogBatchUse:setSliderPercent(num)
    local num = num * 0.01
    local newnum= 1.5 * num /(1+0.5 * num)
    self._slider:setPercent(newnum * 100)
end

function DialogBatchUse:reflashUI(data)
    -- dump("debug", data, "DialogBatchUse:reflashUI")
    -- dump(data)
   
    local itemData = data.data or data
    local useThreshold = data.useThreshold or "one"
    self._useThreshold = useThreshold
    self._itemData = itemData
    local toolD = tab:Tool(itemData.goodsId)
    local boxMaxD = tab:Setting("G_TOOL_BOX_MAX")
-- dump("debug toold",toolD,"DialogBatchUse")
    local name = lang(toolD["name"])
    if OS_IS_WINDOWS then
        self._itemName:setString(name .. " [" .. toolD.id .. "]")
    else
        self._itemName:setString(name)
    end
    -- self._itemName:setColor(UIUtils.colorTable["ccUIBaseColor" .. toolD.color])
    self._itemBg:setContentSize(cc.size(self._itemName:getContentSize().width+100,32))
    local formatNum = ItemUtils.formatItemCount(itemData.num)
    self._itemNum:setString(formatNum or itemData.num)
    self._itemCountDes:disableEffect()
    self._itemCountDes:setPositionX(self._itemNum:getPositionX()+self._itemNum:getContentSize().width)
    -- iconUtils 创建新的icon
    self._itemNode:removeAllChildren()
    local icon = IconUtils:createItemIconById({itemId = itemData.goodsId,itemData = toolD,eventStyle=0,effect = true})
    -- icon:setContentSize(cc.size(80, 80))
    self._itemNode:addChild(icon)

    local max = boxMaxD["value"]
    self._useNum = itemData.num
    self._maxNum = self._useNum
    if self._maxNum > max then
        self._maxNum = max
    end

    -- self._slider:setMinimumValue(1/self._maxNum*100)

    if useThreshold == "max" then
        self._inputNum = self._maxNum
        -- self._useCountInput:setString(self._inputNum)
    end    
    self:setSliderPercent(self._inputNum/self._maxNum*100)
    self._greenPro:setScaleX((self._inputNum~=1 and self._inputNum or 0)/self._maxNum)
    if self._inputNum == 1 then
        self:setSliderPercent(0)
    end

    self:refreshBtnStatus()
end

function DialogBatchUse:refreshBtnStatus( )
    local num = self._slider:getPercent() * 0.01
    
    if self._inputNum == 1 then
        self._subBtn:setEnabled(false)
        self._subBtn:setBright(false) 
        self:setSliderPercent(0)
        self._greenPro:setScaleX(0)
    else
        self._subBtn:setEnabled(true)
        self._subBtn:setBright(true)
    end

    if self._inputNum >= self._maxNum then 
        self._addBtn:setEnabled(false)
        self._addBtn:setBright(false)
        self:setSliderPercent(100)
    else
        self._addBtn:setEnabled(true)
        self._addBtn:setBright(true)
    end
    local sliderBase = 100
    local sliderPercent = self._slider:getPercent()
    sliderPercent = math.max(sliderPercent,10)
    sliderPercent = math.min(sliderPercent,95)
    self._greenPro:setScaleX(sliderPercent/100)
    local toolD = tab:Tool(self._itemData.goodsId)
    self._useTxtNum:setString(self._inputNum)
      
    if not self._adjustPanel then  
        if toolD.typeId == 3 then
             local data = tab:ToolExp(self._itemData.goodsId)  
             if data ~= nil and data.type ~= "texp" then     
                self.bg = self:getUI("bg") 
                -- self._bg1:setContentSize(487,426)
                self._detailPanel:setPosition((self.bg:getContentSize().width - self._detailPanel:getContentSize().width)/2+2, self.bg:getContentSize().height - self._detailPanel:getContentSize().height - 15)
                -- self._closeBtn:setPosition(self.bg:getContentSize().width-40,self.bg:getContentSize().height+20)
                -- self._okBtn:setPosition(self.bg:getContentSize().width/2,50)
                self._adjustPanel = true
            end
            if data ~= nil and data.type == "texp" then     
                self._desPanel:setVisible(true)
                self._canGetValue:setString(self._inputNum*tonumber(data["exp"]))
                self._totalValue:setString(self._modelMgr:getModel("UserModel"):getData().texp) 
            end
        else
            self.bg = self:getUI("bg") 
            -- self._bg1:setContentSize(487,426)
            self._detailPanel:setPosition((self.bg:getContentSize().width - self._detailPanel:getContentSize().width)/2+2, self.bg:getContentSize().height - self._detailPanel:getContentSize().height - 15)
            -- self._closeBtn:setPosition(self.bg:getContentSize().width-40,self.bg:getContentSize().height+20)
            -- self._okBtn:setPosition(self.bg:getContentSize().width/2,50)
            self._adjustPanel = true
        end
            
    end 
end

--[[
--! @function useItem
--! @desc 使用道具
--! @return 
--]]
function DialogBatchUse:useItem()
    if self._inputNum <= 0 then 
        return 
    end
    if self._itemData.goodsId == 30000 and not tab:UserLevel(self._modelMgr:getModel("UserModel"):getData().lvl).exp then
        self._viewMgr:showTip("玩家已满级")
        return 
    end
    local giftData = tab:ToolGift(self._itemData.goodsId) or tab:EquipmentBox(self._itemData.goodsId)
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
    local param = {goodsId = self._itemData.goodsId, goodsNum = self._inputNum,extraParams=nil}
    
    dump(preHave)

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
        for i=1,self._inputNum do 
            table.insert(idList,self._itemData.goodsId)
        end
        self:userRandRed(idList)
    else
        self:sendUseItemMsg(param)
    end
    --]]
end


function DialogBatchUse:userRandRed(idList)
    self._viewMgr:showDialog("guild.dialog.GuildDropRedDialog",idList,true)
    self:close()
end

-- 抽离出 发送使用物品接口
function DialogBatchUse:sendUseItemMsg( param )
    local preHave = clone(self._modelMgr:getModel("UserModel"):getData())
    self._serverMgr:sendMsg("ItemServer", "useItem", param, true, {}, function(result) 
        -- self:upgradeBag(result)
        dump(result,"result==>",5)
        -- 先判断是否是头像框
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
            
            self._inputNum = 0
            local itemModel = self._modelMgr:getModel("ItemModel")
            local item,icount = itemModel:getItemsById(self._itemData.goodsId)
            if icount <= 0 then 
                local data = {}
                data.goodsId = self._itemData.goodsId
                data.num = 0
                self:reflashUI(data)
            else
                self:reflashUI(item[1])
            end

            -- self._viewMgr:showTip("使用礼包成功")
        
        elseif tab:ToolGift(param.goodsId) then
            local giftData = tab:ToolGift(param.goodsId) or {}
            local gifts = giftData.giftContain
            -- 头像框 
            if giftData.type == 5 then
                DialogUtils.showAvatarFrameGet( {gifts = gifts})   
            else
                DialogUtils.showGiftGet( {gifts = gifts,notPop=true})                
            end

            self._inputNum = 0
            local itemModel = self._modelMgr:getModel("ItemModel")
            local item,icount = itemModel:getItemsById(self._itemData.goodsId)
            if icount <= 0 then 
                local data = {}
                data.goodsId = self._itemData.goodsId
                data.num = 0
                self:reflashUI(data)
            else
                self:reflashUI(item[1])
            end

            -- self._viewMgr:showTip("使用礼包成功")
        else
            -- self._viewMgr:showTip("使用成功")
             local goodsData = tab:Tool(param.goodsId)
            if goodsData and goodsData.typeId == 102 then
                DialogUtils.showSkinGetDialog( {skinId = tonumber("2" .. param.goodsId)})
            else
                local items = {}
                local uniqueTab = {}
                for k,v in pairs(result.d) do
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
                end
                if #items > 0 then
                    DialogUtils.showGiftGet( {gifts = items,notPop=true})
                end
            end
        end
        self:close()
    end)
end

-- 显示礼包内容
function DialogBatchUse:showGiftDetail( goodsId )
    -- dump("debug", data, "DialogBatchUse:showGiftDetail")
    local giftData = tab:ToolGift(param.goodsId) or {}
    local gifts = giftData.giftContain
    -- 头像框 
    if giftData.type == 5 then
        DialogUtils.showAvatarFrameGet( {gifts = gifts})   
    else
        DialogUtils.showGiftGet( {gifts = gifts})                
    end
end

function DialogBatchUse:sliderValueChange( ... )    
    local num = self._slider:getPercent() * 0.01
    -- self._inputNum = math.floor(self._maxNum * num /100)
    local newnum = (num/(1.5-0.5*num))*100
    self._inputNum = math.ceil((self._maxNum-0.9) * newnum /100)
    if self._inputNum < 1 then
        self._inputNum = 1
    end
    self:refreshBtnStatus()
end

return DialogBatchUse