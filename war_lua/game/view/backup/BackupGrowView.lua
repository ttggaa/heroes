--[[
 	@FileName 	BackupGrowView.lua
	@Authors 	yuxiaojing
	@Date    	2018-04-17 20:48:55
	@Email    	<yuxiaojing@playcrab.com>
	@Description   描述
--]]

local BackupGrowView = class("BackupGrowView", BaseView)

function BackupGrowView:ctor(  )
	BackupGrowView.super.ctor(self)
end

function BackupGrowView:getBgName(  )
	return "bg_012.jpg"
end

function BackupGrowView:setNavigation( )
	self._viewMgr:showNavigation("global.UserInfoView", {types = {"Texp", "3100","Gem"}, titleTxt = "后援"})
end

function BackupGrowView:getAsyncRes(  )
	return {
		{"asset/ui/backup.plist", "asset/ui/backup.png"},
	}
end

function BackupGrowView:onInit(  )
	self._cellHeight = 150
	self._cellWidth = 200

	self._backupModel = self._modelMgr:getModel("BackupModel")
	self._userModel = self._modelMgr:getModel("UserModel")
	self._itemModel = self._modelMgr:getModel("ItemModel")

	self._backupData = clone(tab.backupMain)
	self._specLevelupData = clone(tab.backupLevelup)
	self._skillLevelupData = clone(tab.backupSkillLevelup)
	self._redPointPrompt = self._backupModel:redPointPrompt()
	self._curSelectIdx = 0

	self._tableBg = self:getUI('tableBg.tableview')
	self._backupCell = self:getUI('itemCell')
	self._skillMainBg = self:getUI('bg.backupInfo.skill_main')
	self._subSkill1 = self:getUI('bg.backupInfo.skill_1')
	self._subSkill2 = self:getUI('bg.backupInfo.skill_2')
	self._formationBg = self:getUI('bg.backupInfo.formation_bg')

	local btn_tips = self:getUI("tableBg.Image_189.btn_tips")
	self:registerClickEvent(btn_tips, function (  )
		self._viewMgr:showDialog("global.GlobalRuleDescView", {desc = lang("backup_Rules")}, true)
	end)

	self._formationIcon = {}
	for i = 1, 16 do
		self._formationIcon[i] = self._formationBg:getChildByFullName('formation.formation_icon_' .. i)
	end

	local specUpgrade1 = self._skillMainBg:getChildByFullName('btn_upgrade_1')
	local specUpgrade5 = self._skillMainBg:getChildByFullName('btn_upgrade_5')
	local skillUpgrade1 = self._subSkill1:getChildByFullName('btn_upgrade')
	local skillUpgrade2 = self._subSkill2:getChildByFullName('btn_upgrade')

	self:registerClickEvent(specUpgrade1, function (  )
		self:upgradeSpecialSkill(1)
	end)

	self:registerClickEvent(specUpgrade5, function (  )
		self:upgradeSpecialSkill(5)
	end)

	self:registerClickEvent(skillUpgrade1, function (  )
		self:upgradeSkill(1)
	end)

	self:registerClickEvent(skillUpgrade2, function (  )
		self:upgradeSkill(2)
	end)

	self:reflashBackupUI()

	self:createTableView()

    self:listenReflash("UserModel", self.reflashUIInfo)
end

function BackupGrowView:reflashUIInfo(  )
	if self._lockReflash then
		self._lockReflash = false
		return
	end
	self:reflashRedPointPrompt()
	self:updateSkill()
end

function BackupGrowView:reflashRedPointPrompt(  )
	self._redPointPrompt = self._backupModel:redPointPrompt()
	local offset = self._tableView:getContentOffset()
	self._tableView:reloadData()
	self._tableView:setContentOffset(offset, false)
end

