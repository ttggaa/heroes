--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-07-13 22:47:24
--
--[[UI结构
左边            				右边
skillPanel  展示编组技			detailPanel 展示选中的技能详情
能内容	编组操作				editPanel   编辑编组信息 新建 改名
								listPanel 	展示技能列表
								tableBg 	技能列表底板，table父节点
辅助cell 
skillCell   技能列表cell	
--]]
local TreasureSelectSkillView = class("TreasureSelectSkillView",BasePopView)
function TreasureSelectSkillView:ctor()
    self.super.ctor(self)
    self._skillTabMap = {
        tab.heroMastery,
        tab.playerSkillEffect,
        tab.skillPassive,
        tab.skillCharacter,
        tab.skillAttackEffect,
        tab.skill,
    }
    self._skillDCache = {}
    self._skillLvs    = {}

    -- 临时数据结构
    -- 编组信息
    self._tFModel   = self._modelMgr:getModel("TformationModel")
    self._formData  = self._tFModel:getData()
    local lastFormId = SystemUtils.loadAccountLocalData("lastTFormId")
    self._curFormId = lastFormId or 1
    self._curFormD  = self._formData[self._curFormId] or {}
    self._formFixedSkill = {}

    dump(self._formData,"formData...-----------------------",10)

    -- 当前选择的node相关信息
    self._curInfo = {
	    skillNode = nil,
	    skillId   = nil,
	    formId 	  = nil,
	    slotIdx   = nil,
	    preSkillNode = nil
	}
end


function TreasureSelectSkillView:getAsyncRes()
    return
    {
        { "asset/ui/treasureSkill.plist", "asset/ui/treasureSkill.png" },
    }
end

-- 初始化UI后会调用, 有需要请覆盖
function TreasureSelectSkillView:onInit()
	self:getUI("bg.layer.bgl"):loadTexture("asset/bg/bg_magic.png")
    self:getUI("bg.layer.bgr"):loadTexture("asset/bg/bg_magic.png")
	self:registerClickEventByName("bg.layer.closeBtn", function()
		SystemUtils.saveAccountLocalData("lastTFormId",self._curFormId)
        self:close()
        UIUtils:reloadLuaFile("treasure.TreasureSelectSkillView")
    end )

    -- 生成列表 数据
    self._detailPanel = self:getUI("bg.layer.detailPanel")
    self._detailPanel:setOpacity(0)
    self._detailPanel:setVisible(false)
    self:initSkillListData()
    self:initDetailPanel()
    -- 初始化板子
	self._formListView = self:getUI("bg.layer.editPanel.formListView")
	self._formListView:setVisible(false)
	self._formName = self:getUI("bg.layer.editPanel.listBtn.formName")
	self:reflashEditName()
	self._editPanel = self:getUI("bg.layer.editPanel")
	self._editPanel:setVisible(true)
    self:initEditPanel()
    -- 初始化左侧技能展示板子
    self._skillPanel = self:getUI("bg.layer.skillPanel")
    self._skillNodes = {}
    self:initSkillPanel()
    -- 初始化列表
    self._tableBg = self:getUI("bg.layer.tableBg")
	-- cell原型
    self._skillCell = self:getUI("bg.layer.skillCell")
    self._noneDes = self:getUI("bg.layer.noneDes")
    self._noneDes:setVisible(false)
    self._noneDes:removeChildByTag(3613330)
    self._noneDes:removeChildByTag(3613332)
    self._noneDes:removeChildByTag(3613334)
    -- 无内容时展示
    local noneDes = lang("BAOWUSKILL_EMPTY")
    -- print("noneDes,,,,,",noneDes)
    rtx = RichTextFactory:create("[color = 8a5c1d,fontsize=18]" .. noneDes ..  "[-]", 255, 300)
    -- rtx:setVerticalSpace(-2)
    rtx:formatText()
    rtx:setName("noneDes")
    local w = rtx:getInnerSize().width
    local h = rtx:getInnerSize().height
    rtx:setPosition(w/2, -h/2+125)
    self._noneDes:addChild(rtx, 99)
    

    self._listPanel = self:getUI("bg.layer.listPanel")
    self._listPanel:setVisible(false)
    self:initListPanel()
    self:onOpenView()
    self:reflashSkillSlot()
    self:filterData()

    -- 监听事件
    self:listenReflash("TformationModel",function( )
    	self._formData  = self._tFModel:getData()
	    self._curFormD  = self._formData[self._curFormId] or {}
    	self:reflashSkillSlot()
	    if self._curSkillNode and self._curSkillNode._skillType then
		    self:filterData(self._curSkillNode._skillType)
		else
			self:filterData()
		end
    end)
end

-- 接收自定义消息
function TreasureSelectSkillView:reflashUI(data)

end

-- 刷新技能槽位
function TreasureSelectSkillView:reflashSkillSlot( )
	if not self._curFormD then return end 
	for slotId,comId in pairs(self._curFormD) do
		print("slotId,comId",slotId,comId)
		local skillNode = self._skillNodes[tonumber(slotId)]
		if skillNode then
			local skillImg = skillNode:getChildByFullName("skillImg")
			if tonumber(comId) ~= 0 then
				local skillId  = self._comSkillMap[comId]
				if skillId then
					skillNode._status  = "fixed"
					skillNode._skillId = skillId
					print("fixed is ",slotId)
					self:setSkillImg(skillImg,skillId)
				end
			else
				skillNode._skillId = nil 
				skillNode._status  = "empty"
				skillImg:loadTexture("hero_skill_bg2_forma.png",1)
			end
		end
	end
end

