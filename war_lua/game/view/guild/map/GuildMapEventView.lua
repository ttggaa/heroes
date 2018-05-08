--[[
    Filename:    GuildMapEventView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-06-15 16:58:47
    Description: File description
--]]


local GuildMapEventView = class("GuildMapEventView", BasePopView, require("game.view.guild.map.GuildMapCommonBattle"))
  
function GuildMapEventView:ctor(data)
    GuildMapEventView.super.ctor(self)

    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then
            UIUtils:reloadLuaFile("guild.map.GuildMapEventView")
        elseif eventType == "enter" then 
        end
    end)

    self._userId = self._modelMgr:getModel("UserModel"):getData()._id
    self._guildId = self._modelMgr:getModel("UserModel"):getData().guildId

    self._guildMapModel = self._modelMgr:getModel("GuildMapModel")
    self._eventType = data.eventType
	if self._eventType==GuildConst.ELEMENT_EVENT_TYPE.YEAR then
		self._eventCallback = data.resultCallback
	end
    self._callback = data.callback
    self._targetId = data.targetId
    self._eleId = data.eleId
    self._closePopCallback = data.closePopCallback
    self._isRemote = data.isRemote
	
	if data.eventType==GuildConst.ELEMENT_EVENT_TYPE.YEAR then
		self._yearData = data.yearData
	end

    self._enterBattle = false
    if data.eventType==GuildConst.ELEMENT_EVENT_TYPE.OFFICER and data.rewardState then
		self._rewardState = true
		self._commanderData = data.commanderData
		self._getAllRewardCallback = data.getAllRewardCallback
	end
end

function GuildMapEventView:closeInit()
    self:setVisible(false)
    self._viewMgr:lock(-1)
    ScheduleMgr:delayCall(0, self, function ()
        self._viewMgr:unlock()
        if self._closePopCallback ~= nil then 
            self._closePopCallback(self.parentView)
        end
        if self.close ~= nil then
            self:close(true)
        end
    end)
end

function GuildMapEventView:onInit()

    for i=1,12 do
        local event = self:getUI("event" .. i )
        if event ~= nil then 
            event:setVisible(false)
        end
    end

    for i=20,22 do
        local event = self:getUI("event" .. i )
        if event ~= nil then 
            event:setVisible(false)
        end
    end

    local event = self:getUI("event7_1")
    event:setVisible(false)

    local event = self:getUI("event1_1")
    event:setVisible(false)
	
	for i=26, 28 do
		local event = self:getUI("event"..i)
		if event then
			event:setVisible(false)
		end
	end

    self._sysGuildMapThing = tab:GuildMapThing(self._eleId)

    if self._eleId == 34 then 
        self._eventType = "1_1"
    end

    local subTitleLab = self:getUI("event" .. self._eventType .. ".bg.infoBg.titleLab")
    local titleLab = self:getUI("event" .. self._eventType .. ".bg.titleBg.titleLab")
    UIUtils:setTitleFormat(titleLab, 1)
    -- titleLab:setFontName(UIUtils.ttfName)
    -- titleLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
    if subTitleLab == nil then 
        titleLab:setString(lang(self._sysGuildMapThing.name))
    else
        subTitleLab:setString(lang(self._sysGuildMapThing.name))
        UIUtils:adjustTitle(self:getUI("event" .. self._eventType .. ".bg.infoBg"))
    end
    

    local descBg = self:getUI("event" .. self._eventType .. ".bg.descBg")
--    print("descBg ~= nil and self._sysGuildMapThing.des====", descBg ~= nil , self._sysGuildMapThing.des)
    if descBg ~= nil and self._sysGuildMapThing.des ~= nil then 
        local str = lang(self._sysGuildMapThing.des)
        if string.find(str, "color=") == nil then
            str = "[color=000000]"..str.."[-]"
        end          
--        print("str-====", str)
        local rtx = RichTextFactory:create(str,descBg:getContentSize().width ,descBg:getContentSize().height)
        rtx:setPixelNewline(true)
        rtx:formatText()
        rtx:setVerticalSpace(3)
        rtx:setAnchorPoint(cc.p(0,0.5))
        rtx:setPosition(-rtx:getInnerSize().width/2,descBg:getContentSize().height - rtx:getRealSize().height/2)
        descBg:addChild(rtx)
    end


    local eventBg = self:getUI("event" .. self._eventType)
    eventBg:setVisible(true)

    local closeBtn
	if self._eventType == GuildConst.ELEMENT_EVENT_TYPE.YEAR then
		closeBtn = self:getUI("event26.bg.passBtn")
	else
		closeBtn = self:getUI("event" .. self._eventType .. ".bg.closeBtn")
	end
    self:registerClickEvent(closeBtn, function ()
        if self._closePopCallback ~= nil then 
            self._closePopCallback(self.parentView)
        end
        self:close(true)
    end)


    self["onInit" .. self._eventType](self)
end

--[[
--! @function onInit1
--! @desc 直接领取奖励 初始化
--! @return 
--]]

function GuildMapEventView:onInit1()
    local infoBg = self:getUI("event1.bg.infoBg")

    local userData = self._modelMgr:getModel("UserModel"):getData()
    local reward = {}
    for i=1, 6 do
        local award = self._sysGuildMapThing["award" .. i]
        if award ~= nil  and userData.lvl >= award[1] and userData.lvl <= award[2] then 
            for k,v in pairs(award[3]) do
                reward[#reward + 1] = v 
            end
        end
    end
    -- 奖励
    local GuildMapUtils = require "game.view.guild.map.GuildMapUtils"
    local backNode = GuildMapUtils:showItems(reward)
    backNode:setPosition(infoBg:getContentSize().width/2, infoBg:getContentSize().height/2)
    infoBg:addChild(backNode)

    local enterBtn = self:getUI("event1.bg.enterBtn")
    self:registerClickEvent(enterBtn, function ()
        self:roleGetReward()
    end)
end

--[[
--! @function onInit2
--! @desc 直接领取奖励 初始化
--! @return 
--]]
function GuildMapEventView:onInit1_1()
    local infoBg = self:getUI("event1_1.bg.infoBg")
 


    local reward = self._sysGuildMapThing["award1"][3][1]
    -- local showImg = self:getUI("event1_1.bg.showImg")
    -- if self._sysGuildMapThing.art1 ~= nil then 
    --     showImg:loadTexture(self._sysGuildMapThing.art1 .. ".png", 1)
    -- end
    local tempPic = cc.Sprite:createWithSpriteFrameName(self._sysGuildMapThing.art1 .. ".png")
    tempPic:setAnchorPoint(0.5, 0)
    tempPic:setPosition(cc.p(infoBg:getContentSize().width * 0.5 - 20, 20))
    infoBg:addChild(tempPic)




    local showIcon = self:getUI("event1_1.bg.showIcon")
    showIcon:loadTexture("i_111.png", 1)

    local tipLab = self:getUI("event1_1.bg.tipLab")
    tipLab:setColor(UIUtils.colorTable.ccUIBaseTextColor1)

    local tipLab1 = self:getUI("event1_1.bg.tipLab1")
    tipLab1:setColor(UIUtils.colorTable.ccUIBaseColor2)
    tipLab1:setString("+" .. reward[3])
    tipLab1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    local enterBtn = self:getUI("event1_1.bg.enterBtn")
    self:registerClickEvent(enterBtn, function ()
        self:roleGetReward()
    end)
end


--[[
--! @function onInit2
--! @desc 兑换奖励 初始化
--! @return 
--]]
function GuildMapEventView:onInit2()
    local enterBtn = self:getUI("event2.bg.enterBtn")
    self:registerClickEvent(enterBtn, function ()
        self:exchangeReward()
    end)

    local cancelBtn = self:getUI("event2.bg.cancelBtn")
    self:registerClickEvent(cancelBtn, function ()
        self:giveUpExchange()
    end)

    if self._sysGuildMapThing.use == nil then 
        return
    end

    local useItem = self._sysGuildMapThing.use[1]
    if useItem == nil then 
        return
    end 

    local infoBg = self:getUI("event2.bg.infoBg")
    local userData = self._modelMgr:getModel("UserModel"):getData()


    -- 奖励
    local GuildMapUtils = require "game.view.guild.map.GuildMapUtils"
    local backNode = GuildMapUtils:showItems(self._sysGuildMapThing["exchange"])
    backNode:setPosition(infoBg:getContentSize().width/2, infoBg:getContentSize().height/2)
    infoBg:addChild(backNode)

    -- 所需消耗
    local useBg = self:getUI("event2.bg.useBg")
    local tips1 = {}
    if useItem[1] == "gem" then
        tips1[1] = cc.Sprite:createWithSpriteFrameName("globalImageUI_diamond.png")
    else
        tips1[1] = cc.Sprite:createWithSpriteFrameName("globalImageUI_gold1.png")
    end
    tips1[1]:setScale(0.62)
    tips1[2] = cc.Label:createWithTTF(" "..useItem[3],UIUtils.ttfName, 16)
    tips1[2]:setColor(UIUtils.colorTable.ccUIBaseTextColor1)

    local nodeTip1 = UIUtils:createHorizontalNode(tips1)
    nodeTip1:setAnchorPoint(cc.p(0.5, 0.5))
    nodeTip1:setPosition(useBg:getContentSize().width/2, useBg:getContentSize().height/2 - 4 )
    useBg:addChild(nodeTip1)
end


--[[
--! @function onInit3
--! @desc 直接获得buffer 初始化
--! @return 
--]]
function GuildMapEventView:onInit3()

    local infoBg = self:getUI("event3.bg.infoBg")

    
    local tipLab = self:getUI("event3.bg.tipLab")
    tipLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    -- tipLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    local buffers = self._sysGuildMapThing["buff"]
    local sysBuffPic = tab.crusadeBuffPic
    local tips1 = {}
    for k,v in pairs(buffers) do
        local bufferIcon = cc.Sprite:createWithSpriteFrameName("guildMapImg_buffer" .. v[1] .. ".png")
        local desc = lang("CRUSADE_BUFFS1_" .. v[1])   --text
        local result,count = string.gsub(desc, "$num", v[2])
        if count > 0 then 
            desc = result
        end
        bufferIcon:setScale(0.7)

        local richText = RichTextFactory:create(desc, bufferIcon:getContentSize().width + 60, 0)
        richText:formatText()
        richText:setScale(1.3)
        richText:setPosition(bufferIcon:getContentSize().width+ 25 + richText:getContentSize().width/2, bufferIcon:getContentSize().height/2)
        bufferIcon:addChild(richText)
        infoBg:addChild(bufferIcon)
        if k == 1 then 
            bufferIcon:setPosition(150, infoBg:getContentSize().height - 75)
        else
            bufferIcon:setPosition(150, infoBg:getContentSize().height - 135)
        end
    end

    local enterBtn = self:getUI("event3.bg.enterBtn")
    self:registerClickEvent(enterBtn, function ()
        self:getBuff()
    end)
end

--[[
--! @function onInit4
--! @desc 迷雾开启 初始化
--! @return 
--]]
function GuildMapEventView:onInit4()

    -- local enterBtn = self:getUI("event4.bg.enterBtn")
    -- self:registerClickEvent(enterBtn, function ()
    --     -- self:missFog()
    -- end)


    self._openFog = false
    local mapList = self._guildMapModel:getData().mapList
    self._fogTipLab = self:getUI("event" .. self._eventType .. ".bg.tipLab")
    self._fogTipLab:setFontName(UIUtils.ttfName)
    self._fogTipLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
    self._fogTipLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    local thisTarget = mapList[self._targetId]
    if thisTarget == nil then 
        self._viewMgr:showTip(lang("GUILD_MAP_RESULT_CODE_TIP_3004")) 
        self:closeInit()
        return
    end

    local thisEle = thisTarget.guild
    if thisEle == nil then 
        self._viewMgr:showTip(lang("GUILD_MAP_RESULT_CODE_TIP_3004")) 
        self:closeInit()
        return
    end

    local activeBtn = self:getUI("event4.bg.activeBtn")
    activeBtn:setVisible(false)

    local infoBg = self:getUI("event4.bg.infoBg")
    infoBg:loadTexture(self._sysGuildMapThing.art1 .. ".png", 1)

    -- 如果已经激活
    if thisEle.haduse ~= nil and 
        tonumber(thisEle.haduse) >= 1 then
        self._fogTipLab:setString("已激活")
        self._fogTipLab:setColor(UIUtils.colorTable.ccUIBaseColor2)
        self._fogTipLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        return
    end
    
    if self._isRemote == true then 
        self._fogTipLab:setString("未激活")
        self._fogTipLab:setColor(UIUtils.colorTable.ccColorQuality6)  
        self._fogTipLab:disableEffect()
        return
    end

    
    local closeBtn = self:getUI("event4.bg.closeBtn")
    self:registerClickEvent(closeBtn, function ()
        if self._openFog == true then 
            if self._callback ~= nil then 
                self._callback()
            end
        end
        if self.close ~= nil then
            self:close(true)
        end
    end)

    activeBtn:setVisible(true)
    if activeBtn.mc1 == nil then
        local mc1 = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true, false)
        mc1:setName("anim")
        mc1:setPosition(activeBtn:getContentSize().width*activeBtn:getScaleX()*0.5, activeBtn:getContentSize().height*activeBtn:getScaleY()*0.5)
        activeBtn:addChild(mc1, 1)
    end
    self:registerClickEvent(activeBtn, function ()
        activeBtn:setVisible(false)
        local mapList = self._guildMapModel:getData().mapList
        local thisTarget = mapList[self._targetId]
        if thisTarget == nil then 
            self._viewMgr:showTip("建筑不存在")
            self:closeInit()
            return
        end
        local thisEle = thisTarget.guild
        if thisEle ~= nil and thisEle.haduse ~= nil and tonumber(thisEle.haduse) >= 1 then
            self._viewMgr:showTip("建筑已激活")
            self:closeInit()
            return
        end
        self:missFog()
    end)    
