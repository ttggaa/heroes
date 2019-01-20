--[[
    Filename:    GuildScienceDonateDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-05-04 16:07:55
    Description: File description
--]]

-- 联盟捐献
local GuildScienceDonateDialog = class("GuildScienceDonateDialog",BasePopView)
function GuildScienceDonateDialog:ctor(param)
    GuildScienceDonateDialog.super.ctor(self)
    self._callback = param.callback
    param.callback = nil
    self._donateData = param

    self._baseIndex = param.baseIndex
    self._childIndex = param.childIndex
    self._backflowModel = self._modelMgr:getModel("BackflowModel")
    self:updateBuildTimes()
    self:setListenReflashWithParam(true)

end

function GuildScienceDonateDialog:updateBuildTimes()
    self.backType,self.backTimes,self.backDiscount = self._backflowModel:getGuildScience()
    self._roleGuild = self._modelMgr:getModel("UserModel"):getData().roleGuild
    if self.backDiscount == 0 then
        self.backDiscount = 1
    else
        self.backDiscount = self.backDiscount /10
    end
    if self.backTimes then
        if self.backTimes <= 0 then
            self.backType = nil
        end
    end

    print(self.backType,self.backTimes,self.backDiscount)
end

-- 初始化UI后会调用, 有需要请覆盖5
function GuildScienceDonateDialog:onInit()
    local closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(closeBtn, function( )
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("guild.science.GuildScienceDonateDialog")
        end
        if self._callback then
            self._callback()
        end
        self:close()
    end)

    -- local title = self:getUI("bg.bg.title")
    -- UIUtils:setTitleFormat(title, 2)

    self._mask = self:getUI("bg.mask")
    self._mask:setVisible(true)
    self._mask:setOpacity(0)

    self._richTextBg = self:getUI("bg.titleBg.richTextBg")
    self._richTextBg1 = self:getUI("bg.titleBg.richTextBg1")
    self._ismaxExp = self:getUI("bg.ismaxExp")
    local lab = self:getUI("bg.titleBg.expBg.lab")
    self._refExp = false
    self:updateCost()
	self:updateOneKeyDonate()
	local checkBox = self:getUI("bg.titleBg.oneKeyPanel.checkBox")
	local userId = self._modelMgr:getModel("UserModel"):getRID()
	local defaultKey = string.format("guildScienceOneKey_%s", userId)
	checkBox:addEventListener(function(sender, eventType)
        if eventType == 0 then
            UserDefault:setStringForKey(defaultKey, 1)
        else
            UserDefault:setStringForKey(defaultKey, 0)
        end
    end)
end

function GuildScienceDonateDialog:updateCost()
    local dStatus = self._modelMgr:getModel("UserModel"):getData().roleGuild.dStatus   --wangyan
    for i=1,3 do
        local donate = self:getUI("bg.donate" .. i)

        local contribution = tab:GuildContribution(i)
        local title = donate:getChildByFullName("title")
        -- title:setFontName(UIUtils.ttfName)
        local expValue = donate:getChildByFullName("ziyuanBg.expValue")
        expValue:setString("+" .. contribution.contribution)
        local goldValue = donate:getChildByFullName("ziyuanBg.goldValue")
        goldValue:setString("+" .. contribution.award[1][3])
        local costValue = donate:getChildByFullName("ziyuanBg.costValue")
        

        if self.backType == i then
            costValue:setColor(UIUtils.colorTable.ccUIBaseColor9)
            costValue:setString(contribution.cost[3]*self.backDiscount)
        else
            costValue:setColor(cc.c4b(70,40,0,255))
            costValue:setString(contribution.cost[3])
        end

        local shuangbei = donate:getChildByFullName("shuangbei")
        local seq = cc.Sequence:create(cc.ScaleTo:create(2, 1.1), cc.ScaleTo:create(2, 0.95))
        shuangbei:runAction(cc.RepeatForever:create(seq))
        if dStatus and dStatus == 1 then
            if shuangbei then
                shuangbei:setVisible(true)
            end
        else
            if shuangbei then
                shuangbei:setVisible(false)
            end
        end
    end
    self:setAnim(dStatus)
end

function GuildScienceDonateDialog:refreshCostLable()
    self:updateBuildTimes()
    for i=1,3 do
        local donate = self:getUI("bg.donate" .. i)
        local contribution = tab:GuildContribution(i)
        local costValue = donate:getChildByFullName("ziyuanBg.costValue")
        if self.backType == i then
            costValue:setColor(UIUtils.colorTable.ccUIBaseColor9)
            costValue:setString(contribution.cost[3]*self.backDiscount)
        else
            costValue:setColor(cc.c4b(70,40,0,255))
            costValue:setString(contribution.cost[3])
        end
    end
