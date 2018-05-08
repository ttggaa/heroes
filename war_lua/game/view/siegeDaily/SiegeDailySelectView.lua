--[[
    @FileName   SiegeDailySelectView.lua
    @Authors    hexinping
    @Date       2017-09-16
    @Email      <hexinping@playcrad.com>
    @Description   日常玩法选择界面UI
--]]

local  SiegeDailySelectView = class("SiegeDailySelectView",BasePopView)

local pageVar = {
    attackType        = 1,
    defendType        = 2,
    delayTime         = 1000,
    delayActinoTime   = 200,
    offset            = 600,   -- 动画初始水平位移     
    startAngle        = 50,    -- 动画初始旋转角度
    endAngle          = 3,     -- 动画结束旋转角度
    pagePlist         = {{"asset/ui/siegeDaily.plist", "asset/ui/siegeDaily.png"}},
}

function SiegeDailySelectView:ctor(params)
    self.super.ctor(self)
    self._dailySiegeModel = self._modelMgr:getModel("DailySiegeModel")
    self:setListenReflashWithParam(true)
    self:listenReflash("DailySiegeModel", self.onModelReflash)
end


function SiegeDailySelectView:createAction(node,startP,angle)
    node:setTouchEnabled(false)
    local action = cc.Spawn:create(
                        cc.EaseIn:create(cc.MoveTo:create(0.3, startP), 1),
                        cc.RotateTo:create(0.3, angle),
                        cc.CallFunc:create(function ()
                            ScheduleMgr:delayCall(pageVar.delayActinoTime, self, function()
                                node:setVisible(true)
                            end)
                        end)
                        )
    local seq = cc.Sequence:create(
        action,
        cc.RotateTo:create(0.2, 0),
        cc.CallFunc:create(function ()
            node:setTouchEnabled(true)
    end))
    return  seq
end

function SiegeDailySelectView:addAction()
    local startP1 = cc.p(self._attackBtn:getPosition())
    local startP2 = cc.p(self._defendBtn:getPosition())
    self._attackBtn:setPositionX(startP1.x - pageVar.offset)
    self._defendBtn:setPositionX(startP2.x + pageVar.offset)
    self._attackBtn:setRotation(pageVar.startAngle)
    self._defendBtn:setRotation(-pageVar.startAngle)
    self._attackBtn:setVisible(false)
    self._defendBtn:setVisible(false)

    local seq1 = self:createAction(self._attackBtn, startP1, -pageVar.endAngle)
    local seq2 = self:createAction(self._defendBtn, startP2, pageVar.endAngle)
    self._attackBtn:runAction(seq1)
    self._defendBtn:runAction(seq2)

    self:addCircleAction("bg.attackBtn.circle")
    self:addCircleAction("bg.defendBtn.circle")
end

function SiegeDailySelectView:addCircleAction(name)
    local circle = self:getUI(name)
    local getMC = mcMgr:createViewMC("rukouxuanzeguang_gongcheng", true)
    getMC:setPlaySpeed(1, true)
    getMC:setPosition(circle:getContentSize().width / 2 - 2, circle:getContentSize().height / 2)
    circle:addChild(getMC)
end

function SiegeDailySelectView:onInit()

    self._attackBtn = self:getUI("bg.attackBtn")
    self._defendBtn = self:getUI("bg.defendBtn")
    self:addAction()

    local reviewBtn = self:getUI("bg.reviewBtn")
    reviewBtn:setVisible(true)

    local label = self:getUI("bg.reviewBtn.label")
    label:setFontName(UIUtils.ttfName)

    self:registerClickEvent(reviewBtn, function()
        self._viewMgr:showDialog("siegeDaily.SiegeDailyPlotReviewView")
    end)
   
    self:registerClickEventByName("bg.closeBtn", function()
        self:close()
        if self._callBack then
            self._callBack()
        end
        UIUtils:reloadLuaFile("siegeDaily.SiegeDailySelectView")
    end)

    self:registerClickEvent(self._attackBtn, function()
        self._viewMgr:showView("siegeDaily.SiegeDailyView",{utype = pageVar.attackType, container = self}) 
        -- ScheduleMgr:delayCall(pageVar.delayTime, self, function()
        --     self:close()
        -- end)
    end)

    self:registerClickEvent(self._defendBtn, function()
        self._viewMgr:showView("siegeDaily.SiegeDailyView",{utype = pageVar.defendType, container = self})
        -- ScheduleMgr:delayCall(pageVar.delayTime, self, function()
        --     self:close()
        -- end)
    end)

    self._attackRemain = self:getUI("bg.attackBtn.txt")
    self._defendRemain = self:getUI("bg.defendBtn.txt")
    self._attackRemain:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._defendRemain:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._serverMgr:sendMsg("DailySiegeServer", "getDailySiegeInfo", {}, true, {},function (success)
        if success then
            self:update()
        end 
    end)
end


function SiegeDailySelectView:updateDropReward(node, uType)
    local cfg = self._dailySiegeModel:getCardConfigData(uType)
    local drops = self._dailySiegeModel:getDropGoods(cfg.id)
    local data = drops[1]
    local itemId = IconUtils.iconIdMap[data.type]
    local itemData = tab:Tool(itemId)
    local iconPng = itemData.art .. ".png"
    local reward = node:getChildByFullName("rewardPanel.reward")
    reward:loadTexture(iconPng, 1)
end

function SiegeDailySelectView:update()
    self:updateRemainNum(self._attackRemain, pageVar.attackType)
    self:updateRemainNum(self._defendRemain, pageVar.defendType)

    -- update drop reward
    self:updateDropReward(self._attackBtn, pageVar.attackType)
    self:updateDropReward(self._defendBtn, pageVar.defendType)
end

function SiegeDailySelectView:updateRemainNum(node, uType)
    local total, num = self._dailySiegeModel:getRemainNum(uType)
    local color = cc.c4b(133, 244, 126, 255)
    if num == 0 then
        color = UIUtils.colorTable.ccColorQuality1
    end 
    node:setTextColor(color)
    node:setString("今日剩余次数:"..num.."/"..total)
end

function SiegeDailySelectView:_clearVars()
    self._attackRemain = nil
    self._defendRemain = nil
    self._attackBtn    = nil
    self._defendBtn    = nil
end

function SiegeDailySelectView:onDestroy()
    self:_clearVars()
end

function SiegeDailySelectView:getAsyncRes()
    return pageVar.pagePlist
end

function SiegeDailySelectView:onModelReflash(event)
    if event == "refleshUIEvent" then
        self._dailySiegeModel:resetDailyNum()
        self:update()
    end
end


return SiegeDailySelectView