end




--[[
--! @function updateEvent5Plan3
--! @desc 事件类型5我方公会展示
--! @return 
--]]
function GuildMapEventView:event5Plan3()
    local mapList = self._guildMapModel:getData().mapList
    local userList = self._guildMapModel:getData().userList
    -- 当前元素信息
    local thisEle = mapList[self._targetId].common
    -- 占领用户信息
    local holdUserInfo = userList[thisEle.owner]

    local guildId = self._modelMgr:getModel("UserModel"):getData().guildId
    
    -- 攻击按钮
    local attackBtn = self:getUI("event5.bg.attackBtn")
    self:registerClickEvent(attackBtn, function ()
        -- self:close()
        local mapList = self._guildMapModel:getData().mapList
        local userList = self._guildMapModel:getData().userList
        local thisEle = mapList[self._targetId].common
        if thisEle == nil or thisEle.owner == nil or userList[thisEle.owner] == nil then 
            self._viewMgr:showTip(lang("GUILD_MAP_RESULT_CODE_TIP_3023"))
            self:closeInit()
            return
        end
        self:getAimInfo(thisEle.owner, 1)
    end)

    -- 路过右侧
    local cancelBtn = self:getUI("event5.bg.cancelBtn")
    self:registerClickEvent(cancelBtn, function ()
        self:close()
    end)

    -- 路过中间
    local cancelBtn2 = self:getUI("event5.bg.cancelBtn2")
    self:registerClickEvent(cancelBtn2, function ()
        self:close()
    end)

    self:registerClickEvent(cancelBtn2, function ()
        self:close()
    end)


    local headBg = self:getUI("event5.bg.headBg")
    headBg:setVisible(true)

    local rewardBg = self:getUI("event5.bg.rewardBg")
    rewardBg:setPositionY(rewardBg.positionY)


    -- 移除头像上内容
    local avatarBg = self:getUI("event5.bg.headBg.avatarBg")
    avatarBg:removeAllChildren()

    -- 头像
    local avatar = IconUtils:createHeadIconById({avatar = holdUserInfo.avatar,level = holdUserInfo.lvl , tp = 4,avatarFrame = holdUserInfo["avatarFrame"]})   --,tp = 2
    avatarBg:addChild(avatar)


    local nameLab = self:getUI("event5.bg.headBg.nameLab")
    nameLab:setFontName(UIUtils.ttfName)
    nameLab:setString(holdUserInfo.name)
    nameLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    
    -- 战力
    local labScore = self:getUI("event5.bg.headBg.labScore")
    labScore:setString("a" ..holdUserInfo.score)
    labScore:setFntFile(UIUtils.bmfName_zhandouli)

    local tipLab = self:getUI("event5.bg.headBg.tipLab")
    tipLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    local headTipLab2 = self:getUI("event5.bg.headBg.tipLab2")
    headTipLab2:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    local tipLab = self:getUI("event5.bg.rewardBg.tipLab")
    tipLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    -- local tipLab2 = self:getUI("event5.bg.headBg.Label_347")
    -- tipLab2:setFontName(UIUtils.ttfName)
    -- tipLab2:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    -- tipLab2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    local mapHurtLab = self:getUI("event5.bg.headBg.mapHurtLab")
    mapHurtLab:setFontName(UIUtils.ttfName)
    mapHurtLab:setColor(UIUtils.colorTable.ccColorQuality6)
    mapHurtLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1) 
    if holdUserInfo.mapHurt == nil then 
        mapHurtLab:setString("0/100")
    else
        mapHurtLab:setString(holdUserInfo.mapHurt .. "/100")
    end

    -- mapHurtLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    local tipLab1 = self:getUI("event5.bg.tipLab1")
    tipLab1:setFontName(UIUtils.ttfName)
    tipLab1:setVisible(true)

    local holdTimeLab = self:getUI("event5.bg.holdTimeLab")
    holdTimeLab:setVisible(true)
    holdTimeLab:setString("0%")
    holdTimeLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1) 
    if tostring(userList[thisEle.owner].guildId) == tostring(guildId) then 
        cancelBtn2:setVisible(true)
        tipLab1:setString("敌方占领")
        tipLab1:setColor(UIUtils.colorTable.ccUIBaseColor2)
        tipLab1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)      

        holdTimeLab:setColor(UIUtils.colorTable.ccUIBaseColor2)

    else
        print(" if tostring(userList[thisEle.owner].guildId) == tostring(guildId) then ===",  tostring(userList[thisEle.owner].guildId),  tostring(guildId)  )
        tipLab1:setString("敌方占领")
        tipLab1:setColor(UIUtils.colorTable.ccColorQuality6)
        tipLab1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1) 

        holdTimeLab:setColor(UIUtils.colorTable.ccColorQuality6)

        cancelBtn:setVisible(true)
        attackBtn:setVisible(true)               
    end
       
    local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()    

    -- 时间满足的话，可以领取  
    if tonumber(thisEle.locktime) > curTime then 
        -- 占领进度提示
        holdTimeLab:runAction(
            cc.RepeatForever:create(
                    cc.Sequence:create(cc.CallFunc:create(
                        function()
                            local mapList = self._guildMapModel:getData().mapList
                            if mapList == nil then 
                                return
                            end
                            if mapList[self._targetId] == nil then 
                                self._viewMgr:showTip("您失去此矿")
                                holdTimeLab:stopAllActions()
                                self:closeInit()
                                return
                            end                    
                            local thisEle = mapList[self._targetId].common
                            if thisEle == nil or thisEle.owner == nil then 
                                if self._enterBattle == true then 
                                    holdTimeLab:stopAllActions()
                                    self:onInit5()
                                else
                                    holdTimeLab:stopAllActions()
                                    self._viewMgr:showTip("其他玩家取消占领")
                                    self:closeInit()
                                end
                                return
                            end
                            local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
                            local percent = math.ceil((curServerTime - tonumber(thisEle.createtime)) / (tonumber(thisEle.locktime) - tonumber(thisEle.createtime)) * 100)
                            if curServerTime > tonumber(thisEle.locktime) then 
                                holdTimeLab:stopAllActions()
                                self:onInit5()
                                return
                            end
                            holdTimeLab:setString(percent .. "%")    
                            -- thisEle.locktime - curServerTime
                        end),
                    cc.DelayTime:create(2)
                )
            ))
    else
        holdTimeLab:setString("100%")
    end
end