function BackupGrowView:createTableView(  )
	local tableView = cc.TableView:create(cc.size(200, 488))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(0,0))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    self._tableBg:addChild(tableView)

    tableView:registerScriptHandler(function( view )
        return self:scrollViewDidScroll(view)
    end ,cc.SCROLLVIEW_SCRIPT_SCROLL)

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

    self._tableView = tableView

    UIUtils:ccScrollViewAddScrollBar(self._tableView, cc.c3b(169, 124, 75), cc.c3b(64, 32, 12), 0, 6)

    tableView:reloadData()
end

function BackupGrowView:scrollViewDidScroll(view)
    UIUtils:ccScrollViewUpdateScrollBar(view)
end

function BackupGrowView:switchBackupItem( cell )
	local lastCell = self._tableView:cellAtIndex(self._curSelectIdx)
	if lastCell ~= nil then
		self:switchItemState(lastCell, true)
	end
	self:switchItemState(cell, false)

	self._curSelectIdx = cell:getIdx()

	self:reflashBackupUI()
end

function BackupGrowView:tableCellTouched( table, cell )
	local lockType = cell.lockType
	local cellIdx = cell:getIdx()
	print("cell touch at index: " .. cell:getIdx() .. ", lockType:" .. lockType)
	if lockType == 2 then
		local data = self._backupData[cellIdx + 1]
		local curDiamond = self._modelMgr:getModel("UserModel"):getData().gem
		local needDiamond = data.openDiamond[1][3]
		
		DialogUtils.showBuyDialog({
            costNum = needDiamond,
            goods = "解锁阵型？",
            callback1 = function()
            	
				if needDiamond > curDiamond then
					DialogUtils.showNeedCharge({desc = "钻石不足，是否前去充值",callback1=function( )
			            local viewMgr = ViewManager:getInstance()
			            viewMgr:showView("vip.VipView", {viewType = 0})
			        end})
			        return
			    end

            	self._lockReflash = true
                self._serverMgr:sendMsg("BackupServer", "unlock", {bid = data.id}, true, {}, function(success, dataa)
                	self:lock(-1)
                	local lockBG = cell:getChildByFullName("backupItem.lockBG")
                	if lockBG:getChildByFullName('lockAnim') then
                		lockBG:removeChildByName('lockAnim')
                	end
					local mc2 = mcMgr:createViewMC("jianzao_qianghua", false, true)
					mc2:setPosition(0, 8)
					lockBG:addChild(mc2, 2)
					local mc1 = mcMgr:createViewMC("jinengsuo1_qianghua", false, true)
					mc1:setPosition(-57, -13)
					lockBG:addChild(mc1, 3)
					ScheduleMgr:delayCall(500, self, function(_, sender) 
						-- local cell = self._tableView:cellAtIndex(cellIdx)
						self:unlock()
						self:switchBackupItem(cell)
	                	self._tableView:updateCellAtIndex(cellIdx)
						self:reflashRedPointPrompt()
	                	self._viewMgr:showDialog("backup.BackupUnlockSuccessDialog", {backupId = data.id, showType = 1})
        			end)
                end)
            end
        })
		return
	elseif lockType == 3 then
		self._viewMgr:showTip('阵型尚未开放')
		return
	end
	self:switchBackupItem(cell)
end

function BackupGrowView:cellSizeForTable( table, idx )
	return self._cellHeight, self._cellWidth
end

function BackupGrowView:numberOfCellsInTableView( table )
	return #self._backupData
end

function BackupGrowView:tableCellAtIndex( table, idx )
	local cell = table:dequeueCell()
	if nil == cell then
		cell = cc.TableViewCell:new()
	end

	local backupItem = cell:getChildByFullName("backupItem")
	if tolua.isnull(backupItem) then
		backupItem = self._backupCell:clone()
		backupItem:setPosition(0, 0)
		backupItem:setCascadeOpacityEnabled(true, true)
		backupItem:setSwallowTouches(false)
		backupItem:setName("backupItem")
		backupItem:setVisible(true)
		cell:addChild(backupItem, 1)
	end

	self:updateCellInfo(cell, idx)

	return cell
