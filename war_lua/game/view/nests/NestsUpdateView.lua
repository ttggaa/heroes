--
-- Author: <ligen@playcrab.com>
-- Date: 2016-12-13 17:47:42
--
local NestsUpdateView = class("NestsUpdateView", BasePopView)

function NestsUpdateView:ctor(data)
    NestsUpdateView.super.ctor(self)

    self._nestData = data.nData

    -- 升级成功回调
    self._callBack = data.callBack

    self._nModel = self._modelMgr:getModel("NestsModel")
end


function NestsUpdateView:onInit()
    self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
        UIUtils:reloadLuaFile("nests.NestsUpdateView")
    end)


    self._nestTempData = tab:Nests(tonumber(self._nestData.id))

    local title = self:getUI("bg.title")
    UIUtils:setTitleFormat(title, 1)
    title:setString(lang(self._nestTempData.name))

    local infoNode = self:getUI("bg.infoNode")
    local lNameLabel = infoNode:getChildByFullName("lNameLabel")
    lNameLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    lNameLabel:setString(lang(self._nestTempData.name) .. " Lv." .. self._nestData.lvl)
    local lIcon = infoNode:getChildByFullName("lIcon")
    local lRateLabel = infoNode:getChildByFullName("lRateLabel")
    lRateLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    lRateLabel:setString(tostring(self._nModel:getTimeById(self._nestTempData.id, self._nestData.lvl) .. "小时/个"))

    local rNameLabel = infoNode:getChildByFullName("rNameLabel")
    rNameLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    rNameLabel:setString(lang(self._nestTempData.name) .. " Lv." .. (self._nestData.lvl + 1))
    local rIcon = infoNode:getChildByFullName("rIcon")

    local rRateLabel = infoNode:getChildByFullName("rRateLabel")
    rRateLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    rRateLabel:setString(tostring(self._nModel:getTimeById(self._nestTempData.id, self._nestData.lvl + 1) .. "小时/个"))

    -- 添加icon
    local goodsId = tab:Team(self._nestTempData.team)["goods"]
    local toolData = tab:Tool(goodsId)
    local lIconImg = IconUtils:createItemIconById({itemId = goodsId,itemData = toolData,eventStyle = 3,effect = true})
    lIconImg:setScale(110 / lIconImg:getContentSize().width)
    lIcon:addChild(lIconImg)

    local rIconImg = IconUtils:createItemIconById({itemId = goodsId,itemData = toolData,eventStyle = 3,effect = true})
    rIconImg:setScale(110 / rIconImg:getContentSize().width)
    rIcon:addChild(rIconImg)

    local costNode = self:getUI("bg.costNode")
    self._currencyNode = costNode:getChildByFullName("currencyNode")

    local label1 = costNode:getChildByFullName("label1")
    label1:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    local label2 = costNode:getChildByFullName("label2")
    label2:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    label2:setString("兵营需要:")
    local nameLabel = costNode:getChildByFullName("nestName")
    nameLabel:setColor(UIUtils.colorTable.ccUIBaseColor2)
    nameLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    nameLabel:setString(lang(self._nestTempData.name))

    local label1Width = label1:getContentSize().width
    local label2Width = label2:getContentSize().width
    local nameLabelWidth = nameLabel:getContentSize().width
    nameLabel:setPositionX(label1:getPositionX() + label1Width * 0.5 + nameLabelWidth * 0.5)
    label2:setPositionX(nameLabel:getPositionX() + label2Width * 0.5 + nameLabelWidth * 0.5)


    self:updateCurrency()

    self:registerClickEventByName("bg.updateBtn", specialize(self.onUpdate, self))
    self:listenReflash("UserModel", self.updateCurrency)
end

function NestsUpdateView:onUpdate()
    local costDataArr = self._nestTempData.upgrade[self._nestData.lvl]

    for i = 1, #costDataArr do
        local cData = costDataArr[i]
        if cData[3] >  self._modelMgr:getModel("UserModel"):getCurrencyByType(cData[1]) then
            local tData = tab:Tool(IconUtils.iconIdMap[cData[1]])
            if self._nModel:getIsNestsCurrency(cData[1]) then
                local param = {indexId = 2, tihuan = lang(tData.name)}
                self._viewMgr:showDialog("global.GlobalPromptDialog", param)

            elseif cData[1] == "gold" then
                DialogUtils.showLackRes({goalType = "gold"})
            else
                self._viewMgr:showTip(lang(tData.name) .. "不足")
            end
            return
        end
    end

    self._serverMgr:sendMsg("NestsServer", "upgradeNest", {cid = self._nestTempData.race, nid = self._nestTempData.id}, true, { }, function(result)
        self._viewMgr:showTip("升级成功")

        local nestData = result.d.nests
        local backData = {}
        backData.campId = next(nestData)
        backData.nestId = next(nestData[backData.campId])
        self._callBack(backData)

        self:close()
    end)
end

function NestsUpdateView:updateCurrency()
    self._currencyNode:removeAllChildren()

    local costDataArr = self._nestTempData.upgrade[self._nestData.lvl]
    if costDataArr == nil then return end

    local infoEndPos = 0
    local rewardSpace = 15
    for i = 1, #costDataArr do
        local cData = costDataArr[i]

        local icon = nil
        local iconWidth = 34
        if cData[1] == "tool" then
            local iconPath = tab:Tool(cData[2]).art
            icon = cc.Sprite:createWithSpriteFrameName(iconPath .. ".png")
        else
            local iconPath = IconUtils.resImgMap[cData[1]]
            if iconPath == nil then
                local itemId = tonumber(IconUtils.iconIdMap[cData[1]])
                local toolD = tab:Tool(itemId)
                iconPath = IconUtils.iconPath .. toolD.art .. ".png"
                icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD})
            end
            icon = cc.Sprite:createWithSpriteFrameName(iconPath)
        end
        icon:setScale(iconWidth / icon:getContentSize().width)
        icon:setPosition(infoEndPos + iconWidth / 2 + rewardSpace, 19)
        self._currencyNode:addChild(icon)
        infoEndPos = icon:getPositionX() + iconWidth / 2

        local haveCount = self._modelMgr:getModel("UserModel"):getCurrencyByType(cData[1]) or 0
        local countTxt = tostring(cData[3])
--        if haveCount > 99999 then
--            countTxt = math.floor(haveCount / 10000) .. "万" .. "/" .. tostring(cData[3])
--        else
--            countTxt =  haveCount .. "/" .. tostring(cData[3])
--        end

        local rewardCount = cc.Label:createWithTTF(countTxt, UIUtils.ttfName, 22) 
        if haveCount < cData[3] then
            rewardCount:setColor(UIUtils.colorTable.ccUIBaseColor6)
            rewardCount:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        else
            rewardCount:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        end
        rewardCount:setPosition(infoEndPos + rewardCount:getContentSize().width / 2 + 2, 19)
        self._currencyNode:addChild(rewardCount)
        infoEndPos = rewardCount:getPositionX() + rewardCount:getContentSize().width / 2
    end

end
return NestsUpdateView