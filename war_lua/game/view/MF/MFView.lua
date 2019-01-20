--
-- Author: <wangguojun@playcrab.com>
-- Date: 2016-04-20 15:53:31
--
local MFView = class("MFView",BaseView)
local CITYNUM = 7
function MFView:ctor(params)
    MFView.super.ctor(self)
end

function MFView:onInit()
	local ruleBtn = self:getUI("titleBg.ruleBtn")
	self:registerClickEvent(ruleBtn, function()
        self._viewMgr:showDialog("MF.MFDescDialog")
	end)
    self._firstJump = false
    self._awardCity = 1

    self._oldMusic = audioMgr:getMusicFileName()
    audioMgr:playMusic("HappyGame", true)

    self._modelMgr:getModel("MFModel"):setTipData(false)
    self._MFModel = self._modelMgr:getModel("MFModel")
    self._userModel = self._modelMgr:getModel("UserModel")

    -- 背景加载
    local mfbg = self:getUI("bg.scrollView.bg")
    mfbg:removeFromParent()
    local sp1 = cc.Sprite:create("asset/bg/bg_mf_1.jpg")
    sp1:setPosition(512, 480)
    local sp2 = cc.Sprite:create("asset/bg/bg_mf_2.jpg")
    sp2:setPosition(1024 + 340, 480)

    local helpLab = self:getUI("helptimeBg.helpLab")
    helpLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._scrollView = self:getUI("bg.scrollView")
    self._scrollView:setContentSize(cc.size(MAX_SCREEN_WIDTH,MAX_SCREEN_HEIGHT))
    self._scrollView:setInnerContainerSize(cc.size(1704, 960))
    self._scrollView:addChild(sp1)
    self._scrollView:addChild(sp2)

    -- 长按tips
    local helptimeBg = self:getUI("helptimeBg")
    local jiasuTip = self:getUI("helptimeBg.jiasuTip")
    self:registerTouchEvent(helptimeBg, nil, nil, function()
        jiasuTip:setVisible(false)
    end, function()
        jiasuTip:setVisible(false)
    end, function()
        jiasuTip:setVisible(true)
    end)

    self._cityLock = {
        [1] = false,
        [2] = false,
        [3] = false,
        [4] = false,
        [5] = false,
        [6] = false,
        [7] = false,
        [8] = false,
    }
	
	local openLevel = tab:SystemOpen("Alchemy")[1]
	local showLevel = tab:SystemOpen("Alchemy")[2]
	local openTip = tab:SystemOpen("Alchemy")[3]
	local myLvl = self._userModel:getPlayerLevel()
	local alchemyDaoyu = self:getUI("bg.scrollView.layer.daoyu10")
	if myLvl<showLevel then
		alchemyDaoyu:setVisible(false)
	else
		alchemyDaoyu:setVisible(true)
		alchemyDaoyu:getChildByName("timeBg"):setVisible(false)
		alchemyDaoyu:getChildByFullName("timeBg.timerLab"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
		alchemyDaoyu.daoyu = self:createDaoyu(tab.mfOpen[10]["cityCo"][1], tab.mfOpen[10]["cityCo"][2], 10)
		self:setButton(alchemyDaoyu, function()
			if myLvl<openLevel then
				self._viewMgr:showTip(lang(openTip))
				return
			end
			self._viewMgr:lock(-1)
			local beijing = mcMgr:createViewMC("yunqiehuan_mfqiehuanyun", false, true)
			beijing:setAnchorPoint(cc.p(0.5,0.5))
			beijing:setPosition(cc.p(MAX_SCREEN_WIDTH*0.5, MAX_SCREEN_HEIGHT*0.5))
			self:addChild(beijing)
			beijing:addCallbackAtFrame(15, function(_, sender)
				self._serverMgr:sendMsg("AlchemyServer", "getInfo", {}, true, {}, function(result)
					self._viewMgr:unlock()
					self._viewMgr:showView("MF.MFAlchemyView", {callback = function()
						self:reflashAlchemyTip()
					end})
				end)
			end)
		end)
	end

    local invade = self:getUI("bg.scrollView.layer.daoyu9")
    local qiangduotubiao = mcMgr:createViewMC("qiangduotubiao_bangzhucaihong", true, false)
    qiangduotubiao:setPosition(invade:getContentSize().width*0.5-68, invade:getContentSize().height*0.5-36)
    invade:addChild(qiangduotubiao, 10)

    local lueduo = cc.Sprite:create() 
    lueduo:setSpriteFrame("mf_lueduo.png")
    -- lueduo:setPosition(cc.p(qiangduotubiao:getContentSize().width/2, 0))
    lueduo:setAnchorPoint(cc.p(0.5, 0))
    qiangduotubiao:addChild(lueduo,100)

    self:registerClickEvent(invade, function()
        local playerTimesData = self._modelMgr:getModel("PlayerTodayModel"):getData()
        if tab:Setting("G_MF_LOOT_NUM").value <= playerTimesData["day28"] then
            self._viewMgr:showTip(lang("MF_LOOT4"))
            return 
        end
        self:getRival()
    end)

    local closeBtn = self:getUI("closeBtn")
    self:registerClickEvent(closeBtn, function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("MF.MFView")
        end
        self:close()
    end)


	self._daoyu = {}
    local layer = self:getUI("bg.scrollView.layer")
	for i=1,8 do
        self._daoyu[i] = self:getUI("bg.scrollView.layer.daoyu" .. i)
        local cityTab = tab:MfOpen(i)
        if i < 9 then
            self._daoyu[i].daoyu = self:createDaoyu(cityTab["cityCo"][1], cityTab["cityCo"][2], i)
            self._daoyu[i].cloud1 = self:createCloud(self._daoyu[i].daoyu, cityTab["cloud"], i)
            -- if i < 7 then
                local suo, levelLab = self:createSuo(self._daoyu[i].daoyu, cityTab["cityCo"][1], cityTab["cityCo"][2], i)
                self._daoyu[i].suo = suo
                self._daoyu[i].levelLab = levelLab   
            -- end
        end

        self._daoyu[i].weikaishi = mcMgr:createViewMC("tanhao_bangzhucaihong", true, false)
        self._daoyu[i].weikaishi:setPosition(cityTab["cityCo"][1], cityTab["cityCo"][2])
        self._daoyu[i].weikaishi:setName("weikaishi")
        self._daoyu[i].weikaishi:setVisible(false)
        layer:addChild(self._daoyu[i].weikaishi, 200)

        self._daoyu[i].cqqipao = ccui.ImageView:create()
        self._daoyu[i].cqqipao:loadTexture("mfimg_chanchuqipao1.png", 1)
        self._daoyu[i].cqqipao:setAnchorPoint(cc.p(0.2, 0.1))
        self._daoyu[i].cqqipao:setPosition(cityTab["starShowCo"][1], cityTab["starShowCo"][2])
        self._daoyu[i].cqqipao:setName("cqqipao")
        layer:addChild(self._daoyu[i].cqqipao, 200)
        local seq = cc.Sequence:create(cc.ScaleTo:create(1, 0.9), cc.ScaleTo:create(1, 1.1))
        self._daoyu[i].cqqipao:runAction(cc.RepeatForever:create(seq))

        self._daoyu[i].titleBg = self._daoyu[i]:getChildByFullName("titleBg") -- self:createTitle(titlePos[i]["x"], titlePos[i]["y"], i, self._daoyu[i])
        self._daoyu[i].titleBg:setCascadeOpacityEnabled(true)
        self._daoyu[i].title = self._daoyu[i]:getChildByFullName("titleBg.title") -- self:createTitle(titlePos[i]["x"], titlePos[i]["y"], i, self._daoyu[i])
        self._daoyu[i].title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        self._daoyu[i].title:setFontName(UIUtils.ttfName)
        self._daoyu[i].title:setFontSize(48)
        self._daoyu[i].starBg = self._daoyu[i]:getChildByFullName("titleBg.starBg")
        self._daoyu[i].starBg:setCascadeOpacityEnabled(true)
		self._daoyu[i].teamBg = self._daoyu[i]:getChildByFullName("iconBg")
        -- self._daoyu[i].teamBg:setPosition(cc.p(cityTab["mfimage"][1], cityTab["mfimage"][2]))
        self._daoyu[i].teamBg:setCascadeOpacityEnabled(true)
		self._daoyu[i].timeBg = self._daoyu[i]:getChildByFullName("timeBg")
        -- self._daoyu[i].timeBg:setCascadeOpacityEnabled(true)
		self._daoyu[i].timeBg:setVisible(false)
        self._daoyu[i].timeBar = self._daoyu[i]:getChildByFullName("timeBg.timeBar")
		self._daoyu[i].timerLab = self._daoyu[i]:getChildByFullName("timeBg.timerLab")
        self._daoyu[i].timerLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

        self:registerClickEvent(self._daoyu[i], function()
            self:updateButton(self._daoyu[i])
        end)

        local mc2 = mcMgr:createViewMC("shalou_mfhanghaifengweitexiao", true, false)
        mc2:setName("shalou")
        mc2:setPosition(0, 12)
        mc2:setScale(1.2)
        self._daoyu[i].timeBg:addChild(mc2, 10)
        self._daoyu[i].shalou = mc2
	end

    self._suo = false
    self:setHanghaiBg()
    -- -- 菜单
    -- self._isShowMenu = false
    self:setMenu()
    -- self:setMenuStart(1)
    self:updatePlayerTimes()

    self:listenReflash("MFModel", self.reflashUI)
    self:listenReflash("PlayerTodayModel", self.updatePlayerTimes)
end 

function MFView:onExit()
    audioMgr:playMusic(self._oldMusic)
end

function MFView:onAnimEnd()
    local mfData = self._modelMgr:getModel("MFModel"):getData()
    if mfData["thankList"] then
        print("+++++++++++++领取谢礼+++++++++++++++")
        self._serverMgr:sendMsg("MFServer", "getThankAward", {}, true, {}, function (result)
            -- dump(result, "result ===", 10)
            self._viewMgr:showDialog("MF.MFDoleDialog", {doleType = 1, thankList = mfData["thankList"],callBack = function()
                --关闭谢礼界面弹出帮助界面
                self:showHelpDialog()
            end})
            mfData["thankList"] = nil
        end)
    else
        self:showHelpDialog()
    end
end

function MFView:checkTips()
	local mfModel = self._modelMgr:getModel("MFModel")
	local dayinfo = self._modelMgr:getModel("PlayerTodayModel"):getData()
	local noticeMap = {
		-- 布阵
		{iconName = "menu.menuList.fourmation",detectFuc = function()
			local formationModel = self._modelMgr:getModel("FormationModel")
			local flag = formationModel:isFormationTeamFullByType(formationModel.kFormationTypeMFDef)
			return not flag 
		end},
		-- 好友
		{iconName = "menu.menuList.friend",detectFuc = function()
			local flag = false
			if dayinfo["day26"] < tab:Setting("G_MF_HELP_NUM").value then
				if mfModel:isHelpFriend() then
					flag = true
				end
			end
			return flag
		end},
		{iconName = "menu.menuList.receive", detectFuc = function()
			if table.nums(self:getCityData())>0 then
				return true
			end
			return false
		end},
	}

	-- 红点处理
	for k,v in pairs(noticeMap) do
		local hint = false
		if v.detectFuc then
			hint = v.detectFuc()
		end
		print("=hinthint========", v.iconName, hint)
		self:setHintTip(v.iconName, hint)
	end
end

function MFView:setHintTip(btnName, hint)
    local btnName = self:getUI(btnName)
    if not btnName then
        return
    end
    if btnName then
        local btnNameTip = btnName:getChildByName("btnNameTip")
        if btnNameTip then
            btnNameTip:setVisible(hint)
        else
            btnNameTip = cc.Sprite:createWithSpriteFrameName("globalImageUI_bag_keyihecheng.png")
            btnNameTip:setName("btnNameTip")
            btnNameTip:setAnchorPoint(cc.p(0,0))
            btnNameTip:setPosition(cc.p(btnName:getContentSize().width - 26, btnName:getContentSize().height*0.5 + 17))
            btnName:addChild(btnNameTip, 10)
            btnNameTip:setVisible(hint)
        end
    end
end

function MFView:onTop()
    local beijing = self:getChildByName("beijing")
    if beijing then
        beijing:removeFromParent()
    end

    local mfModel = self._modelMgr:getModel("MFModel")
    if mfModel:getCloudShow() == true then
        local beijing = mcMgr:createViewMC("yunqiehuan1_mfqiehuanyun", false, true)
        beijing:setAnchorPoint(cc.p(0.5,0.5))
        beijing:setPosition(cc.p(MAX_SCREEN_WIDTH*0.5, MAX_SCREEN_HEIGHT*0.5))
        self:addChild(beijing)
        mfModel:setCloudShow(false)
    end

    print("=checkTips==============+++++++++++")
    self:checkTips()
end

function MFView:updatePlayerTimes()
    local playerTimesData = self._modelMgr:getModel("PlayerTodayModel"):getData()

    local invade = self:getUI("bg.scrollView.layer.daoyu9")
    local times = (tab:Setting("G_MF_LOOT_NUM").value - playerTimesData["day28"])
    if times < 0 then
        times = 0
    end
    local str = times .. "/" .. tab:Setting("G_MF_LOOT_NUM").value
    local robtime = invade:getChildByName("robtime")
    if robtime then
        robtime:setString(str)
    else
        robtime = cc.Label:createWithTTF(str, UIUtils.ttfName, 24)
        robtime:setName("robtime")
        robtime:setAnchorPoint(cc.p(0.5, 0.5))
        robtime:setPosition(cc.p(20, 0))
        robtime:setColor(cc.c3b(255,255,255))
        robtime:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        invade:addChild(robtime, 10)
    end
    if (tab:Setting("G_MF_LOOT_NUM").value - playerTimesData["day28"]) > 0 then
        robtime:setColor(cc.c3b(0, 255, 30))
    else
        robtime:setColor(cc.c3b(255, 23, 23))
    end

    
    for i=1,CITYNUM do
        local helptime = self:getUI("helptimeBg.helptime" .. i)
        if helptime then
            if i <= (tab:Setting("G_MF_HELP_NUM").value-playerTimesData["day26"]) then
                helptime:loadTexture("mf_helpTimes1.png", 1)
            else
                helptime:loadTexture("mf_helpTimes2.png", 1)
            end
        end
    end

    self:checkTips()
end

function MFView:setMenu()
    -- local menu1 = self:getUI("menu.menu1")
    -- menu1:setScaleAnim(true)
    local menu2 = self:getUI("menu.menuList.menu2")
    menu2:setScaleAnim(true)
    
    self:registerClickEvent(menu2, function()
        self:setMenuStart()
    end)

    local fourmation = self:getUI("menu.menuList.fourmation")
    fourmation:setScaleAnim(true)
    local friend = self:getUI("menu.menuList.friend")
    friend:setScaleAnim(true)
    local log = self:getUI("menu.menuList.log")
    log:setScaleAnim(true)
	local receiveBtn = self:getUI("menu.menuList.receive")
	receiveBtn:setScaleAnim(true)
	local receiveBg = self:getUI("menu.menuList.btnBg04")
	
    fourmation:setCascadeOpacityEnabled(true)
    friend:setCascadeOpacityEnabled(true)
    log:setCascadeOpacityEnabled(true)
	receiveBtn:setCascadeOpacityEnabled(true)
	
    local lab = self:getUI("menu.menuList.fourmation.lab")
    lab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    lab:setFontName(UIUtils.ttfName)
    local lab = self:getUI("menu.menuList.friend.lab")
    lab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    lab:setFontName(UIUtils.ttfName)
    local lab = self:getUI("menu.menuList.log.lab")
    lab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    lab:setFontName(UIUtils.ttfName)
	local receiveLab = self:getUI("menu.menuList.receive.lab")
	receiveLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	receiveLab:setFontName(UIUtils.ttfName)
	
    self:registerClickEvent(fourmation, function()
        print("布阵防守阵容")
        self._viewMgr:showView("formation.NewFormationView", {
            formationType = self._modelMgr:getModel("FormationModel").kFormationTypeMFDef,
        })
        -- self:setMenuStart()
        -- self._viewMgr:showView("MF.", params, forceSync)
    end)
    self:registerClickEvent(friend, function()
        print("好友帮助")
        local param = {checkTipCallback = function()
            self:checkTips()
        end}
        self._viewMgr:showDialog("MF.MFFriendDialog", param)
        -- self:setMenuStart()
    end)
    self:registerClickEvent(log, function()
        print("战报")
        self._serverMgr:sendMsg("MFServer", "getReportList", {}, true, {}, function (result)
            -- dump(result, "result ======", 10)
            self._viewMgr:showDialog("MF.MFTaskLogDialog", {list = result.list})
            -- DialogUtils.showGiftGet({gifts = result.reward})
        end)
        -- self:setMenuStart()
        -- self._viewMgr:showDialog("MF.MFTaskLogDialog")
    end)
	
	local gifts = self:getCityData()
	local userLvl = self._modelMgr:getModel("UserModel"):getData().lvl
	if table.nums(gifts)==0 or userLvl<tonumber(tab:Setting("G_MF_TIPS_LV").value) then
		receiveBtn:setSaturation(-100)
		receiveBg:setSaturation(-100)
	else
		receiveBtn:setSaturation(0)
		receiveBg:setSaturation(0)
	end
	self:registerClickEvent(receiveBtn, function()
		if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("MF.MFReceiveDialog")
        end
		local gifts = self:getCityData()
		local ids = {}
		for i,v in ipairs(gifts) do
			table.insert(ids, v.index)
		end
		local userLvl = self._modelMgr:getModel("UserModel"):getData().lvl
		if userLvl<tonumber(tab:Setting("G_MF_TIPS_LV").value) then
			self._viewMgr:showTip(lang("MF_TIPS_DES5"))
		elseif table.nums(gifts)==0 then
			self._viewMgr:showTip(lang("MF_TIPS_DES4"))
		else
			self._serverMgr:sendMsg("MFServer", "oneKeyGetfinishMFReward", {ids = ids}, true, {}, function(result)
				local rewards = {}
				for _,v in pairs(result.reward) do
					for i,reward in ipairs(v) do
						table.insert(rewards, reward)
					end
				end
				self._viewMgr:showDialog("MF.MFReceiveDialog", {gifts = gifts, rewards = rewards, callback = function()
					self:checkTips()
				end})
			end)
			--[[--]]
		end
	end)
end

--[[
    帮助弹板
]]
function MFView:showHelpDialog()
    local lvl = self._userModel:getData().lvl
    local level = tab:Setting("G_MF_TIPS_LV").value
    if lvl < tonumber(level) then
        return
    end
    local data1,data2 = self._MFModel:getOneKeyEndData()
    if (data1 and table.nums(data1) > 0) or (data2 and table.nums(data2) > 0) then
        self._viewMgr:showDialog("MF.MFOneKeyDialog",{},true)
    end
end

function MFView:setMenuStart(menuType)
    self._isShowMenu = not self._isShowMenu
    local menu1 = self:getUI("menu.menu1")
    local menu2 = self:getUI("menu.menuList.menu2")
    local menuList = self:getUI("menu.menuList")

    local fourmation = self:getUI("menu.menuList.fourmation")
    local friend = self:getUI("menu.menuList.friend")
    local log = self:getUI("menu.menuList.log")

    if self._isShowMenu == true then
        menu2:setFlippedX(not self._isShowMenu)
        local callFunc = cc.CallFunc:create(function()
            fourmation:setVisible(true)
            friend:setVisible(true)
            log:setVisible(true)
        end)
        local seq = cc.Sequence:create(callFunc, cc.EaseBackOut:create(cc.MoveTo:create(0.2, cc.p(205, 21)))) 
        menuList:runAction(seq)
    else
        menu2:setFlippedX(not self._isShowMenu)
        local callFunc = cc.CallFunc:create(function()
            fourmation:setVisible(false)
            friend:setVisible(false)
            log:setVisible(false)
        end)
        local seq = cc.Sequence:create(cc.EaseBackIn:create(cc.MoveTo:create(0.1, cc.p(-75, 21))), callFunc)
        menuList:runAction(seq)
    end
end

function MFView:updateButton(inView)
    if inView.click == 1 then
        self._viewMgr:showTip(inView.data .. "级开启")
    elseif inView.click == 2 then
        self._viewMgr:showTip("尚未开启")
    elseif inView.click == 3 then
        self._viewMgr:showTip("敬请期待")
    end
end

function MFView:reflashUI()
    self._suo = false
    local tasks = self._modelMgr:getModel("MFModel"):getTasks()
    local currentTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local userlvl = self._modelMgr:getModel("UserModel"):getData().lvl
    for i=1,8 do
        if i <= CITYNUM then
            local cityTab = tab:MfOpen(i)
            print("userlvl <= cityTa", userlvl, cityTab["lv"])
            if userlvl >= cityTab["lv"] then
                self:updateDaoyu(cityTab, i)
            else
                print("任务未解锁" .. i)
                self._daoyu[i].cqqipao:setVisible(false)
                self._daoyu[i].titleBg:setVisible(false)
                self._daoyu[i].timeBg:setVisible(false)
                if self._suo == false then
                    self._daoyu[i].suo:setVisible(true)
                    self._suo = true
                    self._daoyu[i].click = 1
                    self._daoyu[i].data = cityTab["lv"]
                    -- self:registerClickEvent(self._daoyu[i], function()
                    --     self._viewMgr:showTip(cityTab["lv"] .. "级开启")
                    -- end)
                else
                    self._daoyu[i].suo:setVisible(false)
                    self._daoyu[i].click = 2
                    -- self:registerClickEvent(self._daoyu[i], function()
                    --     self._viewMgr:showTip("尚未开启")
                    -- end)
                end
                -- self._daoyu[i].click = 3
                -- self._daoyu[i].data = cityTab["lv"]

                self._daoyu[i].levelLab:setString(cityTab["lv"] .. "级解锁")
                -- self:setButton(self._daoyu[i], function()
                --     self._viewMgr:showTip(cityTab["lv"] .. "级开启")
                -- end)

            end
        else
            self._daoyu[i].cqqipao:setVisible(false)
            self._daoyu[i].suo:setVisible(false)
            self._daoyu[i].click = 3
            -- self:registerClickEvent(self._daoyu[i], function()
            --     self._viewMgr:showTip("敬请期待")
            -- end)
        end

    end

    if self._firstJump == false then
        -- local scrollView = self:getUI("bg.scrollView")
        -- self._scrollView:jumpToBottomRight()
        -- self:setMenuStart(1)
        local scrollTab = {
            [1] = 1,
            [2] = 1,
            [3] = 2,
            [4] = 2,
            [5] = 3,
            [6] = 3,
            [7] = 4,
            [8] = 4,
        }
        
        self:scrollToNext(scrollTab[self._awardCity])
    end
	self:setMenu()
end 

function MFView:scrollToNext(posId)
    self._firstJump = true
    if posId == 1 then
        self._scrollView:jumpToBottomRight()
    elseif posId == 2 then
        self._scrollView:jumpToBottomLeft()
    elseif posId == 3 then
        self._scrollView:jumpToTopLeft()
    elseif posId == 4 then
        self._scrollView:jumpToTopRight()
    end
end

-- 更新岛屿
function MFView:updateDaoyu(cityTab, index)
    local tasks = self._modelMgr:getModel("MFModel"):getTasks()
    local currentTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local userlvl = self._modelMgr:getModel("UserModel"):getData().lvl

    self._daoyu[index].titleBg:setVisible(true)
    local tempTask = tasks[tostring(index)]
    local taskTab = tab:MfTask(tempTask.taskId)
    local cityTab = tab:MfOpen(index)
    -- 设置星星
    local starBg = self._daoyu[index].starBg
    local x = (starBg:getContentSize().width - taskTab.star*48*1)*0.5
    for i=1,5 do
        local iconStar = starBg:getChildByName("star" .. i)
        if i <= taskTab.star then
            if iconStar == nil then
                iconStar = cc.Sprite:createWithSpriteFrameName("globalImageUI6_star1.png")
                -- iconStar:setScale(0.5)
                iconStar:setAnchorPoint(cc.p(0, 1))
                starBg:addChild(iconStar,3) 
                iconStar:setName("star" .. i)
            else
                iconStar:setVisible(true)
            end
            iconStar:setPosition(x, starBg:getContentSize().height-10)
            x = x + iconStar:getContentSize().width*iconStar:getScaleX()
        else
            if iconStar then
                iconStar:setVisible(false)
            end
        end
    end
    -- local title = self:getUI("bg.titleBg.title")
    self._daoyu[index].title:setString(lang(taskTab.name))
    if taskTab.starShow then
        self._daoyu[index].cqqipao:loadTexture("mfimg_chanchuqipao" .. taskTab.starShow .. ".png", 1)
        self._daoyu[index].cqqipao:setVisible(true)
    else
        self._daoyu[index].cqqipao:setVisible(false)
    end
    
    -- 设置icon
    local teamBg = self._daoyu[index].teamBg
    local teamIcon = teamBg:getChildByName("teamIcon")
    -- 设置兵团icon
    if taskTab["icon"] then
        local param = {itemId = taskTab["icon"], effect = true, eventStyle = 0, num = -1}
        if teamIcon then
            IconUtils:updateItemIconByView(teamIcon, param)
        else
            teamIcon = IconUtils:createItemIconById(param)
            teamIcon:setName("teamIcon")
            teamIcon:setAnchorPoint(cc.p(0, 0))
            teamIcon:setCascadeOpacityEnabled(true)
            teamIcon:setPosition(cc.p(16,22))
            teamBg:addChild(teamIcon)
            teamIcon:setScale(0.40)
        end

        teamBg:setVisible(true)
    else
        teamBg:setVisible(false)
    end
    
    
    self._daoyu[index].cloud1:setVisible(false)
    self._daoyu[index].suo:setVisible(false)

    if self._daoyu[index].timerLab then
        self._daoyu[index].timerLab:stopAllActions()
    end

    -- 处理任务开始以后
    if tempTask["finishTime"] then
        if self._daoyu[index].weikaishi then
            self._daoyu[index].weikaishi:setVisible(false)
        end
        if self._daoyu[index].teamBg then
            self._daoyu[index].teamBg:setVisible(false)
        end
        self._daoyu[index].timeBg:setVisible(true)
        local tempTime = tempTask["finishTime"]
        tempTime = tempTime - currentTime
        if tempTime > 0 then
            if self._daoyu[index].timerLab then
                self._daoyu[index].timerLab:stopAllActions()
                self._daoyu[index].timerLab:runAction(cc.RepeatForever:create(
                    cc.Sequence:create(cc.CallFunc:create(function()
                        tempTime = tempTime - 1
                        local tempValue = tempTime
                        local hour, minute, second
                        hour = math.floor(tempValue/3600)
                        tempValue = tempValue - hour*3600
                        minute = math.floor(tempValue/60)
                        tempValue = tempValue - minute*60
                        second = math.fmod(tempValue, 60)
                        local showTime = string.format("%.2d:%.2d:%.2d", hour, minute, second)
                        if tempTime <= 0 then
                            showTime = "00:00:00"
                            self._daoyu[index].timerLab:stopAllActions()
                            self:reflashUI()
                            self._daoyu[index].timerLab:setString(showTime)
                            -- self._daoyu[index].timeBar:setPercent(100)
                            self._daoyu[index].timeBar:setScaleX(1)
                            print("=========时间到，领取奖励")
                            return
                        end
                        if self._daoyu[index].timerLab then
                            self._daoyu[index].timerLab:setString(showTime)
                        end
                        if self._daoyu[index].timeBar then
                            local str = math.ceil(((3600*taskTab.time-tempTime)/(3600*taskTab.time))*100)/100
                            if str < 0 then
                                str = 0
                            end
                            self._daoyu[index].timeBar:setScaleX(str)
                        end
                    end), cc.DelayTime:create(1))
                ))
            end
        end

        if tempTask.helper and tempTask.helper ~= "" then
            local posX = cityTab["help"][1]
            local posY = cityTab["help"][2]
            if tolua.isnull(self._daoyu[index].bangzhucaihong) then
                self._daoyu[index].bangzhucaihong = mcMgr:createViewMC("bangzhucaihong_bangzhucaihong", true, false)
                self._daoyu[index].bangzhucaihong:setPosition(cc.p(self._daoyu[index]:getContentSize().width*0.5+posX, self._daoyu[index]:getContentSize().height*0.5+posY))
                self._daoyu[index]:addChild(self._daoyu[index].bangzhucaihong, 1)
            else
                self._daoyu[index].bangzhucaihong:setVisible(true)
            end
        else
            if self._daoyu and self._daoyu[index] and not tolua.isnull(self._daoyu[index].bangzhucaihong) then
                self._daoyu[index].bangzhucaihong:setVisible(false)
            end
        end
        if self._daoyu[index].stop then
            self._daoyu[index].stop:removeFromParent()
            self._daoyu[index].stop = nil
        end
        if (currentTime - tempTask["finishTime"]) >= 0 then
            self._daoyu[index].daoyu:setBrightness(40)

            -- if self._daoyu[index].kelingqu then
            --     self._daoyu[index].kelingqu:setVisible(true)
            -- else
            --     self._daoyu[index].kelingqu = cc.Sprite:createWithSpriteFrameName("mftask_award.png")
            --     self._daoyu[index].kelingqu:setPosition(cc.p(self._daoyu[index]:getContentSize().width*0.5+80, 30+self._daoyu[index]:getContentSize().height*0.5))
                
            --     local label = cc.Label:createWithTTF("可领取", UIUtils.ttfName, 24)
            --     label:setPosition(cc.p(self._daoyu[index].kelingqu:getContentSize().width*0.5, 3 + self._daoyu[index].kelingqu:getContentSize().height * 0.5))
            --     label:setColor(cc.c3b(61, 31, 0))
            --     self._daoyu[index].kelingqu:addChild(label)

            --     self._daoyu[index].kelingqu:runAction(
            --         cc.RepeatForever:create(
            --         cc.Sequence:create(
            --         cc.ScaleTo:create(0.4, 1.05),
            --         cc.ScaleTo:create(0.4, 0.95)
            --     )))
            --     self._daoyu[index]:addChild(self._daoyu[index].kelingqu, 1)
            -- end



            if taskTab["icon"] then
                if not self._daoyu[index].animTeamIcon then
                    self._daoyu[index].animTeamIcon = ccui.ImageView:create()
                    self._daoyu[index].animTeamIcon:loadTexture("mfImg_qipao.png", 1)
                    self._daoyu[index].animTeamIcon:setAnchorPoint(cc.p(0.1, 0))
                    self._daoyu[index].animTeamIcon:setPosition(cc.p(self._daoyu[index]:getContentSize().width*0.5, self._daoyu[index]:getContentSize().height*0.5))
                    -- self._daoyu[index].animTeamIcon:setName("suo")
                    self._daoyu[index]:addChild(self._daoyu[index].animTeamIcon, 1000)

                    local move1 = cc.MoveBy:create(0.5, cc.p(0, 5))
                    local move3 = cc.MoveBy:create(0.5, cc.p(0, 5))
                    local move5 = cc.MoveBy:create(0.5, cc.p(0, 5))
                    local move2 = cc.MoveBy:create(0.5, cc.p(0, -5))
                    local move4 = cc.MoveBy:create(0.5, cc.p(0, -5))
                    local move6 = cc.MoveBy:create(0.3, cc.p(0, -5))
                    -- local spawn = cc.Spawn:create(move1, move2, move3, move4)
                    local seq = cc.Sequence:create(cc.ScaleTo:create(0.3, 1), move1, move2, move3, move4, move5, move6, cc.ScaleTo:create(0.2, 0), cc.DelayTime:create(2))
                    self._daoyu[index].animTeamIcon:runAction(cc.RepeatForever:create(seq))
                end

                -- local sysTeam = tab:Team(taskTab["icon"])
                -- if self._daoyu[index].animTeamqipao then
                --     IconUtils:updateSysTeamIconByView(self._daoyu[index].animTeamqipao, {sysTeamData = sysTeam,isGray = false ,eventStyle = 0, star = false})
                -- else
                --     local animTeamqipao = IconUtils:createSysTeamIconById({sysTeamData = sysTeam,isGray = false ,eventStyle = 0, star = false})
                --     animTeamqipao:setName("animTeamqipao")
                --     animTeamqipao:setAnchorPoint(cc.p(0.5, 0.5))
                --     animTeamqipao:setCascadeOpacityEnabled(true)
                --     animTeamqipao:setPosition(cc.p(self._daoyu[index].animTeamIcon:getContentSize().width*0.5, self._daoyu[index].animTeamIcon:getContentSize().height*0.5+3))
                --     self._daoyu[index].animTeamIcon:addChild(animTeamqipao, 99)
                --     animTeamqipao:setScale(0.43)
                --     self._daoyu[index].animTeamqipao = animTeamqipao
                -- end
                local param = {itemId = taskTab["icon"], effect = true, eventStyle = 1, num = -1}
                
                if self._daoyu[index].animTeamqipao then
                    IconUtils:updateItemIconByView(self._daoyu[index].animTeamqipao, param)
                else
                    local animTeamqipao = IconUtils:createItemIconById(param)
                    animTeamqipao:setName("animTeamqipao")
                    animTeamqipao:setAnchorPoint(cc.p(0.5, 0.5))
                    animTeamqipao:setCascadeOpacityEnabled(true)
                    animTeamqipao:setPosition(cc.p(self._daoyu[index].animTeamIcon:getContentSize().width*0.5, self._daoyu[index].animTeamIcon:getContentSize().height*0.5+3))
                    self._daoyu[index].animTeamIcon:addChild(animTeamqipao, 99)
                    animTeamqipao:setScale(0.43)
                    self._daoyu[index].animTeamqipao = animTeamqipao
                end

                self._daoyu[index].animTeamIcon:setVisible(true)

                self._daoyu[index].stop = mcMgr:createViewMC("stop_bangzhucaihong", true, false)
                self._daoyu[index].stop:setName("stop")
                self._daoyu[index].stop:setPosition(cc.p(self._daoyu[index]:getContentSize().width*0.5, self._daoyu[index]:getContentSize().height*0.5-20))
                self._daoyu[index]:addChild(self._daoyu[index].stop, 99)
            else
                -- local stop = self._daoyu[index]:getChildByFullName("stop")
                -- local mc4 = mcMgr:createViewMC("borm_baoxiang", false, true, function()
                -- end)
                -- mc4:setPosition(cc.p(self._daoyu[index]:getContentSize().width*0.5, self._daoyu[index]:getContentSize().height*0.5-20))
                -- self._daoyu[index]:addChild(mc4, 99)

                self._daoyu[index].stop = mcMgr:createViewMC("stop2_bangzhucaihong", true, false)
                self._daoyu[index].stop:setName("stop")
                self._daoyu[index].stop:setPosition(cc.p(self._daoyu[index]:getContentSize().width*0.5, self._daoyu[index]:getContentSize().height*0.5-20))
                self._daoyu[index]:addChild(self._daoyu[index].stop, 99)

            end
            if self._daoyu[index].jindutiao then
                self._daoyu[index].jindutiao:setVisible(false)
            end
            if self._daoyu[index].timeBg then
                self._daoyu[index].timeBg:setVisible(false)
            end
            if not self._daoyu[index].lingjiangchangtai then
                self._daoyu[index].lingjiangchangtai = mcMgr:createViewMC("lingjiangchangtai_mfhanghaifengweitexiao", true, false)
                self._daoyu[index].lingjiangchangtai:setPosition(cc.p(self._daoyu[index]:getContentSize().width*0.5, self._daoyu[index]:getContentSize().height*0.5+1))
                self._daoyu[index]:addChild(self._daoyu[index].lingjiangchangtai, 1)
            else
                self._daoyu[index].lingjiangchangtai:setVisible(true)
            end

            if self._daoyu[index].renwuStart then
                self._daoyu[index].renwuStart:removeFromParent()
                self._daoyu[index].renwuStart = nil
            end

            self:setButton(self._daoyu[index], function()
                if tempTask.robbed then
                    local param = {pos = index}
                    self:delRob(param, tempTask, 1)
                    -- self._viewMgr:showDialog("MF.MFRobDialog", {tempTask, robType = 1})
                elseif tempTask.helper and tempTask.helper ~= "" then
                    local tempPlayerId = {}
                    for k,v in pairs(tempTask["helper"]) do
                        tempPlayerId[k] = v._id
                    end
                    local param = {fid = tempPlayerId, id = index}
                    -- self._serverMgr:sendMsg("MFServer", "thankGameFriend", param, true, {}, function (result)
                    --     dump(result, "result ===", 10)
                    --     tempTask.helper = nil
                    --     self._daoyu[index].bangzhucaihong:setVisible(false)
                    -- end)
                    self:thankGameFriend(param, tempTask)
                else
                    local gifts = self:getGift(index)
                    print("领取奖励")
                    self._viewMgr:showDialog("MF.MFAwardDialog", {gifts = gifts, index = index, callback = function()
						self:checkTips()
					end})
                end
            end)
            print("领取状态" .. index)
            self._awardCity = index
        else
            if self._daoyu[index].renwuStart then
                self._daoyu[index].renwuStart:removeFromParent()
                self._daoyu[index].renwuStart = nil
            end
            -- dump(taskTab, "taskTab===")
            local pos = tab:MfOpen(index)["cameracature"]
            -- dump(pos, "pos===")
            local daoyuPos = taskTab["cameracatureCo"]
            self._daoyu[index].renwuStart = mcMgr:createViewMC(taskTab["cameracature"], true, false)
            -- self._daoyu[index].renwuStart:setPosition(cc.p(0,0))
            local sca = pos[daoyuPos][3]
            self._daoyu[index].renwuStart:setPosition(cc.p(pos[daoyuPos][1]*sca, pos[daoyuPos][2]*sca))
            self._daoyu[index].renwuStart:setScale(sca)
            self._daoyu[index]:addChild(self._daoyu[index].renwuStart)

            -- if self._daoyu[index].kelingqu then
            --     self._daoyu[index].kelingqu:setVisible(false)
            -- end

            self:setButton(self._daoyu[index], function()
                if tempTask.robbed then
                    local param = {pos = index}
                    self:delRob(param, tempTask, 2)
                elseif tempTask.helper and tempTask.helper ~= "" then
                    local tempPlayerId = {}
                    for k,v in pairs(tempTask["helper"]) do
                        tempPlayerId[k] = v._id
                    end
                    local param = {fid = tempPlayerId, id = index}
                    self:thankGameFriend(param, tempTask)
                else
                    self._viewMgr:showView("MF.MFTaskView", {index = index, callback = function()
                        self._daoyu[index].timeBg:setVisible(true)
                        -- self._daoyu[index].timeBg:setVisible(false)
                        local seq = cc.Sequence:create(
                            cc.MoveBy:create(0, cc.p(0,-50)),
                            cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(0,50))),
                            -- cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(0,50)), cc.FadeTo:create(0.2, 150)),
                            cc.CallFunc:create(function()
                                -- self._daoyu[index].timerLab:setOpacity(255)
                            end)
                            )
                        self._daoyu[index].timeBg:runAction(seq)
                        
                    end, callbackTime = function(index)
                        self:updateDaoyu(tab:MfOpen(index), index)
                        print("MfOpen====updateDaoyu==================")
                    end})
                end
                print("岛屿" .. index)
            end)
            print("任务进行中" .. index)
        end

        
        if tempTask.robbed then
            for i=1,CITYNUM do
                if i <= table.nums(cityTab["loot"]) then
                    local posX = cityTab["loot"][i][1]
                    local posY = cityTab["loot"][i][2]
                    local tempScale = cityTab["loot"][i][3]
                    if not self._daoyu[index]["qiangduohuo" .. i] then
                        self._daoyu[index]["qiangduohuo" .. i] = mcMgr:createViewMC("qiangduduo_bangzhucaihong", true, false)
                        self._daoyu[index]:addChild(self._daoyu[index]["qiangduohuo" .. i], 1)
                    else
                        self._daoyu[index]["qiangduohuo" .. i]:setVisible(true)
                    end
                    self._daoyu[index]["qiangduohuo" .. i]:setPosition(cc.p(self._daoyu[index]:getContentSize().width*0.5+posX, self._daoyu[index]:getContentSize().height*0.5+posY))
                    self._daoyu[index]["qiangduohuo" .. i]:setScale(tempScale)
                else
                    if self._daoyu[index]["qiangduohuo" .. i] then
                        self._daoyu[index]["qiangduohuo" .. i]:setVisible(false)
                    end
                end
            end
            if self._daoyu[index].animTeamIcon then
                self._daoyu[index].animTeamIcon:setVisible(false)
            end
            if self._daoyu[index].bangzhucaihong then
                self._daoyu[index].bangzhucaihong:setVisible(false)
            end
            if self._daoyu[index].stop then
                self._daoyu[index].stop:setVisible(false)
            end
            if self._daoyu[index].renwuStart then
                self._daoyu[index].renwuStart:setVisible(false)
            end
        else
            for i=1,CITYNUM do
                if self._daoyu and self._daoyu[index] and not tolua.isnull(self._daoyu[index]["qiangduohuo" .. i]) then
                    self._daoyu[index]["qiangduohuo" .. i]:runAction(cc.Sequence:create(cc.FadeOut:create(0.3),cc.RemoveSelf:create(true)))
                    self._daoyu[index]["qiangduohuo" .. i] = nil
                end
            end
        end
        
    else
        -- lab1:setString("任务刷新时间:")
        -- lab1:setVisible(true)
        -- self._nextUpdateTime:setVisible(true)
        -- self._startTime:setString(taskTab.time .. ":00:00")
        local tempTime = tempTask.createTime + tab:Setting("G_MF_TIME").value * 60
        -- local tempTime = tempTask.createTime + tab:Setting("G_MF_TIME").value * 60
        -- print("===", tab:Setting("G_MF_TIME").value * 60)
        tempTime = tempTime - self._modelMgr:getModel("UserModel"):getCurServerTime()
        self._daoyu[index].timerLab:stopAllActions()
        self._daoyu[index].timerLab:runAction(cc.RepeatForever:create(
            cc.Sequence:create(cc.CallFunc:create(function()
                tempTime = tempTime - 1                
                if tempTime < 0 then
                    print("刷星数数 =========",tempTime, index)
                    self:getUpdateInfo(index)
                    -- self._daoyu[index].timerLab:stopAllActions()
                    return
                end
            end), cc.DelayTime:create(1))
        ))

        for i=1,CITYNUM do
            if self._daoyu[index]["qiangduohuo" .. i] then
                self._daoyu[index]["qiangduohuo" .. i]:setVisible(false)
            end
        end
        if self._daoyu[index].animTeamIcon then
            self._daoyu[index].animTeamIcon:setVisible(false)
        end
        if self._daoyu[index].renwuStart then
            self._daoyu[index].renwuStart:setVisible(false)
        end
        if self._daoyu[index].lingjiangchangtai then
            self._daoyu[index].lingjiangchangtai:setVisible(false)
        end
        if self._daoyu[index].weikaishi then
            self._daoyu[index].weikaishi:setVisible(true)
        end
        -- if self._daoyu[index].kelingqu then
        --     self._daoyu[index].kelingqu:setVisible(false)
        -- end
        
        -- local stop = self._daoyu[index]:getChildByFullName("stop")
        if self._daoyu[index].stop then
            self._daoyu[index].stop:setVisible(false)
        end
        self._daoyu[index].timeBg:setVisible(false)
        print("任务未开始" .. index)
        self:setButton(self._daoyu[index], function()
            self._viewMgr:showView("MF.MFTaskView", {index = index, callback = function()
                -- self:getUpdateInfo(index)
                -- self:updateDaoyu(tab:MfOpen(index), index)
                -- print("岛屿updateDaoyu" .. index)
                self._daoyu[index].timeBg:setVisible(true)
                local seq = cc.Sequence:create(
                    cc.MoveBy:create(0, cc.p(0,-50)),
                    cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(0,50)))
                    )
                self._daoyu[index].timeBg:runAction(seq)
            end, callbackTime = function(index)
                self:updateDaoyu(tab:MfOpen(index), index)
                print("MfOpen====updateDaoyu==================")
            end})

            print("岛屿updateDaoyu" .. index)
        end)

        if self._awardCity == 1 then
            self._awardCity = index
        end
    end
    -- self._daoyu[index].cloud:setVisible(false)
    self._daoyu[index].levelLab:setString(cityTab["lv"] .. "级解锁")
    local flag = self._modelMgr:getModel("MFModel"):getOpenCity(index)  
    if flag == true then
        self._daoyu[index].suo:setVisible(true)
        self._daoyu[index].cloud1:setVisible(true)
        self:openDaoyuAnim(index) 
        self._suo = false
    end
