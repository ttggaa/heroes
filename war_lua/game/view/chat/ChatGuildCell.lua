--[[
    Filename:    ChatGuildCell.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2016-05-20 12:26
    Description: 联盟单个cell
--]]

local ChatGuildCell = class("ChatGuildCell", cc.TableViewCell)

function ChatGuildCell:ctor()
	-- ChatGuildCell.super.ctor(self)
    self._viewMgr = ViewManager:getInstance()
    self._serverMgr = ServerManager:getInstance()
    self._modelMgr = ModelManager:getInstance()
    self._chatModel = self._modelMgr:getModel("ChatModel")
    self._chooseObj = {}
end

function ChatGuildCell:onInit()
end

function ChatGuildCell:reflashUI(data, richText, width, height, isMyself, oldUI)
    if richText:getParent() ~= nil then 
        local tempText = richText
        richText = cc.Node:create()
        richText:setContentSize(cc.size(tempText:getContentSize().width, tempText:getContentSize().height))
    end
    if richText.getRealSize == nil then 
        richText.getRealSize = richText.getContentSize
    end    
    self._guildView = self._guildView or {}
    self._sysView = self._sysView or {}
    if data.typeCell and data.typeCell == ChatConst.CELL_TYPE.GUILD2 then   --联盟日志/红包
        for i,v in ipairs(self._guildView) do
            v:setVisible(false)
        end
        for i,v in ipairs(self._sysView) do
            v:setVisible(true)
        end
        self:reflashSysUI(data, richText, width, height)
    else
        for i,v in ipairs(self._sysView) do
            v:setVisible(false)
        end

        for i,v in ipairs(self._guildView) do
            v:setVisible(true)
        end
        self:reflashGuildUI(data, richText, width, height, isMyself, oldUI)
    end   
end

function ChatGuildCell:reflashSysUI(data, richText, width, height)
    if self._channelSpSys == nil then
        self._channelSpSys = ccui.ImageView:create("chatImg_channel_" .. data.type .. ".png", 1)
        self._channelSpSys:setAnchorPoint(0, 1)
        self:addChild(self._channelSpSys)
        table.insert(self._sysView, self._channelSpSys)
    else
        self._channelSpSys:loadTexture("chatImg_channel_" .. data.type .. ".png", 1)
    end
    self._channelSpSys:setPosition(2, height - 5)

    if self._textBgSys == nil then 
        self._textBgSys = cc.Node:create()
        self._textBgSys:setAnchorPoint(0, 1)
        self:addChild(self._textBgSys)
        table.insert(self._sysView, self._textBgSys)
    end

    local x = richText:getRealSize().width / 2
    if richText:getRealSize().width < richText:getContentSize().width then 
        x = richText:getContentSize().width / 2
    end
    x = x + 20
    
    local textBgHeight = 35 
    if richText:getRealSize().height + 10 > textBgHeight then 
        textBgHeight = richText:getRealSize().height + 10
    end

    self._textBgSys:setContentSize(cc.size(width + 40, textBgHeight))
    self._textBgSys:setPosition(60, height)
    

    richText:setPosition(x, textBgHeight/2)

    self._textBgSys:addChild(richText)

    self.richText = richText
end