--[[
--! @function onInit5
--! @desc 读条获取奖励 初始化
--! @return 
--]]
function GuildMapEventView:onInit5()

    self._enterBattle = false
    print("GuildMapEventView:onInit5()=================================", self._targetId)
    local mapList = self._guildMapModel:getData().mapList
    local userList = self._guildMapModel:getData().userList

    local thisTarget = mapList[self._targetId]

    if thisTarget == nil then 
        self._viewMgr:showTip("已经被占领")
        self:closeInit()
        return
    end
    local thisEle = thisTarget.common
    if thisEle == nil or next(thisEle) == nil then 
        self._viewMgr:showTip("数据不匹配")
        self:closeInit()
        return
    end
    local headBg = self:getUI("event5.bg.headBg")
    headBg:setVisible(false)

    local descBg = self:getUI("event5.bg.descBg")
    descBg:setVisible(false)


    -- 路过右侧
    local cancelBtn = self:getUI("event5.bg.cancelBtn")
    -- 放弃中间
    local cancelBtn1 = self:getUI("event5.bg.cancelBtn1")
    -- 路过中间
    local cancelBtn2 = self:getUI("event5.bg.cancelBtn2")

    cancelBtn:setVisible(false)
    cancelBtn1:setVisible(false)
    cancelBtn2:setVisible(false)

    -- 左侧掠夺
    local enterBtn = self:getUI("event5.bg.enterBtn")
    enterBtn:setVisible(false)

    -- 中间领取
    local enterBtn1 = self:getUI("event5.bg.enterBtn1")
    enterBtn1:setVisible(false)

    -- 攻击按钮
    local attackBtn = self:getUI("event5.bg.attackBtn")
    attackBtn:setVisible(false)

    local tipLab = self:getUI("event5.bg.rewardBg.tipLab")
    tipLab:setFontName(UIUtils.ttfName)
    tipLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)



    

    -- 占领进度提示
    local tipLab1 = self:getUI("event5.bg.tipLab1")
    tipLab1:setVisible(false)
    -- tipLab1:setFontName(UIUtils.ttfName)
    
    -- 占领进度提示
    local holdTimeLab = self:getUI("event5.bg.holdTimeLab")
    holdTimeLab:setVisible(false)
    holdTimeLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
    holdTimeLab:setString("0%")
    holdTimeLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1) 

    local infoBg = self:getUI("event5.bg.infoBg")
    if self._sysGuildMapThing.art1 ~= nil then
        if infoBg.tempPic == nil then 
            local tempPic = cc.Sprite:createWithSpriteFrameName(self._sysGuildMapThing.art1 .. ".png")
            tempPic:setAnchorPoint(0.5, 0)
            tempPic:setPosition(cc.p(infoBg:getContentSize().width * 0.5 - 20, 30))
            infoBg:addChild(tempPic)
            infoBg.tempPic = tempPic
        end
    end

    local userData = self._modelMgr:getModel("UserModel"):getData()
    local reward = {}

    for i=1, 6 do
        local award = self._sysGuildMapThing["award" .. i]
        if award ~= nil  and userData.lvl >= award[1] and userData.lvl <= award[2] then 
            for k,v in pairs(award[3]) do
                reward[#reward + 1] = v 
            end
        end
    end
    local rewardBg = self:getUI("event5.bg.rewardBg")

    if rewardBg.backNode ~= nil then rewardBg.backNode:removeFromParent() end
    -- 奖励
    local GuildMapUtils = require "game.view.guild.map.GuildMapUtils"
    local backNode = GuildMapUtils:showItems(reward)
    backNode:setAnchorPoint(0, 0.5)
    backNode:setPosition(15, rewardBg:getContentSize().height/2)
    rewardBg:addChild(backNode)
    rewardBg.backNode = backNode
    if rewardBg.positionY == nil then
        rewardBg.positionY = rewardBg:getPositionY()
    end
    rewardBg:setPositionY(rewardBg.positionY + 30)

    local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()

    print("curServerTime==================",curTime, thisEle.locktime )

    -- 我自己占领占领
    local plan2 = function()
        descBg:setVisible(true)
        -- tipLab:setVisible(false)
        enterBtn1:setVisible(false)
        cancelBtn1:setVisible(false)
        holdTimeLab:stopAllActions()

        -- backNode:setPosition(infoBg:getContentSize().width/2, infoBg:getContentSize().height/2 + 20)
        -- 时间满足的话，可以领取  
        if tonumber(thisEle.locktime) > curTime then 
            cancelBtn1:setVisible(true)
            self:registerClickEvent(cancelBtn1, function ()
                self:cancelTimeRewardRead(function() 
                    holdTimeLab:stopAllActions() 
                    self:onInit5() 
                    self._callback(2, nil)
                end)
            end)
            -- 占领进度提示
            tipLab1:setVisible(true)
            tipLab1:setString("我方占领")
            tipLab1:setColor(UIUtils.colorTable.ccUIBaseColor2)
            tipLab1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1) 

            holdTimeLab:setVisible(true)
            holdTimeLab:setColor(UIUtils.colorTable.ccUIBaseColor2)
            holdTimeLab:runAction(
                cc.RepeatForever:create(
                        cc.Sequence:create(cc.CallFunc:create(
                            function()
                                local mapList = self._guildMapModel:getData().mapList
                                if mapList == nil then 
                                    return
                                end
                                local thisTarget = mapList[self._targetId]
                                if thisTarget == nil then 
                                    self._viewMgr:showTip("您失去此矿")
                                    holdTimeLab:stopAllActions()
                                    self:closeInit()
                                    return
                                end
                                local thisEle = thisTarget.common
                                if thisEle == nil or thisEle.owner == nil then 
                                    self._viewMgr:showTip("您失去此矿")
                                    holdTimeLab:stopAllActions()
                                    self:closeInit()
                                    return
                                end

                                local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
                                local percent = math.ceil((curServerTime - tonumber(thisEle.createtime)) / (tonumber(thisEle.locktime) - tonumber(thisEle.createtime)) * 100)
                                if curServerTime > tonumber(thisEle.locktime) then 
                                    holdTimeLab:stopAllActions()
                                    self:onInit5()
                                    return
                                end
                                -- 防止倒计时过程中被别人攻击了
                                if thisEle.owner ~= self._userId then 
                                    holdTimeLab:stopAllActions()
                                    self._viewMgr:showTip("您被其他人攻击，失去此矿")
                                    self:onInit5()
                                    return
                                end
                                holdTimeLab:setString(percent .. "%")    
                                -- thisEle.locktime - curServerTime
                            end),
                        cc.DelayTime:create(2)
                    )
                ))

        else
            enterBtn1:setVisible(true)
            self:registerClickEvent(enterBtn1, function ()
                 self:getTimeRewardGet()
            end)            
        end
    end


    -- 无人占领
    local plan1 = function()
        descBg:setVisible(true)
        -- tipLab:setVisible(true)
        print("1GuildMapEventView:onInit5()=================================")
        enterBtn:setVisible(true)
        cancelBtn:setVisible(true)
        self:registerClickEvent(enterBtn, function ()
            self:getTimeRewardRead(function()
                if self.onInit5 == nil then return end
                self:onInit5()
                self._callback(1, nil)
            end)
        end)

        self:registerClickEvent(cancelBtn, function ()
            self:close()
        end)
    end

    -- 无人占领
    if thisEle.owner == nil then 
        plan1()
        return
    end
    
    -- 我自己占领
    if thisEle.owner == self._userId then 
        plan2()
        return
    end
    -- 其他人占领
    if thisEle.owner ~= self._userId then 
        -- dump(self._modelMgr:getModel("UserModel"):getData())
        -- local guildId = self._modelMgr:getModel("UserModel"):getData().guildId
        -- if tostring(userList[thisEle.owner].guildId) == tostring(guildId) then 
        --     -- 我方公会
        --     return
        -- end
        self:event5Plan3()
        -- 敌方公会占领
        -- plan4()
        -- self._viewMgr:showTip("当前点正在被敌人占领")
    end
end


--[[
--! @function onInit7
--! @desc 金矿、招募点（联盟） 初始化
--! @return 
--]]
function GuildMapEventView:onInit7()

    local mapList = self._guildMapModel:getData().mapList

    local thisTarget = mapList[self._targetId]
    if thisTarget == nil then 
        self._viewMgr:showTip("数据不匹配")
        self:closeInit()
        return
    end

    local thisEle = thisTarget.common

    if thisEle == nil or next(thisEle) == nil then 
        self._viewMgr:showTip("数据不匹配")
        self:closeInit()
        return
    end

    -- 抢夺者相关信息
    local enemyPanel = self:getUI("event7.bg.enemyPanel")
    enemyPanel:setVisible(false)

    local closeBtn = self:getUI("event7.bg.closeBtn")
    self:registerClickEvent(closeBtn, function ()
        self:close(true)
    end)
    
    local infoBg = self:getUI("event7.bg.infoBg")
    if infoBg.tempPic == nil then
        local tempPic = cc.Sprite:createWithSpriteFrameName(self._sysGuildMapThing.art1 .. ".png")
        tempPic:setAnchorPoint(0.5, 0)
        tempPic:setPosition(cc.p(infoBg:getContentSize().width * 0.5 - 20, 20))
        infoBg:addChild(tempPic)
        infoBg.tempPic = tempPic
    end
    
    local tipLab4 = self:getUI("event7.bg.tipLab4")
    tipLab4:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    local tipLab5 = self:getUI("event7.bg.tipLab5")
    tipLab5:setColor(UIUtils.colorTable.ccUIBaseTextColor2)


    -- 每日奖励
    local tipLab2 = self:getUI("event7.bg.tipLab2")
    tipLab2:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    local tipLab1 = self:getUI("event7.bg.tipLab1")
    tipLab1:setColor(UIUtils.colorTable.ccUIBaseTextColor1)

    self._fogTipImg = self:getUI("event7.bg.stateImg")

    -- self._fogTipLab = self:getUI("event7.bg.stateLab")
    -- self._fogTipLab:setString("未激活")
    -- self._fogTipLab:setColor(UIUtils.colorTable.ccUIBaseColor6)
 
    local serverLvl = self._guildMapModel:getData().servLv

    local rewordNum = 0
    local reward = {}
    for k,v in pairs(self._sysGuildMapThing.produceAward) do
        if serverLvl >= v[1] and serverLvl <= v[2] then 
            for k,v1 in pairs(v[3]) do
                local tempV = clone(v1)
                tempV[3] = ((100/ self._sysGuildMapThing.point) * v1[3])
                rewordNum = rewordNum + tempV[3]
                reward[#reward + 1] = tempV
            end
        end
    end

    local numLab = self:getUI("event7.bg.numLab")
    numLab:setColor(UIUtils.colorTable.ccUIBaseColor2)
    numLab:setString(rewordNum)
    numLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1) 
    
    local tipLab6 = self:getUI("event7.bg.tipLab6")
    tipLab6:setColor(UIUtils.colorTable.ccUIBaseTextColor2)


    local spliceImg = self:getUI("event7.bg.spliceImg")
    if self._sysGuildMapThing.functype == 2 then 
        print("self._sysGuildMapThing.funtype=================================")
        spliceImg:setVisible(true)
        spliceImg:setPositionX(numLab:getPositionX() + numLab:getContentSize().width + 4)
        tipLab6:setPositionX(spliceImg:getPositionX() + spliceImg:getContentSize().width * spliceImg:getScaleX() + 2)
    else
        spliceImg:setVisible(false)
        tipLab6:setPositionX(numLab:getPositionX() + numLab:getContentSize().width + 2)
    end
    dump(self._sysGuildMapThing, "test", 10)
    


    local activeBtn = self:getUI("event7.bg.activeBtn")
    activeBtn:setVisible(false)
    -- 如果已经激活
    if thisEle.haduse ~= nil and 
        tonumber(thisEle.haduse) >= 1 then
        self:activeEvent7()
    end


    if not(thisEle.haduse ~= nil and 
        tonumber(thisEle.haduse) >= 1) and self._isRemote == true then 
        -- self._fogTipLab:setString("未激活")
        -- self._fogTipLab:setColor(UIUtils.colorTable.ccColorQuality6)    
        self._fogTipImg:loadTexture("guildMapImg_temp36.png", 1)    
    end

    local rewardBg = self:getUI("event7.bg.rewardBg")
    if rewardBg.backNode ~= nil then rewardBg.backNode:removeFromParent() end
    local GuildMapUtils = require "game.view.guild.map.GuildMapUtils"
    -- 当前公会的人才能激活
    local currentGuildId = self._guildMapModel:getData().currentGuildId
    if tostring(currentGuildId) == tostring(self._guildId) then

        local backNode = GuildMapUtils:showItems(reward, nil, 1)
        backNode:setAnchorPoint(0, 0.5)
        backNode:setScale(0.8)
        backNode:setPosition(20, rewardBg:getContentSize().height/2)
        rewardBg:addChild(backNode)
        rewardBg.backNode = backNode


        if self._isRemote == false and not (thisEle.haduse ~= nil and 
        tonumber(thisEle.haduse) >= 1) then
            activeBtn:setVisible(true)
            -- if activeBtn.mc1 == nil then
            --     local mc1 = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true, false)
            --     mc1:setName("anim")
            --     mc1:setPosition(activeBtn:getContentSize().width*activeBtn:getScaleX()*0.5, activeBtn:getContentSize().height*activeBtn:getScaleY()*0.5)
            --     activeBtn:addChild(mc1, 1)
            -- end
            self:registerClickEvent(activeBtn, function ()
                local mapList = self._guildMapModel:getData().mapList
                local thisTarget = mapList[self._targetId]
                if thisTarget == nil then 
                    self._viewMgr:showTip("建筑不存在")
                    self:closeInit()
                    return
                end
                local thisEle = thisTarget.common
                if thisEle ~= nil and thisEle.haduse ~= nil and tonumber(thisEle.haduse) >= 1 then 
                    self._viewMgr:showTip("建筑已激活")
                    self:closeInit()
                    return
                end                
                self:acGoldMine()
            end)
        end
    else

        local backNode = GuildMapUtils:showItems(reward)
        backNode:setAnchorPoint(0, 0.5)
        backNode:setScale(0.8)
        backNode:setPosition(20, rewardBg:getContentSize().height/2)
        rewardBg:addChild(backNode)
        rewardBg.backNode = backNode

        self:onInit7_Enemy()
    end
    