end

-- 答谢好友
function MFView:thankGameFriend(param, tempTask)
    self._serverMgr:sendMsg("MFServer", "thankGameFriend", param, true, {}, function (result)
        dump(result, "result ===", 10)
        self._viewMgr:showDialog("MF.MFDoleDialog", {doleType = 0, helper = tempTask.helper})
        tempTask.helper = nil
        -- self._daoyu[param.id].bangzhucaihong:setVisible(false)
        self._daoyu[param.id].bangzhucaihong:runAction(cc.Sequence:create(cc.FadeOut:create(0.3),cc.RemoveSelf:create(true)))
        local cityTab = tab:MfOpen(param.id)
        self:updateDaoyu(cityTab, param.id)
    end)
end

-- 删除入侵字段
function MFView:delRob(param, tempTask, robType)
    -- local tempP = {tempTask = tempTask, robType = robType}
    -- dump(tempP, 'tempP===')
    -- self._viewMgr:showDialog("MF.MFRobDialog", {tempTask = tempTask, robType = robType})
    self._serverMgr:sendMsg("MFServer", "delRob", param, true, {}, function(result)
        -- dump(result, "result ===", 10)
        -- self._daoyu[param.id].bangzhucaihong:setVisible(false)
        -- self._viewMgr:showDialog("MF.MFRobDialog", tempTask.robbed)
        self._viewMgr:showDialog("MF.MFRobDialog", {tempTask = tempTask, robType = robType})
        tempTask.robbed = nil
        for i=1,CITYNUM do
            if self._daoyu[param.pos]["qiangduohuo" .. i] then
                self._daoyu[param.pos]["qiangduohuo" .. i]:runAction(cc.Sequence:create(cc.FadeOut:create(0.3),cc.RemoveSelf:create(true)))
                self._daoyu[param.pos]["qiangduohuo" .. i] = nil
            end
        end
        local cityTab = tab:MfOpen(param.pos)
        self:updateDaoyu(cityTab, param.pos)
    end)
