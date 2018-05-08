--[[
    Filename:    MFAwardDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-07-06 21:05:15
    Description: File description
--]]

local iconIdMap = IconUtils.iconIdMap

local MFAwardDialog = class("MFAwardDialog",BasePopView)
function MFAwardDialog:ctor(data)
    -- dump(data, "data ================")
    self.super.ctor(self)
    self._callback = data.callback or nil
    self._selectIndex = data.index
    self.viewType = data.viewType
    self.canGet = data.canGet
    self._heros = {}
    self._times = 1
    -- self.bgName = "bg.bg0"
end

-- 初始化UI后会调用, 有需要请覆盖
function MFAwardDialog:onInit()
    -- self._scrollView = self:getUI("bg.scrollView")
    self._bg0 = self:getUI("bg.bg0")
    self._bg0:setVisible(false)
    -- self:registerClickEventByName("bg", function()
    --     UIUtils:reloadLuaFile("MF.MFAwardDialog")
    --     self:close()
    -- end) 

    self._roleImg = self:getUI("bg.bg0.role_img")
    self._roleImg:loadTexture("asset/bg/global_reward_img.png")
    -- self._confirmBtn = self:getUI("bg.confirmBtn")
    
    -- self._okBtn = self:getUI("bg.bg0.closeBtn")
    self._closePanel = self:getUI("closePanel")
    self._closePanel:setSwallowTouches(false)
    self._okBtn = self:getUI("bg.bg0.okBtn")
    self.bgWidth = self._bg0:getContentSize().width
    self.bgWidth,self.bgHeight = self._bg0:getContentSize().width,self._bg0:getContentSize().height
    self._bg0:setVisible(true)
    local title = self:getUI("bg.bg0.title")
    -- title:setFontName(UIUtils.ttfName)
    title:setColor(cc.c4b(255,255,255,255))
    -- title:enableOutline(cc.c4b(0, 0, 0, 255),1.5)
    self._title = title
    local hadClose
    self._okBtn:setTitleText("确定") 
    -- self._okBtn:setEnabled(self.canGet)
    -- self._okBtn:setBright(self.canGet)
    local viplvl = self._modelMgr:getModel("VipModel"):getData().level
    local mfTimes = tab:Vip(viplvl).mfDouble
    local cost = 0
    local gem = self:getUI("bg.bg0.gem")
    gem:setVisible(false)
    self._gemValue = self:getUI("bg.bg0.gemValue")
    self._gemValue:setString(cost)
    self._gemValue:setVisible(false)

    self._okBtn = self:getUI("bg.bg0.okBtn")
    local userData = self._modelMgr:getModel("UserModel"):getData()
    if userData.gem < 0 then
        self._gemValue:setColor(cc.c3b(255,23,23))
        self:registerClickEvent(self._okBtn, function()
            DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function( )
                local viewMgr = ViewManager:getInstance()
                viewMgr:showView("vip.VipView", {viewType = 0})
            end}) 
        end)
    else
        self._gemValue:setColor(cc.c3b(255,255,255))
        self:registerClickEvent(self._okBtn, function()
            print("领取奖励")
            self:getfinishMFReward(self._selectIndex)
        end)
    end
    
    local mfData = self._modelMgr:getModel("MFModel"):getTasksById(self._selectIndex)
    if mfData.times then
        self._times = mfData.times + 1
    end
    local taskTab = tab:MfTask(mfData.taskId)
    local chanliang = self:getUI("bg.bg0.chanliang")
    if taskTab.starShow then
        local chimg = self:getUI("bg.bg0.chanliang.chImg")
        chimg:loadTexture("mfimg_schanchuqipao" .. taskTab.starShow .. ".png", 1)
        chanliang:setVisible(true)
    else
        chanliang:setVisible(false)
    end

    self._cancelBtn = self:getUI("bg.bg0.cancelBtn")
    self:registerClickEvent(self._cancelBtn, function()
        print("取消")
        self:finishMF(self._selectIndex)
    end)

    -- self:getUI("bg.closeBtn"):setVisible(true)
    -- self:registerClickEventByName("bg.closeBtn", function()
    --     self:close()
    -- end)


    self._rewardPanel = self:getUI("bg.bg0.reward_panel")
    self:listenReflash("UserModel", self.updateBtn)
    self:updateBtn()
    -- 动画相关
    self._itemNames = {}
    -- self._touchLab = self:getUI("touchLab")
    -- self._touchLab:setVisible(true)
    -- self._touchLab:setOpacity(0)
end

