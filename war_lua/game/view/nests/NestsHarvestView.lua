--
-- Author: <ligen@playcrab.com>
-- Date: 2016-12-13 17:45:19
--
local NestsHarvestView = class("NestsHarvestView", BasePopView)

function NestsHarvestView:ctor(data)
    NestsHarvestView.super.ctor(self)

    -- 阵营ID
    self._cId = data.cId
    -- 巢穴ID
    self._nId = data.nId
    -- 购买次数
    self._buyTimes = data.buyTimes

    -- 丰收成功回调
    self._callBack = data.callBack

    self._nModel = self._modelMgr:getModel("NestsModel")

    self._raceIdMap = {
        [101] = 101,
        [102] = 102,
        [103] = 104,
        [104] = 103,
        [105] = 105,
        [106] = 106,
    }
end

function NestsHarvestView:onInit()
    local title = self:getUI("bg.title")
    UIUtils:setTitleFormat(title, 6)
    title:setString("丰收祈祷")

    self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
        UIUtils:reloadLuaFile("nests.NestsHarvestView")
    end)

    local infoNode = self:getUI("bg.infoNode")
    infoNode:setContentSize(453, 118)
    infoNode:setPositionX(infoNode:getPositionX() - 1)
    local nameLabel = infoNode:getChildByFullName("nameLabel")
    nameLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    nameLabel:setString(lang(tab:Nests(self._nId).name))

    local desLabel = infoNode:getChildByFullName("desLabel")
    desLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    desLabel:setFontName(UIUtils.ttfName)
    desLabel:setString("可兑换")

    local chipLabel = infoNode:getChildByFullName("chipLabel")
    chipLabel:setColor(UIUtils.colorTable.ccUIBaseColor2)
    chipLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    chipLabel:setFontName(UIUtils.ttfName)
    chipLabel:setString(lang(tab:Team(tab:Nests(self._nId).team).name))

    local desLabel2 = infoNode:getChildByFullName("desLabel2")
    desLabel2:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    desLabel2:setFontName(UIUtils.ttfName)
    desLabel2:setString("碎片数量")

    local countLabel = infoNode:getChildByFullName("countLabel")
    countLabel:setColor(UIUtils.colorTable.ccUIBaseColor2)
    countLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    countLabel:setString("+" .. tab:Setting("NESTS_ADD_NUM").value)

    local infoNodeWidth = infoNode:getContentSize().width
    local nameLabelWidth = nameLabel:getContentSize().width
    local desLabelWidth = desLabel:getContentSize().width
    local chipLabelWidth = chipLabel:getContentSize().width
    local desLabelWidth2 = desLabel2:getContentSize().width
    local countLabelWidth = countLabel:getContentSize().width

    nameLabel:setPositionX(-(nameLabelWidth+desLabelWidth+chipLabelWidth+desLabelWidth2+countLabelWidth) * 0.5 + infoNodeWidth * 0.5)
    desLabel:setPositionX(nameLabel:getPositionX() + nameLabelWidth)
    chipLabel:setPositionX(desLabel:getPositionX() + desLabelWidth)
    desLabel2:setPositionX(chipLabel:getPositionX() + chipLabelWidth)
    countLabel:setPositionX(desLabel2:getPositionX() + desLabelWidth2)

--    local harvestTimes = self._modelMgr:getModel("PlayerTodayModel"):getData().day36
    self._costNum = tab:ReflashCost(self._buyTimes + 1).nests
    local costLabel = self:getUI("bg.costLabel")
    costLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    costLabel:setString(tostring(self._costNum))

    local buyLabel = self:getUI("bg.buyLabel")
    buyLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    buyLabel:setString("今日购买次数:")

    local maxTimes = tab:Vip(self._modelMgr:getModel("VipModel"):getLevel()).nest
    self._leftTimes = maxTimes - self._buyTimes

    self._buyCountLabel = self:getUI("bg.buyCountLabel")
    self._buyCountLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    self._buyCountLabel:setString(self._leftTimes .. "/" .. maxTimes)

    local openBtn = self:getUI("bg.openBtn")
    self:registerClickEvent(openBtn, specialize(self.onOpen, self))

    self:setListenReflashWithParam(true)
    self:listenReflash("NestsModel", self.onModelReflash)
end

function NestsHarvestView:onModelReflash(eventName)
    if eventName == "update" then
        local nestData = self._nModel:getNestDataById(self._nId)
        dump(nestData)
        self._buyTimes = nestData.hst or 0

        local maxTimes = tab:Vip(self._modelMgr:getModel("VipModel"):getLevel()).nest
        self._leftTimes = maxTimes - self._buyTimes

        self._buyCountLabel:setString(self._leftTimes .. "/" .. maxTimes)
    end
end

function NestsHarvestView:onOpen()
--    if self._modelMgr:getModel("UserModel"):getData().gem < self._costNum then
--        self._viewMgr:showTip("钻石不足")
--        return
--    end

--    if not self._nModel:getCampCanHarvest(self._cId - 100) then
--        self._viewMgr:showTip("储存量已满")
--        return
--    end

--    if self._leftTimes == 0 then
--        self._viewMgr:showTip("今日丰收次数用尽")
--        return
--    end

    if not self._nModel:getNestCanHarvest(self._cId, self._nId) then
        self._viewMgr:showTip(lang("NESTS_TIP_2"))
        return
    end

    local vipLv = self._modelMgr:getModel("VipModel"):getData().level

    local vipTab = tab.vip
    local maxTimes = vipTab[#vipTab]["nest"]
    -- 判断是否到达当前VIP等级最大购买数
    if self._buyTimes >= vipTab[vipLv]["nest"] then
        -- 判断是否到最高VIP等级
        if vipLv < #vipTab then
            -- 判断升级VIP是否可以提高购买次数
            if self._buyTimes >= maxTimes then
                self._viewMgr:showTip("今日丰收剩余次数不足")
            else
			    self._viewMgr:showDialog("global.GlobalResTipDialog",{des1 = "今日丰收次数已用完，提升VIP可增加丰收次数"} or {},true)
            end
		else
			self._viewMgr:showTip(lang("TIP_GLOBAL_MAX_VIP"))
		end
        return
    else
        local gem = self._modelMgr:getModel("UserModel"):getData()["gem"]
        if gem < self._costNum then
           DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function( )
               local viewMgr = ViewManager:getInstance()
               viewMgr:showView("vip.VipView", {viewType = 0})
           end})
        else
           self._serverMgr:sendMsg("NestsServer", "harvest", {cid = self._cId, nid = self._nId}, true, { }, function(harvestData)
               self._viewMgr:showTip("丰收成功")

               self._callBack(harvestData)
               self:close()
           end)
        end
    end

end
return NestsHarvestView