--
-- Author: <ligen@playcrab.com>
-- Date: 2016-11-05 17:04:19
--
local CloudCityExplainView = class("CloudCityExplainView", BasePopView)

function CloudCityExplainView:ctor(data)
    CloudCityExplainView.super.ctor(self)

    self._explainId = data and data.show[1] or 1

    self._kData = {
        [1] = {aniName = "kengdong_yindao"},
        [2] = {aniName = "huixue_yunzhongchengyingdao"},
        [3] = {aniName = "zhiliaolian_yunzhongchengyingdao"},
        [4] = {aniName = "mofata_yunzhongchengyingdao"},
        [5] = {aniName = "maichong_yunzhongchengyingdao"},
        [6] = {aniName = "chuansongmen_yunzhongchengyingdao"},
        [7] = {aniName = "shidun_yunzhongchengyingdao"},
        [8] = {aniName = "zhaohuanxiaowu_zhaohuanxiaowuyindao"},
        [9] = {aniName = "jinmotayindao_jinmotayindao"}
    }

    SystemUtils.saveAccountLocalData("showExpalin_" .. self._explainId, 1)
end

function CloudCityExplainView:getMaskOpacity()
    return 229
end

function CloudCityExplainView:initData()
    for k, v in pairs(tab.towerFight) do
        if v.show then
            local explainId = v.show[1]
            self._kData[explainId].nameStr = v.show[2]
            self._kData[explainId].desStr = v.show[3]
        end
    end

    self._kDataLen = #self._kData
end


function CloudCityExplainView:onInit()
    self:initData()

    self:registerClickEventByName("bg.layer.closeBtn", function()
        self:close()
        -- UIUtils:reloadLuaFile("cloudcity.CloudCityExplainView")
    end )

    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("cloudcity.CloudCityExplainView")
        elseif eventType == "enter" then 
        end
    end)

    self._layer = self:getUI("bg.layer")

    self._title = self:getUI("bg.layer.titleBg.titleLab")
    self._title:setString("器械说明")
    UIUtils:setTitleFormat(self._title, 3, 1)

    self._infoNode = self._layer:getChildByFullName("infoNode")

    self._nameLabel = self:getUI("bg.layer.titleBg1.titleLab")
    self._nameLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    UIUtils:adjustTitle(self:getUI("bg.layer.titleBg1"))

    self:registerClickEventByName("bg.layer.leftBtn", function ()
        self:changePage("left")
    end)

    self:registerClickEventByName("bg.layer.rightBtn", function ()
        self:changePage("right")
    end)

    local maxPage = self._kDataLen
    local space = 24
    local startPosX = 484-space*(maxPage-1)/2

    self._pointList = {}
    for i = 1 , maxPage do
        local pointBg = cc.Sprite:createWithSpriteFrameName("globaImageUI_pagePointGray.png")
        pointBg:setPosition(startPosX + (i-1)*space, 108)
        self._layer:addChild(pointBg)
        table.insert(self._pointList, pointBg)
    end

    self._curIndex = self._explainId
    self:updateUI(self._curIndex)
end

function CloudCityExplainView:changePage(tp)
    if tp == "left" then
        self._curIndex = self._curIndex - 1
        self._curIndex = self._curIndex == 0 and self._kDataLen or self._curIndex
    elseif tp == "right" then
        self._curIndex = self._curIndex + 1
        self._curIndex = self._curIndex == self._kDataLen + 1 and 1 or self._curIndex
    end

    self:updateUI(self._curIndex)
end

function CloudCityExplainView:updateUI(index)
    if self._curPoint == nil then
        self._curPoint = cc.Sprite:createWithSpriteFrameName("globaImageUI_pagePointRed.png")
        self._layer:addChild(self._curPoint)
    end
    self._curPoint:setPosition(self._pointList[index]:getPosition())

    local curData = self._kData[index]
    self._nameLabel:setString(lang(curData.nameStr))
    UIUtils:adjustTitle(self:getUI("bg.layer.titleBg1"))

    if index == 9 then
        local heroArt = tab:Hero(60103)["heroart"]
        mcMgr:loadRes("stop_" .. heroArt, function(fileName)
            if not tolua.isnull(self._infoNode) then
                self._specialAni9 = mcMgr:createViewMC("stop_" .. heroArt, true)
                self._specialAni9:setPosition(176, 85)
                self._specialAni9:setScale(0.5)
                self._infoNode:addChild(self._specialAni9)
            end
        end)
    else
        if self._specialAni9 then
            self._specialAni9:removeFromParent()
            self._specialAni9 = nil
        end
    end

    if self._explainMc then
        self._explainMc:removeFromParent()
        self._explainMc = nil
    end

    mcMgr:loadRes(curData.aniName, function(fileName)
        if not tolua.isnull(self._infoNode) then
            self._explainMc = mcMgr:createViewMC(curData.aniName, true, false)
            self._explainMc:setPosition(306, 70)
            self._infoNode:addChild(self._explainMc)
        end
    end)

    if self._desRich ~= nil then
        self._desRich:removeFromParent(true)
        self._desRich = nil
    end
    self._desRich = RichTextFactory:create(lang(curData.desStr), 820, 30)
    self._desRich:formatText()
    self._desRich:enablePrinter(true)
    self._desRich:setPosition(473, 146)
    self._layer:addChild(self._desRich)
	UIUtils:alignRichText(self._desRich,{hAlign = "center"})
end

return CloudCityExplainView