function ChatGuildCell:reflashGuildUI(data, richText, width, height, isMyself, oldUI)
    self._data = data
    self._infoData = data.message
    local userData = data.message.udata
    --headIcon
    if not self._avatar then
        self._avatar = IconUtils:createHeadIconById({avatar = userData.avatar, level = userData.lvl or "0", tp = 4, eventStyle=1, avatarFrame=userData["avatarFrame"]})
        self._avatar:setScale(0.64)
        self._avatar:setAnchorPoint(0, 1)
        self:addChild(self._avatar)
        table.insert(self._guildView, self._avatar)
    else
        IconUtils:updateHeadIconByView(self._avatar,{avatar = userData.avatar, level = userData.lvl or "0", tp = 4, eventStyle=1, avatarFrame=userData["avatarFrame"]})   
    end
    if isMyself == true then 
        self._avatar:setPosition(width - self._avatar:getContentSize().width * self._avatar:getScaleX() - 125, height - 5)
        self._avatar:setTouchEnabled(false)
    else
        self._avatar:setTouchEnabled(true)
        self._avatar:setPosition(3, height - 5)
        registerClickEvent(self._avatar, function()  

            -- 获取玩家信息详情  hgf
            local fId = (userData.lvl and  userData.lvl >= 15) and 101 or 1
            ServerManager:getInstance():sendMsg("UserServer", "getTargetUserBattleInfo", {tagId = userData["rid"],fid=fId}, true, {}, function(result)                 
                -- 打开聊天详情界面
                self._viewMgr:showDialog("chat.DialogFriendHandle", {uiData = data, detailData = result, oldUI = oldUI}, true) 
            end)
        end)
    end

    --channel
    if self._channelSp == nil then
        self._channelSp = cc.Sprite:create()
        self._channelSp:setAnchorPoint(0, 1)
        self:addChild(self._channelSp)
        table.insert(self._guildView, self._channelSp)
    end
    userData.roleGuild = userData.roleGuild or 3
    self._channelSp:setSpriteFrame("chatImg_channel_guild" .. userData.roleGuild .. ".png")

    if isMyself == true then 
        self._channelSp:setPosition(width - self._channelSp:getContentSize().width - 199, height - 8)
    else
        self._channelSp:setPosition(77, height - 8)
    end

    --name
    if self._nameLab == nil then
        self._nameLab = cc.Label:createWithTTF("", UIUtils.ttfName, 20)
        self._nameLab:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
        -- self._nameLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        self._nameLab:setAnchorPoint(0, 1)
        self:addChild(self._nameLab)
        table.insert(self._guildView, self._nameLab)
    end
    self._nameLab:setString(userData.name)

    if isMyself == true then 
        self._nameLab:setPosition(width - self._nameLab:getContentSize().width - 255, height - 9)
    else
        self._nameLab:setPosition(132, height - 9)
    end

    --vip
    if userData.vipLvl and userData.vipLvl ~= 0 then
        if self._vipImg == nil then
            self._vipImg = cc.Sprite:createWithSpriteFrameName("chatPri_vipLv"..math.max(1, userData.vipLvl)..".png")  
            self._vipImg:setAnchorPoint(0, 1)
            self._vipImg:setScale(0.7)
            self:addChild(self._vipImg)
            table.insert(self._guildView, self._vipImg)
        else
            self._vipImg:setVisible(true)
            self._vipImg:setSpriteFrame("chatPri_vipLv"..math.max(1, userData.vipLvl)..".png")
        end
        if isMyself == true then
            self._vipImg:setPosition(width - self._nameLab:getContentSize().width - 289, height - 10)
        else
            self._vipImg:setPosition(138 + self._nameLab:getContentSize().width, height - 7)
        end
    else
        if self._vipImg then
            self._vipImg:setVisible(false)
        end
    end

    --textBg
    if self._textBg == nil then
        self._textBg = cc.Scale9Sprite:createWithSpriteFrameName("chatImg_contextBg.png")
        self:addChild(self._textBg)
        table.insert(self._guildView, self._textBg)
    end

    if self._myTextBg == nil then
        self._myTextBg = cc.Scale9Sprite:createWithSpriteFrameName("chatImg_contextBg1.png")
        self:addChild(self._myTextBg)
        table.insert(self._guildView, self._myTextBg)
    end

    --------------------------------按类型创建---------------------------------------
    --显示隐藏
    for i,v in ipairs(self._chooseObj) do
        v:setVisible(false)
    end

    local cellType = data.message.typeCell
    if cellType and cellType == ChatConst.CELL_TYPE.VOICE then
        self:createVoiceItem(data, richText, width, height, isMyself)  --语音
    else
        self:createOtherItem(data, richText, width, height, isMyself)
    end 

    --btn(备注：放在“按类型创建”之后 因为需要textBg文本确定高度)
    self:createBtnEvent(data, height, isMyself)