end

function GuildScienceDonateDialog:reflashUI()
    -- dump(self._donateData)
    local guildModel = self._modelMgr:getModel("GuildModel")
    local guildScience = guildModel:getGuildScience()
    -- local guildLevel = guildScience.level
    local dStatus = self._modelMgr:getModel("UserModel"):getData().roleGuild.dStatus
    local userGuildData = self._modelMgr:getModel("UserModel"):getRoleAlliance()
    local scienceBase = guildModel:getGuildScienceBase()
    -- dump(scienceBase)
    -- self._expBefore = self._exp or 0   --wangyan 升级显示用

    if not guildScience[tostring(self._donateData.id)] then
        self._level = 1
        self._exp = 0
    elseif guildScience[tostring(self._donateData.id)] then
        self._level = guildScience[tostring(self._donateData.id)].lvl + 1
        self._exp = guildScience[tostring(self._donateData.id)].exp
    end
    local donateValue = self:getUI("bg.titleBg.donateValue")
    donateValue:setString(userGuildData.dNum)
    local timesValue = self:getUI("bg.titleBg.timesValue")
    local times = guildModel:getDonateTimes()
	local surplusTimes = times - userGuildData.dTimes
    if (times - userGuildData.dTimes) < 0 then
        timesValue:setString(0 .. "/" .. times)
    else
        timesValue:setString(surplusTimes .. "/" .. times)
    end

    if self._refExp == false then
        --进度条
        local lab = self:getUI("bg.titleBg.expBg.lab")
        local labFront = self:getUI("bg.titleBg.expBg.labfront")
        local bar = self:getUI("bg.titleBg.expBg.bar")
        if self._level > self._donateData.levelmax then
            labFront:setString(self._donateData.levelexp[(self._level - 1)])
            lab:setString("/" .. self._donateData.levelexp[(self._level - 1)])
            bar:setPercent(100)
            self._richTextBg1:setVisible(false)
        else
            labFront:setString(self._exp)
            lab:setString("/" .. self._donateData.levelexp[self._level])
            -- lab:setString(self._exp .. "/" .. self._donateData.levelexp[self._level])
            local barValue = (self._exp/self._donateData.levelexp[self._level])*100
            bar:setPercent(barValue)
            self._richTextBg1:setVisible(true)
        end
        lab:setPositionX(labFront:getPositionX()+labFront:getContentSize().width)
        self._refExp = true
    end

    dump(self._donateData,"hta666")
    local richTextStr = ""
    richTextStr = self:split(lang(self._donateData.show), self._level-1)
    -- if guildScience[tostring(data.include[indexId])] and guildScience[tostring(data.include[indexId])].lvl >= technology.levelmax then
    --     level = level - 1
    --     richTextStr = self:split(lang(technology.show), level)
    -- else
    --     richTextStr = self:split(lang(technology.show), (level - 1))
    --     -- str = self:split(lang(technology.show), level)
    --     -- self:createRichText(self._branches[indexId].nextLvlDes, str)
    -- end

    self:createRichText(self._richTextBg, richTextStr)
    local tempStr = lang("TECHNOLOGY2_WORD_" .. self._donateData.id) -- "[color=865c30,fontsize=22](Lv. " .. self._level .. "提高至[-][color=078f00,fontsize=22]{$level*2}%)[-]" .. "[color=078f00,fontsize=22])[-]"

    local richTextStr1 = self:split(tempStr, self._level)
    self:createRichText(self._richTextBg1, richTextStr1)


    local title = self:getUI("bg.titleBg.title")
    title:setString(lang(self._donateData.name))
    local lvl = self:getUI("bg.titleBg.lvl")
    lvl:setString(self._level-1)

    local userData = self._modelMgr:getModel("UserModel"):getData()

    local BaseId = tab:TechnologyBase(self._baseIndex)["include"][self._childIndex]
    print("BaseId" .. BaseId)
    local guildLevel = self._modelMgr:getModel("GuildModel"):getAllianceDetail().level
    local limitTable = tab:TechnologyChild(tonumber(BaseId))["limit"]
    local limit_guild_level = limitTable[guildLevel]

    local function checkNeedLevel(curLevel)
        for glevel,levelMax in pairs (limitTable) do 
            if curLevel <= levelMax then
                return glevel
            end
        end
    end
    
    -- limit_guild_level = 20
    for i=1,3 do
        local donate = self:getUI("bg.donate" .. i)
        local donateBtn = donate:getChildByFullName("donateBtn")
        local contribution = tab:GuildContribution(i)

        if userGuildData.dTimes >= times then
            if donateBtn.anim then
                donateBtn.anim:setVisible(false)
            end
        end



        self:registerClickEvent(donateBtn, function()

            -- print("limit_guild_level" .. limit_guild_level)
            -- dump(tab:TechnologyChild(tonumber(BaseId)))
            
            if userGuildData.dTimes >= times then
                self._viewMgr:showTip(lang("TIP_GUILD_TECHNOLOGY_2"))
            elseif self._level > self._donateData.levelmax then
                self._viewMgr:showTip(lang("TIP_GUILD_TECHNOLOGY_1"))
            elseif self._level >  limit_guild_level then
                -- self._viewMgr:showTip("联盟等级不足")
                self._viewMgr:showTip("科技已达当前等级上限")
            else
                local flag = false
                local animStr = "juanxiandianji2_juanxiandonghua"
                local cost = contribution["cost"][3]
				local maxTimes = 1
				local checkBox = self:getUI("bg.titleBg.oneKeyPanel.checkBox")
				if checkBox:isSelected() then
					local addExp = tab:GuildContribution(i).contribution
					for i=self._level,limit_guild_level do
						if i==self._level then
							maxTimes = math.ceil((self._donateData.levelexp[i] - self._exp)/addExp)
						else
							maxTimes = maxTimes + math.ceil(self._donateData.levelexp[i]/addExp)
						end
					end
					if maxTimes>surplusTimes then
						maxTimes = surplusTimes
					end
					cost = cost*maxTimes
				end
				
                if i == 1 then
                    local gold = userData.gold
                    if self.backType == i then
                       cost = cost*self.backDiscount
                    end
                    if userData.gold < cost then
                        DialogUtils.showLackRes( {goalType = "gold"})
                    else
                        flag = true
                    end
                elseif i == 2 then
--                    local cost = contribution["cost"][3]
                    if self.backType == i then
                       cost = cost*self.backDiscount
                    end

                    if userData.gem >= cost then
                        flag = true
                    else
                        local param = {callback1 = function()
                            self._viewMgr:showView("vip.VipView", {viewType = 0})
                        end}
                        DialogUtils.showNeedCharge(param)
                    end
                elseif i == 3 then
                    animStr = "juanxiandianji2_juanxiandonghua"
--                    local cost = contribution["cost"][3]
                    if self.backType == i then
                       cost = cost*self.backDiscount
                    end
                    if userData.gem >= cost then
                        flag = true
                    else
                        local param = {callback1 = function()
                            self._viewMgr:showView("vip.VipView", {viewType = 0})
                        end}
                        DialogUtils.showNeedCharge(param)
                    end
                end
                if flag == true then
                    for i=1,3 do
                        local donate = self:getUI("bg.donate" .. i)
                        donate:getChildByFullName("shuangbei"):setVisible(false)
                        -- donate:getChildByFullName("tipBg"):setVisible(false)
                    end

                    if self._tipBg then
                        self._tipBg:removeFromParent(true)
                        self._tipBg = nil
                    end
                    self:getUI("bg.tipImg"):setVisible(false)
                    
                    local param = {tid = self._donateData.id, did = i}
					if maxTimes~=1 then
						param.times = maxTimes
					end
					if i~=3 then
						self:techDonate(param)
					else
						local _time = self._modelMgr:getModel("UserModel"):getCurServerTime()
						local closeSecondConfirm = SystemUtils.loadAccountLocalData("ScienceDonate")
						if not closeSecondConfirm or TimeUtils.date("%m-%d", _time) ~= closeSecondConfirm then
							DialogUtils.showSecondConfirmDialog({
								costNum = cost,
								desc = lang("GUILD_CONFIRM_TIPS_1"),
								callback1 = function (state)
									if state then 
										SystemUtils.saveAccountLocalData("ScienceDonate", TimeUtils.date("%m-%d", _time)) 
									end
									self:techDonate(param)
								end
								})
							return 
						else
							self:techDonate(param)
						end
					end
                end
            end
        end)
    end

    local flag = false
    if (self._level-1) >= self._donateData.levelmax then
        self._richTextBg1:setVisible(false)
        flag = true
        self._ismaxExp:setVisible(true)
        self._ismaxExp:setString("已满级，无法继续捐献")
    elseif self._level >  limit_guild_level then
        flag = true
        self._ismaxExp:setVisible(true)
        local level_ = checkNeedLevel(self._level)
        self._ismaxExp:setString("下一级需要联盟Lv."..level_)
    else
        self._richTextBg1:setVisible(true)
        self._ismaxExp:setVisible(false)
    end

    local guildLevelTab = tab:GuildLevel(scienceBase.level)
    if scienceBase.todayExp >= guildLevelTab.limit then
        self._ismaxExp:setString("今日联盟经验获得已达上限")
        self._ismaxExp:setVisible(true)
    elseif flag == false then
        self._ismaxExp:setVisible(false)
    end
