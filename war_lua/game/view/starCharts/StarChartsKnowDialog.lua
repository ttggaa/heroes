--[[
    @FileName   StarChartsKnowDialog.lua
    @Authors    cuiyake
    @Date       2018-03-21 17:00:00
    @Email      <cuiyake@playcrad.com>
    @Description   星图详情UI
--]]

local StarChartsKnowDialog = class("StarChartsKnowDialog",BaseLayer)

function StarChartsKnowDialog:ctor(params)
    self.super.ctor(self)
    self._parent = params.container
    self._showType = params.showType
    self._starId = params.starId
    self._posBtn = params.btn
    self._trainShowTable = {
    [1] = {"低",cc.c4b(0, 255, 30,255)},
    [2] = {"中",cc.c4b(75, 235, 212,255)},
    [3] = {"高",cc.c4b(255, 120, 255,255)},
    [4] = {"极",cc.c4b(250, 146, 26,255)}}
end

-- 初始化UI后会调用, 有需要请覆盖
function StarChartsKnowDialog:onInit()
    -- self:registerScriptHandler(function (state)
    --     if state == "exit" then
    --         UIUtils:reloadLuaFile("starCharts.StarChartsKnowDialog")
    --     end
    -- end)

    self._btnPos = self._posBtn:convertToWorldSpace(cc.p(0,0))
    self._bg = self:getUI("bg")
    self._bg:setContentSize(MAX_SCREEN_WIDTH,MAX_SCREEN_HEIGHT)
    self:registerClickEvent(self._bg, function()
        ScheduleMgr:nextFrameCall(self, function()
            self._viewMgr:closeHintView()
            UIUtils:reloadLuaFile("starCharts.StarChartsKnowDialog")
        end)
    end)

    self._Panel1 = self:getUI("Panel1")
    self._Panel2 = self:getUI("Panel2")
    self._Panel3 = self:getUI("Panel3")

    local posX1 = self._btnPos.x - self:getUI("Panel" .. (self._showType + 1)):getContentSize().width
    local posY1 = self._btnPos.y- self:getUI("Panel" .. (self._showType + 1)):getContentSize().height
    self._Panel1:setPosition(posX1 + 5,posY1 + 10)
    self._Panel2:setPosition(posX1 + 5,posY1 + 10)
    self._Panel3:setPosition(posX1 + 5,posY1 + 10)
    self._qualityType = StarChartConst.QualityTypeTab

    self._Panel1:setVisible(self._showType == StarChartConst.DetailsType1)
    self._Panel2:setVisible(self._showType == StarChartConst.DetailsType2)
    self._Panel3:setVisible(self._showType == StarChartConst.DetailsType3)

    if self._showType == StarChartConst.DetailsType1 then
        self:initStarChartRate()
    elseif self._showType == StarChartConst.DetailsType2 then
        self:initComposeDetails()
    elseif self._showType == StarChartConst.DetailsType3 then
        self:initStarSoulDetails()
    else
            
    end
end

-- 第一次进入调用, 有需要请覆盖
function StarChartsKnowDialog:onShow()

end

-- 接收自定义消息
function StarChartsKnowDialog:reflashUI(data)

end

function StarChartsKnowDialog:initStarChartRate()

    local  qualityShow1 = tab.starCharts[self._starId]["quality_show1"]
    local  qualityShow2 = tab.starCharts[self._starId]["quality_show2"]
    for key,value in pairs(qualityShow1) do
        local activeStarnum = self:getUI("Panel1.bg1.descbg.num" .. key)
        activeStarnum:setString("+" .. value)
    end

    for key,value in pairs(qualityShow2) do
        local activeStarlab = self:getUI("Panel1.bg1.descbg.lab" .. key)
        activeStarlab:setString(self._qualityType[value])
    end

    for i=1,4 do
        local activityCount,totalCount = self._modelMgr:getModel("StarChartsModel"):getShowSortCount(i)
        local numlab = self:getUI("Panel1.bg1.descbg.numlab" .. i)
        numlab:setString("(".. activityCount .. "/" .. totalCount .. ")")
        if activityCount == totalCount then
            self:getUI("Panel1.bg1.descbg.num" .. i):setColor(UIUtils.colorTable.ccColorQuality2)
            self:getUI("Panel1.bg1.descbg.lab" .. i):setColor(UIUtils.colorTable.ccColorQuality2)
            numlab:setColor(UIUtils.colorTable.ccColorQuality2)
            self:getUI("Panel1.bg1.descbg.activeLab" .. i):setColor(UIUtils.colorTable.ccColorQuality2)
        end
    end

    local nameNode = self:getUI("Panel1.nameNode")

    local catenaIdTable = tab.starCharts[self._starId]["catena_id"]
    for i,catenaid in pairs(catenaIdTable) do
      
        local name = lang(tab.starChartsCatena[catenaid]["name"])
        local qualityNum = tab.starChartsCatena[catenaid]["quality"]
        local qualityType = tab.starChartsCatena[catenaid]["quality_type"]
        local qualityDesc = lang("SHOW_ATTR_" .. qualityType)
        
        local nameNodeClone = nameNode:clone()
        nameNodeClone:setVisible(true)
        self._Panel1:addChild(nameNodeClone)
        local activeLab = nameNodeClone:getChildByName("activeLab")
        local activenum = nameNodeClone:getChildByName("activenum")
        local activeatt = nameNodeClone:getChildByName("activeatt")
        activeLab:setString("激活【" .. name .."】:")
        activenum:setString("+" .. qualityNum)
        activeatt:setString(qualityDesc)
        local posY = nameNode:getPositionY() - (i - 1) * nameNode:getContentSize().height
        nameNodeClone:setPositionY(posY)

        local activityNum,totalNum = self._modelMgr:getModel("StarChartsModel"):getBodyIdsByCatenaId(catenaid)
        if activityNum ==  totalNum then
          activeLab:setColor(UIUtils.colorTable.ccColorQuality2)
          activenum:setColor(UIUtils.colorTable.ccColorQuality2)
          activeatt:setColor(UIUtils.colorTable.ccColorQuality2)
        end


    end
end

function StarChartsKnowDialog:initComposeDetails()
    local trainShowTable = tab.starCharts[self._starId]["train_pos_show"]
    for i,v in pairs(trainShowTable) do
        local showLab = self:getUI("Panel2.bg.showLab" .. i)
        showLab:setString(self._trainShowTable[v][1])
        showLab:setColor(self._trainShowTable[v][2])
    end


    local trainmaxTable = tab.starCharts[self._starId]["train_max"]
    for i,v in pairs(trainmaxTable) do
        local trainmaxdesc = self:getUI("Panel2.bg.trainmaxdesc" .. i)
        trainmaxdesc:setString("(上限".. v ..")")
    end
end

function StarChartsKnowDialog:initStarSoulDetails()
    -- tip
    local desTip = self:getUI("Panel3.desTip")
    local tipDes =  self:getUI("Panel3.desTip.tipDes")
    tipDes:setString(lang("TIP_starCharts12"))
    
end

return StarChartsKnowDialog