end


--[[
--! @function onInit7
--! @desc 金矿、招募点（联盟）敌对公会人员显示界面
--! @return 
--]]
function GuildMapEventView:onInit7_Enemy()
    print('onInit7_Enemy=====')

    local event = self:getUI("event7")
    event:setVisible(false)

    local event = self:getUI("event7_1")
    event:setVisible(true)
    
    local subTitleLab = self:getUI("event7_1.bg.infoBg.titleLab")
    local titleLab = self:getUI("event7_1.bg.titleBg.titleLab")
    UIUtils:setTitleFormat(titleLab, 1)

    if subTitleLab == nil then 
        titleLab:setString(lang(self._sysGuildMapThing.name))
    else
        subTitleLab:setString(lang(self._sysGuildMapThing.name))
        UIUtils:adjustTitle(self:getUI("event7_1.bg.infoBg"))
    end
    
    local infoBg = self:getUI("event7_1.bg.infoBg")
    if infoBg.tempPic == nil then
        local tempPic = cc.Sprite:createWithSpriteFrameName(self._sysGuildMapThing.art1 .. ".png")
        tempPic:setAnchorPoint(0.5, 0)
        tempPic:setPosition(cc.p(infoBg:getContentSize().width * 0.5 - 20, 20))
        infoBg:addChild(tempPic)
        infoBg.tempPic = tempPic
    end

    local outPutProgress = self:getUI("event7_1.bg.progBgPanel.outPutProgress")
    local outPutProgressBg = self:getUI("event7_1.bg.progBgPanel.outPutProgressBg")


    -- 路过右侧
    local cancelBtn = self:getUI("event7_1.bg.cancelBtn")
    -- 放弃中间
    local cancelBtn1 = self:getUI("event7_1.bg.cancelBtn1")

    cancelBtn:setVisible(false)
    cancelBtn1:setVisible(false)

    -- 左侧掠夺
    local enterBtn = self:getUI("event7_1.bg.enterBtn")
    enterBtn:setVisible(false)

    -- 中间领取
    local enterBtn1 = self:getUI("event7_1.bg.enterBtn1")
    enterBtn1:setVisible(false)


    -- 是否抢夺完成
    local getTipLab = self:getUI("event7_1.bg.getTipLab")
    getTipLab:setVisible(false)
    getTipLab:setColor(UIUtils.colorTable.ccUIBaseColor1)


    local tipLab = self:getUI("event7_1.bg.rewardBgPanel.tipLab")
    tipLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    -- 占领进度提示
    local tipLab1 = self:getUI("event7_1.bg.progBgPanel.tipLab1")
    tipLab1:setColor(UIUtils.colorTable.ccUIBaseTextColor2)


    local tipLab2 = self:getUI("event7_1.bg.tipLab2")
    tipLab2:setVisible(false)
    tipLab2:setColor(UIUtils.colorTable.ccColorQuality6)
    tipLab2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1) 

    -- local tipLab3 = self:getUI("event7_1.bg.tipLab3")
    -- tipLab3:setColor(UIUtils.colorTable.ccUIBaseColor1)
    -- tipLab3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    -- 占领进度提示
    local holdTimeLab = self:getUI("event7_1.bg.progBgPanel.holdTimeLab")
    holdTimeLab:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    holdTimeLab:setString("0%")

    local mapList = self._guildMapModel:getData().mapList
    local thisTarget = mapList[self._targetId]
    if thisTarget == nil then 
        self._viewMgr:showTip("数据不匹配")
        return
    end

    local thisEle = thisTarget.common
    if thisEle == nil then 
        self._viewMgr:showTip("数据不匹配")
        return
    end

    local closeBtn = self:getUI("event7_1.bg.closeBtn")
    self:registerClickEvent(closeBtn, function ()
        self:close(true)
    end)


    local descBg = self:getUI("event7_1.bg.descBg")
    descBg:removeAllChildren()
    
    if descBg ~= nil and self._sysGuildMapThing.enemyshow ~= nil then 
        local str = lang(self._sysGuildMapThing.enemyshow)
        if string.find(str, "color=") == nil then
            str = "[color=000000]"..str.."[-]"
        end          
        local rtx = RichTextFactory:create(str,descBg:getContentSize().width - 20,descBg:getContentSize().height)
        rtx:setPixelNewline(true)
        rtx:formatText()
        rtx:setVerticalSpace(3)
        rtx:setAnchorPoint(cc.p(0,0.5))
        rtx:setPosition(-rtx:getInnerSize().width/2,descBg:getContentSize().height/2)
        descBg:addChild(rtx)
    end


    local userData = self._modelMgr:getModel("UserModel"):getData()
    local reward = {}

    local award = self._sysGuildMapThing["award1"]
    if award ~= nil then
        for k,v in pairs(award) do
            if userData.lvl >= v[1] and userData.lvl <= v[2] then 
                for k1,v1 in pairs(v[3]) do
                    reward[#reward + 1] = v1
                end
            end
        end
    end

    
    local rewardBgPanel = self:getUI("event7_1.bg.rewardBgPanel")
    -- end
    local GuildMapUtils = require "game.view.guild.map.GuildMapUtils"
    local backNode = GuildMapUtils:showItems(reward, nil, 0)
    backNode:setAnchorPoint(0, 0.5)
    backNode:setScale(0.8)
    backNode:setPosition(15, rewardBgPanel:getContentSize().height/2)
    rewardBgPanel:addChild(backNode)
    rewardBgPanel:setVisible(true)

    local progBgPanel = self:getUI("event7_1.bg.progBgPanel")
    progBgPanel:setVisible(false)
    -- 远程访问只显示部分信息
    if self._isRemote == true then 
        if thisEle.lastRob ~= nil then 
            local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
            local tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
            local tempLastRob = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(thisEle.lastRob,"%Y-%m-%d 05:00:00"))
            if tempCurDayTime <= tempLastRob then 
                tipLab2:setVisible(true)
            end
        end        
        return
    end
    -- 我自己占领占领
    local plan2 = function()
        -- tipLab:setVisible(false)
        enterBtn1:setVisible(false)
        cancelBtn1:setVisible(false)
        holdTimeLab:stopAllActions()

        -- backNode:setPosition(infoBg:getContentSize().width/2, infoBg:getContentSize().height/2 + 20)
        -- 时间满足的话，可以领取  
        local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
        if tonumber(thisEle.locktime) > curTime then 
            cancelBtn1:setVisible(true)
            self:registerClickEvent(cancelBtn1, function ()
                self:robGoldMineCancel(function() 
                    holdTimeLab:stopAllActions() 
                    self:onInit7_Enemy() 
                    self._callback(2, nil)
                end)
            end)
            rewardBgPanel:setVisible(false)
            -- 占领进度提示
            progBgPanel:setVisible(true)
            holdTimeLab:runAction(
                cc.RepeatForever:create(
                        cc.Sequence:create(cc.CallFunc:create(
                            function()
                                local mapList = self._guildMapModel:getData().mapList
                                if mapList == nil then
                                    return
                                end
                                local thisTarget = mapList[self._targetId]
                                if thisTarget == nil then 
                                    return
                                end

                                local thisEle = thisTarget.common
                                if thisEle == nil or thisEle.owner == nil then 
                                    self._viewMgr:showTip("您失去此矿")
                                    self:closeInit()
                                    return
                                end
                                local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
                                local percent = math.ceil((curServerTime - tonumber(thisEle.createtime)) / (tonumber(thisEle.locktime) - tonumber(thisEle.createtime)) * 100)
                                if curServerTime > tonumber(thisEle.locktime) then 
                                    holdTimeLab:stopAllActions()
                                    self:onInit7_Enemy()
                                    return
                                end
                                -- 防止倒计时过程中被别人攻击了
                                if thisEle.owner ~= self._userId then 
                                    holdTimeLab:stopAllActions()
                                    self._viewMgr:showTip("您被其他人攻击，失去此矿")
                                    self:onInit7_Enemy()
                                    return
                                end
                                holdTimeLab:setString(percent .. "%")    

                                outPutProgress:setPercent(percent)
                                -- thisEle.locktime - curServerTime
                            end),
                        cc.DelayTime:create(2)
                    )
                ))

        else
            enterBtn1:setVisible(true)
            self:registerClickEvent(enterBtn1, function ()
                 self:robGoldMineGet()
            end)            
        end
    end


    -- 无人占领
    local plan1 = function()
        -- tipLab:setVisible(true)
        print("1GuildMapEventView:onInit7_Enemy()=================================")
        local unlockFunction = function()
            enterBtn:setVisible(true)
            cancelBtn:setVisible(true)
            

            -- lastRob
            self:registerClickEvent(enterBtn, function ()
                self:robGoldMineRead(function()
                    self:onInit7_Enemy()
                    self._callback(1, nil)
                end)
            end)

            self:registerClickEvent(cancelBtn, function ()
                self:close()
            end)
        end
        
        if thisEle.lastRob == nil then 
            unlockFunction()
        else
            local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
            local todayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
            local yesdayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime - 86400,"%Y-%m-%d 05:00:00"))

            local restTime = 0
            if curServerTime >= todayTime then
                restTime = todayTime
            else
                restTime = yesdayTime
            end

            if tonumber(thisEle.lastRob) < restTime then 
                unlockFunction()
            else
                tipLab2:setVisible(true)
            end
        end
    end

    -- 无人占领
    if thisEle.owner == nil then 
        plan1()
        return
    end
    
    -- 我自己占领
    if thisEle.owner == self._userId then 
        plan2()
        return
    end
   