end

function BackupGrowView:updateCellInfo( backupItem, idx )
	local cell = backupItem:getChildByFullName('backupItem')
	local data = self._backupData[idx + 1]
	local sData = self._backupModel:getBackupById(data.id)
	local name = lang(data.name)
	if sData and sData.lv then
		name = name .. "Lv." .. sData.lv
	end
	cell:getChildByFullName('itemName'):setString(name)

	-- thumb
	local formationIcons = self._backupModel:handleBackupThumb(cell, data.icon)
	self._backupModel:handleFormation(formationIcons, data.icon)

	--unlock
	local unlockImg = cell:getChildByFullName('lockBG')
	unlockImg:setVisible(false)
	unlockImg:getChildByFullName("lockImg"):setVisible(true)
	if unlockImg:getChildByFullName('lockAnim') then
		unlockImg:removeChildByName('lockAnim')
	end
	local openLevel = data.openLevel or 0
	local curLevel = self._userModel:getPlayerLevel()
	if curLevel >= openLevel then
		if sData and sData.lv then
			backupItem.lockType = 1
		else
			unlockImg:setVisible(true)
			local mc = mcMgr:createViewMC("jinengsuo_qianghua", true, false)
			mc:setName("lockAnim")
			mc:setPosition(-57, -13)
			unlockImg:addChild(mc)
			unlockImg:getChildByFullName("lockImg"):setVisible(false)
			unlockImg:getChildByFullName('Label_197'):setString("点击解锁")
			backupItem.lockType = 2
		end
	else
		unlockImg:setVisible(true)
		unlockImg:getChildByFullName('Label_197'):setString(openLevel .. "级开放")
		backupItem.lockType = 3
	end

	local img_redPoing = cell:getChildByFullName('redPoint')
	if table.indexof(self._redPointPrompt, tostring(data.id)) then
		img_redPoing:setVisible(true)
	else
		img_redPoing:setVisible(false)
	end

	-- icon
	cell:getChildByFullName('icon.Image_88'):loadTexture(data.specialSkillIcon .. ".png", 1)

	self:switchItemState(backupItem, self._curSelectIdx ~= idx)
end

function BackupGrowView:switchItemState( cell, isSelected )
	cell:getChildByFullName("backupItem.Image_47"):setVisible(not isSelected == true)
	cell:getChildByFullName("backupItem.Image_48"):setVisible(isSelected == true)
	cell:getChildByFullName("backupItem.Image_49"):setVisible(isSelected == true)
end

function BackupGrowView:reflashBackupUI(  )
	print("self._curSelectIdx:" .. self._curSelectIdx)
	local data = self._backupData[self._curSelectIdx + 1]
	local sData = self._backupModel:getBackupById(data.id)
	if sData == nil then
		print("=================这个阵型没解锁呢================")
		return
	end

	self:updateSpecialSkill()

	self:updateSkill()

	self:updateFightScore()

	--formation
	self._backupModel:handleFormation(self._formationIcon, data.class)
end