end 

function GuildScienceDonateDialog:refreshView(inType)
    if inType == "DayChanged" then
        self:updateBuildTimes()
        self:reflashUI()
        self:updateCost()
    end
end

function GuildScienceDonateDialog:onPopEnd()
    self:listenReflash("GuildModel", self.refreshView)
end

function GuildScienceDonateDialog:techDonate(param)
    self._factor = 1
    local dStatus = self._modelMgr:getModel("UserModel"):getData().roleGuild.dStatus
    if dStatus and dStatus == 1 then
        self._isDouble = true
        self._factor = 2
    end
    self._oldExp = self._exp
    self._serverMgr:sendMsg("GuildServer", "techDonate", param, true, {}, function (result)
        self._viewMgr:lock(-1)
        if not result["gameGuild"]["todayExp"] then
            self._viewMgr:showTip("今日联盟经验已达上限")
            self._factor = 0
        else
            self._modelMgr:getModel("GuildModel"):updateAllianceTodayExp(result["gameGuild"]["todayExp"])
        end
        if not self._roleGuild["d" .. param.did] then
            self._roleGuild["d" .. param.did] = 0
        end
        self._roleGuild["d" .. param.did] = self._roleGuild["d" .. param.did] + 1
        self:refreshCostLable()
        dump(result, "guild", 10)
        -- self:showDoubleEffect_1(param["did"])
        print("============", self._factor)
        local animStr = "juanxiandianji2_juanxiandonghua"
        if param.did == 3 then
            animStr = "juanxiandianji1_juanxiandonghua"
        end

        local donateBg = self:getUI("bg.donate" .. param.did)
        local lianCoin = mcMgr:createViewMC(animStr, false, true)
        lianCoin:setName("lianCoin")
        lianCoin:setPosition(donateBg:getContentSize().width*0.5, donateBg:getContentSize().height*0.5-50)
        donateBg:addChild(lianCoin, 10)
        if dStatus == 1 then
            ScheduleMgr:delayCall(100, self, function()
                if not animStr then return end
                local donateBg = self:getUI("bg.donate" .. param.did)
                local lianCoin = mcMgr:createViewMC(animStr, false, true)
                lianCoin:setPosition(donateBg:getContentSize().width*0.5, donateBg:getContentSize().height*0.5-50)
                donateBg:addChild(lianCoin, 10)
            end)
        end

        if self._factor == 0 then
            self:doubleDonate1()
        else
            self:doubleDonate(param["did"])
        end
        
        self:reflashUI()

        self:refreshCostLable()
    end)
    -- self:doubleDonate(param["did"])
    -- 
    -- self:reflashUI()