end

--创建语音
function ChatGuildCell:createVoiceItem(data, richText, width, height, isMyself, oldUI)
    local voiceNode, parentNode
    local posVX, posVY
    if isMyself == true then
        self._textBg:setVisible(false)
        self._myTextBg:setVisible(true)
        self._myTextBg:setAnchorPoint(0, 1)
        parentNode = self._myTextBg
        voiceNode = self._voiceImgR
        posVX, posVY = 12, 27
    else
        self._textBg:setVisible(true)
        self._myTextBg:setVisible(false)
        self._textBg:setAnchorPoint(0, 1)
        parentNode = self._textBg
        voiceNode = self._voiceImgL
        posVX, posVY = 47, 27
    end

    --语音红点
    local function refreshState(inObj)
        local redpoint = inObj._redpoint
        local readList = self._chatModel:getVoiceReadState()
        if readList[self._infoData["textId"]] and readList[self._infoData["textId"]] == true and isMyself == false then
            redpoint:setVisible(true)
        else
            redpoint:setVisible(false)
        end
    end

    if voiceNode == nil then
        --voiceImg
        voiceNode = ccui.ImageView:create("chat_voice_msg.png", 1)
        voiceNode:setScale9Enabled(true)
        voiceNode:setCapInsets(cc.rect(36, 16, 1, 1))
        voiceNode:setAnchorPoint(cc.p(0, 0.5))
        voiceNode:setPosition(posVX, posVY)
        voiceNode:ignoreContentAdaptWithSize(false)
        voiceNode:setTouchEnabled(true)
        voiceNode:setSwallowTouches(false)
        parentNode:addChild(voiceNode)
        table.insert(self._chooseObj, voiceNode)

        --变长
        local tDis = 250 * (6 * (data.message.textTime or 0) + 40) / (4 * (data.message.textTime or 0) + 160)
        voiceNode:setContentSize(cc.size(math.max(tDis, 72), voiceNode:getContentSize().height))

        --时长
        local voiceT = ccui.Text:create()
        voiceT:setFontName(UIUtils.ttfName)
        voiceT:setString((data.message.textTime or 0) .. "秒")
        voiceT:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        voiceT:setFontSize(18)
        voiceT:setPosition(voiceNode:getContentSize().width * 0.5, voiceNode:getContentSize().height * 0.5)
        voiceNode._time = voiceT
        voiceNode:addChild(voiceT)

        --红点
        local voiceRedPt = ccui.ImageView:create("globalImageUI_bag_keyihecheng.png", 1)
        if isMyself == true then
            voiceRedPt:setPosition(3, voiceNode:getContentSize().height)
        else
            voiceRedPt:setPosition(voiceNode:getContentSize().width - 3, voiceNode:getContentSize().height)
        end
        voiceRedPt:setScale(0.6)
        voiceNode._redpoint = voiceRedPt
        voiceNode:addChild(voiceRedPt)

        refreshState(voiceNode)

        --特效
        local voiceAinm
        if isMyself == true then
            voiceAinm = mcMgr:createViewMC("yuyinR_mainviewcoin", true)
            voiceAinm:setPosition(voiceNode:getContentSize().width + 21, voiceNode:getContentSize().height * 0.5 - 1)
        else
            voiceAinm = mcMgr:createViewMC("yuyin_mainviewcoin", true)
            voiceAinm:setPosition(-19, voiceNode:getContentSize().height * 0.5 - 1)
        end
        voiceAinm:gotoAndStop(9)
        voiceNode._anim = voiceAinm
        voiceNode:addChild(voiceAinm)
        
        --textBg
        parentNode:setContentSize(voiceNode:getContentSize().width + 60, 50) --300
        parentNode:setCapInsets(cc.rect(20, 25, 1, 1))
        if isMyself == true then
            parentNode:setPosition(width - parentNode:getContentSize().width - 193, height - 40)
        else
            parentNode:setPosition(70, height - 40)
        end

        registerTouchEvent(voiceNode, 
            function(_, _x, _y)
                self._vPosX1, self.vPosY1 = _x, _y
                self._vDisX, self._vDisY = 0, 0  --cell滑动距离
            end,
            --move
            function(_, _x, _y)
                local disX, disY = math.abs(self._vPosX1 - _x), math.abs(self.vPosY1 - _y)
                if disX > self._vDisX then
                    self._vDisX = disX
                end
                if disY > self._vDisY then
                    self._vDisY = disY
                end
            end,
            --pop
            function(_, _x, _y)
                if self._vDisX >= 5 or self._vDisY >= 5 then
                    return
                end
                local fileID = self._infoData["textId"] or 0
                self._chatModel:setVoiceReadState(fileID, false)
                voiceNode._redpoint:setVisible(false)
                voiceNode._anim:gotoAndPlay(1)
                
                VoiceUtils.play(fileID, function()
                    if voiceNode and voiceNode._anim then
                        voiceNode._anim:gotoAndStop(9)
                    end
                    end)
            end)
    else
        --变长
        local tDis = 250 * (6 * (self._infoData["textTime"] or 0) + 40) / (4 * (self._infoData["textTime"] or 0) + 160)
        voiceNode:setContentSize(cc.size(math.max(tDis, 72), voiceNode:getContentSize().height))
        voiceNode:setVisible(true)

        --textBg
        parentNode:setContentSize(voiceNode:getContentSize().width + 60, 50)
        if isMyself == true then
            parentNode:setPosition(width - parentNode:getContentSize().width - 193, height - 40)
        else
            parentNode:setPosition(70, height - 40)
        end
        
        --时长
        voiceNode._time:setString((self._infoData["textTime"] or 0) .. "秒")
        voiceNode._time:setPosition(voiceNode:getContentSize().width * 0.5, voiceNode:getContentSize().height * 0.5)

        --红点
        if isMyself == true then
            voiceNode._redpoint:setPosition(3, voiceNode:getContentSize().height)
        else
            voiceNode._redpoint:setPosition(voiceNode:getContentSize().width - 3, voiceNode:getContentSize().height)
        end
        refreshState(voiceNode)
        
        --特效
        if isMyself == true then
            voiceNode._anim:setPosition(voiceNode:getContentSize().width  + 20, voiceNode:getContentSize().height * 0.5 - 1)
        else
            voiceNode._anim:setPosition(-20, voiceNode:getContentSize().height * 0.5 - 1)
        end
    end

    if isMyself == true then
        self._voiceImgR = voiceNode
    else
        self._voiceImgL = voiceNode
    end
