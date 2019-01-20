--[[
    Filename:    ChatFullServerCell.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2016-05-20 12:26
    Description: 联盟单个cell
--]]

local ChatFullServerCell = class("ChatFullServerCell", cc.TableViewCell)

function ChatFullServerCell:ctor()
    self._viewMgr = ViewManager:getInstance()
    self._serverMgr = ServerManager:getInstance()
    self._modelMgr = ModelManager:getInstance()
    self._chatModel = self._modelMgr:getModel("ChatModel")
    self._leagueModel = self._modelMgr:getModel("LeagueModel")
    self._chooseObj = {}
end

function ChatFullServerCell:reflashUI(data, richText, width, height, isMyself, oldUI, callback)
    if not self._bg then
        self._bg = ccui.Layout:create()
        self._bg:setBackGroundColorOpacity(0)
        self._bg:setBackGroundColorType(1)
        self._bg:setBackGroundColor(cc.c3b(100, 100, 0))
        self._bg:setContentSize(width, height)
        self._bg:setPosition(0, 0)
        self:addChild(self._bg)
    end
    
    if richText:getParent() ~= nil then 
        local tempText = richText
        richText = cc.Node:create()
        richText:setContentSize(cc.size(tempText:getContentSize().width, tempText:getContentSize().height))
    end
    if richText.getRealSize == nil then 
        richText.getRealSize = richText.getContentSize
    end  

    self._data = data
    self._infoData = data.message
    self._callback = callback
    local isShowT = self._chatModel:checkIsShowTime(data)
    self._timeDisH = isShowT and 20 or 0
    local userData = data.message.udata

    --time
    if self._timeLab == nil then
        self._timeLab = cc.Label:createWithTTF("", UIUtils.ttfName, 18)
        self._timeLab:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
        self:addChild(self._timeLab)
    end

    self._timeLab:setVisible(false)
    local timeStr = ""
    if data.disT then
        local intT = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(data.t,"%Y-%m-%d 00:00:00"))
        if data.disT > 60 and data.disT < (data.t - intT) then
            self._timeLab:setVisible(true)
            timeStr = TimeUtils.date("%H:%M", data.t or 0)
        elseif data.disT >= (data.t - intT) then
            self._timeLab:setVisible(true)
            timeStr = TimeUtils.date("%m-%d %H:%M", data.t or 0)
        end        
    end
    self._timeLab:setPosition(width * 0.5 - 75, height - 14)
    self._timeLab:setString(timeStr)

    --headIcon
    if not self._avatar then
        local headP = {avatar = userData.avatar, level = userData.lvl or "0", tp = 4, eventStyle=1, avatarFrame=userData["avatarFrame"], plvl = userData.plvl}
        self._avatar = IconUtils:createHeadIconById(headP)
        self._avatar:setScale(0.64)
        self._avatar:setAnchorPoint(0, 1)
        self:addChild(self._avatar)
    else
        local headP = {avatar = userData.avatar, level = userData.lvl or "0", tp = 4, eventStyle=1, avatarFrame=userData["avatarFrame"], plvl = userData.plvl}
        IconUtils:updateHeadIconByView(self._avatar, headP)   
    end
    if isMyself == true then 
        self._avatar:setPosition(width - self._avatar:getContentSize().width * self._avatar:getScaleX() - 125, height - 5 - self._timeDisH)
        self._avatar:setTouchEnabled(false)
    else
        self._avatar:setTouchEnabled(true)
        self._avatar:setPosition(3, height - 5 -self._timeDisH)
        self:avatarClickCallback(data, oldUI)
    end

    --name
    if self._nameLab == nil then
        self._nameLab = cc.Label:createWithTTF("", UIUtils.ttfName, 20)
        self._nameLab:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
        self._nameLab:setAnchorPoint(0, 1)
        self:addChild(self._nameLab)
    end
    self._nameLab:setString(userData.name)

    if isMyself == true then 
        self._nameLab:setPosition(width - self._nameLab:getContentSize().width - 255 + 56, height - 9 - self._timeDisH)
    else
        self._nameLab:setPosition(132 - 56, height - 9 -self._timeDisH)
    end

    --vip
    userData.vipLvl = userData.vipLvl or 0
    if self._vipImg == nil then
        self._vipImg = cc.Sprite:createWithSpriteFrameName("chatPri_vipLv"..math.max(1, userData.vipLvl)..".png")  
        self._vipImg:setAnchorPoint(0, 1)
        self._vipImg:setScale(0.7)
        self:addChild(self._vipImg)
    end
    self._vipImg:setSpriteFrame("chatPri_vipLv".. math.max(1, userData.vipLvl) ..".png")
    self._vipImg:setVisible(userData.vipLvl > 0)

    if isMyself == true then
        self._vipImg:setPosition(width - self._nameLab:getContentSize().width - 236 , height - 10 - self._timeDisH)
    else
        self._vipImg:setPosition(140 + self._nameLab:getContentSize().width - 56, height - 7 - self._timeDisH)
    end

    --区服
    if self._secLab == nil then
        self._secLab = cc.Label:createWithTTF("", UIUtils.ttfName, 20)
        self._secLab:setColor(cc.c4b(120,120,120,255))
        self._secLab:setAnchorPoint(0, 1)
        self:addChild(self._secLab)
    end

    local serverName = self._leagueModel:getServerName(userData.sec)
    self._secLab:setString(serverName)

    if isMyself == true then 
        if self._vipImg:isVisible() then
            self._secLab:setPosition(self._vipImg:getPositionX() - self._secLab:getContentSize().width - 10, height - 9 - self._timeDisH)
        else
            self._secLab:setPosition(self._nameLab:getPositionX() - self._secLab:getContentSize().width - 10, height - 9 - self._timeDisH)
        end
        
    else
        if self._vipImg:isVisible() then
            self._secLab:setPosition(self._vipImg:getPositionX() + 36, height - 9 - self._timeDisH)
        else
            self._secLab:setPosition(self._nameLab:getPositionX() + self._nameLab:getContentSize().width + 10, height - 9 - self._timeDisH)
        end
    end

    --textBg
    if self._textBg == nil then
        self._textBg = cc.Scale9Sprite:createWithSpriteFrameName("chatImg_contextBg.png")
        self:addChild(self._textBg)
    end

    if self._myTextBg == nil then
        self._myTextBg = cc.Scale9Sprite:createWithSpriteFrameName("chatImg_contextBg1.png")
        self:addChild(self._myTextBg)
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
end