end

function GuildScienceDonateDialog:createRichText(inview, str)
    if not inview then
        return
    end 
    local richText = inview:getChildByName("richText")
    if richText ~= nil then
        richText:removeFromParent()
    end

    if string.find(str, "color=") == nil then
        str = "[color=865c30]"..str.."[-]"
    end   
    richText = RichTextFactory:create(str, inview:getContentSize().width, inview:getContentSize().height)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(inview:getContentSize().width*0.5, inview:getContentSize().height*0.8 - richText:getInnerSize().height*0.5)
    richText:setName("richText")
    inview:addChild(richText)
end

function GuildScienceDonateDialog:split(str,reps)
    local des = string.gsub(str,"%b{}",function( lvStr )
        local str = string.gsub(lvStr,"%$level",reps)
        return loadstring("return " .. string.gsub(str, "[{}]", ""))()
    end)
    return des 
end

function GuildScienceDonateDialog:setAnim(dStatus)
    local bg = self:getUI("bg") 
    if self._shuangbei then
        self._shuangbei:removeFromParent()
    end
    self._shuangbei = mcMgr:createViewMC("juanxianshuangbei_juanxiandonghua", true, false, function()
        -- body
    end)
    self._shuangbei:gotoAndPlay(35)
    self._shuangbei:setPosition(493, 417)
    bg:addChild(self._shuangbei, 300)

    self._shuangbei:addCallbackAtFrame(88, function()
        self._shuangbei:gotoAndPlay(35)
    end)

    self._shuangbei:addCallbackAtFrame(10, function()
        for i=1,3 do
            local donateBg = self:getUI("bg.donate" .. i)
            local xingxingshan = donateBg:getChildByName("xingxingshan")
            if xingxingshan then
                xingxingshan:setVisible(true)
            end
            local xingxingbian = donateBg:getChildByName("xingxingbian")
            if xingxingbian then
                xingxingbian:setVisible(true)
            end
            
            local shuangbei = self:getUI("bg.donate" .. i .. ".shuangbei")
            shuangbei:setVisible(true)
            -- shuangbei:setOpacity(0)
            -- shuangbei:setScale(1.3)
            -- local spawn = cc.Spawn:create(cc.FadeIn:create(0.1), cc.ScaleTo:create(0.1, 0.9))
            -- local seq = cc.Sequence:create(spawn, cc.ScaleTo:create(0.2, 1))
            -- shuangbei:runAction(seq)
        end
    end)

    if dStatus and dStatus == 1 then
        self._shuangbei:setVisible(true)
    else
        self._shuangbei:setVisible(false)
    end
    for i=1,3 do
        local donateBg = self:getUI("bg.donate" .. i)
        local donateBtn = self:getUI("bg.donate" .. i .. ".donateBtn")
        local btnAnim = donateBtn:getChildByName("donateBtn")
        if i == 2 then
            local iconBg = self:getUI("bg.donate" .. i .. ".iconBg")
            if not iconBg.mc1 then
                local mc1 = mcMgr:createViewMC("zuanshijuanxiantexiao_juanxiandonghua", true, false)
                mc1:setPosition(127, 76)
                iconBg:addChild(mc1)
                iconBg.mc1 = mc1
            else
                iconBg.mc1:setVisible(true)
            end
            
            if not iconBg.mc2 then
                local mc2 = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true, false)
                mc2:setName("anniuguangxiao")
                mc2:setPosition(donateBtn:getContentSize().width*0.5, donateBtn:getContentSize().height*0.5)
                mc2:setScaleX(1.1)
                donateBtn:addChild(mc2)
                donateBtn.anim = mc2
                iconBg.mc2 = mc2
            else
                iconBg.mc2:setVisible(true)
            end

            
        elseif i == 3 then
            local iconBg = self:getUI("bg.donate" .. i .. ".iconBg")
            if not iconBg.mc1 then
                local mc1 = mcMgr:createViewMC("zhizunjuanxiantexiao_juanxiandonghua", true, false)
                local clipNode = cc.ClippingNode:create()
                clipNode:setInverted(false)
                local mask = cc.Sprite:create()
                mask:setAnchorPoint(cc.p(0.5,0.5))
                mask:setSpriteFrame("allianceScicene_img29.png")
                
                clipNode:setStencil(mask)
                clipNode:setAlphaThreshold(0.1)
                clipNode:addChild(mc1)
                clipNode:setName("clipNode")
                clipNode:setAnchorPoint(cc.p(0.5,0.5))
                clipNode:setPosition(cc.p(iconBg:getContentSize().width*0.5,iconBg:getContentSize().height*0.5))
                iconBg:addChild(clipNode)
                iconBg.mc1 = mc1
            else
                iconBg.mc1:setVisible(true)
            end

            if not iconBg.mc2 then
                local mc2 = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true, false)
                mc2:setName("anniuguangxiao")
                mc2:setPosition(donateBtn:getContentSize().width*0.5, donateBtn:getContentSize().height*0.5)
                mc2:setScaleX(1.1)
                donateBtn:addChild(mc2)
                donateBtn.anim = mc2
                iconBg.mc2 = mc2
            else
                iconBg.mc2:setVisible(true)
            end

            if not iconBg.mc3 then
                local mc2 = mcMgr:createViewMC("zhizunjuanxianxingxing_juanxiandonghua", true, false)
                mc2:setName("xingxingshan")
                mc2:setVisible(false)
                mc2:setPosition(donateBg:getContentSize().width*0.5, donateBg:getContentSize().height*0.5)
                donateBg:addChild(mc2)
                donateBg.xingxingshan = mc2
                iconBg.mc3 = mc2
            end
        end

        local xingxingbian
        if not donateBg.xingxingshan2 then
            xingxingbian = mcMgr:createViewMC("juanxianbanzikuang_juanxiandonghua", true, false)
            xingxingbian:setName("xingxingbian")
            xingxingbian:setVisible(false)
            xingxingbian:setPosition(donateBg:getContentSize().width*0.5, donateBg:getContentSize().height*0.5)
            donateBg:addChild(xingxingbian)
            donateBg.xingxingshan2 = xingxingbian
        else
            xingxingbian = donateBg.xingxingshan2
        end
        if dStatus and dStatus == 1 then
            xingxingbian:setVisible(true)
            if donateBg.xingxingshan then
                donateBg.xingxingshan:setVisible(true)
            end
        else
            xingxingbian:setVisible(false)
        end
    end