function BackupGrowView:updateFightScore( isAnim )
	local data = self._backupData[self._curSelectIdx + 1]
	local sData = self._backupModel:getBackupById(data.id)

	local score_panel = self._skillMainBg:getChildByFullName('score_panel')

	local fightLab = score_panel:getChildByFullName('fightLab')
	if fightLab == nil then
		fightLab = ccui.TextBMFont:create("a", UIUtils.bmfName_zhandouli_little)
	    fightLab:setAnchorPoint(cc.p(0, 0.5))
	    fightLab:setPosition(5, 10)
	    fightLab:setScale(0.4)
	    fightLab:setName("fightLab")
	    score_panel:addChild(fightLab)
	end

	local fightNum = score_panel:getChildByFullName('fightNum')
	if fightNum == nil then
		fightNum = ccui.TextBMFont:create("0", UIUtils.bmfName_zhandouli_little)
		fightNum:setAnchorPoint(0, 0.5)
		fightNum:setPosition(fightLab:getContentSize().width * fightLab:getScale() + 8, 10)
		fightNum:setScale(0.5)
	    fightNum:setName("fightNum")
		score_panel:addChild(fightNum)
	end
	local score = sData.score or 0
	local as = sData.as or 0
	if not isAnim then
		fightNum:setString(score + as)
		return
	end
	local oldPropFight = tonumber(fightNum:getString())
	local propFight = score + as
	local fightBg = self:getUI("bg")
    TeamUtils:setFightAnim(fightBg, {oldFight = oldPropFight, newFight = propFight, x = fightBg:getContentSize().width*0.5-100, y = fightBg:getContentSize().height - 200})
    fightNum:setString(propFight)
end

function BackupGrowView:updateSpecialSkill( isExpBar )
	local data = self._backupData[self._curSelectIdx + 1]
	local sData = self._backupModel:getBackupById(data.id)
	-- special skill
	local specSkillMaxlv = tab.setting["backupLevelMax"].value
	local specName = lang(data.specialSkillName) .. "Lv." .. sData.lv .. "/" .. specSkillMaxlv
	if OS_IS_WINDOWS then
		specName = specName .. "   [id:" .. data.id .. "]"
	end
	self._skillMainBg:getChildByFullName('label_1'):setString(specName)
	self._skillMainBg:getChildByFullName('label_1'):enableOutline(cc.c4b(0,0,0,255), 1)

	--specialSkill exp
	local expTxt = self._skillMainBg:getChildByFullName('expBg.exp')
	local expBar = self._skillMainBg:getChildByFullName('expBg.expBar')
	expTxt:enableOutline(cc.c4b(0,0,0,255), 2)

	local upgrade_btn = self._skillMainBg:getChildByFullName("btn_upgrade_1")
	local img_max = self._skillMainBg:getChildByFullName('img_max')
	upgrade_btn:setVisible(false)
	img_max:setVisible(false)

	local specExpData = self._specLevelupData[sData.lv] or {}
	local maxExp = specExpData.levelupExp
	if sData.lv < specSkillMaxlv then
		local sExp = sData.exp or 0
		expTxt:setString(sExp .. "/" .. maxExp)
		local scaleX = sExp / maxExp
		if scaleX > 1 then scaleX = 1 end
		if scaleX < 0 then scaleX = 0 end
		if not isExpBar then
			expBar:setScaleX(scaleX)
		end
		upgrade_btn:setVisible(true)
	else
		expTxt:setString('Max')
		if not isExpBar then
			expBar:setScaleX(1)
		end
		img_max:setVisible(true)
	end

	self._skillMainBg:getChildByFullName('Panel_89.Image_88'):loadTexture(data.specialSkillIcon .. ".png", 1)

	-- desc
	local labelDiscription = self._skillMainBg:getChildByFullName('Panel_79')
	local attr = {sklevel = sData.lv, artifactlv = 1}
	local desc = "[color=fcf4c5, fontsize=20]" .. BattleUtils.getDescription(BattleUtils.kIconTypeSkill, data.specialSkill, attr, 1, nil, nil, nil) .. "[-]"
	local richText = labelDiscription:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, labelDiscription:getContentSize().width, labelDiscription:getContentSize().height - 5)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(labelDiscription:getContentSize().width / 2, labelDiscription:getContentSize().height / 2)
    richText:setName("descRichText")
    labelDiscription:addChild(richText)
end