function ChatFullServerCell:avatarClickCallback(data, oldUI)
    local userData = data.message.udata
    registerTouchEvent(self._avatar, 
        function()  
            self._avatar.isLongC = false
            end,
        nil,
        function() 
            if self._avatar.isLongC then
                if self._callback then
                    self._callback(data)
                end
            else
                -- 获取玩家信息详情  hgf
                local fId = (userData.lvl and  userData.lvl >= 15) and 101 or 1
                ServerManager:getInstance():sendMsg("UserServer", "getTargetUserBattleInfo", {tagId = userData["rid"], fid = fId}, true, {}, function(result)                 
                    -- 打开聊天详情界面
                    self._viewMgr:showDialog("chat.DialogFriendHandle", 
                        {openType = "fSer", uiData = data, detailData = result, oldUI = oldUI}, true) 
                end)
            end
            
            end,
        nil,
        function() 
            self._avatar.isLongC = true
            end
        )
end

--创建语音
function ChatFullServerCell:createVoiceItem(data, richText, width, height, isMyself, oldUI)
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
            parentNode:setPosition(width - parentNode:getContentSize().width - 193, height - 40 - self._timeDisH)
        else
            parentNode:setPosition(70, height - 40 - self._timeDisH)
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
            parentNode:setPosition(width - parentNode:getContentSize().width - 193, height - 40 - self._timeDisH)
        else
            parentNode:setPosition(70, height - 40 - self._timeDisH)
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
function ChatFullServerCell:createOtherItem(data, richText, width, height, isMyself, oldUI)
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
        parentNode:setPosition(width - self._myTextBg:getContentSize().width - 193, height - 40 - self._timeDisH)
    else
        parentNode:setPosition(70, height - 40 - self._timeDisH)
    end
    
    if richText.restoreGif then 
        richText:restoreGif()
    end
    self.richText = richText
end

return ChatFullServerCell