end

-- 设置按钮效果
function MFView:setButton(btn, callback)
    if not btn then
        return
    end
    self:registerTouchEvent(btn,
        function ()
            btn.daoyu:setVisible(true)
            btn.daoyu:setOpacity(0)
            btn.daoyu:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 100), cc.FadeTo:create(0.5, 50))))

            btn.daoyu:setBrightness(40)
            btn.daoyu.downSp = btn.daoyu:getVirtualRenderer()
        end,
        function ()
            if btn.daoyu.downSp ~= btn.daoyu:getVirtualRenderer() then
                btn.daoyu:setBrightness(0)
            end
        end,
        function ()
            btn.daoyu:stopAllActions()
            btn.daoyu:setVisible(false)
            btn.daoyu:setBrightness(0)
            -- self._scrollView:stopScroll()
            -- self:ActionOpen()
            callback()
        end,
        function()
            -- btn.daoyu:setScale(0.8)
            btn.daoyu:stopAllActions()
            btn.daoyu:setVisible(false)
            btn.daoyu:setBrightness(0)
        end)
end

-- 汇总奖励
function MFView:getGift(index)
    local mfModel = self._modelMgr:getModel("MFModel")
    local mfData = mfModel:getTasksById(index)

    local goldNum = mfModel:getMFGoldNum(index)

    local tempCon1 = mfModel:getTaskFinish(index, mfData["condition"]["1"])
    local tempCon2 = mfModel:getTaskFinish(index, mfData["condition"]["2"])

    local taskTab = tab:MfTask(mfData["taskId"])
    local gifts = {}

    -- dump(taskTab["awardBase"]," ======", 10)
    for k,v in pairs(taskTab["awardBase"]) do
        gifts[v[1] .. v[2]] = clone(v)
    end

    if tempCon1 >= mfData["condition"]["1"]["param2"] then
        for k,v in pairs(taskTab["awardOne"]) do
            local str = v[1] .. v[2]
            if not gifts[str] then
                gifts[str] = clone(v)
            else
                gifts[str][3] = gifts[str][3] + v[3]
            end
        end
    end
    
    if tempCon2 >= mfData["condition"]["2"]["param2"] then
        for k,v in pairs(taskTab["awardTwo"]) do
            local str = v[1] .. v[2]
            if not gifts[str] then
                gifts[str] = clone(v)
            else
                gifts[str][3] = gifts[str][3] + v[3]
            end
        end
    end

    local tempGifts = {}
    for k,v in pairs(gifts) do
        table.insert(tempGifts, v)
    end
    
    local sortFunc = function(a, b)
        local atsort = a[2]
        local btsort = b[2]
        if atsort == nil or btsort == nil then
            return 
        end
        if atsort ~= btsort then
            return atsort < btsort
        else
            if IconUtils.iconIdMap[a[1]] > IconUtils.iconIdMap[b[1]] then
                return true
            end
        end
    end
    table.sort(tempGifts, sortFunc)

    tempGifts[1][3] = tempGifts[1][3] + goldNum
    
    return tempGifts