end

function GuildMapEventView:activeEvent7()
    local mapList = self._guildMapModel:getData().mapList
    local thisEle = mapList[self._targetId].common

    local tipLab1 = self:getUI("event7.bg.tipLab1")
    tipLab1:setColor(UIUtils.colorTable.ccUIBaseColor2)
    tipLab1:setString(thisEle.perc)
    tipLab1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1) 

    local tipLab5 = self:getUI("event7.bg.tipLab5")
    tipLab5:setPositionX(tipLab1:getPositionX() + tipLab1:getContentSize().width )
    

    -- self._fogTipLab:setString("已激活")
    -- self._fogTipLab:setColor(UIUtils.colorTable.ccUIBaseColor2)

    self._fogTipImg:loadTexture("guildMapImg_temp37.png", 1)

    local activeBtn = self:getUI("event7.bg.activeBtn")
    activeBtn:setVisible(false)

    local tipLab3 = self:getUI("event7.bg.enemyPanel.tipLab3")
    tipLab3:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    local enemyNumLab = self:getUI("event7.bg.enemyPanel.enemyNumLab")
    enemyNumLab:setColor(UIUtils.colorTable.ccColorQuality6)
    enemyNumLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1) 


    local tipLab8 = self:getUI("event7.bg.enemyPanel.tipLab8")
    tipLab8:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    local enemyPanel = self:getUI("event7.bg.enemyPanel")
    if thisEle.hadrob == nil or next(thisEle.hadrob) == nil then 
        enemyPanel:setVisible(false)
        if enemyPanel.getPointInfo == true then return end
        enemyPanel.getPointInfo = true
        self:getPointInfo(
            function() 
                self:activeEvent7()
            end)
    else
        enemyPanel:setVisible(true)
        local x = 0
        for k,v in pairs(thisEle.hadrob) do
            local avatar = IconUtils:createHeadIconById({avatar = v.avatar, level = v.lvl , tp = 1, avatarFrame = v.avatarFrame})   --,tp = 2
            avatar:setPosition(x, 5)
            avatar:setAnchorPoint(0, 0)
            enemyPanel:addChild(avatar)
            avatar:setScale(0.6)

            self:registerClickEvent(avatar, function ()
                self:getTargetUserBattleInfo(v.rid, false)
            end)
            
            x = x + avatar:getContentSize().width * avatar:getScaleX()
            if k >= 4 then 
                break
            end
        end
        enemyNumLab:setString(table.nums(thisEle.hadrob))
        tipLab8:setPositionX(enemyNumLab:getPositionX() + enemyNumLab:getContentSize().width)
    end
    
end

--[[
--! @function onInit11
--! @desc 边境大门
--! @return 
--]]
function GuildMapEventView:onInit11()
    local mapList = self._guildMapModel:getData().mapList
    local thisTarget = mapList[self._targetId]
    if thisTarget == nil then 
        self._viewMgr:showTip("数据不匹配")
        return
    end


    self._fogTipLab = self:getUI("event" .. self._eventType .. ".bg.tipLab")
    self._fogTipLab:setFontName(UIUtils.ttfName)
    self._fogTipLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
    self._fogTipLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    local closeBtn = self:getUI("event4.bg.closeBtn")
    self:registerClickEvent(closeBtn, function ()
        if self._openFog == true then 
            if self._callback ~= nil then 
                self._callback()
            end
        end
        if self.close ~= nil then
            self:close(true)
        end
    end)
    self._fogTipLab:setString("未激活")
    self._fogTipLab:setColor(UIUtils.colorTable.ccColorQuality6)    
    self._fogTipLab:disableEffect()

    local thisEle = thisTarget.guild
    if thisEle == nil then 
        self._viewMgr:showTip("数据不匹配")
        return
    end    

    local infoBg = self:getUI("event11.bg.infoBg")
    infoBg:loadTexture(self._sysGuildMapThing.art1 .. ".png", 1)

    -- 如果已经激活
    if mapList[self._targetId].guild.haduse ~= nil and 
        tonumber(mapList[self._targetId].guild.haduse) >= 1 then
        self._fogTipLab:setString("已激活")
        self._fogTipLab:setColor(UIUtils.colorTable.ccUIBaseColor2)
        self._fogTipLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1) 
        return
    end
    
    if self._isRemote == true then 
        self._fogTipLab:setString("未激活")
        self._fogTipLab:setColor(UIUtils.colorTable.ccColorQuality6)  
        self._fogTipLab:disableEffect() 
        return
    end

end


--[[
--! @function onInit12
--! @desc 迷雾开启 初始化
--! @return 
--]]
function GuildMapEventView:onInit12()

    -- local enterBtn = self:getUI("event4.bg.enterBtn")
    -- self:registerClickEvent(enterBtn, function ()
    --     -- self:missFog()
    -- end)

    local mapList = self._guildMapModel:getData().mapList

    local thisTarget = mapList[self._targetId]
    if thisTarget == nil then 
        self._viewMgr:showTip("数据不匹配")
        self:closeInit()
        return
    end

    local thisEle = thisTarget.guild
    if thisEle == nil then 
        self._viewMgr:showTip("数据不匹配")
        self:closeInit()
        return
    end

    local closeBtn = self:getUI("event12.bg.closeBtn")
    self:registerClickEvent(closeBtn, function ()
        if self._openGold == true then 
            if self._callback ~= nil then 
                self._callback()
            end
        end
        if self.close ~= nil then
            self:close(true)
        end
    end)
    
    if thisEle == nil or next(thisEle) == nil then 
        self._viewMgr:showTip("数据不匹配")
        self:closeInit()
        return
    end

    local infoBg = self:getUI("event12.bg.infoBg")
    infoBg:loadTexture(self._sysGuildMapThing.art1 .. ".png", 1)

    self._openGold = false

    self._fogTipLab = self:getUI("event12.bg.tipLab")
    self._fogTipLab:setFontName(UIUtils.ttfName)
    self._fogTipLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
    -- self._fogTipLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._fogTipLab:setVisible(false)
    print("mapList[self._targetId].guild.haduse============", mapList[self._targetId].guild.haduse)
    local activeBtn = self:getUI("event12.bg.activeBtn")
    activeBtn:setVisible(false)
    -- 如果已经激活
    if thisEle.haduse ~= nil and 
        tonumber(thisEle.haduse) >= 1 then
        self._fogTipLab:setVisible(true)
        self._fogTipLab:setString("已激活")
        self._fogTipLab:setColor(UIUtils.colorTable.ccUIBaseColor2)
        self._fogTipLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)   
        return
    end
    
    if self._isRemote == true then 
        self._fogTipLab:setVisible(true)
        self._fogTipLab:setString("未激活")
        self._fogTipLab:setColor(UIUtils.colorTable.ccColorQuality6)     
        self._fogTipLab:disableEffect() 
        return
    end
    activeBtn:setVisible(true)
    -- if activeBtn.mc1 == nil then
    --     local mc1 = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true, false)
    --     mc1:setScale(1.1)
    --     mc1:setName("anim")
    --     mc1:setPosition(activeBtn:getContentSize().width*activeBtn:getScaleX()*0.5, activeBtn:getContentSize().height*activeBtn:getScaleY()*0.5)
    --     activeBtn:addChild(mc1, 1)
    -- end

    self:registerClickEvent(activeBtn, function ()
        activeBtn:setVisible(false)
        local mapList = self._guildMapModel:getData().mapList
        local thisTarget = mapList[self._targetId]
        if thisTarget == nil then 
            self._viewMgr:showTip("建筑不存在")
            self:closeInit()
            return
        end
        local thisEle = thisTarget.guild
        if thisEle ~= nil and thisEle.haduse ~= nil and tonumber(thisEle.haduse) >= 1 then
            self._viewMgr:showTip("建筑已激活")
            self:closeInit()
            return
        end
        self:acTent()
    end)
end

--[[
--! @function onInit26
--! @desc 新年使者 初始化
--! @return 
--]]
function GuildMapEventView:onInit26()
--	self._viewMgr:showTip("GuildMapEventView:onInit26")
	local infoBg = self:getUI("event26.bg.infoBg")
	local npcImg = cc.Sprite:createWithSpriteFrameName(self._sysGuildMapThing.art..".png")
	npcImg:setPosition(infoBg:getContentSize().width/2, 25)
	npcImg:setScale(0.8)
	npcImg:setAnchorPoint(0.5, 0)
	infoBg:addChild(npcImg)
	
	local titleLab = self:getUI("event26.bg.titleBg.titleLab")
	titleLab:setString(lang(self._sysGuildMapThing.name))
	
	
	local rewardPanel = self:getUI("event26.bg.desc2")
	local rtx = RichTextFactory:create(lang("REWARD_TIPS1"),rewardPanel:getContentSize().width-10 ,rewardPanel:getContentSize().height)
	rtx:setPixelNewline(true)
	rtx:formatText()
	rtx:setVerticalSpace(3)
	rtx:setAnchorPoint(cc.p(0.5,0.5))
	rtx:setName("rtx")
	rtx:setPosition(rewardPanel:getContentSize().width/2, rewardPanel:getContentSize().height/2)
	rewardPanel:addChild(rtx)
	
	self._acceptBtn = self:getUI("event26.bg.acceptBtn")
	self._passBtn = self:getUI("event26.bg.passBtn")
	self._sureBtn = self:getUI("event26.bg.sureBtn")
	self._sureBtn:setVisible(false)
	self:registerClickEvent(self._acceptBtn, function()
		self._serverMgr:sendMsg("GuildMapServer", "acYearAmb",{tagPoint = self._targetId}, true, {}, function(result)
			self._yearData = result
			self:initYearViewData()
		end)
	end)
	self:registerClickEvent(self._passBtn, function()
		self:close()
	end)