end

function GuildScienceDonateDialog:doubleDonate(indexId)
    -- 物品移动
    local bg = self:getUI("bg") 
    local titleBg = self:getUI("bg.titleBg")
    local expIcon = self:getUI("bg.donate" .. indexId .. ".ziyuanBg.expIcon")

    local tempIcon = expIcon:clone()
    tempIcon:setName("tempIcon")
    tempIcon:setAnchorPoint(cc.p(0.5, 0.5))
    bg:addChild(tempIcon, 10)

    local expProg = self:getUI("bg.titleBg.expBg")
    local expProgWorldPoint = expProg:convertToWorldSpace(cc.p(257, 12))
    local mcPos = bg:convertToNodeSpace(cc.p(expProgWorldPoint.x,expProgWorldPoint.y))

    local itemWorldPoint = expIcon:convertToWorldSpace(cc.p(26, 10))
    local pos1 = bg:convertToNodeSpace(cc.p(itemWorldPoint.x,itemWorldPoint.y))
    tempIcon:setPosition(cc.p(pos1.x,pos1.y))

    local moveSp = cc.MoveTo:create(0.2, cc.p(mcPos.x,mcPos.y)) 
    local scaleSp = cc.ScaleTo:create(0.2, 0.8)
    local spawnSp = cc.Spawn:create(moveSp, scaleSp)

    local callFunc1 = cc.CallFunc:create(function()
        if tolua.isnull(tempIcon) == false then
            tempIcon:setPurityColor(255,255,255)
        end
        local juanxianjindutiao = mcMgr:createViewMC("juanxianjindutiao_juanxiandonghua", false, true)
        juanxianjindutiao:addCallbackAtFrame(5, function()
            --进度条
            local lab = self:getUI("bg.titleBg.expBg.lab")
            local bar = self:getUI("bg.titleBg.expBg.bar")
            local labFront = self:getUI("bg.titleBg.expBg.labfront")
            if self._level > self._donateData.levelmax then
                labFront:setString(self._donateData.levelexp[(self._level - 1)])
                lab:setString("/" .. self._donateData.levelexp[(self._level - 1)])
                -- lab:setString(self._donateData.levelexp[(self._level - 1)] .. "/" .. self._donateData.levelexp[(self._level - 1)])
                bar:setPercent(100)
            else
                labFront:setString(self._exp)
                lab:setString("/" .. self._donateData.levelexp[self._level])
                -- lab:setString(self._exp .. "/" .. self._donateData.levelexp[self._level])
                local barValue = (self._exp/self._donateData.levelexp[self._level])*100
                bar:setPercent(barValue)
            end
            lab:setPositionX(labFront:getPositionX()+labFront:getContentSize().width)
            print("self._factor=======", self._factor)
            local str = "+" .. tab:GuildContribution(indexId).technologyExp*self._factor
            self:teamPiaoNature1(str)
            self._shuangbei:setVisible(false)
        end)
        juanxianjindutiao:addCallbackAtFrame(6, function()
            self:doubleDonate1()
        end)

        juanxianjindutiao:setPosition(expProg:getContentSize().width*0.5+1, expProg:getContentSize().height*0.5)
        expProg:addChild(juanxianjindutiao)
    end)

    local seq = cc.Sequence:create(spawnSp, cc.DelayTime:create(0.1), callFunc1, cc.FadeTo:create(0.1, 100), cc.RemoveSelf:create(true))
    tempIcon:stopAllActions()
    tempIcon:runAction(seq)