end

-- function MFView:getfinishMFReward(index)
--     self._serverMgr:sendMsg("MFServer", "getfinishMFReward", {id = index}, true, {}, function (result)
--         dump(result, "result ======", 10)
--         print("li====================")
--         self._viewMgr:showDialog("MF.MFAwardDialog", {gifts = result.reward})
--         -- DialogUtils.showGiftGet({gifts = result.reward})
--     end)
-- end

-- function MFView:onBeforeAdd(callback, errorCallback)
--     local mfModel = self._modelMgr:getModel("MFModel")
--     local mfData = mfModel:getTasks()
--     if not mfData then
--         errorCallback()
--         return
--     end
--     local tempNum = 0
--     local flag = false
--     local userlvl = self._modelMgr:getModel("UserModel"):getData().lvl
--     for i=1,5 do
--         if tab:MfOpen(i).lv <= userlvl then
--             tempNum = tempNum + 1
--         end
--     end
--     if tempNum > table.nums(mfData) or mfModel:isEmpty() then
--         flag = true
--     end
--     if flag then
--         self._onBeforeAddCallback = function(inType)
--             if inType == 1 then 
--                 callback()
--             else
--                 errorCallback()
--             end
--         end
--         self:getMFInfo()
--     else
--         self:reflashUI()
--         callback()
--     end
-- end