end

function GuildMapEventView:initYearViewData()
	
	
	local yearData = self._yearData
	
	self._sureBtn:setVisible(true)
	self._acceptBtn:setVisible(false)
	self._passBtn:setVisible(false)
	
	local rewardPanel = self:getUI("event26.bg.desc2")
	local panelSize = rewardPanel:getContentSize()
	local mc = mcMgr:createViewMC("shangdianshuaxin_shoprefreshanim", false, true,function( )
		
	end)
	local mcSize = mc:getContentSize()
	mc:setScaleX(1.45)
	mc:setScaleY(0.73)
	mc:setPosition(panelSize.width/2+6, panelSize.height/2-4)
	rewardPanel:addChild(mc,9999)
	local showReward = {--显示reward图标的类型
		[GuildConst.YEAR_TYPE.REWARD] = true,
		[GuildConst.YEAR_TYPE.PEERBUFF] = true,
	}
	local reward = yearData.reward
	local lastX = 0
	local rtx = rewardPanel:getChildByName("rtx")
	if rtx then
		rtx:removeFromParent()
	end
	if showReward[yearData.yearType] then
		for i,v in ipairs(reward) do
			local itemType = v.type or v[1]
			local itemId = v.typeId or v[2]
			local itemNum = v.num or v[3]
			if itemType ~= "tool" and itemType ~= "hero" and itemType ~= "team" then
				itemId = IconUtils.iconIdMap[itemType]
			end
			local itemConfig = tab:Tool(itemId)
			if itemConfig == nil then
				itemConfig = tab:Team(itemId)
			end
			
			local itemNode = IconUtils:createItemIconById({itemId = itemId, num = itemNum, itemData = itemConfig, effect = false })
			itemNode:setSwallowTouches(false)
			itemNode:setScale(0.85)
			itemNode:setScaleAnim(true)
			itemNode:setAnchorPoint(0, 0.5)
			local x = 10 + (i-1)*itemNode:getContentSize().width - (i-1)*8
			itemNode:setPosition(x, panelSize.height/2)
			itemNode:setVisible(true)
			rewardPanel:addChild(itemNode)
			lastX = 10+i*itemNode:getContentSize().width - i*8
		end
	else
		local tbStr = {
			[GuildConst.YEAR_TYPE.SKIP_MAP] = lang("REWARD_TIPS2"),
			[GuildConst.YEAR_TYPE.MISS_FOG] = lang("REWARD_TIPS3"),
			[GuildConst.YEAR_TYPE.GET_POWER] = lang("REWARD_TIPS4")
		}
		
		rtx = RichTextFactory:create(tbStr[yearData.yearType],panelSize.width-10, panelSize.height)
		rtx:setPixelNewline(true)
		rtx:formatText()
		rtx:setVerticalSpace(3)
		rtx:setAnchorPoint(cc.p(0.5,0.5))
		rtx:setName("rtx")
		rtx:setPosition(panelSize.width/2, panelSize.height/2)
		rewardPanel:addChild(rtx)
	end
	
	self:registerClickEvent(self._sureBtn, function()
		DialogUtils.showGiftGet({gifts = reward,notPop = true})
		if self._eventCallback then
			self._eventCallback(self._yearData)
		end
		self:close()
	end)
	
	if yearData.yearType==GuildConst.YEAR_TYPE.REWARD then
	elseif yearData.yearType==GuildConst.YEAR_TYPE.PEERBUFF then
		local buff = yearData["d"].guildBackup.shop
		local tabBuff = tab.peerShop
		for i,v in pairs(buff) do
			local id = tonumber(i)
			local param = {image = tabBuff[id].icon .. ".png", quality = 5, scale = 0.85, bigpeer = true, buffConfig = tabBuff[id]}
			local buffNode = IconUtils:createBuffIconById(param)
			buffNode:setAnchorPoint(0, 0.5)
			buffNode:setPosition(lastX, rewardPanel:getContentSize().height/2)
			rewardPanel:addChild(buffNode)
		end
	elseif yearData.yearType==GuildConst.YEAR_TYPE.SKIP_MAP then
	elseif yearData.yearType==GuildConst.YEAR_TYPE.GET_POWER then
		local buff = yearData.yearBuff
		self._guildMapModel:setYearBuffData(buff)
	elseif yearData.yearType==GuildConst.YEAR_TYPE.MISS_FOG then
	end
end