function BackupGrowView:updateSkill(  )
	local data = self._backupData[self._curSelectIdx + 1]
	local sData = self._backupModel:getBackupById(data.id)

	local skillMaxLv = tab.setting["backupLevelMax"].value
	local specialSkill = sData.lv or 1
	--skill1
	local slv1 = sData.slv1 or 1
	local levelupData = self._skillLevelupData[sData.slv1] or {}
	self._subSkill1:getChildByFullName('title'):setString("战场技能")
	self._subSkill1:getChildByFullName('name'):setString(lang(data.skill1Name) .. " Lv." .. slv1)

	local needBg = self._subSkill1:getChildByFullName('needBg')
	local maxTxt = self._subSkill1:getChildByFullName('img_max')
	local btn_upgrade = self._subSkill1:getChildByFullName('btn_upgrade')
	local lock_img = self._subSkill1:getChildByFullName('lock_img')
	local lock_txt = self._subSkill1:getChildByFullName('lock_txt')
	needBg:setVisible(false)
	maxTxt:setVisible(false)
	btn_upgrade:setVisible(false)
	lock_img:setVisible(false)
	lock_txt:setVisible(false)

	local needNum = levelupData.skill1Item[1][3]
	local _, curNum = self._itemModel:getItemsById(levelupData.skill1Item[1][2])
	-- local curNum = self._userModel:getResNumByType(levelupData.skill1Item[1][1])
	-- print("needNum:" .. needNum .. ", curNum:" .. curNum)
	if specialSkill >= data.skill1Unlock then
		if slv1 < skillMaxLv then
			needBg:setVisible(true)
			btn_upgrade:setVisible(true)
			needBg:getChildByFullName('number'):setString(curNum .. "/" .. needNum)
			if curNum >= needNum then
				needBg:getChildByFullName('number'):setColor(cc.c4b(0, 255, 0, 255))
			else
				needBg:getChildByFullName('number'):setColor(cc.c4b(255, 0, 0, 255))
			end
			local toolImg = tab.tool[levelupData.skill1Item[1][2]].art
			needBg:getChildByFullName('icon'):loadTexture(toolImg .. ".png", 1)
			-- needBg:getChildByFullName('icon'):loadTexture(IconUtils.resImgMap[levelupData.skill1Item[1][1]], 1)
		else
			maxTxt:setVisible(true)
		end
		self._subSkill1:setBrightness(0)
	else
		self._subSkill1:setBrightness(-40)
		lock_img:setVisible(true)
		lock_txt:setVisible(true)
		lock_txt:setString("阵型" .. data.skill1Unlock .. "级开启")
	end
	self._subSkill1:getChildByFullName('icon.Image_39'):loadTexture(data.skill1Icon .. ".png", 1)
	-- desc
	local labelDiscription = self._subSkill1:getChildByFullName('desc')
	local attr = {sklevel = slv1, artifactlv = 1}
	local desc = "[color=9f9ea3, fontsize=16]" .. BattleUtils.getDescription(BattleUtils.kIconTypeHeroMastery, data.skill1, attr, 1, nil, nil, nil) .. "[-]"
	local richText = labelDiscription:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, labelDiscription:getContentSize().width, labelDiscription:getContentSize().height - 5)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(labelDiscription:getContentSize().width / 2, labelDiscription:getContentSize().height / 2)
    richText:setName("descRichText")
    labelDiscription:addChild(richText)

	-- skill2
	local slv2 = sData.slv2 or 1
	local levelupData = self._skillLevelupData[sData.slv2] or {}
	self._subSkill2:getChildByFullName('title'):setString("全局特效")
	self._subSkill2:getChildByFullName('name'):setString(lang(data.skill2Name) .. " Lv." .. slv2)

	local needBg = self._subSkill2:getChildByFullName('needBg')
	local maxTxt = self._subSkill2:getChildByFullName('img_max')
	local btn_upgrade = self._subSkill2:getChildByFullName('btn_upgrade')
	local lock_img = self._subSkill2:getChildByFullName('lock_img')
	local lock_txt = self._subSkill2:getChildByFullName('lock_txt')
	needBg:setVisible(false)
	maxTxt:setVisible(false)
	btn_upgrade:setVisible(false)
	lock_img:setVisible(false)
	lock_txt:setVisible(false)

	local needNum = levelupData.skill2Item[1][3]
	local _, curNum = self._itemModel:getItemsById(levelupData.skill2Item[1][2])
	-- local curNum = self._userModel:getResNumByType(levelupData.skill2Item[1][1])
	-- print("needNum:" .. needNum .. ", curNum:" .. curNum)
	if specialSkill >= data.skill2Unlock then
		if slv2 < skillMaxLv then
			needBg:setVisible(true)
			btn_upgrade:setVisible(true)
			needBg:getChildByFullName('number'):setString(curNum .. "/" .. needNum)
			if curNum >= needNum then
				needBg:getChildByFullName('number'):setColor(cc.c4b(0, 255, 0, 255))
			else
				needBg:getChildByFullName('number'):setColor(cc.c4b(255, 0, 0, 255))
			end
			local toolImg = tab.tool[levelupData.skill2Item[1][2]].art
			needBg:getChildByFullName('icon'):loadTexture(toolImg .. ".png", 1)
			-- needBg:getChildByFullName('icon'):loadTexture(IconUtils.resImgMap[levelupData.skill2Item[1][1]], 1)
		else
			maxTxt:setVisible(true)
		end
		self._subSkill2:setBrightness(0)
	else
		self._subSkill2:setBrightness(-40)
		lock_img:setVisible(true)
		lock_txt:setVisible(true)
		lock_txt:setString("阵型" .. data.skill2Unlock .. "级开启")
	end

	self._subSkill2:getChildByFullName('icon.Image_39'):loadTexture(data.skill2Icon .. ".png", 1)
	-- desc
	local labelDiscription = self._subSkill2:getChildByFullName('desc')
	local attr = {sklevel = slv2, artifactlv = 1}
	local desc = "[color=9f9ea3, fontsize=16]" .. BattleUtils.getDescription(BattleUtils.kIconTypeBackupSkill2, data.id, attr, 1, nil, nil, nil) .. "[-]"
	local richText = labelDiscription:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, labelDiscription:getContentSize().width, labelDiscription:getContentSize().height - 5)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(labelDiscription:getContentSize().width / 2, labelDiscription:getContentSize().height / 2)
    richText:setName("descRichText")
    labelDiscription:addChild(richText)
