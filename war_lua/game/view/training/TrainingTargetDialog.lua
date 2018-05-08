--
-- Author: huangguofang
-- Date: 2016-10-18 17:34:28
-- Description: 训练所规则展示面板
local TrainingTargetDialog = class("TrainingTargetDialog",BasePopView)
function TrainingTargetDialog:ctor(data)
    self.super.ctor(self)
    self._trainingId = data.trainingId
    self._trainingData = data.trainingData
end


-- 初始化UI后会调用, 有需要请覆盖
function TrainingTargetDialog:onInit()

	if not self._trainingData then
		self._trainingData = tab:Training(tonumber(self._trainingId))
	end
	-- self:getUI("blackBg"):setOpacity(0)
	self:registerClickEventByName("bg.touchPanel", function(  )
        self:close()
        UIUtils:reloadLuaFile("training.TrainingTargetDialog")
    end)

	self:registerClickEventByName("bg.titleBg.closeBtn", function(  )
        self:close()
        UIUtils:reloadLuaFile("training.TrainingTargetDialog")
    end)

    self._roleImg = self:getUI("bg.roleImg")
    self._roleImg:loadTexture("asset/uiother/guide/guideImage_leftRole.png")

	-- titleBg
	self._titleTxt = self:getUI("bg.titleBg.titleTxt")    
    UIUtils:setTitleFormat(self._titleTxt, 6)

    self._rulePanel = self:getUI("bg.rulePanel")
    local startPosY = self._rulePanel:getContentSize().height - 40
    for i=1,3 do
    	if self._trainingData["explain" .. i] then
		    --菱形
		    local txt1 = ccui.Text:create()
		    txt1:setFontSize(16)
		    txt1:setFontName(UIUtils.ttfName)
		    txt1:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
		 --    txt1:ignoreContentAdaptWithSize(false)
			-- txt1:setSize(370,35)
		    txt1:setAnchorPoint(cc.p(1,0.5))
		    txt1:setString("◆  ")
		    txt1:setPosition(15, startPosY - (i-1)*35)
		    self._rulePanel:addChild(txt1)

		    local rtxStr = lang(self._trainingData["explain" .. i])
		    local txt = RichTextFactory:create(rtxStr,374,50)  
		    txt:setPosition(195, startPosY - (i-1)*35)
		    self._rulePanel:addChild(txt)

		end
    end

    local name = self:getUI("bg.desImg.name")
    name:setColor( UIUtils.colorTable.ccUIBaseColor1)
    name:enable2Color(1, UIUtils.colorTable.ccUIBasePromptColor)
    name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
    name:setFontName(UIUtils.ttfName)

    self._desTxt = self:getUI("bg.desImg.desTxt")
    self._desTxt:setString(lang(self._trainingData.explain))
    -- self._desTxt:setString(self._trainingData.explain)
end


-- 接收自定义消息
function TrainingTargetDialog:reflashUI(data)

end

return TrainingTargetDialog