function MFView:onBeforeAdd(callback, errorCallback)
    self._onBeforeAddCallback = function(inType)
        if inType == 1 then 
            callback()
        else
            errorCallback()
        end
    end
    self:getMFInfo()
	self:getAlchemyInfo()
end

function MFView:getAlchemyInfo()
	local openLevel = tab:SystemOpen("Alchemy")[1]
	local myLvl = self._userModel:getPlayerLevel()
	if myLvl>=openLevel then
		self._serverMgr:sendMsg("AlchemyServer", "getInfo", {}, true, {}, function(alchemyResult)
			self:reflashAlchemyTip()
		end)
	end
end

function MFView:reflashAlchemyTip()
	local alchemyModel = self._modelMgr:getModel("AlchemyModel")
	local alchemyDaoyu = self:getUI("bg.scrollView.layer.daoyu10")
	local daoyuSize = alchemyDaoyu:getContentSize()
	if alchemyDaoyu.daoyu then
		local mc = alchemyDaoyu:getChildByName("mc")
		if mc then
			mc:removeFromParent()
		end
		local libData = alchemyModel:getLibData()
		local nowProId, proStartTime = alchemyModel:getNowProFormulaId()
		local nowTime = self._userModel:getCurServerTime()
		local timeBg = alchemyDaoyu:getChildByName("timeBg")
		local timeLab = timeBg:getChildByName("timerLab")
		timeLab:stopAllActions()
		timeBg:setVisible(false)
		if table.nums(libData)>0 then
			mc = mcMgr:createViewMC("stop2_bangzhucaihong", true, false)
			mc:setPosition(cc.p(daoyuSize.width/2+50, daoyuSize.height/2-30))
		elseif nowProId and nowProId~=0 then
			--生产中状态
			mc = mcMgr:createViewMC("shalou_mfhanghaifengweitexiao", true, false)
			mc:setPosition(cc.p(daoyuSize.width/2-30, daoyuSize.height/4))
			timeBg:setPosition(cc.p(daoyuSize.width/2-30 + timeBg:getContentSize().width/2, daoyuSize.height/4))
			timeBg:setVisible(true)
			local needTime = tab.alchemyPlan[nowProId].costTime
			timeLab:setString(TimeUtils.getStringTimeForInt(needTime- (nowTime - proStartTime)))
			timeBg:getChildByName("timeBar"):setScaleX((nowTime-proStartTime)/needTime)
			timeLab:runAction(cc.RepeatForever:create(
				cc.Sequence:create(
					cc.CallFunc:create(function()
						local nowTempTime = self._userModel:getCurServerTime()
						if nowTempTime-proStartTime<=needTime then
							timeLab:setString(TimeUtils.getStringTimeForInt(needTime - (nowTempTime - proStartTime)))
							timeBg:getChildByName("timeBar"):setScaleX((nowTempTime-proStartTime)/needTime)
						elseif nowTempTime-proStartTime-needTime>=-1 then
							self._serverMgr:sendMsg("AlchemyServer", "getInfo", {}, true, {}, function(result)
								self:reflashAlchemyTip()
							end)
							timeLab:stopAllActions()
						end
					end),
					cc.DelayTime:create(1)
				)
			))
		else
			--待生产
			mc = mcMgr:createViewMC("tanhao_bangzhucaihong", true, false)
			mc:setPosition(cc.p(daoyuSize.width/2+30, daoyuSize.height/2))
		end
		mc:setName("mc")
		alchemyDaoyu:addChild(mc, 100)
	end