end

function BackupGrowView:upgradeSpecialSkill( level )
	local data = self._backupData[self._curSelectIdx + 1]
	local sData = self._backupModel:getBackupById(data.id)
	local specSkillMaxlv = tab.setting["backupLevelMax"].value
	if level == 1 then
		level = 0
	else
		level = 1
	end
	if sData.lv < specSkillMaxlv then
		local userData = self._userModel:getData()
		local userBU = userData.texp or 0
		if userBU > 0 then
			self._oldBackupData = clone(sData)
			self._serverMgr:sendMsg("BackupServer", "upgrade", {bid = data.id, mode = level}, true, {}, function(data)
		    	self:updateSpecialSkill(true)
		    	self:updateSkill()
		    	self:showSpecialSkillLevelAnim()
		    	-- self._tableView:updateCellAtIndex(self._curSelectIdx)
		    	self:reflashRedPointPrompt()
		    	self:updateFightScore(true)
		    	self:processSkillUnlock()
		    end, function ( errorId )
		    	
		    end)
		else
			DialogUtils.showLackRes( {goalType = "texp"})
		end
	else
		self._viewMgr:showTip(lang("backup_Tips1"))
	end
	
end

function BackupGrowView:upgradeSkill( level )
	local function sendUpgradeSkillMsg( level )
		local data = self._backupData[self._curSelectIdx + 1]
		self._serverMgr:sendMsg("BackupServer", "skillUpgrade", {bid = data.id, sidx = level}, true, {}, function(data)
	    	self:updateSkill()
	    	self:showSkillLevelAnim(level)
	    	self:reflashRedPointPrompt()
    		self:updateFightScore(true)
	    end, function ( errorId )
	    	
	    end)
	end
	local data = self._backupData[self._curSelectIdx + 1]
	local sData = self._backupModel:getBackupById(data.id)

	local skillMaxLv = tab.setting["backupLevelMax"].value
	local specialSkill = sData.lv or 1

	local slv = sData.slv1 or 1
	local levelupData = self._skillLevelupData[slv] or {}
	local needNum = levelupData.skill1Item[1][3]
	local _, curNum = self._itemModel:getItemsById(levelupData.skill1Item[1][2])
	if level == 2 then
		slv = sData.slv2 or 1
		levelupData = self._skillLevelupData[slv] or {}
		needNum = levelupData.skill2Item[1][3]
		_, curNum = self._itemModel:getItemsById(levelupData.skill2Item[1][2])
	end

	-- local curNum = self._userModel:getResNumByType(levelupData.skill1Item[1][1])
	print("needNum:" .. needNum .. ", curNum:" .. curNum)

	if slv < skillMaxLv then
		if curNum >= needNum then
			if slv >= specialSkill then
				self._viewMgr:showTip(lang("backup_Tips2"))
				return
			else
				sendUpgradeSkillMsg(level)
				return
			end
		else
			self._viewMgr:showDialog("bag.DialogAccessTo",{goodsId = 3100, needItemNum = 0},true)
			-- self._viewMgr:showDialog("global.GlobalPromptDialog", {indexId = 21})
			return
		end
	else
		self._viewMgr:showTip(lang("backup_Tips1"))
		return
	end