end

function GuildScienceDonateDialog:doubleDonate1()
    local dStatus = self._modelMgr:getModel("UserModel"):getData().roleGuild.dStatus
    if self._shuangbei and dStatus and dStatus == 1 then
        self._shuangbei:setVisible(true)
        self._shuangbei:gotoAndPlay(1)
        self._mask:setOpacity(200)

        local bg = self:getUI("bg") 
        local yanhua = mcMgr:createViewMC("yanhua_juanxiandonghua", false, true)
        yanhua:setPosition(bg:getContentSize().width*0.5, bg:getContentSize().height*0.5+100)
        bg:addChild(yanhua, 300)

        self._mask:stopAllActions()
        local seq = cc.Sequence:create(cc.DelayTime:create(1), cc.FadeOut:create(0.3), cc.CallFunc:create(function()
            self._mask:setOpacity(0)
            self._viewMgr:unlock()
        end))
        self._mask:runAction(seq)
    else
        self._shuangbei:setVisible(false)
        for i=1,3 do
            local donateBg = self:getUI("bg.donate" .. i)
            donateBg:getChildByFullName("shuangbei"):setVisible(false)
            local xingxingshan = donateBg:getChildByName("xingxingshan")
            if xingxingshan then
                xingxingshan:setVisible(false)
            end
            local xingxingbian = donateBg:getChildByName("xingxingbian")
            if xingxingbian then
                xingxingbian:setVisible(false)
            end
        end
        self._viewMgr:unlock()
    end
    
end