----------------- 辅助方法 begin -----------------
function TreasureSelectSkillView:setSkillImg( skillImg,skillId )
	if not skillId then return end 
	if not self._skillImgMap  then
		self._skillImgMap = {}
	end
	local skillImgName = self._skillImgMap[skillId]
	if not skillImgName then
		local skillD = { }
		if not self._skillDCache[skillId] then
		    for k, v in pairs(self._skillTabMap) do
		        if v[skillId] and(v[skillId].art or v[skillId].icon) then
		            skillD = clone(v[skillId])
		            break
		        end
		    end
		    self._skillDCache[skillId] = skillD
		else
			skillD = self._skillDCache[skillId]
		end
		if not skillD then return end
		local fu = cc.FileUtils:getInstance()
		local art = skillD.art or skillD.icon
	    -- print("art.......", skillId, art)
	    if art == nil then
	        dump(skillD,skillId)
	    end
	    if fu:isFileExist(IconUtils.iconPath .. art .. ".jpg") then
	    	skillImgName = IconUtils.iconPath .. art .. ".jpg"
	    else
	    	skillImgName = IconUtils.iconPath .. art .. ".png"
	    end
	end
	if skillImgName then
		self._skillImgMap[skillId] = skillImgName
		skillImg:loadTexture(skillImgName,1)
	end
	return skillImgName
end
----------------- 辅助方法   end -----------------


-- 刷新技能详情
function TreasureSelectSkillView:reflashTreasureInfo( skillId,tp )
	local skillD = self._skillDCache[skillId]
	-- 刷名字
	local skillName = self:getUI("bg.layer.detailPanel.skillBg.skillName")
	skillName:setString(lang(skillD.name))
	-- 刷icon
	local skillImg = self:getUI("bg.layer.detailPanel.skillBg.skillImg")
	self:setSkillImg(skillImg,skillId)
    skillImg:setScale(80 / skillImg:getContentSize().width)
    -- 刷lv
    local stage = self._skillLvs[skillId] or 0
    local skillLv = self:getUI("bg.layer.detailPanel.skillBg.skillLv")
    skillLv:setColor(UIUtils.colorTable.ccUIBaseColor9)
    skillLv:setString("Lv." .. stage)

    local typeLab = self:getUI("bg.layer.detailPanel.skillBg.typeLab") 
	typeLab:setString(lang("BAOWUADDTAG_" .. tp))
	local skillTag = self:getUI("bg.layer.detailPanel.skillBg.skillTag") 
	local colorMap = {"blue","purple","green",[9] = "green"}
	skillTag:loadTexture((colorMap[tp] or "green") .. "Tag_treasureSkill.png", 1)

    local desScroll = self._detailPanel:getChildByName("desScroll")
    -- desScroll:removeAllChildren()
    -- 刷描述
    local rtx = desScroll:getChildByName("skillDes")
    if rtx then
    	rtx:removeFromParent()
    end
    local skillDes = self:generateDes(skillId,math.max(stage,1),tp)
    -- print("skillDes,,,,,",skillDes)
    rtx = RichTextFactory:create("[color = 8a5c1d,fontsize=18]" .. skillDes ..  "[-]", 260, 300)
    -- rtx:setVerticalSpace(-2)
    rtx:formatText()
    rtx:setName("skillDes")
    local w = rtx:getInnerSize().width
    local h = rtx:getInnerSize().height
    -- local realW,realH = rtx:getRealSize().width,rtx:getRealSize().height
    -- print("···",h,realH)
    rtx:setPosition(w/2+20, -h/2+240)
    desScroll:addChild(rtx, 99)
    if stage == 0 then UIUtils:setGray(rtx,true) end
    UIUtils:alignRichText(rtx, { hAlign = "top"})
    local attH = self:generateExAtts(self._skillComMap[skillId],stage,desScroll,-15,-h-10)
    local desH = desScroll:getInnerContainerSize().height
    print("desH:::::::::::",desH)
    rtx:setPosition(w/2+20, -h/2+desH)
end

