--
-- Author: <ligen@playcrab.com>
-- Date: 2017-01-19 20:36:20
--
local HeroDuelEnteranceLayer = class("HeroDuelEnteranceLayer", BaseLayer)
function HeroDuelEnteranceLayer:ctor(data)
    HeroDuelEnteranceLayer.super.ctor(self)
    self._buyTimes = data.buyTimes or 0
    self._isOpen = data.open == 1
    self._enterCallBack = data.callBack
end

function HeroDuelEnteranceLayer:onInit()
    self._bg = self:getUI("bg")
    self:setContentSize(self._bg:getContentSize().width, self._bg:getContentSize().height)

    self._desLabel1 = self._bg:getChildByFullName("labelBg.desLab1")
    self._desLabel2 = self._bg:getChildByFullName("labelBg.desLab2")
    self._desLabel3 = self._bg:getChildByFullName("labelBg.desLab3")
    self._desLabel4 = self._bg:getChildByFullName("labelBg.desLab4")

    self._desLabel1:setString("使用随机英雄和兵团打造战队")
    self._desLabel2:setString("和全世界的领主进行对决")
    self._desLabel3:setString("您能坚持多久呢？")
    self._desLabel4:setString("坚持越久奖励越多！")
    self._desLabel4:setColor(cc.c3b(255, 238, 160))

    self._openNode = self._bg:getChildByFullName("openNode") 
    self._unopenNode = self._bg:getChildByFullName("unopenNode")
    self._unopenNode:setTouchEnabled(false)

    self._titleMc = mcMgr:createViewMC("yingxiongjiaofengzi_duizhanui", true, false)
    self._titleMc:setPosition(475, 463)
    self._bg:addChild(self._titleMc)

    self:reflashUI()
end


function HeroDuelEnteranceLayer:reflashUI()
    self._openNode:setVisible(self._isOpen)
    self._unopenNode:setVisible(not self._isOpen)

    if self._isOpen then
        local btnEnter = self._openNode:getChildByFullName("btnEnter")
        self:registerClickEvent(btnEnter, function()
            self:onEnterDuel()
        end )

        local costBg = self._openNode:getChildByFullName("costBg")
        local timesTxt = self._openNode:getChildByFullName("costBg.timesTxt")
        local timesLabel = self._openNode:getChildByFullName("costBg.timesLabel")
        local costIcon = self._openNode:getChildByFullName("costBg.costIcon")
        self._tipsLabel = self._openNode:getChildByFullName("tipsLabel")
        self._tipsLabel:setString(lang("HERODUEL15"))

        local _, ticketNum = self._modelMgr:getModel("ItemModel"):getItemsById(3042)
        local picPath = tab:Tool(3042).art
        self._ticketNum = ticketNum
        if self._ticketNum > 0 then
            timesTxt:setString("本次消耗")
            timesLabel:setString("1/" .. self._ticketNum)
            costIcon:loadTexture(picPath .. ".png" , 1)
        else
            -- 判断是否到最大购买次数
            local vipTab = tab.vip
            if self._buyTimes >= vipTab[#vipTab]["heroDuel"] then
                self._tipsLabel:setVisible(true)
                costBg:setVisible(false)

                UIUtils:setGray(btnEnter, true)
--                local btnEnterGray = self._openNode:getChildByFullName("btnEnterGray")
--                btnEnterGray:setVisible(true)
--                self:registerClickEvent(btnEnterGray, function()
--                    self:onEnterDuel()
--                end ) 
            else
                costBg:setVisible(true)
                UIUtils:setGray(btnEnter, false)

                timesTxt:setString("入场消耗")
                local costTempData = tab:Setting("DUEL_COST").value
                self._costValue = costTempData[self._buyTimes + 1] or costTempData[#costTempData]
                timesLabel:setString(tostring(self._costValue))
                costIcon:loadTexture(IconUtils.resImgMap["gem"], 1)
            end

        end


        costIcon:setScale(35 / costIcon:getContentSize().width)
        costIcon:setPositionX(timesLabel:getPositionX() + timesLabel:getContentSize().width + 20)

    else
        local btnUnopen = self._unopenNode:getChildByFullName("btnUnopen")
        UIUtils:setGray(btnUnopen, true)
        self:registerClickEvent(btnUnopen, function()
            self._viewMgr:showTip(lang("HERODUEL1"))

        end )

        local closeDesLabel = self._unopenNode:getChildByFullName("desLabel")
        closeDesLabel:setString(lang("HERODUEL12"))
        closeDesLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    end
end

function HeroDuelEnteranceLayer:onEnterDuel()
    if self._ticketNum and self._ticketNum > 0 then
        self:sendSignUp(0)
    else
        local vipLv = self._modelMgr:getModel("VipModel"):getData().level

        local vipTab = tab.vip
        local maxTimes = vipTab[#vipTab]["heroDuel"]
        -- 判断是否到达当前VIP等级最大购买数
        if self._buyTimes >= vipTab[vipLv]["heroDuel"] then
            -- 判断是否到最高VIP等级
            if vipLv < #vipTab then
                -- 判断升级VIP是否可以提高购买次数
                if self._buyTimes >= maxTimes then
                    self._viewMgr:showTip(lang("HERODUEL14"))
                else
				    self._viewMgr:showDialog("global.GlobalResTipDialog",{des1 = "今日购买入场次数已用完，提升VIP可增加购买次数"} or {},true)
                end
			else
				self._viewMgr:showTip(lang("TIP_GLOBAL_MAX_VIP"))
			end
            return
        else
             local leftTimes = maxTimes - self._buyTimes
             local desStr = "购买一次挑战次数(本周还可购买" .. leftTimes .. "次挑战次数)"
             DialogUtils.showBuyDialog({costNum = self._costValue,goods = desStr,callback1 = function( )
                 local gem = self._modelMgr:getModel("UserModel"):getData()["gem"]
                 if gem < self._costValue then
                    DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function( )
                        local viewMgr = ViewManager:getInstance()
                        viewMgr:showView("vip.VipView", {viewType = 0})
                    end})
                 else
                    self:sendSignUp(1)
                 end
             end})
        end
    end
end

-- @param tp 付费类型 0 入场券  1 钻石
function HeroDuelEnteranceLayer:sendSignUp(tp)
    self._serverMgr:sendMsg("HeroDuelServer", "hDuelSignUp", {type = tp}, true, {}, function(result)
        self._viewMgr:showDialog("heroduel.HeroDuelApplyView", {callBack = self._enterCallBack})
--        self._viewMgr:showView("heroduel.HeroDuelApplyView")
    end)
end

function HeroDuelEnteranceLayer:onTop()

end

function HeroDuelEnteranceLayer:onShow()


end

-- 交锋关闭
function HeroDuelEnteranceLayer:onHDuelClose()
    self._isOpen = false
    self._viewMgr:showTip(lang("HERODUEL16"))
    self:reflashUI()
end

-- 交锋开启
function HeroDuelEnteranceLayer:onHDuelOpen()
    self._isOpen = true
    self._viewMgr:showTip(lang("HERODUEL17"))
    self:reflashUI()
end
return HeroDuelEnteranceLayer