function GuildScienceDonateDialog:teamPiaoNature1(str)
    local expProg = self:getUI("bg.titleBg.expBg")
    local natureLab = expProg:getChildByName("natureLab")
    natureLab = cc.Label:createWithTTF(str, UIUtils.ttfName, 24)
    natureLab:setName("natureLab")
    natureLab:setColor(UIUtils.colorTable.ccUIBaseColor2)
    natureLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    natureLab:setPosition(cc.p(expProg:getContentSize().width*0.5, expProg:getContentSize().height*0.5 - 20))
    natureLab:setOpacity(0)
    expProg:addChild(natureLab,100)

    local seqnature = cc.Sequence:create(cc.ScaleTo:create(0, 0.2), cc.DelayTime:create(0.2), 
        cc.Spawn:create(cc.ScaleTo:create(0.2, 1),cc.FadeIn:create(0.2),cc.MoveBy:create(0.2, cc.p(0,28))), 
        cc.MoveBy:create(0.38, cc.p(0,17)),
        cc.Spawn:create(cc.MoveBy:create(0.4, cc.p(0,10)),cc.FadeOut:create(0.7)),
        cc.RemoveSelf:create(true))
    natureLab:runAction(seqnature)
end

function GuildScienceDonateDialog:updateOneKeyDonate()
	local oneKeyPanel = self:getUI("bg.titleBg.oneKeyPanel")
	local myLevel = self._modelMgr:getModel("UserModel"):getPlayerLevel()
	local limitLevel = tab:Setting("QUICKDONATE_LEVEL").value
	if myLevel>=limitLevel then
		oneKeyPanel:setVisible(true)
		local checkBox = oneKeyPanel:getChildByName("checkBox")
		local userId = self._modelMgr:getModel("UserModel"):getRID()
		local defaultKey = string.format("guildScienceOneKey_%s", userId)
		local checkState = tonumber(UserDefault:getStringForKey(defaultKey))
		checkBox:setSelected((checkState and checkState==1) and true or false)
	else
		oneKeyPanel:setVisible(false)
	end
end


-- --升经验  蓝光特效  wangyan
-- function GuildScienceDonateDialog:showDoubleEffect_1(index)
--     self._viewMgr:lock(-1)
--     local donate = self:getUI("bg.donate" .. index)       --捐献btn
--     local expImg = donate:getChildByFullName("ziyuanBg.Image_57")
--     local point1 = expImg:convertToWorldSpace(cc.p(0, 0))
--     point1 = self:convertToNodeSpace(point1)
--     point1.x = point1.x + expImg:getContentSize().width/2
--     point1.y = point1.y + expImg:getContentSize().height/2

--     local expBarImg = self:getUI("bg.titleBg.expBg")   --exp
--     local point2 = expBarImg:convertToWorldSpace(cc.p(-250, 0)) 
--     point2 = self:convertToNodeSpace(point2)
--     point2.x = point2.x + expBarImg:getContentSize().width/2 + 40
--     point2.y = point2.y + expBarImg:getContentSize().height/2

--     local anim1 = mcMgr:createViewMC("qidian_juanxiandonghua", false, true) 
--     anim1:addCallbackAtFrame(8, function()  
--         local anim2 = mcMgr:createViewMC("lansefeixing_juanxiandonghua", false, true)
--         anim2:addCallbackAtFrame(9, function()
--             local anim3 = mcMgr:createViewMC("zhongdian_juanxiandonghua", false, true)
--             anim3:addCallbackAtFrame(8, function()
--                 --升级数显示
--                 local upNumDes = cc.Label:createWithTTF("", UIUtils.ttfName, 30)
--                 upNumDes:setString("+" .. tab:GuildContribution(index).contribution * self._factor)
--                 upNumDes:setColor(UIUtils.colorTable.ccUIBaseColor2)
--                 upNumDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
--                 upNumDes:setPosition(point2.x + 140, point2.y)
--                 self:addChild(upNumDes)
--                 local _moveTo = cc.MoveBy:create(0.4, cc.p(0, 25))
--                 upNumDes:runAction(cc.Sequence:create(_moveTo, cc.CallFunc:create(function()
--                     upNumDes:removeFromParent(true)
--                     end)))

--                 local dStatus = self._modelMgr:getModel("UserModel"):getData().roleGuild.dStatus
--                 if dStatus and dStatus == 1 then
--                     -- self:showDoubleEffect_2()
--                     self._viewMgr:unlock()
--                 else
--                     self._viewMgr:unlock()
--                 end
--                 end)
--             anim3:setPosition(point2)
--             self:addChild(anim3)

--             --进度条
--             local lab = self:getUI("bg.titleBg.expBg.lab")
--             local bar = self:getUI("bg.titleBg.expBg.bar")
--             if self._level > self._donateData.levelmax then
--                 lab:setString(self._donateData.levelexp[(self._level - 1)] .. "/" .. self._donateData.levelexp[(self._level - 1)])
--                 bar:setPercent(100)
--             else
--                 lab:setString(self._exp .. "/" .. self._donateData.levelexp[self._level])
--                 local barValue = (self._exp/self._donateData.levelexp[self._level])*100
--                 bar:setPercent(barValue)
--             end
--         end)

--         if index == 3 then
--             anim2:setScaleX(2.2)
--         elseif index == 2 then
--             anim2:setScaleX(1.2)
--         end
        
--         local midPoint = MathUtils.midpoint(point1, point2)   
--         anim2:setPosition(point1)

--         local angle = 360 - MathUtils.angleAtan2(point1, point2) + 90
--         anim2:setRotation(angle)
--         self:addChild(anim2)
--     end)
--     anim1:setPosition(point1)
--     self:addChild(anim1)
-- end 