function MFAwardDialog:reflashUI(data)
    -- dump(data)
    local gifts = data.gifts or data
    if gifts and #gifts == 0 then
        gifts = {}
        table.insert(gifts,data.gifts or data)
    end
    self._gifts = gifts

    local colMax = 5
    local itemHeight,itemWidth = 120,106
    local maxHeight = itemHeight * math.ceil( #gifts / colMax)+150
    
    local x = 0
    local y = 0

    local offsetX,offsetY = 0,0
    local row = math.ceil( #gifts / colMax)
    local col = #gifts
    if col > colMax then
        col = colMax
    end



    offsetX = 0--(self.bgWidth-(col-1)*itemWidth)*0.5
    offsetY = 0--offsetY + (row-1)*itemHeight*0.5+self.bgHeight/2

    if table.nums(gifts) < 3 then
        offsetX = 100
    end
    x = x+offsetX-itemWidth
    y = y+offsetY
    if data.vipPlus then
        y = y + 40
    end
    local showItems
    showItems = function( idx )
        x = x + itemWidth
        if idx ~= 1 and (idx-1) % colMax == 0 then 
            x =  offsetX
            y = y - itemHeight
        end
        self:createItem(gifts[idx], x, y, idx, showItems)
    end
    offsetY = offsetY + 15
    showItems(1)


    -- if self._title and data.title then
    --     self._title:setString(data.title or "")
    -- end
    -- local des = data.des or data.desc
    -- if des and self._title then
    --     -- local txt = ccui.Text:create()        
    --     -- txt:setString(des)
    --     if string.sub(des,1,1) ~= "[" then
    --         des = "[color=ebb45a]" .. des .. "[-]"
    --     end
    --     local rtx = RichTextFactory:create(des,500,80)
    --     rtx:formatText()
    --     rtx:setAnchorPoint(cc.p(0,0.5))
    --     local h = rtx:getInnerSize().height
    --     local posX = self._title:getPositionX() - 260
    --     local posY = self._rewardPanel:getPositionY()+self._rewardPanel:getContentSize().height + 20
    --     rtx:setPosition(posX,posY)
    --     -- UIUtils:alignRichText(rtx)
    --     self._bg0:addChild(rtx,10)
    -- end
end

function MFAwardDialog:updateGemBtn()
    local userData = self._modelMgr:getModel("UserModel"):getData()
    if userData.gem < 0 then
        self._gemValue:setColor(cc.c3b(255,23,23))
        self:registerClickEvent(self._okBtn, function()
            DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function( )
                local viewMgr = ViewManager:getInstance()
                viewMgr:showView("vip.VipView", {viewType = 0})
            end}) 
        end)
    else
        self._gemValue:setColor(cc.c3b(255,255,255))
        self:registerClickEvent(self._okBtn, function()
            print("领取奖励")
            self:getfinishMFReward(self._selectIndex)
        end)
    end
end


function MFAwardDialog:createItem( data,x,y,index,nextFunc )
    if data == nil then
        return
    end
    local itemType = data.type or data[1]
    local itemId = data.typeId or data[2]
    local itemNum = data.num or data[3]
    if itemType ~= "tool" and itemType ~= "hero" and itemType ~= "team" then
        itemId = iconIdMap[itemType]
    end
    
    -- if data.isItem then
    local itemData = tab:Tool(itemId)
    if itemData == nil then
        itemData = tab:Team(itemId)
    end
    local item = IconUtils:createItemIconById({itemId = itemId,num = itemNum,itemData = itemData,effect = false })
    item:setSwallowTouches(true)
    item:setAnchorPoint(cc.p(0,0))
    item:setPosition(cc.p(x,y))
    item:setVisible(true)
    local itemNormalScale = 100/item:getContentSize().width
    item:setScale(itemNormalScale)

    self._rewardPanel:addChild(item) 
    print("index",index,x,y)
    nextFunc(index+1)
end

function MFAwardDialog:getfinishMFReward(index)
    self._serverMgr:sendMsg("MFServer", "getfinishMFReward", {id = index}, true, {}, function (result)
        -- self._viewMgr:showDialog("MF.MFAwardDialog", {gifts = result.reward})
        self:updateGemBtn()
        local viplvl = self._modelMgr:getModel("VipModel"):getData().level
        local mfTimes = tab:Vip(viplvl).mfDouble
        -- local cost = costMf
        print("vself._times ====", self._times, mfTimes)
        local mfData = self._modelMgr:getModel("MFModel"):getTasksById(self._selectIndex)
        if mfData.taskId == 151 then
            self._times = mfTimes
            DialogUtils.showGiftGet({
                gifts = result.reward,
                callback = function()
                self:finishMF(index)
            end,notPop = true})
            return
        end
        if self._times == mfTimes then
            print("最后一次领取奖励")
            -- local mfloot = self:split(lang("MF_LOOT"), "$des", costMf) 
            -- self._title:setString(mfloot)
            DialogUtils.showGiftGet({
                gifts = result.reward,
                callback = function()
                -- self:finishMF(index)
            end,notPop = true})
        else
            DialogUtils.showGiftGet({gifts = result.reward,notPop = true})
        end
        self._times = mfData.times + 1
        self:updateBtn()
    end, function(errorId)
        if errorId ~= nil and self.close then
            if self._callback then
                self._callback()
            end
            self:close()
        end
    end)