end

function MFView:getMFInfo()
    self._serverMgr:sendMsg("MFServer", "getMFInfo", {}, true, {}, function (result)
        dump(result, "result ===", 10)
		self:getMFInfoFinish(result)
    end)
end

function MFView:getMFInfoFinish(result)
    if result == nil then
        self._onBeforeAddCallback(2)
        return 
    end
    self._onBeforeAddCallback(1)
    self:reflashUI()
    self:checkTips()
end

function MFView:getUpdateInfo(index)
    local param = {id = index}
    if self._cityLock[index] == true then
        return
    end
    self._cityLock[index] = true
    self._serverMgr:sendMsg("MFServer", "reflashMFTask", param, true, {}, function (result)
        self._suo = false
        self:shuaxinAnim(index)
    end, function(errorId)
        if tonumber(errorId) == 2614 then
            print("errorId==========", errorId)
        end
    end)
end

function MFView:shuaxinAnim(index)
--     local posX, posY = 0, 0
--     posX = titlePos[index][1] + self._daoyu[index]:getContentSize().width*0.5
--     posY = titlePos[index][2] + self._daoyu[index]:getContentSize().height*0.5
    local titleBg = self:getUI("bg.scrollView.layer.daoyu" .. index .. ".titleBg")
    local seq2 = cc.Sequence:create(cc.Spawn:create(cc.MoveBy:create(0.15, cc.p(0, -30)), cc.FadeTo:create(0.15, 1)), cc.MoveBy:create(0.01, cc.p(0, 80)), cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(0, -50))), cc.FadeTo:create(0.2, 255))
    -- local seq2 = cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(0.15, cc.p(posX, posY - 30)), cc.FadeOut:create(0.15)), cc.MoveTo:create(0.01, cc.p(posX, posY + 80)), cc.Spawn:create(cc.MoveTo:create(0.2, cc.p(posX, posY))), cc.FadeIn:create(0.2))
    local callFunc = cc.CallFunc:create(function()
        print("=============", index)
        -- self:reflashUI()
        self:updateDaoyu(tab:MfOpen(index), index)
        local starBg = self._daoyu[index].starBg
        for i=1,5 do
            local iconStar = starBg:getChildByName("star" .. i)
            if iconStar and iconStar:isVisible() then
                local seq = cc.Sequence:create(cc.DelayTime:create(0.1*i),cc.ScaleBy:create(0, 3), cc.ScaleTo:create(0.1, 1))
                iconStar:runAction(seq)
            end
        end
    end)
    local callFunc1 = cc.CallFunc:create(function()
        self._cityLock[index] = false
    end)
    
    titleBg:runAction(cc.Sequence:create(seq2, cc.DelayTime:create(0.1), callFunc, cc.DelayTime:create(3), callFunc1))
