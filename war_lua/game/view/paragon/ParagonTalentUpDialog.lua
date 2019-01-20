--[[
 	@FileName 	ParagonTalentUpDialog.lua
	@Authors 	yuxiaojing
	@Date    	2018-09-20 20:45:31
	@Email    	<yuxiaojing@playcrab.com>
	@Description   描述
--]]

local ParagonTalentUpDialog = class("ParagonTalentUpDialog", BasePopView)

ParagonTalentUpDialog.qualityType = {
	[110] = "[全局]英雄攻击",
	[113] = "[全局]英雄防御",
	[116] = "[全局]英雄智力",
	[119] = "[全局]英雄知识"
}

function ParagonTalentUpDialog:ctor( params )
	self.super.ctor(self)

	params = params or {}
	self._talentId = params.talentId or 3011
	self._callback = params.callback
end

function ParagonTalentUpDialog:onInit(  )

	self._userModel = self._modelMgr:getModel("UserModel")
	self._paragonModel = self._modelMgr:getModel("ParagonModel")

	local title = self:getUI("bg.headNode.title")
    UIUtils:setTitleFormat(title, 1)

    local btn_close = self:getUI("bg.btn_close")
    self:registerClickEvent(btn_close, function (  )
    	self:close()
    end)

    self._sysTalentData = tab.paragonTalent[self._talentId]
    self._talentData = self._paragonModel:getParagonTalentData(self._talentId)

    self:updateTalentInfo()
end

function ParagonTalentUpDialog:showSuccessAnim( )
	local iconBg = self:getUI("bg.layer.iconBg")
	local mc = mcMgr:createViewMC("tianfushengji_tianfushengji", false, true)
	mc:setPosition(iconBg:getContentSize().width / 2, iconBg:getContentSize().height / 2)
	iconBg:addChild(mc, 2)
end