-- 不同阶数下 额外加成
-- 不同阶数下 额外加成
function TreasureSelectSkillView:generateExAtts( id, stage, node, offsetx, offsety )
    local disData = tab.comTreasure[id]
    local unlockData = disData.unlockaddattr
    local addAttrsData = disData.addattr
    local nextBuffId 
    for i,v in ipairs(unlockData) do
        if unlockData[i] > stage and not nextBuffId then
            nextBuffId = unlockData[i]
        end 
    end
    if not nextBuffId then nextBuffId = table.nums(tab.devComTreasure) + 1 end
    if not self._addAttrItems then
        self._addAttrItems = {}
    end
    local scrollHeight = 0
    -- 创建额外加成显示
    for i=2,#unlockData do
        -- if unlockData[i] > nextBuffId then break end
        local item = self._addAttrItems[i]
        if not item then
            item = ccui.Layout:create()
            -- item:setBackGroundColorOpacity(255)
            -- item:setBackGroundColorType(1)
            -- item:setBackGroundColor(cc.c4b(207, 192, 175, 40))
            item:setBackGroundImage("globalPanelUI11_0419DayGoodsCellBg.png", 1)
            item:setBackGroundImageCapInsets(cc.rect(8,11,1,1))
            item:setBackGroundImageScale9Enabled(true)
            item:setOpacity(0 or 255*((i+1)%2))
            item:setContentSize(378, 20)
            item:setAnchorPoint(0,0)
            item:setPosition(offsetx,offsety-i*20)
            node:addChild(item)
            self._addAttrItems[i] = item
        end 

        -- local stageUpImg = item:getChildByName("upStage")
        -- if not stageUpImg then
        --     stageUpImg = ccui.ImageView:create()
        --     stageUpImg:loadTexture("comAttr_null_treasure.png",1)
        --     stageUpImg:setPosition(7,16)
        --     stageUpImg:setAnchorPoint(0,0.5)
        --     stageUpImg:setName("upStage")
        --     -- stageUpImg:setScale(0.8)
        --     item:addChild(stageUpImg)
        -- end
        -- node:reorderChild(item,12)
        -- if unlockData[i] < nextBuffId then
        --     stageUpImg:loadTexture("comAttr_full_treasure.png",1)
        -- end

        local attr = addAttrsData[1][1]
        local addValue = addAttrsData[1][2]



        local des = lang("HEROMASTERYDES_" .. addValue .. math.max(i-1,1))
        local desEx = ""
        if des == "" then
            des   = lang("PLAYERSKILLDES2_" .. addValue .. math.max(i-1,1))
            desEx = lang("PLAYERSKILLDESEX_" .. addValue .. math.max(i-1,1))
        end
        print("des",des)
        
        if i == 1 then
            des = self:generateDes(1)
        end
        local color = cc.c3b(100, 100, 100)
        local colorH = "[color=645252,fontsize=16]"
        local isOutline = false
        local isNotAffect = false -- 判断是不是没有开启
        if stage < unlockData[i] then
            des = "[color=787878,fontsize=16]Lv." .. unlockData[i]  .. des .. "[-]" -- "Lv." .. unlockData[i] .. " " ..
            isNotAffect = true
        elseif stage <= unlockData[i]  then
            isOutline = true
            color = cc.c3b(250, 146, 26)
            des = "[color=8a5c1d,fontsize=16]Lv." .. unlockData[i] .. "" .. des .. "[-]"
        else
            color = cc.c3b(70, 40, 0)
            des =  "[color=8a5c1d,fontsize=16]Lv." .. unlockData[i] .. "" .. des .. "[-]" -- 
        end

        if item:getChildByName("rtx") then
            item:getChildByName("rtx"):removeFromParent()
        end
        --]]
        -- 加开启条件
        -- if isNotAffect then
        --     -- local desLabW = desLab:getContentSize().width
        --     -- if desLabW < 300 then
        --     --     des = des .. "\n"
        --     -- end
        --     des = des .. "[color=646464,fontsize=16]　(Lv." .. unlockData[i] .."可获得)[-]"
        --     -- desLab:setString(des)
        -- end
        -- [[ 换用普通label创建
        des = "[color=ffffff,fontsize=16]" .. des .. "[-]"
        des = string.gsub(des,"fontsize=22","fontsize=16")
        des = string.gsub(des,"color=1ca216","color=1ca216,fontsize=16")
        des = string.gsub(des,"color=c44904","color=c44904,fontsize=16")
        local rtx = RichTextFactory:create(des or "",280,item:getContentSize().height)
        rtx:formatText()
        -- rtx:setVerticalSpace(5)
        -- rtx:setAnchorPoint(cc.p(0,0))
        local w = rtx:getInnerSize().width
        local h = rtx:getInnerSize().height
        rtx:setPosition(cc.p(w/2+35,item:getContentSize().height/2))
        UIUtils:alignRichText(rtx,{vAlign = "center",hAlign = "left"})
        rtx:setName("rtx")
        item:addChild(rtx)
        local desLab = rtx
        local h = h --desLab:getContentSize().height
        if h < 20 then 
            h = 20
        else
            h = math.ceil(h/20)*20
        end 
        -- if h > 32 then
        item:setContentSize(cc.size(375,h))
        -- end
        local children = item:getChildren()
        for _,child in pairs(children) do
            local name 
            if child.getName and child:getName() then 
                name = child:getName()
            end
            if name == "rtx" then
                child:setPositionY(math.max(16,h/2))
            end
            if name ~= "rtx" then
                if h > 20  then
                    child:setPositionY(20)
                else
                    child:setPositionY(math.max(10,h/2))
                end
            end
        end
        scrollHeight = scrollHeight+math.max(h,20)
    end

    node:setInnerContainerSize(cc.size(310,math.max(175,scrollHeight+math.abs(offsety))))
    local addHeight = scrollHeight+math.abs(offsety)
    addHeight = math.max(175,addHeight)
    print(scrollHeight,"scrollHeight",offsety)
    -- dump(self._addAttrItems)
    for k,item in pairs(self._addAttrItems) do
        local itemH = item:getContentSize().height
        item:setPositionY(addHeight-itemH+offsety)
        -- print("height...",addHeight-itemH)
        addHeight = addHeight - itemH
    end
end

-- 技能描述
function TreasureSelectSkillView:generateDes( skillId,stage,tp )
    local skillDes
    local skillD = self._skillDCache[skillId]
    stage = stage or 1
    -- if self._curComInfo then stage = self._curComInfo.stage end
    local maxComStage = table.nums(tab.devComTreasure) + 1
    local GlobalTipView = require("game.view.global.GlobalTipView")
    local tipDataD = GlobalTipView["getDataDForTipType2"](GlobalTipView,
    { tipType = 2, node = desBg, id = skillD.id, skillType = tp,comId = self._skillComMap[skillId], skillLevel = math.min(stage, maxComStage) })
    skillDes = GlobalTipView._des
    skillDes = string.gsub(skillDes, "fontsize=16", "fontsize=18") -- 
    skillDes = string.gsub(skillDes, "fontsize=17", "fontsize=18") -- 
    skillDes = string.gsub(skillDes, "fontsize=18", "fontsize=18") -- 
    skillDes = string.gsub(skillDes, "fontsize=20", "fontsize=18") -- 
    skillDes = string.gsub(skillDes, "fontsize=24", "fontsize=18") -- 
    skillDes = string.gsub(skillDes, "color=3d1f00", "color=fae0bc")
    skillDes = string.gsub(skillDes, "outlinecolor=3c1e0a00", "")
    skillDes = string.gsub(skillDes, "outlinecolor=3c1e0aff", "")
    skillDes = string.gsub(skillDes, "outlinesize=1", "")
    skillDes = string.gsub(skillDes, "outlinesize=2", "")

    GlobalTipView._des = nil
    return skillDes
end

-- 创建技能格子
function TreasureSelectSkillView:createSkillIdcon( skillId,tp )
	local skillD = { }
	if not self._skillDCache[skillId] then
	    for k, v in pairs(self._skillTabMap) do
	        if v[skillId] and(v[skillId].art or v[skillId].icon) then
	            skillD = clone(v[skillId])
	            break
	        end
	    end
	    self._skillDCache[skillId] = skillD
	else
		skillD = self._skillDCache[skillId]
	end
    local art = skillD.art or skillD.icon
	local bgNode = ccui.Widget:create()
	bgNode:setContentSize(cc.size(80,80))
	bgNode:setAnchorPoint(cc.p(0,0))
	local fu = cc.FileUtils:getInstance()
	local icon = ccui.ImageView:create()
	local sfc = cc.SpriteFrameCache:getInstance()
	if sfc:getSpriteFrameByName(art ..".jpg") then
		icon:loadTexture("" .. art ..".jpg", 1)
	else
		icon:loadTexture("" .. art ..".png", 1) 
	end
	icon:ignoreContentAdaptWithSize(false)
	icon:setContentSize(cc.size(78,78))
	icon:setAnchorPoint(cc.p(0,0))
	icon:setPosition(cc.p(0,0))
	bgNode:addChild(icon)

	local frame = ccui.ImageView:create()
	frame:loadTexture("globalImageUI_skillFrame.png",1) 
	frame:setContentSize(cc.size(88,88))
	frame:ignoreContentAdaptWithSize(false)
	frame:setPosition(cc.p(-5,-5))

	frame:setAnchorPoint(cc.p(0,0))
	bgNode:addChild(frame,1)

	local iconBg = ccui.ImageView:create()
	iconBg:loadTexture("globalImageUI4_heroBg2.png",1) 
	iconBg:setContentSize(cc.size(80,80))
	iconBg:ignoreContentAdaptWithSize(false)
	iconBg:setPosition(cc.p(-5,-5))
	iconBg:setScale(84/iconBg:getContentSize().width)
	iconBg:setAnchorPoint(cc.p(0,0))
	bgNode:addChild(iconBg,-1)
	
	-- local iconBg2 = ccui.ImageView:create()
	-- iconBg2:loadTexture("globalPanelUI5_tipiconbg.png",1) 
	-- iconBg2:setContentSize(cc.size(80,80))
	-- iconBg2:ignoreContentAdaptWithSize(false)
	-- iconBg2:setPosition(cc.p(-5,-5))
	-- iconBg2:setScale(90/iconBg2:getContentSize().width)
	-- iconBg2:setAnchorPoint(cc.p(0,0))
	-- bgNode:addChild(iconBg2,-2)
	bgNode:setScale(0.9)
	self:registerClickEvent(bgNode,function() 
		self:reflashTreasureInfo(skillId,tp)
	end)
	return bgNode
end

------------------------------------ 初始化界面 begin --------------------------------------
-- 进入界面展示
function TreasureSelectSkillView:onOpenView( )
	local empty = #self._formData == 0
	-- local initHidePanel = {"tableBg","listPanel"}
	-- for i,panelName in ipairs(initHidePanel) do
	-- 	self:getUI("bg.layer." .. panelName):setVisible(not empty)
	-- end

	self._noneDes:setVisible(empty)
end

-- 右侧编辑界面
function TreasureSelectSkillView:initEditPanel( )
	self:registerClickEventByName("bg.layer.editPanel.addBtn",function() 
		-- 添加编组
	local slotMaxNum = tab.setting["G_BUY_TREASURE_SKILLSLOT"].value
	local formNum
	for i=1,slotMaxNum do
		if not self._tFModel:getTFormDataById(i) then
			formNum = i 
			break
		end
	end

	if not formNum or formNum > slotMaxNum then
		self._viewMgr:showTip("编组已满")
		return 
	end
	local costFormNum = math.max(formNum,2)
	local cost = tab.reflashCost[costFormNum] and tab.reflashCost[costFormNum].unlockTskill
	local gem = self._modelMgr:getModel("UserModel"):getData().gem 
	if gem < cost then
		DialogUtils.showNeedCharge({desc = "钻石不足，是否前去充值",callback1=function( )
            -- print("充值去！")
            local viewMgr = ViewManager:getInstance()
            viewMgr:showView("vip.VipView", {viewType = 0})
        end})
		return
	end
	local descStr =  "[color=462800,fontsize=24]是否使用[pic=globalImageUI_littleDiamond.png][-][color=3d1f00,fontsize=24]" .. (cost or 0) 
					.. "[-][-]" .. "[color=462800,fontsize=24]".. "解锁宝物编组" .. costFormNum .. "[-]"
	self._viewMgr:showSelectDialog( descStr, "", function( )
			if formNum == 1 then
		        self:sendAddFormMsg(2)
			else
				self:sendAddFormMsg(formNum)
			end
		end, 
    "", nil)
	end)
	self:registerClickEventByName("bg.layer.editPanel.editBtn",function() 
		-- 编辑编组名字
		self._viewMgr:showDialog("treasure.TreasureSetSkillDialog",{title = "修改名称",formId = self._curFormId,callback = function( name )
			print("name..",name)
			local formName = self._curFormD.name 
			if (not formName or formName ~= name)and name then
				self:sendChangeFormNameMsg(self._curFormId,name,function( )
					self._curFormD = self._tFModel:getData()[self._curFormId]
					self:reflashEditName()
				end)
			end
		end})
	end)
	self:registerClickEventByName("bg.layer.editPanel.listBtn",function() 
		-- 展示编组列表
		self._viewMgr:showDialog("treasure.TreasureSelectFormDialog",{tFormId = self._curFormId,callback = function( formId )
			if formId and self._tFModel:getData()[formId] then
				print("formId in changing....back ...........",formId)
				self._curFormId = formId 
				self._curFormD  = self._tFModel:getData()[formId]
			    self:reflashSkillSlot()
				self:filterData()
			    self:reflashEditName()
			end
		end})
	end)
	self:registerClickEventByName("bg.layer.editPanel.editBg",function() 
		-- 展示编组列表
		self:showSmallList()
	end)
end

-- 刷新editPanel
function TreasureSelectSkillView:reflashEditName()
	local editFormName = self._curFormD.name 
	if not editFormName or editFormName == "" then
		editFormName = "宝物编组" .. self._curFormId
	end
	self._formName:setString( editFormName or "宝物编组")
end

-- 右侧技能详情界面
function TreasureSelectSkillView:initDetailPanel()
	-- 关闭详情按钮
	self:registerClickEventByName("bg.layer.detailPanel.detailCloseBtn",function()
		self:cancelSelect()
		self:filterData() 
		self:switchRightPage("default")
	end)
	-- 交换按钮
	self:registerClickEventByName("bg.layer.detailPanel.changeBtn",function() 
		self:switchRightPage("list")
		-- self._curSkillNode._status = "empty"
		if self._curSkillNode and self._curSkillNode._skillType then
		    self:filterData(self._curSkillNode._skillType)
		end
	end)
	-- 卸下按钮
	self:registerClickEventByName("bg.layer.detailPanel.cancelBtn",function() 
		local slotId = self._curSkillNode._slotId
		self:sendRemoveMsg(self._curFormId,slotId,function( )
			self:cancelSelect()
			self:filterData()
			self:switchRightPage("default")
		end)
	end)

end

-- 左侧技能编组详情界面
function TreasureSelectSkillView:initSkillPanel( )
	self._skillSelectedMC = mcMgr:createViewMC("fashuxuanzhong_herospellstudyanim", true)
    self._skillSelectedMC:setVisible(false)
    self._skillSelectedMC:setPlaySpeed(1, true)
    self._skillPanel:addChild(self._skillSelectedMC,99)
	self._skillFixedMc = mcMgr:createViewMC("baowujinengxuanze_treasurebaowujinengxuanze", false,false)
    self._skillFixedMc:setVisible(false)
    self._skillFixedMc:setPlaySpeed(1, true)
    self._skillPanel:addChild(self._skillFixedMc,99)
	local funcMap = {
		fixed = "showChangeSkill",
		empty = "showFixSkill"
	}
	local slotIds = {1,2,3,3,3}
	for i=1,5 do
    	local skillNode = self:getUI("bg.layer.skillPanel.skillNode_" .. i)
    	skillNode._status = "empty"
    	skillNode._slotId = i
    	skillNode._skillType = slotIds[i]
    	self._skillNodes[i] = skillNode
    	skillNode:setScaleAnim(true)
    	self:registerClickEvent(skillNode,function() 
    		print(".....touc h skill idx",i,skillNode._status)
    		local func = self[funcMap[skillNode._status or "empty"]]
    		if func then
	    		func(self,i)
	    	end
    	end)
    end
end

function TreasureSelectSkillView:showChangeSkill( skillIdx )
	-- body
	self._curSkillIdx = skillIdx
	self._curSkillNode = self._skillNodes[skillIdx]
	self:selectSkillNode(self._curSkillNode)
	self:switchRightPage("detail")
	local skillId = self._curSkillNode._skillId
	local tp = self._curSkillNode._skillType
	self:reflashTreasureInfo(self._curSkillNode._skillId,tp)
end

function TreasureSelectSkillView:showFixSkill( skillIdx )
	-- body
	self._curSkillIdx = skillIdx
	self._curSkillNode = self._skillNodes[skillIdx]
	self:selectSkillNode(self._curSkillNode)
	self:switchRightPage("list")
	self:filterData(self._curSkillNode._skillType)
end

-- 选中动画
function TreasureSelectSkillView:selectSkillNode( skillNode )
	if self._preSkillNode 
		and ( not self._preSkillNode._status 
			or self._preSkillNode._status == "empty") 
	then
		local skillAdd = self._preSkillNode:getChildByFullName("skillAdd")
		skillAdd:stopAllActions()
		skillAdd:setOpacity(255)
	end
	self._skillSelectedMC:setVisible(true)
	local nodeW = skillNode:getContentSize().width
	local x = skillNode:getPositionX()+nodeW/2
	local y = skillNode:getPositionY()+nodeW/2
	-- self._skillSelectedMC:setScale(1.1)
	self._skillSelectedMC:setPosition(x,y)
	if not skillNode._status or skillNode._status == "empty" then 
		local skillAdd = skillNode:getChildByFullName("skillAdd")
		skillAdd:runAction(cc.RepeatForever:create(
			cc.Sequence:create(
				cc.FadeTo:create(0.5,100),
				cc.FadeTo:create(0.5,255)
			)
		))
	end
	self._preSkillNode = skillNode
end

-- 取消所有选中
function TreasureSelectSkillView:cancelSelect()
	self._skillSelectedMC:setVisible(false)
	if self._curSkillNode then
		local skillAdd = self._curSkillNode:getChildByFullName("skillAdd")
		skillAdd:stopAllActions()
		skillAdd:setOpacity(255)
		self._curSkillNode = nil
	end
end

function TreasureSelectSkillView:stopAddAnim( skillNode )
	if not tolua.isnull(skillNode) then
		local skillAdd = skillNode:getChildByFullName("skillAdd")
		skillAdd:stopAllActions()
		skillAdd:setOpacity(255)
	end
end

-- 右侧技能列表界面
function TreasureSelectSkillView:initListPanel( )
	-- body
	self:registerClickEventByName("bg.layer.listPanel.listCloseBtn",function() 
		self:cancelSelect()
		self:filterData()
		self:switchRightPage("default")
	end)
	self._tableData = {}
	dump(self._tableData,"tableData.....slllllll")
	self:addTableView()
end
--- table begin ---
function TreasureSelectSkillView:addTableView( )
    local tableView = cc.TableView:create(cc.size(350, 400))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(0,0))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    self._tableBg:addChild(tableView)
    tableView:registerScriptHandler(function( view )
        return self:scrollViewDidScroll(view)
    end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(function( view )
        return self:scrollViewDidZoom(view)
    end ,cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(function ( table,cell )
        return self:tableCellTouched(table,cell)
    end,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(function( table,index )
        return self:cellSizeForTable(table,index)
    end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function ( table,index )
        return self:tableCellAtIndex(table,index)
    end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function ( table )
        return self:numberOfCellsInTableView(table)
    end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()
    self._tableView = tableView
end

function TreasureSelectSkillView:scrollViewDidScroll(view)
    -- print("scrollViewDidScroll")
end

function TreasureSelectSkillView:scrollViewDidZoom(view)
    -- print("scrollViewDidZoom")
end

function TreasureSelectSkillView:tableCellTouched(table,cell)
    print("cell touched at index: " .. cell:getIdx())
end

function TreasureSelectSkillView:cellSizeForTable(table,idx) 
    return 95,345
end

function TreasureSelectSkillView:tableCellAtIndex(table, idx)
    local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
	    cell:setCascadeOpacityEnabled(true,true)
    end
    local cellBoard = cell:getChildByFullName("cellBoard")
    if tolua.isnull(cellBoard) then
    	cellBoard = self._skillCell:clone()
    	cellBoard:setPosition(0,0)
    	cellBoard:setCascadeOpacityEnabled(true,true)
    	cellBoard:setName("cellBoard")
    	cell:addChild(cellBoard,999)
    end
    local cellBoardY = 0
    if self._notShowSelectYellowBg then
    	cellBoardY =(idx+1)*14-7
	end
	cellBoard:setPositionY(cellBoardY)
	cellBoard:setVisible(true)
    self:updateCellBoard(cellBoard,self._tableData[idx+1],idx)

    -- cell 动画
    cellBoard:stopAllActions()
    cellBoard:setOpacity(0)
    cellBoard:setPositionY(-20*(idx+1))
    cellBoard:runAction(
    	cc.Spawn:create(
    		cc.FadeIn:create(0.1),
    		cc.EaseIn:create(
	    		cc.MoveTo:create(0.15,cc.p(0,cellBoardY)),
	    		0.3
    		)
    	)
    )
    return cell
end

function TreasureSelectSkillView:numberOfCellsInTableView(table)
   return #self._tableData
end

function TreasureSelectSkillView:updateCellBoard( cellBoard,data,idx )
	if not data then return end
	-- dump(data,"updateCellBoard....")
	local skillD = { }
	local skillId = data.id
	if not self._skillDCache[skillId] then
	    for k, v in pairs(self._skillTabMap) do
	        if v[skillId] and(v[skillId].art or v[skillId].icon) then
	            skillD = clone(v[skillId])
	            break
	        end
	    end
	    self._skillDCache[skillId] = skillD
	else
		skillD = self._skillDCache[skillId]
	end
	local skillName = cellBoard:getChildByName("skillName")
	skillName:setString(lang(skillD.name))

	local skillLv = cellBoard:getChildByName("skillLv")
	skillLv:setString("Lv." .. math.max(1,data.lv))

	local skillType = data.skillType or 1
	local typeLab = cellBoard:getChildByName("typeLab")
	typeLab:setString(lang("BAOWUADDTAG_" .. skillType))
	local skillTag = cellBoard:getChildByName("skillTag")
	local colorMap = {"blue","purple","green",[9] = "green"}
	skillTag:loadTexture((colorMap[skillType] or "green") .. "Tag_treasureSkill.png", 1)
	
	local skillFrame = cellBoard:getChildByName("skillNode"):getChildByName("skillFrame")
	local skillFrameMap = {
		"hero_skill_bg1_forma.png",
		"bigSkillFrame_treasureSkill.png",
		"hero_skill_bg2_forma.png",
	}
	skillFrame:loadTexture(skillFrameMap[skillType] or "hero_skill_bg2_forma.png",1)

	-- 刷icon
	local skillImg = cellBoard:getChildByFullName("skillNode.skillImg")
	self:setSkillImg(skillImg,skillId)
    skillImg:setScale(70 / skillImg:getContentSize().width)

    -- cell 的状态
    ---- lv == 0 不可操作
    ---- fixed
    local slotId = self._curSkillNode and self._curSkillNode._slotId or -1
    local status = "canfix" or nil 
    local canTouch = true
    if data.lv == 0 then
    	status = "disable"
    	canTouch = false
    end
    local equipTag = cellBoard:getChildByFullName("equipTag")
    equipTag:setVisible(false)
    if self._curFormD 
    	and self._curFormD[tostring(slotId)] 
    	and tonumber(self._curFormD[tostring(slotId)]) ~= 0 
    	and tonumber(self._curFormD[tostring(slotId)]) == self._skillComMap[skillId]
    then 
    	canTouch = false
    end
    if self._curFormD then
    	local hadInFixed = false
    	local cellComId  = self._skillComMap[skillId]
    	for k,comId in pairs(self._curFormD) do
    		if comId == cellComId then
    			hadInFixed = true
    			break
    		end
    	end
    	if hadInFixed then
    		status = "fixed"
		end
    end
    equipTag:setVisible(status == "fixed")
    UIUtils:setGray(cellBoard,status == "disable")
    -- 展示界面
    local split1 = cellBoard:getChildByName("split1")
    local split2 = cellBoard:getChildByName("split2")
    print("self._notShowSelectYellowBg^^^^^^^^^",self._notShowSelectYellowBg)
    if self._notShowSelectYellowBg then
	    cellBoard:setBackGroundImageOpacity(0)
	    -- 横隔条
	    if not split1 then
		    split1 = ccui.ImageView:create()
			split1:setName("split1")
			-- split1:setScaleX(0.56)
			split1:loadTexture("globalImageUI_approach_split.png",1)		
		    split1:setPosition(-30,5)
		    split1:setAnchorPoint(0,0)
		    split1:setSwallowTouches(false)	
			cellBoard:addChild(split1)
		end
		split1:setVisible(true)

		if not split2 then
		    split2 = ccui.ImageView:create()
			split2:setName("split2")
			-- split2:setScaleX(0.56)
			split2:loadTexture("globalImageUI_approach_split.png",1)		
		    split2:setPosition(-30,85)
		    split2:setAnchorPoint(0,0)
		    split2:setSwallowTouches(false)	
			cellBoard:addChild(split2)
		end
		split2:setVisible(idx == 0)
		equipTag:setVisible(false)
	else
		if split1 then split1:setVisible(false) end
		if split2 then split2:setVisible(false) end
		cellBoard:setBackGroundImage("skillBg_n_treasureSkill.png",1)
		if  self._curSkillNode  
			and self._curSkillNode._skillId 
			and self._curSkillNode._skillId == skillId then
			cellBoard:setBackGroundImage("skillBg_s_treasureSkill.png",1)
		end
		cellBoard:setBackGroundImageCapInsets(cc.rect(25,25,1,1))
		cellBoard:setBackGroundImageOpacity(255)
	end
    -- 点击事件
    self:registerClickEvent(cellBoard,function() 
    	if canTouch and self._curSkillNode then
    		self:sendChangeMsg( self._curFormId or 1,self._curSkillNode._slotId,data.tid )
    	end 
    end)
    cellBoard:setSwallowTouches(false)
    -- 展示技能tip
    self:registerClickEvent(skillImg,function() 
    	local comD = tab.comTreasure[data.tid]
	    self._viewMgr:showHintView("global.GlobalTipView", 
	    	{ 
	    		tipType = 2, 
	    		node = skillImg, 
	    		id = skillId, 
	    		skillType = comD.addattr[1][1], 
	    		skillLevel = math.max(1,data.lv),
	    		notAutoClose = true,
	    		treasureInfo = {id=data.tid,stage=math.max(1,data.lv)}
	    	})
    end)
    	
end
--- table end   ---

------------------------------------ 初始化界面   end --------------------------------------


------------------------------------ 界面切换 begin --------------------------------------
-- 右侧状态
---- 编组名称         				以下界面是否显示  
---- 	type 				detailPanel editPanel listPanel tableBg	
---- 默认编组 default    	 false 		 true 		false 	 false   
---- 选择技能 list 	 		 false       false      true 	 true
---- 修改技能 detail 		 true        false      false 	 false
function TreasureSelectSkillView:switchRightPage( pageType )
	local empty = #self._formData == 0
	self._tableBg:setVisible(not empty)
	local showViewMap = {
		default = {detailPanel = false, editPanel = true,  listPanel = false, tableBg = true,},
		list 	= {detailPanel = false, editPanel = false, listPanel = true,  tableBg = true,},
		detail 	= {detailPanel = true,  editPanel = false, listPanel = false, tableBg = false,},
	}
	local curMap = showViewMap[pageType]
	for k,v in pairs(curMap) do
		print(k,v)
		self["_" .. k]:setVisible(v)
	end
	self._pageType = pageType
end

-- 刷新右侧列表数据
function TreasureSelectSkillView:refreshListData( )
	
end

-- 展示技能列表名
function TreasureSelectSkillView:showSmallList( )
	self._formListView:removeAllChildren()
	self._formListView:setVisible(true)
	local formList = self._formData
	local formNum = #formList
	local listH = 30*formNum+10
	if formNum == 0 then
	end
	self._formListView:setContentSize(cc.size(220,listH))
	self._formListView:setPositionY(400-listH)
	for i=1,formNum do
		local listNode = self:createFormListItem(i)
		self._formListView:pushBackCustomItem(listNode)
	end
end

function TreasureSelectSkillView:createFormListItem( idx )
	local data = self._formData[idx]
	if not data then return end
	local listNode = ccui.Layout:create()
	listNode:setAnchorPoint(cc.p(0,0))
	listNode:setContentSize(cc.size(200, 30))
	--名字
	local nameLab = ccui.Text:create()
    nameLab:setString(data.name or "宝物编组")
    nameLab:setFontSize(20)
    nameLab:setPosition(58, 0)
    nameLab:setFontName(UIUtils.ttfName)
    nameLab:setSwallowTouches(false)	
	nameLab:setAnchorPoint(0.5,0)
    nameLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    listNode:addChild(nameLab,2)
    -- 横隔条
    local splitImg = ccui.ImageView:create()
	splitImg:setName("splitImg")
	splitImg:setScaleX(0.56)
	splitImg:loadTexture("globalImageUI_approach_split.png",1)		
    splitImg:setPosition(0,0)
    splitImg:setAnchorPoint(0,0)
    splitImg:setSwallowTouches(false)	
	listNode:addChild(splitImg)
	self:registerClickEvent(listNode,function() 
		self._formListView:setVisible(false)
		-- 选择编组
		self._formName:setString(data.name)
		self:filterData()
		self:switchRightPage("list")
	end)
	return listNode
end

------------------------------------ 界面切换   end --------------------------------------


------------------------------------ 数据处理 begin --------------------------------------
-- 生成静态表数据结构
function TreasureSelectSkillView:initSkillListData( )
	self._comSkillMap = {}
	self._skillComMap = {}
	local skills = {}
	-- 分类
	for k,treasureD in pairs(tab.comTreasure) do
		local skillTp = treasureD.addtag
		local skillId = treasureD.addattr[1][2]
		if not skills[skillTp] then
			skills[skillTp] = {}
		end
		self._skillLvs[skillId] = 0
		local comInfo = self._modelMgr:getModel("TreasureModel"):getTreasureById(treasureD.id)
	    self._comSkillMap[k] 		= skillId
	    self._skillComMap[skillId] 	= k
	    if comInfo then
	    	-- dump(comInfo)
	    	self._skillLvs[skillId] = comInfo.stage or 0
	    end
	    if treasureD.produce ~= 1 or comInfo then
			table.insert(skills[skillTp],{id = skillId,tid = k,lv = self._skillLvs[skillId],skillType = skillTp})
		end
	end
	dump(skills,"skills.....")
	self._skills = skills
end
-- 过滤数据
-- 按类型返回技能
function TreasureSelectSkillView:filterData( skillTp )
	self._notShowSelectYellowBg = not skillTp
	if skillTp then
		self._tableData = self._skills[skillTp]
	else 
		-- 当前的编组列表
		local ids = {}
		for k,comId in pairs(self._curFormD) do
			local slotId = tonumber(k)
			if slotId and tonumber(comId) ~= 0 then
				local skillInfo = {}
				skillInfo.id = self._comSkillMap[tonumber(comId)]
				skillInfo.tid = comId
				skillInfo.lv = self._skillLvs[skillInfo.id] or 0
				skillInfo.skillType = tab.comTreasure[comId].addtag
				table.insert(ids,skillInfo)
			end
		end
		self._tableData = ids
	end
	local fixedFilter = {}
	if self._curFormD then
		for k,comId in pairs(self._curFormD) do
			fixedFilter[comId] = true
		end
	end
	local curSlotSkillId = self._curSkillNode and self._curSkillNode._skillId 
	table.sort(self._tableData,function( a,b )
		local aNodeSkill = a.id == curSlotSkillId
		local bNodeSkill = b.id == curSlotSkillId
		local aFixed = fixedFilter[a.tid]
		local bFixed = fixedFilter[b.tid]
		if aNodeSkill ~= bNodeSkill then
			return aNodeSkill
		else
			if aFixed ~= bFixed then
				return aFixed
			else
				return a.id < b.id
			end
		end
	end)
	local dataNum = table.nums(self._tableData)
	self._noneDes:setVisible(dataNum == 0)
	self._tableView:reloadData()
end

------------------------------------ 数据处理   end --------------------------------------

------------------------------------ 发送协议 begin --------------------------------------
-- 获取信息
function TreasureSelectSkillView:sendGetMsg()
	self._serverMgr:sendMsg("TformationServer", "getFormation", {}, true, { }, function(result)
        
    end)
end

function TreasureSelectSkillView:sendSetFormMsg( formId,slotId,treasureId )
	local param = {id = formId,slot = slotId, tid = treasureId}
	self._serverMgr:sendMsg("TformationServer", "setFormation", param, true, { }, function(result)
        if self._curSkillNode then
        	self._skillFixedMc:setVisible(true)
			local nodeW = self._curSkillNode:getContentSize().width
			local x = self._curSkillNode:getPositionX()+nodeW/2
			local y = self._curSkillNode:getPositionY()+nodeW/2
			-- self._skillFixedMc:setScale(1.1)
			self._skillFixedMc:setPosition(x,y)
			self._skillFixedMc:gotoAndPlay(0)
			self._skillFixedMc:addCallbackAtFrame(10,function( )
				self._skillFixedMc:stop()
				self._skillFixedMc:setVisible(false)
			end)
        end
    end)
end

function TreasureSelectSkillView:sendRemoveMsg( formId,slotId,callback )
	local param = {id = formId,slot = slotId}
	self._serverMgr:sendMsg("TformationServer", "removeFormation", param, true, { }, function(result)
        if callback then 
        	callback()
        end
    end)
end

function TreasureSelectSkillView:sendAddFormMsg( formId,callback )
	local param = {id = formId}
	self._serverMgr:sendMsg("TformationServer", "openFormation", param, true, { }, function(result)
        if callback then 
        	callback()
        end
    end)
end

-- 改名
function TreasureSelectSkillView:sendChangeFormNameMsg( formId,nameStr,callback )
	local param = {id = formId,name = nameStr}
	self._serverMgr:sendMsg("TformationServer", "changeFormationName", param, true, { }, function(result)
        if callback then 
        	callback()
        end
    end)
end

-- 安装 更换 统一接口
function TreasureSelectSkillView:sendChangeMsg( formId,slotId,treasureId )
	local formData = self._tFModel:getData()[formId]
	local removeSlotId = nil
	if formData then
		for k,v in pairs(formData) do
			if tonumber(k) 
				and tonumber(k) ~= tonumber(slotId) 
				and v == treasureId 
			then
				removeSlotId = tonumber(k)
			end 
		end
	end
	if removeSlotId then
		self:sendRemoveMsg(formId,removeSlotId,function( )
			local skillNode = self._skillNodes[removeSlotId]
			self:stopAddAnim(skillNode)
			self:sendSetFormMsg( formId,slotId,treasureId )
		end)
	else
		self:sendSetFormMsg( formId,slotId,treasureId )
	end
end


------------------------------------ 发送协议   end --------------------------------------

return TreasureSelectSkillView