end

function MFAwardDialog:finishMF(index)
    self._serverMgr:sendMsg("MFServer", "finishMF", { id = {index} }, true, {}, function (result)
        if self._callback then
            self._callback()
        end
        self:close()
        -- DialogUtils.showGiftGet({gifts = result.reward})
    end, function(errorId)
        if errorId ~= nil and self.close then
            if self._callback then
                self._callback()
            end
            self._serverMgr:sendMsg("MFServer", "getMFInfo", {}, true, {}, function (result)
                self:close()
            end)
        end
    end)
end

function MFAwardDialog:updateBtn()
    if self._times >= 2 then
        -- 设置领取翻倍
        local mfData = self._modelMgr:getModel("MFModel"):getTasksById(self._selectIndex)
        local taskTab = tab:MfTask(mfData["taskId"])
        local costMf = 0
        if self._times > 3 then
            costMf = taskTab["cost"][4][3]
        else
            costMf = taskTab["cost"][self._times][3]
            -- dump(taskTab["cost"][3])
            -- self._gemValue:setString(taskTab["cost"][self._times][3])
        end

        local activityModel = self._modelMgr:getModel("ActivityModel")
        local openActivity = activityModel:getAbilityEffect(activityModel.PrivilegIDs.PrivilegID_20)
        costMf = costMf * (1 + openActivity)
        self._gemValue:setString(costMf)
        local userData = self._modelMgr:getModel("UserModel"):getData()
        print("====costMf========", openActivity, userData.gem, costMf)
        if userData.gem < costMf then
            self._gemValue:setColor(cc.c3b(255,23,23))
            self:registerClickEvent(self._okBtn, function()
                DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function( )
                    local viewMgr = ViewManager:getInstance()
                    viewMgr:showView("vip.VipView", {viewType = 0})
                end}) 
            end)
        else
            self._gemValue:setColor(cc.c3b(255,255,255))
            self:registerClickEvent(self._okBtn, function()
                print("领取奖励")
                self:getfinishMFReward(self._selectIndex)
            end)
        end
        local viplvl = self._modelMgr:getModel("VipModel"):getData().level
        local mfTimes = tab:Vip(viplvl).mfDouble
        if self._times <= mfTimes then
            local mfloot = self:split(lang("MF_LOOT"), "$des", costMf) 
            self._title:setString(mfloot)
        end
        
        self._gemValue:setVisible(true)
        local gem = self:getUI("bg.bg0.gem")
        gem:setVisible(true)
        self._okBtn:setTitleText("再次领取")
        self._okBtn:setSaturation(0)
        self._cancelBtn:setVisible(true)
        
        local userData = self._modelMgr:getModel("UserModel"):getData()
        if userData.gem < costMf then
            self._gemValue:setColor(cc.c3b(255,23,23))
        else
            self._gemValue:setColor(cc.c3b(255,255,255))
        end
    else
        self._okBtn:setTitleText("领取奖励")
        self._cancelBtn:setVisible(false)
    end

    local viplvl = self._modelMgr:getModel("VipModel"):getData().level
    local mfTimes = tab:Vip(viplvl).mfDouble
    print("vself._times ====", self._times, mfTimes)
    if self._times == mfTimes+1 then
        self._okBtn:setTitleText("次数用尽")
        self._okBtn:setSaturation(-100)
        
        local gem = self:getUI("bg.bg0.gem")
        gem:setVisible(false)
        self._gemValue:setVisible(false)

        self:registerClickEvent(self._okBtn, function()
            if mfTimes < 4 then
                -- self._viewMgr:showTip(lang("MF_VIP1"))
                self._buyTipDesTable = {des1 = lang("MF_VIP1")}
                self._viewMgr:showDialog("global.GlobalResTipDialog",self._buyTipDesTable or {},true)
            elseif mfTimes == 4 then
                self._viewMgr:showTip(lang("MF_VIP2"))
            else
                self._viewMgr:showTip(lang("MF_VIP2"))
            end
        end)
    else
        self._okBtn:setSaturation(0)
    end 
end

function MFAwardDialog:split(str,param,reps)
    -- print("str,param,reps ================", str,param,reps)
    if str == "" then
        return str
    end
    local des = string.gsub(str,"%b{}",function( lvStr )
        return string.gsub(string.gsub(lvStr,param,reps),"[{}]","")
    end, 1)
    -- print(des)
    return des 
end

return MFAwardDialog