end

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

function BackupGrowView:processSkillUnlock(  )
	local oldBackupData = self._oldBackupData
	local data = self._backupData[self._curSelectIdx + 1]
	local sData = self._backupModel:getBackupById(data.id)
	local skill1Unlock = data.skill1Unlock
	local skill2Unlock = data.skill2Unlock

	local oldSpecSkillLv = oldBackupData.lv or 1
	local specSkillLv = sData.lv or 1
	if oldSpecSkillLv >= skill1Unlock and oldSpecSkillLv >= skill2Unlock then
		return
	end
	local params = {}
	params.showType = 2
	if specSkillLv >= skill1Unlock and oldSpecSkillLv < skill1Unlock then
		params.backupId = data.id
		params.skillType = 1
	end

	if specSkillLv >= skill2Unlock and oldSpecSkillLv < skill2Unlock then
		if params.backupId then
			params.nextSkill = true
		else
			params.backupId = data.id
			params.skillType = 2
		end
	end
	if params.backupId then
		self._viewMgr:showDialog("backup.BackupUnlockSuccessDialog", params)
	end
end

function BackupGrowView:showSpecialSkillLevelAnim(inResult)
    audioMgr:playSound("crLvUp")

    local data = self._backupData[self._curSelectIdx + 1]
    local weaponTypeData = self._backupModel:getBackupById(data.id)
    local oldBackupData = self._oldBackupData
    local specSkillMaxlv = tab.setting["backupLevelMax"].value
    local tempParent = 0
    local percent = 0
    local oldlevel = oldBackupData.lv
    local newlevel = weaponTypeData.lv
    for i = oldlevel, newlevel do
        if i == oldlevel and oldBackupData.exp ~= 0 and oldlevel < newlevel then
            tempParent = tempParent + 100 
        elseif i == newlevel and weaponTypeData.exp ~= 0 then
            percent = (weaponTypeData.exp / tab:BackupLevelup(newlevel).levelupExp) * 100
            tempParent = tempParent + percent
        elseif i == newlevel and weaponTypeData.exp == 0 then
            tempParent = tempParent
        else
            tempParent = tempParent + 100
        end
    end

    local expBar = self._skillMainBg:getChildByFullName('expBg.expBar')

    local tempExp = (oldBackupData.exp / tab:BackupLevelup(oldlevel).levelupExp) * 100

    local addExp = 5
    if tempParent > 100 then
        addExp = 10
    end
    expBar:stopAllActions()
    expBar:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
        if tempExp < tempParent then
            local str = math.fmod(tempExp, 100)
            if str + 10 >= 100 then
                str = 100
            end
            local percent = str*0.01
            if percent > 1 then
                percent = 1
            end
            if percent < 0 then
                percent = 0
            end
            expBar:setScaleX(percent)
        else
            local weaponMaxExp = tab:BackupLevelup(newlevel)
            if newlevel < specSkillMaxlv then
                percent = (weaponTypeData.exp / tab:BackupLevelup(newlevel).levelupExp)
            else
                percent = 1
            end
            if percent > 1 then
                percent = 1
            end
            if percent < 0 then
                percent = 0
            end
            expBar:setScaleX(percent)

            expBar:stopAllActions()
        end
        tempExp = tempExp + addExp
    end), cc.DelayTime:create(0.001))))
    
    if oldlevel ~= newlevel then
	    --skill success
	    local expBar = self._skillMainBg:getChildByFullName('expBg')

	    local expBarLab = cc.Sprite:create() 
	    expBarLab:setSpriteFrame("globalImageUI_upgrade_success.png")
	    expBarLab:setPosition(cc.p(expBar:getContentSize().width / 2, 5))
	    expBarLab:setOpacity(0)
	    expBar:addChild(expBarLab,10)
	    local movenature = cc.MoveBy:create(0.3, cc.p(0,25))
	    local fadenature = cc.FadeIn:create(0.3)
	    local spawnnature = cc.Spawn:create(movenature,fadenature)
	    local seq = cc.Sequence:create(cc.DelayTime:create(0.25),spawnnature,cc.Spawn:create(cc.MoveBy:create(0.5, cc.p(0,5)),cc.FadeOut:create(0.5)))
	    local callFunc = cc.CallFunc:create(function()
	        expBarLab:removeFromParent()
	    end)
	    expBarLab:runAction(cc.Sequence:create(seq,callFunc))
	end

    --skill icon anim
    local mcBg = self._skillMainBg:getChildByFullName('Panel_89')
    local mc = mcMgr:createViewMC("shengji_houyuanxitong", false, true)
    mc:setScale(1.15)
    mc:setPosition(0, 0)
    mcBg:addChild(mc)
