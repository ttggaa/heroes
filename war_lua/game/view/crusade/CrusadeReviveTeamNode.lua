--[[
    Filename:    CrusadeDieTeamNode.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-12-03 16:47:29
    Description: File description
--]]

local CrusadeReviveTeamNode = class("CrusadeReviveTeamNode", BasePopView)


function CrusadeReviveTeamNode:ctor()
    CrusadeReviveTeamNode.super.ctor(self)
end


function CrusadeReviveTeamNode:onInit()
	self:registerClickEventByName("closeBtn", function ()
        self._callback(1)
        self:close()
        UIUtils:reloadLuaFile("crusade.CrusadeReviveTeamNode")
        UIUtils:reloadLuaFile("crusade.CrusadeReviveTeamCell")
    end)
end

function CrusadeReviveTeamNode:reflashUI(data)
    local bgLayer = ccui.Layout:create()
    bgLayer:setBackGroundColorOpacity(180)
    bgLayer:setBackGroundColorType(1)
    bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
    bgLayer:setTouchEnabled(true)
    bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self._widget:addChild(bgLayer, -1)


	self._curCrusadeId = data.crusadeId 
	self._curBuffId = data.buffId 
	self._token = data.token
    self._type = data.inType
	self._callback = data.callback
	local formationModel = self._modelMgr:getModel("FormationModel")
    local formationData = formationModel:getFormationDataByType(formationModel.kFormationTypeCrusade)
    -- formationData.filter = {403}

    self._scrollView = self:getUI("bg.bg1.scrollView")
    self._scrollView:removeAllChildren()
    -- local filters = string.split(formationData.filter,",")
  
    local x = 0 
    for k,v in pairs(formationData.filter) do
    	local  crusadeReviveTeamCell = self:createLayer("crusade.CrusadeReviveTeamCell")
    	crusadeReviveTeamCell:reflashUI({teamId = v, callback = function()
    		self:getCrusadeEventReward(v)
    	end})
    	crusadeReviveTeamCell:setPosition(x, 45)
    	self._scrollView:addChild(crusadeReviveTeamCell)
    	x = x + crusadeReviveTeamCell:getContentSize().width + 10
    end

    self._scrollMaxWidth = x
    self._scrollView:setInnerContainerSize(cc.size(x, self._scrollView:getContentSize().height))

    local step = self._scrollView:getContentSize().width / self._scrollMaxWidth

    local leftBtn = self:getUI("bg.bg1.leftBtn")
    local rightBtn = self:getUI("bg.bg1.rightBtn")
    local time = 0.5
    if #formationData.filter > 6 then
        leftBtn:setVisible(true)
        rightBtn:setVisible(true)

        self:registerClickEvent(leftBtn,function() 
            local backPercent = self._scrollView:getInnerContainer():getPositionX() / (self._scrollMaxWidth - self._scrollView:getContentSize().width)
            backPercent = math.abs(backPercent) - step
            if backPercent < 0 then 
                backPercent =  0
            end
            self._scrollView:scrollToPercentHorizontal(backPercent * 100, time, true)
        end)

        self:registerClickEvent(rightBtn,function() 
            local backPercent = self._scrollView:getInnerContainer():getPositionX() / (self._scrollMaxWidth - self._scrollView:getContentSize().width)
            backPercent = math.abs(backPercent) + step

            if backPercent  > 1 then 
                backPercent = 1
            end
            self._scrollView:scrollToPercentHorizontal(backPercent * 100, time, true)
        end)
    else
        leftBtn:setVisible(false)
        rightBtn:setVisible(false)
    end
end



function CrusadeReviveTeamNode:getCrusadeEventReward(inTeamId)
    self._viewMgr:showDialog("global.GlobalSelectDialog",
    {
        desc = "是否确认复活该兵团",
        button1 = "确定" ,
        button2 = "取消", 
        callback1 = function ()
            if self._type == 1 then   --一键扫荡选择
                local param = {id = self._curCrusadeId, args = {buffId = self._curBuffId, teamId = inTeamId}}
                self._serverMgr:sendMsg("CrusadeServer", "chooseSweepCrusadeBuff", param, true, {}, function (result)
                    return self:getCrusadeEventRewardFinish(result)
                end)
            else
                self._serverMgr:sendMsg("CrusadeServer", "getCrusadeEventReward", {id = self._curCrusadeId, token = self._token, args =json.encode({buffId = self._curBuffId, teamId = inTeamId})}, true, {}, function (result)
                    return self:getCrusadeEventRewardFinish(result)
                end)
            end
            
        end,
        callback2 = function()
        end
    }, true)
end

function CrusadeReviveTeamNode:getCrusadeEventRewardFinish(result)
	if result["d"] == nil then 
        return 
    end
    self._viewMgr:showTip(lang("CRUSADE_TIPS_11"))
    -- 关闭前一页面
    if self._callback ~= nil then
        self._callback(2)
    end
    self:close()
end


return CrusadeReviveTeamNode