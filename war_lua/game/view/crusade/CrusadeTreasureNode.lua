--[[
    Filename:    CrusadeTreasureNode.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-12-04 17:37:29
    Description: File description
--]]

local CrusadeTreasureNode = class("CrusadeTreasureNode", BasePopView)

function CrusadeTreasureNode:ctor()
    CrusadeTreasureNode.super.ctor(self)

end

function CrusadeTreasureNode:onInit()
	self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
    end)


    local bgLayer = ccui.Layout:create()
    bgLayer:setBackGroundColorOpacity(180)
    bgLayer:setBackGroundColorType(1)
    bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
    bgLayer:setTouchEnabled(true)
    bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self._widget:addChild(bgLayer, -1)
    
    local temp1 = self:getUI("bg.Image_33")

    local amin1 = mcMgr:createViewMC("suipianguangxiao_crusadegettr", true, false, nil, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    amin1:setPosition(temp1:getContentSize().width/2, temp1:getContentSize().height/2)
    temp1:addChild(amin1, -1)

end


function CrusadeTreasureNode:reflashUI(data)
	self._curCrusadeId = data.crusadeId
    self._buildId = data.crusadeData.buildId
    self._token = data.netData.token
    self._callback = data.callback
    -- self._reward = data.netData.reward
    local sysCrusadeBuild = tab:CrusadeBuild(self._buildId)

    local tipLab = self:getUI("bg.Label_39")
    tipLab:enableOutline(cc.c4b(60, 30, 10, 255), 2)

    local descBg = self:getUI("bg.descBg")
    local richText = RichTextFactory:create(lang(sysCrusadeBuild.des1), 600, 100)
    richText:formatText()

    richText:setPosition(descBg:getContentSize().width/2, descBg:getContentSize().height/2)
    descBg:addChild(richText)


    self:registerClickEventByName("bg.enterBtn", function ()
    	self:getCrusadeEventReward()
    end)
end



function CrusadeTreasureNode:getCrusadeEventReward()
    self._serverMgr:sendMsg("CrusadeServer", "getCrusadeEventReward", {id = self._curCrusadeId, token = self._token}, true, {}, function (result)
        return self:getCrusadeEventRewardFinish(result)
    end)
end

function CrusadeTreasureNode:getCrusadeEventRewardFinish(result)
    if result["d"] == nil then 
        return 
    end
    local crusadeModel = self._modelMgr:getModel("CrusadeModel")
    local usePcs = crusadeModel:getData().usePcs
    local needPcs = crusadeModel:getData().needPcs
    local unusePcs = crusadeModel:getData().unusePcs
    local amin = false
    if (usePcs + unusePcs) == needPcs then 
        crusadeModel:getData().playEffect = 1
    end

    if (usePcs + unusePcs) <= needPcs then 
        amin = true
    else
        self._callback(false)
        self:close(true)
        return
    end
    self:setVisible(false)
    audioMgr:playSound("MapFrag")
    self._viewMgr:showDialog("crusade.CrusadeTreasureMapNode", {
            amin = amin,
            callback = function(inNeedScroll)
            if self._callback ~= nil then 
                self._callback(inNeedScroll)
            end
    		self:close(true)
    	end}, true)  
end

return CrusadeTreasureNode