end

function BackupGrowView:showSkillLevelAnim(level)
    local item = self._subSkill1
    if level == 2 then
    	item = self._subSkill2
    end

    local animBg = item:getChildByFullName('icon')

    local expBarLab = cc.Sprite:create() 
    expBarLab:setSpriteFrame("globalImageUI_upgrade_success.png")
    expBarLab:setPosition(cc.p(0, animBg:getContentSize().height / 2 + 20))
    expBarLab:setOpacity(0)
    animBg:addChild(expBarLab,10)
    local movenature = cc.MoveBy:create(0.3, cc.p(0,25))
    local fadenature = cc.FadeIn:create(0.3)
    local spawnnature = cc.Spawn:create(movenature,fadenature)
    local seq = cc.Sequence:create(cc.DelayTime:create(0.25),spawnnature,cc.Spawn:create(cc.MoveBy:create(0.5, cc.p(0,5)),cc.FadeOut:create(0.5)))
    local callFunc = cc.CallFunc:create(function()
        expBarLab:removeFromParent()
    end)
    expBarLab:runAction(cc.Sequence:create(seq,callFunc))

    --skill icon anim
    local mc = mcMgr:createViewMC("jinengshengji_houyuanxitong", false, true)
    mc:setScale(1)
    mc:setPosition(0, 0)
    animBg:addChild(mc)
end

return BackupGrowView