--[[
--! @function onInit22
--! @desc 怪兽直接领取奖励 初始化
--! @return 
--]]
function GuildMapEventView:onInit22()

    local cancelBtn = self:getUI("event22.bg.cancelBtn")
    self:registerClickEvent(cancelBtn, function ()
        if self._closePopCallback ~= nil then 
            self._closePopCallback(self.parentView)
        end
        self:close(true)
    end)


    local userData = self._modelMgr:getModel("UserModel"):getData()
    local reward = {}
    for i=1, 6 do
        local award = self._sysGuildMapThing["award" .. i]
        if award ~= nil  and userData.lvl >= award[1] and userData.lvl <= award[2] then 
            for k,v in pairs(award[3]) do
                reward[#reward + 1] = v 
            end
        end
    end

    local labTip = self:getUI("event22.bg.tipLab")
    labTip:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    local titleLab = self:getUI("event22.bg.titleBg.titleLab")
    titleLab:setString(lang(self._sysGuildMapThing.name))

    local subTitleLab = self:getUI("event22.bg.infoBg.titleLab")
    subTitleLab:setString(lang(self._sysGuildMapThing.name))
    
    UIUtils:adjustTitle(self:getUI("event22.bg.infoBg"))
    subTitleLab:setColor(UIUtils.colorTable.ccUIBasePromptColor)

    local infoBg = self:getUI("event22.bg.infoBg")

    local sysTeam = tab:Team(self._sysGuildMapThing.corart)
    local teamImg = cc.Sprite:create("asset/uiother/steam/" .. sysTeam.steam .. ".png")
    teamImg:setPosition(infoBg:getContentSize().width/2, 50)
    teamImg:setScale(sysTeam.guildmap / 100)
    teamImg:setAnchorPoint(0.5, 0)
    infoBg:addChild(teamImg)


    -- 奖励
    local rewardNode = self:getUI("event22.bg.rewardBg.rewardNode")
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local reward = {}
    for i=1, 6 do
        local award = self._sysGuildMapThing["award" .. i]
        if award ~= nil  and userData.lvl >= award[1] and userData.lvl <= award[2] then 
            for k,v in pairs(award[3]) do
                reward[#reward + 1] = v 
            end
        end
    end
    -- 奖励
    local GuildMapUtils = require "game.view.guild.map.GuildMapUtils"
    local backNode = GuildMapUtils:showItems(reward, 0.7)
    backNode:setPosition(rewardNode:getContentSize().width/2  , rewardNode:getContentSize().height/2)
    rewardNode:addChild(backNode)


    local enterBtn = self:getUI("event22.bg.enterBtn")
    self:registerClickEvent(enterBtn, function ()
        self:roleGetReward()
    end)
end

--[[
--! @function onInit21
--! @desc 怪兽直接领取奖励 初始化
--! @return 
--]]

function GuildMapEventView:onInit21()

    local closeBtn = self:getUI("event21.bg.closeBtn")
    closeBtn:setVisible(false)
    
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local reward = {}
    for i=1, 6 do
        local award = self._sysGuildMapThing["award" .. i]
        if award ~= nil  and userData.lvl >= award[1] and userData.lvl <= award[2] then 
            for k,v in pairs(award[3]) do
                reward[#reward + 1] = v 
            end
        end
    end
    
    local labTip = self:getUI("event21.bg.tipLab")
    labTip:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    local titleLab = self:getUI("event21.bg.titleBg.titleLab")
    titleLab:setString(lang(self._sysGuildMapThing.name))

    local subTitleLab = self:getUI("event21.bg.infoBg.titleLab")
    subTitleLab:setString(lang(self._sysGuildMapThing.name))

    UIUtils:adjustTitle(self:getUI("event21.bg.infoBg"))
    subTitleLab:setColor(UIUtils.colorTable.ccUIBasePromptColor)


    local infoBg = self:getUI("event21.bg.infoBg")

    local sysTeam = tab:Team(self._sysGuildMapThing.corart)
    local teamImg = cc.Sprite:create("asset/uiother/steam/" .. sysTeam.steam .. ".png")
    teamImg:setPosition(infoBg:getContentSize().width/2, 50)
    teamImg:setScale(sysTeam.guildmap / 100)
    teamImg:setAnchorPoint(0.5, 0)
    infoBg:addChild(teamImg)


    -- 奖励
    local rewardNode = self:getUI("event21.bg.rewardBg.rewardNode")
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local reward = {}
    for i=1, 6 do
        local award = self._sysGuildMapThing["award" .. i]
        if award ~= nil  and userData.lvl >= award[1] and userData.lvl <= award[2] then 
            for k,v in pairs(award[3]) do
                reward[#reward + 1] = v 
            end
        end
    end
    -- 奖励
    local GuildMapUtils = require "game.view.guild.map.GuildMapUtils"
    local backNode = GuildMapUtils:showItems(reward, 0.7)
    backNode:setPosition(rewardNode:getContentSize().width/2  , rewardNode:getContentSize().height/2)
    rewardNode:addChild(backNode)

    -- -- 奖励
    -- local GuildMapUtils = require "game.view.guild.map.GuildMapUtils"
    -- local backNode = GuildMapUtils:showItems(reward)
    -- backNode:setPosition(infoBg:getContentSize().width/2, infoBg:getContentSize().height/2)
    -- infoBg:addChild(backNode)

    local enterBtn = self:getUI("event21.bg.enterBtn")
    self:registerClickEvent(enterBtn, function ()
        self:roleGetReward()
    end)
end


--[[
--! @function onInit2
--! @desc 怪兽兑换奖励 初始化
--! @return 
--]]
function GuildMapEventView:onInit20()
    local enterBtn = self:getUI("event20.bg.enterBtn")
    self:registerClickEvent(enterBtn, function ()
        self:exchangeReward()
    end)


    local cancelBtn = self:getUI("event20.bg.cancelBtn")
    self:registerClickEvent(cancelBtn, function ()
        self:giveUpExchange()
    end)

    if self._sysGuildMapThing.use == nil then 
        return
    end

    local useItem = self._sysGuildMapThing.use[1]
    if useItem == nil then 
        return
    end 

    local labTip = self:getUI("event20.bg.tipLab")
    labTip:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    local titleLab = self:getUI("event20.bg.titleBg.titleLab")
    titleLab:setString(lang(self._sysGuildMapThing.name))

    local subTitleLab = self:getUI("event20.bg.infoBg.titleLab")
    subTitleLab:setString(lang(self._sysGuildMapThing.name))
    UIUtils:adjustTitle(self:getUI("event20.bg.infoBg"))
    subTitleLab:setColor(UIUtils.colorTable.ccUIBasePromptColor)


    local infoBg = self:getUI("event20.bg.infoBg")

    local sysTeam = tab:Team(self._sysGuildMapThing.corart)
    local teamImg = cc.Sprite:create("asset/uiother/steam/" .. sysTeam.steam .. ".png")
    teamImg:setPosition(infoBg:getContentSize().width/2, 50)
    teamImg:setScale(sysTeam.guildmap / 100)
    teamImg:setAnchorPoint(0.5, 0)
    infoBg:addChild(teamImg)


    -- 奖励
    local rewardNode = self:getUI("event20.bg.rewardBg.rewardNode")
    local GuildMapUtils = require "game.view.guild.map.GuildMapUtils"
    local backNode = GuildMapUtils:showItems(self._sysGuildMapThing["exchange"], 0.7)
    backNode:setPosition(rewardNode:getContentSize().width/2  , rewardNode:getContentSize().height/2)
    rewardNode:addChild(backNode)

    -- 所需消耗
    local useBg = self:getUI("event20.bg.useBg")
    local tips1 = {}
    if useItem[1] == "gem" then
        tips1[1] = cc.Sprite:createWithSpriteFrameName("globalImageUI_diamond.png")
    else
        tips1[1] = cc.Sprite:createWithSpriteFrameName("globalImageUI_gold1.png")
    end
    tips1[1]:setScale(0.62)
    tips1[2] = cc.Label:createWithTTF(" "..useItem[3],UIUtils.ttfName, 16)
    tips1[2]:setColor(UIUtils.colorTable.ccUIBaseTextColor1)

    local nodeTip1 = UIUtils:createHorizontalNode(tips1)
    nodeTip1:setAnchorPoint(cc.p(0.5, 0.5))
    nodeTip1:setPosition(useBg:getContentSize().width/2, useBg:getContentSize().height/2 - 4 )
    useBg:addChild(nodeTip1)
end

function GuildMapEventView:calcOfficerReward()
	
end

function GuildMapEventView:getOfficerReward()
	self._serverMgr:sendMsg("GuildMapServer", "getJReward", {tagPoint = self._targetId}, true, {}, function(result)
		self._guildMapModel:setCommanderData(result.jxRewardSt)
		if tonumber(result.jxRewardSt.type)~=3 then
			DialogUtils.showGiftGet( {gifts = result.reward, notPop = true})
		else
			if self._callback then
				self._callback()
			end
		end
		local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
		local maxInterval = tab:Setting("OFFICER_REWARD_TOTAL").value*60
		local interval = tab:Setting("OFFICER_REWARD_INTERVAL").value*60
		local maxCanGetTimes = maxInterval/interval
		local nowTimes = math.floor((nowTime-tonumber(self._commanderData.actime))/interval)
		nowTimes = nowTimes>maxCanGetTimes and maxCanGetTimes or nowTimes
		if nowTimes == maxCanGetTimes and self._getAllRewardCallback then
			self._getAllRewardCallback()
		end
		self:close()
	end)
end

function GuildMapEventView:onInit27()
	local typeBg = self:getUI("event27")
	local taskPanel = typeBg:getChildByFullName("bg.taskPanel")
	local rewardPanel = typeBg:getChildByFullName("bg.rewardPanel")
	if self._rewardState then
		local commanderData = self._commanderData
		
		local descBg = typeBg:getChildByFullName("bg.descBg")
		descBg:setVisible(false)
		
		local maxTimeInterval = tab:Setting("OFFICER_REWARD_TOTAL").value*60
		local intervalTimeStr = TimeUtils.getStringTimeForInt(maxTimeInterval)
		
		local timeLab = rewardPanel:getChildByName("timeLab")
		
		local scroll = rewardPanel:getChildByName("scroll")
		local getBtn = rewardPanel:getChildByName("getBtn")
		self:registerClickEvent(getBtn, function()
			self:getOfficerReward()
		end)
		
		local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
		local maxInterval = tab:Setting("OFFICER_REWARD_TOTAL").value*60
		local interval = tab:Setting("OFFICER_REWARD_INTERVAL").value*60
		local maxCanGetTimes = maxInterval/interval
		local getTimes = math.floor((commanderData.rtime-commanderData.actime)/interval)
		local nowTimes = math.floor((nowTime-commanderData.actime)/interval)
		nowTimes = nowTimes>maxCanGetTimes and maxCanGetTimes or nowTimes
		local canGet = nowTimes~=getTimes
		local rewards = tonumber(commanderData.type)~=3 and commanderData.rewards or commanderData.mapEquips
		
		
		if canGet then
			getBtn:setSaturation(0)
			getBtn:setEnabled(true)
		else
			getBtn:setSaturation(-100)
			getBtn:setEnabled(false)
		end
		
		
		timeLab:stopAllActions()
		local repeatAction =cc.RepeatForever:create(
			cc.Sequence:create(cc.CallFunc:create(function()
				local nowTimeStamp = self._modelMgr:getModel("UserModel"):getCurServerTime()
				
				local nowInterval = nowTimeStamp - tonumber(commanderData.actime)
				
				if nowTimes<maxCanGetTimes then--当到了下一个奖励激活的时候，更新界面。
					local nextTimeStamp = tonumber(commanderData.actime) + (nowTimes+1)*interval
					if nowTimeStamp>nextTimeStamp then
						nowTimes = nowTimes + 1
						local node = scroll:getChildByName("node"..nowTimes)
						node:setSaturation(0)
						node:setEnabled(true)
						if scroll:getChildByName("collectionLab"..nowTimes) then
							scroll:getChildByName("collectionLab"..nowTimes):removeFromParent()
						end
						getBtn:setSaturation(0)
						getBtn:setEnabled(true)
					end
				end
				
				if nowInterval>=maxTimeInterval then
					nowInterval = maxTimeInterval
				end
				local nowIntervalStr = TimeUtils.getStringTimeForInt(nowInterval)
				
				timeLab:setString(nowIntervalStr.."/"..intervalTimeStr)
				if nowInterval>=maxTimeInterval then
					timeLab:stopAllActions()
				end
			end),
			cc.DelayTime:create(1)))
		timeLab:runAction(repeatAction)
		
		local totalWidth = 0
		local nodes = {}
		for i,v in ipairs(rewards) do
			if table.nums(v)~=1 then
				error(string.format("Wrong number of officer reward, expect 1, get %d!!!@lizhiyuan", table.nums(v)))
			end
			local rewardData = v[1]
			local node
			if tonumber(commanderData.type)~=3 then
				local itemId = rewardData[2]
				if rewardData[1] ~= "tool" then
					itemId = IconUtils.iconIdMap[rewardData[1]]
				end
				node = IconUtils:createItemIconById({itemId = itemId, num = rewardData[3], eventStyle = 4})
			else
				node = IconUtils:createGuildMapEquipment({equipId = rewardData[1], num = rewardData[2]})
			end
			node:setAnchorPoint(0, 0.5)
			table.insert(nodes, node)
			node:setScale(0.65)
			node:setName("node"..i)
			totalWidth = totalWidth + node:getContentSize().width*0.65 + 3
			scroll:addChild(node)
		end
		if scroll:getInnerContainerSize().width<totalWidth then
			scroll:setInnerContainerSize(cc.size(totalWidth, scroll:getContentSize().height))
		end
		local posx = 0
		
		local innerPosX = 0
		for i,v in ipairs(nodes) do
			v:setPosition(cc.p(posx, scroll:getContentSize().height/2))
			posx = posx + v:getContentSize().width*0.65 + 3
			v:setSaturation(0)
			v:setEnabled(true)
			if i>nowTimes then
				v:setSaturation(-100)
				v:setEnabled(false)
				local collectionLab = ccui.Text:create()
				collectionLab:setString("收集中")
				collectionLab:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
				collectionLab:setFontName(UIUtils.ttfName)
				collectionLab:setFontSize(22)
				collectionLab:setName("collectionLab"..i)
				collectionLab:setScale(0.65)
				collectionLab:enableOutline(UIUtils.colorTable.titleOutLineColor, 1)
				collectionLab:setAnchorPoint(0.5, 0)
				collectionLab:setPosition(v:getPositionX()+v:getContentSize().width*0.65/2, v:getPositionY()-v:getContentSize().height*0.65/2+3)
				scroll:addChild(collectionLab)
			elseif i<=getTimes then
				if i==getTimes then
					innerPosX = v:getPositionX()
				end
				v:setEnabled(false)
				local hasGetImg = ccui.ImageView:create()
				hasGetImg:loadTexture("globalImageUI_activity_getItBlue.png", 1)
				hasGetImg:setPosition(cc.p(v:getContentSize().width/2, v:getContentSize().height/2))
				v:addChild(hasGetImg, 10)
			end
		end
		if getTimes>1 then
			ScheduleMgr:nextFrameCall(self, function()
				scroll:scrollToPercentHorizontal(innerPosX/scroll:getInnerContainerSize().width*100, 0.5, true)
			end)
		end
		taskPanel:setVisible(false)
		rewardPanel:setVisible(true)
		
	else
		--[[local desRich = RichTextFactory:create(lang("GUILD_MILITARY_TIP_3"), 268)
		desRich:setPixelNewline(true)
		desRich:formatText()
		desRich:setVerticalSpace(3)
		desRich:setAnchorPoint(cc.p(0, 0.5))
		desRich:setPosition(cc.p(-126, taskPanel:getContentSize().height/2+desRich:getInnerSize().height + 10))
		desRich:setName("desRich")
		taskPanel:addChild(desRich)
		
		local desRich2 = RichTextFactory:create(lang("GUILD_MILITARY_TIP_4"), 268)
		desRich2:setPixelNewline(true)
		desRich2:formatText()
		desRich2:setVerticalSpace(3)
		desRich2:setAnchorPoint(cc.p(0, 0.5))
		desRich2:setPosition(cc.p(-126, desRich:getPositionY()-desRich:getInnerSize().height - desRich2:getInnerSize().height/2))
		desRich2:setName("desRich2")
		taskPanel:addChild(desRich2)--]]
		
		local passBtn = typeBg:getChildByFullName("bg.taskPanel.passBtn")
		self:registerClickEvent(passBtn, function()
			self:close()
		end)
		
		local actBtn = typeBg:getChildByFullName("bg.taskPanel.acceptBtn")
		self:registerClickEvent(actBtn, function()
			self._serverMgr:sendMsg("GuildMapServer", "acJNpc1", {tagPoint = self._targetId}, true, {}, function(result)
				if result.jxGid and result.jxGid~=0 then
					self._guildMapModel:setOfficerTargetGuildId(result.jxGid)
				end
				if result.yearBuff then
					self._guildMapModel:setYearBuffData(result.yearBuff)
				end
				if self._callback then
					self._callback()
				end
				self:close()
			end)
		end)
		taskPanel:setVisible(true)
		rewardPanel:setVisible(false)
	end
end

function GuildMapEventView:acTent()
    self._serverMgr:sendMsg("GuildMapServer", "acTent", {tagPoint = self._targetId}, true, {}, function(result)
        if result == nil then 
            self._fogTipLab:setVisible(true)
            self._fogTipLab:setString("激活失败,请重试")
            self._fogTipLab:setColor(UIUtils.colorTable.ccColorQuality6)
            self._fogTipLab:disableEffect()
            return
        end
        self._viewMgr:lock(-1)
        self:showActiveAnim(function()
            self._openGold = true
            self._fogTipLab:setVisible(true)
            self._fogTipLab:setString("已激活")
            self._fogTipLab:setColor(UIUtils.colorTable.ccUIBaseColor2)
            self._fogTipLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)      

        end, function()
            self._viewMgr:unlock()
            if self._callback ~= nil then 
                self._callback(result)
            end
            self:close()
        end)
    end)
end
function GuildMapEventView:acGoldMine()
    print("missFog=========================")
    self._serverMgr:sendMsg("GuildMapServer", "acGoldMine", {tagPoint = self._targetId}, true, {}, function(result)
        -- dump(result, "1321",10)
        if result == nil then 
            self._fogTipLab:setString("激活失败,请重试")
            self._fogTipLab:setColor(UIUtils.colorTable.ccColorQuality6)
            self._fogTipLab:disableEffect()
            return
        end
        self._viewMgr:lock(-1)
        self:showActiveAnim(function()
            self._viewMgr:unlock()
            self:activeEvent7()
            self._openGold = true
            if result["reward"] ~= nil then
                DialogUtils.showGiftGet({
                  gifts = result["reward"],
                })
            end               
            if self._callback ~= nil then 
                self._callback()
            end
            -- self:close()
            end)
    end)
end

function GuildMapEventView:roleGetReward()
    self._serverMgr:sendMsg("GuildMapServer", "roleGetReward", {tagPoint = self._targetId}, true, {}, function(result)
        if result == nil then 
            return
        end
        if self._closePopCallback ~= nil then 
            self._closePopCallback(self.parentView)
        end        
        if self._callback ~= nil then 
            self._callback(result)
        end
        if self.close ~= nil then
            self:close()
        end
    end)
end


function GuildMapEventView:giveUpExchange()
    self._serverMgr:sendMsg("GuildMapServer", "giveUpExchange", {tagPoint = self._targetId}, true, {}, function(result)
        if result == nil then 
            return
        end
        if self._closePopCallback ~= nil then 
            self._closePopCallback(self.parentView)
        end              
        if self._callback ~= nil then 
            self._callback(result)
        end
        if self.close ~= nil then
            self:close()
        end
    end)
end


function GuildMapEventView:exchangeReward()
    -- local sysGuildMapThing = tab.guildMapThing[tonumber(self._eleId)]
    if self._sysGuildMapThing.use == nil or self._sysGuildMapThing.exchange == nil then 
        return
    end
    local userModel = self._modelMgr:getModel("UserModel")
    for k,v in pairs(self._sysGuildMapThing.use) do
        if v[1] == "gem" then 
            if userModel:getData().gem < tonumber(v[3]) then 
              self._viewMgr:showTip("钻石不足")
              return
            end
        elseif v[1] == "gold" then
            if userModel:getData().gold < tonumber(v[3]) then 
                DialogUtils.showLackRes({goalType = "gold"})
                return
            end
        elseif v[1] == "tool" then
            local item,icount = itemModel:getItemsById(v[2])
            if icount < v[3] then
                self._viewMgr:showTip("所需道具：" .. lang(tab:Tool(v[2])).name .. "不足")
                return
            end
        end
    end

    self._serverMgr:sendMsg("GuildMapServer", "exchangeReward", {tagPoint = self._targetId}, true, {}, function(result)
        if result == nil then 
            return
        end

        if self._callback ~= nil then 
            self._callback(result)
        end
        if self.close ~= nil then
            self:close()
        end
    end)
end

function GuildMapEventView:missFog()
    print("missFog=========================")
    self._serverMgr:sendMsg("GuildMapServer", "missFog", {tagPoint = self._targetId}, true, {}, function(result)
        if result == nil then 
            self._fogTipLab:setString("激活失败,请重试")
            self._fogTipLab:setColor(UIUtils.colorTable.ccColorQuality6)
            self._fogTipLab:disableEffect()
            return
        end
        self._viewMgr:lock(-1)
        self:showActiveAnim(function()
            self._viewMgr:unlock()
            self._openFog = true
            self._fogTipLab:setString("已激活")
            self._fogTipLab:setColor(UIUtils.colorTable.ccUIBaseColor2)
            self._fogTipLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)      

            -- if self._callback ~= nil then 
            --     self._callback()
            -- end
            -- self:close()
            if result["reward"] ~= nil then
                DialogUtils.showGiftGet({
                  gifts = result["reward"],
                })
            end             
            end)
    end)
end

function GuildMapEventView:getTimeRewardGet()
    self._serverMgr:sendMsg("GuildMapServer", "getTimeRewardGet", {tagPoint = self._targetId}, true, {}, function(result)
        if result == nil then 
            return
        end
        if self._callback ~= nil then 
            self._callback(3, result)
        end
        if self.close ~= nil then
            self:close()
        end
    end)
end

function GuildMapEventView:getTimeRewardRead(callback)
    self._serverMgr:sendMsg("GuildMapServer", "getTimeRewardRead", {tagPoint = self._targetId}, true, {}, function(result)
        if result == nil then 
            return
        end
        -- if self._callback ~= nil then 
        --     self._callback(result)
        -- end
        -- self:close()
        callback()
    end)
end

function GuildMapEventView:cancelTimeRewardRead(callback)
    self._serverMgr:sendMsg("GuildMapServer", "cancelTimeRewardRead", {tagPoint = self._targetId}, true, {}, function(result)
        if result == nil then 
            return
        end
        -- if self._callback ~= nil then 
        --     self._callback(result)
        -- end
        -- self:close()
        callback()
    end)
end


function GuildMapEventView:getTimeBuffGet()
    self._serverMgr:sendMsg("GuildMapServer", "getTimeBuffGet", {tagPoint = self._targetId}, true, {}, function(result)
        if result == nil then 
            return
        end
        if self._callback ~= nil then 
            self._callback(3, result)
        end
        if self.close ~= nil then
            self:close()
        end
    end)
end

function GuildMapEventView:getTimeBuffRead(callback)
    self._serverMgr:sendMsg("GuildMapServer", "getTimeBuffRead", {tagPoint = self._targetId}, true, {}, function(result)
        if result == nil then 
            return
        end
        -- if self._callback ~= nil then 
        --     self._callback(result)
        -- end
        -- self:close()
        callback()
    end)
end

function GuildMapEventView:cancelTimeBuffRead(callback)
    self._serverMgr:sendMsg("GuildMapServer", "cancelTimeBuffRead", {tagPoint = self._targetId}, true, {}, function(result)
        if result == nil then 
            return
        end
        -- if self._callback ~= nil then 
        --     self._callback(result)
        -- end
        -- self:close()
        callback()
    end)
end


function GuildMapEventView:robGoldMineGet()
    self._serverMgr:sendMsg("GuildMapServer", "robGoldMineGet", {tagPoint = self._targetId}, true, {}, function(result)
        if result == nil then 
            return
        end
        if self._callback ~= nil then 
            self._callback(3, result)
        end
        if self.close ~= nil then
            self:close()
        end
    end)
end

function GuildMapEventView:robGoldMineRead(callback)
    self._serverMgr:sendMsg("GuildMapServer", "robGoldMineRead", {tagPoint = self._targetId}, true, {}, function(result)
        if result == nil then 
            return
        end
        -- if self._callback ~= nil then 
        --     self._callback(result)
        -- end
        -- self:close()
        callback()
    end)
end

function GuildMapEventView:robGoldMineCancel(callback)
    self._serverMgr:sendMsg("GuildMapServer", "robGoldMineCancel", {tagPoint = self._targetId}, true, {}, function(result)
        if result == nil then 
            return
        end
        dump(result, "test", 10)
        -- if self._callback ~= nil then 
        --     self._callback(result)
        -- end
        -- self:close()
        callback()
    end)
end

--激活动画  by wangyan
function GuildMapEventView:showActiveAnim(inCallback, inFinishCallback)
    local activeAim = mcMgr:createViewMC("gongxijihuo_lianmengjihuo", false, true, function()

        if inFinishCallback ~= nil then 
            inFinishCallback()
        end
    end)
    activeAim:addCallbackAtFrame(13, function()
        if inCallback ~= nil then
            inCallback()
        end
    end)
    activeAim:setPosition(self:getContentSize().width*0.5, self:getContentSize().height*0.5 + 50)
    self:addChild(activeAim, 1000000)
end

function GuildMapEventView:getPointInfo(inCallback)
    self._serverMgr:sendMsg("GuildMapServer", "getPointInfo", {tagPoint = self._targetId}, true, {}, function(result)
        if result == nil then 
            return
        end
        if self.showActiveAnim == nil then return end
        -- if self._callback ~= nil then 
        --     self._callback(result)
        -- end
        -- self:close()
        if inCallback  ~= nil then 
            inCallback()
        end
    end)
end


function GuildMapEventView:getTargetUserBattleInfo(inUserId, inIsFriend)
    local formationModel = self._modelMgr:getModel("FormationModel")
    local param = {}
    param.tagId = inUserId
    param.fid = formationModel.kFormationTypeGuildDef
    self._serverMgr:sendMsg("UserServer", "getTargetUserBattleInfo", param, true, {}, function(result)
        local userList = self._guildMapModel:getData().userList
        local holdUserInfo = userList[inUserId]
        local guildList = self._guildMapModel:getData().guildList
        result.isNotShowBtn = true
        result.showType = 1
        if holdUserInfo ~= nil then
            if holdUserInfo.guildId ~= nil and guildList[tostring(holdUserInfo.guildId)] ~= nil then
                result.guildMapName = guildList[tostring(holdUserInfo.guildId)].name
            else
                result.guildMapName = ""
            end
            result.mapHurt = holdUserInfo.mapHurt
        else
            result.mapHurt = 0
            result.guildMapName = ""
        end
        self._userInfo = self._viewMgr:showDialog("arena.DialogArenaUserInfo", result, true)
    end)
end
 
return GuildMapEventView