end

--创建普通信息
function ChatGuildCell:createOtherItem(data, richText, width, height, isMyself, oldUI)
    local parentNode
    if isMyself == true then
        self._textBg:setVisible(false)
        self._myTextBg:setVisible(true)
        parentNode = self._myTextBg
    else
        self._textBg:setVisible(true)
        self._myTextBg:setVisible(false)
        parentNode = self._textBg
    end

    --create
    parentNode.showId = data.id
    parentNode:setAnchorPoint(0, 1)

    local x = richText:getRealSize().width / 2
    if richText:getRealSize().width < richText:getContentSize().width then 
        x = richText:getContentSize().width / 2
    end
    if isMyself == true then
        x = x + 10
    else
        x = x + 20
    end
    parentNode:addChild(richText)

    local textBgHeight = 45 
    if richText:getRealSize().height + 10 > textBgHeight then 
        textBgHeight = richText:getRealSize().height + 20
    end
    richText:setPosition(x, textBgHeight/2 + 2)

    parentNode:setContentSize(math.max(richText:getRealSize().width +30, 44), textBgHeight)
    parentNode:setCapInsets(cc.rect(20, 25, 1, 1))
    if isMyself == true then
        parentNode:setPosition(width - self._myTextBg:getContentSize().width - 193, height - 40)
    else
        parentNode:setPosition(70, height - 40)
    end
    
    if richText.restoreGif then 
        richText:restoreGif()
    end
    self.richText = richText
end