-- --双倍 黄光特效 wangyan
-- function GuildScienceDonateDialog:showDoubleEffect_2()
--     self._tipBg = ccui.ImageView:create("allianceScience_tip.png", 1)
--     self._tipBg:setPosition(cc.p(MAX_SCREEN_WIDTH/2, MAX_SCREEN_HEIGHT/2 + 100))  
--     self:addChild(self._tipBg)
--     self._tipBg:ignoreContentAdaptWithSize(false)

--     self._tipBg:setScale(0.5)
--     local big = cc.ScaleTo:create(0.15, 1.1)
--     local small = cc.ScaleTo:create(0.1, 1)
--     self._tipBg:runAction(cc.Sequence:create(big, small))

--     --双倍三道光特效
--     local function createDoubleEff()
--         self._playNum = 0
--         for _index=1,3 do
--             local point1 = self._tipBg:convertToWorldSpace(cc.p(0, 0))
--             point1 = self:convertToNodeSpace(point1)
--             point1.x = point1.x + self._tipBg:getContentSize().width/2
--             point1.y = point1.y + self._tipBg:getContentSize().height/2

--             local denateBtn = self:getUI("bg.donate".._index..".donateBtn")
--             local point2 = denateBtn:convertToWorldSpace(cc.p(0, 0)) 
--             point2 = self:convertToNodeSpace(point2)
--             point2.x = point2.x + denateBtn:getContentSize().width/2
--             point2.y = point2.y + denateBtn:getContentSize().height/2 - 35

--             local huangsefeixing = mcMgr:createViewMC("huangsefeixing_juanxiandonghua", false, true)
--             huangsefeixing:addCallbackAtFrame(9, function()
--                 self._playNum = self._playNum + 1
--                 if self._playNum == 3 then
--                     -- self._tipBg:removeFromParent(true)

--                     for i=1,3 do
--                         local donate = self:getUI("bg.donate" .. i)
--                         local shuangbei = donate:getChildByFullName("shuangbei")
--                         local tipBg11 = donate:getChildByFullName("tipBg")
--                         if shuangbei then
--                             shuangbei:setVisible(true)
--                         end
--                         if tipBg11 then
--                             tipBg11:setVisible(true)
--                         end
--                     end
--                     self._viewMgr:unlock()
--                 end
--                 local shuaguangDown = mcMgr:createViewMC("wenzishuaguang1_juanxiandonghua", false, true, function()
--                     end)
--                 shuaguangDown:setPosition(point2.x, point2.y)
--                 self:addChild(shuaguangDown)
--                 end)

--             local midPoint = MathUtils.midpoint(point1, point2)   
--             huangsefeixing:setPosition(point1)
--             local angle = 360 - MathUtils.angleAtan2(point1, point2) + 90
--             huangsefeixing:setRotation(angle)
--             self:addChild(huangsefeixing)

--             huangsefeixing:setScaleY(1.5)
--             if _index == 2 then
--                 huangsefeixing:setPlaySpeed(0.85)
--                 huangsefeixing:setScaleX(1.7)
--             elseif _index == 3 then
--                 huangsefeixing:setPlaySpeed(1.2)
--                 huangsefeixing:setScaleX(1.9)
--             else
--                 huangsefeixing:setPlaySpeed(1)
--                 huangsefeixing:setScaleX(1.8)
--             end
--         end
        
--     end

--     local wenzishuaguang = mcMgr:createViewMC("wenzishuaguang_juanxiandonghua", false, true)
--     wenzishuaguang:addCallbackAtFrame(15, function()
--         createDoubleEff()
--     end)
--     wenzishuaguang:setPosition(cc.p(MAX_SCREEN_WIDTH/2 - 100, MAX_SCREEN_HEIGHT/2 + 100)) 
--     self:addChild(wenzishuaguang, 20)
-- end

return GuildScienceDonateDialog