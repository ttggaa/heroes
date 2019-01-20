
--author lannan

local MFAlchemyQuickAddDialog = class("MFAlchemyQuickAddDialog",BasePopView)
	
function MFAlchemyQuickAddDialog:ctor(data)
	MFAlchemyQuickAddDialog.super.ctor(self)
	self._slotIndex = data.index
	self._nowUnlock = data.unlockSlot
	
	self._alchemyModel = self._modelMgr:getModel("AlchemyModel")
end

function MFAlchemyQuickAddDialog:onInit()
	local closeBtn = self:getUI("bg.closeBtn")
	self:registerClickEvent(closeBtn, function()
		if OS_IS_WINDOWS then
			UIUtils:reloadLuaFile("MF.MFAlchemyQuickAddDialog")
		end
		self:close()
	end)
	
	local title = self:getUI("bg.titleBg.titleLab")
	title:setString("材料充足配方")
	UIUtils:setTitleFormat(title, 7)
	
	self._formulaData = self._alchemyModel:getQuickFormulaData()
	
	self:loadFormulaData()
end

function MFAlchemyQuickAddDialog:loadFormulaData()
	local scroll = self:getUI("bg.scroll")
	local tbTitleNode = {}
	local tbInfoNode = {}
	for i,v in pairs(self._formulaData) do
		local titleBg = ccui.ImageView:create()
		titleBg:loadTexture("alchemy_closeUnderImg.png", 1)
		scroll:addChild(titleBg)
		table.insert(tbTitleNode, titleBg)
		
		local nodeHeight = 90*table.nums(v)
		local bgImg1 = ccui.ImageView:create()
		bgImg1:loadTexture("")
		bgImg1:setScale9Enabled(true)
		bgImg1:ignoreContentAdaptWithSize(false)
		bgImg1:setCapInsets(cc.rect(7, 7, 1, 1))
		bgImg1:setContentSize(cc.size(titleBg:getContentSize().width, nodeHeight))
		scroll:addChild(bgImg1)
		
		local bgImg2 = ccui.ImageView:create()
		bgImg2:loadTexture("")
		bgImg2:setScale9Enabled(true)
		bgImg2:ignoreContentAdaptWithSize(false)
		bgImg2:setCapInsets(cc.rect(3, 3, 1, 1))
		bgImg2:setContentSize(cc.size(titleBg:getContentSize().width-8, nodeHeight-4))
		bgImg2:setPosition(cc.p(bgImg1:getContentSize().width/2, bgImg1:getContentSize().height/2+2))
		bgImg1:addChild(bgImg2)
		self:loadFormulaDetail(v, bgImg1)
		
		print("debugData")
	end
	
end

return MFAlchemyQuickAddDialog