--添加按钮点击事件
function ChatGuildCell:createBtnEvent(data, height, isMyself)
    local img, btnScale, btnColor, outColor
    local title, titlePosX, titlePosY, titleSize
    local isVisible, callback
    local _typeCell = ""
    if data.message and data.message.typeCell then
        _typeCell = data.message.typeCell
    end
    if _typeCell == ChatConst.CELL_TYPE.GUILD3 then     --联盟秘境
        img = "chatGuild_enterBtn.png"
        title = ""
        titlePosX,titlePosY, btnScale, titleSize = 30, -13, 1, 16
        isVisible = not isMyself
        callback = function()
            self:callbackHandle1(data)
        end

    else
        img = "globalImageUI6_meiyoutu.png"
        title = ""
        titlePosX,titlePosY, btnScale, titleSize = 0, 0, 1, 22
        isVisible = false
        callback = function() end
    end

    --btn
    if self._clickBtn == nil then
        self._clickBtn = ccui.Button:create()
        self:addChild(self._clickBtn)
        table.insert(self._guildView, self._clickBtn)
    end
    self._clickBtn:loadTextures(img, img, img, 1)
    self._clickBtn:setScale(btnScale)

    --title
    if self._btnTitle == nil then
        self._btnTitle = ccui.Text:create()
        self._btnTitle:setFontName(UIUtils.ttfName)
        self:addChild(self._btnTitle)
        table.insert(self._guildView, self._btnTitle)
    end
    self._btnTitle:setFontSize(titleSize)
    self._btnTitle:setString(title)
    self._btnTitle:setColor(btnColor or cc.c4b(255,255,255,255))
    self._btnTitle:enableOutline(outColor or cc.c4b(124, 64, 0, 255), 1)

    -- pos
    if isMyself == true then
        -- self._clickBtn:setAnchorPoint(0, 0.5)
        local bPosX, bPosY = 50, self._myTextBg:getPositionY() - self._myTextBg:getContentSize().height*0.5
        self._clickBtn:setPosition(bPosX, bPosY)
        self._clickBtn:setScaleX(-btnScale)
        self._btnTitle:setPosition(bPosX - titlePosX, bPosY + titlePosY)
    else
        -- self._clickBtn:setAnchorPoint(0, 0.5)
        local bPosX, bPosY = 345, self._textBg:getPositionY() - self._textBg:getContentSize().height*0.5
        self._clickBtn:setPosition(bPosX, bPosY)
        self._clickBtn:setScaleX(btnScale)
        self._btnTitle:setPosition(bPosX + titlePosX, bPosY + titlePosY)
    end 

    -- visible
    self._clickBtn:setVisible(isVisible)
    self._btnTitle:setVisible(isVisible)

    --callback
    registerClickEvent(self._clickBtn, callback)  
end

--联盟秘境 按钮点击事件
function ChatGuildCell:callbackHandle1(data)
    local gridKey = data.message.famData.gridKey
	
	local isLoad = self._viewMgr:isViewLoad("guild.map.GuildMapView")
	self._serverMgr:sendMsg("GuildMapServer", "getSecretLandStatus", {tagPoint = gridKey}, true, {}, function(result, errorCode)
		if errorCode and errorCode~=0 then
			if errorCode == 3047 then
				self._viewMgr:showTip(lang("GUILD_FAM_TIPS_23"))
			end
			return
		end
		if result.status==1 then
			self._modelMgr:getModel("GuildMapFamModel"):setInviteKey(1)
			if isLoad then
				self._modelMgr:getModel("GuildMapModel"):noticeScreenToFam(gridKey)
			else
				self._viewMgr:showView("guild.map.GuildMapView", {toGridKey = gridKey})
			end
		elseif result.status==2 then
			self._viewMgr:showTip(lang("GUILD_FAM_TIPS_28"))
		elseif result.status==3 then
			self._viewMgr:showTip(lang("GUILD_FAM_TIPS_29"))
		else
			self._viewMgr:showTip(lang("GUILD_FAM_TIPS_15"))
		end
	end)
end

return ChatGuildCell