function ParagonTalentUpDialog:updateTalentInfo(  )
	local talentLevel = self._talentData.lv or 0
	local attrTalentLv = talentLevel
	if attrTalentLv <= 0 then
		attrTalentLv = 1
	end
	local totalLevel = #(self._sysTalentData.costGold or {})
	local layerNode = self:getUI("bg.layer")
	layerNode:getChildByFullName("talentName"):setString(lang(self._sysTalentData.name))
	layerNode:getChildByFullName("talentLevel"):setString("等级：" .. talentLevel .. "/" .. totalLevel)

	layerNode:getChildByFullName("desNode.des"):setString(lang(self._sysTalentData.des))
	local iconBg = layerNode:getChildByFullName("iconBg")
	iconBg:removeAllChildren()
	local icon = ccui.ImageView:create()
	icon:loadTexture(self._sysTalentData.icon .. ".png", 1)
	icon:setPosition(iconBg:getContentSize().width / 2, iconBg:getContentSize().height / 2)
	icon:setScale(1.2)
	iconBg:addChild(icon)

	local Attr = self._sysTalentData.Attr or {}
	local attrCondition = self._sysTalentData.attrCondition or {}
	for i = 1, 2 do
		local node = layerNode:getChildByFullName("desNode.teamAttr_" .. i)
		local attr = Attr[i]
		if not attr then
			node:setVisible(false)
		else
			node:setVisible(true)
			local attrDes = ""
			for k, v in pairs(attrCondition) do
				if v == 0 or (v > 100 and v < 300) then
					attrDes = attrDes .. lang("ability_team_camp" .. v)
				elseif v > 0 and v <= 100 then
					attrDes = attrDes .. lang("ability_system_pvp" .. v)
				else
					attrDes = attrDes .. lang("ability_team_posclass" .. (v - 300))
				end
				if k ~= #attrCondition then
					attrDes = attrDes .. "、"
				end
			end
			attrDes = attrDes .. lang("ATTR_" .. attr[1]) .. "+" .. (attr[2] * attrTalentLv)
			local dd = tab.attClient[attr[1]]
			if dd and dd.attType == 1 then
				attrDes = attrDes .. "%"
			end
			node:setString(attrDes)
		end
	end

	local heroNode = layerNode:getChildByFullName("desNode.heroAttr")
	local heroAttr = self._sysTalentData.heroAttr or {}
	local attrStr = ""
	for k, v in pairs(heroAttr) do
		local attrNum = 0
		for i = 2, attrTalentLv + 1 do
			attrNum = attrNum + heroAttr[k][i]
		end
		attrStr = attrStr .. ParagonTalentUpDialog.qualityType[v[1]] .. "+" .. attrNum
		if k ~= #heroAttr then
			attrStr = attrStr .. "  "
		end
	end
	heroNode:setString(attrStr)

	local consumeNode = self:getUI("bg.layer.conumeNode")
	local btn_up = self:getUI("bg.layer.btn_up")
	local unlockLab = self:getUI("bg.layer.unlockLab")
	local img_max = self:getUI("bg.layer.img_max")

	if talentLevel >= totalLevel then
		consumeNode:setVisible(false)
		btn_up:setVisible(false)
		unlockLab:setVisible(false)
		img_max:setVisible(true)
		return
	else
		img_max:setVisible(false)
	end

	-- consume
	local costGold = self._sysTalentData.costGold or {}
	local costTalentPoint = self._sysTalentData.costTalentPoint or {}
	local costGoldNum = costGold[talentLevel + 1] or 0
	local costTalentPointNum = costTalentPoint[talentLevel + 1] or 0
	local curGoldNum = self._userModel:getData().gold
	local curTalentPointNum = self._userModel:getData().pTalentPoint or 0
	
	consumeNode:setVisible(true)
	consumeNode:getChildByFullName("goldNum"):setString(costGoldNum)
	consumeNode:getChildByFullName("talentNum"):setString(costTalentPointNum)

	self._upState = 0
	consumeNode:getChildByFullName("goldNum"):setColor(cc.c4b(115, 85, 61, 255))
	consumeNode:getChildByFullName("talentNum"):setColor(cc.c4b(115, 85, 61, 255))
	if curGoldNum < costGoldNum then
		self._upState = 1
		consumeNode:getChildByFullName("goldNum"):setColor(cc.c4b(255, 0, 0, 255))
	end
	if curTalentPointNum < costTalentPointNum then
		self._upState = 2
		consumeNode:getChildByFullName("talentNum"):setColor(cc.c4b(255, 0, 0, 255))
	end

	local isCanUp = true
	local unlockCondition = self._sysTalentData.unlock
	local cTalentId = nil
	local cTalentLevel = nil
	local cTalentData = nil
	local cLevel = nil
	if unlockCondition then
		cTalentId = unlockCondition[1]
		cTalentLevel = unlockCondition[2]
		if cTalentId and cTalentLevel then
			cTalentData = self._paragonModel:getParagonTalentData(cTalentId)
			cLevel = cTalentData.lv or 0
			if cLevel < cTalentLevel then
				isCanUp = false
			end
		end
	end

	if isCanUp then
		btn_up:setVisible(true)
		unlockLab:setVisible(false)
		if self._upState == 0 then
			UIUtils:setGray(btn_up, false)
			self:registerClickEvent(btn_up, function (  )
		    	self._serverMgr:sendMsg("ParagonTalentServer", "upgradePTalent", {pTalentId = self._talentId}, true, {}, function(success, data)
		    		self._talentData = self._paragonModel:getParagonTalentData(self._talentId)
	    			self:updateTalentInfo()
	    			self:showSuccessAnim()
	    			if self._callback then
			    		self._callback()
			    	end
	            end)
		    end)
		else
			UIUtils:setGray(btn_up, true)
			self:registerClickEvent(btn_up, function (  )
		    	self._viewMgr:showTip(lang("TIP_ParagonTalent_no_resource"))
		    end)
		end
	else
		btn_up:setVisible(false)
		unlockLab:setVisible(true)
		local cData = tab.paragonTalent[cTalentId]
		unlockLab:setString("开启条件：" .. lang(cData.name) .. " 升级" .. cTalentLevel .. "级（" .. cLevel .. "/" .. cTalentLevel .. "）")
	end

end

return ParagonTalentUpDialog