end

function MFView:setNoticeBar()
    self._viewMgr:hideNotice(true)
end

function MFView:getAsyncRes()
    return 
    {
        {"asset/ui/mf.plist", "asset/ui/mf.png"},
        {"asset/ui/mf1.plist", "asset/ui/mf1.png"},
        {"asset/ui/mf2.plist", "asset/ui/mf2.png"},
    }
end


-- 岛屿开启动画
function MFView:openDaoyuAnim(index)
    local scrollTab = {
        [1] = 1,
        [2] = 1,
        [3] = 2,
        [4] = 2,
        [5] = 3,
        [6] = 3,
        [7] = 4,
        [8] = 4,
    }
    local callfunc = cc.CallFunc:create(function()
        self:scrollToNext(scrollTab[index])
    end)
    local callfunc1 = cc.CallFunc:create(function()
        if not self._daoyu[index].suo then
            return
        end
        local mc2 = mcMgr:createViewMC("hanghaijiesuo_mfhanghaifengweitexiao", false, true, function()
            if self._daoyu[index].suo then
                self._daoyu[index].suo:setVisible(false)
            end
            self._daoyu[index]["cloud1"]:runAction(cc.Spawn:create(cc.FadeOut:create(2), cc.ScaleTo:create(2, 8)))
        end)
        mc2:setPosition(self._daoyu[index].suo:getContentSize().width*0.5, self._daoyu[index].suo:getContentSize().height*0.5)
        self._daoyu[index].suo:addChild(mc2)
    end)

    local callfunc2 = cc.CallFunc:create(function()
        self._daoyu[index]["cloud1"]:setVisible(false)
        -- 烟花
        local mc2 = mcMgr:createViewMC("yanhua_mfhanghaifengweitexiao", false, true)
        mc2:setPosition(self._daoyu[index]:getContentSize().width*0.5, self._daoyu[index]:getContentSize().height*0.5)
        self._daoyu[index]:addChild(mc2)
    end)
    self:runAction(cc.Sequence:create(callfunc, callfunc1, cc.DelayTime:create(2), callfunc2))
