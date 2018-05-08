--[[
    Filename:    CrusadeTreasureMapNode.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-12-04 17:37:36
    Description: 藏宝图界面
--]]

local CrusadeTreasureMapNode = class("CrusadeTreasureMapNode", BasePopView)

function CrusadeTreasureMapNode:ctor()
    CrusadeTreasureMapNode.super.ctor(self)
end

function CrusadeTreasureMapNode:onInit()
	self:registerClickEventByName("bg.closeBtn", function ()
        self:closeNode()
    end)
end

function CrusadeTreasureMapNode:reflashUI(data)
	-- dump(data, "CrusadeTreasureMapNode", 10)
	if data.amin == nil then 
		self._amin = false
	else
		self._amin = data.amin 
	end
	self._callback = data.callback
	local crusadeModel = self._modelMgr:getModel("CrusadeModel")
	local usePcs = crusadeModel:getData().usePcs
	local needPcs = crusadeModel:getData().needPcs
	local unusePcs = crusadeModel:getData().unusePcs
	local pcsPosition = crusadeModel:getData().pcsPosition
	self._playEffect = crusadeModel:getData().playEffect
	if usePcs == needPcs and self._playEffect == 1 then
		self._amin = true
	end

	--by wangyan
	local tempLab = self:getUI("bg.mapBg1.tipDes")
	if usePcs == needPcs then
		tempLab:setString(lang("CRUSADE_TIPS_20"))
	else
		tempLab:setString(lang("CRUSADE_TIPS_14"))
	end

	crusadeModel:getData().playEffect = 0
	local positionId = math.ceil(((pcsPosition[1] + pcsPosition[2] - 1) / 2))
	local sysCrusadeTreaPosi = tab:CrusadeTreaPosi(positionId)

	local mapBg = self:getUI("bg.mapBg")

	local mapSp = cc.Sprite:create("asset/uiother/crusade/" .. sysCrusadeTreaPosi.res .. ".jpg")
    mapSp:setPosition(mapBg:getContentSize().width/2, mapBg:getContentSize().height/2 - 10)
    mapSp:setAnchorPoint(0.5, 0.5)
    mapSp:setScale(1.62)
    mapBg:addChild(mapSp)

    local zOrderMc = {3, 4, 6, 7, 5, 3, 5}
    for i=1, 7 do
    	local mapsMc = mcMgr:createViewMC("cangbaotu"..i.."_crusadechip1", false)
		mapsMc:setPosition(mapBg:getContentSize().width * 0.5, mapBg:getContentSize().height * 0.5)
		mapsMc:setName("t"..i)
		mapsMc:gotoAndStop(1)
		mapsMc:setLocalZOrder(zOrderMc[i])
		mapBg:addChild(mapsMc)
    end
   
	local tempUsePcs = usePcs 

	local showTip = self:getUI("bg.showTip")
	showTip:setCascadeOpacityEnabled(true, true)
	showTip:setOpacity(0)

	if self._amin == true then
		tempUsePcs = tempUsePcs - 1
		local closeBtn = self:getUI("bg.closeBtn")
		closeBtn:setVisible(false)		
	else
		if usePcs ~= needPcs then
			showTip:setOpacity(0)
		else
			showTip:setOpacity(255)
		end
	    self:registerClickEvent(self._widget, function ()
	        self:closeNode()
	    end)
	end

	for i=1, tempUsePcs do
		local index = pcsPosition[i]

		local clip1 = mapBg:getChildByFullName("t" .. index)
		clip1:setVisible(false)

	end

	if self._amin == true then
		local index = pcsPosition[usePcs]
		local chip1 = mapBg:getChildByFullName("t" .. index)
		chip1:gotoAndPlay(1)
		chip1:addCallbackAtFrame(25, function()
			chip1:setVisible(false)
			local closeBtn = self:getUI("bg.closeBtn")
			closeBtn:setVisible(true)

            self:registerClickEvent(self._widget, function ()
		        self:closeNode()
		    end)
		    if usePcs == needPcs and self._playEffect == 1 then
				local mc = mcMgr:createViewMC("xiaochanzi_crusadeopen", true, false)
		    	mc:setPosition(cc.p(sysCrusadeTreaPosi.posi2[1], sysCrusadeTreaPosi.posi2[2]))
		    	mapBg:addChild(mc,6)
			end
			end)

    else
    	if usePcs == needPcs and self._playEffect == 1 then
			local mc = mcMgr:createViewMC("xiaochanzi_crusadeopen", true, false)
	    	mc:setPosition(cc.p(sysCrusadeTreaPosi.posi2[1], sysCrusadeTreaPosi.posi2[2]))
	    	mapBg:addChild(mc,6)
		end
	end
end

function CrusadeTreasureMapNode:closeNode()
	local crusadeModel = self._modelMgr:getModel("CrusadeModel")
	local usePcs = crusadeModel:getData().usePcs
	local needPcs = crusadeModel:getData().needPcs
	local userInfo = self._modelMgr:getModel("UserModel"):getData()
	local needScroll = false
	if self._playEffect == 1 then 
		needScroll = true
	end
	if self._callback ~= nil then 
		self._callback(needScroll)
	end
	-- UIUtils:reloadLuaFile("crusade.CrusadeTreasureMapNode")
	self:close()
end

return CrusadeTreasureMapNode