end

-- mf 背景动画
function MFView:setHanghaiBg()
    local bg = self:getUI("bg")
    local layer = self:getUI("bg.scrollView.layer")

    -- 旋涡
    local mc2 = mcMgr:createViewMC("xuanwo_mfhanghaifengweitexiao", true, false)
    mc2:setName("xuanwo") 
    mc2:setScale(1)
    mc2:setPosition(547, 610)
    layer:addChild(mc2, -1)

    -- 背景
    -- local mc3 = mcMgr:createViewMC("haimian_mfhanghaifengweitexiao", true, false)
    -- mc3:setName("haimian")
    -- mc3:setScale(1.5)
    -- mc3:setPosition(480, 320)
    -- bg:addChild(mc3, -1)

    -- 云鸟
    local mc4 = mcMgr:createViewMC("yunniao_mfhanghaifengweitexiao", true, false)
    mc4:setName("yunniao")
    mc4:setPosition(480, 380)
    layer:addChild(mc4, 99)
end

function MFView:createShalou(index)
    local mc3 = mcMgr:createViewMC("shalou_mfhanghaifengweitexiao", true, false)
    mc3:setName("shalou")
    mc3:setScale(2)
    mc3:setPosition(0, 0)
    bg:addChild(mc3, -1)
    return shalou
end

function MFView:createTitle(x, y, index, inView)
    local titleBg = ccui.ImageView:create()
    titleBg:loadTexture("mfimg_chanchuqipao1.png", 1)
    titleBg:setAnchorPoint(cc.p(0.5, 0.5))
    titleBg:setPosition(cc.p(inView:getContentSize().width*0.5+x, inView:getContentSize().height*0.5+y))
    titleBg:setScale(0.5)
    titleBg:setName("titleBg")
    inView:addChild(titleBg, 200)

    local title =  cc.Label:createWithTTF(lang("MF_ISLANDS_" .. index), UIUtils.ttfName, 24)
    title:setAnchorPoint(cc.p(0.5, 0.5))
    title:setPosition(cc.p(inView:getContentSize().width*0.5+x, inView:getContentSize().height*0.5+y+7))
    title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    title:setName("title")
    inView:addChild(title, 500) -- 4

    return titleBg
end

function MFView:createDaoyu(x, y, index)
    local layer = self:getUI("bg.scrollView.layer")
    local daoyu = ccui.ImageView:create()
    daoyu:loadTexture("mf_btnbefore" .. index .. ".png", 1)
    daoyu:setAnchorPoint(cc.p(0.5, 0.5))
    daoyu:setPosition(cc.p(x, y))
    daoyu:setVisible(false)
    daoyu:setScale(index==10 and 1 or 2)
    daoyu:setName("daoyu")
    layer:addChild(daoyu, -1)
	
	if index~=10 then
		local mc3 = mcMgr:createViewMC("haidao" .. index .."_mfhanghaifengweitexiao", true, false)
		mc3:setName("anim2")
		mc3:setScale(1)
		mc3:setPosition(x, y)
		mc3:setPlaySpeed(0.5)
		layer:addChild(mc3, -1)
	else
		local mc3 = mcMgr:createViewMC("lianjingongfangrukou_lianjingongfangrukou", true, false)
		mc3:setName("anim2")
		mc3:setScale(1)
		mc3:setPosition(x+2, y+2)
		mc3:setPlaySpeed(0.5)
		layer:addChild(mc3, -1)
	end
	return daoyu
end

function MFView:createCloud(inView, cloudPos, index)
    local layer = self:getUI("bg.scrollView.layer")
    local cloud1 = ccui.ImageView:create()
    cloud1:loadTexture("mf_cloud" .. index .. ".png", 1)
    cloud1:setAnchorPoint(cc.p(0.5, 0.5))
    cloud1:setPosition(cc.p(cloudPos[1], cloudPos[2]))
    cloud1:setScale(2)
    cloud1:setName("cloud1")
    layer:addChild(cloud1, 100)

    return cloud1 
end

function MFView:createSuo(inView, x, y, index)
    local layer = self:getUI("bg.scrollView.layer")
    local suo = ccui.ImageView:create()
    suo:loadTexture("globalImageUI5_treasureLock.png", 1)
    suo:setAnchorPoint(cc.p(0.5, 0.5))
    suo:setPosition(cc.p(x-80, y))
    suo:setName("suo")
    layer:addChild(suo, 1000)

    local levelLab = cc.Label:createWithTTF("100级解锁", UIUtils.ttfName, 24)
    levelLab:setAnchorPoint(cc.p(0, 0.5))
    levelLab:setPosition(suo:getContentSize().width*0.5 + 20, suo:getContentSize().height*0.5)
    levelLab:setColor(cc.c3b(255, 255, 255))
    levelLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    levelLab:setName("levelLab")
    suo:addChild(levelLab) -- 4

    return suo, levelLab
end

-- 入侵数据
function MFView:getRival()
	self._viewMgr:lock(-1)
    self._serverMgr:sendMsg("MFServer", "getRival", {}, true, {}, function (result)
        local beijing = mcMgr:createViewMC("yunqiehuan_mfqiehuanyun", false, true)
        beijing:setAnchorPoint(cc.p(0.5,0.5))
        beijing:setPosition(cc.p(MAX_SCREEN_WIDTH*0.5, MAX_SCREEN_HEIGHT*0.5))
        self:addChild(beijing)

        beijing:addCallbackAtFrame(15, function(_, sender)
			self._viewMgr:unlock()
            self._viewMgr:showView("MF.MFInvadeView", result)
        end)
    end)
end

-- 进入动画
function MFView:beforePopAnim()
    local titleBg = self:getUI("titleBg")
    if titleBg then
        titleBg:setOpacity(0)
    end
end

function MFView:popAnim(callback)
    local titleBg = self:getUI("titleBg")
    if titleBg then
        ScheduleMgr:nextFrameCall(self, function()
            titleBg:stopAllActions()
            titleBg:setOpacity(255)
            local x, y = titleBg:getPositionX(), titleBg:getPositionY()
            titleBg:setPosition(x, y + 80)
            titleBg:runAction(cc.Sequence:create(
                cc.EaseOut:create(cc.MoveTo:create(0.1, cc.p(x, y - 5)), 3),
                cc.MoveTo:create(0.07, cc.p(x, y)),
                cc.CallFunc:create(function ()
                    self.__popAnimOver = true
                    if callback then callback() end
                end)
            ))
        end)
    else
        self.__popAnimOver = true
    end
end

function MFView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{hideHead=true,hideInfo=true})
end

function MFView:getCityData()
	local cityData = {}
	for i=1,8 do
		if i <= CITYNUM then
			local cityTab = tab:MfOpen(i)
			local userlvl = self._modelMgr:getModel("UserModel"):getData().lvl
			if userlvl >= cityTab["lv"] then
				local tasks = self._modelMgr:getModel("MFModel"):getTasks()
				local currentTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
				local tempTask = tasks[tostring(i)] or {}
				if tempTask.finishTime and currentTime-tempTask.finishTime>=0 then
					local gifts = self:getGift(i)
					table.insert(cityData, {index = i, gifts = gifts})
				end
			end
		end
	end
	return cityData
end

return MFView